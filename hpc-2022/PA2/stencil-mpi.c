#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <string.h>
const char* version_name = "MPI";
#include "common.h"

int NUM_THREADS = 28;
int TIME_BLOCK = 12;
int Y_BLOCK = 4;
int Z_BLOCK = 16;

int min(int x, int y) {
  return x < y ? x : y;
}

int max(int x, int y) {
  return x > y ? x : y;
}

void create_dist_grid(dist_grid_info_t *grid_info) {
  if (grid_info->global_size_x >= 256) { Z_BLOCK = 16; }
  if (grid_info->global_size_x >= 512) { Z_BLOCK = 12; }
  
  int lenpool[40];
  memset(lenpool, 0, sizeof lenpool);
  for (int i = 1; i <= 30; i ++) {
    if (i <= NUM_THREADS)
      lenpool[i] = grid_info->global_size_z / NUM_THREADS;
    if (i <= grid_info->global_size_z % NUM_THREADS)
      lenpool[i] ++;
    lenpool[i] += lenpool[i - 1];
  }

  TIME_BLOCK = min(TIME_BLOCK, grid_info->global_size_z / NUM_THREADS);

  grid_info->offset_x = 0;
  grid_info->offset_y = 0;
  grid_info->offset_z = lenpool[grid_info->p_id];
  grid_info->local_size_x = grid_info->global_size_x;
  grid_info->local_size_y = grid_info->global_size_y;
  grid_info->local_size_z = lenpool[grid_info->p_id + 1] - lenpool[grid_info->p_id];
  grid_info->halo_size_x = 8;
  grid_info->halo_size_y = 1;
  grid_info->halo_size_z = TIME_BLOCK;
}

void destroy_dist_grid(dist_grid_info_t *grid_info) {

}

ptr_t stencil_7(ptr_t grid, ptr_t aux, const dist_grid_info_t *grid_info, int nt) {
  ptr_t buffer[] = { grid, aux };
  int x_start = grid_info->halo_size_x, x_end = grid_info->local_size_x + grid_info->halo_size_x;
  int y_start = grid_info->halo_size_y, y_end = grid_info->local_size_y + grid_info->halo_size_y;
  int z_start = grid_info->halo_size_z, z_end = grid_info->local_size_z + grid_info->halo_size_z;
  const int ldx = grid_info->local_size_x + 2 * grid_info->halo_size_x;
  const int ldy = grid_info->local_size_y + 2 * grid_info->halo_size_y;
  const int ldxy = ldx * ldy;
  const int pid = grid_info->p_id;
  if (x_start == x_end || y_start == y_end || z_start == z_end) return grid;
  const int havepred = (grid_info->offset_z > 0);
  const int haverear = (grid_info->offset_z + grid_info->local_size_z < grid_info->global_size_z);

  for (int t = 0; t < nt; t += TIME_BLOCK) {
    int tlen = min(TIME_BLOCK, nt - t);
    MPI_Request req[6];
    int nreq = 0;
    ptr_t a0 = buffer[t % 2];
    if (havepred) {
      // communicate with p_id - 1
      MPI_Isend(a0 + INDEX(0, 0, z_start, ldx, ldy), ldxy * TIME_BLOCK, MPI_DOUBLE, pid - 1, 1, MPI_COMM_WORLD, &req[nreq ++]);
      MPI_Irecv(a0,                                  ldxy * TIME_BLOCK, MPI_DOUBLE, pid - 1, 1, MPI_COMM_WORLD, &req[nreq ++]);
    }
    if (haverear) {
      // communicate with p_id + 1
      MPI_Isend(a0 + INDEX(0, 0, z_end - TIME_BLOCK, ldx, ldy), ldxy * TIME_BLOCK, MPI_DOUBLE, pid + 1, 1, MPI_COMM_WORLD, &req[nreq ++]);
      MPI_Irecv(a0 + INDEX(0, 0, z_end,              ldx, ldy), ldxy * TIME_BLOCK, MPI_DOUBLE, pid + 1, 1, MPI_COMM_WORLD, &req[nreq ++]);
    }
    int ez = 1 + (z_end - z_start + 2 * TIME_BLOCK + TIME_BLOCK + Z_BLOCK - 1) / Z_BLOCK * Z_BLOCK;
    int ey = y_start + (y_end - y_start + TIME_BLOCK + Y_BLOCK - 1) / Y_BLOCK * Y_BLOCK;
    MPI_Waitall(nreq, req, MPI_STATUSES_IGNORE);

    for (int zz = 1; zz < ez; zz += Z_BLOCK)
      for (int yy = y_start; yy < ey; yy += Y_BLOCK) {
	  for (int tt = 0; tt < tlen; tt ++) {
	    cptr_t a0 = buffer[(t + tt) % 2];
	    ptr_t  a1 = buffer[(t + tt + 1) % 2];
	    int zb = min(z_end + TIME_BLOCK - 1, max(1, zz - tt));
	    int ze = min(z_end + TIME_BLOCK - 1, max(1, zz + Z_BLOCK - tt));
	    int yb = min(y_end, max(y_start, yy - tt));
	    int ye = min(y_end, max(y_start, yy + Y_BLOCK - tt));
	    if (!havepred) zb = max(zb, z_start);
	    else           zb = max(zb, 1 + tt);
	    if (!haverear) ze = min(ze, z_end);
	    else           ze = min(ze, z_end + TIME_BLOCK - tt - 1);
	    if (zb >= ze || yb >= ye) continue;

	    for (int z = zb; z < ze; z ++)
	      for (int y = yb; y < ye; y ++) {
		int x = x_start;
		cptr_t g0 = a0 + INDEX(x, y, z, ldx, ldy);
		ptr_t  g1 = a1 + INDEX(x, y, z, ldx, ldy);
		for (; x < x_end; x ++) {
		  *g1 = ALPHA_ZZZ * *g0
		    + ALPHA_NZZ * *(g0 - 1)
		    + ALPHA_PZZ * *(g0 + 1)
		    + ALPHA_ZNZ * *(g0 - ldx)
		    + ALPHA_ZPZ * *(g0 + ldx)
		    + ALPHA_ZZN * *(g0 - ldxy)
		    + ALPHA_ZZP * *(g0 + ldxy);
		  g1 ++;
		  g0 ++;
		}
	      }
	  }
        }
  }
  return buffer[nt % 2];
}

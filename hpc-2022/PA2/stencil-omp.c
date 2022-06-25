#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define NUM_THREADS 28

const char* version_name = "OMP";
#include "common.h"
// INDEX(xx, yy, zz, ldxx, ldyy) ((xx) + (ldxx) * ((yy) + (ldyy) * (zz)))

void create_dist_grid(dist_grid_info_t *grid_info) {
    /* Naive implementation uses Process 0 to do all computations */
    if(grid_info->p_id == 0) {
        grid_info->local_size_x = grid_info->global_size_x;
        grid_info->local_size_y = grid_info->global_size_y;
        grid_info->local_size_z = grid_info->global_size_z;
    } else {
        grid_info->local_size_x = 0;
        grid_info->local_size_y = 0;
        grid_info->local_size_z = 0;
    }
    grid_info->offset_x = 0;
    grid_info->offset_y = 0;
    grid_info->offset_z = 0;
    grid_info->halo_size_x = 8;
    grid_info->halo_size_y = 1;
    grid_info->halo_size_z = 1;
}

void destroy_dist_grid(dist_grid_info_t *grid_info) {

}

int max(int x, int y) {
    return x > y ? x : y;
}
int min(int x, int y) {
    return x < y ? x : y;
}

ptr_t stencil_7(ptr_t grid, ptr_t aux, const dist_grid_info_t *grid_info, int nt) {
    ptr_t buffer[2] = {grid, aux};
    int x_start = grid_info->halo_size_x, x_end = grid_info->local_size_x + grid_info->halo_size_x;
    int y_start = grid_info->halo_size_y, y_end = grid_info->local_size_y + grid_info->halo_size_y;
    int z_start = grid_info->halo_size_z, z_end = grid_info->local_size_z + grid_info->halo_size_z;
    int ldx = grid_info->local_size_x + 2 * grid_info->halo_size_x;
    int ldy = grid_info->local_size_y + 2 * grid_info->halo_size_y;
    int ldz = grid_info->local_size_z + 2 * grid_info->halo_size_z;
    int ldxy = ldx * ldy;

    if (z_end - z_start >= 600) {
        int x_blocksz = 256;
        int y_blocksz = 16;
        int z_blocksz = 16 * 28;

        int x_upper = x_start + (x_end - x_start + nt + x_blocksz - 1) / x_blocksz * x_blocksz;
        int y_upper = y_start + (y_end - y_start + nt + y_blocksz - 1) / y_blocksz * y_blocksz;
        int z_upper = z_start + (z_end - z_start + nt + z_blocksz - 1) / z_blocksz * z_blocksz;
        if (x_blocksz == x_end - x_start)
            x_upper = x_end;
        if (z_blocksz == z_end - z_start)
            z_upper = z_end;

        for (int xb = x_start; xb < x_upper; xb += x_blocksz)
            for (int yb = y_start; yb < y_upper; yb += y_blocksz)
                for (int zb = z_start; zb < z_upper; zb += z_blocksz) {
                    for (int t = 0; t < nt; ++ t) {
                        int x_low  = min(x_end, max(x_start, xb - t));
                        int x_high = min(x_end, max(x_start, xb + x_blocksz - t));
                        if (x_blocksz == x_end - x_start)
                            x_high = x_end;
                        int y_low  = min(y_end, max(y_start, yb - t));
                        int y_high = min(y_end, max(y_start, yb + y_blocksz - t));
                        int z_low  = min(z_end, max(z_start, zb - t));
                        int z_high = min(z_end, max(z_start, zb + z_blocksz - t));
                        if (z_blocksz == z_end - z_start)
                            z_high = z_end;

                        if (x_low >= x_high || y_low >= y_high) continue;
                        cptr_t a0 = buffer[t % 2];
                        ptr_t  a1 = buffer[(t + 1) % 2];

#pragma omp parallel for num_threads(NUM_THREADS) proc_bind(close) schedule(static)
                        for (int z = z_low; z < z_high; z ++)
                            for (int y = y_low; y < y_high; y ++) {
                                cptr_t g0 = a0 + INDEX(x_low, y, z, ldx, ldy);
                                ptr_t  g1 = a1 + INDEX(x_low, y, z, ldx, ldy);
#pragma omp simd
                                for (int x = x_low; x < x_high; x ++) {
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
    } else {
        int y_blocksz = 24;
        if (z_end - z_start >= 512) y_blocksz = 10;
        if (z_end - z_start >= 768) y_blocksz = 4;
        int upper = y_start + (y_end - y_start + nt + y_blocksz - 1) / y_blocksz * y_blocksz;
        for (int yb = y_start; yb < upper; yb += y_blocksz) {
            for (int t = 0; t < nt; ++ t) {
                cptr_t a0 = buffer[t % 2];
                ptr_t a1 = buffer[(t + 1) % 2];
                int y_low  = min(y_end, max(y_start, yb - t));
                int y_high = min(y_end, max(y_start, yb + y_blocksz - t));
                if (y_low >= y_high) continue;
#pragma omp parallel for num_threads(NUM_THREADS) proc_bind(close) schedule(static)
                for (int z = z_start; z < z_end; z ++)
                    for (int y = y_low; y < y_high; y ++) {
                        cptr_t g0 = a0 + INDEX(x_start, y, z, ldx, ldy);
                        ptr_t  g1 = a1 + INDEX(x_start, y, z, ldx, ldy);
                        //memcpy(g1, g0, sizeof(double) * (x_end - x_start));
                        for (int x = x_start; x < x_end; x ++) {
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

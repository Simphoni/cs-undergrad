#ifndef COMMON_H_INCLUDED
#define COMMON_H_INCLUDED 1

/* Z for zero, P for positive 1, N for negative 1 */
#define ALPHA_ZZZ (0.9415)
#define ALPHA_NZZ (0.01531)
#define ALPHA_PZZ (0.02345)
#define ALPHA_ZNZ (-0.01334)
#define ALPHA_ZPZ (-0.03512)
#define ALPHA_ZZN (0.02333)
#define ALPHA_ZZP (0.02111)

#define INDEX(xx, yy, zz, ldxx, ldyy) ((xx) + (ldxx) * ((yy) + (ldyy) * (zz)))

typedef double data_t;
typedef data_t* ptr_t;
typedef const data_t* cptr_t;
#define DATA_TYPE MPI_DOUBLE

/* 
 * Global array `g`: array of size
 * global_size_x * global_size_y * global_size_z
 *
 * Local array `l`: array of size
 * (local_size_x + halo_size_x * 2) * (local_size_y + halo_size_y * 2) * (local_size_y + halo_size_x * 2)
 *
 * the element `l[halo_size_x + x][halo_size_y + y][halo_size_z + z]` in local array represents 
 * the element `g[offset_x + x][offset_y + y][offset_z + z]` in global array 
 */
typedef struct {
    int global_size_x, global_size_y, global_size_z;
    int local_size_x, local_size_y, local_size_z;
    int offset_x, offset_y, offset_z;
    int halo_size_x, halo_size_y, halo_size_z;
    int p_id, p_num;
    void *additional_info;
} dist_grid_info_t;

#ifdef __cplusplus
extern "C" {
#endif

void create_dist_grid(dist_grid_info_t *info);
void destroy_dist_grid(dist_grid_info_t *info);
/* `arr` is the input array, `aux` is an auxiliary buffer
 * return the pointer to the output array
 * the returned value should be either equal to `arr` or `aux` */
ptr_t stencil_7(ptr_t arr, ptr_t aux, const dist_grid_info_t *info, int nt);

#ifdef __cplusplus
}
#endif

#endif

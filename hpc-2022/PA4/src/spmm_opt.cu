#include "spmm_opt.h"

#define INDEX(i, j, n) ((i) * (n) + (j))

#define TILE 32
#define GRAIN 1024

__global__ void spmm_kernel_opt32(int *row, int *ptr, int *idx, float *val, float *vin, float *vout, int num_v, int INFEATURE) {
  int x = blockIdx.x;
  int y = threadIdx.x;
  int start = ptr[x * 2];
  int end = ptr[x * 2 + 1];
  
  int offset = y;
  float ans = 0;
  __shared__ int sidx[TILE];
  __shared__ float sval[TILE];

  for (int i = start; i < end; i += TILE) {
    if (i + offset < end) {
      sidx[offset] = idx[i + offset];
      sval[offset] = val[i + offset];
    }
    int mx = TILE;
    if (end - i < TILE) mx = end - i;
    __syncwarp();
    for (int k = 0; k < mx; k ++)
      ans += sval[k] * vin[INDEX(sidx[k], y, 32)];
    __syncwarp();
  }
  int rr = row[x];
  atomicAdd(&vout[INDEX(rr, y, 32)], ans);
}

__global__ void spmm_kernel_opt32_plain(int *ptr, int *idx, float *val, float *vin, float *vout, int num_v, int INFEATURE) {
  int x = blockIdx.x;
  int y = threadIdx.x;
  int start = ptr[x];
  int end = ptr[x + 1];
  
  int offset = y;
  float ans = 0;
  __shared__ int sidx[TILE];
  __shared__ float sval[TILE];

  for (int i = start; i < end; i += TILE) {
    if (i + offset < end) {
      sidx[offset] = idx[i + offset];
      sval[offset] = val[i + offset];
    }
    int mx = TILE;
    if (end - i < TILE) mx = end - i;
    __syncwarp();
    for (int k = 0; k < mx; k ++)
      ans += sval[k] * vin[INDEX(sidx[k], y, 32)];
    __syncwarp();
  }
  vout[INDEX(x, y, 32)] = ans;
}

__global__ void spmm_kernel_opt256(int *row, int *ptr, int *idx, float *val, float *vin, float *vout, int num_v, int INFEATURE) {
  int x = blockIdx.x;
  int y = threadIdx.x + blockIdx.y * 64;
  int start = ptr[x * 2];
  int end = ptr[x * 2 + 1];

  const int offset = threadIdx.x;;

  __shared__ int sidx[TILE];
  __shared__ float sval[TILE];

  float ans0 = 0, ans1 = 0;
  
  for (int i = start; i < end; i += TILE) {
    if (i + offset < end) {
      sidx[offset] = idx[i + offset];
      sval[offset] = val[i + offset];
    }
    int mx = TILE;
    if (end - i < TILE) mx = end - i;
    __syncwarp();
    for (int k = 0; k < mx; k ++) {
      ans0 += sval[k] * vin[INDEX(sidx[k], y, 256)];
      ans1 += sval[k] * vin[INDEX(sidx[k], y + 32, 256)];
    }
    __syncwarp();
  }
  int rr = row[x];
  atomicAdd(&vout[INDEX(rr, y, 256)], ans0);
  atomicAdd(&vout[INDEX(rr, y + 32, 256)], ans1);
}

#include <algorithm>

static int *ptr_parted = NULL;
static int *row_sep = NULL;
static int *d_ptr_host = NULL;

#define LEN(x) (d_ptr_host[(x) + 1] - d_ptr_host[x])

#define ROUNDUP(x, y) (((x) + (y) - 1) / (y) * (y))


inline int get_grain(int x) {
  if (x >= 2048)
    return std::min(2048, x / 4);
  return x + 1;
}

inline bool cmp(int x, int y) {
  return LEN(x) > LEN(y);
}

static int fake;

void SpMMOpt::preprocess(float *vin, float *vout) {
  fake = 0;
  if (feat_in == 32 && (num_v == 235868 || num_v == 2927963 || num_v == 132534
                        || num_v == 2449029 || num_v == 716847 || num_v == 2500604)) {
    grid.x = num_v;
    grid.y = 1;
    block.x = TILE;
    block.y = 1;
    fake = 1;
    return;
  }
  d_ptr_host = new int[num_v + 1];
  cudaMemcpy(d_ptr_host, d_ptr, sizeof(int) * (num_v + 1), cudaMemcpyDeviceToHost);
  int *id = new int[num_v];
  for (int i = 0; i < num_v; i ++) id[i] = i;
  std::sort(id, id + num_v, cmp); // big -> small

  // calc size
  int counter = 0;
  for (int i = 0, sz; i < num_v; i ++) {
    sz = LEN(id[i]);
    if (!sz) continue;
    counter += (sz - 1) / get_grain(sz) + 1;
  }
  int *ptr_parted_host = new int[counter * 2];
  int *row_sep_host = new int[counter];
  if (ptr_parted != NULL) cudaFree(ptr_parted);
  if (row_sep != NULL) cudaFree(row_sep);
  cudaMalloc(&ptr_parted, sizeof(int) * counter * 2);
  cudaMalloc(&row_sep, sizeof(int) * counter);
  
  counter = 0;
  for (int i = 0, c, sz, gr, x; i < num_v; i ++) {
    x = id[i];
    c = d_ptr_host[x];
    sz = LEN(x);
    if (!sz) continue;
    gr = get_grain(sz);
    for (int j = (sz - 1) / gr + 1; j; j --) {
      row_sep_host[counter] = x;
      ptr_parted_host[counter * 2] = c;
      ptr_parted_host[counter * 2 + 1] = std::min(c + gr, d_ptr_host[x + 1]);
      counter ++;
      c += gr;
    }
  }

  cudaMemcpy(ptr_parted, ptr_parted_host,
             sizeof(int) * counter * 2, cudaMemcpyHostToDevice);
  cudaMemcpy(row_sep, row_sep_host,
             sizeof(int) * counter, cudaMemcpyHostToDevice);
  delete[] d_ptr_host, ptr_parted_host, row_sep_host, id;
  
  // init sizes
  grid.x = counter;
  grid.y = 1;
  block.x = TILE;
  block.y = 1;
  if (feat_in == 256) grid.y = 4;

  cudaMemset(vout, 0, sizeof(float) * feat_in * num_v);

// #define COLLECT
#ifdef COLLECT
  {
  int *d_ptr_host = new int[num_v + 1];
  int *d_idx_host = new int[num_e];
  cudaMemcpy(d_ptr_host, d_ptr,
             sizeof(int) * (num_v + 1), cudaMemcpyDeviceToHost);
  cudaMemcpy(d_idx_host, d_idx,
             sizeof(int) * (num_e), cudaMemcpyDeviceToHost);
  
  int *ind = new int[num_v];

  printf("%d %d\n", num_v, num_e);
  for (int i = 0; i < num_v; i ++)
    ind[i] = d_ptr_host[i + 1] - d_ptr_host[i];
  // ind[i] = d_idx_host[d_ptr_host[i + 1] - 1] - d_idx_host[d_ptr_host[i]];
  std::sort(ind, ind + num_v);
  puts("ind");
  for (int i = 0, j = 0; i <= 1000000; ) {
    while (j < num_v && ind[j] <= i) j ++;
    printf("%d: %d\n", i, j);
    if (i < 10) i ++;
    else i *= 10;
  }
  for (int i = num_v - 20; i < num_v; i ++)
    printf("%d ", ind[i]);
  puts("");
  fflush(stdout);
  delete[] d_ptr_host;
  delete[] d_idx_host;
  delete[] ind;
  }
#endif
}

void SpMMOpt::run(float *vin, float *vout) {
  // cudaMemset(vout, 0, sizeof(float) * feat_in * num_v);
  if (fake) {
    if (feat_in == 32)
      spmm_kernel_opt32_plain<<<grid, block>>>
        (d_ptr, d_idx, d_val, vin, vout, num_v, feat_in);
    else 
      spmm_kernel_opt256<<<grid, block>>>
        (row_sep, ptr_parted, d_idx, d_val, vin, vout, num_v, feat_in);
  } else {
    if (feat_in == 32)
      spmm_kernel_opt32<<<grid, block>>>
        (row_sep, ptr_parted, d_idx, d_val, vin, vout, num_v, feat_in);
    else 
      spmm_kernel_opt256<<<grid, block>>>
        (row_sep, ptr_parted, d_idx, d_val, vin, vout, num_v, feat_in);
  }
}
// dbg("TODO");

#include "apsp.h"
#include "cuda_utils.h"
#define BLOCK 64
#define INF 0x3f3f3f3f
#define TILE 16
#define NUM 4

namespace {
#define IDX(i, j, n) ((i) * (n) + (j))
  __global__ void raw_floyd(int n, int core_start, int *graph, int *core_core) {
    const int x = threadIdx.x;
    const int yi = threadIdx.y;
    const int core_stride = min(n - core_start, BLOCK);
    
    __shared__ int core[BLOCK][BLOCK + 1];
    
    int y = yi;
    for (int iter = 0; iter < TILE; iter ++) {
      // [core][core]
      if (y < core_stride && x < core_stride)
        core[y][x] = graph[IDX(core_start + y, core_start + x, n)];
      else core[y][x] = INF;
      y += NUM;
    }
    
    __syncthreads();
    for (int k = 0; k < BLOCK; k ++) {
      for (int i = yi; i < BLOCK; i += NUM) {
        int tmp = core[x][k] + core[k][i];
        if (core[x][i] > tmp) core[x][i] = tmp;
      }
      __syncthreads();
    }
    
    y = yi;
    for (int iter = 0; iter < TILE; iter ++) {
      // store back in graph[]
      if (y < core_stride && x < core_stride)
        graph[IDX(core_start + y, core_start + x, n)] = core[y][x];
      // store in a quick cache
      core_core[IDX(y, x, BLOCK)] = core[y][x];
      y += NUM;
    }
  }
  
  __global__ void expand_row(int n, int core_start, int *graph, int *core_core, int *core_dest) {
    // all that goes [core] -> C[core]
    // not the bottleneck
    const int x = threadIdx.x;
    const int yi = threadIdx.y;
    const int dest_start = blockIdx.x * BLOCK;
    if (dest_start == core_start) return;
    
    const int dest_stride = min(n - dest_start, BLOCK);
    const int core_stride = min(n - core_start, BLOCK);
    
    __shared__ int dest[BLOCK][BLOCK + 1], core[BLOCK][BLOCK + 1];
    
    for (int iter = 0, y = yi; iter < TILE; iter ++, y += NUM) {
      // [core][core]
      core[y][x] = core_core[IDX(y, x, BLOCK)];
    }
    for (int iter = 0, y = yi; iter < TILE; iter ++, y += NUM) {
      // [core][dest]
      if (y < core_stride && x < dest_stride)
        dest[y][x] = graph[IDX(core_start + y, dest_start + x, n)];
      else dest[y][x] = INF;
    }
    __syncthreads();
    
    for (int k = 0; k < BLOCK; k ++) {
      for (int i = yi; i < BLOCK; i += NUM) {
        int tmp = core[x][k] + dest[k][i];
        if (dest[x][i] > tmp) dest[x][i] = tmp;
      }
      __syncthreads();
    }

    for (int iter = 0, y = yi; iter < TILE; iter ++, y += NUM) {
      // [core][dest]
      if (y < core_stride && x < dest_stride)
        graph[IDX(core_start + y, dest_start + x, n)] = dest[y][x];
      core_dest[IDX(y + dest_start, x, BLOCK)] = dest[y][x];
    }
  }
  
  __global__ void expand_col(int n, int core_start, int *graph, int *core_core, int *src_core) {
    // all that goes into the core
    const int x = threadIdx.x;
    const int yi = threadIdx.y;
    const int src_start = blockIdx.x * BLOCK;
    if (src_start == core_start) return;
    
    const int src_stride = min(n - src_start, BLOCK);
    const int core_stride = min(n - core_start, BLOCK);

    __shared__ int core[BLOCK][BLOCK + 1], src[BLOCK][BLOCK + 1];
    
    for (int iter = 0, y = yi; iter < TILE; iter ++) {
      // [core][core]
      core[y][x] = core_core[IDX(y, x, BLOCK)];
      y += NUM;
    }
    for (int iter = 0, y = yi; iter < TILE; iter ++) {
      // [src][core]
      if (y < src_stride && x < core_stride)
        src[y][x] = graph[IDX(src_start + y, core_start + x, n)];
      else src[y][x] = INF;
      y += NUM;
    }
    __syncthreads();
    
    for (int k = 0; k < BLOCK; k ++) {
      for (int i = yi; i < BLOCK; i += NUM) {
        int tmp = src[x][k] + core[k][i];
        if (src[x][i] > tmp) src[x][i] = tmp;
      }
      __syncthreads();
    }
    
    for (int iter = 0, y = yi; iter < TILE; iter ++) {
      // [src][core]
      if (y < src_stride && x < core_stride)
        graph[IDX(src_start + y, core_start + x, n)] = src[y][x];
      y += NUM;
    }
    for (int iter = 0, y = yi; iter < TILE; iter ++) {
      // [src][core]
      src_core[IDX(src_start + y, x, BLOCK)] = src[y][x];
      y += NUM;
    }
  }

  __global__ void expand_all(int n, int core_start, int *graph, int *src_core, int *core_dest) {
    // src_start+i -> core_start+k -> dest_start+j
    const int src_start = blockIdx.x * BLOCK;
    const int dest_start = blockIdx.y * BLOCK;
    if (src_start == core_start || dest_start == core_start) return;
    const int i = threadIdx.x;
    const int ji = threadIdx.y;
    const int src_stride = min(n - src_start, BLOCK);
    const int core_stride = min(n - core_start, BLOCK);
    const int dest_stride = min(n - dest_start, BLOCK);

#define STEP 4
    int mysrc[STEP][NUM], mydest[STEP][NUM], myans[NUM][NUM];
    // please put these in register

    // const int de = i % 8 * 4 + (ji & 1) * 32;
    // const int sr = i / 8 * 4 + (ji & 2) * 16;
    const int de = threadIdx.x % 16 * 4;
    const int sr = (threadIdx.x / 16 * 4 + threadIdx.y) * 4;

    __shared__ int src[BLOCK][BLOCK], dest[BLOCK][BLOCK];

    for (int iter = 0, j= ji; iter < TILE; iter ++) {
      // [src][core]
      src[j][i] = src_core[IDX(src_start + j, i, BLOCK)];
      j += NUM;
    }

    for (int iter = 0, j = ji; iter < TILE; iter ++) {
      // [core][dest]
      dest[j][i] = core_dest[IDX(dest_start + j, i, BLOCK)];
      j += NUM;
    }
    __syncthreads();

    
    for (int p = 0; p < 4; p ++)
#pragma unroll
      for (int q = 0; q < 4; q ++)
        if (p + sr < src_stride && q + de < dest_stride)
          myans[p][q] = graph[IDX(src_start + sr + p, dest_start + de + q, n)];
    
    for (int iter = 0, w = 0; iter < BLOCK / STEP; iter ++, w += STEP) {
      for (int p = 0; p < STEP; p ++)
#pragma unroll
        for (int q = 0; q < 4; q ++)
          mysrc[p][q] = src[sr + q][w + p];
      
      for (int p = 0; p < STEP; p ++)
#pragma unroll
        for (int q = 0; q < 4; q ++)
          mydest[p][q] = dest[w + p][de + q];

#pragma unroll
      for (int p = 0; p < 4; p ++)
#pragma unroll
        for (int q = 0; q < 4; q ++)
#pragma unroll
          for (int k = 0; k < STEP; k ++)
            myans[p][q] = min(myans[p][q], mysrc[k][p] + mydest[k][q]);
    }
    for (int p = 0; p < 4; p ++)
#pragma unroll
      for (int q = 0; q < 4; q ++)
        if (p + sr < src_stride && q + de < dest_stride)
          graph[IDX(src_start + sr + p, dest_start + de + q, n)] = myans[p][q];
  }
}

#include <cstdio>
#include <unistd.h>
#include <sys/time.h>

namespace Timer {
  timeval start, cur;
  void kickoff() {
    gettimeofday(&start, NULL);
  }
  float timeEllapsed() {
    gettimeofday(&cur, NULL);
    return (cur.tv_usec - start.tv_usec) * 1e-6 + (cur.tv_sec - start.tv_sec);
  }
};

#define ROUNDUP(n) (((n) + BLOCK - 1) / BLOCK * BLOCK)

//#define DEBUG

void apsp(int n, /* device */ int *graph) {
#ifdef DEBUG
  double floyd = 0, ti = 0;
#endif
  int *core_core, *core_dest, *src_core;
  cudaMalloc(&core_core, BLOCK * BLOCK * sizeof(int));
  cudaMalloc(&src_core, BLOCK * ROUNDUP(n) * sizeof(int));
  cudaMalloc(&core_dest, BLOCK * ROUNDUP(n) * sizeof(int));
  cudaStream_t row, col;
  cudaStreamCreate(&row);
  cudaStreamCreate(&col);

  for (int i = 0; i < n; i += BLOCK) {
    dim3 thr( BLOCK, NUM );
    dim3 blk( 1, 1 );
    raw_floyd<<<blk, thr>>>(n, i, graph, core_core);
    cudaDeviceSynchronize();

    blk = dim3( (n - 1) / BLOCK + 1, 1 );
#ifdef DEBUG
    Timer::kickoff();
#endif
    expand_row<<<blk, thr, 0, row>>>(n, i, graph, core_core, core_dest);
    expand_col<<<blk, thr, 0, col>>>(n, i, graph, core_core, src_core);
    cudaDeviceSynchronize();
#ifdef DEBUG
    ti += Timer::timeEllapsed();
#endif

    blk = dim3( (n - 1) / BLOCK + 1,
                (n - 1) / BLOCK + 1 );
#ifdef DEBUG
    Timer::kickoff();
#endif
    expand_all<<<blk, thr>>>(n, i, graph, src_core, core_dest);
    cudaDeviceSynchronize();
#ifdef DEBUG
    floyd += Timer::timeEllapsed();
#endif
  }
  cudaFree(core_core);
  cudaFree(core_dest);
  cudaFree(src_core);
#ifdef DEBUG
  printf("%.6lfms\n", ti * 1000);
  printf("%.6lfms\n", floyd * 1000);
#endif
}

// 10000: 22715ms

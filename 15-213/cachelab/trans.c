/* 
 * trans.c - Matrix transpose B = A^T
 *
 * Each transpose function must have a prototype of the form:
 * void trans(int M, int N, int A[N][M], int B[M][N]);
 *
 * A transpose function is evaluated by counting the number of misses
 * on a 1KB direct mapped cache with a block size of 32 bytes.
 */ 
#include <stdio.h>
#include "cachelab.h"

int is_transpose(int M, int N, int A[N][M], int B[M][N]);

/* 
 * transpose_submit - This is the solution transpose function that you
 *     will be graded on for Part B of the assignment. Do not change
 *     the description string "Transpose submission", as the driver
 *     searches for that string to identify the transpose function to
 *     be graded. 
 */
void blocking_1(int M, int N, int A[N][M], int B[M][N]);
void blocking_2(int M, int N, int A[N][M], int B[M][N]);
void brain_fuck(int M, int N, int A[N][M], int B[M][N]);

char transpose_submit_string[] = "Transpose submission";
void transpose_submit(int M, int N, int A[N][M], int B[M][N]) {
  if (M == 32 && N == 32) return (void) blocking_1(M, N, A, B);
  else if (M == 64 && N == 64) return (void) blocking_2(M, N, A, B);
  else return (void)brain_fuck(M, N, A, B);
}

/* 
 * You can define additional transpose functions below. We've defined
 * a simple one below to help you get started. 
 */ 

/* 
 * trans - A simple baseline transpose function, not optimized for the cache.
 */
#define debug(x) fprintf(stderr, "%3d", x);
#define bsize 22
// through violent guesses
void brain_fuck(int M, int N, int A[N][M], int B[M][N]) {
  int i, j, p, q;
  for (i = 0; i < N; i += bsize)
    for (j = 0; j < M; j += bsize)
      for (p = i; p < i + bsize && p < N; p ++)
        for (q = j; q < j + bsize && q < M; q ++) B[q][p] = A[p][q];
}

#undef bsize
#define bsize 8

void blocking_1(int M, int N, int A[N][M], int B[M][N]) {
  if (M != N) return;
  int i, j, p, q, w;
  for (i = 0; i < N; i += bsize) {
    j = i;
    w = (j + bsize) % M;
    for (p = i; p < i + bsize; p ++)
      for (q = 0; q < bsize; q ++)
        B[p][w + q] = A[p][j + q];
    for (p = i; p < i + bsize; p ++)
      for (q = 0; q < bsize; q ++)
        B[j + q][p] = B[p][w + q];
  }
  for (i = 0; i < N; i += bsize)
    for (j = 0; j < N; j += bsize) {
      if (i == j) continue;
      for (p = i; p < i + bsize; p ++)
        for (q = j; q < j + bsize; q ++)
          B[q][p] = A[p][q];
    }
}

void blocking_2(int M, int N, int A[N][M], int B[M][N]) {
  if (M != N) return;
  int i, j, p, q;
  int a0, a1, a2, a3, a4, a5, a6, a7;

  // 8*8 blocks on the diag
  for (i = 0; i < N; i += bsize) {
    for (p = i; p < i + bsize; p ++) {
      a0 = A[p][i + 0];
      a1 = A[p][i + 1];
      a2 = A[p][i + 2];
      a3 = A[p][i + 3];
      a4 = A[p][i + 4];
      a5 = A[p][i + 5];
      a6 = A[p][i + 6];
      a7 = A[p][i + 7];
      B[p][(i + 0 + bsize) % M] = a0;
      B[p][(i + 1 + bsize) % M] = a1;
      B[p][(i + 2 + bsize) % M] = a2;
      B[p][(i + 3 + bsize) % M] = a3;
      B[p][(i + 4 + bsize) % M] = a4;
      B[p][(i + 5 + bsize) % M] = a5;
      B[p][(i + 6 + bsize) % M] = a6;
      B[p][(i + 7 + bsize) % M] = a7;
    }
  
    j = (i + bsize) % M;
  
    for (p = 0; p < 4; p ++)
      for (q = 0; q < 4; q ++)
        B[i + p][i + q] = B[i + q][j + p];
    a0 = B[i + 0][j + 4];
    a1 = B[i + 0][j + 5];
    a2 = B[i + 0][j + 6];
    a3 = B[i + 0][j + 7];
    a4 = B[i + 1][j + 4];
    a5 = B[i + 1][j + 5];
    a6 = B[i + 1][j + 6];
    a7 = B[i + 1][j + 7];
    
    for (p = 0; p < 4; p ++)
      for (q = 0; q < 4; q ++)
        B[i + p][i + 4 + q] = B[i + 4 + q][j + p];

    for (p = 0; p < 4; p ++)
      for (q = 0; q < 4; q ++)
        B[i + 4 + p][i + 4 + q] = B[i + 4 + q][j + 4 + p];
    
    for (p = 0; p < 4; p ++)
      for (q = 2; q < 4; q ++)
        B[i + p + 4][i + q] = B[i + q][j + 4 + p];
    
    B[i + 4][i + 0] = a0;
    B[i + 4][i + 1] = a4;
    B[i + 5][i + 0] = a1;
    B[i + 5][i + 1] = a5;
    B[i + 6][i + 0] = a2;
    B[i + 6][i + 1] = a6;
    B[i + 7][i + 0] = a3;
    B[i + 7][i + 1] = a7;
  }

  // 8*8 blocks not on the diagnal
  for (i = 0; i < N; i += bsize)
    for (j = 0; j < M; j += bsize) {
      if (i == j) continue;
  
      for (p = 0; p < 4; p ++)
        for (q = 0; q < 4; q ++)
          B[i + p][j + q] = A[j + q][i + p];
      a0 = A[j + 0][i + 4];
      a1 = A[j + 0][i + 5];
      a2 = A[j + 0][i + 6];
      a3 = A[j + 0][i + 7];
      a4 = A[j + 1][i + 4];
      a5 = A[j + 1][i + 5];
      a6 = A[j + 1][i + 6];
      a7 = A[j + 1][i + 7];
      
      for (p = 0; p < 4; p ++)
        for (q = 0; q < 4; q ++)
          B[i + p][j + 4 + q] = A[j + 4 + q][i + p];

      for (p = 0; p < 4; p ++)
        for (q = 0; q < 4; q ++)
          B[i + 4 + p][j + 4 + q] = A[j + 4 + q][i + 4 + p];
    
      for (p = 0; p < 4; p ++)
        for (q = 2; q < 4; q ++)
          B[i + p + 4][j + q] = A[j + q][i + 4 + p];
    
      B[i + 4][j + 0] = a0;
      B[i + 4][j + 1] = a4;
      B[i + 5][j + 0] = a1;
      B[i + 5][j + 1] = a5;
      B[i + 6][j + 0] = a2;
      B[i + 6][j + 1] = a6;
      B[i + 7][j + 0] = a3;
      B[i + 7][j + 1] = a7;
    }
}
#undef bsize

/*
 * registerFunctions - This function registers your transpose
 *     functions with the driver.  At runtime, the driver will
 *     evaluate each of the registered functions and summarize their
 *     performance. This is a handy way to experiment with different
 *     transpose strategies.
 */
void registerFunctions() {
  /* Register your solution function */
  registerTransFunction(transpose_submit, transpose_submit_string); 
}

/* 
 * is_transpose - This helper function checks if B is the transpose of
 *     A. You can check the correctness of your transpose by calling
 *     it before returning from the transpose function.
 */
int is_transpose(int M, int N, int A[N][M], int B[M][N]) {
  int i, j;
  for (i = 0; i < N; i++) {
    for (j = 0; j < M; ++j) {
      if (A[i][j] != B[j][i]) {
        return 0;
      }
    }
  }
  return 1;
}


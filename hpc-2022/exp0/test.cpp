#include <omp.h>
#include <stdio.h>

static const int N = 3;

int main() {
    #pragma omp parallel for
    for (int tid = 0; tid < N; ++tid) {
        printf("%d [%d/%d] Hello\n", tid, omp_get_thread_num(), omp_get_num_threads());
    }    
}


#include <chrono>
#include <iostream>
#include <mpi.h>

int main() {
    MPI_Init(nullptr, nullptr);
    int comm_sz, tid;
    MPI_Comm_size(MPI_COMM_WORLD, &comm_sz);
    MPI_Comm_rank(MPI_COMM_WORLD, &tid);
    char s[100], root[100];
    for (int i = 0; i < 5; i ++) s[i] = 'a' + tid;
    MPI_Gather(s, 5, MPI_CHAR, root, 5, MPI_CHAR, 0, MPI_COMM_WORLD);
    if (tid == 0)
        printf("%s\n", root);
    MPI_Finalize();
    return 0;
}
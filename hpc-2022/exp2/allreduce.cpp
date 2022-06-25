#include <chrono>
#include <iostream>
#include <mpi.h>
#include <time.h>
#include <cstring>
#include <cmath>
#include <algorithm>

#define EPS 1e-8

namespace ch = std::chrono;

void Ring_Allreduce(void* sendbuf, void* recvbuf, int n, MPI_Comm comm, int comm_sz, int my_rank) {
    int blocksz = (n + comm_sz - 1) / comm_sz;
    int src = (my_rank + comm_sz - 1) % comm_sz;
    int dest = (my_rank + 1) % comm_sz;
    int sendId = my_rank;
    int recvId = src;
    MPI_Request u[2];

    for (int i = 1; i < comm_sz; i ++) {
        if (i == 1) {
            MPI_Isend(static_cast <float*> (sendbuf) + sendId * blocksz,
                      blocksz, MPI_FLOAT, dest, 1, comm, &u[0]);
        } else {
            MPI_Isend(static_cast <float*> (recvbuf) + sendId * blocksz,
                      blocksz, MPI_FLOAT, dest, 1, comm, &u[0]);
        }
        MPI_Irecv(static_cast <float*> (recvbuf) + recvId * blocksz,
                  blocksz, MPI_FLOAT, src, 1, comm, &u[1]);
        MPI_Waitall(2, u, nullptr);        
        float *p = static_cast <float*> (sendbuf) + recvId * blocksz;
        float *q = static_cast <float*> (recvbuf) + recvId * blocksz;
        for (int k = 0; k < blocksz; k ++) q[k] += p[k];
        sendId = recvId;
        recvId = (recvId + comm_sz - 1) % comm_sz;
    }

    sendId = (my_rank + 1) % comm_sz;
    recvId = my_rank;
    for (int i = 1; i < comm_sz; i ++) {
        MPI_Isend(static_cast <float*> (recvbuf) + sendId * blocksz,
                 blocksz, MPI_FLOAT, dest, 1, comm, &u[0]);
        MPI_Irecv(static_cast <float*> (recvbuf) + recvId * blocksz,
                 blocksz, MPI_FLOAT, src, 1, comm, &u[1]);
        MPI_Waitall(2, u, nullptr);
        sendId = recvId;
        recvId = (recvId + comm_sz - 1) % comm_sz;
    }
}


// reduce + bcast
void Naive_Allreduce(void* sendbuf, void* recvbuf, int n, MPI_Comm comm, int comm_sz, int my_rank)
{
    MPI_Reduce(sendbuf, recvbuf, n, MPI_FLOAT, MPI_SUM, 0, comm);
    MPI_Bcast(recvbuf, n, MPI_FLOAT, 0, comm);
}

int main(int argc, char *argv[])
{
    int ITER = atoi(argv[1]);
    int n = atoi(argv[2]);
    float* mpi_sendbuf = new float[n];
    float* mpi_recvbuf = new float[n];
    float* naive_sendbuf = new float[n];
    float* naive_recvbuf = new float[n];
    float* ring_sendbuf = new float[n];
    float* ring_recvbuf = new float[n];

    MPI_Init(nullptr, nullptr);
    int comm_sz;
    int my_rank;
    MPI_Comm_size(MPI_COMM_WORLD, &comm_sz);
    MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
    
    srand(time(NULL) + my_rank);
    for (int i = 0; i < n; ++i)
        mpi_sendbuf[i] = static_cast <float> (rand()) / static_cast <float> (RAND_MAX);
    memcpy(naive_sendbuf, mpi_sendbuf, n * sizeof(float));
    memcpy(ring_sendbuf, mpi_sendbuf, n * sizeof(float));

    //warmup and check
    MPI_Allreduce(mpi_sendbuf, mpi_recvbuf, n, MPI_FLOAT, MPI_SUM, MPI_COMM_WORLD);
    Naive_Allreduce(naive_sendbuf, naive_recvbuf, n, MPI_COMM_WORLD, comm_sz, my_rank);
    Ring_Allreduce(ring_sendbuf, ring_recvbuf, n, MPI_COMM_WORLD, comm_sz, my_rank);
    bool correct = true;
    for (int i = 0; i < n; ++i)
        if (abs(mpi_recvbuf[i] - ring_recvbuf[i]) > EPS)
        {
            correct = false;
            break;
        }

    if (correct)
    {
        auto beg = ch::high_resolution_clock::now();
        for (int iter = 0; iter < ITER; ++iter)
            MPI_Allreduce(mpi_sendbuf, mpi_recvbuf, n, MPI_FLOAT, MPI_SUM, MPI_COMM_WORLD);
        auto end = ch::high_resolution_clock::now();
        double mpi_dur = ch::duration_cast<ch::duration<double>>(end - beg).count() * 1000; //ms

        beg = ch::high_resolution_clock::now();
        for (int iter = 0; iter < ITER; ++iter)
            Naive_Allreduce(naive_sendbuf, naive_recvbuf, n, MPI_COMM_WORLD, comm_sz, my_rank);
        end = ch::high_resolution_clock::now();
        double naive_dur = ch::duration_cast<ch::duration<double>>(end - beg).count() * 1000; //ms

        beg = ch::high_resolution_clock::now();
        for (int iter = 0; iter < ITER; ++iter)
            Ring_Allreduce(ring_sendbuf, ring_recvbuf, n, MPI_COMM_WORLD, comm_sz, my_rank);
        end = ch::high_resolution_clock::now();
        double ring_dur = ch::duration_cast<ch::duration<double>>(end - beg).count() * 1000; //ms
        
        if (my_rank == 0)
        {
            std::cout << "Correct." << std::endl;
            std::cout << "MPI_Allreduce:   " << mpi_dur << " ms." << std::endl;
            std::cout << "Naive_Allreduce: " << naive_dur << " ms." << std::endl;
            std::cout << "Ring_Allreduce:  " << ring_dur << " ms." << std::endl;
        }
    }
    else
        if (my_rank == 0)
            std::cout << "Wrong!" << std::endl;

    delete[] mpi_sendbuf;
    delete[] mpi_recvbuf;
    delete[] naive_sendbuf;
    delete[] naive_recvbuf;
    delete[] ring_sendbuf;
    delete[] ring_recvbuf;
    MPI_Finalize();
    return 0;
}

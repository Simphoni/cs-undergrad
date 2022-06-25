MPICXX := mpicxx
FLAGS := -O3 -std=c++11

all: run

run: allreduce
	srun -N 4 -n 4 allreduce 10 10000

runall: allreduce
	srun -N 4 -n 4 allreduce 10 100000000
	srun -N 4 -n 8 allreduce 10 100000000
	srun -N 4 -n 32 allreduce 10 10000000
	srun -N 4 -n 32 allreduce 10 1000000
	srun -N 4 -n 32 allreduce 10 100000
	srun -N 4 -n 100 allreduce 10 1000
	srun -N 4 -n 100 allreduce 10 100

allreduce: allreduce.cpp
	$(MPICXX) $< $(FLAGS) -o $@

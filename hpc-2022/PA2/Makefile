
CC = mpicc 
OPT = -O3 -mfma
CFLAGS = -Wall -std=c99 $(OPT) -fopenmp 
LDFLAGS = -Wall -fopenmp -lm -lnuma
LDLIBS = $(LDFLAGS)

targets = benchmark-naive benchmark-omp benchmark-mpi checker run
objects = check.o benchmark.o stencil-naive.o stencil-omp.o stencil-mpi.o

.PHONY : default
default : all

.PHONY : all
all : clean $(targets)

run: run.cpp
	g++ run.cpp -o run

output : check.o output.o stencil-naive.o
	$(CC) -o $@ $^ $(LDLIBS)

benchmark-naive : check.o benchmark.o stencil-naive.o
	$(CC) -o $@ $^ $(LDLIBS)

benchmark-omp : check.o benchmark.o stencil-omp.o
	$(CC) -o $@ $^ $(LDLIBS)

benchmark-mpi : check.o benchmark.o stencil-mpi.o
	$(CC) -o $@ $^ $(LDLIBS)

%.o : %.c common.h
	$(CC) -c $(CFLAGS) $< -o $@

.PHONY: clean
clean:
	rm -rf $(targets) $(objects)

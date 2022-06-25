.PHONY: clean
all: omp_sched test	
omp_sched: omp_sched.cpp
	g++ omp_sched.cpp -o omp_sched -O2 -fopenmp

test: test.cpp
	g++ test.cpp -o test -O2 -fopenmp
clean:
	rm omp_sched

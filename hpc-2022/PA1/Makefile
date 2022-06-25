CFLAGS ?= -std=c++14 -O2 -Wall -Wextra -Werror -Wno-cast-function-type -pedantic -DDEBUG

.PHONY: clean check_mpi

all: check_mpi generate odd_even_sort

check_mpi:
ifeq ($(shell which mpicxx),)
	$(error No mpicxx found, please load OpenMPI first!)
endif

generate: generate.cpp
	g++ $(CFLAGS) $^ -o $@ 

odd_even_sort: main.cpp worker.cpp odd_even_sort.cpp
	mpicxx -g $(CFLAGS) $^ -o $@

clean:
	rm -f generate odd_even_sort

# version 0, run nproc times
ver0: main.cpp worker.cpp ver0.cpp
	mpicxx -g $(CFLAGS) $^ -o $@
run0: ver0
	echo "n=1000" > time.0
	./run.sh $^ 1000 data/1000.dat | grep "Execution" >> time.0
	echo "n=1000000" >> time.0
	./run.sh $^ 1000000 data/1000000.dat | grep "Execution" >> time.0
	echo "n=100000000" >> time.0
	./run.sh $^ 100000000 data/100000000.dat | grep "Execution" >> time.0

# version 1, comm on sigstop after data process
ver1: main.cpp worker.cpp ver1.cpp
	mpicxx -g $(CFLAGS) $^ -o $@
run1: ver1
	echo "n=1000" > time.1
	./run.sh $^ 1000 data/1000.dat | grep "Execution" >> time.1
	echo "n=1000000" >> time.1
	./run.sh $^ 1000000 data/1000000.dat | grep "Execution" >> time.1
	echo "n=100000000" >> time.1
	./run.sh $^ 100000000 data/100000000.dat | grep "Execution" >> time.1


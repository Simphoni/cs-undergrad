UNROLL_N ?= 16

.PHONY: clean

all: main

main: main.cpp
	icc $^ -o $@ -O3 -DUNROLL_N=${UNROLL_N}

clean:
	rm main


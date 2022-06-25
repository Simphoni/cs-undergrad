#include <algorithm>
#include <cassert>
#include <chrono>
#include <iostream>
#include <random>
#include <cmath>

#include <omp.h>

int main() {
    
    #pragma omp parallel num_threads(2)
    {
        printf("test");
    }
    return 0;
}
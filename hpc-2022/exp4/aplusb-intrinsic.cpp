#include "aplusb.h"
#include <x86intrin.h>

void a_plus_b_intrinsic(float* a, float* b, float* c, int n) {
	// Your code here
	for (int i = 0; i < n; i += 8) {
		__m256 rega = _mm256_load_ps(a + i);
		__m256 regb = _mm256_load_ps(b + i);
		_mm256_store_ps(c + i, _mm256_add_ps(rega, regb));
	}
}

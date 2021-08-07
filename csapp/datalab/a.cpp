#include <cstdio>
#include <iostream>
#include <climits>
using namespace std;

unsigned floatScale2(unsigned uf) {
  unsigned t = uf >> 23;
  unsigned res = 0;
  if ((t & 255) == 255) return uf;
  cerr << (t & 255) << endl;
  cerr << (uf & ((1 << 23) - 1)) << endl;
  if ((t & 255) == 0 && (uf & ((1 << 23) - 1) == 0)) return uf;
  return ((t + 1) << 23) + uf & ((1 << 23) - 1);
}
int main() {
  unsigned x = 0x80000000;
  floatScale2(x);
}

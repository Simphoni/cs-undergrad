#include "stdio.h"

int logicalShift(int x, int n) {
  int b = (x >> 31) & 1; // b = 1 if (x < 0)
  x = x + (b << 31);     // abandon sgn 1
  x = x >> n;
  x = x | ( b << (31 - n) );
  return x;
}
int bitReverse(int x) {
  int ret = 0;
  ret = ret | ( ((x      ) & 0xFF) ^ 0xFF );
  ret = ret | ( ((x >> 8 ) & 0xFF) ^ 0xFF ) << 8;
  ret = ret | ( ((x >> 16) & 0xFF) ^ 0xFF ) << 16;
  ret = ret | ( ((x >> 24) & 0xFF) ^ 0xFF ) << 24;
  return ret;
}
int dividePower2(int x, int n) {
  int b = (x >> 31);  // 0 if (x >= 0), -1 if (x < 0)
  int ox = ((~ x) + 1) >> n;
  ox = (~ ox) + 1;
  x = x >> n;
  return (x & (~b)) | (ox & (b));
}
int fitsBits(int x, int n) {
  int b = x >> 31;
  int a = (x & (~ b)) | ((~x) & b);
  b = ~0;
  a = a << ((x >> 31) & 1);
  b = b ^ (b << n);
  return !(a ^ (a & b));
}
int main() {
  int x, n;
  scanf("%d%d", &x, &n);
  printf("%d\n", fitsBits(x, n));
}

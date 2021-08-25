#include <bits/stdc++.h>
using namespace std;
int a[100][100];
int main() {
  int c = 0;
  printf("    ");
  for (int i = 0; i < 64; i ++) printf("%8d", i);
  puts("");
  for (int i = 0; i < 67; i ++) {
    for (int j = 0; j < 61; j ++) {
      a[i][j] = (c>>5)&31;
      c += 4;
    }
  }
  int cnt = 0;
  for (int i = 0; i < 61; i ++) {
    printf("%2d: ", i);
    for (int j = 0; j < 67; j ++) {
	  c += 4;
       printf("%3d(%3d)", a[i][j], a[j][i]);
      // printf("%3d", a[i][j], a[j][i]);
    }
	puts("");
  }
  cerr << cnt << endl;
  return 0;
}

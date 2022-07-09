#include <bits/stdc++.h>
using namespace std;

int edi;
bool fail;

inline int func4(int edx = 14, int esi = 0) {
	int eax = edx - esi;
  eax = eax - (eax < 0);
	eax >>= 1;
	int ecx = eax + esi;
	if (ecx <= edi) {
		eax = 0;
		if (ecx < edi) {
			esi = ecx + 1;
			eax = func4(edx, esi) << 1 | 1;
		}
	} else {
		edx = ecx - 1;
		eax = func4(edx, esi) << 1;
	}
  return eax;
}

int main() {
  for (int i = 1; i <= 9; i ++) {
    edi = i;
    if (!func4()) cout << i << endl;
  }
  return 0;
}

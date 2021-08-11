#include <bits/stdc++.h>
using namespace std;
int main() {
	for (int i = 0; i < 26; i ++) {
	cout << (char)(i+'a') << " " << ((i + 'a') & 15) << endl;
	}
}

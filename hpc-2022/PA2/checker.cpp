#include <bits/stdc++.h>
using namespace std;
int main(int argc, char* argv[]) {
  if (argc != 6) {
    puts("./checker nx ny nz nsteps ./prog");
    return 0;
  }
  char s[500];
  sprintf(s, "touch stdout_%sx%sx%sx%s", argv[1], argv[2], argv[3], argv[4]);
  printf("%s\n", s);
  system(s);
  sprintf(s, "export DAPL_DBG_TYPE=0; srun -N 1 -n 1 ./output 7 %s %s %s %s stencil_data/stencil_data_768x768x768 stdout_%sx%sx%sx%s",
	  argv[1], argv[2], argv[3], argv[4], argv[1], argv[2], argv[3], argv[4]);
  printf("%s\n", s);
  system(s);
  if (strcmp("./benchmark-mpi", argv[5]) == 0)
    sprintf(s, "export DAPL_DBG_TYPE=0; srun -N 1 --ntasks-per-node 28 %s 7 %s %s %s %s stencil_data/stencil_data_768x768x768 stdout_%sx%sx%sx%s",
	    argv[5], argv[1], argv[2], argv[3], argv[4], argv[1], argv[2], argv[3], argv[4]);
  else
    sprintf(s, "export DAPL_DBG_TYPE=0; srun -N 1 -n 1 numactl --interleave=all %s 7 %s %s %s %s stencil_data/stencil_data_768x768x768 stdout_%sx%sx%sx%s",
	    argv[5], argv[1], argv[2], argv[3], argv[4], argv[1], argv[2], argv[3], argv[4]);
  printf("%s\n", s);
  system(s);
  return 0;
}

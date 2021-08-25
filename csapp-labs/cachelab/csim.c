#include "cachelab.h"
#include <unistd.h>
#include <getopt.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

static char read_alpha() {
  char c = getchar();
  while (c < 'A' || c > 'Z') {
    if ((c = getchar()) == -1) return -1;
  }
  return c;
}

static int read_int() {
  // read positive integer
  char c = getchar();
  while ((c < '0' || c > '9') && (c < 'a' || c > 'f')) {
    if ((c = getchar()) == -1) return -1;
  }
  int x = 0;
  while (('0' <= c && c <= '9') || ('a' <= c && c <= 'f')) {
    if ('0' <= c && c <= '9') x = (x << 4) + c - '0';
    else x = (x << 4) + c - 'a' + 10;
    if ((c = getchar()) == -1) return x;
  }
  return x;
}

static int s, E, b, t;
static int hit, miss, evict, cur;
static int **cache_arr, **stamp;
static char *file = NULL;

static void read_args(int argc, char *argv[]) {
  int opt;
  while ((opt = getopt(argc, argv, "s:E:b:t:")) != -1) {
    if (opt == 's') s = atoi(optarg);
    else if (opt == 'E') E = atoi(optarg);
    else if (opt == 'b') b = atoi(optarg);
    else if (opt == 't') {
      file = (char*)malloc(sizeof(char) * (strlen(optarg) + 1));
      strcpy(file, optarg);
    }
  }
}

static void load(int addr) {
  cur ++;
  int set = (addr >> b) & ((1 << s) - 1);
  int flag = (addr >> (b + s)) | (1 << t);
  for (int i = 0; i < E; i ++)
    if ( cache_arr[set][i] == flag ) {
      hit ++; stamp[set][i] = cur; return;
    }
  miss ++;
  int Min = 0;
  for (int i = 1; i < E; i ++)
    if (stamp[set][i] < stamp[set][Min]) Min = i;
  if (cache_arr[set][Min] >> t) evict ++;
  stamp[set][Min] = cur;
  cache_arr[set][Min] = flag;
}

static void simulate(void) {
  char c; int addr;
  cur = 0;
  while ((c = read_alpha()) != -1) {
    addr = read_int(); read_int();
    if (c == 'I') continue;
    load((addr >> b) << b);
    if (c == 'M') load((addr >> b) << b);
  }
}

int main(int argc, char *argv[]) {
  read_args(argc, argv);
  if (file != NULL) freopen(file, "r", stdin);
  t = 64 - b - s;
  cache_arr = (int**) malloc(sizeof(int*) << s);
  for (int i = 0; i < (1 << s); i ++) {
    cache_arr[i] = (int*) malloc(sizeof(int) * E);
    memset(cache_arr[i], 0, sizeof(int) * E);
  }
  stamp = (int**) malloc(sizeof(int*) << s);
  for (int i = 0; i < (1 << s); i ++) {
    stamp[i] = (int*) malloc(sizeof(int) * E);
    memset(stamp[i], 0, sizeof(int) * E);
  }
  hit = miss = evict = 0;
  simulate();
  printSummary(hit, miss, evict);
  return 0;
}

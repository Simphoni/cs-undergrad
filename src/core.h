#include <semaphore.h>

void unix_error(char*);
void app_error(char*);

#define SAFEIO_BUFSIZE 2048
#define SAFEIO_GUARD 65536
typedef struct {
  int fileid;
  char buf[SAFEIO_BUFSIZE];
  char *nextchar, *empchar;
  sem_t mutex;
} safeio;
void sio_readinit(safeio*, int);
int sio_readn(safeio*, char*, int);
int sio_readlineb(safeio*, char*);
int sio_writen(int, char*, int);

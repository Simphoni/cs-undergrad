#include "core.h"
#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>
#include <semaphore.h>
#include <sys/types.h>

extern int errno;

void unix_error(char *s) {
  fprintf(stderr, "Unix error: %s\n", s);
}

void app_error(char *s) {
  fprintf(stderr, "App error: %s\n", s);
}

void sio_readinit(safeio *io, int fileid) {
  io->fileid = fileid;
  io->nextchar = io->buf;
  io->empchar = io->buf;
  sem_init(&io->mutex, 0, 1);
}

int sio_try_refresh_buffer(safeio *io) {
  io->nextchar = io->buf;
  int len = read(io->fileid, io->buf, SAFEIO_BUFSIZE - 1); // -1 avoids '\0' overflow
  if (len < 0) {
    if (errno == EINTR) len = -2;
    else {
      unix_error(strerror(errno));
      len = -1;
    }
    io->empchar = io->buf;
  }
  else io->empchar = io->buf + len;
  return len;
}

int sio_readn(safeio *io, char *s, int size) {
  // switching fileid can cause loss of data in io->buf[]
  if (size < 0) return 0;
  sem_wait(&io->mutex); // locks this safeio instance
  int len, osize = size;
  while (size) {
    if (io->nextchar == io->empchar)
      len = sio_try_refresh_buffer(io);
    else len = io->empchar - io->nextchar;
    if (len == -1 || len == 0) break;
    else {
      while (size && io->nextchar != io->empchar) {
        *s = *io->nextchar;
        io->nextchar ++; s ++;
        size --;
      }
    }
  }
  *s = '\0';
  sem_post(&io->mutex); // unlocks safeio instance
  return osize - size;
}

int sio_readlineb(safeio *io, char *s) {
  int len, ret = 0;
  sem_wait(&io->mutex);
  while (ret < SAFEIO_GUARD) {
    if (io->nextchar < io->empchar) {
      *s = *io->nextchar;
      ++ io->nextchar;
    }
    else {
      len = read(io->fileid, s, 1);
      if (len <= 0) {
        if (len == -1 && errno != EINTR)
          unix_error(strerror(errno));
        break;
      }
    }
    if (*s == '\n') break;
    s ++;
    ret ++;
  }
  *s = '\0';
  sem_post(&io->mutex);
  return ret;
}

int sio_writen(int fileid, char *buf, int n) {
  if (n < 0) return -1;
  int nwrite;
  while (n) {
    nwrite = write(fileid, buf, n);
    if (nwrite < 0) {
      
    }
  }
  
}

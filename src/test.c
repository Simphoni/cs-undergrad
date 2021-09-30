#include "core.h"
#include <stdio.h>
#include <unistd.h>
safeio io;
int main() {
  sio_init(&io, STDIN_FILENO);
  char s[SAFEIO_BUFSIZE], tmp[100];
  int n = sio_readn(&io, s, 5);
  sprintf(tmp, "%d", n);
  app_error(tmp);
  app_error(s);
  n = sio_readline(&io, s);
  sprintf(tmp, "%d" ,n);
  app_error(tmp);
  app_error(s);
  n = sio_readline(&io, s);
  sprintf(tmp, "%d" ,n);
  app_error(tmp);
  app_error(s);
}

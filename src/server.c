#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <pthread.h>
#include "core.h"
#define NTHREADS 1
#define QUEUE_SIZE 1024

static const int PORT = 2282;

typedef struct {
  int buf[QUEUE_SIZE];
  int front;
  int rear;
  sem_t mutex_all;
  sem_t mutex_item;
  sem_t mutex_slot;
} queue;
char buf[1024];
pthread_t pid[100];
safeio sio_t; // buffer is shared, do not call sio_readn
queue conn_t;

int open_listenfd(unsigned short);
void *thread(void*);
void queue_init(queue*);
void queue_push(queue*, int);
int queue_pop(queue*);

int main() {
  int sockfd = open_listenfd(PORT);
  if (sockfd < -1) return 0;
  struct sockaddr_storage clientsock;
  unsigned int clientlen = sizeof clientsock;
  queue_init(&conn_t);
  while (1) {
    int connfd = accept(sockfd, (struct sockaddr*)&clientsock, &clientlen);
    fprintf(stderr, "connected\n");
    int read_bytes;
    while ((read_bytes = read(connfd, buf, 1024)) > 0) {
      fprintf(stderr, "%d bytes read: \n", read_bytes);
      write(STDOUT_FILENO, buf, read_bytes);
    }
    if (read_bytes == -1) {
    }
    fprintf(stderr, "connection closed by peer\n");
  }
  return 0;
}

void *thread(void *arg) {
  int connid;
  static char buf[SAFEIO_GUARD];
  while (1) {
    connid = queue_pop(&conn_t);
    sio_readinit(&sio_t, connid);
    int nbytes;
    while ((nbytes = sio_readlineb(&sio_t, buf)) > 0) {
      sio_write(buf, nbytes);
    }
  }
}

void queue_init(queue *q) {
  q->front = 0;
  q->rear = 0;
  sem_init(&q->mutex_all, 0, 1); // allows only one thread to operate on queue
  sem_init(&q->mutex_slot, 0, QUEUE_SIZE); // reject push request
  sem_init(&q->mutex_item, 0, 0); // reject pop request
}

void queue_push(queue *q, int value) {
  sem_wait(&q->mutex_slot);
  // mutex_slot has already been decreased,
  // which reserves(guarantees) a free slot
  sem_wait(&q->mutex_all);
  q->buf[(++q->rear) % QUEUE_SIZE] = value;
  sem_post(&q->mutex_item);
  sem_post(&q->mutex_all);
}

int queue_pop(queue *q) {
  int ret;
  sem_wait(&q->mutex_item);
  sem_wait(&q->mutex_all);
  ret = q->buf[(++q->rear) % QUEUE_SIZE];
  sem_post(&q->mutex_slot);
  sem_post(&q->mutex_all);
  return ret;
}

int open_listenfd(unsigned short port) {
  struct sockaddr_in servsock;
  int fileid;
  if ((fileid = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    unix_error("request for socket failed.");
    return -1;
  }
  memset(&servsock, 0, sizeof servsock);
  servsock.sin_family = AF_INET;
  servsock.sin_port = htons(port);
  servsock.sin_addr.s_addr = htonl(INADDR_ANY);
  if ((bind(fileid, (struct sockaddr*) &servsock, sizeof servsock)) < 0) {
    unix_error("bind error.");
    return -1;
  }
  if (listen(fileid, 1024) == 0)
    fprintf(stderr, "Listening on port %d.\n", (int)port);
  else {
    unix_error("failed to switch into listening.");
    return -1;
  }
  return fileid;
}

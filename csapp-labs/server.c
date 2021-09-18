#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>

const int PORT = 15213;

int open_listenfd(unsigned short port) {
  struct sockaddr_in servsock;
  int fileid;
  if ((fileid = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    fprintf(stderr, "socket error.\n");
    return -1;
  }
  memset(&servsock, 0, sizeof servsock);
  servsock.sin_family = AF_INET;
  servsock.sin_port = htons(port);
  servsock.sin_addr.s_addr = htonl(INADDR_ANY);
  if ((bind(fileid, (struct sockaddr*) &servsock, sizeof servsock)) < 0) {
    fprintf(stderr, "bind error.\n");
    return -1;
  }
  if (listen(fileid, 1024) < 0) return -1;
  return fileid;
}

char buf[1024];

int main() {
  int sockfd = open_listenfd(PORT);
  if (sockfd < -1) return 0;
  fprintf(stderr, "Listening to port %d...\n", PORT);
  struct sockaddr clientsock;
  unsigned int clientlen = sizeof clientsock;
  while (1) {
    int connfd = accept(sockfd, &clientsock, &clientlen);
    fprintf(stderr, "connected\n");
    int read_bytes;
    while ((read_bytes = read(connfd, buf, 1024)) != 0) {
      fprintf(stderr, "%d bytes read: \n", read_bytes);
      write(STDOUT_FILENO, buf, read_bytes);
    }
    fprintf(stderr, "connection closed by peer\n");
  }
  return 0;
}

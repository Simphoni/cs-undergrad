#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>

const int PORT = 1521;

int open_clientfd(char *hostname, unsigned short port) {
  struct sockaddr_in servsock;
  int clientfd;
  // lookup hostname info
  struct hostent *hp = gethostbyname(hostname);
  if (hp == NULL) {
    fprintf(stderr, "gethostbyname failed.\n");
    return -1;
  }
  /* printf("h_name: %s\n", hp -> h_name); */
  /* for (int i = 0; hp -> h_aliases[i] != NULL; i ++) */
  /*   printf("h_aliases[%d]: %s\n", i, hp -> h_aliases[i]); */
  /* printf("h_addrtype: %d\n", hp -> h_addrtype); */
  /* printf("h_length: %d\n", hp -> h_length); */
  /* if (hp -> h_addr_list == NULL || hp -> h_addr_list[0] == NULL) { */
  /*   fprintf(stderr, "DNS failed.\n"); */
  /*   return -1; */
  /* } */
  /* for (int i = 0; hp -> h_addr_list[i] != NULL; i ++) */
  /*   printf("h_addr_list[%d]: %s\n", i, */
  /*          inet_ntoa( *((struct in_addr*)(hp -> h_addr_list[i])) )); */
  /* puts("--------- END OF HOSTNAME INFO --------\n"); */
  // connect
  memset(&servsock, 0, sizeof servsock);
  servsock.sin_family = AF_INET;
  servsock.sin_port = htons(port);
  if ((clientfd = socket(AF_INET, SOCK_STREAM, 0)) < 0) return -1;
  memcpy((char*)&servsock.sin_addr.s_addr,
         (char*)hp -> h_addr_list[0], hp -> h_length);
  if ((connect(clientfd, (struct sockaddr*)&servsock, sizeof(servsock))) < 0) {
    printf("%d\n", (connect(clientfd, (struct sockaddr*)&servsock, sizeof(servsock))));
    printf("%s\n", strerror(errno));
    return -1;
  }
  return clientfd;
}

char buf[1024];

int main() {
  int clientfd = open_clientfd("localhost", PORT), bytes;
  if (clientfd < 0) return 0;
  while ((bytes = read(STDIN_FILENO, buf, 1023)) != 0) write(clientfd, buf, bytes);
  close(clientfd);
  return 0;
}

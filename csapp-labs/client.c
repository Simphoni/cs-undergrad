#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>

const int PORT = 109;

int Open_clientfd(char *hostname, char *port) {
    int clientfd, rc;
    struct addrinfo hints, *listp, *p;

    /* Get a list of potential server addresses */
    memset(&hints, 0, sizeof(struct addrinfo));
    hints.ai_socktype = SOCK_STREAM;  /* Open a connection */
    hints.ai_flags = AI_NUMERICSERV;  /* ... using a numeric port arg. */
    hints.ai_flags |= AI_ADDRCONFIG;  /* Recommended for connections */
    if ((rc = getaddrinfo(hostname, port, &hints, &listp)) != 0) {
        fprintf(stderr, "getaddrinfo failed (%s:%s): %s\n", hostname, port, gai_strerror(rc));
        return -2;
    }
  
    /* Walk the list for one that we can successfully connect to */
    for (p = listp; p; p = p->ai_next) {
        /* Create a socket descriptor */
        if ((clientfd = socket(p->ai_family, p->ai_socktype, p->ai_protocol)) < 0) 
            continue; /* Socket failed, try the next */

        /* Connect to the server */
        if (connect(clientfd, p->ai_addr, p->ai_addrlen) != -1) 
            break; /* Success */
        if (close(clientfd) < 0) { /* Connect failed, try another */  //line:netp:openclientfd:closefd
            /* fprintf(stderr, "open_clientfd: close failed: %s\n", strerror(errno)); */
            return -1;
        } 
    } 

    /* Clean up */
    freeaddrinfo(listp);
    if (!p) /* All connects failed */
        return -1;
    else    /* The last connect succeeded */
        return clientfd;
}


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
  if ((clientfd = socket(AF_INET, SOCK_STREAM, 0) < 0)) return -1;
  memcpy((char*)&servsock.sin_addr.s_addr,
         (char*)hp -> h_addr_list[0], hp -> h_length);
  if ((connect(clientfd, (struct sockaddr*)&servsock, sizeof(servsock))) < 0) {
    printf("%d\n", (connect(clientfd, (struct sockaddr*)&servsock, sizeof(servsock))));
    return -1;
  }
  return clientfd;
}

char buf[1024];

int main() {
  char port = 255;
  int clientfd = Open_clientfd("localhost", &port), bytes;
  if (clientfd < 0) return 0;
  while ((bytes = read(STDIN_FILENO, buf, 1023)) != 0) write(clientfd, buf, bytes);
  close(clientfd);
  return 0;
}

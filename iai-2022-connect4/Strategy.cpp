#include <iostream>
#include <unistd.h>
#include <sys/time.h>
#include <bitset>
#include <cstring>
#include <cmath>
#include <iostream>
#include <string>
#include <vector>
#include "Point.h"
#include "Strategy.h"

using namespace std;

namespace UCT {
  const double CONSTANT = - 0.9;
  int N, M;
  int badX, badY;
  enum who {
            OPPONENT = 1,
            ME = 2
  };
  namespace Timer {
    timeval start, cur;
    void kickoff() {
      gettimeofday(&start, NULL);
    }
    float timeEllapsed() {
      gettimeofday(&cur, NULL);
      return (cur.tv_usec - start.tv_usec) * 1e-6 + (cur.tv_sec - start.tv_sec);
    }
  };
  
  struct chessboard {
    static const int N = 16 * 12;
    bitset<N> data;
    inline bool checkTerm() const {
      bitset<N> a = data & (data >> 1 ) & (data >> 2 ) & (data >> 3 );
      bitset<N> b = data & (data >> 16) & (data >> 32) & (data >> 48);
      bitset<N> c = data & (data >> 15) & (data >> 30) & (data >> 45);
      bitset<N> d = data & (data >> 17) & (data >> 34) & (data >> 51);
      return (a | b | c | d).count() != 0;
    }
    inline void set(int col, int row) {
      data.set((col << 4) + row, 1);
    }
    inline void unset(int col, int row) {
      data.set((col << 4) + row, 0);
    }
    inline bool get(int col, int row) const {
      return data[(col << 4) + row];
    }
  };

  const int NNODES = 3e6;
  struct mcnode {
    mcnode *prev;
    mcnode *child[13];
    int nullkids; // number of extendable childs
    who player;
    int nsim, score; // number of simulations in the subtree
    int kids;
    int deadEnd;
    void init(mcnode *_prev, who _player, int nc) {
      prev = _prev;
      player = _player;
      nsim = score = 0;
      nullkids = kids = nc;
      deadEnd = 0;
      memset(child, 0, sizeof(size_t) * 12);
    }
  } pool[NNODES];
  int cnt = 0;

  void refresh() {
    cnt = 0;
  }
  inline mcnode *getnode(mcnode *prev, who player, int kids) {
    if (cnt < NNODES) {
      pool[cnt].init(prev, player, kids);
      cnt ++;
      return pool + cnt - 1;
    }
    else return NULL;
  }
  
  struct optim {
    chessboard my, op;
    int top[16];

    optim() = default;

    optim(chessboard _my, chessboard _op, int* _top): my(_my), op(_op) {
      memcpy(top, _top, sizeof(int) * N);
    }

    void update(mcnode *p, int v) {
      while (p != NULL) {
        p->nsim ++;
        if (p->player == ME) p->score += v;
        else p->score -= v;
        p = p->prev;
      }
    }

    int passive_policy(chessboard *b, int lastX, int lastY, const int *top) {
      // @out: -2 - doomed, -1 - no threat
      int ret = -1;
      if (lastX > 0) { // vert
        int i = lastX, ret0 = -1;
        for (; i < M; i ++) if (!b->get(lastY, i)) break;
        if (i - lastX == 3 && top[lastY] == lastX) ret0 = lastY;
        if (ret0 != -1) ret = ret0;
      }
      { // horizon
        int i = lastY - 1, j = lastY + 1, ret1 = -1;
        for (; i >= 0; i --) if (!b->get(i, lastX)) break;
        for (; i < N; i ++) if (!b->get(j, lastX)) break;
        if (j - i - 1 == 3) {
          bool okl = (i >= 0 && top[i] - 1 == lastX);
          bool okr = (j <  N && top[j] - 1 == lastX);
          if (okl && okr) return -2;
          if (okl) ret1 = i;
          else if (okr) ret1 = j;
        }
        if (ret1 != -1) {
          if (ret != -1 && ret != ret1) return -2;
          ret = ret1;
        }
      }
      { //slash
        int l = 1, r = 1, ret2 = -1;
        for (; lastX - l >= 0 && lastY - l >= 0; l ++)
          if (!b->get(lastY - l, lastX - l)) break;
        for (; lastX + r < M && lastY + r < N; r ++)
          if (!b->get(lastY + r, lastX + r)) break;
        if (l + r - 1 == 3) {
          bool okl = (lastX - l >= 0 && lastY - l >= 0 && top[lastY - l] - 1 == lastX - l);
          bool okr = (lastX + r <  M && lastY + r <  N && top[lastY + r] - 1 == lastX + r);
          if (okl && okr) return -2;
          if (okl) ret2 = lastY - l;
          else if (okr) ret2 = lastY + r;
        }
        if (ret2 != -1) {
          if (ret != -1 && ret != ret2) return -2;
          ret = ret2;
        }
      }

      { // bslash
        int l = 1, r = 1, ret3 = -1;
        for (; lastX + l <  M && lastY - l >= 0; l ++)
          if (!b->get(lastY - l, lastX + l)) break;
        for (; lastX - r >= 0 && lastY + r <  N; r ++)
          if (!b->get(lastY + r, lastX - r)) break;
        if (l + r - 1 == 3) {
          bool okl = (lastX + l <  M && lastY - l >= 0 && top[lastY - l] - 1 == lastX + l);
          bool okr = (lastX - r >= 0 && lastY + r <  N && top[lastY + r] - 1 == lastX - r);
          if (okl && okr) return -2;
          if (okl) ret3 = lastY - l;
          else if (okr) ret3 = lastY + r;
        }
        if (ret3 != -1) {
          if (ret != -1 && ret != ret3) return -2;
          ret = ret3;
        }
      }
      return ret;
    }

    void simulate(mcnode *p) {
      who player = p->player;
      int score = 0, remains = 0;
      int lastX = 0, lastY = 0;
      for (int i = 0; i < N; i ++) remains += (top[i] != 0);
      
      int epoch = 0;
      while (true) {
        if (player == ME && op.checkTerm()) { score = -1; break; }
        if (player == OPPONENT && my.checkTerm()) { score = 1; break; } 
        if (remains == 0) { score = 0; break; }
        
        // passive policy
        int idx = 0;
        
        int tmp = -1;
        chessboard *b = (player == ME ? &op : &my); // defend against my opponent
        if (epoch == 0) {
          // lastX, lastY not provided
          for (int i = 0; i < N; i ++) {
            if (!b->get(i, top[i])) continue;
            int w = passive_policy(b, top[i], i, top);
            if (w == -2) { tmp = -2; break; }
            if (w != -1) {
              if (tmp != -1 && tmp != w) { tmp = -2; break; }
              tmp = w;
            }
          }
        }
        else tmp = passive_policy(b, lastX, lastY, top);
        if (tmp == -2) score = (player == ME ? -1 : 1); // current player will fail
        if (score) break;
        if (tmp != -1) idx = tmp;
        else {
          idx = rand() % N;
          while (top[idx] == 0) idx = rand() % N;
        }
          
        epoch ++;
        top[idx] --;
        lastX = top[idx];
        lastY = idx;
        if (player == OPPONENT) op.set(idx, top[idx]);
        else                    my.set(idx, top[idx]);
        if (top[idx] - 1 == badX && idx == badY) top[idx] --;
        
        if (!top[idx]) remains --;
        // transfer control
        player = (who)(3 - player);
      }

      update(p, score);
    }

  };
  
  int nextStep(mcnode *p) {
    mcnode **tmp = p->child;
    double minval = 1e100;
    int idx = -1;
    for (int i = 0; i < N; i ++) {
      if (tmp[i] == NULL) continue;
      double res = 1.0 * tmp[i]->score / tmp[i]->nsim;
#ifdef LOCAL
      printf("[%d] %f\t%d\t%d\n", i, 1.0*tmp[i]->score/tmp[i]->nsim,
             tmp[i]->score, tmp[i]->nsim);
#endif
      if (res < minval) {
        minval = res; idx = i;
      }
    }
#ifdef LOCAL
    fprintf(stderr, "choose: [%d]\n", idx);
    mcnode *nxt = p->child[idx];
    double best = 1;
    int iidx = 0;
    for (int i = 0; i < N; i ++)
      if (nxt->child[i] != NULL) {
        double gg = nxt->child[i]->score*1.0/nxt->child[i]->nsim;
        printf("[%d]: %f\t%d\t%d\n", i, gg, nxt->child[i]->score, nxt->child[i]->nsim);
        if (gg < best) {
          best = gg; iidx = i;
        }
      }
    fprintf(stderr, "expect: [%d]\n", iidx);
#endif
    return idx;
  }
  void calcState(mcnode *p, const chessboard &my, const chessboard &op) {
    if ( (p->player == ME && op.checkTerm())
         || (p->player == OPPONENT && my.checkTerm()))
      p->deadEnd = 1;
    else if (p->kids == 0) p->deadEnd = 2;
  }
  mcnode* extendLeaf(chessboard &my, chessboard &op, int *top, mcnode *p) {
    mcnode *nxt;
    mcnode **tmp = NULL;
    for (; p->kids && p->nullkids == 0 && !p->deadEnd; p = nxt) {
      tmp = p->child;
      double lnn = log(p->nsim);
      double minval = 1e100;
      int idx = -1;
      nxt = NULL;
      for (int i = 0; i < N; i ++) {
        if (tmp[i] == NULL) continue; //reached top
        double res = 1.0 * tmp[i]->score / tmp[i]->nsim
                   + CONSTANT * sqrt(2 * lnn / tmp[i]->nsim);
        if (res < minval) {
          minval = res; nxt = tmp[i]; idx = i;
        }
      }
      top[idx] --;
      if (p->player == OPPONENT) op.set(idx, top[idx]);
      else                       my.set(idx, top[idx]);
      if (top[idx] - 1 == badX && idx == badY) top[idx] --;
    }
    // dead ends still have weights
    if (p->deadEnd) return p;
    
    tmp = p->child;
    // choose a random son to extend
    int idx = rand() % N;
    while (tmp[idx] != NULL || !top[idx]) idx = rand() % N; // not extended, and not top
    
    top[idx] --;
    if (p->player == OPPONENT) op.set(idx, top[idx]);
    else                       my.set(idx, top[idx]);
    // bad point
    if (top[idx] - 1 == badX && idx == badY) top[idx] --;
    p->nullkids --;
    tmp[idx] = getnode(p, (who)(3 - p->player), p->kids - (top[idx] == 0));
    calcState(tmp[idx], my, op);
    return tmp[idx];
  }
}

// N - columns

const float THRESHOLD = 2.6;

extern "C" Point *getPoint(const int M, const int N,
                           const int *top,
                           const int *_board,
                           const int lastX, const int lastY,
                           const int noX, const int noY) {
  UCT::Timer::kickoff();
#ifdef LOCAL
  fprintf(stderr, "real: [%d]\n", lastY);
  for (int i = 0, t = 0; i < M; i ++) {
    for (int j = 0; j < N; j ++, t ++) {
      fprintf(stderr, "%c ", _board[t] == 2 ? 'M' : (_board[t] == 0 ? '.' : 'O'));
    }
    fprintf(stderr, "\n");
  }
#endif
  // env
  UCT::N = N;
  UCT::M = M;
  UCT::badX = noX;
  UCT::badY = noY;
  UCT::chessboard myOrig, opOrig;
  // check init
  UCT::refresh();
  // read
  for (int i = 0; i < M; i ++)
    for (int j = 0; j < N; j ++) {
      if (_board[i * N + j] == UCT::ME) myOrig.set(j, i); // slot j, height i
      else if (_board[i * N + j] == UCT::OPPONENT) opOrig.set(j, i);
    }
  
  int root_kids = 0;
  for (int i = 0; i < N; i ++)
    root_kids += (top[i] != 0);
  UCT::mcnode *root = UCT::getnode(NULL, UCT::ME, root_kids);
  UCT::calcState(root, myOrig, opOrig);
  
  int cnt = 0;
  int nowTop[16];
  while (UCT::Timer::timeEllapsed() < THRESHOLD) {
    UCT::chessboard my = myOrig, op = opOrig;
    memcpy(nowTop, top, sizeof(int) * N);
    UCT::mcnode *chosen = UCT::extendLeaf(my, op, nowTop, root);
    if (chosen == NULL) break;
    UCT::optim opt(my, op, nowTop);
    opt.simulate(chosen);
    cnt ++;
  }
  
#ifdef LOCAL
  static int step = 0; step ++;
  fprintf(stderr, "step %d: simulated %d times\n", step, cnt);
#endif
  
  int idx = UCT::nextStep(root);
  return new Point(top[idx] - 1, idx);
}

/*
  getPoint函数返回的Point指针是在本so模块中声明的，为避免产生堆错误，应在外部调用本so中的
  函数来释放空间，而不应该在外部直接delete
*/
extern "C" void clearPoint(Point *p) {
  delete p;
  return;
}

/*
  清除top和board数组
*/
void clearArray(int M, int N, int **board) {
  for (int i = 0; i < M; i++) {
    delete[] board[i];
  }
  delete[] board;
}

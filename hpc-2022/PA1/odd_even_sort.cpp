// version 0, brute nproc times
#include <algorithm>
#include <cassert>
#include <cstdio>
#include <cstdlib>
#include <mpi.h>

#include "worker.h"

typedef unsigned int uint;

static void _sort(uint *a, uint *swp, int n) {
	int buc0[1 << 8], buc1[1 << 8], buc2[1 << 8], buc3[1 << 8];
	memset(buc0, 0, sizeof buc0);
	memset(buc1, 0, sizeof buc0);
	memset(buc2, 0, sizeof buc0);
	memset(buc3, 0, sizeof buc0);
	for (int i = 0; i < n; ++ i) {
		++ buc0[a[i]       & 255];
		++ buc1[a[i] >>  8 & 255];
		++ buc2[a[i] >> 16 & 255];
		++ buc3[a[i] >> 24 & 255];
	}
	for (int i = 1; i < 256; ++ i) {
		buc0[i] += buc0[i - 1];
		buc1[i] += buc1[i - 1];
		buc2[i] += buc2[i - 1];
		buc3[i] += buc3[i - 1];
	}
	// round 1
	uint *ptr = a + n - 1;
	for (int iter = n >> 3; iter; iter --) {
		swp[-- buc0[ptr[ 0] & 255]] = ptr[ 0];
		swp[-- buc0[ptr[-1] & 255]] = ptr[-1];
		swp[-- buc0[ptr[-2] & 255]] = ptr[-2];
		swp[-- buc0[ptr[-3] & 255]] = ptr[-3];
		swp[-- buc0[ptr[-4] & 255]] = ptr[-4];
		swp[-- buc0[ptr[-5] & 255]] = ptr[-5];
		swp[-- buc0[ptr[-6] & 255]] = ptr[-6];
		swp[-- buc0[ptr[-7] & 255]] = ptr[-7];
		ptr -= 8;
	}
	while (ptr >= a) {
		swp[-- buc0[ptr[0] & 255]] = ptr[0];
		ptr --;
	}
	// round 2
	ptr = swp + n - 1;
	for (int iter = n >> 3; iter; iter --) {
		a[-- buc1[ptr[ 0] >> 8 & 255]] = ptr[ 0];
		a[-- buc1[ptr[-1] >> 8 & 255]] = ptr[-1];
		a[-- buc1[ptr[-2] >> 8 & 255]] = ptr[-2];
		a[-- buc1[ptr[-3] >> 8 & 255]] = ptr[-3];
		a[-- buc1[ptr[-4] >> 8 & 255]] = ptr[-4];
		a[-- buc1[ptr[-5] >> 8 & 255]] = ptr[-5];
		a[-- buc1[ptr[-6] >> 8 & 255]] = ptr[-6];
		a[-- buc1[ptr[-7] >> 8 & 255]] = ptr[-7];
		ptr -= 8;
	}
	while (ptr >= swp) {
		a[-- buc1[ptr[0] >> 8 & 255]] = ptr[0];
		ptr --;
	}
	// round 3
	ptr = a + n - 1;
	for (int iter = n >> 3; iter; iter --) {
		swp[-- buc2[ptr[ 0] >> 16 & 255]] = ptr[ 0];
		swp[-- buc2[ptr[-1] >> 16 & 255]] = ptr[-1];
		swp[-- buc2[ptr[-2] >> 16 & 255]] = ptr[-2];
		swp[-- buc2[ptr[-3] >> 16 & 255]] = ptr[-3];
		swp[-- buc2[ptr[-4] >> 16 & 255]] = ptr[-4];
		swp[-- buc2[ptr[-5] >> 16 & 255]] = ptr[-5];
		swp[-- buc2[ptr[-6] >> 16 & 255]] = ptr[-6];
		swp[-- buc2[ptr[-7] >> 16 & 255]] = ptr[-7];
		ptr -= 8;
	}
	while (ptr >= a) {
		swp[-- buc2[ptr[0] >> 16 & 255]] = ptr[0];
		ptr --;
	}
	// round 4
	ptr = swp + n - 1;
	for (int iter = n >> 3; iter; iter --) {
		a[-- buc3[ptr[ 0] >> 24 & 255]] = ptr[ 0];
		a[-- buc3[ptr[-1] >> 24 & 255]] = ptr[-1];
		a[-- buc3[ptr[-2] >> 24 & 255]] = ptr[-2];
		a[-- buc3[ptr[-3] >> 24 & 255]] = ptr[-3];
		a[-- buc3[ptr[-4] >> 24 & 255]] = ptr[-4];
		a[-- buc3[ptr[-5] >> 24 & 255]] = ptr[-5];
		a[-- buc3[ptr[-6] >> 24 & 255]] = ptr[-6];
		a[-- buc3[ptr[-7] >> 24 & 255]] = ptr[-7];
		ptr -= 8;
	}
	while (ptr >= swp) {
		a[-- buc3[ptr[0] >> 24 & 255]] = ptr[0];
		ptr --;
	}
}

static void bucsort(uint *a, uint *swp, int n) {
	if (n <= 1) return;
	int l = 0, r = n - 1;
	while (l < r) {
		while (l < r && (a[l] & (1u << 31))) l ++;
		while (l < r && (a[r] & (1u << 31)) == 0) r --;
		if (l < r) {
			std::swap(a[l], a[r]);
		} else break;
	}
	if (l >= 0 && (a[l] & (1u << 31)) == 0) l --;
	if (l > 0) {
		for (int i = 0; i <= l; i ++) a[i] ^= (~0);
		_sort(a, swp, l + 1);
		for (int i = 0; i <= l; i ++) a[i] ^= (~0);
	}
	if (r < n - 1 && (a[r] & (1u << 31))) r ++;
	if (r < n - 1) _sort(a + r, swp, n - r);
}

void Worker::sort() {
	bool running;
	int avelen = (n + nprocs - 1) / nprocs;
	int nfull = n / avelen;
	int nlive = nfull + ((int)n != nfull * avelen);
	// data comm
	float *data_recv = new float[avelen + 5];
	float *data_swp = new float[block_len + 5];
	float *pdata = data, *swp = data_swp;
	int partner, diff;
	MPI_Request mpireq[30];
	// stopsig comm
	float comm_send[3], comm_recv[3];
	int next = (rank + 1) % nlive;
	int prev = (rank + nlive - 1) % nlive;


	// initialize
	{
		uint *p = static_cast<uint*>(static_cast<void*>(&data[0]));
		uint *q = static_cast<uint*>(static_cast<void*>(&data_swp[0]));
		bucsort(p, q, block_len);
	}
	if (nlive == 1) return;
	// first round: (0 1) (2 3)
	if (rank & 1) diff = -1;
	else diff = 1;

	if (n <= 500000) {
		for (int g = 1; g <= nlive; g ++) {
			if (block_len == 0) break;
			partner = rank + diff;
			int recv_len = (partner < nfull ? avelen : (partner == nfull ? n - avelen * nfull : 0));
			running = (partner >= 0 && partner < nlive);
			if (running) {
				// exchange values
				MPI_Isend(pdata, block_len, MPI_FLOAT, partner, 1, MPI_COMM_WORLD, &mpireq[0]);
				// place the recv value at offset 1, for faster implementation
				MPI_Irecv(data_recv + 1, recv_len, MPI_FLOAT, partner, 1, MPI_COMM_WORLD, &mpireq[1]);
				MPI_Waitall(2, mpireq, nullptr);
				data_recv[0] = -1e120;
				data_recv[recv_len + 1] = 1e120;

				if (diff > 0) {
					if (pdata[block_len - 1] > data_recv[1]) {
						for (int i = 0, u = 0, v = 1; i < (int)block_len; i ++) {
							if (pdata[u] < data_recv[v])
								swp[i] = pdata[u ++];
							else
								swp[i] = data_recv[v ++];
						}
						std::swap(pdata, swp);
					}
				} else {
					// take out largest block_len floats
					if (data_recv[recv_len] > pdata[0]) {
						for (int i = block_len - 1, u = block_len - 1, v = recv_len; i >= 0; i --) {
							if (pdata[u] > data_recv[v])
								swp[i] = pdata[u --];
							else
								swp[i] = data_recv[v --];
						}
						std::swap(pdata, swp);
					}
				}
			}
			diff = - diff;
		}
		if (pdata != (float*)data)
			memcpy(data, pdata, sizeof(float) * block_len);
		delete[] data_recv;
		delete[] data_swp;
		return; // haha
	}

	for (int g = 1; ; g ++) {
		if (nlive == 1) break;
		// skip sleeping process
		if (block_len == 0) break;
		// partner info
		partner = rank + diff;
		int recv_len = (partner < nfull ? avelen : (partner == nfull ? n - avelen * nfull : 0));
		running = (partner >= 0 && partner < nlive);
		// halt signal
		int steady = 0;

		if (running) {
			// exchange values between pairs
			MPI_Isend(pdata, block_len, MPI_FLOAT, partner, 1, MPI_COMM_WORLD, &mpireq[0]);
			// place recv sequence at offset 1, for faster implementation
			MPI_Irecv(data_recv + 1, recv_len, MPI_FLOAT, partner, 1, MPI_COMM_WORLD, &mpireq[1]);
			MPI_Waitall(2, mpireq, nullptr);
			data_recv[0] = -1e100;
			data_recv[recv_len + 1] = 1e100;

			// comm startup
			int cntreq = 0;
			if (diff > 0 && rank > 0) {
				MPI_Irecv(comm_recv, 1, MPI_FLOAT, prev, 2, MPI_COMM_WORLD, &mpireq[0]);
				cntreq = 1;
			} else if (diff < 0 && rank + 1 < nlive) {
				comm_send[0] = std::max(pdata[block_len - 1], data_recv[recv_len]);
				MPI_Isend(comm_send, 1, MPI_FLOAT, next, 2, MPI_COMM_WORLD, &mpireq[0]);
				cntreq = 1;
			}

			// interval for comm to wake up
			int stage = 0;
			int interval = std::max((int)block_len / nlive, 1000);

			if (diff > 0) {
				// |self, partner|, takes out smallest block_len floats
				int i = 0, u = 0, v = 1;
				while (i < (int)block_len) {
					int endpos = std::min(i + interval, (int)block_len);
					for (; i < endpos; i ++) {
						if (pdata[u] < data_recv[v]) swp[i] = pdata[u ++];
						else                         swp[i] = data_recv[v ++];
					}
					// comm & calc async
					if (cntreq) {
						MPI_Waitall(cntreq, mpireq, nullptr);
						if (stage == 0) steady = swp[0] < comm_recv[0];       // inter process_pair checking
						else            steady |= (int)(comm_recv[0] + 1e-6); // ring allreduce
					}
					++ stage;
					cntreq = 0;
					if (stage >= nlive) continue;
					// start next round
					comm_send[0] = steady;
					MPI_Isend(comm_send, 1, MPI_FLOAT, next, 2, MPI_COMM_WORLD, &mpireq[0]);
					MPI_Irecv(comm_recv, 1, MPI_FLOAT, prev, 2, MPI_COMM_WORLD, &mpireq[1]);
					cntreq = 2;
				}
				// deal the remaining
				while (stage < nlive) {
					if (cntreq) {
						MPI_Waitall(cntreq, mpireq, nullptr);
						if (stage == 0) steady = swp[0] < comm_recv[0]; // inter process_pair checking
						else            steady |= (int)(comm_recv[0] + 1e-6);
					}
					++ stage;
					cntreq = 0;
					if (stage >= nlive) break;
					// start next phase
					comm_send[0] = steady;
					MPI_Isend(comm_send, 1, MPI_FLOAT, next, 2, MPI_COMM_WORLD, &mpireq[0]);
					MPI_Irecv(comm_recv, 1, MPI_FLOAT, prev, 2, MPI_COMM_WORLD, &mpireq[1]);
					cntreq = 2;
				}
			} else {
				// diff < 0, take out largest block_len floats
				int i = block_len - 1, u = block_len - 1, v = recv_len;
				while (i >= 0) {
					int endpos = std::max(0, i - interval);
					for (; i >= endpos; i --) {
						if (pdata[u] > data_recv[v]) swp[i] = pdata[u --];
						else                         swp[i] = data_recv[v --];
					}
					// comm & calc async
					if (cntreq) {
						MPI_Waitall(cntreq, mpireq, nullptr);
						if (stage != 0) steady |= (int)(comm_recv[0] + 1e-6);
					}
					++ stage;
					cntreq = 0;
					if (stage >= nlive) continue;
					// start next round
					comm_send[0] = steady;
					MPI_Isend(comm_send, 1, MPI_FLOAT, next, 2, MPI_COMM_WORLD, &mpireq[0]);
					MPI_Irecv(comm_recv, 1, MPI_FLOAT, prev, 2, MPI_COMM_WORLD, &mpireq[1]);
					cntreq = 2;
				}
				// deal the remaining
				while (stage < nlive) {
					if (cntreq) {
						MPI_Waitall(cntreq, mpireq, nullptr);
						if (stage != 0) steady |= (int)(comm_recv[0] + 1e-6);
					}
					++ stage;
					cntreq = 0;
					if (stage >= nlive) break;
					// start next phase
					comm_send[0] = steady;
					MPI_Isend(comm_send, 1, MPI_FLOAT, next, 2, MPI_COMM_WORLD, &mpireq[0]);
					MPI_Irecv(comm_recv, 1, MPI_FLOAT, prev, 2, MPI_COMM_WORLD, &mpireq[1]);
					cntreq = 2;
				}
			}
			std::swap(pdata, swp);
		} else {
			// unpaired process
			if (rank == 0) {
				comm_send[0] = pdata[block_len - 1];
				MPI_Isend(comm_send, 1, MPI_FLOAT, next, 2, MPI_COMM_WORLD, &mpireq[0]);
				MPI_Waitall(1, mpireq, nullptr);
			} else {
				MPI_Irecv(comm_recv, 1, MPI_FLOAT, prev, 2, MPI_COMM_WORLD, &mpireq[0]);
				MPI_Waitall(1, mpireq, nullptr);
				steady = comm_recv[0] > pdata[0];
			}
			for (int u = 1; u < nlive; u ++) {
				comm_send[0] = steady;
				MPI_Isend(comm_send, 1, MPI_FLOAT, next, 2, MPI_COMM_WORLD, &mpireq[0]);
				MPI_Irecv(comm_recv, 1, MPI_FLOAT, prev, 2, MPI_COMM_WORLD, &mpireq[1]);
				MPI_Waitall(2, mpireq, nullptr);
				steady |= (int)(comm_recv[0] + 1e-6);
			}
		}
		if (!steady) break;
		diff = - diff;
	}
	if (pdata != (float*)data) {
		memcpy(data, pdata, sizeof(float) * block_len);
	}
	delete[] data_recv;
	delete[] data_swp;
#if 0
	printf("t[%d]:\n", rank);
	for (int i = 0; i < block_len; i ++)printf("%lf ", pdata[i]);
	puts("");
#endif
}

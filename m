Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41025 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751795AbcJ1NXG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Oct 2016 09:23:06 -0400
From: Paolo Abeni <pabeni@redhat.com>
To: netdev@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>,
        James Morris <jmorris@namei.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>, Tom Herbert <tom@herbertland.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        linux-nfs@vger.kernel.org
Subject: [PATCH net-next] udp: do fwd memory scheduling on dequeue
Date: Fri, 28 Oct 2016 15:20:19 +0200
Message-Id: <95bb1b780be2e35ff04fb9e1e2c41470a0a15582.1477660091.git.pabeni@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A new argument is added to __skb_recv_datagram, it allows
the caller to perform protocol specific action on dequeue
under the receive queue spinlock.
The UDP protocol uses such argument to perform fwd memory
reclaiming on dequeue, while protocol memory and rmem updatating
is delayed after the lock release, to keep the time spent
under the lock as low as possible.
The UDP specific skb desctructor is not used anymore, instead
explicit memory reclaiming is performed at close() time and
when skbs are removed from the receive queue.
The in kernel UDP procotol users now need to use an
skb_recv_udp() variant instead of skb_recv_datagram() to
properly perform memory accounting on dequeue.

Overall, this allows acquiring only once the receive queue
lock on dequeue.

Tested using pktgen with random src port, 64 bytes packet,
wire-speed on a 10G link as sender and udp_sink as the receiver,
using an l4 tuple rxhash to stress the contention, and one or more
udp_sink instances with reuseport.

nr sinks	vanilla		patched
1		440		560
3		2150		2300
6		3650		3800
9		4450		4600
12		6250		6450

Suggested-by: Eric Dumazet <edumazet@google.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/linux/skbuff.h |  4 ++++
 include/net/udp.h      | 10 ++++++++
 net/core/datagram.c    | 11 ++++++---
 net/ipv4/udp.c         | 65 ++++++++++++++++++++++++++++++++++++++++----------
 net/ipv6/udp.c         |  3 +--
 net/rxrpc/input.c      |  7 +++---
 net/sunrpc/svcsock.c   |  2 +-
 net/sunrpc/xprtsock.c  |  2 +-
 net/unix/af_unix.c     |  4 ++--
 9 files changed, 83 insertions(+), 25 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 601258f..dd171a9 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3028,13 +3028,17 @@ static inline void skb_frag_list_init(struct sk_buff *skb)
 #define skb_walk_frags(skb, iter)	\
 	for (iter = skb_shinfo(skb)->frag_list; iter; iter = iter->next)
 
+typedef void (*skb_dequeue_cb_t)(struct sock *sk, struct sk_buff *skb,
+				 int flags);
 
 int __skb_wait_for_more_packets(struct sock *sk, int *err, long *timeo_p,
 				const struct sk_buff *skb);
 struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned flags,
+					skb_dequeue_cb_t dequeue_cb,
 					int *peeked, int *off, int *err,
 					struct sk_buff **last);
 struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned flags,
+				    skb_dequeue_cb_t dequeue_cb,
 				    int *peeked, int *off, int *err);
 struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned flags, int noblock,
 				  int *err);
diff --git a/include/net/udp.h b/include/net/udp.h
index 18f1e6b..983c861 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -48,6 +48,7 @@ struct udp_skb_cb {
 	} header;
 	__u16		cscov;
 	__u8		partial_cov;
+	int		fwd_memory_released;
 };
 #define UDP_SKB_CB(__skb)	((struct udp_skb_cb *)((__skb)->cb))
 
@@ -248,6 +249,15 @@ static inline __be16 udp_flow_src_port(struct net *net, struct sk_buff *skb,
 /* net/ipv4/udp.c */
 void skb_consume_udp(struct sock *sk, struct sk_buff *skb, int len);
 int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb);
+struct sk_buff *__skb_recv_udp(struct sock *sk, unsigned int flags, int noblock,
+			       int *peeked, int *off, int *err);
+static inline struct sk_buff *skb_recv_udp(struct sock *sk, unsigned int flags,
+					   int noblock, int *err)
+{
+	int peeked, off = 0;
+
+	return __skb_recv_udp(sk, flags, noblock, &peeked, &off, err);
+}
 
 void udp_v4_early_demux(struct sk_buff *skb);
 int udp_get_port(struct sock *sk, unsigned short snum,
diff --git a/net/core/datagram.c b/net/core/datagram.c
index bfb973a..226548b 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -165,6 +165,7 @@ static struct sk_buff *skb_set_peeked(struct sk_buff *skb)
  *	__skb_try_recv_datagram - Receive a datagram skbuff
  *	@sk: socket
  *	@flags: MSG_ flags
+ *	@dequeue_cb: invoked under the receive lock on successful dequeue
  *	@peeked: returns non-zero if this packet has been seen before
  *	@off: an offset in bytes to peek skb from. Returns an offset
  *	      within an skb where data actually starts
@@ -197,6 +198,7 @@ static struct sk_buff *skb_set_peeked(struct sk_buff *skb)
  *	the standard around please.
  */
 struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned int flags,
+					skb_dequeue_cb_t dequeue_cb,
 					int *peeked, int *off, int *err,
 					struct sk_buff **last)
 {
@@ -244,6 +246,8 @@ struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned int flags,
 			} else
 				__skb_unlink(skb, queue);
 
+			if (dequeue_cb)
+				dequeue_cb(sk, skb, flags);
 			spin_unlock_irqrestore(&queue->lock, cpu_flags);
 			*off = _off;
 			return skb;
@@ -262,6 +266,7 @@ struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned int flags,
 EXPORT_SYMBOL(__skb_try_recv_datagram);
 
 struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
+				    skb_dequeue_cb_t dequeue_cb,
 				    int *peeked, int *off, int *err)
 {
 	struct sk_buff *skb, *last;
@@ -270,8 +275,8 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 	timeo = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
 
 	do {
-		skb = __skb_try_recv_datagram(sk, flags, peeked, off, err,
-					      &last);
+		skb = __skb_try_recv_datagram(sk, flags, dequeue_cb, peeked,
+					      off, err, &last);
 		if (skb)
 			return skb;
 
@@ -290,7 +295,7 @@ struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned int flags,
 	int peeked, off = 0;
 
 	return __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
-				   &peeked, &off, err);
+				   NULL, &peeked, &off, err);
 }
 EXPORT_SYMBOL(skb_recv_datagram);
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index c833271..2f1a727 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1172,26 +1172,61 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
 	return ret;
 }
 
+/* fully reclaim rmem/fwd memory allocated for skb */
 static void udp_rmem_release(struct sock *sk, int size, int partial)
 {
 	int amt;
 
 	atomic_sub(size, &sk->sk_rmem_alloc);
-
-	spin_lock_bh(&sk->sk_receive_queue.lock);
 	sk->sk_forward_alloc += size;
 	amt = (sk->sk_forward_alloc - partial) & ~(SK_MEM_QUANTUM - 1);
 	sk->sk_forward_alloc -= amt;
-	spin_unlock_bh(&sk->sk_receive_queue.lock);
 
 	if (amt)
 		__sk_mem_reduce_allocated(sk, amt >> SK_MEM_QUANTUM_SHIFT);
 }
 
-static void udp_rmem_free(struct sk_buff *skb)
+/* if we are not peeking the skb, reclaim fwd allocated memory;
+ * rmem and protocol memory updating is delayed outside the lock
+ */
+static void udp_dequeue(struct sock *sk, struct sk_buff *skb, int flags)
+{
+	int amt;
+
+	if (flags & MSG_PEEK)
+		return;
+
+	sk->sk_forward_alloc += skb->truesize;
+	amt = (sk->sk_forward_alloc - 1) & ~(SK_MEM_QUANTUM - 1);
+	sk->sk_forward_alloc -= amt;
+	UDP_SKB_CB(skb)->fwd_memory_released = amt >> SK_MEM_QUANTUM_SHIFT;
+}
+
+/* complete the memory reclaiming started with udp_dequeue */
+static void __udp_rmem_release(struct sock *sk, struct sk_buff *skb, int flags)
+{
+	int amt = UDP_SKB_CB(skb)->fwd_memory_released;
+
+	if (flags & MSG_PEEK)
+		return;
+
+	atomic_sub(skb->truesize, &sk->sk_rmem_alloc);
+	if (amt)
+		__sk_mem_reduce_allocated(sk, amt);
+}
+
+struct sk_buff *__skb_recv_udp(struct sock *sk, unsigned int flags,
+			       int noblock, int *peeked, int *off, int *err)
 {
-	udp_rmem_release(skb->sk, skb->truesize, 1);
+	struct sk_buff *skb;
+
+	skb = __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
+				  udp_dequeue, peeked, off, err);
+	if (skb)
+		__udp_rmem_release(sk, skb, flags);
+	return skb;
 }
+EXPORT_SYMBOL(__skb_recv_udp);
 
 int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
 {
@@ -1230,7 +1265,6 @@ int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
 
 	/* the skb owner in now the udp socket */
 	skb->sk = sk;
-	skb->destructor = udp_rmem_free;
 	skb->dev = NULL;
 	sock_skb_set_dropcount(sk, skb);
 
@@ -1254,8 +1288,13 @@ int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
 static void udp_destruct_sock(struct sock *sk)
 {
 	/* reclaim completely the forward allocated memory */
-	__skb_queue_purge(&sk->sk_receive_queue);
-	udp_rmem_release(sk, 0, 0);
+	struct sk_buff *skb;
+
+	while ((skb = __skb_dequeue(&sk->sk_receive_queue)) != NULL) {
+		udp_rmem_release(sk, skb->truesize, 0);
+		kfree_skb(skb);
+	}
+
 	inet_sock_destruct(sk);
 }
 
@@ -1303,11 +1342,11 @@ static int first_packet_length(struct sock *sk)
 		atomic_inc(&sk->sk_drops);
 		__skb_unlink(skb, rcvq);
 		__skb_queue_tail(&list_kill, skb);
+		udp_rmem_release(sk, skb->truesize, 1);
+		kfree_skb(skb);
 	}
 	res = skb ? skb->len : -1;
 	spin_unlock_bh(&rcvq->lock);
-
-	__skb_queue_purge(&list_kill);
 	return res;
 }
 
@@ -1362,8 +1401,7 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 
 try_again:
 	peeking = off = sk_peek_offset(sk, flags);
-	skb = __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
-				  &peeked, &off, &err);
+	skb = __skb_recv_udp(sk, flags, noblock, &peeked, &off, &err);
 	if (!skb)
 		return err;
 
@@ -2583,6 +2621,9 @@ void __init udp_init(void)
 {
 	unsigned long limit;
 
+	BUILD_BUG_ON(sizeof(struct udp_skb_cb) >
+		     FIELD_SIZEOF(struct sk_buff, cb));
+
 	udp_table_init(&udp_table, "UDP");
 	limit = nr_free_buffer_pages() / 8;
 	limit = max(limit, 128UL);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 71963b2..273a806 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -343,8 +343,7 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 
 try_again:
 	peeking = off = sk_peek_offset(sk, flags);
-	skb = __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
-				  &peeked, &off, &err);
+	skb = __skb_recv_udp(sk, flags, noblock, &peeked, &off, &err);
 	if (!skb)
 		return err;
 
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 44fb8d8..4c36112 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -1053,7 +1053,7 @@ void rxrpc_data_ready(struct sock *udp_sk)
 
 	ASSERT(!irqs_disabled());
 
-	skb = skb_recv_datagram(udp_sk, 0, 1, &ret);
+	skb = skb_recv_udp(udp_sk, 0, 1, &ret);
 	if (!skb) {
 		if (ret == -EAGAIN)
 			return;
@@ -1075,10 +1075,9 @@ void rxrpc_data_ready(struct sock *udp_sk)
 
 	__UDP_INC_STATS(&init_net, UDP_MIB_INDATAGRAMS, 0);
 
-	/* The socket buffer we have is owned by UDP, with UDP's data all over
-	 * it, but we really want our own data there.
+	/* The UDP protocol already released all skb resources;
+	 * we are free to add own data there.
 	 */
-	skb_orphan(skb);
 	sp = rxrpc_skb(skb);
 
 	/* dig out the RxRPC connection details */
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index e2a55dc..78da4ae 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -547,7 +547,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 	err = kernel_recvmsg(svsk->sk_sock, &msg, NULL,
 			     0, 0, MSG_PEEK | MSG_DONTWAIT);
 	if (err >= 0)
-		skb = skb_recv_datagram(svsk->sk_sk, 0, 1, &err);
+		skb = skb_recv_udp(svsk->sk_sk, 0, 1, &err);
 
 	if (skb == NULL) {
 		if (err != -EAGAIN) {
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 1758665..7178d0a 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1080,7 +1080,7 @@ static void xs_udp_data_receive(struct sock_xprt *transport)
 	if (sk == NULL)
 		goto out;
 	for (;;) {
-		skb = skb_recv_datagram(sk, 0, 1, &err);
+		skb = skb_recv_udp(sk, 0, 1, &err);
 		if (skb != NULL) {
 			xs_udp_data_read_skb(&transport->xprt, sk, skb);
 			consume_skb(skb);
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 145082e..8762018 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2113,8 +2113,8 @@ static int unix_dgram_recvmsg(struct socket *sock, struct msghdr *msg,
 		mutex_lock(&u->iolock);
 
 		skip = sk_peek_offset(sk, flags);
-		skb = __skb_try_recv_datagram(sk, flags, &peeked, &skip, &err,
-					      &last);
+		skb = __skb_try_recv_datagram(sk, flags, NULL, &peeked, &skip,
+					      &err, &last);
 		if (skb)
 			break;
 
-- 
1.8.3.1


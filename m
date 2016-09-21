Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55060 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757837AbcIURYE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Sep 2016 13:24:04 -0400
From: Paolo Abeni <pabeni@redhat.com>
To: netdev@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>,
        James Morris <jmorris@namei.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>, Tom Herbert <tom@herbertland.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        linux-nfs@vger.kernel.org
Subject: [PATCH net-next 2/3] udp: implement memory accounting helpers
Date: Wed, 21 Sep 2016 19:23:15 +0200
Message-Id: <93ccb49b7f037461ef436a50b907185744b093d8.1474477902.git.pabeni@redhat.com>
In-Reply-To: <cover.1474477902.git.pabeni@redhat.com>
References: <cover.1474477902.git.pabeni@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Avoid usage of common memory accounting functions, since
the logic is pretty much different.

To account for forward allocation, a couple of new atomic_t
members are added to udp_sock: 'mem_alloced' and 'mem_freed'.
The current forward allocation is estimated as 'mem_alloced'
 minus 'mem_freed' minus 'sk_rmem_alloc'.

When the forward allocation can't cope with the packet to be
enqueued, 'mem_alloced' is incremented by the packet size
rounded-up to the next SK_MEM_QUANTUM.
After a dequeue, we try to partially reclaim of the forward
allocated memory rounded down to an SK_MEM_QUANTUM and
'mem_freed' is increased by that amount.
sk->sk_forward_alloc is set after each allocated/freed memory
update, to the currently estimated forward allocation, without
any lock or protection.
This value is updated/maintained only to expose some
semi-reasonable value to the eventual reader, and is guaranteed
to be 0 at socket destruction time.

The above needs custom memory reclaiming on shutdown, provided
by the udp_destruct_sock() helper, which completely reclaim
the allocated forward memory.

Helpers are provided for skb free, consume and purge, respecting
the above constraints.

The socket lock is still used to protect the updates to sk_peek_off,
but is acquired only if peeking with offset is enabled.

As a consequence of the above schema, enqueue to sk_error_queue
will cause larger forward allocation on following normal data
(due to sk_rmem_alloc grow), but this allows amortizing the cost
of the atomic operation on SK_MEM_QUANTUM/skb->truesize packets.
The use of separate atomics for 'mem_alloced' and 'mem_freed'
allows the use of a single atomic operation to protect against
concurrent dequeue.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/linux/udp.h |   2 +
 include/net/udp.h   |   5 ++
 net/ipv4/udp.c      | 151 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 158 insertions(+)

diff --git a/include/linux/udp.h b/include/linux/udp.h
index d1fd8cd..cd72645 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -42,6 +42,8 @@ static inline u32 udp_hashfn(const struct net *net, u32 num, u32 mask)
 struct udp_sock {
 	/* inet_sock has to be the first member */
 	struct inet_sock inet;
+	atomic_t	 mem_allocated;
+	atomic_t	 mem_freed;
 #define udp_port_hash		inet.sk.__sk_common.skc_u16hashes[0]
 #define udp_portaddr_hash	inet.sk.__sk_common.skc_u16hashes[1]
 #define udp_portaddr_node	inet.sk.__sk_common.skc_portaddr_node
diff --git a/include/net/udp.h b/include/net/udp.h
index ea53a87..86307a4 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -246,6 +246,10 @@ static inline __be16 udp_flow_src_port(struct net *net, struct sk_buff *skb,
 }
 
 /* net/ipv4/udp.c */
+void skb_free_udp(struct sock *sk, struct sk_buff *skb);
+void skb_consume_udp(struct sock *sk, struct sk_buff *skb, int len);
+int udp_rmem_schedule(struct sock *sk, struct sk_buff *skb);
+
 void udp_v4_early_demux(struct sk_buff *skb);
 int udp_get_port(struct sock *sk, unsigned short snum,
 		 int (*saddr_cmp)(const struct sock *,
@@ -258,6 +262,7 @@ void udp_flush_pending_frames(struct sock *sk);
 void udp4_hwcsum(struct sk_buff *skb, __be32 src, __be32 dst);
 int udp_rcv(struct sk_buff *skb);
 int udp_ioctl(struct sock *sk, int cmd, unsigned long arg);
+int udp_init_sock(struct sock *sk);
 int udp_disconnect(struct sock *sk, int flags);
 unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait);
 struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 058c312..98480af 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1178,6 +1178,157 @@ out:
 	return ret;
 }
 
+static inline int __udp_forward(struct udp_sock *up, int freed, int rmem)
+{
+	return atomic_read(&up->mem_allocated) - freed - rmem;
+}
+
+static int skb_unref(struct sk_buff *skb)
+{
+	if (likely(atomic_read(&skb->users) == 1))
+		smp_rmb();
+	else if (likely(!atomic_dec_and_test(&skb->users)))
+		return 0;
+
+	return skb->truesize;
+}
+
+static inline int udp_try_release(struct sock *sk, int *fwd, int partial)
+{
+	struct udp_sock *up = udp_sk(sk);
+	int freed_old, freed_new, amt;
+
+	freed_old = atomic_read(&up->mem_freed);
+	*fwd = __udp_forward(up, freed_old, atomic_read(&sk->sk_rmem_alloc));
+	if (*fwd < SK_MEM_QUANTUM + partial)
+		return 0;
+
+	/* we can have concurrent release; if we catch any conflict
+	 * via atomic_cmpxchg, let only one of them relase the memory
+	 */
+	amt = sk_mem_pages(*fwd - partial) << SK_MEM_QUANTUM_SHIFT;
+	freed_new = atomic_cmpxchg(&up->mem_freed, freed_old, freed_old + amt);
+	return (freed_new == freed_old) ? amt : 0;
+}
+
+/* reclaim the allocated forward memory, except 'partial' quanta */
+static void skb_release_mem_udp(struct sock *sk, int partial)
+{
+	int fwd, delta = udp_try_release(sk, &fwd, partial);
+
+	if (delta)
+		__sk_mem_reduce_allocated(sk, delta >> SK_MEM_QUANTUM_SHIFT);
+	sk->sk_forward_alloc = fwd - delta;
+}
+
+void skb_free_udp(struct sock *sk, struct sk_buff *skb)
+{
+	int size = skb_unref(skb);
+
+	if (!size)
+		return;
+
+	trace_kfree_skb(skb, __builtin_return_address(0));
+	__kfree_skb(skb);
+	skb_release_mem_udp(sk, 1);
+}
+EXPORT_SYMBOL_GPL(skb_free_udp);
+
+void skb_consume_udp(struct sock *sk, struct sk_buff *skb, int len)
+{
+	int size = skb_unref(skb);
+
+	if (unlikely(READ_ONCE(sk->sk_peek_off) >= 0)) {
+		bool slow = lock_sock_fast(sk);
+
+		sk_peek_offset_bwd(sk, len);
+		unlock_sock_fast(sk, slow);
+	}
+	if (!size)
+		return;
+
+	__kfree_skb(skb);
+	skb_release_mem_udp(sk, 1);
+}
+EXPORT_SYMBOL_GPL(skb_consume_udp);
+
+static void udp_queue_purge(struct sock *sk, struct sk_buff_head *list,
+			    int partial)
+{
+	struct sk_buff *skb;
+	int size;
+
+	while ((skb = __skb_dequeue(list)) != NULL) {
+		size = skb_unref(skb);
+		if (size) {
+			trace_kfree_skb(skb, udp_queue_purge);
+			__kfree_skb(skb);
+		}
+	}
+	skb_release_mem_udp(sk, partial);
+}
+
+int udp_rmem_schedule(struct sock *sk, struct sk_buff *skb)
+{
+	int alloc, freed, fwd, amt, delta, rmem, err = -ENOMEM;
+	struct udp_sock *up = udp_sk(sk);
+
+	rmem = atomic_add_return(skb->truesize, &sk->sk_rmem_alloc);
+	if (rmem > sk->sk_rcvbuf)
+		goto drop;
+
+	freed = atomic_read(&up->mem_freed);
+	fwd = __udp_forward(up, freed, rmem);
+	if (fwd > 0)
+		goto no_alloc;
+
+	amt = sk_mem_pages(skb->truesize);
+	delta = amt << SK_MEM_QUANTUM_SHIFT;
+	if (!__sk_mem_raise_allocated(sk, delta, amt, SK_MEM_RECV)) {
+		err = -ENOBUFS;
+		goto drop;
+	}
+
+	/* if we have some skbs in the error queue, the forward allocation could
+	 * be understimated, even below 0; avoid exporting such values
+	 */
+	alloc = atomic_add_return(delta, &up->mem_allocated);
+	fwd = alloc - freed - rmem;
+	if (fwd < 0)
+		fwd = SK_MEM_QUANTUM;
+
+no_alloc:
+	sk->sk_forward_alloc = fwd;
+	skb_orphan(skb);
+	skb->sk = sk;
+	skb->destructor = sock_rmem_free;
+	return 0;
+
+drop:
+	atomic_sub(skb->truesize, &sk->sk_rmem_alloc);
+	atomic_inc(&sk->sk_drops);
+	return err;
+}
+EXPORT_SYMBOL_GPL(udp_rmem_schedule);
+
+static void udp_destruct_sock(struct sock *sk)
+{
+	/* reclaim completely the forward allocated memory */
+	udp_queue_purge(sk, &sk->sk_receive_queue, 0);
+	inet_sock_destruct(sk);
+}
+
+int udp_init_sock(struct sock *sk)
+{
+	struct udp_sock *up = udp_sk(sk);
+
+	atomic_set(&up->mem_allocated, 0);
+	atomic_set(&up->mem_freed, 0);
+	sk->sk_destruct = udp_destruct_sock;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(udp_init_sock);
+
 /**
  *	first_packet_length	- return length of first packet in receive queue
  *	@sk: socket
-- 
1.8.3.1


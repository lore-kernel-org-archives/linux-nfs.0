Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32876 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753023AbcI1KxK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Sep 2016 06:53:10 -0400
From: Paolo Abeni <pabeni@redhat.com>
To: netdev@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>,
        James Morris <jmorris@namei.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>, Tom Herbert <tom@herbertland.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Edward Cree <ecree@solarflare.com>, linux-nfs@vger.kernel.org
Subject: [PATCH net-next v3 2/3] udp: implement memory accounting helpers
Date: Wed, 28 Sep 2016 12:52:52 +0200
Message-Id: <6f445861ef2ce2e626a1df4946bc3f43f3d43e3f.1475048434.git.pabeni@redhat.com>
In-Reply-To: <cover.1475048434.git.pabeni@redhat.com>
References: <cover.1475048434.git.pabeni@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Avoid usage of common memory accounting functions, since
the logic is pretty much different.

To account for forward allocation, a couple of new atomic_t
members are added to udp_sock: 'mem_alloced' and 'can_reclaim'.
The current forward allocation is estimated as 'mem_alloced'
 minus 'sk_rmem_alloc'.

When the forward allocation can't cope with the packet to be
enqueued, 'mem_alloced' is incremented by the packet size
rounded-up to the next SK_MEM_QUANTUM.
After a dequeue, if under memory pressure, we try to partially
reclaim all forward allocated memory rounded down to an
SK_MEM_QUANTUM and 'mem_alloc' is decreased by that amount.
To protect against concurrent reclaim, we use 'can_reclaim' as
an unblocking synchronization point and let only one process
do the work.
sk->sk_forward_alloc is set after each memory update to the
currently estimated forward allocation, without any lock or
protection.
This value is updated/maintained only to expose some
semi-reasonable value to the eventual reader, and is guaranteed
to be 0 at socket destruction time.

The above needs custom memory reclaiming on shutdown, provided
by the udp_destruct_sock() helper, which completely reclaim
the allocated forward memory.

As a consequence of the above schema, enqueue to sk_error_queue
will cause fwd value to be understimated.

v1 -> v2:
  - use a udp specific destrctor to perform memory reclaiming
  - remove a couple of helpers, unneeded after the above cleanup
  - do not reclaim memory on dequeue if not under memory
    pressure
  - reworked the fwd accounting schema to avoid potential
    integer overflow

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/linux/udp.h |   2 +
 include/net/udp.h   |   7 +++
 net/ipv4/udp.c      | 137 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 146 insertions(+)

diff --git a/include/linux/udp.h b/include/linux/udp.h
index d1fd8cd..16aa22b 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -42,6 +42,8 @@ static inline u32 udp_hashfn(const struct net *net, u32 num, u32 mask)
 struct udp_sock {
 	/* inet_sock has to be the first member */
 	struct inet_sock inet;
+	atomic_t	 mem_allocated;
+	atomic_t	 can_reclaim;
 #define udp_port_hash		inet.sk.__sk_common.skc_u16hashes[0]
 #define udp_portaddr_hash	inet.sk.__sk_common.skc_u16hashes[1]
 #define udp_portaddr_node	inet.sk.__sk_common.skc_portaddr_node
diff --git a/include/net/udp.h b/include/net/udp.h
index ea53a87..b9563ef 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -98,6 +98,8 @@ static inline struct udp_hslot *udp_hashslot2(struct udp_table *table,
 extern struct proto udp_prot;
 
 extern atomic_long_t udp_memory_allocated;
+extern int udp_memory_pressure;
+extern struct percpu_counter udp_sockets_allocated;
 
 /* sysctl variables for udp */
 extern long sysctl_udp_mem[3];
@@ -246,6 +248,10 @@ static inline __be16 udp_flow_src_port(struct net *net, struct sk_buff *skb,
 }
 
 /* net/ipv4/udp.c */
+void skb_consume_udp(struct sock *sk, struct sk_buff *skb, int len);
+int udp_rmem_schedule(struct sock *sk, struct sk_buff *skb);
+void udp_enter_memory_pressure(struct sock *sk);
+
 void udp_v4_early_demux(struct sk_buff *skb);
 int udp_get_port(struct sock *sk, unsigned short snum,
 		 int (*saddr_cmp)(const struct sock *,
@@ -258,6 +264,7 @@ void udp_flush_pending_frames(struct sock *sk);
 void udp4_hwcsum(struct sk_buff *skb, __be32 src, __be32 dst);
 int udp_rcv(struct sk_buff *skb);
 int udp_ioctl(struct sock *sk, int cmd, unsigned long arg);
+int udp_init_sock(struct sock *sk);
 int udp_disconnect(struct sock *sk, int flags);
 unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait);
 struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 7d96dc2..2218901 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -131,6 +131,12 @@ EXPORT_SYMBOL(sysctl_udp_wmem_min);
 atomic_long_t udp_memory_allocated;
 EXPORT_SYMBOL(udp_memory_allocated);
 
+int udp_memory_pressure __read_mostly;
+EXPORT_SYMBOL(udp_memory_pressure);
+
+struct percpu_counter udp_sockets_allocated;
+EXPORT_SYMBOL(udp_sockets_allocated);
+
 #define MAX_UDP_PORTS 65536
 #define PORTS_PER_CHAIN (MAX_UDP_PORTS / UDP_HTABLE_SIZE_MIN)
 
@@ -1172,6 +1178,137 @@ out:
 	return ret;
 }
 
+static int __udp_forward(struct udp_sock *up, int rmem)
+{
+	return atomic_read(&up->mem_allocated) - rmem;
+}
+
+static bool udp_under_memory_pressure(const struct sock *sk)
+{
+	if (mem_cgroup_sockets_enabled && sk->sk_memcg &&
+	    mem_cgroup_under_socket_pressure(sk->sk_memcg))
+		return true;
+
+	return READ_ONCE(udp_memory_pressure);
+}
+
+void udp_enter_memory_pressure(struct sock *sk)
+{
+	WRITE_ONCE(udp_memory_pressure, 1);
+}
+EXPORT_SYMBOL(udp_enter_memory_pressure);
+
+/* if partial != 0 do nothing if not under memory pressure and avoid
+ * reclaiming last quanta
+ */
+static void udp_rmem_release(struct sock *sk, int partial)
+{
+	struct udp_sock *up = udp_sk(sk);
+	int fwd, amt;
+
+	if (partial && !udp_under_memory_pressure(sk))
+		return;
+
+	/* we can have concurrent release; if we catch any conflict
+	 * we let only one of them do the work
+	 */
+	if (atomic_dec_if_positive(&up->can_reclaim) < 0)
+		return;
+
+	fwd = __udp_forward(up, atomic_read(&sk->sk_rmem_alloc));
+	if (fwd < SK_MEM_QUANTUM + partial) {
+		atomic_inc(&up->can_reclaim);
+		return;
+	}
+
+	amt = (fwd - partial) & ~(SK_MEM_QUANTUM - 1);
+	atomic_sub(amt, &up->mem_allocated);
+	atomic_inc(&up->can_reclaim);
+
+	__sk_mem_reduce_allocated(sk, amt >> SK_MEM_QUANTUM_SHIFT);
+	sk->sk_forward_alloc = fwd - amt;
+}
+
+static void udp_rmem_free(struct sk_buff *skb)
+{
+	struct sock *sk = skb->sk;
+
+	atomic_sub(skb->truesize, &sk->sk_rmem_alloc);
+	udp_rmem_release(sk, 1);
+}
+
+int udp_rmem_schedule(struct sock *sk, struct sk_buff *skb)
+{
+	int fwd, amt, delta, rmem, err = -ENOMEM;
+	struct udp_sock *up = udp_sk(sk);
+
+	rmem = atomic_add_return(skb->truesize, &sk->sk_rmem_alloc);
+	if (rmem > sk->sk_rcvbuf)
+		goto drop;
+
+	fwd = __udp_forward(up, rmem);
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
+	fwd = atomic_add_return(delta, &up->mem_allocated) - rmem;
+	if (fwd < 0)
+		fwd = SK_MEM_QUANTUM;
+
+no_alloc:
+	sk->sk_forward_alloc = fwd;
+	skb_orphan(skb);
+	skb->sk = sk;
+	skb->destructor = udp_rmem_free;
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
+	__skb_queue_purge(&sk->sk_receive_queue);
+	udp_rmem_release(sk, 0);
+	inet_sock_destruct(sk);
+}
+
+int udp_init_sock(struct sock *sk)
+{
+	struct udp_sock *up = udp_sk(sk);
+
+	atomic_set(&up->mem_allocated, 0);
+	atomic_set(&up->can_reclaim, 1);
+	sk->sk_destruct = udp_destruct_sock;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(udp_init_sock);
+
+void skb_consume_udp(struct sock *sk, struct sk_buff *skb, int len)
+{
+	if (unlikely(READ_ONCE(sk->sk_peek_off) >= 0)) {
+		bool slow = lock_sock_fast(sk);
+
+		sk_peek_offset_bwd(sk, len);
+		unlock_sock_fast(sk, slow);
+	}
+	consume_skb(skb);
+}
+EXPORT_SYMBOL_GPL(skb_consume_udp);
+
 /**
  *	first_packet_length	- return length of first packet in receive queue
  *	@sk: socket
-- 
1.8.3.1


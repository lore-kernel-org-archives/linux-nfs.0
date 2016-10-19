Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57850 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S942886AbcJSPQr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Oct 2016 11:16:47 -0400
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
Subject: [PATCH net-next v4 2/3] udp: implement memory accounting helpers
Date: Wed, 19 Oct 2016 14:47:01 +0200
Message-Id: <c5a425a33f7dc8cda35f19c0979cf3ea5c10fc96.1476877189.git.pabeni@redhat.com>
In-Reply-To: <cover.1476877189.git.pabeni@redhat.com>
References: <cover.1476877189.git.pabeni@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Avoid using the generic helpers.
Adds a new spinlock_t to the udp_sock structure and use
it to protect the memory accounting operation, both on
enqueue and on dequeue.

On dequeue perform partial memory reclaiming, trying to
leave a quantum of forward allocated memory.

On enqueue use a custom helper, to allow some optimizations:
- use a plain spin_lock() variant instead of the slightly
  costly spin_lock_irqsave(),
- avoid dst_force check, since the calling code has already
  dropped the skb dst

The above needs custom memory reclaiming on shutdown, provided
by the udp_destruct_sock().

v3 -> v4:
  - reworked memory accunting, simplifying the schema
  - provide an helper for both memory scheduling and enqueuing

v1 -> v2:
  - use a udp specific destrctor to perform memory reclaiming
  - remove a couple of helpers, unneeded after the above cleanup
  - do not reclaim memory on dequeue if not under memory
    pressure
  - reworked the fwd accounting schema to avoid potential
    integer overflow

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/linux/udp.h |   1 +
 include/net/udp.h   |   4 ++
 net/ipv4/udp.c      | 111 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 116 insertions(+)

diff --git a/include/linux/udp.h b/include/linux/udp.h
index d1fd8cd..8ea7f8b 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -66,6 +66,7 @@ struct udp_sock {
 #define UDPLITE_RECV_CC  0x4		/* set via udplite setsocktopt        */
 	__u8		 pcflag;        /* marks socket as UDP-Lite if > 0    */
 	__u8		 unused[3];
+	spinlock_t	 mem_lock;	/* protects memory accounting         */
 	/*
 	 * For encapsulation sockets.
 	 */
diff --git a/include/net/udp.h b/include/net/udp.h
index ea53a87..18f1e6b 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -246,6 +246,9 @@ static inline __be16 udp_flow_src_port(struct net *net, struct sk_buff *skb,
 }
 
 /* net/ipv4/udp.c */
+void skb_consume_udp(struct sock *sk, struct sk_buff *skb, int len);
+int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb);
+
 void udp_v4_early_demux(struct sk_buff *skb);
 int udp_get_port(struct sock *sk, unsigned short snum,
 		 int (*saddr_cmp)(const struct sock *,
@@ -258,6 +261,7 @@ int udp_get_port(struct sock *sk, unsigned short snum,
 void udp4_hwcsum(struct sk_buff *skb, __be32 src, __be32 dst);
 int udp_rcv(struct sk_buff *skb);
 int udp_ioctl(struct sock *sk, int cmd, unsigned long arg);
+int udp_init_sock(struct sock *sk);
 int udp_disconnect(struct sock *sk, int flags);
 unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait);
 struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 7d96dc2..7047bb3 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1172,6 +1172,117 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
 	return ret;
 }
 
+static void udp_rmem_release(struct sock *sk, int size, int partial)
+{
+	struct udp_sock *up = udp_sk(sk);
+	int amt;
+
+	atomic_sub(size, &sk->sk_rmem_alloc);
+
+	spin_lock_bh(&up->mem_lock);
+	sk->sk_forward_alloc += size;
+	amt = (sk->sk_forward_alloc - partial) & ~(SK_MEM_QUANTUM - 1);
+	sk->sk_forward_alloc -= amt;
+	spin_unlock_bh(&up->mem_lock);
+
+	if (amt)
+		__sk_mem_reduce_allocated(sk, amt >> SK_MEM_QUANTUM_SHIFT);
+}
+
+static void udp_rmem_free(struct sk_buff *skb)
+{
+	udp_rmem_release(skb->sk, skb->truesize, 1);
+}
+
+int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
+{
+	struct sk_buff_head *list = &sk->sk_receive_queue;
+	int rmem, delta, amt, err = -ENOMEM;
+	struct udp_sock *up = udp_sk(sk);
+	int size = skb->truesize;
+
+	/* try to avoid the costly atomic add/sub pair when the receive
+	 * queue is full
+	 */
+	if (atomic_read(&sk->sk_rmem_alloc) + size > sk->sk_rcvbuf)
+		goto drop;
+
+	rmem = atomic_add_return(size, &sk->sk_rmem_alloc);
+	if (rmem > sk->sk_rcvbuf)
+		goto uncharge_drop;
+
+	spin_lock(&up->mem_lock);
+	if (size < sk->sk_forward_alloc)
+		goto unlock;
+
+	amt = sk_mem_pages(size);
+	delta = amt << SK_MEM_QUANTUM_SHIFT;
+	if (!__sk_mem_raise_allocated(sk, delta, amt, SK_MEM_RECV)) {
+		err = -ENOBUFS;
+		spin_unlock(&up->mem_lock);
+		goto uncharge_drop;
+	}
+
+	sk->sk_forward_alloc += delta;
+
+unlock:
+	sk->sk_forward_alloc -= size;
+	spin_unlock(&up->mem_lock);
+
+	/* the skb owner in now the udp socket */
+	skb_orphan(skb);
+	skb->sk = sk;
+	skb->destructor = udp_rmem_free;
+
+	skb->dev = NULL;
+	sock_skb_set_dropcount(sk, skb);
+
+	spin_lock(&list->lock);
+	__skb_queue_tail(list, skb);
+	spin_unlock(&list->lock);
+
+	if (!sock_flag(sk, SOCK_DEAD))
+		sk->sk_data_ready(sk);
+
+	return 0;
+
+uncharge_drop:
+	atomic_sub(skb->truesize, &sk->sk_rmem_alloc);
+
+drop:
+	atomic_inc(&sk->sk_drops);
+	return err;
+}
+EXPORT_SYMBOL_GPL(__udp_enqueue_schedule_skb);
+
+static void udp_destruct_sock(struct sock *sk)
+{
+	/* reclaim completely the forward allocated memory */
+	__skb_queue_purge(&sk->sk_receive_queue);
+	udp_rmem_release(sk, 0, 0);
+	inet_sock_destruct(sk);
+}
+
+int udp_init_sock(struct sock *sk)
+{
+	sk->sk_destruct = udp_destruct_sock;
+	spin_lock_init(&udp_sk(sk)->mem_lock);
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


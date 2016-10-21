Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42589 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754962AbcJULz7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Oct 2016 07:55:59 -0400
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
Subject: [PATCH net-next v6 1/3] net/socket: factor out helpers for memory and queue manipulation
Date: Fri, 21 Oct 2016 13:55:45 +0200
Message-Id: <14784e6382342c2184929ef2959e7c11faf8ff8e.1477043395.git.pabeni@redhat.com>
In-Reply-To: <cover.1477043395.git.pabeni@redhat.com>
References: <cover.1477043395.git.pabeni@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Basic sock operations that udp code can use with its own
memory accounting schema. No functional change is introduced
in the existing APIs.

v4 -> v5:
  - avoid whitespace changes

v2 -> v4:
  - avoid exporting __sock_enqueue_skb

v1 -> v2:
  - avoid export sock_rmem_free

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/net/sock.h  |  4 ++++
 net/core/datagram.c | 36 ++++++++++++++++++------------
 net/core/sock.c     | 64 +++++++++++++++++++++++++++++++++++++----------------
 3 files changed, 71 insertions(+), 33 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index ebf75db..2764895 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1274,7 +1274,9 @@ static inline struct inode *SOCK_INODE(struct socket *socket)
 /*
  * Functions for memory accounting
  */
+int __sk_mem_raise_allocated(struct sock *sk, int size, int amt, int kind);
 int __sk_mem_schedule(struct sock *sk, int size, int kind);
+void __sk_mem_reduce_allocated(struct sock *sk, int amount);
 void __sk_mem_reclaim(struct sock *sk, int amount);
 
 #define SK_MEM_QUANTUM ((int)PAGE_SIZE)
@@ -1950,6 +1952,8 @@ void sk_reset_timer(struct sock *sk, struct timer_list *timer,
 
 void sk_stop_timer(struct sock *sk, struct timer_list *timer);
 
+int __sk_queue_drop_skb(struct sock *sk, struct sk_buff *skb,
+			unsigned int flags);
 int __sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
 int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
 
diff --git a/net/core/datagram.c b/net/core/datagram.c
index b7de71f..bfb973a 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -323,6 +323,27 @@ void __skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb, int len)
 }
 EXPORT_SYMBOL(__skb_free_datagram_locked);
 
+int __sk_queue_drop_skb(struct sock *sk, struct sk_buff *skb,
+			unsigned int flags)
+{
+	int err = 0;
+
+	if (flags & MSG_PEEK) {
+		err = -ENOENT;
+		spin_lock_bh(&sk->sk_receive_queue.lock);
+		if (skb == skb_peek(&sk->sk_receive_queue)) {
+			__skb_unlink(skb, &sk->sk_receive_queue);
+			atomic_dec(&skb->users);
+			err = 0;
+		}
+		spin_unlock_bh(&sk->sk_receive_queue.lock);
+	}
+
+	atomic_inc(&sk->sk_drops);
+	return err;
+}
+EXPORT_SYMBOL(__sk_queue_drop_skb);
+
 /**
  *	skb_kill_datagram - Free a datagram skbuff forcibly
  *	@sk: socket
@@ -346,23 +367,10 @@ void __skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb, int len)
 
 int skb_kill_datagram(struct sock *sk, struct sk_buff *skb, unsigned int flags)
 {
-	int err = 0;
-
-	if (flags & MSG_PEEK) {
-		err = -ENOENT;
-		spin_lock_bh(&sk->sk_receive_queue.lock);
-		if (skb == skb_peek(&sk->sk_receive_queue)) {
-			__skb_unlink(skb, &sk->sk_receive_queue);
-			atomic_dec(&skb->users);
-			err = 0;
-		}
-		spin_unlock_bh(&sk->sk_receive_queue.lock);
-	}
+	int err = __sk_queue_drop_skb(sk, skb, flags);
 
 	kfree_skb(skb);
-	atomic_inc(&sk->sk_drops);
 	sk_mem_reclaim_partial(sk);
-
 	return err;
 }
 EXPORT_SYMBOL(skb_kill_datagram);
diff --git a/net/core/sock.c b/net/core/sock.c
index c73e28f..d8e4532e 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2091,24 +2091,18 @@ int sk_wait_data(struct sock *sk, long *timeo, const struct sk_buff *skb)
 EXPORT_SYMBOL(sk_wait_data);
 
 /**
- *	__sk_mem_schedule - increase sk_forward_alloc and memory_allocated
+ *	__sk_mem_raise_allocated - increase memory_allocated
  *	@sk: socket
  *	@size: memory size to allocate
+ *	@amt: pages to allocate
  *	@kind: allocation type
  *
- *	If kind is SK_MEM_SEND, it means wmem allocation. Otherwise it means
- *	rmem allocation. This function assumes that protocols which have
- *	memory_pressure use sk_wmem_queued as write buffer accounting.
+ *	Similar to __sk_mem_schedule(), but does not update sk_forward_alloc
  */
-int __sk_mem_schedule(struct sock *sk, int size, int kind)
+int __sk_mem_raise_allocated(struct sock *sk, int size, int amt, int kind)
 {
 	struct proto *prot = sk->sk_prot;
-	int amt = sk_mem_pages(size);
-	long allocated;
-
-	sk->sk_forward_alloc += amt * SK_MEM_QUANTUM;
-
-	allocated = sk_memory_allocated_add(sk, amt);
+	long allocated = sk_memory_allocated_add(sk, amt);
 
 	if (mem_cgroup_sockets_enabled && sk->sk_memcg &&
 	    !mem_cgroup_charge_skmem(sk->sk_memcg, amt))
@@ -2169,9 +2163,6 @@ int __sk_mem_schedule(struct sock *sk, int size, int kind)
 
 	trace_sock_exceed_buf_limit(sk, prot, allocated);
 
-	/* Alas. Undo changes. */
-	sk->sk_forward_alloc -= amt * SK_MEM_QUANTUM;
-
 	sk_memory_allocated_sub(sk, amt);
 
 	if (mem_cgroup_sockets_enabled && sk->sk_memcg)
@@ -2179,18 +2170,40 @@ int __sk_mem_schedule(struct sock *sk, int size, int kind)
 
 	return 0;
 }
+EXPORT_SYMBOL(__sk_mem_raise_allocated);
+
+/**
+ *	__sk_mem_schedule - increase sk_forward_alloc and memory_allocated
+ *	@sk: socket
+ *	@size: memory size to allocate
+ *	@kind: allocation type
+ *
+ *	If kind is SK_MEM_SEND, it means wmem allocation. Otherwise it means
+ *	rmem allocation. This function assumes that protocols which have
+ *	memory_pressure use sk_wmem_queued as write buffer accounting.
+ */
+int __sk_mem_schedule(struct sock *sk, int size, int kind)
+{
+	int ret, amt = sk_mem_pages(size);
+
+	sk->sk_forward_alloc += amt << SK_MEM_QUANTUM_SHIFT;
+	ret = __sk_mem_raise_allocated(sk, size, amt, kind);
+	if (!ret)
+		sk->sk_forward_alloc -= amt << SK_MEM_QUANTUM_SHIFT;
+	return ret;
+}
 EXPORT_SYMBOL(__sk_mem_schedule);
 
 /**
- *	__sk_mem_reclaim - reclaim memory_allocated
+ *	__sk_mem_reduce_allocated - reclaim memory_allocated
  *	@sk: socket
- *	@amount: number of bytes (rounded down to a SK_MEM_QUANTUM multiple)
+ *	@amount: number of quanta
+ *
+ *	Similar to __sk_mem_reclaim(), but does not update sk_forward_alloc
  */
-void __sk_mem_reclaim(struct sock *sk, int amount)
+void __sk_mem_reduce_allocated(struct sock *sk, int amount)
 {
-	amount >>= SK_MEM_QUANTUM_SHIFT;
 	sk_memory_allocated_sub(sk, amount);
-	sk->sk_forward_alloc -= amount << SK_MEM_QUANTUM_SHIFT;
 
 	if (mem_cgroup_sockets_enabled && sk->sk_memcg)
 		mem_cgroup_uncharge_skmem(sk->sk_memcg, amount);
@@ -2199,6 +2212,19 @@ void __sk_mem_reclaim(struct sock *sk, int amount)
 	    (sk_memory_allocated(sk) < sk_prot_mem_limits(sk, 0)))
 		sk_leave_memory_pressure(sk);
 }
+EXPORT_SYMBOL(__sk_mem_reduce_allocated);
+
+/**
+ *	__sk_mem_reclaim - reclaim sk_forward_alloc and memory_allocated
+ *	@sk: socket
+ *	@amount: number of bytes (rounded down to a SK_MEM_QUANTUM multiple)
+ */
+void __sk_mem_reclaim(struct sock *sk, int amount)
+{
+	amount >>= SK_MEM_QUANTUM_SHIFT;
+	sk->sk_forward_alloc -= amount << SK_MEM_QUANTUM_SHIFT;
+	__sk_mem_reduce_allocated(sk, amount);
+}
 EXPORT_SYMBOL(__sk_mem_reclaim);
 
 int sk_set_peek_off(struct sock *sk, int val)
-- 
1.8.3.1


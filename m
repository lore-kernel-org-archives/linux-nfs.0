Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59118 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935303AbcI0Q6R (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 27 Sep 2016 12:58:17 -0400
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
Subject: [PATCH net-next v2 3/3] udp: use it's own memory accounting schema
Date: Tue, 27 Sep 2016 18:58:02 +0200
Message-Id: <bc55b0885e0f93895c211168561a6b3403bade10.1474995024.git.pabeni@redhat.com>
In-Reply-To: <cover.1474995024.git.pabeni@redhat.com>
References: <cover.1474995024.git.pabeni@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Completely avoid default sock memory accounting and replace it
with udp-specific accounting.

The udp code now tracks the memory pressure status, to optimize
memory reclaiming.

Since the new memory accounting model does not require socket
locking, remove the lock on enqueue and free and avoid using the
backlog on enqueue.

Be sure to clean-up rx queue memory on socket destruction, using
udp its own sk_destruct.

Tested using pktgen with random src port, 64 bytes packet,
wire-speed on a 10G link as sender and udp_sink as the receiver,
using an l4 tuple rxhash to stress the contention, and one or more
udp_sink instances with reuseport.

nr readers      Kpps (vanilla)  Kpps (patched)
1               150             600
3               1300            2300
6               3100            3900
9               4300            4650
12              5800            6550

v1 -> v2:
  - add memory pressure support
  - fixed dropwatch accounting for ipv6

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/udp.c        | 41 +++++++++++++----------------------------
 net/ipv6/udp.c        | 32 ++++++++++++--------------------
 net/sunrpc/svcsock.c  | 20 ++++++++++++++++----
 net/sunrpc/xprtsock.c |  2 +-
 4 files changed, 42 insertions(+), 53 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 2218901..c500d51 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1338,13 +1338,8 @@ static int first_packet_length(struct sock *sk)
 	res = skb ? skb->len : -1;
 	spin_unlock_bh(&rcvq->lock);
 
-	if (!skb_queue_empty(&list_kill)) {
-		bool slow = lock_sock_fast(sk);
-
+	if (!skb_queue_empty(&list_kill))
 		__skb_queue_purge(&list_kill);
-		sk_mem_reclaim_partial(sk);
-		unlock_sock_fast(sk, slow);
-	}
 	return res;
 }
 
@@ -1393,7 +1388,6 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 	int err;
 	int is_udplite = IS_UDPLITE(sk);
 	bool checksum_valid = false;
-	bool slow;
 
 	if (flags & MSG_ERRQUEUE)
 		return ip_recv_error(sk, msg, len, addr_len);
@@ -1434,13 +1428,12 @@ try_again:
 	}
 
 	if (unlikely(err)) {
-		trace_kfree_skb(skb, udp_recvmsg);
 		if (!peeked) {
 			atomic_inc(&sk->sk_drops);
 			UDP_INC_STATS(sock_net(sk),
 				      UDP_MIB_INERRORS, is_udplite);
 		}
-		skb_free_datagram_locked(sk, skb);
+		kfree_skb(skb);
 		return err;
 	}
 
@@ -1465,16 +1458,15 @@ try_again:
 	if (flags & MSG_TRUNC)
 		err = ulen;
 
-	__skb_free_datagram_locked(sk, skb, peeking ? -err : err);
+	skb_consume_udp(sk, skb, peeking ? -err : err);
 	return err;
 
 csum_copy_err:
-	slow = lock_sock_fast(sk);
-	if (!skb_kill_datagram(sk, skb, flags)) {
+	if (!__sk_queue_drop_skb(sk, skb, flags)) {
 		UDP_INC_STATS(sock_net(sk), UDP_MIB_CSUMERRORS, is_udplite);
 		UDP_INC_STATS(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
 	}
-	unlock_sock_fast(sk, slow);
+	kfree_skb(skb);
 
 	/* starting over for a new packet, but check if we need to yield */
 	cond_resched();
@@ -1593,7 +1585,7 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		sk_incoming_cpu_update(sk);
 	}
 
-	rc = __sock_queue_rcv_skb(sk, skb);
+	rc = udp_rmem_schedule(sk, skb);
 	if (rc < 0) {
 		int is_udplite = IS_UDPLITE(sk);
 
@@ -1607,8 +1599,8 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		return -1;
 	}
 
+	__sock_enqueue_skb(sk, skb);
 	return 0;
-
 }
 
 static struct static_key udp_encap_needed __read_mostly;
@@ -1630,7 +1622,6 @@ EXPORT_SYMBOL(udp_encap_enable);
 int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	struct udp_sock *up = udp_sk(sk);
-	int rc;
 	int is_udplite = IS_UDPLITE(sk);
 
 	/*
@@ -1723,19 +1714,8 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		goto drop;
 	}
 
-	rc = 0;
-
 	ipv4_pktinfo_prepare(sk, skb);
-	bh_lock_sock(sk);
-	if (!sock_owned_by_user(sk))
-		rc = __udp_queue_rcv_skb(sk, skb);
-	else if (sk_add_backlog(sk, skb, sk->sk_rcvbuf)) {
-		bh_unlock_sock(sk);
-		goto drop;
-	}
-	bh_unlock_sock(sk);
-
-	return rc;
+	return __udp_queue_rcv_skb(sk, skb);
 
 csum_error:
 	__UDP_INC_STATS(sock_net(sk), UDP_MIB_CSUMERRORS, is_udplite);
@@ -2345,6 +2325,7 @@ struct proto udp_prot = {
 	.connect	   = ip4_datagram_connect,
 	.disconnect	   = udp_disconnect,
 	.ioctl		   = udp_ioctl,
+	.init		   = udp_init_sock,
 	.destroy	   = udp_destroy_sock,
 	.setsockopt	   = udp_setsockopt,
 	.getsockopt	   = udp_getsockopt,
@@ -2357,7 +2338,10 @@ struct proto udp_prot = {
 	.unhash		   = udp_lib_unhash,
 	.rehash		   = udp_v4_rehash,
 	.get_port	   = udp_v4_get_port,
+	.enter_memory_pressure = udp_enter_memory_pressure,
+	.sockets_allocated = &udp_sockets_allocated,
 	.memory_allocated  = &udp_memory_allocated,
+	.memory_pressure   = &udp_memory_pressure,
 	.sysctl_mem	   = sysctl_udp_mem,
 	.sysctl_wmem	   = &sysctl_udp_wmem_min,
 	.sysctl_rmem	   = &sysctl_udp_rmem_min,
@@ -2641,6 +2625,7 @@ void __init udp_init(void)
 {
 	unsigned long limit;
 
+	percpu_counter_init(&udp_sockets_allocated, 0, GFP_KERNEL);
 	udp_table_init(&udp_table, "UDP");
 	limit = nr_free_buffer_pages() / 8;
 	limit = max(limit, 128UL);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 9aa7c1c..0b80520 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -334,7 +334,6 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 	int is_udplite = IS_UDPLITE(sk);
 	bool checksum_valid = false;
 	int is_udp4;
-	bool slow;
 
 	if (flags & MSG_ERRQUEUE)
 		return ipv6_recv_error(sk, msg, len, addr_len);
@@ -378,7 +377,6 @@ try_again:
 			goto csum_copy_err;
 	}
 	if (unlikely(err)) {
-		trace_kfree_skb(skb, udpv6_recvmsg);
 		if (!peeked) {
 			atomic_inc(&sk->sk_drops);
 			if (is_udp4)
@@ -388,7 +386,7 @@ try_again:
 				UDP6_INC_STATS(sock_net(sk), UDP_MIB_INERRORS,
 					       is_udplite);
 		}
-		skb_free_datagram_locked(sk, skb);
+		kfree_skb(skb);
 		return err;
 	}
 	if (!peeked) {
@@ -437,12 +435,11 @@ try_again:
 	if (flags & MSG_TRUNC)
 		err = ulen;
 
-	__skb_free_datagram_locked(sk, skb, peeking ? -err : err);
+	skb_consume_udp(sk, skb, peeking ? -err : err);
 	return err;
 
 csum_copy_err:
-	slow = lock_sock_fast(sk);
-	if (!skb_kill_datagram(sk, skb, flags)) {
+	if (!__sk_queue_drop_skb(sk, skb, flags)) {
 		if (is_udp4) {
 			UDP_INC_STATS(sock_net(sk),
 				      UDP_MIB_CSUMERRORS, is_udplite);
@@ -455,7 +452,7 @@ csum_copy_err:
 				       UDP_MIB_INERRORS, is_udplite);
 		}
 	}
-	unlock_sock_fast(sk, slow);
+	kfree_skb(skb);
 
 	/* starting over for a new packet, but check if we need to yield */
 	cond_resched();
@@ -523,7 +520,7 @@ static int __udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		sk_incoming_cpu_update(sk);
 	}
 
-	rc = __sock_queue_rcv_skb(sk, skb);
+	rc = udp_rmem_schedule(sk, skb);
 	if (rc < 0) {
 		int is_udplite = IS_UDPLITE(sk);
 
@@ -535,6 +532,8 @@ static int __udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		kfree_skb(skb);
 		return -1;
 	}
+
+	__sock_enqueue_skb(sk, skb);
 	return 0;
 }
 
@@ -556,7 +555,6 @@ EXPORT_SYMBOL(udpv6_encap_enable);
 int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	struct udp_sock *up = udp_sk(sk);
-	int rc;
 	int is_udplite = IS_UDPLITE(sk);
 
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
@@ -630,17 +628,7 @@ int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 	skb_dst_drop(skb);
 
-	bh_lock_sock(sk);
-	rc = 0;
-	if (!sock_owned_by_user(sk))
-		rc = __udpv6_queue_rcv_skb(sk, skb);
-	else if (sk_add_backlog(sk, skb, sk->sk_rcvbuf)) {
-		bh_unlock_sock(sk);
-		goto drop;
-	}
-	bh_unlock_sock(sk);
-
-	return rc;
+	return __udpv6_queue_rcv_skb(sk, skb);
 
 csum_error:
 	__UDP6_INC_STATS(sock_net(sk), UDP_MIB_CSUMERRORS, is_udplite);
@@ -1433,6 +1421,7 @@ struct proto udpv6_prot = {
 	.connect	   = ip6_datagram_connect,
 	.disconnect	   = udp_disconnect,
 	.ioctl		   = udp_ioctl,
+	.init		   = udp_init_sock,
 	.destroy	   = udpv6_destroy_sock,
 	.setsockopt	   = udpv6_setsockopt,
 	.getsockopt	   = udpv6_getsockopt,
@@ -1444,7 +1433,10 @@ struct proto udpv6_prot = {
 	.unhash		   = udp_lib_unhash,
 	.rehash		   = udp_v6_rehash,
 	.get_port	   = udp_v6_get_port,
+	.enter_memory_pressure = udp_enter_memory_pressure,
+	.sockets_allocated = &udp_sockets_allocated,
 	.memory_allocated  = &udp_memory_allocated,
+	.memory_pressure   = &udp_memory_pressure,
 	.sysctl_mem	   = sysctl_udp_mem,
 	.sysctl_wmem	   = &sysctl_udp_wmem_min,
 	.sysctl_rmem	   = &sysctl_udp_rmem_min,
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 57625f6..e2a55dc 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -39,6 +39,7 @@
 #include <net/checksum.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
+#include <net/udp.h>
 #include <net/tcp.h>
 #include <net/tcp_states.h>
 #include <asm/uaccess.h>
@@ -129,6 +130,18 @@ static void svc_release_skb(struct svc_rqst *rqstp)
 	}
 }
 
+static void svc_release_udp_skb(struct svc_rqst *rqstp)
+{
+	struct sk_buff *skb = rqstp->rq_xprt_ctxt;
+
+	if (skb) {
+		rqstp->rq_xprt_ctxt = NULL;
+
+		dprintk("svc: service %p, releasing skb %p\n", rqstp, skb);
+		consume_skb(skb);
+	}
+}
+
 union svc_pktinfo_u {
 	struct in_pktinfo pkti;
 	struct in6_pktinfo pkti6;
@@ -575,7 +588,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 			goto out_free;
 		}
 		local_bh_enable();
-		skb_free_datagram_locked(svsk->sk_sk, skb);
+		consume_skb(skb);
 	} else {
 		/* we can use it in-place */
 		rqstp->rq_arg.head[0].iov_base = skb->data;
@@ -602,8 +615,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 
 	return len;
 out_free:
-	trace_kfree_skb(skb, svc_udp_recvfrom);
-	skb_free_datagram_locked(svsk->sk_sk, skb);
+	kfree_skb(skb);
 	return 0;
 }
 
@@ -660,7 +672,7 @@ static struct svc_xprt_ops svc_udp_ops = {
 	.xpo_create = svc_udp_create,
 	.xpo_recvfrom = svc_udp_recvfrom,
 	.xpo_sendto = svc_udp_sendto,
-	.xpo_release_rqst = svc_release_skb,
+	.xpo_release_rqst = svc_release_udp_skb,
 	.xpo_detach = svc_sock_detach,
 	.xpo_free = svc_sock_free,
 	.xpo_prep_reply_hdr = svc_udp_prep_reply_hdr,
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index bf16883..8e04a43 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1074,7 +1074,7 @@ static void xs_udp_data_receive(struct sock_xprt *transport)
 		skb = skb_recv_datagram(sk, 0, 1, &err);
 		if (skb != NULL) {
 			xs_udp_data_read_skb(&transport->xprt, sk, skb);
-			skb_free_datagram_locked(sk, skb);
+			consume_skb(skb);
 			continue;
 		}
 		if (!test_and_clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state))
-- 
1.8.3.1


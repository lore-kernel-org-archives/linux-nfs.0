Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37132 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757492AbcIURYI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Sep 2016 13:24:08 -0400
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
Subject: [PATCH net-next 3/3] udp: use it's own memory accounting schema
Date: Wed, 21 Sep 2016 19:23:16 +0200
Message-Id: <9e6a28cad6a0b68f8a11c5abb406bd8ede27b71e.1474477902.git.pabeni@redhat.com>
In-Reply-To: <cover.1474477902.git.pabeni@redhat.com>
References: <cover.1474477902.git.pabeni@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Completely avoid default sock memory accounting and replace it
with udp-specific accounting.

Since the new memory accounting model does not require socket
locking, remove the lock on enqueue and free and avoid using the
backlog on enqueue.

Be sure to clean-up rx queue memory on socket destruction, using
udp its own sk_destruct.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/udp.c        | 39 ++++++++++-----------------------------
 net/ipv6/udp.c        | 28 +++++++++-------------------
 net/sunrpc/svcsock.c  | 22 ++++++++++++++++++----
 net/sunrpc/xprtsock.c |  2 +-
 4 files changed, 38 insertions(+), 53 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 98480af..cb617ee 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1358,13 +1358,8 @@ static int first_packet_length(struct sock *sk)
 	res = skb ? skb->len : -1;
 	spin_unlock_bh(&rcvq->lock);
 
-	if (!skb_queue_empty(&list_kill)) {
-		bool slow = lock_sock_fast(sk);
-
-		__skb_queue_purge(&list_kill);
-		sk_mem_reclaim_partial(sk);
-		unlock_sock_fast(sk, slow);
-	}
+	if (!skb_queue_empty(&list_kill))
+		udp_queue_purge(sk, &list_kill, 1);
 	return res;
 }
 
@@ -1413,7 +1408,6 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 	int err;
 	int is_udplite = IS_UDPLITE(sk);
 	bool checksum_valid = false;
-	bool slow;
 
 	if (flags & MSG_ERRQUEUE)
 		return ip_recv_error(sk, msg, len, addr_len);
@@ -1454,13 +1448,12 @@ try_again:
 	}
 
 	if (unlikely(err)) {
-		trace_kfree_skb(skb, udp_recvmsg);
 		if (!peeked) {
 			atomic_inc(&sk->sk_drops);
 			UDP_INC_STATS(sock_net(sk),
 				      UDP_MIB_INERRORS, is_udplite);
 		}
-		skb_free_datagram_locked(sk, skb);
+		skb_free_udp(sk, skb);
 		return err;
 	}
 
@@ -1485,16 +1478,15 @@ try_again:
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
+	skb_free_udp(sk, skb);
 
 	/* starting over for a new packet, but check if we need to yield */
 	cond_resched();
@@ -1613,7 +1605,7 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		sk_incoming_cpu_update(sk);
 	}
 
-	rc = __sock_queue_rcv_skb(sk, skb);
+	rc = udp_rmem_schedule(sk, skb);
 	if (rc < 0) {
 		int is_udplite = IS_UDPLITE(sk);
 
@@ -1627,8 +1619,8 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		return -1;
 	}
 
+	__sock_enqueue_skb(sk, skb);
 	return 0;
-
 }
 
 static struct static_key udp_encap_needed __read_mostly;
@@ -1650,7 +1642,6 @@ EXPORT_SYMBOL(udp_encap_enable);
 int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	struct udp_sock *up = udp_sk(sk);
-	int rc;
 	int is_udplite = IS_UDPLITE(sk);
 
 	/*
@@ -1743,19 +1734,8 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
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
@@ -2365,6 +2345,7 @@ struct proto udp_prot = {
 	.connect	   = ip4_datagram_connect,
 	.disconnect	   = udp_disconnect,
 	.ioctl		   = udp_ioctl,
+	.init		   = udp_init_sock,
 	.destroy	   = udp_destroy_sock,
 	.setsockopt	   = udp_setsockopt,
 	.getsockopt	   = udp_getsockopt,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 9aa7c1c..6f8e160 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -334,7 +334,6 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 	int is_udplite = IS_UDPLITE(sk);
 	bool checksum_valid = false;
 	int is_udp4;
-	bool slow;
 
 	if (flags & MSG_ERRQUEUE)
 		return ipv6_recv_error(sk, msg, len, addr_len);
@@ -388,7 +387,7 @@ try_again:
 				UDP6_INC_STATS(sock_net(sk), UDP_MIB_INERRORS,
 					       is_udplite);
 		}
-		skb_free_datagram_locked(sk, skb);
+		skb_free_udp(sk, skb);
 		return err;
 	}
 	if (!peeked) {
@@ -437,12 +436,11 @@ try_again:
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
@@ -455,7 +453,7 @@ csum_copy_err:
 				       UDP_MIB_INERRORS, is_udplite);
 		}
 	}
-	unlock_sock_fast(sk, slow);
+	skb_free_udp(sk, skb);
 
 	/* starting over for a new packet, but check if we need to yield */
 	cond_resched();
@@ -523,7 +521,7 @@ static int __udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		sk_incoming_cpu_update(sk);
 	}
 
-	rc = __sock_queue_rcv_skb(sk, skb);
+	rc = udp_rmem_schedule(sk, skb);
 	if (rc < 0) {
 		int is_udplite = IS_UDPLITE(sk);
 
@@ -535,6 +533,8 @@ static int __udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		kfree_skb(skb);
 		return -1;
 	}
+
+	__sock_enqueue_skb(sk, skb);
 	return 0;
 }
 
@@ -556,7 +556,6 @@ EXPORT_SYMBOL(udpv6_encap_enable);
 int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	struct udp_sock *up = udp_sk(sk);
-	int rc;
 	int is_udplite = IS_UDPLITE(sk);
 
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
@@ -630,17 +629,7 @@ int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
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
@@ -1433,6 +1422,7 @@ struct proto udpv6_prot = {
 	.connect	   = ip6_datagram_connect,
 	.disconnect	   = udp_disconnect,
 	.ioctl		   = udp_ioctl,
+	.init		   = udp_init_sock,
 	.destroy	   = udpv6_destroy_sock,
 	.setsockopt	   = udpv6_setsockopt,
 	.getsockopt	   = udpv6_getsockopt,
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 57625f6..b5739c7 100644
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
@@ -129,6 +130,20 @@ static void svc_release_skb(struct svc_rqst *rqstp)
 	}
 }
 
+static void svc_release_udp_skb(struct svc_rqst *rqstp)
+{
+	struct sk_buff *skb = rqstp->rq_xprt_ctxt;
+
+	if (skb) {
+		struct svc_sock *svsk =
+			container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
+		rqstp->rq_xprt_ctxt = NULL;
+
+		dprintk("svc: service %p, releasing skb %p\n", rqstp, skb);
+		skb_consume_udp(svsk->sk_sk, skb, 0);
+	}
+}
+
 union svc_pktinfo_u {
 	struct in_pktinfo pkti;
 	struct in6_pktinfo pkti6;
@@ -575,7 +590,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 			goto out_free;
 		}
 		local_bh_enable();
-		skb_free_datagram_locked(svsk->sk_sk, skb);
+		skb_consume_udp(svsk->sk_sk, skb, 0);
 	} else {
 		/* we can use it in-place */
 		rqstp->rq_arg.head[0].iov_base = skb->data;
@@ -602,8 +617,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 
 	return len;
 out_free:
-	trace_kfree_skb(skb, svc_udp_recvfrom);
-	skb_free_datagram_locked(svsk->sk_sk, skb);
+	skb_free_udp(svsk->sk_sk, skb);
 	return 0;
 }
 
@@ -660,7 +674,7 @@ static struct svc_xprt_ops svc_udp_ops = {
 	.xpo_create = svc_udp_create,
 	.xpo_recvfrom = svc_udp_recvfrom,
 	.xpo_sendto = svc_udp_sendto,
-	.xpo_release_rqst = svc_release_skb,
+	.xpo_release_rqst = svc_release_udp_skb,
 	.xpo_detach = svc_sock_detach,
 	.xpo_free = svc_sock_free,
 	.xpo_prep_reply_hdr = svc_udp_prep_reply_hdr,
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 8ede3bc..b75c2c3 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1074,7 +1074,7 @@ static void xs_udp_data_receive(struct sock_xprt *transport)
 		skb = skb_recv_datagram(sk, 0, 1, &err);
 		if (skb != NULL) {
 			xs_udp_data_read_skb(&transport->xprt, sk, skb);
-			skb_free_datagram(sk, skb);
+			skb_consume_udp(sk, skb, 0);
 			continue;
 		}
 		if (!test_and_clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state))
-- 
1.8.3.1


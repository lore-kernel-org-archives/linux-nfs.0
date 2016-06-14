Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34777 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752727AbcFNTEg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2016 15:04:36 -0400
Received: by mail-it0-f65.google.com with SMTP id d71so419272ith.1
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2016 12:04:36 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] SUNRPC: Small optimisation of client receive
Date: Tue, 14 Jun 2016 15:04:02 -0400
Message-Id: <1465931046-30696-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Do not queue the client receive work if we're still processing.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/xprtsock.h |  1 +
 net/sunrpc/xprtsock.c           | 44 ++++++++++++++++++++++++++++++-----------
 2 files changed, 34 insertions(+), 11 deletions(-)

diff --git a/include/linux/sunrpc/xprtsock.h b/include/linux/sunrpc/xprtsock.h
index 0ece4ba06f06..bef3fb0abb8f 100644
--- a/include/linux/sunrpc/xprtsock.h
+++ b/include/linux/sunrpc/xprtsock.h
@@ -80,6 +80,7 @@ struct sock_xprt {
 #define TCP_RPC_REPLY		(1UL << 6)
 
 #define XPRT_SOCK_CONNECTING	1U
+#define XPRT_SOCK_DATA_READY	(2)
 
 #endif /* __KERNEL__ */
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 2d3e0c42361e..2f2178027761 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -755,11 +755,19 @@ static void xs_restore_old_callbacks(struct sock_xprt *transport, struct sock *s
 	sk->sk_error_report = transport->old_error_report;
 }
 
+static void xs_sock_reset_state_flags(struct rpc_xprt *xprt)
+{
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+
+	clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state);
+}
+
 static void xs_sock_reset_connection_flags(struct rpc_xprt *xprt)
 {
 	smp_mb__before_atomic();
 	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 	clear_bit(XPRT_CLOSING, &xprt->state);
+	xs_sock_reset_state_flags(xprt);
 	smp_mb__after_atomic();
 }
 
@@ -962,10 +970,13 @@ static void xs_local_data_receive(struct sock_xprt *transport)
 		goto out;
 	for (;;) {
 		skb = skb_recv_datagram(sk, 0, 1, &err);
-		if (skb == NULL)
+		if (skb != NULL) {
+			xs_local_data_read_skb(&transport->xprt, sk, skb);
+			skb_free_datagram(sk, skb);
+			continue;
+		}
+		if (!test_and_clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state))
 			break;
-		xs_local_data_read_skb(&transport->xprt, sk, skb);
-		skb_free_datagram(sk, skb);
 	}
 out:
 	mutex_unlock(&transport->recv_mutex);
@@ -1043,10 +1054,13 @@ static void xs_udp_data_receive(struct sock_xprt *transport)
 		goto out;
 	for (;;) {
 		skb = skb_recv_datagram(sk, 0, 1, &err);
-		if (skb == NULL)
+		if (skb != NULL) {
+			xs_udp_data_read_skb(&transport->xprt, sk, skb);
+			skb_free_datagram(sk, skb);
+			continue;
+		}
+		if (!test_and_clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state))
 			break;
-		xs_udp_data_read_skb(&transport->xprt, sk, skb);
-		skb_free_datagram(sk, skb);
 	}
 out:
 	mutex_unlock(&transport->recv_mutex);
@@ -1074,7 +1088,8 @@ static void xs_data_ready(struct sock *sk)
 	if (xprt != NULL) {
 		struct sock_xprt *transport = container_of(xprt,
 				struct sock_xprt, xprt);
-		queue_work(rpciod_workqueue, &transport->recv_worker);
+		if (!test_and_set_bit(XPRT_SOCK_DATA_READY, &transport->sock_state))
+			queue_work(rpciod_workqueue, &transport->recv_worker);
 	}
 	read_unlock_bh(&sk->sk_callback_lock);
 }
@@ -1474,10 +1489,15 @@ static void xs_tcp_data_receive(struct sock_xprt *transport)
 	for (;;) {
 		lock_sock(sk);
 		read = tcp_read_sock(sk, &rd_desc, xs_tcp_data_recv);
-		release_sock(sk);
-		if (read <= 0)
-			break;
-		total += read;
+		if (read <= 0) {
+			clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state);
+			release_sock(sk);
+			if (!test_bit(XPRT_SOCK_DATA_READY, &transport->sock_state))
+				break;
+		} else {
+			release_sock(sk);
+			total += read;
+		}
 		rd_desc.count = 65536;
 	}
 out:
@@ -1508,6 +1528,8 @@ static void xs_tcp_data_ready(struct sock *sk)
 	if (!(xprt = xprt_from_sock(sk)))
 		goto out;
 	transport = container_of(xprt, struct sock_xprt, xprt);
+	if (test_and_set_bit(XPRT_SOCK_DATA_READY, &transport->sock_state))
+		goto out;
 
 	/* Any data means we had a useful conversation, so
 	 * the we don't need to delay the next reconnect
-- 
2.5.5


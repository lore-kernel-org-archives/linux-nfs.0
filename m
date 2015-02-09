Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:36049 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759093AbbBIDH4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Feb 2015 22:07:56 -0500
Received: by ierx19 with SMTP id x19so7106640ier.3
        for <linux-nfs@vger.kernel.org>; Sun, 08 Feb 2015 19:07:55 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 09/11] SUNRPC: Remove TCP socket linger code
Date: Sun,  8 Feb 2015 22:07:40 -0500
Message-Id: <1423451262-84493-10-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423451262-84493-9-git-send-email-trond.myklebust@primarydata.com>
References: <1423451262-84493-1-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-2-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-3-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-4-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-5-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-6-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-7-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-8-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-9-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we no longer use the partial shutdown code when closing the
socket, we no longer need to worry about the TCP linger2 state.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 35 -----------------------------------
 1 file changed, 35 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index b5dfb4f14ef9..ca45f1c1c36d 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1399,37 +1399,6 @@ out:
 	read_unlock_bh(&sk->sk_callback_lock);
 }
 
-/*
- * Do the equivalent of linger/linger2 handling for dealing with
- * broken servers that don't close the socket in a timely
- * fashion
- */
-static void xs_tcp_schedule_linger_timeout(struct rpc_xprt *xprt,
-		unsigned long timeout)
-{
-	struct sock_xprt *transport;
-
-	if (xprt_test_and_set_connecting(xprt))
-		return;
-	set_bit(XPRT_CONNECTION_ABORT, &xprt->state);
-	transport = container_of(xprt, struct sock_xprt, xprt);
-	queue_delayed_work(rpciod_workqueue, &transport->connect_worker,
-			   timeout);
-}
-
-static void xs_tcp_cancel_linger_timeout(struct rpc_xprt *xprt)
-{
-	struct sock_xprt *transport;
-
-	transport = container_of(xprt, struct sock_xprt, xprt);
-
-	if (!test_bit(XPRT_CONNECTION_ABORT, &xprt->state) ||
-	    !cancel_delayed_work(&transport->connect_worker))
-		return;
-	clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
-	xprt_clear_connecting(xprt);
-}
-
 static void xs_sock_mark_closed(struct rpc_xprt *xprt)
 {
 	xs_sock_reset_connection_flags(xprt);
@@ -1485,7 +1454,6 @@ static void xs_tcp_state_change(struct sock *sk)
 		clear_bit(XPRT_CONNECTED, &xprt->state);
 		clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 		smp_mb__after_atomic();
-		xs_tcp_schedule_linger_timeout(xprt, xs_tcp_fin_timeout);
 		break;
 	case TCP_CLOSE_WAIT:
 		/* The server initiated a shutdown of the socket */
@@ -1502,13 +1470,11 @@ static void xs_tcp_state_change(struct sock *sk)
 		break;
 	case TCP_LAST_ACK:
 		set_bit(XPRT_CLOSING, &xprt->state);
-		xs_tcp_schedule_linger_timeout(xprt, xs_tcp_fin_timeout);
 		smp_mb__before_atomic();
 		clear_bit(XPRT_CONNECTED, &xprt->state);
 		smp_mb__after_atomic();
 		break;
 	case TCP_CLOSE:
-		xs_tcp_cancel_linger_timeout(xprt);
 		xs_sock_mark_closed(xprt);
 	}
  out:
@@ -2106,7 +2072,6 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 
 		/* socket options */
 		sock_reset_flag(sk, SOCK_LINGER);
-		tcp_sk(sk)->linger2 = 0;
 		tcp_sk(sk)->nonagle |= TCP_NAGLE_OFF;
 
 		xprt_clear_connected(xprt);
-- 
2.1.0


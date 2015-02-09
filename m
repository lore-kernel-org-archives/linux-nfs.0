Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:42300 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759235AbbBIDHu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Feb 2015 22:07:50 -0500
Received: by iery20 with SMTP id y20so5074159ier.9
        for <linux-nfs@vger.kernel.org>; Sun, 08 Feb 2015 19:07:50 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 04/11] SUNRPC: Ensure xs_reset_transport() resets the close connection flags
Date: Sun,  8 Feb 2015 22:07:35 -0500
Message-Id: <1423451262-84493-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423451262-84493-4-git-send-email-trond.myklebust@primarydata.com>
References: <1423451262-84493-1-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-2-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-3-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Otherwise, we may end up looping.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 29 +++++++++++++----------------
 1 file changed, 13 insertions(+), 16 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ea1882f97912..0fa7ed93dc20 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -803,10 +803,21 @@ static void xs_error_report(struct sock *sk)
 	read_unlock_bh(&sk->sk_callback_lock);
 }
 
+static void xs_sock_reset_connection_flags(struct rpc_xprt *xprt)
+{
+	smp_mb__before_atomic();
+	clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
+	clear_bit(XPRT_CONNECTION_CLOSE, &xprt->state);
+	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
+	clear_bit(XPRT_CLOSING, &xprt->state);
+	smp_mb__after_atomic();
+}
+
 static void xs_reset_transport(struct sock_xprt *transport)
 {
 	struct socket *sock = transport->sock;
 	struct sock *sk = transport->inet;
+	struct rpc_xprt *xprt = &transport->xprt;
 
 	if (sk == NULL)
 		return;
@@ -819,8 +830,9 @@ static void xs_reset_transport(struct sock_xprt *transport)
 
 	xs_restore_old_callbacks(transport, sk);
 	write_unlock_bh(&sk->sk_callback_lock);
+	xs_sock_reset_connection_flags(xprt);
 
-	trace_rpc_socket_close(&transport->xprt, sock);
+	trace_rpc_socket_close(xprt, sock);
 	sock_release(sock);
 }
 
@@ -845,11 +857,6 @@ static void xs_close(struct rpc_xprt *xprt)
 	xs_reset_transport(transport);
 	xprt->reestablish_timeout = 0;
 
-	smp_mb__before_atomic();
-	clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
-	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
-	clear_bit(XPRT_CLOSING, &xprt->state);
-	smp_mb__after_atomic();
 	xprt_disconnect_done(xprt);
 }
 
@@ -1455,16 +1462,6 @@ static void xs_tcp_cancel_linger_timeout(struct rpc_xprt *xprt)
 	xprt_clear_connecting(xprt);
 }
 
-static void xs_sock_reset_connection_flags(struct rpc_xprt *xprt)
-{
-	smp_mb__before_atomic();
-	clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
-	clear_bit(XPRT_CONNECTION_CLOSE, &xprt->state);
-	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
-	clear_bit(XPRT_CLOSING, &xprt->state);
-	smp_mb__after_atomic();
-}
-
 static void xs_sock_mark_closed(struct rpc_xprt *xprt)
 {
 	xs_sock_reset_connection_flags(xprt);
-- 
2.1.0


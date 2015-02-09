Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f171.google.com ([209.85.213.171]:39470 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933602AbbBIRTE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2015 12:19:04 -0500
Received: by mail-ig0-f171.google.com with SMTP id h15so17798461igd.4
        for <linux-nfs@vger.kernel.org>; Mon, 09 Feb 2015 09:19:03 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 13/14] SUNRPC: Handle connection reset more efficiently.
Date: Mon,  9 Feb 2015 12:18:43 -0500
Message-Id: <1423502324-25981-14-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423502324-25981-13-git-send-email-trond.myklebust@primarydata.com>
References: <1423502324-25981-1-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-2-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-3-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-4-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-5-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-6-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-7-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-8-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-9-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-10-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-11-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-12-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-13-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the connection reset is due to an active call on our side, then
the state change is sometimes not reported. Catch those instances
using xs_error_report() instead.
Also remove the xs_tcp_shutdown() call in xs_tcp_send_request() as
the change in behaviour makes it redundant.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 34 ++++++++++++++++++----------------
 1 file changed, 18 insertions(+), 16 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index c72b13e2bdf5..540d542d85e5 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -718,7 +718,6 @@ static int xs_tcp_send_request(struct rpc_task *task)
 		dprintk("RPC:       sendmsg returned unrecognized error %d\n",
 			-status);
 	case -ECONNRESET:
-		xs_tcp_shutdown(xprt);
 	case -ECONNREFUSED:
 	case -ENOTCONN:
 	case -EADDRINUSE:
@@ -774,6 +773,21 @@ static void xs_restore_old_callbacks(struct sock_xprt *transport, struct sock *s
 	sk->sk_error_report = transport->old_error_report;
 }
 
+static void xs_sock_reset_connection_flags(struct rpc_xprt *xprt)
+{
+	smp_mb__before_atomic();
+	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
+	clear_bit(XPRT_CLOSING, &xprt->state);
+	smp_mb__after_atomic();
+}
+
+static void xs_sock_mark_closed(struct rpc_xprt *xprt)
+{
+	xs_sock_reset_connection_flags(xprt);
+	/* Mark transport as closed and wake up all pending tasks */
+	xprt_disconnect_done(xprt);
+}
+
 /**
  * xs_error_report - callback to handle TCP socket state errors
  * @sk: socket
@@ -793,6 +807,9 @@ static void xs_error_report(struct sock *sk)
 	err = -sk->sk_err;
 	if (err == 0)
 		goto out;
+	/* Is this a reset event? */
+	if (sk->sk_state == TCP_CLOSE)
+		xs_sock_mark_closed(xprt);
 	dprintk("RPC:       xs_error_report client %p, error=%d...\n",
 			xprt, -err);
 	trace_rpc_socket_error(xprt, sk->sk_socket, err);
@@ -801,14 +818,6 @@ static void xs_error_report(struct sock *sk)
 	read_unlock_bh(&sk->sk_callback_lock);
 }
 
-static void xs_sock_reset_connection_flags(struct rpc_xprt *xprt)
-{
-	smp_mb__before_atomic();
-	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
-	clear_bit(XPRT_CLOSING, &xprt->state);
-	smp_mb__after_atomic();
-}
-
 static void xs_reset_transport(struct sock_xprt *transport)
 {
 	struct socket *sock = transport->sock;
@@ -1421,13 +1430,6 @@ out:
 	read_unlock_bh(&sk->sk_callback_lock);
 }
 
-static void xs_sock_mark_closed(struct rpc_xprt *xprt)
-{
-	xs_sock_reset_connection_flags(xprt);
-	/* Mark transport as closed and wake up all pending tasks */
-	xprt_disconnect_done(xprt);
-}
-
 /**
  * xs_tcp_state_change - callback to handle TCP socket state changes
  * @sk: socket whose state has changed
-- 
2.1.0


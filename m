Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:56996 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933720AbbBIWsX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2015 17:48:23 -0500
Received: by mail-ig0-f177.google.com with SMTP id z20so19745798igj.4
        for <linux-nfs@vger.kernel.org>; Mon, 09 Feb 2015 14:48:23 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 07/15] SUNRPC: Remove TCP client connection reset hack
Date: Mon,  9 Feb 2015 17:48:03 -0500
Message-Id: <1423522091-35365-8-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423522091-35365-7-git-send-email-trond.myklebust@primarydata.com>
References: <1423522091-35365-1-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-2-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-3-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-4-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-5-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-6-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-7-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead we rely on SO_REUSEPORT to provide the reconnection semantics
that we need for NFSv2/v3.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/xprt.h |  1 -
 net/sunrpc/xprtsock.c       | 67 +--------------------------------------------
 2 files changed, 1 insertion(+), 67 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 2926e618dbc6..86af854338b5 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -363,7 +363,6 @@ void			xprt_unlock_connect(struct rpc_xprt *, void *);
 #define XPRT_CONNECTION_ABORT	(7)
 #define XPRT_CONNECTION_CLOSE	(8)
 #define XPRT_CONGESTED		(9)
-#define XPRT_CONNECTION_REUSE	(10)
 
 static inline void xprt_set_connected(struct rpc_xprt *xprt)
 {
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index e53a5ca03daf..dbf279cd4494 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -796,8 +796,6 @@ static void xs_error_report(struct sock *sk)
 	dprintk("RPC:       xs_error_report client %p, error=%d...\n",
 			xprt, -err);
 	trace_rpc_socket_error(xprt, sk->sk_socket, err);
-	if (test_bit(XPRT_CONNECTION_REUSE, &xprt->state))
-		goto out;
 	xprt_wake_pending_tasks(xprt, err);
  out:
 	read_unlock_bh(&sk->sk_callback_lock);
@@ -2102,57 +2100,6 @@ out:
 	xprt_wake_pending_tasks(xprt, status);
 }
 
-/*
- * We need to preserve the port number so the reply cache on the server can
- * find our cached RPC replies when we get around to reconnecting.
- */
-static void xs_abort_connection(struct sock_xprt *transport)
-{
-	int result;
-	struct sockaddr any;
-
-	dprintk("RPC:       disconnecting xprt %p to reuse port\n", transport);
-
-	/*
-	 * Disconnect the transport socket by doing a connect operation
-	 * with AF_UNSPEC.  This should return immediately...
-	 */
-	memset(&any, 0, sizeof(any));
-	any.sa_family = AF_UNSPEC;
-	result = kernel_connect(transport->sock, &any, sizeof(any), 0);
-	trace_rpc_socket_reset_connection(&transport->xprt,
-			transport->sock, result);
-	if (!result)
-		xs_sock_reset_connection_flags(&transport->xprt);
-	dprintk("RPC:       AF_UNSPEC connect return code %d\n", result);
-}
-
-static void xs_tcp_reuse_connection(struct sock_xprt *transport)
-{
-	unsigned int state = transport->inet->sk_state;
-
-	if (state == TCP_CLOSE && transport->sock->state == SS_UNCONNECTED) {
-		/* we don't need to abort the connection if the socket
-		 * hasn't undergone a shutdown
-		 */
-		if (transport->inet->sk_shutdown == 0)
-			return;
-		dprintk("RPC:       %s: TCP_CLOSEd and sk_shutdown set to %d\n",
-				__func__, transport->inet->sk_shutdown);
-	}
-	if ((1 << state) & (TCPF_ESTABLISHED|TCPF_SYN_SENT)) {
-		/* we don't need to abort the connection if the socket
-		 * hasn't undergone a shutdown
-		 */
-		if (transport->inet->sk_shutdown == 0)
-			return;
-		dprintk("RPC:       %s: ESTABLISHED/SYN_SENT "
-				"sk_shutdown set to %d\n",
-				__func__, transport->inet->sk_shutdown);
-	}
-	xs_abort_connection(transport);
-}
-
 static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 {
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
@@ -2245,18 +2192,6 @@ static void xs_tcp_setup_socket(struct work_struct *work)
 			status = PTR_ERR(sock);
 			goto out;
 		}
-	} else {
-		int abort_and_exit;
-
-		abort_and_exit = test_and_clear_bit(XPRT_CONNECTION_ABORT,
-				&xprt->state);
-		/* "close" the socket, preserving the local port */
-		set_bit(XPRT_CONNECTION_REUSE, &xprt->state);
-		xs_tcp_reuse_connection(transport);
-		clear_bit(XPRT_CONNECTION_REUSE, &xprt->state);
-
-		if (abort_and_exit)
-			goto out_eagain;
 	}
 
 	dprintk("RPC:       worker connecting xprt %p via %s to "
@@ -2296,9 +2231,9 @@ static void xs_tcp_setup_socket(struct work_struct *work)
 	case -EADDRINUSE:
 	case -ENOBUFS:
 		/* retry with existing socket, after a delay */
+		xs_tcp_force_close(xprt);
 		goto out;
 	}
-out_eagain:
 	status = -EAGAIN;
 out:
 	xprt_unlock_connect(xprt, transport);
-- 
2.1.0


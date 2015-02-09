Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f171.google.com ([209.85.213.171]:65356 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759281AbbBIDHz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Feb 2015 22:07:55 -0500
Received: by mail-ig0-f171.google.com with SMTP id h15so13746545igd.4
        for <linux-nfs@vger.kernel.org>; Sun, 08 Feb 2015 19:07:54 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 08/11] SUNRPC: Kill the special TCP close mechanisms
Date: Sun,  8 Feb 2015 22:07:39 -0500
Message-Id: <1423451262-84493-9-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423451262-84493-8-git-send-email-trond.myklebust@primarydata.com>
References: <1423451262-84493-1-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-2-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-3-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-4-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-5-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-6-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-7-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-8-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just use the ordinary sock_release() now that we can reuse ports.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 30 +-----------------------------
 1 file changed, 1 insertion(+), 29 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index dbf279cd4494..b5dfb4f14ef9 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -623,24 +623,6 @@ process_status:
 }
 
 /**
- * xs_tcp_shutdown - gracefully shut down a TCP socket
- * @xprt: transport
- *
- * Initiates a graceful shutdown of the TCP socket by calling the
- * equivalent of shutdown(SHUT_WR);
- */
-static void xs_tcp_shutdown(struct rpc_xprt *xprt)
-{
-	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
-	struct socket *sock = transport->sock;
-
-	if (sock != NULL) {
-		kernel_sock_shutdown(sock, SHUT_WR);
-		trace_rpc_socket_shutdown(xprt, sock);
-	}
-}
-
-/**
  * xs_tcp_send_request - write an RPC request to a TCP socket
  * @task: address of RPC task that manages the state of an RPC request
  *
@@ -718,7 +700,6 @@ static int xs_tcp_send_request(struct rpc_task *task)
 		dprintk("RPC:       sendmsg returned unrecognized error %d\n",
 			-status);
 	case -ECONNRESET:
-		xs_tcp_shutdown(xprt);
 	case -ECONNREFUSED:
 	case -ENOTCONN:
 	case -EADDRINUSE:
@@ -856,14 +837,6 @@ static void xs_close(struct rpc_xprt *xprt)
 	xprt_disconnect_done(xprt);
 }
 
-static void xs_tcp_close(struct rpc_xprt *xprt)
-{
-	if (test_and_clear_bit(XPRT_CONNECTION_CLOSE, &xprt->state))
-		xs_close(xprt);
-	else
-		xs_tcp_shutdown(xprt);
-}
-
 static void xs_xprt_free(struct rpc_xprt *xprt)
 {
 	xs_free_peer_addresses(xprt);
@@ -1034,7 +1007,6 @@ static void xs_udp_data_ready(struct sock *sk)
  */
 static void xs_tcp_force_close(struct rpc_xprt *xprt)
 {
-	set_bit(XPRT_CONNECTION_CLOSE, &xprt->state);
 	xprt_force_disconnect(xprt);
 }
 
@@ -2540,7 +2512,7 @@ static struct rpc_xprt_ops xs_tcp_ops = {
 	.buf_free		= rpc_free,
 	.send_request		= xs_tcp_send_request,
 	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
-	.close			= xs_tcp_close,
+	.close			= xs_close,
 	.destroy		= xs_destroy,
 	.print_stats		= xs_tcp_print_stats,
 };
-- 
2.1.0


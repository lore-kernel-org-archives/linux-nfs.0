Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:27557 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755755Ab0JDMxA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Oct 2010 08:53:00 -0400
Message-ID: <4CA9CE27.3010000@parallels.com>
Date: Mon, 04 Oct 2010 16:52:55 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 4/13] sunrpc: Remove duplicate xprt/transport arguments from
 calls
References: <4CA9CDA8.4010407@parallels.com>
In-Reply-To: <4CA9CDA8.4010407@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The xs_tcp_reuse_connection takes the xprt only to pass it down
to the xs_abort_connection. The later one can get it from the given
transport itself.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/sunrpc/xprtsock.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index a76446a..8ff57c5 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1754,12 +1754,12 @@ out:
  * We need to preserve the port number so the reply cache on the server can
  * find our cached RPC replies when we get around to reconnecting.
  */
-static void xs_abort_connection(struct rpc_xprt *xprt, struct sock_xprt *transport)
+static void xs_abort_connection(struct sock_xprt *transport)
 {
 	int result;
 	struct sockaddr any;
 
-	dprintk("RPC:       disconnecting xprt %p to reuse port\n", xprt);
+	dprintk("RPC:       disconnecting xprt %p to reuse port\n", transport);
 
 	/*
 	 * Disconnect the transport socket by doing a connect operation
@@ -1769,13 +1769,13 @@ static void xs_abort_connection(struct rpc_xprt *xprt, struct sock_xprt *transpo
 	any.sa_family = AF_UNSPEC;
 	result = kernel_connect(transport->sock, &any, sizeof(any), 0);
 	if (!result)
-		xs_sock_mark_closed(xprt);
+		xs_sock_mark_closed(&transport->xprt);
 	else
 		dprintk("RPC:       AF_UNSPEC connect return code %d\n",
 				result);
 }
 
-static void xs_tcp_reuse_connection(struct rpc_xprt *xprt, struct sock_xprt *transport)
+static void xs_tcp_reuse_connection(struct sock_xprt *transport)
 {
 	unsigned int state = transport->inet->sk_state;
 
@@ -1798,7 +1798,7 @@ static void xs_tcp_reuse_connection(struct rpc_xprt *xprt, struct sock_xprt *tra
 				"sk_shutdown set to %d\n",
 				__func__, transport->inet->sk_shutdown);
 	}
-	xs_abort_connection(xprt, transport);
+	xs_abort_connection(transport);
 }
 
 static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
@@ -1875,7 +1875,7 @@ static void xs_tcp_setup_socket(struct sock_xprt *transport,
 		abort_and_exit = test_and_clear_bit(XPRT_CONNECTION_ABORT,
 				&xprt->state);
 		/* "close" the socket, preserving the local port */
-		xs_tcp_reuse_connection(xprt, transport);
+		xs_tcp_reuse_connection(transport);
 
 		if (abort_and_exit)
 			goto out_eagain;
-- 
1.5.5.6


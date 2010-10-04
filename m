Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:22756 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755227Ab0JDMzn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Oct 2010 08:55:43 -0400
Message-ID: <4CA9CECA.6000700@parallels.com>
Date: Mon, 04 Oct 2010 16:55:38 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 8/13] sunrpc: Call xs_create_sockX directly from setup_socket
References: <4CA9CDA8.4010407@parallels.com>
In-Reply-To: <4CA9CDA8.4010407@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Remove now unneeded wrappers that just add type and protocol
to socket creation callback.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/sunrpc/xprtsock.c |   40 ++++++++--------------------------------
 1 files changed, 8 insertions(+), 32 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 96128d0..7fdf2bb 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1710,7 +1710,7 @@ static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 
 static void xs_udp_setup_socket(struct sock_xprt *transport,
 		struct socket *(*create_sock)(struct rpc_xprt *,
-			struct sock_xprt *))
+			struct sock_xprt *, int type, int protocol))
 {
 	struct rpc_xprt *xprt = &transport->xprt;
 	struct socket *sock = transport->sock;
@@ -1721,7 +1721,7 @@ static void xs_udp_setup_socket(struct sock_xprt *transport,
 
 	/* Start by resetting any existing state */
 	xs_reset_transport(transport);
-	sock = create_sock(xprt, transport);
+	sock = create_sock(xprt, transport, SOCK_DGRAM, IPPROTO_UDP);
 	if (IS_ERR(sock))
 		goto out;
 
@@ -1745,18 +1745,12 @@ out:
  * Invoked by a work queue tasklet.
  */
 
-static struct socket *xs_create_udp_sock4(struct rpc_xprt *xprt,
-		struct sock_xprt *transport)
-{
-	return xs_create_sock4(xprt, transport, SOCK_DGRAM, IPPROTO_UDP);
-}
-
 static void xs_udp_connect_worker4(struct work_struct *work)
 {
 	struct sock_xprt *transport =
 		container_of(work, struct sock_xprt, connect_worker.work);
 
-	xs_udp_setup_socket(transport, xs_create_udp_sock4);
+	xs_udp_setup_socket(transport, xs_create_sock4);
 }
 
 /**
@@ -1766,18 +1760,12 @@ static void xs_udp_connect_worker4(struct work_struct *work)
  * Invoked by a work queue tasklet.
  */
 
-static struct socket *xs_create_udp_sock6(struct rpc_xprt *xprt,
-		struct sock_xprt *transport)
-{
-	return xs_create_sock6(xprt, transport, SOCK_DGRAM, IPPROTO_UDP);
-}
-
 static void xs_udp_connect_worker6(struct work_struct *work)
 {
 	struct sock_xprt *transport =
 		container_of(work, struct sock_xprt, connect_worker.work);
 
-	xs_udp_setup_socket(transport, xs_create_udp_sock6);
+	xs_udp_setup_socket(transport, xs_create_sock6);
 }
 
 /*
@@ -1883,7 +1871,7 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
  */
 static void xs_tcp_setup_socket(struct sock_xprt *transport,
 		struct socket *(*create_sock)(struct rpc_xprt *,
-			struct sock_xprt *))
+			struct sock_xprt *, int type, int protocol))
 {
 	struct socket *sock = transport->sock;
 	struct rpc_xprt *xprt = &transport->xprt;
@@ -1894,7 +1882,7 @@ static void xs_tcp_setup_socket(struct sock_xprt *transport,
 
 	if (!sock) {
 		clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
-		sock = create_sock(xprt, transport);
+		sock = create_sock(xprt, transport, SOCK_STREAM, IPPROTO_TCP);
 		if (IS_ERR(sock)) {
 			status = PTR_ERR(sock);
 			goto out;
@@ -1954,12 +1942,6 @@ out:
 	xprt_wake_pending_tasks(xprt, status);
 }
 
-static struct socket *xs_create_tcp_sock4(struct rpc_xprt *xprt,
-		struct sock_xprt *transport)
-{
-	return xs_create_sock4(xprt, transport, SOCK_STREAM, IPPROTO_TCP);
-}
-
 /**
  * xs_tcp_connect_worker4 - connect a TCP socket to a remote endpoint
  * @work: RPC transport to connect
@@ -1971,13 +1953,7 @@ static void xs_tcp_connect_worker4(struct work_struct *work)
 	struct sock_xprt *transport =
 		container_of(work, struct sock_xprt, connect_worker.work);
 
-	xs_tcp_setup_socket(transport, xs_create_tcp_sock4);
-}
-
-static struct socket *xs_create_tcp_sock6(struct rpc_xprt *xprt,
-		struct sock_xprt *transport)
-{
-	return xs_create_sock6(xprt, transport, SOCK_STREAM, IPPROTO_TCP);
+	xs_tcp_setup_socket(transport, xs_create_sock4);
 }
 
 /**
@@ -1991,7 +1967,7 @@ static void xs_tcp_connect_worker6(struct work_struct *work)
 	struct sock_xprt *transport =
 		container_of(work, struct sock_xprt, connect_worker.work);
 
-	xs_tcp_setup_socket(transport, xs_create_tcp_sock6);
+	xs_tcp_setup_socket(transport, xs_create_sock6);
 }
 
 /**
-- 
1.5.5.6


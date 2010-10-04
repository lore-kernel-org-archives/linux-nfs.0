Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:18525 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755834Ab0JDM5o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Oct 2010 08:57:44 -0400
Message-ID: <4CA9CF44.2040101@parallels.com>
Date: Mon, 04 Oct 2010 16:57:40 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 12/13] sunrpc: Remove TCP worker wrappers
References: <4CA9CDA8.4010407@parallels.com>
In-Reply-To: <4CA9CDA8.4010407@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The v4 and the v6 wrappers only pass the respective family
to the xs_tcp_setup_socket. This family can be taken from the
xprt's sockaddr.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/sunrpc/xprtsock.c |   39 +++++++--------------------------------
 1 files changed, 7 insertions(+), 32 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index d4d7c98..4760ce8 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1826,8 +1826,10 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
  *
  * Invoked by a work queue tasklet.
  */
-static void xs_tcp_setup_socket(struct sock_xprt *transport, int family)
+static void xs_tcp_setup_socket(struct work_struct *work)
 {
+	struct sock_xprt *transport =
+		container_of(work, struct sock_xprt, connect_worker.work);
 	struct socket *sock = transport->sock;
 	struct rpc_xprt *xprt = &transport->xprt;
 	int status = -EIO;
@@ -1837,7 +1839,8 @@ static void xs_tcp_setup_socket(struct sock_xprt *transport, int family)
 
 	if (!sock) {
 		clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
-		sock = xs_create_sock(xprt, transport, family, SOCK_STREAM, IPPROTO_TCP);
+		sock = xs_create_sock(xprt, transport,
+				xs_addr(xprt)->sa_family, SOCK_STREAM, IPPROTO_TCP);
 		if (IS_ERR(sock)) {
 			status = PTR_ERR(sock);
 			goto out;
@@ -1898,34 +1901,6 @@ out:
 }
 
 /**
- * xs_tcp_connect_worker4 - connect a TCP socket to a remote endpoint
- * @work: RPC transport to connect
- *
- * Invoked by a work queue tasklet.
- */
-static void xs_tcp_connect_worker4(struct work_struct *work)
-{
-	struct sock_xprt *transport =
-		container_of(work, struct sock_xprt, connect_worker.work);
-
-	xs_tcp_setup_socket(transport, PF_INET);
-}
-
-/**
- * xs_tcp_connect_worker6 - connect a TCP socket to a remote endpoint
- * @work: RPC transport to connect
- *
- * Invoked by a work queue tasklet.
- */
-static void xs_tcp_connect_worker6(struct work_struct *work)
-{
-	struct sock_xprt *transport =
-		container_of(work, struct sock_xprt, connect_worker.work);
-
-	xs_tcp_setup_socket(transport, PF_INET6);
-}
-
-/**
  * xs_connect - connect a socket to a remote endpoint
  * @task: address of RPC task that manages state of connect request
  *
@@ -2328,7 +2303,7 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 			xprt_set_bound(xprt);
 
 		INIT_DELAYED_WORK(&transport->connect_worker,
-					xs_tcp_connect_worker4);
+					xs_tcp_setup_socket);
 		xs_format_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP);
 		break;
 	case AF_INET6:
@@ -2336,7 +2311,7 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 			xprt_set_bound(xprt);
 
 		INIT_DELAYED_WORK(&transport->connect_worker,
-					xs_tcp_connect_worker6);
+					xs_tcp_setup_socket);
 		xs_format_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP6);
 		break;
 	default:
-- 
1.5.5.6


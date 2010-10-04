Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:34999 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755834Ab0JDM5Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Oct 2010 08:57:16 -0400
Message-ID: <4CA9CF27.7060203@parallels.com>
Date: Mon, 04 Oct 2010 16:57:11 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 11/13] sunrpc: Pass family to setup_socket calls
References: <4CA9CDA8.4010407@parallels.com>
In-Reply-To: <4CA9CDA8.4010407@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Now we have a single socket creation routine and can call it
directly from the setup_socket routines.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/sunrpc/xprtsock.c |   32 ++++++++------------------------
 1 files changed, 8 insertions(+), 24 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 7095471..d4d7c98 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1638,18 +1638,6 @@ out:
 	return ERR_PTR(err);
 }
 
-static struct socket *xs_create_sock4(struct rpc_xprt *xprt,
-		struct sock_xprt *transport, int type, int protocol)
-{
-	return xs_create_sock(xprt, transport, PF_INET, type, protocol);
-}
-
-static struct socket *xs_create_sock6(struct rpc_xprt *xprt,
-		struct sock_xprt *transport, int type, int protocol)
-{
-	return xs_create_sock(xprt, transport, PF_INET6, type, protocol);
-}
-
 static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 {
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
@@ -1679,9 +1667,7 @@ static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 	xs_udp_do_set_buffer_size(xprt);
 }
 
-static void xs_udp_setup_socket(struct sock_xprt *transport,
-		struct socket *(*create_sock)(struct rpc_xprt *,
-			struct sock_xprt *, int type, int protocol))
+static void xs_udp_setup_socket(struct sock_xprt *transport, int family)
 {
 	struct rpc_xprt *xprt = &transport->xprt;
 	struct socket *sock = transport->sock;
@@ -1692,7 +1678,7 @@ static void xs_udp_setup_socket(struct sock_xprt *transport,
 
 	/* Start by resetting any existing state */
 	xs_reset_transport(transport);
-	sock = create_sock(xprt, transport, SOCK_DGRAM, IPPROTO_UDP);
+	sock = xs_create_sock(xprt, transport, family, SOCK_DGRAM, IPPROTO_UDP);
 	if (IS_ERR(sock))
 		goto out;
 
@@ -1721,7 +1707,7 @@ static void xs_udp_connect_worker4(struct work_struct *work)
 	struct sock_xprt *transport =
 		container_of(work, struct sock_xprt, connect_worker.work);
 
-	xs_udp_setup_socket(transport, xs_create_sock4);
+	xs_udp_setup_socket(transport, PF_INET);
 }
 
 /**
@@ -1736,7 +1722,7 @@ static void xs_udp_connect_worker6(struct work_struct *work)
 	struct sock_xprt *transport =
 		container_of(work, struct sock_xprt, connect_worker.work);
 
-	xs_udp_setup_socket(transport, xs_create_sock6);
+	xs_udp_setup_socket(transport, PF_INET6);
 }
 
 /*
@@ -1840,9 +1826,7 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
  *
  * Invoked by a work queue tasklet.
  */
-static void xs_tcp_setup_socket(struct sock_xprt *transport,
-		struct socket *(*create_sock)(struct rpc_xprt *,
-			struct sock_xprt *, int type, int protocol))
+static void xs_tcp_setup_socket(struct sock_xprt *transport, int family)
 {
 	struct socket *sock = transport->sock;
 	struct rpc_xprt *xprt = &transport->xprt;
@@ -1853,7 +1837,7 @@ static void xs_tcp_setup_socket(struct sock_xprt *transport,
 
 	if (!sock) {
 		clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
-		sock = create_sock(xprt, transport, SOCK_STREAM, IPPROTO_TCP);
+		sock = xs_create_sock(xprt, transport, family, SOCK_STREAM, IPPROTO_TCP);
 		if (IS_ERR(sock)) {
 			status = PTR_ERR(sock);
 			goto out;
@@ -1924,7 +1908,7 @@ static void xs_tcp_connect_worker4(struct work_struct *work)
 	struct sock_xprt *transport =
 		container_of(work, struct sock_xprt, connect_worker.work);
 
-	xs_tcp_setup_socket(transport, xs_create_sock4);
+	xs_tcp_setup_socket(transport, PF_INET);
 }
 
 /**
@@ -1938,7 +1922,7 @@ static void xs_tcp_connect_worker6(struct work_struct *work)
 	struct sock_xprt *transport =
 		container_of(work, struct sock_xprt, connect_worker.work);
 
-	xs_tcp_setup_socket(transport, xs_create_sock6);
+	xs_tcp_setup_socket(transport, PF_INET6);
 }
 
 /**
-- 
1.5.5.6


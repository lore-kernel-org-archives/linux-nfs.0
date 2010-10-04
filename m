Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:26698 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755755Ab0JDM6H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Oct 2010 08:58:07 -0400
Message-ID: <4CA9CF5A.7080000@parallels.com>
Date: Mon, 04 Oct 2010 16:58:02 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 13/13] sunrpc: Remove UDP worker wrappers
References: <4CA9CDA8.4010407@parallels.com>
In-Reply-To: <4CA9CDA8.4010407@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Same for UDP sockets creation paths.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/sunrpc/xprtsock.c |   41 +++++++----------------------------------
 1 files changed, 7 insertions(+), 34 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 4760ce8..1f41f1a 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1667,8 +1667,10 @@ static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 	xs_udp_do_set_buffer_size(xprt);
 }
 
-static void xs_udp_setup_socket(struct sock_xprt *transport, int family)
+static void xs_udp_setup_socket(struct work_struct *work)
 {
+	struct sock_xprt *transport =
+		container_of(work, struct sock_xprt, connect_worker.work);
 	struct rpc_xprt *xprt = &transport->xprt;
 	struct socket *sock = transport->sock;
 	int status = -EIO;
@@ -1678,7 +1680,8 @@ static void xs_udp_setup_socket(struct sock_xprt *transport, int family)
 
 	/* Start by resetting any existing state */
 	xs_reset_transport(transport);
-	sock = xs_create_sock(xprt, transport, family, SOCK_DGRAM, IPPROTO_UDP);
+	sock = xs_create_sock(xprt, transport,
+			xs_addr(xprt)->sa_family, SOCK_DGRAM, IPPROTO_UDP);
 	if (IS_ERR(sock))
 		goto out;
 
@@ -1695,36 +1698,6 @@ out:
 	xprt_wake_pending_tasks(xprt, status);
 }
 
-/**
- * xs_udp_connect_worker4 - set up a UDP socket
- * @work: RPC transport to connect
- *
- * Invoked by a work queue tasklet.
- */
-
-static void xs_udp_connect_worker4(struct work_struct *work)
-{
-	struct sock_xprt *transport =
-		container_of(work, struct sock_xprt, connect_worker.work);
-
-	xs_udp_setup_socket(transport, PF_INET);
-}
-
-/**
- * xs_udp_connect_worker6 - set up a UDP socket
- * @work: RPC transport to connect
- *
- * Invoked by a work queue tasklet.
- */
-
-static void xs_udp_connect_worker6(struct work_struct *work)
-{
-	struct sock_xprt *transport =
-		container_of(work, struct sock_xprt, connect_worker.work);
-
-	xs_udp_setup_socket(transport, PF_INET6);
-}
-
 /*
  * We need to preserve the port number so the reply cache on the server can
  * find our cached RPC replies when we get around to reconnecting.
@@ -2229,7 +2202,7 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 			xprt_set_bound(xprt);
 
 		INIT_DELAYED_WORK(&transport->connect_worker,
-					xs_udp_connect_worker4);
+					xs_udp_setup_socket);
 		xs_format_peer_addresses(xprt, "udp", RPCBIND_NETID_UDP);
 		break;
 	case AF_INET6:
@@ -2237,7 +2210,7 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 			xprt_set_bound(xprt);
 
 		INIT_DELAYED_WORK(&transport->connect_worker,
-					xs_udp_connect_worker6);
+					xs_udp_setup_socket);
 		xs_format_peer_addresses(xprt, "udp", RPCBIND_NETID_UDP6);
 		break;
 	default:
-- 
1.5.5.6


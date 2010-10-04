Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:8292 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755791Ab0JDMzA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Oct 2010 08:55:00 -0400
Message-ID: <4CA9CE9F.3050001@parallels.com>
Date: Mon, 04 Oct 2010 16:54:55 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 7/13] sunrpc: Factor out v6 sockets creation
References: <4CA9CDA8.4010407@parallels.com>
In-Reply-To: <4CA9CDA8.4010407@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Same patch for v6 protocols.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/sunrpc/xprtsock.c |   63 ++++++++++++++++++++----------------------------
 1 files changed, 26 insertions(+), 37 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index b73a605..96128d0 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1655,6 +1655,30 @@ out:
 	return ERR_PTR(err);
 }
 
+static struct socket *xs_create_sock6(struct rpc_xprt *xprt,
+		struct sock_xprt *transport, int type, int protocol)
+{
+	struct socket *sock;
+	int err;
+
+	err = __sock_create(xprt->xprt_net, PF_INET6, type, protocol, &sock, 1);
+	if (err < 0) {
+		dprintk("RPC:       can't create %d transport socket (%d).\n",
+				protocol, -err);
+		goto out;
+	}
+	xs_reclassify_socket6(sock);
+
+	if (xs_bind6(transport, sock)) {
+		sock_release(sock);
+		goto out;
+	}
+
+	return sock;
+out:
+	return ERR_PTR(err);
+}
+
 static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 {
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
@@ -1745,24 +1769,7 @@ static void xs_udp_connect_worker4(struct work_struct *work)
 static struct socket *xs_create_udp_sock6(struct rpc_xprt *xprt,
 		struct sock_xprt *transport)
 {
-	struct socket *sock;
-	int err;
-
-	err = __sock_create(xprt->xprt_net, PF_INET6, SOCK_DGRAM, IPPROTO_UDP, &sock, 1);
-	if (err < 0) {
-		dprintk("RPC:       can't create UDP transport socket (%d).\n", -err);
-		goto out;
-	}
-	xs_reclassify_socket6(sock);
-
-	if (xs_bind6(transport, sock) < 0) {
-		sock_release(sock);
-		goto out;
-	}
-
-	return sock;
-out:
-	return ERR_PTR(err);
+	return xs_create_sock6(xprt, transport, SOCK_DGRAM, IPPROTO_UDP);
 }
 
 static void xs_udp_connect_worker6(struct work_struct *work)
@@ -1970,25 +1977,7 @@ static void xs_tcp_connect_worker4(struct work_struct *work)
 static struct socket *xs_create_tcp_sock6(struct rpc_xprt *xprt,
 		struct sock_xprt *transport)
 {
-	struct socket *sock;
-	int err;
-
-	/* start from scratch */
-	err = __sock_create(xprt->xprt_net, PF_INET6, SOCK_STREAM, IPPROTO_TCP, &sock, 1);
-	if (err < 0) {
-		dprintk("RPC:       can't create TCP transport socket (%d).\n",
-				-err);
-		goto out_err;
-	}
-	xs_reclassify_socket6(sock);
-
-	if (xs_bind6(transport, sock) < 0) {
-		sock_release(sock);
-		goto out_err;
-	}
-	return sock;
-out_err:
-	return ERR_PTR(-EIO);
+	return xs_create_sock6(xprt, transport, SOCK_STREAM, IPPROTO_TCP);
 }
 
 /**
-- 
1.5.5.6


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:45677 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755227Ab0JDM4m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Oct 2010 08:56:42 -0400
Message-ID: <4CA9CF06.4070004@parallels.com>
Date: Mon, 04 Oct 2010 16:56:38 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 10/13] sunrpc: Merge xs_create_sock code
References: <4CA9CDA8.4010407@parallels.com>
In-Reply-To: <4CA9CDA8.4010407@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

After xs_bind is merged it's easy to merge its callers.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/sunrpc/xprtsock.c |   46 +++++++++++++++++++++++-----------------------
 1 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 3618cfd..7095471 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1592,6 +1592,14 @@ static inline void xs_reclassify_socket6(struct socket *sock)
 	sock_lock_init_class_and_name(sk, "slock-AF_INET6-RPC",
 		&xs_slock_key[1], "sk_lock-AF_INET6-RPC", &xs_key[1]);
 }
+
+static inline void xs_reclassify_socket(int family, struct socket *sock)
+{
+	if (family == PF_INET)
+		xs_reclassify_socket4(sock);
+	else
+		xs_reclassify_socket6(sock);
+}
 #else
 static inline void xs_reclassify_socket4(struct socket *sock)
 {
@@ -1600,21 +1608,25 @@ static inline void xs_reclassify_socket4(struct socket *sock)
 static inline void xs_reclassify_socket6(struct socket *sock)
 {
 }
+
+static inline void xs_reclassify_socket(int family, struct socket *sock)
+{
+}
 #endif
 
-static struct socket *xs_create_sock4(struct rpc_xprt *xprt,
-		struct sock_xprt *transport, int type, int protocol)
+static struct socket *xs_create_sock(struct rpc_xprt *xprt,
+		struct sock_xprt *transport, int family, int type, int protocol)
 {
 	struct socket *sock;
 	int err;
 
-	err = __sock_create(xprt->xprt_net, PF_INET, type, protocol, &sock, 1);
+	err = __sock_create(xprt->xprt_net, family, type, protocol, &sock, 1);
 	if (err < 0) {
 		dprintk("RPC:       can't create %d transport socket (%d).\n",
 				protocol, -err);
 		goto out;
 	}
-	xs_reclassify_socket4(sock);
+	xs_reclassify_socket(family, sock);
 
 	if (xs_bind(transport, sock)) {
 		sock_release(sock);
@@ -1626,28 +1638,16 @@ out:
 	return ERR_PTR(err);
 }
 
-static struct socket *xs_create_sock6(struct rpc_xprt *xprt,
+static struct socket *xs_create_sock4(struct rpc_xprt *xprt,
 		struct sock_xprt *transport, int type, int protocol)
 {
-	struct socket *sock;
-	int err;
-
-	err = __sock_create(xprt->xprt_net, PF_INET6, type, protocol, &sock, 1);
-	if (err < 0) {
-		dprintk("RPC:       can't create %d transport socket (%d).\n",
-				protocol, -err);
-		goto out;
-	}
-	xs_reclassify_socket6(sock);
-
-	if (xs_bind(transport, sock)) {
-		sock_release(sock);
-		goto out;
-	}
+	return xs_create_sock(xprt, transport, PF_INET, type, protocol);
+}
 
-	return sock;
-out:
-	return ERR_PTR(err);
+static struct socket *xs_create_sock6(struct rpc_xprt *xprt,
+		struct sock_xprt *transport, int type, int protocol)
+{
+	return xs_create_sock(xprt, transport, PF_INET6, type, protocol);
 }
 
 static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
-- 
1.5.5.6


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:45912 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755813Ab0JDMxw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Oct 2010 08:53:52 -0400
Message-ID: <4CA9CE5A.8040107@parallels.com>
Date: Mon, 04 Oct 2010 16:53:46 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 5/13] sunrpc: Factor out udp sockets creation
References: <4CA9CDA8.4010407@parallels.com>
In-Reply-To: <4CA9CDA8.4010407@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Make it look like the TCP sockets creation.
Unfortunately the git diff made the patch look messy :(

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/sunrpc/xprtsock.c |   96 ++++++++++++++++++++++++++++--------------------
 1 files changed, 56 insertions(+), 40 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 8ff57c5..df53dc5 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1660,37 +1660,22 @@ static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 	xs_udp_do_set_buffer_size(xprt);
 }
 
-/**
- * xs_udp_connect_worker4 - set up a UDP socket
- * @work: RPC transport to connect
- *
- * Invoked by a work queue tasklet.
- */
-static void xs_udp_connect_worker4(struct work_struct *work)
+static void xs_udp_setup_socket(struct sock_xprt *transport,
+		struct socket *(*create_sock)(struct rpc_xprt *,
+			struct sock_xprt *))
 {
-	struct sock_xprt *transport =
-		container_of(work, struct sock_xprt, connect_worker.work);
 	struct rpc_xprt *xprt = &transport->xprt;
 	struct socket *sock = transport->sock;
-	int err, status = -EIO;
+	int status = -EIO;
 
 	if (xprt->shutdown)
 		goto out;
 
 	/* Start by resetting any existing state */
 	xs_reset_transport(transport);
-
-	err = __sock_create(xprt->xprt_net, PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock, 1);
-	if (err < 0) {
-		dprintk("RPC:       can't create UDP transport socket (%d).\n", -err);
+	sock = create_sock(xprt, transport);
+	if (IS_ERR(sock))
 		goto out;
-	}
-	xs_reclassify_socket4(sock);
-
-	if (xs_bind4(transport, sock)) {
-		sock_release(sock);
-		goto out;
-	}
 
 	dprintk("RPC:       worker connecting xprt %p via %s to "
 				"%s (port %s)\n", xprt,
@@ -1706,24 +1691,55 @@ out:
 }
 
 /**
- * xs_udp_connect_worker6 - set up a UDP socket
+ * xs_udp_connect_worker4 - set up a UDP socket
  * @work: RPC transport to connect
  *
  * Invoked by a work queue tasklet.
  */
-static void xs_udp_connect_worker6(struct work_struct *work)
+
+static struct socket *xs_create_udp_sock4(struct rpc_xprt *xprt,
+		struct sock_xprt *transport)
+{
+	struct socket *sock;
+	int err;
+
+	err = __sock_create(xprt->xprt_net, PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock, 1);
+	if (err < 0) {
+		dprintk("RPC:       can't create UDP transport socket (%d).\n", -err);
+		goto out;
+	}
+	xs_reclassify_socket4(sock);
+
+	if (xs_bind4(transport, sock)) {
+		sock_release(sock);
+		goto out;
+	}
+
+	return sock;
+out:
+	return ERR_PTR(err);
+}
+
+static void xs_udp_connect_worker4(struct work_struct *work)
 {
 	struct sock_xprt *transport =
 		container_of(work, struct sock_xprt, connect_worker.work);
-	struct rpc_xprt *xprt = &transport->xprt;
-	struct socket *sock = transport->sock;
-	int err, status = -EIO;
 
-	if (xprt->shutdown)
-		goto out;
+	xs_udp_setup_socket(transport, xs_create_udp_sock4);
+}
 
-	/* Start by resetting any existing state */
-	xs_reset_transport(transport);
+/**
+ * xs_udp_connect_worker6 - set up a UDP socket
+ * @work: RPC transport to connect
+ *
+ * Invoked by a work queue tasklet.
+ */
+
+static struct socket *xs_create_udp_sock6(struct rpc_xprt *xprt,
+		struct sock_xprt *transport)
+{
+	struct socket *sock;
+	int err;
 
 	err = __sock_create(xprt->xprt_net, PF_INET6, SOCK_DGRAM, IPPROTO_UDP, &sock, 1);
 	if (err < 0) {
@@ -1737,17 +1753,17 @@ static void xs_udp_connect_worker6(struct work_struct *work)
 		goto out;
 	}
 
-	dprintk("RPC:       worker connecting xprt %p via %s to "
-				"%s (port %s)\n", xprt,
-			xprt->address_strings[RPC_DISPLAY_PROTO],
-			xprt->address_strings[RPC_DISPLAY_ADDR],
-			xprt->address_strings[RPC_DISPLAY_PORT]);
-
-	xs_udp_finish_connecting(xprt, sock);
-	status = 0;
+	return sock;
 out:
-	xprt_clear_connecting(xprt);
-	xprt_wake_pending_tasks(xprt, status);
+	return ERR_PTR(err);
+}
+
+static void xs_udp_connect_worker6(struct work_struct *work)
+{
+	struct sock_xprt *transport =
+		container_of(work, struct sock_xprt, connect_worker.work);
+
+	xs_udp_setup_socket(transport, xs_create_udp_sock6);
 }
 
 /*
-- 
1.5.5.6


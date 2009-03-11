From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 30/30]
 =?utf-8?b?U1VOUlBDOsKgeHNfdGNwX2Nvbm5lY3Rfd29ya2VyezQsNn06?= merge common
 code
Date: Wed, 11 Mar 2009 14:41:10 -0400
Message-ID: <20090311184110.5578.91173.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6546 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755108AbZCKSps (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:45:48 -0400
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIj5jm022182
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:45:46 -0700 (PDT)
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprtsock.c |  140 +++++++++++++++++++++++++------------------------
 1 files changed, 72 insertions(+), 68 deletions(-)


diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 42222b4..f05a56e 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1738,33 +1738,29 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 }
 
 /**
- * xs_tcp_connect_worker4 - connect a TCP socket to a remote endpoint
- * @work: RPC transport to connect
+ * xs_tcp_setup_socket - create a TCP socket and connect to a remote endpoint
+ * @xprt: RPC transport to connect
+ * @transport: socket transport to connect
+ * @create_sock: function to create a socket of the correct type
  *
  * Invoked by a work queue tasklet.
  */
-static void xs_tcp_connect_worker4(struct work_struct *work)
+static void xs_tcp_setup_socket(struct rpc_xprt *xprt,
+		struct sock_xprt *transport,
+		struct socket *(*create_sock)(struct rpc_xprt *,
+			struct sock_xprt *))
 {
-	struct sock_xprt *transport =
-		container_of(work, struct sock_xprt, connect_worker.work);
-	struct rpc_xprt *xprt = &transport->xprt;
 	struct socket *sock = transport->sock;
-	int err, status = -EIO;
+	int status = -EIO;
 
 	if (xprt->shutdown)
 		goto out;
 
 	if (!sock) {
 		clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
-		/* start from scratch */
-		if ((err = sock_create_kern(PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock)) < 0) {
-			dprintk("RPC:       can't create TCP transport socket (%d).\n", -err);
-			goto out;
-		}
-		xs_reclassify_socket4(sock);
-
-		if (xs_bind4(transport, sock) < 0) {
-			sock_release(sock);
+		sock = create_sock(xprt, transport);
+		if (IS_ERR(sock)) {
+			status = PTR_ERR(sock);
 			goto out;
 		}
 	} else {
@@ -1808,74 +1804,82 @@ out:
 	xprt_wake_pending_tasks(xprt, status);
 }
 
+static struct socket *xs_create_tcp_sock4(struct rpc_xprt *xprt,
+		struct sock_xprt *transport)
+{
+	struct socket *sock;
+	int err;
+
+	/* start from scratch */
+	err = sock_create_kern(PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock);
+	if (err < 0) {
+		dprintk("RPC:       can't create TCP transport socket (%d).\n",
+				-err);
+		goto out_err;
+	}
+	xs_reclassify_socket4(sock);
+
+	if (xs_bind4(transport, sock) < 0) {
+		sock_release(sock);
+		goto out_err;
+	}
+	return sock;
+out_err:
+	return ERR_PTR(-EIO);
+}
+
 /**
- * xs_tcp_connect_worker6 - connect a TCP socket to a remote endpoint
+ * xs_tcp_connect_worker4 - connect a TCP socket to a remote endpoint
  * @work: RPC transport to connect
  *
  * Invoked by a work queue tasklet.
  */
-static void xs_tcp_connect_worker6(struct work_struct *work)
+static void xs_tcp_connect_worker4(struct work_struct *work)
 {
 	struct sock_xprt *transport =
 		container_of(work, struct sock_xprt, connect_worker.work);
 	struct rpc_xprt *xprt = &transport->xprt;
-	struct socket *sock = transport->sock;
-	int err, status = -EIO;
 
-	if (xprt->shutdown)
-		goto out;
-
-	if (!sock) {
-		clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
-		/* start from scratch */
-		if ((err = sock_create_kern(PF_INET6, SOCK_STREAM, IPPROTO_TCP, &sock)) < 0) {
-			dprintk("RPC:       can't create TCP transport socket (%d).\n", -err);
-			goto out;
-		}
-		xs_reclassify_socket6(sock);
+	xs_tcp_setup_socket(xprt, transport, xs_create_tcp_sock4);
+}
 
-		if (xs_bind6(transport, sock) < 0) {
-			sock_release(sock);
-			goto out;
-		}
-	} else {
-		int abort_and_exit;
+static struct socket *xs_create_tcp_sock6(struct rpc_xprt *xprt,
+		struct sock_xprt *transport)
+{
+	struct socket *sock;
+	int err;
 
-		abort_and_exit = test_and_clear_bit(XPRT_CONNECTION_ABORT,
-				&xprt->state);
-		/* "close" the socket, preserving the local port */
-		xs_tcp_reuse_connection(xprt, transport);
+	/* start from scratch */
+	err = sock_create_kern(PF_INET6, SOCK_STREAM, IPPROTO_TCP, &sock);
+	if (err < 0) {
+		dprintk("RPC:       can't create TCP transport socket (%d).\n",
+				-err);
+		goto out_err;
+	}
+	xs_reclassify_socket6(sock);
 
-		if (abort_and_exit)
-			goto out_eagain;
+	if (xs_bind6(transport, sock) < 0) {
+		sock_release(sock);
+		goto out_err;
 	}
+	return sock;
+out_err:
+	return ERR_PTR(-EIO);
+}
 
-	dprintk("RPC:       worker connecting xprt %p to address: %s\n",
-			xprt, xprt->address_strings[RPC_DISPLAY_ALL]);
+/**
+ * xs_tcp_connect_worker6 - connect a TCP socket to a remote endpoint
+ * @work: RPC transport to connect
+ *
+ * Invoked by a work queue tasklet.
+ */
+static void xs_tcp_connect_worker6(struct work_struct *work)
+{
+	struct sock_xprt *transport =
+		container_of(work, struct sock_xprt, connect_worker.work);
+	struct rpc_xprt *xprt = &transport->xprt;
 
-	status = xs_tcp_finish_connecting(xprt, sock);
-	dprintk("RPC:       %p connect status %d connected %d sock state %d\n",
-			xprt, -status, xprt_connected(xprt), sock->sk->sk_state);
-	switch (status) {
-	case -ECONNREFUSED:
-	case -ECONNRESET:
-	case -ENETUNREACH:
-		/* retry with existing socket, after a delay */
-	case 0:
-	case -EINPROGRESS:
-	case -EALREADY:
-		xprt_clear_connecting(xprt);
-		return;
-	}
-	/* get rid of existing socket, and retry */
-	xs_tcp_shutdown(xprt);
-	printk("%s: connect returned unhandled error %d\n",
-			__func__, status);
-out_eagain:
-	status = -EAGAIN;
-out:
-	xprt_clear_connecting(xprt);
-	xprt_wake_pending_tasks(xprt, status);
+	xs_tcp_setup_socket(xprt, transport, xs_create_tcp_sock6);
 }
 
 /**


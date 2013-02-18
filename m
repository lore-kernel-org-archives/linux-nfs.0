Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56545 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757512Ab3BRWy2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Feb 2013 17:54:28 -0500
Date: Mon, 18 Feb 2013 17:54:25 -0500
To: Trond Myklebust <trond@netapp.com>, Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org, simo@redhat.com
Subject: synchronous AF_LOCAL connect
Message-ID: <20130218225424.GD3391@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The rpc code expects all connects to be done asynchronously by a
workqueue.  But that doesn't seem necessary in the AF_LOCAL case.  The
only user (rpcbind) actually wants the connect done in the context of a
process with the right namespace.  (And that will be true of gss proxy
too, which also wants to use AF_LOCAL.)

But maybe I'm missing something.

Also, I haven't really tried to understand this code--I just assumed I
could basically call xs_local_setup_socket from ->setup instead of the
workqueue, and that seems to work based on a very superficial test.  At
a minimum I guess the PF_FSTRANS fiddling shouldn't be there.

--b.

commit 93713cdf3ba42789b4e960ad457d2d802746b3ff
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Feb 15 17:54:26 2013 -0500

    rpc: simplify AF_LOCAL connect
    
    It doesn't appear that anyone actually needs to connect asynchronously.
    
    Also, using a workqueue for the connect means we lose the namespace
    information from the original process.  This is a problem since there's
    no way to explicitly pass in a filesystem namespace for resolution of an
    AF_LOCAL address.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index bbc0915..72765f1 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1866,57 +1866,14 @@ static int xs_local_finish_connecting(struct rpc_xprt *xprt,
  * @xprt: RPC transport to connect
  * @transport: socket transport to connect
  * @create_sock: function to create a socket of the correct type
- *
- * Invoked by a work queue tasklet.
  */
 static void xs_local_setup_socket(struct work_struct *work)
 {
 	struct sock_xprt *transport =
 		container_of(work, struct sock_xprt, connect_worker.work);
 	struct rpc_xprt *xprt = &transport->xprt;
-	struct socket *sock;
-	int status = -EIO;
-
-	current->flags |= PF_FSTRANS;
-
-	clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
-	status = __sock_create(xprt->xprt_net, AF_LOCAL,
-					SOCK_STREAM, 0, &sock, 1);
-	if (status < 0) {
-		dprintk("RPC:       can't create AF_LOCAL "
-			"transport socket (%d).\n", -status);
-		goto out;
-	}
-	xs_reclassify_socketu(sock);
-
-	dprintk("RPC:       worker connecting xprt %p via AF_LOCAL to %s\n",
-			xprt, xprt->address_strings[RPC_DISPLAY_ADDR]);
 
-	status = xs_local_finish_connecting(xprt, sock);
-	switch (status) {
-	case 0:
-		dprintk("RPC:       xprt %p connected to %s\n",
-				xprt, xprt->address_strings[RPC_DISPLAY_ADDR]);
-		xprt_set_connected(xprt);
-		break;
-	case -ENOENT:
-		dprintk("RPC:       xprt %p: socket %s does not exist\n",
-				xprt, xprt->address_strings[RPC_DISPLAY_ADDR]);
-		break;
-	case -ECONNREFUSED:
-		dprintk("RPC:       xprt %p: connection refused for %s\n",
-				xprt, xprt->address_strings[RPC_DISPLAY_ADDR]);
-		break;
-	default:
-		printk(KERN_ERR "%s: unhandled error (%d) connecting to %s\n",
-				__func__, -status,
-				xprt->address_strings[RPC_DISPLAY_ADDR]);
-	}
-
-out:
-	xprt_clear_connecting(xprt);
-	xprt_wake_pending_tasks(xprt, status);
-	current->flags &= ~PF_FSTRANS;
+	xprt_wake_pending_tasks(xprt, -EIO);
 }
 
 #ifdef CONFIG_SUNRPC_SWAP
@@ -2588,6 +2545,55 @@ static const struct rpc_timeout xs_local_default_timeout = {
 	.to_retries = 2,
 };
 
+
+static int xs_local_connect(struct sock_xprt *transport)
+{
+	struct rpc_xprt *xprt = &transport->xprt;
+	struct socket *sock;
+	int status = -EIO;
+
+	current->flags |= PF_FSTRANS;
+
+	clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
+	status = __sock_create(xprt->xprt_net, AF_LOCAL,
+					SOCK_STREAM, 0, &sock, 1);
+	if (status < 0) {
+		dprintk("RPC:       can't create AF_LOCAL "
+			"transport socket (%d).\n", -status);
+		goto out;
+	}
+	xs_reclassify_socketu(sock);
+
+	dprintk("RPC:       worker connecting xprt %p via AF_LOCAL to %s\n",
+			xprt, xprt->address_strings[RPC_DISPLAY_ADDR]);
+
+	status = xs_local_finish_connecting(xprt, sock);
+	switch (status) {
+	case 0:
+		dprintk("RPC:       xprt %p connected to %s\n",
+				xprt, xprt->address_strings[RPC_DISPLAY_ADDR]);
+		xprt_set_connected(xprt);
+		break;
+	case -ENOENT:
+		dprintk("RPC:       xprt %p: socket %s does not exist\n",
+				xprt, xprt->address_strings[RPC_DISPLAY_ADDR]);
+		break;
+	case -ECONNREFUSED:
+		dprintk("RPC:       xprt %p: connection refused for %s\n",
+				xprt, xprt->address_strings[RPC_DISPLAY_ADDR]);
+		break;
+	default:
+		printk(KERN_ERR "%s: unhandled error (%d) connecting to %s\n",
+				__func__, -status,
+				xprt->address_strings[RPC_DISPLAY_ADDR]);
+	}
+out:
+	xprt_clear_connecting(xprt);
+	xprt_wake_pending_tasks(xprt, status);
+	current->flags &= ~PF_FSTRANS;
+	return status;
+}
+
 /**
  * xs_setup_local - Set up transport to use an AF_LOCAL socket
  * @args: rpc transport creation arguments
@@ -2630,6 +2636,9 @@ static struct rpc_xprt *xs_setup_local(struct xprt_create *args)
 		INIT_DELAYED_WORK(&transport->connect_worker,
 					xs_local_setup_socket);
 		xs_format_peer_addresses(xprt, "local", RPCBIND_NETID_LOCAL);
+		ret = ERR_PTR(xs_local_connect(transport));
+		if (ret)
+			goto out_err;
 		break;
 	default:
 		ret = ERR_PTR(-EAFNOSUPPORT);

From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] Fix NFS locking over TCP
Date: Wed, 9 Oct 2002 17:56:10 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <15780.20890.390171.863200@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Linus Torvalds <torvalds@transmeta.com>
List-ID: <nfs.lists.sourceforge.net>


The 2.5.x RPC code is currently broken in that it demands that all
tasks that call xprt_create_proto() in order to open a TCP socket must
have CAP_NET_BIND_SERVICE capabilities, and must bind to a privileged
port.
This breaks the NLM locking code and its use of the call_bind() RPC
portmapper lookup feature.

The following patch allows the built-in portmapper client to use
unbound TCP sockets if the user does not have the necessary
capabilities.

Cheers,
  Trond

diff -u --recursive --new-file linux-2.5.41/include/linux/sunrpc/xprt.h linux-2.5.41-fix_tcp/include/linux/sunrpc/xprt.h
--- linux-2.5.41/include/linux/sunrpc/xprt.h	2002-09-18 06:03:45.000000000 -0400
+++ linux-2.5.41-fix_tcp/include/linux/sunrpc/xprt.h	2002-10-08 21:37:46.000000000 -0400
@@ -146,6 +146,7 @@
 	unsigned long		sockstate;	/* Socket state */
 	unsigned char		shutdown   : 1,	/* being shut down */
 				nocong	   : 1,	/* no congestion control */
+				resvport   : 1, /* use a reserved port */
 				stream     : 1;	/* TCP */
 
 	/*
diff -u --recursive --new-file linux-2.5.41/net/sunrpc/xprt.c linux-2.5.41-fix_tcp/net/sunrpc/xprt.c
--- linux-2.5.41/net/sunrpc/xprt.c	2002-09-18 06:03:45.000000000 -0400
+++ linux-2.5.41-fix_tcp/net/sunrpc/xprt.c	2002-10-08 21:47:53.000000000 -0400
@@ -89,7 +89,7 @@
 static void	xprt_conn_status(struct rpc_task *task);
 static struct rpc_xprt * xprt_setup(int proto, struct sockaddr_in *ap,
 						struct rpc_timeout *to);
-static struct socket *xprt_create_socket(int, struct rpc_timeout *);
+static struct socket *xprt_create_socket(int, struct rpc_timeout *, int);
 static void	xprt_bind_socket(struct rpc_xprt *, struct socket *);
 static int      __xprt_get_cong(struct rpc_xprt *, struct rpc_task *);
 
@@ -442,7 +442,7 @@
 	 * Start by resetting any existing state.
 	 */
 	xprt_close(xprt);
-	if (!(sock = xprt_create_socket(xprt->prot, &xprt->timeout))) {
+	if (!(sock = xprt_create_socket(xprt->prot, &xprt->timeout, xprt->resvport))) {
 		/* couldn't create socket or bind to reserved port;
 		 * this is likely a permanent error, so cause an abort */
 		task->tk_status = -EIO;
@@ -1490,7 +1490,7 @@
  * and connect stream sockets.
  */
 static struct socket *
-xprt_create_socket(int proto, struct rpc_timeout *to)
+xprt_create_socket(int proto, struct rpc_timeout *to, int resvport)
 {
 	struct socket	*sock;
 	int		type, err;
@@ -1506,7 +1506,7 @@
 	}
 
 	/* If the caller has the capability, bind to a reserved port */
-	if (capable(CAP_NET_BIND_SERVICE) && xprt_bindresvport(sock) < 0) {
+	if (resvport && xprt_bindresvport(sock) < 0) {
 		printk("RPC: can't bind to reserved port.\n");
 		goto failed;
 	}
@@ -1528,29 +1528,25 @@
 
 	xprt = xprt_setup(proto, sap, to);
 	if (!xprt)
-		goto out;
+		goto out_bad;
 
+	xprt->resvport = capable(CAP_NET_BIND_SERVICE) ? 1 : 0;
 	if (!xprt->stream) {
-		struct socket *sock = xprt_create_socket(proto, to);
-		if (sock)
-			xprt_bind_socket(xprt, sock);
-		else {
-			rpc_free(xprt);
-			xprt = NULL;
-		}
-	} else
-		/*
-		 * Don't allow a TCP service user unless they have
-		 * enough capability to bind a reserved port.
-		 */
-		if (!capable(CAP_NET_BIND_SERVICE)) {
-			rpc_free(xprt);
-			xprt = NULL;
-		}
+		struct socket *sock;
+
+		sock = xprt_create_socket(proto, to, xprt->resvport);
+		if (!sock)
+			goto out_bad;
+		xprt_bind_socket(xprt, sock);
+	}
 
- out:
 	dprintk("RPC:      xprt_create_proto created xprt %p\n", xprt);
 	return xprt;
+ out_bad:
+	dprintk("RPC:      xprt_create_proto failed\n");
+	if (xprt)
+		rpc_free(xprt);
+	return NULL;
 }
 
 /*

From: Chuck Lever <cel@citi.umich.edu>
Subject: [PATCH] check initial RPC timeout values more carefully
Date: Wed, 13 Nov 2002 12:36:10 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0211131232410.12934-100000@dexter.citi.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dexter.citi.umich.edu ([141.211.133.33])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18C1RC-0002ax-00
	for <nfs@lists.sourceforge.net>; Wed, 13 Nov 2002 09:36:27 -0800
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

this patch provides better checking of initial RPC timeout values, and
moves protocol-specific setup (part of which is timeout value setup) into
separate functions.  this will ease the addition of support for new
networking protocols later.

against 2.5.47 with previous patches.


diff -ruN 11-timeout/fs/nfs/inode.c 12-timeout-check/fs/nfs/inode.c
--- 11-timeout/fs/nfs/inode.c	Sun Nov 10 22:28:28 2002
+++ 12-timeout-check/fs/nfs/inode.c	Wed Nov 13 11:56:46 2002
@@ -391,7 +391,6 @@
 	/* Initialize timeout values */
 	timeparms.to_initval = data->timeo * HZ / 10;
 	timeparms.to_retries = data->retrans;
-	timeparms.to_maxval  = tcp? RPC_MAX_TCP_TIMEOUT : RPC_MAX_UDP_TIMEOUT;
 	timeparms.to_exponential = 1;
 
 	if (!timeparms.to_initval)
@@ -1309,12 +1308,10 @@
 	/* Which IP protocol do we use? */
 	switch (proto) {
 	case IPPROTO_TCP:
-		timeparms.to_maxval  = RPC_MAX_TCP_TIMEOUT;
 		if (!timeparms.to_initval)
 			timeparms.to_initval = 600 * HZ / 10;
 		break;
 	case IPPROTO_UDP:
-		timeparms.to_maxval  = RPC_MAX_UDP_TIMEOUT;
 		if (!timeparms.to_initval)
 			timeparms.to_initval = 11 * HZ / 10;
 		break;
diff -ruN 11-timeout/include/linux/sunrpc/xprt.h 12-timeout-check/include/linux/sunrpc/xprt.h
--- 11-timeout/include/linux/sunrpc/xprt.h	Tue Nov 12 17:06:16 2002
+++ 12-timeout-check/include/linux/sunrpc/xprt.h	Wed Nov 13 11:30:12 2002
@@ -40,7 +40,21 @@
 #define RPC_INITCWND		RPC_CWNDSCALE
 #define RPCXPRT_CONGESTED(xprt) ((xprt)->cong >= (xprt)->cwnd)
 
+/*
+ * RTO for stream transports should always be long.  The RPC client
+ * handles a major timeout by first closing and reconnecting the
+ * underlying stream transport socket.
+ */
+#define RPC_MIN_UDP_TIMEOUT    (HZ/10)
+#define RPC_MIN_TCP_TIMEOUT    (6*HZ)
+
 /* Default timeout values */
+#define RPC_DEF_UDP_TIMEOUT    (5*HZ)
+#define RPC_DEF_UDP_RETRIES    (5)
+#define RPC_DEF_TCP_TIMEOUT    (60*HZ)
+#define RPC_DEF_TCP_RETRIES    (2)
+
+/* Maximum timeout values */
 #define RPC_MAX_UDP_TIMEOUT	(60*HZ)
 #define RPC_MAX_TCP_TIMEOUT	(600*HZ)
 
@@ -175,7 +189,6 @@
 					struct rpc_timeout *toparms);
 int			xprt_destroy(struct rpc_xprt *);
 void			xprt_shutdown(struct rpc_xprt *);
-void			xprt_default_timeout(struct rpc_timeout *, int);
 void			xprt_set_timeout(struct rpc_timeout *, unsigned int,
 					unsigned long);
 
diff -ruN 11-timeout/net/sunrpc/xprt.c 12-timeout-check/net/sunrpc/xprt.c
--- 11-timeout/net/sunrpc/xprt.c	Tue Nov 12 17:06:16 2002
+++ 12-timeout-check/net/sunrpc/xprt.c	Wed Nov 13 12:07:14 2002
@@ -355,10 +355,6 @@
 		to->to_current = to->to_initval;
 	}
 
-	if (!to->to_current) {
-		printk(KERN_WARNING "xprt_adjust_timeout: to_current = 0!\n");
-		to->to_current = 5 * HZ;
-	}
 	pprintk("RPC: %lu %s\n", jiffies,
 			to->to_retries? "retrans" : "timeout");
 	return;
@@ -1327,18 +1323,6 @@
 }
 
 /*
- * Set default timeout parameters
- */
-void
-xprt_default_timeout(struct rpc_timeout *to, int proto)
-{
-	if (proto == IPPROTO_UDP)
-		xprt_set_timeout(to, 5,  5 * HZ);
-	else
-		xprt_set_timeout(to, 5, 60 * HZ);
-}
-
-/*
  * Set constant timeout
  */
 void
@@ -1352,6 +1336,55 @@
 	to->to_exponential = 0;
 }
 
+static void
+xprt_udp_setup(struct rpc_xprt *xprt, struct rpc_timeout *to)
+{
+	xprt->prot = IPPROTO_UDP;
+
+	xprt->cwnd = RPC_INITCWND;
+
+	/* Set timeout parameters */
+	if (to) {
+		xprt->timeout = *to;
+
+		to->to_maxval = RPC_MAX_UDP_TIMEOUT;
+
+		if (to->to_initval < RPC_MIN_UDP_TIMEOUT)
+			to->to_initval = RPC_MIN_UDP_TIMEOUT;
+		if (to->to_initval > RPC_MAX_UDP_TIMEOUT)
+			to->to_initval = RPC_MAX_UDP_TIMEOUT;
+
+		xprt->timeout.to_current = to->to_initval;
+	} else
+		xprt_set_timeout(to, RPC_DEF_UDP_RETRIES, RPC_DEF_UDP_TIMEOUT);
+}
+
+static void
+xprt_tcp_setup(struct rpc_xprt *xprt, struct rpc_timeout *to)
+{
+	xprt->prot = IPPROTO_TCP;
+
+	xprt->stream = 1;
+	xprt->nocong = 1;
+	xprt->cwnd = RPC_MAXCWND;
+
+	/* Set timeout parameters */
+	if (to) {
+		xprt->timeout = *to;
+
+		to->to_maxval = RPC_MAX_TCP_TIMEOUT;
+
+		if (to->to_initval < RPC_MIN_TCP_TIMEOUT)
+			to->to_initval = RPC_MIN_TCP_TIMEOUT;
+		if (to->to_initval > RPC_MAX_TCP_TIMEOUT)
+			to->to_initval = RPC_MAX_TCP_TIMEOUT;
+
+		xprt->timeout.to_current = to->to_initval;
+	} else
+		xprt_set_timeout(to, RPC_DEF_TCP_RETRIES, RPC_DEF_TCP_TIMEOUT);
+
+}
+
 /*
  * Initialize an RPC client
  */
@@ -1370,26 +1403,26 @@
 	memset(xprt, 0, sizeof(*xprt)); /* Nnnngh! */
 
 	xprt->addr = *ap;
-	xprt->prot = proto;
-	xprt->stream = (proto == IPPROTO_TCP)? 1 : 0;
-	if (xprt->stream) {
-		xprt->cwnd = RPC_MAXCWND;
-		xprt->nocong = 1;
-	} else
-		xprt->cwnd = RPC_INITCWND;
+
+	switch (proto) {
+	case IPPROTO_UDP:
+		xprt_udp_setup(xprt, to);
+		break;
+	case IPPROTO_TCP:
+		xprt_tcp_setup(xprt, to);
+		break;
+	default:
+		printk(KERN_WARNING "RPC: unsupported protocol %d\n", proto);
+		kfree(xprt);
+		return NULL;
+	}
+
 	spin_lock_init(&xprt->sock_lock);
 	spin_lock_init(&xprt->xprt_lock);
 	init_waitqueue_head(&xprt->cong_wait);
 
 	INIT_LIST_HEAD(&xprt->recv);
 
-	/* Set timeout parameters */
-	if (to) {
-		xprt->timeout = *to;
-		xprt->timeout.to_current = to->to_initval;
-	} else
-		xprt_default_timeout(&xprt->timeout, xprt->prot);
-
 	INIT_RPC_WAITQ(&xprt->pending, "xprt_pending");
 	INIT_RPC_WAITQ(&xprt->sending, "xprt_sending");
 	INIT_RPC_WAITQ(&xprt->resend, "xprt_resend");



-------------------------------------------------------
This sf.net email is sponsored by: Are you worried about 
your web server security? Click here for a FREE Thawte 
Apache SSL Guide and answer your Apache SSL security 
needs: http://www.gothawte.com/rd523.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

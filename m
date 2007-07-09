From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: 2.6.22 [PATCH] SUNRPC: cleanup transport creation argument
	passing
Date: Mon, 9 Jul 2007 22:10:53 +0200
Message-ID: <20070709201053.GA3897@janus>
References: <20070708110854.GA14883@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I7zZW-0001Je-Hw
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 13:11:02 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I7zZT-0007Xd-3t
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 13:11:06 -0700
In-Reply-To: <20070708110854.GA14883@janus>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Cleanup argument passing to functions for creating an RPC transport

Signed-off-by: Frank van Maarseveen <frankvm@frankvm.com>
---

diff -urp a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
--- a/include/linux/sunrpc/xprt.h	2007-07-09 19:43:50.000000000 +0200
+++ b/include/linux/sunrpc/xprt.h	2007-07-09 19:48:04.000000000 +0200
@@ -17,6 +17,8 @@
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/msg_prot.h>
 
+#ifdef __KERNEL__
+
 extern unsigned int xprt_udp_slot_table_entries;
 extern unsigned int xprt_tcp_slot_table_entries;
 
@@ -194,7 +196,12 @@ struct rpc_xprt {
 	char *			address_strings[RPC_DISPLAY_MAX];
 };
 
-#ifdef __KERNEL__
+struct rpc_xprtsock_create {
+	int			proto;		/* IPPROTO_UDP or IPPROTO_TCP */
+	struct sockaddr *	dstaddr;	/* remote peer address */
+	size_t			addrlen;
+	struct rpc_timeout *	timeout;	/* optional timeout parameters */
+};
 
 /*
  * Transport operations used by ULPs
@@ -204,7 +211,7 @@ void			xprt_set_timeout(struct rpc_timeo
 /*
  * Generic internal transport functions
  */
-struct rpc_xprt *	xprt_create_transport(int proto, struct sockaddr *addr, size_t size, struct rpc_timeout *toparms);
+struct rpc_xprt *	xprt_create_transport(struct rpc_xprtsock_create *args);
 void			xprt_connect(struct rpc_task *task);
 void			xprt_reserve(struct rpc_task *task);
 int			xprt_reserve_xprt(struct rpc_task *task);
@@ -242,8 +249,8 @@ void			xprt_disconnect(struct rpc_xprt *
 /*
  * Socket transport setup operations
  */
-struct rpc_xprt *	xs_setup_udp(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to);
-struct rpc_xprt *	xs_setup_tcp(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to);
+struct rpc_xprt *	xs_setup_udp(struct rpc_xprtsock_create *args);
+struct rpc_xprt *	xs_setup_tcp(struct rpc_xprtsock_create *args);
 int			init_socket_xprt(void);
 void			cleanup_socket_xprt(void);
 
diff -urp a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
--- a/net/sunrpc/clnt.c	2007-07-09 19:43:54.000000000 +0200
+++ b/net/sunrpc/clnt.c	2007-07-09 19:46:35.000000000 +0200
@@ -205,9 +205,14 @@ struct rpc_clnt *rpc_create(struct rpc_c
 {
 	struct rpc_xprt *xprt;
 	struct rpc_clnt *clnt;
+	struct rpc_xprtsock_create xprtargs = {
+		.proto = args->protocol,
+		.dstaddr = args->address,
+		.addrlen = args->addrsize,
+		.timeout = args->timeout
+	};
 
-	xprt = xprt_create_transport(args->protocol, args->address,
-					args->addrsize, args->timeout);
+	xprt = xprt_create_transport(&xprtargs);
 	if (IS_ERR(xprt))
 		return (struct rpc_clnt *)xprt;
 
diff -urp a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
--- a/net/sunrpc/xprt.c	2007-07-09 19:43:54.000000000 +0200
+++ b/net/sunrpc/xprt.c	2007-07-09 19:46:35.000000000 +0200
@@ -886,27 +886,24 @@ void xprt_set_timeout(struct rpc_timeout
 
 /**
  * xprt_create_transport - create an RPC transport
- * @proto: requested transport protocol
- * @ap: remote peer address
- * @size: length of address
- * @to: timeout parameters
+ * @args: rpc transport creation arguments
  *
  */
-struct rpc_xprt *xprt_create_transport(int proto, struct sockaddr *ap, size_t size, struct rpc_timeout *to)
+struct rpc_xprt *xprt_create_transport(struct rpc_xprtsock_create *args)
 {
 	struct rpc_xprt	*xprt;
 	struct rpc_rqst	*req;
 
-	switch (proto) {
+	switch (args->proto) {
 	case IPPROTO_UDP:
-		xprt = xs_setup_udp(ap, size, to);
+		xprt = xs_setup_udp(args);
 		break;
 	case IPPROTO_TCP:
-		xprt = xs_setup_tcp(ap, size, to);
+		xprt = xs_setup_tcp(args);
 		break;
 	default:
 		printk(KERN_ERR "RPC: unrecognized transport protocol: %d\n",
-				proto);
+				args->proto);
 		return ERR_PTR(-EIO);
 	}
 	if (IS_ERR(xprt)) {
diff -urp a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
--- a/net/sunrpc/xprtsock.c	2007-07-09 19:43:54.000000000 +0200
+++ b/net/sunrpc/xprtsock.c	2007-07-09 19:46:35.000000000 +0200
@@ -1505,12 +1505,12 @@ static struct rpc_xprt_ops xs_tcp_ops = 
 	.print_stats		= xs_tcp_print_stats,
 };
 
-static struct rpc_xprt *xs_setup_xprt(struct sockaddr *addr, size_t addrlen, unsigned int slot_table_size)
+static struct rpc_xprt *xs_setup_xprt(struct rpc_xprtsock_create *args, unsigned int slot_table_size)
 {
 	struct rpc_xprt *xprt;
 	struct sock_xprt *new;
 
-	if (addrlen > sizeof(xprt->addr)) {
+	if (args->addrlen > sizeof(xprt->addr)) {
 		dprintk("RPC:       xs_setup_xprt: address too large\n");
 		return ERR_PTR(-EBADF);
 	}
@@ -1532,8 +1532,8 @@ static struct rpc_xprt *xs_setup_xprt(st
 		return ERR_PTR(-ENOMEM);
 	}
 
-	memcpy(&xprt->addr, addr, addrlen);
-	xprt->addrlen = addrlen;
+	memcpy(&xprt->addr, args->dstaddr, args->addrlen);
+	xprt->addrlen = args->addrlen;
 	new->port = xs_get_random_port();
 
 	return xprt;
@@ -1541,22 +1541,20 @@ static struct rpc_xprt *xs_setup_xprt(st
 
 /**
  * xs_setup_udp - Set up transport to use a UDP socket
- * @addr: address of remote server
- * @addrlen: length of address in bytes
- * @to:   timeout parameters
+ * @args: rpc transport creation arguments
  *
  */
-struct rpc_xprt *xs_setup_udp(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to)
+struct rpc_xprt *xs_setup_udp(struct rpc_xprtsock_create *args)
 {
 	struct rpc_xprt *xprt;
 	struct sock_xprt *transport;
 
-	xprt = xs_setup_xprt(addr, addrlen, xprt_udp_slot_table_entries);
+	xprt = xs_setup_xprt(args, xprt_udp_slot_table_entries);
 	if (IS_ERR(xprt))
 		return xprt;
 	transport = container_of(xprt, struct sock_xprt, xprt);
 
-	if (ntohs(((struct sockaddr_in *)addr)->sin_port) != 0)
+	if (ntohs(((struct sockaddr_in *)args->dstaddr)->sin_port) != 0)
 		xprt_set_bound(xprt);
 
 	xprt->prot = IPPROTO_UDP;
@@ -1572,8 +1570,8 @@ struct rpc_xprt *xs_setup_udp(struct soc
 
 	xprt->ops = &xs_udp_ops;
 
-	if (to)
-		xprt->timeout = *to;
+	if (args->timeout)
+		xprt->timeout = *args->timeout;
 	else
 		xprt_set_timeout(&xprt->timeout, 5, 5 * HZ);
 
@@ -1586,22 +1584,20 @@ struct rpc_xprt *xs_setup_udp(struct soc
 
 /**
  * xs_setup_tcp - Set up transport to use a TCP socket
- * @addr: address of remote server
- * @addrlen: length of address in bytes
- * @to: timeout parameters
+ * @args: rpc transport creation arguments
  *
  */
-struct rpc_xprt *xs_setup_tcp(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to)
+struct rpc_xprt *xs_setup_tcp(struct rpc_xprtsock_create *args)
 {
 	struct rpc_xprt *xprt;
 	struct sock_xprt *transport;
 
-	xprt = xs_setup_xprt(addr, addrlen, xprt_tcp_slot_table_entries);
+	xprt = xs_setup_xprt(args, xprt_tcp_slot_table_entries);
 	if (IS_ERR(xprt))
 		return xprt;
 	transport = container_of(xprt, struct sock_xprt, xprt);
 
-	if (ntohs(((struct sockaddr_in *)addr)->sin_port) != 0)
+	if (ntohs(((struct sockaddr_in *)args->dstaddr)->sin_port) != 0)
 		xprt_set_bound(xprt);
 
 	xprt->prot = IPPROTO_TCP;
@@ -1616,8 +1612,8 @@ struct rpc_xprt *xs_setup_tcp(struct soc
 
 	xprt->ops = &xs_tcp_ops;
 
-	if (to)
-		xprt->timeout = *to;
+	if (args->timeout)
+		xprt->timeout = *args->timeout;
 	else
 		xprt_set_timeout(&xprt->timeout, 2, 60 * HZ);
 

-- 
Frank

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

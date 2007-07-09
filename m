From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: 2.6.22 [PATCH 2/3] SUNRPC client: add interface for binding
	to a local address
Date: Mon, 9 Jul 2007 22:23:35 +0200
Message-ID: <20070709202335.GC3970@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I7zld-0002gH-7s
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 13:23:33 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I7zlg-0004VR-9X
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 13:23:36 -0700
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

In addition to binding to a local privileged port the NFS client should
allow binding to a specific local address. This is used by the server
for callbacks. The patch adds the necessary interface.

Signed-off-by: Frank van Maarseveen <frankvm@frankvm.com>
---

diff -urp a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
--- a/include/linux/sunrpc/clnt.h	2007-07-09 19:43:50.000000000 +0200
+++ b/include/linux/sunrpc/clnt.h	2007-07-09 19:53:10.000000000 +0200
@@ -98,6 +98,7 @@ struct rpc_create_args {
 	int			protocol;
 	struct sockaddr		*address;
 	size_t			addrsize;
+	struct sockaddr		*saddress;
 	struct rpc_timeout	*timeout;
 	char			*servername;
 	struct rpc_program	*program;
diff -urp a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
--- a/include/linux/sunrpc/xprt.h	2007-07-09 19:48:04.000000000 +0200
+++ b/include/linux/sunrpc/xprt.h	2007-07-09 19:53:10.000000000 +0200
@@ -198,6 +198,7 @@ struct rpc_xprt {
 
 struct rpc_xprtsock_create {
 	int			proto;		/* IPPROTO_UDP or IPPROTO_TCP */
+	struct sockaddr *	srcaddr;	/* optional local address */
 	struct sockaddr *	dstaddr;	/* remote peer address */
 	size_t			addrlen;
 	struct rpc_timeout *	timeout;	/* optional timeout parameters */
diff -urp a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
--- a/net/sunrpc/clnt.c	2007-07-09 19:46:35.000000000 +0200
+++ b/net/sunrpc/clnt.c	2007-07-09 19:53:10.000000000 +0200
@@ -207,6 +207,7 @@ struct rpc_clnt *rpc_create(struct rpc_c
 	struct rpc_clnt *clnt;
 	struct rpc_xprtsock_create xprtargs = {
 		.proto = args->protocol,
+		.srcaddr = args->saddress,
 		.dstaddr = args->address,
 		.addrlen = args->addrsize,
 		.timeout = args->timeout
diff -urp a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
--- a/net/sunrpc/xprtsock.c	2007-07-09 19:46:35.000000000 +0200
+++ b/net/sunrpc/xprtsock.c	2007-07-09 19:53:10.000000000 +0200
@@ -235,6 +235,7 @@ struct sock_xprt {
 	 * Connection of transports
 	 */
 	struct delayed_work	connect_worker;
+	struct sockaddr_storage	addr;
 	unsigned short		port;
 
 	/*
@@ -1146,31 +1147,36 @@ static void xs_set_port(struct rpc_xprt 
 	sap->sin_port = htons(port);
 }
 
-static int xs_bindresvport(struct sock_xprt *transport, struct socket *sock)
+static int xs_bind(struct sock_xprt *transport, struct socket *sock)
 {
 	struct sockaddr_in myaddr = {
 		.sin_family = AF_INET,
 	};
+	struct sockaddr_in *sa;
 	int err;
 	unsigned short port = transport->port;
 
+	if (!transport->xprt.resvport)
+		port = 0;
+	sa = (struct sockaddr_in *)&transport->addr;
+	myaddr.sin_addr = sa->sin_addr;
 	do {
 		myaddr.sin_port = htons(port);
 		err = kernel_bind(sock, (struct sockaddr *) &myaddr,
 						sizeof(myaddr));
+		if (!transport->xprt.resvport)
+			break;
 		if (err == 0) {
 			transport->port = port;
-			dprintk("RPC:       xs_bindresvport bound to port %u\n",
-					port);
-			return 0;
+			break;
 		}
 		if (port <= xprt_min_resvport)
 			port = xprt_max_resvport;
 		else
 			port--;
 	} while (err == -EADDRINUSE && port != transport->port);
-
-	dprintk("RPC:       can't bind to reserved port (%d).\n", -err);
+	dprintk("RPC:       xs_bind "NIPQUAD_FMT":%u: %s (%d)\n",
+		NIPQUAD(myaddr.sin_addr), port, err ? "failed" : "ok", err);
 	return err;
 }
 
@@ -1229,7 +1235,7 @@ static void xs_udp_connect_worker(struct
 	}
 	xs_reclassify_socket(sock);
 
-	if (xprt->resvport && xs_bindresvport(transport, sock) < 0) {
+	if (xs_bind(transport, sock)) {
 		sock_release(sock);
 		goto out;
 	}
@@ -1316,7 +1322,7 @@ static void xs_tcp_connect_worker(struct
 		}
 		xs_reclassify_socket(sock);
 
-		if (xprt->resvport && xs_bindresvport(transport, sock) < 0) {
+		if (xs_bind(transport, sock)) {
 			sock_release(sock);
 			goto out;
 		}
@@ -1534,6 +1540,8 @@ static struct rpc_xprt *xs_setup_xprt(st
 
 	memcpy(&xprt->addr, args->dstaddr, args->addrlen);
 	xprt->addrlen = args->addrlen;
+	if (args->srcaddr)
+		memcpy(&new->addr, args->srcaddr, args->addrlen);
 	new->port = xs_get_random_port();
 
 	return xprt;

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

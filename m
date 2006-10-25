From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/10] SUNRPC: Move rpc_xprt socket connect fields
	into private data structure
Date: Wed, 25 Oct 2006 12:47:09 -0400
Message-ID: <20061025164708.6410.45824.stgit@localhost.localdomain>
References: <20061025164602.6410.27449.stgit@localhost.localdomain>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GcrQh-0006R1-61
	for nfs@lists.sourceforge.net; Wed, 25 Oct 2006 15:40:59 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GcrQh-0003hA-On
	for nfs@lists.sourceforge.net; Wed, 25 Oct 2006 15:41:00 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <20061025164602.6410.27449.stgit@localhost.localdomain>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Move the socket-specific connection management fields out of the generic
rpc_xprt structure into a private data structure maintained in
net/sunrpc/xprtsock.c.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xprt.h |    2 --
 net/sunrpc/xprtsock.c       |   51 ++++++++++++++++++++++++++++---------------
 2 files changed, 33 insertions(+), 20 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 3ff8230..18bf72c 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -163,8 +163,6 @@ struct rpc_xprt {
 	unsigned long		connect_timeout,
 				bind_timeout,
 				reestablish_timeout;
-	struct work_struct	connect_worker;
-	unsigned short		port;
 
 	/*
 	 * Disconnection of idle transports
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 0e01296..091b39a 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -145,6 +145,12 @@ struct sock_xprt {
 
 	unsigned long		tcp_copied,
 				tcp_flags;
+
+	/*
+	 * Connection of transports
+	 */
+	struct work_struct	connect_worker;
+	unsigned short		port;
 };
 
 /*
@@ -555,9 +561,11 @@ clear_close_wait:
  */
 static void xs_destroy(struct rpc_xprt *xprt)
 {
+	struct sock_xprt *sx = container_of(xprt, struct sock_xprt, xprt);
+
 	dprintk("RPC:      xs_destroy xprt %p\n", xprt);
 
-	cancel_delayed_work(&xprt->connect_worker);
+	cancel_delayed_work(&sx->connect_worker);
 	flush_scheduled_work();
 
 	xprt_disconnect(xprt);
@@ -1072,20 +1080,20 @@ static void xs_set_port(struct rpc_xprt 
 	sap->sin_port = htons(port);
 }
 
-static int xs_bindresvport(struct rpc_xprt *xprt, struct socket *sock)
+static int xs_bindresvport(struct sock_xprt *sx, struct socket *sock)
 {
 	struct sockaddr_in myaddr = {
 		.sin_family = AF_INET,
 	};
 	int err;
-	unsigned short port = xprt->port;
+	unsigned short port = sx->port;
 
 	do {
 		myaddr.sin_port = htons(port);
 		err = kernel_bind(sock, (struct sockaddr *) &myaddr,
 						sizeof(myaddr));
 		if (err == 0) {
-			xprt->port = port;
+			sx->port = port;
 			dprintk("RPC:      xs_bindresvport bound to port %u\n",
 					port);
 			return 0;
@@ -1094,7 +1102,7 @@ static int xs_bindresvport(struct rpc_xp
 			port = xprt_max_resvport;
 		else
 			port--;
-	} while (err == -EADDRINUSE && port != xprt->port);
+	} while (err == -EADDRINUSE && port != sx->port);
 
 	dprintk("RPC:      can't bind to reserved port (%d).\n", -err);
 	return err;
@@ -1108,8 +1116,8 @@ static int xs_bindresvport(struct rpc_xp
  */
 static void xs_udp_connect_worker(void *args)
 {
-	struct rpc_xprt *xprt = (struct rpc_xprt *) args;
-	struct sock_xprt *sx = container_of(xprt, struct sock_xprt, xprt);
+	struct sock_xprt *sx = (struct sock_xprt *)args;
+	struct rpc_xprt *xprt = &sx->xprt;
 	struct socket *sock = sx->sock;
 	int err, status = -EIO;
 
@@ -1124,7 +1132,7 @@ static void xs_udp_connect_worker(void *
 		goto out;
 	}
 
-	if (xprt->resvport && xs_bindresvport(xprt, sock) < 0) {
+	if (xprt->resvport && xs_bindresvport(sx, sock) < 0) {
 		sock_release(sock);
 		goto out;
 	}
@@ -1193,8 +1201,8 @@ static void xs_tcp_reuse_connection(stru
  */
 static void xs_tcp_connect_worker(void *args)
 {
-	struct rpc_xprt *xprt = (struct rpc_xprt *)args;
-	struct sock_xprt *sx = container_of(xprt, struct sock_xprt, xprt);
+	struct sock_xprt *sx = (struct sock_xprt *)args;
+	struct rpc_xprt *xprt = &sx->xprt;
 	struct socket *sock = sx->sock;
 	int err, status = -EIO;
 
@@ -1208,7 +1216,7 @@ static void xs_tcp_connect_worker(void *
 			goto out;
 		}
 
-		if (xprt->resvport && xs_bindresvport(xprt, sock) < 0) {
+		if (xprt->resvport && xs_bindresvport(sx, sock) < 0) {
 			sock_release(sock);
 			goto out;
 		}
@@ -1300,14 +1308,14 @@ static void xs_connect(struct rpc_task *
 	if (sx->sock != NULL) {
 		dprintk("RPC:      xs_connect delayed xprt %p for %lu seconds\n",
 				xprt, xprt->reestablish_timeout / HZ);
-		schedule_delayed_work(&xprt->connect_worker,
+		schedule_delayed_work(&sx->connect_worker,
 					xprt->reestablish_timeout);
 		xprt->reestablish_timeout <<= 1;
 		if (xprt->reestablish_timeout > XS_TCP_MAX_REEST_TO)
 			xprt->reestablish_timeout = XS_TCP_MAX_REEST_TO;
 	} else {
 		dprintk("RPC:      xs_connect scheduled xprt %p\n", xprt);
-		schedule_work(&xprt->connect_worker);
+		schedule_work(&sx->connect_worker);
 
 		/* flush_scheduled_work can sleep... */
 		if (!RPC_IS_ASYNC(task))
@@ -1323,8 +1331,10 @@ static void xs_connect(struct rpc_task *
  */
 static void xs_udp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 {
+	struct sock_xprt *sx = container_of(xprt, struct sock_xprt, xprt);
+
 	seq_printf(seq, "\txprt:\tudp %u %lu %lu %lu %lu %Lu %Lu\n",
-			xprt->port,
+			sx->port,
 			xprt->stat.bind_count,
 			xprt->stat.sends,
 			xprt->stat.recvs,
@@ -1341,13 +1351,14 @@ static void xs_udp_print_stats(struct rp
  */
 static void xs_tcp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 {
+	struct sock_xprt *sx = container_of(xprt, struct sock_xprt, xprt);
 	long idle_time = 0;
 
 	if (xprt_connected(xprt))
 		idle_time = (long)(jiffies - xprt->last_used) / HZ;
 
 	seq_printf(seq, "\txprt:\ttcp %u %lu %lu %lu %ld %lu %lu %lu %Lu %Lu\n",
-			xprt->port,
+			sx->port,
 			xprt->stat.bind_count,
 			xprt->stat.connect_count,
 			xprt->stat.connect_time,
@@ -1421,7 +1432,7 @@ static struct rpc_xprt *xs_setup_xprt(st
 
 	memcpy(&xprt->addr, addr, addrlen);
 	xprt->addrlen = addrlen;
-	xprt->port = xs_get_random_port();
+	sx->port = xs_get_random_port();
 
 	return xprt;
 }
@@ -1436,10 +1447,12 @@ static struct rpc_xprt *xs_setup_xprt(st
 struct rpc_xprt *xs_setup_udp(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to)
 {
 	struct rpc_xprt *xprt;
+	struct sock_xprt *sx;
 
 	xprt = xs_setup_xprt(addr, addrlen, xprt_udp_slot_table_entries);
 	if (IS_ERR(xprt))
 		return xprt;
+	sx = container_of(xprt, struct sock_xprt, xprt);
 
 	if (ntohs(((struct sockaddr_in *)addr)->sin_port) != 0)
 		xprt_set_bound(xprt);
@@ -1449,7 +1462,7 @@ struct rpc_xprt *xs_setup_udp(struct soc
 	/* XXX: header size can vary due to auth type, IPv6, etc. */
 	xprt->max_payload = (1U << 16) - (MAX_HEADER << 3);
 
-	INIT_WORK(&xprt->connect_worker, xs_udp_connect_worker, xprt);
+	INIT_WORK(&sx->connect_worker, xs_udp_connect_worker, sx);
 	xprt->bind_timeout = XS_BIND_TO;
 	xprt->connect_timeout = XS_UDP_CONN_TO;
 	xprt->reestablish_timeout = XS_UDP_REEST_TO;
@@ -1479,10 +1492,12 @@ struct rpc_xprt *xs_setup_udp(struct soc
 struct rpc_xprt *xs_setup_tcp(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to)
 {
 	struct rpc_xprt *xprt;
+	struct sock_xprt *sx;
 
 	xprt = xs_setup_xprt(addr, addrlen, xprt_tcp_slot_table_entries);
 	if (IS_ERR(xprt))
 		return xprt;
+	sx = container_of(xprt, struct sock_xprt, xprt);
 
 	if (ntohs(((struct sockaddr_in *)addr)->sin_port) != 0)
 		xprt_set_bound(xprt);
@@ -1491,7 +1506,7 @@ struct rpc_xprt *xs_setup_tcp(struct soc
 	xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
 	xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
 
-	INIT_WORK(&xprt->connect_worker, xs_tcp_connect_worker, xprt);
+	INIT_WORK(&sx->connect_worker, xs_tcp_connect_worker, sx);
 	xprt->bind_timeout = XS_BIND_TO;
 	xprt->connect_timeout = XS_TCP_CONN_TO;
 	xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

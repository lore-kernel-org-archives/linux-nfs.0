From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/21] SUNRPC: Move rpc_xprt socket connect fields
	into private data structure
Date: Thu, 16 Nov 2006 15:04:11 -0500
Message-ID: <20061116200411.32549.90220.stgit@localhost.localdomain>
References: <20061116200151.32549.88898.stgit@localhost.localdomain>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gko1F-0006qT-Ha
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:39:33 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gko1E-0004oy-5R
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:39:34 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: <20061116200151.32549.88898.stgit@localhost.localdomain>
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
index 66096a9..5e3e51c 100644
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
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+
 	dprintk("RPC:      xs_destroy xprt %p\n", xprt);
 
-	cancel_delayed_work(&xprt->connect_worker);
+	cancel_delayed_work(&transport->connect_worker);
 	flush_scheduled_work();
 
 	xprt_disconnect(xprt);
@@ -1075,20 +1083,20 @@ static void xs_set_port(struct rpc_xprt 
 	sap->sin_port = htons(port);
 }
 
-static int xs_bindresvport(struct rpc_xprt *xprt, struct socket *sock)
+static int xs_bindresvport(struct sock_xprt *transport, struct socket *sock)
 {
 	struct sockaddr_in myaddr = {
 		.sin_family = AF_INET,
 	};
 	int err;
-	unsigned short port = xprt->port;
+	unsigned short port = transport->port;
 
 	do {
 		myaddr.sin_port = htons(port);
 		err = kernel_bind(sock, (struct sockaddr *) &myaddr,
 						sizeof(myaddr));
 		if (err == 0) {
-			xprt->port = port;
+			transport->port = port;
 			dprintk("RPC:      xs_bindresvport bound to port %u\n",
 					port);
 			return 0;
@@ -1097,7 +1105,7 @@ static int xs_bindresvport(struct rpc_xp
 			port = xprt_max_resvport;
 		else
 			port--;
-	} while (err == -EADDRINUSE && port != xprt->port);
+	} while (err == -EADDRINUSE && port != transport->port);
 
 	dprintk("RPC:      can't bind to reserved port (%d).\n", -err);
 	return err;
@@ -1111,8 +1119,8 @@ static int xs_bindresvport(struct rpc_xp
  */
 static void xs_udp_connect_worker(void *args)
 {
-	struct rpc_xprt *xprt = (struct rpc_xprt *) args;
-	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+	struct sock_xprt *transport = (struct sock_xprt *)args;
+	struct rpc_xprt *xprt = &transport->xprt;
 	struct socket *sock = transport->sock;
 	int err, status = -EIO;
 
@@ -1127,7 +1135,7 @@ static void xs_udp_connect_worker(void *
 		goto out;
 	}
 
-	if (xprt->resvport && xs_bindresvport(xprt, sock) < 0) {
+	if (xprt->resvport && xs_bindresvport(transport, sock) < 0) {
 		sock_release(sock);
 		goto out;
 	}
@@ -1196,8 +1204,8 @@ static void xs_tcp_reuse_connection(stru
  */
 static void xs_tcp_connect_worker(void *args)
 {
-	struct rpc_xprt *xprt = (struct rpc_xprt *)args;
-	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+	struct sock_xprt *transport = (struct sock_xprt *)args;
+	struct rpc_xprt *xprt = &transport->xprt;
 	struct socket *sock = transport->sock;
 	int err, status = -EIO;
 
@@ -1211,7 +1219,7 @@ static void xs_tcp_connect_worker(void *
 			goto out;
 		}
 
-		if (xprt->resvport && xs_bindresvport(xprt, sock) < 0) {
+		if (xprt->resvport && xs_bindresvport(transport, sock) < 0) {
 			sock_release(sock);
 			goto out;
 		}
@@ -1303,14 +1311,14 @@ static void xs_connect(struct rpc_task *
 	if (transport->sock != NULL) {
 		dprintk("RPC:      xs_connect delayed xprt %p for %lu seconds\n",
 				xprt, xprt->reestablish_timeout / HZ);
-		schedule_delayed_work(&xprt->connect_worker,
+		schedule_delayed_work(&transport->connect_worker,
 					xprt->reestablish_timeout);
 		xprt->reestablish_timeout <<= 1;
 		if (xprt->reestablish_timeout > XS_TCP_MAX_REEST_TO)
 			xprt->reestablish_timeout = XS_TCP_MAX_REEST_TO;
 	} else {
 		dprintk("RPC:      xs_connect scheduled xprt %p\n", xprt);
-		schedule_work(&xprt->connect_worker);
+		schedule_work(&transport->connect_worker);
 
 		/* flush_scheduled_work can sleep... */
 		if (!RPC_IS_ASYNC(task))
@@ -1326,8 +1334,10 @@ static void xs_connect(struct rpc_task *
  */
 static void xs_udp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 {
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+
 	seq_printf(seq, "\txprt:\tudp %u %lu %lu %lu %lu %Lu %Lu\n",
-			xprt->port,
+			transport->port,
 			xprt->stat.bind_count,
 			xprt->stat.sends,
 			xprt->stat.recvs,
@@ -1344,13 +1354,14 @@ static void xs_udp_print_stats(struct rp
  */
 static void xs_tcp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 {
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
 	long idle_time = 0;
 
 	if (xprt_connected(xprt))
 		idle_time = (long)(jiffies - xprt->last_used) / HZ;
 
 	seq_printf(seq, "\txprt:\ttcp %u %lu %lu %lu %ld %lu %lu %lu %Lu %Lu\n",
-			xprt->port,
+			transport->port,
 			xprt->stat.bind_count,
 			xprt->stat.connect_count,
 			xprt->stat.connect_time,
@@ -1424,7 +1435,7 @@ static struct rpc_xprt *xs_setup_xprt(st
 
 	memcpy(&xprt->addr, addr, addrlen);
 	xprt->addrlen = addrlen;
-	xprt->port = xs_get_random_port();
+	new->port = xs_get_random_port();
 
 	return xprt;
 }
@@ -1439,10 +1450,12 @@ static struct rpc_xprt *xs_setup_xprt(st
 struct rpc_xprt *xs_setup_udp(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to)
 {
 	struct rpc_xprt *xprt;
+	struct sock_xprt *transport;
 
 	xprt = xs_setup_xprt(addr, addrlen, xprt_udp_slot_table_entries);
 	if (IS_ERR(xprt))
 		return xprt;
+	transport = container_of(xprt, struct sock_xprt, xprt);
 
 	if (ntohs(((struct sockaddr_in *)addr)->sin_port) != 0)
 		xprt_set_bound(xprt);
@@ -1452,7 +1465,7 @@ struct rpc_xprt *xs_setup_udp(struct soc
 	/* XXX: header size can vary due to auth type, IPv6, etc. */
 	xprt->max_payload = (1U << 16) - (MAX_HEADER << 3);
 
-	INIT_WORK(&xprt->connect_worker, xs_udp_connect_worker, xprt);
+	INIT_WORK(&transport->connect_worker, xs_udp_connect_worker, transport);
 	xprt->bind_timeout = XS_BIND_TO;
 	xprt->connect_timeout = XS_UDP_CONN_TO;
 	xprt->reestablish_timeout = XS_UDP_REEST_TO;
@@ -1482,10 +1495,12 @@ struct rpc_xprt *xs_setup_udp(struct soc
 struct rpc_xprt *xs_setup_tcp(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to)
 {
 	struct rpc_xprt *xprt;
+	struct sock_xprt *transport;
 
 	xprt = xs_setup_xprt(addr, addrlen, xprt_tcp_slot_table_entries);
 	if (IS_ERR(xprt))
 		return xprt;
+	transport = container_of(xprt, struct sock_xprt, xprt);
 
 	if (ntohs(((struct sockaddr_in *)addr)->sin_port) != 0)
 		xprt_set_bound(xprt);
@@ -1494,7 +1509,7 @@ struct rpc_xprt *xs_setup_tcp(struct soc
 	xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
 	xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
 
-	INIT_WORK(&xprt->connect_worker, xs_tcp_connect_worker, xprt);
+	INIT_WORK(&transport->connect_worker, xs_tcp_connect_worker, transport);
 	xprt->bind_timeout = XS_BIND_TO;
 	xprt->connect_timeout = XS_TCP_CONN_TO;
 	xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

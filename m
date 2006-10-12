From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/9] SUNRPC: Move rpc_xprt socket connect fields into
	private data structure
Date: Thu, 12 Oct 2006 17:15:15 -0400
Message-ID: <20061012211515.8734.44424.stgit@ingres.dsl.sfldmi.ameritech.net>
References: <20061012211247.8734.23147.stgit@ingres.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GY7to-00084v-Iq
	for nfs@lists.sourceforge.net; Thu, 12 Oct 2006 14:15:28 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GY7tp-00065R-4d
	for nfs@lists.sourceforge.net; Thu, 12 Oct 2006 14:15:29 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <20061012211247.8734.23147.stgit@ingres.dsl.sfldmi.ameritech.net>
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

Test plan:
Connectathon.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xprt.h |    2 --
 net/sunrpc/xprtsock.c       |   36 +++++++++++++++++++++++++-----------
 2 files changed, 25 insertions(+), 13 deletions(-)

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
index 363b2fc..b0bead5 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -145,6 +145,12 @@ struct xs_xprt {
 
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
@@ -565,7 +571,7 @@ static void xs_destroy(struct rpc_xprt *
 {
 	dprintk("RPC:      xs_destroy xprt %p\n", xprt);
 
-	cancel_delayed_work(&xprt->connect_worker);
+	cancel_delayed_work(&xs_private_data(xprt)->connect_worker);
 	flush_scheduled_work();
 
 	xprt_disconnect(xprt);
@@ -1076,18 +1082,19 @@ static void xs_set_port(struct rpc_xprt 
 
 static int xs_bindresvport(struct rpc_xprt *xprt, struct socket *sock)
 {
+	struct xs_xprt *private = xs_private_data(xprt);
 	struct sockaddr_in myaddr = {
 		.sin_family = AF_INET,
 	};
 	int err;
-	unsigned short port = xprt->port;
+	unsigned short port = private->port;
 
 	do {
 		myaddr.sin_port = htons(port);
 		err = kernel_bind(sock, (struct sockaddr *) &myaddr,
 						sizeof(myaddr));
 		if (err == 0) {
-			xprt->port = port;
+			private->port = port;
 			dprintk("RPC:      xs_bindresvport bound to port %u\n",
 					port);
 			return 0;
@@ -1096,7 +1103,7 @@ static int xs_bindresvport(struct rpc_xp
 			port = xprt_max_resvport;
 		else
 			port--;
-	} while (err == -EADDRINUSE && port != xprt->port);
+	} while (err == -EADDRINUSE && port != private->port);
 
 	dprintk("RPC:      can't bind to reserved port (%d).\n", -err);
 	return err;
@@ -1302,14 +1309,14 @@ static void xs_connect(struct rpc_task *
 	if (private->sock != NULL) {
 		dprintk("RPC:      xs_connect delayed xprt %p for %lu seconds\n",
 				xprt, xprt->reestablish_timeout / HZ);
-		schedule_delayed_work(&xprt->connect_worker,
+		schedule_delayed_work(&private->connect_worker,
 					xprt->reestablish_timeout);
 		xprt->reestablish_timeout <<= 1;
 		if (xprt->reestablish_timeout > XS_TCP_MAX_REEST_TO)
 			xprt->reestablish_timeout = XS_TCP_MAX_REEST_TO;
 	} else {
 		dprintk("RPC:      xs_connect scheduled xprt %p\n", xprt);
-		schedule_work(&xprt->connect_worker);
+		schedule_work(&private->connect_worker);
 
 		/* flush_scheduled_work can sleep... */
 		if (!RPC_IS_ASYNC(task))
@@ -1325,8 +1332,10 @@ static void xs_connect(struct rpc_task *
  */
 static void xs_udp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 {
+	struct xs_xprt *private = xs_private_data(xprt);
+
 	seq_printf(seq, "\txprt:\tudp %u %lu %lu %lu %lu %Lu %Lu\n",
-			xprt->port,
+			private->port,
 			xprt->stat.bind_count,
 			xprt->stat.sends,
 			xprt->stat.recvs,
@@ -1343,13 +1352,14 @@ static void xs_udp_print_stats(struct rp
  */
 static void xs_tcp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 {
+	struct xs_xprt *private = xs_private_data(xprt);
 	long idle_time = 0;
 
 	if (xprt_connected(xprt))
 		idle_time = (long)(jiffies - xprt->last_used) / HZ;
 
 	seq_printf(seq, "\txprt:\ttcp %u %lu %lu %lu %ld %lu %lu %lu %Lu %Lu\n",
-			xprt->port,
+			private->port,
 			xprt->stat.bind_count,
 			xprt->stat.connect_count,
 			xprt->stat.connect_time,
@@ -1423,7 +1433,7 @@ static struct rpc_xprt *xs_setup_xprt(st
 
 	memcpy(&xprt->addr, addr, addrlen);
 	xprt->addrlen = addrlen;
-	xprt->port = xs_get_random_port();
+	private->port = xs_get_random_port();
 
 	return xprt;
 }
@@ -1438,10 +1448,12 @@ static struct rpc_xprt *xs_setup_xprt(st
 struct rpc_xprt *xs_setup_udp(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to)
 {
 	struct rpc_xprt *xprt;
+	struct xs_xprt *private;
 
 	xprt = xs_setup_xprt(addr, addrlen, xprt_udp_slot_table_entries);
 	if (IS_ERR(xprt))
 		return xprt;
+	private = xs_private_data(xprt);
 
 	if (ntohs(((struct sockaddr_in *)addr)->sin_port) != 0)
 		xprt_set_bound(xprt);
@@ -1451,7 +1463,7 @@ struct rpc_xprt *xs_setup_udp(struct soc
 	/* XXX: header size can vary due to auth type, IPv6, etc. */
 	xprt->max_payload = (1U << 16) - (MAX_HEADER << 3);
 
-	INIT_WORK(&xprt->connect_worker, xs_udp_connect_worker, xprt);
+	INIT_WORK(&private->connect_worker, xs_udp_connect_worker, xprt);
 	xprt->bind_timeout = XS_BIND_TO;
 	xprt->connect_timeout = XS_UDP_CONN_TO;
 	xprt->reestablish_timeout = XS_UDP_REEST_TO;
@@ -1481,10 +1493,12 @@ struct rpc_xprt *xs_setup_udp(struct soc
 struct rpc_xprt *xs_setup_tcp(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to)
 {
 	struct rpc_xprt *xprt;
+	struct xs_xprt *private;
 
 	xprt = xs_setup_xprt(addr, addrlen, xprt_tcp_slot_table_entries);
 	if (IS_ERR(xprt))
 		return xprt;
+	private = xs_private_data(xprt);
 
 	if (ntohs(((struct sockaddr_in *)addr)->sin_port) != 0)
 		xprt_set_bound(xprt);
@@ -1493,7 +1507,7 @@ struct rpc_xprt *xs_setup_tcp(struct soc
 	xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
 	xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
 
-	INIT_WORK(&xprt->connect_worker, xs_tcp_connect_worker, xprt);
+	INIT_WORK(&private->connect_worker, xs_tcp_connect_worker, xprt);
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

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:34937 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752166AbbJEXDf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Oct 2015 19:03:35 -0400
Received: by ykdz138 with SMTP id z138so186606430ykd.2
        for <linux-nfs@vger.kernel.org>; Mon, 05 Oct 2015 16:03:35 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH 2/3] SUNRPC: Move TCP receive data path into a workqueue context
Date: Mon,  5 Oct 2015 19:03:30 -0400
Message-Id: <1444086211-4811-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1444086211-4811-1-git-send-email-trond.myklebust@primarydata.com>
References: <1444086211-4811-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Stream protocols such as TCP can often build up a backlog of data to be
read due to ordering. Combine this with the fact that some workloads such
as NFS read()-intensive workloads need to receive a lot of data per RPC
call, and it turns out that receiving the data from inside a softirq
context can cause starvation.

The following patch moves the TCP data receive into a workqueue context.
We still end up calling tcp_read_sock(), but we do so from a process
context, meaning that softirqs are enabled for most of the time.

With this patch, I see a doubling of read bandwidth when running a
multi-threaded iozone workload between a virtual client and server setup.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/xprtsock.h |  2 ++
 net/sunrpc/xprtsock.c           | 51 +++++++++++++++++++++++++++++------------
 2 files changed, 38 insertions(+), 15 deletions(-)

diff --git a/include/linux/sunrpc/xprtsock.h b/include/linux/sunrpc/xprtsock.h
index 357e44c1a46b..0ece4ba06f06 100644
--- a/include/linux/sunrpc/xprtsock.h
+++ b/include/linux/sunrpc/xprtsock.h
@@ -44,6 +44,8 @@ struct sock_xprt {
 	 */
 	unsigned long		sock_state;
 	struct delayed_work	connect_worker;
+	struct work_struct	recv_worker;
+	struct mutex		recv_mutex;
 	struct sockaddr_storage	srcaddr;
 	unsigned short		srcport;
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index fa8d0c15c8cd..58dc90ccebb6 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -823,6 +823,7 @@ static void xs_reset_transport(struct sock_xprt *transport)
 
 	kernel_sock_shutdown(sock, SHUT_RDWR);
 
+	mutex_lock(&transport->recv_mutex);
 	write_lock_bh(&sk->sk_callback_lock);
 	transport->inet = NULL;
 	transport->sock = NULL;
@@ -833,6 +834,7 @@ static void xs_reset_transport(struct sock_xprt *transport)
 	xprt_clear_connected(xprt);
 	write_unlock_bh(&sk->sk_callback_lock);
 	xs_sock_reset_connection_flags(xprt);
+	mutex_unlock(&transport->recv_mutex);
 
 	trace_rpc_socket_close(xprt, sock);
 	sock_release(sock);
@@ -886,6 +888,7 @@ static void xs_destroy(struct rpc_xprt *xprt)
 
 	cancel_delayed_work_sync(&transport->connect_worker);
 	xs_close(xprt);
+	cancel_work_sync(&transport->recv_worker);
 	xs_xprt_free(xprt);
 	module_put(THIS_MODULE);
 }
@@ -1243,12 +1246,12 @@ static inline int xs_tcp_read_reply(struct rpc_xprt *xprt,
 	dprintk("RPC:       read reply XID %08x\n", ntohl(transport->tcp_xid));
 
 	/* Find and lock the request corresponding to this xid */
-	spin_lock(&xprt->transport_lock);
+	spin_lock_bh(&xprt->transport_lock);
 	req = xprt_lookup_rqst(xprt, transport->tcp_xid);
 	if (!req) {
 		dprintk("RPC:       XID %08x request not found!\n",
 				ntohl(transport->tcp_xid));
-		spin_unlock(&xprt->transport_lock);
+		spin_unlock_bh(&xprt->transport_lock);
 		return -1;
 	}
 
@@ -1257,7 +1260,7 @@ static inline int xs_tcp_read_reply(struct rpc_xprt *xprt,
 	if (!(transport->tcp_flags & TCP_RCV_COPY_DATA))
 		xprt_complete_rqst(req->rq_task, transport->tcp_copied);
 
-	spin_unlock(&xprt->transport_lock);
+	spin_unlock_bh(&xprt->transport_lock);
 	return 0;
 }
 
@@ -1277,10 +1280,10 @@ static int xs_tcp_read_callback(struct rpc_xprt *xprt,
 	struct rpc_rqst *req;
 
 	/* Look up and lock the request corresponding to the given XID */
-	spin_lock(&xprt->transport_lock);
+	spin_lock_bh(&xprt->transport_lock);
 	req = xprt_lookup_bc_request(xprt, transport->tcp_xid);
 	if (req == NULL) {
-		spin_unlock(&xprt->transport_lock);
+		spin_unlock_bh(&xprt->transport_lock);
 		printk(KERN_WARNING "Callback slot table overflowed\n");
 		xprt_force_disconnect(xprt);
 		return -1;
@@ -1291,7 +1294,7 @@ static int xs_tcp_read_callback(struct rpc_xprt *xprt,
 
 	if (!(transport->tcp_flags & TCP_RCV_COPY_DATA))
 		xprt_complete_bc_request(req, transport->tcp_copied);
-	spin_unlock(&xprt->transport_lock);
+	spin_unlock_bh(&xprt->transport_lock);
 
 	return 0;
 }
@@ -1402,19 +1405,33 @@ static void xs_tcp_data_receive(struct sock_xprt *transport)
 	unsigned long total = 0;
 	int read = 0;
 
+	mutex_lock(&transport->recv_mutex);
 	sk = transport->inet;
+	if (sk == NULL)
+		goto out;
 
 	/* We use rd_desc to pass struct xprt to xs_tcp_data_recv */
 	for (;;) {
+		lock_sock(sk);
 		read = tcp_read_sock(sk, &rd_desc, xs_tcp_data_recv);
+		release_sock(sk);
 		if (read <= 0)
 			break;
 		total += read;
 		rd_desc.count = 65536;
 	}
+out:
+	mutex_unlock(&transport->recv_mutex);
 	trace_xs_tcp_data_ready(xprt, read, total);
 }
 
+static void xs_tcp_data_receive_workfn(struct work_struct *work)
+{
+	struct sock_xprt *transport =
+		container_of(work, struct sock_xprt, recv_worker);
+	xs_tcp_data_receive(transport);
+}
+
 /**
  * xs_tcp_data_ready - "data ready" callback for TCP sockets
  * @sk: socket with data to read
@@ -1437,8 +1454,8 @@ static void xs_tcp_data_ready(struct sock *sk)
 	 */
 	if (xprt->reestablish_timeout)
 		xprt->reestablish_timeout = 0;
+	queue_work(rpciod_workqueue, &transport->recv_worker);
 
-	xs_tcp_data_receive(transport);
 out:
 	read_unlock_bh(&sk->sk_callback_lock);
 }
@@ -1840,6 +1857,10 @@ static inline void xs_reclassify_socket(int family, struct socket *sock)
 }
 #endif
 
+static void xs_dummy_data_receive_workfn(struct work_struct *work)
+{
+}
+
 static void xs_dummy_setup_socket(struct work_struct *work)
 {
 }
@@ -2664,6 +2685,7 @@ static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
 	}
 
 	new = container_of(xprt, struct sock_xprt, xprt);
+	mutex_init(&new->recv_mutex);
 	memcpy(&xprt->addr, args->dstaddr, args->addrlen);
 	xprt->addrlen = args->addrlen;
 	if (args->srcaddr)
@@ -2717,6 +2739,7 @@ static struct rpc_xprt *xs_setup_local(struct xprt_create *args)
 	xprt->ops = &xs_local_ops;
 	xprt->timeout = &xs_local_default_timeout;
 
+	INIT_WORK(&transport->recv_worker, xs_dummy_data_receive_workfn);
 	INIT_DELAYED_WORK(&transport->connect_worker,
 			xs_dummy_setup_socket);
 
@@ -2788,21 +2811,20 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 
 	xprt->timeout = &xs_udp_default_timeout;
 
+	INIT_WORK(&transport->recv_worker, xs_dummy_data_receive_workfn);
+	INIT_DELAYED_WORK(&transport->connect_worker, xs_udp_setup_socket);
+
 	switch (addr->sa_family) {
 	case AF_INET:
 		if (((struct sockaddr_in *)addr)->sin_port != htons(0))
 			xprt_set_bound(xprt);
 
-		INIT_DELAYED_WORK(&transport->connect_worker,
-					xs_udp_setup_socket);
 		xs_format_peer_addresses(xprt, "udp", RPCBIND_NETID_UDP);
 		break;
 	case AF_INET6:
 		if (((struct sockaddr_in6 *)addr)->sin6_port != htons(0))
 			xprt_set_bound(xprt);
 
-		INIT_DELAYED_WORK(&transport->connect_worker,
-					xs_udp_setup_socket);
 		xs_format_peer_addresses(xprt, "udp", RPCBIND_NETID_UDP6);
 		break;
 	default:
@@ -2867,21 +2889,20 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 	xprt->ops = &xs_tcp_ops;
 	xprt->timeout = &xs_tcp_default_timeout;
 
+	INIT_WORK(&transport->recv_worker, xs_tcp_data_receive_workfn);
+	INIT_DELAYED_WORK(&transport->connect_worker, xs_tcp_setup_socket);
+
 	switch (addr->sa_family) {
 	case AF_INET:
 		if (((struct sockaddr_in *)addr)->sin_port != htons(0))
 			xprt_set_bound(xprt);
 
-		INIT_DELAYED_WORK(&transport->connect_worker,
-					xs_tcp_setup_socket);
 		xs_format_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP);
 		break;
 	case AF_INET6:
 		if (((struct sockaddr_in6 *)addr)->sin6_port != htons(0))
 			xprt_set_bound(xprt);
 
-		INIT_DELAYED_WORK(&transport->connect_worker,
-					xs_tcp_setup_socket);
 		xs_format_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP6);
 		break;
 	default:
-- 
2.4.3


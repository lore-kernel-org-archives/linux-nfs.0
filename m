From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [RFC 04/11] nfsd41: sunrpc: Added rpc server-side backchannel handling
Date: Tue, 19 May 2009 20:00:21 -0700
Message-ID: <1242788428-18723-4-git-send-email-Ricardo.Labiaga@netapp.com>
References: <273FE88A07F5D445824060902F70034405CEB64D@SACMVEXC1-PRD.hq.netapp.com>
 <1242788428-18723-1-git-send-email-Ricardo.Labiaga@netapp.com>
 <1242788428-18723-2-git-send-email-Ricardo.Labiaga@netapp.com>
 <1242788428-18723-3-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>,
	Rahul Iyer <iyer@netapp.com>, Mike Sager <sager@netapp.com>,
	Marc Eshel <eshel@almaden.ibm.com>,
	Benny Halevy <bhalevy@panasas.com>,
	Andy Adamson <andros@netapp.com>,
	Alexandros Batsakis <batsakis@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50956 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755142AbZETDAb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 May 2009 23:00:31 -0400
In-Reply-To: <1242788428-18723-3-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Rahul Iyer <iyer@netapp.com>
Signed-off-by: Mike Sager <sager@netapp.com>
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>

When the call direction is a reply, copy the xid and call direction into the
req->rq_private_buf.head[0].iov_base otherwise rpc_verify_header returns
rpc_garbage.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[get rid of CONFIG_NFSD_V4_1]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>

[sunrpc: refactoring of svc_tcp_recvfrom]
Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 include/linux/sunrpc/clnt.h    |    1 +
 include/linux/sunrpc/svcsock.h |    1 +
 include/linux/sunrpc/xprt.h    |    2 +
 net/sunrpc/clnt.c              |    1 +
 net/sunrpc/svcsock.c           |  102 +++++++++++++--
 net/sunrpc/xprt.c              |   41 ++++++-
 net/sunrpc/xprtsock.c          |  278 +++++++++++++++++++++++++++++++++++++++-
 7 files changed, 405 insertions(+), 21 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index c39a210..cf9a8ec 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -110,6 +110,7 @@ struct rpc_create_args {
 	rpc_authflavor_t	authflavor;
 	unsigned long		flags;
 	char			*client_name;
+	struct svc_sock		*bc_sock;	/* NFSv4.1 backchannel */
 };
 
 /* Values for "flags" field */
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 8271631..19228f4 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -28,6 +28,7 @@ struct svc_sock {
 	/* private TCP part */
 	u32			sk_reclen;	/* length of record */
 	u32			sk_tcplen;	/* current read length */
+	struct rpc_xprt	       *sk_bc_xprt;	/* NFSv4.1 backchannel xprt */
 };
 
 /*
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 1758d9f..063a6a7 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -174,6 +174,7 @@ struct rpc_xprt {
 	spinlock_t		reserve_lock;	/* lock slot table */
 	u32			xid;		/* Next XID value to use */
 	struct rpc_task *	snd_task;	/* Task blocked in send */
+	struct svc_sock		*bc_sock;	/* NFSv4.1 backchannel */
 	struct list_head	recv;
 
 	struct {
@@ -197,6 +198,7 @@ struct xprt_create {
 	struct sockaddr *	srcaddr;	/* optional local address */
 	struct sockaddr *	dstaddr;	/* remote peer address */
 	size_t			addrlen;
+	struct svc_sock		*bc_sock;	/* NFSv4.1 backchannel */
 };
 
 struct xprt_class {
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 5abab09..3dc847f 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -266,6 +266,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 		.srcaddr = args->saddress,
 		.dstaddr = args->address,
 		.addrlen = args->addrsize,
+		.bc_sock = args->bc_sock,
 	};
 	char servername[48];
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index b739111..90c9a75 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -49,6 +49,7 @@
 #include <linux/sunrpc/msg_prot.h>
 #include <linux/sunrpc/svcsock.h>
 #include <linux/sunrpc/stats.h>
+#include <linux/sunrpc/xprt.h>
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
@@ -895,6 +896,57 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 	return -EAGAIN;
 }
 
+static int svc_process_calldir(struct svc_sock *svsk, struct svc_rqst *rqstp,
+			       struct rpc_rqst **reqpp, struct kvec *vec)
+{
+	struct rpc_rqst *req = NULL;
+	u32 *p;
+	u32 xid;
+	u32 calldir;
+	int len;
+
+	len = svc_recvfrom(rqstp, vec, 1, 8);
+	if (len < 0)
+		goto error;
+
+	p = (u32 *)rqstp->rq_arg.head[0].iov_base;
+	xid = *p++;
+	calldir = *p;
+
+	if (calldir == 0) {
+		/* REQUEST is the most common case */
+		vec[0] = rqstp->rq_arg.head[0];
+	} else {
+		/* REPLY */
+		if (svsk->sk_bc_xprt)
+			req = xprt_lookup_rqst(svsk->sk_bc_xprt, xid);
+
+		if (!req) {
+			printk(KERN_NOTICE
+				"%s: Got unrecognized reply: "
+				"calldir 0x%x sk_bc_xprt %p xid %08x\n",
+				__func__, ntohl(calldir),
+				svsk->sk_bc_xprt, xid);
+			vec[0] = rqstp->rq_arg.head[0];
+			goto out;
+		}
+
+		memcpy(&req->rq_private_buf, &req->rq_rcv_buf,
+		       sizeof(struct xdr_buf));
+		/* copy the xid and call direction */
+		memcpy(req->rq_private_buf.head[0].iov_base,
+		       rqstp->rq_arg.head[0].iov_base, 8);
+		vec[0] = req->rq_private_buf.head[0];
+	}
+ out:
+	vec[0].iov_base += 8;
+	vec[0].iov_len -= 8;
+	len = svsk->sk_reclen - 8;
+ error:
+	*reqpp = req;
+	return len;
+}
+
 /*
  * Receive data from a TCP socket.
  */
@@ -906,6 +958,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	int		len;
 	struct kvec *vec;
 	int pnum, vlen;
+	struct rpc_rqst *req = NULL;
 
 	dprintk("svc: tcp_recv %p data %d conn %d close %d\n",
 		svsk, test_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags),
@@ -919,9 +972,27 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	vec = rqstp->rq_vec;
 	vec[0] = rqstp->rq_arg.head[0];
 	vlen = PAGE_SIZE;
+
+	/*
+	 * We have enough data for the whole tcp record. Let's try and read the
+	 * first 8 bytes to get the xid and the call direction. We can use this
+	 * to figure out if this is a call or a reply to a callback. If
+	 * sk_reclen is < 8 (xid and calldir), then this is a malformed packet.
+	 * In that case, don't bother with the calldir and just read the data.
+	 * It will be rejected in svc_process.
+	 */
+	if (len >= 8) {
+		len = svc_process_calldir(svsk, rqstp, &req, vec);
+		if (len < 0)
+			goto err_again;
+		vlen -= 8;
+	}
+
 	pnum = 1;
 	while (vlen < len) {
-		vec[pnum].iov_base = page_address(rqstp->rq_pages[pnum]);
+		vec[pnum].iov_base = (req) ?
+			page_address(req->rq_private_buf.pages[pnum - 1]) :
+			page_address(rqstp->rq_pages[pnum]);
 		vec[pnum].iov_len = PAGE_SIZE;
 		pnum++;
 		vlen += PAGE_SIZE;
@@ -931,8 +1002,18 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	/* Now receive data */
 	len = svc_recvfrom(rqstp, vec, pnum, len);
 	if (len < 0)
-		goto error;
+		goto err_again;
+
+	/*
+	 * Account for the 8 bytes we read earlier
+	 */
+	len += 8;
 
+	if (req) {
+		xprt_complete_rqst(req->rq_task, len);
+		len = 0;
+		goto out;
+	}
 	dprintk("svc: TCP complete record (%d bytes)\n", len);
 	rqstp->rq_arg.len = len;
 	rqstp->rq_arg.page_base = 0;
@@ -946,6 +1027,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	rqstp->rq_xprt_ctxt   = NULL;
 	rqstp->rq_prot	      = IPPROTO_TCP;
 
+out:
 	/* Reset TCP read info */
 	svsk->sk_reclen = 0;
 	svsk->sk_tcplen = 0;
@@ -957,21 +1039,19 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 
 	return len;
 
- err_delete:
-	set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
-	return -EAGAIN;
-
- error:
+err_again:
 	if (len == -EAGAIN) {
 		dprintk("RPC: TCP recvfrom got EAGAIN\n");
 		svc_xprt_received(&svsk->sk_xprt);
-	} else {
+		return len;
+	}
+error:
+	if (len != -EAGAIN) {
 		printk(KERN_NOTICE "%s: recvfrom returned errno %d\n",
 		       svsk->sk_xprt.xpt_server->sv_name, -len);
-		goto err_delete;
+		set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
 	}
-
-	return len;
+	return -EAGAIN;
 }
 
 /*
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index a0bfe53..03f175e 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1015,6 +1015,27 @@ void xprt_release(struct rpc_task *task)
 	spin_unlock(&xprt->reserve_lock);
 }
 
+/*
+ * The autoclose function for the back channel
+ *
+ * The callback channel should never close the channel,
+ * let the forechannel do that.
+ */
+static void bc_autoclose(struct work_struct *work)
+{
+	return;
+}
+
+
+/*
+ * The autodisconnect routine for the back channel. We never disconnect
+ */
+static void
+bc_init_autodisconnect(unsigned long data)
+{
+	return;
+}
+
 /**
  * xprt_create_transport - create an RPC transport
  * @args: rpc transport creation arguments
@@ -1051,9 +1072,16 @@ found:
 
 	INIT_LIST_HEAD(&xprt->free);
 	INIT_LIST_HEAD(&xprt->recv);
-	INIT_WORK(&xprt->task_cleanup, xprt_autoclose);
-	setup_timer(&xprt->timer, xprt_init_autodisconnect,
-			(unsigned long)xprt);
+	if (args->bc_sock) {
+		INIT_WORK(&xprt->task_cleanup, bc_autoclose);
+		setup_timer(&xprt->timer, bc_init_autodisconnect,
+			    (unsigned long)xprt);
+	} else {
+		INIT_WORK(&xprt->task_cleanup, xprt_autoclose);
+		setup_timer(&xprt->timer, xprt_init_autodisconnect,
+			    (unsigned long)xprt);
+	}
+
 	xprt->last_used = jiffies;
 	xprt->cwnd = RPC_INITCWND;
 	xprt->bind_index = 0;
@@ -1073,6 +1101,13 @@ found:
 	dprintk("RPC:       created transport %p with %u slots\n", xprt,
 			xprt->max_reqs);
 
+	/*
+	 * Since we don't want connections for the backchannel, we set
+	 * the xprt status to connected
+	 */
+	if (args->bc_sock)
+		xprt_set_connected(xprt);
+
 	return xprt;
 }
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index d40ff50..067d205 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -32,6 +32,7 @@
 #include <linux/tcp.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/sched.h>
+#include <linux/sunrpc/svcsock.h>
 #include <linux/sunrpc/xprtsock.h>
 #include <linux/file.h>
 
@@ -1966,6 +1967,219 @@ static void xs_tcp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 			xprt->stat.bklog_u);
 }
 
+/*
+ * The connect worker for the backchannel
+ * This should never be called as we should never need to connect
+ */
+static void bc_connect_worker(struct work_struct *work)
+{
+	BUG();
+}
+
+/*
+ * The set_port routine of the rpc_xprt_ops. This is related to the portmapper
+ * and should never be called
+ */
+
+static void bc_set_port(struct rpc_xprt *xprt, unsigned short port)
+{
+	BUG();
+}
+
+/*
+ * The connect routine for the backchannel rpc_xprt ops
+ * Again, should never be called!
+ */
+
+static void bc_connect(struct rpc_task *task)
+{
+	BUG();
+}
+
+struct rpc_buffer {
+	size_t	len;
+	char	data[];
+};
+/*
+ * Allocate a bunch of pages for a scratch buffer for the rpc code. The reason
+ * we allocate pages instead doing a kmalloc like rpc_malloc is because we want
+ * to use the server side send routines.
+ */
+void *bc_malloc(struct rpc_task *task, size_t size)
+{
+	struct page *page;
+	struct rpc_buffer *buf;
+
+	BUG_ON(size > PAGE_SIZE - sizeof(struct rpc_buffer));
+	page = alloc_page(GFP_KERNEL);
+
+	if (!page)
+		return NULL;
+
+	buf = page_address(page);
+	buf->len = PAGE_SIZE;
+
+	return buf->data;
+}
+
+/*
+ * Free the space allocated in the bc_alloc routine
+ */
+void bc_free(void *buffer)
+{
+	struct rpc_buffer *buf;
+
+	if (!buffer)
+		return;
+
+	buf = container_of(buffer, struct rpc_buffer, data);
+	free_pages((unsigned long)buf, get_order(buf->len));
+}
+
+/*
+ * Use the svc_sock to send the callback. Must be called with svsk->sk_mutex
+ * held. Borrows heavily from svc_tcp_sendto and xs_tcp_semd_request.
+ */
+static int bc_sendto(struct rpc_rqst *req)
+{
+	int total_len;
+	int len;
+	int size;
+	int result;
+	struct xdr_buf *xbufp = &req->rq_snd_buf;
+	struct page **pages = xbufp->pages;
+	unsigned int flags = MSG_MORE;
+	unsigned int pglen = xbufp->page_len;
+	size_t base = xbufp->page_base;
+	struct rpc_xprt *xprt = req->rq_xprt;
+	struct sock_xprt *transport =
+				container_of(xprt, struct sock_xprt, xprt);
+	struct socket *sock = transport->sock;
+
+	total_len = xbufp->len;
+
+	/*
+	 * Set up the rpc header and record marker stuff
+	 */
+	xs_encode_tcp_record_marker(xbufp);
+
+	/*
+	 * The RPC message is divided into 3 pieces:
+	 * - The header: This is what most of the smaller RPC messages consist
+	 *   of. Often the whole message is in this.
+	 *
+	 *   - xdr->pages: This is a list of pages that contain data, for
+	 *   example in a write request or while using rpcsec gss
+	 *
+	 *   - The tail: This is the rest of the rpc message
+	 *
+	 *  First we send the header, then the pages and then finally the tail.
+	 *  The code borrows heavily from svc_sendto.
+	 */
+
+	/*
+	 * Send the head
+	 */
+	if (total_len == xbufp->head[0].iov_len)
+		flags = 0;
+
+	len = sock->ops->sendpage(sock, virt_to_page(xbufp->head[0].iov_base),
+			(unsigned long)xbufp->head[0].iov_base & ~PAGE_MASK,
+			xbufp->head[0].iov_len, flags);
+
+	if (len != xbufp->head[0].iov_len)
+		goto out;
+
+	/*
+	 * send page data
+	 *
+	 * Check the amount of data to be sent. If it is less than the
+	 * remaining page, then send it else send the current page
+	 */
+
+	size = PAGE_SIZE - base < pglen ? PAGE_SIZE - base : pglen;
+	while (pglen > 0) {
+		if (total_len == size)
+			flags = 0;
+		result = sock->ops->sendpage(sock, *pages, base, size, flags);
+		if (result > 0)
+			len += result;
+		if (result != size)
+			goto out;
+		total_len -= size;
+		pglen -= size;
+		size = PAGE_SIZE < pglen ? PAGE_SIZE : pglen;
+		base = 0;
+		pages++;
+	}
+	/*
+	 * send tail
+	 */
+	if (xbufp->tail[0].iov_len) {
+		result = sock->ops->sendpage(sock,
+			xbufp->tail[0].iov_base,
+			(unsigned long)xbufp->tail[0].iov_base & ~PAGE_MASK,
+			xbufp->tail[0].iov_len,
+			0);
+
+		if (result > 0)
+			len += result;
+	}
+out:
+	if (len != xbufp->len)
+		printk(KERN_NOTICE "Error sending entire callback!\n");
+
+	return len;
+}
+
+/*
+ * The send routine. Borrows from svc_send
+ */
+static int bc_send_request(struct rpc_task *task)
+{
+	struct rpc_rqst *req = task->tk_rqstp;
+	struct rpc_xprt *bc_xprt = req->rq_xprt;
+	struct svc_xprt	*xprt;
+	struct svc_sock         *svsk;
+	u32                     len;
+
+	dprintk("sending request with xid: %08x\n", ntohl(req->rq_xid));
+	/*
+	 * Get the server socket associated with this callback xprt
+	 */
+	svsk = bc_xprt->bc_sock;
+	xprt = &svsk->sk_xprt;
+
+	mutex_lock(&xprt->xpt_mutex);
+	if (test_bit(XPT_DEAD, &xprt->xpt_flags))
+		len = -ENOTCONN;
+	else
+		len = bc_sendto(req);
+	mutex_unlock(&xprt->xpt_mutex);
+
+	return 0;
+
+}
+
+/*
+ * The close routine. Since this is client initiated, we do nothing
+ */
+
+static void bc_close(struct rpc_xprt *xprt)
+{
+	return;
+}
+
+/*
+ * The xprt destroy routine. Again, because this connection is client
+ * initiated, we do nothing
+ */
+
+static void bc_destroy(struct rpc_xprt *xprt)
+{
+	return;
+}
+
 static struct rpc_xprt_ops xs_udp_ops = {
 	.set_buffer_size	= xs_udp_set_buffer_size,
 	.reserve_xprt		= xprt_reserve_xprt_cong,
@@ -1999,6 +2213,24 @@ static struct rpc_xprt_ops xs_tcp_ops = {
 	.print_stats		= xs_tcp_print_stats,
 };
 
+/*
+ * The rpc_xprt_ops for the server backchannel
+ */
+
+static struct rpc_xprt_ops bc_tcp_ops = {
+	.reserve_xprt		= xprt_reserve_xprt,
+	.release_xprt		= xprt_release_xprt,
+	.set_port		= bc_set_port,
+	.connect		= bc_connect,
+	.buf_alloc		= bc_malloc,
+	.buf_free		= bc_free,
+	.send_request		= bc_send_request,
+	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
+	.close			= bc_close,
+	.destroy		= bc_destroy,
+	.print_stats		= xs_tcp_print_stats,
+};
+
 static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
 				      unsigned int slot_table_size)
 {
@@ -2131,13 +2363,29 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 	xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
 	xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
 
-	xprt->bind_timeout = XS_BIND_TO;
-	xprt->connect_timeout = XS_TCP_CONN_TO;
-	xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
-	xprt->idle_timeout = XS_IDLE_DISC_TO;
+	if (args->bc_sock) {
+		/* backchannel */
+		xprt_set_bound(xprt);
+		INIT_DELAYED_WORK(&transport->connect_worker,
+				  bc_connect_worker);
+		xprt->bind_timeout = 0;
+		xprt->connect_timeout = 0;
+		xprt->reestablish_timeout = 0;
+		xprt->idle_timeout = (~0);
 
-	xprt->ops = &xs_tcp_ops;
-	xprt->timeout = &xs_tcp_default_timeout;
+		/*
+		 * The backchannel uses the same socket connection as the
+		 * forechannel
+		 */
+		xprt->bc_sock = args->bc_sock;
+		xprt->bc_sock->sk_bc_xprt = xprt;
+		transport->sock = xprt->bc_sock->sk_sock;
+		transport->inet = xprt->bc_sock->sk_sk;
+
+		xprt->ops = &bc_tcp_ops;
+
+		goto next;
+	}
 
 	switch (addr->sa_family) {
 	case AF_INET:
@@ -2145,13 +2393,29 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 			xprt_set_bound(xprt);
 
 		INIT_DELAYED_WORK(&transport->connect_worker, xs_tcp_connect_worker4);
-		xs_format_ipv4_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP);
 		break;
 	case AF_INET6:
 		if (((struct sockaddr_in6 *)addr)->sin6_port != htons(0))
 			xprt_set_bound(xprt);
 
 		INIT_DELAYED_WORK(&transport->connect_worker, xs_tcp_connect_worker6);
+		break;
+	}
+	xprt->bind_timeout = XS_BIND_TO;
+	xprt->connect_timeout = XS_TCP_CONN_TO;
+	xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
+	xprt->idle_timeout = XS_IDLE_DISC_TO;
+
+	xprt->ops = &xs_tcp_ops;
+
+next:
+	xprt->timeout = &xs_tcp_default_timeout;
+
+	switch (addr->sa_family) {
+	case AF_INET:
+		xs_format_ipv4_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP);
+		break;
+	case AF_INET6:
 		xs_format_ipv6_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP6);
 		break;
 	default:
-- 
1.5.4.3


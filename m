Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:33274 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932887AbbLGUnO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2015 15:43:14 -0500
Subject: [PATCH v3 6/6] xprtrdma: Add class for RDMA backwards direction
 transport
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 07 Dec 2015 15:43:13 -0500
Message-ID: <20151207204313.12988.41483.stgit@klimt.1015granger.net>
In-Reply-To: <20151207203851.12988.97804.stgit@klimt.1015granger.net>
References: <20151207203851.12988.97804.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To support the server-side of an NFSv4.1 backchannel on RDMA
connections, add a transport class that enables backward
direction messages on an existing forward channel connection.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/xprt.h                |    1 
 net/sunrpc/xprt.c                          |    1 
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  219 ++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |   14 +-
 net/sunrpc/xprtrdma/transport.c            |   31 +++-
 net/sunrpc/xprtrdma/xprt_rdma.h            |   11 +
 6 files changed, 263 insertions(+), 14 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 69ef5b3..7637ccd 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -85,6 +85,7 @@ struct rpc_rqst {
 	__u32 *			rq_buffer;	/* XDR encode buffer */
 	size_t			rq_callsize,
 				rq_rcvsize;
+	void *			rq_privdata; /* xprt-specific per-rqst data */
 	size_t			rq_xmit_bytes_sent;	/* total bytes sent */
 	size_t			rq_reply_bytes_recvd;	/* total reply bytes */
 							/* received */
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 2e98f4a..37edea6 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1425,3 +1425,4 @@ void xprt_put(struct rpc_xprt *xprt)
 	if (atomic_dec_and_test(&xprt->count))
 		xprt_destroy(xprt);
 }
+EXPORT_SYMBOL_GPL(xprt_put);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index 69dab71..3534e75 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -84,3 +84,222 @@ out_notfound:
 
 	goto out_unlock;
 }
+
+/* Server-side transport endpoint wants a whole page for its send
+ * buffer. The client RPC code constructs the RPC header in this
+ * buffer before it invokes ->send_request.
+ *
+ * Returns NULL if there was a temporary allocation failure.
+ */
+static void *
+xprt_rdma_bc_allocate(struct rpc_task *task, size_t size)
+{
+	struct rpc_rqst *rqst = task->tk_rqstp;
+	struct svc_rdma_op_ctxt *ctxt;
+	struct svcxprt_rdma *rdma;
+	struct svc_xprt *sxprt;
+	struct page *page;
+
+	/* Prevent an infinite loop: don't return NULL */
+	if (size > PAGE_SIZE)
+		WARN_ONCE(1, "svcrdma: bc buffer request too large (size %zu)\n",
+			  size);
+
+	page = alloc_page(RPCRDMA_DEF_GFP);
+	if (!page)
+		return NULL;
+
+	sxprt = rqst->rq_xprt->bc_xprt;
+	rdma = container_of(sxprt, struct svcxprt_rdma, sc_xprt);
+	ctxt = svc_rdma_get_context(rdma);
+	if (!ctxt) {
+		put_page(page);
+		return NULL;
+	}
+
+	rqst->rq_privdata = ctxt;
+	ctxt->pages[0] = page;
+	ctxt->count = 1;
+	return page_address(page);
+}
+
+static void
+xprt_rdma_bc_free(void *buffer)
+{
+	/* No-op: ctxt and page have already been freed. */
+}
+
+static int
+rpcrdma_bc_send_request(struct svcxprt_rdma *rdma, struct rpc_rqst *rqst)
+{
+	struct rpc_xprt *xprt = rqst->rq_xprt;
+	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
+	struct rpcrdma_msg *headerp = (struct rpcrdma_msg *)rqst->rq_buffer;
+	struct svc_rdma_op_ctxt *ctxt;
+	int rc;
+
+	/* Space in the send buffer for an RPC/RDMA header is reserved
+	 * via xprt->tsh_size */
+	headerp->rm_xid = rqst->rq_xid;
+	headerp->rm_vers = rpcrdma_version;
+	headerp->rm_credit = cpu_to_be32(r_xprt->rx_buf.rb_bc_max_requests);
+	headerp->rm_type = rdma_msg;
+	headerp->rm_body.rm_chunks[0] = xdr_zero;
+	headerp->rm_body.rm_chunks[1] = xdr_zero;
+	headerp->rm_body.rm_chunks[2] = xdr_zero;
+
+#ifdef SVCRDMA_BACKCHANNEL_DEBUG
+	pr_info("%s: %*ph\n", __func__, 64, rqst->rq_buffer);
+#endif
+
+	ctxt = (struct svc_rdma_op_ctxt *)rqst->rq_privdata;
+	rc = svc_rdma_bc_post_send(rdma, ctxt, &rqst->rq_snd_buf);
+	if (rc)
+		goto drop_connection;
+	return rc;
+
+drop_connection:
+	dprintk("svcrdma: failed to send bc call\n");
+	svc_rdma_put_context(ctxt, 1);
+	xprt_disconnect_done(xprt);
+	return -ENOTCONN;
+}
+
+/* Send an RPC call on the passive end of a transport
+ * connection.
+ */
+static int
+xprt_rdma_bc_send_request(struct rpc_task *task)
+{
+	struct rpc_rqst *rqst = task->tk_rqstp;
+	struct svc_xprt *sxprt = rqst->rq_xprt->bc_xprt;
+	struct svcxprt_rdma *rdma;
+	u32 len;
+
+	dprintk("svcrdma: sending bc call with xid: %08x\n",
+		be32_to_cpu(rqst->rq_xid));
+
+	if (!mutex_trylock(&sxprt->xpt_mutex)) {
+		rpc_sleep_on(&sxprt->xpt_bc_pending, task, NULL);
+		if (!mutex_trylock(&sxprt->xpt_mutex))
+			return -EAGAIN;
+		rpc_wake_up_queued_task(&sxprt->xpt_bc_pending, task);
+	}
+
+	len = -ENOTCONN;
+	rdma = container_of(sxprt, struct svcxprt_rdma, sc_xprt);
+	if (!test_bit(XPT_DEAD, &sxprt->xpt_flags))
+		len = rpcrdma_bc_send_request(rdma, rqst);
+
+	mutex_unlock(&sxprt->xpt_mutex);
+
+	if (len < 0)
+		return len;
+	return 0;
+}
+
+static void
+xprt_rdma_bc_close(struct rpc_xprt *xprt)
+{
+	dprintk("svcrdma: %s: xprt %p\n", __func__, xprt);
+}
+
+static void
+xprt_rdma_bc_put(struct rpc_xprt *xprt)
+{
+	dprintk("svcrdma: %s: xprt %p\n", __func__, xprt);
+
+	xprt_free(xprt);
+	module_put(THIS_MODULE);
+}
+
+static struct rpc_xprt_ops xprt_rdma_bc_procs = {
+	.reserve_xprt		= xprt_reserve_xprt_cong,
+	.release_xprt		= xprt_release_xprt_cong,
+	.alloc_slot		= xprt_alloc_slot,
+	.release_request	= xprt_release_rqst_cong,
+	.buf_alloc		= xprt_rdma_bc_allocate,
+	.buf_free		= xprt_rdma_bc_free,
+	.send_request		= xprt_rdma_bc_send_request,
+	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
+	.close			= xprt_rdma_bc_close,
+	.destroy		= xprt_rdma_bc_put,
+	.print_stats		= xprt_rdma_print_stats
+};
+
+static const struct rpc_timeout xprt_rdma_bc_timeout = {
+	.to_initval = 60 * HZ,
+	.to_maxval = 60 * HZ,
+};
+
+/* It shouldn't matter if the number of backchannel session slots
+ * doesn't match the number of RPC/RDMA credits. That just means
+ * one or the other will have extra slots that aren't used.
+ */
+static struct rpc_xprt *
+xprt_setup_rdma_bc(struct xprt_create *args)
+{
+	struct rpc_xprt *xprt;
+	struct rpcrdma_xprt *new_xprt;
+
+	if (args->addrlen > sizeof(xprt->addr)) {
+		dprintk("RPC:       %s: address too large\n", __func__);
+		return ERR_PTR(-EBADF);
+	}
+
+	xprt = xprt_alloc(args->net, sizeof(*new_xprt),
+			  RPCRDMA_MAX_BC_REQUESTS,
+			  RPCRDMA_MAX_BC_REQUESTS);
+	if (xprt == NULL) {
+		dprintk("RPC:       %s: couldn't allocate rpc_xprt\n",
+			__func__);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	xprt->timeout = &xprt_rdma_bc_timeout;
+	xprt_set_bound(xprt);
+	xprt_set_connected(xprt);
+	xprt->bind_timeout = RPCRDMA_BIND_TO;
+	xprt->reestablish_timeout = RPCRDMA_INIT_REEST_TO;
+	xprt->idle_timeout = RPCRDMA_IDLE_DISC_TO;
+
+	xprt->prot = XPRT_TRANSPORT_BC_RDMA;
+	xprt->tsh_size = RPCRDMA_HDRLEN_MIN / sizeof(__be32);
+	xprt->ops = &xprt_rdma_bc_procs;
+
+	memcpy(&xprt->addr, args->dstaddr, args->addrlen);
+	xprt->addrlen = args->addrlen;
+	xprt_rdma_format_addresses(xprt, (struct sockaddr *)&xprt->addr);
+	xprt->resvport = 0;
+
+	xprt->max_payload = xprt_rdma_max_inline_read;
+
+	new_xprt = rpcx_to_rdmax(xprt);
+	new_xprt->rx_buf.rb_bc_max_requests = xprt->max_reqs;
+
+	xprt_get(xprt);
+	args->bc_xprt->xpt_bc_xprt = xprt;
+	xprt->bc_xprt = args->bc_xprt;
+
+	if (!try_module_get(THIS_MODULE))
+		goto out_fail;
+
+	/* Final put for backchannel xprt is in __svc_rdma_free */
+	xprt_get(xprt);
+	return xprt;
+
+out_fail:
+	xprt_rdma_free_addresses(xprt);
+	args->bc_xprt->xpt_bc_xprt = NULL;
+	xprt_put(xprt);
+	xprt_free(xprt);
+	return ERR_PTR(-EINVAL);
+}
+
+struct xprt_class xprt_rdma_bc = {
+	.list			= LIST_HEAD_INIT(xprt_rdma_bc.list),
+	.name			= "rdma backchannel",
+	.owner			= THIS_MODULE,
+	.ident			= XPRT_TRANSPORT_BC_RDMA,
+	.setup			= xprt_setup_rdma_bc,
+};
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index ed5dd93..8aea4ad 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -1212,12 +1212,14 @@ static void __svc_rdma_free(struct work_struct *work)
 {
 	struct svcxprt_rdma *rdma =
 		container_of(work, struct svcxprt_rdma, sc_work);
-	dprintk("svcrdma: svc_rdma_free(%p)\n", rdma);
+	struct svc_xprt *xprt = &rdma->sc_xprt;
+
+	dprintk("svcrdma: %s(%p)\n", __func__, rdma);
 
 	/* We should only be called from kref_put */
-	if (atomic_read(&rdma->sc_xprt.xpt_ref.refcount) != 0)
+	if (atomic_read(&xprt->xpt_ref.refcount) != 0)
 		pr_err("svcrdma: sc_xprt still in use? (%d)\n",
-		       atomic_read(&rdma->sc_xprt.xpt_ref.refcount));
+		       atomic_read(&xprt->xpt_ref.refcount));
 
 	/*
 	 * Destroy queued, but not processed read completions. Note
@@ -1252,6 +1254,12 @@ static void __svc_rdma_free(struct work_struct *work)
 		pr_err("svcrdma: dma still in use? (%d)\n",
 		       atomic_read(&rdma->sc_dma_used));
 
+	/* Final put of backchannel client transport */
+	if (xprt->xpt_bc_xprt) {
+		xprt_put(xprt->xpt_bc_xprt);
+		xprt->xpt_bc_xprt = NULL;
+	}
+
 	/* De-allocate fastreg mr */
 	rdma_dealloc_frmr_q(rdma);
 
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 8c545f7..43d25f4 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -63,7 +63,7 @@
  */
 
 static unsigned int xprt_rdma_slot_table_entries = RPCRDMA_DEF_SLOT_TABLE;
-static unsigned int xprt_rdma_max_inline_read = RPCRDMA_DEF_INLINE;
+       unsigned int xprt_rdma_max_inline_read = RPCRDMA_DEF_INLINE;
 static unsigned int xprt_rdma_max_inline_write = RPCRDMA_DEF_INLINE;
 static unsigned int xprt_rdma_inline_write_padding;
 static unsigned int xprt_rdma_memreg_strategy = RPCRDMA_FRMR;
@@ -143,12 +143,8 @@ static struct ctl_table sunrpc_table[] = {
 
 #endif
 
-#define RPCRDMA_BIND_TO		(60U * HZ)
-#define RPCRDMA_INIT_REEST_TO	(5U * HZ)
-#define RPCRDMA_MAX_REEST_TO	(30U * HZ)
-#define RPCRDMA_IDLE_DISC_TO	(5U * 60 * HZ)
-
-static struct rpc_xprt_ops xprt_rdma_procs;	/* forward reference */
+static struct rpc_xprt_ops xprt_rdma_procs;
+extern struct xprt_class xprt_rdma_bc;
 
 static void
 xprt_rdma_format_addresses4(struct rpc_xprt *xprt, struct sockaddr *sap)
@@ -174,7 +170,7 @@ xprt_rdma_format_addresses6(struct rpc_xprt *xprt, struct sockaddr *sap)
 	xprt->address_strings[RPC_DISPLAY_NETID] = RPCBIND_NETID_RDMA6;
 }
 
-static void
+void
 xprt_rdma_format_addresses(struct rpc_xprt *xprt, struct sockaddr *sap)
 {
 	char buf[128];
@@ -203,7 +199,7 @@ xprt_rdma_format_addresses(struct rpc_xprt *xprt, struct sockaddr *sap)
 	xprt->address_strings[RPC_DISPLAY_PROTO] = "rdma";
 }
 
-static void
+void
 xprt_rdma_free_addresses(struct rpc_xprt *xprt)
 {
 	unsigned int i;
@@ -499,7 +495,7 @@ xprt_rdma_allocate(struct rpc_task *task, size_t size)
 	if (req == NULL)
 		return NULL;
 
-	flags = GFP_NOIO | __GFP_NOWARN;
+	flags = RPCRDMA_DEF_GFP;
 	if (RPC_IS_SWAPPER(task))
 		flags = __GFP_MEMALLOC | GFP_NOWAIT | __GFP_NOWARN;
 
@@ -639,7 +635,7 @@ drop_connection:
 	return -ENOTCONN;	/* implies disconnect */
 }
 
-static void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
+void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 {
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 	long idle_time = 0;
@@ -740,6 +736,11 @@ void xprt_rdma_cleanup(void)
 
 	rpcrdma_destroy_wq();
 	frwr_destroy_recovery_wq();
+
+	rc = xprt_unregister_transport(&xprt_rdma_bc);
+	if (rc)
+		dprintk("RPC:       %s: xprt_unregister(bc) returned %i\n",
+			__func__, rc);
 }
 
 int xprt_rdma_init(void)
@@ -763,6 +764,14 @@ int xprt_rdma_init(void)
 		return rc;
 	}
 
+	rc = xprt_register_transport(&xprt_rdma_bc);
+	if (rc) {
+		xprt_unregister_transport(&xprt_rdma);
+		rpcrdma_destroy_wq();
+		frwr_destroy_recovery_wq();
+		return rc;
+	}
+
 	dprintk("RPCRDMA Module Init, register RPC RDMA transport\n");
 
 	dprintk("Defaults:\n");
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 3895574..d83abbc 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -55,6 +55,11 @@
 #define RDMA_RESOLVE_TIMEOUT	(5000)	/* 5 seconds */
 #define RDMA_CONNECT_RETRY_MAX	(2)	/* retries if no listener backlog */
 
+#define RPCRDMA_BIND_TO		(60U * HZ)
+#define RPCRDMA_INIT_REEST_TO	(5U * HZ)
+#define RPCRDMA_MAX_REEST_TO	(30U * HZ)
+#define RPCRDMA_IDLE_DISC_TO	(5U * 60 * HZ)
+
 /*
  * Interface Adapter -- one per transport instance
  */
@@ -148,6 +153,8 @@ rdmab_to_msg(struct rpcrdma_regbuf *rb)
 	return (struct rpcrdma_msg *)rb->rg_base;
 }
 
+#define RPCRDMA_DEF_GFP		(GFP_NOIO | __GFP_NOWARN)
+
 /*
  * struct rpcrdma_rep -- this structure encapsulates state required to recv
  * and complete a reply, asychronously. It needs several pieces of
@@ -516,6 +523,10 @@ int rpcrdma_marshal_req(struct rpc_rqst *);
 
 /* RPC/RDMA module init - xprtrdma/transport.c
  */
+extern unsigned int xprt_rdma_max_inline_read;
+void xprt_rdma_format_addresses(struct rpc_xprt *xprt, struct sockaddr *sap);
+void xprt_rdma_free_addresses(struct rpc_xprt *xprt);
+void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq);
 int xprt_rdma_init(void);
 void xprt_rdma_cleanup(void);
 


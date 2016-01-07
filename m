Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:35482 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634AbcAGTuM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jan 2016 14:50:12 -0500
Subject: [PATCH v5 10/10] svcrdma: Add class for RDMA backwards direction
 transport
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org, dledford@redhat.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 07 Jan 2016 14:50:10 -0500
Message-ID: <20160107195010.2662.62075.stgit@klimt.1015granger.net>
In-Reply-To: <20160107194251.2662.88158.stgit@klimt.1015granger.net>
References: <20160107194251.2662.88158.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To support the server-side of an NFSv4.1 backchannel on RDMA
connections, add a transport class that enables backward
direction messages on an existing forward channel connection.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-by: Bruce Fields <bfields@fieldses.org>
---
 include/linux/sunrpc/svc_rdma.h            |    5 
 net/sunrpc/xprt.c                          |    1 
 net/sunrpc/xprtrdma/Makefile               |    2 
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  371 ++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |   52 ++++
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |   14 +
 net/sunrpc/xprtrdma/transport.c            |   30 +-
 net/sunrpc/xprtrdma/xprt_rdma.h            |   15 +
 8 files changed, 475 insertions(+), 15 deletions(-)
 create mode 100644 net/sunrpc/xprtrdma/svc_rdma_backchannel.c

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 9a2c418..b13513a 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -195,6 +195,11 @@ struct svcxprt_rdma {
 
 #define RPCSVC_MAXPAYLOAD_RDMA	RPCSVC_MAXPAYLOAD
 
+/* svc_rdma_backchannel.c */
+extern int svc_rdma_handle_bc_reply(struct rpc_xprt *xprt,
+				    struct rpcrdma_msg *rmsgp,
+				    struct xdr_buf *rcvbuf);
+
 /* svc_rdma_marshal.c */
 extern int svc_rdma_xdr_decode_req(struct rpcrdma_msg **, struct svc_rqst *);
 extern int svc_rdma_xdr_encode_error(struct svcxprt_rdma *,
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 2e98f4a..37edea6 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1425,3 +1425,4 @@ void xprt_put(struct rpc_xprt *xprt)
 	if (atomic_dec_and_test(&xprt->count))
 		xprt_destroy(xprt);
 }
+EXPORT_SYMBOL_GPL(xprt_put);
diff --git a/net/sunrpc/xprtrdma/Makefile b/net/sunrpc/xprtrdma/Makefile
index 33f99d3..dc9f3b5 100644
--- a/net/sunrpc/xprtrdma/Makefile
+++ b/net/sunrpc/xprtrdma/Makefile
@@ -2,7 +2,7 @@ obj-$(CONFIG_SUNRPC_XPRT_RDMA) += rpcrdma.o
 
 rpcrdma-y := transport.o rpc_rdma.o verbs.o \
 	fmr_ops.o frwr_ops.o physical_ops.o \
-	svc_rdma.o svc_rdma_transport.o \
+	svc_rdma.o svc_rdma_backchannel.o svc_rdma_transport.o \
 	svc_rdma_marshal.o svc_rdma_sendto.o svc_rdma_recvfrom.o \
 	module.o
 rpcrdma-$(CONFIG_SUNRPC_BACKCHANNEL) += backchannel.o
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
new file mode 100644
index 0000000..deff06a
--- /dev/null
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -0,0 +1,371 @@
+/*
+ * Copyright (c) 2015 Oracle.  All rights reserved.
+ *
+ * Support for backward direction RPCs on RPC/RDMA (server-side).
+ */
+
+#include <linux/sunrpc/svc_rdma.h>
+#include "xprt_rdma.h"
+
+#define RPCDBG_FACILITY	RPCDBG_SVCXPRT
+
+#undef SVCRDMA_BACKCHANNEL_DEBUG
+
+int svc_rdma_handle_bc_reply(struct rpc_xprt *xprt, struct rpcrdma_msg *rmsgp,
+			     struct xdr_buf *rcvbuf)
+{
+	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
+	struct kvec *dst, *src = &rcvbuf->head[0];
+	struct rpc_rqst *req;
+	unsigned long cwnd;
+	u32 credits;
+	size_t len;
+	__be32 xid;
+	__be32 *p;
+	int ret;
+
+	p = (__be32 *)src->iov_base;
+	len = src->iov_len;
+	xid = rmsgp->rm_xid;
+
+#ifdef SVCRDMA_BACKCHANNEL_DEBUG
+	pr_info("%s: xid=%08x, length=%zu\n",
+		__func__, be32_to_cpu(xid), len);
+	pr_info("%s: RPC/RDMA: %*ph\n",
+		__func__, (int)RPCRDMA_HDRLEN_MIN, rmsgp);
+	pr_info("%s:      RPC: %*ph\n",
+		__func__, (int)len, p);
+#endif
+
+	ret = -EAGAIN;
+	if (src->iov_len < 24)
+		goto out_shortreply;
+
+	spin_lock_bh(&xprt->transport_lock);
+	req = xprt_lookup_rqst(xprt, xid);
+	if (!req)
+		goto out_notfound;
+
+	dst = &req->rq_private_buf.head[0];
+	memcpy(&req->rq_private_buf, &req->rq_rcv_buf, sizeof(struct xdr_buf));
+	if (dst->iov_len < len)
+		goto out_unlock;
+	memcpy(dst->iov_base, p, len);
+
+	credits = be32_to_cpu(rmsgp->rm_credit);
+	if (credits == 0)
+		credits = 1;	/* don't deadlock */
+	else if (credits > r_xprt->rx_buf.rb_bc_max_requests)
+		credits = r_xprt->rx_buf.rb_bc_max_requests;
+
+	cwnd = xprt->cwnd;
+	xprt->cwnd = credits << RPC_CWNDSHIFT;
+	if (xprt->cwnd > cwnd)
+		xprt_release_rqst_cong(req->rq_task);
+
+	ret = 0;
+	xprt_complete_rqst(req->rq_task, rcvbuf->len);
+	rcvbuf->len = 0;
+
+out_unlock:
+	spin_unlock_bh(&xprt->transport_lock);
+out:
+	return ret;
+
+out_shortreply:
+	dprintk("svcrdma: short bc reply: xprt=%p, len=%zu\n",
+		xprt, src->iov_len);
+	goto out;
+
+out_notfound:
+	dprintk("svcrdma: unrecognized bc reply: xprt=%p, xid=%08x\n",
+		xprt, be32_to_cpu(xid));
+
+	goto out_unlock;
+}
+
+/* Send a backwards direction RPC call.
+ *
+ * Caller holds the connection's mutex and has already marshaled
+ * the RPC/RDMA request.
+ *
+ * This is similar to svc_rdma_reply, but takes an rpc_rqst
+ * instead, does not support chunks, and avoids blocking memory
+ * allocation.
+ *
+ * XXX: There is still an opportunity to block in svc_rdma_send()
+ * if there are no SQ entries to post the Send. This may occur if
+ * the adapter has a small maximum SQ depth.
+ */
+static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
+			      struct rpc_rqst *rqst)
+{
+	struct xdr_buf *sndbuf = &rqst->rq_snd_buf;
+	struct svc_rdma_op_ctxt *ctxt;
+	struct svc_rdma_req_map *vec;
+	struct ib_send_wr send_wr;
+	int ret;
+
+	vec = svc_rdma_get_req_map(rdma);
+	ret = svc_rdma_map_xdr(rdma, sndbuf, vec);
+	if (ret)
+		goto out_err;
+
+	/* Post a recv buffer to handle the reply for this request. */
+	ret = svc_rdma_post_recv(rdma, GFP_NOIO);
+	if (ret) {
+		pr_err("svcrdma: Failed to post bc receive buffer, err=%d.\n",
+		       ret);
+		pr_err("svcrdma: closing transport %p.\n", rdma);
+		set_bit(XPT_CLOSE, &rdma->sc_xprt.xpt_flags);
+		ret = -ENOTCONN;
+		goto out_err;
+	}
+
+	ctxt = svc_rdma_get_context(rdma);
+	ctxt->pages[0] = virt_to_page(rqst->rq_buffer);
+	ctxt->count = 1;
+
+	ctxt->wr_op = IB_WR_SEND;
+	ctxt->direction = DMA_TO_DEVICE;
+	ctxt->sge[0].lkey = rdma->sc_dma_lkey;
+	ctxt->sge[0].length = sndbuf->len;
+	ctxt->sge[0].addr =
+	    ib_dma_map_page(rdma->sc_cm_id->device, ctxt->pages[0], 0,
+			    sndbuf->len, DMA_TO_DEVICE);
+	if (ib_dma_mapping_error(rdma->sc_cm_id->device, ctxt->sge[0].addr)) {
+		ret = -EIO;
+		goto out_unmap;
+	}
+	atomic_inc(&rdma->sc_dma_used);
+
+	memset(&send_wr, 0, sizeof(send_wr));
+	send_wr.wr_id = (unsigned long)ctxt;
+	send_wr.sg_list = ctxt->sge;
+	send_wr.num_sge = 1;
+	send_wr.opcode = IB_WR_SEND;
+	send_wr.send_flags = IB_SEND_SIGNALED;
+
+	ret = svc_rdma_send(rdma, &send_wr);
+	if (ret) {
+		ret = -EIO;
+		goto out_unmap;
+	}
+
+out_err:
+	svc_rdma_put_req_map(rdma, vec);
+	dprintk("svcrdma: %s returns %d\n", __func__, ret);
+	return ret;
+
+out_unmap:
+	svc_rdma_unmap_dma(ctxt);
+	svc_rdma_put_context(ctxt, 1);
+	goto out_err;
+}
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
+	struct svc_xprt *sxprt = rqst->rq_xprt->bc_xprt;
+	struct svcxprt_rdma *rdma;
+	struct page *page;
+
+	rdma = container_of(sxprt, struct svcxprt_rdma, sc_xprt);
+
+	/* Prevent an infinite loop: try to make this case work */
+	if (size > PAGE_SIZE)
+		WARN_ONCE(1, "svcrdma: large bc buffer request (size %zu)\n",
+			  size);
+
+	page = alloc_page(RPCRDMA_DEF_GFP);
+	if (!page)
+		return NULL;
+
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
+	int rc;
+
+	/* Space in the send buffer for an RPC/RDMA header is reserved
+	 * via xprt->tsh_size.
+	 */
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
+	rc = svc_rdma_bc_sendto(rdma, rqst);
+	if (rc)
+		goto drop_connection;
+	return rc;
+
+drop_connection:
+	dprintk("svcrdma: failed to send bc call\n");
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
+	int ret;
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
+	ret = -ENOTCONN;
+	rdma = container_of(sxprt, struct svcxprt_rdma, sc_xprt);
+	if (!test_bit(XPT_DEAD, &sxprt->xpt_flags))
+		ret = rpcrdma_bc_send_request(rdma, rqst);
+
+	mutex_unlock(&sxprt->xpt_mutex);
+
+	if (ret < 0)
+		return ret;
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
+	if (!xprt) {
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
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index ff4f01e..3dfe464 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -567,6 +567,38 @@ static int rdma_read_complete(struct svc_rqst *rqstp,
 	return ret;
 }
 
+/* By convention, backchannel calls arrive via rdma_msg type
+ * messages, and never populate the chunk lists. This makes
+ * the RPC/RDMA header small and fixed in size, so it is
+ * straightforward to check the RPC header's direction field.
+ */
+static bool
+svc_rdma_is_backchannel_reply(struct svc_xprt *xprt, struct rpcrdma_msg *rmsgp)
+{
+	__be32 *p = (__be32 *)rmsgp;
+
+	if (!xprt->xpt_bc_xprt)
+		return false;
+
+	if (rmsgp->rm_type != rdma_msg)
+		return false;
+	if (rmsgp->rm_body.rm_chunks[0] != xdr_zero)
+		return false;
+	if (rmsgp->rm_body.rm_chunks[1] != xdr_zero)
+		return false;
+	if (rmsgp->rm_body.rm_chunks[2] != xdr_zero)
+		return false;
+
+	/* sanity */
+	if (p[7] != rmsgp->rm_xid)
+		return false;
+	/* call direction */
+	if (p[8] == cpu_to_be32(RPC_CALL))
+		return false;
+
+	return true;
+}
+
 /*
  * Set up the rqstp thread context to point to the RQ buffer. If
  * necessary, pull additional data from the client with an RDMA_READ
@@ -632,6 +664,15 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 		goto close_out;
 	}
 
+	if (svc_rdma_is_backchannel_reply(xprt, rmsgp)) {
+		ret = svc_rdma_handle_bc_reply(xprt->xpt_bc_xprt, rmsgp,
+					       &rqstp->rq_arg);
+		svc_rdma_put_context(ctxt, 0);
+		if (ret)
+			goto repost;
+		return ret;
+	}
+
 	/* Read read-list data. */
 	ret = rdma_read_chunks(rdma_xprt, rmsgp, rqstp, ctxt);
 	if (ret > 0) {
@@ -668,4 +709,15 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 	set_bit(XPT_CLOSE, &xprt->xpt_flags);
 defer:
 	return 0;
+
+repost:
+	ret = svc_rdma_post_recv(rdma_xprt, GFP_KERNEL);
+	if (ret) {
+		pr_err("svcrdma: could not post a receive buffer, err=%d.\n",
+		       ret);
+		pr_err("svcrdma: closing transport %p.\n", rdma_xprt);
+		set_bit(XPT_CLOSE, &rdma_xprt->sc_xprt.xpt_flags);
+		ret = -ENOTCONN;
+	}
+	return ret;
 }
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index af86dfe..7fd2395 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -1287,12 +1287,14 @@ static void __svc_rdma_free(struct work_struct *work)
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
@@ -1327,6 +1329,12 @@ static void __svc_rdma_free(struct work_struct *work)
 		pr_err("svcrdma: dma still in use? (%d)\n",
 		       atomic_read(&rdma->sc_dma_used));
 
+	/* Final put of backchannel client transport */
+	if (xprt->xpt_bc_xprt) {
+		xprt_put(xprt->xpt_bc_xprt);
+		xprt->xpt_bc_xprt = NULL;
+	}
+
 	rdma_dealloc_frmr_q(rdma);
 	svc_rdma_destroy_ctxts(rdma);
 	svc_rdma_destroy_maps(rdma);
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 8c545f7..5c7d235 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -63,7 +63,7 @@
  */
 
 static unsigned int xprt_rdma_slot_table_entries = RPCRDMA_DEF_SLOT_TABLE;
-static unsigned int xprt_rdma_max_inline_read = RPCRDMA_DEF_INLINE;
+unsigned int xprt_rdma_max_inline_read = RPCRDMA_DEF_INLINE;
 static unsigned int xprt_rdma_max_inline_write = RPCRDMA_DEF_INLINE;
 static unsigned int xprt_rdma_inline_write_padding;
 static unsigned int xprt_rdma_memreg_strategy = RPCRDMA_FRMR;
@@ -143,12 +143,7 @@ static struct ctl_table sunrpc_table[] = {
 
 #endif
 
-#define RPCRDMA_BIND_TO		(60U * HZ)
-#define RPCRDMA_INIT_REEST_TO	(5U * HZ)
-#define RPCRDMA_MAX_REEST_TO	(30U * HZ)
-#define RPCRDMA_IDLE_DISC_TO	(5U * 60 * HZ)
-
-static struct rpc_xprt_ops xprt_rdma_procs;	/* forward reference */
+static struct rpc_xprt_ops xprt_rdma_procs;	/*forward reference */
 
 static void
 xprt_rdma_format_addresses4(struct rpc_xprt *xprt, struct sockaddr *sap)
@@ -174,7 +169,7 @@ xprt_rdma_format_addresses6(struct rpc_xprt *xprt, struct sockaddr *sap)
 	xprt->address_strings[RPC_DISPLAY_NETID] = RPCBIND_NETID_RDMA6;
 }
 
-static void
+void
 xprt_rdma_format_addresses(struct rpc_xprt *xprt, struct sockaddr *sap)
 {
 	char buf[128];
@@ -203,7 +198,7 @@ xprt_rdma_format_addresses(struct rpc_xprt *xprt, struct sockaddr *sap)
 	xprt->address_strings[RPC_DISPLAY_PROTO] = "rdma";
 }
 
-static void
+void
 xprt_rdma_free_addresses(struct rpc_xprt *xprt)
 {
 	unsigned int i;
@@ -499,7 +494,7 @@ xprt_rdma_allocate(struct rpc_task *task, size_t size)
 	if (req == NULL)
 		return NULL;
 
-	flags = GFP_NOIO | __GFP_NOWARN;
+	flags = RPCRDMA_DEF_GFP;
 	if (RPC_IS_SWAPPER(task))
 		flags = __GFP_MEMALLOC | GFP_NOWAIT | __GFP_NOWARN;
 
@@ -639,7 +634,7 @@ drop_connection:
 	return -ENOTCONN;	/* implies disconnect */
 }
 
-static void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
+void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 {
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 	long idle_time = 0;
@@ -740,6 +735,11 @@ void xprt_rdma_cleanup(void)
 
 	rpcrdma_destroy_wq();
 	frwr_destroy_recovery_wq();
+
+	rc = xprt_unregister_transport(&xprt_rdma_bc);
+	if (rc)
+		dprintk("RPC:       %s: xprt_unregister(bc) returned %i\n",
+			__func__, rc);
 }
 
 int xprt_rdma_init(void)
@@ -763,6 +763,14 @@ int xprt_rdma_init(void)
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
index 72276c7..5a38236 100644
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
@@ -147,6 +152,8 @@ rdmab_to_msg(struct rpcrdma_regbuf *rb)
 	return (struct rpcrdma_msg *)rb->rg_base;
 }
 
+#define RPCRDMA_DEF_GFP		(GFP_NOIO | __GFP_NOWARN)
+
 /*
  * struct rpcrdma_rep -- this structure encapsulates state required to recv
  * and complete a reply, asychronously. It needs several pieces of
@@ -308,6 +315,8 @@ struct rpcrdma_buffer {
 	u32			rb_bc_srv_max_requests;
 	spinlock_t		rb_reqslock;	/* protect rb_allreqs */
 	struct list_head	rb_allreqs;
+
+	u32			rb_bc_max_requests;
 };
 #define rdmab_to_ia(b) (&container_of((b), struct rpcrdma_xprt, rx_buf)->rx_ia)
 
@@ -513,6 +522,10 @@ int rpcrdma_marshal_req(struct rpc_rqst *);
 
 /* RPC/RDMA module init - xprtrdma/transport.c
  */
+extern unsigned int xprt_rdma_max_inline_read;
+void xprt_rdma_format_addresses(struct rpc_xprt *xprt, struct sockaddr *sap);
+void xprt_rdma_free_addresses(struct rpc_xprt *xprt);
+void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq);
 int xprt_rdma_init(void);
 void xprt_rdma_cleanup(void);
 
@@ -528,4 +541,6 @@ void xprt_rdma_bc_free_rqst(struct rpc_rqst *);
 void xprt_rdma_bc_destroy(struct rpc_xprt *, unsigned int);
 #endif	/* CONFIG_SUNRPC_BACKCHANNEL */
 
+extern struct xprt_class xprt_rdma_bc;
+
 #endif				/* _LINUX_SUNRPC_XPRT_RDMA_H */


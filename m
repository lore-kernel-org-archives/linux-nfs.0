Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34603 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014AbcBHRZj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Feb 2016 12:25:39 -0500
Subject: [PATCH v2 9/9] svcrdma: Use new CQ API for RPC-over-RDMA server
 send CQs
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 08 Feb 2016 12:25:37 -0500
Message-ID: <20160208172537.13423.97332.stgit@klimt.1015granger.net>
In-Reply-To: <20160208171756.13423.14384.stgit@klimt.1015granger.net>
References: <20160208171756.13423.14384.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Calling ib_poll_cq() to sort through WCs during a completion is a
common pattern amongst RDMA consumers. Since commit 14d3a3b2498e
("IB: add a proper completion queue abstraction"), WC sorting can
be handled by the IB core.

By converting to this new API, svcrdma is made a better neighbor to
other RDMA consumers, as it allows the core to schedule the delivery
of completions more fairly amongst all active consumers.

This new API also aims each completion at a function that is
specific to the WR's opcode. Thus the ctxt->wr_op field and the
switch in process_context is replaced by a set of methods that
handle each completion type.

The server's rdma_stat_sq_poll and rdma_stat_sq_prod metrics are no
longer updated.

As a clean up, the cq_event_handler, the dto_tasklet, and all
associated locking is removed, as they are no longer referenced or
used.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h            |    9 +
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    4 
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |   15 +-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |   12 +
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |  259 +++++++++++-----------------
 5 files changed, 121 insertions(+), 178 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 7de9cbb..5275969 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -76,8 +76,9 @@ struct svc_rdma_op_ctxt {
 	int hdr_count;
 	struct xdr_buf arg;
 	struct ib_cqe cqe;
+	struct ib_cqe reg_cqe;
+	struct ib_cqe inv_cqe;
 	struct list_head dto_q;
-	enum ib_wr_opcode wr_op;
 	enum ib_wc_status wc_status;
 	u32 byte_len;
 	u32 position;
@@ -175,7 +176,6 @@ struct svcxprt_rdma {
 	struct work_struct   sc_work;
 };
 /* sc_flags */
-#define RDMAXPRT_SQ_PENDING	2
 #define RDMAXPRT_CONN_PENDING	3
 
 #define RPCRDMA_LISTEN_BACKLOG  10
@@ -232,6 +232,11 @@ extern void svc_rdma_send_error(struct svcxprt_rdma *, struct rpcrdma_msg *,
 				int);
 
 /* svc_rdma_transport.c */
+extern void svc_rdma_wc_send(struct ib_cq *, struct ib_wc *);
+extern void svc_rdma_wc_write(struct ib_cq *, struct ib_wc *);
+extern void svc_rdma_wc_reg(struct ib_cq *, struct ib_wc *);
+extern void svc_rdma_wc_read(struct ib_cq *, struct ib_wc *);
+extern void svc_rdma_wc_inv(struct ib_cq *, struct ib_wc *);
 extern int svc_rdma_send(struct svcxprt_rdma *, struct ib_send_wr *);
 extern int svc_rdma_post_recv(struct svcxprt_rdma *, gfp_t);
 extern int svc_rdma_repost_recv(struct svcxprt_rdma *, gfp_t);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index 4498eaf..64282ae 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -119,7 +119,6 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
 	ctxt->pages[0] = virt_to_page(rqst->rq_buffer);
 	ctxt->count = 1;
 
-	ctxt->wr_op = IB_WR_SEND;
 	ctxt->direction = DMA_TO_DEVICE;
 	ctxt->sge[0].lkey = rdma->sc_pd->local_dma_lkey;
 	ctxt->sge[0].length = sndbuf->len;
@@ -133,7 +132,8 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
 	atomic_inc(&rdma->sc_dma_used);
 
 	memset(&send_wr, 0, sizeof(send_wr));
-	send_wr.wr_id = (unsigned long)ctxt;
+	ctxt->cqe.done = svc_rdma_wc_send;
+	send_wr.wr_cqe = &ctxt->cqe;
 	send_wr.sg_list = ctxt->sge;
 	send_wr.num_sge = 1;
 	send_wr.opcode = IB_WR_SEND;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index d3718e9..2324fa3 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -180,9 +180,9 @@ int rdma_read_chunk_lcl(struct svcxprt_rdma *xprt,
 		clear_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags);
 
 	memset(&read_wr, 0, sizeof(read_wr));
-	read_wr.wr.wr_id = (unsigned long)ctxt;
+	ctxt->cqe.done = svc_rdma_wc_read;
+	read_wr.wr.wr_cqe = &ctxt->cqe;
 	read_wr.wr.opcode = IB_WR_RDMA_READ;
-	ctxt->wr_op = read_wr.wr.opcode;
 	read_wr.wr.send_flags = IB_SEND_SIGNALED;
 	read_wr.rkey = rs_handle;
 	read_wr.remote_addr = rs_offset;
@@ -299,8 +299,9 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
 	ctxt->read_hdr = head;
 
 	/* Prepare REG WR */
+	ctxt->reg_cqe.done = svc_rdma_wc_reg;
+	reg_wr.wr.wr_cqe = &ctxt->reg_cqe;
 	reg_wr.wr.opcode = IB_WR_REG_MR;
-	reg_wr.wr.wr_id = 0;
 	reg_wr.wr.send_flags = IB_SEND_SIGNALED;
 	reg_wr.wr.num_sge = 0;
 	reg_wr.mr = frmr->mr;
@@ -310,26 +311,26 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
 
 	/* Prepare RDMA_READ */
 	memset(&read_wr, 0, sizeof(read_wr));
+	ctxt->cqe.done = svc_rdma_wc_read;
+	read_wr.wr.wr_cqe = &ctxt->cqe;
 	read_wr.wr.send_flags = IB_SEND_SIGNALED;
 	read_wr.rkey = rs_handle;
 	read_wr.remote_addr = rs_offset;
 	read_wr.wr.sg_list = ctxt->sge;
 	read_wr.wr.num_sge = 1;
 	if (xprt->sc_dev_caps & SVCRDMA_DEVCAP_READ_W_INV) {
-		read_wr.wr.opcode = IB_WR_RDMA_READ_WITH_INV;
-		read_wr.wr.wr_id = (unsigned long)ctxt;
 		read_wr.wr.ex.invalidate_rkey = ctxt->frmr->mr->lkey;
 	} else {
 		read_wr.wr.opcode = IB_WR_RDMA_READ;
 		read_wr.wr.next = &inv_wr;
 		/* Prepare invalidate */
 		memset(&inv_wr, 0, sizeof(inv_wr));
-		inv_wr.wr_id = (unsigned long)ctxt;
+		ctxt->inv_cqe.done = svc_rdma_wc_inv;
+		inv_wr.wr_cqe = &ctxt->inv_cqe;
 		inv_wr.opcode = IB_WR_LOCAL_INV;
 		inv_wr.send_flags = IB_SEND_SIGNALED | IB_SEND_FENCE;
 		inv_wr.ex.invalidate_rkey = frmr->mr->lkey;
 	}
-	ctxt->wr_op = read_wr.wr.opcode;
 
 	/* Post the chain */
 	ret = svc_rdma_send(xprt, &reg_wr.wr);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 73793dd..751af2d 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -281,8 +281,8 @@ static int send_write(struct svcxprt_rdma *xprt, struct svc_rqst *rqstp,
 
 	/* Prepare WRITE WR */
 	memset(&write_wr, 0, sizeof write_wr);
-	ctxt->wr_op = IB_WR_RDMA_WRITE;
-	write_wr.wr.wr_id = (unsigned long)ctxt;
+	ctxt->cqe.done = svc_rdma_wc_write;
+	write_wr.wr.wr_cqe = &ctxt->cqe;
 	write_wr.wr.sg_list = &sge[0];
 	write_wr.wr.num_sge = sge_no;
 	write_wr.wr.opcode = IB_WR_RDMA_WRITE;
@@ -538,8 +538,8 @@ static int send_reply(struct svcxprt_rdma *rdma,
 		goto err;
 	}
 	memset(&send_wr, 0, sizeof send_wr);
-	ctxt->wr_op = IB_WR_SEND;
-	send_wr.wr_id = (unsigned long)ctxt;
+	ctxt->cqe.done = svc_rdma_wc_send;
+	send_wr.wr_cqe = &ctxt->cqe;
 	send_wr.sg_list = ctxt->sge;
 	send_wr.num_sge = sge_no;
 	send_wr.opcode = IB_WR_SEND;
@@ -685,8 +685,8 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
 
 	/* Prepare SEND WR */
 	memset(&err_wr, 0, sizeof err_wr);
-	ctxt->wr_op = IB_WR_SEND;
-	err_wr.wr_id = (unsigned long)ctxt;
+	ctxt->cqe.done = svc_rdma_wc_send;
+	err_wr.wr_cqe = &ctxt->cqe;
 	err_wr.sg_list = ctxt->sge;
 	err_wr.num_sge = 1;
 	err_wr.opcode = IB_WR_SEND;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index fed3827..7bf3304 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -63,16 +63,10 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
 					int flags);
 static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt);
 static void svc_rdma_release_rqst(struct svc_rqst *);
-static void dto_tasklet_func(unsigned long data);
 static void svc_rdma_detach(struct svc_xprt *xprt);
 static void svc_rdma_free(struct svc_xprt *xprt);
 static int svc_rdma_has_wspace(struct svc_xprt *xprt);
 static int svc_rdma_secure_port(struct svc_rqst *);
-static void sq_cq_reap(struct svcxprt_rdma *xprt);
-
-static DECLARE_TASKLET(dto_tasklet, dto_tasklet_func, 0UL);
-static DEFINE_SPINLOCK(dto_lock);
-static LIST_HEAD(dto_xprt_q);
 
 static struct svc_xprt_ops svc_rdma_ops = {
 	.xpo_create = svc_rdma_create,
@@ -351,15 +345,6 @@ static void svc_rdma_destroy_maps(struct svcxprt_rdma *xprt)
 	}
 }
 
-/* ib_cq event handler */
-static void cq_event_handler(struct ib_event *event, void *context)
-{
-	struct svc_xprt *xprt = context;
-	dprintk("svcrdma: received CQ event %s (%d), context=%p\n",
-		ib_event_msg(event->event), event->event, context);
-	set_bit(XPT_CLOSE, &xprt->xpt_flags);
-}
-
 /* QP event handler */
 static void qp_event_handler(struct ib_event *event, void *context)
 {
@@ -391,35 +376,6 @@ static void qp_event_handler(struct ib_event *event, void *context)
 	}
 }
 
-/*
- * Data Transfer Operation Tasklet
- *
- * Walks a list of transports with I/O pending, removing entries as
- * they are added to the server's I/O pending list. Two bits indicate
- * if SQ, RQ, or both have I/O pending. The dto_lock is an irqsave
- * spinlock that serializes access to the transport list with the RQ
- * and SQ interrupt handlers.
- */
-static void dto_tasklet_func(unsigned long data)
-{
-	struct svcxprt_rdma *xprt;
-	unsigned long flags;
-
-	spin_lock_irqsave(&dto_lock, flags);
-	while (!list_empty(&dto_xprt_q)) {
-		xprt = list_entry(dto_xprt_q.next,
-				  struct svcxprt_rdma, sc_dto_q);
-		list_del_init(&xprt->sc_dto_q);
-		spin_unlock_irqrestore(&dto_lock, flags);
-
-		sq_cq_reap(xprt);
-
-		svc_xprt_put(&xprt->sc_xprt);
-		spin_lock_irqsave(&dto_lock, flags);
-	}
-	spin_unlock_irqrestore(&dto_lock, flags);
-}
-
 /**
  * svc_rdma_wc_receive - Invoked by RDMA provider for each polled Receive WC
  * @cq:        completion queue
@@ -465,132 +421,127 @@ out:
 	svc_xprt_put(&xprt->sc_xprt);
 }
 
-/*
- * Process a completion context
- */
-static void process_context(struct svcxprt_rdma *xprt,
-			    struct svc_rdma_op_ctxt *ctxt)
+static void svc_rdma_send_wc_common(struct svcxprt_rdma *xprt,
+				    struct ib_wc *wc,
+				    const char *opname)
 {
-	struct svc_rdma_op_ctxt *read_hdr;
-	int free_pages = 0;
-
-	svc_rdma_unmap_dma(ctxt);
-
-	switch (ctxt->wr_op) {
-	case IB_WR_SEND:
-		free_pages = 1;
-		break;
+	if (wc->status != IB_WC_SUCCESS)
+		goto err;
 
-	case IB_WR_RDMA_WRITE:
-		break;
+out:
+	atomic_dec(&xprt->sc_sq_count);
+	wake_up(&xprt->sc_send_wait);
+	return;
 
-	case IB_WR_RDMA_READ:
-	case IB_WR_RDMA_READ_WITH_INV:
-		svc_rdma_put_frmr(xprt, ctxt->frmr);
+err:
+	set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
+	if (wc->status != IB_WC_WR_FLUSH_ERR)
+		pr_err("svcrdma: %s: %s (%u/0x%x)\n",
+		       opname, ib_wc_status_msg(wc->status),
+		       wc->status, wc->vendor_err);
+	goto out;
+}
 
-		if (!test_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags))
-			break;
+static void svc_rdma_send_wc_common_put(struct ib_cq *cq, struct ib_wc *wc,
+					const char *opname)
+{
+	struct svcxprt_rdma *xprt = cq->cq_context;
 
-		read_hdr = ctxt->read_hdr;
-		svc_rdma_put_context(ctxt, 0);
+	svc_rdma_send_wc_common(xprt, wc, opname);
+	svc_xprt_put(&xprt->sc_xprt);
+}
 
-		spin_lock_bh(&xprt->sc_rq_dto_lock);
-		set_bit(XPT_DATA, &xprt->sc_xprt.xpt_flags);
-		list_add_tail(&read_hdr->dto_q,
-			      &xprt->sc_read_complete_q);
-		spin_unlock_bh(&xprt->sc_rq_dto_lock);
-		svc_xprt_enqueue(&xprt->sc_xprt);
-		return;
+/**
+ * svc_rdma_wc_send - Invoked by RDMA provider for each polled Send WC
+ * @cq:        completion queue
+ * @wc:        completed WR
+ *
+ */
+void svc_rdma_wc_send(struct ib_cq *cq, struct ib_wc *wc)
+{
+	struct ib_cqe *cqe = wc->wr_cqe;
+	struct svc_rdma_op_ctxt *ctxt;
 
-	default:
-		dprintk("svcrdma: unexpected completion opcode=%d\n",
-			ctxt->wr_op);
-		break;
-	}
+	svc_rdma_send_wc_common_put(cq, wc, "send");
 
-	svc_rdma_put_context(ctxt, free_pages);
+	ctxt = container_of(cqe, struct svc_rdma_op_ctxt, cqe);
+	svc_rdma_unmap_dma(ctxt);
+	svc_rdma_put_context(ctxt, 1);
 }
 
-/*
- * Send Queue Completion Handler - potentially called on interrupt context.
+/**
+ * svc_rdma_wc_write - Invoked by RDMA provider for each polled Write WC
+ * @cq:        completion queue
+ * @wc:        completed WR
  *
- * Note that caller must hold a transport reference.
  */
-static void sq_cq_reap(struct svcxprt_rdma *xprt)
+void svc_rdma_wc_write(struct ib_cq *cq, struct ib_wc *wc)
 {
-	struct svc_rdma_op_ctxt *ctxt = NULL;
-	struct ib_wc wc_a[6];
-	struct ib_wc *wc;
-	struct ib_cq *cq = xprt->sc_sq_cq;
-	int ret;
+	struct ib_cqe *cqe = wc->wr_cqe;
+	struct svc_rdma_op_ctxt *ctxt;
 
-	memset(wc_a, 0, sizeof(wc_a));
+	svc_rdma_send_wc_common_put(cq, wc, "write");
 
-	if (!test_and_clear_bit(RDMAXPRT_SQ_PENDING, &xprt->sc_flags))
-		return;
+	ctxt = container_of(cqe, struct svc_rdma_op_ctxt, cqe);
+	svc_rdma_unmap_dma(ctxt);
+	svc_rdma_put_context(ctxt, 0);
+}
 
-	ib_req_notify_cq(xprt->sc_sq_cq, IB_CQ_NEXT_COMP);
-	atomic_inc(&rdma_stat_sq_poll);
-	while ((ret = ib_poll_cq(cq, ARRAY_SIZE(wc_a), wc_a)) > 0) {
-		int i;
+/**
+ * svc_rdma_wc_reg - Invoked by RDMA provider for each polled FASTREG WC
+ * @cq:        completion queue
+ * @wc:        completed WR
+ *
+ */
+void svc_rdma_wc_reg(struct ib_cq *cq, struct ib_wc *wc)
+{
+	svc_rdma_send_wc_common_put(cq, wc, "fastreg");
+}
 
-		for (i = 0; i < ret; i++) {
-			wc = &wc_a[i];
-			if (wc->status != IB_WC_SUCCESS) {
-				dprintk("svcrdma: sq wc err status %s (%d)\n",
-					ib_wc_status_msg(wc->status),
-					wc->status);
+/**
+ * svc_rdma_wc_read - Invoked by RDMA provider for each polled Read WC
+ * @cq:        completion queue
+ * @wc:        completed WR
+ *
+ */
+void svc_rdma_wc_read(struct ib_cq *cq, struct ib_wc *wc)
+{
+	struct svcxprt_rdma *xprt = cq->cq_context;
+	struct ib_cqe *cqe = wc->wr_cqe;
+	struct svc_rdma_op_ctxt *ctxt;
 
-				/* Close the transport */
-				set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
-			}
+	svc_rdma_send_wc_common(xprt, wc, "read");
 
-			/* Decrement used SQ WR count */
-			atomic_dec(&xprt->sc_sq_count);
-			wake_up(&xprt->sc_send_wait);
+	ctxt = container_of(cqe, struct svc_rdma_op_ctxt, cqe);
+	svc_rdma_unmap_dma(ctxt);
+	svc_rdma_put_frmr(xprt, ctxt->frmr);
 
-			ctxt = (struct svc_rdma_op_ctxt *)
-				(unsigned long)wc->wr_id;
-			if (ctxt)
-				process_context(xprt, ctxt);
+	if (test_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags)) {
+		struct svc_rdma_op_ctxt *read_hdr;
 
-			svc_xprt_put(&xprt->sc_xprt);
-		}
+		read_hdr = ctxt->read_hdr;
+		spin_lock(&xprt->sc_rq_dto_lock);
+		list_add_tail(&read_hdr->dto_q,
+			      &xprt->sc_read_complete_q);
+		spin_unlock(&xprt->sc_rq_dto_lock);
+
+		set_bit(XPT_DATA, &xprt->sc_xprt.xpt_flags);
+		svc_xprt_enqueue(&xprt->sc_xprt);
 	}
 
-	if (ctxt)
-		atomic_inc(&rdma_stat_sq_prod);
+	svc_rdma_put_context(ctxt, 0);
+	svc_xprt_put(&xprt->sc_xprt);
 }
 
-static void sq_comp_handler(struct ib_cq *cq, void *cq_context)
+/**
+ * svc_rdma_wc_inv - Invoked by RDMA provider for each polled LOCAL_INV WC
+ * @cq:        completion queue
+ * @wc:        completed WR
+ *
+ */
+void svc_rdma_wc_inv(struct ib_cq *cq, struct ib_wc *wc)
 {
-	struct svcxprt_rdma *xprt = cq_context;
-	unsigned long flags;
-
-	/* Guard against unconditional flush call for destroyed QP */
-	if (atomic_read(&xprt->sc_xprt.xpt_ref.refcount)==0)
-		return;
-
-	/*
-	 * Set the bit regardless of whether or not it's on the list
-	 * because it may be on the list already due to an RQ
-	 * completion.
-	 */
-	set_bit(RDMAXPRT_SQ_PENDING, &xprt->sc_flags);
-
-	/*
-	 * If this transport is not already on the DTO transport queue,
-	 * add it
-	 */
-	spin_lock_irqsave(&dto_lock, flags);
-	if (list_empty(&xprt->sc_dto_q)) {
-		svc_xprt_get(&xprt->sc_xprt);
-		list_add_tail(&xprt->sc_dto_q, &dto_xprt_q);
-	}
-	spin_unlock_irqrestore(&dto_lock, flags);
-
-	/* Tasklet does all the work to avoid irqsave locks. */
-	tasklet_schedule(&dto_tasklet);
+	svc_rdma_send_wc_common_put(cq, wc, "localInv");
 }
 
 static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
@@ -981,7 +932,6 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	struct svcxprt_rdma *listen_rdma;
 	struct svcxprt_rdma *newxprt = NULL;
 	struct rdma_conn_param conn_param;
-	struct ib_cq_init_attr cq_attr = {};
 	struct ib_qp_init_attr qp_attr;
 	struct ib_device *dev;
 	unsigned int i;
@@ -1039,12 +989,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 		dprintk("svcrdma: error creating PD for connect request\n");
 		goto errout;
 	}
-	cq_attr.cqe = newxprt->sc_sq_depth;
-	newxprt->sc_sq_cq = ib_create_cq(dev,
-					 sq_comp_handler,
-					 cq_event_handler,
-					 newxprt,
-					 &cq_attr);
+	newxprt->sc_sq_cq = ib_alloc_cq(dev, newxprt, newxprt->sc_sq_depth,
+					0, IB_POLL_SOFTIRQ);
 	if (IS_ERR(newxprt->sc_sq_cq)) {
 		dprintk("svcrdma: error creating SQ CQ for connect request\n");
 		goto errout;
@@ -1139,12 +1085,6 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	/* Swap out the handler */
 	newxprt->sc_cm_id->event_handler = rdma_cma_handler;
 
-	/*
-	 * Arm the CQs for the SQ and RQ before accepting so we can't
-	 * miss the first message
-	 */
-	ib_req_notify_cq(newxprt->sc_sq_cq, IB_CQ_NEXT_COMP);
-
 	/* Accept Connection */
 	set_bit(RDMAXPRT_CONN_PENDING, &newxprt->sc_flags);
 	memset(&conn_param, 0, sizeof conn_param);
@@ -1284,7 +1224,7 @@ static void __svc_rdma_free(struct work_struct *work)
 		ib_destroy_qp(rdma->sc_qp);
 
 	if (rdma->sc_sq_cq && !IS_ERR(rdma->sc_sq_cq))
-		ib_destroy_cq(rdma->sc_sq_cq);
+		ib_free_cq(rdma->sc_sq_cq);
 
 	if (rdma->sc_rq_cq && !IS_ERR(rdma->sc_rq_cq))
 		ib_free_cq(rdma->sc_rq_cq);
@@ -1348,9 +1288,6 @@ int svc_rdma_send(struct svcxprt_rdma *xprt, struct ib_send_wr *wr)
 			spin_unlock_bh(&xprt->sc_lock);
 			atomic_inc(&rdma_stat_sq_starve);
 
-			/* See if we can opportunistically reap SQ WR to make room */
-			sq_cq_reap(xprt);
-
 			/* Wait until SQ WR available if SQ still full */
 			wait_event(xprt->sc_send_wait,
 				   atomic_read(&xprt->sc_sq_count) <


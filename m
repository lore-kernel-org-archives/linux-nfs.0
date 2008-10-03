From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 04/12] svcrdma: Add a service to register a Fast Reg MR with the device
Date: Fri,  3 Oct 2008 16:33:41 -0500
Message-ID: <1223069629-5267-5-git-send-email-tom@opengridcomputing.com>
References: <1223069629-5267-1-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-2-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-3-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-4-git-send-email-tom@opengridcomputing.com>
Cc: thomas.talpey@netapp.com, linux-nfs@vger.kernel.org,
	Tom Tucker <tom@opengridcomputing.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:40978 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753397AbYJCVdu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Oct 2008 17:33:50 -0400
In-Reply-To: <1223069629-5267-4-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fast Reg MR introduces a new WR type. Add a service to register the
region with the adapter and update the completion handling to support
completions with a NULL WR context.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

---
 include/linux/sunrpc/svc_rdma.h          |    1 +
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  111 ++++++++++++++++++++---------
 2 files changed, 77 insertions(+), 35 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 3425268..1402d19 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -214,6 +214,7 @@ extern struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *);
 extern void svc_rdma_put_context(struct svc_rdma_op_ctxt *, int);
 extern struct svc_rdma_req_map *svc_rdma_get_req_map(void);
 extern void svc_rdma_put_req_map(struct svc_rdma_req_map *);
+extern int svc_rdma_fastreg(struct svcxprt_rdma *, struct svc_rdma_fastreg_mr *);
 extern struct svc_rdma_fastreg_mr *svc_rdma_get_frmr(struct svcxprt_rdma *);
 extern void svc_rdma_put_frmr(struct svcxprt_rdma *,
 			      struct svc_rdma_fastreg_mr *);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 5918285..4b70282 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -326,6 +326,45 @@ static void rq_cq_reap(struct svcxprt_rdma *xprt)
 }
 
 /*
+ * Processs a completion context
+ */
+static void process_context(struct svcxprt_rdma *xprt,
+			    struct svc_rdma_op_ctxt *ctxt)
+{
+	svc_rdma_unmap_dma(ctxt);
+
+	switch (ctxt->wr_op) {
+	case IB_WR_SEND:
+		svc_rdma_put_context(ctxt, 1);
+		break;
+
+	case IB_WR_RDMA_WRITE:
+		svc_rdma_put_context(ctxt, 0);
+		break;
+
+	case IB_WR_RDMA_READ:
+		if (test_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags)) {
+			struct svc_rdma_op_ctxt *read_hdr = ctxt->read_hdr;
+			BUG_ON(!read_hdr);
+			spin_lock_bh(&xprt->sc_rq_dto_lock);
+			set_bit(XPT_DATA, &xprt->sc_xprt.xpt_flags);
+			list_add_tail(&read_hdr->dto_q,
+				      &xprt->sc_read_complete_q);
+			spin_unlock_bh(&xprt->sc_rq_dto_lock);
+			svc_xprt_enqueue(&xprt->sc_xprt);
+		}
+		svc_rdma_put_context(ctxt, 0);
+		break;
+
+	default:
+		printk(KERN_ERR "svcrdma: unexpected completion type, "
+		       "opcode=%d\n",
+		       ctxt->wr_op);
+		break;
+	}
+}
+
+/*
  * Send Queue Completion Handler - potentially called on interrupt context.
  *
  * Note that caller must hold a transport reference.
@@ -337,17 +376,12 @@ static void sq_cq_reap(struct svcxprt_rdma *xprt)
 	struct ib_cq *cq = xprt->sc_sq_cq;
 	int ret;
 
-
 	if (!test_and_clear_bit(RDMAXPRT_SQ_PENDING, &xprt->sc_flags))
 		return;
 
 	ib_req_notify_cq(xprt->sc_sq_cq, IB_CQ_NEXT_COMP);
 	atomic_inc(&rdma_stat_sq_poll);
 	while ((ret = ib_poll_cq(cq, 1, &wc)) > 0) {
-		ctxt = (struct svc_rdma_op_ctxt *)(unsigned long)wc.wr_id;
-		xprt = ctxt->xprt;
-
-		svc_rdma_unmap_dma(ctxt);
 		if (wc.status != IB_WC_SUCCESS)
 			/* Close the transport */
 			set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
@@ -356,35 +390,10 @@ static void sq_cq_reap(struct svcxprt_rdma *xprt)
 		atomic_dec(&xprt->sc_sq_count);
 		wake_up(&xprt->sc_send_wait);
 
-		switch (ctxt->wr_op) {
-		case IB_WR_SEND:
-			svc_rdma_put_context(ctxt, 1);
-			break;
-
-		case IB_WR_RDMA_WRITE:
-			svc_rdma_put_context(ctxt, 0);
-			break;
-
-		case IB_WR_RDMA_READ:
-			if (test_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags)) {
-				struct svc_rdma_op_ctxt *read_hdr = ctxt->read_hdr;
-				BUG_ON(!read_hdr);
-				spin_lock_bh(&xprt->sc_rq_dto_lock);
-				set_bit(XPT_DATA, &xprt->sc_xprt.xpt_flags);
-				list_add_tail(&read_hdr->dto_q,
-					      &xprt->sc_read_complete_q);
-				spin_unlock_bh(&xprt->sc_rq_dto_lock);
-				svc_xprt_enqueue(&xprt->sc_xprt);
-			}
-			svc_rdma_put_context(ctxt, 0);
-			break;
+		ctxt = (struct svc_rdma_op_ctxt *)(unsigned long)wc.wr_id;
+		if (ctxt)
+			process_context(xprt, ctxt);
 
-		default:
-			printk(KERN_ERR "svcrdma: unexpected completion type, "
-			       "opcode=%d, status=%d\n",
-			       wc.opcode, wc.status);
-			break;
-		}
 		svc_xprt_put(&xprt->sc_xprt);
 	}
 
@@ -1190,6 +1199,40 @@ static int svc_rdma_has_wspace(struct svc_xprt *xprt)
 	return 1;
 }
 
+/*
+ * Attempt to register the kvec representing the RPC memory with the
+ * device.
+ *
+ * Returns:
+ *  NULL : The device does not support fastreg or there were no more
+ *         fastreg mr.
+ *  frmr : The kvec register request was successfully posted.
+ *    <0 : An error was encountered attempting to register the kvec.
+ */
+int svc_rdma_fastreg(struct svcxprt_rdma *xprt,
+		     struct svc_rdma_fastreg_mr *frmr)
+{
+	struct ib_send_wr fastreg_wr;
+	u8 key;
+
+	/* Bump the key */
+	key = (u8)(frmr->mr->lkey & 0x000000FF);
+	ib_update_fast_reg_key(frmr->mr, ++key);
+
+	/* Prepare FASTREG WR */
+	memset(&fastreg_wr, 0, sizeof fastreg_wr);
+	fastreg_wr.opcode = IB_WR_FAST_REG_MR;
+	fastreg_wr.send_flags = IB_SEND_SIGNALED;
+	fastreg_wr.wr.fast_reg.iova_start = (unsigned long)frmr->kva;
+	fastreg_wr.wr.fast_reg.page_list = frmr->page_list;
+	fastreg_wr.wr.fast_reg.page_list_len = frmr->page_list_len;
+	fastreg_wr.wr.fast_reg.page_shift = PAGE_SHIFT;
+	fastreg_wr.wr.fast_reg.length = frmr->map_len;
+	fastreg_wr.wr.fast_reg.access_flags = frmr->access_flags;
+	fastreg_wr.wr.fast_reg.rkey = frmr->mr->lkey;
+	return svc_rdma_send(xprt, &fastreg_wr);
+}
+
 int svc_rdma_send(struct svcxprt_rdma *xprt, struct ib_send_wr *wr)
 {
 	struct ib_send_wr *bad_wr;
@@ -1199,8 +1242,6 @@ int svc_rdma_send(struct svcxprt_rdma *xprt, struct ib_send_wr *wr)
 		return -ENOTCONN;
 
 	BUG_ON(wr->send_flags != IB_SEND_SIGNALED);
-	BUG_ON(((struct svc_rdma_op_ctxt *)(unsigned long)wr->wr_id)->wr_op !=
-		wr->opcode);
 	/* If the SQ is full, wait until an SQ entry is available */
 	while (1) {
 		spin_lock_bh(&xprt->sc_lock);

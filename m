Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33640 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964931AbdAGRRh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jan 2017 12:17:37 -0500
Subject: [PATCH v1 17/22] svcrdma: Remove unused Read completion handlers
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 07 Jan 2017 12:17:35 -0500
Message-ID: <20170107171735.14126.43279.stgit@klimt.1015granger.net>
In-Reply-To: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
References: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:

The generic RDMA R/W API conversion of svc_rdma_recvfrom replaced
the Register, Read, and Invalidate completion handlers. Remove the
old ones, which are no longer used.

As an additional clean up, fold the wc_common helper back into the
remaining Send completion handler in svc_rdma_transport.c.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h          |    4 -
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   98 ++++--------------------------
 2 files changed, 15 insertions(+), 87 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 95a3720..6fae169 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -77,18 +77,16 @@ enum {
  */
 struct svc_rdma_op_ctxt {
 	struct list_head list;
-	struct svc_rdma_op_ctxt *read_hdr;
 	struct svc_rdma_fastreg_mr *frmr;
-	int hdr_count;
 	struct xdr_buf arg;
 	struct ib_cqe cqe;
 	u32 byte_len;
 	u32 position;
 	struct svcxprt_rdma *xprt;
-	unsigned long flags;
 	enum dma_data_direction direction;
 	int count;
 	unsigned int mapped_sges;
+	int hdr_count;
 	struct ib_send_wr send_wr;
 	struct ib_sge sge[1 + RPCRDMA_MAX_REQ_SIZE / PAGE_SIZE];
 	struct page *pages[RPCSVC_MAXPAGES];
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index bb0281f..e77d18b 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -345,36 +345,6 @@ static void svc_rdma_wc_receive(struct ib_cq *cq, struct ib_wc *wc)
 	svc_xprt_put(&xprt->sc_xprt);
 }
 
-static void svc_rdma_send_wc_common(struct svcxprt_rdma *xprt,
-				    struct ib_wc *wc,
-				    const char *opname)
-{
-	if (wc->status != IB_WC_SUCCESS)
-		goto err;
-
-out:
-	atomic_inc(&xprt->sc_sq_avail);
-	wake_up(&xprt->sc_send_wait);
-	return;
-
-err:
-	set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
-	if (wc->status != IB_WC_WR_FLUSH_ERR)
-		pr_err("svcrdma: %s: %s (%u/0x%x)\n",
-		       opname, ib_wc_status_msg(wc->status),
-		       wc->status, wc->vendor_err);
-	goto out;
-}
-
-static void svc_rdma_send_wc_common_put(struct ib_cq *cq, struct ib_wc *wc,
-					const char *opname)
-{
-	struct svcxprt_rdma *xprt = cq->cq_context;
-
-	svc_rdma_send_wc_common(xprt, wc, opname);
-	svc_xprt_put(&xprt->sc_xprt);
-}
-
 /**
  * svc_rdma_wc_send - Invoked by RDMA provider for each polled Send WC
  * @cq:        completion queue
@@ -383,71 +353,31 @@ static void svc_rdma_send_wc_common_put(struct ib_cq *cq, struct ib_wc *wc,
  */
 void svc_rdma_wc_send(struct ib_cq *cq, struct ib_wc *wc)
 {
-	struct ib_cqe *cqe = wc->wr_cqe;
-	struct svc_rdma_op_ctxt *ctxt;
-
-	svc_rdma_send_wc_common_put(cq, wc, "send");
-
-	ctxt = container_of(cqe, struct svc_rdma_op_ctxt, cqe);
-	svc_rdma_unmap_dma(ctxt);
-	svc_rdma_put_context(ctxt, 1);
-}
-
-/**
- * svc_rdma_wc_reg - Invoked by RDMA provider for each polled FASTREG WC
- * @cq:        completion queue
- * @wc:        completed WR
- *
- */
-void svc_rdma_wc_reg(struct ib_cq *cq, struct ib_wc *wc)
-{
-	svc_rdma_send_wc_common_put(cq, wc, "fastreg");
-}
-
-/**
- * svc_rdma_wc_read - Invoked by RDMA provider for each polled Read WC
- * @cq:        completion queue
- * @wc:        completed WR
- *
- */
-void svc_rdma_wc_read(struct ib_cq *cq, struct ib_wc *wc)
-{
 	struct svcxprt_rdma *xprt = cq->cq_context;
 	struct ib_cqe *cqe = wc->wr_cqe;
 	struct svc_rdma_op_ctxt *ctxt;
 
-	svc_rdma_send_wc_common(xprt, wc, "read");
+	atomic_inc(&xprt->sc_sq_avail);
+	wake_up(&xprt->sc_send_wait);
 
 	ctxt = container_of(cqe, struct svc_rdma_op_ctxt, cqe);
 	svc_rdma_unmap_dma(ctxt);
-	svc_rdma_put_frmr(xprt, ctxt->frmr);
-
-	if (test_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags)) {
-		struct svc_rdma_op_ctxt *read_hdr;
-
-		read_hdr = ctxt->read_hdr;
-		spin_lock(&xprt->sc_rq_dto_lock);
-		list_add_tail(&read_hdr->list,
-			      &xprt->sc_read_complete_q);
-		spin_unlock(&xprt->sc_rq_dto_lock);
+	svc_rdma_put_context(ctxt, 1);
 
-		set_bit(XPT_DATA, &xprt->sc_xprt.xpt_flags);
-		svc_xprt_enqueue(&xprt->sc_xprt);
-	}
+	if (wc->status != IB_WC_SUCCESS)
+		goto flush;
 
-	svc_rdma_put_context(ctxt, 0);
+out:
 	svc_xprt_put(&xprt->sc_xprt);
-}
+	return;
 
-/**
- * svc_rdma_wc_inv - Invoked by RDMA provider for each polled LOCAL_INV WC
- * @cq:        completion queue
- * @wc:        completed WR
- *
- */
-void svc_rdma_wc_inv(struct ib_cq *cq, struct ib_wc *wc)
-{
-	svc_rdma_send_wc_common_put(cq, wc, "localInv");
+flush:
+	set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
+	if (wc->status != IB_WC_WR_FLUSH_ERR)
+		pr_err("svcrdma: Send: %s (%u/0x%x)\n",
+		       ib_wc_status_msg(wc->status),
+		       wc->status, wc->vendor_err);
+	goto out;
 }
 
 static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,


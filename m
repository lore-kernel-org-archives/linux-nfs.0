Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35464 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753651AbdBGQ7G (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Feb 2017 11:59:06 -0500
Subject: [PATCH v3 7/7] svcrdma: Poll CQs in "workqueue" mode
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 07 Feb 2017 11:59:04 -0500
Message-ID: <20170207165904.14422.95545.stgit@klimt.1015granger.net>
In-Reply-To: <20170207165131.14422.47088.stgit@klimt.1015granger.net>
References: <20170207165131.14422.47088.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

svcrdma calls svc_xprt_put() in its completion handlers, which
currently run in IRQ context.

However, svc_xprt_put() is meant to be invoked in process context,
not in IRQ context. After the last transport reference is gone, it
directly calls a transport release function that expects to run in
process context.

Change the CQ polling modes to IB_POLL_WORKQUEUE so that svcrdma
invokes svc_xprt_put() only in process context. As an added benefit,
bottom half-disabled spin locking can be eliminated from I/O paths.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    6 +++---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   26 +++++++++++++-------------
 2 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index b9ccd73..f7b2daf 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -606,12 +606,12 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 
 	dprintk("svcrdma: rqstp=%p\n", rqstp);
 
-	spin_lock_bh(&rdma_xprt->sc_rq_dto_lock);
+	spin_lock(&rdma_xprt->sc_rq_dto_lock);
 	if (!list_empty(&rdma_xprt->sc_read_complete_q)) {
 		ctxt = list_first_entry(&rdma_xprt->sc_read_complete_q,
 					struct svc_rdma_op_ctxt, list);
 		list_del(&ctxt->list);
-		spin_unlock_bh(&rdma_xprt->sc_rq_dto_lock);
+		spin_unlock(&rdma_xprt->sc_rq_dto_lock);
 		rdma_read_complete(rqstp, ctxt);
 		goto complete;
 	} else if (!list_empty(&rdma_xprt->sc_rq_dto_q)) {
@@ -623,7 +623,7 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 		clear_bit(XPT_DATA, &xprt->xpt_flags);
 		ctxt = NULL;
 	}
-	spin_unlock_bh(&rdma_xprt->sc_rq_dto_lock);
+	spin_unlock(&rdma_xprt->sc_rq_dto_lock);
 	if (!ctxt) {
 		/* This is the EAGAIN path. The svc_recv routine will
 		 * return -EAGAIN, the nfsd thread will go to call into
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 87b8b5a..ab2fd53 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -188,7 +188,7 @@ struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
 {
 	struct svc_rdma_op_ctxt *ctxt = NULL;
 
-	spin_lock_bh(&xprt->sc_ctxt_lock);
+	spin_lock(&xprt->sc_ctxt_lock);
 	xprt->sc_ctxt_used++;
 	if (list_empty(&xprt->sc_ctxts))
 		goto out_empty;
@@ -196,7 +196,7 @@ struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
 	ctxt = list_first_entry(&xprt->sc_ctxts,
 				struct svc_rdma_op_ctxt, list);
 	list_del(&ctxt->list);
-	spin_unlock_bh(&xprt->sc_ctxt_lock);
+	spin_unlock(&xprt->sc_ctxt_lock);
 
 out:
 	ctxt->count = 0;
@@ -208,15 +208,15 @@ struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
 	/* Either pre-allocation missed the mark, or send
 	 * queue accounting is broken.
 	 */
-	spin_unlock_bh(&xprt->sc_ctxt_lock);
+	spin_unlock(&xprt->sc_ctxt_lock);
 
 	ctxt = alloc_ctxt(xprt, GFP_NOIO);
 	if (ctxt)
 		goto out;
 
-	spin_lock_bh(&xprt->sc_ctxt_lock);
+	spin_lock(&xprt->sc_ctxt_lock);
 	xprt->sc_ctxt_used--;
-	spin_unlock_bh(&xprt->sc_ctxt_lock);
+	spin_unlock(&xprt->sc_ctxt_lock);
 	WARN_ONCE(1, "svcrdma: empty RDMA ctxt list?\n");
 	return NULL;
 }
@@ -253,10 +253,10 @@ void svc_rdma_put_context(struct svc_rdma_op_ctxt *ctxt, int free_pages)
 		for (i = 0; i < ctxt->count; i++)
 			put_page(ctxt->pages[i]);
 
-	spin_lock_bh(&xprt->sc_ctxt_lock);
+	spin_lock(&xprt->sc_ctxt_lock);
 	xprt->sc_ctxt_used--;
 	list_add(&ctxt->list, &xprt->sc_ctxts);
-	spin_unlock_bh(&xprt->sc_ctxt_lock);
+	spin_unlock(&xprt->sc_ctxt_lock);
 }
 
 static void svc_rdma_destroy_ctxts(struct svcxprt_rdma *xprt)
@@ -921,14 +921,14 @@ struct svc_rdma_fastreg_mr *svc_rdma_get_frmr(struct svcxprt_rdma *rdma)
 {
 	struct svc_rdma_fastreg_mr *frmr = NULL;
 
-	spin_lock_bh(&rdma->sc_frmr_q_lock);
+	spin_lock(&rdma->sc_frmr_q_lock);
 	if (!list_empty(&rdma->sc_frmr_q)) {
 		frmr = list_entry(rdma->sc_frmr_q.next,
 				  struct svc_rdma_fastreg_mr, frmr_list);
 		list_del_init(&frmr->frmr_list);
 		frmr->sg_nents = 0;
 	}
-	spin_unlock_bh(&rdma->sc_frmr_q_lock);
+	spin_unlock(&rdma->sc_frmr_q_lock);
 	if (frmr)
 		return frmr;
 
@@ -941,10 +941,10 @@ void svc_rdma_put_frmr(struct svcxprt_rdma *rdma,
 	if (frmr) {
 		ib_dma_unmap_sg(rdma->sc_cm_id->device,
 				frmr->sg, frmr->sg_nents, frmr->direction);
-		spin_lock_bh(&rdma->sc_frmr_q_lock);
+		spin_lock(&rdma->sc_frmr_q_lock);
 		WARN_ON_ONCE(!list_empty(&frmr->frmr_list));
 		list_add(&frmr->frmr_list, &rdma->sc_frmr_q);
-		spin_unlock_bh(&rdma->sc_frmr_q_lock);
+		spin_unlock(&rdma->sc_frmr_q_lock);
 	}
 }
 
@@ -1026,13 +1026,13 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 		goto errout;
 	}
 	newxprt->sc_sq_cq = ib_alloc_cq(dev, newxprt, newxprt->sc_sq_depth,
-					0, IB_POLL_SOFTIRQ);
+					0, IB_POLL_WORKQUEUE);
 	if (IS_ERR(newxprt->sc_sq_cq)) {
 		dprintk("svcrdma: error creating SQ CQ for connect request\n");
 		goto errout;
 	}
 	newxprt->sc_rq_cq = ib_alloc_cq(dev, newxprt, newxprt->sc_rq_depth,
-					0, IB_POLL_SOFTIRQ);
+					0, IB_POLL_WORKQUEUE);
 	if (IS_ERR(newxprt->sc_rq_cq)) {
 		dprintk("svcrdma: error creating RQ CQ for connect request\n");
 		goto errout;


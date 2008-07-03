From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 04/11] svcrdma: Move the DMA unmap logic to the CQ handler
Date: Wed,  2 Jul 2008 21:27:36 -0500
Message-ID: <1215052063-7330-5-git-send-email-tom@opengridcomputing.com>
References: <1215052063-7330-1-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-2-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-3-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-4-git-send-email-tom@opengridcomputing.com>
Cc: linux-nfs@vger.kernel.org, Tom Tucker <tom@opengridcomputing.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:48834 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753342AbYGCC1o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jul 2008 22:27:44 -0400
In-Reply-To: <1215052063-7330-4-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Separate DMA unmap from context destruction and perform DMA unmapping
in the SQ/RQ CQ reap functions. This is necessary to support software
based RDMA implementations that actually copy the data in their
ib_dma_unmap callback functions and architectures that don't have
cache coherent I/O busses.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index fc86338..7e8ee66 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -150,6 +150,18 @@ struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
 	return ctxt;
 }
 
+static void svc_rdma_unmap_dma(struct svc_rdma_op_ctxt *ctxt)
+{
+	struct svcxprt_rdma *xprt = ctxt->xprt;
+	int i;
+	for (i = 0; i < ctxt->count && ctxt->sge[i].length; i++) {
+		ib_dma_unmap_single(xprt->sc_cm_id->device,
+				    ctxt->sge[i].addr,
+				    ctxt->sge[i].length,
+				    ctxt->direction);
+	}
+}
+
 void svc_rdma_put_context(struct svc_rdma_op_ctxt *ctxt, int free_pages)
 {
 	struct svcxprt_rdma *xprt;
@@ -161,12 +173,6 @@ void svc_rdma_put_context(struct svc_rdma_op_ctxt *ctxt, int free_pages)
 		for (i = 0; i < ctxt->count; i++)
 			put_page(ctxt->pages[i]);
 
-	for (i = 0; i < ctxt->count; i++)
-		ib_dma_unmap_single(xprt->sc_cm_id->device,
-				    ctxt->sge[i].addr,
-				    ctxt->sge[i].length,
-				    ctxt->direction);
-
 	spin_lock_bh(&xprt->sc_ctxt_lock);
 	list_add(&ctxt->free_list, &xprt->sc_ctxt_free);
 	spin_unlock_bh(&xprt->sc_ctxt_lock);
@@ -328,6 +334,7 @@ static void rq_cq_reap(struct svcxprt_rdma *xprt)
 		ctxt = (struct svc_rdma_op_ctxt *)(unsigned long)wc.wr_id;
 		ctxt->wc_status = wc.status;
 		ctxt->byte_len = wc.byte_len;
+		svc_rdma_unmap_dma(ctxt);
 		if (wc.status != IB_WC_SUCCESS) {
 			/* Close the transport */
 			dprintk("svcrdma: transport closing putting ctxt %p\n", ctxt);
@@ -377,6 +384,7 @@ static void sq_cq_reap(struct svcxprt_rdma *xprt)
 		ctxt = (struct svc_rdma_op_ctxt *)(unsigned long)wc.wr_id;
 		xprt = ctxt->xprt;
 
+		svc_rdma_unmap_dma(ctxt);
 		if (wc.status != IB_WC_SUCCESS)
 			/* Close the transport */
 			set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);

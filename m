Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34096 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752941AbcKITE7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Nov 2016 14:04:59 -0500
Subject: [PATCH v1 01/14] xprtrdma: Fix DMAR failure in frwr_op_map() after
 reconnect
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 09 Nov 2016 14:04:56 -0500
Message-ID: <20161109190456.15007.87544.stgit@manet.1015granger.net>
In-Reply-To: <20161109184735.15007.96507.stgit@manet.1015granger.net>
References: <20161109184735.15007.96507.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When a LOCALINV WR is flushed, the frmr is marked STALE, then
frwr_op_unmap_sync DMA-unmaps the frmr's SGL. These STALE frmrs
are then recovered when frwr_op_map hunts for an INVALID frmr to
use.

All other cases that need frmr recovery leave that SGL DMA-mapped.
The FRMR recovery path unconditionally DMA-unmaps the frmr's SGL.

To avoid DMA unmapping the SGL twice for flushed LOCAL_INV WRs,
alter the recovery logic (rather than the hot frwr_op_unmap_sync
path) to distinguish among these cases. This solution also takes
care of the case where multiple LOCAL_INV WRs are issued for the
same rpcrdma_req, some complete successfully, but some are flushed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Vasco Steinmetz <linux@kyberraum.net>
---
 net/sunrpc/xprtrdma/frwr_ops.c  |   37 ++++++++++++++++++++++---------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    3 ++-
 2 files changed, 24 insertions(+), 16 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 2109495..26b26be 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -44,18 +44,20 @@
  * being done.
  *
  * When the underlying transport disconnects, MRs are left in one of
- * three states:
+ * four states:
  *
  * INVALID:	The MR was not in use before the QP entered ERROR state.
- *		(Or, the LOCAL_INV WR has not completed or flushed yet).
- *
- * STALE:	The MR was being registered or unregistered when the QP
- *		entered ERROR state, and the pending WR was flushed.
  *
  * VALID:	The MR was registered before the QP entered ERROR state.
  *
- * When frwr_op_map encounters STALE and VALID MRs, they are recovered
- * with ib_dereg_mr and then are re-initialized. Beause MR recovery
+ * FLUSHED_FR:	The MR was being registered when the QP entered ERROR
+ *		state, and the pending WR was flushed.
+ *
+ * FLUSHED_LI:	The MR was being invalidated when the QP entered ERROR
+ *		state, and the pending WR was flushed.
+ *
+ * When frwr_op_map encounters FLUSHED and VALID MRs, they are recovered
+ * with ib_dereg_mr and then are re-initialized. Because MR recovery
  * allocates fresh resources, it is deferred to a workqueue, and the
  * recovered MRs are placed back on the rb_mws list when recovery is
  * complete. frwr_op_map allocates another MR for the current RPC while
@@ -177,12 +179,15 @@
 static void
 frwr_op_recover_mr(struct rpcrdma_mw *mw)
 {
+	enum rpcrdma_frmr_state state = mw->frmr.fr_state;
 	struct rpcrdma_xprt *r_xprt = mw->mw_xprt;
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	int rc;
 
 	rc = __frwr_reset_mr(ia, mw);
-	ib_dma_unmap_sg(ia->ri_device, mw->mw_sg, mw->mw_nents, mw->mw_dir);
+	if (state != FRMR_FLUSHED_LI)
+		ib_dma_unmap_sg(ia->ri_device,
+				mw->mw_sg, mw->mw_nents, mw->mw_dir);
 	if (rc)
 		goto out_release;
 
@@ -262,10 +267,8 @@
 }
 
 static void
-__frwr_sendcompletion_flush(struct ib_wc *wc, struct rpcrdma_frmr *frmr,
-			    const char *wr)
+__frwr_sendcompletion_flush(struct ib_wc *wc, const char *wr)
 {
-	frmr->fr_state = FRMR_IS_STALE;
 	if (wc->status != IB_WC_WR_FLUSH_ERR)
 		pr_err("rpcrdma: %s: %s (%u/0x%x)\n",
 		       wr, ib_wc_status_msg(wc->status),
@@ -288,7 +291,8 @@
 	if (wc->status != IB_WC_SUCCESS) {
 		cqe = wc->wr_cqe;
 		frmr = container_of(cqe, struct rpcrdma_frmr, fr_cqe);
-		__frwr_sendcompletion_flush(wc, frmr, "fastreg");
+		frmr->fr_state = FRMR_FLUSHED_FR;
+		__frwr_sendcompletion_flush(wc, "fastreg");
 	}
 }
 
@@ -308,7 +312,8 @@
 	if (wc->status != IB_WC_SUCCESS) {
 		cqe = wc->wr_cqe;
 		frmr = container_of(cqe, struct rpcrdma_frmr, fr_cqe);
-		__frwr_sendcompletion_flush(wc, frmr, "localinv");
+		frmr->fr_state = FRMR_FLUSHED_LI;
+		__frwr_sendcompletion_flush(wc, "localinv");
 	}
 }
 
@@ -328,8 +333,10 @@
 	/* WARNING: Only wr_cqe and status are reliable at this point */
 	cqe = wc->wr_cqe;
 	frmr = container_of(cqe, struct rpcrdma_frmr, fr_cqe);
-	if (wc->status != IB_WC_SUCCESS)
-		__frwr_sendcompletion_flush(wc, frmr, "localinv");
+	if (wc->status != IB_WC_SUCCESS) {
+		frmr->fr_state = FRMR_FLUSHED_LI;
+		__frwr_sendcompletion_flush(wc, "localinv");
+	}
 	complete(&frmr->fr_linv_done);
 }
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 0d35b76..6e1bba3 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -216,7 +216,8 @@ struct rpcrdma_rep {
 enum rpcrdma_frmr_state {
 	FRMR_IS_INVALID,	/* ready to be used */
 	FRMR_IS_VALID,		/* in use */
-	FRMR_IS_STALE,		/* failed completion */
+	FRMR_FLUSHED_FR,	/* flushed FASTREG WR */
+	FRMR_FLUSHED_LI,	/* flushed LOCALINV WR */
 };
 
 struct rpcrdma_frmr {


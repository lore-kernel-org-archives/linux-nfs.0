Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36423 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932821AbcDYTW2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Apr 2016 15:22:28 -0400
Subject: [PATCH v2 12/18] xprtrdma: Reset MRs in frwr_op_unmap_sync()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 25 Apr 2016 15:22:26 -0400
Message-ID: <20160425192226.3566.56804.stgit@manet.1015granger.net>
In-Reply-To: <20160425185956.3566.64142.stgit@manet.1015granger.net>
References: <20160425185956.3566.64142.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

frwr_op_unmap_sync() is now invoked in a workqueue context, the same
as __frwr_queue_recovery(). There's no need to defer MR reset if
posting LOCAL_INV MRs fails.

This means that even when ib_post_send() fails (which should occur
very rarely) the invalidation and DMA unmapping steps are still done
in the correct order.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c |   98 ++++++++++++++++++++++++----------------
 1 file changed, 60 insertions(+), 38 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index e1e6ac1..ce245dc 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -98,6 +98,32 @@ frwr_destroy_recovery_wq(void)
 	destroy_workqueue(wq);
 }
 
+static int
+__frwr_reset_mr(struct rpcrdma_ia *ia, struct rpcrdma_mw *r)
+{
+	struct rpcrdma_frmr *f = &r->frmr;
+	int rc;
+
+	rc = ib_dereg_mr(f->fr_mr);
+	if (rc) {
+		pr_warn("rpcrdma: ib_dereg_mr status %d, frwr %p orphaned\n",
+			rc, r);
+		return rc;
+	}
+
+	f->fr_mr = ib_alloc_mr(ia->ri_pd, IB_MR_TYPE_MEM_REG,
+			       ia->ri_max_frmr_depth);
+	if (IS_ERR(f->fr_mr)) {
+		pr_warn("rpcrdma: ib_alloc_mr status %ld, frwr %p orphaned\n",
+			PTR_ERR(f->fr_mr), r);
+		return PTR_ERR(f->fr_mr);
+	}
+
+	dprintk("RPC:       %s: recovered FRMR %p\n", __func__, r);
+	f->fr_state = FRMR_IS_INVALID;
+	return 0;
+}
+
 /* Deferred reset of a single FRMR. Generate a fresh rkey by
  * replacing the MR.
  *
@@ -111,24 +137,15 @@ __frwr_recovery_worker(struct work_struct *work)
 	struct rpcrdma_mw *r = container_of(work, struct rpcrdma_mw,
 					    frmr.fr_work);
 	struct rpcrdma_xprt *r_xprt = r->frmr.fr_xprt;
-	unsigned int depth = r_xprt->rx_ia.ri_max_frmr_depth;
-	struct ib_pd *pd = r_xprt->rx_ia.ri_pd;
-
-	if (ib_dereg_mr(r->frmr.fr_mr))
-		goto out_fail;
+	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
+	int rc;
 
-	r->frmr.fr_mr = ib_alloc_mr(pd, IB_MR_TYPE_MEM_REG, depth);
-	if (IS_ERR(r->frmr.fr_mr))
-		goto out_fail;
+	rc = __frwr_reset_mr(ia, r);
+	if (rc)
+		return;
 
-	dprintk("RPC:       %s: recovered FRMR %p\n", __func__, r);
-	r->frmr.fr_state = FRMR_IS_INVALID;
 	rpcrdma_put_mw(r_xprt, r);
 	return;
-
-out_fail:
-	pr_warn("RPC:       %s: FRMR %p unrecovered\n",
-		__func__, r);
 }
 
 /* A broken MR was discovered in a context that can't sleep.
@@ -490,24 +507,6 @@ __frwr_prepare_linv_wr(struct rpcrdma_mr_seg *seg)
 	return invalidate_wr;
 }
 
-static void
-__frwr_dma_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
-		 int rc)
-{
-	struct ib_device *device = r_xprt->rx_ia.ri_device;
-	struct rpcrdma_mw *mw = seg->rl_mw;
-	struct rpcrdma_frmr *f = &mw->frmr;
-
-	seg->rl_mw = NULL;
-
-	ib_dma_unmap_sg(device, f->fr_sg, f->fr_nents, f->fr_dir);
-
-	if (!rc)
-		rpcrdma_put_mw(r_xprt, mw);
-	else
-		__frwr_queue_recovery(mw);
-}
-
 /* Invalidate all memory regions that were registered for "req".
  *
  * Sleeps until it is safe for the host CPU to access the
@@ -521,6 +520,7 @@ frwr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 	struct rpcrdma_mr_seg *seg;
 	unsigned int i, nchunks;
 	struct rpcrdma_frmr *f;
+	struct rpcrdma_mw *mw;
 	int rc;
 
 	dprintk("RPC:       %s: req %p\n", __func__, req);
@@ -561,11 +561,8 @@ frwr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 	 * unless ri_id->qp is a valid pointer.
 	 */
 	rc = ib_post_send(ia->ri_id->qp, invalidate_wrs, &bad_wr);
-	if (rc) {
-		pr_warn("%s: ib_post_send failed %i\n", __func__, rc);
-		rdma_disconnect(ia->ri_id);
-		goto unmap;
-	}
+	if (rc)
+		goto reset_mrs;
 
 	wait_for_completion(&f->fr_linv_done);
 
@@ -575,14 +572,39 @@ frwr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 unmap:
 	for (i = 0, nchunks = req->rl_nchunks; nchunks; nchunks--) {
 		seg = &req->rl_segments[i];
+		mw = seg->rl_mw;
+		seg->rl_mw = NULL;
 
-		__frwr_dma_unmap(r_xprt, seg, rc);
+		ib_dma_unmap_sg(ia->ri_device, f->fr_sg, f->fr_nents,
+				f->fr_dir);
+		rpcrdma_put_mw(r_xprt, mw);
 
 		i += seg->mr_nsegs;
 		seg->mr_nsegs = 0;
 	}
 
 	req->rl_nchunks = 0;
+	return;
+
+reset_mrs:
+	pr_warn("%s: ib_post_send failed %i\n", __func__, rc);
+
+	/* Find and reset the MRs in the LOCAL_INV WRs that did not
+	 * get posted. This is synchronous, and slow.
+	 */
+	for (i = 0, nchunks = req->rl_nchunks; nchunks; nchunks--) {
+		seg = &req->rl_segments[i];
+		mw = seg->rl_mw;
+		f = &mw->frmr;
+
+		if (mw->frmr.fr_mr->rkey == bad_wr->ex.invalidate_rkey) {
+			__frwr_reset_mr(ia, mw);
+			bad_wr = bad_wr->next;
+		}
+
+		i += seg->mr_nsegs;
+	}
+	goto unmap;
 }
 
 /* Post a LOCAL_INV Work Request to prevent further remote access


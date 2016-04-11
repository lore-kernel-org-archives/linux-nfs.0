Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f196.google.com ([209.85.213.196]:34434 "EHLO
	mail-ig0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753109AbcDKUMd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Apr 2016 16:12:33 -0400
Subject: [PATCH v1 17/18] xprtrdma: Remove ro_unmap() from all registration
 modes
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 11 Apr 2016 16:12:30 -0400
Message-ID: <20160411201230.20531.19787.stgit@manet.1015granger.net>
In-Reply-To: <20160411200323.20531.8893.stgit@manet.1015granger.net>
References: <20160411200323.20531.8893.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: The ro_unmap method is no longer used.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c      |   31 --------------------------
 net/sunrpc/xprtrdma/frwr_ops.c     |   43 ------------------------------------
 net/sunrpc/xprtrdma/physical_ops.c |   12 ----------
 net/sunrpc/xprtrdma/xprt_rdma.h    |    2 --
 4 files changed, 88 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index a658dcf..6326ebe 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -328,36 +328,6 @@ fmr_op_unmap_safe(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 	}
 }
 
-/* Use the ib_unmap_fmr() verb to prevent further remote
- * access via RDMA READ or RDMA WRITE.
- */
-static int
-fmr_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
-{
-	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
-	struct rpcrdma_mr_seg *seg1 = seg;
-	struct rpcrdma_mw *mw = seg1->rl_mw;
-	int rc, nsegs = seg->mr_nsegs;
-
-	dprintk("RPC:       %s: FMR %p\n", __func__, mw);
-
-	seg1->rl_mw = NULL;
-	while (seg1->mr_nsegs--)
-		rpcrdma_unmap_one(ia->ri_device, seg++);
-	rc = __fmr_unmap(mw);
-	if (rc)
-		goto out_err;
-	rpcrdma_put_mw(r_xprt, mw);
-	return nsegs;
-
-out_err:
-	/* The FMR is abandoned, but remains in rb_all. fmr_op_destroy
-	 * will attempt to release it when the transport is destroyed.
-	 */
-	dprintk("RPC:       %s: ib_unmap_fmr status %i\n", __func__, rc);
-	return nsegs;
-}
-
 static void
 fmr_op_destroy(struct rpcrdma_buffer *buf)
 {
@@ -382,7 +352,6 @@ const struct rpcrdma_memreg_ops rpcrdma_fmr_memreg_ops = {
 	.ro_map				= fmr_op_map,
 	.ro_unmap_sync			= fmr_op_unmap_sync,
 	.ro_unmap_safe			= fmr_op_unmap_safe,
-	.ro_unmap			= fmr_op_unmap,
 	.ro_open			= fmr_op_open,
 	.ro_maxpages			= fmr_op_maxpages,
 	.ro_init			= fmr_op_init,
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 79ba323..a192b91 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -640,48 +640,6 @@ frwr_op_unmap_safe(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 	}
 }
 
-/* Post a LOCAL_INV Work Request to prevent further remote access
- * via RDMA READ or RDMA WRITE.
- */
-static int
-frwr_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
-{
-	struct rpcrdma_mr_seg *seg1 = seg;
-	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
-	struct rpcrdma_mw *mw = seg1->rl_mw;
-	struct rpcrdma_frmr *frmr = &mw->frmr;
-	struct ib_send_wr *invalidate_wr, *bad_wr;
-	int rc, nsegs = seg->mr_nsegs;
-
-	dprintk("RPC:       %s: FRMR %p\n", __func__, mw);
-
-	seg1->rl_mw = NULL;
-	frmr->fr_state = FRMR_IS_INVALID;
-	invalidate_wr = &mw->frmr.fr_invwr;
-
-	memset(invalidate_wr, 0, sizeof(*invalidate_wr));
-	frmr->fr_cqe.done = frwr_wc_localinv;
-	invalidate_wr->wr_cqe = &frmr->fr_cqe;
-	invalidate_wr->opcode = IB_WR_LOCAL_INV;
-	invalidate_wr->ex.invalidate_rkey = frmr->fr_mr->rkey;
-	DECR_CQCOUNT(&r_xprt->rx_ep);
-
-	ib_dma_unmap_sg(ia->ri_device, frmr->fr_sg, frmr->fr_nents, frmr->fr_dir);
-	read_lock(&ia->ri_qplock);
-	rc = ib_post_send(ia->ri_id->qp, invalidate_wr, &bad_wr);
-	read_unlock(&ia->ri_qplock);
-	if (rc)
-		goto out_err;
-
-	rpcrdma_put_mw(r_xprt, mw);
-	return nsegs;
-
-out_err:
-	dprintk("RPC:       %s: ib_post_send status %i\n", __func__, rc);
-	__frwr_queue_recovery(mw);
-	return nsegs;
-}
-
 static void
 frwr_op_destroy(struct rpcrdma_buffer *buf)
 {
@@ -702,7 +660,6 @@ const struct rpcrdma_memreg_ops rpcrdma_frwr_memreg_ops = {
 	.ro_map				= frwr_op_map,
 	.ro_unmap_sync			= frwr_op_unmap_sync,
 	.ro_unmap_safe			= frwr_op_unmap_safe,
-	.ro_unmap			= frwr_op_unmap,
 	.ro_open			= frwr_op_open,
 	.ro_maxpages			= frwr_op_maxpages,
 	.ro_init			= frwr_op_init,
diff --git a/net/sunrpc/xprtrdma/physical_ops.c b/net/sunrpc/xprtrdma/physical_ops.c
index 95ef3a7..3750596 100644
--- a/net/sunrpc/xprtrdma/physical_ops.c
+++ b/net/sunrpc/xprtrdma/physical_ops.c
@@ -74,17 +74,6 @@ physical_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	return 1;
 }
 
-/* Unmap a memory region, but leave it registered.
- */
-static int
-physical_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
-{
-	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
-
-	rpcrdma_unmap_one(ia->ri_device, seg);
-	return 1;
-}
-
 /* DMA unmap all memory regions that were mapped for "req".
  */
 static void
@@ -125,7 +114,6 @@ const struct rpcrdma_memreg_ops rpcrdma_physical_memreg_ops = {
 	.ro_map				= physical_op_map,
 	.ro_unmap_sync			= physical_op_unmap_sync,
 	.ro_unmap_safe			= physical_op_unmap_safe,
-	.ro_unmap			= physical_op_unmap,
 	.ro_open			= physical_op_open,
 	.ro_maxpages			= physical_op_maxpages,
 	.ro_init			= physical_op_init,
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 04a7058..24bbea4 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -397,8 +397,6 @@ struct rpcrdma_memreg_ops {
 				  struct rpcrdma_mr_seg *, int, bool);
 	void		(*ro_unmap_sync)(struct rpcrdma_xprt *,
 					 struct rpcrdma_req *);
-	int		(*ro_unmap)(struct rpcrdma_xprt *,
-				    struct rpcrdma_mr_seg *);
 	void		(*ro_unmap_safe)(struct rpcrdma_xprt *,
 					 struct rpcrdma_req *, bool);
 	int		(*ro_open)(struct rpcrdma_ia *,


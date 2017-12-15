Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:40451 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754733AbdLOB5t (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Dec 2017 20:57:49 -0500
Subject: [PATCH v1 14/16] xprtrdma: Replace all usage of "frmr" with "frwr"
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 14 Dec 2017 20:57:47 -0500
Message-ID: <20171215015747.13776.55357.stgit@manet.1015granger.net>
In-Reply-To: <20171215015403.13776.46706.stgit@manet.1015granger.net>
References: <20171215015403.13776.46706.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Over time, the industry has adopted the term "frwr"
instead of "frmr". The term "frwr" is now more widely recognized.

For the past couple of years I've attempted to add new code using
"frwr" , but there still remains plenty of older code that still
uses "frmr". Replace all usage of "frmr" to avoid confusion.

While we're churning code, rename variables unhelpfully called "f"
to "frwr", to improve code clarity.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/xprtrdma.h |    2 
 net/sunrpc/xprtrdma/frwr_ops.c  |  176 ++++++++++++++++++++-------------------
 net/sunrpc/xprtrdma/transport.c |    2 
 net/sunrpc/xprtrdma/verbs.c     |    2 
 net/sunrpc/xprtrdma/xprt_rdma.h |   18 ++--
 5 files changed, 100 insertions(+), 100 deletions(-)

diff --git a/include/linux/sunrpc/xprtrdma.h b/include/linux/sunrpc/xprtrdma.h
index 221b7a2..5859563 100644
--- a/include/linux/sunrpc/xprtrdma.h
+++ b/include/linux/sunrpc/xprtrdma.h
@@ -64,7 +64,7 @@ enum rpcrdma_memreg {
 	RPCRDMA_MEMWINDOWS,
 	RPCRDMA_MEMWINDOWS_ASYNC,
 	RPCRDMA_MTHCAFMR,
-	RPCRDMA_FRMR,
+	RPCRDMA_FRWR,
 	RPCRDMA_ALLPHYSICAL,
 	RPCRDMA_LAST
 };
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index e1f7303..185eb69 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -1,11 +1,11 @@
 // SPDX-License-Identifier: GPL-2.0
 /*
- * Copyright (c) 2015 Oracle.  All rights reserved.
+ * Copyright (c) 2015, 2017 Oracle.  All rights reserved.
  * Copyright (c) 2003-2007 Network Appliance, Inc. All rights reserved.
  */
 
 /* Lightweight memory registration using Fast Registration Work
- * Requests (FRWR). Also referred to sometimes as FRMR mode.
+ * Requests (FRWR).
  *
  * FRWR features ordered asynchronous registration and deregistration
  * of arbitrarily sized memory regions. This is the fastest and safest
@@ -15,9 +15,9 @@
 /* Normal operation
  *
  * A Memory Region is prepared for RDMA READ or WRITE using a FAST_REG
- * Work Request (frmr_op_map). When the RDMA operation is finished, this
+ * Work Request (frwr_op_map). When the RDMA operation is finished, this
  * Memory Region is invalidated using a LOCAL_INV Work Request
- * (frmr_op_unmap).
+ * (frwr_op_unmap).
  *
  * Typically these Work Requests are not signaled, and neither are RDMA
  * SEND Work Requests (with the exception of signaling occasionally to
@@ -98,12 +98,12 @@
 static int
 frwr_op_init_mr(struct rpcrdma_ia *ia, struct rpcrdma_mw *r)
 {
-	unsigned int depth = ia->ri_max_frmr_depth;
-	struct rpcrdma_frmr *f = &r->frmr;
+	unsigned int depth = ia->ri_max_frwr_depth;
+	struct rpcrdma_frwr *frwr = &r->frwr;
 	int rc;
 
-	f->fr_mr = ib_alloc_mr(ia->ri_pd, ia->ri_mrtype, depth);
-	if (IS_ERR(f->fr_mr))
+	frwr->fr_mr = ib_alloc_mr(ia->ri_pd, ia->ri_mrtype, depth);
+	if (IS_ERR(frwr->fr_mr))
 		goto out_mr_err;
 
 	r->mw_sg = kcalloc(depth, sizeof(*r->mw_sg), GFP_KERNEL);
@@ -111,11 +111,11 @@
 		goto out_list_err;
 
 	sg_init_table(r->mw_sg, depth);
-	init_completion(&f->fr_linv_done);
+	init_completion(&frwr->fr_linv_done);
 	return 0;
 
 out_mr_err:
-	rc = PTR_ERR(f->fr_mr);
+	rc = PTR_ERR(frwr->fr_mr);
 	dprintk("RPC:       %s: ib_alloc_mr status %i\n",
 		__func__, rc);
 	return rc;
@@ -124,7 +124,7 @@
 	rc = -ENOMEM;
 	dprintk("RPC:       %s: sg allocation failure\n",
 		__func__);
-	ib_dereg_mr(f->fr_mr);
+	ib_dereg_mr(frwr->fr_mr);
 	return rc;
 }
 
@@ -137,7 +137,7 @@
 	if (!list_empty(&r->mw_list))
 		list_del(&r->mw_list);
 
-	rc = ib_dereg_mr(r->frmr.fr_mr);
+	rc = ib_dereg_mr(r->frwr.fr_mr);
 	if (rc)
 		pr_err("rpcrdma: final ib_dereg_mr for %p returned %i\n",
 		       r, rc);
@@ -148,41 +148,41 @@
 static int
 __frwr_reset_mr(struct rpcrdma_ia *ia, struct rpcrdma_mw *r)
 {
-	struct rpcrdma_frmr *f = &r->frmr;
+	struct rpcrdma_frwr *frwr = &r->frwr;
 	int rc;
 
-	rc = ib_dereg_mr(f->fr_mr);
+	rc = ib_dereg_mr(frwr->fr_mr);
 	if (rc) {
 		pr_warn("rpcrdma: ib_dereg_mr status %d, frwr %p orphaned\n",
 			rc, r);
 		return rc;
 	}
 
-	f->fr_mr = ib_alloc_mr(ia->ri_pd, ia->ri_mrtype,
-			       ia->ri_max_frmr_depth);
-	if (IS_ERR(f->fr_mr)) {
+	frwr->fr_mr = ib_alloc_mr(ia->ri_pd, ia->ri_mrtype,
+				  ia->ri_max_frwr_depth);
+	if (IS_ERR(frwr->fr_mr)) {
 		pr_warn("rpcrdma: ib_alloc_mr status %ld, frwr %p orphaned\n",
-			PTR_ERR(f->fr_mr), r);
-		return PTR_ERR(f->fr_mr);
+			PTR_ERR(frwr->fr_mr), r);
+		return PTR_ERR(frwr->fr_mr);
 	}
 
-	dprintk("RPC:       %s: recovered FRMR %p\n", __func__, f);
-	f->fr_state = FRMR_IS_INVALID;
+	dprintk("RPC:       %s: recovered FRWR %p\n", __func__, frwr);
+	frwr->fr_state = FRWR_IS_INVALID;
 	return 0;
 }
 
-/* Reset of a single FRMR. Generate a fresh rkey by replacing the MR.
+/* Reset of a single FRWR. Generate a fresh rkey by replacing the MR.
  */
 static void
 frwr_op_recover_mr(struct rpcrdma_mw *mw)
 {
-	enum rpcrdma_frmr_state state = mw->frmr.fr_state;
+	enum rpcrdma_frwr_state state = mw->frwr.fr_state;
 	struct rpcrdma_xprt *r_xprt = mw->mw_xprt;
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	int rc;
 
 	rc = __frwr_reset_mr(ia, mw);
-	if (state != FRMR_FLUSHED_LI)
+	if (state != FRWR_FLUSHED_LI)
 		ib_dma_unmap_sg(ia->ri_device,
 				mw->mw_sg, mw->mw_nents, mw->mw_dir);
 	if (rc)
@@ -193,7 +193,7 @@
 	return;
 
 out_release:
-	pr_err("rpcrdma: FRMR reset failed %d, %p release\n", rc, mw);
+	pr_err("rpcrdma: FRWR reset failed %d, %p release\n", rc, mw);
 	r_xprt->rx_stats.mrs_orphaned++;
 
 	spin_lock(&r_xprt->rx_buf.rb_mwlock);
@@ -214,31 +214,31 @@
 	if (attrs->device_cap_flags & IB_DEVICE_SG_GAPS_REG)
 		ia->ri_mrtype = IB_MR_TYPE_SG_GAPS;
 
-	ia->ri_max_frmr_depth =
+	ia->ri_max_frwr_depth =
 			min_t(unsigned int, RPCRDMA_MAX_DATA_SEGS,
 			      attrs->max_fast_reg_page_list_len);
 	dprintk("RPC:       %s: device's max FR page list len = %u\n",
-		__func__, ia->ri_max_frmr_depth);
-
-	/* Add room for frmr register and invalidate WRs.
-	 * 1. FRMR reg WR for head
-	 * 2. FRMR invalidate WR for head
-	 * 3. N FRMR reg WRs for pagelist
-	 * 4. N FRMR invalidate WRs for pagelist
-	 * 5. FRMR reg WR for tail
-	 * 6. FRMR invalidate WR for tail
+		__func__, ia->ri_max_frwr_depth);
+
+	/* Add room for frwr register and invalidate WRs.
+	 * 1. FRWR reg WR for head
+	 * 2. FRWR invalidate WR for head
+	 * 3. N FRWR reg WRs for pagelist
+	 * 4. N FRWR invalidate WRs for pagelist
+	 * 5. FRWR reg WR for tail
+	 * 6. FRWR invalidate WR for tail
 	 * 7. The RDMA_SEND WR
 	 */
 	depth = 7;
 
-	/* Calculate N if the device max FRMR depth is smaller than
+	/* Calculate N if the device max FRWR depth is smaller than
 	 * RPCRDMA_MAX_DATA_SEGS.
 	 */
-	if (ia->ri_max_frmr_depth < RPCRDMA_MAX_DATA_SEGS) {
-		delta = RPCRDMA_MAX_DATA_SEGS - ia->ri_max_frmr_depth;
+	if (ia->ri_max_frwr_depth < RPCRDMA_MAX_DATA_SEGS) {
+		delta = RPCRDMA_MAX_DATA_SEGS - ia->ri_max_frwr_depth;
 		do {
-			depth += 2; /* FRMR reg + invalidate */
-			delta -= ia->ri_max_frmr_depth;
+			depth += 2; /* FRWR reg + invalidate */
+			delta -= ia->ri_max_frwr_depth;
 		} while (delta > 0);
 	}
 
@@ -252,7 +252,7 @@
 	}
 
 	ia->ri_max_segs = max_t(unsigned int, 1, RPCRDMA_MAX_DATA_SEGS /
-				ia->ri_max_frmr_depth);
+				ia->ri_max_frwr_depth);
 	return 0;
 }
 
@@ -265,7 +265,7 @@
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 
 	return min_t(unsigned int, RPCRDMA_MAX_DATA_SEGS,
-		     RPCRDMA_MAX_HDR_SEGS * ia->ri_max_frmr_depth);
+		     RPCRDMA_MAX_HDR_SEGS * ia->ri_max_frwr_depth);
 }
 
 static void
@@ -286,14 +286,14 @@
 static void
 frwr_wc_fastreg(struct ib_cq *cq, struct ib_wc *wc)
 {
-	struct rpcrdma_frmr *frmr;
+	struct rpcrdma_frwr *frwr;
 	struct ib_cqe *cqe;
 
 	/* WARNING: Only wr_cqe and status are reliable at this point */
 	if (wc->status != IB_WC_SUCCESS) {
 		cqe = wc->wr_cqe;
-		frmr = container_of(cqe, struct rpcrdma_frmr, fr_cqe);
-		frmr->fr_state = FRMR_FLUSHED_FR;
+		frwr = container_of(cqe, struct rpcrdma_frwr, fr_cqe);
+		frwr->fr_state = FRWR_FLUSHED_FR;
 		__frwr_sendcompletion_flush(wc, "fastreg");
 	}
 }
@@ -307,14 +307,14 @@
 static void
 frwr_wc_localinv(struct ib_cq *cq, struct ib_wc *wc)
 {
-	struct rpcrdma_frmr *frmr;
+	struct rpcrdma_frwr *frwr;
 	struct ib_cqe *cqe;
 
 	/* WARNING: Only wr_cqe and status are reliable at this point */
 	if (wc->status != IB_WC_SUCCESS) {
 		cqe = wc->wr_cqe;
-		frmr = container_of(cqe, struct rpcrdma_frmr, fr_cqe);
-		frmr->fr_state = FRMR_FLUSHED_LI;
+		frwr = container_of(cqe, struct rpcrdma_frwr, fr_cqe);
+		frwr->fr_state = FRWR_FLUSHED_LI;
 		__frwr_sendcompletion_flush(wc, "localinv");
 	}
 }
@@ -329,17 +329,17 @@
 static void
 frwr_wc_localinv_wake(struct ib_cq *cq, struct ib_wc *wc)
 {
-	struct rpcrdma_frmr *frmr;
+	struct rpcrdma_frwr *frwr;
 	struct ib_cqe *cqe;
 
 	/* WARNING: Only wr_cqe and status are reliable at this point */
 	cqe = wc->wr_cqe;
-	frmr = container_of(cqe, struct rpcrdma_frmr, fr_cqe);
+	frwr = container_of(cqe, struct rpcrdma_frwr, fr_cqe);
 	if (wc->status != IB_WC_SUCCESS) {
-		frmr->fr_state = FRMR_FLUSHED_LI;
+		frwr->fr_state = FRWR_FLUSHED_LI;
 		__frwr_sendcompletion_flush(wc, "localinv");
 	}
-	complete(&frmr->fr_linv_done);
+	complete(&frwr->fr_linv_done);
 }
 
 /* Post a REG_MR Work Request to register a memory region
@@ -351,8 +351,8 @@
 {
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	bool holes_ok = ia->ri_mrtype == IB_MR_TYPE_SG_GAPS;
+	struct rpcrdma_frwr *frwr;
 	struct rpcrdma_mw *mw;
-	struct rpcrdma_frmr *frmr;
 	struct ib_mr *mr;
 	struct ib_reg_wr *reg_wr;
 	struct ib_send_wr *bad_wr;
@@ -366,14 +366,13 @@
 		mw = rpcrdma_get_mw(r_xprt);
 		if (!mw)
 			return ERR_PTR(-ENOBUFS);
-	} while (mw->frmr.fr_state != FRMR_IS_INVALID);
-	frmr = &mw->frmr;
-	frmr->fr_state = FRMR_IS_VALID;
-	mr = frmr->fr_mr;
-	reg_wr = &frmr->fr_regwr;
-
-	if (nsegs > ia->ri_max_frmr_depth)
-		nsegs = ia->ri_max_frmr_depth;
+	} while (mw->frwr.fr_state != FRWR_IS_INVALID);
+	frwr = &mw->frwr;
+	frwr->fr_state = FRWR_IS_VALID;
+	mr = frwr->fr_mr;
+
+	if (nsegs > ia->ri_max_frwr_depth)
+		nsegs = ia->ri_max_frwr_depth;
 	for (i = 0; i < nsegs;) {
 		if (seg->mr_page)
 			sg_set_page(&mw->mw_sg[i],
@@ -402,16 +401,17 @@
 	if (unlikely(n != mw->mw_nents))
 		goto out_mapmr_err;
 
-	dprintk("RPC:       %s: Using frmr %p to map %u segments (%llu bytes)\n",
-		__func__, frmr, mw->mw_nents, mr->length);
+	dprintk("RPC:       %s: Using frwr %p to map %u segments (%llu bytes)\n",
+		__func__, frwr, mw->mw_nents, mr->length);
 
 	key = (u8)(mr->rkey & 0x000000FF);
 	ib_update_fast_reg_key(mr, ++key);
 
+	reg_wr = &frwr->fr_regwr;
 	reg_wr->wr.next = NULL;
 	reg_wr->wr.opcode = IB_WR_REG_MR;
-	frmr->fr_cqe.done = frwr_wc_fastreg;
-	reg_wr->wr.wr_cqe = &frmr->fr_cqe;
+	frwr->fr_cqe.done = frwr_wc_fastreg;
+	reg_wr->wr.wr_cqe = &frwr->fr_cqe;
 	reg_wr->wr.num_sge = 0;
 	reg_wr->wr.send_flags = 0;
 	reg_wr->mr = mr;
@@ -434,18 +434,18 @@
 out_dmamap_err:
 	pr_err("rpcrdma: failed to DMA map sg %p sg_nents %d\n",
 	       mw->mw_sg, i);
-	frmr->fr_state = FRMR_IS_INVALID;
+	frwr->fr_state = FRWR_IS_INVALID;
 	rpcrdma_put_mw(r_xprt, mw);
 	return ERR_PTR(-EIO);
 
 out_mapmr_err:
 	pr_err("rpcrdma: failed to map mr %p (%d/%d)\n",
-	       frmr->fr_mr, n, mw->mw_nents);
+	       frwr->fr_mr, n, mw->mw_nents);
 	rpcrdma_defer_mr_recovery(mw);
 	return ERR_PTR(-EIO);
 
 out_senderr:
-	pr_err("rpcrdma: FRMR registration ib_post_send returned %i\n", rc);
+	pr_err("rpcrdma: FRWR registration ib_post_send returned %i\n", rc);
 	rpcrdma_defer_mr_recovery(mw);
 	return ERR_PTR(-ENOTCONN);
 }
@@ -462,7 +462,7 @@
 			struct rpcrdma_xprt *r_xprt = mw->mw_xprt;
 
 			list_del(&mw->mw_list);
-			mw->frmr.fr_state = FRMR_IS_INVALID;
+			mw->frwr.fr_state = FRWR_IS_INVALID;
 			ib_dma_unmap_sg(r_xprt->rx_ia.ri_device,
 					mw->mw_sg, mw->mw_nents, mw->mw_dir);
 			rpcrdma_put_mw(r_xprt, mw);
@@ -483,7 +483,7 @@
 {
 	struct ib_send_wr *first, **prev, *last, *bad_wr;
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
-	struct rpcrdma_frmr *f;
+	struct rpcrdma_frwr *frwr;
 	struct rpcrdma_mw *mw;
 	int count, rc;
 
@@ -492,20 +492,20 @@
 	 * Chain the LOCAL_INV Work Requests and post them with
 	 * a single ib_post_send() call.
 	 */
-	f = NULL;
+	frwr = NULL;
 	count = 0;
 	prev = &first;
 	list_for_each_entry(mw, mws, mw_list) {
-		mw->frmr.fr_state = FRMR_IS_INVALID;
+		mw->frwr.fr_state = FRWR_IS_INVALID;
 
-		f = &mw->frmr;
-		dprintk("RPC:       %s: invalidating frmr %p\n",
-			__func__, f);
+		frwr = &mw->frwr;
+		dprintk("RPC:       %s: invalidating frwr %p\n",
+			__func__, frwr);
 
-		f->fr_cqe.done = frwr_wc_localinv;
-		last = &f->fr_invwr;
+		frwr->fr_cqe.done = frwr_wc_localinv;
+		last = &frwr->fr_invwr;
 		memset(last, 0, sizeof(*last));
-		last->wr_cqe = &f->fr_cqe;
+		last->wr_cqe = &frwr->fr_cqe;
 		last->opcode = IB_WR_LOCAL_INV;
 		last->ex.invalidate_rkey = mw->mw_handle;
 		count++;
@@ -513,7 +513,7 @@
 		*prev = last;
 		prev = &last->next;
 	}
-	if (!f)
+	if (!frwr)
 		goto unmap;
 
 	/* Strong send queue ordering guarantees that when the
@@ -521,8 +521,8 @@
 	 * are complete.
 	 */
 	last->send_flags = IB_SEND_SIGNALED;
-	f->fr_cqe.done = frwr_wc_localinv_wake;
-	reinit_completion(&f->fr_linv_done);
+	frwr->fr_cqe.done = frwr_wc_localinv_wake;
+	reinit_completion(&frwr->fr_linv_done);
 
 	/* Transport disconnect drains the receive CQ before it
 	 * replaces the QP. The RPC reply handler won't call us
@@ -532,7 +532,7 @@
 	bad_wr = NULL;
 	rc = ib_post_send(ia->ri_id->qp, first, &bad_wr);
 	if (bad_wr != first)
-		wait_for_completion(&f->fr_linv_done);
+		wait_for_completion(&frwr->fr_linv_done);
 	if (rc)
 		goto reset_mrs;
 
@@ -542,8 +542,8 @@
 unmap:
 	while (!list_empty(mws)) {
 		mw = rpcrdma_pop_mw(mws);
-		dprintk("RPC:       %s: DMA unmapping frmr %p\n",
-			__func__, &mw->frmr);
+		dprintk("RPC:       %s: DMA unmapping frwr %p\n",
+			__func__, &mw->frwr);
 		ib_dma_unmap_sg(ia->ri_device,
 				mw->mw_sg, mw->mw_nents, mw->mw_dir);
 		rpcrdma_put_mw(r_xprt, mw);
@@ -551,15 +551,15 @@
 	return;
 
 reset_mrs:
-	pr_err("rpcrdma: FRMR invalidate ib_post_send returned %i\n", rc);
+	pr_err("rpcrdma: FRWR invalidate ib_post_send returned %i\n", rc);
 
 	/* Find and reset the MRs in the LOCAL_INV WRs that did not
 	 * get posted.
 	 */
 	while (bad_wr) {
-		f = container_of(bad_wr, struct rpcrdma_frmr,
-				 fr_invwr);
-		mw = container_of(f, struct rpcrdma_mw, frmr);
+		frwr = container_of(bad_wr, struct rpcrdma_frwr,
+				    fr_invwr);
+		mw = container_of(frwr, struct rpcrdma_mw, frwr);
 
 		__frwr_reset_mr(ia, mw);
 
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index be8c4e6..ddf0d87 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -67,7 +67,7 @@
 static unsigned int xprt_rdma_slot_table_entries = RPCRDMA_DEF_SLOT_TABLE;
 unsigned int xprt_rdma_max_inline_read = RPCRDMA_DEF_INLINE;
 static unsigned int xprt_rdma_max_inline_write = RPCRDMA_DEF_INLINE;
-unsigned int xprt_rdma_memreg_strategy		= RPCRDMA_FRMR;
+unsigned int xprt_rdma_memreg_strategy		= RPCRDMA_FRWR;
 int xprt_rdma_pad_optimize;
 
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index d6c737d..8405799 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -388,7 +388,7 @@
 	}
 
 	switch (xprt_rdma_memreg_strategy) {
-	case RPCRDMA_FRMR:
+	case RPCRDMA_FRWR:
 		if (frwr_is_supported(ia)) {
 			ia->ri_ops = &rpcrdma_frwr_memreg_ops;
 			break;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index e084130..f52269a 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -73,7 +73,7 @@ struct rpcrdma_ia {
 	struct completion	ri_remove_done;
 	int			ri_async_rc;
 	unsigned int		ri_max_segs;
-	unsigned int		ri_max_frmr_depth;
+	unsigned int		ri_max_frwr_depth;
 	unsigned int		ri_max_inline_write;
 	unsigned int		ri_max_inline_read;
 	unsigned int		ri_max_send_sges;
@@ -242,17 +242,17 @@ enum {
  * rpcrdma_deregister_external() uses this metadata to unmap and
  * release these resources when an RPC is complete.
  */
-enum rpcrdma_frmr_state {
-	FRMR_IS_INVALID,	/* ready to be used */
-	FRMR_IS_VALID,		/* in use */
-	FRMR_FLUSHED_FR,	/* flushed FASTREG WR */
-	FRMR_FLUSHED_LI,	/* flushed LOCALINV WR */
+enum rpcrdma_frwr_state {
+	FRWR_IS_INVALID,	/* ready to be used */
+	FRWR_IS_VALID,		/* in use */
+	FRWR_FLUSHED_FR,	/* flushed FASTREG WR */
+	FRWR_FLUSHED_LI,	/* flushed LOCALINV WR */
 };
 
-struct rpcrdma_frmr {
+struct rpcrdma_frwr {
 	struct ib_mr			*fr_mr;
 	struct ib_cqe			fr_cqe;
-	enum rpcrdma_frmr_state		fr_state;
+	enum rpcrdma_frwr_state		fr_state;
 	struct completion		fr_linv_done;
 	union {
 		struct ib_reg_wr	fr_regwr;
@@ -272,7 +272,7 @@ struct rpcrdma_mw {
 	enum dma_data_direction	mw_dir;
 	union {
 		struct rpcrdma_fmr	fmr;
-		struct rpcrdma_frmr	frmr;
+		struct rpcrdma_frwr	frwr;
 	};
 	struct rpcrdma_xprt	*mw_xprt;
 	u32			mw_handle;


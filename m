Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f194.google.com ([209.85.213.194]:35226 "EHLO
	mail-ig0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749AbcBLVG4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Feb 2016 16:06:56 -0500
Subject: [PATCH v1 7/8] xprtrdma: Use an anonymous union in struct rpcrdma_mw
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 12 Feb 2016 16:06:51 -0500
Message-ID: <20160212210651.5278.31825.stgit@manet.1015granger.net>
In-Reply-To: <20160212205107.5278.55938.stgit@manet.1015granger.net>
References: <20160212205107.5278.55938.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Make code more readable.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c   |   28 +++++++++++++-------------
 net/sunrpc/xprtrdma/frwr_ops.c  |   42 ++++++++++++++++++++-------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 +-
 3 files changed, 36 insertions(+), 36 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index c14f3a4..b289e10 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -80,13 +80,13 @@ fmr_op_init(struct rpcrdma_xprt *r_xprt)
 		if (!r)
 			goto out;
 
-		r->r.fmr.physaddrs = kmalloc(RPCRDMA_MAX_FMR_SGES *
-					     sizeof(u64), GFP_KERNEL);
-		if (!r->r.fmr.physaddrs)
+		r->fmr.physaddrs = kmalloc(RPCRDMA_MAX_FMR_SGES *
+					   sizeof(u64), GFP_KERNEL);
+		if (!r->fmr.physaddrs)
 			goto out_free;
 
-		r->r.fmr.fmr = ib_alloc_fmr(pd, mr_access_flags, &fmr_attr);
-		if (IS_ERR(r->r.fmr.fmr))
+		r->fmr.fmr = ib_alloc_fmr(pd, mr_access_flags, &fmr_attr);
+		if (IS_ERR(r->fmr.fmr))
 			goto out_fmr_err;
 
 		list_add(&r->mw_list, &buf->rb_mws);
@@ -95,9 +95,9 @@ fmr_op_init(struct rpcrdma_xprt *r_xprt)
 	return 0;
 
 out_fmr_err:
-	rc = PTR_ERR(r->r.fmr.fmr);
+	rc = PTR_ERR(r->fmr.fmr);
 	dprintk("RPC:       %s: ib_alloc_fmr status %i\n", __func__, rc);
-	kfree(r->r.fmr.physaddrs);
+	kfree(r->fmr.physaddrs);
 out_free:
 	kfree(r);
 out:
@@ -109,7 +109,7 @@ __fmr_unmap(struct rpcrdma_mw *r)
 {
 	LIST_HEAD(l);
 
-	list_add(&r->r.fmr.fmr->list, &l);
+	list_add(&r->fmr.fmr->list, &l);
 	return ib_unmap_fmr(&l);
 }
 
@@ -148,7 +148,7 @@ fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 		nsegs = RPCRDMA_MAX_FMR_SGES;
 	for (i = 0; i < nsegs;) {
 		rpcrdma_map_one(device, seg, direction);
-		mw->r.fmr.physaddrs[i] = seg->mr_dma;
+		mw->fmr.physaddrs[i] = seg->mr_dma;
 		len += seg->mr_len;
 		++seg;
 		++i;
@@ -158,13 +158,13 @@ fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 			break;
 	}
 
-	rc = ib_map_phys_fmr(mw->r.fmr.fmr, mw->r.fmr.physaddrs,
+	rc = ib_map_phys_fmr(mw->fmr.fmr, mw->fmr.physaddrs,
 			     i, seg1->mr_dma);
 	if (rc)
 		goto out_maperr;
 
 	seg1->rl_mw = mw;
-	seg1->mr_rkey = mw->r.fmr.fmr->rkey;
+	seg1->mr_rkey = mw->fmr.fmr->rkey;
 	seg1->mr_base = seg1->mr_dma + pageoff;
 	seg1->mr_nsegs = i;
 	seg1->mr_len = len;
@@ -219,7 +219,7 @@ fmr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 		seg = &req->rl_segments[i];
 		mw = seg->rl_mw;
 
-		list_add(&mw->r.fmr.fmr->list, &unmap_list);
+		list_add(&mw->fmr.fmr->list, &unmap_list);
 
 		i += seg->mr_nsegs;
 	}
@@ -281,9 +281,9 @@ fmr_op_destroy(struct rpcrdma_buffer *buf)
 	while (!list_empty(&buf->rb_all)) {
 		r = list_entry(buf->rb_all.next, struct rpcrdma_mw, mw_all);
 		list_del(&r->mw_all);
-		kfree(r->r.fmr.physaddrs);
+		kfree(r->fmr.physaddrs);
 
-		rc = ib_dealloc_fmr(r->r.fmr.fmr);
+		rc = ib_dealloc_fmr(r->fmr.fmr);
 		if (rc)
 			dprintk("RPC:       %s: ib_dealloc_fmr failed %i\n",
 				__func__, rc);
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index e165673..23382fa 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -109,20 +109,20 @@ static void
 __frwr_recovery_worker(struct work_struct *work)
 {
 	struct rpcrdma_mw *r = container_of(work, struct rpcrdma_mw,
-					    r.frmr.fr_work);
-	struct rpcrdma_xprt *r_xprt = r->r.frmr.fr_xprt;
+					    frmr.fr_work);
+	struct rpcrdma_xprt *r_xprt = r->frmr.fr_xprt;
 	unsigned int depth = r_xprt->rx_ia.ri_max_frmr_depth;
 	struct ib_pd *pd = r_xprt->rx_ia.ri_pd;
 
-	if (ib_dereg_mr(r->r.frmr.fr_mr))
+	if (ib_dereg_mr(r->frmr.fr_mr))
 		goto out_fail;
 
-	r->r.frmr.fr_mr = ib_alloc_mr(pd, IB_MR_TYPE_MEM_REG, depth);
-	if (IS_ERR(r->r.frmr.fr_mr))
+	r->frmr.fr_mr = ib_alloc_mr(pd, IB_MR_TYPE_MEM_REG, depth);
+	if (IS_ERR(r->frmr.fr_mr))
 		goto out_fail;
 
 	dprintk("RPC:       %s: recovered FRMR %p\n", __func__, r);
-	r->r.frmr.fr_state = FRMR_IS_INVALID;
+	r->frmr.fr_state = FRMR_IS_INVALID;
 	rpcrdma_put_mw(r_xprt, r);
 	return;
 
@@ -137,15 +137,15 @@ out_fail:
 static void
 __frwr_queue_recovery(struct rpcrdma_mw *r)
 {
-	INIT_WORK(&r->r.frmr.fr_work, __frwr_recovery_worker);
-	queue_work(frwr_recovery_wq, &r->r.frmr.fr_work);
+	INIT_WORK(&r->frmr.fr_work, __frwr_recovery_worker);
+	queue_work(frwr_recovery_wq, &r->frmr.fr_work);
 }
 
 static int
 __frwr_init(struct rpcrdma_mw *r, struct ib_pd *pd, struct ib_device *device,
 	    unsigned int depth)
 {
-	struct rpcrdma_frmr *f = &r->r.frmr;
+	struct rpcrdma_frmr *f = &r->frmr;
 	int rc;
 
 	f->fr_mr = ib_alloc_mr(pd, IB_MR_TYPE_MEM_REG, depth);
@@ -179,11 +179,11 @@ __frwr_release(struct rpcrdma_mw *r)
 {
 	int rc;
 
-	rc = ib_dereg_mr(r->r.frmr.fr_mr);
+	rc = ib_dereg_mr(r->frmr.fr_mr);
 	if (rc)
 		dprintk("RPC:       %s: ib_dereg_mr status %i\n",
 			__func__, rc);
-	kfree(r->r.frmr.sg);
+	kfree(r->frmr.sg);
 }
 
 static int
@@ -263,14 +263,14 @@ __frwr_sendcompletion_flush(struct ib_wc *wc, struct rpcrdma_mw *r)
 		pr_warn("RPC:       %s: frmr %p error, status %s (%d)\n",
 			__func__, r, ib_wc_status_msg(wc->status), wc->status);
 
-	r->r.frmr.fr_state = FRMR_IS_STALE;
+	r->frmr.fr_state = FRMR_IS_STALE;
 }
 
 static void
 frwr_sendcompletion(struct ib_wc *wc)
 {
 	struct rpcrdma_mw *r = (struct rpcrdma_mw *)(unsigned long)wc->wr_id;
-	struct rpcrdma_frmr *f = &r->r.frmr;
+	struct rpcrdma_frmr *f = &r->frmr;
 
 	if (unlikely(wc->status != IB_WC_SUCCESS))
 		__frwr_sendcompletion_flush(wc, r);
@@ -314,7 +314,7 @@ frwr_op_init(struct rpcrdma_xprt *r_xprt)
 		list_add(&r->mw_list, &buf->rb_mws);
 		list_add(&r->mw_all, &buf->rb_all);
 		r->mw_sendcompletion = frwr_sendcompletion;
-		r->r.frmr.fr_xprt = r_xprt;
+		r->frmr.fr_xprt = r_xprt;
 	}
 
 	return 0;
@@ -347,8 +347,8 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 		mw = rpcrdma_get_mw(r_xprt);
 		if (!mw)
 			return -ENOMEM;
-	} while (mw->r.frmr.fr_state != FRMR_IS_INVALID);
-	frmr = &mw->r.frmr;
+	} while (mw->frmr.fr_state != FRMR_IS_INVALID);
+	frmr = &mw->frmr;
 	frmr->fr_state = FRMR_IS_VALID;
 	frmr->fr_waiter = false;
 	mr = frmr->fr_mr;
@@ -434,7 +434,7 @@ static struct ib_send_wr *
 __frwr_prepare_linv_wr(struct rpcrdma_mr_seg *seg)
 {
 	struct rpcrdma_mw *mw = seg->rl_mw;
-	struct rpcrdma_frmr *f = &mw->r.frmr;
+	struct rpcrdma_frmr *f = &mw->frmr;
 	struct ib_send_wr *invalidate_wr;
 
 	f->fr_waiter = false;
@@ -455,7 +455,7 @@ __frwr_dma_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 {
 	struct ib_device *device = r_xprt->rx_ia.ri_device;
 	struct rpcrdma_mw *mw = seg->rl_mw;
-	struct rpcrdma_frmr *f = &mw->r.frmr;
+	struct rpcrdma_frmr *f = &mw->frmr;
 
 	seg->rl_mw = NULL;
 
@@ -504,7 +504,7 @@ frwr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 
 		i += seg->mr_nsegs;
 	}
-	f = &seg->rl_mw->r.frmr;
+	f = &seg->rl_mw->frmr;
 
 	/* Strong send queue ordering guarantees that when the
 	 * last WR in the chain completes, all WRs in the chain
@@ -549,7 +549,7 @@ frwr_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
 	struct rpcrdma_mr_seg *seg1 = seg;
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	struct rpcrdma_mw *mw = seg1->rl_mw;
-	struct rpcrdma_frmr *frmr = &mw->r.frmr;
+	struct rpcrdma_frmr *frmr = &mw->frmr;
 	struct ib_send_wr *invalidate_wr, *bad_wr;
 	int rc, nsegs = seg->mr_nsegs;
 
@@ -557,7 +557,7 @@ frwr_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
 
 	seg1->rl_mw = NULL;
 	frmr->fr_state = FRMR_IS_INVALID;
-	invalidate_wr = &mw->r.frmr.fr_invwr;
+	invalidate_wr = &mw->frmr.fr_invwr;
 
 	memset(invalidate_wr, 0, sizeof(*invalidate_wr));
 	invalidate_wr->wr_id = (uintptr_t)mw;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 7d87cdc..4be4c9b 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -225,7 +225,7 @@ struct rpcrdma_mw {
 	union {
 		struct rpcrdma_fmr	fmr;
 		struct rpcrdma_frmr	frmr;
-	} r;
+	};
 	void			(*mw_sendcompletion)(struct ib_wc *);
 	struct list_head	mw_list;
 	struct list_head	mw_all;


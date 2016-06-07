Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36116 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752832AbcFGTqx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2016 15:46:53 -0400
Subject: [PATCH v1 04/20] xprtrdma: Use scatterlist for DMA mapping and
 unmapping under FMR
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 07 Jun 2016 15:46:51 -0400
Message-ID: <20160607194651.18401.63235.stgit@manet.1015granger.net>
In-Reply-To: <20160607194001.18401.88592.stgit@manet.1015granger.net>
References: <20160607194001.18401.88592.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The use of a scatterlist for handling DMA mapping and unmapping
was recently introduced in frwr_ops.c in commit 4143f34e01e9
("xprtrdma: Port to new memory registration API"). That commit did
not make a similar update to xprtrdma's FMR support because the
core ib_map_phys_fmr() and ib_unmap_fmr() APIs have not been changed
to take a scatterlist argument.

However, FMR still needs to do DMA mapping and unmapping. It appears
that RDS, for example, uses a scatterlist for this, then builds the
DMA addr array for the ib_map_phys_fmr call separately. We can do
something similar.

This modernization can be used immediately to properly defer DMA
unmapping during fmr_unmap_safe (a FIXME). It separates the DMA
unmapping coordinates from the rl_segments array. This array, being
part of an rpcrdma_req, is always re-used immediately when an RPC
exits. A scatterlist is allocated in memory independent of the
rl_segments array, so it can be preserved indefinitely (ie, until
the MR invalidation and DMA unmapping can actually be done by a
worker thread).

The FRWR and FMR DMA mapping code are slightly different from each
other now, and will diverge further when the "Check for holes" logic
can be removed from FRWR. So I chose not to create helpers for the
common-looking code.

Fixes: ead3f26e359e ("xprtrdma: Add ro_unmap_safe memreg method")
Suggested-by: Sagi Grimberg <sagi@lightbits.io>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c   |  160 ++++++++++++++++++++++++---------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    4 -
 2 files changed, 100 insertions(+), 64 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index b8952c7..b581a28 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -64,10 +64,35 @@ __fmr_unmap(struct rpcrdma_mw *mw)
 {
 	LIST_HEAD(l);
 
-	list_add(&mw->fmr.fmr->list, &l);
+	list_add(&mw->fmr.fm_mr->list, &l);
 	return ib_unmap_fmr(&l);
 }
 
+static void
+__fmr_dma_unmap(struct rpcrdma_mw *mw)
+{
+	struct rpcrdma_xprt *r_xprt = mw->mw_xprt;
+
+	ib_dma_unmap_sg(r_xprt->rx_ia.ri_device,
+			mw->mw_sg, mw->mw_nents, mw->mw_dir);
+	rpcrdma_put_mw(r_xprt, mw);
+}
+
+static void
+__fmr_reset_and_unmap(struct rpcrdma_mw *mw)
+{
+	int rc;
+
+	/* ORDER */
+	rc = __fmr_unmap(mw);
+	if (rc) {
+		pr_warn("rpcrdma: ib_unmap_fmr status %d, fmr %p orphaned\n",
+			rc, mw);
+		return;
+	}
+	__fmr_dma_unmap(mw);
+ }
+
 /* Deferred reset of a single FMR. Generate a fresh rkey by
  * replacing the MR. There's no recovery if this fails.
  */
@@ -75,11 +100,9 @@ static void
 __fmr_recovery_worker(struct work_struct *work)
 {
 	struct rpcrdma_mw *mw = container_of(work, struct rpcrdma_mw,
-					    mw_work);
-	struct rpcrdma_xprt *r_xprt = mw->mw_xprt;
+					     mw_work);
 
-	__fmr_unmap(mw);
-	rpcrdma_put_mw(r_xprt, mw);
+	__fmr_reset_and_unmap(mw);
 	return;
 }
 
@@ -93,6 +116,22 @@ __fmr_queue_recovery(struct rpcrdma_mw *mw)
 	queue_work(fmr_recovery_wq, &mw->mw_work);
 }
 
+static void
+__fmr_release(struct rpcrdma_mw *r)
+{
+	int rc;
+
+	kfree(r->fmr.fm_physaddrs);
+	kfree(r->mw_sg);
+
+	rc = ib_dealloc_fmr(r->fmr.fm_mr);
+	if (rc)
+		dprintk("RPC:       %s: ib_dealloc_fmr failed %i\n",
+			__func__, rc);
+
+	kfree(r);
+}
+
 static int
 fmr_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
 	    struct rpcrdma_create_data_internal *cdata)
@@ -137,13 +176,20 @@ fmr_op_init(struct rpcrdma_xprt *r_xprt)
 		if (!r)
 			goto out;
 
-		r->fmr.physaddrs = kmalloc(RPCRDMA_MAX_FMR_SGES *
-					   sizeof(u64), GFP_KERNEL);
-		if (!r->fmr.physaddrs)
+		r->fmr.fm_physaddrs = kcalloc(RPCRDMA_MAX_FMR_SGES,
+					      sizeof(u64), GFP_KERNEL);
+		if (!r->fmr.fm_physaddrs)
 			goto out_free;
 
-		r->fmr.fmr = ib_alloc_fmr(pd, mr_access_flags, &fmr_attr);
-		if (IS_ERR(r->fmr.fmr))
+		r->mw_sg = kcalloc(RPCRDMA_MAX_FMR_SGES,
+				    sizeof(*r->mw_sg), GFP_KERNEL);
+		if (!r->mw_sg)
+			goto out_free;
+
+		sg_init_table(r->mw_sg, RPCRDMA_MAX_FMR_SGES);
+
+		r->fmr.fm_mr = ib_alloc_fmr(pd, mr_access_flags, &fmr_attr);
+		if (IS_ERR(r->fmr.fm_mr))
 			goto out_fmr_err;
 
 		r->mw_xprt = r_xprt;
@@ -153,10 +199,11 @@ fmr_op_init(struct rpcrdma_xprt *r_xprt)
 	return 0;
 
 out_fmr_err:
-	rc = PTR_ERR(r->fmr.fmr);
+	rc = PTR_ERR(r->fmr.fm_mr);
 	dprintk("RPC:       %s: ib_alloc_fmr status %i\n", __func__, rc);
-	kfree(r->fmr.physaddrs);
 out_free:
+	kfree(r->mw_sg);
+	kfree(r->fmr.fm_physaddrs);
 	kfree(r);
 out:
 	return rc;
@@ -169,12 +216,10 @@ static int
 fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	   int nsegs, bool writing)
 {
-	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
-	struct ib_device *device = ia->ri_device;
-	enum dma_data_direction direction = rpcrdma_data_dir(writing);
 	struct rpcrdma_mr_seg *seg1 = seg;
 	int len, pageoff, i, rc;
 	struct rpcrdma_mw *mw;
+	u64 *dma_pages;
 
 	mw = seg1->rl_mw;
 	seg1->rl_mw = NULL;
@@ -196,8 +241,14 @@ fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	if (nsegs > RPCRDMA_MAX_FMR_SGES)
 		nsegs = RPCRDMA_MAX_FMR_SGES;
 	for (i = 0; i < nsegs;) {
-		rpcrdma_map_one(device, seg, direction);
-		mw->fmr.physaddrs[i] = seg->mr_dma;
+		if (seg->mr_page)
+			sg_set_page(&mw->mw_sg[i],
+				    seg->mr_page,
+				    seg->mr_len,
+				    offset_in_page(seg->mr_offset));
+		else
+			sg_set_buf(&mw->mw_sg[i], seg->mr_offset,
+				   seg->mr_len);
 		len += seg->mr_len;
 		++seg;
 		++i;
@@ -206,38 +257,40 @@ fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 		    offset_in_page((seg-1)->mr_offset + (seg-1)->mr_len))
 			break;
 	}
+	mw->mw_nents = i;
+	mw->mw_dir = rpcrdma_data_dir(writing);
 
-	rc = ib_map_phys_fmr(mw->fmr.fmr, mw->fmr.physaddrs,
-			     i, seg1->mr_dma);
+	if (!ib_dma_map_sg(r_xprt->rx_ia.ri_device,
+			   mw->mw_sg, mw->mw_nents, mw->mw_dir))
+		goto out_dmamap_err;
+
+	for (i = 0, dma_pages = mw->fmr.fm_physaddrs; i < mw->mw_nents; i++)
+		dma_pages[i] = sg_dma_address(&mw->mw_sg[i]);
+	rc = ib_map_phys_fmr(mw->fmr.fm_mr, dma_pages, mw->mw_nents,
+			     dma_pages[0]);
 	if (rc)
 		goto out_maperr;
 
 	seg1->rl_mw = mw;
-	seg1->mr_rkey = mw->fmr.fmr->rkey;
-	seg1->mr_base = seg1->mr_dma + pageoff;
-	seg1->mr_nsegs = i;
+	seg1->mr_rkey = mw->fmr.fm_mr->rkey;
+	seg1->mr_base = dma_pages[0] + pageoff;
+	seg1->mr_nsegs = mw->mw_nents;
 	seg1->mr_len = len;
-	return i;
+	return mw->mw_nents;
+
+out_dmamap_err:
+	pr_err("rpcrdma: failed to dma map sg %p sg_nents %u\n",
+	       mw->mw_sg, mw->mw_nents);
+	return -ENOMEM;
 
 out_maperr:
-	dprintk("RPC:       %s: ib_map_phys_fmr %u@0x%llx+%i (%d) status %i\n",
-		__func__, len, (unsigned long long)seg1->mr_dma,
-		pageoff, i, rc);
-	while (i--)
-		rpcrdma_unmap_one(device, --seg);
+	pr_err("rpcrdma: ib_map_phys_fmr %u@0x%llx+%i (%d) status %i\n",
+	       len, (unsigned long long)dma_pages[0],
+	       pageoff, mw->mw_nents, rc);
+	__fmr_dma_unmap(mw);
 	return rc;
 }
 
-static void
-__fmr_dma_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
-{
-	struct ib_device *device = r_xprt->rx_ia.ri_device;
-	int nsegs = seg->mr_nsegs;
-
-	while (nsegs--)
-		rpcrdma_unmap_one(device, seg++);
-}
-
 /* Invalidate all memory regions that were registered for "req".
  *
  * Sleeps until it is safe for the host CPU to access the
@@ -263,7 +316,7 @@ fmr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 		seg = &req->rl_segments[i];
 		mw = seg->rl_mw;
 
-		list_add(&mw->fmr.fmr->list, &unmap_list);
+		list_add(&mw->fmr.fm_mr->list, &unmap_list);
 
 		i += seg->mr_nsegs;
 	}
@@ -276,9 +329,9 @@ fmr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 	 */
 	for (i = 0, nchunks = req->rl_nchunks; nchunks; nchunks--) {
 		seg = &req->rl_segments[i];
+		mw = seg->rl_mw;
 
-		__fmr_dma_unmap(r_xprt, seg);
-		rpcrdma_put_mw(r_xprt, seg->rl_mw);
+		__fmr_dma_unmap(mw);
 
 		i += seg->mr_nsegs;
 		seg->mr_nsegs = 0;
@@ -290,11 +343,6 @@ fmr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 
 /* Use a slow, safe mechanism to invalidate all memory regions
  * that were registered for "req".
- *
- * In the asynchronous case, DMA unmapping occurs first here
- * because the rpcrdma_mr_seg is released immediately after this
- * call. It's contents won't be available in __fmr_dma_unmap later.
- * FIXME.
  */
 static void
 fmr_op_unmap_safe(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
@@ -308,15 +356,10 @@ fmr_op_unmap_safe(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 		seg = &req->rl_segments[i];
 		mw = seg->rl_mw;
 
-		if (sync) {
-			/* ORDER */
-			__fmr_unmap(mw);
-			__fmr_dma_unmap(r_xprt, seg);
-			rpcrdma_put_mw(r_xprt, mw);
-		} else {
-			__fmr_dma_unmap(r_xprt, seg);
+		if (sync)
+			__fmr_reset_and_unmap(mw);
+		else
 			__fmr_queue_recovery(mw);
-		}
 
 		i += seg->mr_nsegs;
 		seg->mr_nsegs = 0;
@@ -328,19 +371,12 @@ static void
 fmr_op_destroy(struct rpcrdma_buffer *buf)
 {
 	struct rpcrdma_mw *r;
-	int rc;
 
 	while (!list_empty(&buf->rb_all)) {
 		r = list_entry(buf->rb_all.next, struct rpcrdma_mw, mw_all);
 		list_del(&r->mw_all);
-		kfree(r->fmr.physaddrs);
-
-		rc = ib_dealloc_fmr(r->fmr.fmr);
-		if (rc)
-			dprintk("RPC:       %s: ib_dealloc_fmr failed %i\n",
-				__func__, rc);
 
-		kfree(r);
+		__fmr_release(r);
 	}
 }
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 8c979a4..6378469 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -231,8 +231,8 @@ struct rpcrdma_frmr {
 };
 
 struct rpcrdma_fmr {
-	struct ib_fmr		*fmr;
-	u64			*physaddrs;
+	struct ib_fmr		*fm_mr;
+	u64			*fm_physaddrs;
 };
 
 struct rpcrdma_mw {


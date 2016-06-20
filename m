Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36843 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755600AbcFTQJS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jun 2016 12:09:18 -0400
Subject: [PATCH v3 05/25] xprtrdma: Use scatterlist for DMA mapping and
 unmapping under FMR
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 20 Jun 2016 12:09:15 -0400
Message-ID: <20160620160915.10809.56398.stgit@manet.1015granger.net>
In-Reply-To: <20160620155751.10809.22262.stgit@manet.1015granger.net>
References: <20160620155751.10809.22262.stgit@manet.1015granger.net>
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
DMA addr array for the ib_map_phys_fmr call separately. I see that
SRP also utilizes a scatterlist for DMA mapping. xprtrdma can do
something similar.

This modernization is used immediately to properly defer DMA
unmapping during fmr_unmap_safe (a FIXME). It separates the DMA
unmapping coordinates from the rl_segments array. This array, being
part of an rpcrdma_req, is always re-used immediately when an RPC
exits. A scatterlist is allocated in memory independent of the
rl_segments array, so it can be preserved indefinitely (ie, until
the MR invalidation and DMA unmapping can actually be done by a
worker thread).

The FRWR and FMR DMA mapping code are slightly different from each
other now, and will diverge further when the "Check for holes" logic
can be removed from FRWR (support for SG_GAP MRs). So I chose not to
create helpers for the common-looking code.

Fixes: ead3f26e359e ("xprtrdma: Add ro_unmap_safe memreg method")
Suggested-by: Sagi Grimberg <sagi@lightbits.io>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c |   96 ++++++++++++++++++++++++-----------------
 1 file changed, 57 insertions(+), 39 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index a6a67b4..3044593 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -117,13 +117,28 @@ __fmr_unmap(struct rpcrdma_mw *mw)
 }
 
 static void
-__fmr_dma_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
+__fmr_dma_unmap(struct rpcrdma_mw *mw)
 {
-	struct ib_device *device = r_xprt->rx_ia.ri_device;
-	int nsegs = seg->mr_nsegs;
+	struct rpcrdma_xprt *r_xprt = mw->mw_xprt;
 
-	while (nsegs--)
-		rpcrdma_unmap_one(device, seg++);
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
 }
 
 static void
@@ -147,11 +162,9 @@ static void
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
 
@@ -226,12 +239,10 @@ static int
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
@@ -253,8 +264,14 @@ fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	if (nsegs > RPCRDMA_MAX_FMR_SGES)
 		nsegs = RPCRDMA_MAX_FMR_SGES;
 	for (i = 0; i < nsegs;) {
-		rpcrdma_map_one(device, seg, direction);
-		mw->fmr.fm_physaddrs[i] = seg->mr_dma;
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
@@ -263,25 +280,37 @@ fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 		    offset_in_page((seg-1)->mr_offset + (seg-1)->mr_len))
 			break;
 	}
+	mw->mw_nents = i;
+	mw->mw_dir = rpcrdma_data_dir(writing);
+
+	if (!ib_dma_map_sg(r_xprt->rx_ia.ri_device,
+			   mw->mw_sg, mw->mw_nents, mw->mw_dir))
+		goto out_dmamap_err;
 
-	rc = ib_map_phys_fmr(mw->fmr.fm_mr, mw->fmr.fm_physaddrs,
-			     i, seg1->mr_dma);
+	for (i = 0, dma_pages = mw->fmr.fm_physaddrs; i < mw->mw_nents; i++)
+		dma_pages[i] = sg_dma_address(&mw->mw_sg[i]);
+	rc = ib_map_phys_fmr(mw->fmr.fm_mr, dma_pages, mw->mw_nents,
+			     dma_pages[0]);
 	if (rc)
 		goto out_maperr;
 
 	seg1->rl_mw = mw;
 	seg1->mr_rkey = mw->fmr.fm_mr->rkey;
-	seg1->mr_base = seg1->mr_dma + pageoff;
-	seg1->mr_nsegs = i;
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
 
@@ -326,8 +355,7 @@ fmr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 		mw = seg->rl_mw;
 
 		list_del_init(&mw->fmr.fm_mr->list);
-		__fmr_dma_unmap(r_xprt, seg);
-		rpcrdma_put_mw(r_xprt, seg->rl_mw);
+		__fmr_dma_unmap(mw);
 
 		i += seg->mr_nsegs;
 		seg->mr_nsegs = 0;
@@ -339,11 +367,6 @@ fmr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 
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
@@ -357,15 +380,10 @@ fmr_op_unmap_safe(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
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


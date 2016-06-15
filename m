Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34155 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932473AbcFODR3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2016 23:17:29 -0400
Subject: [PATCH v2 16/24] xprtrdma: Place registered MWs on a per-req list
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 14 Jun 2016 23:17:26 -0400
Message-ID: <20160615031726.14794.85860.stgit@manet.1015granger.net>
In-Reply-To: <20160615030626.14794.43805.stgit@manet.1015granger.net>
References: <20160615030626.14794.43805.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of placing registered MWs sparsely into the rl_segments
array, place these MWs on a per-req list.

ro_unmap_{sync,safe} can then simply pull those MWs off the list
instead of walking through the array.

This change significantly reduces the size of struct rpcrdma_req
by removing nsegs and rl_mw from every array element.

As an additional clean-up, chunk co-ordinates are returned in the
"*mw" output argument so they are no longer needed in every
array element.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c   |   65 ++++++++++---------------------
 net/sunrpc/xprtrdma/frwr_ops.c  |   72 ++++++++++++-----------------------
 net/sunrpc/xprtrdma/rpc_rdma.c  |   81 ++++++++++++++++++---------------------
 net/sunrpc/xprtrdma/transport.c |    3 +
 net/sunrpc/xprtrdma/verbs.c     |    1 
 net/sunrpc/xprtrdma/xprt_rdma.h |   11 +++--
 6 files changed, 94 insertions(+), 139 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 2ad117f..8d23317 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -91,6 +91,10 @@ fmr_op_release_mr(struct rpcrdma_mw *r)
 	LIST_HEAD(unmap_list);
 	int rc;
 
+	/* Ensure MW is not on any rl_registered list */
+	if (!list_empty(&r->mw_list))
+		list_del(&r->mw_list);
+
 	kfree(r->fmr.fm_physaddrs);
 	kfree(r->mw_sg);
 
@@ -166,17 +170,13 @@ fmr_op_maxpages(struct rpcrdma_xprt *r_xprt)
  */
 static int
 fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
-	   int nsegs, bool writing)
+	   int nsegs, bool writing, struct rpcrdma_mw **out)
 {
 	struct rpcrdma_mr_seg *seg1 = seg;
 	int len, pageoff, i, rc;
 	struct rpcrdma_mw *mw;
 	u64 *dma_pages;
 
-	mw = seg1->rl_mw;
-	seg1->rl_mw = NULL;
-	if (mw)
-		rpcrdma_defer_mr_recovery(mw);
 	mw = rpcrdma_get_mw(r_xprt);
 	if (!mw)
 		return -ENOBUFS;
@@ -220,11 +220,11 @@ fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	if (rc)
 		goto out_maperr;
 
-	seg1->rl_mw = mw;
-	seg1->mr_rkey = mw->fmr.fm_mr->rkey;
-	seg1->mr_base = dma_pages[0] + pageoff;
-	seg1->mr_nsegs = mw->mw_nents;
-	seg1->mr_len = len;
+	mw->mw_handle = mw->fmr.fm_mr->rkey;
+	mw->mw_length = len;
+	mw->mw_offset = dma_pages[0] + pageoff;
+
+	*out = mw;
 	return mw->mw_nents;
 
 out_dmamap_err:
@@ -245,13 +245,13 @@ out_maperr:
  *
  * Sleeps until it is safe for the host CPU to access the
  * previously mapped memory regions.
+ *
+ * Caller ensures that req->rl_registered is not empty.
  */
 static void
 fmr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 {
-	struct rpcrdma_mr_seg *seg;
-	unsigned int i, nchunks;
-	struct rpcrdma_mw *mw;
+	struct rpcrdma_mw *mw, *tmp;
 	LIST_HEAD(unmap_list);
 	int rc;
 
@@ -262,14 +262,8 @@ fmr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 	 * ib_unmap_fmr() is slow, so use a single call instead
 	 * of one call per mapped FMR.
 	 */
-	for (i = 0, nchunks = req->rl_nchunks; nchunks; nchunks--) {
-		seg = &req->rl_segments[i];
-		mw = seg->rl_mw;
-
+	list_for_each_entry(mw, &req->rl_registered, mw_list)
 		list_add_tail(&mw->fmr.fm_mr->list, &unmap_list);
-
-		i += seg->mr_nsegs;
-	}
 	rc = ib_unmap_fmr(&unmap_list);
 	if (rc)
 		goto out_reset;
@@ -277,34 +271,22 @@ fmr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 	/* ORDER: Now DMA unmap all of the req's MRs, and return
 	 * them to the free MW list.
 	 */
-	for (i = 0, nchunks = req->rl_nchunks; nchunks; nchunks--) {
-		seg = &req->rl_segments[i];
-		mw = seg->rl_mw;
-
+	list_for_each_entry_safe(mw, tmp, &req->rl_registered, mw_list) {
+		list_del_init(&mw->mw_list);
 		list_del_init(&mw->fmr.fm_mr->list);
 		ib_dma_unmap_sg(r_xprt->rx_ia.ri_device,
 				mw->mw_sg, mw->mw_nents, mw->mw_dir);
 		rpcrdma_put_mw(r_xprt, mw);
-
-		i += seg->mr_nsegs;
-		seg->mr_nsegs = 0;
-		seg->rl_mw = NULL;
 	}
 
-	req->rl_nchunks = 0;
 	return;
 
 out_reset:
 	pr_err("rpcrdma: ib_unmap_fmr failed (%i)\n", rc);
 
-	for (i = 0, nchunks = req->rl_nchunks; nchunks; nchunks--) {
-		seg = &req->rl_segments[i];
-		mw = seg->rl_mw;
-
+	list_for_each_entry_safe(mw, tmp, &req->rl_registered, mw_list) {
 		list_del_init(&mw->fmr.fm_mr->list);
 		fmr_op_recover_mr(mw);
-
-		i += seg->mr_nsegs;
 	}
 }
 
@@ -315,22 +297,17 @@ static void
 fmr_op_unmap_safe(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 		  bool sync)
 {
-	struct rpcrdma_mr_seg *seg;
 	struct rpcrdma_mw *mw;
-	unsigned int i;
 
-	for (i = 0; req->rl_nchunks; req->rl_nchunks--) {
-		seg = &req->rl_segments[i];
-		mw = seg->rl_mw;
+	while (!list_empty(&req->rl_registered)) {
+		mw = list_first_entry(&req->rl_registered,
+				      struct rpcrdma_mw, mw_list);
+		list_del_init(&mw->mw_list);
 
 		if (sync)
 			fmr_op_recover_mr(mw);
 		else
 			rpcrdma_defer_mr_recovery(mw);
-
-		i += seg->mr_nsegs;
-		seg->mr_nsegs = 0;
-		seg->rl_mw = NULL;
 	}
 }
 
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 38de90c..bacb859 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -111,6 +111,10 @@ frwr_op_release_mr(struct rpcrdma_mw *r)
 {
 	int rc;
 
+	/* Ensure MW is not on any rl_registered list */
+	if (!list_empty(&r->mw_list))
+		list_del(&r->mw_list);
+
 	rc = ib_dereg_mr(r->frmr.fr_mr);
 	if (rc)
 		pr_err("rpcrdma: final ib_dereg_mr for %p returned %i\n",
@@ -316,10 +320,9 @@ frwr_wc_localinv_wake(struct ib_cq *cq, struct ib_wc *wc)
  */
 static int
 frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
-	    int nsegs, bool writing)
+	    int nsegs, bool writing, struct rpcrdma_mw **out)
 {
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
-	struct rpcrdma_mr_seg *seg1 = seg;
 	struct rpcrdma_mw *mw;
 	struct rpcrdma_frmr *frmr;
 	struct ib_mr *mr;
@@ -328,8 +331,7 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	int rc, i, n, dma_nents;
 	u8 key;
 
-	mw = seg1->rl_mw;
-	seg1->rl_mw = NULL;
+	mw = NULL;
 	do {
 		if (mw)
 			rpcrdma_defer_mr_recovery(mw);
@@ -399,12 +401,11 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	if (rc)
 		goto out_senderr;
 
-	seg1->rl_mw = mw;
-	seg1->mr_rkey = mr->rkey;
-	seg1->mr_base = mr->iova;
-	seg1->mr_nsegs = mw->mw_nents;
-	seg1->mr_len = mr->length;
+	mw->mw_handle = mr->rkey;
+	mw->mw_length = mr->length;
+	mw->mw_offset = mr->iova;
 
+	*out = mw;
 	return mw->mw_nents;
 
 out_dmamap_err:
@@ -426,9 +427,8 @@ out_senderr:
 }
 
 static struct ib_send_wr *
-__frwr_prepare_linv_wr(struct rpcrdma_mr_seg *seg)
+__frwr_prepare_linv_wr(struct rpcrdma_mw *mw)
 {
-	struct rpcrdma_mw *mw = seg->rl_mw;
 	struct rpcrdma_frmr *f = &mw->frmr;
 	struct ib_send_wr *invalidate_wr;
 
@@ -448,16 +448,16 @@ __frwr_prepare_linv_wr(struct rpcrdma_mr_seg *seg)
  *
  * Sleeps until it is safe for the host CPU to access the
  * previously mapped memory regions.
+ *
+ * Caller ensures that req->rl_registered is not empty.
  */
 static void
 frwr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 {
 	struct ib_send_wr *invalidate_wrs, *pos, *prev, *bad_wr;
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
-	struct rpcrdma_mr_seg *seg;
-	unsigned int i, nchunks;
+	struct rpcrdma_mw *mw, *tmp;
 	struct rpcrdma_frmr *f;
-	struct rpcrdma_mw *mw;
 	int rc;
 
 	dprintk("RPC:       %s: req %p\n", __func__, req);
@@ -467,22 +467,18 @@ frwr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 	 * Chain the LOCAL_INV Work Requests and post them with
 	 * a single ib_post_send() call.
 	 */
+	f = NULL;
 	invalidate_wrs = pos = prev = NULL;
-	seg = NULL;
-	for (i = 0, nchunks = req->rl_nchunks; nchunks; nchunks--) {
-		seg = &req->rl_segments[i];
-
-		pos = __frwr_prepare_linv_wr(seg);
+	list_for_each_entry(mw, &req->rl_registered, mw_list) {
+		pos = __frwr_prepare_linv_wr(mw);
 
 		if (!invalidate_wrs)
 			invalidate_wrs = pos;
 		else
 			prev->next = pos;
 		prev = pos;
-
-		i += seg->mr_nsegs;
+		f = &mw->frmr;
 	}
-	f = &seg->rl_mw->frmr;
 
 	/* Strong send queue ordering guarantees that when the
 	 * last WR in the chain completes, all WRs in the chain
@@ -507,20 +503,12 @@ frwr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 	 * them to the free MW list.
 	 */
 unmap:
-	for (i = 0, nchunks = req->rl_nchunks; nchunks; nchunks--) {
-		seg = &req->rl_segments[i];
-		mw = seg->rl_mw;
-		seg->rl_mw = NULL;
-
+	list_for_each_entry_safe(mw, tmp, &req->rl_registered, mw_list) {
+		list_del_init(&mw->mw_list);
 		ib_dma_unmap_sg(ia->ri_device,
 				mw->mw_sg, mw->mw_nents, mw->mw_dir);
 		rpcrdma_put_mw(r_xprt, mw);
-
-		i += seg->mr_nsegs;
-		seg->mr_nsegs = 0;
 	}
-
-	req->rl_nchunks = 0;
 	return;
 
 reset_mrs:
@@ -530,17 +518,12 @@ reset_mrs:
 	/* Find and reset the MRs in the LOCAL_INV WRs that did not
 	 * get posted. This is synchronous, and slow.
 	 */
-	for (i = 0, nchunks = req->rl_nchunks; nchunks; nchunks--) {
-		seg = &req->rl_segments[i];
-		mw = seg->rl_mw;
+	list_for_each_entry(mw, &req->rl_registered, mw_list) {
 		f = &mw->frmr;
-
 		if (mw->frmr.fr_mr->rkey == bad_wr->ex.invalidate_rkey) {
 			__frwr_reset_mr(ia, mw);
 			bad_wr = bad_wr->next;
 		}
-
-		i += seg->mr_nsegs;
 	}
 	goto unmap;
 }
@@ -552,22 +535,17 @@ static void
 frwr_op_unmap_safe(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 		   bool sync)
 {
-	struct rpcrdma_mr_seg *seg;
 	struct rpcrdma_mw *mw;
-	unsigned int i;
 
-	for (i = 0; req->rl_nchunks; req->rl_nchunks--) {
-		seg = &req->rl_segments[i];
-		mw = seg->rl_mw;
+	while (!list_empty(&req->rl_registered)) {
+		mw = list_first_entry(&req->rl_registered,
+				      struct rpcrdma_mw, mw_list);
+		list_del_init(&mw->mw_list);
 
 		if (sync)
 			frwr_op_recover_mr(mw);
 		else
 			rpcrdma_defer_mr_recovery(mw);
-
-		i += seg->mr_nsegs;
-		seg->mr_nsegs = 0;
-		seg->rl_mw = NULL;
 	}
 }
 
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 8fde0ab..6d34c1f 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -286,11 +286,11 @@ rpcrdma_convert_iovs(struct xdr_buf *xdrbuf, unsigned int pos,
 }
 
 static inline __be32 *
-xdr_encode_rdma_segment(__be32 *iptr, struct rpcrdma_mr_seg *seg)
+xdr_encode_rdma_segment(__be32 *iptr, struct rpcrdma_mw *mw)
 {
-	*iptr++ = cpu_to_be32(seg->mr_rkey);
-	*iptr++ = cpu_to_be32(seg->mr_len);
-	return xdr_encode_hyper(iptr, seg->mr_base);
+	*iptr++ = cpu_to_be32(mw->mw_handle);
+	*iptr++ = cpu_to_be32(mw->mw_length);
+	return xdr_encode_hyper(iptr, mw->mw_offset);
 }
 
 /* XDR-encode the Read list. Supports encoding a list of read
@@ -311,6 +311,7 @@ rpcrdma_encode_read_list(struct rpcrdma_xprt *r_xprt,
 			 __be32 *iptr, enum rpcrdma_chunktype rtype)
 {
 	struct rpcrdma_mr_seg *seg = req->rl_nextseg;
+	struct rpcrdma_mw *mw;
 	unsigned int pos;
 	int n, nsegs;
 
@@ -328,9 +329,11 @@ rpcrdma_encode_read_list(struct rpcrdma_xprt *r_xprt,
 		return ERR_PTR(nsegs);
 
 	do {
-		n = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs, false);
+		n = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
+						 false, &mw);
 		if (n < 0)
 			return ERR_PTR(n);
+		list_add(&mw->mw_list, &req->rl_registered);
 
 		*iptr++ = xdr_one;	/* item present */
 
@@ -338,13 +341,12 @@ rpcrdma_encode_read_list(struct rpcrdma_xprt *r_xprt,
 		 * have the same "position".
 		 */
 		*iptr++ = cpu_to_be32(pos);
-		iptr = xdr_encode_rdma_segment(iptr, seg);
+		iptr = xdr_encode_rdma_segment(iptr, mw);
 
-		dprintk("RPC: %5u %s: read segment pos %u "
-			"%d@0x%016llx:0x%08x (%s)\n",
+		dprintk("RPC: %5u %s: pos %u %u@0x%016llx:0x%08x (%s)\n",
 			rqst->rq_task->tk_pid, __func__, pos,
-			seg->mr_len, (unsigned long long)seg->mr_base,
-			seg->mr_rkey, n < nsegs ? "more" : "last");
+			mw->mw_length, (unsigned long long)mw->mw_offset,
+			mw->mw_handle, n < nsegs ? "more" : "last");
 
 		r_xprt->rx_stats.read_chunk_count++;
 		req->rl_nchunks++;
@@ -376,6 +378,7 @@ rpcrdma_encode_write_list(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 			  enum rpcrdma_chunktype wtype)
 {
 	struct rpcrdma_mr_seg *seg = req->rl_nextseg;
+	struct rpcrdma_mw *mw;
 	int n, nsegs, nchunks;
 	__be32 *segcount;
 
@@ -396,17 +399,18 @@ rpcrdma_encode_write_list(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 
 	nchunks = 0;
 	do {
-		n = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs, true);
+		n = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
+						 true, &mw);
 		if (n < 0)
 			return ERR_PTR(n);
+		list_add(&mw->mw_list, &req->rl_registered);
 
-		iptr = xdr_encode_rdma_segment(iptr, seg);
+		iptr = xdr_encode_rdma_segment(iptr, mw);
 
-		dprintk("RPC: %5u %s: write segment "
-			"%d@0x016%llx:0x%08x (%s)\n",
+		dprintk("RPC: %5u %s: %u@0x016%llx:0x%08x (%s)\n",
 			rqst->rq_task->tk_pid, __func__,
-			seg->mr_len, (unsigned long long)seg->mr_base,
-			seg->mr_rkey, n < nsegs ? "more" : "last");
+			mw->mw_length, (unsigned long long)mw->mw_offset,
+			mw->mw_handle, n < nsegs ? "more" : "last");
 
 		r_xprt->rx_stats.write_chunk_count++;
 		r_xprt->rx_stats.total_rdma_request += seg->mr_len;
@@ -443,6 +447,7 @@ rpcrdma_encode_reply_chunk(struct rpcrdma_xprt *r_xprt,
 			   __be32 *iptr, enum rpcrdma_chunktype wtype)
 {
 	struct rpcrdma_mr_seg *seg = req->rl_nextseg;
+	struct rpcrdma_mw *mw;
 	int n, nsegs, nchunks;
 	__be32 *segcount;
 
@@ -461,17 +466,18 @@ rpcrdma_encode_reply_chunk(struct rpcrdma_xprt *r_xprt,
 
 	nchunks = 0;
 	do {
-		n = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs, true);
+		n = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
+						 true, &mw);
 		if (n < 0)
 			return ERR_PTR(n);
+		list_add(&mw->mw_list, &req->rl_registered);
 
-		iptr = xdr_encode_rdma_segment(iptr, seg);
+		iptr = xdr_encode_rdma_segment(iptr, mw);
 
-		dprintk("RPC: %5u %s: reply segment "
-			"%d@0x%016llx:0x%08x (%s)\n",
+		dprintk("RPC: %5u %s: %u@0x%016llx:0x%08x (%s)\n",
 			rqst->rq_task->tk_pid, __func__,
-			seg->mr_len, (unsigned long long)seg->mr_base,
-			seg->mr_rkey, n < nsegs ? "more" : "last");
+			mw->mw_length, (unsigned long long)mw->mw_offset,
+			mw->mw_handle, n < nsegs ? "more" : "last");
 
 		r_xprt->rx_stats.reply_chunk_count++;
 		r_xprt->rx_stats.total_rdma_request += seg->mr_len;
@@ -690,10 +696,7 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 out_overflow:
 	pr_err("rpcrdma: send overflow: hdrlen %zd rpclen %zu %s/%s\n",
 		hdrlen, rpclen, transfertypes[rtype], transfertypes[wtype]);
-	/* Terminate this RPC. Chunks registered above will be
-	 * released by xprt_release -> xprt_rmda_free .
-	 */
-	return -EIO;
+	iptr = ERR_PTR(-EIO);
 
 out_unmap:
 	r_xprt->rx_ia.ri_ops->ro_unmap_safe(r_xprt, req, false);
@@ -705,15 +708,13 @@ out_unmap:
  * RDMA'd by server. See map at rpcrdma_create_chunks()! :-)
  */
 static int
-rpcrdma_count_chunks(struct rpcrdma_rep *rep, unsigned int max, int wrchunk, __be32 **iptrp)
+rpcrdma_count_chunks(struct rpcrdma_rep *rep, int wrchunk, __be32 **iptrp)
 {
 	unsigned int i, total_len;
 	struct rpcrdma_write_chunk *cur_wchunk;
 	char *base = (char *)rdmab_to_msg(rep->rr_rdmabuf);
 
 	i = be32_to_cpu(**iptrp);
-	if (i > max)
-		return -1;
 	cur_wchunk = (struct rpcrdma_write_chunk *) (*iptrp + 1);
 	total_len = 0;
 	while (i--) {
@@ -960,14 +961,13 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 		    (headerp->rm_body.rm_chunks[1] == xdr_zero &&
 		     headerp->rm_body.rm_chunks[2] != xdr_zero) ||
 		    (headerp->rm_body.rm_chunks[1] != xdr_zero &&
-		     req->rl_nchunks == 0))
+		     list_empty(&req->rl_registered)))
 			goto badheader;
 		if (headerp->rm_body.rm_chunks[1] != xdr_zero) {
 			/* count any expected write chunks in read reply */
 			/* start at write chunk array count */
 			iptr = &headerp->rm_body.rm_chunks[2];
-			rdmalen = rpcrdma_count_chunks(rep,
-						req->rl_nchunks, 1, &iptr);
+			rdmalen = rpcrdma_count_chunks(rep, 1, &iptr);
 			/* check for validity, and no reply chunk after */
 			if (rdmalen < 0 || *iptr++ != xdr_zero)
 				goto badheader;
@@ -997,11 +997,11 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 		if (headerp->rm_body.rm_chunks[0] != xdr_zero ||
 		    headerp->rm_body.rm_chunks[1] != xdr_zero ||
 		    headerp->rm_body.rm_chunks[2] != xdr_one ||
-		    req->rl_nchunks == 0)
+		    list_empty(&req->rl_registered))
 			goto badheader;
 		iptr = (__be32 *)((unsigned char *)headerp +
 							RPCRDMA_HDRLEN_MIN);
-		rdmalen = rpcrdma_count_chunks(rep, req->rl_nchunks, 0, &iptr);
+		rdmalen = rpcrdma_count_chunks(rep, 0, &iptr);
 		if (rdmalen < 0)
 			goto badheader;
 		r_xprt->rx_stats.total_rdma_reply += rdmalen;
@@ -1014,14 +1014,9 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 
 badheader:
 	default:
-		dprintk("%s: invalid rpcrdma reply header (type %d):"
-				" chunks[012] == %d %d %d"
-				" expected chunks <= %d\n",
-				__func__, be32_to_cpu(headerp->rm_type),
-				headerp->rm_body.rm_chunks[0],
-				headerp->rm_body.rm_chunks[1],
-				headerp->rm_body.rm_chunks[2],
-				req->rl_nchunks);
+		dprintk("RPC: %5u %s: invalid rpcrdma reply (type %u)\n",
+			rqst->rq_task->tk_pid, __func__,
+			be32_to_cpu(headerp->rm_type));
 		status = -EIO;
 		r_xprt->rx_stats.bad_reply_count++;
 		break;
@@ -1035,7 +1030,7 @@ out:
 	 * control: waking the next RPC waits until this RPC has
 	 * relinquished all its Send Queue entries.
 	 */
-	if (req->rl_nchunks)
+	if (!list_empty(&req->rl_registered))
 		r_xprt->rx_ia.ri_ops->ro_unmap_sync(r_xprt, req);
 
 	spin_lock_bh(&xprt->transport_lock);
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index b1dd42a..81f0e87 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -619,6 +619,9 @@ xprt_rdma_send_request(struct rpc_task *task)
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 	int rc = 0;
 
+	/* On retransmit, remove any previously registered chunks */
+	r_xprt->rx_ia.ri_ops->ro_unmap_safe(r_xprt, req, false);
+
 	rc = rpcrdma_marshal_req(rqst);
 	if (rc < 0)
 		goto failed_marshal;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 4a7a712..ae99c04 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -862,6 +862,7 @@ rpcrdma_create_req(struct rpcrdma_xprt *r_xprt)
 	spin_unlock(&buffer->rb_reqslock);
 	req->rl_cqe.done = rpcrdma_wc_send;
 	req->rl_buffer = &r_xprt->rx_buf;
+	INIT_LIST_HEAD(&req->rl_registered);
 	return req;
 }
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 0bde4c0..025365c 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -245,6 +245,9 @@ struct rpcrdma_mw {
 		struct rpcrdma_frmr	frmr;
 	};
 	struct rpcrdma_xprt	*mw_xprt;
+	u32			mw_handle;
+	u32			mw_length;
+	u64			mw_offset;
 	struct list_head	mw_all;
 };
 
@@ -272,11 +275,7 @@ struct rpcrdma_mw {
  */
 
 struct rpcrdma_mr_seg {		/* chunk descriptors */
-	struct rpcrdma_mw *rl_mw;	/* registered MR */
-	u64		mr_base;	/* registration result */
-	u32		mr_rkey;	/* registration result */
 	u32		mr_len;		/* length of chunk or segment */
-	int		mr_nsegs;	/* number of segments in chunk or 0 */
 	struct page	*mr_page;	/* owning page, if any */
 	char		*mr_offset;	/* kva if no page, else offset */
 };
@@ -294,6 +293,7 @@ struct rpcrdma_req {
 	struct ib_sge		rl_send_iov[RPCRDMA_MAX_IOVS];
 	struct rpcrdma_regbuf	*rl_rdmabuf;
 	struct rpcrdma_regbuf	*rl_sendbuf;
+	struct list_head	rl_registered;	/* registered segments */
 	struct rpcrdma_mr_seg	rl_segments[RPCRDMA_MAX_SEGS];
 	struct rpcrdma_mr_seg	*rl_nextseg;
 
@@ -397,7 +397,8 @@ struct rpcrdma_stats {
 struct rpcrdma_xprt;
 struct rpcrdma_memreg_ops {
 	int		(*ro_map)(struct rpcrdma_xprt *,
-				  struct rpcrdma_mr_seg *, int, bool);
+				  struct rpcrdma_mr_seg *, int, bool,
+				  struct rpcrdma_mw **);
 	void		(*ro_unmap_sync)(struct rpcrdma_xprt *,
 					 struct rpcrdma_req *);
 	void		(*ro_unmap_safe)(struct rpcrdma_xprt *,


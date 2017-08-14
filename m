Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36980 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752159AbdHNTic (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Aug 2017 15:38:32 -0400
Received: by mail-it0-f65.google.com with SMTP id 77so8554068itj.4
        for <linux-nfs@vger.kernel.org>; Mon, 14 Aug 2017 12:38:32 -0700 (PDT)
Subject: [PATCH v1 2/2] xprtrdma: Remove imul instructions from chunk list
 encoders
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 14 Aug 2017 15:38:30 -0400
Message-ID: <20170814193830.25033.97752.stgit@manet.1015granger.net>
In-Reply-To: <20170814192946.25033.43917.stgit@manet.1015granger.net>
References: <20170814192946.25033.43917.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Re-arrange the pointer arithmetic in the chunk list encoders to
eliminate several more integer multiplication instructions during
Transport Header encoding.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c   |   10 ++++-----
 net/sunrpc/xprtrdma/frwr_ops.c  |   12 +++++-----
 net/sunrpc/xprtrdma/rpc_rdma.c  |   45 ++++++++++++++++++---------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    3 ++-
 4 files changed, 34 insertions(+), 36 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index d3f84bb..6c71513 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -177,7 +177,7 @@ enum {
 /* Use the ib_map_phys_fmr() verb to register a memory region
  * for remote access via RDMA READ or RDMA WRITE.
  */
-static int
+static struct rpcrdma_mr_seg *
 fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	   int nsegs, bool writing, struct rpcrdma_mw **out)
 {
@@ -188,7 +188,7 @@ enum {
 
 	mw = rpcrdma_get_mw(r_xprt);
 	if (!mw)
-		return -ENOBUFS;
+		return ERR_PTR(-ENOBUFS);
 
 	pageoff = offset_in_page(seg1->mr_offset);
 	seg1->mr_offset -= pageoff;	/* start of page */
@@ -232,13 +232,13 @@ enum {
 	mw->mw_offset = dma_pages[0] + pageoff;
 
 	*out = mw;
-	return mw->mw_nents;
+	return seg;
 
 out_dmamap_err:
 	pr_err("rpcrdma: failed to DMA map sg %p sg_nents %d\n",
 	       mw->mw_sg, i);
 	rpcrdma_put_mw(r_xprt, mw);
-	return -EIO;
+	return ERR_PTR(-EIO);
 
 out_maperr:
 	pr_err("rpcrdma: ib_map_phys_fmr %u@0x%llx+%i (%d) status %i\n",
@@ -247,7 +247,7 @@ enum {
 	ib_dma_unmap_sg(r_xprt->rx_ia.ri_device,
 			mw->mw_sg, mw->mw_nents, mw->mw_dir);
 	rpcrdma_put_mw(r_xprt, mw);
-	return -EIO;
+	return ERR_PTR(-EIO);
 }
 
 /* Invalidate all memory regions that were registered for "req".
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 6aea36a..5a936a6 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -344,7 +344,7 @@
 /* Post a REG_MR Work Request to register a memory region
  * for remote access via RDMA READ or RDMA WRITE.
  */
-static int
+static struct rpcrdma_mr_seg *
 frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	    int nsegs, bool writing, struct rpcrdma_mw **out)
 {
@@ -364,7 +364,7 @@
 			rpcrdma_defer_mr_recovery(mw);
 		mw = rpcrdma_get_mw(r_xprt);
 		if (!mw)
-			return -ENOBUFS;
+			return ERR_PTR(-ENOBUFS);
 	} while (mw->frmr.fr_state != FRMR_IS_INVALID);
 	frmr = &mw->frmr;
 	frmr->fr_state = FRMR_IS_VALID;
@@ -429,25 +429,25 @@
 	mw->mw_offset = mr->iova;
 
 	*out = mw;
-	return mw->mw_nents;
+	return seg;
 
 out_dmamap_err:
 	pr_err("rpcrdma: failed to DMA map sg %p sg_nents %d\n",
 	       mw->mw_sg, i);
 	frmr->fr_state = FRMR_IS_INVALID;
 	rpcrdma_put_mw(r_xprt, mw);
-	return -EIO;
+	return ERR_PTR(-EIO);
 
 out_mapmr_err:
 	pr_err("rpcrdma: failed to map mr %p (%d/%d)\n",
 	       frmr->fr_mr, n, mw->mw_nents);
 	rpcrdma_defer_mr_recovery(mw);
-	return -EIO;
+	return ERR_PTR(-EIO);
 
 out_senderr:
 	pr_err("rpcrdma: FRMR registration ib_post_send returned %i\n", rc);
 	rpcrdma_defer_mr_recovery(mw);
-	return -ENOTCONN;
+	return ERR_PTR(-ENOTCONN);
 }
 
 /* Invalidate all memory regions that were registered for "req".
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 211ac4b..84584ca 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -349,7 +349,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	struct rpcrdma_mr_seg *seg;
 	struct rpcrdma_mw *mw;
 	unsigned int pos;
-	int n, nsegs;
+	int nsegs;
 
 	pos = rqst->rq_snd_buf.head[0].iov_len;
 	if (rtype == rpcrdma_areadch)
@@ -361,10 +361,10 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		return nsegs;
 
 	do {
-		n = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
-						 false, &mw);
-		if (n < 0)
-			return n;
+		seg = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
+						   false, &mw);
+		if (IS_ERR(seg))
+			return PTR_ERR(seg);
 		rpcrdma_push_mw(mw, &req->rl_registered);
 
 		if (encode_read_segment(xdr, mw, pos) < 0)
@@ -373,11 +373,10 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		dprintk("RPC: %5u %s: pos %u %u@0x%016llx:0x%08x (%s)\n",
 			rqst->rq_task->tk_pid, __func__, pos,
 			mw->mw_length, (unsigned long long)mw->mw_offset,
-			mw->mw_handle, n < nsegs ? "more" : "last");
+			mw->mw_handle, mw->mw_nents < nsegs ? "more" : "last");
 
 		r_xprt->rx_stats.read_chunk_count++;
-		seg += n;
-		nsegs -= n;
+		nsegs -= mw->mw_nents;
 	} while (nsegs);
 
 	return 0;
@@ -405,7 +404,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	struct xdr_stream *xdr = &req->rl_stream;
 	struct rpcrdma_mr_seg *seg;
 	struct rpcrdma_mw *mw;
-	int n, nsegs, nchunks;
+	int nsegs, nchunks;
 	__be32 *segcount;
 
 	seg = req->rl_segments;
@@ -424,10 +423,10 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 
 	nchunks = 0;
 	do {
-		n = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
-						 true, &mw);
-		if (n < 0)
-			return n;
+		seg = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
+						   true, &mw);
+		if (IS_ERR(seg))
+			return PTR_ERR(seg);
 		rpcrdma_push_mw(mw, &req->rl_registered);
 
 		if (encode_rdma_segment(xdr, mw) < 0)
@@ -436,13 +435,12 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		dprintk("RPC: %5u %s: %u@0x016%llx:0x%08x (%s)\n",
 			rqst->rq_task->tk_pid, __func__,
 			mw->mw_length, (unsigned long long)mw->mw_offset,
-			mw->mw_handle, n < nsegs ? "more" : "last");
+			mw->mw_handle, mw->mw_nents < nsegs ? "more" : "last");
 
 		r_xprt->rx_stats.write_chunk_count++;
 		r_xprt->rx_stats.total_rdma_request += seg->mr_len;
 		nchunks++;
-		seg   += n;
-		nsegs -= n;
+		nsegs -= mw->mw_nents;
 	} while (nsegs);
 
 	/* Update count of segments in this Write chunk */
@@ -470,7 +468,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	struct xdr_stream *xdr = &req->rl_stream;
 	struct rpcrdma_mr_seg *seg;
 	struct rpcrdma_mw *mw;
-	int n, nsegs, nchunks;
+	int nsegs, nchunks;
 	__be32 *segcount;
 
 	seg = req->rl_segments;
@@ -487,10 +485,10 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 
 	nchunks = 0;
 	do {
-		n = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
-						 true, &mw);
-		if (n < 0)
-			return n;
+		seg = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
+						   true, &mw);
+		if (IS_ERR(seg))
+			return PTR_ERR(seg);
 		rpcrdma_push_mw(mw, &req->rl_registered);
 
 		if (encode_rdma_segment(xdr, mw) < 0)
@@ -499,13 +497,12 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		dprintk("RPC: %5u %s: %u@0x%016llx:0x%08x (%s)\n",
 			rqst->rq_task->tk_pid, __func__,
 			mw->mw_length, (unsigned long long)mw->mw_offset,
-			mw->mw_handle, n < nsegs ? "more" : "last");
+			mw->mw_handle, mw->mw_nents < nsegs ? "more" : "last");
 
 		r_xprt->rx_stats.reply_chunk_count++;
 		r_xprt->rx_stats.total_rdma_request += seg->mr_len;
 		nchunks++;
-		seg   += n;
-		nsegs -= n;
+		nsegs -= mw->mw_nents;
 	} while (nsegs);
 
 	/* Update count of segments in the Reply chunk */
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 2af9106..546c264 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -466,7 +466,8 @@ struct rpcrdma_stats {
  */
 struct rpcrdma_xprt;
 struct rpcrdma_memreg_ops {
-	int		(*ro_map)(struct rpcrdma_xprt *,
+	struct rpcrdma_mr_seg *
+			(*ro_map)(struct rpcrdma_xprt *,
 				  struct rpcrdma_mr_seg *, int, bool,
 				  struct rpcrdma_mw **);
 	void		(*ro_unmap_sync)(struct rpcrdma_xprt *,


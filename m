Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:34778 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754AbbCXUbq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Mar 2015 16:31:46 -0400
Subject: [PATCH v2 08/15] xprtrdma: Add a "register_external" op for each
 memreg mode
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 24 Mar 2015 16:31:43 -0400
Message-ID: <20150324203143.2311.27788.stgit@manet.1015granger.net>
In-Reply-To: <20150324201849.2311.53599.stgit@manet.1015granger.net>
References: <20150324201849.2311.53599.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is very little common processing among the different external
memory registration functions. Have rpcrdma_create_chunks() call
the registration method directly. This removes a stack frame and a
switch statement from the external registration path.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c      |   51 +++++++++++
 net/sunrpc/xprtrdma/frwr_ops.c     |   82 ++++++++++++++++++
 net/sunrpc/xprtrdma/physical_ops.c |   17 ++++
 net/sunrpc/xprtrdma/rpc_rdma.c     |    5 +
 net/sunrpc/xprtrdma/verbs.c        |  168 +-----------------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h    |    6 +
 6 files changed, 160 insertions(+), 169 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index eec2660..45fb646 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -29,7 +29,58 @@ fmr_op_maxpages(struct rpcrdma_xprt *r_xprt)
 		     rpcrdma_max_segments(r_xprt) * RPCRDMA_MAX_FMR_SGES);
 }
 
+/* Use the ib_map_phys_fmr() verb to register a memory region
+ * for remote access via RDMA READ or RDMA WRITE.
+ */
+static int
+fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
+	   int nsegs, bool writing)
+{
+	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
+	struct rpcrdma_mr_seg *seg1 = seg;
+	struct rpcrdma_mw *mw = seg1->rl_mw;
+	u64 physaddrs[RPCRDMA_MAX_DATA_SEGS];
+	int len, pageoff, i, rc;
+
+	pageoff = offset_in_page(seg1->mr_offset);
+	seg1->mr_offset -= pageoff;	/* start of page */
+	seg1->mr_len += pageoff;
+	len = -pageoff;
+	if (nsegs > RPCRDMA_MAX_FMR_SGES)
+		nsegs = RPCRDMA_MAX_FMR_SGES;
+	for (i = 0; i < nsegs;) {
+		rpcrdma_map_one(ia, seg, writing);
+		physaddrs[i] = seg->mr_dma;
+		len += seg->mr_len;
+		++seg;
+		++i;
+		/* Check for holes */
+		if ((i < nsegs && offset_in_page(seg->mr_offset)) ||
+		    offset_in_page((seg-1)->mr_offset + (seg-1)->mr_len))
+			break;
+	}
+
+	rc = ib_map_phys_fmr(mw->r.fmr, physaddrs, i, seg1->mr_dma);
+	if (rc)
+		goto out_maperr;
+
+	seg1->mr_rkey = mw->r.fmr->rkey;
+	seg1->mr_base = seg1->mr_dma + pageoff;
+	seg1->mr_nsegs = i;
+	seg1->mr_len = len;
+	return i;
+
+out_maperr:
+	dprintk("RPC:       %s: ib_map_phys_fmr %u@0x%llx+%i (%d) status %i\n",
+		__func__, len, (unsigned long long)seg1->mr_dma,
+		pageoff, i, rc);
+	while (i--)
+		rpcrdma_unmap_one(ia, --seg);
+	return rc;
+}
+
 const struct rpcrdma_memreg_ops rpcrdma_fmr_memreg_ops = {
+	.ro_map				= fmr_op_map,
 	.ro_maxpages			= fmr_op_maxpages,
 	.ro_displayname			= "fmr",
 };
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 73a5ac8..23e4d99 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -29,7 +29,89 @@ frwr_op_maxpages(struct rpcrdma_xprt *r_xprt)
 		     rpcrdma_max_segments(r_xprt) * ia->ri_max_frmr_depth);
 }
 
+/* Post a FAST_REG Work Request to register a memory region
+ * for remote access via RDMA READ or RDMA WRITE.
+ */
+static int
+frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
+	    int nsegs, bool writing)
+{
+	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
+	struct rpcrdma_mr_seg *seg1 = seg;
+	struct rpcrdma_mw *mw = seg1->rl_mw;
+	struct rpcrdma_frmr *frmr = &mw->r.frmr;
+	struct ib_mr *mr = frmr->fr_mr;
+	struct ib_send_wr fastreg_wr, *bad_wr;
+	u8 key;
+	int len, pageoff;
+	int i, rc;
+	int seg_len;
+	u64 pa;
+	int page_no;
+
+	pageoff = offset_in_page(seg1->mr_offset);
+	seg1->mr_offset -= pageoff;	/* start of page */
+	seg1->mr_len += pageoff;
+	len = -pageoff;
+	if (nsegs > ia->ri_max_frmr_depth)
+		nsegs = ia->ri_max_frmr_depth;
+	for (page_no = i = 0; i < nsegs;) {
+		rpcrdma_map_one(ia, seg, writing);
+		pa = seg->mr_dma;
+		for (seg_len = seg->mr_len; seg_len > 0; seg_len -= PAGE_SIZE) {
+			frmr->fr_pgl->page_list[page_no++] = pa;
+			pa += PAGE_SIZE;
+		}
+		len += seg->mr_len;
+		++seg;
+		++i;
+		/* Check for holes */
+		if ((i < nsegs && offset_in_page(seg->mr_offset)) ||
+		    offset_in_page((seg-1)->mr_offset + (seg-1)->mr_len))
+			break;
+	}
+	dprintk("RPC:       %s: Using frmr %p to map %d segments (%d bytes)\n",
+		__func__, mw, i, len);
+
+	frmr->fr_state = FRMR_IS_VALID;
+
+	memset(&fastreg_wr, 0, sizeof(fastreg_wr));
+	fastreg_wr.wr_id = (unsigned long)(void *)mw;
+	fastreg_wr.opcode = IB_WR_FAST_REG_MR;
+	fastreg_wr.wr.fast_reg.iova_start = seg1->mr_dma + pageoff;
+	fastreg_wr.wr.fast_reg.page_list = frmr->fr_pgl;
+	fastreg_wr.wr.fast_reg.page_shift = PAGE_SHIFT;
+	fastreg_wr.wr.fast_reg.page_list_len = page_no;
+	fastreg_wr.wr.fast_reg.length = len;
+	fastreg_wr.wr.fast_reg.access_flags = writing ?
+				IB_ACCESS_REMOTE_WRITE | IB_ACCESS_LOCAL_WRITE :
+				IB_ACCESS_REMOTE_READ;
+	key = (u8)(mr->rkey & 0x000000FF);
+	ib_update_fast_reg_key(mr, ++key);
+	fastreg_wr.wr.fast_reg.rkey = mr->rkey;
+
+	DECR_CQCOUNT(&r_xprt->rx_ep);
+	rc = ib_post_send(ia->ri_id->qp, &fastreg_wr, &bad_wr);
+	if (rc)
+		goto out_senderr;
+
+	seg1->mr_rkey = mr->rkey;
+	seg1->mr_base = seg1->mr_dma + pageoff;
+	seg1->mr_nsegs = i;
+	seg1->mr_len = len;
+	return i;
+
+out_senderr:
+	dprintk("RPC:       %s: ib_post_send status %i\n", __func__, rc);
+	ib_update_fast_reg_key(mr, --key);
+	frmr->fr_state = FRMR_IS_INVALID;
+	while (i--)
+		rpcrdma_unmap_one(ia, --seg);
+	return rc;
+}
+
 const struct rpcrdma_memreg_ops rpcrdma_frwr_memreg_ops = {
+	.ro_map				= frwr_op_map,
 	.ro_maxpages			= frwr_op_maxpages,
 	.ro_displayname			= "frwr",
 };
diff --git a/net/sunrpc/xprtrdma/physical_ops.c b/net/sunrpc/xprtrdma/physical_ops.c
index 28ade19..5a284ee 100644
--- a/net/sunrpc/xprtrdma/physical_ops.c
+++ b/net/sunrpc/xprtrdma/physical_ops.c
@@ -28,7 +28,24 @@ physical_op_maxpages(struct rpcrdma_xprt *r_xprt)
 		     rpcrdma_max_segments(r_xprt));
 }
 
+/* The client's physical memory is already exposed for
+ * remote access via RDMA READ or RDMA WRITE.
+ */
+static int
+physical_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
+		int nsegs, bool writing)
+{
+	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
+
+	rpcrdma_map_one(ia, seg, writing);
+	seg->mr_rkey = ia->ri_bind_mem->rkey;
+	seg->mr_base = seg->mr_dma;
+	seg->mr_nsegs = 1;
+	return 1;
+}
+
 const struct rpcrdma_memreg_ops rpcrdma_physical_memreg_ops = {
+	.ro_map				= physical_op_map,
 	.ro_maxpages			= physical_op_maxpages,
 	.ro_displayname			= "physical",
 };
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 41456d9..6ab1d03 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -187,6 +187,7 @@ rpcrdma_create_chunks(struct rpc_rqst *rqst, struct xdr_buf *target,
 	struct rpcrdma_write_array *warray = NULL;
 	struct rpcrdma_write_chunk *cur_wchunk = NULL;
 	__be32 *iptr = headerp->rm_body.rm_chunks;
+	int (*map)(struct rpcrdma_xprt *, struct rpcrdma_mr_seg *, int, bool);
 
 	if (type == rpcrdma_readch || type == rpcrdma_areadch) {
 		/* a read chunk - server will RDMA Read our memory */
@@ -209,9 +210,9 @@ rpcrdma_create_chunks(struct rpc_rqst *rqst, struct xdr_buf *target,
 	if (nsegs < 0)
 		return nsegs;
 
+	map = r_xprt->rx_ia.ri_ops->ro_map;
 	do {
-		n = rpcrdma_register_external(seg, nsegs,
-						cur_wchunk != NULL, r_xprt);
+		n = map(r_xprt, seg, nsegs, cur_wchunk != NULL);
 		if (n <= 0)
 			goto out;
 		if (cur_rchunk) {	/* read */
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index da55cda..4318c04 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1858,8 +1858,8 @@ rpcrdma_free_regbuf(struct rpcrdma_ia *ia, struct rpcrdma_regbuf *rb)
  * Wrappers for chunk registration, shared by read/write chunk code.
  */
 
-static void
-rpcrdma_map_one(struct rpcrdma_ia *ia, struct rpcrdma_mr_seg *seg, int writing)
+void
+rpcrdma_map_one(struct rpcrdma_ia *ia, struct rpcrdma_mr_seg *seg, bool writing)
 {
 	seg->mr_dir = writing ? DMA_FROM_DEVICE : DMA_TO_DEVICE;
 	seg->mr_dmalen = seg->mr_len;
@@ -1879,7 +1879,7 @@ rpcrdma_map_one(struct rpcrdma_ia *ia, struct rpcrdma_mr_seg *seg, int writing)
 	}
 }
 
-static void
+void
 rpcrdma_unmap_one(struct rpcrdma_ia *ia, struct rpcrdma_mr_seg *seg)
 {
 	if (seg->mr_page)
@@ -1891,89 +1891,6 @@ rpcrdma_unmap_one(struct rpcrdma_ia *ia, struct rpcrdma_mr_seg *seg)
 }
 
 static int
-rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
-			int *nsegs, int writing, struct rpcrdma_ia *ia,
-			struct rpcrdma_xprt *r_xprt)
-{
-	struct rpcrdma_mr_seg *seg1 = seg;
-	struct rpcrdma_mw *mw = seg1->rl_mw;
-	struct rpcrdma_frmr *frmr = &mw->r.frmr;
-	struct ib_mr *mr = frmr->fr_mr;
-	struct ib_send_wr fastreg_wr, *bad_wr;
-	u8 key;
-	int len, pageoff;
-	int i, rc;
-	int seg_len;
-	u64 pa;
-	int page_no;
-
-	pageoff = offset_in_page(seg1->mr_offset);
-	seg1->mr_offset -= pageoff;	/* start of page */
-	seg1->mr_len += pageoff;
-	len = -pageoff;
-	if (*nsegs > ia->ri_max_frmr_depth)
-		*nsegs = ia->ri_max_frmr_depth;
-	for (page_no = i = 0; i < *nsegs;) {
-		rpcrdma_map_one(ia, seg, writing);
-		pa = seg->mr_dma;
-		for (seg_len = seg->mr_len; seg_len > 0; seg_len -= PAGE_SIZE) {
-			frmr->fr_pgl->page_list[page_no++] = pa;
-			pa += PAGE_SIZE;
-		}
-		len += seg->mr_len;
-		++seg;
-		++i;
-		/* Check for holes */
-		if ((i < *nsegs && offset_in_page(seg->mr_offset)) ||
-		    offset_in_page((seg-1)->mr_offset + (seg-1)->mr_len))
-			break;
-	}
-	dprintk("RPC:       %s: Using frmr %p to map %d segments (%d bytes)\n",
-		__func__, mw, i, len);
-
-	frmr->fr_state = FRMR_IS_VALID;
-
-	memset(&fastreg_wr, 0, sizeof(fastreg_wr));
-	fastreg_wr.wr_id = (unsigned long)(void *)mw;
-	fastreg_wr.opcode = IB_WR_FAST_REG_MR;
-	fastreg_wr.wr.fast_reg.iova_start = seg1->mr_dma + pageoff;
-	fastreg_wr.wr.fast_reg.page_list = frmr->fr_pgl;
-	fastreg_wr.wr.fast_reg.page_list_len = page_no;
-	fastreg_wr.wr.fast_reg.page_shift = PAGE_SHIFT;
-	fastreg_wr.wr.fast_reg.length = len;
-
-	/* Bump the key */
-	key = (u8)(mr->rkey & 0x000000FF);
-	ib_update_fast_reg_key(mr, ++key);
-
-	fastreg_wr.wr.fast_reg.access_flags = (writing ?
-				IB_ACCESS_REMOTE_WRITE | IB_ACCESS_LOCAL_WRITE :
-				IB_ACCESS_REMOTE_READ);
-	fastreg_wr.wr.fast_reg.rkey = mr->rkey;
-	DECR_CQCOUNT(&r_xprt->rx_ep);
-
-	rc = ib_post_send(ia->ri_id->qp, &fastreg_wr, &bad_wr);
-	if (rc) {
-		dprintk("RPC:       %s: failed ib_post_send for register,"
-			" status %i\n", __func__, rc);
-		ib_update_fast_reg_key(mr, --key);
-		goto out_err;
-	} else {
-		seg1->mr_rkey = mr->rkey;
-		seg1->mr_base = seg1->mr_dma + pageoff;
-		seg1->mr_nsegs = i;
-		seg1->mr_len = len;
-	}
-	*nsegs = i;
-	return 0;
-out_err:
-	frmr->fr_state = FRMR_IS_INVALID;
-	while (i--)
-		rpcrdma_unmap_one(ia, --seg);
-	return rc;
-}
-
-static int
 rpcrdma_deregister_frmr_external(struct rpcrdma_mr_seg *seg,
 			struct rpcrdma_ia *ia, struct rpcrdma_xprt *r_xprt)
 {
@@ -2004,49 +1921,6 @@ rpcrdma_deregister_frmr_external(struct rpcrdma_mr_seg *seg,
 }
 
 static int
-rpcrdma_register_fmr_external(struct rpcrdma_mr_seg *seg,
-			int *nsegs, int writing, struct rpcrdma_ia *ia)
-{
-	struct rpcrdma_mr_seg *seg1 = seg;
-	u64 physaddrs[RPCRDMA_MAX_DATA_SEGS];
-	int len, pageoff, i, rc;
-
-	pageoff = offset_in_page(seg1->mr_offset);
-	seg1->mr_offset -= pageoff;	/* start of page */
-	seg1->mr_len += pageoff;
-	len = -pageoff;
-	if (*nsegs > RPCRDMA_MAX_DATA_SEGS)
-		*nsegs = RPCRDMA_MAX_DATA_SEGS;
-	for (i = 0; i < *nsegs;) {
-		rpcrdma_map_one(ia, seg, writing);
-		physaddrs[i] = seg->mr_dma;
-		len += seg->mr_len;
-		++seg;
-		++i;
-		/* Check for holes */
-		if ((i < *nsegs && offset_in_page(seg->mr_offset)) ||
-		    offset_in_page((seg-1)->mr_offset + (seg-1)->mr_len))
-			break;
-	}
-	rc = ib_map_phys_fmr(seg1->rl_mw->r.fmr, physaddrs, i, seg1->mr_dma);
-	if (rc) {
-		dprintk("RPC:       %s: failed ib_map_phys_fmr "
-			"%u@0x%llx+%i (%d)... status %i\n", __func__,
-			len, (unsigned long long)seg1->mr_dma,
-			pageoff, i, rc);
-		while (i--)
-			rpcrdma_unmap_one(ia, --seg);
-	} else {
-		seg1->mr_rkey = seg1->rl_mw->r.fmr->rkey;
-		seg1->mr_base = seg1->mr_dma + pageoff;
-		seg1->mr_nsegs = i;
-		seg1->mr_len = len;
-	}
-	*nsegs = i;
-	return rc;
-}
-
-static int
 rpcrdma_deregister_fmr_external(struct rpcrdma_mr_seg *seg,
 			struct rpcrdma_ia *ia)
 {
@@ -2067,42 +1941,6 @@ rpcrdma_deregister_fmr_external(struct rpcrdma_mr_seg *seg,
 }
 
 int
-rpcrdma_register_external(struct rpcrdma_mr_seg *seg,
-			int nsegs, int writing, struct rpcrdma_xprt *r_xprt)
-{
-	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
-	int rc = 0;
-
-	switch (ia->ri_memreg_strategy) {
-
-	case RPCRDMA_ALLPHYSICAL:
-		rpcrdma_map_one(ia, seg, writing);
-		seg->mr_rkey = ia->ri_bind_mem->rkey;
-		seg->mr_base = seg->mr_dma;
-		seg->mr_nsegs = 1;
-		nsegs = 1;
-		break;
-
-	/* Registration using frmr registration */
-	case RPCRDMA_FRMR:
-		rc = rpcrdma_register_frmr_external(seg, &nsegs, writing, ia, r_xprt);
-		break;
-
-	/* Registration using fmr memory registration */
-	case RPCRDMA_MTHCAFMR:
-		rc = rpcrdma_register_fmr_external(seg, &nsegs, writing, ia);
-		break;
-
-	default:
-		return -EIO;
-	}
-	if (rc)
-		return rc;
-
-	return nsegs;
-}
-
-int
 rpcrdma_deregister_external(struct rpcrdma_mr_seg *seg,
 		struct rpcrdma_xprt *r_xprt)
 {
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 59e627e..7bf077b 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -336,6 +336,8 @@ struct rpcrdma_stats {
  */
 struct rpcrdma_xprt;
 struct rpcrdma_memreg_ops {
+	int		(*ro_map)(struct rpcrdma_xprt *,
+				  struct rpcrdma_mr_seg *, int, bool);
 	size_t		(*ro_maxpages)(struct rpcrdma_xprt *);
 	const char	*ro_displayname;
 };
@@ -403,8 +405,6 @@ void rpcrdma_buffer_put(struct rpcrdma_req *);
 void rpcrdma_recv_buffer_get(struct rpcrdma_req *);
 void rpcrdma_recv_buffer_put(struct rpcrdma_rep *);
 
-int rpcrdma_register_external(struct rpcrdma_mr_seg *,
-				int, int, struct rpcrdma_xprt *);
 int rpcrdma_deregister_external(struct rpcrdma_mr_seg *,
 				struct rpcrdma_xprt *);
 
@@ -414,6 +414,8 @@ void rpcrdma_free_regbuf(struct rpcrdma_ia *,
 			 struct rpcrdma_regbuf *);
 
 unsigned int rpcrdma_max_segments(struct rpcrdma_xprt *);
+void rpcrdma_map_one(struct rpcrdma_ia *, struct rpcrdma_mr_seg *, bool);
+void rpcrdma_unmap_one(struct rpcrdma_ia *, struct rpcrdma_mr_seg *);
 
 /*
  * RPC/RDMA connection management calls - xprtrdma/rpc_rdma.c


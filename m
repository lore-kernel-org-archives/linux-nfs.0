Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:36350 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509AbbCXUcu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Mar 2015 16:32:50 -0400
Subject: [PATCH v2 15/15] xprtrdma: Make rpcrdma_{un}map_one() into inline
 functions
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 24 Mar 2015 16:32:47 -0400
Message-ID: <20150324203247.2311.59032.stgit@manet.1015granger.net>
In-Reply-To: <20150324201849.2311.53599.stgit@manet.1015granger.net>
References: <20150324201849.2311.53599.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These functions are called in a loop for each page transferred via
RDMA READ or WRITE. Extract loop invariants and inline them to
reduce CPU overhead.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c      |   10 ++++++--
 net/sunrpc/xprtrdma/frwr_ops.c     |   10 ++++++--
 net/sunrpc/xprtrdma/physical_ops.c |   10 ++++++--
 net/sunrpc/xprtrdma/verbs.c        |   44 ++++++-----------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h    |   45 ++++++++++++++++++++++++++++++++++--
 5 files changed, 73 insertions(+), 46 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index e8a9837..a91ba2c 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -85,6 +85,8 @@ fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	   int nsegs, bool writing)
 {
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
+	struct ib_device *device = ia->ri_id->device;
+	enum dma_data_direction direction = rpcrdma_data_dir(writing);
 	struct rpcrdma_mr_seg *seg1 = seg;
 	struct rpcrdma_mw *mw = seg1->rl_mw;
 	u64 physaddrs[RPCRDMA_MAX_DATA_SEGS];
@@ -97,7 +99,7 @@ fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	if (nsegs > RPCRDMA_MAX_FMR_SGES)
 		nsegs = RPCRDMA_MAX_FMR_SGES;
 	for (i = 0; i < nsegs;) {
-		rpcrdma_map_one(ia, seg, writing);
+		rpcrdma_map_one(device, seg, direction);
 		physaddrs[i] = seg->mr_dma;
 		len += seg->mr_len;
 		++seg;
@@ -123,7 +125,7 @@ out_maperr:
 		__func__, len, (unsigned long long)seg1->mr_dma,
 		pageoff, i, rc);
 	while (i--)
-		rpcrdma_unmap_one(ia, --seg);
+		rpcrdma_unmap_one(device, --seg);
 	return rc;
 }
 
@@ -135,14 +137,16 @@ fmr_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
 {
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	struct rpcrdma_mr_seg *seg1 = seg;
+	struct ib_device *device;
 	int rc, nsegs = seg->mr_nsegs;
 	LIST_HEAD(l);
 
 	list_add(&seg1->rl_mw->r.fmr->list, &l);
 	rc = ib_unmap_fmr(&l);
 	read_lock(&ia->ri_qplock);
+	device = ia->ri_id->device;
 	while (seg1->mr_nsegs--)
-		rpcrdma_unmap_one(ia, seg++);
+		rpcrdma_unmap_one(device, seg++);
 	read_unlock(&ia->ri_qplock);
 	if (rc)
 		goto out_err;
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index ea59c1b..0a7b9df 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -178,6 +178,8 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	    int nsegs, bool writing)
 {
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
+	struct ib_device *device = ia->ri_id->device;
+	enum dma_data_direction direction = rpcrdma_data_dir(writing);
 	struct rpcrdma_mr_seg *seg1 = seg;
 	struct rpcrdma_mw *mw = seg1->rl_mw;
 	struct rpcrdma_frmr *frmr = &mw->r.frmr;
@@ -197,7 +199,7 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	if (nsegs > ia->ri_max_frmr_depth)
 		nsegs = ia->ri_max_frmr_depth;
 	for (page_no = i = 0; i < nsegs;) {
-		rpcrdma_map_one(ia, seg, writing);
+		rpcrdma_map_one(device, seg, direction);
 		pa = seg->mr_dma;
 		for (seg_len = seg->mr_len; seg_len > 0; seg_len -= PAGE_SIZE) {
 			frmr->fr_pgl->page_list[page_no++] = pa;
@@ -247,7 +249,7 @@ out_senderr:
 	ib_update_fast_reg_key(mr, --key);
 	frmr->fr_state = FRMR_IS_INVALID;
 	while (i--)
-		rpcrdma_unmap_one(ia, --seg);
+		rpcrdma_unmap_one(device, --seg);
 	return rc;
 }
 
@@ -261,6 +263,7 @@ frwr_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	struct ib_send_wr invalidate_wr, *bad_wr;
 	int rc, nsegs = seg->mr_nsegs;
+	struct ib_device *device;
 
 	seg1->rl_mw->r.frmr.fr_state = FRMR_IS_INVALID;
 
@@ -271,8 +274,9 @@ frwr_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
 	DECR_CQCOUNT(&r_xprt->rx_ep);
 
 	read_lock(&ia->ri_qplock);
+	device = ia->ri_id->device;
 	while (seg1->mr_nsegs--)
-		rpcrdma_unmap_one(ia, seg++);
+		rpcrdma_unmap_one(device, seg++);
 	rc = ib_post_send(ia->ri_id->qp, &invalidate_wr, &bad_wr);
 	read_unlock(&ia->ri_qplock);
 	if (rc)
diff --git a/net/sunrpc/xprtrdma/physical_ops.c b/net/sunrpc/xprtrdma/physical_ops.c
index 0ba130b..ba518af 100644
--- a/net/sunrpc/xprtrdma/physical_ops.c
+++ b/net/sunrpc/xprtrdma/physical_ops.c
@@ -50,7 +50,8 @@ physical_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 {
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 
-	rpcrdma_map_one(ia, seg, writing);
+	rpcrdma_map_one(ia->ri_id->device, seg,
+			rpcrdma_data_dir(writing));
 	seg->mr_rkey = ia->ri_bind_mem->rkey;
 	seg->mr_base = seg->mr_dma;
 	seg->mr_nsegs = 1;
@@ -62,7 +63,12 @@ physical_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 static int
 physical_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
 {
-	rpcrdma_unmap_one(&r_xprt->rx_ia, seg);
+	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
+
+	read_lock(&ia->ri_qplock);
+	rpcrdma_unmap_one(ia->ri_id->device, seg);
+	read_unlock(&ia->ri_qplock);
+
 	return 1;
 }
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index cac06f2..4870d27 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1436,6 +1436,14 @@ rpcrdma_recv_buffer_put(struct rpcrdma_rep *rep)
  * Wrappers for internal-use kmalloc memory registration, used by buffer code.
  */
 
+void
+rpcrdma_mapping_error(struct rpcrdma_mr_seg *seg)
+{
+	dprintk("RPC:       map_one: offset %p iova %llx len %zu\n",
+		seg->mr_offset,
+		(unsigned long long)seg->mr_dma, seg->mr_dmalen);
+}
+
 static int
 rpcrdma_register_internal(struct rpcrdma_ia *ia, void *va, int len,
 				struct ib_mr **mrp, struct ib_sge *iov)
@@ -1561,42 +1569,6 @@ rpcrdma_free_regbuf(struct rpcrdma_ia *ia, struct rpcrdma_regbuf *rb)
 }
 
 /*
- * Wrappers for chunk registration, shared by read/write chunk code.
- */
-
-void
-rpcrdma_map_one(struct rpcrdma_ia *ia, struct rpcrdma_mr_seg *seg, bool writing)
-{
-	seg->mr_dir = writing ? DMA_FROM_DEVICE : DMA_TO_DEVICE;
-	seg->mr_dmalen = seg->mr_len;
-	if (seg->mr_page)
-		seg->mr_dma = ib_dma_map_page(ia->ri_id->device,
-				seg->mr_page, offset_in_page(seg->mr_offset),
-				seg->mr_dmalen, seg->mr_dir);
-	else
-		seg->mr_dma = ib_dma_map_single(ia->ri_id->device,
-				seg->mr_offset,
-				seg->mr_dmalen, seg->mr_dir);
-	if (ib_dma_mapping_error(ia->ri_id->device, seg->mr_dma)) {
-		dprintk("RPC:       %s: mr_dma %llx mr_offset %p mr_dma_len %zu\n",
-			__func__,
-			(unsigned long long)seg->mr_dma,
-			seg->mr_offset, seg->mr_dmalen);
-	}
-}
-
-void
-rpcrdma_unmap_one(struct rpcrdma_ia *ia, struct rpcrdma_mr_seg *seg)
-{
-	if (seg->mr_page)
-		ib_dma_unmap_page(ia->ri_id->device,
-				seg->mr_dma, seg->mr_dmalen, seg->mr_dir);
-	else
-		ib_dma_unmap_single(ia->ri_id->device,
-				seg->mr_dma, seg->mr_dmalen, seg->mr_dir);
-}
-
-/*
  * Prepost any receive buffer, then post send.
  *
  * Receive buffer is donated to hardware, reclaimed upon recv completion.
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 54bcbe4..78e0b8b 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -424,8 +424,49 @@ void rpcrdma_free_regbuf(struct rpcrdma_ia *,
 			 struct rpcrdma_regbuf *);
 
 unsigned int rpcrdma_max_segments(struct rpcrdma_xprt *);
-void rpcrdma_map_one(struct rpcrdma_ia *, struct rpcrdma_mr_seg *, bool);
-void rpcrdma_unmap_one(struct rpcrdma_ia *, struct rpcrdma_mr_seg *);
+
+/*
+ * Wrappers for chunk registration, shared by read/write chunk code.
+ */
+
+void rpcrdma_mapping_error(struct rpcrdma_mr_seg *);
+
+static inline enum dma_data_direction
+rpcrdma_data_dir(bool writing)
+{
+	return writing ? DMA_FROM_DEVICE : DMA_TO_DEVICE;
+}
+
+static inline void
+rpcrdma_map_one(struct ib_device *device, struct rpcrdma_mr_seg *seg,
+		enum dma_data_direction direction)
+{
+	seg->mr_dir = direction;
+	seg->mr_dmalen = seg->mr_len;
+
+	if (seg->mr_page)
+		seg->mr_dma = ib_dma_map_page(device,
+				seg->mr_page, offset_in_page(seg->mr_offset),
+				seg->mr_dmalen, seg->mr_dir);
+	else
+		seg->mr_dma = ib_dma_map_single(device,
+				seg->mr_offset,
+				seg->mr_dmalen, seg->mr_dir);
+
+	if (ib_dma_mapping_error(device, seg->mr_dma))
+		rpcrdma_mapping_error(seg);
+}
+
+static inline void
+rpcrdma_unmap_one(struct ib_device *device, struct rpcrdma_mr_seg *seg)
+{
+	if (seg->mr_page)
+		ib_dma_unmap_page(device,
+				  seg->mr_dma, seg->mr_dmalen, seg->mr_dir);
+	else
+		ib_dma_unmap_single(device,
+				    seg->mr_dma, seg->mr_dmalen, seg->mr_dir);
+}
 
 /*
  * RPC/RDMA connection management calls - xprtrdma/rpc_rdma.c


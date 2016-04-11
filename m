Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33579 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbcDKULe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Apr 2016 16:11:34 -0400
Subject: [PATCH v1 10/18] xprtrdma: Rename rpcrdma_frwr::sg and sg_nents
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 11 Apr 2016 16:11:32 -0400
Message-ID: <20160411201132.20531.655.stgit@manet.1015granger.net>
In-Reply-To: <20160411200323.20531.8893.stgit@manet.1015granger.net>
References: <20160411200323.20531.8893.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Follow same naming convention as other fields in struct
rpcrdma_frwr.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c  |   36 ++++++++++++++++++------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    4 ++--
 2 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 41e02e7..7c22e9e 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -152,11 +152,11 @@ __frwr_init(struct rpcrdma_mw *r, struct ib_pd *pd, struct ib_device *device,
 	if (IS_ERR(f->fr_mr))
 		goto out_mr_err;
 
-	f->sg = kcalloc(depth, sizeof(*f->sg), GFP_KERNEL);
-	if (!f->sg)
+	f->fr_sg = kcalloc(depth, sizeof(*f->fr_sg), GFP_KERNEL);
+	if (!f->fr_sg)
 		goto out_list_err;
 
-	sg_init_table(f->sg, depth);
+	sg_init_table(f->fr_sg, depth);
 
 	init_completion(&f->fr_linv_done);
 
@@ -185,7 +185,7 @@ __frwr_release(struct rpcrdma_mw *r)
 	if (rc)
 		dprintk("RPC:       %s: ib_dereg_mr status %i\n",
 			__func__, rc);
-	kfree(r->frmr.sg);
+	kfree(r->frmr.fr_sg);
 }
 
 static int
@@ -399,12 +399,12 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 
 	for (i = 0; i < nsegs;) {
 		if (seg->mr_page)
-			sg_set_page(&frmr->sg[i],
+			sg_set_page(&frmr->fr_sg[i],
 				    seg->mr_page,
 				    seg->mr_len,
 				    offset_in_page(seg->mr_offset));
 		else
-			sg_set_buf(&frmr->sg[i], seg->mr_offset,
+			sg_set_buf(&frmr->fr_sg[i], seg->mr_offset,
 				   seg->mr_len);
 
 		++seg;
@@ -415,25 +415,25 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 		    offset_in_page((seg-1)->mr_offset + (seg-1)->mr_len))
 			break;
 	}
-	frmr->sg_nents = i;
+	frmr->fr_nents = i;
 
-	dma_nents = ib_dma_map_sg(device, frmr->sg, frmr->sg_nents, direction);
+	dma_nents = ib_dma_map_sg(device, frmr->fr_sg, frmr->fr_nents, direction);
 	if (!dma_nents) {
 		pr_err("RPC:       %s: failed to dma map sg %p sg_nents %u\n",
-		       __func__, frmr->sg, frmr->sg_nents);
+		       __func__, frmr->fr_sg, frmr->fr_nents);
 		return -ENOMEM;
 	}
 
-	n = ib_map_mr_sg(mr, frmr->sg, frmr->sg_nents, PAGE_SIZE);
-	if (unlikely(n != frmr->sg_nents)) {
+	n = ib_map_mr_sg(mr, frmr->fr_sg, frmr->fr_nents, PAGE_SIZE);
+	if (unlikely(n != frmr->fr_nents)) {
 		pr_err("RPC:       %s: failed to map mr %p (%u/%u)\n",
-		       __func__, frmr->fr_mr, n, frmr->sg_nents);
+		       __func__, frmr->fr_mr, n, frmr->fr_nents);
 		rc = n < 0 ? n : -EINVAL;
 		goto out_senderr;
 	}
 
 	dprintk("RPC:       %s: Using frmr %p to map %u segments (%u bytes)\n",
-		__func__, mw, frmr->sg_nents, mr->length);
+		__func__, mw, frmr->fr_nents, mr->length);
 
 	key = (u8)(mr->rkey & 0x000000FF);
 	ib_update_fast_reg_key(mr, ++key);
@@ -459,14 +459,14 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	seg1->rl_mw = mw;
 	seg1->mr_rkey = mr->rkey;
 	seg1->mr_base = mr->iova;
-	seg1->mr_nsegs = frmr->sg_nents;
+	seg1->mr_nsegs = frmr->fr_nents;
 	seg1->mr_len = mr->length;
 
-	return frmr->sg_nents;
+	return frmr->fr_nents;
 
 out_senderr:
 	dprintk("RPC:       %s: ib_post_send status %i\n", __func__, rc);
-	ib_dma_unmap_sg(device, frmr->sg, dma_nents, direction);
+	ib_dma_unmap_sg(device, frmr->fr_sg, dma_nents, direction);
 	__frwr_queue_recovery(mw);
 	return rc;
 }
@@ -500,7 +500,7 @@ __frwr_dma_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 
 	seg->rl_mw = NULL;
 
-	ib_dma_unmap_sg(device, f->sg, f->sg_nents, seg->mr_dir);
+	ib_dma_unmap_sg(device, f->fr_sg, f->fr_nents, seg->mr_dir);
 
 	if (!rc)
 		rpcrdma_put_mw(r_xprt, mw);
@@ -611,7 +611,7 @@ frwr_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
 	invalidate_wr->ex.invalidate_rkey = frmr->fr_mr->rkey;
 	DECR_CQCOUNT(&r_xprt->rx_ep);
 
-	ib_dma_unmap_sg(ia->ri_device, frmr->sg, frmr->sg_nents, seg1->mr_dir);
+	ib_dma_unmap_sg(ia->ri_device, frmr->fr_sg, frmr->fr_nents, seg1->mr_dir);
 	read_lock(&ia->ri_qplock);
 	rc = ib_post_send(ia->ri_id->qp, invalidate_wr, &bad_wr);
 	read_unlock(&ia->ri_qplock);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index d44e6e3..abfce80 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -220,8 +220,8 @@ enum rpcrdma_frmr_state {
 };
 
 struct rpcrdma_frmr {
-	struct scatterlist		*sg;
-	int				sg_nents;
+	struct scatterlist		*fr_sg;
+	int				fr_nents;
 	struct ib_mr			*fr_mr;
 	struct ib_cqe			fr_cqe;
 	enum rpcrdma_frmr_state		fr_state;


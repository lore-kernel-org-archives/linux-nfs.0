Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:33472 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932088AbbLNVSN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Dec 2015 16:18:13 -0500
Subject: [PATCH v3 04/11] xprtrdma: Move struct ib_send_wr off the stack
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 14 Dec 2015 16:18:11 -0500
Message-ID: <20151214211811.16295.47695.stgit@manet.1015granger.net>
In-Reply-To: <20151214211317.16295.70115.stgit@manet.1015granger.net>
References: <20151214211317.16295.70115.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For FRWR FASTREG and LOCAL_INV, move the ib_*_wr structure off
the stack. This allows frwr_op_map and frwr_op_unmap to chain
WRs together without limit to register or invalidate a set of MRs
with a single ib_post_send().

(This will be for chaining LOCAL_INV requests).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c  |   38 ++++++++++++++++++++------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 ++
 2 files changed, 22 insertions(+), 18 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index ae2a241..660d0b6 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -318,7 +318,7 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	struct rpcrdma_mw *mw;
 	struct rpcrdma_frmr *frmr;
 	struct ib_mr *mr;
-	struct ib_reg_wr reg_wr;
+	struct ib_reg_wr *reg_wr;
 	struct ib_send_wr *bad_wr;
 	int rc, i, n, dma_nents;
 	u8 key;
@@ -335,6 +335,7 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	frmr = &mw->r.frmr;
 	frmr->fr_state = FRMR_IS_VALID;
 	mr = frmr->fr_mr;
+	reg_wr = &frmr->fr_regwr;
 
 	if (nsegs > ia->ri_max_frmr_depth)
 		nsegs = ia->ri_max_frmr_depth;
@@ -380,19 +381,19 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	key = (u8)(mr->rkey & 0x000000FF);
 	ib_update_fast_reg_key(mr, ++key);
 
-	reg_wr.wr.next = NULL;
-	reg_wr.wr.opcode = IB_WR_REG_MR;
-	reg_wr.wr.wr_id = (uintptr_t)mw;
-	reg_wr.wr.num_sge = 0;
-	reg_wr.wr.send_flags = 0;
-	reg_wr.mr = mr;
-	reg_wr.key = mr->rkey;
-	reg_wr.access = writing ?
-			IB_ACCESS_REMOTE_WRITE | IB_ACCESS_LOCAL_WRITE :
-			IB_ACCESS_REMOTE_READ;
+	reg_wr->wr.next = NULL;
+	reg_wr->wr.opcode = IB_WR_REG_MR;
+	reg_wr->wr.wr_id = (uintptr_t)mw;
+	reg_wr->wr.num_sge = 0;
+	reg_wr->wr.send_flags = 0;
+	reg_wr->mr = mr;
+	reg_wr->key = mr->rkey;
+	reg_wr->access = writing ?
+			 IB_ACCESS_REMOTE_WRITE | IB_ACCESS_LOCAL_WRITE :
+			 IB_ACCESS_REMOTE_READ;
 
 	DECR_CQCOUNT(&r_xprt->rx_ep);
-	rc = ib_post_send(ia->ri_id->qp, &reg_wr.wr, &bad_wr);
+	rc = ib_post_send(ia->ri_id->qp, &reg_wr->wr, &bad_wr);
 	if (rc)
 		goto out_senderr;
 
@@ -422,23 +423,24 @@ frwr_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	struct rpcrdma_mw *mw = seg1->rl_mw;
 	struct rpcrdma_frmr *frmr = &mw->r.frmr;
-	struct ib_send_wr invalidate_wr, *bad_wr;
+	struct ib_send_wr *invalidate_wr, *bad_wr;
 	int rc, nsegs = seg->mr_nsegs;
 
 	dprintk("RPC:       %s: FRMR %p\n", __func__, mw);
 
 	seg1->rl_mw = NULL;
 	frmr->fr_state = FRMR_IS_INVALID;
+	invalidate_wr = &mw->r.frmr.fr_invwr;
 
-	memset(&invalidate_wr, 0, sizeof(invalidate_wr));
-	invalidate_wr.wr_id = (unsigned long)(void *)mw;
-	invalidate_wr.opcode = IB_WR_LOCAL_INV;
-	invalidate_wr.ex.invalidate_rkey = frmr->fr_mr->rkey;
+	memset(invalidate_wr, 0, sizeof(*invalidate_wr));
+	invalidate_wr->wr_id = (uintptr_t)mw;
+	invalidate_wr->opcode = IB_WR_LOCAL_INV;
+	invalidate_wr->ex.invalidate_rkey = frmr->fr_mr->rkey;
 	DECR_CQCOUNT(&r_xprt->rx_ep);
 
 	ib_dma_unmap_sg(ia->ri_device, frmr->sg, frmr->sg_nents, seg1->mr_dir);
 	read_lock(&ia->ri_qplock);
-	rc = ib_post_send(ia->ri_id->qp, &invalidate_wr, &bad_wr);
+	rc = ib_post_send(ia->ri_id->qp, invalidate_wr, &bad_wr);
 	read_unlock(&ia->ri_qplock);
 	if (rc)
 		goto out_err;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 4197191..e60d817 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -206,6 +206,8 @@ struct rpcrdma_frmr {
 	enum rpcrdma_frmr_state		fr_state;
 	struct work_struct		fr_work;
 	struct rpcrdma_xprt		*fr_xprt;
+	struct ib_reg_wr		fr_regwr;
+	struct ib_send_wr		fr_invwr;
 };
 
 struct rpcrdma_fmr {


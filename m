Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f193.google.com ([209.85.213.193]:35635 "EHLO
	mail-ig0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933101AbcDYTWU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Apr 2016 15:22:20 -0400
Subject: [PATCH v2 11/18] xprtrdma: Save I/O direction in struct rpcrdma_frwr
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 25 Apr 2016 15:22:18 -0400
Message-ID: <20160425192218.3566.13233.stgit@manet.1015granger.net>
In-Reply-To: <20160425185956.3566.64142.stgit@manet.1015granger.net>
References: <20160425185956.3566.64142.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the the I/O direction field from rpcrdma_mr_seg into the
rpcrdma_frmr. This makes it possible to perform the DMA unmapping
long after the rpcrdma_mr_seg has been released and re-used.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c  |    6 +++---
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 7c22e9e..e1e6ac1 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -416,6 +416,7 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 			break;
 	}
 	frmr->fr_nents = i;
+	frmr->fr_dir = direction;
 
 	dma_nents = ib_dma_map_sg(device, frmr->fr_sg, frmr->fr_nents, direction);
 	if (!dma_nents) {
@@ -455,7 +456,6 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	if (rc)
 		goto out_senderr;
 
-	seg1->mr_dir = direction;
 	seg1->rl_mw = mw;
 	seg1->mr_rkey = mr->rkey;
 	seg1->mr_base = mr->iova;
@@ -500,7 +500,7 @@ __frwr_dma_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 
 	seg->rl_mw = NULL;
 
-	ib_dma_unmap_sg(device, f->fr_sg, f->fr_nents, seg->mr_dir);
+	ib_dma_unmap_sg(device, f->fr_sg, f->fr_nents, f->fr_dir);
 
 	if (!rc)
 		rpcrdma_put_mw(r_xprt, mw);
@@ -611,7 +611,7 @@ frwr_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
 	invalidate_wr->ex.invalidate_rkey = frmr->fr_mr->rkey;
 	DECR_CQCOUNT(&r_xprt->rx_ep);
 
-	ib_dma_unmap_sg(ia->ri_device, frmr->fr_sg, frmr->fr_nents, seg1->mr_dir);
+	ib_dma_unmap_sg(ia->ri_device, frmr->fr_sg, frmr->fr_nents, frmr->fr_dir);
 	read_lock(&ia->ri_qplock);
 	rc = ib_post_send(ia->ri_id->qp, invalidate_wr, &bad_wr);
 	read_unlock(&ia->ri_qplock);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index abfce80..0b3aa54 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -222,6 +222,7 @@ enum rpcrdma_frmr_state {
 struct rpcrdma_frmr {
 	struct scatterlist		*fr_sg;
 	int				fr_nents;
+	enum dma_data_direction		fr_dir;
 	struct ib_mr			*fr_mr;
 	struct ib_cqe			fr_cqe;
 	enum rpcrdma_frmr_state		fr_state;


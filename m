Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f169.google.com ([209.85.213.169]:60630 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147AbaFWWkJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 18:40:09 -0400
Subject: [PATCH v1 08/13] xprtrdma: Back off rkey when FAST_REG_MR fails
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 23 Jun 2014 18:40:07 -0400
Message-ID: <20140623224007.1634.55636.stgit@manet.1015granger.net>
In-Reply-To: <20140623223201.1634.83888.stgit@manet.1015granger.net>
References: <20140623223201.1634.83888.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If posting a FAST_REG_MR Work Reqeust fails, or the FAST_REG WR
flushes, revert the rkey update to avoid subsequent
IB_WC_MW_BIND_ERR completions.

Suggested-by: Steve Wise <swise@opengridcomputing.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   39 +++++++++++++++++++++++++++++----------
 1 file changed, 29 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index cef67fd..3efc007 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -61,6 +61,8 @@
 # define RPCDBG_FACILITY	RPCDBG_TRANS
 #endif
 
+static void rpcrdma_decrement_frmr_rkey(struct rpcrdma_mw *);
+
 /*
  * internal functions
  */
@@ -154,13 +156,17 @@ rpcrdma_sendcq_process_wc(struct ib_wc *wc)
 
 	if (wrid == 0)
 		return;
-	if (wc->status != IB_WC_SUCCESS)
-		return;
 
 	fastreg = test_and_clear_bit(RPCRDMA_BIT_FASTREG, &wrid);
 	mw = (struct rpcrdma_mw *)wrid;
 
-	mw->r.frmr.fr_state = fastreg ? FRMR_IS_VALID : FRMR_IS_INVALID;
+	if (wc->status == IB_WC_SUCCESS) {
+		mw->r.frmr.fr_state = fastreg ?
+				FRMR_IS_VALID : FRMR_IS_INVALID;
+	} else {
+		if (fastreg)
+			rpcrdma_decrement_frmr_rkey(mw);
+	}
 }
 
 static int
@@ -1480,6 +1486,24 @@ rpcrdma_unmap_one(struct rpcrdma_ia *ia, struct rpcrdma_mr_seg *seg)
 				seg->mr_dma, seg->mr_dmalen, seg->mr_dir);
 }
 
+static void
+rpcrdma_increment_frmr_rkey(struct rpcrdma_mw *mw)
+{
+	struct ib_mr *frmr = mw->r.frmr.fr_mr;
+	u8 key = frmr->rkey & 0x000000FF;
+
+	ib_update_fast_reg_key(frmr, ++key);
+}
+
+static void
+rpcrdma_decrement_frmr_rkey(struct rpcrdma_mw *mw)
+{
+	struct ib_mr *frmr = mw->r.frmr.fr_mr;
+	u8 key = frmr->rkey & 0x000000FF;
+
+	ib_update_fast_reg_key(frmr, --key);
+}
+
 static int
 rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 			int *nsegs, int writing, struct rpcrdma_ia *ia,
@@ -1487,8 +1511,6 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 {
 	struct rpcrdma_mr_seg *seg1 = seg;
 	struct ib_send_wr invalidate_wr, frmr_wr, *bad_wr, *post_wr;
-
-	u8 key;
 	int len, pageoff;
 	int i, rc;
 	int seg_len;
@@ -1552,14 +1574,10 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 		rc = -EIO;
 		goto out_err;
 	}
-
-	/* Bump the key */
-	key = (u8)(seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey & 0x000000FF);
-	ib_update_fast_reg_key(seg1->mr_chunk.rl_mw->r.frmr.fr_mr, ++key);
-
 	frmr_wr.wr.fast_reg.access_flags = (writing ?
 				IB_ACCESS_REMOTE_WRITE | IB_ACCESS_LOCAL_WRITE :
 				IB_ACCESS_REMOTE_READ);
+	rpcrdma_increment_frmr_rkey(seg1->mr_chunk.rl_mw);
 	frmr_wr.wr.fast_reg.rkey = seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey;
 	DECR_CQCOUNT(&r_xprt->rx_ep);
 
@@ -1568,6 +1586,7 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	if (rc) {
 		dprintk("RPC:       %s: failed ib_post_send for register,"
 			" status %i\n", __func__, rc);
+		rpcrdma_decrement_frmr_rkey(seg1->mr_chunk.rl_mw);
 		goto out_err;
 	} else {
 		seg1->mr_rkey = seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey;


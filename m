Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:64772 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755812AbaGVOxV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jul 2014 10:53:21 -0400
Subject: [PATCH v4 16/21] xprtrdma: Rename frmr_wr
From: Chuck Lever <chuck.lever@oracle.com>
To: Anna.Schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 22 Jul 2014 10:53:18 -0400
Message-ID: <20140722145318.6010.34299.stgit@manet.1015granger.net>
In-Reply-To: <20140722144459.6010.99389.stgit@manet.1015granger.net>
References: <20140722144459.6010.99389.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Name frmr_wr after the opcode of the Work Request,
consistent with the send and local invalidation paths.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Steve Wise <swise@opengridcomputing.com>
Tested-by: Shirley Ma <shirley.ma@oracle.com>
Tested-by: Devesh Sharma <devesh.sharma@emulex.com>
---
 net/sunrpc/xprtrdma/verbs.c |   26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index fa5199d..1294338 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1684,7 +1684,7 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	struct rpcrdma_mw *mw = seg1->mr_chunk.rl_mw;
 	struct rpcrdma_frmr *frmr = &mw->r.frmr;
 	struct ib_mr *mr = frmr->fr_mr;
-	struct ib_send_wr frmr_wr, *bad_wr;
+	struct ib_send_wr fastreg_wr, *bad_wr;
 	int len, pageoff;
 	int i, rc;
 	int seg_len;
@@ -1718,27 +1718,27 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 
 	frmr->fr_state = FRMR_IS_VALID;
 
-	memset(&frmr_wr, 0, sizeof frmr_wr);
-	frmr_wr.wr_id = (unsigned long)(void *)mw;
-	frmr_wr.opcode = IB_WR_FAST_REG_MR;
-	frmr_wr.wr.fast_reg.iova_start = seg1->mr_dma;
-	frmr_wr.wr.fast_reg.page_list = frmr->fr_pgl;
-	frmr_wr.wr.fast_reg.page_list_len = page_no;
-	frmr_wr.wr.fast_reg.page_shift = PAGE_SHIFT;
-	frmr_wr.wr.fast_reg.length = page_no << PAGE_SHIFT;
-	if (frmr_wr.wr.fast_reg.length < len) {
+	memset(&fastreg_wr, 0, sizeof(fastreg_wr));
+	fastreg_wr.wr_id = (unsigned long)(void *)mw;
+	fastreg_wr.opcode = IB_WR_FAST_REG_MR;
+	fastreg_wr.wr.fast_reg.iova_start = seg1->mr_dma;
+	fastreg_wr.wr.fast_reg.page_list = frmr->fr_pgl;
+	fastreg_wr.wr.fast_reg.page_list_len = page_no;
+	fastreg_wr.wr.fast_reg.page_shift = PAGE_SHIFT;
+	fastreg_wr.wr.fast_reg.length = page_no << PAGE_SHIFT;
+	if (fastreg_wr.wr.fast_reg.length < len) {
 		rc = -EIO;
 		goto out_err;
 	}
-	frmr_wr.wr.fast_reg.access_flags = (writing ?
+	fastreg_wr.wr.fast_reg.access_flags = (writing ?
 				IB_ACCESS_REMOTE_WRITE | IB_ACCESS_LOCAL_WRITE :
 				IB_ACCESS_REMOTE_READ);
 	rkey = ib_inc_rkey(mr->rkey);
 	ib_update_fast_reg_key(mr, rkey);
-	frmr_wr.wr.fast_reg.rkey = mr->rkey;
+	fastreg_wr.wr.fast_reg.rkey = frmr->fr_mr->rkey;
 	DECR_CQCOUNT(&r_xprt->rx_ep);
 
-	rc = ib_post_send(ia->ri_id->qp, &frmr_wr, &bad_wr);
+	rc = ib_post_send(ia->ri_id->qp, &fastreg_wr, &bad_wr);
 	if (rc) {
 		dprintk("RPC:       %s: failed ib_post_send for register,"
 			" status %i\n", __func__, rc);


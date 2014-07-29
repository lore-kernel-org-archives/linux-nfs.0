Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:35438 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754309AbaG2VZF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 17:25:05 -0400
Subject: [PATCH v5 13/21] xprtrdma: Don't post a LOCAL_INV in
 rpcrdma_register_frmr_external()
From: Chuck Lever <chuck.lever@oracle.com>
To: Anna.Schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 29 Jul 2014 17:25:03 -0400
Message-ID: <20140729212503.2812.14645.stgit@manet.1015granger.net>
In-Reply-To: <20140729211534.2812.3128.stgit@manet.1015granger.net>
References: <20140729211534.2812.3128.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Any FRMR arriving in rpcrdma_register_frmr_external() is now
guaranteed to be either invalid, or to be targeted by a queued
LOCAL_INV that will invalidate it before the adapter processes
the FAST_REG_MR being built here.

The problem with current arrangement of chaining a LOCAL_INV to the
FAST_REG_MR is that if the transport is not connected, the LOCAL_INV
is flushed and the FAST_REG_MR is flushed. This leaves the FRMR
valid with the old rkey. But rpcrdma_register_frmr_external() has
already bumped the in-memory rkey.

Next time through rpcrdma_register_frmr_external(), a LOCAL_INV and
FAST_REG_MR is attempted again because the FRMR is still valid. But
the rkey no longer matches the hardware's rkey, and a memory
management operation error occurs.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Steve Wise <swise@opengridcomputing.com>
Tested-by: Shirley Ma <shirley.ma@oracle.com>
Tested-by: Devesh Sharma <devesh.sharma@emulex.com>
---
 net/sunrpc/xprtrdma/verbs.c |   22 ++--------------------
 1 file changed, 2 insertions(+), 20 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 2e91745..8da9a35 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1692,8 +1692,7 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	struct rpcrdma_mw *mw = seg1->mr_chunk.rl_mw;
 	struct rpcrdma_frmr *frmr = &mw->r.frmr;
 	struct ib_mr *mr = frmr->fr_mr;
-	struct ib_send_wr invalidate_wr, frmr_wr, *bad_wr, *post_wr;
-
+	struct ib_send_wr frmr_wr, *bad_wr;
 	u8 key;
 	int len, pageoff;
 	int i, rc;
@@ -1725,22 +1724,6 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	dprintk("RPC:       %s: Using frmr %p to map %d segments\n",
 		__func__, mw, i);
 
-	if (unlikely(frmr->fr_state != FRMR_IS_INVALID)) {
-		dprintk("RPC:       %s: frmr %x left valid, posting invalidate.\n",
-			__func__, mr->rkey);
-		/* Invalidate before using. */
-		memset(&invalidate_wr, 0, sizeof invalidate_wr);
-		invalidate_wr.wr_id = (unsigned long)(void *)mw;
-		invalidate_wr.next = &frmr_wr;
-		invalidate_wr.opcode = IB_WR_LOCAL_INV;
-		invalidate_wr.send_flags = IB_SEND_SIGNALED;
-		invalidate_wr.ex.invalidate_rkey = mr->rkey;
-		DECR_CQCOUNT(&r_xprt->rx_ep);
-		post_wr = &invalidate_wr;
-	} else
-		post_wr = &frmr_wr;
-
-	/* Prepare FRMR WR */
 	memset(&frmr_wr, 0, sizeof frmr_wr);
 	frmr_wr.wr_id = (unsigned long)(void *)mw;
 	frmr_wr.opcode = IB_WR_FAST_REG_MR;
@@ -1765,8 +1748,7 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	frmr_wr.wr.fast_reg.rkey = mr->rkey;
 	DECR_CQCOUNT(&r_xprt->rx_ep);
 
-	rc = ib_post_send(ia->ri_id->qp, post_wr, &bad_wr);
-
+	rc = ib_post_send(ia->ri_id->qp, &frmr_wr, &bad_wr);
 	if (rc) {
 		dprintk("RPC:       %s: failed ib_post_send for register,"
 			" status %i\n", __func__, rc);


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:59927 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756476AbaGIQ6X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jul 2014 12:58:23 -0400
Subject: [PATCH v2 13/21] xprtrdma: Don't post a LOCAL_INV in
 rpcrdma_register_frmr_external()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 09 Jul 2014 12:58:21 -0400
Message-ID: <20140709165821.3496.25120.stgit@manet.1015granger.net>
In-Reply-To: <20140709163326.3496.37893.stgit@manet.1015granger.net>
References: <20140709163326.3496.37893.stgit@manet.1015granger.net>
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
---
 net/sunrpc/xprtrdma/verbs.c |   21 ++-------------------
 1 file changed, 2 insertions(+), 19 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 877c928..78290bb 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1709,7 +1709,7 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	struct rpcrdma_mr_seg *seg1 = seg;
 	struct rpcrdma_mw *mw = seg1->mr_chunk.rl_mw;
 	struct rpcrdma_frmr *frmr = &mw->r.frmr;
-	struct ib_send_wr invalidate_wr, frmr_wr, *bad_wr, *post_wr;
+	struct ib_send_wr frmr_wr, *bad_wr;
 	int len, pageoff;
 	int i, rc;
 	int seg_len;
@@ -1740,22 +1740,6 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	dprintk("RPC:       %s: Using frmr %p to map %d segments\n",
 		__func__, mw, i);
 
-	if (unlikely(frmr->fr_state != FRMR_IS_INVALID)) {
-		dprintk("RPC:       %s: frmr %x left valid, posting invalidate.\n",
-			__func__, frmr->fr_mr->rkey);
-		/* Invalidate before using. */
-		memset(&invalidate_wr, 0, sizeof invalidate_wr);
-		invalidate_wr.wr_id = (unsigned long)(void *)mw;
-		invalidate_wr.next = &frmr_wr;
-		invalidate_wr.opcode = IB_WR_LOCAL_INV;
-		invalidate_wr.send_flags = IB_SEND_SIGNALED;
-		invalidate_wr.ex.invalidate_rkey = frmr->fr_mr->rkey;
-		DECR_CQCOUNT(&r_xprt->rx_ep);
-		post_wr = &invalidate_wr;
-	} else
-		post_wr = &frmr_wr;
-
-	/* Prepare FRMR WR */
 	memset(&frmr_wr, 0, sizeof frmr_wr);
 	frmr_wr.wr_id = (unsigned long)(void *)mw;
 	frmr_wr.opcode = IB_WR_FAST_REG_MR;
@@ -1776,8 +1760,7 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	frmr_wr.wr.fast_reg.rkey = frmr->fr_mr->rkey;
 	DECR_CQCOUNT(&r_xprt->rx_ep);
 
-	rc = ib_post_send(ia->ri_id->qp, post_wr, &bad_wr);
-
+	rc = ib_post_send(ia->ri_id->qp, &frmr_wr, &bad_wr);
 	if (rc) {
 		dprintk("RPC:       %s: failed ib_post_send for register,"
 			" status %i\n", __func__, rc);


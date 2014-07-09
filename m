Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f169.google.com ([209.85.223.169]:57080 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755765AbaGIQ6k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jul 2014 12:58:40 -0400
Subject: [PATCH v2 15/21] xprtrdma: Disable completions for LOCAL_INV Work
 Requests
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 09 Jul 2014 12:58:38 -0400
Message-ID: <20140709165838.3496.17169.stgit@manet.1015granger.net>
In-Reply-To: <20140709163326.3496.37893.stgit@manet.1015granger.net>
References: <20140709163326.3496.37893.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of relying on a completion to change the state of an FRMR
to FRMR_IS_INVALID, set it in advance. If an error occurs, a completion
will fire anyway and mark the FRMR FRMR_IS_STALE.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index e83eda6..8eef343 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -154,12 +154,8 @@ rpcrdma_sendcq_process_wc(struct ib_wc *wc)
 
 	if (wc->wr_id == 0ULL)
 		return;
-	if (wc->status != IB_WC_SUCCESS) {
+	if (wc->status != IB_WC_SUCCESS)
 		frmr->r.frmr.fr_state = FRMR_IS_STALE;
-		return;
-	}
-
-	frmr->r.frmr.fr_state = FRMR_IS_INVALID;
 }
 
 static int
@@ -1369,12 +1365,11 @@ rpcrdma_retry_local_inv(struct rpcrdma_mw *r, struct rpcrdma_ia *ia)
 	dprintk("RPC:       %s: FRMR %p is stale\n", __func__, r);
 
 	/* When this FRMR is re-inserted into rb_mws, it is no longer stale */
-	r->r.frmr.fr_state = FRMR_IS_VALID;
+	r->r.frmr.fr_state = FRMR_IS_INVALID;
 
 	memset(&invalidate_wr, 0, sizeof(invalidate_wr));
 	invalidate_wr.wr_id = (unsigned long)(void *)r;
 	invalidate_wr.opcode = IB_WR_LOCAL_INV;
-	invalidate_wr.send_flags = IB_SEND_SIGNALED;
 	invalidate_wr.ex.invalidate_rkey = r->r.frmr.fr_mr->rkey;
 	DECR_CQCOUNT(&r_xprt->rx_ep);
 
@@ -1787,10 +1782,11 @@ rpcrdma_deregister_frmr_external(struct rpcrdma_mr_seg *seg,
 	struct ib_send_wr invalidate_wr, *bad_wr;
 	int rc;
 
+	seg1->mr_chunk.rl_mw->r.frmr.fr_state = FRMR_IS_INVALID;
+
 	memset(&invalidate_wr, 0, sizeof invalidate_wr);
 	invalidate_wr.wr_id = (unsigned long)(void *)seg1->mr_chunk.rl_mw;
 	invalidate_wr.opcode = IB_WR_LOCAL_INV;
-	invalidate_wr.send_flags = IB_SEND_SIGNALED;
 	invalidate_wr.ex.invalidate_rkey = seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey;
 	DECR_CQCOUNT(&r_xprt->rx_ep);
 
@@ -1799,9 +1795,12 @@ rpcrdma_deregister_frmr_external(struct rpcrdma_mr_seg *seg,
 		rpcrdma_unmap_one(ia, seg++);
 	rc = ib_post_send(ia->ri_id->qp, &invalidate_wr, &bad_wr);
 	read_unlock(&ia->ri_qplock);
-	if (rc)
+	if (rc) {
+		/* Force rpcrdma_buffer_get() to retry */
+		seg1->mr_chunk.rl_mw->r.frmr.fr_state = FRMR_IS_STALE;
 		dprintk("RPC:       %s: failed ib_post_send for invalidate,"
 			" status %i\n", __func__, rc);
+	}
 	return rc;
 }
 


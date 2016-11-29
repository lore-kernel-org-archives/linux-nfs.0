Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:32867 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934086AbcK2Pw6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2016 10:52:58 -0500
Subject: [PATCH v3 07/12] xprtrdma: Refactor FRMR invalidation
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 29 Nov 2016 10:52:57 -0500
Message-ID: <20161129155256.23061.43386.stgit@manet.1015granger.net>
In-Reply-To: <20161129154845.23061.29385.stgit@manet.1015granger.net>
References: <20161129154845.23061.29385.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: After some recent updates, clarifications can be made to
the FRMR invalidation logic.

- Both the remote and local invalidation case mark the frmr INVALID,
  so make that a common path.

- Manage the WR list more "tastefully" by replacing the conditional
  that discriminates between the list head and ->next pointers.

- Use mw->mw_handle in all cases, since that has the same value as
  f->fr_mr->rkey, and is already in cache.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c |   57 +++++++++++++++-------------------------
 1 file changed, 21 insertions(+), 36 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index e99bf61..900dc40 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -457,26 +457,6 @@
 	return -ENOTCONN;
 }
 
-static struct ib_send_wr *
-__frwr_prepare_linv_wr(struct rpcrdma_mw *mw)
-{
-	struct rpcrdma_frmr *f = &mw->frmr;
-	struct ib_send_wr *invalidate_wr;
-
-	dprintk("RPC:       %s: invalidating frmr %p\n", __func__, f);
-
-	f->fr_state = FRMR_IS_INVALID;
-	invalidate_wr = &f->fr_invwr;
-
-	memset(invalidate_wr, 0, sizeof(*invalidate_wr));
-	f->fr_cqe.done = frwr_wc_localinv;
-	invalidate_wr->wr_cqe = &f->fr_cqe;
-	invalidate_wr->opcode = IB_WR_LOCAL_INV;
-	invalidate_wr->ex.invalidate_rkey = f->fr_mr->rkey;
-
-	return invalidate_wr;
-}
-
 /* Invalidate all memory regions that were registered for "req".
  *
  * Sleeps until it is safe for the host CPU to access the
@@ -487,7 +467,7 @@
 static void
 frwr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 {
-	struct ib_send_wr *invalidate_wrs, *pos, *prev, *bad_wr;
+	struct ib_send_wr *first, **prev, *last, *bad_wr;
 	struct rpcrdma_rep *rep = req->rl_reply;
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	struct rpcrdma_mw *mw, *tmp;
@@ -503,23 +483,28 @@
 	 */
 	f = NULL;
 	count = 0;
-	invalidate_wrs = pos = prev = NULL;
+	prev = &first;
 	list_for_each_entry(mw, &req->rl_registered, mw_list) {
+		mw->frmr.fr_state = FRMR_IS_INVALID;
+
 		if ((rep->rr_wc_flags & IB_WC_WITH_INVALIDATE) &&
-		    (mw->mw_handle == rep->rr_inv_rkey)) {
-			mw->frmr.fr_state = FRMR_IS_INVALID;
+		    (mw->mw_handle == rep->rr_inv_rkey))
 			continue;
-		}
 
-		pos = __frwr_prepare_linv_wr(mw);
+		f = &mw->frmr;
+		dprintk("RPC:       %s: invalidating frmr %p\n",
+			__func__, f);
+
+		f->fr_cqe.done = frwr_wc_localinv;
+		last = &f->fr_invwr;
+		memset(last, 0, sizeof(*last));
+		last->wr_cqe = &f->fr_cqe;
+		last->opcode = IB_WR_LOCAL_INV;
+		last->ex.invalidate_rkey = mw->mw_handle;
 		count++;
 
-		if (!invalidate_wrs)
-			invalidate_wrs = pos;
-		else
-			prev->next = pos;
-		prev = pos;
-		f = &mw->frmr;
+		*prev = last;
+		prev = &last->next;
 	}
 	if (!f)
 		goto unmap;
@@ -528,7 +513,7 @@
 	 * last WR in the chain completes, all WRs in the chain
 	 * are complete.
 	 */
-	f->fr_invwr.send_flags = IB_SEND_SIGNALED;
+	last->send_flags = IB_SEND_SIGNALED;
 	f->fr_cqe.done = frwr_wc_localinv_wake;
 	reinit_completion(&f->fr_linv_done);
 
@@ -543,7 +528,7 @@
 	 * unless ri_id->qp is a valid pointer.
 	 */
 	r_xprt->rx_stats.local_inv_needed++;
-	rc = ib_post_send(ia->ri_id->qp, invalidate_wrs, &bad_wr);
+	rc = ib_post_send(ia->ri_id->qp, first, &bad_wr);
 	if (rc)
 		goto reset_mrs;
 
@@ -554,7 +539,7 @@
 	 */
 unmap:
 	list_for_each_entry_safe(mw, tmp, &req->rl_registered, mw_list) {
-		dprintk("RPC:       %s: unmapping frmr %p\n",
+		dprintk("RPC:       %s: DMA unmapping frmr %p\n",
 			__func__, &mw->frmr);
 		list_del_init(&mw->mw_list);
 		ib_dma_unmap_sg(ia->ri_device,
@@ -572,7 +557,7 @@
 	 */
 	list_for_each_entry(mw, &req->rl_registered, mw_list) {
 		f = &mw->frmr;
-		if (mw->frmr.fr_mr->rkey == bad_wr->ex.invalidate_rkey) {
+		if (mw->mw_handle == bad_wr->ex.invalidate_rkey) {
 			__frwr_reset_mr(ia, mw);
 			bad_wr = bad_wr->next;
 		}


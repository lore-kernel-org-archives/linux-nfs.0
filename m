Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33193 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968285AbdEWOyE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 May 2017 10:54:04 -0400
Subject: [PATCH v1 03/12] xprtrdma: Fix FRWR invalidation error recovery
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 23 May 2017 10:54:02 -0400
Message-ID: <20170523145402.961.7601.stgit@manet.1015granger.net>
In-Reply-To: <20170523142629.961.81233.stgit@manet.1015granger.net>
References: <20170523142629.961.81233.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When ib_post_send() fails, all LOCAL_INV WRs past @bad_wr have to be
examined, and the MRs reset by hand.

I'm not sure how the existing code can work by comparing R_keys.
Restructure the logic so that instead it walks the chain of WRs,
starting from the first bad one.

Make sure to wait for completion if at least one WR was actually
posted. Otherwise, if the ib_post_send fails, we can end up
DMA-unmapping the MR while LOCAL_INV operations are in flight.

Commit 7a89f9c626e3 ("xprtrdma: Honor ->send_request API contract")
added the rdma_disconnect() call site. The disconnect actually
causes more problems than it solves, and SQ overruns happen only as
a result of software bugs. So remove it.

Fixes: d7a21c1bed54 ("xprtrdma: Reset MRs in frwr_op_unmap_sync()")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c |   23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 33ede72..98808d0 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -521,12 +521,13 @@
 	 * unless ri_id->qp is a valid pointer.
 	 */
 	r_xprt->rx_stats.local_inv_needed++;
+	bad_wr = NULL;
 	rc = ib_post_send(ia->ri_id->qp, first, &bad_wr);
+	if (bad_wr != first)
+		wait_for_completion(&f->fr_linv_done);
 	if (rc)
 		goto reset_mrs;
 
-	wait_for_completion(&f->fr_linv_done);
-
 	/* ORDER: Now DMA unmap all of the req's MRs, and return
 	 * them to the free MW list.
 	 */
@@ -543,17 +544,19 @@
 
 reset_mrs:
 	pr_err("rpcrdma: FRMR invalidate ib_post_send returned %i\n", rc);
-	rdma_disconnect(ia->ri_id);
 
 	/* Find and reset the MRs in the LOCAL_INV WRs that did not
-	 * get posted. This is synchronous, and slow.
+	 * get posted.
 	 */
-	list_for_each_entry(mw, &req->rl_registered, mw_list) {
-		f = &mw->frmr;
-		if (mw->mw_handle == bad_wr->ex.invalidate_rkey) {
-			__frwr_reset_mr(ia, mw);
-			bad_wr = bad_wr->next;
-		}
+	rpcrdma_init_cqcount(&r_xprt->rx_ep, -count);
+	while (bad_wr) {
+		f = container_of(bad_wr, struct rpcrdma_frmr,
+				 fr_invwr);
+		mw = container_of(f, struct rpcrdma_mw, frmr);
+
+		__frwr_reset_mr(ia, mw);
+
+		bad_wr = bad_wr->next;
 	}
 	goto unmap;
 }


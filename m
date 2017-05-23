Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34264 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968285AbdEWOyV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 May 2017 10:54:21 -0400
Subject: [PATCH v1 05/12] xprtrdma: Pass only the list of registered MRs to
 ro_unmap_sync
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 23 May 2017 10:54:18 -0400
Message-ID: <20170523145418.961.95551.stgit@manet.1015granger.net>
In-Reply-To: <20170523142629.961.81233.stgit@manet.1015granger.net>
References: <20170523142629.961.81233.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There are rare cases where an rpcrdma_req can be re-used (via
rpcrdma_buffer_put) while the RPC reply handler is still running.
This is due to a signal firing at just the wrong instant.

Since commit 9d6b04097882 ("xprtrdma: Place registered MWs on a
per-req list"), rpcrdma_mws are self-contained; ie., they fully
describe an MR and scatterlist, and no part of that information is
stored in struct rpcrdma_req.

As part of closing the above race window, pass only the req's list
of registered MRs to ro_unmap_sync, rather than the rpcrdma_req
itself.

Some extra transport header sanity checking is removed. Since the
client depends on its own recollection of what memory had been
registered, there doesn't seem to be a way to abuse this change.

And, the check was not terribly effective. If the client had sent
Read chunks, the "list_empty" test is negative in both of the
removed cases, which are actually looking for Write or Reply
chunks.

BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=305
Fixes: 68791649a725 ('xprtrdma: Invalidate in the RPC reply ... ')
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c   |   16 +++++++++-------
 net/sunrpc/xprtrdma/frwr_ops.c  |   17 ++++++++---------
 net/sunrpc/xprtrdma/rpc_rdma.c  |   16 +++++++---------
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 +-
 4 files changed, 25 insertions(+), 26 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 7b2de86..2f4eacd 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -255,24 +255,26 @@ enum {
  * Sleeps until it is safe for the host CPU to access the
  * previously mapped memory regions.
  *
- * Caller ensures that req->rl_registered is not empty.
+ * Caller ensures that @mws is not empty before the call. This
+ * function empties the list.
  */
 static void
-fmr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
+fmr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct list_head *mws)
 {
 	struct rpcrdma_mw *mw, *tmp;
 	LIST_HEAD(unmap_list);
 	int rc;
 
-	dprintk("RPC:       %s: req %p\n", __func__, req);
-
 	/* ORDER: Invalidate all of the req's MRs first
 	 *
 	 * ib_unmap_fmr() is slow, so use a single call instead
 	 * of one call per mapped FMR.
 	 */
-	list_for_each_entry(mw, &req->rl_registered, mw_list)
+	list_for_each_entry(mw, mws, mw_list) {
+		dprintk("RPC:       %s: unmapping fmr %p\n",
+			__func__, &mw->fmr);
 		list_add_tail(&mw->fmr.fm_mr->list, &unmap_list);
+	}
 	r_xprt->rx_stats.local_inv_needed++;
 	rc = ib_unmap_fmr(&unmap_list);
 	if (rc)
@@ -281,7 +283,7 @@ enum {
 	/* ORDER: Now DMA unmap all of the req's MRs, and return
 	 * them to the free MW list.
 	 */
-	list_for_each_entry_safe(mw, tmp, &req->rl_registered, mw_list) {
+	list_for_each_entry_safe(mw, tmp, mws, mw_list) {
 		list_del_init(&mw->mw_list);
 		list_del_init(&mw->fmr.fm_mr->list);
 		ib_dma_unmap_sg(r_xprt->rx_ia.ri_device,
@@ -294,7 +296,7 @@ enum {
 out_reset:
 	pr_err("rpcrdma: ib_unmap_fmr failed (%i)\n", rc);
 
-	list_for_each_entry_safe(mw, tmp, &req->rl_registered, mw_list) {
+	list_for_each_entry_safe(mw, tmp, mws, mw_list) {
 		list_del_init(&mw->mw_list);
 		list_del_init(&mw->fmr.fm_mr->list);
 		fmr_op_recover_mr(mw);
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 9c0fa4a..8f63d38 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -455,10 +455,11 @@
  * Sleeps until it is safe for the host CPU to access the
  * previously mapped memory regions.
  *
- * Caller ensures that req->rl_registered is not empty.
+ * Caller ensures that @mws is not empty before the call. This
+ * function empties the list.
  */
 static void
-frwr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
+frwr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct list_head *mws)
 {
 	struct ib_send_wr *first, **prev, *last, *bad_wr;
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
@@ -466,9 +467,7 @@
 	struct rpcrdma_mw *mw;
 	int count, rc;
 
-	dprintk("RPC:       %s: req %p\n", __func__, req);
-
-	/* ORDER: Invalidate all of the req's MRs first
+	/* ORDER: Invalidate all of the MRs first
 	 *
 	 * Chain the LOCAL_INV Work Requests and post them with
 	 * a single ib_post_send() call.
@@ -476,7 +475,7 @@
 	f = NULL;
 	count = 0;
 	prev = &first;
-	list_for_each_entry(mw, &req->rl_registered, mw_list) {
+	list_for_each_entry(mw, mws, mw_list) {
 		mw->frmr.fr_state = FRMR_IS_INVALID;
 
 		if (mw->mw_flags & RPCRDMA_MW_F_RI)
@@ -526,12 +525,12 @@
 	if (rc)
 		goto reset_mrs;
 
-	/* ORDER: Now DMA unmap all of the req's MRs, and return
+	/* ORDER: Now DMA unmap all of the MRs, and return
 	 * them to the free MW list.
 	 */
 unmap:
-	while (!list_empty(&req->rl_registered)) {
-		mw = rpcrdma_pop_mw(&req->rl_registered);
+	while (!list_empty(mws)) {
+		mw = rpcrdma_pop_mw(mws);
 		dprintk("RPC:       %s: DMA unmapping frmr %p\n",
 			__func__, &mw->frmr);
 		ib_dma_unmap_sg(ia->ri_device,
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 2356a63..c88132d 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -995,6 +995,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	__be32 *iptr;
 	int rdmalen, status, rmerr;
 	unsigned long cwnd;
+	struct list_head mws;
 
 	dprintk("RPC:       %s: incoming rep %p\n", __func__, rep);
 
@@ -1024,7 +1025,8 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	/* Sanity checking has passed. We are now committed
 	 * to complete this transaction.
 	 */
-	rpcrdma_mark_remote_invalidation(&req->rl_registered, rep);
+	list_replace_init(&req->rl_registered, &mws);
+	rpcrdma_mark_remote_invalidation(&mws, rep);
 	list_del_init(&rqst->rq_list);
 	req->rl_reply = rep;
 	spin_unlock_bh(&xprt->transport_lock);
@@ -1042,12 +1044,9 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	case rdma_msg:
 		/* never expect read chunks */
 		/* never expect reply chunks (two ways to check) */
-		/* never expect write chunks without having offered RDMA */
 		if (headerp->rm_body.rm_chunks[0] != xdr_zero ||
 		    (headerp->rm_body.rm_chunks[1] == xdr_zero &&
-		     headerp->rm_body.rm_chunks[2] != xdr_zero) ||
-		    (headerp->rm_body.rm_chunks[1] != xdr_zero &&
-		     list_empty(&req->rl_registered)))
+		     headerp->rm_body.rm_chunks[2] != xdr_zero))
 			goto badheader;
 		if (headerp->rm_body.rm_chunks[1] != xdr_zero) {
 			/* count any expected write chunks in read reply */
@@ -1084,8 +1083,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		/* never expect read or write chunks, always reply chunks */
 		if (headerp->rm_body.rm_chunks[0] != xdr_zero ||
 		    headerp->rm_body.rm_chunks[1] != xdr_zero ||
-		    headerp->rm_body.rm_chunks[2] != xdr_one ||
-		    list_empty(&req->rl_registered))
+		    headerp->rm_body.rm_chunks[2] != xdr_one)
 			goto badheader;
 		iptr = (__be32 *)((unsigned char *)headerp +
 							RPCRDMA_HDRLEN_MIN);
@@ -1118,8 +1116,8 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	 * control: waking the next RPC waits until this RPC has
 	 * relinquished all its Send Queue entries.
 	 */
-	if (!list_empty(&req->rl_registered))
-		r_xprt->rx_ia.ri_ops->ro_unmap_sync(r_xprt, req);
+	if (!list_empty(&mws))
+		r_xprt->rx_ia.ri_ops->ro_unmap_sync(r_xprt, &mws);
 
 	spin_lock_bh(&xprt->transport_lock);
 	cwnd = xprt->cwnd;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 2e02733..1c23117 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -467,7 +467,7 @@ struct rpcrdma_memreg_ops {
 				  struct rpcrdma_mr_seg *, int, bool,
 				  struct rpcrdma_mw **);
 	void		(*ro_unmap_sync)(struct rpcrdma_xprt *,
-					 struct rpcrdma_req *);
+					 struct list_head *);
 	void		(*ro_unmap_safe)(struct rpcrdma_xprt *,
 					 struct rpcrdma_req *, bool);
 	void		(*ro_recover_mr)(struct rpcrdma_mw *);


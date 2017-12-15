Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:39829 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754571AbdLOB42 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Dec 2017 20:56:28 -0500
Subject: [PATCH v1 04/16] xprtrdma: Per-mode handling for Remote Invalidation
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 14 Dec 2017 20:56:26 -0500
Message-ID: <20171215015626.13776.10844.stgit@manet.1015granger.net>
In-Reply-To: <20171215015403.13776.46706.stgit@manet.1015granger.net>
References: <20171215015403.13776.46706.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Refactoring change: Remote Invalidation is particular to the memory
registration mode that is use. Use a callout instead of a generic
function to handle Remote Invalidation.

This gets rid of the 8-byte flags field in struct rpcrdma_mw, of
which only a single bit flag has been allocated.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c  |   24 +++++++++++++++++++++---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   24 ++++--------------------
 net/sunrpc/xprtrdma/verbs.c     |    1 -
 net/sunrpc/xprtrdma/xprt_rdma.h |    8 ++------
 4 files changed, 27 insertions(+), 30 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 773e66e..e1f7303 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -450,6 +450,26 @@
 	return ERR_PTR(-ENOTCONN);
 }
 
+/* Handle a remotely invalidated mw on the @mws list
+ */
+static void
+frwr_op_reminv(struct rpcrdma_rep *rep, struct list_head *mws)
+{
+	struct rpcrdma_mw *mw;
+
+	list_for_each_entry(mw, mws, mw_list)
+		if (mw->mw_handle == rep->rr_inv_rkey) {
+			struct rpcrdma_xprt *r_xprt = mw->mw_xprt;
+
+			list_del(&mw->mw_list);
+			mw->frmr.fr_state = FRMR_IS_INVALID;
+			ib_dma_unmap_sg(r_xprt->rx_ia.ri_device,
+					mw->mw_sg, mw->mw_nents, mw->mw_dir);
+			rpcrdma_put_mw(r_xprt, mw);
+			break;	/* only one invalidated MR per RPC */
+		}
+}
+
 /* Invalidate all memory regions that were registered for "req".
  *
  * Sleeps until it is safe for the host CPU to access the
@@ -478,9 +498,6 @@
 	list_for_each_entry(mw, mws, mw_list) {
 		mw->frmr.fr_state = FRMR_IS_INVALID;
 
-		if (mw->mw_flags & RPCRDMA_MW_F_RI)
-			continue;
-
 		f = &mw->frmr;
 		dprintk("RPC:       %s: invalidating frmr %p\n",
 			__func__, f);
@@ -553,6 +570,7 @@
 
 const struct rpcrdma_memreg_ops rpcrdma_frwr_memreg_ops = {
 	.ro_map				= frwr_op_map,
+	.ro_reminv			= frwr_op_reminv,
 	.ro_unmap_sync			= frwr_op_unmap_sync,
 	.ro_recover_mr			= frwr_op_recover_mr,
 	.ro_open			= frwr_op_open,
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index a3f2ab2..d7463bc 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -984,24 +984,6 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	return fixup_copy_count;
 }
 
-/* Caller must guarantee @rep remains stable during this call.
- */
-static void
-rpcrdma_mark_remote_invalidation(struct list_head *mws,
-				 struct rpcrdma_rep *rep)
-{
-	struct rpcrdma_mw *mw;
-
-	if (!(rep->rr_wc_flags & IB_WC_WITH_INVALIDATE))
-		return;
-
-	list_for_each_entry(mw, mws, mw_list)
-		if (mw->mw_handle == rep->rr_inv_rkey) {
-			mw->mw_flags = RPCRDMA_MW_F_RI;
-			break; /* only one invalidated MR per RPC */
-		}
-}
-
 /* By convention, backchannel calls arrive via rdma_msg type
  * messages, and never populate the chunk lists. This makes
  * the RPC/RDMA header small and fixed in size, so it is
@@ -1339,9 +1321,11 @@ void rpcrdma_deferred_completion(struct work_struct *work)
 	struct rpcrdma_rep *rep =
 			container_of(work, struct rpcrdma_rep, rr_work);
 	struct rpcrdma_req *req = rpcr_to_rdmar(rep->rr_rqst);
+	struct rpcrdma_xprt *r_xprt = rep->rr_rxprt;
 
-	rpcrdma_mark_remote_invalidation(&req->rl_registered, rep);
-	rpcrdma_release_rqst(rep->rr_rxprt, req);
+	if (rep->rr_wc_flags & IB_WC_WITH_INVALIDATE)
+		r_xprt->rx_ia.ri_ops->ro_reminv(rep, &req->rl_registered);
+	rpcrdma_release_rqst(r_xprt, req);
 	rpcrdma_complete_rqst(rep);
 }
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 6eecd97..1cf1eb4 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1307,7 +1307,6 @@ struct rpcrdma_mw *
 
 	if (!mw)
 		goto out_nomws;
-	mw->mw_flags = 0;
 	return mw;
 
 out_nomws:
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 3b63e61..e787dda 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -272,7 +272,6 @@ struct rpcrdma_mw {
 	struct scatterlist	*mw_sg;
 	int			mw_nents;
 	enum dma_data_direction	mw_dir;
-	unsigned long		mw_flags;
 	union {
 		struct rpcrdma_fmr	fmr;
 		struct rpcrdma_frmr	frmr;
@@ -284,11 +283,6 @@ struct rpcrdma_mw {
 	struct list_head	mw_all;
 };
 
-/* mw_flags */
-enum {
-	RPCRDMA_MW_F_RI		= 1,
-};
-
 /*
  * struct rpcrdma_req -- structure central to the request/reply sequence.
  *
@@ -485,6 +479,8 @@ struct rpcrdma_memreg_ops {
 			(*ro_map)(struct rpcrdma_xprt *,
 				  struct rpcrdma_mr_seg *, int, bool,
 				  struct rpcrdma_mw **);
+	void		(*ro_reminv)(struct rpcrdma_rep *rep,
+				     struct list_head *mws);
 	void		(*ro_unmap_sync)(struct rpcrdma_xprt *,
 					 struct list_head *);
 	void		(*ro_recover_mr)(struct rpcrdma_mw *);


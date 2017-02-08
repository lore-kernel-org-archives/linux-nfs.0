Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35956 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750972AbdBHWC4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Feb 2017 17:02:56 -0500
Subject: [PATCH v3 08/12] xprtrdma: Refactor management of mw_list field
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 08 Feb 2017 17:00:43 -0500
Message-ID: <20170208220043.7152.23924.stgit@manet.1015granger.net>
In-Reply-To: <20170208214854.7152.83331.stgit@manet.1015granger.net>
References: <20170208214854.7152.83331.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up some duplicate code.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c   |    5 +----
 net/sunrpc/xprtrdma/frwr_ops.c  |   11 ++++-------
 net/sunrpc/xprtrdma/rpc_rdma.c  |    6 +++---
 net/sunrpc/xprtrdma/verbs.c     |   15 +++++----------
 net/sunrpc/xprtrdma/xprt_rdma.h |   16 ++++++++++++++++
 5 files changed, 29 insertions(+), 24 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 1ebb09e..59e6402 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -310,10 +310,7 @@ enum {
 	struct rpcrdma_mw *mw;
 
 	while (!list_empty(&req->rl_registered)) {
-		mw = list_first_entry(&req->rl_registered,
-				      struct rpcrdma_mw, mw_list);
-		list_del_init(&mw->mw_list);
-
+		mw = rpcrdma_pop_mw(&req->rl_registered);
 		if (sync)
 			fmr_op_recover_mr(mw);
 		else
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 47bed53..f81dd93 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -466,8 +466,8 @@
 	struct ib_send_wr *first, **prev, *last, *bad_wr;
 	struct rpcrdma_rep *rep = req->rl_reply;
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
-	struct rpcrdma_mw *mw, *tmp;
 	struct rpcrdma_frmr *f;
+	struct rpcrdma_mw *mw;
 	int count, rc;
 
 	dprintk("RPC:       %s: req %p\n", __func__, req);
@@ -534,10 +534,10 @@
 	 * them to the free MW list.
 	 */
 unmap:
-	list_for_each_entry_safe(mw, tmp, &req->rl_registered, mw_list) {
+	while (!list_empty(&req->rl_registered)) {
+		mw = rpcrdma_pop_mw(&req->rl_registered);
 		dprintk("RPC:       %s: DMA unmapping frmr %p\n",
 			__func__, &mw->frmr);
-		list_del_init(&mw->mw_list);
 		ib_dma_unmap_sg(ia->ri_device,
 				mw->mw_sg, mw->mw_nents, mw->mw_dir);
 		rpcrdma_put_mw(r_xprt, mw);
@@ -571,10 +571,7 @@
 	struct rpcrdma_mw *mw;
 
 	while (!list_empty(&req->rl_registered)) {
-		mw = list_first_entry(&req->rl_registered,
-				      struct rpcrdma_mw, mw_list);
-		list_del_init(&mw->mw_list);
-
+		mw = rpcrdma_pop_mw(&req->rl_registered);
 		if (sync)
 			frwr_op_recover_mr(mw);
 		else
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 72b3ca0..a044be2 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -322,7 +322,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 						 false, &mw);
 		if (n < 0)
 			return ERR_PTR(n);
-		list_add(&mw->mw_list, &req->rl_registered);
+		rpcrdma_push_mw(mw, &req->rl_registered);
 
 		*iptr++ = xdr_one;	/* item present */
 
@@ -390,7 +390,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 						 true, &mw);
 		if (n < 0)
 			return ERR_PTR(n);
-		list_add(&mw->mw_list, &req->rl_registered);
+		rpcrdma_push_mw(mw, &req->rl_registered);
 
 		iptr = xdr_encode_rdma_segment(iptr, mw);
 
@@ -455,7 +455,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 						 true, &mw);
 		if (n < 0)
 			return ERR_PTR(n);
-		list_add(&mw->mw_list, &req->rl_registered);
+		rpcrdma_push_mw(mw, &req->rl_registered);
 
 		iptr = xdr_encode_rdma_segment(iptr, mw);
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index d1ee33f..81cd31a 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -776,9 +776,7 @@ static void rpcrdma_destroy_id(struct rdma_cm_id *id)
 
 	spin_lock(&buf->rb_recovery_lock);
 	while (!list_empty(&buf->rb_stale_mrs)) {
-		mw = list_first_entry(&buf->rb_stale_mrs,
-				      struct rpcrdma_mw, mw_list);
-		list_del_init(&mw->mw_list);
+		mw = rpcrdma_pop_mw(&buf->rb_stale_mrs);
 		spin_unlock(&buf->rb_recovery_lock);
 
 		dprintk("RPC:       %s: recovering MR %p\n", __func__, mw);
@@ -796,7 +794,7 @@ static void rpcrdma_destroy_id(struct rdma_cm_id *id)
 	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
 
 	spin_lock(&buf->rb_recovery_lock);
-	list_add(&mw->mw_list, &buf->rb_stale_mrs);
+	rpcrdma_push_mw(mw, &buf->rb_stale_mrs);
 	spin_unlock(&buf->rb_recovery_lock);
 
 	schedule_delayed_work(&buf->rb_recovery_worker, 0);
@@ -1072,11 +1070,8 @@ struct rpcrdma_mw *
 	struct rpcrdma_mw *mw = NULL;
 
 	spin_lock(&buf->rb_mwlock);
-	if (!list_empty(&buf->rb_mws)) {
-		mw = list_first_entry(&buf->rb_mws,
-				      struct rpcrdma_mw, mw_list);
-		list_del_init(&mw->mw_list);
-	}
+	if (!list_empty(&buf->rb_mws))
+		mw = rpcrdma_pop_mw(&buf->rb_mws);
 	spin_unlock(&buf->rb_mwlock);
 
 	if (!mw)
@@ -1099,7 +1094,7 @@ struct rpcrdma_mw *
 	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
 
 	spin_lock(&buf->rb_mwlock);
-	list_add_tail(&mw->mw_list, &buf->rb_mws);
+	rpcrdma_push_mw(mw, &buf->rb_mws);
 	spin_unlock(&buf->rb_mwlock);
 }
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 852dd0a..171a351 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -354,6 +354,22 @@ struct rpcrdma_req {
 	return rqst->rq_xprtdata;
 }
 
+static inline void
+rpcrdma_push_mw(struct rpcrdma_mw *mw, struct list_head *list)
+{
+	list_add_tail(&mw->mw_list, list);
+}
+
+static inline struct rpcrdma_mw *
+rpcrdma_pop_mw(struct list_head *list)
+{
+	struct rpcrdma_mw *mw;
+
+	mw = list_first_entry(list, struct rpcrdma_mw, mw_list);
+	list_del(&mw->mw_list);
+	return mw;
+}
+
 /*
  * struct rpcrdma_buffer -- holds list/queue of pre-registered memory for
  * inline requests/replies, and client/server credits.


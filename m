Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:51239 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727411AbeIJUDp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Sep 2018 16:03:45 -0400
Subject: [PATCH v1 03/22] xprtrdma: Explicitly resetting MRs is no longer
 necessary
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 10 Sep 2018 11:09:11 -0400
Message-ID: <20180910150911.10564.94387.stgit@manet.1015granger.net>
In-Reply-To: <20180910150040.10564.97487.stgit@manet.1015granger.net>
References: <20180910150040.10564.97487.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When a memory operation fails, the MR's driver state might not match
its hardware state. The only reliable recourse is to dereg the MR.
This is done in ->ro_recover_mr, which then attempts to allocate a
fresh MR to replace the released MR.

Since commit e2ac236c0b651 ("xprtrdma: Allocate MRs on demand"),
xprtrdma dynamically allocates MRs. It can add more MRs whenever
they are needed.

That makes it possible to simply release an MR when a memory
operation fails, instead of "recovering" it. It will automatically
be replaced by the on-demand MR allocator.

This commit is a little larger than I wanted, but it replaces
->ro_recover_mr, rb_recovery_lock, rb_recovery_worker, and the
rb_stale_mrs list with a generic work queue.

Since MRs are no longer orphaned, the mrs_orphaned metric is no
longer used.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h  |    2 -
 net/sunrpc/xprtrdma/fmr_ops.c   |  124 +++++++++++++++++--------------------
 net/sunrpc/xprtrdma/frwr_ops.c  |  130 ++++++++++++++-------------------------
 net/sunrpc/xprtrdma/rpc_rdma.c  |    2 -
 net/sunrpc/xprtrdma/transport.c |    2 -
 net/sunrpc/xprtrdma/verbs.c     |   38 -----------
 net/sunrpc/xprtrdma/xprt_rdma.h |   14 ++--
 7 files changed, 114 insertions(+), 198 deletions(-)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index 53df203..9906f4d 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -655,7 +655,7 @@
 DEFINE_MR_EVENT(xprtrdma_dma_map);
 DEFINE_MR_EVENT(xprtrdma_dma_unmap);
 DEFINE_MR_EVENT(xprtrdma_remoteinv);
-DEFINE_MR_EVENT(xprtrdma_recover_mr);
+DEFINE_MR_EVENT(xprtrdma_mr_recycle);
 
 /**
  ** Reply events
diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index db589a2..f1cf3a3 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -49,46 +49,7 @@ enum {
 	return true;
 }
 
-static int
-fmr_op_init_mr(struct rpcrdma_ia *ia, struct rpcrdma_mr *mr)
-{
-	static struct ib_fmr_attr fmr_attr = {
-		.max_pages	= RPCRDMA_MAX_FMR_SGES,
-		.max_maps	= 1,
-		.page_shift	= PAGE_SHIFT
-	};
-
-	mr->fmr.fm_physaddrs = kcalloc(RPCRDMA_MAX_FMR_SGES,
-				       sizeof(u64), GFP_KERNEL);
-	if (!mr->fmr.fm_physaddrs)
-		goto out_free;
-
-	mr->mr_sg = kcalloc(RPCRDMA_MAX_FMR_SGES,
-			    sizeof(*mr->mr_sg), GFP_KERNEL);
-	if (!mr->mr_sg)
-		goto out_free;
-
-	sg_init_table(mr->mr_sg, RPCRDMA_MAX_FMR_SGES);
-
-	mr->fmr.fm_mr = ib_alloc_fmr(ia->ri_pd, RPCRDMA_FMR_ACCESS_FLAGS,
-				     &fmr_attr);
-	if (IS_ERR(mr->fmr.fm_mr))
-		goto out_fmr_err;
-
-	INIT_LIST_HEAD(&mr->mr_list);
-	return 0;
-
-out_fmr_err:
-	dprintk("RPC:       %s: ib_alloc_fmr returned %ld\n", __func__,
-		PTR_ERR(mr->fmr.fm_mr));
-
-out_free:
-	kfree(mr->mr_sg);
-	kfree(mr->fmr.fm_physaddrs);
-	return -ENOMEM;
-}
-
-static int
+static void
 __fmr_unmap(struct rpcrdma_mr *mr)
 {
 	LIST_HEAD(l);
@@ -97,13 +58,16 @@ enum {
 	list_add(&mr->fmr.fm_mr->list, &l);
 	rc = ib_unmap_fmr(&l);
 	list_del(&mr->fmr.fm_mr->list);
-	return rc;
+	if (rc)
+		pr_err("rpcrdma: final ib_unmap_fmr for %p failed %i\n",
+		       mr, rc);
 }
 
+/* Release an MR.
+ */
 static void
 fmr_op_release_mr(struct rpcrdma_mr *mr)
 {
-	LIST_HEAD(unmap_list);
 	int rc;
 
 	kfree(mr->fmr.fm_physaddrs);
@@ -112,10 +76,7 @@ enum {
 	/* In case this one was left mapped, try to unmap it
 	 * to prevent dealloc_fmr from failing with EBUSY
 	 */
-	rc = __fmr_unmap(mr);
-	if (rc)
-		pr_err("rpcrdma: final ib_unmap_fmr for %p failed %i\n",
-		       mr, rc);
+	__fmr_unmap(mr);
 
 	rc = ib_dealloc_fmr(mr->fmr.fm_mr);
 	if (rc)
@@ -125,28 +86,16 @@ enum {
 	kfree(mr);
 }
 
-/* Reset of a single FMR.
+/* MRs are dynamically allocated, so simply clean up and release the MR.
+ * A replacement MR will subsequently be allocated on demand.
  */
 static void
-fmr_op_recover_mr(struct rpcrdma_mr *mr)
+fmr_mr_recycle_worker(struct work_struct *work)
 {
+	struct rpcrdma_mr *mr = container_of(work, struct rpcrdma_mr, mr_recycle);
 	struct rpcrdma_xprt *r_xprt = mr->mr_xprt;
-	int rc;
 
-	/* ORDER: invalidate first */
-	rc = __fmr_unmap(mr);
-	if (rc)
-		goto out_release;
-
-	/* ORDER: then DMA unmap */
-	rpcrdma_mr_unmap_and_put(mr);
-
-	r_xprt->rx_stats.mrs_recovered++;
-	return;
-
-out_release:
-	pr_err("rpcrdma: FMR reset failed (%d), %p released\n", rc, mr);
-	r_xprt->rx_stats.mrs_orphaned++;
+	trace_xprtrdma_mr_recycle(mr);
 
 	trace_xprtrdma_dma_unmap(mr);
 	ib_dma_unmap_sg(r_xprt->rx_ia.ri_device,
@@ -154,11 +103,51 @@ enum {
 
 	spin_lock(&r_xprt->rx_buf.rb_mrlock);
 	list_del(&mr->mr_all);
+	r_xprt->rx_stats.mrs_recycled++;
 	spin_unlock(&r_xprt->rx_buf.rb_mrlock);
-
 	fmr_op_release_mr(mr);
 }
 
+static int
+fmr_op_init_mr(struct rpcrdma_ia *ia, struct rpcrdma_mr *mr)
+{
+	static struct ib_fmr_attr fmr_attr = {
+		.max_pages	= RPCRDMA_MAX_FMR_SGES,
+		.max_maps	= 1,
+		.page_shift	= PAGE_SHIFT
+	};
+
+	mr->fmr.fm_physaddrs = kcalloc(RPCRDMA_MAX_FMR_SGES,
+				       sizeof(u64), GFP_KERNEL);
+	if (!mr->fmr.fm_physaddrs)
+		goto out_free;
+
+	mr->mr_sg = kcalloc(RPCRDMA_MAX_FMR_SGES,
+			    sizeof(*mr->mr_sg), GFP_KERNEL);
+	if (!mr->mr_sg)
+		goto out_free;
+
+	sg_init_table(mr->mr_sg, RPCRDMA_MAX_FMR_SGES);
+
+	mr->fmr.fm_mr = ib_alloc_fmr(ia->ri_pd, RPCRDMA_FMR_ACCESS_FLAGS,
+				     &fmr_attr);
+	if (IS_ERR(mr->fmr.fm_mr))
+		goto out_fmr_err;
+
+	INIT_LIST_HEAD(&mr->mr_list);
+	INIT_WORK(&mr->mr_recycle, fmr_mr_recycle_worker);
+	return 0;
+
+out_fmr_err:
+	dprintk("RPC:       %s: ib_alloc_fmr returned %ld\n", __func__,
+		PTR_ERR(mr->fmr.fm_mr));
+
+out_free:
+	kfree(mr->mr_sg);
+	kfree(mr->fmr.fm_physaddrs);
+	return -ENOMEM;
+}
+
 /* On success, sets:
  *	ep->rep_attr.cap.max_send_wr
  *	ep->rep_attr.cap.max_recv_wr
@@ -312,7 +301,7 @@ enum {
 	r_xprt->rx_stats.local_inv_needed++;
 	rc = ib_unmap_fmr(&unmap_list);
 	if (rc)
-		goto out_reset;
+		goto out_release;
 
 	/* ORDER: Now DMA unmap all of the req's MRs, and return
 	 * them to the free MW list.
@@ -325,13 +314,13 @@ enum {
 
 	return;
 
-out_reset:
+out_release:
 	pr_err("rpcrdma: ib_unmap_fmr failed (%i)\n", rc);
 
 	while (!list_empty(mrs)) {
 		mr = rpcrdma_mr_pop(mrs);
 		list_del(&mr->fmr.fm_mr->list);
-		fmr_op_recover_mr(mr);
+		rpcrdma_mr_recycle(mr);
 	}
 }
 
@@ -339,7 +328,6 @@ enum {
 	.ro_map				= fmr_op_map,
 	.ro_send			= fmr_op_send,
 	.ro_unmap_sync			= fmr_op_unmap_sync,
-	.ro_recover_mr			= fmr_op_recover_mr,
 	.ro_open			= fmr_op_open,
 	.ro_maxpages			= fmr_op_maxpages,
 	.ro_init_mr			= fmr_op_init_mr,
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 1cc4db5..6594627 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -97,6 +97,44 @@
 	return false;
 }
 
+static void
+frwr_op_release_mr(struct rpcrdma_mr *mr)
+{
+	int rc;
+
+	rc = ib_dereg_mr(mr->frwr.fr_mr);
+	if (rc)
+		pr_err("rpcrdma: final ib_dereg_mr for %p returned %i\n",
+		       mr, rc);
+	kfree(mr->mr_sg);
+	kfree(mr);
+}
+
+/* MRs are dynamically allocated, so simply clean up and release the MR.
+ * A replacement MR will subsequently be allocated on demand.
+ */
+static void
+frwr_mr_recycle_worker(struct work_struct *work)
+{
+	struct rpcrdma_mr *mr = container_of(work, struct rpcrdma_mr, mr_recycle);
+	enum rpcrdma_frwr_state state = mr->frwr.fr_state;
+	struct rpcrdma_xprt *r_xprt = mr->mr_xprt;
+
+	trace_xprtrdma_mr_recycle(mr);
+
+	if (state != FRWR_FLUSHED_LI) {
+		trace_xprtrdma_dma_unmap(mr);
+		ib_dma_unmap_sg(r_xprt->rx_ia.ri_device,
+				mr->mr_sg, mr->mr_nents, mr->mr_dir);
+	}
+
+	spin_lock(&r_xprt->rx_buf.rb_mrlock);
+	list_del(&mr->mr_all);
+	r_xprt->rx_stats.mrs_recycled++;
+	spin_unlock(&r_xprt->rx_buf.rb_mrlock);
+	frwr_op_release_mr(mr);
+}
+
 static int
 frwr_op_init_mr(struct rpcrdma_ia *ia, struct rpcrdma_mr *mr)
 {
@@ -113,6 +151,7 @@
 		goto out_list_err;
 
 	INIT_LIST_HEAD(&mr->mr_list);
+	INIT_WORK(&mr->mr_recycle, frwr_mr_recycle_worker);
 	sg_init_table(mr->mr_sg, depth);
 	init_completion(&frwr->fr_linv_done);
 	return 0;
@@ -131,79 +170,6 @@
 	return rc;
 }
 
-static void
-frwr_op_release_mr(struct rpcrdma_mr *mr)
-{
-	int rc;
-
-	rc = ib_dereg_mr(mr->frwr.fr_mr);
-	if (rc)
-		pr_err("rpcrdma: final ib_dereg_mr for %p returned %i\n",
-		       mr, rc);
-	kfree(mr->mr_sg);
-	kfree(mr);
-}
-
-static int
-__frwr_mr_reset(struct rpcrdma_ia *ia, struct rpcrdma_mr *mr)
-{
-	struct rpcrdma_frwr *frwr = &mr->frwr;
-	int rc;
-
-	rc = ib_dereg_mr(frwr->fr_mr);
-	if (rc) {
-		pr_warn("rpcrdma: ib_dereg_mr status %d, frwr %p orphaned\n",
-			rc, mr);
-		return rc;
-	}
-
-	frwr->fr_mr = ib_alloc_mr(ia->ri_pd, ia->ri_mrtype,
-				  ia->ri_max_frwr_depth);
-	if (IS_ERR(frwr->fr_mr)) {
-		pr_warn("rpcrdma: ib_alloc_mr status %ld, frwr %p orphaned\n",
-			PTR_ERR(frwr->fr_mr), mr);
-		return PTR_ERR(frwr->fr_mr);
-	}
-
-	dprintk("RPC:       %s: recovered FRWR %p\n", __func__, frwr);
-	frwr->fr_state = FRWR_IS_INVALID;
-	return 0;
-}
-
-/* Reset of a single FRWR. Generate a fresh rkey by replacing the MR.
- */
-static void
-frwr_op_recover_mr(struct rpcrdma_mr *mr)
-{
-	enum rpcrdma_frwr_state state = mr->frwr.fr_state;
-	struct rpcrdma_xprt *r_xprt = mr->mr_xprt;
-	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
-	int rc;
-
-	rc = __frwr_mr_reset(ia, mr);
-	if (state != FRWR_FLUSHED_LI) {
-		trace_xprtrdma_dma_unmap(mr);
-		ib_dma_unmap_sg(ia->ri_device,
-				mr->mr_sg, mr->mr_nents, mr->mr_dir);
-	}
-	if (rc)
-		goto out_release;
-
-	rpcrdma_mr_put(mr);
-	r_xprt->rx_stats.mrs_recovered++;
-	return;
-
-out_release:
-	pr_err("rpcrdma: FRWR reset failed %d, %p released\n", rc, mr);
-	r_xprt->rx_stats.mrs_orphaned++;
-
-	spin_lock(&r_xprt->rx_buf.rb_mrlock);
-	list_del(&mr->mr_all);
-	spin_unlock(&r_xprt->rx_buf.rb_mrlock);
-
-	frwr_op_release_mr(mr);
-}
-
 /* On success, sets:
  *	ep->rep_attr.cap.max_send_wr
  *	ep->rep_attr.cap.max_recv_wr
@@ -385,7 +351,7 @@
 	mr = NULL;
 	do {
 		if (mr)
-			rpcrdma_mr_defer_recovery(mr);
+			rpcrdma_mr_recycle(mr);
 		mr = rpcrdma_mr_get(r_xprt);
 		if (!mr)
 			return ERR_PTR(-EAGAIN);
@@ -452,7 +418,7 @@
 out_mapmr_err:
 	pr_err("rpcrdma: failed to map mr %p (%d/%d)\n",
 	       frwr->fr_mr, n, mr->mr_nents);
-	rpcrdma_mr_defer_recovery(mr);
+	rpcrdma_mr_recycle(mr);
 	return ERR_PTR(-EIO);
 }
 
@@ -571,7 +537,7 @@
 	if (bad_wr != first)
 		wait_for_completion(&frwr->fr_linv_done);
 	if (rc)
-		goto reset_mrs;
+		goto out_release;
 
 	/* ORDER: Now DMA unmap all of the MRs, and return
 	 * them to the free MR list.
@@ -583,22 +549,21 @@
 	}
 	return;
 
-reset_mrs:
+out_release:
 	pr_err("rpcrdma: FRWR invalidate ib_post_send returned %i\n", rc);
 
-	/* Find and reset the MRs in the LOCAL_INV WRs that did not
+	/* Unmap and release the MRs in the LOCAL_INV WRs that did not
 	 * get posted.
 	 */
 	while (bad_wr) {
 		frwr = container_of(bad_wr, struct rpcrdma_frwr,
 				    fr_invwr);
 		mr = container_of(frwr, struct rpcrdma_mr, frwr);
-
-		__frwr_mr_reset(ia, mr);
-
 		bad_wr = bad_wr->next;
+
+		list_del(&mr->mr_list);
+		frwr_op_release_mr(mr);
 	}
-	goto unmap;
 }
 
 const struct rpcrdma_memreg_ops rpcrdma_frwr_memreg_ops = {
@@ -606,7 +571,6 @@
 	.ro_send			= frwr_op_send,
 	.ro_reminv			= frwr_op_reminv,
 	.ro_unmap_sync			= frwr_op_unmap_sync,
-	.ro_recover_mr			= frwr_op_recover_mr,
 	.ro_open			= frwr_op_open,
 	.ro_maxpages			= frwr_op_maxpages,
 	.ro_init_mr			= frwr_op_init_mr,
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 33da912..ec4b1f9 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -803,7 +803,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		struct rpcrdma_mr *mr;
 
 		mr = rpcrdma_mr_pop(&req->rl_registered);
-		rpcrdma_mr_defer_recovery(mr);
+		rpcrdma_mr_recycle(mr);
 	}
 
 	/* This implementation supports the following combinations
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 98cbc7b..3ae73e6 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -792,7 +792,7 @@ void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 		   r_xprt->rx_stats.bad_reply_count,
 		   r_xprt->rx_stats.nomsg_call_count);
 	seq_printf(seq, "%lu %lu %lu %lu %lu %lu\n",
-		   r_xprt->rx_stats.mrs_recovered,
+		   r_xprt->rx_stats.mrs_recycled,
 		   r_xprt->rx_stats.mrs_orphaned,
 		   r_xprt->rx_stats.mrs_allocated,
 		   r_xprt->rx_stats.local_inv_needed,
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 5625a50..88fe75e 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -978,39 +978,6 @@ struct rpcrdma_sendctx *rpcrdma_sendctx_get_locked(struct rpcrdma_buffer *buf)
 }
 
 static void
-rpcrdma_mr_recovery_worker(struct work_struct *work)
-{
-	struct rpcrdma_buffer *buf = container_of(work, struct rpcrdma_buffer,
-						  rb_recovery_worker.work);
-	struct rpcrdma_mr *mr;
-
-	spin_lock(&buf->rb_recovery_lock);
-	while (!list_empty(&buf->rb_stale_mrs)) {
-		mr = rpcrdma_mr_pop(&buf->rb_stale_mrs);
-		spin_unlock(&buf->rb_recovery_lock);
-
-		trace_xprtrdma_recover_mr(mr);
-		mr->mr_xprt->rx_ia.ri_ops->ro_recover_mr(mr);
-
-		spin_lock(&buf->rb_recovery_lock);
-	}
-	spin_unlock(&buf->rb_recovery_lock);
-}
-
-void
-rpcrdma_mr_defer_recovery(struct rpcrdma_mr *mr)
-{
-	struct rpcrdma_xprt *r_xprt = mr->mr_xprt;
-	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
-
-	spin_lock(&buf->rb_recovery_lock);
-	rpcrdma_mr_push(mr, &buf->rb_stale_mrs);
-	spin_unlock(&buf->rb_recovery_lock);
-
-	schedule_delayed_work(&buf->rb_recovery_worker, 0);
-}
-
-static void
 rpcrdma_mrs_create(struct rpcrdma_xprt *r_xprt)
 {
 	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
@@ -1142,14 +1109,10 @@ struct rpcrdma_req *
 	buf->rb_bc_srv_max_requests = 0;
 	spin_lock_init(&buf->rb_mrlock);
 	spin_lock_init(&buf->rb_lock);
-	spin_lock_init(&buf->rb_recovery_lock);
 	INIT_LIST_HEAD(&buf->rb_mrs);
 	INIT_LIST_HEAD(&buf->rb_all);
-	INIT_LIST_HEAD(&buf->rb_stale_mrs);
 	INIT_DELAYED_WORK(&buf->rb_refresh_worker,
 			  rpcrdma_mr_refresh_worker);
-	INIT_DELAYED_WORK(&buf->rb_recovery_worker,
-			  rpcrdma_mr_recovery_worker);
 
 	rpcrdma_mrs_create(r_xprt);
 
@@ -1233,7 +1196,6 @@ struct rpcrdma_req *
 void
 rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 {
-	cancel_delayed_work_sync(&buf->rb_recovery_worker);
 	cancel_delayed_work_sync(&buf->rb_refresh_worker);
 
 	rpcrdma_sendctxs_destroy(buf);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 2ca14f7..eae2166 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -280,6 +280,7 @@ struct rpcrdma_mr {
 	u32			mr_handle;
 	u32			mr_length;
 	u64			mr_offset;
+	struct work_struct	mr_recycle;
 	struct list_head	mr_all;
 };
 
@@ -411,9 +412,6 @@ struct rpcrdma_buffer {
 
 	u32			rb_bc_max_requests;
 
-	spinlock_t		rb_recovery_lock; /* protect rb_stale_mrs */
-	struct list_head	rb_stale_mrs;
-	struct delayed_work	rb_recovery_worker;
 	struct delayed_work	rb_refresh_worker;
 };
 #define rdmab_to_ia(b) (&container_of((b), struct rpcrdma_xprt, rx_buf)->rx_ia)
@@ -452,7 +450,7 @@ struct rpcrdma_stats {
 	unsigned long		hardway_register_count;
 	unsigned long		failed_marshal_count;
 	unsigned long		bad_reply_count;
-	unsigned long		mrs_recovered;
+	unsigned long		mrs_recycled;
 	unsigned long		mrs_orphaned;
 	unsigned long		mrs_allocated;
 	unsigned long		empty_sendctx_q;
@@ -481,7 +479,6 @@ struct rpcrdma_memreg_ops {
 				     struct list_head *mrs);
 	void		(*ro_unmap_sync)(struct rpcrdma_xprt *,
 					 struct list_head *);
-	void		(*ro_recover_mr)(struct rpcrdma_mr *mr);
 	int		(*ro_open)(struct rpcrdma_ia *,
 				   struct rpcrdma_ep *,
 				   struct rpcrdma_create_data_internal *);
@@ -578,7 +575,12 @@ int rpcrdma_ep_post(struct rpcrdma_ia *, struct rpcrdma_ep *,
 struct rpcrdma_mr *rpcrdma_mr_get(struct rpcrdma_xprt *r_xprt);
 void rpcrdma_mr_put(struct rpcrdma_mr *mr);
 void rpcrdma_mr_unmap_and_put(struct rpcrdma_mr *mr);
-void rpcrdma_mr_defer_recovery(struct rpcrdma_mr *mr);
+
+static inline void
+rpcrdma_mr_recycle(struct rpcrdma_mr *mr)
+{
+	schedule_work(&mr->mr_recycle);
+}
 
 struct rpcrdma_req *rpcrdma_buffer_get(struct rpcrdma_buffer *);
 void rpcrdma_buffer_put(struct rpcrdma_req *);

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36383 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932627AbcFODRM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2016 23:17:12 -0400
Subject: [PATCH v2 14/24] xprtrdma: Allocate MRs on demand
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 14 Jun 2016 23:17:10 -0400
Message-ID: <20160615031710.14794.45728.stgit@manet.1015granger.net>
In-Reply-To: <20160615030626.14794.43805.stgit@manet.1015granger.net>
References: <20160615030626.14794.43805.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Frequent MR list exhaustion can impact I/O throughput, so enough MRs
are always created during transport set-up to prevent running out.
This means more MRs are created than most workloads need.

Commit 94f58c58c0b4 ("xprtrdma: Allow Read list and Reply chunk
simultaneously") introduced support for sending two chunk lists per
RPC, which consumes more MRs per RPC.

Instead of trying to provision more MRs, introduce a mechanism for
allocating MRs on demand. A few MRs are allocated during transport
set-up to kick things off.

This significantly reduces the average number of MRs per transport
while allowing the MR count to grow for workloads or devices that
need more MRs.

FRWR with mlx4 allocated almost 400 MRs per transport before this
patch. Now it starts with 16.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c   |   64 +++-------------------------
 net/sunrpc/xprtrdma/frwr_ops.c  |   64 +++-------------------------
 net/sunrpc/xprtrdma/transport.c |    5 +-
 net/sunrpc/xprtrdma/verbs.c     |   90 ++++++++++++++++++++++++++++++++++++---
 net/sunrpc/xprtrdma/xprt_rdma.h |    7 ++-
 5 files changed, 106 insertions(+), 124 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index e86fe83..840479f 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -35,7 +35,7 @@ enum {
 };
 
 static int
-__fmr_init(struct rpcrdma_mw *mw, struct ib_pd *pd)
+fmr_op_init_mr(struct rpcrdma_ia *ia, struct rpcrdma_mw *mw)
 {
 	static struct ib_fmr_attr fmr_attr = {
 		.max_pages	= RPCRDMA_MAX_FMR_SGES,
@@ -55,7 +55,7 @@ __fmr_init(struct rpcrdma_mw *mw, struct ib_pd *pd)
 
 	sg_init_table(mw->mw_sg, RPCRDMA_MAX_FMR_SGES);
 
-	mw->fmr.fm_mr = ib_alloc_fmr(pd, RPCRDMA_FMR_ACCESS_FLAGS,
+	mw->fmr.fm_mr = ib_alloc_fmr(ia->ri_pd, RPCRDMA_FMR_ACCESS_FLAGS,
 				     &fmr_attr);
 	if (IS_ERR(mw->fmr.fm_mr))
 		goto out_fmr_err;
@@ -86,7 +86,7 @@ __fmr_unmap(struct rpcrdma_mw *mw)
 }
 
 static void
-__fmr_release(struct rpcrdma_mw *r)
+fmr_op_release_mr(struct rpcrdma_mw *r)
 {
 	LIST_HEAD(unmap_list);
 	int rc;
@@ -106,13 +106,11 @@ __fmr_release(struct rpcrdma_mw *r)
 	if (rc)
 		pr_err("rpcrdma: final ib_dealloc_fmr for %p returned %i\n",
 		       r, rc);
+
+	kfree(r);
 }
 
 /* Reset of a single FMR.
- *
- * There's no recovery if this fails. The FMR is abandoned, but
- * remains in rb_all. It will be cleaned up when the transport is
- * destroyed.
  */
 static void
 fmr_op_recover_mr(struct rpcrdma_mw *mw)
@@ -156,41 +154,6 @@ fmr_op_maxpages(struct rpcrdma_xprt *r_xprt)
 		     RPCRDMA_MAX_HDR_SEGS * RPCRDMA_MAX_FMR_SGES);
 }
 
-static int
-fmr_op_init(struct rpcrdma_xprt *r_xprt)
-{
-	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
-	struct ib_pd *pd = r_xprt->rx_ia.ri_pd;
-	struct rpcrdma_mw *r;
-	int i, rc;
-
-	spin_lock_init(&buf->rb_mwlock);
-	INIT_LIST_HEAD(&buf->rb_mws);
-	INIT_LIST_HEAD(&buf->rb_all);
-
-	i = max_t(int, RPCRDMA_MAX_DATA_SEGS / RPCRDMA_MAX_FMR_SGES, 1);
-	i += 2;				/* head + tail */
-	i *= buf->rb_max_requests;	/* one set for each RPC slot */
-	dprintk("RPC:       %s: initalizing %d FMRs\n", __func__, i);
-
-	while (i--) {
-		r = kzalloc(sizeof(*r), GFP_KERNEL);
-		if (!r)
-			return -ENOMEM;
-
-		rc = __fmr_init(r, pd);
-		if (rc) {
-			kfree(r);
-			return rc;
-		}
-
-		r->mw_xprt = r_xprt;
-		list_add(&r->mw_list, &buf->rb_mws);
-		list_add(&r->mw_all, &buf->rb_all);
-	}
-	return 0;
-}
-
 /* Use the ib_map_phys_fmr() verb to register a memory region
  * for remote access via RDMA READ or RDMA WRITE.
  */
@@ -364,19 +327,6 @@ fmr_op_unmap_safe(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 	}
 }
 
-static void
-fmr_op_destroy(struct rpcrdma_buffer *buf)
-{
-	struct rpcrdma_mw *r;
-
-	while (!list_empty(&buf->rb_all)) {
-		r = list_entry(buf->rb_all.next, struct rpcrdma_mw, mw_all);
-		list_del(&r->mw_all);
-		__fmr_release(r);
-		kfree(r);
-	}
-}
-
 const struct rpcrdma_memreg_ops rpcrdma_fmr_memreg_ops = {
 	.ro_map				= fmr_op_map,
 	.ro_unmap_sync			= fmr_op_unmap_sync,
@@ -384,7 +334,7 @@ const struct rpcrdma_memreg_ops rpcrdma_fmr_memreg_ops = {
 	.ro_recover_mr			= fmr_op_recover_mr,
 	.ro_open			= fmr_op_open,
 	.ro_maxpages			= fmr_op_maxpages,
-	.ro_init			= fmr_op_init,
-	.ro_destroy			= fmr_op_destroy,
+	.ro_init_mr			= fmr_op_init_mr,
+	.ro_release_mr			= fmr_op_release_mr,
 	.ro_displayname			= "fmr",
 };
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index d7e63bd..f603c3a 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -74,12 +74,13 @@
 #endif
 
 static int
-__frwr_init(struct rpcrdma_mw *r, struct ib_pd *pd, unsigned int depth)
+frwr_op_init_mr(struct rpcrdma_ia *ia, struct rpcrdma_mw *r)
 {
+	unsigned int depth = ia->ri_max_frmr_depth;
 	struct rpcrdma_frmr *f = &r->frmr;
 	int rc;
 
-	f->fr_mr = ib_alloc_mr(pd, IB_MR_TYPE_MEM_REG, depth);
+	f->fr_mr = ib_alloc_mr(ia->ri_pd, IB_MR_TYPE_MEM_REG, depth);
 	if (IS_ERR(f->fr_mr))
 		goto out_mr_err;
 
@@ -106,7 +107,7 @@ out_list_err:
 }
 
 static void
-__frwr_release(struct rpcrdma_mw *r)
+frwr_op_release_mr(struct rpcrdma_mw *r)
 {
 	int rc;
 
@@ -115,6 +116,7 @@ __frwr_release(struct rpcrdma_mw *r)
 		pr_err("rpcrdma: final ib_dereg_mr for %p returned %i\n",
 		       r, rc);
 	kfree(r->mw_sg);
+	kfree(r);
 }
 
 static int
@@ -302,45 +304,6 @@ frwr_wc_localinv_wake(struct ib_cq *cq, struct ib_wc *wc)
 	complete_all(&frmr->fr_linv_done);
 }
 
-static int
-frwr_op_init(struct rpcrdma_xprt *r_xprt)
-{
-	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
-	unsigned int depth = r_xprt->rx_ia.ri_max_frmr_depth;
-	struct ib_pd *pd = r_xprt->rx_ia.ri_pd;
-	int i;
-
-	spin_lock_init(&buf->rb_mwlock);
-	INIT_LIST_HEAD(&buf->rb_mws);
-	INIT_LIST_HEAD(&buf->rb_all);
-
-	i = max_t(int, RPCRDMA_MAX_DATA_SEGS / depth, 1);
-	i += 2;				/* head + tail */
-	i *= buf->rb_max_requests;	/* one set for each RPC slot */
-	dprintk("RPC:       %s: initalizing %d FRMRs\n", __func__, i);
-
-	while (i--) {
-		struct rpcrdma_mw *r;
-		int rc;
-
-		r = kzalloc(sizeof(*r), GFP_KERNEL);
-		if (!r)
-			return -ENOMEM;
-
-		rc = __frwr_init(r, pd, depth);
-		if (rc) {
-			kfree(r);
-			return rc;
-		}
-
-		r->mw_xprt = r_xprt;
-		list_add(&r->mw_list, &buf->rb_mws);
-		list_add(&r->mw_all, &buf->rb_all);
-	}
-
-	return 0;
-}
-
 /* Post a REG_MR Work Request to register a memory region
  * for remote access via RDMA READ or RDMA WRITE.
  */
@@ -601,19 +564,6 @@ frwr_op_unmap_safe(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 	}
 }
 
-static void
-frwr_op_destroy(struct rpcrdma_buffer *buf)
-{
-	struct rpcrdma_mw *r;
-
-	while (!list_empty(&buf->rb_all)) {
-		r = list_entry(buf->rb_all.next, struct rpcrdma_mw, mw_all);
-		list_del(&r->mw_all);
-		__frwr_release(r);
-		kfree(r);
-	}
-}
-
 const struct rpcrdma_memreg_ops rpcrdma_frwr_memreg_ops = {
 	.ro_map				= frwr_op_map,
 	.ro_unmap_sync			= frwr_op_unmap_sync,
@@ -621,7 +571,7 @@ const struct rpcrdma_memreg_ops rpcrdma_frwr_memreg_ops = {
 	.ro_recover_mr			= frwr_op_recover_mr,
 	.ro_open			= frwr_op_open,
 	.ro_maxpages			= frwr_op_maxpages,
-	.ro_init			= frwr_op_init,
-	.ro_destroy			= frwr_op_destroy,
+	.ro_init_mr			= frwr_op_init_mr,
+	.ro_release_mr			= frwr_op_release_mr,
 	.ro_displayname			= "frwr",
 };
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index be4dd2c..b1dd42a 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -682,9 +682,10 @@ void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 		   r_xprt->rx_stats.failed_marshal_count,
 		   r_xprt->rx_stats.bad_reply_count,
 		   r_xprt->rx_stats.nomsg_call_count);
-	seq_printf(seq, "%lu %lu\n",
+	seq_printf(seq, "%lu %lu %lu\n",
 		   r_xprt->rx_stats.mrs_recovered,
-		   r_xprt->rx_stats.mrs_orphaned);
+		   r_xprt->rx_stats.mrs_orphaned,
+		   r_xprt->rx_stats.mrs_allocated);
 }
 
 static int
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 35f2176..4a7a712 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -797,6 +797,55 @@ rpcrdma_defer_mr_recovery(struct rpcrdma_mw *mw)
 	schedule_delayed_work(&buf->rb_recovery_worker, 0);
 }
 
+static void
+rpcrdma_create_mrs(struct rpcrdma_xprt *r_xprt)
+{
+	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
+	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
+	unsigned int count;
+	LIST_HEAD(free);
+	LIST_HEAD(all);
+
+	for (count = 0; count < 16; count++) {
+		struct rpcrdma_mw *mw;
+		int rc;
+
+		mw = kzalloc(sizeof(*mw), GFP_KERNEL);
+		if (!mw)
+			break;
+
+		rc = ia->ri_ops->ro_init_mr(ia, mw);
+		if (rc) {
+			kfree(mw);
+			break;
+		}
+
+		mw->mw_xprt = r_xprt;
+
+		list_add(&mw->mw_list, &free);
+		list_add(&mw->mw_all, &all);
+	}
+
+	spin_lock(&buf->rb_mwlock);
+	list_splice(&free, &buf->rb_mws);
+	list_splice(&all, &buf->rb_all);
+	r_xprt->rx_stats.mrs_allocated += count;
+	spin_unlock(&buf->rb_mwlock);
+
+	dprintk("RPC:       %s: created %u MRs\n", __func__, count);
+}
+
+static void
+rpcrdma_mr_refresh_worker(struct work_struct *work)
+{
+	struct rpcrdma_buffer *buf = container_of(work, struct rpcrdma_buffer,
+						  rb_refresh_worker.work);
+	struct rpcrdma_xprt *r_xprt = container_of(buf, struct rpcrdma_xprt,
+						   rx_buf);
+
+	rpcrdma_create_mrs(r_xprt);
+}
+
 struct rpcrdma_req *
 rpcrdma_create_req(struct rpcrdma_xprt *r_xprt)
 {
@@ -852,21 +901,23 @@ int
 rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 {
 	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
-	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	int i, rc;
 
 	buf->rb_max_requests = r_xprt->rx_data.max_requests;
 	buf->rb_bc_srv_max_requests = 0;
 	atomic_set(&buf->rb_credits, 1);
+	spin_lock_init(&buf->rb_mwlock);
 	spin_lock_init(&buf->rb_lock);
 	spin_lock_init(&buf->rb_recovery_lock);
+	INIT_LIST_HEAD(&buf->rb_mws);
+	INIT_LIST_HEAD(&buf->rb_all);
 	INIT_LIST_HEAD(&buf->rb_stale_mrs);
+	INIT_DELAYED_WORK(&buf->rb_refresh_worker,
+			  rpcrdma_mr_refresh_worker);
 	INIT_DELAYED_WORK(&buf->rb_recovery_worker,
 			  rpcrdma_mr_recovery_worker);
 
-	rc = ia->ri_ops->ro_init(r_xprt);
-	if (rc)
-		goto out;
+	rpcrdma_create_mrs(r_xprt);
 
 	INIT_LIST_HEAD(&buf->rb_send_bufs);
 	INIT_LIST_HEAD(&buf->rb_allreqs);
@@ -946,6 +997,10 @@ void
 rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 {
 	struct rpcrdma_ia *ia = rdmab_to_ia(buf);
+	struct rpcrdma_xprt *r_xprt = container_of(buf, struct rpcrdma_xprt,
+						   rx_buf);
+	struct rpcrdma_mw *mw;
+	unsigned int count;
 
 	cancel_delayed_work_sync(&buf->rb_recovery_worker);
 
@@ -970,7 +1025,21 @@ rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 	}
 	spin_unlock(&buf->rb_reqslock);
 
-	ia->ri_ops->ro_destroy(buf);
+	count = 0;
+	spin_lock(&buf->rb_mwlock);
+	while (!list_empty(&buf->rb_all)) {
+		mw = list_entry(buf->rb_all.next, struct rpcrdma_mw, mw_all);
+		list_del(&mw->mw_all);
+
+		spin_unlock(&buf->rb_mwlock);
+		ia->ri_ops->ro_release_mr(mw);
+		count++;
+		spin_lock(&buf->rb_mwlock);
+	}
+	spin_unlock(&buf->rb_mwlock);
+	r_xprt->rx_stats.mrs_allocated = 0;
+
+	dprintk("RPC:       %s: released %u MRs\n", __func__, count);
 }
 
 struct rpcrdma_mw *
@@ -988,8 +1057,17 @@ rpcrdma_get_mw(struct rpcrdma_xprt *r_xprt)
 	spin_unlock(&buf->rb_mwlock);
 
 	if (!mw)
-		pr_err("RPC:       %s: no MWs available\n", __func__);
+		goto out_nomws;
 	return mw;
+
+out_nomws:
+	dprintk("RPC:       %s: no MWs available\n", __func__);
+	schedule_delayed_work(&buf->rb_refresh_worker, 0);
+
+	/* Allow the reply handler and refresh worker to run */
+	cond_resched();
+
+	return NULL;
 }
 
 void
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index f1b6f2f..0bde4c0 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -339,6 +339,7 @@ struct rpcrdma_buffer {
 	spinlock_t		rb_recovery_lock; /* protect rb_stale_mrs */
 	struct list_head	rb_stale_mrs;
 	struct delayed_work	rb_recovery_worker;
+	struct delayed_work	rb_refresh_worker;
 };
 #define rdmab_to_ia(b) (&container_of((b), struct rpcrdma_xprt, rx_buf)->rx_ia)
 
@@ -387,6 +388,7 @@ struct rpcrdma_stats {
 	unsigned long		bcall_count;
 	unsigned long		mrs_recovered;
 	unsigned long		mrs_orphaned;
+	unsigned long		mrs_allocated;
 };
 
 /*
@@ -405,8 +407,9 @@ struct rpcrdma_memreg_ops {
 				   struct rpcrdma_ep *,
 				   struct rpcrdma_create_data_internal *);
 	size_t		(*ro_maxpages)(struct rpcrdma_xprt *);
-	int		(*ro_init)(struct rpcrdma_xprt *);
-	void		(*ro_destroy)(struct rpcrdma_buffer *);
+	int		(*ro_init_mr)(struct rpcrdma_ia *,
+				      struct rpcrdma_mw *);
+	void		(*ro_release_mr)(struct rpcrdma_mw *);
 	const char	*ro_displayname;
 };
 


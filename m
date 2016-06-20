Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36740 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755140AbcFTQJH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jun 2016 12:09:07 -0400
Subject: [PATCH v3 03/25] xprtrdma: Move init and release helpers
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 20 Jun 2016 12:08:59 -0400
Message-ID: <20160620160859.10809.91014.stgit@manet.1015granger.net>
In-Reply-To: <20160620155751.10809.22262.stgit@manet.1015granger.net>
References: <20160620155751.10809.22262.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Moving these helpers in a separate patch makes later
patches more readable.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c  |  120 +++++++++++++++++++++++++---------------
 net/sunrpc/xprtrdma/frwr_ops.c |   90 +++++++++++++++---------------
 2 files changed, 120 insertions(+), 90 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 958c792..b3f8699 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -35,6 +35,12 @@
 /* Maximum scatter/gather per FMR */
 #define RPCRDMA_MAX_FMR_SGES	(64)
 
+/* Access mode of externally registered pages */
+enum {
+	RPCRDMA_FMR_ACCESS_FLAGS	= IB_ACCESS_REMOTE_WRITE |
+					  IB_ACCESS_REMOTE_READ,
+};
+
 static struct workqueue_struct *fmr_recovery_wq;
 
 #define FMR_RECOVERY_WQ_FLAGS		(WQ_UNBOUND)
@@ -60,6 +66,45 @@ fmr_destroy_recovery_wq(void)
 }
 
 static int
+__fmr_init(struct rpcrdma_mw *mw, struct ib_pd *pd)
+{
+	static struct ib_fmr_attr fmr_attr = {
+		.max_pages	= RPCRDMA_MAX_FMR_SGES,
+		.max_maps	= 1,
+		.page_shift	= PAGE_SHIFT
+	};
+
+	mw->fmr.physaddrs = kcalloc(RPCRDMA_MAX_FMR_SGES,
+				    sizeof(u64), GFP_KERNEL);
+	if (!mw->fmr.physaddrs)
+		goto out_free;
+
+	mw->mw_sg = kcalloc(RPCRDMA_MAX_FMR_SGES,
+			    sizeof(*mw->mw_sg), GFP_KERNEL);
+	if (!mw->mw_sg)
+		goto out_free;
+
+	sg_init_table(mw->mw_sg, RPCRDMA_MAX_FMR_SGES);
+
+	mw->fmr.fmr = ib_alloc_fmr(pd, RPCRDMA_FMR_ACCESS_FLAGS,
+				   &fmr_attr);
+	if (IS_ERR(mw->fmr.fmr))
+		goto out_fmr_err;
+
+	INIT_LIST_HEAD(&mw->fmr.fmr->list);
+	return 0;
+
+out_fmr_err:
+	dprintk("RPC:       %s: ib_alloc_fmr returned %ld\n", __func__,
+		PTR_ERR(mw->fmr.fmr));
+
+out_free:
+	kfree(mw->mw_sg);
+	kfree(mw->fmr.physaddrs);
+	return -ENOMEM;
+}
+
+static int
 __fmr_unmap(struct rpcrdma_mw *mw)
 {
 	LIST_HEAD(l);
@@ -71,6 +116,30 @@ __fmr_unmap(struct rpcrdma_mw *mw)
 	return rc;
 }
 
+static void
+__fmr_dma_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
+{
+	struct ib_device *device = r_xprt->rx_ia.ri_device;
+	int nsegs = seg->mr_nsegs;
+
+	while (nsegs--)
+		rpcrdma_unmap_one(device, seg++);
+}
+
+static void
+__fmr_release(struct rpcrdma_mw *r)
+{
+	int rc;
+
+	kfree(r->fmr.physaddrs);
+	kfree(r->mw_sg);
+
+	rc = ib_dealloc_fmr(r->fmr.fmr);
+	if (rc)
+		pr_err("rpcrdma: final ib_dealloc_fmr for %p returned %i\n",
+		       r, rc);
+}
+
 /* Deferred reset of a single FMR. Generate a fresh rkey by
  * replacing the MR. There's no recovery if this fails.
  */
@@ -119,12 +188,6 @@ static int
 fmr_op_init(struct rpcrdma_xprt *r_xprt)
 {
 	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
-	int mr_access_flags = IB_ACCESS_REMOTE_WRITE | IB_ACCESS_REMOTE_READ;
-	struct ib_fmr_attr fmr_attr = {
-		.max_pages	= RPCRDMA_MAX_FMR_SGES,
-		.max_maps	= 1,
-		.page_shift	= PAGE_SHIFT
-	};
 	struct ib_pd *pd = r_xprt->rx_ia.ri_pd;
 	struct rpcrdma_mw *r;
 	int i, rc;
@@ -138,36 +201,22 @@ fmr_op_init(struct rpcrdma_xprt *r_xprt)
 	i *= buf->rb_max_requests;	/* one set for each RPC slot */
 	dprintk("RPC:       %s: initalizing %d FMRs\n", __func__, i);
 
-	rc = -ENOMEM;
 	while (i--) {
 		r = kzalloc(sizeof(*r), GFP_KERNEL);
 		if (!r)
-			goto out;
-
-		r->fmr.physaddrs = kmalloc(RPCRDMA_MAX_FMR_SGES *
-					   sizeof(u64), GFP_KERNEL);
-		if (!r->fmr.physaddrs)
-			goto out_free;
+			return -ENOMEM;
 
-		r->fmr.fmr = ib_alloc_fmr(pd, mr_access_flags, &fmr_attr);
-		if (IS_ERR(r->fmr.fmr))
-			goto out_fmr_err;
-		INIT_LIST_HEAD(&r->fmr.fmr->list);
+		rc = __fmr_init(r, pd);
+		if (rc) {
+			kfree(r);
+			return rc;
+		}
 
 		r->mw_xprt = r_xprt;
 		list_add(&r->mw_list, &buf->rb_mws);
 		list_add(&r->mw_all, &buf->rb_all);
 	}
 	return 0;
-
-out_fmr_err:
-	rc = PTR_ERR(r->fmr.fmr);
-	dprintk("RPC:       %s: ib_alloc_fmr status %i\n", __func__, rc);
-	kfree(r->fmr.physaddrs);
-out_free:
-	kfree(r);
-out:
-	return rc;
 }
 
 /* Use the ib_map_phys_fmr() verb to register a memory region
@@ -236,16 +285,6 @@ out_maperr:
 	return rc;
 }
 
-static void
-__fmr_dma_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
-{
-	struct ib_device *device = r_xprt->rx_ia.ri_device;
-	int nsegs = seg->mr_nsegs;
-
-	while (nsegs--)
-		rpcrdma_unmap_one(device, seg++);
-}
-
 /* Invalidate all memory regions that were registered for "req".
  *
  * Sleeps until it is safe for the host CPU to access the
@@ -338,18 +377,11 @@ static void
 fmr_op_destroy(struct rpcrdma_buffer *buf)
 {
 	struct rpcrdma_mw *r;
-	int rc;
 
 	while (!list_empty(&buf->rb_all)) {
 		r = list_entry(buf->rb_all.next, struct rpcrdma_mw, mw_all);
 		list_del(&r->mw_all);
-		kfree(r->fmr.physaddrs);
-
-		rc = ib_dealloc_fmr(r->fmr.fmr);
-		if (rc)
-			dprintk("RPC:       %s: ib_dealloc_fmr failed %i\n",
-				__func__, rc);
-
+		__fmr_release(r);
 		kfree(r);
 	}
 }
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index f02ab80..9cd60bf0 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -99,6 +99,50 @@ frwr_destroy_recovery_wq(void)
 }
 
 static int
+__frwr_init(struct rpcrdma_mw *r, struct ib_pd *pd, unsigned int depth)
+{
+	struct rpcrdma_frmr *f = &r->frmr;
+	int rc;
+
+	f->fr_mr = ib_alloc_mr(pd, IB_MR_TYPE_MEM_REG, depth);
+	if (IS_ERR(f->fr_mr))
+		goto out_mr_err;
+
+	r->mw_sg = kcalloc(depth, sizeof(*r->mw_sg), GFP_KERNEL);
+	if (!r->mw_sg)
+		goto out_list_err;
+
+	sg_init_table(r->mw_sg, depth);
+	init_completion(&f->fr_linv_done);
+	return 0;
+
+out_mr_err:
+	rc = PTR_ERR(f->fr_mr);
+	dprintk("RPC:       %s: ib_alloc_mr status %i\n",
+		__func__, rc);
+	return rc;
+
+out_list_err:
+	rc = -ENOMEM;
+	dprintk("RPC:       %s: sg allocation failure\n",
+		__func__);
+	ib_dereg_mr(f->fr_mr);
+	return rc;
+}
+
+static void
+__frwr_release(struct rpcrdma_mw *r)
+{
+	int rc;
+
+	rc = ib_dereg_mr(r->frmr.fr_mr);
+	if (rc)
+		pr_err("rpcrdma: final ib_dereg_mr for %p returned %i\n",
+		       r, rc);
+	kfree(r->mw_sg);
+}
+
+static int
 __frwr_reset_mr(struct rpcrdma_ia *ia, struct rpcrdma_mw *r)
 {
 	struct rpcrdma_frmr *f = &r->frmr;
@@ -165,52 +209,6 @@ __frwr_queue_recovery(struct rpcrdma_mw *r)
 }
 
 static int
-__frwr_init(struct rpcrdma_mw *r, struct ib_pd *pd, unsigned int depth)
-{
-	struct rpcrdma_frmr *f = &r->frmr;
-	int rc;
-
-	f->fr_mr = ib_alloc_mr(pd, IB_MR_TYPE_MEM_REG, depth);
-	if (IS_ERR(f->fr_mr))
-		goto out_mr_err;
-
-	r->mw_sg = kcalloc(depth, sizeof(*r->mw_sg), GFP_KERNEL);
-	if (!r->mw_sg)
-		goto out_list_err;
-
-	sg_init_table(r->mw_sg, depth);
-
-	init_completion(&f->fr_linv_done);
-
-	return 0;
-
-out_mr_err:
-	rc = PTR_ERR(f->fr_mr);
-	dprintk("RPC:       %s: ib_alloc_mr status %i\n",
-		__func__, rc);
-	return rc;
-
-out_list_err:
-	rc = -ENOMEM;
-	dprintk("RPC:       %s: sg allocation failure\n",
-		__func__);
-	ib_dereg_mr(f->fr_mr);
-	return rc;
-}
-
-static void
-__frwr_release(struct rpcrdma_mw *r)
-{
-	int rc;
-
-	rc = ib_dereg_mr(r->frmr.fr_mr);
-	if (rc)
-		dprintk("RPC:       %s: ib_dereg_mr status %i\n",
-			__func__, rc);
-	kfree(r->mw_sg);
-}
-
-static int
 frwr_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
 	     struct rpcrdma_create_data_internal *cdata)
 {


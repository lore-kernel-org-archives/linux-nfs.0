Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:36372 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752663AbbCMVWa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Mar 2015 17:22:30 -0400
Received: by iegc3 with SMTP id c3so130665062ieg.3
        for <linux-nfs@vger.kernel.org>; Fri, 13 Mar 2015 14:22:29 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id w3sm1992001igz.1.2015.03.13.14.22.23
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 14:22:24 -0700 (PDT)
Subject: [PATCH v1 07/16] xprtrdma: Add "init MRs" memreg op
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Fri, 13 Mar 2015 17:22:23 -0400
Message-ID: <20150313212223.22471.54459.stgit@manet.1015granger.net>
In-Reply-To: <20150313211124.22471.14517.stgit@manet.1015granger.net>
References: <20150313211124.22471.14517.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This method is used when setting up a new transport instance to
create a pool of Memory Region objects that will be used to register
memory during operation.

Memory Regions are not needed for "physical" registration, since
->prepare and ->release are basically no-ops for that mode.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c      |   42 +++++++++++++++
 net/sunrpc/xprtrdma/frwr_ops.c     |   66 +++++++++++++++++++++++
 net/sunrpc/xprtrdma/physical_ops.c |    7 ++
 net/sunrpc/xprtrdma/verbs.c        |  104 +-----------------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h    |    1 
 5 files changed, 119 insertions(+), 101 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 9b983b4..1501db0 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -55,6 +55,47 @@ fmr_op_maxpages(struct rpcrdma_xprt *r_xprt)
 		     rpcrdma_max_segments(r_xprt) * RPCRDMA_MAX_FMR_SGES);
 }
 
+static int
+fmr_op_init(struct rpcrdma_xprt *r_xprt)
+{
+	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
+	int mr_access_flags = IB_ACCESS_REMOTE_WRITE | IB_ACCESS_REMOTE_READ;
+	struct ib_fmr_attr fmr_attr = {
+		.max_pages	= RPCRDMA_MAX_FMR_SGES,
+		.max_maps	= 1,
+		.page_shift	= PAGE_SHIFT
+	};
+	struct ib_pd *pd = r_xprt->rx_ia.ri_pd;
+	struct rpcrdma_mw *r;
+	int i, rc;
+
+	INIT_LIST_HEAD(&buf->rb_mws);
+	INIT_LIST_HEAD(&buf->rb_all);
+
+	i = (buf->rb_max_requests + 1) * RPCRDMA_MAX_SEGS;
+	dprintk("RPC:       %s: initalizing %d FMRs\n", __func__, i);
+
+	while (i--) {
+		r = kzalloc(sizeof(*r), GFP_KERNEL);
+		if (!r)
+			return -ENOMEM;
+
+		r->r.fmr = ib_alloc_fmr(pd, mr_access_flags, &fmr_attr);
+		if (IS_ERR(r->r.fmr))
+			goto out_fmr_err;
+
+		list_add(&r->mw_list, &buf->rb_mws);
+		list_add(&r->mw_all, &buf->rb_all);
+	}
+	return 0;
+
+out_fmr_err:
+	rc = PTR_ERR(r->r.fmr);
+	dprintk("RPC:       %s: ib_alloc_fmr status %i\n", __func__, rc);
+	kfree(r);
+	return rc;
+}
+
 /* Use the ib_map_phys_fmr() verb to register a memory region
  * for remote access via RDMA READ or RDMA WRITE.
  */
@@ -119,5 +160,6 @@ const struct rpcrdma_memreg_ops rpcrdma_fmr_memreg_ops = {
 	.ro_map				= fmr_op_map,
 	.ro_unmap			= fmr_op_unmap,
 	.ro_maxpages			= fmr_op_maxpages,
+	.ro_init			= fmr_op_init,
 	.ro_displayname			= "fmr",
 };
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 05b5761..975372c 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -17,6 +17,35 @@
 # define RPCDBG_FACILITY	RPCDBG_TRANS
 #endif
 
+static int
+__frwr_init(struct rpcrdma_mw *r, struct ib_pd *pd, struct ib_device *device,
+	    unsigned int depth)
+{
+	struct rpcrdma_frmr *f = &r->r.frmr;
+	int rc;
+
+	f->fr_mr = ib_alloc_fast_reg_mr(pd, depth);
+	if (IS_ERR(f->fr_mr))
+		goto out_mr_err;
+	f->fr_pgl = ib_alloc_fast_reg_page_list(device, depth);
+	if (IS_ERR(f->fr_pgl))
+		goto out_list_err;
+	return 0;
+
+out_mr_err:
+	rc = PTR_ERR(f->fr_mr);
+	dprintk("RPC:       %s: ib_alloc_fast_reg_mr status %i\n",
+		__func__, rc);
+	return rc;
+
+out_list_err:
+	rc = PTR_ERR(f->fr_pgl);
+	dprintk("RPC:       %s: ib_alloc_fast_reg_page_list status %i\n",
+		__func__, rc);
+	ib_dereg_mr(f->fr_mr);
+	return rc;
+}
+
 /* Post a LOCAL_INV Work Request to prevent further remote access
  * via RDMA READ or RDMA WRITE.
  */
@@ -64,6 +93,42 @@ frwr_op_maxpages(struct rpcrdma_xprt *r_xprt)
 		     rpcrdma_max_segments(r_xprt) * ia->ri_max_frmr_depth);
 }
 
+static int
+frwr_op_init(struct rpcrdma_xprt *r_xprt)
+{
+	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
+	struct ib_device *device = r_xprt->rx_ia.ri_id->device;
+	unsigned int depth = r_xprt->rx_ia.ri_max_frmr_depth;
+	struct ib_pd *pd = r_xprt->rx_ia.ri_pd;
+	int i;
+
+	INIT_LIST_HEAD(&buf->rb_mws);
+	INIT_LIST_HEAD(&buf->rb_all);
+
+	i = (buf->rb_max_requests + 1) * RPCRDMA_MAX_SEGS;
+	dprintk("RPC:       %s: initalizing %d FRMRs\n", __func__, i);
+
+	while (i--) {
+		struct rpcrdma_mw *r;
+		int rc;
+
+		r = kzalloc(sizeof(*r), GFP_KERNEL);
+		if (!r)
+			return -ENOMEM;
+
+		rc = __frwr_init(r, pd, device, depth);
+		if (rc) {
+			kfree(r);
+			return rc;
+		}
+
+		list_add(&r->mw_list, &buf->rb_mws);
+		list_add(&r->mw_all, &buf->rb_all);
+	}
+
+	return 0;
+}
+
 /* Post a FAST_REG Work Request to register a memory region
  * for remote access via RDMA READ or RDMA WRITE.
  */
@@ -165,5 +230,6 @@ const struct rpcrdma_memreg_ops rpcrdma_frwr_memreg_ops = {
 	.ro_map				= frwr_op_map,
 	.ro_unmap			= frwr_op_unmap,
 	.ro_maxpages			= frwr_op_maxpages,
+	.ro_init			= frwr_op_init,
 	.ro_displayname			= "frwr",
 };
diff --git a/net/sunrpc/xprtrdma/physical_ops.c b/net/sunrpc/xprtrdma/physical_ops.c
index f2c15be..ae2b0bc 100644
--- a/net/sunrpc/xprtrdma/physical_ops.c
+++ b/net/sunrpc/xprtrdma/physical_ops.c
@@ -28,6 +28,12 @@ physical_op_maxpages(struct rpcrdma_xprt *r_xprt)
 		     rpcrdma_max_segments(r_xprt));
 }
 
+static int
+physical_op_init(struct rpcrdma_xprt *r_xprt)
+{
+	return 0;
+}
+
 /* The client's physical memory is already exposed for
  * remote access via RDMA READ or RDMA WRITE.
  */
@@ -60,5 +66,6 @@ const struct rpcrdma_memreg_ops rpcrdma_physical_memreg_ops = {
 	.ro_map				= physical_op_map,
 	.ro_unmap			= physical_op_unmap,
 	.ro_maxpages			= physical_op_maxpages,
+	.ro_init			= physical_op_init,
 	.ro_displayname			= "physical",
 };
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index a1621fd..d7810d6 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1123,91 +1123,6 @@ out:
 	return ERR_PTR(rc);
 }
 
-static int
-rpcrdma_init_fmrs(struct rpcrdma_ia *ia, struct rpcrdma_buffer *buf)
-{
-	int mr_access_flags = IB_ACCESS_REMOTE_WRITE | IB_ACCESS_REMOTE_READ;
-	struct ib_fmr_attr fmr_attr = {
-		.max_pages	= RPCRDMA_MAX_DATA_SEGS,
-		.max_maps	= 1,
-		.page_shift	= PAGE_SHIFT
-	};
-	struct rpcrdma_mw *r;
-	int i, rc;
-
-	i = (buf->rb_max_requests + 1) * RPCRDMA_MAX_SEGS;
-	dprintk("RPC:       %s: initalizing %d FMRs\n", __func__, i);
-
-	while (i--) {
-		r = kzalloc(sizeof(*r), GFP_KERNEL);
-		if (r == NULL)
-			return -ENOMEM;
-
-		r->r.fmr = ib_alloc_fmr(ia->ri_pd, mr_access_flags, &fmr_attr);
-		if (IS_ERR(r->r.fmr)) {
-			rc = PTR_ERR(r->r.fmr);
-			dprintk("RPC:       %s: ib_alloc_fmr failed %i\n",
-				__func__, rc);
-			goto out_free;
-		}
-
-		list_add(&r->mw_list, &buf->rb_mws);
-		list_add(&r->mw_all, &buf->rb_all);
-	}
-	return 0;
-
-out_free:
-	kfree(r);
-	return rc;
-}
-
-static int
-rpcrdma_init_frmrs(struct rpcrdma_ia *ia, struct rpcrdma_buffer *buf)
-{
-	struct rpcrdma_frmr *f;
-	struct rpcrdma_mw *r;
-	int i, rc;
-
-	i = (buf->rb_max_requests + 1) * RPCRDMA_MAX_SEGS;
-	dprintk("RPC:       %s: initalizing %d FRMRs\n", __func__, i);
-
-	while (i--) {
-		r = kzalloc(sizeof(*r), GFP_KERNEL);
-		if (r == NULL)
-			return -ENOMEM;
-		f = &r->r.frmr;
-
-		f->fr_mr = ib_alloc_fast_reg_mr(ia->ri_pd,
-						ia->ri_max_frmr_depth);
-		if (IS_ERR(f->fr_mr)) {
-			rc = PTR_ERR(f->fr_mr);
-			dprintk("RPC:       %s: ib_alloc_fast_reg_mr "
-				"failed %i\n", __func__, rc);
-			goto out_free;
-		}
-
-		f->fr_pgl = ib_alloc_fast_reg_page_list(ia->ri_id->device,
-							ia->ri_max_frmr_depth);
-		if (IS_ERR(f->fr_pgl)) {
-			rc = PTR_ERR(f->fr_pgl);
-			dprintk("RPC:       %s: ib_alloc_fast_reg_page_list "
-				"failed %i\n", __func__, rc);
-
-			ib_dereg_mr(f->fr_mr);
-			goto out_free;
-		}
-
-		list_add(&r->mw_list, &buf->rb_mws);
-		list_add(&r->mw_all, &buf->rb_all);
-	}
-
-	return 0;
-
-out_free:
-	kfree(r);
-	return rc;
-}
-
 int
 rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 {
@@ -1244,22 +1159,9 @@ rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 	buf->rb_recv_bufs = (struct rpcrdma_rep **) p;
 	p = (char *) &buf->rb_recv_bufs[buf->rb_max_requests];
 
-	INIT_LIST_HEAD(&buf->rb_mws);
-	INIT_LIST_HEAD(&buf->rb_all);
-	switch (ia->ri_memreg_strategy) {
-	case RPCRDMA_FRMR:
-		rc = rpcrdma_init_frmrs(ia, buf);
-		if (rc)
-			goto out;
-		break;
-	case RPCRDMA_MTHCAFMR:
-		rc = rpcrdma_init_fmrs(ia, buf);
-		if (rc)
-			goto out;
-		break;
-	default:
-		break;
-	}
+	rc = ia->ri_ops->ro_init(r_xprt);
+	if (rc)
+		goto out;
 
 	for (i = 0; i < buf->rb_max_requests; i++) {
 		struct rpcrdma_req *req;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 3aabbb2..4fe3c38 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -341,6 +341,7 @@ struct rpcrdma_memreg_ops {
 	void		(*ro_unmap)(struct rpcrdma_xprt *,
 				    struct rpcrdma_req *, unsigned int);
 	size_t		(*ro_maxpages)(struct rpcrdma_xprt *);
+	int		(*ro_init)(struct rpcrdma_xprt *);
 	const char	*ro_displayname;
 };
 


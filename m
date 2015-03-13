Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:33359 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753677AbbCMVWi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Mar 2015 17:22:38 -0400
Received: by iecvj10 with SMTP id vj10so123218523iec.0
        for <linux-nfs@vger.kernel.org>; Fri, 13 Mar 2015 14:22:38 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id b1sm2023253igl.7.2015.03.13.14.22.33
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 14:22:33 -0700 (PDT)
Subject: [PATCH v1 08/16] xprtrdma: Add "reset MRs" memreg op
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Fri, 13 Mar 2015 17:22:32 -0400
Message-ID: <20150313212232.22471.47435.stgit@manet.1015granger.net>
In-Reply-To: <20150313211124.22471.14517.stgit@manet.1015granger.net>
References: <20150313211124.22471.14517.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This method is invoked when a transport instance is about to be
reconnected. Each Memory Region object is reset to its initial
state.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c      |   23 ++++++++
 net/sunrpc/xprtrdma/frwr_ops.c     |   46 ++++++++++++++++
 net/sunrpc/xprtrdma/physical_ops.c |    6 ++
 net/sunrpc/xprtrdma/verbs.c        |  103 +-----------------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h    |    1 
 5 files changed, 78 insertions(+), 101 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 1501db0..1ccb3de 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -156,10 +156,33 @@ fmr_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 		i += __fmr_unmap(r_xprt, &req->rl_segments[i]);
 }
 
+/* After a disconnect, unmap all FMRs.
+ *
+ * This is invoked only in the transport connect worker in order
+ * to serialize with rpcrdma_register_fmr_external().
+ */
+static void
+fmr_op_reset(struct rpcrdma_xprt *r_xprt)
+{
+	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
+	struct rpcrdma_mw *r;
+	LIST_HEAD(list);
+	int rc;
+
+	list_for_each_entry(r, &buf->rb_all, mw_all)
+		list_add(&r->r.fmr->list, &list);
+
+	rc = ib_unmap_fmr(&list);
+	if (rc)
+		dprintk("RPC:       %s: ib_unmap_fmr failed %i\n",
+			__func__, rc);
+}
+
 const struct rpcrdma_memreg_ops rpcrdma_fmr_memreg_ops = {
 	.ro_map				= fmr_op_map,
 	.ro_unmap			= fmr_op_unmap,
 	.ro_maxpages			= fmr_op_maxpages,
 	.ro_init			= fmr_op_init,
+	.ro_reset			= fmr_op_reset,
 	.ro_displayname			= "fmr",
 };
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 975372c..b4ce0e5 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -81,6 +81,18 @@ out_err:
 	return nsegs;
 }
 
+static void
+__frwr_release(struct rpcrdma_mw *r)
+{
+	int rc;
+
+	rc = ib_dereg_mr(r->r.frmr.fr_mr);
+	if (rc)
+		dprintk("RPC:       %s: ib_dereg_mr status %i\n",
+			__func__, rc);
+	ib_free_fast_reg_page_list(r->r.frmr.fr_pgl);
+}
+
 /* FRWR mode conveys a list of pages per chunk segment. The
  * maximum length of that list is the FRWR page list depth.
  */
@@ -226,10 +238,44 @@ frwr_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 		i += __frwr_unmap(r_xprt, &req->rl_segments[i]);
 }
 
+/* After a disconnect, a flushed FAST_REG_MR can leave an FRMR in
+ * an unusable state. Find FRMRs in this state and dereg / reg
+ * each.  FRMRs that are VALID and attached to an rpcrdma_req are
+ * also torn down.
+ *
+ * This gives all in-use FRMRs a fresh rkey and leaves them INVALID.
+ *
+ * This is invoked only in the transport connect worker in order
+ * to serialize with rpcrdma_register_frmr_external().
+ */
+static void
+frwr_op_reset(struct rpcrdma_xprt *r_xprt)
+{
+	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
+	struct ib_device *device = r_xprt->rx_ia.ri_id->device;
+	unsigned int depth = r_xprt->rx_ia.ri_max_frmr_depth;
+	struct ib_pd *pd = r_xprt->rx_ia.ri_pd;
+	struct rpcrdma_mw *r;
+	int rc;
+
+	list_for_each_entry(r, &buf->rb_all, mw_all) {
+		if (r->r.frmr.fr_state == FRMR_IS_INVALID)
+			continue;
+
+		__frwr_release(r);
+		rc = __frwr_init(r, pd, device, depth);
+		if (rc)
+			continue;
+
+		r->r.frmr.fr_state = FRMR_IS_INVALID;
+	}
+}
+
 const struct rpcrdma_memreg_ops rpcrdma_frwr_memreg_ops = {
 	.ro_map				= frwr_op_map,
 	.ro_unmap			= frwr_op_unmap,
 	.ro_maxpages			= frwr_op_maxpages,
 	.ro_init			= frwr_op_init,
+	.ro_reset			= frwr_op_reset,
 	.ro_displayname			= "frwr",
 };
diff --git a/net/sunrpc/xprtrdma/physical_ops.c b/net/sunrpc/xprtrdma/physical_ops.c
index ae2b0bc..0afc691 100644
--- a/net/sunrpc/xprtrdma/physical_ops.c
+++ b/net/sunrpc/xprtrdma/physical_ops.c
@@ -62,10 +62,16 @@ physical_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 		rpcrdma_unmap_one(&r_xprt->rx_ia, &req->rl_segments[i]);
 }
 
+static void
+physical_op_reset(struct rpcrdma_xprt *r_xprt)
+{
+}
+
 const struct rpcrdma_memreg_ops rpcrdma_physical_memreg_ops = {
 	.ro_map				= physical_op_map,
 	.ro_unmap			= physical_op_unmap,
 	.ro_maxpages			= physical_op_maxpages,
 	.ro_init			= physical_op_init,
+	.ro_reset			= physical_op_reset,
 	.ro_displayname			= "physical",
 };
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index d7810d6..e17d91a 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -63,9 +63,6 @@
 # define RPCDBG_FACILITY	RPCDBG_TRANS
 #endif
 
-static void rpcrdma_reset_frmrs(struct rpcrdma_ia *);
-static void rpcrdma_reset_fmrs(struct rpcrdma_ia *);
-
 /*
  * internal functions
  */
@@ -944,21 +941,9 @@ retry:
 		rpcrdma_ep_disconnect(ep, ia);
 		rpcrdma_flush_cqs(ep);
 
-		switch (ia->ri_memreg_strategy) {
-		case RPCRDMA_FRMR:
-			rpcrdma_reset_frmrs(ia);
-			break;
-		case RPCRDMA_MTHCAFMR:
-			rpcrdma_reset_fmrs(ia);
-			break;
-		case RPCRDMA_ALLPHYSICAL:
-			break;
-		default:
-			rc = -EIO;
-			goto out;
-		}
-
 		xprt = container_of(ia, struct rpcrdma_xprt, rx_ia);
+		ia->ri_ops->ro_reset(xprt);
+
 		id = rpcrdma_create_id(xprt, ia,
 				(struct sockaddr *)&xprt->rx_data.addr);
 		if (IS_ERR(id)) {
@@ -1288,90 +1273,6 @@ rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 	kfree(buf->rb_pool);
 }
 
-/* After a disconnect, unmap all FMRs.
- *
- * This is invoked only in the transport connect worker in order
- * to serialize with rpcrdma_register_fmr_external().
- */
-static void
-rpcrdma_reset_fmrs(struct rpcrdma_ia *ia)
-{
-	struct rpcrdma_xprt *r_xprt =
-				container_of(ia, struct rpcrdma_xprt, rx_ia);
-	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
-	struct list_head *pos;
-	struct rpcrdma_mw *r;
-	LIST_HEAD(l);
-	int rc;
-
-	list_for_each(pos, &buf->rb_all) {
-		r = list_entry(pos, struct rpcrdma_mw, mw_all);
-
-		INIT_LIST_HEAD(&l);
-		list_add(&r->r.fmr->list, &l);
-		rc = ib_unmap_fmr(&l);
-		if (rc)
-			dprintk("RPC:       %s: ib_unmap_fmr failed %i\n",
-				__func__, rc);
-	}
-}
-
-/* After a disconnect, a flushed FAST_REG_MR can leave an FRMR in
- * an unusable state. Find FRMRs in this state and dereg / reg
- * each.  FRMRs that are VALID and attached to an rpcrdma_req are
- * also torn down.
- *
- * This gives all in-use FRMRs a fresh rkey and leaves them INVALID.
- *
- * This is invoked only in the transport connect worker in order
- * to serialize with rpcrdma_register_frmr_external().
- */
-static void
-rpcrdma_reset_frmrs(struct rpcrdma_ia *ia)
-{
-	struct rpcrdma_xprt *r_xprt =
-				container_of(ia, struct rpcrdma_xprt, rx_ia);
-	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
-	struct list_head *pos;
-	struct rpcrdma_mw *r;
-	int rc;
-
-	list_for_each(pos, &buf->rb_all) {
-		r = list_entry(pos, struct rpcrdma_mw, mw_all);
-
-		if (r->r.frmr.fr_state == FRMR_IS_INVALID)
-			continue;
-
-		rc = ib_dereg_mr(r->r.frmr.fr_mr);
-		if (rc)
-			dprintk("RPC:       %s: ib_dereg_mr failed %i\n",
-				__func__, rc);
-		ib_free_fast_reg_page_list(r->r.frmr.fr_pgl);
-
-		r->r.frmr.fr_mr = ib_alloc_fast_reg_mr(ia->ri_pd,
-					ia->ri_max_frmr_depth);
-		if (IS_ERR(r->r.frmr.fr_mr)) {
-			rc = PTR_ERR(r->r.frmr.fr_mr);
-			dprintk("RPC:       %s: ib_alloc_fast_reg_mr"
-				" failed %i\n", __func__, rc);
-			continue;
-		}
-		r->r.frmr.fr_pgl = ib_alloc_fast_reg_page_list(
-					ia->ri_id->device,
-					ia->ri_max_frmr_depth);
-		if (IS_ERR(r->r.frmr.fr_pgl)) {
-			rc = PTR_ERR(r->r.frmr.fr_pgl);
-			dprintk("RPC:       %s: "
-				"ib_alloc_fast_reg_page_list "
-				"failed %i\n", __func__, rc);
-
-			ib_dereg_mr(r->r.frmr.fr_mr);
-			continue;
-		}
-		r->r.frmr.fr_state = FRMR_IS_INVALID;
-	}
-}
-
 /* "*mw" can be NULL when rpcrdma_buffer_get_mrs() fails, leaving
  * some req segments uninitialized.
  */
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 4fe3c38..cdf6763 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -342,6 +342,7 @@ struct rpcrdma_memreg_ops {
 				    struct rpcrdma_req *, unsigned int);
 	size_t		(*ro_maxpages)(struct rpcrdma_xprt *);
 	int		(*ro_init)(struct rpcrdma_xprt *);
+	void		(*ro_reset)(struct rpcrdma_xprt *);
 	const char	*ro_displayname;
 };
 


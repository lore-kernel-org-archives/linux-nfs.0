Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:34760 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753178AbbEKSEH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 May 2015 14:04:07 -0400
Subject: [PATCH v2 11/16] xprtrdma: Remove ->ro_reset
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 11 May 2015 14:04:01 -0400
Message-ID: <20150511180401.31263.9823.stgit@manet.1015granger.net>
In-Reply-To: <20150511174401.31263.79596.stgit@manet.1015granger.net>
References: <20150511174401.31263.79596.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An RPC can exit at any time. When it does so, xprt_rdma_free() is
called, and it calls ->op_unmap().

If ->ro_reset() is running due to a transport disconnect, the two
methods can race while processing the same rpcrdma_mw. The results
are unpredictable.

Because of this, in previous patches I've altered ->ro_map() to
handle MR reset. ->ro_reset() is no longer needed and can be
removed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Steve Wise <swise@opengridcomputing.com>
Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
Reviewed-by: Devesh Sharma <devesh.sharma@avagotech.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c      |   23 ---------------------
 net/sunrpc/xprtrdma/frwr_ops.c     |   39 ------------------------------------
 net/sunrpc/xprtrdma/physical_ops.c |    6 ------
 net/sunrpc/xprtrdma/verbs.c        |    2 --
 net/sunrpc/xprtrdma/xprt_rdma.h    |    1 -
 5 files changed, 71 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 53fb649..5dd77da 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -197,28 +197,6 @@ out_err:
 	return nsegs;
 }
 
-/* After a disconnect, unmap all FMRs.
- *
- * This is invoked only in the transport connect worker in order
- * to serialize with rpcrdma_register_fmr_external().
- */
-static void
-fmr_op_reset(struct rpcrdma_xprt *r_xprt)
-{
-	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
-	struct rpcrdma_mw *r;
-	LIST_HEAD(list);
-	int rc;
-
-	list_for_each_entry(r, &buf->rb_all, mw_all)
-		list_add(&r->r.fmr->list, &list);
-
-	rc = ib_unmap_fmr(&list);
-	if (rc)
-		dprintk("RPC:       %s: ib_unmap_fmr failed %i\n",
-			__func__, rc);
-}
-
 static void
 fmr_op_destroy(struct rpcrdma_buffer *buf)
 {
@@ -242,7 +220,6 @@ const struct rpcrdma_memreg_ops rpcrdma_fmr_memreg_ops = {
 	.ro_open			= fmr_op_open,
 	.ro_maxpages			= fmr_op_maxpages,
 	.ro_init			= fmr_op_init,
-	.ro_reset			= fmr_op_reset,
 	.ro_destroy			= fmr_op_destroy,
 	.ro_displayname			= "fmr",
 };
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 133edf6..8622792 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -430,44 +430,6 @@ out_err:
 	return nsegs;
 }
 
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
-frwr_op_reset(struct rpcrdma_xprt *r_xprt)
-{
-	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
-	struct ib_device *device = r_xprt->rx_ia.ri_device;
-	unsigned int depth = r_xprt->rx_ia.ri_max_frmr_depth;
-	struct ib_pd *pd = r_xprt->rx_ia.ri_pd;
-	struct rpcrdma_mw *r;
-	int rc;
-
-	list_for_each_entry(r, &buf->rb_all, mw_all) {
-		if (r->r.frmr.fr_state == FRMR_IS_INVALID)
-			continue;
-
-		__frwr_release(r);
-		rc = __frwr_init(r, pd, device, depth);
-		if (rc) {
-			dprintk("RPC:       %s: mw %p left %s\n",
-				__func__, r,
-				(r->r.frmr.fr_state == FRMR_IS_STALE ?
-					"stale" : "valid"));
-			continue;
-		}
-
-		r->r.frmr.fr_state = FRMR_IS_INVALID;
-	}
-}
-
 static void
 frwr_op_destroy(struct rpcrdma_buffer *buf)
 {
@@ -490,7 +452,6 @@ const struct rpcrdma_memreg_ops rpcrdma_frwr_memreg_ops = {
 	.ro_open			= frwr_op_open,
 	.ro_maxpages			= frwr_op_maxpages,
 	.ro_init			= frwr_op_init,
-	.ro_reset			= frwr_op_reset,
 	.ro_destroy			= frwr_op_destroy,
 	.ro_displayname			= "frwr",
 };
diff --git a/net/sunrpc/xprtrdma/physical_ops.c b/net/sunrpc/xprtrdma/physical_ops.c
index da149e8..41985d0 100644
--- a/net/sunrpc/xprtrdma/physical_ops.c
+++ b/net/sunrpc/xprtrdma/physical_ops.c
@@ -69,11 +69,6 @@ physical_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
 }
 
 static void
-physical_op_reset(struct rpcrdma_xprt *r_xprt)
-{
-}
-
-static void
 physical_op_destroy(struct rpcrdma_buffer *buf)
 {
 }
@@ -84,7 +79,6 @@ const struct rpcrdma_memreg_ops rpcrdma_physical_memreg_ops = {
 	.ro_open			= physical_op_open,
 	.ro_maxpages			= physical_op_maxpages,
 	.ro_init			= physical_op_init,
-	.ro_reset			= physical_op_reset,
 	.ro_destroy			= physical_op_destroy,
 	.ro_displayname			= "physical",
 };
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index a891cf7..db9303a 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -891,8 +891,6 @@ retry:
 		rpcrdma_flush_cqs(ep);
 
 		xprt = container_of(ia, struct rpcrdma_xprt, rx_ia);
-		ia->ri_ops->ro_reset(xprt);
-
 		id = rpcrdma_create_id(xprt, ia,
 				(struct sockaddr *)&xprt->rx_data.addr);
 		if (IS_ERR(id)) {
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index c5862a4..f19376d 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -352,7 +352,6 @@ struct rpcrdma_memreg_ops {
 				   struct rpcrdma_create_data_internal *);
 	size_t		(*ro_maxpages)(struct rpcrdma_xprt *);
 	int		(*ro_init)(struct rpcrdma_xprt *);
-	void		(*ro_reset)(struct rpcrdma_xprt *);
 	void		(*ro_destroy)(struct rpcrdma_buffer *);
 	const char	*ro_displayname;
 };


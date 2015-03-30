Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:34272 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753289AbbC3Sev (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2015 14:34:51 -0400
Subject: [PATCH v3 09/15] xprtrdma: Add a "deregister_external" op for each
 memreg mode
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 30 Mar 2015 14:34:48 -0400
Message-ID: <20150330183448.7856.66373.stgit@manet.1015granger.net>
In-Reply-To: <20150330182615.7856.61170.stgit@manet.1015granger.net>
References: <20150330182615.7856.61170.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is very little common processing among the different external
memory deregistration functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Devesh Sharma <Devesh.Sharma@Emulex.Com>
Tested-by: Meghana Cheripady <Meghana.Cheripady@Emulex.Com>
Tested-by: Veeresh U. Kokatnur <veereshuk@chelsio.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c      |   27 ++++++++++++
 net/sunrpc/xprtrdma/frwr_ops.c     |   36 ++++++++++++++++
 net/sunrpc/xprtrdma/physical_ops.c |   10 ++++
 net/sunrpc/xprtrdma/rpc_rdma.c     |   11 +++--
 net/sunrpc/xprtrdma/transport.c    |    4 +-
 net/sunrpc/xprtrdma/verbs.c        |   81 ------------------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h    |    5 +-
 7 files changed, 84 insertions(+), 90 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 45fb646..888aa10 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -79,8 +79,35 @@ out_maperr:
 	return rc;
 }
 
+/* Use the ib_unmap_fmr() verb to prevent further remote
+ * access via RDMA READ or RDMA WRITE.
+ */
+static int
+fmr_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
+{
+	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
+	struct rpcrdma_mr_seg *seg1 = seg;
+	int rc, nsegs = seg->mr_nsegs;
+	LIST_HEAD(l);
+
+	list_add(&seg1->rl_mw->r.fmr->list, &l);
+	rc = ib_unmap_fmr(&l);
+	read_lock(&ia->ri_qplock);
+	while (seg1->mr_nsegs--)
+		rpcrdma_unmap_one(ia, seg++);
+	read_unlock(&ia->ri_qplock);
+	if (rc)
+		goto out_err;
+	return nsegs;
+
+out_err:
+	dprintk("RPC:       %s: ib_unmap_fmr status %i\n", __func__, rc);
+	return nsegs;
+}
+
 const struct rpcrdma_memreg_ops rpcrdma_fmr_memreg_ops = {
 	.ro_map				= fmr_op_map,
+	.ro_unmap			= fmr_op_unmap,
 	.ro_maxpages			= fmr_op_maxpages,
 	.ro_displayname			= "fmr",
 };
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 23e4d99..35b725b 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -110,8 +110,44 @@ out_senderr:
 	return rc;
 }
 
+/* Post a LOCAL_INV Work Request to prevent further remote access
+ * via RDMA READ or RDMA WRITE.
+ */
+static int
+frwr_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
+{
+	struct rpcrdma_mr_seg *seg1 = seg;
+	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
+	struct ib_send_wr invalidate_wr, *bad_wr;
+	int rc, nsegs = seg->mr_nsegs;
+
+	seg1->rl_mw->r.frmr.fr_state = FRMR_IS_INVALID;
+
+	memset(&invalidate_wr, 0, sizeof(invalidate_wr));
+	invalidate_wr.wr_id = (unsigned long)(void *)seg1->rl_mw;
+	invalidate_wr.opcode = IB_WR_LOCAL_INV;
+	invalidate_wr.ex.invalidate_rkey = seg1->rl_mw->r.frmr.fr_mr->rkey;
+	DECR_CQCOUNT(&r_xprt->rx_ep);
+
+	read_lock(&ia->ri_qplock);
+	while (seg1->mr_nsegs--)
+		rpcrdma_unmap_one(ia, seg++);
+	rc = ib_post_send(ia->ri_id->qp, &invalidate_wr, &bad_wr);
+	read_unlock(&ia->ri_qplock);
+	if (rc)
+		goto out_err;
+	return nsegs;
+
+out_err:
+	/* Force rpcrdma_buffer_get() to retry */
+	seg1->rl_mw->r.frmr.fr_state = FRMR_IS_STALE;
+	dprintk("RPC:       %s: ib_post_send status %i\n", __func__, rc);
+	return nsegs;
+}
+
 const struct rpcrdma_memreg_ops rpcrdma_frwr_memreg_ops = {
 	.ro_map				= frwr_op_map,
+	.ro_unmap			= frwr_op_unmap,
 	.ro_maxpages			= frwr_op_maxpages,
 	.ro_displayname			= "frwr",
 };
diff --git a/net/sunrpc/xprtrdma/physical_ops.c b/net/sunrpc/xprtrdma/physical_ops.c
index 5a284ee..5b5a63a 100644
--- a/net/sunrpc/xprtrdma/physical_ops.c
+++ b/net/sunrpc/xprtrdma/physical_ops.c
@@ -44,8 +44,18 @@ physical_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	return 1;
 }
 
+/* Unmap a memory region, but leave it registered.
+ */
+static int
+physical_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
+{
+	rpcrdma_unmap_one(&r_xprt->rx_ia, seg);
+	return 1;
+}
+
 const struct rpcrdma_memreg_ops rpcrdma_physical_memreg_ops = {
 	.ro_map				= physical_op_map,
+	.ro_unmap			= physical_op_unmap,
 	.ro_maxpages			= physical_op_maxpages,
 	.ro_displayname			= "physical",
 };
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 6ab1d03..2c53ea9 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -284,11 +284,12 @@ rpcrdma_create_chunks(struct rpc_rqst *rqst, struct xdr_buf *target,
 	return (unsigned char *)iptr - (unsigned char *)headerp;
 
 out:
-	if (r_xprt->rx_ia.ri_memreg_strategy != RPCRDMA_FRMR) {
-		for (pos = 0; nchunks--;)
-			pos += rpcrdma_deregister_external(
-					&req->rl_segments[pos], r_xprt);
-	}
+	if (r_xprt->rx_ia.ri_memreg_strategy == RPCRDMA_FRMR)
+		return n;
+
+	for (pos = 0; nchunks--;)
+		pos += r_xprt->rx_ia.ri_ops->ro_unmap(r_xprt,
+						      &req->rl_segments[pos]);
 	return n;
 }
 
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index da71a24..54f23b1 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -584,8 +584,8 @@ xprt_rdma_free(void *buffer)
 
 	for (i = 0; req->rl_nchunks;) {
 		--req->rl_nchunks;
-		i += rpcrdma_deregister_external(
-			&req->rl_segments[i], r_xprt);
+		i += r_xprt->rx_ia.ri_ops->ro_unmap(r_xprt,
+						    &req->rl_segments[i]);
 	}
 
 	rpcrdma_buffer_put(req);
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 4318c04..b167c99 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1510,7 +1510,7 @@ rpcrdma_buffer_put_sendbuf(struct rpcrdma_req *req, struct rpcrdma_buffer *buf)
 	}
 }
 
-/* rpcrdma_unmap_one() was already done by rpcrdma_deregister_frmr_external().
+/* rpcrdma_unmap_one() was already done during deregistration.
  * Redo only the ib_post_send().
  */
 static void
@@ -1890,85 +1890,6 @@ rpcrdma_unmap_one(struct rpcrdma_ia *ia, struct rpcrdma_mr_seg *seg)
 				seg->mr_dma, seg->mr_dmalen, seg->mr_dir);
 }
 
-static int
-rpcrdma_deregister_frmr_external(struct rpcrdma_mr_seg *seg,
-			struct rpcrdma_ia *ia, struct rpcrdma_xprt *r_xprt)
-{
-	struct rpcrdma_mr_seg *seg1 = seg;
-	struct ib_send_wr invalidate_wr, *bad_wr;
-	int rc;
-
-	seg1->rl_mw->r.frmr.fr_state = FRMR_IS_INVALID;
-
-	memset(&invalidate_wr, 0, sizeof invalidate_wr);
-	invalidate_wr.wr_id = (unsigned long)(void *)seg1->rl_mw;
-	invalidate_wr.opcode = IB_WR_LOCAL_INV;
-	invalidate_wr.ex.invalidate_rkey = seg1->rl_mw->r.frmr.fr_mr->rkey;
-	DECR_CQCOUNT(&r_xprt->rx_ep);
-
-	read_lock(&ia->ri_qplock);
-	while (seg1->mr_nsegs--)
-		rpcrdma_unmap_one(ia, seg++);
-	rc = ib_post_send(ia->ri_id->qp, &invalidate_wr, &bad_wr);
-	read_unlock(&ia->ri_qplock);
-	if (rc) {
-		/* Force rpcrdma_buffer_get() to retry */
-		seg1->rl_mw->r.frmr.fr_state = FRMR_IS_STALE;
-		dprintk("RPC:       %s: failed ib_post_send for invalidate,"
-			" status %i\n", __func__, rc);
-	}
-	return rc;
-}
-
-static int
-rpcrdma_deregister_fmr_external(struct rpcrdma_mr_seg *seg,
-			struct rpcrdma_ia *ia)
-{
-	struct rpcrdma_mr_seg *seg1 = seg;
-	LIST_HEAD(l);
-	int rc;
-
-	list_add(&seg1->rl_mw->r.fmr->list, &l);
-	rc = ib_unmap_fmr(&l);
-	read_lock(&ia->ri_qplock);
-	while (seg1->mr_nsegs--)
-		rpcrdma_unmap_one(ia, seg++);
-	read_unlock(&ia->ri_qplock);
-	if (rc)
-		dprintk("RPC:       %s: failed ib_unmap_fmr,"
-			" status %i\n", __func__, rc);
-	return rc;
-}
-
-int
-rpcrdma_deregister_external(struct rpcrdma_mr_seg *seg,
-		struct rpcrdma_xprt *r_xprt)
-{
-	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
-	int nsegs = seg->mr_nsegs, rc;
-
-	switch (ia->ri_memreg_strategy) {
-
-	case RPCRDMA_ALLPHYSICAL:
-		read_lock(&ia->ri_qplock);
-		rpcrdma_unmap_one(ia, seg);
-		read_unlock(&ia->ri_qplock);
-		break;
-
-	case RPCRDMA_FRMR:
-		rc = rpcrdma_deregister_frmr_external(seg, ia, r_xprt);
-		break;
-
-	case RPCRDMA_MTHCAFMR:
-		rc = rpcrdma_deregister_fmr_external(seg, ia);
-		break;
-
-	default:
-		break;
-	}
-	return nsegs;
-}
-
 /*
  * Prepost any receive buffer, then post send.
  *
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 7bf077b..9a727f9 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -338,6 +338,8 @@ struct rpcrdma_xprt;
 struct rpcrdma_memreg_ops {
 	int		(*ro_map)(struct rpcrdma_xprt *,
 				  struct rpcrdma_mr_seg *, int, bool);
+	int		(*ro_unmap)(struct rpcrdma_xprt *,
+				    struct rpcrdma_mr_seg *);
 	size_t		(*ro_maxpages)(struct rpcrdma_xprt *);
 	const char	*ro_displayname;
 };
@@ -405,9 +407,6 @@ void rpcrdma_buffer_put(struct rpcrdma_req *);
 void rpcrdma_recv_buffer_get(struct rpcrdma_req *);
 void rpcrdma_recv_buffer_put(struct rpcrdma_rep *);
 
-int rpcrdma_deregister_external(struct rpcrdma_mr_seg *,
-				struct rpcrdma_xprt *);
-
 struct rpcrdma_regbuf *rpcrdma_alloc_regbuf(struct rpcrdma_ia *,
 					    size_t, gfp_t);
 void rpcrdma_free_regbuf(struct rpcrdma_ia *,


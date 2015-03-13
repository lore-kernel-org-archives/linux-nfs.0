Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:33809 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752663AbbCMVWX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Mar 2015 17:22:23 -0400
Received: by iecsl2 with SMTP id sl2so126640904iec.1
        for <linux-nfs@vger.kernel.org>; Fri, 13 Mar 2015 14:22:22 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id s17sm2028049igr.2.2015.03.13.14.22.14
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 14:22:15 -0700 (PDT)
Subject: [PATCH v1 06/16] xprtrdma: Add a "deregister_external" op for each
 memreg mode
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Fri, 13 Mar 2015 17:22:14 -0400
Message-ID: <20150313212214.22471.33013.stgit@manet.1015granger.net>
In-Reply-To: <20150313211124.22471.14517.stgit@manet.1015granger.net>
References: <20150313211124.22471.14517.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is very little common processing among the different external
memory deregistration functions.

In addition, instead of calling the deregistration function for each
segment, have one call release all segments for a request. This makes
the API a little asymmetrical, but a hair faster.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c      |   37 ++++++++++++++++
 net/sunrpc/xprtrdma/frwr_ops.c     |   46 ++++++++++++++++++++
 net/sunrpc/xprtrdma/physical_ops.c |   13 ++++++
 net/sunrpc/xprtrdma/rpc_rdma.c     |    7 +--
 net/sunrpc/xprtrdma/transport.c    |    8 +---
 net/sunrpc/xprtrdma/verbs.c        |   81 ------------------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h    |    5 +-
 7 files changed, 103 insertions(+), 94 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 45fb646..9b983b4 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -20,6 +20,32 @@
 /* Maximum scatter/gather per FMR */
 #define RPCRDMA_MAX_FMR_SGES	(64)
 
+/* Use the ib_unmap_fmr() verb to prevent further remote
+ * access via RDMA READ or RDMA WRITE.
+ */
+static int
+__fmr_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
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
 /* FMR mode conveys up to 64 pages of payload per chunk segment.
  */
 static size_t
@@ -79,8 +105,19 @@ out_maperr:
 	return rc;
 }
 
+static void
+fmr_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
+	     unsigned int count)
+{
+	unsigned int i;
+
+	for (i = 0; count--;)
+		i += __fmr_unmap(r_xprt, &req->rl_segments[i]);
+}
+
 const struct rpcrdma_memreg_ops rpcrdma_fmr_memreg_ops = {
 	.ro_map				= fmr_op_map,
+	.ro_unmap			= fmr_op_unmap,
 	.ro_maxpages			= fmr_op_maxpages,
 	.ro_displayname			= "fmr",
 };
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 2b5ccb0..05b5761 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -17,6 +17,41 @@
 # define RPCDBG_FACILITY	RPCDBG_TRANS
 #endif
 
+/* Post a LOCAL_INV Work Request to prevent further remote access
+ * via RDMA READ or RDMA WRITE.
+ */
+static int
+__frwr_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
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
 /* FRWR mode conveys a list of pages per chunk segment. The
  * maximum length of that list is the FRWR page list depth.
  */
@@ -116,8 +151,19 @@ out_err:
 	return rc;
 }
 
+static void
+frwr_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
+	      unsigned int count)
+{
+	unsigned int i;
+
+	for (i = 0; count--;)
+		i += __frwr_unmap(r_xprt, &req->rl_segments[i]);
+}
+
 const struct rpcrdma_memreg_ops rpcrdma_frwr_memreg_ops = {
 	.ro_map				= frwr_op_map,
+	.ro_unmap			= frwr_op_unmap,
 	.ro_maxpages			= frwr_op_maxpages,
 	.ro_displayname			= "frwr",
 };
diff --git a/net/sunrpc/xprtrdma/physical_ops.c b/net/sunrpc/xprtrdma/physical_ops.c
index 5a284ee..f2c15be 100644
--- a/net/sunrpc/xprtrdma/physical_ops.c
+++ b/net/sunrpc/xprtrdma/physical_ops.c
@@ -44,8 +44,21 @@ physical_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	return 1;
 }
 
+/* Unmap a memory region, but leave it registered.
+ */
+static void
+physical_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
+		  unsigned int count)
+{
+	unsigned int i;
+
+	for (i = 0; i < count; i++)
+		rpcrdma_unmap_one(&r_xprt->rx_ia, &req->rl_segments[i]);
+}
+
 const struct rpcrdma_memreg_ops rpcrdma_physical_memreg_ops = {
 	.ro_map				= physical_op_map,
+	.ro_unmap			= physical_op_unmap,
 	.ro_maxpages			= physical_op_maxpages,
 	.ro_displayname			= "physical",
 };
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 6ab1d03..7b51d9d 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -284,11 +284,8 @@ rpcrdma_create_chunks(struct rpc_rqst *rqst, struct xdr_buf *target,
 	return (unsigned char *)iptr - (unsigned char *)headerp;
 
 out:
-	if (r_xprt->rx_ia.ri_memreg_strategy != RPCRDMA_FRMR) {
-		for (pos = 0; nchunks--;)
-			pos += rpcrdma_deregister_external(
-					&req->rl_segments[pos], r_xprt);
-	}
+	if (r_xprt->rx_ia.ri_memreg_strategy != RPCRDMA_FRMR)
+		r_xprt->rx_ia.ri_ops->ro_unmap(r_xprt, req, nchunks);
 	return n;
 }
 
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 9a9da40..c484671 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -571,7 +571,6 @@ xprt_rdma_free(void *buffer)
 	struct rpcrdma_req *req;
 	struct rpcrdma_xprt *r_xprt;
 	struct rpcrdma_regbuf *rb;
-	int i;
 
 	if (buffer == NULL)
 		return;
@@ -582,11 +581,8 @@ xprt_rdma_free(void *buffer)
 
 	dprintk("RPC:       %s: called on 0x%p\n", __func__, req->rl_reply);
 
-	for (i = 0; req->rl_nchunks;) {
-		--req->rl_nchunks;
-		i += rpcrdma_deregister_external(
-			&req->rl_segments[i], r_xprt);
-	}
+	r_xprt->rx_ia.ri_ops->ro_unmap(r_xprt, req, req->rl_nchunks);
+	req->rl_nchunks = 0;
 
 	rpcrdma_buffer_put(req);
 }
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 851ed97..a1621fd 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1509,7 +1509,7 @@ rpcrdma_buffer_put_sendbuf(struct rpcrdma_req *req, struct rpcrdma_buffer *buf)
 	}
 }
 
-/* rpcrdma_unmap_one() was already done by rpcrdma_deregister_frmr_external().
+/* rpcrdma_unmap_one() was already done during deregistration.
  * Redo only the ib_post_send().
  */
 static void
@@ -1889,85 +1889,6 @@ rpcrdma_unmap_one(struct rpcrdma_ia *ia, struct rpcrdma_mr_seg *seg)
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
index 7bf077b..3aabbb2 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -338,6 +338,8 @@ struct rpcrdma_xprt;
 struct rpcrdma_memreg_ops {
 	int		(*ro_map)(struct rpcrdma_xprt *,
 				  struct rpcrdma_mr_seg *, int, bool);
+	void		(*ro_unmap)(struct rpcrdma_xprt *,
+				    struct rpcrdma_req *, unsigned int);
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


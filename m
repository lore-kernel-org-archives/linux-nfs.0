Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:36749 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754575AbbEKSD0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 May 2015 14:03:26 -0400
Subject: [PATCH v2 07/16] xprtrdma: Acquire FMRs in
 rpcrdma_fmr_register_external()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 11 May 2015 14:03:23 -0400
Message-ID: <20150511180323.31263.6279.stgit@manet.1015granger.net>
In-Reply-To: <20150511174401.31263.79596.stgit@manet.1015granger.net>
References: <20150511174401.31263.79596.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Acquiring 64 FMRs in rpcrdma_buffer_get() while holding the buffer
pool lock is expensive, and unnecessary because FMR mode can
transfer up to a 1MB payload using just a single ib_fmr.

Instead, acquire ib_fmrs one-at-a-time as chunks are registered, and
return them to rb_mws immediately during deregistration.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Steve Wise <swise@opengridcomputing.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c |   52 ++++++++++++++++++++++++++++++++++++++---
 net/sunrpc/xprtrdma/verbs.c   |   26 ---------------------
 2 files changed, 48 insertions(+), 30 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 0a96155..53fb649 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -11,6 +11,21 @@
  * can take tens of usecs to complete.
  */
 
+/* Normal operation
+ *
+ * A Memory Region is prepared for RDMA READ or WRITE using the
+ * ib_map_phys_fmr verb (fmr_op_map). When the RDMA operation is
+ * finished, the Memory Region is unmapped using the ib_unmap_fmr
+ * verb (fmr_op_unmap).
+ */
+
+/* Transport recovery
+ *
+ * After a transport reconnect, fmr_op_map re-uses the MR already
+ * allocated for the RPC, but generates a fresh rkey then maps the
+ * MR again. This process is synchronous.
+ */
+
 #include "xprt_rdma.h"
 
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
@@ -77,6 +92,15 @@ out_fmr_err:
 	return rc;
 }
 
+static int
+__fmr_unmap(struct rpcrdma_mw *r)
+{
+	LIST_HEAD(l);
+
+	list_add(&r->r.fmr->list, &l);
+	return ib_unmap_fmr(&l);
+}
+
 /* Use the ib_map_phys_fmr() verb to register a memory region
  * for remote access via RDMA READ or RDMA WRITE.
  */
@@ -88,9 +112,22 @@ fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	struct ib_device *device = ia->ri_device;
 	enum dma_data_direction direction = rpcrdma_data_dir(writing);
 	struct rpcrdma_mr_seg *seg1 = seg;
-	struct rpcrdma_mw *mw = seg1->rl_mw;
 	u64 physaddrs[RPCRDMA_MAX_DATA_SEGS];
 	int len, pageoff, i, rc;
+	struct rpcrdma_mw *mw;
+
+	mw = seg1->rl_mw;
+	seg1->rl_mw = NULL;
+	if (!mw) {
+		mw = rpcrdma_get_mw(r_xprt);
+		if (!mw)
+			return -ENOMEM;
+	} else {
+		/* this is a retransmit; generate a fresh rkey */
+		rc = __fmr_unmap(mw);
+		if (rc)
+			return rc;
+	}
 
 	pageoff = offset_in_page(seg1->mr_offset);
 	seg1->mr_offset -= pageoff;	/* start of page */
@@ -114,6 +151,7 @@ fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	if (rc)
 		goto out_maperr;
 
+	seg1->rl_mw = mw;
 	seg1->mr_rkey = mw->r.fmr->rkey;
 	seg1->mr_base = seg1->mr_dma + pageoff;
 	seg1->mr_nsegs = i;
@@ -137,18 +175,24 @@ fmr_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
 {
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	struct rpcrdma_mr_seg *seg1 = seg;
+	struct rpcrdma_mw *mw = seg1->rl_mw;
 	int rc, nsegs = seg->mr_nsegs;
-	LIST_HEAD(l);
 
-	list_add(&seg1->rl_mw->r.fmr->list, &l);
-	rc = ib_unmap_fmr(&l);
+	dprintk("RPC:       %s: FMR %p\n", __func__, mw);
+
+	seg1->rl_mw = NULL;
 	while (seg1->mr_nsegs--)
 		rpcrdma_unmap_one(ia->ri_device, seg++);
+	rc = __fmr_unmap(mw);
 	if (rc)
 		goto out_err;
+	rpcrdma_put_mw(r_xprt, mw);
 	return nsegs;
 
 out_err:
+	/* The FMR is abandoned, but remains in rb_all. fmr_op_destroy
+	 * will attempt to release it when the transport is destroyed.
+	 */
 	dprintk("RPC:       %s: ib_unmap_fmr status %i\n", __func__, rc);
 	return nsegs;
 }
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index b7ca73e..3188e36 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1324,28 +1324,6 @@ rpcrdma_buffer_get_frmrs(struct rpcrdma_req *req, struct rpcrdma_buffer *buf,
 	return NULL;
 }
 
-static struct rpcrdma_req *
-rpcrdma_buffer_get_fmrs(struct rpcrdma_req *req, struct rpcrdma_buffer *buf)
-{
-	struct rpcrdma_mw *r;
-	int i;
-
-	i = RPCRDMA_MAX_SEGS - 1;
-	while (!list_empty(&buf->rb_mws)) {
-		r = list_entry(buf->rb_mws.next,
-			       struct rpcrdma_mw, mw_list);
-		list_del(&r->mw_list);
-		req->rl_segments[i].rl_mw = r;
-		if (unlikely(i-- == 0))
-			return req;	/* Success */
-	}
-
-	/* Not enough entries on rb_mws for this req */
-	rpcrdma_buffer_put_sendbuf(req, buf);
-	rpcrdma_buffer_put_mrs(req, buf);
-	return NULL;
-}
-
 /*
  * Get a set of request/reply buffers.
  *
@@ -1387,9 +1365,6 @@ rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
 	case RPCRDMA_FRMR:
 		req = rpcrdma_buffer_get_frmrs(req, buffers, &stale);
 		break;
-	case RPCRDMA_MTHCAFMR:
-		req = rpcrdma_buffer_get_fmrs(req, buffers);
-		break;
 	default:
 		break;
 	}
@@ -1414,7 +1389,6 @@ rpcrdma_buffer_put(struct rpcrdma_req *req)
 	rpcrdma_buffer_put_sendbuf(req, buffers);
 	switch (ia->ri_memreg_strategy) {
 	case RPCRDMA_FRMR:
-	case RPCRDMA_MTHCAFMR:
 		rpcrdma_buffer_put_mrs(req, buffers);
 		break;
 	default:


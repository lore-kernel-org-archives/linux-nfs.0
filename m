Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:35183 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752933AbbC3Sf3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2015 14:35:29 -0400
Subject: [PATCH v3 13/15] xprtrdma: Add "open" memreg op
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 30 Mar 2015 14:35:26 -0400
Message-ID: <20150330183526.7856.76975.stgit@manet.1015granger.net>
In-Reply-To: <20150330182615.7856.61170.stgit@manet.1015granger.net>
References: <20150330182615.7856.61170.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The open op determines the size of various transport data structures
based on device capabilities and memory registration mode.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Devesh Sharma <Devesh.Sharma@Emulex.Com>
Tested-by: Meghana Cheripady <Meghana.Cheripady@Emulex.Com>
Tested-by: Veeresh U. Kokatnur <veereshuk@chelsio.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c      |    8 ++++++
 net/sunrpc/xprtrdma/frwr_ops.c     |   48 +++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/physical_ops.c |    8 ++++++
 net/sunrpc/xprtrdma/verbs.c        |   49 ++----------------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h    |    3 ++
 5 files changed, 70 insertions(+), 46 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index e9ca594..e8a9837 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -20,6 +20,13 @@
 /* Maximum scatter/gather per FMR */
 #define RPCRDMA_MAX_FMR_SGES	(64)
 
+static int
+fmr_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
+	    struct rpcrdma_create_data_internal *cdata)
+{
+	return 0;
+}
+
 /* FMR mode conveys up to 64 pages of payload per chunk segment.
  */
 static size_t
@@ -188,6 +195,7 @@ fmr_op_destroy(struct rpcrdma_buffer *buf)
 const struct rpcrdma_memreg_ops rpcrdma_fmr_memreg_ops = {
 	.ro_map				= fmr_op_map,
 	.ro_unmap			= fmr_op_unmap,
+	.ro_open			= fmr_op_open,
 	.ro_maxpages			= fmr_op_maxpages,
 	.ro_init			= fmr_op_init,
 	.ro_reset			= fmr_op_reset,
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 121e400..e17d54d 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -58,6 +58,53 @@ __frwr_release(struct rpcrdma_mw *r)
 	ib_free_fast_reg_page_list(r->r.frmr.fr_pgl);
 }
 
+static int
+frwr_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
+	     struct rpcrdma_create_data_internal *cdata)
+{
+	struct ib_device_attr *devattr = &ia->ri_devattr;
+	int depth, delta;
+
+	ia->ri_max_frmr_depth =
+			min_t(unsigned int, RPCRDMA_MAX_DATA_SEGS,
+			      devattr->max_fast_reg_page_list_len);
+	dprintk("RPC:       %s: device's max FR page list len = %u\n",
+		__func__, ia->ri_max_frmr_depth);
+
+	/* Add room for frmr register and invalidate WRs.
+	 * 1. FRMR reg WR for head
+	 * 2. FRMR invalidate WR for head
+	 * 3. N FRMR reg WRs for pagelist
+	 * 4. N FRMR invalidate WRs for pagelist
+	 * 5. FRMR reg WR for tail
+	 * 6. FRMR invalidate WR for tail
+	 * 7. The RDMA_SEND WR
+	 */
+	depth = 7;
+
+	/* Calculate N if the device max FRMR depth is smaller than
+	 * RPCRDMA_MAX_DATA_SEGS.
+	 */
+	if (ia->ri_max_frmr_depth < RPCRDMA_MAX_DATA_SEGS) {
+		delta = RPCRDMA_MAX_DATA_SEGS - ia->ri_max_frmr_depth;
+		do {
+			depth += 2; /* FRMR reg + invalidate */
+			delta -= ia->ri_max_frmr_depth;
+		} while (delta > 0);
+	}
+
+	ep->rep_attr.cap.max_send_wr *= depth;
+	if (ep->rep_attr.cap.max_send_wr > devattr->max_qp_wr) {
+		cdata->max_requests = devattr->max_qp_wr / depth;
+		if (!cdata->max_requests)
+			return -EINVAL;
+		ep->rep_attr.cap.max_send_wr = cdata->max_requests *
+					       depth;
+	}
+
+	return 0;
+}
+
 /* FRWR mode conveys a list of pages per chunk segment. The
  * maximum length of that list is the FRWR page list depth.
  */
@@ -276,6 +323,7 @@ frwr_op_destroy(struct rpcrdma_buffer *buf)
 const struct rpcrdma_memreg_ops rpcrdma_frwr_memreg_ops = {
 	.ro_map				= frwr_op_map,
 	.ro_unmap			= frwr_op_unmap,
+	.ro_open			= frwr_op_open,
 	.ro_maxpages			= frwr_op_maxpages,
 	.ro_init			= frwr_op_init,
 	.ro_reset			= frwr_op_reset,
diff --git a/net/sunrpc/xprtrdma/physical_ops.c b/net/sunrpc/xprtrdma/physical_ops.c
index eb39011..0ba130b 100644
--- a/net/sunrpc/xprtrdma/physical_ops.c
+++ b/net/sunrpc/xprtrdma/physical_ops.c
@@ -19,6 +19,13 @@
 # define RPCDBG_FACILITY	RPCDBG_TRANS
 #endif
 
+static int
+physical_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
+		 struct rpcrdma_create_data_internal *cdata)
+{
+	return 0;
+}
+
 /* PHYSICAL memory registration conveys one page per chunk segment.
  */
 static size_t
@@ -72,6 +79,7 @@ physical_op_destroy(struct rpcrdma_buffer *buf)
 const struct rpcrdma_memreg_ops rpcrdma_physical_memreg_ops = {
 	.ro_map				= physical_op_map,
 	.ro_unmap			= physical_op_unmap,
+	.ro_open			= physical_op_open,
 	.ro_maxpages			= physical_op_maxpages,
 	.ro_init			= physical_op_init,
 	.ro_reset			= physical_op_reset,
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index a7fb314..b697b3e 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -622,11 +622,6 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 			dprintk("RPC:       %s: FRMR registration "
 				"not supported by HCA\n", __func__);
 			memreg = RPCRDMA_MTHCAFMR;
-		} else {
-			/* Mind the ia limit on FRMR page list depth */
-			ia->ri_max_frmr_depth = min_t(unsigned int,
-				RPCRDMA_MAX_DATA_SEGS,
-				devattr->max_fast_reg_page_list_len);
 		}
 	}
 	if (memreg == RPCRDMA_MTHCAFMR) {
@@ -741,49 +736,11 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 
 	ep->rep_attr.event_handler = rpcrdma_qp_async_error_upcall;
 	ep->rep_attr.qp_context = ep;
-	/* send_cq and recv_cq initialized below */
 	ep->rep_attr.srq = NULL;
 	ep->rep_attr.cap.max_send_wr = cdata->max_requests;
-	switch (ia->ri_memreg_strategy) {
-	case RPCRDMA_FRMR: {
-		int depth = 7;
-
-		/* Add room for frmr register and invalidate WRs.
-		 * 1. FRMR reg WR for head
-		 * 2. FRMR invalidate WR for head
-		 * 3. N FRMR reg WRs for pagelist
-		 * 4. N FRMR invalidate WRs for pagelist
-		 * 5. FRMR reg WR for tail
-		 * 6. FRMR invalidate WR for tail
-		 * 7. The RDMA_SEND WR
-		 */
-
-		/* Calculate N if the device max FRMR depth is smaller than
-		 * RPCRDMA_MAX_DATA_SEGS.
-		 */
-		if (ia->ri_max_frmr_depth < RPCRDMA_MAX_DATA_SEGS) {
-			int delta = RPCRDMA_MAX_DATA_SEGS -
-				    ia->ri_max_frmr_depth;
-
-			do {
-				depth += 2; /* FRMR reg + invalidate */
-				delta -= ia->ri_max_frmr_depth;
-			} while (delta > 0);
-
-		}
-		ep->rep_attr.cap.max_send_wr *= depth;
-		if (ep->rep_attr.cap.max_send_wr > devattr->max_qp_wr) {
-			cdata->max_requests = devattr->max_qp_wr / depth;
-			if (!cdata->max_requests)
-				return -EINVAL;
-			ep->rep_attr.cap.max_send_wr = cdata->max_requests *
-						       depth;
-		}
-		break;
-	}
-	default:
-		break;
-	}
+	rc = ia->ri_ops->ro_open(ia, ep, cdata);
+	if (rc)
+		return rc;
 	ep->rep_attr.cap.max_recv_wr = cdata->max_requests;
 	ep->rep_attr.cap.max_send_sge = (cdata->padding ? 4 : 2);
 	ep->rep_attr.cap.max_recv_sge = 1;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index b95e223..9036fb4 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -340,6 +340,9 @@ struct rpcrdma_memreg_ops {
 				  struct rpcrdma_mr_seg *, int, bool);
 	int		(*ro_unmap)(struct rpcrdma_xprt *,
 				    struct rpcrdma_mr_seg *);
+	int		(*ro_open)(struct rpcrdma_ia *,
+				   struct rpcrdma_ep *,
+				   struct rpcrdma_create_data_internal *);
 	size_t		(*ro_maxpages)(struct rpcrdma_xprt *);
 	int		(*ro_init)(struct rpcrdma_xprt *);
 	void		(*ro_reset)(struct rpcrdma_xprt *);


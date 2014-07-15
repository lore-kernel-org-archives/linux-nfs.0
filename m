Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:33494 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751527AbaGOOVt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 10:21:49 -0400
Subject: [PATCH v3 11/21] xprtrdma: Reset FRMRs when FAST_REG_MR is flushed
 by a disconnect
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 15 Jul 2014 10:21:46 -0400
Message-ID: <20140715142146.8908.9010.stgit@manet.1015granger.net>
In-Reply-To: <20140715142020.8908.80969.stgit@manet.1015granger.net>
References: <20140715142020.8908.80969.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

FAST_REG_MR Work Requests update a Memory Region's rkey. Rkey's are
used to block unwanted access to the memory controlled by an MR. The
rkey is passed to the receiver (the NFS server, in our case), and is
also used by xprtrdma to invalidate the MR when the RPC is complete.

When a FAST_REG_MR Work Request is flushed after a transport
disconnect, xprtrdma cannot tell whether the WR actually hit the
adapter or not. So it is indeterminant at that point whether the
existing rkey is still valid.

After the transport connection is re-established, the next
FAST_REG_MR or LOCAL_INV Work Request against that MR can sometimes
fail because the rkey value does not match what xprtrdma expects.

The only reliable way to recover in this case is to deregister and
register the MR before it is used again. These operations can be
done only in a process context, so handle it in the transport
connect worker.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Steve Wise <swise@opengridcomputing.com>
---
 net/sunrpc/xprtrdma/verbs.c     |   67 ++++++++++++++++++++++++++++++++++++++-
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
 2 files changed, 66 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index cdea6ff..39b31c8 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -61,6 +61,8 @@
 # define RPCDBG_FACILITY	RPCDBG_TRANS
 #endif
 
+static void rpcrdma_reset_frmrs(struct rpcrdma_ia *);
+
 /*
  * internal functions
  */
@@ -152,8 +154,10 @@ rpcrdma_sendcq_process_wc(struct ib_wc *wc)
 
 	if (wc->wr_id == 0ULL)
 		return;
-	if (wc->status != IB_WC_SUCCESS)
+	if (wc->status != IB_WC_SUCCESS) {
+		frmr->r.frmr.fr_state = FRMR_IS_STALE;
 		return;
+	}
 
 	if (wc->opcode == IB_WC_FAST_REG_MR)
 		frmr->r.frmr.fr_state = FRMR_IS_VALID;
@@ -881,6 +885,9 @@ retry:
 				" status %i\n", __func__, rc);
 		rpcrdma_flush_cqs(ep);
 
+		if (ia->ri_memreg_strategy == RPCRDMA_FRMR)
+			rpcrdma_reset_frmrs(ia);
+
 		xprt = container_of(ia, struct rpcrdma_xprt, rx_ia);
 		id = rpcrdma_create_id(xprt, ia,
 				(struct sockaddr *)&xprt->rx_data.addr);
@@ -1256,6 +1263,62 @@ rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 	kfree(buf->rb_pool);
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
+rpcrdma_reset_frmrs(struct rpcrdma_ia *ia)
+{
+	struct rpcrdma_xprt *r_xprt =
+				container_of(ia, struct rpcrdma_xprt, rx_ia);
+	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
+	struct list_head *pos;
+	struct rpcrdma_mw *r;
+	int rc;
+
+	list_for_each(pos, &buf->rb_all) {
+		r = list_entry(pos, struct rpcrdma_mw, mw_all);
+
+		if (r->r.frmr.fr_state == FRMR_IS_INVALID)
+			continue;
+
+		rc = ib_dereg_mr(r->r.frmr.fr_mr);
+		if (rc)
+			dprintk("RPC:       %s: ib_dereg_mr failed %i\n",
+				__func__, rc);
+		ib_free_fast_reg_page_list(r->r.frmr.fr_pgl);
+
+		r->r.frmr.fr_mr = ib_alloc_fast_reg_mr(ia->ri_pd,
+					ia->ri_max_frmr_depth);
+		if (IS_ERR(r->r.frmr.fr_mr)) {
+			rc = PTR_ERR(r->r.frmr.fr_mr);
+			dprintk("RPC:       %s: ib_alloc_fast_reg_mr"
+				" failed %i\n", __func__, rc);
+			continue;
+		}
+		r->r.frmr.fr_pgl = ib_alloc_fast_reg_page_list(
+					ia->ri_id->device,
+					ia->ri_max_frmr_depth);
+		if (IS_ERR(r->r.frmr.fr_pgl)) {
+			rc = PTR_ERR(r->r.frmr.fr_pgl);
+			dprintk("RPC:       %s: "
+				"ib_alloc_fast_reg_page_list "
+				"failed %i\n", __func__, rc);
+
+			ib_dereg_mr(r->r.frmr.fr_mr);
+			continue;
+		}
+		r->r.frmr.fr_state = FRMR_IS_INVALID;
+	}
+}
+
 /* "*mw" can be NULL when rpcrdma_buffer_get_mrs() fails, leaving
  * some req segments uninitialized.
  */
@@ -1571,7 +1634,7 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	dprintk("RPC:       %s: Using frmr %p to map %d segments\n",
 		__func__, mw, i);
 
-	if (unlikely(frmr->fr_state == FRMR_IS_VALID)) {
+	if (unlikely(frmr->fr_state != FRMR_IS_INVALID)) {
 		dprintk("RPC:       %s: frmr %x left valid, posting invalidate.\n",
 			__func__, mr->rkey);
 		/* Invalidate before using. */
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index c1d8652..1ee6db3 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -161,6 +161,7 @@ struct rpcrdma_rep {
 enum rpcrdma_frmr_state {
 	FRMR_IS_INVALID,	/* ready to be used */
 	FRMR_IS_VALID,		/* in use */
+	FRMR_IS_STALE,		/* failed completion */
 };
 
 struct rpcrdma_frmr {


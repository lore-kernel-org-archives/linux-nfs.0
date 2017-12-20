Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:44380 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756531AbdLTVbP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Dec 2017 16:31:15 -0500
Subject: [PATCH v1 07/12] xprtrdma: Add trace points to instrument memory
 invalidation
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 20 Dec 2017 16:31:12 -0500
Message-ID: <20171220213112.29321.68527.stgit@manet.1015granger.net>
In-Reply-To: <20171220210236.29321.59307.stgit@manet.1015granger.net>
References: <20171220210236.29321.59307.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h |   41 ++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/fmr_ops.c  |    4 ++--
 net/sunrpc/xprtrdma/frwr_ops.c |   27 +++++++++++++-------------
 net/sunrpc/xprtrdma/verbs.c    |    1 +
 4 files changed, 57 insertions(+), 16 deletions(-)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index 8176215..057662b 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -200,6 +200,41 @@
 				),					\
 				TP_ARGS(wc, frwr))
 
+DECLARE_EVENT_CLASS(xprtrdma_mr,
+	TP_PROTO(
+		const struct rpcrdma_mr *mr
+	),
+
+	TP_ARGS(mr),
+
+	TP_STRUCT__entry(
+		__field(const void *, mr)
+		__field(u32, handle)
+		__field(u32, length)
+		__field(u64, offset)
+	),
+
+	TP_fast_assign(
+		__entry->mr = mr;
+		__entry->handle = mr->mr_handle;
+		__entry->length = mr->mr_length;
+		__entry->offset = mr->mr_offset;
+	),
+
+	TP_printk("mr=%p %u@0x%016llx:0x%08x",
+		__entry->mr, __entry->length,
+		(unsigned long long)__entry->offset,
+		__entry->handle
+	)
+);
+
+#define DEFINE_MR_EVENT(name) \
+		DEFINE_EVENT(xprtrdma_mr, name, \
+				TP_PROTO( \
+					const struct rpcrdma_mr *mr \
+				), \
+				TP_ARGS(mr))
+
 /**
  ** Call events
  **/
@@ -381,6 +416,12 @@
 );
 
 DEFINE_FRWR_DONE_EVENT(xprtrdma_wc_fastreg);
+DEFINE_FRWR_DONE_EVENT(xprtrdma_wc_li);
+DEFINE_FRWR_DONE_EVENT(xprtrdma_wc_li_wake);
+
+DEFINE_MR_EVENT(xprtrdma_localinv);
+DEFINE_MR_EVENT(xprtrdma_dma_unmap);
+DEFINE_MR_EVENT(xprtrdma_remoteinv);
 
 /**
  ** Reply events
diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 7f2f2b7..d5f95bb 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -148,6 +148,7 @@ enum {
 	pr_err("rpcrdma: FMR reset failed (%d), %p released\n", rc, mr);
 	r_xprt->rx_stats.mrs_orphaned++;
 
+	trace_xprtrdma_dma_unmap(mr);
 	ib_dma_unmap_sg(r_xprt->rx_ia.ri_device,
 			mr->mr_sg, mr->mr_nents, mr->mr_dir);
 
@@ -273,6 +274,7 @@ enum {
 	list_for_each_entry(mr, mrs, mr_list) {
 		dprintk("RPC:       %s: unmapping fmr %p\n",
 			__func__, &mr->fmr);
+		trace_xprtrdma_localinv(mr);
 		list_add_tail(&mr->fmr.fm_mr->list, &unmap_list);
 	}
 	r_xprt->rx_stats.local_inv_needed++;
@@ -285,8 +287,6 @@ enum {
 	 */
 	while (!list_empty(mrs)) {
 		mr = rpcrdma_mr_pop(mrs);
-		dprintk("RPC:       %s: DMA unmapping fmr %p\n",
-			__func__, &mr->fmr);
 		list_del(&mr->fmr.fm_mr->list);
 		rpcrdma_mr_unmap_and_put(mr);
 	}
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index afbeb9b..90f688f 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -182,9 +182,11 @@
 	int rc;
 
 	rc = __frwr_mr_reset(ia, mr);
-	if (state != FRWR_FLUSHED_LI)
+	if (state != FRWR_FLUSHED_LI) {
+		trace_xprtrdma_dma_unmap(mr);
 		ib_dma_unmap_sg(ia->ri_device,
 				mr->mr_sg, mr->mr_nents, mr->mr_dir);
+	}
 	if (rc)
 		goto out_release;
 
@@ -307,16 +309,16 @@
 static void
 frwr_wc_localinv(struct ib_cq *cq, struct ib_wc *wc)
 {
-	struct rpcrdma_frwr *frwr;
-	struct ib_cqe *cqe;
+	struct ib_cqe *cqe = wc->wr_cqe;
+	struct rpcrdma_frwr *frwr = container_of(cqe, struct rpcrdma_frwr,
+						 fr_cqe);
 
 	/* WARNING: Only wr_cqe and status are reliable at this point */
 	if (wc->status != IB_WC_SUCCESS) {
-		cqe = wc->wr_cqe;
-		frwr = container_of(cqe, struct rpcrdma_frwr, fr_cqe);
 		frwr->fr_state = FRWR_FLUSHED_LI;
 		__frwr_sendcompletion_flush(wc, "localinv");
 	}
+	trace_xprtrdma_wc_li(wc, frwr);
 }
 
 /**
@@ -329,17 +331,17 @@
 static void
 frwr_wc_localinv_wake(struct ib_cq *cq, struct ib_wc *wc)
 {
-	struct rpcrdma_frwr *frwr;
-	struct ib_cqe *cqe;
+	struct ib_cqe *cqe = wc->wr_cqe;
+	struct rpcrdma_frwr *frwr = container_of(cqe, struct rpcrdma_frwr,
+						 fr_cqe);
 
 	/* WARNING: Only wr_cqe and status are reliable at this point */
-	cqe = wc->wr_cqe;
-	frwr = container_of(cqe, struct rpcrdma_frwr, fr_cqe);
 	if (wc->status != IB_WC_SUCCESS) {
 		frwr->fr_state = FRWR_FLUSHED_LI;
 		__frwr_sendcompletion_flush(wc, "localinv");
 	}
 	complete(&frwr->fr_linv_done);
+	trace_xprtrdma_wc_li_wake(wc, frwr);
 }
 
 /* Post a REG_MR Work Request to register a memory region
@@ -457,6 +459,7 @@
 	list_for_each_entry(mr, mrs, mr_list)
 		if (mr->mr_handle == rep->rr_inv_rkey) {
 			list_del(&mr->mr_list);
+			trace_xprtrdma_remoteinv(mr);
 			mr->frwr.fr_state = FRWR_IS_INVALID;
 			rpcrdma_mr_unmap_and_put(mr);
 			break;	/* only one invalidated MR per RPC */
@@ -492,9 +495,7 @@
 		mr->frwr.fr_state = FRWR_IS_INVALID;
 
 		frwr = &mr->frwr;
-
-		dprintk("RPC:       %s: invalidating frwr %p\n",
-			__func__, frwr);
+		trace_xprtrdma_localinv(mr);
 
 		frwr->fr_cqe.done = frwr_wc_localinv;
 		last = &frwr->fr_invwr;
@@ -536,8 +537,6 @@
 unmap:
 	while (!list_empty(mrs)) {
 		mr = rpcrdma_mr_pop(mrs);
-		dprintk("RPC:       %s: DMA unmapping frwr %p\n",
-			__func__, &mr->frwr);
 		rpcrdma_mr_unmap_and_put(mr);
 	}
 	return;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index cfa3c03..0e89e55 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1349,6 +1349,7 @@ struct rpcrdma_mr *
 {
 	struct rpcrdma_xprt *r_xprt = mr->mr_xprt;
 
+	trace_xprtrdma_dma_unmap(mr);
 	ib_dma_unmap_sg(r_xprt->rx_ia.ri_device,
 			mr->mr_sg, mr->mr_nents, mr->mr_dir);
 	__rpcrdma_mr_put(&r_xprt->rx_buf, mr);


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:46558 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756004AbdLTVa6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Dec 2017 16:30:58 -0500
Subject: [PATCH v1 05/12] xprtrdma: Add trace points to instrument memory
 registration
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 20 Dec 2017 16:30:56 -0500
Message-ID: <20171220213056.29321.26333.stgit@manet.1015granger.net>
In-Reply-To: <20171220210236.29321.59307.stgit@manet.1015granger.net>
References: <20171220210236.29321.59307.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h |  156 ++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/frwr_ops.c |   11 +--
 net/sunrpc/xprtrdma/rpc_rdma.c |   18 +----
 3 files changed, 163 insertions(+), 22 deletions(-)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index e11bb32..bc7f2db 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -50,10 +50,164 @@
 				),					\
 				TP_ARGS(rep))
 
+DECLARE_EVENT_CLASS(xprtrdma_rdch_event,
+	TP_PROTO(
+		const struct rpc_task *task,
+		unsigned int pos,
+		struct rpcrdma_mr *mr,
+		int nsegs
+	),
+
+	TP_ARGS(task, pos, mr, nsegs),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
+		__field(const void *, mr)
+		__field(unsigned int, pos)
+		__field(int, nents)
+		__field(u32, handle)
+		__field(u32, length)
+		__field(u64, offset)
+		__field(int, nsegs)
+	),
+
+	TP_fast_assign(
+		__entry->task_id = task->tk_pid;
+		__entry->client_id = task->tk_client->cl_clid;
+		__entry->mr = mr;
+		__entry->pos = pos;
+		__entry->nents = mr->mr_nents;
+		__entry->handle = mr->mr_handle;
+		__entry->length = mr->mr_length;
+		__entry->offset = mr->mr_offset;
+		__entry->nsegs = nsegs;
+	),
+
+	TP_printk("task:%u@%u mr=%p pos=%u %u@0x%016llx:0x%08x (%s)",
+		__entry->task_id, __entry->client_id, __entry->mr,
+		__entry->pos, __entry->length,
+		(unsigned long long)__entry->offset, __entry->handle,
+		__entry->nents < __entry->nsegs ? "more" : "last"
+	)
+);
+
+#define DEFINE_RDCH_EVENT(name)						\
+		DEFINE_EVENT(xprtrdma_rdch_event, name,			\
+				TP_PROTO(				\
+					const struct rpc_task *task,	\
+					unsigned int pos,		\
+					struct rpcrdma_mr *mr,		\
+					int nsegs			\
+				),					\
+				TP_ARGS(task, pos, mr, nsegs))
+
+DECLARE_EVENT_CLASS(xprtrdma_wrch_event,
+	TP_PROTO(
+		const struct rpc_task *task,
+		struct rpcrdma_mr *mr,
+		int nsegs
+	),
+
+	TP_ARGS(task, mr, nsegs),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
+		__field(const void *, mr)
+		__field(int, nents)
+		__field(u32, handle)
+		__field(u32, length)
+		__field(u64, offset)
+		__field(int, nsegs)
+	),
+
+	TP_fast_assign(
+		__entry->task_id = task->tk_pid;
+		__entry->client_id = task->tk_client->cl_clid;
+		__entry->mr = mr;
+		__entry->nents = mr->mr_nents;
+		__entry->handle = mr->mr_handle;
+		__entry->length = mr->mr_length;
+		__entry->offset = mr->mr_offset;
+		__entry->nsegs = nsegs;
+	),
+
+	TP_printk("task:%u@%u mr=%p %u@0x%016llx:0x%08x (%s)",
+		__entry->task_id, __entry->client_id, __entry->mr,
+		__entry->length, (unsigned long long)__entry->offset,
+		__entry->handle,
+		__entry->nents < __entry->nsegs ? "more" : "last"
+	)
+);
+
+#define DEFINE_WRCH_EVENT(name)						\
+		DEFINE_EVENT(xprtrdma_wrch_event, name,			\
+				TP_PROTO(				\
+					const struct rpc_task *task,	\
+					struct rpcrdma_mr *mr,		\
+					int nsegs			\
+				),					\
+				TP_ARGS(task, mr, nsegs))
+
+TRACE_DEFINE_ENUM(FRWR_IS_INVALID);
+TRACE_DEFINE_ENUM(FRWR_IS_VALID);
+TRACE_DEFINE_ENUM(FRWR_FLUSHED_FR);
+TRACE_DEFINE_ENUM(FRWR_FLUSHED_LI);
+
+#define xprtrdma_show_frwr_state(x)					\
+		__print_symbolic(x,					\
+				{ FRWR_IS_INVALID, "INVALID" },		\
+				{ FRWR_IS_VALID, "VALID" },		\
+				{ FRWR_FLUSHED_FR, "FLUSHED_FR" },	\
+				{ FRWR_FLUSHED_LI, "FLUSHED_LI" })
+
+DECLARE_EVENT_CLASS(xprtrdma_frwr_done,
+	TP_PROTO(
+		const struct ib_wc *wc,
+		const struct rpcrdma_frwr *frwr
+	),
+
+	TP_ARGS(wc, frwr),
+
+	TP_STRUCT__entry(
+		__field(const void *, mr)
+		__field(unsigned int, state)
+		__field(unsigned int, status)
+		__field(unsigned int, vendor_err)
+	),
+
+	TP_fast_assign(
+		__entry->mr = container_of(frwr, struct rpcrdma_mr, frwr);
+		__entry->state = frwr->fr_state;
+		__entry->status = wc->status;
+		__entry->vendor_err = __entry->status ? wc->vendor_err : 0;
+	),
+
+	TP_printk(
+		"mr=%p state=%s: %s (%u/0x%x)",
+		__entry->mr, xprtrdma_show_frwr_state(__entry->state),
+		rdma_show_wc_status(__entry->status),
+		__entry->status, __entry->vendor_err
+	)
+);
+
+#define DEFINE_FRWR_DONE_EVENT(name)					\
+		DEFINE_EVENT(xprtrdma_frwr_done, name,			\
+				TP_PROTO(				\
+					const struct ib_wc *wc,		\
+					const struct rpcrdma_frwr *frwr	\
+				),					\
+				TP_ARGS(wc, frwr))
+
 /**
  ** Call events
  **/
 
+DEFINE_RDCH_EVENT(xprtrdma_read_chunk);
+DEFINE_WRCH_EVENT(xprtrdma_write_chunk);
+DEFINE_WRCH_EVENT(xprtrdma_reply_chunk);
+
 TRACE_DEFINE_ENUM(rpcrdma_noch);
 TRACE_DEFINE_ENUM(rpcrdma_readch);
 TRACE_DEFINE_ENUM(rpcrdma_areadch);
@@ -226,6 +380,8 @@
 	)
 );
 
+DEFINE_FRWR_DONE_EVENT(xprtrdma_wc_fastreg);
+
 /**
  ** Reply events
  **/
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 35e3a54..afbeb9b 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -286,16 +286,16 @@
 static void
 frwr_wc_fastreg(struct ib_cq *cq, struct ib_wc *wc)
 {
-	struct rpcrdma_frwr *frwr;
-	struct ib_cqe *cqe;
+	struct ib_cqe *cqe = wc->wr_cqe;
+	struct rpcrdma_frwr *frwr =
+			container_of(cqe, struct rpcrdma_frwr, fr_cqe);
 
 	/* WARNING: Only wr_cqe and status are reliable at this point */
 	if (wc->status != IB_WC_SUCCESS) {
-		cqe = wc->wr_cqe;
-		frwr = container_of(cqe, struct rpcrdma_frwr, fr_cqe);
 		frwr->fr_state = FRWR_FLUSHED_FR;
 		__frwr_sendcompletion_flush(wc, "fastreg");
 	}
+	trace_xprtrdma_wc_fastreg(wc, frwr);
 }
 
 /**
@@ -401,9 +401,6 @@
 	if (unlikely(n != mr->mr_nents))
 		goto out_mapmr_err;
 
-	dprintk("RPC:       %s: Using frwr %p to map %u segments (%llu bytes)\n",
-		__func__, frwr, mr->mr_nents, ibmr->length);
-
 	key = (u8)(ibmr->rkey & 0x000000FF);
 	ib_update_fast_reg_key(ibmr, ++key);
 
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 6f774f1e4..634496c 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -371,11 +371,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		if (encode_read_segment(xdr, mr, pos) < 0)
 			return -EMSGSIZE;
 
-		dprintk("RPC: %5u %s: pos %u %u@0x%016llx:0x%08x (%s)\n",
-			rqst->rq_task->tk_pid, __func__, pos,
-			mr->mr_length, (unsigned long long)mr->mr_offset,
-			mr->mr_handle, mr->mr_nents < nsegs ? "more" : "last");
-
+		trace_xprtrdma_read_chunk(rqst->rq_task, pos, mr, nsegs);
 		r_xprt->rx_stats.read_chunk_count++;
 		nsegs -= mr->mr_nents;
 	} while (nsegs);
@@ -433,11 +429,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		if (encode_rdma_segment(xdr, mr) < 0)
 			return -EMSGSIZE;
 
-		dprintk("RPC: %5u %s: %u@0x016%llx:0x%08x (%s)\n",
-			rqst->rq_task->tk_pid, __func__,
-			mr->mr_length, (unsigned long long)mr->mr_offset,
-			mr->mr_handle, mr->mr_nents < nsegs ? "more" : "last");
-
+		trace_xprtrdma_write_chunk(rqst->rq_task, mr, nsegs);
 		r_xprt->rx_stats.write_chunk_count++;
 		r_xprt->rx_stats.total_rdma_request += seg->mr_len;
 		nchunks++;
@@ -495,11 +487,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		if (encode_rdma_segment(xdr, mr) < 0)
 			return -EMSGSIZE;
 
-		dprintk("RPC: %5u %s: %u@0x%016llx:0x%08x (%s)\n",
-			rqst->rq_task->tk_pid, __func__,
-			mr->mr_length, (unsigned long long)mr->mr_offset,
-			mr->mr_handle, mr->mr_nents < nsegs ? "more" : "last");
-
+		trace_xprtrdma_reply_chunk(rqst->rq_task, mr, nsegs);
 		r_xprt->rx_stats.reply_chunk_count++;
 		r_xprt->rx_stats.total_rdma_request += seg->mr_len;
 		nchunks++;


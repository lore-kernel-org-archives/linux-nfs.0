Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35393 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755838AbdLTVam (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Dec 2017 16:30:42 -0500
Subject: [PATCH v1 03/12] xprtrdma: Add trace points in RPC Call transmit
 paths
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 20 Dec 2017 16:30:40 -0500
Message-ID: <20171220213040.29321.939.stgit@manet.1015granger.net>
In-Reply-To: <20171220210236.29321.59307.stgit@manet.1015granger.net>
References: <20171220210236.29321.59307.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h |  124 ++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/rpc_rdma.c |    8 ---
 net/sunrpc/xprtrdma/verbs.c    |   12 +---
 3 files changed, 129 insertions(+), 15 deletions(-)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index e7ca063..8efb2c9 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -10,6 +10,130 @@
 #include <linux/tracepoint.h>
 #include <trace/events/rdma.h>
 
+/**
+ ** Call events
+ **/
+
+TRACE_DEFINE_ENUM(rpcrdma_noch);
+TRACE_DEFINE_ENUM(rpcrdma_readch);
+TRACE_DEFINE_ENUM(rpcrdma_areadch);
+TRACE_DEFINE_ENUM(rpcrdma_writech);
+TRACE_DEFINE_ENUM(rpcrdma_replych);
+
+#define xprtrdma_show_chunktype(x)					\
+		__print_symbolic(x,					\
+				{ rpcrdma_noch, "inline" },		\
+				{ rpcrdma_readch, "read list" },	\
+				{ rpcrdma_areadch, "*read list" },	\
+				{ rpcrdma_writech, "write list" },	\
+				{ rpcrdma_replych, "reply chunk" })
+
+TRACE_EVENT(xprtrdma_marshal,
+	TP_PROTO(
+		const struct rpc_rqst *rqst,
+		unsigned int hdrlen,
+		unsigned int rtype,
+		unsigned int wtype
+	),
+
+	TP_ARGS(rqst, hdrlen, rtype, wtype),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
+		__field(u32, xid)
+		__field(unsigned int, hdrlen)
+		__field(unsigned int, headlen)
+		__field(unsigned int, pagelen)
+		__field(unsigned int, taillen)
+		__field(unsigned int, rtype)
+		__field(unsigned int, wtype)
+	),
+
+	TP_fast_assign(
+		__entry->task_id = rqst->rq_task->tk_pid;
+		__entry->client_id = rqst->rq_task->tk_client->cl_clid;
+		__entry->xid = be32_to_cpu(rqst->rq_xid);
+		__entry->hdrlen = hdrlen;
+		__entry->headlen = rqst->rq_snd_buf.head[0].iov_len;
+		__entry->pagelen = rqst->rq_snd_buf.page_len;
+		__entry->taillen = rqst->rq_snd_buf.tail[0].iov_len;
+		__entry->rtype = rtype;
+		__entry->wtype = wtype;
+	),
+
+	TP_printk("task:%u@%u xid=0x%08x: hdr=%u xdr=%u/%u/%u %s/%s",
+		__entry->task_id, __entry->client_id, __entry->xid,
+		__entry->hdrlen,
+		__entry->headlen, __entry->pagelen, __entry->taillen,
+		xprtrdma_show_chunktype(__entry->rtype),
+		xprtrdma_show_chunktype(__entry->wtype)
+	)
+);
+
+TRACE_EVENT(xprtrdma_post_send,
+	TP_PROTO(
+		const struct rpcrdma_req *req,
+		int status
+	),
+
+	TP_ARGS(req, status),
+
+	TP_STRUCT__entry(
+		__field(const void *, req)
+		__field(int, num_sge)
+		__field(bool, signaled)
+		__field(int, status)
+	),
+
+	TP_fast_assign(
+		__entry->req = req;
+		__entry->num_sge = req->rl_sendctx->sc_wr.num_sge;
+		__entry->signaled = req->rl_sendctx->sc_wr.send_flags &
+				    IB_SEND_SIGNALED;
+		__entry->status = status;
+	),
+
+	TP_printk("req=%p, %d SGEs%s, status=%d",
+		__entry->req, __entry->num_sge,
+		(__entry->signaled ? ", signaled" : ""),
+		__entry->status
+	)
+);
+
+/**
+ ** Completion events
+ **/
+
+TRACE_EVENT(xprtrdma_wc_send,
+	TP_PROTO(
+		const struct rpcrdma_sendctx *sc,
+		const struct ib_wc *wc
+	),
+
+	TP_ARGS(sc, wc),
+
+	TP_STRUCT__entry(
+		__field(const void *, req)
+		__field(unsigned int, unmap_count)
+		__field(unsigned int, status)
+		__field(unsigned int, vendor_err)
+	),
+
+	TP_fast_assign(
+		__entry->req = sc->sc_req;
+		__entry->unmap_count = sc->sc_unmap_count;
+		__entry->status = wc->status;
+		__entry->vendor_err = __entry->status ? wc->vendor_err : 0;
+	),
+
+	TP_printk("req=%p, unmapped %u pages: %s (%u/0x%x)",
+		__entry->req, __entry->unmap_count,
+		rdma_show_wc_status(__entry->status),
+		__entry->status, __entry->vendor_err
+	)
+);
+
 #endif /* _TRACE_RPCRDMA_H */
 
 #include <trace/define_trace.h>
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 9601af0..162c0fd 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -524,9 +524,6 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	struct ib_sge *sge;
 	unsigned int count;
 
-	dprintk("RPC:       %s: unmapping %u sges for sc=%p\n",
-		__func__, sc->sc_unmap_count, sc);
-
 	/* The first two SGEs contain the transport header and
 	 * the inline buffer. These are always left mapped so
 	 * they can be cheaply re-used.
@@ -874,10 +871,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	if (ret)
 		goto out_err;
 
-	dprintk("RPC: %5u %s: %s/%s: hdrlen %u rpclen\n",
-		rqst->rq_task->tk_pid, __func__,
-		transfertypes[rtype], transfertypes[wtype],
-		xdr_stream_pos(xdr));
+	trace_xprtrdma_marshal(rqst, xdr_stream_pos(xdr), rtype, wtype);
 
 	ret = rpcrdma_prepare_send_sges(r_xprt, req, xdr_stream_pos(xdr),
 					&rqst->rq_snd_buf, rtype);
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 9cc8abc..06d86b8 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -133,6 +133,7 @@
 		container_of(cqe, struct rpcrdma_sendctx, sc_cqe);
 
 	/* WARNING: Only wr_cqe and status are reliable at this point */
+	trace_xprtrdma_wc_send(sc, wc);
 	if (wc->status != IB_WC_SUCCESS && wc->status != IB_WC_WR_FLUSH_ERR)
 		pr_err("rpcrdma: Send: %s (%u/0x%x)\n",
 		       ib_wc_status_msg(wc->status),
@@ -1549,9 +1550,6 @@ struct rpcrdma_regbuf *
 		req->rl_reply = NULL;
 	}
 
-	dprintk("RPC:       %s: posting %d s/g entries\n",
-		__func__, send_wr->num_sge);
-
 	if (!ep->rep_send_count ||
 	    test_bit(RPCRDMA_REQ_F_TX_RESOURCES, &req->rl_flags)) {
 		send_wr->send_flags |= IB_SEND_SIGNALED;
@@ -1560,14 +1558,12 @@ struct rpcrdma_regbuf *
 		send_wr->send_flags &= ~IB_SEND_SIGNALED;
 		--ep->rep_send_count;
 	}
+
 	rc = ib_post_send(ia->ri_id->qp, send_wr, &send_wr_fail);
+	trace_xprtrdma_post_send(req, rc);
 	if (rc)
-		goto out_postsend_err;
+		return -ENOTCONN;
 	return 0;
-
-out_postsend_err:
-	pr_err("rpcrdma: RDMA Send ib_post_send returned %i\n", rc);
-	return -ENOTCONN;
 }
 
 int


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:47722 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755697AbdJPTBZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Oct 2017 15:01:25 -0400
Subject: [PATCH 1 3/5] xprtrdma: Refactor rpcrdma_reply_handler some more
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 16 Oct 2017 15:01:22 -0400
Message-ID: <20171016190122.13594.38633.stgit@manet.1015granger.net>
In-Reply-To: <20171016185641.13594.5374.stgit@manet.1015granger.net>
References: <20171016185641.13594.5374.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: I'd like to be able to invoke the tail of
rpcrdma_reply_handler in two different places. Split the tail out
into its own helper function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |  105 ++++++++++++++++++++++-----------------
 net/sunrpc/xprtrdma/xprt_rdma.h |   21 ++++----
 2 files changed, 69 insertions(+), 57 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index e355cd3..418bcc6 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1211,6 +1211,60 @@ static int decode_reply_chunk(struct xdr_stream *xdr, u32 *length)
 	return -EREMOTEIO;
 }
 
+/* Perform XID lookup, reconstruction of the RPC reply, and
+ * RPC completion while holding the transport lock to ensure
+ * the rep, rqst, and rq_task pointers remain stable.
+ */
+void rpcrdma_complete_rqst(struct rpcrdma_rep *rep)
+{
+	struct rpcrdma_xprt *r_xprt = rep->rr_rxprt;
+	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
+	struct rpc_rqst *rqst = rep->rr_rqst;
+	unsigned long cwnd;
+	int status;
+
+	xprt->reestablish_timeout = 0;
+
+	switch (rep->rr_proc) {
+	case rdma_msg:
+		status = rpcrdma_decode_msg(r_xprt, rep, rqst);
+		break;
+	case rdma_nomsg:
+		status = rpcrdma_decode_nomsg(r_xprt, rep);
+		break;
+	case rdma_error:
+		status = rpcrdma_decode_error(r_xprt, rep, rqst);
+		break;
+	default:
+		status = -EIO;
+	}
+	if (status < 0)
+		goto out_badheader;
+
+out:
+	spin_lock(&xprt->recv_lock);
+	cwnd = xprt->cwnd;
+	xprt->cwnd = atomic_read(&r_xprt->rx_buf.rb_credits) << RPC_CWNDSHIFT;
+	if (xprt->cwnd > cwnd)
+		xprt_release_rqst_cong(rqst->rq_task);
+
+	xprt_complete_rqst(rqst->rq_task, status);
+	xprt_unpin_rqst(rqst);
+	spin_unlock(&xprt->recv_lock);
+	return;
+
+/* If the incoming reply terminated a pending RPC, the next
+ * RPC call will post a replacement receive buffer as it is
+ * being marshaled.
+ */
+out_badheader:
+	dprintk("RPC: %5u %s: invalid rpcrdma reply (type %u)\n",
+		rqst->rq_task->tk_pid, __func__, be32_to_cpu(rep->rr_proc));
+	r_xprt->rx_stats.bad_reply_count++;
+	status = -EIO;
+	goto out;
+}
+
 /* Process received RPC/RDMA messages.
  *
  * Errors must result in the RPC task either being awakened, or
@@ -1225,8 +1279,6 @@ static int decode_reply_chunk(struct xdr_stream *xdr, u32 *length)
 	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
 	struct rpcrdma_req *req;
 	struct rpc_rqst *rqst;
-	unsigned long cwnd;
-	int status;
 	__be32 *p;
 
 	dprintk("RPC:       %s: incoming rep %p\n", __func__, rep);
@@ -1263,6 +1315,7 @@ static int decode_reply_chunk(struct xdr_stream *xdr, u32 *length)
 	spin_unlock(&xprt->recv_lock);
 	req = rpcr_to_rdmar(rqst);
 	req->rl_reply = rep;
+	rep->rr_rqst = rqst;
 
 	dprintk("RPC:       %s: reply %p completes request %p (xid 0x%08x)\n",
 		__func__, rep, req, be32_to_cpu(rep->rr_xid));
@@ -1280,36 +1333,7 @@ static int decode_reply_chunk(struct xdr_stream *xdr, u32 *length)
 						    &req->rl_registered);
 	}
 
-	xprt->reestablish_timeout = 0;
-
-	switch (rep->rr_proc) {
-	case rdma_msg:
-		status = rpcrdma_decode_msg(r_xprt, rep, rqst);
-		break;
-	case rdma_nomsg:
-		status = rpcrdma_decode_nomsg(r_xprt, rep);
-		break;
-	case rdma_error:
-		status = rpcrdma_decode_error(r_xprt, rep, rqst);
-		break;
-	default:
-		status = -EIO;
-	}
-	if (status < 0)
-		goto out_badheader;
-
-out:
-	spin_lock(&xprt->recv_lock);
-	cwnd = xprt->cwnd;
-	xprt->cwnd = atomic_read(&r_xprt->rx_buf.rb_credits) << RPC_CWNDSHIFT;
-	if (xprt->cwnd > cwnd)
-		xprt_release_rqst_cong(rqst->rq_task);
-
-	xprt_complete_rqst(rqst->rq_task, status);
-	xprt_unpin_rqst(rqst);
-	spin_unlock(&xprt->recv_lock);
-	dprintk("RPC:       %s: xprt_complete_rqst(0x%p, 0x%p, %d)\n",
-		__func__, xprt, rqst, status);
+	rpcrdma_complete_rqst(rep);
 	return;
 
 out_badstatus:
@@ -1325,20 +1349,8 @@ static int decode_reply_chunk(struct xdr_stream *xdr, u32 *length)
 		__func__, be32_to_cpu(rep->rr_vers));
 	goto repost;
 
-/* If the incoming reply terminated a pending RPC, the next
- * RPC call will post a replacement receive buffer as it is
- * being marshaled.
- */
-out_badheader:
-	dprintk("RPC: %5u %s: invalid rpcrdma reply (type %u)\n",
-		rqst->rq_task->tk_pid, __func__, be32_to_cpu(rep->rr_proc));
-	r_xprt->rx_stats.bad_reply_count++;
-	status = -EIO;
-	goto out;
-
-/* The req was still available, but by the time the recv_lock
- * was acquired, the rqst and task had been released. Thus the RPC
- * has already been terminated.
+/* The RPC transaction has already been terminated, or the header
+ * is corrupt.
  */
 out_norqst:
 	spin_unlock(&xprt->recv_lock);
@@ -1348,7 +1360,6 @@ static int decode_reply_chunk(struct xdr_stream *xdr, u32 *length)
 
 out_shortreply:
 	dprintk("RPC:       %s: short/invalid reply\n", __func__);
-	goto repost;
 
 /* If no pending RPC transaction was matched, post a replacement
  * receive buffer before returning.
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 858b4c5..d68a1351 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -202,18 +202,17 @@ enum {
 };
 
 /*
- * struct rpcrdma_rep -- this structure encapsulates state required to recv
- * and complete a reply, asychronously. It needs several pieces of
- * state:
- *   o recv buffer (posted to provider)
- *   o ib_sge (also donated to provider)
- *   o status of reply (length, success or not)
- *   o bookkeeping state to get run by reply handler (list, etc)
+ * struct rpcrdma_rep -- this structure encapsulates state required
+ * to receive and complete an RPC Reply, asychronously. It needs
+ * several pieces of state:
  *
- * These are allocated during initialization, per-transport instance.
+ *   o receive buffer and ib_sge (donated to provider)
+ *   o status of receive (success or not, length, inv rkey)
+ *   o bookkeeping state to get run by reply handler (XDR stream)
  *
- * N of these are associated with a transport instance, and stored in
- * struct rpcrdma_buffer. N is the max number of outstanding requests.
+ * These structures are allocated during transport initialization.
+ * N of these are associated with a transport instance, managed by
+ * struct rpcrdma_buffer. N is the max number of outstanding RPCs.
  */
 
 struct rpcrdma_rep {
@@ -228,6 +227,7 @@ struct rpcrdma_rep {
 	struct work_struct	rr_work;
 	struct xdr_buf		rr_hdrbuf;
 	struct xdr_stream	rr_stream;
+	struct rpc_rqst		*rr_rqst;
 	struct list_head	rr_list;
 	struct ib_recv_wr	rr_recv_wr;
 };
@@ -616,6 +616,7 @@ bool rpcrdma_prepare_send_sges(struct rpcrdma_ia *, struct rpcrdma_req *,
 void rpcrdma_unmap_sges(struct rpcrdma_ia *, struct rpcrdma_req *);
 int rpcrdma_marshal_req(struct rpcrdma_xprt *r_xprt, struct rpc_rqst *rqst);
 void rpcrdma_set_max_header_sizes(struct rpcrdma_xprt *);
+void rpcrdma_complete_rqst(struct rpcrdma_rep *rep);
 void rpcrdma_reply_handler(struct work_struct *work);
 
 static inline void rpcrdma_set_xdrlen(struct xdr_buf *xdr, size_t len)


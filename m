Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35760 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751700AbdHCSaF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 14:30:05 -0400
Received: by mail-it0-f68.google.com with SMTP id v127so1855002itd.2
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 11:30:05 -0700 (PDT)
Subject: [PATCH v1 1/7] xprtrdma: Add xdr_init_decode to
 rpcrdma_reply_handler()
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 03 Aug 2017 14:30:03 -0400
Message-ID: <20170803183003.14672.27177.stgit@manet.1015granger.net>
In-Reply-To: <20170803182623.14672.77636.stgit@manet.1015granger.net>
References: <20170803182623.14672.77636.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Transport header decoding deals with untrusted input data, therefore
decoding this header needs to be hardened.

Adopt the same infrastructure that is used when XDR decoding NFS
replies. This is slightly more CPU-intensive than the replaced code,
but we're not adding new atomics, locking, or context switches. The
cost is manageable.

Start by initializing an xdr_stream in rpcrdma_reply_handler().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   37 +++++++++++++++++++++++--------------
 net/sunrpc/xprtrdma/verbs.c     |    3 +++
 net/sunrpc/xprtrdma/xprt_rdma.h |    8 ++++++++
 3 files changed, 34 insertions(+), 14 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index ca4d6e4..24f58c7 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -993,10 +993,11 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	struct rpcrdma_xprt *r_xprt = rep->rr_rxprt;
 	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
 	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
+	struct xdr_stream *xdr = &rep->rr_stream;
 	struct rpcrdma_msg *headerp;
 	struct rpcrdma_req *req;
 	struct rpc_rqst *rqst;
-	__be32 *iptr;
+	__be32 *iptr, *p, xid, vers, proc;
 	int rdmalen, status, rmerr;
 	unsigned long cwnd;
 	struct list_head mws;
@@ -1005,8 +1006,18 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 
 	if (rep->rr_len == RPCRDMA_BAD_LEN)
 		goto out_badstatus;
-	if (rep->rr_len < RPCRDMA_HDRLEN_ERR)
+
+	xdr_init_decode(xdr, &rep->rr_hdrbuf,
+			rep->rr_hdrbuf.head[0].iov_base);
+
+	/* Fixed transport header fields */
+	p = xdr_inline_decode(xdr, 4 * sizeof(*p));
+	if (unlikely(!p))
 		goto out_shortreply;
+	xid = *p++;
+	vers = *p++;
+	p++;	/* credits */
+	proc = *p++;
 
 	headerp = rdmab_to_msg(rep->rr_rdmabuf);
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
@@ -1018,8 +1029,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	 * get context for handling any incoming chunks.
 	 */
 	spin_lock(&buf->rb_lock);
-	req = rpcrdma_lookup_req_locked(&r_xprt->rx_buf,
-					headerp->rm_xid);
+	req = rpcrdma_lookup_req_locked(&r_xprt->rx_buf, xid);
 	if (!req)
 		goto out_nomatch;
 	if (req->rl_reply)
@@ -1035,7 +1045,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	spin_unlock(&buf->rb_lock);
 
 	dprintk("RPC:       %s: reply %p completes request %p (xid 0x%08x)\n",
-		__func__, rep, req, be32_to_cpu(headerp->rm_xid));
+		__func__, rep, req, be32_to_cpu(xid));
 
 	/* Invalidate and unmap the data payloads before waking the
 	 * waiting application. This guarantees the memory regions
@@ -1052,16 +1062,16 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	 * the rep, rqst, and rq_task pointers remain stable.
 	 */
 	spin_lock_bh(&xprt->transport_lock);
-	rqst = xprt_lookup_rqst(xprt, headerp->rm_xid);
+	rqst = xprt_lookup_rqst(xprt, xid);
 	if (!rqst)
 		goto out_norqst;
 	xprt->reestablish_timeout = 0;
-	if (headerp->rm_vers != rpcrdma_version)
+	if (vers != rpcrdma_version)
 		goto out_badversion;
 
 	/* check for expected message types */
 	/* The order of some of these tests is important. */
-	switch (headerp->rm_type) {
+	switch (proc) {
 	case rdma_msg:
 		/* never expect read chunks */
 		/* never expect reply chunks (two ways to check) */
@@ -1123,7 +1133,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	default:
 		dprintk("RPC: %5u %s: invalid rpcrdma reply (type %u)\n",
 			rqst->rq_task->tk_pid, __func__,
-			be32_to_cpu(headerp->rm_type));
+			be32_to_cpu(proc));
 		status = -EIO;
 		r_xprt->rx_stats.bad_reply_count++;
 		break;
@@ -1161,7 +1171,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
  */
 out_badversion:
 	dprintk("RPC:       %s: invalid version %d\n",
-		__func__, be32_to_cpu(headerp->rm_vers));
+		__func__, be32_to_cpu(vers));
 	status = -EIO;
 	r_xprt->rx_stats.bad_reply_count++;
 	goto out;
@@ -1204,16 +1214,15 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 
 out_nomatch:
 	spin_unlock(&buf->rb_lock);
-	dprintk("RPC:       %s: no match for incoming xid 0x%08x len %d\n",
-		__func__, be32_to_cpu(headerp->rm_xid),
-		rep->rr_len);
+	dprintk("RPC:       %s: no match for incoming xid 0x%08x\n",
+		__func__, be32_to_cpu(xid));
 	goto repost;
 
 out_duplicate:
 	spin_unlock(&buf->rb_lock);
 	dprintk("RPC:       %s: "
 		"duplicate reply %p to RPC request %p: xid 0x%08x\n",
-		__func__, rep, req, be32_to_cpu(headerp->rm_xid));
+		__func__, rep, req, be32_to_cpu(xid));
 
 /* If no pending RPC transaction was matched, post a replacement
  * receive buffer before returning.
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index e4171f2..f1b1c37 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -180,6 +180,7 @@
 		__func__, rep, wc->byte_len);
 
 	rep->rr_len = wc->byte_len;
+	rpcrdma_set_xdrlen(&rep->rr_hdrbuf, wc->byte_len);
 	rep->rr_wc_flags = wc->wc_flags;
 	rep->rr_inv_rkey = wc->ex.invalidate_rkey;
 
@@ -974,6 +975,8 @@ struct rpcrdma_rep *
 		rc = PTR_ERR(rep->rr_rdmabuf);
 		goto out_free;
 	}
+	xdr_buf_init(&rep->rr_hdrbuf, rep->rr_rdmabuf->rg_base,
+		     rdmab_length(rep->rr_rdmabuf));
 
 	rep->rr_cqe.done = rpcrdma_wc_receive;
 	rep->rr_rxprt = r_xprt;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index b282d3f..13556ae 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -223,6 +223,8 @@ struct rpcrdma_rep {
 	u32			rr_inv_rkey;
 	struct rpcrdma_xprt	*rr_rxprt;
 	struct work_struct	rr_work;
+	struct xdr_buf		rr_hdrbuf;
+	struct xdr_stream	rr_stream;
 	struct list_head	rr_list;
 	struct ib_recv_wr	rr_recv_wr;
 	struct rpcrdma_regbuf	*rr_rdmabuf;
@@ -642,6 +644,12 @@ bool rpcrdma_prepare_send_sges(struct rpcrdma_ia *, struct rpcrdma_req *,
 void rpcrdma_set_max_header_sizes(struct rpcrdma_xprt *);
 void rpcrdma_reply_handler(struct work_struct *work);
 
+static inline void rpcrdma_set_xdrlen(struct xdr_buf *xdr, size_t len)
+{
+	xdr->head[0].iov_len = len;
+	xdr->len = len;
+}
+
 /* RPC/RDMA module init - xprtrdma/transport.c
  */
 extern unsigned int xprt_rdma_max_inline_read;


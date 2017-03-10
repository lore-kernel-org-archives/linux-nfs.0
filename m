Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:32896 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932713AbdCJQGP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Mar 2017 11:06:15 -0500
Subject: [PATCH v1 03/11] xprtrdma: Clean up rpcrdma_marshal_req()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 10 Mar 2017 11:06:12 -0500
Message-ID: <20170310160612.6314.91639.stgit@manet.1015granger.net>
In-Reply-To: <20170310154131.6314.35201.stgit@manet.1015granger.net>
References: <20170310154131.6314.35201.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace C-structure-based XDR encoding with pointer-based,
which is more portable, and more idiomatic.

Add appropriate documenting comment.

rpc_xprt is used only to derive rpcrdma_xprt, which the
caller already has. Pass that directly instead.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   63 ++++++++++++++++++++++-----------------
 net/sunrpc/xprtrdma/transport.c |    2 +
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 +
 3 files changed, 38 insertions(+), 29 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index a044be2..103491e 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -651,37 +651,46 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	req->rl_mapped_sges = 0;
 }
 
-/*
- * Marshal a request: the primary job of this routine is to choose
- * the transfer modes. See comments below.
+/**
+ * rpcrdma_marshal_req - Marshal and send one RPC request
+ * @r_xprt: controlling transport
+ * @rqst: RPC request to be marshaled
  *
- * Returns zero on success, otherwise a negative errno.
+ * For the RPC in "rqst", this function:
+ *  - Chooses the transfer mode (eg., RDMA_MSG or RDMA_NOMSG)
+ *  - Registers Read, Write, and Reply chunks
+ *  - Constructs the transport header
+ *  - Posts a Send WR to send the transport header and request
+ *
+ * Returns:
+ *   0:        the RPC was sent successfully
+ *   ENOTCONN: the connection was lost
+ *   EAGAIN:   no pages are available for on-demand reply buffer
+ *   ENOBUFS:  no MRs are available to register chunks
+ *   EIO:      a permanent problem occurred while marshaling
  */
-
 int
-rpcrdma_marshal_req(struct rpc_rqst *rqst)
+rpcrdma_marshal_req(struct rpcrdma_xprt *r_xprt, struct rpc_rqst *rqst)
 {
-	struct rpc_xprt *xprt = rqst->rq_xprt;
-	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
+	struct rpcrdma_regbuf *rb = req->rl_rdmabuf;
 	enum rpcrdma_chunktype rtype, wtype;
-	struct rpcrdma_msg *headerp;
 	bool ddp_allowed;
 	ssize_t hdrlen;
 	size_t rpclen;
-	__be32 *iptr;
+	__be32 *p;
 
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 	if (test_bit(RPC_BC_PA_IN_USE, &rqst->rq_bc_pa_state))
 		return rpcrdma_bc_marshal_reply(rqst);
 #endif
 
-	headerp = rdmab_to_msg(req->rl_rdmabuf);
+	p = rb->rg_base;
 	/* don't byte-swap XID, it's already done in request */
-	headerp->rm_xid = rqst->rq_xid;
-	headerp->rm_vers = rpcrdma_version;
-	headerp->rm_credit = cpu_to_be32(r_xprt->rx_buf.rb_max_requests);
-	headerp->rm_type = rdma_msg;
+	*p++ = rqst->rq_xid;
+	*p++ = rpcrdma_version;
+	*p++ = cpu_to_be32(r_xprt->rx_buf.rb_max_requests);
+	*p = rdma_msg;
 
 	/* When the ULP employs a GSS flavor that guarantees integrity
 	 * or privacy, direct data placement of individual data items
@@ -729,7 +738,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 			 rqst->rq_snd_buf.tail[0].iov_len;
 	} else {
 		r_xprt->rx_stats.nomsg_call_count++;
-		headerp->rm_type = htonl(RDMA_NOMSG);
+		*p = rdma_nomsg;
 		rtype = rpcrdma_areadch;
 		rpclen = 0;
 	}
@@ -756,17 +765,17 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	 * send a Call message with a Position Zero Read chunk and a
 	 * regular Read chunk at the same time.
 	 */
-	iptr = headerp->rm_body.rm_chunks;
-	iptr = rpcrdma_encode_read_list(r_xprt, req, rqst, iptr, rtype);
-	if (IS_ERR(iptr))
+	p++;
+	p = rpcrdma_encode_read_list(r_xprt, req, rqst, p, rtype);
+	if (IS_ERR(p))
 		goto out_err;
-	iptr = rpcrdma_encode_write_list(r_xprt, req, rqst, iptr, wtype);
-	if (IS_ERR(iptr))
+	p = rpcrdma_encode_write_list(r_xprt, req, rqst, p, wtype);
+	if (IS_ERR(p))
 		goto out_err;
-	iptr = rpcrdma_encode_reply_chunk(r_xprt, req, rqst, iptr, wtype);
-	if (IS_ERR(iptr))
+	p = rpcrdma_encode_reply_chunk(r_xprt, req, rqst, p, wtype);
+	if (IS_ERR(p))
 		goto out_err;
-	hdrlen = (unsigned char *)iptr - (unsigned char *)headerp;
+	hdrlen = (unsigned char *)p - (unsigned char *)rb->rg_base;
 
 	dprintk("RPC: %5u %s: %s/%s: hdrlen %zd rpclen %zd\n",
 		rqst->rq_task->tk_pid, __func__,
@@ -775,16 +784,16 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 
 	if (!rpcrdma_prepare_send_sges(&r_xprt->rx_ia, req, hdrlen,
 				       &rqst->rq_snd_buf, rtype)) {
-		iptr = ERR_PTR(-EIO);
+		p = ERR_PTR(-EIO);
 		goto out_err;
 	}
 	return 0;
 
 out_err:
 	pr_err("rpcrdma: rpcrdma_marshal_req failed, status %ld\n",
-	       PTR_ERR(iptr));
+	       PTR_ERR(p));
 	r_xprt->rx_stats.failed_marshal_count++;
-	return PTR_ERR(iptr);
+	return PTR_ERR(p);
 }
 
 /*
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index c717f54..26c9a19 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -689,7 +689,7 @@
 	if (unlikely(!list_empty(&req->rl_registered)))
 		r_xprt->rx_ia.ri_ops->ro_unmap_safe(r_xprt, req, false);
 
-	rc = rpcrdma_marshal_req(rqst);
+	rc = rpcrdma_marshal_req(r_xprt, rqst);
 	if (rc < 0)
 		goto failed_marshal;
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 171a351..e6d76a0 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -586,7 +586,7 @@ enum rpcrdma_chunktype {
 bool rpcrdma_prepare_send_sges(struct rpcrdma_ia *, struct rpcrdma_req *,
 			       u32, struct xdr_buf *, enum rpcrdma_chunktype);
 void rpcrdma_unmap_sges(struct rpcrdma_ia *, struct rpcrdma_req *);
-int rpcrdma_marshal_req(struct rpc_rqst *);
+int rpcrdma_marshal_req(struct rpcrdma_xprt *r_xprt, struct rpc_rqst *rqst);
 void rpcrdma_set_max_header_sizes(struct rpcrdma_xprt *);
 void rpcrdma_reply_handler(struct work_struct *work);
 


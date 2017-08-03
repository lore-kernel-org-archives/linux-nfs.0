Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:37997 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751700AbdHCSaN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 14:30:13 -0400
Received: by mail-io0-f194.google.com with SMTP id o9so1817562iod.5
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 11:30:13 -0700 (PDT)
Subject: [PATCH v1 2/7] xprtrdma: Harden backchannel call decoding
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 03 Aug 2017 14:30:11 -0400
Message-ID: <20170803183011.14672.87022.stgit@manet.1015granger.net>
In-Reply-To: <20170803182623.14672.77636.stgit@manet.1015granger.net>
References: <20170803182623.14672.77636.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/xdr.h        |   13 ++++++++
 net/sunrpc/xprtrdma/backchannel.c |   40 ++++++--------------------
 net/sunrpc/xprtrdma/rpc_rdma.c    |   58 ++++++++++++++++++++++++-------------
 3 files changed, 59 insertions(+), 52 deletions(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 261b48a..86b59e3 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -239,6 +239,19 @@ extern void xdr_init_decode_pages(struct xdr_stream *xdr, struct xdr_buf *buf,
 extern void xdr_enter_page(struct xdr_stream *xdr, unsigned int len);
 extern int xdr_process_buf(struct xdr_buf *buf, unsigned int offset, unsigned int len, int (*actor)(struct scatterlist *, void *), void *data);
 
+/**
+ * xdr_stream_remaining - Return the number of bytes remaining in the stream
+ * @xdr: pointer to struct xdr_stream
+ *
+ * Return value:
+ *   Number of bytes remaining in @xdr before xdr->end
+ */
+static inline size_t
+xdr_stream_remaining(const struct xdr_stream *xdr)
+{
+	return xdr->nwords << 2;
+}
+
 ssize_t xdr_stream_decode_string_dup(struct xdr_stream *xdr, char **str,
 		size_t maxlen, gfp_t gfp_flags);
 /**
diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 03f6b58..183a103 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -271,9 +271,6 @@ void xprt_rdma_bc_free_rqst(struct rpc_rqst *rqst)
  * @xprt: transport receiving the call
  * @rep: receive buffer containing the call
  *
- * Called in the RPC reply handler, which runs in a tasklet.
- * Be quick about it.
- *
  * Operational assumptions:
  *    o Backchannel credits are ignored, just as the NFS server
  *      forechannel currently does
@@ -284,7 +281,6 @@ void rpcrdma_bc_receive_call(struct rpcrdma_xprt *r_xprt,
 			     struct rpcrdma_rep *rep)
 {
 	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
-	struct rpcrdma_msg *headerp;
 	struct svc_serv *bc_serv;
 	struct rpcrdma_req *req;
 	struct rpc_rqst *rqst;
@@ -292,24 +288,15 @@ void rpcrdma_bc_receive_call(struct rpcrdma_xprt *r_xprt,
 	size_t size;
 	__be32 *p;
 
-	headerp = rdmab_to_msg(rep->rr_rdmabuf);
+	p = xdr_inline_decode(&rep->rr_stream, 0);
+	size = xdr_stream_remaining(&rep->rr_stream);
+
 #ifdef RPCRDMA_BACKCHANNEL_DEBUG
 	pr_info("RPC:       %s: callback XID %08x, length=%u\n",
-		__func__, be32_to_cpu(headerp->rm_xid), rep->rr_len);
-	pr_info("RPC:       %s: %*ph\n", __func__, rep->rr_len, headerp);
+		__func__, be32_to_cpup(p), size);
+	pr_info("RPC:       %s: %*ph\n", __func__, size, p);
 #endif
 
-	/* Sanity check:
-	 * Need at least enough bytes for RPC/RDMA header, as code
-	 * here references the header fields by array offset. Also,
-	 * backward calls are always inline, so ensure there
-	 * are some bytes beyond the RPC/RDMA header.
-	 */
-	if (rep->rr_len < RPCRDMA_HDRLEN_MIN + 24)
-		goto out_short;
-	p = (__be32 *)((unsigned char *)headerp + RPCRDMA_HDRLEN_MIN);
-	size = rep->rr_len - RPCRDMA_HDRLEN_MIN;
-
 	/* Grab a free bc rqst */
 	spin_lock(&xprt->bc_pa_lock);
 	if (list_empty(&xprt->bc_pa_list)) {
@@ -325,7 +312,7 @@ void rpcrdma_bc_receive_call(struct rpcrdma_xprt *r_xprt,
 	/* Prepare rqst */
 	rqst->rq_reply_bytes_recvd = 0;
 	rqst->rq_bytes_sent = 0;
-	rqst->rq_xid = headerp->rm_xid;
+	rqst->rq_xid = *p;
 
 	rqst->rq_private_buf.len = size;
 	set_bit(RPC_BC_PA_IN_USE, &rqst->rq_bc_pa_state);
@@ -337,9 +324,9 @@ void rpcrdma_bc_receive_call(struct rpcrdma_xprt *r_xprt,
 	buf->len = size;
 
 	/* The receive buffer has to be hooked to the rpcrdma_req
-	 * so that it can be reposted after the server is done
-	 * parsing it but just before sending the backward
-	 * direction reply.
+	 * so that it is not released while the req is pointing
+	 * to its buffer, and so that it can be reposted after
+	 * the Upper Layer is done decoding it.
 	 */
 	req = rpcr_to_rdmar(rqst);
 	dprintk("RPC:       %s: attaching rep %p to req %p\n",
@@ -367,13 +354,4 @@ void rpcrdma_bc_receive_call(struct rpcrdma_xprt *r_xprt,
 	 * when the connection is re-established.
 	 */
 	return;
-
-out_short:
-	pr_warn("RPC/RDMA short backward direction call\n");
-
-	if (rpcrdma_ep_post_recv(&r_xprt->rx_ia, rep))
-		xprt_disconnect_done(xprt);
-	else
-		pr_warn("RPC:       %s: reposting rep %p\n",
-			__func__, rep);
 }
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 24f58c7..9b5ab59 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -949,35 +949,59 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		}
 }
 
-#if defined(CONFIG_SUNRPC_BACKCHANNEL)
 /* By convention, backchannel calls arrive via rdma_msg type
  * messages, and never populate the chunk lists. This makes
  * the RPC/RDMA header small and fixed in size, so it is
  * straightforward to check the RPC header's direction field.
  */
 static bool
-rpcrdma_is_bcall(struct rpcrdma_msg *headerp)
+rpcrdma_is_bcall(struct rpcrdma_xprt *r_xprt, struct rpcrdma_rep *rep,
+		 __be32 xid, __be32 proc)
+#if defined(CONFIG_SUNRPC_BACKCHANNEL)
 {
-	__be32 *p = (__be32 *)headerp;
+	struct xdr_stream *xdr = &rep->rr_stream;
+	__be32 *p;
 
-	if (headerp->rm_type != rdma_msg)
+	if (proc != rdma_msg)
 		return false;
-	if (headerp->rm_body.rm_chunks[0] != xdr_zero)
+
+	/* Peek at stream contents without advancing. */
+	p = xdr_inline_decode(xdr, 0);
+
+	/* Chunk lists */
+	if (*p++ != xdr_zero)
 		return false;
-	if (headerp->rm_body.rm_chunks[1] != xdr_zero)
+	if (*p++ != xdr_zero)
 		return false;
-	if (headerp->rm_body.rm_chunks[2] != xdr_zero)
+	if (*p++ != xdr_zero)
 		return false;
 
-	/* sanity */
-	if (p[7] != headerp->rm_xid)
+	/* RPC header */
+	if (*p++ != xid)
 		return false;
-	/* call direction */
-	if (p[8] != cpu_to_be32(RPC_CALL))
+	if (*p != cpu_to_be32(RPC_CALL))
 		return false;
 
+	/* Now that we are sure this is a backchannel call,
+	 * advance to the RPC header.
+	 */
+	p = xdr_inline_decode(xdr, 3 * sizeof(*p));
+	if (unlikely(!p))
+		goto out_short;
+
+	rpcrdma_bc_receive_call(r_xprt, rep);
+	return true;
+
+out_short:
+	pr_warn("RPC/RDMA short backward direction call\n");
+	if (rpcrdma_ep_post_recv(&r_xprt->rx_ia, rep))
+		xprt_disconnect_done(&r_xprt->rx_xprt);
 	return true;
 }
+#else	/* CONFIG_SUNRPC_BACKCHANNEL */
+{
+	return false;
+}
 #endif	/* CONFIG_SUNRPC_BACKCHANNEL */
 
 /* Process received RPC/RDMA messages.
@@ -1020,10 +1044,8 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	proc = *p++;
 
 	headerp = rdmab_to_msg(rep->rr_rdmabuf);
-#if defined(CONFIG_SUNRPC_BACKCHANNEL)
-	if (rpcrdma_is_bcall(headerp))
-		goto out_bcall;
-#endif
+	if (rpcrdma_is_bcall(r_xprt, rep, xid, proc))
+		return;
 
 	/* Match incoming rpcrdma_rep to an rpcrdma_req to
 	 * get context for handling any incoming chunks.
@@ -1159,12 +1181,6 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	}
 	return;
 
-#if defined(CONFIG_SUNRPC_BACKCHANNEL)
-out_bcall:
-	rpcrdma_bc_receive_call(r_xprt, rep);
-	return;
-#endif
-
 /* If the incoming reply terminated a pending RPC, the next
  * RPC call will post a replacement receive buffer as it is
  * being marshaled.


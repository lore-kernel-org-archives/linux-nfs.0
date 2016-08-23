Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35799 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751795AbcHWSF4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Aug 2016 14:05:56 -0400
Subject: [PATCH v2 07/22] xprtrdma: Initialize separate RPC call and reply
 buffers
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 23 Aug 2016 13:53:01 -0400
Message-ID: <20160823175301.13038.92001.stgit@manet.1015granger.net>
In-Reply-To: <20160823174402.13038.84561.stgit@manet.1015granger.net>
References: <20160823174402.13038.84561.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RPC-over-RDMA needs to separate its RPC call and reply buffers.

 o When an RPC Call is sent, rq_snd_buf is DMA mapped for an RDMA
   Send operation using DMA_TO_DEVICE

 o If the client expects a large RPC reply, it DMA maps rq_rcv_buf
   as part of a Reply chunk using DMA_FROM_DEVICE

The two mappings are for data movement in opposite directions.

DMA-API.txt suggests that if these mappings share a DMA cacheline,
bad things can happen. This could occur in the final bytes of
rq_snd_buf and the first bytes of rq_rcv_buf if the two buffers
happen to share a DMA cacheline.

On x86_64 the cacheline size is typically 8 bytes, and RPC call
messages are usually much smaller than the send buffer, so this
hasn't been a noticeable problem. But the DMA cacheline size can be
larger on other platforms.

Also, often rq_rcv_buf starts most of the way into a page, thus
an additional RDMA segment is needed to map and register the end of
that buffer. Try to avoid that scenario to reduce the cost of
registering and invalidating Reply chunks.

Instead of carrying a single regbuf that covers both rq_snd_buf and
rq_rcv_buf, each struct rpcrdma_req now carries one regbuf for
rq_snd_buf and one regbuf for rq_rcv_buf.

Some incidental changes worth noting:

- To clear out some spaghetti, refactor xprt_rdma_allocate.
- The value stored in rg_size is the same as the value stored in
  the iov.length field, so eliminate rg_size

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |  150 +++++++++++++++++++++++++--------------
 net/sunrpc/xprtrdma/verbs.c     |    2 -
 net/sunrpc/xprtrdma/xprt_rdma.h |    6 +-
 3 files changed, 99 insertions(+), 59 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index d83bffa..ecdc3ad 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -477,6 +477,86 @@ xprt_rdma_connect(struct rpc_xprt *xprt, struct rpc_task *task)
 	}
 }
 
+/* Allocate a fixed-size buffer in which to construct and send the
+ * RPC-over-RDMA header for this request.
+ */
+static bool
+rpcrdma_get_rdmabuf(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
+		    gfp_t flags)
+{
+	size_t size = r_xprt->rx_data.inline_wsize;
+	struct rpcrdma_regbuf *rb;
+
+	if (req->rl_rdmabuf)
+		return true;
+
+	rb = rpcrdma_alloc_regbuf(&r_xprt->rx_ia, size, flags);
+	if (IS_ERR(rb))
+		return false;
+
+	r_xprt->rx_stats.hardway_register_count += size;
+	req->rl_rdmabuf = rb;
+	return true;
+}
+
+/* RPC/RDMA marshaling may choose to send payload bearing ops inline,
+ * if the resulting Call message is smaller than the inline threshold.
+ * The value of the "rq_callsize" argument accounts for RPC header
+ * requirements, but not for the data payload in these cases.
+ *
+ * See rpcrdma_inline_pullup.
+ */
+static bool
+rpcrdma_get_sendbuf(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
+		    size_t size, gfp_t flags)
+{
+	struct rpcrdma_regbuf *rb;
+	size_t min_size;
+
+	if (req->rl_sendbuf && rdmab_length(req->rl_sendbuf) >= size)
+		return true;
+
+	min_size = max_t(size_t, size, r_xprt->rx_data.inline_wsize);
+	rb = rpcrdma_alloc_regbuf(&r_xprt->rx_ia, min_size, flags);
+	if (IS_ERR(rb))
+		return false;
+
+	rpcrdma_free_regbuf(&r_xprt->rx_ia, req->rl_sendbuf);
+	r_xprt->rx_stats.hardway_register_count += min_size;
+	req->rl_sendbuf = rb;
+	return true;
+}
+
+/* The rq_rcv_buf is used only if a Reply chunk is necessary.
+ * The decision to use a Reply chunk is made later in
+ * rpcrdma_marshal_req. This buffer is registered at that time.
+ *
+ * Otherwise, the associated RPC Reply arrives in a separate
+ * Receive buffer, arbitrarily chosen by the HCA. The buffer
+ * allocated here for the RPC Reply is not utilized in that
+ * case. See rpcrdma_inline_fixup.
+ *
+ * A regbuf is used here to remember the buffer size.
+ */
+static bool
+rpcrdma_get_recvbuf(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
+		    size_t size, gfp_t flags)
+{
+	struct rpcrdma_regbuf *rb;
+
+	if (req->rl_recvbuf && rdmab_length(req->rl_recvbuf) >= size)
+		return true;
+
+	rb = rpcrdma_alloc_regbuf(&r_xprt->rx_ia, size, flags);
+	if (IS_ERR(rb))
+		return false;
+
+	rpcrdma_free_regbuf(&r_xprt->rx_ia, req->rl_recvbuf);
+	r_xprt->rx_stats.hardway_register_count += size;
+	req->rl_recvbuf = rb;
+	return true;
+}
+
 /**
  * xprt_rdma_allocate - allocate transport resources for an RPC
  * @task: RPC task
@@ -487,22 +567,18 @@ xprt_rdma_connect(struct rpc_xprt *xprt, struct rpc_task *task)
  *      EIO:	A permanent error occurred, do not retry
  *
  * The RDMA allocate/free functions need the task structure as a place
- * to hide the struct rpcrdma_req, which is necessary for the actual send/recv
- * sequence.
+ * to hide the struct rpcrdma_req, which is necessary for the actual
+ * send/recv sequence.
  *
- * The RPC layer allocates both send and receive buffers in the same call
- * (rq_send_buf and rq_rcv_buf are both part of a single contiguous buffer).
- * We may register rq_rcv_buf when using reply chunks.
+ * xprt_rdma_allocate provides buffers that are already mapped for
+ * DMA, and a local DMA lkey is provided for each.
  */
 static int
 xprt_rdma_allocate(struct rpc_task *task)
 {
 	struct rpc_rqst *rqst = task->tk_rqstp;
-	size_t size = rqst->rq_callsize + rqst->rq_rcvsize;
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(rqst->rq_xprt);
-	struct rpcrdma_regbuf *rb;
 	struct rpcrdma_req *req;
-	size_t min_size;
 	gfp_t flags;
 
 	req = rpcrdma_buffer_get(&r_xprt->rx_buf);
@@ -513,59 +589,23 @@ xprt_rdma_allocate(struct rpc_task *task)
 	if (RPC_IS_SWAPPER(task))
 		flags = __GFP_MEMALLOC | GFP_NOWAIT | __GFP_NOWARN;
 
-	if (req->rl_rdmabuf == NULL)
-		goto out_rdmabuf;
-	if (req->rl_sendbuf == NULL)
-		goto out_sendbuf;
-	if (size > req->rl_sendbuf->rg_size)
-		goto out_sendbuf;
+	if (!rpcrdma_get_rdmabuf(r_xprt, req, flags))
+		goto out_fail;
+	if (!rpcrdma_get_sendbuf(r_xprt, req, rqst->rq_callsize, flags))
+		goto out_fail;
+	if (!rpcrdma_get_recvbuf(r_xprt, req, rqst->rq_rcvsize, flags))
+		goto out_fail;
+
+	dprintk("RPC: %5u %s: send size = %zd, recv size = %zd, req = %p\n",
+		task->tk_pid, __func__, rqst->rq_callsize,
+		rqst->rq_rcvsize, req);
 
-out:
-	dprintk("RPC:       %s: size %zd, request 0x%p\n", __func__, size, req);
 	req->rl_connect_cookie = 0;	/* our reserved value */
 	rpcrdma_set_xprtdata(rqst, req);
 	rqst->rq_buffer = req->rl_sendbuf->rg_base;
-	rqst->rq_rbuffer = (char *)rqst->rq_buffer + rqst->rq_rcvsize;
+	rqst->rq_rbuffer = req->rl_recvbuf->rg_base;
 	return 0;
 
-out_rdmabuf:
-	min_size = r_xprt->rx_data.inline_wsize;
-	rb = rpcrdma_alloc_regbuf(&r_xprt->rx_ia, min_size, flags);
-	if (IS_ERR(rb))
-		goto out_fail;
-	req->rl_rdmabuf = rb;
-
-out_sendbuf:
-	/* XDR encoding and RPC/RDMA marshaling of this request has not
-	 * yet occurred. Thus a lower bound is needed to prevent buffer
-	 * overrun during marshaling.
-	 *
-	 * RPC/RDMA marshaling may choose to send payload bearing ops
-	 * inline, if the result is smaller than the inline threshold.
-	 * The value of the "size" argument accounts for header
-	 * requirements but not for the payload in these cases.
-	 *
-	 * Likewise, allocate enough space to receive a reply up to the
-	 * size of the inline threshold.
-	 *
-	 * It's unlikely that both the send header and the received
-	 * reply will be large, but slush is provided here to allow
-	 * flexibility when marshaling.
-	 */
-	min_size = r_xprt->rx_data.inline_rsize;
-	min_size += r_xprt->rx_data.inline_wsize;
-	if (size < min_size)
-		size = min_size;
-
-	rb = rpcrdma_alloc_regbuf(&r_xprt->rx_ia, size, flags);
-	if (IS_ERR(rb))
-		goto out_fail;
-
-	r_xprt->rx_stats.hardway_register_count += size;
-	rpcrdma_free_regbuf(&r_xprt->rx_ia, req->rl_sendbuf);
-	req->rl_sendbuf = rb;
-	goto out;
-
 out_fail:
 	rpcrdma_buffer_put(req);
 	return -ENOMEM;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index baf7f43..9c3e58e 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -974,6 +974,7 @@ rpcrdma_destroy_rep(struct rpcrdma_ia *ia, struct rpcrdma_rep *rep)
 void
 rpcrdma_destroy_req(struct rpcrdma_ia *ia, struct rpcrdma_req *req)
 {
+	rpcrdma_free_regbuf(ia, req->rl_recvbuf);
 	rpcrdma_free_regbuf(ia, req->rl_sendbuf);
 	rpcrdma_free_regbuf(ia, req->rl_rdmabuf);
 	kfree(req);
@@ -1190,7 +1191,6 @@ rpcrdma_alloc_regbuf(struct rpcrdma_ia *ia, size_t size, gfp_t flags)
 
 	iov->length = size;
 	iov->lkey = ia->ri_pd->local_dma_lkey;
-	rb->rg_size = size;
 	return rb;
 
 out_free:
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 99b6839..73f915f 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -112,7 +112,6 @@ struct rpcrdma_ep {
  */
 
 struct rpcrdma_regbuf {
-	size_t			rg_size;
 	struct ib_sge		rg_iov;
 	__be32			rg_base[0] __attribute__ ((aligned(256)));
 };
@@ -285,8 +284,9 @@ struct rpcrdma_req {
 	struct rpcrdma_buffer	*rl_buffer;
 	struct rpcrdma_rep	*rl_reply;/* holder for reply buffer */
 	struct ib_sge		rl_send_iov[RPCRDMA_MAX_IOVS];
-	struct rpcrdma_regbuf	*rl_rdmabuf;
-	struct rpcrdma_regbuf	*rl_sendbuf;
+	struct rpcrdma_regbuf	*rl_rdmabuf;	/* xprt header */
+	struct rpcrdma_regbuf	*rl_sendbuf;	/* rq_snd_buf */
+	struct rpcrdma_regbuf	*rl_recvbuf;	/* rq_rcv_buf */
 
 	struct ib_cqe		rl_cqe;
 	struct list_head	rl_all;


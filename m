Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f196.google.com ([209.85.213.196]:35313 "EHLO
	mail-ig0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933381AbcDYTVX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Apr 2016 15:21:23 -0400
Subject: [PATCH v2 04/18] xprtrdma: Prevent inline overflow
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 25 Apr 2016 15:21:20 -0400
Message-ID: <20160425192120.3566.99978.stgit@manet.1015granger.net>
In-Reply-To: <20160425185956.3566.64142.stgit@manet.1015granger.net>
References: <20160425185956.3566.64142.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When deciding whether to send a Call inline, rpcrdma_marshal_req
doesn't take into account header bytes consumed by chunk lists.
This results in Call messages on the wire that are sometimes larger
than the inline threshold.

Likewise, when a Write list or Reply chunk is in play, the server's
reply has to emit an RDMA Send that includes a larger-than-minimal
RPC-over-RDMA header.

The actual size of a Call message cannot be estimated until after
the chunk lists have been registered. Thus the size of each
RPC-over-RDMA header can be estimated only after chunks are
registered; but the decision to register chunks is based on the size
of that header. Chicken, meet egg.

The best a client can do is estimate header size based on the
largest header that might occur, and then ensure that inline content
is always smaller than that.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c      |    3 +
 net/sunrpc/xprtrdma/frwr_ops.c     |    3 +
 net/sunrpc/xprtrdma/physical_ops.c |    5 ++
 net/sunrpc/xprtrdma/rpc_rdma.c     |   85 ++++++++++++++++++++++++++++++++----
 net/sunrpc/xprtrdma/xprt_rdma.h    |    5 ++
 5 files changed, 90 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 4aeb104..009694b 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -39,6 +39,9 @@ static int
 fmr_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
 	    struct rpcrdma_create_data_internal *cdata)
 {
+	rpcrdma_set_max_header_sizes(ia, cdata, max_t(unsigned int, 1,
+						      RPCRDMA_MAX_DATA_SEGS /
+						      RPCRDMA_MAX_FMR_SGES));
 	return 0;
 }
 
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 2f37598..41e02e7 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -231,6 +231,9 @@ frwr_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
 					       depth;
 	}
 
+	rpcrdma_set_max_header_sizes(ia, cdata, max_t(unsigned int, 1,
+						      RPCRDMA_MAX_DATA_SEGS /
+						      ia->ri_max_frmr_depth));
 	return 0;
 }
 
diff --git a/net/sunrpc/xprtrdma/physical_ops.c b/net/sunrpc/xprtrdma/physical_ops.c
index e16ed54..2dc6ec2 100644
--- a/net/sunrpc/xprtrdma/physical_ops.c
+++ b/net/sunrpc/xprtrdma/physical_ops.c
@@ -36,8 +36,11 @@ physical_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
 		       __func__, PTR_ERR(mr));
 		return -ENOMEM;
 	}
-
 	ia->ri_dma_mr = mr;
+
+	rpcrdma_set_max_header_sizes(ia, cdata, min_t(unsigned int,
+						      RPCRDMA_MAX_DATA_SEGS,
+						      RPCRDMA_MAX_HDR_SEGS));
 	return 0;
 }
 
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 888823b..205b81b 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -61,7 +61,6 @@ enum rpcrdma_chunktype {
 	rpcrdma_replych
 };
 
-#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 static const char transfertypes[][12] = {
 	"pure inline",	/* no chunks */
 	" read chunk",	/* some argument via rdma read */
@@ -69,18 +68,72 @@ static const char transfertypes[][12] = {
 	"write chunk",	/* some result via rdma write */
 	"reply chunk"	/* entire reply via rdma write */
 };
-#endif
+
+/* Returns size of largest RPC-over-RDMA header in a Call message
+ *
+ * The client marshals only one chunk list per Call message.
+ * The largest list is the Read list.
+ */
+static unsigned int rpcrdma_max_call_header_size(unsigned int maxsegs)
+{
+	unsigned int size;
+
+	/* Fixed header fields and list discriminators */
+	size = RPCRDMA_HDRLEN_MIN;
+
+	/* Maximum Read list size */
+	maxsegs += 2;	/* segment for head and tail buffers */
+	size = maxsegs * sizeof(struct rpcrdma_read_chunk);
+
+	dprintk("RPC:       %s: max call header size = %u\n",
+		__func__, size);
+	return size;
+}
+
+/* Returns size of largest RPC-over-RDMA header in a Reply message
+ *
+ * There is only one Write list or one Reply chunk per Reply
+ * message.  The larger list is the Write list.
+ */
+static unsigned int rpcrdma_max_reply_header_size(unsigned int maxsegs)
+{
+	unsigned int size;
+
+	/* Fixed header fields and list discriminators */
+	size = RPCRDMA_HDRLEN_MIN;
+
+	/* Maximum Write list size */
+	maxsegs += 2;	/* segment for head and tail buffers */
+	size = sizeof(__be32);		/* segment count */
+	size += maxsegs * sizeof(struct rpcrdma_segment);
+	size += sizeof(__be32);	/* list discriminator */
+
+	dprintk("RPC:       %s: max reply header size = %u\n",
+		__func__, size);
+	return size;
+}
+
+void rpcrdma_set_max_header_sizes(struct rpcrdma_ia *ia,
+				  struct rpcrdma_create_data_internal *cdata,
+				  unsigned int maxsegs)
+{
+	ia->ri_max_inline_write = cdata->inline_wsize -
+				  rpcrdma_max_call_header_size(maxsegs);
+	ia->ri_max_inline_read = cdata->inline_rsize -
+				 rpcrdma_max_reply_header_size(maxsegs);
+}
 
 /* The client can send a request inline as long as the RPCRDMA header
  * plus the RPC call fit under the transport's inline limit. If the
  * combined call message size exceeds that limit, the client must use
  * the read chunk list for this operation.
  */
-static bool rpcrdma_args_inline(struct rpc_rqst *rqst)
+static bool rpcrdma_args_inline(struct rpcrdma_xprt *r_xprt,
+				struct rpc_rqst *rqst)
 {
-	unsigned int callsize = RPCRDMA_HDRLEN_MIN + rqst->rq_snd_buf.len;
+	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 
-	return callsize <= RPCRDMA_INLINE_WRITE_THRESHOLD(rqst);
+	return rqst->rq_snd_buf.len <= ia->ri_max_inline_write;
 }
 
 /* The client can't know how large the actual reply will be. Thus it
@@ -89,11 +142,12 @@ static bool rpcrdma_args_inline(struct rpc_rqst *rqst)
  * limit, the client must provide a write list or a reply chunk for
  * this request.
  */
-static bool rpcrdma_results_inline(struct rpc_rqst *rqst)
+static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
+				   struct rpc_rqst *rqst)
 {
-	unsigned int repsize = RPCRDMA_HDRLEN_MIN + rqst->rq_rcv_buf.buflen;
+	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 
-	return repsize <= RPCRDMA_INLINE_READ_THRESHOLD(rqst);
+	return rqst->rq_rcv_buf.buflen <= ia->ri_max_inline_read;
 }
 
 static int
@@ -492,7 +546,7 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	 */
 	if (rqst->rq_rcv_buf.flags & XDRBUF_READ)
 		wtype = rpcrdma_writech;
-	else if (rpcrdma_results_inline(rqst))
+	else if (rpcrdma_results_inline(r_xprt, rqst))
 		wtype = rpcrdma_noch;
 	else
 		wtype = rpcrdma_replych;
@@ -511,7 +565,7 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	 * that both has a data payload, and whose non-data arguments
 	 * by themselves are larger than the inline threshold.
 	 */
-	if (rpcrdma_args_inline(rqst)) {
+	if (rpcrdma_args_inline(r_xprt, rqst)) {
 		rtype = rpcrdma_noch;
 	} else if (rqst->rq_snd_buf.flags & XDRBUF_WRITE) {
 		rtype = rpcrdma_readch;
@@ -561,6 +615,9 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	if (hdrlen < 0)
 		return hdrlen;
 
+	if (hdrlen + rpclen > RPCRDMA_INLINE_WRITE_THRESHOLD(rqst))
+		goto out_overflow;
+
 	dprintk("RPC:       %s: %s: hdrlen %zd rpclen %zd"
 		" headerp 0x%p base 0x%p lkey 0x%x\n",
 		__func__, transfertypes[wtype], hdrlen, rpclen,
@@ -587,6 +644,14 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 
 	req->rl_niovs = 2;
 	return 0;
+
+out_overflow:
+	pr_err("rpcrdma: send overflow: hdrlen %zd rpclen %zu %s\n",
+		hdrlen, rpclen, transfertypes[wtype]);
+	/* Terminate this RPC. Chunks registered above will be
+	 * released by xprt_release -> xprt_rmda_free .
+	 */
+	return -EIO;
 }
 
 /*
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 0028748..4349e03 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -73,6 +73,8 @@ struct rpcrdma_ia {
 	struct completion	ri_done;
 	int			ri_async_rc;
 	unsigned int		ri_max_frmr_depth;
+	unsigned int		ri_max_inline_write;
+	unsigned int		ri_max_inline_read;
 	struct ib_qp_attr	ri_qp_attr;
 	struct ib_qp_init_attr	ri_qp_init_attr;
 };
@@ -538,6 +540,9 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *);
  * RPC/RDMA protocol calls - xprtrdma/rpc_rdma.c
  */
 int rpcrdma_marshal_req(struct rpc_rqst *);
+void rpcrdma_set_max_header_sizes(struct rpcrdma_ia *,
+				  struct rpcrdma_create_data_internal *,
+				  unsigned int);
 
 /* RPC/RDMA module init - xprtrdma/transport.c
  */


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:37030 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728210AbeIJUEC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Sep 2018 16:04:02 -0400
Subject: [PATCH v1 06/22] xprtrdma: Refactor chunktype handling
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 10 Sep 2018 11:09:27 -0400
Message-ID: <20180910150927.10564.93847.stgit@manet.1015granger.net>
In-Reply-To: <20180910150040.10564.97487.stgit@manet.1015granger.net>
References: <20180910150040.10564.97487.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a pre-requisite for adding support for sending both a Write
chunk and a Reply chunk in the same RPC. It is a refactoring/clean
up patch, so no functional change is expected.

rpcrdma_convert_iovs is a helper function that is invoked by each
chunk encoder. It's passed an enum rpcrdma_chunktype variable that
indicates either the set of chunks needed for the Call arguments or
the Reply results.

While marshaling the same RPC, rpcrdma_convert_iovs is invoked once
for the Write chunk and once for the Reply chunk. But it's passed
the same @type both times. Thus it can't distinguish between when
it's called to encode the Write chunk versus when it's called to
encode the Reply chunk.

Let's refactor rpcrdma_convert_iovs so it needs just a detail about
how the chunk should be handled. That detail is different for Write
chunks and Reply chunks.

Looking at this change I realized that "wtype" is unhelpfully named
in the entire marshaling code path, since it will include both the
Write chunk list and the Reply chunk. As part of refactoring
rpcrdma_convert_iovs, rename wtype to better fit its purpose. Update
"rtype" as well to match this convention.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h  |   18 ++++---
 net/sunrpc/xprtrdma/rpc_rdma.c  |  100 +++++++++++++++++++++------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 -
 3 files changed, 63 insertions(+), 57 deletions(-)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index 89e017b..b9e6802 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -459,11 +459,11 @@
 	TP_PROTO(
 		const struct rpc_rqst *rqst,
 		unsigned int hdrlen,
-		unsigned int rtype,
-		unsigned int wtype
+		unsigned int argtype,
+		unsigned int restype
 	),
 
-	TP_ARGS(rqst, hdrlen, rtype, wtype),
+	TP_ARGS(rqst, hdrlen, argtype, restype),
 
 	TP_STRUCT__entry(
 		__field(unsigned int, task_id)
@@ -473,8 +473,8 @@
 		__field(unsigned int, headlen)
 		__field(unsigned int, pagelen)
 		__field(unsigned int, taillen)
-		__field(unsigned int, rtype)
-		__field(unsigned int, wtype)
+		__field(unsigned int, argtype)
+		__field(unsigned int, restype)
 	),
 
 	TP_fast_assign(
@@ -485,16 +485,16 @@
 		__entry->headlen = rqst->rq_snd_buf.head[0].iov_len;
 		__entry->pagelen = rqst->rq_snd_buf.page_len;
 		__entry->taillen = rqst->rq_snd_buf.tail[0].iov_len;
-		__entry->rtype = rtype;
-		__entry->wtype = wtype;
+		__entry->argtype = argtype;
+		__entry->restype = restype;
 	),
 
 	TP_printk("task:%u@%u xid=0x%08x: hdr=%u xdr=%u/%u/%u %s/%s",
 		__entry->task_id, __entry->client_id, __entry->xid,
 		__entry->hdrlen,
 		__entry->headlen, __entry->pagelen, __entry->taillen,
-		xprtrdma_show_chunktype(__entry->rtype),
-		xprtrdma_show_chunktype(__entry->wtype)
+		xprtrdma_show_chunktype(__entry->argtype),
+		xprtrdma_show_chunktype(__entry->restype)
 	)
 );
 
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 39996df..26640e6 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -200,11 +200,10 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
  *
  * Returns positive number of SGEs consumed, or a negative errno.
  */
-
 static int
 rpcrdma_convert_iovs(struct rpcrdma_xprt *r_xprt, struct xdr_buf *xdrbuf,
-		     unsigned int pos, enum rpcrdma_chunktype type,
-		     struct rpcrdma_mr_seg *seg)
+		     unsigned int pos, struct rpcrdma_mr_seg *seg,
+		     bool omit_xdr_pad)
 {
 	unsigned long page_base;
 	unsigned int len, n;
@@ -236,18 +235,10 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		page_base = 0;
 	}
 
-	/* When encoding a Read chunk, the tail iovec contains an
-	 * XDR pad and may be omitted.
-	 */
-	if (type == rpcrdma_readch && r_xprt->rx_ia.ri_implicit_roundup)
-		goto out;
-
-	/* When encoding a Write chunk, some servers need to see an
-	 * extra segment for non-XDR-aligned Write chunks. The upper
-	 * layer provides space in the tail iovec that may be used
-	 * for this purpose.
+	/* A normal Read or Write chunk may omit the XDR pad.
+	 * The upper layer provides the pad in @xdrbuf's tail.
 	 */
-	if (type == rpcrdma_writech && r_xprt->rx_ia.ri_implicit_roundup)
+	if (omit_xdr_pad)
 		goto out;
 
 	if (xdrbuf->tail[0].iov_len)
@@ -338,23 +329,31 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
  */
 static noinline int
 rpcrdma_encode_read_list(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
-			 struct rpc_rqst *rqst, enum rpcrdma_chunktype rtype)
+			 struct rpc_rqst *rqst, enum rpcrdma_chunktype argtype)
 {
 	struct xdr_stream *xdr = &req->rl_stream;
 	struct rpcrdma_mr_seg *seg;
 	struct rpcrdma_mr *mr;
+	bool omit_xdr_pad;
 	unsigned int pos;
 	int nsegs;
 
-	if (rtype == rpcrdma_noch)
+	switch (argtype) {
+	case rpcrdma_readch:
+		omit_xdr_pad = r_xprt->rx_ia.ri_implicit_roundup;
+		pos = rqst->rq_snd_buf.head[0].iov_len;
+		break;
+	case rpcrdma_areadch:
+		omit_xdr_pad = false;
+		pos = 0;
+		break;
+	default:
 		goto done;
+	}
 
-	pos = rqst->rq_snd_buf.head[0].iov_len;
-	if (rtype == rpcrdma_areadch)
-		pos = 0;
 	seg = req->rl_segments;
-	nsegs = rpcrdma_convert_iovs(r_xprt, &rqst->rq_snd_buf, pos,
-				     rtype, seg);
+	nsegs = rpcrdma_convert_iovs(r_xprt, &rqst->rq_snd_buf, pos, seg,
+				     omit_xdr_pad);
 	if (nsegs < 0)
 		return nsegs;
 
@@ -394,7 +393,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
  */
 static noinline int
 rpcrdma_encode_write_list(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
-			  struct rpc_rqst *rqst, enum rpcrdma_chunktype wtype)
+			  struct rpc_rqst *rqst, enum rpcrdma_chunktype restype)
 {
 	struct xdr_stream *xdr = &req->rl_stream;
 	struct rpcrdma_mr_seg *seg;
@@ -402,13 +401,18 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	int nsegs, nchunks;
 	__be32 *segcount;
 
-	if (wtype != rpcrdma_writech)
+	if (restype != rpcrdma_writech)
 		goto done;
 
+	/* When encoding a Write chunk, some servers need to see an
+	 * extra segment for non-XDR-aligned Write chunks. The upper
+	 * layer provides space in the tail iovec that may be used
+	 * for this purpose.
+	 */
 	seg = req->rl_segments;
 	nsegs = rpcrdma_convert_iovs(r_xprt, &rqst->rq_rcv_buf,
-				     rqst->rq_rcv_buf.head[0].iov_len,
-				     wtype, seg);
+				     rqst->rq_rcv_buf.head[0].iov_len, seg,
+				     r_xprt->rx_ia.ri_implicit_roundup);
 	if (nsegs < 0)
 		return nsegs;
 
@@ -457,8 +461,9 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
  * @xdr is advanced to the next position in the stream.
  */
 static noinline int
-rpcrdma_encode_reply_chunk(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
-			   struct rpc_rqst *rqst, enum rpcrdma_chunktype wtype)
+rpcrdma_encode_reply_chunk(struct rpcrdma_xprt *r_xprt,
+			   struct rpcrdma_req *req, struct rpc_rqst *rqst,
+			   enum rpcrdma_chunktype restype)
 {
 	struct xdr_stream *xdr = &req->rl_stream;
 	struct rpcrdma_mr_seg *seg;
@@ -466,11 +471,11 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	int nsegs, nchunks;
 	__be32 *segcount;
 
-	if (wtype != rpcrdma_replych)
+	if (restype != rpcrdma_replych)
 		return encode_item_not_present(xdr);
 
 	seg = req->rl_segments;
-	nsegs = rpcrdma_convert_iovs(r_xprt, &rqst->rq_rcv_buf, 0, wtype, seg);
+	nsegs = rpcrdma_convert_iovs(r_xprt, &rqst->rq_rcv_buf, 0, seg, false);
 	if (nsegs < 0)
 		return nsegs;
 
@@ -563,7 +568,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
  */
 static bool
 rpcrdma_prepare_msg_sges(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
-			 struct xdr_buf *xdr, enum rpcrdma_chunktype rtype)
+			 struct xdr_buf *xdr, enum rpcrdma_chunktype argtype)
 {
 	struct rpcrdma_sendctx *sc = req->rl_sendctx;
 	unsigned int sge_no, page_base, len, remaining;
@@ -591,7 +596,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	 * well as additional content, and may not reside in the
 	 * same page as the head iovec.
 	 */
-	if (rtype == rpcrdma_readch) {
+	if (argtype == rpcrdma_readch) {
 		len = xdr->tail[0].iov_len;
 
 		/* Do not include the tail if it is only an XDR pad */
@@ -688,14 +693,14 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
  * @req: context of RPC Call being marshalled
  * @hdrlen: size of transport header, in bytes
  * @xdr: xdr_buf containing RPC Call
- * @rtype: chunk type being encoded
+ * @argtype: chunk type being encoded
  *
  * Returns 0 on success; otherwise a negative errno is returned.
  */
 int
 rpcrdma_prepare_send_sges(struct rpcrdma_xprt *r_xprt,
 			  struct rpcrdma_req *req, u32 hdrlen,
-			  struct xdr_buf *xdr, enum rpcrdma_chunktype rtype)
+			  struct xdr_buf *xdr, enum rpcrdma_chunktype argtype)
 {
 	req->rl_sendctx = rpcrdma_sendctx_get_locked(&r_xprt->rx_buf);
 	if (!req->rl_sendctx)
@@ -708,8 +713,9 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	if (!rpcrdma_prepare_hdr_sge(&r_xprt->rx_ia, req, hdrlen))
 		return -EIO;
 
-	if (rtype != rpcrdma_areadch)
-		if (!rpcrdma_prepare_msg_sges(&r_xprt->rx_ia, req, xdr, rtype))
+	if (argtype != rpcrdma_areadch)
+		if (!rpcrdma_prepare_msg_sges(&r_xprt->rx_ia, req,
+					      xdr, argtype))
 			return -EIO;
 
 	return 0;
@@ -739,7 +745,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 {
 	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
 	struct xdr_stream *xdr = &req->rl_stream;
-	enum rpcrdma_chunktype rtype, wtype;
+	enum rpcrdma_chunktype argtype, restype;
 	bool ddp_allowed;
 	__be32 *p;
 	int ret;
@@ -774,11 +780,11 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	 * o Large non-read ops return as a single reply chunk.
 	 */
 	if (rpcrdma_results_inline(r_xprt, rqst))
-		wtype = rpcrdma_noch;
+		restype = rpcrdma_noch;
 	else if (ddp_allowed && rqst->rq_rcv_buf.flags & XDRBUF_READ)
-		wtype = rpcrdma_writech;
+		restype = rpcrdma_writech;
 	else
-		wtype = rpcrdma_replych;
+		restype = rpcrdma_replych;
 
 	/*
 	 * Chunks needed for arguments?
@@ -796,14 +802,14 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	 */
 	if (rpcrdma_args_inline(r_xprt, rqst)) {
 		*p++ = rdma_msg;
-		rtype = rpcrdma_noch;
+		argtype = rpcrdma_noch;
 	} else if (ddp_allowed && rqst->rq_snd_buf.flags & XDRBUF_WRITE) {
 		*p++ = rdma_msg;
-		rtype = rpcrdma_readch;
+		argtype = rpcrdma_readch;
 	} else {
 		r_xprt->rx_stats.nomsg_call_count++;
 		*p++ = rdma_nomsg;
-		rtype = rpcrdma_areadch;
+		argtype = rpcrdma_areadch;
 	}
 
 	/* If this is a retransmit, discard previously registered
@@ -839,19 +845,19 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	 * send a Call message with a Position Zero Read chunk and a
 	 * regular Read chunk at the same time.
 	 */
-	ret = rpcrdma_encode_read_list(r_xprt, req, rqst, rtype);
+	ret = rpcrdma_encode_read_list(r_xprt, req, rqst, argtype);
 	if (ret)
 		goto out_err;
-	ret = rpcrdma_encode_write_list(r_xprt, req, rqst, wtype);
+	ret = rpcrdma_encode_write_list(r_xprt, req, rqst, restype);
 	if (ret)
 		goto out_err;
-	ret = rpcrdma_encode_reply_chunk(r_xprt, req, rqst, wtype);
+	ret = rpcrdma_encode_reply_chunk(r_xprt, req, rqst, restype);
 	if (ret)
 		goto out_err;
-	trace_xprtrdma_marshal(rqst, xdr_stream_pos(xdr), rtype, wtype);
+	trace_xprtrdma_marshal(rqst, xdr_stream_pos(xdr), argtype, restype);
 
 	ret = rpcrdma_prepare_send_sges(r_xprt, req, xdr_stream_pos(xdr),
-					&rqst->rq_snd_buf, rtype);
+					&rqst->rq_snd_buf, argtype);
 	if (ret)
 		goto out_err;
 	return 0;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index eae2166..d29bf38 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -633,7 +633,7 @@ enum rpcrdma_chunktype {
 int rpcrdma_prepare_send_sges(struct rpcrdma_xprt *r_xprt,
 			      struct rpcrdma_req *req, u32 hdrlen,
 			      struct xdr_buf *xdr,
-			      enum rpcrdma_chunktype rtype);
+			      enum rpcrdma_chunktype argtype);
 void rpcrdma_unmap_sendctx(struct rpcrdma_sendctx *sc);
 int rpcrdma_marshal_req(struct rpcrdma_xprt *r_xprt, struct rpc_rqst *rqst);
 void rpcrdma_set_max_header_sizes(struct rpcrdma_xprt *);

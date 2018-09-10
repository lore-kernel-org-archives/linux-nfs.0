Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:46872 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728072AbeIJUEH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Sep 2018 16:04:07 -0400
Subject: [PATCH v1 07/22] xprtrdma: Support Write+Reply Replies
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 10 Sep 2018 11:09:32 -0400
Message-ID: <20180910150932.10564.1879.stgit@manet.1015granger.net>
In-Reply-To: <20180910150040.10564.97487.stgit@manet.1015granger.net>
References: <20180910150040.10564.97487.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently the client handles a large NFS READ request by providing
the server with a Write chunk, and expecting that the non-payload
part of the RPC Reply will always fit inline.

When the inline threshold is small (for instance, when talking to a
server that uses a 1024-byte threshold) the non-payload part of the
Reply might not fit inline in certain rare cases. The server has to
drop the Reply or return an ERR_CHUNK and the RPC transaction fails.

Let's add a little logic to recognize when the non-payload part of
an NFS READ might be large, and marshal both a Write chunk and a
Reply chunk to enable the server to send the payload in the Write
chunk and the large non-payload part in the Reply chunk.

I've never seen this failure in the wild.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h  |    4 ++
 net/sunrpc/xprtrdma/rpc_rdma.c  |   63 +++++++++++++++++++++++++--------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    3 +-
 3 files changed, 46 insertions(+), 24 deletions(-)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index b9e6802..cd3e5e7 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -446,6 +446,7 @@
 TRACE_DEFINE_ENUM(rpcrdma_areadch);
 TRACE_DEFINE_ENUM(rpcrdma_writech);
 TRACE_DEFINE_ENUM(rpcrdma_replych);
+TRACE_DEFINE_ENUM(rpcrdma_writereply);
 
 #define xprtrdma_show_chunktype(x)					\
 		__print_symbolic(x,					\
@@ -453,7 +454,8 @@
 				{ rpcrdma_readch, "read list" },	\
 				{ rpcrdma_areadch, "*read list" },	\
 				{ rpcrdma_writech, "write list" },	\
-				{ rpcrdma_replych, "reply chunk" })
+				{ rpcrdma_replych, "reply chunk" },	\
+				{ rpcrdma_writereply, "write+reply" })
 
 TRACE_EVENT(xprtrdma_marshal,
 	TP_PROTO(
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 26640e6..3594562 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -202,21 +202,20 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
  */
 static int
 rpcrdma_convert_iovs(struct rpcrdma_xprt *r_xprt, struct xdr_buf *xdrbuf,
-		     unsigned int pos, struct rpcrdma_mr_seg *seg,
-		     bool omit_xdr_pad)
+		     unsigned int pos, unsigned int page_len,
+		     struct rpcrdma_mr_seg *seg, bool omit_xdr_pad)
 {
 	unsigned long page_base;
-	unsigned int len, n;
 	struct page **ppages;
+	unsigned int n;
 
 	n = 0;
 	if (pos == 0)
 		seg = rpcrdma_convert_kvec(&xdrbuf->head[0], seg, &n);
 
-	len = xdrbuf->page_len;
 	ppages = xdrbuf->pages + (xdrbuf->page_base >> PAGE_SHIFT);
 	page_base = offset_in_page(xdrbuf->page_base);
-	while (len) {
+	while (page_len) {
 		if (unlikely(!*ppages)) {
 			/* XXX: Certain upper layer operations do
 			 *	not provide receive buffer pages.
@@ -227,8 +226,8 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		}
 		seg->mr_page = *ppages;
 		seg->mr_offset = (char *)page_base;
-		seg->mr_len = min_t(u32, PAGE_SIZE - page_base, len);
-		len -= seg->mr_len;
+		seg->mr_len = min_t(u32, PAGE_SIZE - page_base, page_len);
+		page_len -= seg->mr_len;
 		++ppages;
 		++seg;
 		++n;
@@ -352,8 +351,9 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	}
 
 	seg = req->rl_segments;
-	nsegs = rpcrdma_convert_iovs(r_xprt, &rqst->rq_snd_buf, pos, seg,
-				     omit_xdr_pad);
+	nsegs = rpcrdma_convert_iovs(r_xprt, &rqst->rq_snd_buf, pos,
+				     rqst->rq_snd_buf.page_len,
+				     seg, omit_xdr_pad);
 	if (nsegs < 0)
 		return nsegs;
 
@@ -401,8 +401,13 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	int nsegs, nchunks;
 	__be32 *segcount;
 
-	if (restype != rpcrdma_writech)
+	switch (restype) {
+	case rpcrdma_writech:
+	case rpcrdma_writereply:
+		break;
+	default:
 		goto done;
+	}
 
 	/* When encoding a Write chunk, some servers need to see an
 	 * extra segment for non-XDR-aligned Write chunks. The upper
@@ -411,8 +416,9 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	 */
 	seg = req->rl_segments;
 	nsegs = rpcrdma_convert_iovs(r_xprt, &rqst->rq_rcv_buf,
-				     rqst->rq_rcv_buf.head[0].iov_len, seg,
-				     r_xprt->rx_ia.ri_implicit_roundup);
+				     rqst->rq_rcv_buf.head[0].iov_len,
+				     rqst->rq_rcv_buf.page_len,
+				     seg, r_xprt->rx_ia.ri_implicit_roundup);
 	if (nsegs < 0)
 		return nsegs;
 
@@ -468,14 +474,24 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	struct xdr_stream *xdr = &req->rl_stream;
 	struct rpcrdma_mr_seg *seg;
 	struct rpcrdma_mr *mr;
+	unsigned int page_len;
 	int nsegs, nchunks;
 	__be32 *segcount;
 
-	if (restype != rpcrdma_replych)
+	switch (restype) {
+	case rpcrdma_replych:
+		page_len = rqst->rq_rcv_buf.page_len;
+		break;
+	case rpcrdma_writereply:
+		page_len = 0;
+		break;
+	default:
 		return encode_item_not_present(xdr);
+	}
 
 	seg = req->rl_segments;
-	nsegs = rpcrdma_convert_iovs(r_xprt, &rqst->rq_rcv_buf, 0, seg, false);
+	nsegs = rpcrdma_convert_iovs(r_xprt, &rqst->rq_rcv_buf, 0,
+				     page_len, seg, false);
 	if (nsegs < 0)
 		return nsegs;
 
@@ -775,16 +791,21 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	 *
 	 * o If the expected result is under the inline threshold, all ops
 	 *   return as inline.
-	 * o Large read ops return data as write chunk(s), header as
-	 *   inline.
+	 * o Large read ops return data as a write chunk and
+	 *   small header as inline, large header as a reply chunk.
 	 * o Large non-read ops return as a single reply chunk.
 	 */
 	if (rpcrdma_results_inline(r_xprt, rqst))
 		restype = rpcrdma_noch;
-	else if (ddp_allowed && rqst->rq_rcv_buf.flags & XDRBUF_READ)
+	else if (ddp_allowed && rqst->rq_rcv_buf.flags & XDRBUF_READ) {
 		restype = rpcrdma_writech;
-	else
+		if ((rqst->rq_rcv_buf.head[0].iov_len +
+		     rqst->rq_rcv_buf.tail[0].iov_len) >
+		    r_xprt->rx_ia.ri_max_inline_read)
+			restype = rpcrdma_writereply;
+	} else {
 		restype = rpcrdma_replych;
+	}
 
 	/*
 	 * Chunks needed for arguments?
@@ -1163,14 +1184,12 @@ static int decode_reply_chunk(struct xdr_stream *xdr, u32 *length)
 		return -EIO;
 
 	/* RDMA_NOMSG sanity checks */
-	if (unlikely(writelist))
-		return -EIO;
 	if (unlikely(!replychunk))
 		return -EIO;
 
 	/* Reply chunk buffer already is the reply vector */
-	r_xprt->rx_stats.total_rdma_reply += replychunk;
-	return replychunk;
+	r_xprt->rx_stats.total_rdma_reply += writelist + replychunk;
+	return writelist + replychunk;
 }
 
 static noinline int
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index d29bf38..5e19bb59 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -627,7 +627,8 @@ enum rpcrdma_chunktype {
 	rpcrdma_readch,
 	rpcrdma_areadch,
 	rpcrdma_writech,
-	rpcrdma_replych
+	rpcrdma_replych,
+	rpcrdma_writereply,
 };
 
 int rpcrdma_prepare_send_sges(struct rpcrdma_xprt *r_xprt,

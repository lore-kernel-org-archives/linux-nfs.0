Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33763 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932473AbcFODRh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2016 23:17:37 -0400
Subject: [PATCH v2 17/24] xprtrdma: Chunk list encoders no longer share one
 rl_segments array
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 14 Jun 2016 23:17:35 -0400
Message-ID: <20160615031734.14794.83510.stgit@manet.1015granger.net>
In-Reply-To: <20160615030626.14794.43805.stgit@manet.1015granger.net>
References: <20160615030626.14794.43805.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, all three chunk list encoders each use a portion of the
one rl_segments array in rpcrdma_req. This is because the MWs for
each chunk list were preserved in rl_segments so that ro_unmap could
find and invalidate them after the RPC was complete.

However, now that MWs are placed on a per-req linked list as they
are registered, there is no longer any information in rpcrdma_mr_seg
that is shared between ro_map and ro_unmap_{sync,safe}, and thus
nothing in rl_segments needs to be preserved after
rpcrdma_marshal_req is complete.

Thus the rl_segments array can be used now just for the needs of
each rpcrdma_convert_iovs call. Once each chunk list is encoded, the
next chunk list encoder is free to re-use all of rl_segments.

This means all three chunk lists in one RPC request can now each
encode a full size data payload with no increase in the size of
rl_segments.

This is a key requirement for Kerberos support, since both the Call
and Reply for a single RPC transaction are conveyed via Long
messages (RDMA Read/Write). Both can be large.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   61 ++++++++++++++++++---------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |   36 ++++++++++-------------
 2 files changed, 44 insertions(+), 53 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 6d34c1f..f60d229 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -196,8 +196,7 @@ rpcrdma_tail_pullup(struct xdr_buf *buf)
  * MR when they can.
  */
 static int
-rpcrdma_convert_kvec(struct kvec *vec, struct rpcrdma_mr_seg *seg,
-		     int n, int nsegs)
+rpcrdma_convert_kvec(struct kvec *vec, struct rpcrdma_mr_seg *seg, int n)
 {
 	size_t page_offset;
 	u32 remaining;
@@ -206,7 +205,7 @@ rpcrdma_convert_kvec(struct kvec *vec, struct rpcrdma_mr_seg *seg,
 	base = vec->iov_base;
 	page_offset = offset_in_page(base);
 	remaining = vec->iov_len;
-	while (remaining && n < nsegs) {
+	while (remaining && n < RPCRDMA_MAX_SEGS) {
 		seg[n].mr_page = NULL;
 		seg[n].mr_offset = base;
 		seg[n].mr_len = min_t(u32, PAGE_SIZE - page_offset, remaining);
@@ -230,23 +229,23 @@ rpcrdma_convert_kvec(struct kvec *vec, struct rpcrdma_mr_seg *seg,
 
 static int
 rpcrdma_convert_iovs(struct xdr_buf *xdrbuf, unsigned int pos,
-	enum rpcrdma_chunktype type, struct rpcrdma_mr_seg *seg, int nsegs)
+	enum rpcrdma_chunktype type, struct rpcrdma_mr_seg *seg)
 {
-	int len, n = 0, p;
-	int page_base;
+	int len, n, p, page_base;
 	struct page **ppages;
 
+	n = 0;
 	if (pos == 0) {
-		n = rpcrdma_convert_kvec(&xdrbuf->head[0], seg, n, nsegs);
-		if (n == nsegs)
-			return -EIO;
+		n = rpcrdma_convert_kvec(&xdrbuf->head[0], seg, n);
+		if (n == RPCRDMA_MAX_SEGS)
+			goto out_overflow;
 	}
 
 	len = xdrbuf->page_len;
 	ppages = xdrbuf->pages + (xdrbuf->page_base >> PAGE_SHIFT);
 	page_base = xdrbuf->page_base & ~PAGE_MASK;
 	p = 0;
-	while (len && n < nsegs) {
+	while (len && n < RPCRDMA_MAX_SEGS) {
 		if (!ppages[p]) {
 			/* alloc the pagelist for receiving buffer */
 			ppages[p] = alloc_page(GFP_ATOMIC);
@@ -257,7 +256,7 @@ rpcrdma_convert_iovs(struct xdr_buf *xdrbuf, unsigned int pos,
 		seg[n].mr_offset = (void *)(unsigned long) page_base;
 		seg[n].mr_len = min_t(u32, PAGE_SIZE - page_base, len);
 		if (seg[n].mr_len > PAGE_SIZE)
-			return -EIO;
+			goto out_overflow;
 		len -= seg[n].mr_len;
 		++n;
 		++p;
@@ -265,8 +264,8 @@ rpcrdma_convert_iovs(struct xdr_buf *xdrbuf, unsigned int pos,
 	}
 
 	/* Message overflows the seg array */
-	if (len && n == nsegs)
-		return -EIO;
+	if (len && n == RPCRDMA_MAX_SEGS)
+		goto out_overflow;
 
 	/* When encoding the read list, the tail is always sent inline */
 	if (type == rpcrdma_readch)
@@ -277,12 +276,16 @@ rpcrdma_convert_iovs(struct xdr_buf *xdrbuf, unsigned int pos,
 		 * xdr pad bytes, saving the server an RDMA operation. */
 		if (xdrbuf->tail[0].iov_len < 4 && xprt_rdma_pad_optimize)
 			return n;
-		n = rpcrdma_convert_kvec(&xdrbuf->tail[0], seg, n, nsegs);
-		if (n == nsegs)
-			return -EIO;
+		n = rpcrdma_convert_kvec(&xdrbuf->tail[0], seg, n);
+		if (n == RPCRDMA_MAX_SEGS)
+			goto out_overflow;
 	}
 
 	return n;
+
+out_overflow:
+	pr_err("rpcrdma: segment array overflow\n");
+	return -EIO;
 }
 
 static inline __be32 *
@@ -310,7 +313,7 @@ rpcrdma_encode_read_list(struct rpcrdma_xprt *r_xprt,
 			 struct rpcrdma_req *req, struct rpc_rqst *rqst,
 			 __be32 *iptr, enum rpcrdma_chunktype rtype)
 {
-	struct rpcrdma_mr_seg *seg = req->rl_nextseg;
+	struct rpcrdma_mr_seg *seg;
 	struct rpcrdma_mw *mw;
 	unsigned int pos;
 	int n, nsegs;
@@ -323,8 +326,8 @@ rpcrdma_encode_read_list(struct rpcrdma_xprt *r_xprt,
 	pos = rqst->rq_snd_buf.head[0].iov_len;
 	if (rtype == rpcrdma_areadch)
 		pos = 0;
-	nsegs = rpcrdma_convert_iovs(&rqst->rq_snd_buf, pos, rtype, seg,
-				     RPCRDMA_MAX_SEGS - req->rl_nchunks);
+	seg = req->rl_segments;
+	nsegs = rpcrdma_convert_iovs(&rqst->rq_snd_buf, pos, rtype, seg);
 	if (nsegs < 0)
 		return ERR_PTR(nsegs);
 
@@ -349,11 +352,9 @@ rpcrdma_encode_read_list(struct rpcrdma_xprt *r_xprt,
 			mw->mw_handle, n < nsegs ? "more" : "last");
 
 		r_xprt->rx_stats.read_chunk_count++;
-		req->rl_nchunks++;
 		seg += n;
 		nsegs -= n;
 	} while (nsegs);
-	req->rl_nextseg = seg;
 
 	/* Finish Read list */
 	*iptr++ = xdr_zero;	/* Next item not present */
@@ -377,7 +378,7 @@ rpcrdma_encode_write_list(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 			  struct rpc_rqst *rqst, __be32 *iptr,
 			  enum rpcrdma_chunktype wtype)
 {
-	struct rpcrdma_mr_seg *seg = req->rl_nextseg;
+	struct rpcrdma_mr_seg *seg;
 	struct rpcrdma_mw *mw;
 	int n, nsegs, nchunks;
 	__be32 *segcount;
@@ -387,10 +388,10 @@ rpcrdma_encode_write_list(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 		return iptr;
 	}
 
+	seg = req->rl_segments;
 	nsegs = rpcrdma_convert_iovs(&rqst->rq_rcv_buf,
 				     rqst->rq_rcv_buf.head[0].iov_len,
-				     wtype, seg,
-				     RPCRDMA_MAX_SEGS - req->rl_nchunks);
+				     wtype, seg);
 	if (nsegs < 0)
 		return ERR_PTR(nsegs);
 
@@ -414,12 +415,10 @@ rpcrdma_encode_write_list(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 
 		r_xprt->rx_stats.write_chunk_count++;
 		r_xprt->rx_stats.total_rdma_request += seg->mr_len;
-		req->rl_nchunks++;
 		nchunks++;
 		seg   += n;
 		nsegs -= n;
 	} while (nsegs);
-	req->rl_nextseg = seg;
 
 	/* Update count of segments in this Write chunk */
 	*segcount = cpu_to_be32(nchunks);
@@ -446,7 +445,7 @@ rpcrdma_encode_reply_chunk(struct rpcrdma_xprt *r_xprt,
 			   struct rpcrdma_req *req, struct rpc_rqst *rqst,
 			   __be32 *iptr, enum rpcrdma_chunktype wtype)
 {
-	struct rpcrdma_mr_seg *seg = req->rl_nextseg;
+	struct rpcrdma_mr_seg *seg;
 	struct rpcrdma_mw *mw;
 	int n, nsegs, nchunks;
 	__be32 *segcount;
@@ -456,8 +455,8 @@ rpcrdma_encode_reply_chunk(struct rpcrdma_xprt *r_xprt,
 		return iptr;
 	}
 
-	nsegs = rpcrdma_convert_iovs(&rqst->rq_rcv_buf, 0, wtype, seg,
-				     RPCRDMA_MAX_SEGS - req->rl_nchunks);
+	seg = req->rl_segments;
+	nsegs = rpcrdma_convert_iovs(&rqst->rq_rcv_buf, 0, wtype, seg);
 	if (nsegs < 0)
 		return ERR_PTR(nsegs);
 
@@ -481,12 +480,10 @@ rpcrdma_encode_reply_chunk(struct rpcrdma_xprt *r_xprt,
 
 		r_xprt->rx_stats.reply_chunk_count++;
 		r_xprt->rx_stats.total_rdma_request += seg->mr_len;
-		req->rl_nchunks++;
 		nchunks++;
 		seg   += n;
 		nsegs -= n;
 	} while (nsegs);
-	req->rl_nextseg = seg;
 
 	/* Update count of segments in the Reply chunk */
 	*segcount = cpu_to_be32(nchunks);
@@ -656,8 +653,6 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	 * send a Call message with a Position Zero Read chunk and a
 	 * regular Read chunk at the same time.
 	 */
-	req->rl_nchunks = 0;
-	req->rl_nextseg = req->rl_segments;
 	iptr = headerp->rm_body.rm_chunks;
 	iptr = rpcrdma_encode_read_list(r_xprt, req, rqst, iptr, rtype);
 	if (IS_ERR(iptr))
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 025365c..c713483 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -171,23 +171,14 @@ rdmab_to_msg(struct rpcrdma_regbuf *rb)
  *   o recv buffer (posted to provider)
  *   o ib_sge (also donated to provider)
  *   o status of reply (length, success or not)
- *   o bookkeeping state to get run by tasklet (list, etc)
+ *   o bookkeeping state to get run by reply handler (list, etc)
  *
- * These are allocated during initialization, per-transport instance;
- * however, the tasklet execution list itself is global, as it should
- * always be pretty short.
+ * These are allocated during initialization, per-transport instance.
  *
  * N of these are associated with a transport instance, and stored in
  * struct rpcrdma_buffer. N is the max number of outstanding requests.
  */
 
-#define RPCRDMA_MAX_DATA_SEGS	((1 * 1024 * 1024) / PAGE_SIZE)
-
-/* data segments + head/tail for Call + head/tail for Reply */
-#define RPCRDMA_MAX_SEGS 	(RPCRDMA_MAX_DATA_SEGS + 4)
-
-struct rpcrdma_buffer;
-
 struct rpcrdma_rep {
 	struct ib_cqe		rr_cqe;
 	unsigned int		rr_len;
@@ -267,13 +258,18 @@ struct rpcrdma_mw {
  * of iovs for send operations. The reason is that the iovs passed to
  * ib_post_{send,recv} must not be modified until the work request
  * completes.
- *
- * NOTES:
- *   o RPCRDMA_MAX_SEGS is the max number of addressible chunk elements we
- *     marshal. The number needed varies depending on the iov lists that
- *     are passed to us and the memory registration mode we are in.
  */
 
+/* Maximum number of page-sized "segments" per chunk list to be
+ * registered or invalidated. Must handle a Reply chunk:
+ */
+enum {
+	RPCRDMA_MAX_IOV_SEGS	= 3,
+	RPCRDMA_MAX_DATA_SEGS	= ((1 * 1024 * 1024) / PAGE_SIZE) + 1,
+	RPCRDMA_MAX_SEGS	= RPCRDMA_MAX_DATA_SEGS +
+				  RPCRDMA_MAX_IOV_SEGS,
+};
+
 struct rpcrdma_mr_seg {		/* chunk descriptors */
 	u32		mr_len;		/* length of chunk or segment */
 	struct page	*mr_page;	/* owning page, if any */
@@ -282,10 +278,10 @@ struct rpcrdma_mr_seg {		/* chunk descriptors */
 
 #define RPCRDMA_MAX_IOVS	(2)
 
+struct rpcrdma_buffer;
 struct rpcrdma_req {
 	struct list_head	rl_free;
 	unsigned int		rl_niovs;
-	unsigned int		rl_nchunks;
 	unsigned int		rl_connect_cookie;
 	struct rpc_task		*rl_task;
 	struct rpcrdma_buffer	*rl_buffer;
@@ -293,13 +289,13 @@ struct rpcrdma_req {
 	struct ib_sge		rl_send_iov[RPCRDMA_MAX_IOVS];
 	struct rpcrdma_regbuf	*rl_rdmabuf;
 	struct rpcrdma_regbuf	*rl_sendbuf;
-	struct list_head	rl_registered;	/* registered segments */
-	struct rpcrdma_mr_seg	rl_segments[RPCRDMA_MAX_SEGS];
-	struct rpcrdma_mr_seg	*rl_nextseg;
 
 	struct ib_cqe		rl_cqe;
 	struct list_head	rl_all;
 	bool			rl_backchannel;
+
+	struct list_head	rl_registered;	/* registered segments */
+	struct rpcrdma_mr_seg	rl_segments[RPCRDMA_MAX_SEGS];
 };
 
 static inline struct rpcrdma_req *


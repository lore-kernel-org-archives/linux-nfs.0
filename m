Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36845 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755040AbcDKULR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Apr 2016 16:11:17 -0400
Subject: [PATCH v1 08/18] xprtrdma: Remove rpcrdma_create_chunks()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 11 Apr 2016 16:11:15 -0400
Message-ID: <20160411201115.20531.99208.stgit@manet.1015granger.net>
In-Reply-To: <20160411200323.20531.8893.stgit@manet.1015granger.net>
References: <20160411200323.20531.8893.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpcrdma_create_chunks() has been replaced, and can be removed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |  151 ----------------------------------------
 1 file changed, 151 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index e80f43d..9ebaf79 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -285,157 +285,6 @@ rpcrdma_convert_iovs(struct xdr_buf *xdrbuf, unsigned int pos,
 	return n;
 }
 
-/*
- * Create read/write chunk lists, and reply chunks, for RDMA
- *
- *   Assume check against THRESHOLD has been done, and chunks are required.
- *   Assume only encoding one list entry for read|write chunks. The NFSv3
- *     protocol is simple enough to allow this as it only has a single "bulk
- *     result" in each procedure - complicated NFSv4 COMPOUNDs are not. (The
- *     RDMA/Sessions NFSv4 proposal addresses this for future v4 revs.)
- *
- * When used for a single reply chunk (which is a special write
- * chunk used for the entire reply, rather than just the data), it
- * is used primarily for READDIR and READLINK which would otherwise
- * be severely size-limited by a small rdma inline read max. The server
- * response will come back as an RDMA Write, followed by a message
- * of type RDMA_NOMSG carrying the xid and length. As a result, reply
- * chunks do not provide data alignment, however they do not require
- * "fixup" (moving the response to the upper layer buffer) either.
- *
- * Encoding key for single-list chunks (HLOO = Handle32 Length32 Offset64):
- *
- *  Read chunklist (a linked list):
- *   N elements, position P (same P for all chunks of same arg!):
- *    1 - PHLOO - 1 - PHLOO - ... - 1 - PHLOO - 0
- *
- *  Write chunklist (a list of (one) counted array):
- *   N elements:
- *    1 - N - HLOO - HLOO - ... - HLOO - 0
- *
- *  Reply chunk (a counted array):
- *   N elements:
- *    1 - N - HLOO - HLOO - ... - HLOO
- *
- * Returns positive RPC/RDMA header size, or negative errno.
- */
-
-static ssize_t
-rpcrdma_create_chunks(struct rpc_rqst *rqst, struct xdr_buf *target,
-		struct rpcrdma_msg *headerp, enum rpcrdma_chunktype type)
-{
-	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
-	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(rqst->rq_xprt);
-	int n, nsegs, nchunks = 0;
-	unsigned int pos;
-	struct rpcrdma_mr_seg *seg = req->rl_segments;
-	struct rpcrdma_read_chunk *cur_rchunk = NULL;
-	struct rpcrdma_write_array *warray = NULL;
-	struct rpcrdma_write_chunk *cur_wchunk = NULL;
-	__be32 *iptr = headerp->rm_body.rm_chunks;
-	int (*map)(struct rpcrdma_xprt *, struct rpcrdma_mr_seg *, int, bool);
-
-	if (type == rpcrdma_readch || type == rpcrdma_areadch) {
-		/* a read chunk - server will RDMA Read our memory */
-		cur_rchunk = (struct rpcrdma_read_chunk *) iptr;
-	} else {
-		/* a write or reply chunk - server will RDMA Write our memory */
-		*iptr++ = xdr_zero;	/* encode a NULL read chunk list */
-		if (type == rpcrdma_replych)
-			*iptr++ = xdr_zero;	/* a NULL write chunk list */
-		warray = (struct rpcrdma_write_array *) iptr;
-		cur_wchunk = (struct rpcrdma_write_chunk *) (warray + 1);
-	}
-
-	if (type == rpcrdma_replych || type == rpcrdma_areadch)
-		pos = 0;
-	else
-		pos = target->head[0].iov_len;
-
-	nsegs = rpcrdma_convert_iovs(target, pos, type, seg, RPCRDMA_MAX_SEGS);
-	if (nsegs < 0)
-		return nsegs;
-
-	map = r_xprt->rx_ia.ri_ops->ro_map;
-	do {
-		n = map(r_xprt, seg, nsegs, cur_wchunk != NULL);
-		if (n <= 0)
-			goto out;
-		if (cur_rchunk) {	/* read */
-			cur_rchunk->rc_discrim = xdr_one;
-			/* all read chunks have the same "position" */
-			cur_rchunk->rc_position = cpu_to_be32(pos);
-			cur_rchunk->rc_target.rs_handle =
-						cpu_to_be32(seg->mr_rkey);
-			cur_rchunk->rc_target.rs_length =
-						cpu_to_be32(seg->mr_len);
-			xdr_encode_hyper(
-					(__be32 *)&cur_rchunk->rc_target.rs_offset,
-					seg->mr_base);
-			dprintk("RPC:       %s: read chunk "
-				"elem %d@0x%llx:0x%x pos %u (%s)\n", __func__,
-				seg->mr_len, (unsigned long long)seg->mr_base,
-				seg->mr_rkey, pos, n < nsegs ? "more" : "last");
-			cur_rchunk++;
-			r_xprt->rx_stats.read_chunk_count++;
-		} else {		/* write/reply */
-			cur_wchunk->wc_target.rs_handle =
-						cpu_to_be32(seg->mr_rkey);
-			cur_wchunk->wc_target.rs_length =
-						cpu_to_be32(seg->mr_len);
-			xdr_encode_hyper(
-					(__be32 *)&cur_wchunk->wc_target.rs_offset,
-					seg->mr_base);
-			dprintk("RPC:       %s: %s chunk "
-				"elem %d@0x%llx:0x%x (%s)\n", __func__,
-				(type == rpcrdma_replych) ? "reply" : "write",
-				seg->mr_len, (unsigned long long)seg->mr_base,
-				seg->mr_rkey, n < nsegs ? "more" : "last");
-			cur_wchunk++;
-			if (type == rpcrdma_replych)
-				r_xprt->rx_stats.reply_chunk_count++;
-			else
-				r_xprt->rx_stats.write_chunk_count++;
-			r_xprt->rx_stats.total_rdma_request += seg->mr_len;
-		}
-		nchunks++;
-		seg   += n;
-		nsegs -= n;
-	} while (nsegs);
-
-	/* success. all failures return above */
-	req->rl_nchunks = nchunks;
-
-	/*
-	 * finish off header. If write, marshal discrim and nchunks.
-	 */
-	if (cur_rchunk) {
-		iptr = (__be32 *) cur_rchunk;
-		*iptr++ = xdr_zero;	/* finish the read chunk list */
-		*iptr++ = xdr_zero;	/* encode a NULL write chunk list */
-		*iptr++ = xdr_zero;	/* encode a NULL reply chunk */
-	} else {
-		warray->wc_discrim = xdr_one;
-		warray->wc_nchunks = cpu_to_be32(nchunks);
-		iptr = (__be32 *) cur_wchunk;
-		if (type == rpcrdma_writech) {
-			*iptr++ = xdr_zero; /* finish the write chunk list */
-			*iptr++ = xdr_zero; /* encode a NULL reply chunk */
-		}
-	}
-
-	/*
-	 * Return header size.
-	 */
-	return (unsigned char *)iptr - (unsigned char *)headerp;
-
-out:
-	for (pos = 0; nchunks--;)
-		pos += r_xprt->rx_ia.ri_ops->ro_unmap(r_xprt,
-						      &req->rl_segments[pos]);
-	return n;
-}
-
 static inline __be32 *
 xdr_encode_rdma_segment(__be32 *iptr, struct rpcrdma_mr_seg *seg)
 {


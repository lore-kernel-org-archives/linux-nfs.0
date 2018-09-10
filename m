Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:37022 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728072AbeIJUD4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Sep 2018 16:03:56 -0400
Subject: [PATCH v1 05/22] xprtrdma: Refactor chunk encoding
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 10 Sep 2018 11:09:22 -0400
Message-ID: <20180910150922.10564.50999.stgit@manet.1015granger.net>
In-Reply-To: <20180910150040.10564.97487.stgit@manet.1015granger.net>
References: <20180910150040.10564.97487.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the "not present" case into the individual chunk encoders. This
improves code organization and readability, and prepares the marsh-
aling code path for handling cases like "Write + Reply".

The reason for the original organization was to optimize this code
path for the case where there there are no chunks. The optimization
was inconsequential.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |   37 ++++++++++++++++---------------------
 1 file changed, 16 insertions(+), 21 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index ec4b1f9..39996df 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -346,6 +346,9 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	unsigned int pos;
 	int nsegs;
 
+	if (rtype == rpcrdma_noch)
+		goto done;
+
 	pos = rqst->rq_snd_buf.head[0].iov_len;
 	if (rtype == rpcrdma_areadch)
 		pos = 0;
@@ -370,7 +373,8 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		nsegs -= mr->mr_nents;
 	} while (nsegs);
 
-	return 0;
+done:
+	return encode_item_not_present(xdr);
 }
 
 /* Register and XDR encode the Write list. Supports encoding a list
@@ -398,6 +402,9 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	int nsegs, nchunks;
 	__be32 *segcount;
 
+	if (wtype != rpcrdma_writech)
+		goto done;
+
 	seg = req->rl_segments;
 	nsegs = rpcrdma_convert_iovs(r_xprt, &rqst->rq_rcv_buf,
 				     rqst->rq_rcv_buf.head[0].iov_len,
@@ -433,7 +440,8 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	/* Update count of segments in this Write chunk */
 	*segcount = cpu_to_be32(nchunks);
 
-	return 0;
+done:
+	return encode_item_not_present(xdr);
 }
 
 /* Register and XDR encode the Reply chunk. Supports encoding an array
@@ -458,6 +466,9 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	int nsegs, nchunks;
 	__be32 *segcount;
 
+	if (wtype != rpcrdma_replych)
+		return encode_item_not_present(xdr);
+
 	seg = req->rl_segments;
 	nsegs = rpcrdma_convert_iovs(r_xprt, &rqst->rq_rcv_buf, 0, wtype, seg);
 	if (nsegs < 0)
@@ -828,31 +839,15 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	 * send a Call message with a Position Zero Read chunk and a
 	 * regular Read chunk at the same time.
 	 */
-	if (rtype != rpcrdma_noch) {
-		ret = rpcrdma_encode_read_list(r_xprt, req, rqst, rtype);
-		if (ret)
-			goto out_err;
-	}
-	ret = encode_item_not_present(xdr);
+	ret = rpcrdma_encode_read_list(r_xprt, req, rqst, rtype);
 	if (ret)
 		goto out_err;
-
-	if (wtype == rpcrdma_writech) {
-		ret = rpcrdma_encode_write_list(r_xprt, req, rqst, wtype);
-		if (ret)
-			goto out_err;
-	}
-	ret = encode_item_not_present(xdr);
+	ret = rpcrdma_encode_write_list(r_xprt, req, rqst, wtype);
 	if (ret)
 		goto out_err;
-
-	if (wtype != rpcrdma_replych)
-		ret = encode_item_not_present(xdr);
-	else
-		ret = rpcrdma_encode_reply_chunk(r_xprt, req, rqst, wtype);
+	ret = rpcrdma_encode_reply_chunk(r_xprt, req, rqst, wtype);
 	if (ret)
 		goto out_err;
-
 	trace_xprtrdma_marshal(rqst, xdr_stream_pos(xdr), rtype, wtype);
 
 	ret = rpcrdma_prepare_send_sges(r_xprt, req, xdr_stream_pos(xdr),

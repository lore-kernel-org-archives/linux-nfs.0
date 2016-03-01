Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:32912 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084AbcCASFi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Mar 2016 13:05:38 -0500
Subject: [PATCH v5 02/14] svcrdma: Find client-provided write and reply
 chunks once per reply
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 01 Mar 2016 13:05:36 -0500
Message-ID: <20160301180536.2492.48267.stgit@klimt.1015granger.net>
In-Reply-To: <20160301180337.2492.4255.stgit@klimt.1015granger.net>
References: <20160301180337.2492.4255.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The client provides the location of Write chunks into which the
server writes bulk payload. The client provides these when the
Upper Layer Protocol wants direct data placement and the Binding
allows it. (For NFS, this is READ and READLINK operations).

The client also provides the location of a Reply chunk into which
the server writes the non-bulk part of an RPC reply. The client
provides this chunk whenever it believes the reply can be larger
than its receive buffers.

The server then uses the presence of these chunks to determine how
it will form its reply message.

svc_rdma_sendto() was looking for Write and Reply chunks multiple
times for every reply message. It would be more efficient to do it
just once.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c |   80 +++++++++++++++------------------
 1 file changed, 36 insertions(+), 44 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index df57f3c..79fa661 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -166,10 +166,10 @@ svc_rdma_get_write_array(struct rpcrdma_msg *rmsgp)
  * reply array is present
  */
 static struct rpcrdma_write_array *
-svc_rdma_get_reply_array(struct rpcrdma_msg *rmsgp)
+svc_rdma_get_reply_array(struct rpcrdma_msg *rmsgp,
+			 struct rpcrdma_write_array *wr_ary)
 {
 	struct rpcrdma_read_chunk *rch;
-	struct rpcrdma_write_array *wr_ary;
 	struct rpcrdma_write_array *rp_ary;
 
 	/* XXX: Need to fix when reply chunk may occur with read list
@@ -191,7 +191,6 @@ svc_rdma_get_reply_array(struct rpcrdma_msg *rmsgp)
 		goto found_it;
 	}
 
-	wr_ary = svc_rdma_get_write_array(rmsgp);
 	if (wr_ary) {
 		int chunk = be32_to_cpu(wr_ary->wc_nchunks);
 
@@ -302,8 +301,9 @@ static int send_write(struct svcxprt_rdma *xprt, struct svc_rqst *rqstp,
 	return -EIO;
 }
 
+noinline
 static int send_write_chunks(struct svcxprt_rdma *xprt,
-			     struct rpcrdma_msg *rdma_argp,
+			     struct rpcrdma_write_array *wr_ary,
 			     struct rpcrdma_msg *rdma_resp,
 			     struct svc_rqst *rqstp,
 			     struct svc_rdma_req_map *vec)
@@ -314,25 +314,21 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
 	int chunk_off;
 	int chunk_no;
 	int nchunks;
-	struct rpcrdma_write_array *arg_ary;
 	struct rpcrdma_write_array *res_ary;
 	int ret;
 
-	arg_ary = svc_rdma_get_write_array(rdma_argp);
-	if (!arg_ary)
-		return 0;
 	res_ary = (struct rpcrdma_write_array *)
 		&rdma_resp->rm_body.rm_chunks[1];
 
 	/* Write chunks start at the pagelist */
-	nchunks = be32_to_cpu(arg_ary->wc_nchunks);
+	nchunks = be32_to_cpu(wr_ary->wc_nchunks);
 	for (xdr_off = rqstp->rq_res.head[0].iov_len, chunk_no = 0;
 	     xfer_len && chunk_no < nchunks;
 	     chunk_no++) {
 		struct rpcrdma_segment *arg_ch;
 		u64 rs_offset;
 
-		arg_ch = &arg_ary->wc_array[chunk_no].wc_target;
+		arg_ch = &wr_ary->wc_array[chunk_no].wc_target;
 		write_len = min(xfer_len, be32_to_cpu(arg_ch->rs_length));
 
 		/* Prepare the response chunk given the length actually
@@ -350,11 +346,8 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
 					 xdr_off,
 					 write_len,
 					 vec);
-			if (ret <= 0) {
-				dprintk("svcrdma: RDMA_WRITE failed, ret=%d\n",
-					ret);
-				return -EIO;
-			}
+			if (ret <= 0)
+				goto out_err;
 			chunk_off += ret;
 			xdr_off += ret;
 			xfer_len -= ret;
@@ -365,10 +358,15 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
 	svc_rdma_xdr_encode_write_list(rdma_resp, chunk_no);
 
 	return rqstp->rq_res.page_len + rqstp->rq_res.tail[0].iov_len;
+
+out_err:
+	pr_err("svcrdma: failed to send write chunks, rc=%d\n", ret);
+	return -EIO;
 }
 
+noinline
 static int send_reply_chunks(struct svcxprt_rdma *xprt,
-			     struct rpcrdma_msg *rdma_argp,
+			     struct rpcrdma_write_array *rp_ary,
 			     struct rpcrdma_msg *rdma_resp,
 			     struct svc_rqst *rqstp,
 			     struct svc_rdma_req_map *vec)
@@ -380,25 +378,21 @@ static int send_reply_chunks(struct svcxprt_rdma *xprt,
 	int chunk_off;
 	int nchunks;
 	struct rpcrdma_segment *ch;
-	struct rpcrdma_write_array *arg_ary;
 	struct rpcrdma_write_array *res_ary;
 	int ret;
 
-	arg_ary = svc_rdma_get_reply_array(rdma_argp);
-	if (!arg_ary)
-		return 0;
 	/* XXX: need to fix when reply lists occur with read-list and or
 	 * write-list */
 	res_ary = (struct rpcrdma_write_array *)
 		&rdma_resp->rm_body.rm_chunks[2];
 
 	/* xdr offset starts at RPC message */
-	nchunks = be32_to_cpu(arg_ary->wc_nchunks);
+	nchunks = be32_to_cpu(rp_ary->wc_nchunks);
 	for (xdr_off = 0, chunk_no = 0;
 	     xfer_len && chunk_no < nchunks;
 	     chunk_no++) {
 		u64 rs_offset;
-		ch = &arg_ary->wc_array[chunk_no].wc_target;
+		ch = &rp_ary->wc_array[chunk_no].wc_target;
 		write_len = min(xfer_len, be32_to_cpu(ch->rs_length));
 
 		/* Prepare the reply chunk given the length actually
@@ -415,11 +409,8 @@ static int send_reply_chunks(struct svcxprt_rdma *xprt,
 					 xdr_off,
 					 write_len,
 					 vec);
-			if (ret <= 0) {
-				dprintk("svcrdma: RDMA_WRITE failed, ret=%d\n",
-					ret);
-				return -EIO;
-			}
+			if (ret <= 0)
+				goto out_err;
 			chunk_off += ret;
 			xdr_off += ret;
 			xfer_len -= ret;
@@ -430,6 +421,10 @@ static int send_reply_chunks(struct svcxprt_rdma *xprt,
 	svc_rdma_xdr_encode_reply_array(res_ary, chunk_no);
 
 	return rqstp->rq_res.len;
+
+out_err:
+	pr_err("svcrdma: failed to send reply chunks, rc=%d\n", ret);
+	return -EIO;
 }
 
 /* This function prepares the portion of the RPCRDMA message to be
@@ -573,7 +568,7 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 		container_of(xprt, struct svcxprt_rdma, sc_xprt);
 	struct rpcrdma_msg *rdma_argp;
 	struct rpcrdma_msg *rdma_resp;
-	struct rpcrdma_write_array *reply_ary;
+	struct rpcrdma_write_array *wr_ary, *rp_ary;
 	enum rpcrdma_proc reply_type;
 	int ret;
 	int inline_bytes;
@@ -587,6 +582,8 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 	 * places this at the start of page 0.
 	 */
 	rdma_argp = page_address(rqstp->rq_pages[0]);
+	wr_ary = svc_rdma_get_write_array(rdma_argp);
+	rp_ary = svc_rdma_get_reply_array(rdma_argp, wr_ary);
 
 	/* Build an req vec for the XDR */
 	ctxt = svc_rdma_get_context(rdma);
@@ -603,8 +600,7 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 	if (!res_page)
 		goto err0;
 	rdma_resp = page_address(res_page);
-	reply_ary = svc_rdma_get_reply_array(rdma_argp);
-	if (reply_ary)
+	if (rp_ary)
 		reply_type = RDMA_NOMSG;
 	else
 		reply_type = RDMA_MSG;
@@ -612,24 +608,20 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 					 rdma_resp, reply_type);
 
 	/* Send any write-chunk data and build resp write-list */
-	ret = send_write_chunks(rdma, rdma_argp, rdma_resp,
-				rqstp, vec);
-	if (ret < 0) {
-		printk(KERN_ERR "svcrdma: failed to send write chunks, rc=%d\n",
-		       ret);
-		goto err1;
+	if (wr_ary) {
+		ret = send_write_chunks(rdma, wr_ary, rdma_resp, rqstp, vec);
+		if (ret < 0)
+			goto err1;
+		inline_bytes -= ret;
 	}
-	inline_bytes -= ret;
 
 	/* Send any reply-list data and update resp reply-list */
-	ret = send_reply_chunks(rdma, rdma_argp, rdma_resp,
-				rqstp, vec);
-	if (ret < 0) {
-		printk(KERN_ERR "svcrdma: failed to send reply chunks, rc=%d\n",
-		       ret);
-		goto err1;
+	if (rp_ary) {
+		ret = send_reply_chunks(rdma, rp_ary, rdma_resp, rqstp, vec);
+		if (ret < 0)
+			goto err1;
+		inline_bytes -= ret;
 	}
-	inline_bytes -= ret;
 
 	ret = send_reply(rdma, rqstp, res_page, rdma_resp, ctxt, vec,
 			 inline_bytes);


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:33928 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392AbcEDOxt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 May 2016 10:53:49 -0400
Subject: [PATCH v2 8/9] svcrdma: Generalize svc_rdma_xdr_decode_req()
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 04 May 2016 10:53:47 -0400
Message-ID: <20160504145347.6602.42108.stgit@klimt.1015granger.net>
In-Reply-To: <20160504144730.6602.89073.stgit@klimt.1015granger.net>
References: <20160504144730.6602.89073.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Pass in just the piece of the svc_rqst that is needed
here.

While we're in the area, add an informative documenting comment.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h         |    2 +-
 net/sunrpc/xprtrdma/svc_rdma_marshal.c  |   32 +++++++++++++++++++++----------
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    2 +-
 3 files changed, 24 insertions(+), 12 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 3081339..d6917b8 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -199,7 +199,7 @@ extern int svc_rdma_handle_bc_reply(struct rpc_xprt *xprt,
 				    struct xdr_buf *rcvbuf);
 
 /* svc_rdma_marshal.c */
-extern int svc_rdma_xdr_decode_req(struct rpcrdma_msg *, struct svc_rqst *);
+extern int svc_rdma_xdr_decode_req(struct xdr_buf *);
 extern int svc_rdma_xdr_encode_error(struct svcxprt_rdma *,
 				     struct rpcrdma_msg *,
 				     enum rpcrdma_errcode, __be32 *);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_marshal.c b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
index 765bca4..0ba9887 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_marshal.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
@@ -145,19 +145,32 @@ static __be32 *decode_reply_array(__be32 *va, __be32 *vaend)
 	return (__be32 *)&ary->wc_array[nchunks];
 }
 
-int svc_rdma_xdr_decode_req(struct rpcrdma_msg *rmsgp, struct svc_rqst *rqstp)
+/**
+ * svc_rdma_xdr_decode_req - Parse incoming RPC-over-RDMA header
+ * @rq_arg: Receive buffer
+ *
+ * On entry, xdr->head[0].iov_base points to first byte in the
+ * RPC-over-RDMA header.
+ *
+ * On successful exit, head[0] points to first byte past the
+ * RPC-over-RDMA header. For RDMA_MSG, this is the RPC message.
+ * The length of the RPC-over-RDMA header is returned.
+ */
+int svc_rdma_xdr_decode_req(struct xdr_buf *rq_arg)
 {
+	struct rpcrdma_msg *rmsgp;
 	__be32 *va, *vaend;
 	unsigned int len;
 	u32 hdr_len;
 
 	/* Verify that there's enough bytes for header + something */
-	if (rqstp->rq_arg.len <= RPCRDMA_HDRLEN_ERR) {
+	if (rq_arg->len <= RPCRDMA_HDRLEN_ERR) {
 		dprintk("svcrdma: header too short = %d\n",
-			rqstp->rq_arg.len);
+			rq_arg->len);
 		return -EINVAL;
 	}
 
+	rmsgp = (struct rpcrdma_msg *)rq_arg->head[0].iov_base;
 	if (rmsgp->rm_vers != rpcrdma_version) {
 		dprintk("%s: bad version %u\n", __func__,
 			be32_to_cpu(rmsgp->rm_vers));
@@ -189,10 +202,10 @@ int svc_rdma_xdr_decode_req(struct rpcrdma_msg *rmsgp, struct svc_rqst *rqstp)
 			be32_to_cpu(rmsgp->rm_body.rm_padded.rm_thresh);
 
 		va = &rmsgp->rm_body.rm_padded.rm_pempty[4];
-		rqstp->rq_arg.head[0].iov_base = va;
+		rq_arg->head[0].iov_base = va;
 		len = (u32)((unsigned long)va - (unsigned long)rmsgp);
-		rqstp->rq_arg.head[0].iov_len -= len;
-		if (len > rqstp->rq_arg.len)
+		rq_arg->head[0].iov_len -= len;
+		if (len > rq_arg->len)
 			return -EINVAL;
 		return len;
 	default:
@@ -205,7 +218,7 @@ int svc_rdma_xdr_decode_req(struct rpcrdma_msg *rmsgp, struct svc_rqst *rqstp)
 	 * chunk list and a reply chunk list.
 	 */
 	va = &rmsgp->rm_body.rm_chunks[0];
-	vaend = (__be32 *)((unsigned long)rmsgp + rqstp->rq_arg.len);
+	vaend = (__be32 *)((unsigned long)rmsgp + rq_arg->len);
 	va = decode_read_list(va, vaend);
 	if (!va) {
 		dprintk("svcrdma: failed to decode read list\n");
@@ -222,10 +235,9 @@ int svc_rdma_xdr_decode_req(struct rpcrdma_msg *rmsgp, struct svc_rqst *rqstp)
 		return -EINVAL;
 	}
 
-	rqstp->rq_arg.head[0].iov_base = va;
+	rq_arg->head[0].iov_base = va;
 	hdr_len = (unsigned long)va - (unsigned long)rmsgp;
-	rqstp->rq_arg.head[0].iov_len -= hdr_len;
-
+	rq_arg->head[0].iov_len -= hdr_len;
 	return hdr_len;
 }
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 1b72f35..c984b0a 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -636,7 +636,7 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 
 	/* Decode the RDMA header. */
 	rmsgp = (struct rpcrdma_msg *)rqstp->rq_arg.head[0].iov_base;
-	ret = svc_rdma_xdr_decode_req(rmsgp, rqstp);
+	ret = svc_rdma_xdr_decode_req(&rqstp->rq_arg);
 	if (ret < 0)
 		goto out_err;
 	if (ret == 0)


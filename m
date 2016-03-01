Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34251 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501AbcCASGs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Mar 2016 13:06:48 -0500
Subject: [PATCH v5 10/14] svcrdma: Use correct XID in error replies
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 01 Mar 2016 13:06:47 -0500
Message-ID: <20160301180647.2492.24382.stgit@klimt.1015granger.net>
In-Reply-To: <20160301180337.2492.4255.stgit@klimt.1015granger.net>
References: <20160301180337.2492.4255.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When constructing an error reply, svc_rdma_xdr_encode_error()
needs to view the client's request message so it can get the
failing request's XID.

svc_rdma_xdr_decode_req() is supposed to return a pointer to the
client's request header. But if it fails to decode the client's
message (and thus an error reply is needed) it does not return the
pointer. The server then sends a bogus XID in the error reply.

Instead, unconditionally generate the pointer to the client's header
in svc_rdma_recvfrom(), and pass that pointer to both functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Devesh Sharma <devesh.sharma@broadcom.com>
Tested-by: Devesh Sharma <devesh.sharma@broadcom.com>
---
 include/linux/sunrpc/svc_rdma.h         |    2 +-
 net/sunrpc/xprtrdma/svc_rdma_marshal.c  |    7 +------
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    3 ++-
 3 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 42e8522..c2b0d95 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -199,7 +199,7 @@ extern int svc_rdma_handle_bc_reply(struct rpc_xprt *xprt,
 				    struct xdr_buf *rcvbuf);
 
 /* svc_rdma_marshal.c */
-extern int svc_rdma_xdr_decode_req(struct rpcrdma_msg **, struct svc_rqst *);
+extern int svc_rdma_xdr_decode_req(struct rpcrdma_msg *, struct svc_rqst *);
 extern int svc_rdma_xdr_encode_error(struct svcxprt_rdma *,
 				     struct rpcrdma_msg *,
 				     enum rpcrdma_errcode, __be32 *);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_marshal.c b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
index f74fc52..b9ce01f 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_marshal.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
@@ -145,15 +145,11 @@ static __be32 *decode_reply_array(__be32 *va, __be32 *vaend)
 	return (__be32 *)&ary->wc_array[nchunks];
 }
 
-int svc_rdma_xdr_decode_req(struct rpcrdma_msg **rdma_req,
-			    struct svc_rqst *rqstp)
+int svc_rdma_xdr_decode_req(struct rpcrdma_msg *rmsgp, struct svc_rqst *rqstp)
 {
-	struct rpcrdma_msg *rmsgp = NULL;
 	__be32 *va, *vaend;
 	u32 hdr_len;
 
-	rmsgp = (struct rpcrdma_msg *)rqstp->rq_arg.head[0].iov_base;
-
 	/* Verify that there's enough bytes for header + something */
 	if (rqstp->rq_arg.len <= RPCRDMA_HDRLEN_MIN) {
 		dprintk("svcrdma: header too short = %d\n",
@@ -201,7 +197,6 @@ int svc_rdma_xdr_decode_req(struct rpcrdma_msg **rdma_req,
 	hdr_len = (unsigned long)va - (unsigned long)rmsgp;
 	rqstp->rq_arg.head[0].iov_len -= hdr_len;
 
-	*rdma_req = rmsgp;
 	return hdr_len;
 }
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 0f09052..8f68cb6 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -653,7 +653,8 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 	rdma_build_arg_xdr(rqstp, ctxt, ctxt->byte_len);
 
 	/* Decode the RDMA header. */
-	ret = svc_rdma_xdr_decode_req(&rmsgp, rqstp);
+	rmsgp = (struct rpcrdma_msg *)rqstp->rq_arg.head[0].iov_base;
+	ret = svc_rdma_xdr_decode_req(rmsgp, rqstp);
 	if (ret < 0)
 		goto out_err;
 	rqstp->rq_xprt_hlen = ret;


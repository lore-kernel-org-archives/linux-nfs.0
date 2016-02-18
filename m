Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:33580 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756473AbcBRRoo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Feb 2016 12:44:44 -0500
Subject: [PATCH v3 07/10] svcrdma: Hook up the logic to return ERR_CHUNK
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 18 Feb 2016 12:44:42 -0500
Message-ID: <20160218174442.12825.98557.stgit@klimt.1015granger.net>
In-Reply-To: <20160218173840.12825.26769.stgit@klimt.1015granger.net>
References: <20160218173840.12825.26769.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RFC 5666 Section 4.2 states:

> When the peer detects an RPC-over-RDMA header version that it does
> not support (currently this document defines only version 1), it
> replies with an error code of ERR_VERS, and provides the low and
> high inclusive version numbers it does, in fact, support.

And:

> When other decoding errors are detected in the header or chunks,
> either an RPC decode error MAY be returned or the RPC/RDMA error
> code ERR_CHUNK MUST be returned.

The Linux NFS server does throw ERR_VERS when a client sends it
a request whose rdma_version is not "one." But it does not return
ERR_CHUNK when a header decoding error occurs. It just drops the
request.

To improve protocol extensibility, it should reject invalid values
in the rdma_proc field instead of treating them all like RDMA_MSG.
Otherwise clients can't detect when the server doesn't support
new rdma_proc values.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Devesh Sharma <devesh.sharma@broadcom.com>
Tested-by: Devesh Sharma <devesh.sharma@broadcom.com>
---
 net/sunrpc/xprtrdma/svc_rdma_marshal.c  |   55 ++++++++++++++++++++++++-------
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    4 ++
 2 files changed, 46 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_marshal.c b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
index b9ce01f..765bca4 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_marshal.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
@@ -148,22 +148,41 @@ static __be32 *decode_reply_array(__be32 *va, __be32 *vaend)
 int svc_rdma_xdr_decode_req(struct rpcrdma_msg *rmsgp, struct svc_rqst *rqstp)
 {
 	__be32 *va, *vaend;
+	unsigned int len;
 	u32 hdr_len;
 
 	/* Verify that there's enough bytes for header + something */
-	if (rqstp->rq_arg.len <= RPCRDMA_HDRLEN_MIN) {
+	if (rqstp->rq_arg.len <= RPCRDMA_HDRLEN_ERR) {
 		dprintk("svcrdma: header too short = %d\n",
 			rqstp->rq_arg.len);
 		return -EINVAL;
 	}
 
-	if (rmsgp->rm_vers != rpcrdma_version)
+	if (rmsgp->rm_vers != rpcrdma_version) {
+		dprintk("%s: bad version %u\n", __func__,
+			be32_to_cpu(rmsgp->rm_vers));
 		return -EPROTONOSUPPORT;
+	}
 
-	/* Pull in the extra for the padded case and bump our pointer */
-	if (rmsgp->rm_type == rdma_msgp) {
-		int hdrlen;
-
+	switch (be32_to_cpu(rmsgp->rm_type)) {
+	case RDMA_MSG:
+	case RDMA_NOMSG:
+		break;
+
+	case RDMA_DONE:
+		/* Just drop it */
+		dprintk("svcrdma: dropping RDMA_DONE message\n");
+		return 0;
+
+	case RDMA_ERROR:
+		/* Possible if this is a backchannel reply.
+		 * XXX: We should cancel this XID, though.
+		 */
+		dprintk("svcrdma: dropping RDMA_ERROR message\n");
+		return 0;
+
+	case RDMA_MSGP:
+		/* Pull in the extra for the padded case, bump our pointer */
 		rmsgp->rm_body.rm_padded.rm_align =
 			be32_to_cpu(rmsgp->rm_body.rm_padded.rm_align);
 		rmsgp->rm_body.rm_padded.rm_thresh =
@@ -171,11 +190,15 @@ int svc_rdma_xdr_decode_req(struct rpcrdma_msg *rmsgp, struct svc_rqst *rqstp)
 
 		va = &rmsgp->rm_body.rm_padded.rm_pempty[4];
 		rqstp->rq_arg.head[0].iov_base = va;
-		hdrlen = (u32)((unsigned long)va - (unsigned long)rmsgp);
-		rqstp->rq_arg.head[0].iov_len -= hdrlen;
-		if (hdrlen > rqstp->rq_arg.len)
+		len = (u32)((unsigned long)va - (unsigned long)rmsgp);
+		rqstp->rq_arg.head[0].iov_len -= len;
+		if (len > rqstp->rq_arg.len)
 			return -EINVAL;
-		return hdrlen;
+		return len;
+	default:
+		dprintk("svcrdma: bad rdma procedure (%u)\n",
+			be32_to_cpu(rmsgp->rm_type));
+		return -EINVAL;
 	}
 
 	/* The chunk list may contain either a read chunk list or a write
@@ -184,14 +207,20 @@ int svc_rdma_xdr_decode_req(struct rpcrdma_msg *rmsgp, struct svc_rqst *rqstp)
 	va = &rmsgp->rm_body.rm_chunks[0];
 	vaend = (__be32 *)((unsigned long)rmsgp + rqstp->rq_arg.len);
 	va = decode_read_list(va, vaend);
-	if (!va)
+	if (!va) {
+		dprintk("svcrdma: failed to decode read list\n");
 		return -EINVAL;
+	}
 	va = decode_write_list(va, vaend);
-	if (!va)
+	if (!va) {
+		dprintk("svcrdma: failed to decode write list\n");
 		return -EINVAL;
+	}
 	va = decode_reply_array(va, vaend);
-	if (!va)
+	if (!va) {
+		dprintk("svcrdma: failed to decode reply chunk\n");
 		return -EINVAL;
+	}
 
 	rqstp->rq_arg.head[0].iov_base = va;
 	hdr_len = (unsigned long)va - (unsigned long)rmsgp;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 8f68cb6..f8b840b 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -657,6 +657,8 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 	ret = svc_rdma_xdr_decode_req(rmsgp, rqstp);
 	if (ret < 0)
 		goto out_err;
+	if (ret == 0)
+		goto out_drop;
 	rqstp->rq_xprt_hlen = ret;
 
 	if (svc_rdma_is_backchannel_reply(xprt, rmsgp)) {
@@ -710,6 +712,8 @@ out_err:
 defer:
 	return 0;
 
+out_drop:
+	svc_rdma_put_context(ctxt, 1);
 repost:
 	return svc_rdma_repost_recv(rdma_xprt, GFP_KERNEL);
 }


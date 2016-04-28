Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:35042 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752456AbcD1PPo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Apr 2016 11:15:44 -0400
Subject: [PATCH 09/10] svcrdma: Simplify the check for backward direction
 replies
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 28 Apr 2016 11:15:42 -0400
Message-ID: <20160428151542.13068.37603.stgit@klimt.1015granger.net>
In-Reply-To: <20160428150915.13068.94602.stgit@klimt.1015granger.net>
References: <20160428150915.13068.94602.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: rq_arg.head[0] already points to the RPC header. No need
to walk down the RPC-over-RDMA header again.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   31 ++++++++++---------------------
 1 file changed, 10 insertions(+), 21 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index c984b0a..41adbe7 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -549,35 +549,24 @@ static void rdma_read_complete(struct svc_rqst *rqstp,
 	rqstp->rq_arg.buflen = head->arg.buflen;
 }
 
-/* By convention, backchannel calls arrive via rdma_msg type
- * messages, and never populate the chunk lists. This makes
- * the RPC/RDMA header small and fixed in size, so it is
- * straightforward to check the RPC header's direction field.
+/* Currently, this implementation does not support chunks in the
+ * backward direction. Thus only RDMA_MSG bc replies are accepted.
  */
 static bool
-svc_rdma_is_backchannel_reply(struct svc_xprt *xprt, struct rpcrdma_msg *rmsgp)
+svc_rdma_is_backchannel_reply(struct svc_xprt *xprt, struct rpcrdma_msg *rmsgp,
+			      struct xdr_buf *rq_arg)
 {
-	__be32 *p = (__be32 *)rmsgp;
+	__be32 *p = (__be32 *)rq_arg->head[0].iov_base;
 
+	/* Is there a backchannel transport associated with xprt? */
 	if (!xprt->xpt_bc_xprt)
 		return false;
-
+	/* Is there an RPC message in the inline buffer? */
 	if (rmsgp->rm_type != rdma_msg)
 		return false;
-	if (rmsgp->rm_body.rm_chunks[0] != xdr_zero)
-		return false;
-	if (rmsgp->rm_body.rm_chunks[1] != xdr_zero)
+	/* Is that message a Call or a Reply? */
+	if (p[1] != cpu_to_be32(RPC_REPLY))
 		return false;
-	if (rmsgp->rm_body.rm_chunks[2] != xdr_zero)
-		return false;
-
-	/* sanity */
-	if (p[7] != rmsgp->rm_xid)
-		return false;
-	/* call direction */
-	if (p[8] == cpu_to_be32(RPC_CALL))
-		return false;
-
 	return true;
 }
 
@@ -643,7 +632,7 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 		goto out_drop;
 	rqstp->rq_xprt_hlen = ret;
 
-	if (svc_rdma_is_backchannel_reply(xprt, rmsgp)) {
+	if (svc_rdma_is_backchannel_reply(xprt, rmsgp, &rqstp->rq_arg)) {
 		ret = svc_rdma_handle_bc_reply(xprt->xpt_bc_xprt, rmsgp,
 					       &rqstp->rq_arg);
 		svc_rdma_put_context(ctxt, 0);


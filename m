Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35284 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753840AbdBGQ6m (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Feb 2017 11:58:42 -0500
Subject: [PATCH v3 4/7] svcrdma: Clean up backchannel send header encoding
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 07 Feb 2017 11:58:40 -0500
Message-ID: <20170207165840.14422.60185.stgit@klimt.1015granger.net>
In-Reply-To: <20170207165131.14422.47088.stgit@klimt.1015granger.net>
References: <20170207165131.14422.47088.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace C structure-based XDR decoding with pointer arithmetic.
Pointer arithmetic is considered more portable.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index 288e35c..b1bc7a7 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -200,19 +200,20 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
 {
 	struct rpc_xprt *xprt = rqst->rq_xprt;
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
-	struct rpcrdma_msg *headerp = (struct rpcrdma_msg *)rqst->rq_buffer;
+	__be32 *p;
 	int rc;
 
 	/* Space in the send buffer for an RPC/RDMA header is reserved
 	 * via xprt->tsh_size.
 	 */
-	headerp->rm_xid = rqst->rq_xid;
-	headerp->rm_vers = rpcrdma_version;
-	headerp->rm_credit = cpu_to_be32(r_xprt->rx_buf.rb_bc_max_requests);
-	headerp->rm_type = rdma_msg;
-	headerp->rm_body.rm_chunks[0] = xdr_zero;
-	headerp->rm_body.rm_chunks[1] = xdr_zero;
-	headerp->rm_body.rm_chunks[2] = xdr_zero;
+	p = rqst->rq_buffer;
+	*p++ = rqst->rq_xid;
+	*p++ = rpcrdma_version;
+	*p++ = cpu_to_be32(r_xprt->rx_buf.rb_bc_max_requests);
+	*p++ = rdma_msg;
+	*p++ = xdr_zero;
+	*p++ = xdr_zero;
+	*p   = xdr_zero;
 
 #ifdef SVCRDMA_BACKCHANNEL_DEBUG
 	pr_info("%s: %*ph\n", __func__, 64, rqst->rq_buffer);


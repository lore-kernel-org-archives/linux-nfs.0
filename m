Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:37647 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752597AbdHJQrW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Aug 2017 12:47:22 -0400
Received: by mail-it0-f66.google.com with SMTP id 77so2045657itj.4
        for <linux-nfs@vger.kernel.org>; Thu, 10 Aug 2017 09:47:21 -0700 (PDT)
Subject: [PATCH v1 2/5] xprtrdma: Remove rpclen from rpcrdma_marshal_req
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 10 Aug 2017 12:47:20 -0400
Message-ID: <20170810164720.23774.50946.stgit@manet.1015granger.net>
In-Reply-To: <20170810164425.23774.91430.stgit@manet.1015granger.net>
References: <20170810164425.23774.91430.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Remove a variable whose result is no longer used.
Commit 655fec6987be ("xprtrdma: Use gathered Send for large inline
messages") should have removed it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |    9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index d916e59..f1d63ac9 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -677,7 +677,6 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	struct rpcrdma_msg *headerp;
 	bool ddp_allowed;
 	ssize_t hdrlen;
-	size_t rpclen;
 	__be32 *iptr;
 
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
@@ -731,16 +730,12 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	 */
 	if (rpcrdma_args_inline(r_xprt, rqst)) {
 		rtype = rpcrdma_noch;
-		rpclen = rqst->rq_snd_buf.len;
 	} else if (ddp_allowed && rqst->rq_snd_buf.flags & XDRBUF_WRITE) {
 		rtype = rpcrdma_readch;
-		rpclen = rqst->rq_snd_buf.head[0].iov_len +
-			 rqst->rq_snd_buf.tail[0].iov_len;
 	} else {
 		r_xprt->rx_stats.nomsg_call_count++;
 		headerp->rm_type = htonl(RDMA_NOMSG);
 		rtype = rpcrdma_areadch;
-		rpclen = 0;
 	}
 
 	req->rl_xid = rqst->rq_xid;
@@ -780,10 +775,10 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		goto out_err;
 	hdrlen = (unsigned char *)iptr - (unsigned char *)headerp;
 
-	dprintk("RPC: %5u %s: %s/%s: hdrlen %zd rpclen %zd\n",
+	dprintk("RPC: %5u %s: %s/%s: hdrlen %zd\n",
 		rqst->rq_task->tk_pid, __func__,
 		transfertypes[rtype], transfertypes[wtype],
-		hdrlen, rpclen);
+		hdrlen);
 
 	if (!rpcrdma_prepare_send_sges(&r_xprt->rx_ia, req, hdrlen,
 				       &rqst->rq_snd_buf, rtype)) {


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36273 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753256AbdHJQrq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Aug 2017 12:47:46 -0400
Received: by mail-io0-f195.google.com with SMTP id j32so1925181iod.3
        for <linux-nfs@vger.kernel.org>; Thu, 10 Aug 2017 09:47:46 -0700 (PDT)
Subject: [PATCH v1 5/5] xprtrdma: Clean up rpcrdma_bc_marshal_reply()
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 10 Aug 2017 12:47:44 -0400
Message-ID: <20170810164744.23774.16144.stgit@manet.1015granger.net>
In-Reply-To: <20170810164425.23774.91430.stgit@manet.1015granger.net>
References: <20170810164425.23774.91430.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Same changes as in rpcrdma_marshal_req(). This removes
C-structure style encoding from the backchannel.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |   31 ++++++++++++++++++-------------
 1 file changed, 18 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 183a103..d31d0ac 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -49,6 +49,7 @@ static int rpcrdma_bc_setup_rqst(struct rpcrdma_xprt *r_xprt,
 	if (IS_ERR(rb))
 		goto out_fail;
 	req->rl_rdmabuf = rb;
+	xdr_buf_init(&req->rl_hdrbuf, rb->rg_base, rdmab_length(rb));
 
 	size = r_xprt->rx_data.inline_rsize;
 	rb = rpcrdma_alloc_regbuf(size, DMA_TO_DEVICE, GFP_KERNEL);
@@ -202,20 +203,24 @@ size_t xprt_rdma_bc_maxpayload(struct rpc_xprt *xprt)
  */
 int rpcrdma_bc_marshal_reply(struct rpc_rqst *rqst)
 {
-	struct rpc_xprt *xprt = rqst->rq_xprt;
-	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
+	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(rqst->rq_xprt);
 	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
-	struct rpcrdma_msg *headerp;
-
-	headerp = rdmab_to_msg(req->rl_rdmabuf);
-	headerp->rm_xid = rqst->rq_xid;
-	headerp->rm_vers = rpcrdma_version;
-	headerp->rm_credit =
-			cpu_to_be32(r_xprt->rx_buf.rb_bc_srv_max_requests);
-	headerp->rm_type = rdma_msg;
-	headerp->rm_body.rm_chunks[0] = xdr_zero;
-	headerp->rm_body.rm_chunks[1] = xdr_zero;
-	headerp->rm_body.rm_chunks[2] = xdr_zero;
+	__be32 *p;
+
+	rpcrdma_set_xdrlen(&req->rl_hdrbuf, 0);
+	xdr_init_encode(&req->rl_stream, &req->rl_hdrbuf,
+			req->rl_rdmabuf->rg_base);
+
+	p = xdr_reserve_space(&req->rl_stream, 28);
+	if (unlikely(!p))
+		return -EIO;
+	*p++ = rqst->rq_xid;
+	*p++ = rpcrdma_version;
+	*p++ = cpu_to_be32(r_xprt->rx_buf.rb_bc_srv_max_requests);
+	*p++ = rdma_msg;
+	*p++ = xdr_zero;
+	*p++ = xdr_zero;
+	*p = xdr_zero;
 
 	if (!rpcrdma_prepare_send_sges(&r_xprt->rx_ia, req, RPCRDMA_HDRLEN_MIN,
 				       &rqst->rq_snd_buf, rpcrdma_noch))


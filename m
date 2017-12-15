Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:46025 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754673AbdLOB5Y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Dec 2017 20:57:24 -0500
Subject: [PATCH v1 11/16] xprtrdma: buf_free not called for CB replies
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 14 Dec 2017 20:57:23 -0500
Message-ID: <20171215015722.13776.98976.stgit@manet.1015granger.net>
In-Reply-To: <20171215015403.13776.46706.stgit@manet.1015granger.net>
References: <20171215015403.13776.46706.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since commit 5a6d1db45569 ("SUNRPC: Add a transport-specific private
field in rpc_rqst"), the rpc_rqst's for RPC-over-RDMA backchannel
operations leave rq_buffer set to NULL.

xprt_release does not invoke ->op->buf_free when rq_buffer is NULL.
The RPCRDMA_REQ_F_BACKCHANNEL check in xprt_rdma_free is therefore
redundant because xprt_rdma_free is not invoked for backchannel
requests.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |    1 -
 net/sunrpc/xprtrdma/transport.c   |    3 ---
 net/sunrpc/xprtrdma/xprt_rdma.h   |    3 +--
 3 files changed, 1 insertion(+), 6 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 256c67b..11fb38f 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -43,7 +43,6 @@ static int rpcrdma_bc_setup_rqst(struct rpcrdma_xprt *r_xprt,
 	req = rpcrdma_create_req(r_xprt);
 	if (IS_ERR(req))
 		return PTR_ERR(req);
-	__set_bit(RPCRDMA_REQ_F_BACKCHANNEL, &req->rl_flags);
 
 	rb = rpcrdma_alloc_regbuf(RPCRDMA_HDRBUF_SIZE,
 				  DMA_TO_DEVICE, GFP_KERNEL);
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index d77dee5..d0cd6d4 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -686,9 +686,6 @@
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(rqst->rq_xprt);
 	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
 
-	if (test_bit(RPCRDMA_REQ_F_BACKCHANNEL, &req->rl_flags))
-		return;
-
 	dprintk("RPC:       %s: called on 0x%p\n", __func__, req->rl_reply);
 
 	if (test_bit(RPCRDMA_REQ_F_PENDING, &req->rl_flags))
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 7c09e2a..ed7e513 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -354,8 +354,7 @@ struct rpcrdma_req {
 
 /* rl_flags */
 enum {
-	RPCRDMA_REQ_F_BACKCHANNEL = 0,
-	RPCRDMA_REQ_F_PENDING,
+	RPCRDMA_REQ_F_PENDING = 0,
 	RPCRDMA_REQ_F_TX_RESOURCES,
 };
 


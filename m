Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33083 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932256AbcHOUuY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Aug 2016 16:50:24 -0400
Subject: [PATCH v1 01/22] xprtrdma: Eliminate INLINE_THRESHOLD macros
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 15 Aug 2016 16:50:21 -0400
Message-ID: <20160815205021.11652.21593.stgit@manet.1015granger.net>
In-Reply-To: <20160815195649.11652.32252.stgit@manet.1015granger.net>
References: <20160815195649.11652.32252.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: r_xprt is already available everywhere these macros are
invoked, so just dereference that directly.

RPCRDMA_INLINE_PAD_VALUE is no longer used, so it can simply be
removed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |    4 ++--
 net/sunrpc/xprtrdma/rpc_rdma.c    |    2 +-
 net/sunrpc/xprtrdma/transport.c   |    6 +++---
 net/sunrpc/xprtrdma/xprt_rdma.h   |    9 ---------
 4 files changed, 6 insertions(+), 15 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 87762d9..5f60ab2 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -46,13 +46,13 @@ static int rpcrdma_bc_setup_rqst(struct rpcrdma_xprt *r_xprt,
 		return PTR_ERR(req);
 	req->rl_backchannel = true;
 
-	size = RPCRDMA_INLINE_WRITE_THRESHOLD(rqst);
+	size = r_xprt->rx_data.inline_wsize;
 	rb = rpcrdma_alloc_regbuf(ia, size, GFP_KERNEL);
 	if (IS_ERR(rb))
 		goto out_fail;
 	req->rl_rdmabuf = rb;
 
-	size += RPCRDMA_INLINE_READ_THRESHOLD(rqst);
+	size += r_xprt->rx_data.inline_rsize;
 	rb = rpcrdma_alloc_regbuf(ia, size, GFP_KERNEL);
 	if (IS_ERR(rb))
 		goto out_fail;
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index a47f170..845586f 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -673,7 +673,7 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 		goto out_unmap;
 	hdrlen = (unsigned char *)iptr - (unsigned char *)headerp;
 
-	if (hdrlen + rpclen > RPCRDMA_INLINE_WRITE_THRESHOLD(rqst))
+	if (hdrlen + rpclen > r_xprt->rx_data.inline_wsize)
 		goto out_overflow;
 
 	dprintk("RPC: %5u %s: %s/%s: hdrlen %zd rpclen %zd\n",
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 81f0e87..be95ece 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -518,7 +518,7 @@ out:
 	return req->rl_sendbuf->rg_base;
 
 out_rdmabuf:
-	min_size = RPCRDMA_INLINE_WRITE_THRESHOLD(task->tk_rqstp);
+	min_size = r_xprt->rx_data.inline_wsize;
 	rb = rpcrdma_alloc_regbuf(&r_xprt->rx_ia, min_size, flags);
 	if (IS_ERR(rb))
 		goto out_fail;
@@ -541,8 +541,8 @@ out_sendbuf:
 	 * reply will be large, but slush is provided here to allow
 	 * flexibility when marshaling.
 	 */
-	min_size = RPCRDMA_INLINE_READ_THRESHOLD(task->tk_rqstp);
-	min_size += RPCRDMA_INLINE_WRITE_THRESHOLD(task->tk_rqstp);
+	min_size = r_xprt->rx_data.inline_rsize;
+	min_size += r_xprt->rx_data.inline_wsize;
 	if (size < min_size)
 		size = min_size;
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 670fad5..6d466ab 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -355,15 +355,6 @@ struct rpcrdma_create_data_internal {
 	unsigned int	padding;	/* non-rdma write header padding */
 };
 
-#define RPCRDMA_INLINE_READ_THRESHOLD(rq) \
-	(rpcx_to_rdmad(rq->rq_xprt).inline_rsize)
-
-#define RPCRDMA_INLINE_WRITE_THRESHOLD(rq)\
-	(rpcx_to_rdmad(rq->rq_xprt).inline_wsize)
-
-#define RPCRDMA_INLINE_PAD_VALUE(rq)\
-	rpcx_to_rdmad(rq->rq_xprt).padding
-
 /*
  * Statistics for RPCRDMA
  */


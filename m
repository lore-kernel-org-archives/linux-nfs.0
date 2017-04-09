Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35521 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752230AbdDIRFy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Apr 2017 13:05:54 -0400
Subject: [PATCH v3 03/14] svcrdma: Eliminate RPCRDMA_SQ_DEPTH_MULT
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sun, 09 Apr 2017 13:05:52 -0400
Message-ID: <20170409170552.15073.43.stgit@klimt.1015granger.net>
In-Reply-To: <20170409163820.15073.43257.stgit@klimt.1015granger.net>
References: <20170409163820.15073.43257.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The Send Queue depth is temporarily reduced to 1 SQE per credit. The
new rdma_rw API does an internal computation, during QP creation, to
increase the depth of the Send Queue to handle RDMA Read and Write
operations.

This change has to come before the NFSD code paths are updated to
use the rdma_rw API. Without this patch, rdma_rw_init_qp() increases
the size of the SQ too much, resulting in memory allocation failures
during QP creation.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/sunrpc/svc_rdma.h          |    1 -
 net/sunrpc/xprtrdma/svc_rdma.c           |    2 --
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 +-
 3 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 002a46d..11d5aa1 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -182,7 +182,6 @@ struct svcxprt_rdma {
 /* The default ORD value is based on two outstanding full-size writes with a
  * page size of 4k, or 32k * 2 ops / 4k = 16 outstanding RDMA_READ.  */
 #define RPCRDMA_ORD             (64/4)
-#define RPCRDMA_SQ_DEPTH_MULT   8
 #define RPCRDMA_MAX_REQUESTS    32
 #define RPCRDMA_MAX_REQ_SIZE    4096
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
index c846ca9..9124441 100644
--- a/net/sunrpc/xprtrdma/svc_rdma.c
+++ b/net/sunrpc/xprtrdma/svc_rdma.c
@@ -247,8 +247,6 @@ int svc_rdma_init(void)
 	dprintk("SVCRDMA Module Init, register RPC RDMA transport\n");
 	dprintk("\tsvcrdma_ord      : %d\n", svcrdma_ord);
 	dprintk("\tmax_requests     : %u\n", svcrdma_max_requests);
-	dprintk("\tsq_depth         : %u\n",
-		svcrdma_max_requests * RPCRDMA_SQ_DEPTH_MULT);
 	dprintk("\tmax_bc_requests  : %u\n", svcrdma_max_bc_requests);
 	dprintk("\tmax_inline       : %d\n", svcrdma_max_req_size);
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index fc8f14c..e1097cc 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -1014,7 +1014,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 					    svcrdma_max_bc_requests);
 	newxprt->sc_rq_depth = newxprt->sc_max_requests +
 			       newxprt->sc_max_bc_requests;
-	newxprt->sc_sq_depth = RPCRDMA_SQ_DEPTH_MULT * newxprt->sc_rq_depth;
+	newxprt->sc_sq_depth = newxprt->sc_rq_depth;
 	atomic_set(&newxprt->sc_sq_avail, newxprt->sc_sq_depth);
 
 	if (!svc_rdma_prealloc_ctxts(newxprt))


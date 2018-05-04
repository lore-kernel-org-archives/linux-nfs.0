Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:37790 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751747AbeEDTfy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 4 May 2018 15:35:54 -0400
Subject: [PATCH v1 16/19] xprtrdma: Move common wait_for_buffer_space call
 to parent function
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 04 May 2018 15:35:52 -0400
Message-ID: <20180504193552.31688.32685.stgit@manet.1015granger.net>
In-Reply-To: <20180504192748.31688.3678.stgit@manet.1015granger.net>
References: <20180504192748.31688.3678.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: The logic to wait for write space is common to a bunch of
the encoding helper functions. Lift it out and put it in the tail
of rpcrdma_marshal_req().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |   31 ++++++++++++-------------------
 1 file changed, 12 insertions(+), 19 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 1d78579..b12b044 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -366,7 +366,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		seg = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
 						   false, &mr);
 		if (IS_ERR(seg))
-			goto out_maperr;
+			return PTR_ERR(seg);
 		rpcrdma_mr_push(mr, &req->rl_registered);
 
 		if (encode_read_segment(xdr, mr, pos) < 0)
@@ -378,11 +378,6 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	} while (nsegs);
 
 	return 0;
-
-out_maperr:
-	if (PTR_ERR(seg) == -EAGAIN)
-		xprt_wait_for_buffer_space(rqst->rq_task, NULL);
-	return PTR_ERR(seg);
 }
 
 /* Register and XDR encode the Write list. Supports encoding a list
@@ -429,7 +424,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		seg = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
 						   true, &mr);
 		if (IS_ERR(seg))
-			goto out_maperr;
+			return PTR_ERR(seg);
 		rpcrdma_mr_push(mr, &req->rl_registered);
 
 		if (encode_rdma_segment(xdr, mr) < 0)
@@ -446,11 +441,6 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	*segcount = cpu_to_be32(nchunks);
 
 	return 0;
-
-out_maperr:
-	if (PTR_ERR(seg) == -EAGAIN)
-		xprt_wait_for_buffer_space(rqst->rq_task, NULL);
-	return PTR_ERR(seg);
 }
 
 /* Register and XDR encode the Reply chunk. Supports encoding an array
@@ -492,7 +482,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		seg = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
 						   true, &mr);
 		if (IS_ERR(seg))
-			goto out_maperr;
+			return PTR_ERR(seg);
 		rpcrdma_mr_push(mr, &req->rl_registered);
 
 		if (encode_rdma_segment(xdr, mr) < 0)
@@ -509,11 +499,6 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	*segcount = cpu_to_be32(nchunks);
 
 	return 0;
-
-out_maperr:
-	if (PTR_ERR(seg) == -EAGAIN)
-		xprt_wait_for_buffer_space(rqst->rq_task, NULL);
-	return PTR_ERR(seg);
 }
 
 /**
@@ -884,7 +869,15 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	return 0;
 
 out_err:
-	r_xprt->rx_stats.failed_marshal_count++;
+	switch (ret) {
+	case -EAGAIN:
+		xprt_wait_for_buffer_space(rqst->rq_task, NULL);
+		break;
+	case -ENOBUFS:
+		break;
+	default:
+		r_xprt->rx_stats.failed_marshal_count++;
+	}
 	return ret;
 }
 


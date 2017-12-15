Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:46002 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754609AbdLOB5Q (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Dec 2017 20:57:16 -0500
Subject: [PATCH v1 10/16] xprtrdma: Move unmap-safe logic to
 rpcrdma_marshal_req
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 14 Dec 2017 20:57:14 -0500
Message-ID: <20171215015714.13776.40984.stgit@manet.1015granger.net>
In-Reply-To: <20171215015403.13776.46706.stgit@manet.1015granger.net>
References: <20171215015403.13776.46706.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up. This logic is related to marshaling the request, and I'd
like to keep everything that touches req->rl_registered close
together, for CPU cache efficiency.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   11 +++++++++++
 net/sunrpc/xprtrdma/transport.c |    5 -----
 2 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index d7463bc..dd7c0aa 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -821,6 +821,17 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		rtype = rpcrdma_areadch;
 	}
 
+	/* If this is a retransmit, discard previously registered
+	 * chunks. Very likely the connection has been replaced,
+	 * so these registrations are invalid and unusable.
+	 */
+	while (unlikely(!list_empty(&req->rl_registered))) {
+		struct rpcrdma_mw *mw;
+
+		mw = rpcrdma_pop_mw(&req->rl_registered);
+		rpcrdma_defer_mr_recovery(mw);
+	}
+
 	/* This implementation supports the following combinations
 	 * of chunk lists in one RPC-over-RDMA Call message:
 	 *
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index cebcd02..d77dee5 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -731,11 +731,6 @@
 	if (!xprt_connected(xprt))
 		goto drop_connection;
 
-	/* On retransmit, remove any previously registered chunks */
-	if (unlikely(!list_empty(&req->rl_registered)))
-		r_xprt->rx_ia.ri_ops->ro_unmap_sync(r_xprt,
-						    &req->rl_registered);
-
 	rc = rpcrdma_marshal_req(r_xprt, rqst);
 	if (rc < 0)
 		goto failed_marshal;


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f171.google.com ([209.85.223.171]:40231 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754386AbaDNWXI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2014 18:23:08 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/8] xprtrdma: Simplify rpcrdma_deregister_external() synopsis
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Mon, 14 Apr 2014 18:23:06 -0400
Message-ID: <20140414222306.20646.68043.stgit@manet.1015granger.net>
In-Reply-To: <20140414220041.20646.63991.stgit@manet.1015granger.net>
References: <20140414220041.20646.63991.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: All remaining callers of rpcrdma_deregister_external()
pass NULL as the last argument, so remove that argument.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/rpc_rdma.c  |    2 +-
 net/sunrpc/xprtrdma/transport.c |    2 +-
 net/sunrpc/xprtrdma/verbs.c     |    8 +-------
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 +-
 4 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index e4af26a..aac6adb 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -273,7 +273,7 @@ rpcrdma_create_chunks(struct rpc_rqst *rqst, struct xdr_buf *target,
 out:
 	for (pos = 0; nchunks--;)
 		pos += rpcrdma_deregister_external(
-				&req->rl_segments[pos], r_xprt, NULL);
+				&req->rl_segments[pos], r_xprt);
 	return 0;
 }
 
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index c23b0c1..430cabb 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -575,7 +575,7 @@ xprt_rdma_free(void *buffer)
 	for (i = 0; req->rl_nchunks;) {
 		--req->rl_nchunks;
 		i += rpcrdma_deregister_external(
-			&req->rl_segments[i], r_xprt, NULL);
+			&req->rl_segments[i], r_xprt);
 	}
 
 	if (req->rl_iov.length == 0) {	/* see allocate above */
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 35c6699..2b763a2 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1697,7 +1697,7 @@ rpcrdma_register_external(struct rpcrdma_mr_seg *seg,
 
 int
 rpcrdma_deregister_external(struct rpcrdma_mr_seg *seg,
-		struct rpcrdma_xprt *r_xprt, void *r)
+		struct rpcrdma_xprt *r_xprt)
 {
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	int nsegs = seg->mr_nsegs, rc;
@@ -1724,12 +1724,6 @@ rpcrdma_deregister_external(struct rpcrdma_mr_seg *seg,
 		rc = rpcrdma_deregister_default_external(seg, ia);
 		break;
 	}
-	if (r) {
-		struct rpcrdma_rep *rep = r;
-		void (*func)(struct rpcrdma_rep *) = rep->rr_func;
-		rep->rr_func = NULL;
-		func(rep);	/* dereg done, callback now */
-	}
 	return nsegs;
 }
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index bf08ee0..3f44d6a 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -331,7 +331,7 @@ int rpcrdma_deregister_internal(struct rpcrdma_ia *,
 int rpcrdma_register_external(struct rpcrdma_mr_seg *,
 				int, int, struct rpcrdma_xprt *);
 int rpcrdma_deregister_external(struct rpcrdma_mr_seg *,
-				struct rpcrdma_xprt *, void *);
+				struct rpcrdma_xprt *);
 
 /*
  * RPC/RDMA connection management calls - xprtrdma/rpc_rdma.c


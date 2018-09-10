Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:55056 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727411AbeIJUDk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Sep 2018 16:03:40 -0400
Subject: [PATCH v1 02/22] xprtrdma: Create more MRs at a time
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 10 Sep 2018 11:09:06 -0400
Message-ID: <20180910150906.10564.92061.stgit@manet.1015granger.net>
In-Reply-To: <20180910150040.10564.97487.stgit@manet.1015granger.net>
References: <20180910150040.10564.97487.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some devices require more than 3 MRs to build a single 1MB I/O.
Ensure that rpcrdma_mrs_create() will add enough MRs to build that
I/O. Otherwise it's possible for ->send_request to loop acquiring
some MRs, not getting enough, getting called again, recycling the
previous MRs, then not getting enough, lather rinse repeat.

I'm "reusing" ia->ri_max_segs. All of its accessors seem to want the
maximum number of data segments plus two, so I'm going to bake that
into the initial calculation.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c  |    1 +
 net/sunrpc/xprtrdma/frwr_ops.c |    1 +
 net/sunrpc/xprtrdma/rpc_rdma.c |    2 --
 net/sunrpc/xprtrdma/verbs.c    |    2 +-
 4 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 0f7c465..db589a2 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -187,6 +187,7 @@ enum {
 
 	ia->ri_max_segs = max_t(unsigned int, 1, RPCRDMA_MAX_DATA_SEGS /
 				RPCRDMA_MAX_FMR_SGES);
+	ia->ri_max_segs += 2;	/* segments for head and tail buffers */
 	return 0;
 }
 
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 1bb00dd..1cc4db5 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -276,6 +276,7 @@
 
 	ia->ri_max_segs = max_t(unsigned int, 1, RPCRDMA_MAX_DATA_SEGS /
 				ia->ri_max_frwr_depth);
+	ia->ri_max_segs += 2;	/* segments for head and tail buffers */
 	return 0;
 }
 
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index c8ae983..33da912 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -71,7 +71,6 @@ static unsigned int rpcrdma_max_call_header_size(unsigned int maxsegs)
 	size = RPCRDMA_HDRLEN_MIN;
 
 	/* Maximum Read list size */
-	maxsegs += 2;	/* segment for head and tail buffers */
 	size = maxsegs * rpcrdma_readchunk_maxsz * sizeof(__be32);
 
 	/* Minimal Read chunk size */
@@ -97,7 +96,6 @@ static unsigned int rpcrdma_max_reply_header_size(unsigned int maxsegs)
 	size = RPCRDMA_HDRLEN_MIN;
 
 	/* Maximum Write list size */
-	maxsegs += 2;	/* segment for head and tail buffers */
 	size = sizeof(__be32);		/* segment count */
 	size += maxsegs * rpcrdma_segment_maxsz * sizeof(__be32);
 	size += sizeof(__be32);	/* list discriminator */
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 956a5ea..5625a50 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1019,7 +1019,7 @@ struct rpcrdma_sendctx *rpcrdma_sendctx_get_locked(struct rpcrdma_buffer *buf)
 	LIST_HEAD(free);
 	LIST_HEAD(all);
 
-	for (count = 0; count < 3; count++) {
+	for (count = 0; count < ia->ri_max_segs; count++) {
 		struct rpcrdma_mr *mr;
 		int rc;
 

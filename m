Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:40272 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752119AbbAMQ1a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2015 11:27:30 -0500
Subject: [PATCH v2 20/20] xprtrdma: Clean up after adding regbuf management
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 13 Jan 2015 11:27:28 -0500
Message-ID: <20150113162728.14086.15466.stgit@manet.1015granger.net>
In-Reply-To: <20150113161440.14086.24801.stgit@manet.1015granger.net>
References: <20150113161440.14086.24801.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpcrdma_{de}register_internal() are used only in verbs.c now.

MAX_RPCRDMAHDR is no longer used and can be removed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c     |    4 ++--
 net/sunrpc/xprtrdma/xprt_rdma.h |    9 ---------
 2 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 669f68a..f7c3d10 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1729,7 +1729,7 @@ rpcrdma_recv_buffer_put(struct rpcrdma_rep *rep)
  * Wrappers for internal-use kmalloc memory registration, used by buffer code.
  */
 
-int
+static int
 rpcrdma_register_internal(struct rpcrdma_ia *ia, void *va, int len,
 				struct ib_mr **mrp, struct ib_sge *iov)
 {
@@ -1780,7 +1780,7 @@ rpcrdma_register_internal(struct rpcrdma_ia *ia, void *va, int len,
 	return rc;
 }
 
-int
+static int
 rpcrdma_deregister_internal(struct rpcrdma_ia *ia,
 				struct ib_mr *mr, struct ib_sge *iov)
 {
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 5630353..c9d2a02 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -171,10 +171,6 @@ enum rpcrdma_chunktype {
 /* temporary static scatter/gather max */
 #define RPCRDMA_MAX_DATA_SEGS	(64)	/* max scatter/gather */
 #define RPCRDMA_MAX_SEGS 	(RPCRDMA_MAX_DATA_SEGS + 2) /* head+tail = 2 */
-#define MAX_RPCRDMAHDR	(\
-	/* max supported RPC/RDMA header */ \
-	sizeof(struct rpcrdma_msg) + (2 * sizeof(u32)) + \
-	(sizeof(struct rpcrdma_read_chunk) * RPCRDMA_MAX_SEGS) + sizeof(u32))
 
 struct rpcrdma_buffer;
 
@@ -401,11 +397,6 @@ void rpcrdma_buffer_put(struct rpcrdma_req *);
 void rpcrdma_recv_buffer_get(struct rpcrdma_req *);
 void rpcrdma_recv_buffer_put(struct rpcrdma_rep *);
 
-int rpcrdma_register_internal(struct rpcrdma_ia *, void *, int,
-				struct ib_mr **, struct ib_sge *);
-int rpcrdma_deregister_internal(struct rpcrdma_ia *,
-				struct ib_mr *, struct ib_sge *);
-
 int rpcrdma_register_external(struct rpcrdma_mr_seg *,
 				int, int, struct rpcrdma_xprt *);
 int rpcrdma_deregister_external(struct rpcrdma_mr_seg *,


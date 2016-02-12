Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f194.google.com ([209.85.213.194]:36610 "EHLO
	mail-ig0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067AbcBLVGN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Feb 2016 16:06:13 -0500
Subject: [PATCH v1 2/8] xprtrdma: Invalidate memory when a signal is caught
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 12 Feb 2016 16:06:10 -0500
Message-ID: <20160212210610.5278.22489.stgit@manet.1015granger.net>
In-Reply-To: <20160212205107.5278.55938.stgit@manet.1015granger.net>
References: <20160212205107.5278.55938.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When a signal occurs during a synchronous RPC, the RPC scheduler
causes the RPC task to exit immediately.

However, the RPC transaction is still running on the server, which
may read arguments from the client or deliver a reply into client
memory that is still registered.

Ensure that xprt_release() invalidates the signaled RPC's chunks
and waits for the invalidation to complete in order to fence the
memory from the server before the client re-allocates it.

Note it should be safe to sleep in this case. An asynchronous
RPC is never awoken by a signal.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |   41 ++++++++++++++++++++++++++++++++-------
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
 2 files changed, 35 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index b1b009f..ceb7140 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -508,6 +508,7 @@ xprt_rdma_allocate(struct rpc_task *task, size_t size)
 out:
 	dprintk("RPC:       %s: size %zd, request 0x%p\n", __func__, size, req);
 	req->rl_connect_cookie = 0;	/* our reserved value */
+	req->rl_task = task;
 	return req->rl_sendbuf->rg_base;
 
 out_rdmabuf:
@@ -555,6 +556,37 @@ out_fail:
 	return NULL;
 }
 
+/* Invalidate registered memory still associated with this req.
+ *
+ * Normally, the RPC reply handler invalidates chunks.
+ *
+ * If we're here because a signal fired, this is an exiting
+ * synchronous RPC and the reply handler has not run, leaving
+ * the RPC's chunks registered. The server is still processing
+ * this RPC and can still read or update those chunks.
+ *
+ * Synchronously fence the chunks before this RPC terminates
+ * to ensure the server doesn't write into memory that has
+ * been reallocated.
+ */
+static void xprt_rdma_free_chunks(struct rpcrdma_xprt *r_xprt,
+				  struct rpcrdma_req *req)
+{
+	unsigned int i;
+
+	if (!RPC_IS_ASYNC(req->rl_task)) {
+		r_xprt->rx_ia.ri_ops->ro_unmap_sync(r_xprt, req);
+		return;
+	}
+
+	pr_warn("rpcrdma: freeing async RPC task with registered chunks\n");
+	for (i = 0; req->rl_nchunks;) {
+		--req->rl_nchunks;
+		i += r_xprt->rx_ia.ri_ops->ro_unmap(r_xprt,
+						    &req->rl_segments[i]);
+	}
+}
+
 /*
  * This function returns all RDMA resources to the pool.
  */
@@ -564,7 +596,6 @@ xprt_rdma_free(void *buffer)
 	struct rpcrdma_req *req;
 	struct rpcrdma_xprt *r_xprt;
 	struct rpcrdma_regbuf *rb;
-	int i;
 
 	if (buffer == NULL)
 		return;
@@ -578,12 +609,8 @@ xprt_rdma_free(void *buffer)
 
 	dprintk("RPC:       %s: called on 0x%p\n", __func__, req->rl_reply);
 
-	for (i = 0; req->rl_nchunks;) {
-		--req->rl_nchunks;
-		i += r_xprt->rx_ia.ri_ops->ro_unmap(r_xprt,
-						    &req->rl_segments[i]);
-	}
-
+	if (req->rl_nchunks)
+		xprt_rdma_free_chunks(r_xprt, req);
 	rpcrdma_buffer_put(req);
 }
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 38fe11b..bf98c67 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -280,6 +280,7 @@ struct rpcrdma_req {
 	struct rpcrdma_regbuf	*rl_rdmabuf;
 	struct rpcrdma_regbuf	*rl_sendbuf;
 	struct rpcrdma_mr_seg	rl_segments[RPCRDMA_MAX_SEGS];
+	struct rpc_task		*rl_task;
 
 	struct list_head	rl_all;
 	bool			rl_backchannel;


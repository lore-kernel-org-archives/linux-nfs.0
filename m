Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f178.google.com ([209.85.166.178]:40711 "EHLO
        mail-it1-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726418AbeJBBFr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 21:05:47 -0400
Subject: [PATCH v2 18/20] xprtrdma: Add documenting comments
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 01 Oct 2018 14:26:40 -0400
Message-ID: <20181001182640.18578.29782.stgit@manet.1015granger.net>
In-Reply-To: <20181001182005.18578.57544.stgit@manet.1015granger.net>
References: <20181001182005.18578.57544.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: fill in or update documenting comments for transport
switch entry points.

For xprt_rdma_allocate:

The first paragraph is no longer true since commit 5a6d1db45569
("SUNRPC: Add a transport-specific private field in rpc_rqst").

The second paragraph is no longer true since commit 54cbd6b0c6b9
("xprtrdma: Delay DMA mapping Send and Receive buffers").

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |   43 +++++++++++++++++++++------------------
 1 file changed, 23 insertions(+), 20 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index d7c4255..39b7991 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -256,6 +256,13 @@
 	}
 }
 
+/**
+ * xprt_rdma_inject_disconnect - inject a connection fault
+ * @xprt: transport context
+ *
+ * If @xprt is connected, disconnect it to simulate spurious connection
+ * loss.
+ */
 static void
 xprt_rdma_inject_disconnect(struct rpc_xprt *xprt)
 {
@@ -266,16 +273,12 @@
 	rdma_disconnect(r_xprt->rx_ia.ri_id);
 }
 
-/*
- * xprt_rdma_destroy
+/**
+ * xprt_rdma_destroy - Full tear down of transport
+ * @xprt: doomed transport context
  *
- * Destroy the xprt.
- * Free all memory associated with the object, including its own.
- * NOTE: none of the *destroy methods free memory for their top-level
- * objects, even though they may have allocated it (they do free
- * private memory). It's up to the caller to handle it. In this
- * case (RDMA transport), all structure memory is inlined with the
- * struct rpcrdma_xprt.
+ * Caller guarantees there will be no more calls to us with
+ * this @xprt.
  */
 static void
 xprt_rdma_destroy(struct rpc_xprt *xprt)
@@ -428,11 +431,12 @@
 }
 
 /**
- * xprt_rdma_close - Close down RDMA connection
- * @xprt: generic transport to be closed
+ * xprt_rdma_close - close a transport connection
+ * @xprt: transport context
  *
- * Called during transport shutdown reconnect, or device
- * removal. Caller holds the transport's write lock.
+ * Called during transport shutdown, reconnect, or device removal.
+ * Caller holds @xprt's send lock to prevent activity on this
+ * transport while the connection is torn down.
  */
 static void
 xprt_rdma_close(struct rpc_xprt *xprt)
@@ -511,6 +515,12 @@
 	xprt_force_disconnect(xprt);
 }
 
+/**
+ * xprt_rdma_connect - try to establish a transport connection
+ * @xprt: transport state
+ * @task: RPC scheduler context
+ *
+ */
 static void
 xprt_rdma_connect(struct rpc_xprt *xprt, struct rpc_task *task)
 {
@@ -630,13 +640,6 @@
  *        0:	Success; rq_buffer points to RPC buffer to use
  *   ENOMEM:	Out of memory, call again later
  *      EIO:	A permanent error occurred, do not retry
- *
- * The RDMA allocate/free functions need the task structure as a place
- * to hide the struct rpcrdma_req, which is necessary for the actual
- * send/recv sequence.
- *
- * xprt_rdma_allocate provides buffers that are already mapped for
- * DMA, and a local DMA lkey is provided for each.
  */
 static int
 xprt_rdma_allocate(struct rpc_task *task)

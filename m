Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:51659 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727940AbeIJUFP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Sep 2018 16:05:15 -0400
Subject: [PATCH v1 20/22] xprtrdma: Add documenting comments
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 10 Sep 2018 11:10:41 -0400
Message-ID: <20180910151041.10564.22475.stgit@manet.1015granger.net>
In-Reply-To: <20180910150040.10564.97487.stgit@manet.1015granger.net>
References: <20180910150040.10564.97487.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: fill in or update documenting comments for transport
switch entry points.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |   36 +++++++++++++++++++++++-------------
 1 file changed, 23 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index d7c4255..67eb900 100644
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

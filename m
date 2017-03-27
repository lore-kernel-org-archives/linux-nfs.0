Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:32816 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753085AbdC0OGa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Mar 2017 10:06:30 -0400
Subject: [PATCH v2 04/13] xprtrdma: Refactor rpcrdma_ia_open()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 27 Mar 2017 10:06:07 -0400
Message-ID: <20170327140607.20813.21752.stgit@manet.1015granger.net>
In-Reply-To: <20170327134847.20813.52412.stgit@manet.1015granger.net>
References: <20170327134847.20813.52412.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to unload a device driver and reload it, xprtrdma will need
to close a transport's interface adapter, and then call
rpcrdma_ia_open again, possibly finding a different interface
adapter.

Make rpcrdma_ia_open safe to call on the same transport multiple
times.

This is a refactoring change only.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |    6 +++--
 net/sunrpc/xprtrdma/verbs.c     |   46 ++++++++++++++++++++-------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    7 +++++-
 3 files changed, 32 insertions(+), 27 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index acf5d81..83e219d 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -66,8 +66,8 @@
 unsigned int xprt_rdma_max_inline_read = RPCRDMA_DEF_INLINE;
 static unsigned int xprt_rdma_max_inline_write = RPCRDMA_DEF_INLINE;
 static unsigned int xprt_rdma_inline_write_padding;
-static unsigned int xprt_rdma_memreg_strategy = RPCRDMA_FRMR;
-		int xprt_rdma_pad_optimize = 0;
+unsigned int xprt_rdma_memreg_strategy		= RPCRDMA_FRMR;
+int xprt_rdma_pad_optimize;
 
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 
@@ -396,7 +396,7 @@
 
 	new_xprt = rpcx_to_rdmax(xprt);
 
-	rc = rpcrdma_ia_open(new_xprt, sap, xprt_rdma_memreg_strategy);
+	rc = rpcrdma_ia_open(new_xprt, sap);
 	if (rc)
 		goto out1;
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 2e4fc1e..d4880d5 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -413,13 +413,16 @@ static void rpcrdma_destroy_id(struct rdma_cm_id *id)
  * Exported functions.
  */
 
-/*
- * Open and initialize an Interface Adapter.
- *  o initializes fields of struct rpcrdma_ia, including
- *    interface and provider attributes and protection zone.
+/**
+ * rpcrdma_ia_open - Open and initialize an Interface Adapter.
+ * @xprt: controlling transport
+ * @addr: IP address of remote peer
+ *
+ * Returns 0 on success, negative errno if an appropriate
+ * Interface Adapter could not be found and opened.
  */
 int
-rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
+rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr)
 {
 	struct rpcrdma_ia *ia = &xprt->rx_ia;
 	int rc;
@@ -427,7 +430,7 @@ static void rpcrdma_destroy_id(struct rdma_cm_id *id)
 	ia->ri_id = rpcrdma_create_id(xprt, ia, addr);
 	if (IS_ERR(ia->ri_id)) {
 		rc = PTR_ERR(ia->ri_id);
-		goto out1;
+		goto out_err;
 	}
 	ia->ri_device = ia->ri_id->device;
 
@@ -435,10 +438,10 @@ static void rpcrdma_destroy_id(struct rdma_cm_id *id)
 	if (IS_ERR(ia->ri_pd)) {
 		rc = PTR_ERR(ia->ri_pd);
 		pr_err("rpcrdma: ib_alloc_pd() returned %d\n", rc);
-		goto out2;
+		goto out_err;
 	}
 
-	switch (memreg) {
+	switch (xprt_rdma_memreg_strategy) {
 	case RPCRDMA_FRMR:
 		if (frwr_is_supported(ia)) {
 			ia->ri_ops = &rpcrdma_frwr_memreg_ops;
@@ -452,28 +455,23 @@ static void rpcrdma_destroy_id(struct rdma_cm_id *id)
 		}
 		/*FALLTHROUGH*/
 	default:
-		pr_err("rpcrdma: Unsupported memory registration mode: %d\n",
-		       memreg);
+		pr_err("rpcrdma: Device %s does not support memreg mode %d\n",
+		       ia->ri_device->name, xprt_rdma_memreg_strategy);
 		rc = -EINVAL;
-		goto out3;
+		goto out_err;
 	}
 
 	return 0;
 
-out3:
-	ib_dealloc_pd(ia->ri_pd);
-	ia->ri_pd = NULL;
-out2:
-	rpcrdma_destroy_id(ia->ri_id);
-	ia->ri_id = NULL;
-out1:
+out_err:
+	rpcrdma_ia_close(ia);
 	return rc;
 }
 
-/*
- * Clean up/close an IA.
- *   o if event handles and PD have been initialized, free them.
- *   o close the IA
+/**
+ * rpcrdma_ia_close - Clean up/close an IA.
+ * @ia: interface adapter to close
+ *
  */
 void
 rpcrdma_ia_close(struct rpcrdma_ia *ia)
@@ -483,12 +481,14 @@ static void rpcrdma_destroy_id(struct rdma_cm_id *id)
 		if (ia->ri_id->qp)
 			rdma_destroy_qp(ia->ri_id);
 		rpcrdma_destroy_id(ia->ri_id);
-		ia->ri_id = NULL;
 	}
+	ia->ri_id = NULL;
+	ia->ri_device = NULL;
 
 	/* If the pd is still busy, xprtrdma missed freeing a resource */
 	if (ia->ri_pd && !IS_ERR(ia->ri_pd))
 		ib_dealloc_pd(ia->ri_pd);
+	ia->ri_pd = NULL;
 }
 
 /*
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 171a351..af844fc 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -497,10 +497,15 @@ struct rpcrdma_xprt {
  * Default is 0, see sysctl entry and rpc_rdma.c rpcrdma_convert_iovs() */
 extern int xprt_rdma_pad_optimize;
 
+/* This setting controls the hunt for a supported memory
+ * registration strategy.
+ */
+extern unsigned int xprt_rdma_memreg_strategy;
+
 /*
  * Interface Adapter calls - xprtrdma/verbs.c
  */
-int rpcrdma_ia_open(struct rpcrdma_xprt *, struct sockaddr *, int);
+int rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr);
 void rpcrdma_ia_close(struct rpcrdma_ia *);
 bool frwr_is_supported(struct rpcrdma_ia *);
 bool fmr_is_supported(struct rpcrdma_ia *);


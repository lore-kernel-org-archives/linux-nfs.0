From: Tom Talpey <talpey@netapp.com>
Subject: [PATCH 03/15] RPC/RDMA: check selected memory registration mode at
	runtime.
Date: Wed, 08 Oct 2008 11:47:24 -0400
Message-ID: <20081008154723.1336.57976.stgit@tmt3.nane.netapp.com>
References: <20081008154506.1336.59892.stgit@tmt3.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [216.240.26.4] ([216.240.26.4]:44118 "EHLO tmt3.nane.netapp.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754640AbYJHQWW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 12:22:22 -0400
Received: from tmt3.nane.netapp.com (localhost.localdomain [127.0.0.1])
	by tmt3.nane.netapp.com (8.14.2/8.14.2) with ESMTP id m98FlONk001439
	for <linux-nfs@vger.kernel.org>; Wed, 8 Oct 2008 11:47:24 -0400
In-Reply-To: <20081008154506.1336.59892.stgit-pfX4bTJKMULWwzOYslWYilaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At transport creation, check for, and use, any local dma lkey.
Then, check that the selected memory registration mode is in fact
supported by the RDMA adapter selected for the mount. Fall back
to best alternative if not.

Signed-off-by: Tom Talpey <talpey@netapp.com>
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/xprtrdma/verbs.c |   95 ++++++++++++++++++++++++++++++++++++-------
 1 files changed, 80 insertions(+), 15 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index d04208a..0f3b431 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -423,7 +423,8 @@ rpcrdma_clean_cq(struct ib_cq *cq)
 int
 rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 {
-	int rc;
+	int rc, mem_priv;
+	struct ib_device_attr devattr;
 	struct rpcrdma_ia *ia = &xprt->rx_ia;
 
 	init_completion(&ia->ri_done);
@@ -443,6 +444,53 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 	}
 
 	/*
+	 * Query the device to determine if the requested memory
+	 * registration strategy is supported. If it isn't, set the
+	 * strategy to a globally supported model.
+	 */
+	rc = ib_query_device(ia->ri_id->device, &devattr);
+	if (rc) {
+		dprintk("RPC:       %s: ib_query_device failed %d\n",
+			__func__, rc);
+		goto out2;
+	}
+
+	if (devattr.device_cap_flags & IB_DEVICE_LOCAL_DMA_LKEY) {
+		ia->ri_have_dma_lkey = 1;
+		ia->ri_dma_lkey = ia->ri_id->device->local_dma_lkey;
+	}
+
+	switch (memreg) {
+	case RPCRDMA_MEMWINDOWS:
+	case RPCRDMA_MEMWINDOWS_ASYNC:
+		if (!(devattr.device_cap_flags & IB_DEVICE_MEM_WINDOW)) {
+			dprintk("RPC:       %s: MEMWINDOWS registration "
+				"specified but not supported by adapter, "
+				"using slower RPCRDMA_REGISTER\n",
+				__func__);
+			memreg = RPCRDMA_REGISTER;
+		}
+		break;
+	case RPCRDMA_MTHCAFMR:
+		if (!ia->ri_id->device->alloc_fmr) {
+#if RPCRDMA_PERSISTENT_REGISTRATION
+			dprintk("RPC:       %s: MTHCAFMR registration "
+				"specified but not supported by adapter, "
+				"using riskier RPCRDMA_ALLPHYSICAL\n",
+				__func__);
+			memreg = RPCRDMA_ALLPHYSICAL;
+#else
+			dprintk("RPC:       %s: MTHCAFMR registration "
+				"specified but not supported by adapter, "
+				"using slower RPCRDMA_REGISTER\n",
+				__func__);
+			memreg = RPCRDMA_REGISTER;
+#endif
+		}
+		break;
+	}
+
+	/*
 	 * Optionally obtain an underlying physical identity mapping in
 	 * order to do a memory window-based bind. This base registration
 	 * is protected from remote access - that is enabled only by binding
@@ -450,22 +498,27 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 	 * revoked after the corresponding completion similar to a storage
 	 * adapter.
 	 */
-	if (memreg > RPCRDMA_REGISTER) {
-		int mem_priv = IB_ACCESS_LOCAL_WRITE;
-		switch (memreg) {
+	switch (memreg) {
+	case RPCRDMA_BOUNCEBUFFERS:
+	case RPCRDMA_REGISTER:
+		break;
 #if RPCRDMA_PERSISTENT_REGISTRATION
-		case RPCRDMA_ALLPHYSICAL:
-			mem_priv |= IB_ACCESS_REMOTE_WRITE;
-			mem_priv |= IB_ACCESS_REMOTE_READ;
-			break;
+	case RPCRDMA_ALLPHYSICAL:
+		mem_priv = IB_ACCESS_LOCAL_WRITE |
+				IB_ACCESS_REMOTE_WRITE |
+				IB_ACCESS_REMOTE_READ;
+		goto register_setup;
 #endif
-		case RPCRDMA_MEMWINDOWS_ASYNC:
-		case RPCRDMA_MEMWINDOWS:
-			mem_priv |= IB_ACCESS_MW_BIND;
-			break;
-		default:
+	case RPCRDMA_MEMWINDOWS_ASYNC:
+	case RPCRDMA_MEMWINDOWS:
+		mem_priv = IB_ACCESS_LOCAL_WRITE |
+				IB_ACCESS_MW_BIND;
+		goto register_setup;
+	case RPCRDMA_MTHCAFMR:
+		if (ia->ri_have_dma_lkey)
 			break;
-		}
+		mem_priv = IB_ACCESS_LOCAL_WRITE;
+	register_setup:
 		ia->ri_bind_mem = ib_get_dma_mr(ia->ri_pd, mem_priv);
 		if (IS_ERR(ia->ri_bind_mem)) {
 			printk(KERN_ALERT "%s: ib_get_dma_mr for "
@@ -475,7 +528,15 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 			memreg = RPCRDMA_REGISTER;
 			ia->ri_bind_mem = NULL;
 		}
+		break;
+	default:
+		printk(KERN_ERR "%s: invalid memory registration mode %d\n",
+				__func__, memreg);
+		rc = -EINVAL;
+		goto out2;
 	}
+	dprintk("RPC:       %s: memory registration strategy is %d\n",
+		__func__, memreg);
 
 	/* Else will do memory reg/dereg for each chunk */
 	ia->ri_memreg_strategy = memreg;
@@ -1248,7 +1309,11 @@ rpcrdma_register_internal(struct rpcrdma_ia *ia, void *va, int len,
 			va, len, DMA_BIDIRECTIONAL);
 	iov->length = len;
 
-	if (ia->ri_bind_mem != NULL) {
+	if (ia->ri_have_dma_lkey) {
+		*mrp = NULL;
+		iov->lkey = ia->ri_dma_lkey;
+		return 0;
+	} else if (ia->ri_bind_mem != NULL) {
 		*mrp = NULL;
 		iov->lkey = ia->ri_bind_mem->lkey;
 		return 0;


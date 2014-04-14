Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:52903 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755002AbaDNWWv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2014 18:22:51 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/8] xprtrdma: Disable ALLPHYSICAL mode by default
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Mon, 14 Apr 2014 18:22:49 -0400
Message-ID: <20140414222249.20646.47882.stgit@manet.1015granger.net>
In-Reply-To: <20140414220041.20646.63991.stgit@manet.1015granger.net>
References: <20140414220041.20646.63991.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

ALLPHYSICAL is not a safe memory registration mode because it
permits NFS servers to write anywhere in a client's memory.  NFS
server bugs could result in client memory being overwritten.

This can be useful for embedded systems which do not support more
surgical RDMA memory registration and protection methods. However,
enterprise Linux distributions have expressed a desire to disable
or remove it entirely.

As a compromise (or as a step towards deprecation), add a CONFIG
setting (by default N) to enable ALLPHYSICAL support.

ALLPHYSICAL is now never a fallback choice when HCAs do not support
the selected memory registration mode.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xprtrdma.h |    3 ---
 net/sunrpc/Kconfig              |   15 +++++++++++++++
 net/sunrpc/xprtrdma/verbs.c     |   22 +++-------------------
 3 files changed, 18 insertions(+), 22 deletions(-)

diff --git a/include/linux/sunrpc/xprtrdma.h b/include/linux/sunrpc/xprtrdma.h
index c2f04e1..54e9b47 100644
--- a/include/linux/sunrpc/xprtrdma.h
+++ b/include/linux/sunrpc/xprtrdma.h
@@ -61,9 +61,6 @@
 
 #define RPCRDMA_INLINE_PAD_THRESH  (512)/* payload threshold to pad (bytes) */
 
-/* memory registration strategies */
-#define RPCRDMA_PERSISTENT_REGISTRATION (1)
-
 enum rpcrdma_memreg {
 	RPCRDMA_BOUNCEBUFFERS = 0,
 	RPCRDMA_REGISTER,
diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index 0754d0f..af56554 100644
--- a/net/sunrpc/Kconfig
+++ b/net/sunrpc/Kconfig
@@ -58,6 +58,21 @@ config SUNRPC_XPRT_RDMA_CLIENT
 
 	  If unsure, say N.
 
+config SUNRPC_XPRT_RDMA_CLIENT_ALLPHYSICAL
+	bool "Enable ALLPHYSICAL memory registration mode"
+	depends on SUNRPC_XPRT_RDMA_CLIENT
+	default N
+	help
+	  This option enables support for the ALLPHYSICAL memory
+	  registration mode.
+
+	  This mode is very fast but not safe because it registers
+	  and exposes all of local memory. This could allow an
+	  NFS server bug to corrupt client memory.
+
+	  N is almost always the correct choice unless you are
+	  sure what you are doing.
+
 config SUNRPC_XPRT_RDMA_SERVER
 	tristate "RPC over RDMA Server Support"
 	depends on SUNRPC && INFINIBAND && INFINIBAND_ADDR_TRANS
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 1fe554f..6373232 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -506,19 +506,11 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 		break;
 	case RPCRDMA_MTHCAFMR:
 		if (!ia->ri_id->device->alloc_fmr) {
-#if RPCRDMA_PERSISTENT_REGISTRATION
-			dprintk("RPC:       %s: MTHCAFMR registration "
-				"specified but not supported by adapter, "
-				"using riskier RPCRDMA_ALLPHYSICAL\n",
-				__func__);
-			memreg = RPCRDMA_ALLPHYSICAL;
-#else
 			dprintk("RPC:       %s: MTHCAFMR registration "
 				"specified but not supported by adapter, "
 				"using slower RPCRDMA_REGISTER\n",
 				__func__);
 			memreg = RPCRDMA_REGISTER;
-#endif
 		}
 		break;
 	case RPCRDMA_FRMR:
@@ -526,19 +518,11 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 		if ((devattr.device_cap_flags &
 		     (IB_DEVICE_MEM_MGT_EXTENSIONS|IB_DEVICE_LOCAL_DMA_LKEY)) !=
 		    (IB_DEVICE_MEM_MGT_EXTENSIONS|IB_DEVICE_LOCAL_DMA_LKEY)) {
-#if RPCRDMA_PERSISTENT_REGISTRATION
-			dprintk("RPC:       %s: FRMR registration "
-				"specified but not supported by adapter, "
-				"using riskier RPCRDMA_ALLPHYSICAL\n",
-				__func__);
-			memreg = RPCRDMA_ALLPHYSICAL;
-#else
 			dprintk("RPC:       %s: FRMR registration "
 				"specified but not supported by adapter, "
 				"using slower RPCRDMA_REGISTER\n",
 				__func__);
 			memreg = RPCRDMA_REGISTER;
-#endif
 		} else {
 			/* Mind the ia limit on FRMR page list depth */
 			ia->ri_max_frmr_depth = min_t(unsigned int,
@@ -560,7 +544,7 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 	case RPCRDMA_REGISTER:
 	case RPCRDMA_FRMR:
 		break;
-#if RPCRDMA_PERSISTENT_REGISTRATION
+#ifdef CONFIG_SUNRPC_XPRT_RDMA_CLIENT_ALLPHYSICAL
 	case RPCRDMA_ALLPHYSICAL:
 		mem_priv = IB_ACCESS_LOCAL_WRITE |
 				IB_ACCESS_REMOTE_WRITE |
@@ -1824,7 +1808,7 @@ rpcrdma_register_external(struct rpcrdma_mr_seg *seg,
 
 	switch (ia->ri_memreg_strategy) {
 
-#if RPCRDMA_PERSISTENT_REGISTRATION
+#ifdef CONFIG_SUNRPC_XPRT_RDMA_CLIENT_ALLPHYSICAL
 	case RPCRDMA_ALLPHYSICAL:
 		rpcrdma_map_one(ia, seg, writing);
 		seg->mr_rkey = ia->ri_bind_mem->rkey;
@@ -1870,7 +1854,7 @@ rpcrdma_deregister_external(struct rpcrdma_mr_seg *seg,
 
 	switch (ia->ri_memreg_strategy) {
 
-#if RPCRDMA_PERSISTENT_REGISTRATION
+#ifdef CONFIG_SUNRPC_XPRT_RDMA_CLIENT_ALLPHYSICAL
 	case RPCRDMA_ALLPHYSICAL:
 		BUG_ON(nsegs != 1);
 		rpcrdma_unmap_one(ia, seg);


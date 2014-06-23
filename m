Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:61653 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbaFWWkl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 18:40:41 -0400
Subject: [PATCH v1 12/13] xprtrdma: Remove RPCRDMA_PERSISTENT_REGISTRATION
 macro
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 23 Jun 2014 18:40:39 -0400
Message-ID: <20140623224039.1634.25323.stgit@manet.1015granger.net>
In-Reply-To: <20140623223201.1634.83888.stgit@manet.1015granger.net>
References: <20140623223201.1634.83888.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

RPCRDMA_PERSISTENT_REGISTRATION was a compile-time switch between
RPCRDMA_REGISTER mode and RPCRDMA_ALLPHYSICAL mode.  Since
RPCRDMA_REGISTER has been removed, there's no need for the extra
conditional compilation.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/xprtrdma.h |    2 --
 net/sunrpc/xprtrdma/verbs.c     |   13 -------------
 2 files changed, 15 deletions(-)

diff --git a/include/linux/sunrpc/xprtrdma.h b/include/linux/sunrpc/xprtrdma.h
index c2f04e1..64a0a0a 100644
--- a/include/linux/sunrpc/xprtrdma.h
+++ b/include/linux/sunrpc/xprtrdma.h
@@ -62,8 +62,6 @@
 #define RPCRDMA_INLINE_PAD_THRESH  (512)/* payload threshold to pad (bytes) */
 
 /* memory registration strategies */
-#define RPCRDMA_PERSISTENT_REGISTRATION (1)
-
 enum rpcrdma_memreg {
 	RPCRDMA_BOUNCEBUFFERS = 0,
 	RPCRDMA_REGISTER,
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index b6c52c7..ec98e48 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -569,12 +569,7 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 		if (!ia->ri_id->device->alloc_fmr) {
 			dprintk("RPC:       %s: MTHCAFMR registration "
 				"not supported by HCA\n", __func__);
-#if RPCRDMA_PERSISTENT_REGISTRATION
 			memreg = RPCRDMA_ALLPHYSICAL;
-#else
-			rc = -ENOMEM;
-			goto out2;
-#endif
 		}
 	}
 
@@ -589,20 +584,16 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 	switch (memreg) {
 	case RPCRDMA_FRMR:
 		break;
-#if RPCRDMA_PERSISTENT_REGISTRATION
 	case RPCRDMA_ALLPHYSICAL:
 		mem_priv = IB_ACCESS_LOCAL_WRITE |
 				IB_ACCESS_REMOTE_WRITE |
 				IB_ACCESS_REMOTE_READ;
 		goto register_setup;
-#endif
 	case RPCRDMA_MTHCAFMR:
 		if (ia->ri_have_dma_lkey)
 			break;
 		mem_priv = IB_ACCESS_LOCAL_WRITE;
-#if RPCRDMA_PERSISTENT_REGISTRATION
 	register_setup:
-#endif
 		ia->ri_bind_mem = ib_get_dma_mr(ia->ri_pd, mem_priv);
 		if (IS_ERR(ia->ri_bind_mem)) {
 			printk(KERN_ALERT "%s: ib_get_dma_mr for "
@@ -1770,7 +1761,6 @@ rpcrdma_register_external(struct rpcrdma_mr_seg *seg,
 
 	switch (ia->ri_memreg_strategy) {
 
-#if RPCRDMA_PERSISTENT_REGISTRATION
 	case RPCRDMA_ALLPHYSICAL:
 		rpcrdma_map_one(ia, seg, writing);
 		seg->mr_rkey = ia->ri_bind_mem->rkey;
@@ -1778,7 +1768,6 @@ rpcrdma_register_external(struct rpcrdma_mr_seg *seg,
 		seg->mr_nsegs = 1;
 		nsegs = 1;
 		break;
-#endif
 
 	/* Registration using frmr registration */
 	case RPCRDMA_FRMR:
@@ -1808,11 +1797,9 @@ rpcrdma_deregister_external(struct rpcrdma_mr_seg *seg,
 
 	switch (ia->ri_memreg_strategy) {
 
-#if RPCRDMA_PERSISTENT_REGISTRATION
 	case RPCRDMA_ALLPHYSICAL:
 		rpcrdma_unmap_one(ia, seg);
 		break;
-#endif
 
 	case RPCRDMA_FRMR:
 		rc = rpcrdma_deregister_frmr_external(seg, ia, r_xprt);


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:59360 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754666AbaGIQ7Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jul 2014 12:59:25 -0400
Subject: [PATCH v2 20/21] xprtrdma: Remove RPCRDMA_PERSISTENT_REGISTRATION
 macro
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 09 Jul 2014 12:59:23 -0400
Message-ID: <20140709165923.3496.48126.stgit@manet.1015granger.net>
In-Reply-To: <20140709163326.3496.37893.stgit@manet.1015granger.net>
References: <20140709163326.3496.37893.stgit@manet.1015granger.net>
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
index da4bbf3..bc0909a 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -561,12 +561,7 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
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
 
@@ -581,20 +576,16 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
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
@@ -1914,7 +1905,6 @@ rpcrdma_register_external(struct rpcrdma_mr_seg *seg,
 
 	switch (ia->ri_memreg_strategy) {
 
-#if RPCRDMA_PERSISTENT_REGISTRATION
 	case RPCRDMA_ALLPHYSICAL:
 		rpcrdma_map_one(ia, seg, writing);
 		seg->mr_rkey = ia->ri_bind_mem->rkey;
@@ -1922,7 +1912,6 @@ rpcrdma_register_external(struct rpcrdma_mr_seg *seg,
 		seg->mr_nsegs = 1;
 		nsegs = 1;
 		break;
-#endif
 
 	/* Registration using frmr registration */
 	case RPCRDMA_FRMR:
@@ -1952,13 +1941,11 @@ rpcrdma_deregister_external(struct rpcrdma_mr_seg *seg,
 
 	switch (ia->ri_memreg_strategy) {
 
-#if RPCRDMA_PERSISTENT_REGISTRATION
 	case RPCRDMA_ALLPHYSICAL:
 		read_lock(&ia->ri_qplock);
 		rpcrdma_unmap_one(ia, seg);
 		read_unlock(&ia->ri_qplock);
 		break;
-#endif
 
 	case RPCRDMA_FRMR:
 		rc = rpcrdma_deregister_frmr_external(seg, ia, r_xprt);


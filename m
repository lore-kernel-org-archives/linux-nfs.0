Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f171.google.com ([209.85.223.171]:39698 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753801AbaE1Ocx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 May 2014 10:32:53 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v5 07/24] xprtrdma: Fall back to MTHCAFMR when FRMR is not
	supported
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Cc: Anna.Schumaker@netapp.com
Date: Wed, 28 May 2014 10:32:51 -0400
Message-ID: <20140528143251.23214.68022.stgit@manet.1015granger.net>
In-Reply-To: <20140528142521.23214.39655.stgit@manet.1015granger.net>
References: <20140528142521.23214.39655.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An audit of in-kernel RDMA providers that do not support the FRMR
memory registration shows that several of them support MTHCAFMR.
Prefer MTHCAFMR when FRMR is not supported.

If MTHCAFMR is not supported, only then choose ALLPHYSICAL.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/verbs.c |   31 +++++++++++++++----------------
 1 files changed, 15 insertions(+), 16 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 6bb9a07..a352798 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -491,33 +491,32 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 		ia->ri_dma_lkey = ia->ri_id->device->local_dma_lkey;
 	}
 
-	switch (memreg) {
-	case RPCRDMA_MTHCAFMR:
-		if (!ia->ri_id->device->alloc_fmr) {
-			dprintk("RPC:       %s: MTHCAFMR registration "
-				"specified but not supported by adapter, "
-				"using riskier RPCRDMA_ALLPHYSICAL\n",
-				__func__);
-			memreg = RPCRDMA_ALLPHYSICAL;
-		}
-		break;
-	case RPCRDMA_FRMR:
+	if (memreg == RPCRDMA_FRMR) {
 		/* Requires both frmr reg and local dma lkey */
 		if ((devattr.device_cap_flags &
 		     (IB_DEVICE_MEM_MGT_EXTENSIONS|IB_DEVICE_LOCAL_DMA_LKEY)) !=
 		    (IB_DEVICE_MEM_MGT_EXTENSIONS|IB_DEVICE_LOCAL_DMA_LKEY)) {
 			dprintk("RPC:       %s: FRMR registration "
-				"specified but not supported by adapter, "
-				"using riskier RPCRDMA_ALLPHYSICAL\n",
-				__func__);
-			memreg = RPCRDMA_ALLPHYSICAL;
+				"not supported by HCA\n", __func__);
+			memreg = RPCRDMA_MTHCAFMR;
 		} else {
 			/* Mind the ia limit on FRMR page list depth */
 			ia->ri_max_frmr_depth = min_t(unsigned int,
 				RPCRDMA_MAX_DATA_SEGS,
 				devattr.max_fast_reg_page_list_len);
 		}
-		break;
+	}
+	if (memreg == RPCRDMA_MTHCAFMR) {
+		if (!ia->ri_id->device->alloc_fmr) {
+			dprintk("RPC:       %s: MTHCAFMR registration "
+				"not supported by HCA\n", __func__);
+#if RPCRDMA_PERSISTENT_REGISTRATION
+			memreg = RPCRDMA_ALLPHYSICAL;
+#else
+			rc = -EINVAL;
+			goto out2;
+#endif
+		}
 	}
 
 	/*


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34596 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933032AbcFTQKB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jun 2016 12:10:01 -0400
Subject: [PATCH v3 10/25] xprtrdma: Clean up device capability detection
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 20 Jun 2016 12:09:56 -0400
Message-ID: <20160620160956.10809.46118.stgit@manet.1015granger.net>
In-Reply-To: <20160620155751.10809.22262.stgit@manet.1015granger.net>
References: <20160620155751.10809.22262.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Move device capability detection into memreg-specific
source files.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c   |   11 +++++++++++
 net/sunrpc/xprtrdma/frwr_ops.c  |   17 +++++++++++++++++
 net/sunrpc/xprtrdma/verbs.c     |   11 ++---------
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 ++
 4 files changed, 32 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index eb42d7f..022c363 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -34,6 +34,17 @@ enum {
 					  IB_ACCESS_REMOTE_READ,
 };
 
+bool
+fmr_is_supported(struct rpcrdma_ia *ia)
+{
+	if (!ia->ri_device->alloc_fmr) {
+		pr_info("rpcrdma: 'fmr' mode is not supported by device %s\n",
+			ia->ri_device->name);
+		return false;
+	}
+	return true;
+}
+
 static int
 __fmr_init(struct rpcrdma_mw *mw, struct ib_pd *pd)
 {
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index c9ead2b..fc2826b 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -73,6 +73,23 @@
 # define RPCDBG_FACILITY	RPCDBG_TRANS
 #endif
 
+bool
+frwr_is_supported(struct rpcrdma_ia *ia)
+{
+	struct ib_device_attr *attrs = &ia->ri_device->attrs;
+
+	if (!(attrs->device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS))
+		goto out_not_supported;
+	if (attrs->max_fast_reg_page_list_len == 0)
+		goto out_not_supported;
+	return true;
+
+out_not_supported:
+	pr_info("rpcrdma: 'frwr' mode is not supported by device %s\n",
+		ia->ri_device->name);
+	return false;
+}
+
 static int
 __frwr_init(struct rpcrdma_mw *r, struct ib_pd *pd, unsigned int depth)
 {
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index b80e767f..dbed9ba 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -395,18 +395,11 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 	}
 
 	if (memreg == RPCRDMA_FRMR) {
-		if (!(ia->ri_device->attrs.device_cap_flags &
-				IB_DEVICE_MEM_MGT_EXTENSIONS) ||
-		    (ia->ri_device->attrs.max_fast_reg_page_list_len == 0)) {
-			dprintk("RPC:       %s: FRMR registration "
-				"not supported by HCA\n", __func__);
+		if (!frwr_is_supported(ia))
 			memreg = RPCRDMA_MTHCAFMR;
-		}
 	}
 	if (memreg == RPCRDMA_MTHCAFMR) {
-		if (!ia->ri_device->alloc_fmr) {
-			dprintk("RPC:       %s: MTHCAFMR registration "
-				"not supported by HCA\n", __func__);
+		if (!fmr_is_supported(ia)) {
 			rc = -EINVAL;
 			goto out3;
 		}
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index f1b6f2f..08d441d 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -446,6 +446,8 @@ extern int xprt_rdma_pad_optimize;
  */
 int rpcrdma_ia_open(struct rpcrdma_xprt *, struct sockaddr *, int);
 void rpcrdma_ia_close(struct rpcrdma_ia *);
+bool frwr_is_supported(struct rpcrdma_ia *);
+bool fmr_is_supported(struct rpcrdma_ia *);
 
 /*
  * Endpoint calls - xprtrdma/verbs.c


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f196.google.com ([209.85.166.196]:54916 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726362AbeJBAzK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 20:55:10 -0400
Subject: [PATCH v1 3/4] svcrdma: Remove try_module_get from backchannel
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 01 Oct 2018 14:16:06 -0400
Message-ID: <20181001181606.2305.48044.stgit@klimt.1015granger.net>
In-Reply-To: <20181001181414.2305.94635.stgit@klimt.1015granger.net>
References: <20181001181414.2305.94635.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since commit ffe1f0df5862 ("rpcrdma: Merge svcrdma and xprtrdma
modules into one"), the forward and backchannel components are part
of the same kernel module. A separate try_module_get() call in the
backchannel code is no longer necessary.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   14 --------------
 1 file changed, 14 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index 642f031..7e188bc 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -5,8 +5,6 @@
  * Support for backward direction RPCs on RPC/RDMA (server-side).
  */
 
-#include <linux/module.h>
-
 #include <linux/sunrpc/svc_rdma.h>
 
 #include "xprt_rdma.h"
@@ -255,7 +253,6 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
 	dprintk("svcrdma: %s: xprt %p\n", __func__, xprt);
 
 	xprt_free(xprt);
-	module_put(THIS_MODULE);
 }
 
 static const struct rpc_xprt_ops xprt_rdma_bc_procs = {
@@ -327,20 +324,9 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
 	args->bc_xprt->xpt_bc_xprt = xprt;
 	xprt->bc_xprt = args->bc_xprt;
 
-	if (!try_module_get(THIS_MODULE))
-		goto out_fail;
-
 	/* Final put for backchannel xprt is in __svc_rdma_free */
 	xprt_get(xprt);
 	return xprt;
-
-out_fail:
-	xprt_rdma_free_addresses(xprt);
-	args->bc_xprt->xpt_bc_xprt = NULL;
-	args->bc_xprt->xpt_bc_xps = NULL;
-	xprt_put(xprt);
-	xprt_free(xprt);
-	return ERR_PTR(-EINVAL);
 }
 
 struct xprt_class xprt_rdma_bc = {

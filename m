Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35000 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933160AbdCJQHU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Mar 2017 11:07:20 -0500
Subject: [PATCH v1 11/11] xprtrdma: Revert commit d0f36c46deea
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 10 Mar 2017 11:07:18 -0500
Message-ID: <20170310160717.6314.12909.stgit@manet.1015granger.net>
In-Reply-To: <20170310154131.6314.35201.stgit@manet.1015granger.net>
References: <20170310154131.6314.35201.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Device removal is now adequately supported. Pinning the underlying
device driver to prevent removal while an NFS mount is active is no
longer necessary.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   33 +++++++--------------------------
 1 file changed, 7 insertions(+), 26 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index ef3ceec..41f00c9 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -53,7 +53,7 @@
 #include <linux/sunrpc/addr.h>
 #include <linux/sunrpc/svc_rdma.h>
 #include <asm/bitops.h>
-#include <linux/module.h> /* try_module_get()/module_put() */
+
 #include <rdma/ib_cm.h>
 
 #include "xprt_rdma.h"
@@ -344,14 +344,6 @@
 	return 0;
 }
 
-static void rpcrdma_destroy_id(struct rdma_cm_id *id)
-{
-	if (id) {
-		module_put(id->device->owner);
-		rdma_destroy_id(id);
-	}
-}
-
 static struct rdma_cm_id *
 rpcrdma_create_id(struct rpcrdma_xprt *xprt,
 			struct rpcrdma_ia *ia, struct sockaddr *addr)
@@ -386,16 +378,6 @@ static void rpcrdma_destroy_id(struct rdma_cm_id *id)
 		goto out;
 	}
 
-	/* FIXME:
-	 * Until xprtrdma supports DEVICE_REMOVAL, the provider must
-	 * be pinned while there are active NFS/RDMA mounts to prevent
-	 * hangs and crashes at umount time.
-	 */
-	if (!ia->ri_async_rc && !try_module_get(id->device->owner)) {
-		dprintk("RPC:       %s: Failed to get device module\n",
-			__func__);
-		ia->ri_async_rc = -ENODEV;
-	}
 	rc = ia->ri_async_rc;
 	if (rc)
 		goto out;
@@ -405,21 +387,20 @@ static void rpcrdma_destroy_id(struct rdma_cm_id *id)
 	if (rc) {
 		dprintk("RPC:       %s: rdma_resolve_route() failed %i\n",
 			__func__, rc);
-		goto put;
+		goto out;
 	}
 	rc = wait_for_completion_interruptible_timeout(&ia->ri_done, wtimeout);
 	if (rc < 0) {
 		dprintk("RPC:       %s: wait() exited: %i\n",
 			__func__, rc);
-		goto put;
+		goto out;
 	}
 	rc = ia->ri_async_rc;
 	if (rc)
-		goto put;
+		goto out;
 
 	return id;
-put:
-	module_put(id->device->owner);
+
 out:
 	rdma_destroy_id(id);
 	return ERR_PTR(rc);
@@ -546,7 +527,7 @@ static void rpcrdma_destroy_id(struct rdma_cm_id *id)
 	if (ia->ri_id != NULL && !IS_ERR(ia->ri_id)) {
 		if (ia->ri_id->qp)
 			rdma_destroy_qp(ia->ri_id);
-		rpcrdma_destroy_id(ia->ri_id);
+		rdma_destroy_id(ia->ri_id);
 	}
 	ia->ri_id = NULL;
 	ia->ri_device = NULL;
@@ -799,7 +780,7 @@ static void rpcrdma_destroy_id(struct rdma_cm_id *id)
 	rdma_destroy_qp(old);
 
 out_destroy:
-	rpcrdma_destroy_id(old);
+	rdma_destroy_id(old);
 out:
 	return rc;
 }


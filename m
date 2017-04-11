Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34248 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752755AbdDKRXm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Apr 2017 13:23:42 -0400
Subject: [PATCH v3 09/13] xprtrdma: Revert commit d0f36c46deea
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 11 Apr 2017 13:23:34 -0400
Message-ID: <20170411172334.11300.35058.stgit@manet.1015granger.net>
In-Reply-To: <20170411171820.11300.55637.stgit@manet.1015granger.net>
References: <20170411171820.11300.55637.stgit@manet.1015granger.net>
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
index b69daa3..d7c1600 100644
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
@@ -800,7 +781,7 @@ static void rpcrdma_destroy_id(struct rdma_cm_id *id)
 	rdma_destroy_qp(old);
 
 out_destroy:
-	rpcrdma_destroy_id(old);
+	rdma_destroy_id(old);
 out:
 	return rc;
 }


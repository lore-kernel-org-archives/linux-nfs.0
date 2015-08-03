Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:36007 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753866AbbHCRFH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Aug 2015 13:05:07 -0400
Subject: [PATCH v4 16/16] xprtrdma: take HCA driver refcount at client
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 03 Aug 2015 13:05:04 -0400
Message-ID: <20150803170504.9115.48166.stgit@manet.1015granger.net>
In-Reply-To: <20150803165807.9115.23842.stgit@manet.1015granger.net>
References: <20150803165807.9115.23842.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Devesh Sharma <devesh.sharma@avagotech.com>

This is a rework of the following patch sent almost a year back:
http://www.mail-archive.com/linux-rdma%40vger.kernel.org/msg20730.html

In presence of active mount if someone tries to rmmod vendor-driver, the
command remains stuck forever waiting for destruction of all rdma-cm-id.
in worst case client can crash during shutdown with active mounts.

The existing code assumes that ia->ri_id->device cannot change during
the lifetime of a transport. xprtrdma do not have support for
DEVICE_REMOVAL event either. Lifting that assumption and adding support
for DEVICE_REMOVAL event is a long chain of work, and is in plan.

The community decided that preventing the hang right now is more
important than waiting for architectural changes.

Thus, this patch introduces a temporary workaround to acquire HCA driver
module reference count during the mount of a nfs-rdma mount point.

Signed-off-by: Devesh Sharma <devesh.sharma@avagotech.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Sagi Grimberg <sagig@dev.mellanox.co.il>
---
 net/sunrpc/xprtrdma/verbs.c |   41 +++++++++++++++++++++++++++++++++--------
 1 file changed, 33 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index b4d4f63..b98fb3b 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -52,6 +52,7 @@
 #include <linux/prefetch.h>
 #include <linux/sunrpc/addr.h>
 #include <asm/bitops.h>
+#include <linux/module.h> /* try_module_get()/module_put() */
 
 #include "xprt_rdma.h"
 
@@ -414,6 +415,16 @@ connected:
 	return 0;
 }
 
+static void rpcrdma_destroy_id(struct rdma_cm_id *id)
+{
+	if (id) {
+		pr_warn("%s: releasing provider for id %p\n",
+			__func__, id);
+		module_put(id->device->owner);
+		rdma_destroy_id(id);
+	}
+}
+
 static struct rdma_cm_id *
 rpcrdma_create_id(struct rpcrdma_xprt *xprt,
 			struct rpcrdma_ia *ia, struct sockaddr *addr)
@@ -440,25 +451,39 @@ rpcrdma_create_id(struct rpcrdma_xprt *xprt,
 	}
 	wait_for_completion_interruptible_timeout(&ia->ri_done,
 				msecs_to_jiffies(RDMA_RESOLVE_TIMEOUT) + 1);
+
+	/* FIXME:
+	 * Until xprtrdma supports DEVICE_REMOVAL, the provider must
+	 * be pinned while there are active NFS/RDMA mounts to prevent
+	 * hangs and crashes at umount time.
+	 */
+	if (!ia->ri_async_rc && !try_module_get(id->device->owner)) {
+		dprintk("RPC:       %s: Failed to get device module\n",
+			__func__);
+		ia->ri_async_rc = -ENODEV;
+	}
 	rc = ia->ri_async_rc;
 	if (rc)
 		goto out;
 
+	pr_warn("%s: pinning provider for id %p\n", __func__, id);
+
 	ia->ri_async_rc = -ETIMEDOUT;
 	rc = rdma_resolve_route(id, RDMA_RESOLVE_TIMEOUT);
 	if (rc) {
 		dprintk("RPC:       %s: rdma_resolve_route() failed %i\n",
 			__func__, rc);
-		goto out;
+		goto put;
 	}
 	wait_for_completion_interruptible_timeout(&ia->ri_done,
 				msecs_to_jiffies(RDMA_RESOLVE_TIMEOUT) + 1);
 	rc = ia->ri_async_rc;
 	if (rc)
-		goto out;
+		goto put;
 
 	return id;
-
+put:
+	module_put(id->device->owner);
 out:
 	rdma_destroy_id(id);
 	return ERR_PTR(rc);
@@ -566,7 +591,7 @@ out3:
 	ib_dealloc_pd(ia->ri_pd);
 	ia->ri_pd = NULL;
 out2:
-	rdma_destroy_id(ia->ri_id);
+	rpcrdma_destroy_id(ia->ri_id);
 	ia->ri_id = NULL;
 out1:
 	return rc;
@@ -584,7 +609,7 @@ rpcrdma_ia_close(struct rpcrdma_ia *ia)
 	if (ia->ri_id != NULL && !IS_ERR(ia->ri_id)) {
 		if (ia->ri_id->qp)
 			rdma_destroy_qp(ia->ri_id);
-		rdma_destroy_id(ia->ri_id);
+		rpcrdma_destroy_id(ia->ri_id);
 		ia->ri_id = NULL;
 	}
 
@@ -794,7 +819,7 @@ retry:
 		if (ia->ri_device != id->device) {
 			printk("RPC:       %s: can't reconnect on "
 				"different device!\n", __func__);
-			rdma_destroy_id(id);
+			rpcrdma_destroy_id(id);
 			rc = -ENETUNREACH;
 			goto out;
 		}
@@ -803,7 +828,7 @@ retry:
 		if (rc) {
 			dprintk("RPC:       %s: rdma_create_qp failed %i\n",
 				__func__, rc);
-			rdma_destroy_id(id);
+			rpcrdma_destroy_id(id);
 			rc = -ENETUNREACH;
 			goto out;
 		}
@@ -814,7 +839,7 @@ retry:
 		write_unlock(&ia->ri_qplock);
 
 		rdma_destroy_qp(old);
-		rdma_destroy_id(old);
+		rpcrdma_destroy_id(old);
 	} else {
 		dprintk("RPC:       %s: connecting...\n", __func__);
 		rc = rdma_create_qp(ia->ri_id, ia->ri_pd, &ep->rep_attr);


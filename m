From: Tom Talpey <talpey@netapp.com>
Subject: [UPDATED PATCH 12/14] RPC/RDMA: harden connection logic against
	missing/late rdma_cm upcalls.
Date: Thu, 09 Oct 2008 15:01:41 -0400
Message-ID: <20081009190141.13947.47198.stgit@tmt3.nane.netapp.com>
References: <20081009185643.13947.64733.stgit@tmt3.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [216.240.26.4] ([216.240.26.4]:45197 "EHLO tmt3.nane.netapp.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760310AbYJITBm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Oct 2008 15:01:42 -0400
Received: from tmt3.nane.netapp.com (localhost.localdomain [127.0.0.1])
	by tmt3.nane.netapp.com (8.14.2/8.14.2) with ESMTP id m99J1f2u014190
	for <linux-nfs@vger.kernel.org>; Thu, 9 Oct 2008 15:01:42 -0400
In-Reply-To: <20081009185643.13947.64733.stgit-pfX4bTJKMULWwzOYslWYilaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add defensive timeouts to wait_for_completion() calls in RDMA
address resolution, and make them interruptible. Fix the timeout
units to milliseconds (formerly jiffies) and move to private header.

Signed-off-by: Tom Talpey <talpey@netapp.com>
---

 include/linux/sunrpc/xprtrdma.h |    3 ---
 net/sunrpc/xprtrdma/verbs.c     |   11 +++++++----
 net/sunrpc/xprtrdma/xprt_rdma.h |    3 +++
 3 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/include/linux/sunrpc/xprtrdma.h b/include/linux/sunrpc/xprtrdma.h
index 55a5d92..54a379c 100644
--- a/include/linux/sunrpc/xprtrdma.h
+++ b/include/linux/sunrpc/xprtrdma.h
@@ -66,9 +66,6 @@
 
 #define RPCRDMA_INLINE_PAD_THRESH  (512)/* payload threshold to pad (bytes) */
 
-#define RDMA_RESOLVE_TIMEOUT	(5*HZ)	/* TBD 5 seconds */
-#define RDMA_CONNECT_RETRY_MAX	(2)	/* retries if no listener backlog */
-
 /* memory registration strategies */
 #define RPCRDMA_PERSISTENT_REGISTRATION (1)
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index a63d0c0..f46fb93 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -284,6 +284,7 @@ rpcrdma_conn_upcall(struct rdma_cm_id *id, struct rdma_cm_event *event)
 	switch (event->event) {
 	case RDMA_CM_EVENT_ADDR_RESOLVED:
 	case RDMA_CM_EVENT_ROUTE_RESOLVED:
+		ia->ri_async_rc = 0;
 		complete(&ia->ri_done);
 		break;
 	case RDMA_CM_EVENT_ADDR_ERROR:
@@ -363,26 +364,28 @@ rpcrdma_create_id(struct rpcrdma_xprt *xprt,
 		return id;
 	}
 
-	ia->ri_async_rc = 0;
+	ia->ri_async_rc = -ETIMEDOUT;
 	rc = rdma_resolve_addr(id, NULL, addr, RDMA_RESOLVE_TIMEOUT);
 	if (rc) {
 		dprintk("RPC:       %s: rdma_resolve_addr() failed %i\n",
 			__func__, rc);
 		goto out;
 	}
-	wait_for_completion(&ia->ri_done);
+	wait_for_completion_interruptible_timeout(&ia->ri_done,
+				msecs_to_jiffies(RDMA_RESOLVE_TIMEOUT) + 1);
 	rc = ia->ri_async_rc;
 	if (rc)
 		goto out;
 
-	ia->ri_async_rc = 0;
+	ia->ri_async_rc = -ETIMEDOUT;
 	rc = rdma_resolve_route(id, RDMA_RESOLVE_TIMEOUT);
 	if (rc) {
 		dprintk("RPC:       %s: rdma_resolve_route() failed %i\n",
 			__func__, rc);
 		goto out;
 	}
-	wait_for_completion(&ia->ri_done);
+	wait_for_completion_interruptible_timeout(&ia->ri_done,
+				msecs_to_jiffies(RDMA_RESOLVE_TIMEOUT) + 1);
 	rc = ia->ri_async_rc;
 	if (rc)
 		goto out;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index fde6499..c7a7eba 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -51,6 +51,9 @@
 #include <linux/sunrpc/rpc_rdma.h> 	/* RPC/RDMA protocol */
 #include <linux/sunrpc/xprtrdma.h> 	/* xprt parameters */
 
+#define RDMA_RESOLVE_TIMEOUT	(5000)	/* 5 seconds */
+#define RDMA_CONNECT_RETRY_MAX	(2)	/* retries if no listener backlog */
+
 /*
  * Interface Adapter -- one per transport instance
  */


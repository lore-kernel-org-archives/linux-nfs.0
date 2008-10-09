From: Tom Talpey <talpey@netapp.com>
Subject: [UPDATED PATCH 11/14] RPC/RDMA: fix connect/reconnect resource leak.
Date: Thu, 09 Oct 2008 15:01:31 -0400
Message-ID: <20081009190131.13947.96597.stgit@tmt3.nane.netapp.com>
References: <20081009185643.13947.64733.stgit@tmt3.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [216.240.26.4] ([216.240.26.4]:60663 "EHLO tmt3.nane.netapp.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760338AbYJITBc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Oct 2008 15:01:32 -0400
Received: from tmt3.nane.netapp.com (localhost.localdomain [127.0.0.1])
	by tmt3.nane.netapp.com (8.14.2/8.14.2) with ESMTP id m99J1VOA014176
	for <linux-nfs@vger.kernel.org>; Thu, 9 Oct 2008 15:01:31 -0400
In-Reply-To: <20081009185643.13947.64733.stgit-pfX4bTJKMULWwzOYslWYilaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The RPC/RDMA code can leak RDMA connection manager endpoints in
certain error cases on connect. Don't signal unwanted events,
and be certain to destroy any allocated qp.

Signed-off-by: Tom Talpey <talpey@netapp.com>
---

 net/sunrpc/xprtrdma/verbs.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index d94f379..a63d0c0 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -338,10 +338,8 @@ connected:
 		wake_up_all(&ep->rep_connect_wait);
 		break;
 	default:
-		ia->ri_async_rc = -EINVAL;
-		dprintk("RPC:       %s: unexpected CM event %X\n",
+		dprintk("RPC:       %s: unexpected CM event %d\n",
 			__func__, event->event);
-		complete(&ia->ri_done);
 		break;
 	}
 
@@ -355,6 +353,8 @@ rpcrdma_create_id(struct rpcrdma_xprt *xprt,
 	struct rdma_cm_id *id;
 	int rc;
 
+	init_completion(&ia->ri_done);
+
 	id = rdma_create_id(rpcrdma_conn_upcall, xprt, RDMA_PS_TCP);
 	if (IS_ERR(id)) {
 		rc = PTR_ERR(id);
@@ -427,8 +427,6 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 	struct ib_device_attr devattr;
 	struct rpcrdma_ia *ia = &xprt->rx_ia;
 
-	init_completion(&ia->ri_done);
-
 	ia->ri_id = rpcrdma_create_id(xprt, ia, addr);
 	if (IS_ERR(ia->ri_id)) {
 		rc = PTR_ERR(ia->ri_id);
@@ -815,6 +813,7 @@ retry:
 			goto out;
 		}
 		/* END TEMP */
+		rdma_destroy_qp(ia->ri_id);
 		rdma_destroy_id(ia->ri_id);
 		ia->ri_id = id;
 	}


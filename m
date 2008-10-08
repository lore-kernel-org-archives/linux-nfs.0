From: Tom Talpey <talpey@netapp.com>
Subject: [PATCH 08/15] RPC/RDMA: avoid an oops due to disconnect racing with
	async upcalls.
Date: Wed, 08 Oct 2008 11:48:15 -0400
Message-ID: <20081008154815.1336.75753.stgit@tmt3.nane.netapp.com>
References: <20081008154506.1336.59892.stgit@tmt3.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [216.240.26.4] ([216.240.26.4]:44118 "EHLO tmt3.nane.netapp.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754539AbYJHQWR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 12:22:17 -0400
Received: from tmt3.nane.netapp.com (localhost.localdomain [127.0.0.1])
	by tmt3.nane.netapp.com (8.14.2/8.14.2) with ESMTP id m98FmFmC001514
	for <linux-nfs@vger.kernel.org>; Wed, 8 Oct 2008 11:48:15 -0400
In-Reply-To: <20081008154506.1336.59892.stgit-pfX4bTJKMULWwzOYslWYilaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RDMA disconnects yield an upcall from the RDMA connection manager,
which can race with rpc transport close, e.g. on ^C of a mount.
Ensure any rdma cm_id and qp are fully destroyed before continuing.

Signed-off-by: Tom Talpey <talpey@netapp.com>
---

 net/sunrpc/xprtrdma/verbs.c |   20 +++++++++-----------
 1 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index e3fe905..d94f379 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -565,6 +565,7 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 	return 0;
 out2:
 	rdma_destroy_id(ia->ri_id);
+	ia->ri_id = NULL;
 out1:
 	return rc;
 }
@@ -585,15 +586,17 @@ rpcrdma_ia_close(struct rpcrdma_ia *ia)
 		dprintk("RPC:       %s: ib_dereg_mr returned %i\n",
 			__func__, rc);
 	}
-	if (ia->ri_id != NULL && !IS_ERR(ia->ri_id) && ia->ri_id->qp)
-		rdma_destroy_qp(ia->ri_id);
+	if (ia->ri_id != NULL && !IS_ERR(ia->ri_id)) {
+		if (ia->ri_id->qp)
+			rdma_destroy_qp(ia->ri_id);
+		rdma_destroy_id(ia->ri_id);
+		ia->ri_id = NULL;
+	}
 	if (ia->ri_pd != NULL && !IS_ERR(ia->ri_pd)) {
 		rc = ib_dealloc_pd(ia->ri_pd);
 		dprintk("RPC:       %s: ib_dealloc_pd returned %i\n",
 			__func__, rc);
 	}
-	if (ia->ri_id != NULL && !IS_ERR(ia->ri_id))
-		rdma_destroy_id(ia->ri_id);
 }
 
 /*
@@ -751,21 +754,16 @@ rpcrdma_ep_destroy(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 		if (rc)
 			dprintk("RPC:       %s: rpcrdma_ep_disconnect"
 				" returned %i\n", __func__, rc);
+		rdma_destroy_qp(ia->ri_id);
+		ia->ri_id->qp = NULL;
 	}
 
-	ep->rep_func = NULL;
-
 	/* padding - could be done in rpcrdma_buffer_destroy... */
 	if (ep->rep_pad_mr) {
 		rpcrdma_deregister_internal(ia, ep->rep_pad_mr, &ep->rep_pad);
 		ep->rep_pad_mr = NULL;
 	}
 
-	if (ia->ri_id->qp) {
-		rdma_destroy_qp(ia->ri_id);
-		ia->ri_id->qp = NULL;
-	}
-
 	rpcrdma_clean_cq(ep->rep_cq);
 	rc = ib_destroy_cq(ep->rep_cq);
 	if (rc)


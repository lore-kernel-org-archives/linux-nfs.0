From: Tom Talpey <talpey@netapp.com>
Subject: [PATCH 05/15] RPC/RDMA: fix connection IRD/ORD setting
Date: Wed, 08 Oct 2008 11:47:44 -0400
Message-ID: <20081008154744.1336.20909.stgit@tmt3.nane.netapp.com>
References: <20081008154506.1336.59892.stgit@tmt3.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [216.240.26.4] ([216.240.26.4]:44118 "EHLO tmt3.nane.netapp.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754621AbYJHQWV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 12:22:21 -0400
Received: from tmt3.nane.netapp.com (localhost.localdomain [127.0.0.1])
	by tmt3.nane.netapp.com (8.14.2/8.14.2) with ESMTP id m98Fliui001471
	for <linux-nfs@vger.kernel.org>; Wed, 8 Oct 2008 11:47:44 -0400
In-Reply-To: <20081008154506.1336.59892.stgit-pfX4bTJKMULWwzOYslWYilaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Tucker <talpey@netapp.com>

This logic sets the connection parameter that configures the local device
and informs the remote peer how many concurrent incoming RDMA_READ
requests are supported. The original logic didn't really do what was
intended for two reasons:

- The max number supported by the device is typically smaller than
any one factor in the calculation used, and

- The field in the connection parameter structure where the value is
stored is a u8 and always overflows for the default settings.

So what really happens is the value requested for responder resources
is the left over 8 bits from the "desired value". If the desired value
happened to be a multiple of 256, the result was zero and it wouldn't
connect at all.

Given the above and the fact that max_requests is almost always larger
than the max responder resources supported by the adapter, this patch
simplifies this logic and simply requests the max supported by the device,
subject to a reasonable limit.

This bug was found by Jim Schutt at Sandia.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Signed-off-by: Tom Talpey <talpey@netapp.com>
---

 net/sunrpc/xprtrdma/verbs.c |   51 ++++++++++++-------------------------------
 1 files changed, 14 insertions(+), 37 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 39a1652..e3fe905 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -705,30 +705,13 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 	ep->rep_remote_cma.private_data_len = 0;
 
 	/* Client offers RDMA Read but does not initiate */
-	switch (ia->ri_memreg_strategy) {
-	case RPCRDMA_BOUNCEBUFFERS:
+	ep->rep_remote_cma.initiator_depth = 0;
+	if (ia->ri_memreg_strategy == RPCRDMA_BOUNCEBUFFERS)
 		ep->rep_remote_cma.responder_resources = 0;
-		break;
-	case RPCRDMA_MTHCAFMR:
-	case RPCRDMA_REGISTER:
-	case RPCRDMA_FRMR:
-		ep->rep_remote_cma.responder_resources = cdata->max_requests *
-				(RPCRDMA_MAX_DATA_SEGS / 8);
-		break;
-	case RPCRDMA_MEMWINDOWS:
-	case RPCRDMA_MEMWINDOWS_ASYNC:
-#if RPCRDMA_PERSISTENT_REGISTRATION
-	case RPCRDMA_ALLPHYSICAL:
-#endif
-		ep->rep_remote_cma.responder_resources = cdata->max_requests *
-				(RPCRDMA_MAX_DATA_SEGS / 2);
-		break;
-	default:
-		break;
-	}
-	if (ep->rep_remote_cma.responder_resources > devattr.max_qp_rd_atom)
+	else if (devattr.max_qp_rd_atom > 32)	/* arbitrary but <= 255 */
+		ep->rep_remote_cma.responder_resources = 32;
+	else
 		ep->rep_remote_cma.responder_resources = devattr.max_qp_rd_atom;
-	ep->rep_remote_cma.initiator_depth = 0;
 
 	ep->rep_remote_cma.retry_count = 7;
 	ep->rep_remote_cma.flow_control = 0;
@@ -858,14 +841,6 @@ if (strnicmp(ia->ri_id->device->dma_device->bus->name, "pci", 3) == 0) {
 	}
 }
 
-	/* Theoretically a client initiator_depth > 0 is not needed,
-	 * but many peers fail to complete the connection unless they
-	 * == responder_resources! */
-	if (ep->rep_remote_cma.initiator_depth !=
-				ep->rep_remote_cma.responder_resources)
-		ep->rep_remote_cma.initiator_depth =
-			ep->rep_remote_cma.responder_resources;
-
 	ep->rep_connected = 0;
 
 	rc = rdma_connect(ia->ri_id, &ep->rep_remote_cma);
@@ -894,14 +869,16 @@ if (strnicmp(ia->ri_id->device->dma_device->bus->name, "pci", 3) == 0) {
 	if (ep->rep_connected <= 0) {
 		/* Sometimes, the only way to reliably connect to remote
 		 * CMs is to use same nonzero values for ORD and IRD. */
-		ep->rep_remote_cma.initiator_depth =
-					ep->rep_remote_cma.responder_resources;
-		if (ep->rep_remote_cma.initiator_depth == 0)
-			++ep->rep_remote_cma.initiator_depth;
-		if (ep->rep_remote_cma.responder_resources == 0)
-			++ep->rep_remote_cma.responder_resources;
-		if (retry_count++ == 0)
+		if (retry_count++ <= RDMA_CONNECT_RETRY_MAX + 1 &&
+		    (ep->rep_remote_cma.responder_resources == 0 ||
+		     ep->rep_remote_cma.initiator_depth !=
+				ep->rep_remote_cma.responder_resources)) {
+			if (ep->rep_remote_cma.responder_resources == 0)
+				ep->rep_remote_cma.responder_resources = 1;
+			ep->rep_remote_cma.initiator_depth =
+				ep->rep_remote_cma.responder_resources;
 			goto retry;
+		}
 		rc = ep->rep_connected;
 	} else {
 		dprintk("RPC:       %s: connected\n", __func__);


From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH, RFC] xprtrdma: Simplify client responder resource handling
Date: Thu, 21 Aug 2008 20:35:06 -0500
Message-ID: <48AE17CA.2070806@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org, Tom Talpey <Thomas.Talpey@netapp.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:57461 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751146AbYHVBfH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Aug 2008 21:35:07 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This logic sets the connection parameter that configures the local device
and informs the remote peer how many concurrent incoming RDMA_READ
requests are supported. This logic didn't really do what was intended for
two reasons:

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
simplifies this logic and simply requests the max supported by the device.

This bug was found by Jim Schutt at Sandia.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

---
  net/sunrpc/xprtrdma/verbs.c |   44 ++++++------------------------------------
  1 files changed, 7 insertions(+), 37 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index edf520c..a6d86f6 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -670,30 +670,11 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
  	ep->rep_remote_cma.private_data_len = 0;

  	/* Client offers RDMA Read but does not initiate */
-	switch (ia->ri_memreg_strategy) {
-	case RPCRDMA_BOUNCEBUFFERS:
-		ep->rep_remote_cma.responder_resources = 0;
-		break;
-	case RPCRDMA_MTHCAFMR:
-	case RPCRDMA_REGISTER:
-	case RPCRDMA_FASTREG:
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
-		ep->rep_remote_cma.responder_resources = devattr.max_qp_rd_atom;
  	ep->rep_remote_cma.initiator_depth = 0;
+	if (ia->ri_memreg_strategy != RPCRDMA_BOUNCEBUFFERS)
+		ep->rep_remote_cma.responder_resources = devattr.max_qp_rd_atom;
+	else
+		ep->rep_remote_cma.responder_resources = 0;

  	ep->rep_remote_cma.retry_count = 7;
  	ep->rep_remote_cma.flow_control = 0;
@@ -822,15 +803,6 @@ if (strnicmp(ia->ri_id->device->dma_device->bus->name, "pci", 3) == 0) {
  		rc = ib_modify_qp(ia->ri_id->qp, &attr, IB_QP_PATH_MTU);
  	}
  }
-
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
@@ -859,12 +831,10 @@ if (strnicmp(ia->ri_id->device->dma_device->bus->name, "pci", 3) == 0) {
  	if (ep->rep_connected <= 0) {
  		/* Sometimes, the only way to reliably connect to remote
  		 * CMs is to use same nonzero values for ORD and IRD. */
+		if (!ep->rep_remote_cma.responder_resources)
+			ep->rep_remote_cma.responder_resources = 1;
  		ep->rep_remote_cma.initiator_depth =
-					ep->rep_remote_cma.responder_resources;
-		if (ep->rep_remote_cma.initiator_depth == 0)
-			++ep->rep_remote_cma.initiator_depth;
-		if (ep->rep_remote_cma.responder_resources == 0)
-			++ep->rep_remote_cma.responder_resources;
+			ep->rep_remote_cma.responder_resources;
  		if (retry_count++ == 0)
  			goto retry;
  		rc = ep->rep_connected;

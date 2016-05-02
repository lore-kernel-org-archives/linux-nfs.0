Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f194.google.com ([209.85.213.194]:35076 "EHLO
	mail-ig0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754998AbcEBSnF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2016 14:43:05 -0400
Subject: [PATCH v3 20/20] xprtrdma: Faster server reboot recovery
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 02 May 2016 14:43:03 -0400
Message-ID: <20160502184303.10798.4709.stgit@manet.1015granger.net>
In-Reply-To: <20160502183144.10798.99847.stgit@manet.1015granger.net>
References: <20160502183144.10798.99847.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In a cluster failover scenario, it is desirable for the client to
attempt to reconnect quickly, as an alternate NFS server is already
waiting to take over for the down server. The client can't see that
a server IP address has moved to a new server until the existing
connection is gone.

For fabrics and devices where it is meaningful, set a definite upper
bound on the amount of time before it is determined that a
connection is no longer valid. This allows the RPC client to detect
connection loss in a timely matter, then perform a fresh resolution
of the server GUID in case it has changed (cluster failover).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Steve Wise <swise@opengridcomputing.com>
---
 net/sunrpc/xprtrdma/verbs.c |   12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index b7a5bc1..be66f65 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -554,6 +554,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 	ep->rep_attr.recv_cq = recvcq;
 
 	/* Initialize cma parameters */
+	memset(&ep->rep_remote_cma, 0, sizeof(ep->rep_remote_cma));
 
 	/* RPC/RDMA does not use private data */
 	ep->rep_remote_cma.private_data = NULL;
@@ -567,7 +568,16 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 		ep->rep_remote_cma.responder_resources =
 						ia->ri_device->attrs.max_qp_rd_atom;
 
-	ep->rep_remote_cma.retry_count = 7;
+	/* Limit transport retries so client can detect server
+	 * GID changes quickly. RPC layer handles re-establishing
+	 * transport connection and retransmission.
+	 */
+	ep->rep_remote_cma.retry_count = 6;
+
+	/* RPC-over-RDMA handles its own flow control. In addition,
+	 * make all RNR NAKs visible so we know that RPC-over-RDMA
+	 * flow control is working correctly (no NAKs should be seen).
+	 */
 	ep->rep_remote_cma.flow_control = 0;
 	ep->rep_remote_cma.rnr_retry_count = 0;
 


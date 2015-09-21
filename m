Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:40639 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753880AbbIURYY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Sep 2015 13:24:24 -0400
From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH 1/3] xprtrdma: disconnect and flush cqs before freeing buffers
To: trond.myklebust@primarydata.com, bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Mon, 21 Sep 2015 12:24:23 -0500
Message-ID: <20150921172423.9761.92399.stgit@build2.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Otherwise a FRMR completion can cause a touch-after-free crash.

In xprt_rdma_destroy(), call rpcrdma_buffer_destroy() only after calling
rpcrdma_ep_destroy().

In rpcrdma_ep_destroy(), disconnect the cm_id first which should flush the
qp, then drain the cqs, then destroy the qp, and finally destroy the cqs.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
Tested-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/transport.c |    2 +-
 net/sunrpc/xprtrdma/verbs.c     |    9 ++++++---
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 64443eb..41e452b 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -270,8 +270,8 @@ xprt_rdma_destroy(struct rpc_xprt *xprt)
 
 	xprt_clear_connected(xprt);
 
-	rpcrdma_buffer_destroy(&r_xprt->rx_buf);
 	rpcrdma_ep_destroy(&r_xprt->rx_ep, &r_xprt->rx_ia);
+	rpcrdma_buffer_destroy(&r_xprt->rx_buf);
 	rpcrdma_ia_close(&r_xprt->rx_ia);
 
 	xprt_rdma_free_addresses(xprt);
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 6829967..01a314a 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -755,19 +755,22 @@ rpcrdma_ep_destroy(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 
 	cancel_delayed_work_sync(&ep->rep_connect_worker);
 
-	if (ia->ri_id->qp) {
+	if (ia->ri_id->qp)
 		rpcrdma_ep_disconnect(ep, ia);
+
+	rpcrdma_clean_cq(ep->rep_attr.recv_cq);
+	rpcrdma_clean_cq(ep->rep_attr.send_cq);
+
+	if (ia->ri_id->qp) {
 		rdma_destroy_qp(ia->ri_id);
 		ia->ri_id->qp = NULL;
 	}
 
-	rpcrdma_clean_cq(ep->rep_attr.recv_cq);
 	rc = ib_destroy_cq(ep->rep_attr.recv_cq);
 	if (rc)
 		dprintk("RPC:       %s: ib_destroy_cq returned %i\n",
 			__func__, rc);
 
-	rpcrdma_clean_cq(ep->rep_attr.send_cq);
 	rc = ib_destroy_cq(ep->rep_attr.send_cq);
 	if (rc)
 		dprintk("RPC:       %s: ib_destroy_cq returned %i\n",


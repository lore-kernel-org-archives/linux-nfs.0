Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:22131 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754988AbaDGXBm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Apr 2014 19:01:42 -0400
From: <devesh.sharma@emulex.com>
To: <linux-nfs@vger.kernel.org>
CC: <linux-rdma@vger.kernel.org>, Devesh Sharma <devesh.sharma@emulex.com>
Subject: [PATCH] NFS-RDMA: fix qp pointer validation checks
Date: Tue, 8 Apr 2014 04:00:05 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-ID: <d4afd436-8e14-4729-9bc1-71ab9079a246@CMEXHTCAS1.ad.emulex.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Devesh Sharma <devesh.sharma@emulex.com>

If the rdma_create_qp fails to create qp due to device firmware being in invalid state
xprtrdma still tries to destroy the non-existant qp and ends up in a NULL pointer reference
crash.
Adding proper checks for vaidating QP pointer avoids this to happen.

Signed-off-by: Devesh Sharma <devesh.sharma@emulex.com>
---
 net/sunrpc/xprtrdma/verbs.c |   34 ++++++++++++++++++++++++++++------
 1 files changed, 28 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 9372656..c01d91e 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -620,7 +620,7 @@ rpcrdma_ia_close(struct rpcrdma_ia *ia)
 			__func__, rc);
 	}
 	if (ia->ri_id != NULL && !IS_ERR(ia->ri_id)) {
-		if (ia->ri_id->qp)
+		if (!IS_ERR(ia->ri_id->qp))
 			rdma_destroy_qp(ia->ri_id);
 		rdma_destroy_id(ia->ri_id);
 		ia->ri_id = NULL;
@@ -794,7 +794,7 @@ rpcrdma_ep_destroy(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 	dprintk("RPC:       %s: entering, connected is %d\n",
 		__func__, ep->rep_connected);
 
-	if (ia->ri_id->qp) {
+	if (!IS_ERR(ia->ri_id->qp)) {
 		rc = rpcrdma_ep_disconnect(ep, ia);
 		if (rc)
 			dprintk("RPC:       %s: rpcrdma_ep_disconnect"
@@ -831,10 +831,12 @@ rpcrdma_ep_connect(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 	if (ep->rep_connected != 0) {
 		struct rpcrdma_xprt *xprt;
 retry:
-		rc = rpcrdma_ep_disconnect(ep, ia);
-		if (rc && rc != -ENOTCONN)
-			dprintk("RPC:       %s: rpcrdma_ep_disconnect"
+		if (!IS_ERR(ia->ri_id->qp)) {
+			rc = rpcrdma_ep_disconnect(ep, ia);
+			if (rc && rc != -ENOTCONN)
+				dprintk("RPC:       %s: rpcrdma_ep_disconnect"
 				" status %i\n", __func__, rc);
+		}
 		rpcrdma_clean_cq(ep->rep_cq);
 
 		xprt = container_of(ia, struct rpcrdma_xprt, rx_ia);
@@ -859,7 +861,9 @@ retry:
 			goto out;
 		}
 		/* END TEMP */
-		rdma_destroy_qp(ia->ri_id);
+		if (!IS_ERR(ia->ri_id->qp)) {
+			rdma_destroy_qp(ia->ri_id);
+		}
 		rdma_destroy_id(ia->ri_id);
 		ia->ri_id = id;
 	}
@@ -1557,6 +1561,13 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	frmr_wr.wr.fast_reg.rkey = seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey;
 	DECR_CQCOUNT(&r_xprt->rx_ep);
 
+	if (IS_ERR(ia->ri_is->qp)) {
+		rc = PTR_ERR(ia->ri_is->qp);
+		while (i--)
+			rpcrdma_unmap_one(ia, --seg);
+		goto out;
+	}
+
 	rc = ib_post_send(ia->ri_id->qp, post_wr, &bad_wr);
 
 	if (rc) {
@@ -1571,6 +1582,7 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 		seg1->mr_len = len;
 	}
 	*nsegs = i;
+out:
 	return rc;
 }
 
@@ -1592,6 +1604,10 @@ rpcrdma_deregister_frmr_external(struct rpcrdma_mr_seg *seg,
 	invalidate_wr.ex.invalidate_rkey = seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey;
 	DECR_CQCOUNT(&r_xprt->rx_ep);
 
+	if (IS_ERR(ia->ri_id->qp)) {
+		return PTR_ERR(ia->ri_id->qp);
+	}
+
 	rc = ib_post_send(ia->ri_id->qp, &invalidate_wr, &bad_wr);
 	if (rc)
 		dprintk("RPC:       %s: failed ib_post_send for invalidate,"
@@ -1923,6 +1939,9 @@ rpcrdma_ep_post(struct rpcrdma_ia *ia,
 		send_wr.send_flags = IB_SEND_SIGNALED;
 	}
 
+	if (IS_ERR(ia->ri_id->qp))
+		return PTR_ERR(ia->ri_id->qp);
+
 	rc = ib_post_send(ia->ri_id->qp, &send_wr, &send_wr_fail);
 	if (rc)
 		dprintk("RPC:       %s: ib_post_send returned %i\n", __func__,
@@ -1951,6 +1970,9 @@ rpcrdma_ep_post_recv(struct rpcrdma_ia *ia,
 		rep->rr_iov.addr, rep->rr_iov.length, DMA_BIDIRECTIONAL);
 
 	DECR_CQCOUNT(ep);
+
+	if (IS_ERR(ia->ri_id->qp))
+		return PTR_ERR(ia->ri_id->qp);
 	rc = ib_post_recv(ia->ri_id->qp, &recv_wr, &recv_wr_fail);
 
 	if (rc)
-- 
1.7.1


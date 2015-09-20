Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:44458 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754363AbbITJxP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 20 Sep 2015 05:53:15 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Cc: linux-rdma@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>,
        Eli Cohen <eli@mellanox.com>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: [PATCH rdma-rc 1/4] xprtrdma: Remove ib_get_dma_mr calls
Date: Sun, 20 Sep 2015 12:52:44 +0300
Message-Id: <1442742767-8755-2-git-send-email-sagig@mellanox.com>
In-Reply-To: <1442742767-8755-1-git-send-email-sagig@mellanox.com>
References: <1442742767-8755-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

since commit 96249d70dd70 ("IB/core:
Guarantee that a local_dma_lkey is available") The PD now
has a local_dma_lkey member which completely replaces
ib_get_dma_mr, use it instead.

In FRWR memreg mode, we assumed that the device local_dma_lkey
is available.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
---
 net/sunrpc/xprtrdma/fmr_ops.c      | 19 -------------------
 net/sunrpc/xprtrdma/frwr_ops.c     |  5 -----
 net/sunrpc/xprtrdma/physical_ops.c |  8 --------
 net/sunrpc/xprtrdma/verbs.c        |  1 +
 4 files changed, 1 insertion(+), 32 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index cb25c89da623..f1e8dafbd507 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -39,25 +39,6 @@ static int
 fmr_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
 	    struct rpcrdma_create_data_internal *cdata)
 {
-	struct ib_device_attr *devattr = &ia->ri_devattr;
-	struct ib_mr *mr;
-
-	/* Obtain an lkey to use for the regbufs, which are
-	 * protected from remote access.
-	 */
-	if (devattr->device_cap_flags & IB_DEVICE_LOCAL_DMA_LKEY) {
-		ia->ri_dma_lkey = ia->ri_device->local_dma_lkey;
-	} else {
-		mr = ib_get_dma_mr(ia->ri_pd, IB_ACCESS_LOCAL_WRITE);
-		if (IS_ERR(mr)) {
-			pr_err("%s: ib_get_dma_mr for failed with %lX\n",
-			       __func__, PTR_ERR(mr));
-			return -ENOMEM;
-		}
-		ia->ri_dma_lkey = ia->ri_dma_mr->lkey;
-		ia->ri_dma_mr = mr;
-	}
-
 	return 0;
 }
 
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index d6653f5d0830..5318951b3b53 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -189,11 +189,6 @@ frwr_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
 	struct ib_device_attr *devattr = &ia->ri_devattr;
 	int depth, delta;
 
-	/* Obtain an lkey to use for the regbufs, which are
-	 * protected from remote access.
-	 */
-	ia->ri_dma_lkey = ia->ri_device->local_dma_lkey;
-
 	ia->ri_max_frmr_depth =
 			min_t(unsigned int, RPCRDMA_MAX_DATA_SEGS,
 			      devattr->max_fast_reg_page_list_len);
diff --git a/net/sunrpc/xprtrdma/physical_ops.c b/net/sunrpc/xprtrdma/physical_ops.c
index 72cf8b15bbb4..5feb63afdb03 100644
--- a/net/sunrpc/xprtrdma/physical_ops.c
+++ b/net/sunrpc/xprtrdma/physical_ops.c
@@ -23,7 +23,6 @@ static int
 physical_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
 		 struct rpcrdma_create_data_internal *cdata)
 {
-	struct ib_device_attr *devattr = &ia->ri_devattr;
 	struct ib_mr *mr;
 
 	/* Obtain an rkey to use for RPC data payloads.
@@ -39,13 +38,6 @@ physical_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
 	}
 	ia->ri_dma_mr = mr;
 
-	/* Obtain an lkey to use for regbufs.
-	 */
-	if (devattr->device_cap_flags & IB_DEVICE_LOCAL_DMA_LKEY)
-		ia->ri_dma_lkey = ia->ri_device->local_dma_lkey;
-	else
-		ia->ri_dma_lkey = ia->ri_dma_mr->lkey;
-
 	return 0;
 }
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 682996779970..4f405bcad39a 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -640,6 +640,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 	ep->rep_attr.qp_context = ep;
 	ep->rep_attr.srq = NULL;
 	ep->rep_attr.cap.max_send_wr = cdata->max_requests;
+	ia->ri_dma_lkey = ia->ri_pd->local_dma_lkey;
 	rc = ia->ri_ops->ro_open(ia, ep, cdata);
 	if (rc)
 		return rc;
-- 
1.8.4.3


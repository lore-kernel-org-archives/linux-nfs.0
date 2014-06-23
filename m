Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:60662 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbaFWWjT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 18:39:19 -0400
Subject: [PATCH v1 02/13] xprtrdma: Protect ->qp during FRMR deregistration
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 23 Jun 2014 18:39:17 -0400
Message-ID: <20140623223917.1634.39429.stgit@manet.1015granger.net>
In-Reply-To: <20140623223201.1634.83888.stgit@manet.1015granger.net>
References: <20140623223201.1634.83888.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure the QP remains valid while posting LOCAL_INV during a
transport reconnect. Otherwise, ia->ri_id->qp is NULL, which
triggers a panic.

BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=259
Fixes: ec62f40d3505a643497d105c297093bb90afd44e
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c     |   14 +++++++++++---
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 78bd7c6..f70b8ad 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -613,6 +613,7 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 	/* Else will do memory reg/dereg for each chunk */
 	ia->ri_memreg_strategy = memreg;
 
+	rwlock_init(&ia->ri_qplock);
 	return 0;
 out2:
 	rdma_destroy_id(ia->ri_id);
@@ -859,7 +860,7 @@ rpcrdma_ep_destroy(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 int
 rpcrdma_ep_connect(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 {
-	struct rdma_cm_id *id;
+	struct rdma_cm_id *id, *old;
 	int rc = 0;
 	int retry_count = 0;
 
@@ -905,9 +906,14 @@ retry:
 			rc = -ENETUNREACH;
 			goto out;
 		}
-		rdma_destroy_qp(ia->ri_id);
-		rdma_destroy_id(ia->ri_id);
+
+		write_lock(&ia->ri_qplock);
+		old = ia->ri_id;
 		ia->ri_id = id;
+		write_unlock(&ia->ri_qplock);
+
+		rdma_destroy_qp(old);
+		rdma_destroy_id(old);
 	} else {
 		dprintk("RPC:       %s: connecting...\n", __func__);
 		rc = rdma_create_qp(ia->ri_id, ia->ri_pd, &ep->rep_attr);
@@ -1597,7 +1603,9 @@ rpcrdma_deregister_frmr_external(struct rpcrdma_mr_seg *seg,
 	invalidate_wr.ex.invalidate_rkey = seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey;
 	DECR_CQCOUNT(&r_xprt->rx_ep);
 
+	read_lock(&ia->ri_qplock);
 	rc = ib_post_send(ia->ri_id->qp, &invalidate_wr, &bad_wr);
+	read_unlock(&ia->ri_qplock);
 	if (rc)
 		dprintk("RPC:       %s: failed ib_post_send for invalidate,"
 			" status %i\n", __func__, rc);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 89e7cd4..97ca516 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -59,6 +59,7 @@
  * Interface Adapter -- one per transport instance
  */
 struct rpcrdma_ia {
+	rwlock_t		ri_qplock;
 	struct rdma_cm_id 	*ri_id;
 	struct ib_pd		*ri_pd;
 	struct ib_mr		*ri_bind_mem;


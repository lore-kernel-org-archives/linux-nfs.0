Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f173.google.com ([209.85.213.173]:56090 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755089AbaGVOvS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jul 2014 10:51:18 -0400
Subject: [PATCH v4 02/21] xprtrdma: Protect ia->ri_id when
 unmapping/invalidating MRs
From: Chuck Lever <chuck.lever@oracle.com>
To: Anna.Schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 22 Jul 2014 10:51:16 -0400
Message-ID: <20140722145116.6010.56308.stgit@manet.1015granger.net>
In-Reply-To: <20140722144459.6010.99389.stgit@manet.1015granger.net>
References: <20140722144459.6010.99389.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure ia->ri_id remains valid while invoking dma_unmap_page() or
posting LOCAL_INV during a transport reconnect. Otherwise,
ia->ri_id->device or ia->ri_id->qp is NULL, which triggers a panic.

BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=259
Fixes: ec62f40 'xprtrdma: Ensure ia->ri_id->qp is not NULL when reconnecting'
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Steve Wise <swise@opengridcomputing.com>
Tested-by: Shirley Ma <shirley.ma@oracle.com>
Tested-by: Devesh Sharma <devesh.sharma@emulex.com>
---
 net/sunrpc/xprtrdma/verbs.c     |   23 +++++++++++++++++------
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
 2 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 78bd7c6..cab742d 100644
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
@@ -1587,9 +1593,6 @@ rpcrdma_deregister_frmr_external(struct rpcrdma_mr_seg *seg,
 	struct ib_send_wr invalidate_wr, *bad_wr;
 	int rc;
 
-	while (seg1->mr_nsegs--)
-		rpcrdma_unmap_one(ia, seg++);
-
 	memset(&invalidate_wr, 0, sizeof invalidate_wr);
 	invalidate_wr.wr_id = (unsigned long)(void *)seg1->mr_chunk.rl_mw;
 	invalidate_wr.opcode = IB_WR_LOCAL_INV;
@@ -1597,7 +1600,11 @@ rpcrdma_deregister_frmr_external(struct rpcrdma_mr_seg *seg,
 	invalidate_wr.ex.invalidate_rkey = seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey;
 	DECR_CQCOUNT(&r_xprt->rx_ep);
 
+	read_lock(&ia->ri_qplock);
+	while (seg1->mr_nsegs--)
+		rpcrdma_unmap_one(ia, seg++);
 	rc = ib_post_send(ia->ri_id->qp, &invalidate_wr, &bad_wr);
+	read_unlock(&ia->ri_qplock);
 	if (rc)
 		dprintk("RPC:       %s: failed ib_post_send for invalidate,"
 			" status %i\n", __func__, rc);
@@ -1658,8 +1665,10 @@ rpcrdma_deregister_fmr_external(struct rpcrdma_mr_seg *seg,
 
 	list_add(&seg1->mr_chunk.rl_mw->r.fmr->list, &l);
 	rc = ib_unmap_fmr(&l);
+	read_lock(&ia->ri_qplock);
 	while (seg1->mr_nsegs--)
 		rpcrdma_unmap_one(ia, seg++);
+	read_unlock(&ia->ri_qplock);
 	if (rc)
 		dprintk("RPC:       %s: failed ib_unmap_fmr,"
 			" status %i\n", __func__, rc);
@@ -1715,7 +1724,9 @@ rpcrdma_deregister_external(struct rpcrdma_mr_seg *seg,
 
 #if RPCRDMA_PERSISTENT_REGISTRATION
 	case RPCRDMA_ALLPHYSICAL:
+		read_lock(&ia->ri_qplock);
 		rpcrdma_unmap_one(ia, seg);
+		read_unlock(&ia->ri_qplock);
 		break;
 #endif
 
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


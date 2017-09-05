Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36342 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752490AbdIERA6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Sep 2017 13:00:58 -0400
Subject: [PATCH RFC 5/5] xprtrdma: Remove atomic send completion counting
From: Chuck Lever <chuck.lever@oracle.com>
To: jgunthorpe@obsidianresearch.com, sagi@grimberg.me
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 05 Sep 2017 13:00:54 -0400
Message-ID: <20170905170054.11106.47871.stgit@manet.1015granger.net>
In-Reply-To: <20170905164347.11106.27140.stgit@manet.1015granger.net>
References: <20170905164347.11106.27140.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Verbs providers require that a posted send has to be signaled every
so often. This is because the providers perform send queue house-
keeping during the send completion.

However, send completion batching now guarantees send operations
are signaled often enough that managing a count of posted sends and
signaling every so often is no longer necessary for xprtrdma.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c  |    8 --------
 net/sunrpc/xprtrdma/verbs.c     |    4 ----
 net/sunrpc/xprtrdma/xprt_rdma.h |   21 ---------------------
 3 files changed, 33 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 5a936a6..f366a05 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -419,7 +419,6 @@
 			 IB_ACCESS_REMOTE_WRITE | IB_ACCESS_LOCAL_WRITE :
 			 IB_ACCESS_REMOTE_READ;
 
-	rpcrdma_set_signaled(&r_xprt->rx_ep, &reg_wr->wr);
 	rc = ib_post_send(ia->ri_id->qp, &reg_wr->wr, &bad_wr);
 	if (rc)
 		goto out_senderr;
@@ -507,12 +506,6 @@
 	f->fr_cqe.done = frwr_wc_localinv_wake;
 	reinit_completion(&f->fr_linv_done);
 
-	/* Initialize CQ count, since there is always a signaled
-	 * WR being posted here.  The new cqcount depends on how
-	 * many SQEs are about to be consumed.
-	 */
-	rpcrdma_init_cqcount(&r_xprt->rx_ep, count);
-
 	/* Transport disconnect drains the receive CQ before it
 	 * replaces the QP. The RPC reply handler won't call us
 	 * unless ri_id->qp is a valid pointer.
@@ -545,7 +538,6 @@
 	/* Find and reset the MRs in the LOCAL_INV WRs that did not
 	 * get posted.
 	 */
-	rpcrdma_init_cqcount(&r_xprt->rx_ep, -count);
 	while (bad_wr) {
 		f = container_of(bad_wr, struct rpcrdma_frmr,
 				 fr_invwr);
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 75899ba..fb84418 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -575,10 +575,6 @@
 	ep->rep_send_batch = min_t(unsigned int, RPCRDMA_MAX_SEND_BATCH,
 				   cdata->max_requests >> 2);
 	ep->rep_send_count = ep->rep_send_batch;
-	ep->rep_cqinit = ep->rep_attr.cap.max_send_wr/2 - 1;
-	if (ep->rep_cqinit <= 2)
-		ep->rep_cqinit = 0;	/* always signal? */
-	rpcrdma_init_cqcount(ep, 0);
 	init_waitqueue_head(&ep->rep_connect_wait);
 	INIT_DELAYED_WORK(&ep->rep_connect_worker, rpcrdma_connect_worker);
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 8f8e2dd..660fa0e 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -95,8 +95,6 @@ enum {
 struct rpcrdma_ep {
 	unsigned int		rep_send_count;
 	unsigned int		rep_send_batch;
-	atomic_t		rep_cqcount;
-	int			rep_cqinit;
 	int			rep_connected;
 	struct ib_qp_init_attr	rep_attr;
 	wait_queue_head_t 	rep_connect_wait;
@@ -106,25 +104,6 @@ struct rpcrdma_ep {
 	struct delayed_work	rep_connect_worker;
 };
 
-static inline void
-rpcrdma_init_cqcount(struct rpcrdma_ep *ep, int count)
-{
-	atomic_set(&ep->rep_cqcount, ep->rep_cqinit - count);
-}
-
-/* To update send queue accounting, provider must take a
- * send completion every now and then.
- */
-static inline void
-rpcrdma_set_signaled(struct rpcrdma_ep *ep, struct ib_send_wr *send_wr)
-{
-	send_wr->send_flags = 0;
-	if (unlikely(atomic_sub_return(1, &ep->rep_cqcount) <= 0)) {
-		rpcrdma_init_cqcount(ep, 0);
-		send_wr->send_flags = IB_SEND_SIGNALED;
-	}
-}
-
 /* Pre-allocate extra Work Requests for handling backward receives
  * and sends. This is a fixed value because the Work Queues are
  * allocated when the forward channel is set up.


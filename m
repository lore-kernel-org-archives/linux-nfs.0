Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f179.google.com ([209.85.213.179]:39755 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751542AbaGIQ7I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jul 2014 12:59:08 -0400
Subject: [PATCH v2 18/21] xprtrdma: Schedule reply tasklet once per upcall
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 09 Jul 2014 12:59:03 -0400
Message-ID: <20140709165903.3496.30848.stgit@manet.1015granger.net>
In-Reply-To: <20140709163326.3496.37893.stgit@manet.1015granger.net>
References: <20140709163326.3496.37893.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Minor optimization: grab rpcrdma_tk_lock_g and disable hard IRQs
just once after clearing the receive completion queue.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   31 +++++++++++++++----------------
 1 file changed, 15 insertions(+), 16 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 7c49a55..a8a86a0 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -105,17 +105,6 @@ rpcrdma_run_tasklet(unsigned long data)
 
 static DECLARE_TASKLET(rpcrdma_tasklet_g, rpcrdma_run_tasklet, 0UL);
 
-static inline void
-rpcrdma_schedule_tasklet(struct rpcrdma_rep *rep)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&rpcrdma_tk_lock_g, flags);
-	list_add_tail(&rep->rr_list, &rpcrdma_tasklets_g);
-	spin_unlock_irqrestore(&rpcrdma_tk_lock_g, flags);
-	tasklet_schedule(&rpcrdma_tasklet_g);
-}
-
 static void
 rpcrdma_qp_async_error_upcall(struct ib_event *event, void *context)
 {
@@ -214,7 +203,7 @@ rpcrdma_sendcq_upcall(struct ib_cq *cq, void *cq_context)
 }
 
 static void
-rpcrdma_recvcq_process_wc(struct ib_wc *wc)
+rpcrdma_recvcq_process_wc(struct ib_wc *wc, struct list_head *sched_list)
 {
 	struct rpcrdma_rep *rep =
 			(struct rpcrdma_rep *)(unsigned long)wc->wr_id;
@@ -245,28 +234,38 @@ rpcrdma_recvcq_process_wc(struct ib_wc *wc)
 	}
 
 out_schedule:
-	rpcrdma_schedule_tasklet(rep);
+	list_add_tail(&rep->rr_list, sched_list);
 }
 
 static int
 rpcrdma_recvcq_poll(struct ib_cq *cq, struct rpcrdma_ep *ep)
 {
+	struct list_head sched_list;
 	struct ib_wc *wcs;
 	int budget, count, rc;
+	unsigned long flags;
 
+	INIT_LIST_HEAD(&sched_list);
 	budget = RPCRDMA_WC_BUDGET / RPCRDMA_POLLSIZE;
 	do {
 		wcs = ep->rep_recv_wcs;
 
 		rc = ib_poll_cq(cq, RPCRDMA_POLLSIZE, wcs);
 		if (rc <= 0)
-			return rc;
+			goto out_schedule;
 
 		count = rc;
 		while (count-- > 0)
-			rpcrdma_recvcq_process_wc(wcs++);
+			rpcrdma_recvcq_process_wc(wcs++, &sched_list);
 	} while (rc == RPCRDMA_POLLSIZE && --budget);
-	return 0;
+	rc = 0;
+
+out_schedule:
+	spin_lock_irqsave(&rpcrdma_tk_lock_g, flags);
+	list_splice_tail(&sched_list, &rpcrdma_tasklets_g);
+	spin_unlock_irqrestore(&rpcrdma_tk_lock_g, flags);
+	tasklet_schedule(&rpcrdma_tasklet_g);
+	return rc;
 }
 
 /*


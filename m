Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:34967 "EHLO
	mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932344AbbJPNZA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Oct 2015 09:25:00 -0400
Subject: [PATCH v3 07/16] xprtrdma: Remove reply tasklet
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 16 Oct 2015 09:24:58 -0400
Message-ID: <20151016132458.6819.77455.stgit@oracle-122.nfsv4bat.org>
In-Reply-To: <20151016131958.6819.98407.stgit@oracle-122.nfsv4bat.org>
References: <20151016131958.6819.98407.stgit@oracle-122.nfsv4bat.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: The reply tasklet is no longer used.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
Tested-By: Devesh Sharma <devesh.sharma@avagotech.com>
---
 net/sunrpc/xprtrdma/verbs.c |   43 -------------------------------------------
 1 file changed, 43 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index cf2f5b3..a4102fc 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -68,38 +68,6 @@
  * internal functions
  */
 
-/*
- * handle replies in tasklet context, using a single, global list
- * rdma tasklet function -- just turn around and call the func
- * for all replies on the list
- */
-
-static DEFINE_SPINLOCK(rpcrdma_tk_lock_g);
-static LIST_HEAD(rpcrdma_tasklets_g);
-
-static void
-rpcrdma_run_tasklet(unsigned long data)
-{
-	struct rpcrdma_rep *rep;
-	unsigned long flags;
-
-	data = data;
-	spin_lock_irqsave(&rpcrdma_tk_lock_g, flags);
-	while (!list_empty(&rpcrdma_tasklets_g)) {
-		rep = list_entry(rpcrdma_tasklets_g.next,
-				 struct rpcrdma_rep, rr_list);
-		list_del(&rep->rr_list);
-		spin_unlock_irqrestore(&rpcrdma_tk_lock_g, flags);
-
-		rpcrdma_reply_handler(rep);
-
-		spin_lock_irqsave(&rpcrdma_tk_lock_g, flags);
-	}
-	spin_unlock_irqrestore(&rpcrdma_tk_lock_g, flags);
-}
-
-static DECLARE_TASKLET(rpcrdma_tasklet_g, rpcrdma_run_tasklet, 0UL);
-
 static struct workqueue_struct *rpcrdma_receive_wq;
 
 int
@@ -130,17 +98,6 @@ rpcrdma_destroy_wq(void)
 }
 
 static void
-rpcrdma_schedule_tasklet(struct list_head *sched_list)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&rpcrdma_tk_lock_g, flags);
-	list_splice_tail(sched_list, &rpcrdma_tasklets_g);
-	spin_unlock_irqrestore(&rpcrdma_tk_lock_g, flags);
-	tasklet_schedule(&rpcrdma_tasklet_g);
-}
-
-static void
 rpcrdma_qp_async_error_upcall(struct ib_event *event, void *context)
 {
 	struct rpcrdma_ep *ep = context;


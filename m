Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:37055 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbaKIBOj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 8 Nov 2014 20:14:39 -0500
Subject: [PATCH v2 04/10] xprtrdma: Refactor tasklet scheduling
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 08 Nov 2014 20:14:37 -0500
Message-ID: <20141109011437.8806.74314.stgit@manet.1015granger.net>
In-Reply-To: <20141109010328.8806.5861.stgit@manet.1015granger.net>
References: <20141109010328.8806.5861.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Restore the separate function that schedules the reply handling
tasklet. I need to call it from two different paths.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 3c88276..478b2fd 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -107,6 +107,17 @@ rpcrdma_run_tasklet(unsigned long data)
 static DECLARE_TASKLET(rpcrdma_tasklet_g, rpcrdma_run_tasklet, 0UL);
 
 static void
+rpcrdma_schedule_tasklet(struct list_head *sched_list)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&rpcrdma_tk_lock_g, flags);
+	list_splice_tail(sched_list, &rpcrdma_tasklets_g);
+	spin_unlock_irqrestore(&rpcrdma_tk_lock_g, flags);
+	tasklet_schedule(&rpcrdma_tasklet_g);
+}
+
+static void
 rpcrdma_qp_async_error_upcall(struct ib_event *event, void *context)
 {
 	struct rpcrdma_ep *ep = context;
@@ -244,7 +255,6 @@ rpcrdma_recvcq_poll(struct ib_cq *cq, struct rpcrdma_ep *ep)
 	struct list_head sched_list;
 	struct ib_wc *wcs;
 	int budget, count, rc;
-	unsigned long flags;
 
 	INIT_LIST_HEAD(&sched_list);
 	budget = RPCRDMA_WC_BUDGET / RPCRDMA_POLLSIZE;
@@ -262,10 +272,7 @@ rpcrdma_recvcq_poll(struct ib_cq *cq, struct rpcrdma_ep *ep)
 	rc = 0;
 
 out_schedule:
-	spin_lock_irqsave(&rpcrdma_tk_lock_g, flags);
-	list_splice_tail(&sched_list, &rpcrdma_tasklets_g);
-	spin_unlock_irqrestore(&rpcrdma_tk_lock_g, flags);
-	tasklet_schedule(&rpcrdma_tasklet_g);
+	rpcrdma_schedule_tasklet(&sched_list);
 	return rc;
 }
 


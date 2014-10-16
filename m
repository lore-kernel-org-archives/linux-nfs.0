Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:49529 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752492AbaJPTis (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Oct 2014 15:38:48 -0400
Received: by mail-ig0-f175.google.com with SMTP id uq10so270851igb.8
        for <linux-nfs@vger.kernel.org>; Thu, 16 Oct 2014 12:38:48 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id 141sm3539702ioz.39.2014.10.16.12.38.47
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Oct 2014 12:38:47 -0700 (PDT)
Subject: [PATCH v1 04/16] xprtrdma: Re-write rpcrdma_flush_cqs()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Thu, 16 Oct 2014 15:38:46 -0400
Message-ID: <20141016193846.13414.23872.stgit@manet.1015granger.net>
In-Reply-To: <20141016192919.13414.3151.stgit@manet.1015granger.net>
References: <20141016192919.13414.3151.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently rpcrdma_flush_cqs() attempts to avoid code duplication,
and simply invokes rpcrdma_recvcq_upcall and rpcrdma_sendcq_upcall.
This has two minor issues:

1. It re-arms the CQ, which can happen even if a CQ upcall is
   running at the same time

2. The upcall functions drain only a limited number of CQEs,
   thanks to the poll budget added by commit 8301a2c047cc
   ("xprtrdma: Limit work done by completion handler").

Rewrite rpcrdma_flush_cqs() to be sure all CQEs are drained after a
transport is disconnected.

Fixes: a7bc211ac926 ("xprtrdma: On disconnect, don't ignore ... ")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   32 ++++++++++++++++++++++++--------
 1 file changed, 24 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 5c0c7a5..6fadb90 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -106,6 +106,17 @@ rpcrdma_run_tasklet(unsigned long data)
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
@@ -243,7 +254,6 @@ rpcrdma_recvcq_poll(struct ib_cq *cq, struct rpcrdma_ep *ep)
 	struct list_head sched_list;
 	struct ib_wc *wcs;
 	int budget, count, rc;
-	unsigned long flags;
 
 	INIT_LIST_HEAD(&sched_list);
 	budget = RPCRDMA_WC_BUDGET / RPCRDMA_POLLSIZE;
@@ -261,10 +271,7 @@ rpcrdma_recvcq_poll(struct ib_cq *cq, struct rpcrdma_ep *ep)
 	rc = 0;
 
 out_schedule:
-	spin_lock_irqsave(&rpcrdma_tk_lock_g, flags);
-	list_splice_tail(&sched_list, &rpcrdma_tasklets_g);
-	spin_unlock_irqrestore(&rpcrdma_tk_lock_g, flags);
-	tasklet_schedule(&rpcrdma_tasklet_g);
+	rpcrdma_schedule_tasklet(&sched_list);
 	return rc;
 }
 
@@ -309,8 +316,17 @@ rpcrdma_recvcq_upcall(struct ib_cq *cq, void *cq_context)
 static void
 rpcrdma_flush_cqs(struct rpcrdma_ep *ep)
 {
-	rpcrdma_recvcq_upcall(ep->rep_attr.recv_cq, ep);
-	rpcrdma_sendcq_upcall(ep->rep_attr.send_cq, ep);
+	struct list_head sched_list;
+	struct ib_wc wc;
+
+	INIT_LIST_HEAD(&sched_list);
+	while (ib_poll_cq(ep->rep_attr.recv_cq, 1, &wc) > 0)
+		rpcrdma_recvcq_process_wc(&wc, &sched_list);
+	if (!list_empty(&sched_list))
+		rpcrdma_schedule_tasklet(&sched_list);
+
+	while (ib_poll_cq(ep->rep_attr.send_cq, 1, &wc) > 0)
+		rpcrdma_sendcq_process_wc(&wc);
 }
 
 #ifdef RPC_DEBUG
@@ -980,7 +996,6 @@ rpcrdma_ep_disconnect(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 {
 	int rc;
 
-	rpcrdma_flush_cqs(ep);
 	rc = rdma_disconnect(ia->ri_id);
 	if (!rc) {
 		/* returns without wait if not connected */
@@ -992,6 +1007,7 @@ rpcrdma_ep_disconnect(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 		dprintk("RPC:       %s: rdma_disconnect %i\n", __func__, rc);
 		ep->rep_connected = rc;
 	}
+	rpcrdma_flush_cqs(ep);
 }
 
 static int


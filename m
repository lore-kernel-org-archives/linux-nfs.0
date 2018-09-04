Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:51668 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726749AbeIEBdX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Sep 2018 21:33:23 -0400
Received: by mail-it0-f67.google.com with SMTP id e14-v6so7033169itf.1
        for <linux-nfs@vger.kernel.org>; Tue, 04 Sep 2018 14:06:31 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id t64-v6sm172860ita.13.2018.09.04.14.06.29
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Sep 2018 14:06:30 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 26/34] SUNRPC: Improve latency for interactive tasks
Date: Tue,  4 Sep 2018 17:05:41 -0400
Message-Id: <20180904210549.81673-27-trond.myklebust@hammerspace.com>
In-Reply-To: <20180904210549.81673-26-trond.myklebust@hammerspace.com>
References: <20180904210549.81673-1-trond.myklebust@hammerspace.com>
 <20180904210549.81673-2-trond.myklebust@hammerspace.com>
 <20180904210549.81673-3-trond.myklebust@hammerspace.com>
 <20180904210549.81673-4-trond.myklebust@hammerspace.com>
 <20180904210549.81673-5-trond.myklebust@hammerspace.com>
 <20180904210549.81673-6-trond.myklebust@hammerspace.com>
 <20180904210549.81673-7-trond.myklebust@hammerspace.com>
 <20180904210549.81673-8-trond.myklebust@hammerspace.com>
 <20180904210549.81673-9-trond.myklebust@hammerspace.com>
 <20180904210549.81673-10-trond.myklebust@hammerspace.com>
 <20180904210549.81673-11-trond.myklebust@hammerspace.com>
 <20180904210549.81673-12-trond.myklebust@hammerspace.com>
 <20180904210549.81673-13-trond.myklebust@hammerspace.com>
 <20180904210549.81673-14-trond.myklebust@hammerspace.com>
 <20180904210549.81673-15-trond.myklebust@hammerspace.com>
 <20180904210549.81673-16-trond.myklebust@hammerspace.com>
 <20180904210549.81673-17-trond.myklebust@hammerspace.com>
 <20180904210549.81673-18-trond.myklebust@hammerspace.com>
 <20180904210549.81673-19-trond.myklebust@hammerspace.com>
 <20180904210549.81673-20-trond.myklebust@hammerspace.com>
 <20180904210549.81673-21-trond.myklebust@hammerspace.com>
 <20180904210549.81673-22-trond.myklebust@hammerspace.com>
 <20180904210549.81673-23-trond.myklebust@hammerspace.com>
 <20180904210549.81673-24-trond.myklebust@hammerspace.com>
 <20180904210549.81673-25-trond.myklebust@hammerspace.com>
 <20180904210549.81673-26-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

One of the intentions with the priority queues was to ensure that no
single process can hog the transport. The field task->tk_owner therefore
identifies the RPC call's origin, and is intended to allow the RPC layer
to organise queues for fairness.
This commit therefore modifies the transmit queue to group requests
by task->tk_owner, and ensures that we round robin among those groups.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/xprt.h       |  1 +
 net/sunrpc/backchannel_rqst.c     |  1 +
 net/sunrpc/xprt.c                 | 23 +++++++++++++++++++++--
 net/sunrpc/xprtrdma/backchannel.c |  1 +
 4 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index b23c757bebfc..5dd64bdb28cd 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -89,6 +89,7 @@ struct rpc_rqst {
 	};
 
 	struct list_head	rq_xmit;	/* Send queue */
+	struct list_head	rq_xmit2;	/* Send queue */
 
 	void			*rq_buffer;	/* Call XDR encode buffer */
 	size_t			rq_callsize;
diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
index 39b394b7dae3..e43dbab2e3f0 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -93,6 +93,7 @@ struct rpc_rqst *xprt_alloc_bc_req(struct rpc_xprt *xprt, gfp_t gfp_flags)
 	req->rq_xprt = xprt;
 	INIT_LIST_HEAD(&req->rq_recv);
 	INIT_LIST_HEAD(&req->rq_xmit);
+	INIT_LIST_HEAD(&req->rq_xmit2);
 	INIT_LIST_HEAD(&req->rq_bc_list);
 
 	/* Preallocate one XDR receive buffer */
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index a7a93d61567f..8a4c5260eecd 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1043,6 +1043,7 @@ xprt_request_enqueue_transmit(struct rpc_task *task)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_xprt *xprt = req->rq_xprt;
+	struct rpc_rqst *pos;
 
 	spin_lock(&xprt->queue_lock);
 	if (list_empty(&req->rq_xmit) && xprt_request_need_transmit(task) &&
@@ -1052,7 +1053,6 @@ xprt_request_enqueue_transmit(struct rpc_task *task)
 		 * to the head of the list to avoid starvation issues.
 		 */
 		if (req->rq_cong) {
-			struct rpc_rqst *pos;
 			list_for_each_entry(pos, &xprt->xmit_queue, rq_xmit) {
 				if (pos->rq_cong)
 					continue;
@@ -1060,6 +1060,13 @@ xprt_request_enqueue_transmit(struct rpc_task *task)
 				list_add_tail(&req->rq_xmit, &pos->rq_xmit);
 				goto out;
 			}
+		} else {
+			list_for_each_entry(pos, &xprt->xmit_queue, rq_xmit) {
+				if (pos->rq_task->tk_owner != task->tk_owner)
+					continue;
+				list_add_tail(&req->rq_xmit2, &pos->rq_xmit2);
+				goto out;
+			}
 		}
 		list_add_tail(&req->rq_xmit, &xprt->xmit_queue);
 	}
@@ -1077,8 +1084,19 @@ xprt_request_enqueue_transmit(struct rpc_task *task)
 static void
 xprt_request_dequeue_transmit_locked(struct rpc_task *task)
 {
+	struct rpc_rqst *req = task->tk_rqstp;
+
 	clear_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
-	list_del_init(&task->tk_rqstp->rq_xmit);
+	if (!list_empty(&req->rq_xmit)) {
+		list_del_init(&req->rq_xmit);
+		if (!list_empty(&req->rq_xmit2)) {
+			struct rpc_rqst *next = list_first_entry(&req->rq_xmit2,
+					struct rpc_rqst, rq_xmit2);
+			list_del_init(&req->rq_xmit2);
+			list_add_tail(&next->rq_xmit, &next->rq_xprt->xmit_queue);
+		}
+	} else if (!list_empty(&req->rq_xmit2))
+		list_del_init(&req->rq_xmit2);
 }
 
 /**
@@ -1376,6 +1394,7 @@ xprt_request_init(struct rpc_task *task)
 
 	INIT_LIST_HEAD(&req->rq_recv);
 	INIT_LIST_HEAD(&req->rq_xmit);
+	INIT_LIST_HEAD(&req->rq_xmit2);
 	req->rq_timeout = task->tk_client->cl_timeout->to_initval;
 	req->rq_task	= task;
 	req->rq_xprt    = xprt;
diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 14fc4596075e..92fffe765731 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -53,6 +53,7 @@ static int rpcrdma_bc_setup_reqs(struct rpcrdma_xprt *r_xprt,
 		rqst->rq_xprt = xprt;
 		INIT_LIST_HEAD(&rqst->rq_recv);
 		INIT_LIST_HEAD(&rqst->rq_xmit);
+		INIT_LIST_HEAD(&rqst->rq_xmit2);
 		INIT_LIST_HEAD(&rqst->rq_bc_list);
 		__set_bit(RPC_BC_PA_IN_USE, &rqst->rq_bc_pa_state);
 		spin_lock_bh(&xprt->bc_pa_lock);
-- 
2.17.1

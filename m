Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:37285 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728299AbeIQSbo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:44 -0400
Received: by mail-qt0-f193.google.com with SMTP id n6-v6so15132587qtl.4
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:28 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.27
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:27 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 26/44] SUNRPC: Improve latency for interactive tasks
Date: Mon, 17 Sep 2018 09:03:17 -0400
Message-Id: <20180917130335.112832-27-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-26-trond.myklebust@hammerspace.com>
References: <20180917130335.112832-1-trond.myklebust@hammerspace.com>
 <20180917130335.112832-2-trond.myklebust@hammerspace.com>
 <20180917130335.112832-3-trond.myklebust@hammerspace.com>
 <20180917130335.112832-4-trond.myklebust@hammerspace.com>
 <20180917130335.112832-5-trond.myklebust@hammerspace.com>
 <20180917130335.112832-6-trond.myklebust@hammerspace.com>
 <20180917130335.112832-7-trond.myklebust@hammerspace.com>
 <20180917130335.112832-8-trond.myklebust@hammerspace.com>
 <20180917130335.112832-9-trond.myklebust@hammerspace.com>
 <20180917130335.112832-10-trond.myklebust@hammerspace.com>
 <20180917130335.112832-11-trond.myklebust@hammerspace.com>
 <20180917130335.112832-12-trond.myklebust@hammerspace.com>
 <20180917130335.112832-13-trond.myklebust@hammerspace.com>
 <20180917130335.112832-14-trond.myklebust@hammerspace.com>
 <20180917130335.112832-15-trond.myklebust@hammerspace.com>
 <20180917130335.112832-16-trond.myklebust@hammerspace.com>
 <20180917130335.112832-17-trond.myklebust@hammerspace.com>
 <20180917130335.112832-18-trond.myklebust@hammerspace.com>
 <20180917130335.112832-19-trond.myklebust@hammerspace.com>
 <20180917130335.112832-20-trond.myklebust@hammerspace.com>
 <20180917130335.112832-21-trond.myklebust@hammerspace.com>
 <20180917130335.112832-22-trond.myklebust@hammerspace.com>
 <20180917130335.112832-23-trond.myklebust@hammerspace.com>
 <20180917130335.112832-24-trond.myklebust@hammerspace.com>
 <20180917130335.112832-25-trond.myklebust@hammerspace.com>
 <20180917130335.112832-26-trond.myklebust@hammerspace.com>
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
 include/linux/sunrpc/xprt.h |  1 +
 net/sunrpc/xprt.c           | 27 ++++++++++++++++++++++++---
 2 files changed, 25 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 8c2bb078f00c..e377620b9744 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -89,6 +89,7 @@ struct rpc_rqst {
 	};
 
 	struct list_head	rq_xmit;	/* Send queue */
+	struct list_head	rq_xmit2;	/* Send queue */
 
 	void			*rq_buffer;	/* Call XDR encode buffer */
 	size_t			rq_callsize;
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 35f5df367591..3e68f35f71f6 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1052,12 +1052,21 @@ xprt_request_need_enqueue_transmit(struct rpc_task *task, struct rpc_rqst *req)
 void
 xprt_request_enqueue_transmit(struct rpc_task *task)
 {
-	struct rpc_rqst *req = task->tk_rqstp;
+	struct rpc_rqst *pos, *req = task->tk_rqstp;
 	struct rpc_xprt *xprt = req->rq_xprt;
 
 	if (xprt_request_need_enqueue_transmit(task, req)) {
 		spin_lock(&xprt->queue_lock);
+		list_for_each_entry(pos, &xprt->xmit_queue, rq_xmit) {
+			if (pos->rq_task->tk_owner != task->tk_owner)
+				continue;
+			list_add_tail(&req->rq_xmit2, &pos->rq_xmit2);
+			INIT_LIST_HEAD(&req->rq_xmit);
+			goto out;
+		}
 		list_add_tail(&req->rq_xmit, &xprt->xmit_queue);
+		INIT_LIST_HEAD(&req->rq_xmit2);
+out:
 		set_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
 		spin_unlock(&xprt->queue_lock);
 	}
@@ -1073,8 +1082,20 @@ xprt_request_enqueue_transmit(struct rpc_task *task)
 static void
 xprt_request_dequeue_transmit_locked(struct rpc_task *task)
 {
-	if (test_and_clear_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate))
-		list_del(&task->tk_rqstp->rq_xmit);
+	struct rpc_rqst *req = task->tk_rqstp;
+
+	if (!test_and_clear_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate))
+		return;
+	if (!list_empty(&req->rq_xmit)) {
+		list_del(&req->rq_xmit);
+		if (!list_empty(&req->rq_xmit2)) {
+			struct rpc_rqst *next = list_first_entry(&req->rq_xmit2,
+					struct rpc_rqst, rq_xmit2);
+			list_del(&req->rq_xmit2);
+			list_add_tail(&next->rq_xmit, &next->rq_xprt->xmit_queue);
+		}
+	} else
+		list_del(&req->rq_xmit2);
 }
 
 /**
-- 
2.17.1

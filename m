Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk1-f193.google.com ([209.85.222.193]:37383 "EHLO
        mail-qk1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728229AbeIQSbe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:34 -0400
Received: by mail-qk1-f193.google.com with SMTP id f17-v6so8912083qkh.4
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:19 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.17
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:17 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 18/44] SUNRPC: Distinguish between the slot allocation list and receive queue
Date: Mon, 17 Sep 2018 09:03:09 -0400
Message-Id: <20180917130335.112832-19-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-18-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When storing a struct rpc_rqst on the slot allocation list, we currently
use the same field 'rq_list' as we use to store the request on the
receive queue. Since the structure is never on both lists at the same
time, this is OK.
However, for clarity, let's make that a union with different names for
the different lists so that we can more easily distinguish between
the two states.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/xprt.h |  9 +++++++--
 net/sunrpc/xprt.c           | 12 ++++++------
 2 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 4fa2af087cff..9cec2d0811f2 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -82,7 +82,11 @@ struct rpc_rqst {
 	struct page		**rq_enc_pages;	/* scratch pages for use by
 						   gss privacy code */
 	void (*rq_release_snd_buf)(struct rpc_rqst *); /* release rq_enc_pages */
-	struct list_head	rq_list;
+
+	union {
+		struct list_head	rq_list;	/* Slot allocation list */
+		struct list_head	rq_recv;	/* Receive queue */
+	};
 
 	void			*rq_buffer;	/* Call XDR encode buffer */
 	size_t			rq_callsize;
@@ -249,7 +253,8 @@ struct rpc_xprt {
 	struct list_head	bc_pa_list;	/* List of preallocated
 						 * backchannel rpc_rqst's */
 #endif /* CONFIG_SUNRPC_BACKCHANNEL */
-	struct list_head	recv;
+
+	struct list_head	recv_queue;	/* Receive queue */
 
 	struct {
 		unsigned long		bind_count,	/* total number of binds */
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index fe857ab18ee2..b242a1c78f8a 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -708,7 +708,7 @@ static void
 xprt_schedule_autodisconnect(struct rpc_xprt *xprt)
 	__must_hold(&xprt->transport_lock)
 {
-	if (list_empty(&xprt->recv) && xprt_has_timer(xprt))
+	if (list_empty(&xprt->recv_queue) && xprt_has_timer(xprt))
 		mod_timer(&xprt->timer, xprt->last_used + xprt->idle_timeout);
 }
 
@@ -718,7 +718,7 @@ xprt_init_autodisconnect(struct timer_list *t)
 	struct rpc_xprt *xprt = from_timer(xprt, t, timer);
 
 	spin_lock(&xprt->transport_lock);
-	if (!list_empty(&xprt->recv))
+	if (!list_empty(&xprt->recv_queue))
 		goto out_abort;
 	/* Reset xprt->last_used to avoid connect/autodisconnect cycling */
 	xprt->last_used = jiffies;
@@ -848,7 +848,7 @@ struct rpc_rqst *xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid)
 {
 	struct rpc_rqst *entry;
 
-	list_for_each_entry(entry, &xprt->recv, rq_list)
+	list_for_each_entry(entry, &xprt->recv_queue, rq_recv)
 		if (entry->rq_xid == xid) {
 			trace_xprt_lookup_rqst(xprt, xid, 0);
 			entry->rq_rtt = ktime_sub(ktime_get(), entry->rq_xtime);
@@ -937,7 +937,7 @@ xprt_request_enqueue_receive(struct rpc_task *task)
 			sizeof(req->rq_private_buf));
 
 	/* Add request to the receive list */
-	list_add_tail(&req->rq_list, &xprt->recv);
+	list_add_tail(&req->rq_recv, &xprt->recv_queue);
 	set_bit(RPC_TASK_NEED_RECV, &task->tk_runstate);
 	spin_unlock(&xprt->queue_lock);
 
@@ -956,7 +956,7 @@ static void
 xprt_request_dequeue_receive_locked(struct rpc_task *task)
 {
 	if (test_and_clear_bit(RPC_TASK_NEED_RECV, &task->tk_runstate))
-		list_del(&task->tk_rqstp->rq_list);
+		list_del(&task->tk_rqstp->rq_recv);
 }
 
 /**
@@ -1491,7 +1491,7 @@ static void xprt_init(struct rpc_xprt *xprt, struct net *net)
 	spin_lock_init(&xprt->queue_lock);
 
 	INIT_LIST_HEAD(&xprt->free);
-	INIT_LIST_HEAD(&xprt->recv);
+	INIT_LIST_HEAD(&xprt->recv_queue);
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 	spin_lock_init(&xprt->bc_pa_lock);
 	INIT_LIST_HEAD(&xprt->bc_pa_list);
-- 
2.17.1

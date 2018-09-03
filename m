Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:39030 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727430AbeICTuz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Sep 2018 15:50:55 -0400
Received: by mail-io0-f193.google.com with SMTP id l7-v6so687583iok.6
        for <linux-nfs@vger.kernel.org>; Mon, 03 Sep 2018 08:30:15 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id c25-v6sm7040027iob.30.2018.09.03.08.30.14
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Sep 2018 08:30:14 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 17/27] SUNRPC: Distinguish between the slot allocation list and receive queue
Date: Mon,  3 Sep 2018 11:29:26 -0400
Message-Id: <20180903152936.24325-18-trond.myklebust@hammerspace.com>
In-Reply-To: <20180903152936.24325-17-trond.myklebust@hammerspace.com>
References: <20180903152936.24325-1-trond.myklebust@hammerspace.com>
 <20180903152936.24325-2-trond.myklebust@hammerspace.com>
 <20180903152936.24325-3-trond.myklebust@hammerspace.com>
 <20180903152936.24325-4-trond.myklebust@hammerspace.com>
 <20180903152936.24325-5-trond.myklebust@hammerspace.com>
 <20180903152936.24325-6-trond.myklebust@hammerspace.com>
 <20180903152936.24325-7-trond.myklebust@hammerspace.com>
 <20180903152936.24325-8-trond.myklebust@hammerspace.com>
 <20180903152936.24325-9-trond.myklebust@hammerspace.com>
 <20180903152936.24325-10-trond.myklebust@hammerspace.com>
 <20180903152936.24325-11-trond.myklebust@hammerspace.com>
 <20180903152936.24325-12-trond.myklebust@hammerspace.com>
 <20180903152936.24325-13-trond.myklebust@hammerspace.com>
 <20180903152936.24325-14-trond.myklebust@hammerspace.com>
 <20180903152936.24325-15-trond.myklebust@hammerspace.com>
 <20180903152936.24325-16-trond.myklebust@hammerspace.com>
 <20180903152936.24325-17-trond.myklebust@hammerspace.com>
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
 include/linux/sunrpc/xprt.h       |  9 +++++++--
 net/sunrpc/backchannel_rqst.c     |  2 +-
 net/sunrpc/xprt.c                 | 16 ++++++++--------
 net/sunrpc/xprtrdma/backchannel.c |  2 +-
 4 files changed, 17 insertions(+), 12 deletions(-)

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
diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
index 3c15a99b9700..92e9ad30ec2f 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -91,7 +91,7 @@ struct rpc_rqst *xprt_alloc_bc_req(struct rpc_xprt *xprt, gfp_t gfp_flags)
 		return NULL;
 
 	req->rq_xprt = xprt;
-	INIT_LIST_HEAD(&req->rq_list);
+	INIT_LIST_HEAD(&req->rq_recv);
 	INIT_LIST_HEAD(&req->rq_bc_list);
 
 	/* Preallocate one XDR receive buffer */
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index aefa23c90a2b..0184a6aed7e3 100644
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
@@ -919,7 +919,7 @@ xprt_request_enqueue_receive(struct rpc_task *task)
 	struct rpc_xprt *xprt = req->rq_xprt;
 
 	spin_lock(&xprt->queue_lock);
-	if (xprt_request_data_received(task) || !list_empty(&req->rq_list)) {
+	if (xprt_request_data_received(task) || !list_empty(&req->rq_recv)) {
 		spin_unlock(&xprt->queue_lock);
 		return;
 	}
@@ -929,7 +929,7 @@ xprt_request_enqueue_receive(struct rpc_task *task)
 			sizeof(req->rq_private_buf));
 
 	/* Add request to the receive list */
-	list_add_tail(&req->rq_list, &xprt->recv);
+	list_add_tail(&req->rq_recv, &xprt->recv_queue);
 	set_bit(RPC_TASK_NEED_RECV, &task->tk_runstate);
 	spin_unlock(&xprt->queue_lock);
 
@@ -948,7 +948,7 @@ static void
 xprt_request_dequeue_receive_locked(struct rpc_task *task)
 {
 	clear_bit(RPC_TASK_NEED_RECV, &task->tk_runstate);
-	list_del_init(&task->tk_rqstp->rq_list);
+	list_del_init(&task->tk_rqstp->rq_recv);
 }
 
 /**
@@ -1337,7 +1337,7 @@ xprt_request_init(struct rpc_task *task)
 	struct rpc_xprt *xprt = task->tk_xprt;
 	struct rpc_rqst	*req = task->tk_rqstp;
 
-	INIT_LIST_HEAD(&req->rq_list);
+	INIT_LIST_HEAD(&req->rq_recv);
 	req->rq_timeout = task->tk_client->cl_timeout->to_initval;
 	req->rq_task	= task;
 	req->rq_xprt    = xprt;
@@ -1471,7 +1471,7 @@ static void xprt_init(struct rpc_xprt *xprt, struct net *net)
 	spin_lock_init(&xprt->queue_lock);
 
 	INIT_LIST_HEAD(&xprt->free);
-	INIT_LIST_HEAD(&xprt->recv);
+	INIT_LIST_HEAD(&xprt->recv_queue);
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 	spin_lock_init(&xprt->bc_pa_lock);
 	INIT_LIST_HEAD(&xprt->bc_pa_list);
diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 90adeff4c06b..40c7c7306a99 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -51,7 +51,7 @@ static int rpcrdma_bc_setup_reqs(struct rpcrdma_xprt *r_xprt,
 		rqst = &req->rl_slot;
 
 		rqst->rq_xprt = xprt;
-		INIT_LIST_HEAD(&rqst->rq_list);
+		INIT_LIST_HEAD(&rqst->rq_recv);
 		INIT_LIST_HEAD(&rqst->rq_bc_list);
 		__set_bit(RPC_BC_PA_IN_USE, &rqst->rq_bc_pa_state);
 		spin_lock_bh(&xprt->bc_pa_lock);
-- 
2.17.1

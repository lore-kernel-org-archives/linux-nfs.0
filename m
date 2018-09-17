Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:41499 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728321AbeIQSbx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:53 -0400
Received: by mail-qt0-f195.google.com with SMTP id t39-v6so15115027qtc.8
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:38 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.36
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:36 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 35/44] SUNRPC: Convert xprt receive queue to use an rbtree
Date: Mon, 17 Sep 2018 09:03:26 -0400
Message-Id: <20180917130335.112832-36-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-35-trond.myklebust@hammerspace.com>
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
 <20180917130335.112832-27-trond.myklebust@hammerspace.com>
 <20180917130335.112832-28-trond.myklebust@hammerspace.com>
 <20180917130335.112832-29-trond.myklebust@hammerspace.com>
 <20180917130335.112832-30-trond.myklebust@hammerspace.com>
 <20180917130335.112832-31-trond.myklebust@hammerspace.com>
 <20180917130335.112832-32-trond.myklebust@hammerspace.com>
 <20180917130335.112832-33-trond.myklebust@hammerspace.com>
 <20180917130335.112832-34-trond.myklebust@hammerspace.com>
 <20180917130335.112832-35-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server is slow, we can find ourselves with quite a lot of entries
on the receive queue. Converting the search from an O(n) to O(log(n))
can make a significant difference, particularly since we have to hold
a number of locks while searching.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/xprt.h |  4 +-
 net/sunrpc/xprt.c           | 93 ++++++++++++++++++++++++++++++++-----
 2 files changed, 84 insertions(+), 13 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 823860cce0bc..9be399020dab 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -85,7 +85,7 @@ struct rpc_rqst {
 
 	union {
 		struct list_head	rq_list;	/* Slot allocation list */
-		struct list_head	rq_recv;	/* Receive queue */
+		struct rb_node		rq_recv;	/* Receive queue */
 	};
 
 	struct list_head	rq_xmit;	/* Send queue */
@@ -260,7 +260,7 @@ struct rpc_xprt {
 						 * backchannel rpc_rqst's */
 #endif /* CONFIG_SUNRPC_BACKCHANNEL */
 
-	struct list_head	recv_queue;	/* Receive queue */
+	struct rb_root		recv_queue;	/* Receive queue */
 
 	struct {
 		unsigned long		bind_count,	/* total number of binds */
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index a1cb28a4adad..051638d5b39c 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -753,7 +753,7 @@ static void
 xprt_schedule_autodisconnect(struct rpc_xprt *xprt)
 	__must_hold(&xprt->transport_lock)
 {
-	if (list_empty(&xprt->recv_queue) && xprt_has_timer(xprt))
+	if (RB_EMPTY_ROOT(&xprt->recv_queue) && xprt_has_timer(xprt))
 		mod_timer(&xprt->timer, xprt->last_used + xprt->idle_timeout);
 }
 
@@ -763,7 +763,7 @@ xprt_init_autodisconnect(struct timer_list *t)
 	struct rpc_xprt *xprt = from_timer(xprt, t, timer);
 
 	spin_lock(&xprt->transport_lock);
-	if (!list_empty(&xprt->recv_queue))
+	if (!RB_EMPTY_ROOT(&xprt->recv_queue))
 		goto out_abort;
 	/* Reset xprt->last_used to avoid connect/autodisconnect cycling */
 	xprt->last_used = jiffies;
@@ -880,6 +880,75 @@ static void xprt_connect_status(struct rpc_task *task)
 	}
 }
 
+enum xprt_xid_rb_cmp {
+	XID_RB_EQUAL,
+	XID_RB_LEFT,
+	XID_RB_RIGHT,
+};
+static enum xprt_xid_rb_cmp
+xprt_xid_cmp(__be32 xid1, __be32 xid2)
+{
+	if (xid1 == xid2)
+		return XID_RB_EQUAL;
+	if ((__force u32)xid1 < (__force u32)xid2)
+		return XID_RB_LEFT;
+	return XID_RB_RIGHT;
+}
+
+static struct rpc_rqst *
+xprt_request_rb_find(struct rpc_xprt *xprt, __be32 xid)
+{
+	struct rb_node *n = xprt->recv_queue.rb_node;
+	struct rpc_rqst *req;
+
+	while (n != NULL) {
+		req = rb_entry(n, struct rpc_rqst, rq_recv);
+		switch (xprt_xid_cmp(xid, req->rq_xid)) {
+		case XID_RB_LEFT:
+			n = n->rb_left;
+			break;
+		case XID_RB_RIGHT:
+			n = n->rb_right;
+			break;
+		case XID_RB_EQUAL:
+			return req;
+		}
+	}
+	return NULL;
+}
+
+static void
+xprt_request_rb_insert(struct rpc_xprt *xprt, struct rpc_rqst *new)
+{
+	struct rb_node **p = &xprt->recv_queue.rb_node;
+	struct rb_node *n = NULL;
+	struct rpc_rqst *req;
+
+	while (*p != NULL) {
+		n = *p;
+		req = rb_entry(n, struct rpc_rqst, rq_recv);
+		switch(xprt_xid_cmp(new->rq_xid, req->rq_xid)) {
+		case XID_RB_LEFT:
+			p = &n->rb_left;
+			break;
+		case XID_RB_RIGHT:
+			p = &n->rb_right;
+			break;
+		case XID_RB_EQUAL:
+			WARN_ON_ONCE(new != req);
+			return;
+		}
+	}
+	rb_link_node(&new->rq_recv, n, p);
+	rb_insert_color(&new->rq_recv, &xprt->recv_queue);
+}
+
+static void
+xprt_request_rb_remove(struct rpc_xprt *xprt, struct rpc_rqst *req)
+{
+	rb_erase(&req->rq_recv, &xprt->recv_queue);
+}
+
 /**
  * xprt_lookup_rqst - find an RPC request corresponding to an XID
  * @xprt: transport on which the original request was transmitted
@@ -891,12 +960,12 @@ struct rpc_rqst *xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid)
 {
 	struct rpc_rqst *entry;
 
-	list_for_each_entry(entry, &xprt->recv_queue, rq_recv)
-		if (entry->rq_xid == xid) {
-			trace_xprt_lookup_rqst(xprt, xid, 0);
-			entry->rq_rtt = ktime_sub(ktime_get(), entry->rq_xtime);
-			return entry;
-		}
+	entry = xprt_request_rb_find(xprt, xid);
+	if (entry != NULL) {
+		trace_xprt_lookup_rqst(xprt, xid, 0);
+		entry->rq_rtt = ktime_sub(ktime_get(), entry->rq_xtime);
+		return entry;
+	}
 
 	dprintk("RPC:       xprt_lookup_rqst did not find xid %08x\n",
 			ntohl(xid));
@@ -980,7 +1049,7 @@ xprt_request_enqueue_receive(struct rpc_task *task)
 			sizeof(req->rq_private_buf));
 
 	/* Add request to the receive list */
-	list_add_tail(&req->rq_recv, &xprt->recv_queue);
+	xprt_request_rb_insert(xprt, req);
 	set_bit(RPC_TASK_NEED_RECV, &task->tk_runstate);
 	spin_unlock(&xprt->queue_lock);
 
@@ -998,8 +1067,10 @@ xprt_request_enqueue_receive(struct rpc_task *task)
 static void
 xprt_request_dequeue_receive_locked(struct rpc_task *task)
 {
+	struct rpc_rqst *req = task->tk_rqstp;
+
 	if (test_and_clear_bit(RPC_TASK_NEED_RECV, &task->tk_runstate))
-		list_del(&task->tk_rqstp->rq_recv);
+		xprt_request_rb_remove(req->rq_xprt, req);
 }
 
 /**
@@ -1710,7 +1781,7 @@ static void xprt_init(struct rpc_xprt *xprt, struct net *net)
 	spin_lock_init(&xprt->queue_lock);
 
 	INIT_LIST_HEAD(&xprt->free);
-	INIT_LIST_HEAD(&xprt->recv_queue);
+	xprt->recv_queue = RB_ROOT;
 	INIT_LIST_HEAD(&xprt->xmit_queue);
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 	spin_lock_init(&xprt->bc_pa_lock);
-- 
2.17.1

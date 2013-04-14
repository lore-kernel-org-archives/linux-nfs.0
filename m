Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:50341 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752219Ab3DNRAm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 14 Apr 2013 13:00:42 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/3] SUNRPC: Fix a livelock problem in the xprt->backlog queue
Date: Sun, 14 Apr 2013 13:00:36 -0400
Message-Id: <1365958838-39047-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch ensures that we throttle new RPC requests if there are
requests already waiting in the xprt->backlog queue. The reason for
doing this is to fix livelock issues that can occur when an existing
(high priority) task is waiting in the backlog queue, gets woken up
by xprt_free_slot(), but a new task then steals the slot.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/xprt.h |  2 ++
 net/sunrpc/clnt.c           | 17 ++++++++++++-
 net/sunrpc/xprt.c           | 61 ++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 76 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 30834be..12815f6 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -279,6 +279,7 @@ struct xprt_class {
 struct rpc_xprt		*xprt_create_transport(struct xprt_create *args);
 void			xprt_connect(struct rpc_task *task);
 void			xprt_reserve(struct rpc_task *task);
+void			xprt_retry_reserve(struct rpc_task *task);
 int			xprt_reserve_xprt(struct rpc_xprt *xprt, struct rpc_task *task);
 int			xprt_reserve_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task);
 void			xprt_alloc_slot(struct rpc_xprt *xprt, struct rpc_task *task);
@@ -334,6 +335,7 @@ int			xs_swapper(struct rpc_xprt *xprt, int enable);
 #define XPRT_CLOSING		(6)
 #define XPRT_CONNECTION_ABORT	(7)
 #define XPRT_CONNECTION_CLOSE	(8)
+#define XPRT_CONGESTED		(9)
 
 static inline void xprt_set_connected(struct rpc_xprt *xprt)
 {
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index b95a0a2..a80ee9b 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1306,6 +1306,8 @@ call_reserve(struct rpc_task *task)
 	xprt_reserve(task);
 }
 
+static void call_retry_reserve(struct rpc_task *task);
+
 /*
  * 1b.	Grok the result of xprt_reserve()
  */
@@ -1347,7 +1349,7 @@ call_reserveresult(struct rpc_task *task)
 	case -ENOMEM:
 		rpc_delay(task, HZ >> 2);
 	case -EAGAIN:	/* woken up; retry */
-		task->tk_action = call_reserve;
+		task->tk_action = call_retry_reserve;
 		return;
 	case -EIO:	/* probably a shutdown */
 		break;
@@ -1360,6 +1362,19 @@ call_reserveresult(struct rpc_task *task)
 }
 
 /*
+ * 1c.	Retry reserving an RPC call slot
+ */
+static void
+call_retry_reserve(struct rpc_task *task)
+{
+	dprint_status(task);
+
+	task->tk_status  = 0;
+	task->tk_action  = call_reserveresult;
+	xprt_retry_reserve(task);
+}
+
+/*
  * 2.	Bind and/or refresh the credentials
  */
 static void
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index b7478d5..745fca3 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -948,6 +948,34 @@ void xprt_transmit(struct rpc_task *task)
 	spin_unlock_bh(&xprt->transport_lock);
 }
 
+static void xprt_add_backlog(struct rpc_xprt *xprt, struct rpc_task *task)
+{
+	set_bit(XPRT_CONGESTED, &xprt->state);
+	rpc_sleep_on(&xprt->backlog, task, NULL);
+}
+
+static void xprt_wake_up_backlog(struct rpc_xprt *xprt)
+{
+	if (rpc_wake_up_next(&xprt->backlog) == NULL)
+		clear_bit(XPRT_CONGESTED, &xprt->state);
+}
+
+static bool xprt_throttle_congested(struct rpc_xprt *xprt, struct rpc_task *task)
+{
+	bool ret = false;
+
+	if (!test_bit(XPRT_CONGESTED, &xprt->state))
+		goto out;
+	spin_lock(&xprt->reserve_lock);
+	if (test_bit(XPRT_CONGESTED, &xprt->state)) {
+		rpc_sleep_on(&xprt->backlog, task, NULL);
+		ret = true;
+	}
+	spin_unlock(&xprt->reserve_lock);
+out:
+	return ret;
+}
+
 static struct rpc_rqst *xprt_dynamic_alloc_slot(struct rpc_xprt *xprt, gfp_t gfp_flags)
 {
 	struct rpc_rqst *req = ERR_PTR(-EAGAIN);
@@ -992,7 +1020,7 @@ void xprt_alloc_slot(struct rpc_xprt *xprt, struct rpc_task *task)
 		task->tk_status = -ENOMEM;
 		break;
 	case -EAGAIN:
-		rpc_sleep_on(&xprt->backlog, task, NULL);
+		xprt_add_backlog(xprt, task);
 		dprintk("RPC:       waiting for request slot\n");
 	default:
 		task->tk_status = -EAGAIN;
@@ -1028,7 +1056,7 @@ static void xprt_free_slot(struct rpc_xprt *xprt, struct rpc_rqst *req)
 		memset(req, 0, sizeof(*req));	/* mark unused */
 		list_add(&req->rq_list, &xprt->free);
 	}
-	rpc_wake_up_next(&xprt->backlog);
+	xprt_wake_up_backlog(xprt);
 	spin_unlock(&xprt->reserve_lock);
 }
 
@@ -1092,7 +1120,8 @@ EXPORT_SYMBOL_GPL(xprt_free);
  * xprt_reserve - allocate an RPC request slot
  * @task: RPC task requesting a slot allocation
  *
- * If no more slots are available, place the task on the transport's
+ * If the transport is marked as being congested, or if no more
+ * slots are available, place the task on the transport's
  * backlog queue.
  */
 void xprt_reserve(struct rpc_task *task)
@@ -1107,6 +1136,32 @@ void xprt_reserve(struct rpc_task *task)
 	task->tk_status = -EAGAIN;
 	rcu_read_lock();
 	xprt = rcu_dereference(task->tk_client->cl_xprt);
+	if (!xprt_throttle_congested(xprt, task))
+		xprt->ops->alloc_slot(xprt, task);
+	rcu_read_unlock();
+}
+
+/**
+ * xprt_retry_reserve - allocate an RPC request slot
+ * @task: RPC task requesting a slot allocation
+ *
+ * If no more slots are available, place the task on the transport's
+ * backlog queue.
+ * Note that the only difference with xprt_reserve is that we now
+ * ignore the value of the XPRT_CONGESTED flag.
+ */
+void xprt_retry_reserve(struct rpc_task *task)
+{
+	struct rpc_xprt	*xprt;
+
+	task->tk_status = 0;
+	if (task->tk_rqstp != NULL)
+		return;
+
+	task->tk_timeout = 0;
+	task->tk_status = -EAGAIN;
+	rcu_read_lock();
+	xprt = rcu_dereference(task->tk_client->cl_xprt);
 	xprt->ops->alloc_slot(xprt, task);
 	rcu_read_unlock();
 }
-- 
1.8.1.4


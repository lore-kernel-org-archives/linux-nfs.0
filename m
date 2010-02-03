From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 6/6] RPC: adjust timeout for connect, bind, restablish so that they sensitive to the major time out value
Date: Tue,  2 Feb 2010 16:06:16 -0800
Message-ID: <1265155576-7618-7-git-send-email-batsakis@netapp.com>
References: <1265155576-7618-1-git-send-email-batsakis@netapp.com>
 <1265155576-7618-2-git-send-email-batsakis@netapp.com>
 <1265155576-7618-3-git-send-email-batsakis@netapp.com>
 <1265155576-7618-4-git-send-email-batsakis@netapp.com>
 <1265155576-7618-5-git-send-email-batsakis@netapp.com>
 <1265155576-7618-6-git-send-email-batsakis@netapp.com>
Cc: trond@netapp.com, Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64043 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933340Ab0BDUdM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Feb 2010 15:33:12 -0500
In-Reply-To: <1265155576-7618-6-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 net/sunrpc/clnt.c     |    2 +-
 net/sunrpc/sunrpc.h   |    2 ++
 net/sunrpc/xprt.c     |   18 +++++++++++++++---
 net/sunrpc/xprtsock.c |   12 ++++++++++--
 4 files changed, 28 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 154034b..8e552cd 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1019,7 +1019,7 @@ call_bind(struct rpc_task *task)
 	task->tk_action = call_connect;
 	if (!xprt_bound(xprt)) {
 		task->tk_action = call_bind_status;
-		task->tk_timeout = xprt->bind_timeout;
+		xprt_set_timeout_sane(task, xprt->bind_timeout);
 		xprt->ops->rpcbind(task);
 	}
 }
diff --git a/net/sunrpc/sunrpc.h b/net/sunrpc/sunrpc.h
index 90c292e..87c7aaa 100644
--- a/net/sunrpc/sunrpc.h
+++ b/net/sunrpc/sunrpc.h
@@ -37,6 +37,8 @@ struct rpc_buffer {
 	char	data[];
 };
 
+void xprt_set_timeout_sane(struct rpc_task *task, unsigned long timeout);
+
 static inline int rpc_reply_expected(struct rpc_task *task)
 {
 	return (task->tk_msg.rpc_proc != NULL) &&
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 469de29..f6f3988 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -482,7 +482,7 @@ void xprt_wait_for_buffer_space(struct rpc_task *task, rpc_action action)
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_xprt *xprt = req->rq_xprt;
 
-	task->tk_timeout = req->rq_timeout;
+	xprt_set_timeout_sane(task, req->rq_timeout);
 	rpc_sleep_on(&xprt->pending, task, action);
 }
 EXPORT_SYMBOL_GPL(xprt_wait_for_buffer_space);
@@ -518,7 +518,7 @@ EXPORT_SYMBOL_GPL(xprt_write_space);
  */
 void xprt_set_retrans_timeout_def(struct rpc_task *task)
 {
-	task->tk_timeout = task->tk_rqstp->rq_timeout;
+	xprt_set_timeout_sane(task, task->tk_rqstp->rq_timeout);
 }
 EXPORT_SYMBOL_GPL(xprt_set_retrans_timeout_def);
 
@@ -682,6 +682,18 @@ out_abort:
 	spin_unlock(&xprt->transport_lock);
 }
 
+void xprt_set_timeout_sane(struct rpc_task *task, unsigned long timeout)
+{
+	unsigned long majorto = task->tk_rqstp->rq_majortimeo;
+
+	if (majorto <= jiffies)
+		task->tk_timeout = 5 * HZ;
+	else if (timeout > majorto - jiffies)
+		task->tk_timeout = 2 * (majorto - jiffies) / 3;
+	else
+		task->tk_timeout = timeout;
+}
+
 /**
  * xprt_connect - schedule a transport connect operation
  * @task: RPC task that is requesting the connect
@@ -710,7 +722,7 @@ void xprt_connect(struct rpc_task *task)
 		if (task->tk_rqstp)
 			task->tk_rqstp->rq_bytes_sent = 0;
 
-		task->tk_timeout = xprt->connect_timeout;
+		xprt_set_timeout_sane(task, xprt->connect_timeout);
 		rpc_sleep_on(&xprt->pending, task, xprt_connect_status);
 		xprt->stat.connect_start = jiffies;
 		xprt->ops->connect(task);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 721bafd..7fcc97f 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2020,9 +2020,17 @@ static void xs_connect(struct rpc_task *task)
 		return;
 
 	if (transport->sock != NULL && !RPC_IS_SOFTCONN(task)) {
+		unsigned long majorto = task->tk_rqstp->rq_majortimeo;
+
+		if (majorto <= jiffies)
+			xprt->reestablish_timeout = 5 * HZ;
+		else if (xprt->reestablish_timeout > majorto - jiffies)
+			xprt->reestablish_timeout = 2 * (majorto - jiffies)
+			  / 3;
+
 		dprintk("RPC:       xs_connect delayed xprt %p for %lu "
-				"seconds\n",
-				xprt, xprt->reestablish_timeout / HZ);
+			"seconds\n",
+			xprt, xprt->reestablish_timeout + (HZ - 1) / HZ);
 		queue_delayed_work(rpciod_workqueue,
 				   &transport->connect_worker,
 				   xprt->reestablish_timeout);
-- 
1.6.2.5


From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] SUNRPC: Cleanup - make rpc_new_task() call rpc_release_calldata on failure
Date: Fri, 16 Apr 2010 16:47:47 -0400
Message-ID: <1271450871-10777-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1271450871-10777-1-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54877 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932522Ab0DPUrw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:47:52 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKlp8w008034
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:47:52 -0700 (PDT)
In-Reply-To: <1271450871-10777-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also have it return an ERR_PTR(-ENOMEM) instead of a null pointer.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/clnt.c  |   19 ++++---------------
 net/sunrpc/sched.c |   13 ++++++++++---
 2 files changed, 14 insertions(+), 18 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 19c9983..8c7b543 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -556,26 +556,16 @@ static const struct rpc_call_ops rpc_default_ops = {
  */
 struct rpc_task *rpc_run_task(const struct rpc_task_setup *task_setup_data)
 {
-	struct rpc_task *task, *ret;
+	struct rpc_task *task;
 
 	task = rpc_new_task(task_setup_data);
-	if (task == NULL) {
-		rpc_release_calldata(task_setup_data->callback_ops,
-				task_setup_data->callback_data);
-		ret = ERR_PTR(-ENOMEM);
+	if (IS_ERR(task))
 		goto out;
-	}
 
-	if (task->tk_status != 0) {
-		ret = ERR_PTR(task->tk_status);
-		rpc_put_task(task);
-		goto out;
-	}
 	atomic_inc(&task->tk_count);
 	rpc_execute(task);
-	ret = task;
 out:
-	return ret;
+	return task;
 }
 EXPORT_SYMBOL_GPL(rpc_run_task);
 
@@ -657,9 +647,8 @@ struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req,
 	 * Create an rpc_task to send the data
 	 */
 	task = rpc_new_task(&task_setup_data);
-	if (!task) {
+	if (IS_ERR(task)) {
 		xprt_free_bc_request(req);
-		task = ERR_PTR(-ENOMEM);
 		goto out;
 	}
 	task->tk_rqstp = req;
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index aae6907..c8979ce 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -856,16 +856,23 @@ struct rpc_task *rpc_new_task(const struct rpc_task_setup *setup_data)
 
 	if (task == NULL) {
 		task = rpc_alloc_task();
-		if (task == NULL)
-			goto out;
+		if (task == NULL) {
+			rpc_release_calldata(setup_data->callback_ops,
+					setup_data->callback_data);
+			return ERR_PTR(-ENOMEM);
+		}
 		flags = RPC_TASK_DYNAMIC;
 	}
 
 	rpc_init_task(task, setup_data);
+	if (task->tk_status < 0) {
+		int err = task->tk_status;
+		rpc_put_task(task);
+		return ERR_PTR(err);
+	}
 
 	task->tk_flags |= flags;
 	dprintk("RPC:       allocated task %p\n", task);
-out:
 	return task;
 }
 
-- 
1.6.6.1


From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/9] SUNRPC: Tighten up the task locking rules in
 __rpc_execute()
Date: Wed, 11 Mar 2009 14:25:25 -0400
Message-ID: <20090311182525.403.75005.stgit@heimdal.trondhjem.org>
References: <20090311182525.403.42026.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20542 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754877AbZCKS3x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:29:53 -0400
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIThdr008167
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:29:51 -0700 (PDT)
In-Reply-To: <20090311182525.403.42026.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We should probably not be testing any flags after we've cleared the
RPC_TASK_RUNNING flag, since rpc_make_runnable() is then free to assign the
rpc_task to another workqueue, which may then destroy it.

We can fix any races with rpc_make_runnable() by ensuring that we only
clear the RPC_TASK_RUNNING flag while holding the rpc_wait_queue->lock that
the task is supposed to be sleeping on (and then checking whether or not
the task really is sleeping).

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/sched.c |   33 ++++++++++++++++++++-------------
 1 files changed, 20 insertions(+), 13 deletions(-)


diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 385f427..ff50a05 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -293,11 +293,6 @@ static void rpc_make_runnable(struct rpc_task *task)
 	rpc_clear_queued(task);
 	if (rpc_test_and_set_running(task))
 		return;
-	/* We might have raced */
-	if (RPC_IS_QUEUED(task)) {
-		rpc_clear_running(task);
-		return;
-	}
 	if (RPC_IS_ASYNC(task)) {
 		int status;
 
@@ -607,7 +602,9 @@ void rpc_release_calldata(const struct rpc_call_ops *ops, void *calldata)
  */
 static void __rpc_execute(struct rpc_task *task)
 {
-	int		status = 0;
+	struct rpc_wait_queue *queue;
+	int task_is_async = RPC_IS_ASYNC(task);
+	int status = 0;
 
 	dprintk("RPC: %5u __rpc_execute flags=0x%x\n",
 			task->tk_pid, task->tk_flags);
@@ -647,15 +644,25 @@ static void __rpc_execute(struct rpc_task *task)
 		 */
 		if (!RPC_IS_QUEUED(task))
 			continue;
-		rpc_clear_running(task);
-		if (RPC_IS_ASYNC(task)) {
-			/* Careful! we may have raced... */
-			if (RPC_IS_QUEUED(task))
-				return;
-			if (rpc_test_and_set_running(task))
-				return;
+		/*
+		 * The queue->lock protects against races with
+		 * rpc_make_runnable().
+		 *
+		 * Note that once we clear RPC_TASK_RUNNING on an asynchronous
+		 * rpc_task, rpc_make_runnable() can assign it to a
+		 * different workqueue. We therefore cannot assume that the
+		 * rpc_task pointer may still be dereferenced.
+		 */
+		queue = task->tk_waitqueue;
+		spin_lock_bh(&queue->lock);
+		if (!RPC_IS_QUEUED(task)) {
+			spin_unlock_bh(&queue->lock);
 			continue;
 		}
+		rpc_clear_running(task);
+		spin_unlock_bh(&queue->lock);
+		if (task_is_async)
+			return;
 
 		/* sync task: sleep here */
 		dprintk("RPC: %5u sync task going to sleep\n", task->tk_pid);


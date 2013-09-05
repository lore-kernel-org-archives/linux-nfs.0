Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:43487 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761976Ab3IEC7B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Sep 2013 22:59:01 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/3] SUNRPC: Ensure that task->tk_pid is unique...
Date: Wed, 4 Sep 2013 22:58:38 -0400
Message-ID: <1378349920-31206-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace the task->tk_pid with a guaranteed unique parameter.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/sched.h |  3 ++-
 net/sunrpc/sched.c           | 57 +++++++++++++++++++++++++++++++++++++-------
 2 files changed, 51 insertions(+), 9 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 8ebb7c0..6e8657c 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -80,7 +80,7 @@ struct rpc_task {
 	unsigned short		tk_timeouts;	/* maj timeouts */
 
 #if defined(RPC_DEBUG) || defined(RPC_TRACEPOINTS)
-	unsigned short		tk_pid;		/* debugging aid */
+	unsigned int		tk_pid;		/* debugging aid */
 #endif
 	unsigned char		tk_priority : 2,/* Task priority */
 				tk_garb_retry : 2,
@@ -133,6 +133,7 @@ struct rpc_task_setup {
 #define RPC_TASK_RUNNING	0
 #define RPC_TASK_QUEUED		1
 #define RPC_TASK_ACTIVE		2
+#define RPC_TASK_PID		3
 
 #define RPC_IS_RUNNING(t)	test_bit(RPC_TASK_RUNNING, &(t)->tk_runstate)
 #define rpc_set_running(t)	set_bit(RPC_TASK_RUNNING, &(t)->tk_runstate)
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index ff3cc4b..fd15110 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -259,24 +259,55 @@ static int rpc_wait_bit_killable(void *word)
 }
 
 #if defined(RPC_DEBUG) || defined(RPC_TRACEPOINTS)
-static void rpc_task_set_debuginfo(struct rpc_task *task)
+static DEFINE_IDA(rpc_pids);
+
+static int rpc_task_alloc_pid(struct rpc_task *task)
 {
-	static atomic_t rpc_pid;
+	int pid;
+
+	pid = ida_simple_get(&rpc_pids, 0, 0, GFP_NOFS);
+	if (pid < 0)
+		return pid;
+	task->tk_pid = pid;
+	set_bit(RPC_TASK_PID, &task->tk_runstate);
+	return 0;
+}
 
-	task->tk_pid = atomic_inc_return(&rpc_pid);
+static bool rpc_task_need_free_pid(struct rpc_task *task)
+{
+	return test_and_clear_bit(RPC_TASK_PID, &task->tk_runstate) != 0;
+}
+
+static void rpc_task_free_pid(int pid)
+{
+	ida_simple_remove(&rpc_pids, pid);
 }
 #else
-static inline void rpc_task_set_debuginfo(struct rpc_task *task)
+static int rpc_task_alloc_pid(struct rpc_task *task)
+{
+	return 0;
+}
+
+static bool rpc_task_need_free_pid(struct rpc_task *task)
+{
+	return false;
+}
+
+static void rpc_task_free_pid(int pid)
 {
 }
 #endif
 
-static void rpc_set_active(struct rpc_task *task)
+static int rpc_set_active(struct rpc_task *task)
 {
-	trace_rpc_task_begin(task->tk_client, task, NULL);
+	int ret;
 
-	rpc_task_set_debuginfo(task);
+	ret = rpc_task_alloc_pid(task);
+	if (ret < 0)
+		return ret;
+	trace_rpc_task_begin(task->tk_client, task, NULL);
 	set_bit(RPC_TASK_ACTIVE, &task->tk_runstate);
+	return 0;
 }
 
 /*
@@ -811,8 +842,14 @@ static void __rpc_execute(struct rpc_task *task)
 void rpc_execute(struct rpc_task *task)
 {
 	bool is_async = RPC_IS_ASYNC(task);
+	int ret;
 
-	rpc_set_active(task);
+	ret = rpc_set_active(task);
+	if (ret < 0) {
+		task->tk_status = ret;
+		rpc_release_task(task);
+		return;
+	}
 	rpc_make_runnable(task);
 	if (!is_async)
 		__rpc_execute(task);
@@ -970,6 +1007,8 @@ struct rpc_task *rpc_new_task(const struct rpc_task_setup *setup_data)
 static void rpc_free_task(struct rpc_task *task)
 {
 	unsigned short tk_flags = task->tk_flags;
+	bool free_pid = rpc_task_need_free_pid(task);
+	int pid = task->tk_pid;
 
 	rpc_release_calldata(task->tk_ops, task->tk_calldata);
 
@@ -977,6 +1016,8 @@ static void rpc_free_task(struct rpc_task *task)
 		dprintk("RPC: %5u freeing task\n", task->tk_pid);
 		mempool_free(task, rpc_task_mempool);
 	}
+	if (free_pid)
+		rpc_task_free_pid(pid);
 }
 
 static void rpc_async_release(struct work_struct *work)
-- 
1.8.3.1


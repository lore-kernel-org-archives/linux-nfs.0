Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:62166 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753631Ab3ADSPK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jan 2013 13:15:10 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Weston Andros Adamson <dros@netapp.com>, Tejun Heo <tj@kernel.org>,
        Bruce Fields <bfields@fieldses.org>
Subject: [PATCH 1/3] SUNRPC: Ensure that we free the rpc_task after cleanups are done
Date: Fri,  4 Jan 2013 13:15:00 -0500
Message-Id: <1357323302-12944-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <0EC8763B847DB24D9ADF5EBD9CD7B419125A16A9@SACEXCMBX02-PRD.hq.netapp.com>
References: <0EC8763B847DB24D9ADF5EBD9CD7B419125A16A9@SACEXCMBX02-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch ensures that we free the rpc_task after the cleanup callbacks
are done in order to avoid a deadlock problem that can be triggered if
the callback needs to wait for another workqueue item to complete.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Weston Andros Adamson <dros@netapp.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Bruce Fields <bfields@fieldses.org>
Cc: stable@vger.kernel.org
---
 net/sunrpc/sched.c | 27 +++++++++++++++++++++++----
 1 file changed, 23 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index d17a704..b4133bd 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -934,16 +934,35 @@ struct rpc_task *rpc_new_task(const struct rpc_task_setup *setup_data)
 	return task;
 }
 
+/*
+ * rpc_free_task - release rpc task and perform cleanups
+ *
+ * Note that we free up the rpc_task _after_ rpc_release_calldata()
+ * in order to work around a workqueue dependency issue.
+ *
+ * Tejun Heo states:
+ * "Workqueue currently considers two work items to be the same if they're
+ * on the same address and won't execute them concurrently - ie. it
+ * makes a work item which is queued again while being executed wait
+ * for the previous execution to complete.
+ *
+ * If a work function frees the work item, and then waits for an event
+ * which should be performed by another work item and *that* work item
+ * recycles the freed work item, it can create a false dependency loop.
+ * There really is no reliable way to detect this short of verifying
+ * every memory free."
+ *
+ */
 static void rpc_free_task(struct rpc_task *task)
 {
-	const struct rpc_call_ops *tk_ops = task->tk_ops;
-	void *calldata = task->tk_calldata;
+	unsigned short tk_flags = task->tk_flags;
+
+	rpc_release_calldata(task->tk_ops, task->tk_calldata);
 
-	if (task->tk_flags & RPC_TASK_DYNAMIC) {
+	if (tk_flags & RPC_TASK_DYNAMIC) {
 		dprintk("RPC: %5u freeing task\n", task->tk_pid);
 		mempool_free(task, rpc_task_mempool);
 	}
-	rpc_release_calldata(tk_ops, calldata);
 }
 
 static void rpc_async_release(struct work_struct *work)
-- 
1.7.11.7


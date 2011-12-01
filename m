Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:33942 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756171Ab1LATUh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Dec 2011 14:20:37 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] SUNRPC: Fix the execution time statistics in the face of RPC restarts
Date: Thu,  1 Dec 2011 14:20:16 -0500
Message-Id: <1322767217-11539-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the rpc_task gets restarted, then we want to ensure that we don't
double-count the execution time statistics, timeout data, etc.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/sched.c |   30 +++++++++++++++++++++++-------
 1 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index d12ffa5..00a1a2a 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -590,6 +590,27 @@ void rpc_prepare_task(struct rpc_task *task)
 	task->tk_ops->rpc_call_prepare(task, task->tk_calldata);
 }
 
+static void
+rpc_init_task_statistics(struct rpc_task *task)
+{
+	/* Initialize retry counters */
+	task->tk_garb_retry = 2;
+	task->tk_cred_retry = 2;
+	task->tk_rebind_retry = 2;
+
+	/* starting timestamp */
+	task->tk_start = ktime_get();
+}
+
+static void
+rpc_reset_task_statistics(struct rpc_task *task)
+{
+	task->tk_timeouts = 0;
+	task->tk_flags &= ~(RPC_CALL_MAJORSEEN|RPC_TASK_KILLED|RPC_TASK_SENT);
+
+	rpc_init_task_statistics(task);
+}
+
 /*
  * Helper that calls task->tk_ops->rpc_call_done if it exists
  */
@@ -602,6 +623,7 @@ void rpc_exit_task(struct rpc_task *task)
 			WARN_ON(RPC_ASSASSINATED(task));
 			/* Always release the RPC slot and buffer memory */
 			xprt_release(task);
+			rpc_reset_task_statistics(task);
 		}
 	}
 }
@@ -804,11 +826,6 @@ static void rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *ta
 	task->tk_calldata = task_setup_data->callback_data;
 	INIT_LIST_HEAD(&task->tk_task);
 
-	/* Initialize retry counters */
-	task->tk_garb_retry = 2;
-	task->tk_cred_retry = 2;
-	task->tk_rebind_retry = 2;
-
 	task->tk_priority = task_setup_data->priority - RPC_PRIORITY_LOW;
 	task->tk_owner = current->tgid;
 
@@ -818,8 +835,7 @@ static void rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *ta
 	if (task->tk_ops->rpc_call_prepare != NULL)
 		task->tk_action = rpc_prepare_task;
 
-	/* starting timestamp */
-	task->tk_start = ktime_get();
+	rpc_init_task_statistics(task);
 
 	dprintk("RPC:       new task initialized, procpid %u\n",
 				task_pid_nr(current));
-- 
1.7.7.3


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3250 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753631Ab0EMVIa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 May 2010 17:08:30 -0400
Received: from localhost.localdomain (heimdal.trondhjem.org [10.58.49.73] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4DL8MCW021257
	for <linux-nfs@vger.kernel.org>; Thu, 13 May 2010 14:08:29 -0700 (PDT)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 13/15] SUNRPC: Remove the 'tk_magic' debugging field
Date: Thu, 13 May 2010 17:08:19 -0400
Message-Id: <1273784901-25599-13-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1273784901-25599-12-git-send-email-Trond.Myklebust@netapp.com>
References: <1273784901-25599-1-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-2-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-3-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-4-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-5-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-6-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-7-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-8-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-9-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-10-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-11-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-12-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

It has not triggered in almost a decade. Time to get rid of it...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/sched.h |    3 ---
 net/sunrpc/sched.c           |   11 -----------
 2 files changed, 0 insertions(+), 14 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 46ebef1..41b9f97 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -41,9 +41,6 @@ struct rpc_wait {
  * This is the RPC task struct
  */
 struct rpc_task {
-#ifdef RPC_DEBUG
-	unsigned long		tk_magic;	/* 0xf00baa */
-#endif
 	atomic_t		tk_count;	/* Reference count */
 	struct list_head	tk_task;	/* global list of tasks */
 	struct rpc_clnt *	tk_client;	/* RPC client */
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index aa7b07e..4a843b8 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -25,7 +25,6 @@
 
 #ifdef RPC_DEBUG
 #define RPCDBG_FACILITY		RPCDBG_SCHED
-#define RPC_TASK_MAGIC_ID	0xf00baa
 #endif
 
 /*
@@ -237,7 +236,6 @@ static void rpc_task_set_debuginfo(struct rpc_task *task)
 {
 	static atomic_t rpc_pid;
 
-	task->tk_magic = RPC_TASK_MAGIC_ID;
 	task->tk_pid = atomic_inc_return(&rpc_pid);
 }
 #else
@@ -360,9 +358,6 @@ static void __rpc_do_wake_up_task(struct rpc_wait_queue *queue, struct rpc_task
 	dprintk("RPC: %5u __rpc_wake_up_task (now %lu)\n",
 			task->tk_pid, jiffies);
 
-#ifdef RPC_DEBUG
-	BUG_ON(task->tk_magic != RPC_TASK_MAGIC_ID);
-#endif
 	/* Has the task been executed yet? If not, we cannot wake it up! */
 	if (!RPC_IS_ACTIVATED(task)) {
 		printk(KERN_ERR "RPC: Inactive task (%p) being woken up!\n", task);
@@ -916,9 +911,6 @@ EXPORT_SYMBOL_GPL(rpc_put_task);
 
 static void rpc_release_task(struct rpc_task *task)
 {
-#ifdef RPC_DEBUG
-	BUG_ON(task->tk_magic != RPC_TASK_MAGIC_ID);
-#endif
 	dprintk("RPC: %5u release task\n", task->tk_pid);
 
 	if (!list_empty(&task->tk_task)) {
@@ -930,9 +922,6 @@ static void rpc_release_task(struct rpc_task *task)
 	}
 	BUG_ON (RPC_IS_QUEUED(task));
 
-#ifdef RPC_DEBUG
-	task->tk_magic = 0;
-#endif
 	/* Wake up anyone who is waiting for task completion */
 	rpc_mark_complete_task(task);
 
-- 
1.6.6.1


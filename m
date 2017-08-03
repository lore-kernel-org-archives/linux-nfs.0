Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:37655 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751963AbdHCNqH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 09:46:07 -0400
Received: by mail-it0-f68.google.com with SMTP id 77so1307935itj.4
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 06:46:07 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 27/28] SUNRPC: Add a function to allow waiting for RPC transmission
Date: Thu,  3 Aug 2017 09:45:22 -0400
Message-Id: <20170803134523.4922-28-trond.myklebust@primarydata.com>
In-Reply-To: <20170803134523.4922-27-trond.myklebust@primarydata.com>
References: <20170803134523.4922-1-trond.myklebust@primarydata.com>
 <20170803134523.4922-2-trond.myklebust@primarydata.com>
 <20170803134523.4922-3-trond.myklebust@primarydata.com>
 <20170803134523.4922-4-trond.myklebust@primarydata.com>
 <20170803134523.4922-5-trond.myklebust@primarydata.com>
 <20170803134523.4922-6-trond.myklebust@primarydata.com>
 <20170803134523.4922-7-trond.myklebust@primarydata.com>
 <20170803134523.4922-8-trond.myklebust@primarydata.com>
 <20170803134523.4922-9-trond.myklebust@primarydata.com>
 <20170803134523.4922-10-trond.myklebust@primarydata.com>
 <20170803134523.4922-11-trond.myklebust@primarydata.com>
 <20170803134523.4922-12-trond.myklebust@primarydata.com>
 <20170803134523.4922-13-trond.myklebust@primarydata.com>
 <20170803134523.4922-14-trond.myklebust@primarydata.com>
 <20170803134523.4922-15-trond.myklebust@primarydata.com>
 <20170803134523.4922-16-trond.myklebust@primarydata.com>
 <20170803134523.4922-17-trond.myklebust@primarydata.com>
 <20170803134523.4922-18-trond.myklebust@primarydata.com>
 <20170803134523.4922-19-trond.myklebust@primarydata.com>
 <20170803134523.4922-20-trond.myklebust@primarydata.com>
 <20170803134523.4922-21-trond.myklebust@primarydata.com>
 <20170803134523.4922-22-trond.myklebust@primarydata.com>
 <20170803134523.4922-23-trond.myklebust@primarydata.com>
 <20170803134523.4922-24-trond.myklebust@primarydata.com>
 <20170803134523.4922-25-trond.myklebust@primarydata.com>
 <20170803134523.4922-26-trond.myklebust@primarydata.com>
 <20170803134523.4922-27-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sometimes, we only want to know that the RPC message is in the process
of being transmitted. Add a function to allow that.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/sched.h |  3 +++
 net/sunrpc/sched.c           | 22 ++++++++++++++++++++++
 net/sunrpc/xprt.c            |  6 ++++++
 3 files changed, 31 insertions(+)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 50a99a117da7..15bc1cd6ee5c 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -139,6 +139,8 @@ struct rpc_task_setup {
 #define RPC_TASK_RUNNING	0
 #define RPC_TASK_QUEUED		1
 #define RPC_TASK_ACTIVE		2
+#define RPC_TASK_MSG_XMIT	3
+#define RPC_TASK_MSG_XMIT_WAIT	4
 
 #define RPC_IS_RUNNING(t)	test_bit(RPC_TASK_RUNNING, &(t)->tk_runstate)
 #define rpc_set_running(t)	set_bit(RPC_TASK_RUNNING, &(t)->tk_runstate)
@@ -244,6 +246,7 @@ void		rpc_free(struct rpc_task *);
 int		rpciod_up(void);
 void		rpciod_down(void);
 int		__rpc_wait_for_completion_task(struct rpc_task *task, wait_bit_action_f *);
+int		rpc_wait_for_msg_send(struct rpc_task *task);
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 struct net;
 void		rpc_show_tasks(struct net *);
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 0cc83839c13c..30509a4d7e00 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -320,6 +320,19 @@ int __rpc_wait_for_completion_task(struct rpc_task *task, wait_bit_action_f *act
 EXPORT_SYMBOL_GPL(__rpc_wait_for_completion_task);
 
 /*
+ * Allow callers to wait for completion of an RPC call
+ */
+int rpc_wait_for_msg_send(struct rpc_task *task)
+{
+	if (!test_bit(RPC_TASK_MSG_XMIT, &task->tk_runstate))
+		return 0;
+	set_bit(RPC_TASK_MSG_XMIT_WAIT, &task->tk_runstate);
+	return wait_on_bit_action(&task->tk_runstate, RPC_TASK_MSG_XMIT,
+			rpc_wait_bit_killable, TASK_KILLABLE);
+}
+EXPORT_SYMBOL_GPL(rpc_wait_for_msg_send);
+
+/*
  * Make an RPC task runnable.
  *
  * Note: If the task is ASYNC, and is being made runnable after sitting on an
@@ -700,6 +713,7 @@ rpc_reset_task_statistics(struct rpc_task *task)
 {
 	task->tk_timeouts = 0;
 	task->tk_flags &= ~(RPC_CALL_MAJORSEEN|RPC_TASK_KILLED|RPC_TASK_SENT);
+	set_bit(RPC_TASK_MSG_XMIT, &task->tk_runstate);
 
 	rpc_init_task_statistics(task);
 }
@@ -928,6 +942,7 @@ static void rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *ta
 	memset(task, 0, sizeof(*task));
 	atomic_set(&task->tk_count, 1);
 	task->tk_flags  = task_setup_data->flags;
+	task->tk_runstate = BIT(RPC_TASK_MSG_XMIT);
 	task->tk_ops = task_setup_data->callback_ops;
 	task->tk_calldata = task_setup_data->callback_data;
 	INIT_LIST_HEAD(&task->tk_task);
@@ -1012,6 +1027,13 @@ static void rpc_async_release(struct work_struct *work)
 
 static void rpc_release_resources_task(struct rpc_task *task)
 {
+	if (test_bit(RPC_TASK_MSG_XMIT, &task->tk_runstate)) {
+		clear_bit(RPC_TASK_MSG_XMIT, &task->tk_runstate);
+		smp_mb__after_atomic();
+		if (test_bit(RPC_TASK_MSG_XMIT_WAIT, &task->tk_runstate))
+			wake_up_bit(&task->tk_runstate, RPC_TASK_MSG_XMIT);
+	}
+
 	xprt_release(task);
 	if (task->tk_msg.rpc_cred) {
 		put_rpccred(task->tk_msg.rpc_cred);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 4654a9934269..788c1b6138c2 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -937,6 +937,12 @@ bool xprt_prepare_transmit(struct rpc_task *task)
 		goto out_unlock;
 	}
 	ret = true;
+	if (test_bit(RPC_TASK_MSG_XMIT, &task->tk_runstate)) {
+		clear_bit(RPC_TASK_MSG_XMIT, &task->tk_runstate);
+		smp_mb__after_atomic();
+		if (test_bit(RPC_TASK_MSG_XMIT_WAIT, &task->tk_runstate))
+			wake_up_bit(&task->tk_runstate, RPC_TASK_MSG_XMIT);
+	}
 out_unlock:
 	spin_unlock_bh(&xprt->transport_lock);
 	return ret;
-- 
2.13.3


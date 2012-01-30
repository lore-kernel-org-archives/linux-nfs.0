Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e38.co.us.ibm.com ([32.97.110.159]:33183 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752299Ab2A3TaR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jan 2012 14:30:17 -0500
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 30 Jan 2012 12:30:16 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 8AD7D19D804C
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:30:09 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0UJU07j046860
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:30:01 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0UJTuYk020196
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:29:56 -0700
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q0UJTuZV020137
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:29:56 -0700
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 01/13] SUNRPC: Allow temporary blocking of an rpc client
Date: Mon, 30 Jan 2012 13:29:43 -0600
Message-Id: <1327951795-16400-2-git-send-email-malahal@us.ibm.com>
In-Reply-To: <1327951795-16400-1-git-send-email-malahal@us.ibm.com>
References: <1327951795-16400-1-git-send-email-malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Add a mechanism to allow us to temporarily block an rpc client while
we do surgery on its transport and authentication code.

The new function rpc_lock_client() will block all new rpc calls from
starting, and then wait for existing rpc calls to complete. If the
wait times out before the rpc calls have completed, then the function
returns the number of outstanding active tasks, otherwise it returns 0.

In the event of a non-zero return value, it is up to the caller either
to cancel the lock (by calling rpc_unlock_client), or to take the
appropriate action to ensure the existing rpc calls complete (e.g.
by calling rpc_killall_tasks()).

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/clnt.h |   11 ++++++
 net/sunrpc/clnt.c           |   72 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 83 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 2c5993a..c85696e 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -24,6 +24,7 @@
 #include <asm/signal.h>
 #include <linux/path.h>
 #include <net/ipv6.h>
+#include <linux/completion.h>
 
 struct rpc_inode;
 
@@ -32,6 +33,7 @@ struct rpc_inode;
  */
 struct rpc_clnt {
 	atomic_t		cl_count;	/* Number of references */
+	atomic_t		cl_active_tasks;/* Number of active tasks */
 	struct list_head	cl_clients;	/* Global list of clients */
 	struct list_head	cl_tasks;	/* List of tasks */
 	spinlock_t		cl_lock;	/* spinlock */
@@ -47,6 +49,10 @@ struct rpc_clnt {
 	struct rpc_stat *	cl_stats;	/* per-program statistics */
 	struct rpc_iostats *	cl_metrics;	/* per-client statistics */
 
+	unsigned long		cl_flags;	/* Bit flags */
+	struct rpc_wait_queue	cl_waitqueue;
+	struct completion	cl_completion;
+
 	unsigned int		cl_softrtry : 1,/* soft timeouts */
 				cl_discrtry : 1,/* disconnect before retry */
 				cl_autobind : 1,/* use getport() */
@@ -66,6 +72,8 @@ struct rpc_clnt {
 	char			*cl_principal;	/* target to authenticate to */
 };
 
+#define RPC_CLIENT_LOCKED	0
+
 /*
  * General RPC program info
  */
@@ -136,6 +144,9 @@ void		rpc_shutdown_client(struct rpc_clnt *);
 void		rpc_release_client(struct rpc_clnt *);
 void		rpc_task_release_client(struct rpc_task *);
 
+int		rpc_lock_client(struct rpc_clnt *clnt, unsigned long timeout);
+void		rpc_unlock_client(struct rpc_clnt *clnt);
+
 int		rpcb_create_local(void);
 void		rpcb_put_local(void);
 int		rpcb_register(u32, u32, int, unsigned short);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index f0268ea..b6a7817 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -225,6 +225,8 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 
 	atomic_set(&clnt->cl_count, 1);
 
+	rpc_init_wait_queue(&clnt->cl_waitqueue, "client waitqueue");
+
 	err = rpc_setup_pipedir(clnt, program->pipe_dir_name);
 	if (err < 0)
 		goto out_no_path;
@@ -394,6 +396,8 @@ rpc_clone_client(struct rpc_clnt *clnt)
 			goto out_no_principal;
 	}
 	atomic_set(&new->cl_count, 1);
+	atomic_set(&new->cl_active_tasks, 0);
+	rpc_init_wait_queue(&new->cl_waitqueue, "client waitqueue");
 	err = rpc_setup_pipedir(new, clnt->cl_program->pipe_dir_name);
 	if (err != 0)
 		goto out_no_path;
@@ -570,11 +574,76 @@ out:
 }
 EXPORT_SYMBOL_GPL(rpc_bind_new_program);
 
+/**
+ * rpc_lock_client - lock the RPC client
+ * @clnt: pointer to a struct rpc_clnt
+ * @timeout: timeout parameter to pass to wait_for_completion_timeout()
+ *
+ * This function sets the RPC_CLIENT_LOCKED flag, which causes
+ * all new rpc_tasks to wait instead of executing. It then waits for
+ * any existing active tasks to complete.
+ */
+int rpc_lock_client(struct rpc_clnt *clnt, unsigned long timeout)
+{
+	if (!test_and_set_bit(RPC_CLIENT_LOCKED, &clnt->cl_flags))
+		init_completion(&clnt->cl_completion);
+
+	if (atomic_read(&clnt->cl_active_tasks) &&
+	    !wait_for_completion_timeout(&clnt->cl_completion, timeout))
+		return -ETIMEDOUT;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(rpc_lock_client);
+
+/**
+ * rpc_unlock_client
+ * @clnt: pointer to a struct rpc_clnt
+ *
+ * Clears the RPC_CLIENT_LOCKED flag, and starts any rpc_tasks that
+ * were waiting on it.
+ */
+void rpc_unlock_client(struct rpc_clnt *clnt)
+{
+	spin_lock(&clnt->cl_lock);
+	clear_bit(RPC_CLIENT_LOCKED, &clnt->cl_flags);
+	spin_unlock(&clnt->cl_lock);
+	rpc_wake_up(&clnt->cl_waitqueue);
+}
+EXPORT_SYMBOL_GPL(rpc_unlock_client);
+
+static void rpc_task_clear_active(struct rpc_task *task)
+{
+	struct rpc_clnt *clnt = task->tk_client;
+
+	if (atomic_dec_and_test(&clnt->cl_active_tasks) &&
+	    test_bit(RPC_CLIENT_LOCKED, &clnt->cl_flags))
+		complete(&clnt->cl_completion);
+}
+
+static void rpc_task_set_active(struct rpc_task *task)
+{
+	struct rpc_clnt *clnt = task->tk_client;
+
+	atomic_inc(&clnt->cl_active_tasks);
+	if (unlikely(test_bit(RPC_CLIENT_LOCKED, &clnt->cl_flags))) {
+		spin_lock(&clnt->cl_lock);
+		if (test_bit(RPC_CLIENT_LOCKED, &clnt->cl_flags) &&
+				!RPC_ASSASSINATED(task)) {
+			rpc_sleep_on(&clnt->cl_waitqueue, task,
+					rpc_task_set_active);
+			rpc_task_clear_active(task);
+		}
+		spin_unlock(&clnt->cl_lock);
+	}
+}
+
 void rpc_task_release_client(struct rpc_task *task)
 {
 	struct rpc_clnt *clnt = task->tk_client;
 
 	if (clnt != NULL) {
+		rpc_task_clear_active(task);
 		/* Remove from client task list */
 		spin_lock(&clnt->cl_lock);
 		list_del(&task->tk_task);
@@ -598,6 +667,9 @@ void rpc_task_set_client(struct rpc_task *task, struct rpc_clnt *clnt)
 		spin_lock(&clnt->cl_lock);
 		list_add_tail(&task->tk_task, &clnt->cl_tasks);
 		spin_unlock(&clnt->cl_lock);
+
+		/* Notify the client when this task is activated */
+		task->tk_callback = rpc_task_set_active;
 	}
 }
 
-- 
1.7.8.3


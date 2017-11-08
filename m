Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:50359 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752603AbdKHPAT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Nov 2017 10:00:19 -0500
Received: by mail-io0-f195.google.com with SMTP id 97so6214274iok.7
        for <linux-nfs@vger.kernel.org>; Wed, 08 Nov 2017 07:00:19 -0800 (PST)
From: Joshua Watt <jpewhacker@gmail.com>
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        David Howells <dhowells@redhat.com>,
        Joshua Watt <JPEWhacker@gmail.com>
Subject: [RFC 1/4] SUNRPC: Add flag to kill new tasks
Date: Wed,  8 Nov 2017 08:59:39 -0600
Message-Id: <20171108145942.5127-2-JPEWhacker@gmail.com>
In-Reply-To: <20171108145942.5127-1-JPEWhacker@gmail.com>
References: <CAJdd5GZ-EMj8f3RaV_WUdeZs6aWbEAeC6xX8BadMD-aOFL3_jA@mail.gmail.com>
 <20171108145942.5127-1-JPEWhacker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The new flag to rpc_killall_tasks() causes new tasks that are killed
after to call to be killed immediately instead of being executed. This
will all clients (particularly NFS) to prevents these task from delaying
shutdown of the RPC session longer than necessary.

Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
---
 fs/nfs/super.c               |  4 ++--
 include/linux/sunrpc/clnt.h  |  1 +
 include/linux/sunrpc/sched.h |  2 +-
 net/sunrpc/clnt.c            | 13 ++++++++++---
 net/sunrpc/sched.c           |  7 +++++++
 5 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 216f67d628b3..66fda2dcadd0 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -903,10 +903,10 @@ void nfs_umount_begin(struct super_block *sb)
 	/* -EIO all pending I/O */
 	rpc = server->client_acl;
 	if (!IS_ERR(rpc))
-		rpc_killall_tasks(rpc);
+		rpc_killall_tasks(rpc, 0);
 	rpc = server->client;
 	if (!IS_ERR(rpc))
-		rpc_killall_tasks(rpc);
+		rpc_killall_tasks(rpc, 0);
 }
 EXPORT_SYMBOL_GPL(nfs_umount_begin);
 
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 71c237e8240e..94f4e464de1b 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -54,6 +54,7 @@ struct rpc_clnt {
 				cl_noretranstimeo: 1,/* No retransmit timeouts */
 				cl_autobind : 1,/* use getport() */
 				cl_chatty   : 1;/* be verbose */
+	bool			cl_kill_new_tasks;	/* Kill all new tasks */
 
 	struct rpc_rtt *	cl_rtt;		/* RTO estimator data */
 	const struct rpc_timeout *cl_timeout;	/* Timeout strategy */
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index d96e74e114c0..9b8bebaee0f4 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -218,7 +218,7 @@ void		rpc_put_task_async(struct rpc_task *);
 void		rpc_exit_task(struct rpc_task *);
 void		rpc_exit(struct rpc_task *, int);
 void		rpc_release_calldata(const struct rpc_call_ops *, void *);
-void		rpc_killall_tasks(struct rpc_clnt *);
+void		rpc_killall_tasks(struct rpc_clnt *clnt, int kill_new_tasks);
 void		rpc_execute(struct rpc_task *);
 void		rpc_init_priority_wait_queue(struct rpc_wait_queue *, const char *);
 void		rpc_init_wait_queue(struct rpc_wait_queue *, const char *);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index df4ecb042ebe..70005252b32f 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -814,14 +814,21 @@ EXPORT_SYMBOL_GPL(rpc_clnt_iterate_for_each_xprt);
  * Kill all tasks for the given client.
  * XXX: kill their descendants as well?
  */
-void rpc_killall_tasks(struct rpc_clnt *clnt)
+void rpc_killall_tasks(struct rpc_clnt *clnt, int kill_new_tasks)
 {
 	struct rpc_task	*rovr;
 
+	dprintk("RPC:       killing all tasks for client %p\n", clnt);
+
+	if (kill_new_tasks) {
+		WRITE_ONCE(clnt->cl_kill_new_tasks, true);
+
+		/* Ensure the kill flag is set before checking the task list */
+		smp_mb();
+	}
 
 	if (list_empty(&clnt->cl_tasks))
 		return;
-	dprintk("RPC:       killing all tasks for client %p\n", clnt);
 	/*
 	 * Spin lock all_tasks to prevent changes...
 	 */
@@ -854,7 +861,7 @@ void rpc_shutdown_client(struct rpc_clnt *clnt)
 			rcu_dereference(clnt->cl_xprt)->servername);
 
 	while (!list_empty(&clnt->cl_tasks)) {
-		rpc_killall_tasks(clnt);
+		rpc_killall_tasks(clnt, 0);
 		wait_event_timeout(destroy_wait,
 			list_empty(&clnt->cl_tasks), 1*HZ);
 	}
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 0cc83839c13c..c9bf1ab9e941 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -748,6 +748,13 @@ static void __rpc_execute(struct rpc_task *task)
 	dprintk("RPC: %5u __rpc_execute flags=0x%x\n",
 			task->tk_pid, task->tk_flags);
 
+	/* Ensure the task is in the client task list before checking the kill
+	 * flag
+	 */
+	smp_mb();
+	if (READ_ONCE(task->tk_client->cl_kill_new_tasks))
+		rpc_exit(task, -EIO);
+
 	WARN_ON_ONCE(RPC_IS_QUEUED(task));
 	if (RPC_IS_QUEUED(task))
 		return;
-- 
2.13.6


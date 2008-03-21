From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/6] SUNRPC: Display symbolic function addresses in
	rpc_show_tasks
Date: Fri, 21 Mar 2008 18:43:41 -0400
Message-ID: <20080321224341.18966.360.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]:27999 "EHLO
	flpi195.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758929AbYCUWn6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Mar 2008 18:43:58 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For each running RPC task, rpc_show_tasks displays the hex address of the
call_foo function that the task is running.  To make debugging slightly
nicer, let's display the call_foo function name instead.

Note that it was necessary to expose rpc_prepare_task to the rest of the
RPC client so that its address would be visible in the action name table.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/sched.h |    1 +
 net/sunrpc/clnt.c            |   54 ++++++++++++++++++++++++++++++++++++++----
 net/sunrpc/sched.c           |    2 +-
 3 files changed, 51 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index d1a5c8c..108342e 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -212,6 +212,7 @@ struct rpc_wait_queue {
 struct rpc_task *rpc_new_task(const struct rpc_task_setup *);
 struct rpc_task *rpc_run_task(const struct rpc_task_setup *);
 void		rpc_put_task(struct rpc_task *);
+void		rpc_prepare_task(struct rpc_task *);
 void		rpc_exit_task(struct rpc_task *);
 void		rpc_release_calldata(const struct rpc_call_ops *, void *);
 void		rpc_killall_tasks(struct rpc_clnt *);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index c8acd56..13bb0d5 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1502,10 +1502,53 @@ struct rpc_task *rpc_call_null(struct rpc_clnt *clnt, struct rpc_cred *cred, int
 EXPORT_SYMBOL_GPL(rpc_call_null);
 
 #ifdef RPC_DEBUG
+/*
+ * To make it easier to tell what action each running RPC task
+ * is executing, use a table to map the content of tk_action to
+ * a human-readable name.  This uses a little extra memory, but
+ * causes no additional run-time overhead per RPC request.
+ */
+typedef void   (*rpc_task_action)(struct rpc_task *);
+
+static struct {
+	rpc_task_action		action;
+	const char		*name;
+} rpc_action_table[] = {
+	{ rpc_prepare_task,		"prepare"		},
+	{ call_start,			"start"			},
+	{ call_reserve,			"reserve"		},
+	{ call_reserveresult,		"reserveresult"		},
+	{ call_allocate,		"allocate"		},
+	{ call_bind,			"bind"			},
+	{ call_bind_status,		"bindstatus"		},
+	{ call_connect,			"connect"		},
+	{ call_connect_status,		"connectstatus"		},
+	{ call_transmit,		"transmit"		},
+	{ call_transmit_status,		"transmitstatus"	},
+	{ call_status,			"status"		},
+	{ call_timeout,			"timeout"		},
+	{ call_decode,			"decode"		},
+	{ call_refresh,			"refresh"		},
+	{ call_refreshresult,		"refreshresult"		},
+	{ rpc_exit_task,		"exit"			},
+	{ NULL,				"null"			},
+};
+
+static const char *rpc_show_action(rpc_task_action action)
+{
+	unsigned int i;
+
+	for (i = 0; i <= ARRAY_SIZE(rpc_action_table); i++)
+		if (rpc_action_table[i].action == action)
+			return rpc_action_table[i].name;
+
+	return "unknown";
+}
+
 static void rpc_show_header(void)
 {
 	printk(KERN_INFO "-pid- flgs status -client- --rqstp- "
-		"-timeout -action- ---ops--\n");
+		"-timeout ---ops--\n");
 }
 
 static void rpc_show_task(struct rpc_clnt *clnt, struct rpc_task *task)
@@ -1519,13 +1562,14 @@ static void rpc_show_task(struct rpc_clnt *clnt, struct rpc_task *task)
 	if (RPC_IS_QUEUED(task))
 		rpc_waitq = rpc_qname(task->tk_waitqueue);
 
-	printk(KERN_INFO "%5u %04x %6d %8p %8p %8ld %8p %8p\n",
+	printk(KERN_INFO "%5u %04x %6d %8p %8p %8ld %8p\n",
 		task->tk_pid, task->tk_flags, task->tk_status,
 		clnt, task->tk_rqstp, task->tk_timeout,
-		task->tk_action, task->tk_ops);
+		task->tk_ops);
 
-	printk(KERN_INFO " prog: %s%u  proc: %s  waitq: %s\n",
-		clnt->cl_protname, clnt->cl_vers, proc, rpc_waitq);
+	printk(KERN_INFO " prog: %s%u  proc: %s  action: %s  waitq: %s\n",
+		clnt->cl_protname, clnt->cl_vers,
+		proc, rpc_show_action(task->tk_action), rpc_waitq);
 }
 
 void rpc_show_tasks(void)
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 6eab9bf..9aa9948 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -574,7 +574,7 @@ EXPORT_SYMBOL_GPL(rpc_delay);
 /*
  * Helper to call task->tk_ops->rpc_call_prepare
  */
-static void rpc_prepare_task(struct rpc_task *task)
+void rpc_prepare_task(struct rpc_task *task)
 {
 	lock_kernel();
 	task->tk_ops->rpc_call_prepare(task, task->tk_calldata);


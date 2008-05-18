From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 8/8] SUNRPC: Display symbolic function addresses in
	rpc_show_tasks
Date: Sat, 17 May 2008 22:17:05 -0400
Message-ID: <20080518021705.8366.51402.stgit@ellison.1015granger.net>
References: <20080518021241.8366.12464.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:49502 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752547AbYERCYh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 17 May 2008 22:24:37 -0400
In-Reply-To: <20080518021241.8366.12464.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For each running RPC task, rpc_show_tasks displays the hex address of the
call_foo function that the task is running.  To make debugging slightly
nicer, let's display the call_foo function name instead.

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
index ba87a0f..43ccb7d 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1510,10 +1510,53 @@ struct rpc_task *rpc_call_null(struct rpc_clnt *clnt, struct rpc_cred *cred, int
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
 
 static void rpc_show_task(const struct rpc_clnt *clnt,
@@ -1528,13 +1571,14 @@ static void rpc_show_task(const struct rpc_clnt *clnt,
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


From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 8/8] SUNRPC: Display symbolic function addresses in
	rpc_show_tasks
Date: Tue, 20 May 2008 16:30:18 -0400
Message-ID: <20080520203018.3851.21166.stgit@ellison.1015granger.net>
References: <20080520202108.3851.7464.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:62273 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759340AbYETUam (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 May 2008 16:30:42 -0400
In-Reply-To: <20080520202108.3851.7464.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For each running RPC task, rpc_show_tasks displays the hex address of the
call_foo function that the task is running.  To make debugging slightly
nicer, let's display the call_foo function name instead.

Sample output:

 -pid- flgs status -client- --rqstp- -timeout ---ops--
 27915 0001      0 ee84a460 eedf00d0    60000 f8fa677c nfs3 COMMIT act:status wq:xprt_pending
 27918 0080      0 ee84a460 eedf0000    60000 f8d527a8 nfs3 SETATTR act:status wq:xprt_pending

 -pid- flgs status -client- --rqstp- -timeout ---ops--
 60859 0001      0 ee84a460 eedf00d0        0 f8fa66c8 nfs3 READ act:status
 60860 0080      0 ee84a460 eedf0000        0 f8d527a8 nfs3 GETATTR act:status


Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/sched.h |    1 +
 net/sunrpc/clnt.c            |   52 +++++++++++++++++++++++++++++++++++++++---
 net/sunrpc/sched.c           |    2 +-
 3 files changed, 50 insertions(+), 5 deletions(-)


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
index c33d727..ec9c072 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1510,24 +1510,68 @@ struct rpc_task *rpc_call_null(struct rpc_clnt *clnt, struct rpc_cred *cred, int
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
 			  const struct rpc_task *task)
 {
-	printk(KERN_INFO "%5u %04x %6d %8p %8p %8ld %8p %8p %s%u",
+	printk(KERN_INFO "%5u %04x %6d %8p %8p %8ld %8p %s%u",
 		task->tk_pid, task->tk_flags, task->tk_status,
 		clnt, task->tk_rqstp, task->tk_timeout,
-		task->tk_action, task->tk_ops, clnt->cl_protname,
-		clnt->cl_vers);
+		task->tk_ops, clnt->cl_protname, clnt->cl_vers);
 
 	if (task->tk_msg.rpc_proc)
 		printk(KERN_CONT " %s", task->tk_msg.rpc_proc->p_name);
 
+	printk(KERN_CONT " act:%s", rpc_show_action(task->tk_action));
+
 	if (RPC_IS_QUEUED(task))
 		printk(KERN_CONT " wq:%s", rpc_qname(task->tk_waitqueue));
 
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


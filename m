From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/6] SUNRPC: Refactor rpc_show_tasks
Date: Fri, 21 Mar 2008 18:43:19 -0400
Message-ID: <20080321224319.18966.24627.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]:27227 "EHLO
	flpi195.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757049AbYCUWne (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Mar 2008 18:43:34 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: move the logic that displays each task to its own function.
This removes indentation and makes future changes easier.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |   45 +++++++++++++++++++++++----------------------
 1 files changed, 23 insertions(+), 22 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 0410acb..f7ad79c 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1517,10 +1517,30 @@ static void rpc_show_header(void)
 		"-timeout -rpcwait -action- ---ops--\n");
 }
 
+static void rpc_show_task(struct rpc_clnt *clnt, struct rpc_task *task)
+{
+	const char *rpc_waitq = "none";
+	int proc = -1;
+
+	if (task->tk_msg.rpc_proc)
+		proc = task->tk_msg.rpc_proc->p_proc;
+
+	if (RPC_IS_QUEUED(task))
+		rpc_waitq = rpc_qname(task->tk_waitqueue);
+
+	printk(KERN_INFO "%5u %04d %04x %6d %8p %6d %8p %8ld %8s %8p %8p\n",
+		task->tk_pid, proc,
+		task->tk_flags, task->tk_status,
+		clnt, clnt->cl_prog,
+		task->tk_rqstp, task->tk_timeout,
+		rpc_waitq,
+		task->tk_action, task->tk_ops);
+}
+
 void rpc_show_tasks(void)
 {
 	struct rpc_clnt *clnt;
-	struct rpc_task *t;
+	struct rpc_task *task;
 	int header = 0;
 
 	spin_lock(&rpc_client_lock);
@@ -1530,31 +1550,12 @@ void rpc_show_tasks(void)
 		if (list_empty(&clnt->cl_tasks))
 			continue;
 		spin_lock(&clnt->cl_lock);
-		list_for_each_entry(t, &clnt->cl_tasks, tk_task) {
-			const char *rpc_waitq = "none";
-			int proc;
-
+		list_for_each_entry(task, &clnt->cl_tasks, tk_task) {
 			if (!header) {
 				rpc_show_header();
 				header++;
 			}
-
-			if (t->tk_msg.rpc_proc)
-				proc = t->tk_msg.rpc_proc->p_proc;
-			else
-				proc = -1;
-
-			if (RPC_IS_QUEUED(t))
-				rpc_waitq = rpc_qname(t->tk_waitqueue);
-
-			printk("%5u %04d %04x %6d %8p %6d %8p %8ld %8s %8p %8p\n",
-				t->tk_pid, proc,
-				t->tk_flags, t->tk_status,
-				t->tk_client,
-				(t->tk_client ? t->tk_client->cl_prog : 0),
-				t->tk_rqstp, t->tk_timeout,
-				rpc_waitq,
-				t->tk_action, t->tk_ops);
+			rpc_show_task(clnt, task);
 		}
 		spin_unlock(&clnt->cl_lock);
 	}


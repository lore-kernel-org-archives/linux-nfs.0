From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/6] SUNRPC: Refactor rpc_show_tasks
Date: Wed, 21 May 2008 14:16:13 -0400
Message-ID: <20080521181612.3295.67151.stgit@ellison>
References: <20080521180231.3295.84997.stgit@ellison>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:40989 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765287AbYEUSVb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 May 2008 14:21:31 -0400
In-Reply-To: <20080521180231.3295.84997.stgit@ellison>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: move the logic that displays each task to its own function.
This removes indentation and makes future changes easier.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |   46 ++++++++++++++++++++++++----------------------
 1 files changed, 24 insertions(+), 22 deletions(-)


diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e763725..68b08d4 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1531,40 +1531,42 @@ static void rpc_show_header(void)
 		"-timeout -rpcwait -action- ---ops--\n");
 }
 
+static void rpc_show_task(const struct rpc_clnt *clnt,
+			  const struct rpc_task *task)
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
 	list_for_each_entry(clnt, &all_clients, cl_clients) {
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


From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/6] SUNRPC: Add second output line for each RPC task in
	rpc_show_tasks
Date: Fri, 21 Mar 2008 18:43:27 -0400
Message-ID: <20080321224326.18966.76928.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]:27402 "EHLO
	flpi195.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758617AbYCUWnj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Mar 2008 18:43:39 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  Add a second display output line for each RPC task shown via
rpc_show_tasks.  This second line is for non-columnar variable-length
data (like the name of the RPC wait queue the task is waiting on, or
the procedure name).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index f7ad79c..31fae5f 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1513,28 +1513,28 @@ EXPORT_SYMBOL_GPL(rpc_call_null);
 #ifdef RPC_DEBUG
 static void rpc_show_header(void)
 {
-	printk(KERN_INFO "-pid- proc flgs status -client- -prog- --rqstp- "
-		"-timeout -rpcwait -action- ---ops--\n");
+	printk(KERN_INFO "-pid- flgs status -client- --rqstp- "
+		"-timeout -action- ---ops--\n");
 }
 
 static void rpc_show_task(struct rpc_clnt *clnt, struct rpc_task *task)
 {
 	const char *rpc_waitq = "none";
-	int proc = -1;
+	const char *proc = "NULL";
 
 	if (task->tk_msg.rpc_proc)
-		proc = task->tk_msg.rpc_proc->p_proc;
+		proc = task->tk_msg.rpc_proc->p_name;
 
 	if (RPC_IS_QUEUED(task))
 		rpc_waitq = rpc_qname(task->tk_waitqueue);
 
-	printk(KERN_INFO "%5u %04d %04x %6d %8p %6d %8p %8ld %8s %8p %8p\n",
-		task->tk_pid, proc,
-		task->tk_flags, task->tk_status,
-		clnt, clnt->cl_prog,
-		task->tk_rqstp, task->tk_timeout,
-		rpc_waitq,
+	printk(KERN_INFO "%5u %04x %6d %8p %8p %8ld %8p %8p\n",
+		task->tk_pid, task->tk_flags, task->tk_status,
+		clnt, task->tk_rqstp, task->tk_timeout,
 		task->tk_action, task->tk_ops);
+
+	printk(KERN_INFO " prog: %s%u  proc: %s  waitq: %s\n",
+		clnt->cl_protname, clnt->cl_vers, proc, rpc_waitq);
 }
 
 void rpc_show_tasks(void)


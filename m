From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/8] SUNRPC: Display some debugging information as text rather
	than numbers
Date: Tue, 20 May 2008 16:30:03 -0400
Message-ID: <20080520203003.3851.17656.stgit@ellison.1015granger.net>
References: <20080520202108.3851.7464.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:62309 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759456AbYETUat (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 May 2008 16:30:49 -0400
In-Reply-To: <20080520202108.3851.7464.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In rpc_show_tasks(), display the program name, version number, and
procedure name as human-readable variable-length text fields rather than
columnar numbers.

Sample output:

 -pid- flgs status -client- --rqstp- -timeout -action- ---ops--
 14470 0001      0 ee83eaf0 f79a2060    60000 f8cefa00 f8eaa764 nfs3 WRITE wq:xprt_pending
  2970 0001      0 ee83eaf0 f79a2060    60000 f8cefa00 f8eaa77c nfs3 COMMIT wq:xprt_pending
 12468 0080      0 ee83eaf0 f79a2060        0 f8cefa00 f8d03634 nfs3 SETATTR
 40513 0001      0 ee83eaf0 f79a2060        0 f8cefa00 f8eaa6c8 nfs3 READ

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |   25 +++++++++++--------------
 1 files changed, 11 insertions(+), 14 deletions(-)


diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 15c0f5b..6f94a70 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1519,29 +1519,26 @@ EXPORT_SYMBOL_GPL(rpc_call_null);
 #ifdef RPC_DEBUG
 static void rpc_show_header(void)
 {
-	printk(KERN_INFO "-pid- proc flgs status -client- -prog- --rqstp- "
-		"-timeout -rpcwait -action- ---ops--\n");
+	printk(KERN_INFO "-pid- flgs status -client- --rqstp- "
+		"-timeout -action- ---ops--\n");
 }
 
 static void rpc_show_task(const struct rpc_clnt *clnt,
 			  const struct rpc_task *task)
 {
-	const char *rpc_waitq = "none";
-	int proc = -1;
+	printk(KERN_INFO "%5u %04x %6d %8p %8p %8ld %8p %8p %s%u",
+		task->tk_pid, task->tk_flags, task->tk_status,
+		clnt, task->tk_rqstp, task->tk_timeout,
+		task->tk_action, task->tk_ops, clnt->cl_protname,
+		clnt->cl_vers);
 
 	if (task->tk_msg.rpc_proc)
-		proc = task->tk_msg.rpc_proc->p_proc;
+		printk(KERN_CONT " %s", task->tk_msg.rpc_proc->p_name);
 
 	if (RPC_IS_QUEUED(task))
-		rpc_waitq = rpc_qname(task->tk_waitqueue);
-
-	printk(KERN_INFO "%5u %04d %04x %6d %8p %6d %8p %8ld %8s %8p %8p\n",
-		task->tk_pid, proc,
-		task->tk_flags, task->tk_status,
-		clnt, clnt->cl_prog,
-		task->tk_rqstp, task->tk_timeout,
-		rpc_waitq,
-		task->tk_action, task->tk_ops);
+		printk(KERN_CONT " wq:%s", rpc_qname(task->tk_waitqueue));
+
+	printk(KERN_CONT "\n");
 }
 
 void rpc_show_tasks(void)


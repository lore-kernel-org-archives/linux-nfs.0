From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/6] SUNRPC: Don't display the rpc_show_tasks header if there
	are no tasks
Date: Wed, 21 May 2008 17:09:26 -0400
Message-ID: <20080521210926.6468.24502.stgit@ellison.1015granger.net>
References: <20080521210411.6468.68771.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:33805 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937442AbYEUVKi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 May 2008 17:10:38 -0400
In-Reply-To: <20080521210411.6468.68771.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: don't display the rpc_show_tasks column header unless there is at
least one task to display.  As far as I can tell, it is safe to let the
list_for_each_entry macro decide that each list is empty.

scripts/checkpatch.pl also wants a KERN_FOO at the start of any newly added
printk() calls, so this and subsequent patches will also add KERN_INFO.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |   19 ++++++++++++-------
 1 files changed, 12 insertions(+), 7 deletions(-)


diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 619e4ea..e763725 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1525,24 +1525,30 @@ struct rpc_task *rpc_call_null(struct rpc_clnt *clnt, struct rpc_cred *cred, int
 EXPORT_SYMBOL_GPL(rpc_call_null);
 
 #ifdef RPC_DEBUG
+static void rpc_show_header(void)
+{
+	printk(KERN_INFO "-pid- proc flgs status -client- -prog- --rqstp- "
+		"-timeout -rpcwait -action- ---ops--\n");
+}
+
 void rpc_show_tasks(void)
 {
 	struct rpc_clnt *clnt;
 	struct rpc_task *t;
+	int header = 0;
 
 	spin_lock(&rpc_client_lock);
-	if (list_empty(&all_clients))
-		goto out;
-	printk("-pid- proc flgs status -client- -prog- --rqstp- -timeout "
-		"-rpcwait -action- ---ops--\n");
 	list_for_each_entry(clnt, &all_clients, cl_clients) {
-		if (list_empty(&clnt->cl_tasks))
-			continue;
 		spin_lock(&clnt->cl_lock);
 		list_for_each_entry(t, &clnt->cl_tasks, tk_task) {
 			const char *rpc_waitq = "none";
 			int proc;
 
+			if (!header) {
+				rpc_show_header();
+				header++;
+			}
+
 			if (t->tk_msg.rpc_proc)
 				proc = t->tk_msg.rpc_proc->p_proc;
 			else
@@ -1562,7 +1568,6 @@ void rpc_show_tasks(void)
 		}
 		spin_unlock(&clnt->cl_lock);
 	}
-out:
 	spin_unlock(&rpc_client_lock);
 }
 #endif


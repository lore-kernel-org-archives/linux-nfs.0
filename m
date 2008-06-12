From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 13/37] SUNRPC: Don't display the rpc_show_tasks header if
	there are no tasks
Date: Thu, 12 Jun 2008 15:22:00 -0400
Message-ID: <20080612192200.24528.72028.stgit@localhost.localdomain>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61969 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754900AbYFLTeE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:34:04 -0400
In-Reply-To: <20080612192159.24528.43756.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up: don't display the rpc_show_tasks column header unless there is at
least one task to display.  As far as I can tell, it is safe to let the
list_for_each_entry macro decide that each list is empty.

scripts/checkpatch.pl also wants a KERN_FOO at the start of any newly added
printk() calls, so this and subsequent patches will also add KERN_INFO.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/clnt.c |   19 ++++++++++++-------
 1 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index ab8038d..7dda328 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1526,24 +1526,30 @@ struct rpc_task *rpc_call_null(struct rpc_clnt *clnt, struct rpc_cred *cred, int
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
@@ -1563,7 +1569,6 @@ void rpc_show_tasks(void)
 		}
 		spin_unlock(&clnt->cl_lock);
 	}
-out:
 	spin_unlock(&rpc_client_lock);
 }
 #endif


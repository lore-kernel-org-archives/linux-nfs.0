From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/6] SUNRPC: Don't display the rpc_show_tasks header if there
	are no tasks
Date: Fri, 21 Mar 2008 18:43:12 -0400
Message-ID: <20080321224312.18966.19727.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]:27114 "EHLO
	flpi195.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756701AbYCUWn3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Mar 2008 18:43:29 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: don't display the rpc_show_tasks column header unless there is at
least one task to display.

scripts/checkpatch.pl also wants a KERN_FOO at the start of any newly added
printk() calls, so this and subsequent patches will also add KERN_INFO, as
appropriate.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 5a48f96..0410acb 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1511,16 +1511,21 @@ struct rpc_task *rpc_call_null(struct rpc_clnt *clnt, struct rpc_cred *cred, int
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
 	if (list_empty(&all_clients))
 		goto out;
-	printk("-pid- proc flgs status -client- -prog- --rqstp- -timeout "
-		"-rpcwait -action- ---ops--\n");
 	list_for_each_entry(clnt, &all_clients, cl_clients) {
 		if (list_empty(&clnt->cl_tasks))
 			continue;
@@ -1529,6 +1534,11 @@ void rpc_show_tasks(void)
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


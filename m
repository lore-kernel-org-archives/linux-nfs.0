From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/6] SUNRPC: Add a function to display the name of an RPC
	procedure
Date: Wed, 21 May 2008 17:09:12 -0400
Message-ID: <20080521210911.6468.78374.stgit@ellison.1015granger.net>
References: <20080521210411.6468.68771.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:33787 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937420AbYEUVKe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 May 2008 17:10:34 -0400
In-Reply-To: <20080521210411.6468.68771.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Improve debugging messages in call_start() and call_verify() by having
them show the RPC procedure name instead of the procedure number.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |   23 +++++++++++++++++++----
 1 files changed, 19 insertions(+), 4 deletions(-)


diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 8945307..b20638b 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -690,6 +690,21 @@ rpc_restart_call(struct rpc_task *task)
 }
 EXPORT_SYMBOL_GPL(rpc_restart_call);
 
+#ifdef RPC_DEBUG
+static const char *rpc_proc_name(const struct rpc_task *task)
+{
+	const struct rpc_procinfo *proc = task->tk_msg.rpc_proc;
+
+	if (proc) {
+		if (proc->p_name)
+			return proc->p_name;
+		else
+			return "NULL";
+	} else
+		return "no proc";
+}
+#endif
+
 /*
  * 0.  Initial state
  *
@@ -701,9 +716,9 @@ call_start(struct rpc_task *task)
 {
 	struct rpc_clnt	*clnt = task->tk_client;
 
-	dprintk("RPC: %5u call_start %s%d proc %d (%s)\n", task->tk_pid,
+	dprintk("RPC: %5u call_start %s%d proc %s (%s)\n", task->tk_pid,
 			clnt->cl_protname, clnt->cl_vers,
-			task->tk_msg.rpc_proc->p_proc,
+			rpc_proc_name(task),
 			(RPC_IS_ASYNC(task) ? "async" : "sync"));
 
 	/* Increment call count */
@@ -1431,10 +1446,10 @@ call_verify(struct rpc_task *task)
 		error = -EPROTONOSUPPORT;
 		goto out_err;
 	case RPC_PROC_UNAVAIL:
-		dprintk("RPC: %5u %s: proc %p unsupported by program %u, "
+		dprintk("RPC: %5u %s: proc %s unsupported by program %u, "
 				"version %u on server %s\n",
 				task->tk_pid, __func__,
-				task->tk_msg.rpc_proc,
+				rpc_proc_name(task),
 				task->tk_client->cl_prog,
 				task->tk_client->cl_vers,
 				task->tk_client->cl_server);


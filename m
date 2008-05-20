From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/8] SUNRPC: Use RPC procedure name in call_start
Date: Tue, 20 May 2008 16:29:33 -0400
Message-ID: <20080520202933.3851.1295.stgit@ellison.1015granger.net>
References: <20080520202108.3851.7464.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:44677 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757835AbYETUaF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 May 2008 16:30:05 -0400
In-Reply-To: <20080520202108.3851.7464.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Making debugging output a little cleaner in call_start by displaying the
name of the RPC procedure instead of it's number.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)


diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 8945307..adbc85c 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -701,9 +701,9 @@ call_start(struct rpc_task *task)
 {
 	struct rpc_clnt	*clnt = task->tk_client;
 
-	dprintk("RPC: %5u call_start %s%d proc %d (%s)\n", task->tk_pid,
+	dprintk("RPC: %5u call_start %s%u proc %s (%s)\n", task->tk_pid,
 			clnt->cl_protname, clnt->cl_vers,
-			task->tk_msg.rpc_proc->p_proc,
+			task->tk_msg.rpc_proc->p_name,
 			(RPC_IS_ASYNC(task) ? "async" : "sync"));
 
 	/* Increment call count */


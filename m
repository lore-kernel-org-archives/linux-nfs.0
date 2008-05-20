From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/8] SUNRPC: Use RPC procedure name in call_verify
Date: Tue, 20 May 2008 16:29:41 -0400
Message-ID: <20080520202941.3851.61861.stgit@ellison.1015granger.net>
References: <20080520202108.3851.7464.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:44720 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758136AbYETUaJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 May 2008 16:30:09 -0400
In-Reply-To: <20080520202108.3851.7464.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Making debugging output a little cleaner in call_verify by displaying the
name of the RPC procedure instead of it's number.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)


diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index adbc85c..5aa32fa 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1431,10 +1431,10 @@ call_verify(struct rpc_task *task)
 		error = -EPROTONOSUPPORT;
 		goto out_err;
 	case RPC_PROC_UNAVAIL:
-		dprintk("RPC: %5u %s: proc %p unsupported by program %u, "
+		dprintk("RPC: %5u %s: proc %s unsupported by program %u, "
 				"version %u on server %s\n",
 				task->tk_pid, __func__,
-				task->tk_msg.rpc_proc,
+				task->tk_msg.rpc_proc->p_name,
 				task->tk_client->cl_prog,
 				task->tk_client->cl_vers,
 				task->tk_client->cl_server);


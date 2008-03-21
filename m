From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/6] SUNRPC: Use RPC procedure name in call_start
Date: Fri, 21 Mar 2008 18:43:04 -0400
Message-ID: <20080321224304.18966.66326.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]:26991 "EHLO
	flpi195.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755186AbYCUWnY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Mar 2008 18:43:24 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Making debugging output a little cleaner in call_start by
displaying the name of the about-to-be-started RPC procedure, instead of
it's number.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index ea14314..5a48f96 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -705,9 +705,9 @@ call_start(struct rpc_task *task)
 {
 	struct rpc_clnt	*clnt = task->tk_client;
 
-	dprintk("RPC: %5u call_start %s%d proc %d (%s)\n", task->tk_pid,
+	dprintk("RPC: %5u call_start %s%u proc %s (%s)\n", task->tk_pid,
 			clnt->cl_protname, clnt->cl_vers,
-			task->tk_msg.rpc_proc->p_proc,
+			task->tk_msg.rpc_proc->p_name,
 			(RPC_IS_ASYNC(task) ? "async" : "sync"));
 
 	/* Increment call count */


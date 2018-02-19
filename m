Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38523 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751012AbeBSFEf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Feb 2018 00:04:35 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 19 Feb 2018 16:02:29 +1100
Subject: [PATCH 14/23] SUNRPC: add side channel to use non-generic cred for
 rpc call.
Cc: linux-nfs@vger.kernel.org
Message-ID: <151901654925.17421.8083987724119246673.stgit@noble>
In-Reply-To: <151901634940.17421.7637564368419392071.stgit@noble>
References: <151901634940.17421.7637564368419392071.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The credential passed in rpc_message.rpc_cred is always a
generic credential except in one instance.
When gss_destroying_context() calls rpc_call_null(), it passes
a specific credential that it needs to destroy.
In this case the RPC acts *on* the credential rather than
being authorized by it.

This special case deserves explicit support and providing that will
mean that rpc_message.rpc_cred is *always* generic, allowing
some optimizations.

So add "tk_op_cred" to rpc_task and "rpc_op_cred" to the setup data.
Use this to pass the cred down from rpc_call_null(), and have
rpcauth_bindcred() notice it and bind it in place.

Signed-off-by: NeilBrown <neilb@suse.com>

CHANGES: add missing 'else' in rpcauth_bindcred()
  A subsequent patch added this before.
---
 include/linux/sunrpc/sched.h |    2 ++
 net/sunrpc/auth.c            |    6 +++++-
 net/sunrpc/clnt.c            |    2 +-
 net/sunrpc/sched.c           |    3 +++
 4 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 216b6a7513db..be278d92ff4f 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -71,6 +71,7 @@ struct rpc_task {
 
 	struct rpc_clnt *	tk_client;	/* RPC client */
 	struct rpc_xprt *	tk_xprt;	/* Transport */
+	struct rpc_cred *	tk_op_cred;	/* cred being operated on */
 
 	struct rpc_rqst *	tk_rqstp;	/* RPC request */
 
@@ -105,6 +106,7 @@ struct rpc_task_setup {
 	struct rpc_task *task;
 	struct rpc_clnt *rpc_client;
 	struct rpc_xprt *rpc_xprt;
+	struct rpc_cred *rpc_op_cred;	/* credential being operated on */
 	const struct rpc_message *rpc_message;
 	const struct rpc_call_ops *callback_ops;
 	void *callback_data;
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 484a850a7e00..0130d0151623 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -726,7 +726,11 @@ rpcauth_bindcred(struct rpc_task *task, struct rpc_cred *cred, int flags)
 
 	if (flags & RPC_TASK_ASYNC)
 		lookupflags |= RPCAUTH_LOOKUP_NEW;
-	if (cred != NULL && cred != &machine_cred)
+	if (task->tk_op_cred)
+		/* Task must use exactly this rpc_cred */
+		new = task->tk_op_cred->cr_ops->crbind(task, task->tk_op_cred,
+						       lookupflags);
+	else if (cred != NULL && cred != &machine_cred)
 		new = cred->cr_ops->crbind(task, cred, lookupflags);
 	else if (cred == &machine_cred)
 		new = rpcauth_bind_machine_cred(task, lookupflags);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 85db88bfb4c8..be66fec601b0 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2516,12 +2516,12 @@ struct rpc_task *rpc_call_null_helper(struct rpc_clnt *clnt,
 {
 	struct rpc_message msg = {
 		.rpc_proc = &rpcproc_null,
-		.rpc_cred = cred,
 	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = clnt,
 		.rpc_xprt = xprt,
 		.rpc_message = &msg,
+		.rpc_op_cred = cred,
 		.callback_ops = (ops != NULL) ? ops : &rpc_default_ops,
 		.callback_data = data,
 		.flags = flags,
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index d9db2eab3a8d..d0091e5ad220 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -949,6 +949,8 @@ static void rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *ta
 
 	task->tk_xprt = xprt_get(task_setup_data->rpc_xprt);
 
+	task->tk_op_cred = get_rpccred(task_setup_data->rpc_op_cred);
+
 	if (task->tk_ops->rpc_call_prepare != NULL)
 		task->tk_action = rpc_prepare_task;
 
@@ -1007,6 +1009,7 @@ static void rpc_free_task(struct rpc_task *task)
 	unsigned short tk_flags = task->tk_flags;
 
 	rpc_release_calldata(task->tk_ops, task->tk_calldata);
+	put_rpccred(task->tk_op_cred);
 
 	if (tk_flags & RPC_TASK_DYNAMIC) {
 		dprintk("RPC: %5u freeing task\n", task->tk_pid);



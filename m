From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 3/6] SUNRPC: Clean up rpcauth_bindcred()
Date: Thu, 13 Mar 2008 13:48:09 -0400
Message-ID: <20080313174808.13840.32022.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080313174806.13840.90325.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org, Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61939 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753939AbYCMSCH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Mar 2008 14:02:07 -0400
In-Reply-To: <20080313174806.13840.90325.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/auth.h |    4 +---
 net/sunrpc/auth.c           |   28 ++++++++++++++++++----------
 net/sunrpc/sched.c          |   11 ++++-------
 3 files changed, 23 insertions(+), 20 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 012566a..348546c 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -135,9 +135,7 @@ void			rpcauth_release(struct rpc_auth *);
 struct rpc_cred *	rpcauth_lookup_credcache(struct rpc_auth *, struct auth_cred *, int);
 void			rpcauth_init_cred(struct rpc_cred *, const struct auth_cred *, struct rpc_auth *, const struct rpc_credops *);
 struct rpc_cred *	rpcauth_lookupcred(struct rpc_auth *, int);
-void			rpcauth_bindcred(struct rpc_task *);
-void			rpcauth_bind_root_cred(struct rpc_task *);
-void			rpcauth_holdcred(struct rpc_task *);
+void			rpcauth_bindcred(struct rpc_task *, struct rpc_cred *, int);
 void			put_rpccred(struct rpc_cred *);
 void			rpcauth_unbindcred(struct rpc_task *);
 __be32 *		rpcauth_marshcred(struct rpc_task *, __be32 *);
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index b0f2b2e..1cdb163 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -375,7 +375,15 @@ rpcauth_init_cred(struct rpc_cred *cred, const struct auth_cred *acred,
 }
 EXPORT_SYMBOL_GPL(rpcauth_init_cred);
 
-void
+static void
+rpcauth_generic_bind_cred(struct rpc_task *task, struct rpc_cred *cred)
+{
+	task->tk_msg.rpc_cred = get_rpccred(cred);
+	dprintk("RPC: %5u holding %s cred %p\n", task->tk_pid,
+			cred->cr_auth->au_ops->au_name, cred);
+}
+
+static void
 rpcauth_bind_root_cred(struct rpc_task *task)
 {
 	struct rpc_auth *auth = task->tk_client->cl_auth;
@@ -394,8 +402,8 @@ rpcauth_bind_root_cred(struct rpc_task *task)
 		task->tk_status = PTR_ERR(ret);
 }
 
-void
-rpcauth_bindcred(struct rpc_task *task)
+static void
+rpcauth_bind_new_cred(struct rpc_task *task)
 {
 	struct rpc_auth *auth = task->tk_client->cl_auth;
 	struct rpc_cred *ret;
@@ -410,14 +418,14 @@ rpcauth_bindcred(struct rpc_task *task)
 }
 
 void
-rpcauth_holdcred(struct rpc_task *task)
+rpcauth_bindcred(struct rpc_task *task, struct rpc_cred *cred, int flags)
 {
-	struct rpc_cred *cred = task->tk_msg.rpc_cred;
-	if (cred != NULL) {
-		get_rpccred(cred);
-		dprintk("RPC: %5u holding %s cred %p\n", task->tk_pid,
-				cred->cr_auth->au_ops->au_name, cred);
-	}
+	if (cred != NULL)
+		rpcauth_generic_bind_cred(task, cred);
+	else if (flags & RPC_TASK_ROOTCREDS)
+		rpcauth_bind_root_cred(task);
+	else
+		rpcauth_bind_new_cred(task);
 }
 
 void
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 7db956f..6eab9bf 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -817,14 +817,11 @@ static void rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *ta
 		task->tk_action = rpc_prepare_task;
 
 	if (task_setup_data->rpc_message != NULL) {
-		memcpy(&task->tk_msg, task_setup_data->rpc_message, sizeof(task->tk_msg));
+		task->tk_msg.rpc_proc = task_setup_data->rpc_message->rpc_proc;
+		task->tk_msg.rpc_argp = task_setup_data->rpc_message->rpc_argp;
+		task->tk_msg.rpc_resp = task_setup_data->rpc_message->rpc_resp;
 		/* Bind the user cred */
-		if (task->tk_msg.rpc_cred != NULL)
-			rpcauth_holdcred(task);
-		else if (!(task_setup_data->flags & RPC_TASK_ROOTCREDS))
-			rpcauth_bindcred(task);
-		else
-			rpcauth_bind_root_cred(task);
+		rpcauth_bindcred(task, task_setup_data->rpc_message->rpc_cred, task_setup_data->flags);
 		if (task->tk_action == NULL)
 			rpc_call_start(task);
 	}


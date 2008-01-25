From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 020/112] SUNRPC: Mask signals across the call to
	rpc_call_setup() in rpc_run_task
Date: Fri, 25 Jan 2008 11:37:28 -0500
Message-ID: <20080125163728.31887.16898.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33369 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753546AbYAYQ7l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:41 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxcPH010116
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:38 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To ensure that the RPCSEC_GSS upcall is performed with the correct sigmask.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/auth.c |    3 +++
 net/sunrpc/clnt.c |   13 +++++++------
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index eca941c..bcd9abd 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -385,6 +385,7 @@ rpcauth_bindcred(struct rpc_task *task)
 		.group_info = current->group_info,
 	};
 	struct rpc_cred *ret;
+	sigset_t oldset;
 	int flags = 0;
 
 	dprintk("RPC: %5u looking up %s cred\n",
@@ -392,7 +393,9 @@ rpcauth_bindcred(struct rpc_task *task)
 	get_group_info(acred.group_info);
 	if (task->tk_flags & RPC_TASK_ROOTCREDS)
 		flags |= RPCAUTH_LOOKUP_ROOTCREDS;
+	rpc_clnt_sigmask(task->tk_client, &oldset);
 	ret = auth->au_ops->lookup_cred(auth, &acred, flags);
+	rpc_clnt_sigunmask(task->tk_client, &oldset);
 	if (!IS_ERR(ret))
 		task->tk_msg.rpc_cred = ret;
 	else
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 9aad459..aefe3ae 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -501,12 +501,12 @@ static void rpc_save_sigmask(sigset_t *oldset, int intr)
 	sigprocmask(SIG_BLOCK, &sigmask, oldset);
 }
 
-static inline void rpc_task_sigmask(struct rpc_task *task, sigset_t *oldset)
+static void rpc_task_sigmask(struct rpc_task *task, sigset_t *oldset)
 {
 	rpc_save_sigmask(oldset, !RPC_TASK_UNINTERRUPTIBLE(task));
 }
 
-static inline void rpc_restore_sigmask(sigset_t *oldset)
+static void rpc_restore_sigmask(sigset_t *oldset)
 {
 	sigprocmask(SIG_SETMASK, oldset, NULL);
 }
@@ -536,11 +536,10 @@ struct rpc_task *rpc_run_task(const struct rpc_task_setup *task_setup_data)
 	if (task == NULL) {
 		rpc_release_calldata(task_setup_data->callback_ops,
 				task_setup_data->callback_data);
-		return ERR_PTR(-ENOMEM);
+		ret = ERR_PTR(-ENOMEM);
+		goto out;
 	}
 
-	/* Mask signals on synchronous RPC calls and RPCSEC_GSS upcalls */
-	rpc_task_sigmask(task, &oldset);
 	if (task_setup_data->rpc_message != NULL) {
 		rpc_call_setup(task, task_setup_data->rpc_message, 0);
 		if (task->tk_status != 0) {
@@ -550,10 +549,12 @@ struct rpc_task *rpc_run_task(const struct rpc_task_setup *task_setup_data)
 		}
 	}
 	atomic_inc(&task->tk_count);
+	/* Mask signals on synchronous RPC calls and RPCSEC_GSS upcalls */
+	rpc_task_sigmask(task, &oldset);
 	rpc_execute(task);
+	rpc_restore_sigmask(&oldset);
 	ret = task;
 out:
-	rpc_restore_sigmask(&oldset);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(rpc_run_task);

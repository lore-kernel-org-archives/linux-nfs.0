From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfsd4: replace callback thread by asynchronous rpc
Date: Sun,  3 May 2009 14:16:34 -0400
Message-ID: <1241374599-20348-9-git-send-email-bfields@fieldses.org>
References: <1241374599-20348-1-git-send-email-bfields@fieldses.org>
 <1241374599-20348-2-git-send-email-bfields@fieldses.org>
 <1241374599-20348-3-git-send-email-bfields@fieldses.org>
 <1241374599-20348-4-git-send-email-bfields@fieldses.org>
 <1241374599-20348-5-git-send-email-bfields@fieldses.org>
 <1241374599-20348-6-git-send-email-bfields@fieldses.org>
 <1241374599-20348-7-git-send-email-bfields@fieldses.org>
 <1241374599-20348-8-git-send-email-bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:58609 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754159AbZECSQj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 May 2009 14:16:39 -0400
In-Reply-To: <1241374599-20348-8-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

We don't really need a synchronous rpc, and moving to an asynchronous
rpc allows us to do without this extra kthread.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |   38 ++++++++++++++++++++++----------------
 1 files changed, 22 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index cc10ed3..0aaf68b 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -415,6 +415,21 @@ static void warn_no_callback_path(struct nfs4_client *clp, int reason)
 		(int)clp->cl_name.len, clp->cl_name.data, reason);
 }
 
+static void nfsd4_cb_probe_done(struct rpc_task *task, void *calldata)
+{
+	struct nfs4_client *clp = calldata;
+
+	if (task->tk_status)
+		warn_no_callback_path(clp, task->tk_status);
+	else
+		atomic_set(&clp->cl_callback.cb_set, 1);
+	put_nfs4_client(clp);
+}
+
+static const struct rpc_call_ops nfsd4_cb_probe_ops = {
+	.rpc_call_done = nfsd4_cb_probe_done,
+};
+
 static struct rpc_cred *lookup_cb_cred(struct nfs4_callback *cb)
 {
 	struct auth_cred acred = {
@@ -431,9 +446,8 @@ static struct rpc_cred *lookup_cb_cred(struct nfs4_callback *cb)
 							RPCAUTH_LOOKUP_NEW);
 }
 
-static int do_probe_callback(void *data)
+void do_probe_callback(struct nfs4_client *clp)
 {
-	struct nfs4_client *clp = data;
 	struct nfs4_callback    *cb = &clp->cl_callback;
 	struct rpc_message msg = {
 		.rpc_proc       = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
@@ -449,15 +463,13 @@ static int do_probe_callback(void *data)
 	}
 	cb->cb_cred = cred;
 	msg.rpc_cred = cb->cb_cred;
-	status = rpc_call_sync(cb->cb_client, &msg, RPC_TASK_SOFT);
+	status = rpc_call_async(cb->cb_client, &msg, RPC_TASK_SOFT,
+				&nfsd4_cb_probe_ops, (void *)clp);
 out:
-	if (status)
+	if (status) {
 		warn_no_callback_path(clp, status);
-	else
-		atomic_set(&cb->cb_set, 1);
-
-	put_nfs4_client(clp);
-	return 0;
+		put_nfs4_client(clp);
+	}
 }
 
 /*
@@ -466,7 +478,6 @@ out:
 void
 nfsd4_probe_callback(struct nfs4_client *clp)
 {
-	struct task_struct *t;
 	int status;
 
 	BUG_ON(atomic_read(&clp->cl_callback.cb_set));
@@ -480,12 +491,7 @@ nfsd4_probe_callback(struct nfs4_client *clp)
 	/* the task holds a reference to the nfs4_client struct */
 	atomic_inc(&clp->cl_count);
 
-	t = kthread_run(do_probe_callback, clp, "nfs4_cb_probe");
-
-	if (IS_ERR(t))
-		atomic_dec(&clp->cl_count);
-
-	return;
+	do_probe_callback(clp);
 }
 
 /*
-- 
1.6.0.4


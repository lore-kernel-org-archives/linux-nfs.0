Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49117 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932197Ab0I3QTi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 12:19:38 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 05/16] nfsd4: use generic callback code in null case
Date: Thu, 30 Sep 2010 12:19:02 -0400
Message-Id: <1285863553-8945-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1285863553-8945-1-git-send-email-bfields@redhat.com>
References: <1285863553-8945-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: J. Bruce Fields <bfields@citi.umich.edu>

This will eventually allow us, for example, to kick off null callback
from contexts where we can't sleep.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |   33 ++++++++++++++++++---------------
 fs/nfsd/nfs4state.c    |    1 +
 fs/nfsd/state.h        |    1 +
 3 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 2289ad5..3b06212 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -518,7 +518,7 @@ static void warn_no_callback_path(struct nfs4_client *clp, int reason)
 
 static void nfsd4_cb_probe_done(struct rpc_task *task, void *calldata)
 {
-	struct nfs4_client *clp = calldata;
+	struct nfs4_client *clp = container_of(calldata, struct nfs4_client, cl_cb_null);
 
 	if (task->tk_status)
 		warn_no_callback_path(clp, task->tk_status);
@@ -527,6 +527,8 @@ static void nfsd4_cb_probe_done(struct rpc_task *task, void *calldata)
 }
 
 static const struct rpc_call_ops nfsd4_cb_probe_ops = {
+	/* XXX: release method to ensure we set the cb channel down if
+	 * necessary on early failure? */
 	.rpc_call_done = nfsd4_cb_probe_done,
 };
 
@@ -542,21 +544,23 @@ int set_callback_cred(void)
 	return 0;
 }
 
+static struct workqueue_struct *callback_wq;
 
 void do_probe_callback(struct nfs4_client *clp)
 {
-	struct rpc_message msg = {
-		.rpc_proc       = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
-		.rpc_argp       = clp,
-		.rpc_cred	= callback_cred
-	};
-	int status;
+	struct nfsd4_callback *cb = &clp->cl_cb_null;
 
-	status = rpc_call_async(clp->cl_cb_client, &msg,
-				RPC_TASK_SOFT | RPC_TASK_SOFTCONN,
-				&nfsd4_cb_probe_ops, (void *)clp);
-	if (status)
-		warn_no_callback_path(clp, status);
+	cb->cb_args.args_op = NULL;
+	cb->cb_args.args_clp = clp;
+
+	cb->cb_msg.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL];
+	cb->cb_msg.rpc_argp = NULL;
+	cb->cb_msg.rpc_resp = NULL;
+	cb->cb_msg.rpc_cred = callback_cred;
+
+	cb->cb_ops = &nfsd4_cb_probe_ops;
+
+	queue_work(callback_wq, &cb->cb_work);
 }
 
 /*
@@ -712,8 +716,6 @@ static const struct rpc_call_ops nfsd4_cb_recall_ops = {
 	.rpc_release = nfsd4_cb_recall_release,
 };
 
-static struct workqueue_struct *callback_wq;
-
 int nfsd4_create_callback_queue(void)
 {
 	callback_wq = create_singlethread_workqueue("nfsd4_callbacks");
@@ -759,7 +761,8 @@ void nfsd4_do_callback_rpc(struct work_struct *w)
 		nfsd4_release_cb(cb);
 		return; /* Client is shutting down; give up. */
 	}
-	rpc_call_async(clnt, &cb->cb_msg, RPC_TASK_SOFT, cb->cb_ops, cb);
+	rpc_call_async(clnt, &cb->cb_msg, RPC_TASK_SOFT | RPC_TASK_SOFTCONN,
+			cb->cb_ops, cb);
 }
 
 void nfsd4_cb_recall(struct nfs4_delegation *dp)
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d347180..2f464fb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -978,6 +978,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
 	INIT_LIST_HEAD(&clp->cl_delegations);
 	INIT_LIST_HEAD(&clp->cl_sessions);
 	INIT_LIST_HEAD(&clp->cl_lru);
+	INIT_WORK(&clp->cl_cb_null.cb_work, nfsd4_do_callback_rpc);
 	clp->cl_time = get_seconds();
 	clear_bit(0, &clp->cl_cb_slot_busy);
 	rpc_init_wait_queue(&clp->cl_cb_waitq, "Backchannel slot table");
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 6e59214..19732d5 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -223,6 +223,7 @@ struct nfs4_client {
 	struct nfs4_cb_conn	cl_cb_conn;
 	struct rpc_clnt		*cl_cb_client;
 	atomic_t		cl_cb_set;
+	struct nfsd4_callback	cl_cb_null;
 
 	/* for nfs41 */
 	struct list_head	cl_sessions;
-- 
1.7.0.4


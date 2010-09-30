Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49114 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932192Ab0I3QTi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 12:19:38 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 04/16] nfsd4: generic callback code
Date: Thu, 30 Sep 2010 12:19:01 -0400
Message-Id: <1285863553-8945-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1285863553-8945-1-git-send-email-bfields@redhat.com>
References: <1285863553-8945-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: J. Bruce Fields <bfields@citi.umich.edu>

Make the recall callback code more generic, so that other callbacks
will be able to use it too.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |   70 +++++++++++++++++++++--------------------------
 fs/nfsd/state.h        |    2 +
 2 files changed, 33 insertions(+), 39 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index ae63f69..2289ad5 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -584,7 +584,6 @@ void nfsd4_probe_callback(struct nfs4_client *clp, struct nfs4_cb_conn *conn)
 static int nfsd41_cb_setup_sequence(struct nfs4_client *clp,
 		struct rpc_task *task)
 {
-	struct nfsd4_cb_args *args = task->tk_msg.rpc_argp;
 	u32 *ptr = (u32 *)clp->cl_sessionid.data;
 	int status = 0;
 
@@ -597,14 +596,6 @@ static int nfsd41_cb_setup_sequence(struct nfs4_client *clp,
 		status = -EAGAIN;
 		goto out;
 	}
-
-	/*
-	 * We'll need the clp during XDR encoding and decoding,
-	 * and the sequence during decoding to verify the reply
-	 */
-	args->args_clp = clp;
-	task->tk_msg.rpc_resp = args;
-
 out:
 	dprintk("%s status=%d\n", __func__, status);
 	return status;
@@ -616,7 +607,8 @@ out:
  */
 static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
 {
-	struct nfs4_delegation *dp = calldata;
+	struct nfsd4_callback *cb = calldata;
+	struct nfs4_delegation *dp = container_of(cb, struct nfs4_delegation, dl_recall);
 	struct nfs4_client *clp = dp->dl_client;
 	struct nfsd4_cb_args *args = task->tk_msg.rpc_argp;
 	u32 minorversion = clp->cl_cb_conn.cb_minorversion;
@@ -639,7 +631,8 @@ static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
 
 static void nfsd4_cb_done(struct rpc_task *task, void *calldata)
 {
-	struct nfs4_delegation *dp = calldata;
+	struct nfsd4_callback *cb = calldata;
+	struct nfs4_delegation *dp = container_of(cb, struct nfs4_delegation, dl_recall);
 	struct nfs4_client *clp = dp->dl_client;
 
 	dprintk("%s: minorversion=%d\n", __func__,
@@ -661,7 +654,8 @@ static void nfsd4_cb_done(struct rpc_task *task, void *calldata)
 
 static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
 {
-	struct nfs4_delegation *dp = calldata;
+	struct nfsd4_callback *cb = calldata;
+	struct nfs4_delegation *dp = container_of(cb, struct nfs4_delegation, dl_recall);
 	struct nfs4_client *clp = dp->dl_client;
 	struct rpc_clnt *current_rpc_client = clp->cl_cb_client;
 
@@ -706,7 +700,8 @@ static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
 
 static void nfsd4_cb_recall_release(void *calldata)
 {
-	struct nfs4_delegation *dp = calldata;
+	struct nfsd4_callback *cb = calldata;
+	struct nfs4_delegation *dp = container_of(cb, struct nfs4_delegation, dl_recall);
 
 	nfs4_put_delegation(dp);
 }
@@ -748,42 +743,39 @@ void nfsd4_set_callback_client(struct nfs4_client *clp, struct rpc_clnt *new)
 		rpc_shutdown_client(old);
 }
 
-/*
- * called with dp->dl_count inc'ed.
- */
-static void _nfsd4_cb_recall(struct nfs4_delegation *dp)
+void nfsd4_release_cb(struct nfsd4_callback *cb)
 {
-	struct nfs4_client *clp = dp->dl_client;
+	if (cb->cb_ops->rpc_release)
+		cb->cb_ops->rpc_release(cb);
+}
+
+void nfsd4_do_callback_rpc(struct work_struct *w)
+{
+	struct nfsd4_callback *cb = container_of(w, struct nfsd4_callback, cb_work);
+	struct nfs4_client *clp = cb->cb_args.args_clp;
 	struct rpc_clnt *clnt = clp->cl_cb_client;
-	struct nfsd4_cb_args *args = &dp->dl_recall.cb_args;
-	struct rpc_message msg = {
-		.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_RECALL],
-		.rpc_cred = callback_cred
-	};
 
 	if (clnt == NULL) {
-		nfs4_put_delegation(dp);
+		nfsd4_release_cb(cb);
 		return; /* Client is shutting down; give up. */
 	}
-
-	args->args_op = dp;
-	msg.rpc_argp = args;
-	dp->dl_retries = 1;
-	rpc_call_async(clnt, &msg, RPC_TASK_SOFT, &nfsd4_cb_recall_ops, dp);
+	rpc_call_async(clnt, &cb->cb_msg, RPC_TASK_SOFT, cb->cb_ops, cb);
 }
 
-void nfsd4_do_callback_rpc(struct work_struct *w)
+void nfsd4_cb_recall(struct nfs4_delegation *dp)
 {
-	/* XXX: for now, just send off delegation recall. */
-	/* In future, generalize to handle any sort of callback. */
-	struct nfsd4_callback *c = container_of(w, struct nfsd4_callback, cb_work);
-	struct nfs4_delegation *dp = container_of(c, struct nfs4_delegation, dl_recall);
-
-	_nfsd4_cb_recall(dp);
-}
+	struct nfsd4_callback *cb = &dp->dl_recall;
 
+	dp->dl_retries = 1;
+	cb->cb_args.args_op = dp;
+	cb->cb_args.args_clp = dp->dl_client;
+	cb->cb_msg.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_RECALL];
+	cb->cb_msg.rpc_argp = &cb->cb_args;
+	cb->cb_msg.rpc_resp = &cb->cb_args;
+	cb->cb_msg.rpc_cred = callback_cred;
+
+	cb->cb_ops = &nfsd4_cb_recall_ops;
+	dp->dl_retries = 1;
 
-void nfsd4_cb_recall(struct nfs4_delegation *dp)
-{
 	queue_work(callback_wq, &dp->dl_recall.cb_work);
 }
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index f988b90..6e59214 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -72,6 +72,8 @@ struct nfsd4_cb_args {
 
 struct nfsd4_callback {
 	struct nfsd4_cb_args cb_args;
+	struct rpc_message cb_msg;
+	const struct rpc_call_ops *cb_ops;
 	struct work_struct cb_work;
 };
 
-- 
1.7.0.4


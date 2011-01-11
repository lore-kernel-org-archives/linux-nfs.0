Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56207 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932276Ab1AKQWF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jan 2011 11:22:05 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 14/14] nfsd4: allow restarting callbacks
Date: Tue, 11 Jan 2011 11:21:34 -0500
Message-Id: <1294762894-21371-15-git-send-email-bfields@redhat.com>
In-Reply-To: <1294762894-21371-1-git-send-email-bfields@redhat.com>
References: <1294762894-21371-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

If we lose the backchannel and then the client repairs the problem,
resend any callbacks.

We use a new cb_done flag to track whether there is still work to be
done for the callback or whether it can be destroyed with the rpc.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4callback.c |   34 ++++++++++++++++++++++++++++------
 fs/nfsd/nfs4state.c    |    1 +
 fs/nfsd/state.h        |    3 +++
 3 files changed, 32 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 69955e9..f1d9dd4 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -639,6 +639,10 @@ static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
 		if (!nfsd41_cb_get_slot(clp, task))
 			return;
 	}
+	cb->cb_done = false;
+	spin_lock(&clp->cl_lock);
+	list_add(&cb->cb_per_client, &clp->cl_callbacks);
+	spin_unlock(&clp->cl_lock);
 	rpc_call_start(task);
 }
 
@@ -681,8 +685,11 @@ static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
 		return;
 	}
 
+	if (cb->cb_done)
+		return;
 	switch (task->tk_status) {
 	case 0:
+		cb->cb_done = true;
 		return;
 	case -EBADHANDLE:
 	case -NFS4ERR_BAD_STATEID:
@@ -695,7 +702,7 @@ static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
 		if (current_rpc_client != task->tk_client) {
 			/* queue a callback on the new connection: */
 			atomic_inc(&dp->dl_count);
-			nfsd4_cb_recall(dp);
+			run_nfsd4_cb(&dp->dl_recall);
 			return;
 		}
 	}
@@ -704,16 +711,23 @@ static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
 		task->tk_status = 0;
 		rpc_restart_call_prepare(task);
 		return;
-	} else
-		nfsd4_mark_cb_down(clp, task->tk_status);
+	}
+	nfsd4_mark_cb_down(clp, task->tk_status);
+	cb->cb_done = true;
 }
 
 static void nfsd4_cb_recall_release(void *calldata)
 {
 	struct nfsd4_callback *cb = calldata;
+	struct nfs4_client *clp = cb->cb_clp;
 	struct nfs4_delegation *dp = container_of(cb, struct nfs4_delegation, dl_recall);
 
-	nfs4_put_delegation(dp);
+	if (cb->cb_done) {
+		spin_lock(&clp->cl_lock);
+		list_del(&cb->cb_per_client);
+		spin_unlock(&clp->cl_lock);
+		nfs4_put_delegation(dp);
+	}
 }
 
 static const struct rpc_call_ops nfsd4_cb_recall_ops = {
@@ -808,8 +822,13 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
 	spin_unlock(&clp->cl_lock);
 
 	err = setup_callback_client(clp, &conn, ses);
-	if (err)
+	if (err) {
 		warn_no_callback_path(clp, err);
+		return;
+	}
+	/* Yay, the callback channel's back! Restart any callbacks: */
+	list_for_each_entry(cb, &clp->cl_callbacks, cb_per_client)
+		run_nfsd4_cb(cb);
 }
 
 void nfsd4_do_callback_rpc(struct work_struct *w)
@@ -834,10 +853,11 @@ void nfsd4_do_callback_rpc(struct work_struct *w)
 void nfsd4_cb_recall(struct nfs4_delegation *dp)
 {
 	struct nfsd4_callback *cb = &dp->dl_recall;
+	struct nfs4_client *clp = dp->dl_client;
 
 	dp->dl_retries = 1;
 	cb->cb_op = dp;
-	cb->cb_clp = dp->dl_client;
+	cb->cb_clp = clp;
 	cb->cb_msg.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_RECALL];
 	cb->cb_msg.rpc_argp = cb;
 	cb->cb_msg.rpc_resp = cb;
@@ -846,5 +866,7 @@ void nfsd4_cb_recall(struct nfs4_delegation *dp)
 	cb->cb_ops = &nfsd4_cb_recall_ops;
 	dp->dl_retries = 1;
 
+	cb->cb_done = true;
+
 	run_nfsd4_cb(&dp->dl_recall);
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 408957c..6e1f9aa 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1077,6 +1077,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
 	INIT_LIST_HEAD(&clp->cl_openowners);
 	INIT_LIST_HEAD(&clp->cl_delegations);
 	INIT_LIST_HEAD(&clp->cl_lru);
+	INIT_LIST_HEAD(&clp->cl_callbacks);
 	spin_lock_init(&clp->cl_lock);
 	INIT_WORK(&clp->cl_cb_null.cb_work, nfsd4_do_callback_rpc);
 	clp->cl_time = get_seconds();
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 4e5bdfd..3074656 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -68,10 +68,12 @@ typedef struct {
 struct nfsd4_callback {
 	void *cb_op;
 	struct nfs4_client *cb_clp;
+	struct list_head cb_per_client;
 	u32 cb_minorversion;
 	struct rpc_message cb_msg;
 	const struct rpc_call_ops *cb_ops;
 	struct work_struct cb_work;
+	bool cb_done;
 };
 
 struct nfs4_delegation {
@@ -248,6 +250,7 @@ struct nfs4_client {
 	int			cl_cb_state;
 	struct nfsd4_callback	cl_cb_null;
 	struct nfsd4_session	*cl_cb_session;
+	struct list_head	cl_callbacks; /* list of in-progress callbacks */
 
 	/* for all client information that callback code might need: */
 	spinlock_t		cl_lock;
-- 
1.7.1


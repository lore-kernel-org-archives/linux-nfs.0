Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:39533 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754307AbaIXKRB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Sep 2014 06:17:01 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] nfsd: introduce nfsd4_callback_ops
Date: Wed, 24 Sep 2014 12:19:19 +0200
Message-Id: <1411553959-5280-5-git-send-email-hch@lst.de>
In-Reply-To: <1411553959-5280-1-git-send-email-hch@lst.de>
References: <1411553959-5280-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a higher level abstraction than the rpc_ops for callback operations.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4callback.c | 91 ++++++++++++++++----------------------------------
 fs/nfsd/nfs4state.c    | 51 +++++++++++++++++++++++++---
 fs/nfsd/state.h        | 12 ++++---
 3 files changed, 83 insertions(+), 71 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 6d9d947..9cc51b9 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -824,18 +824,8 @@ static void nfsd4_cb_done(struct rpc_task *task, void *calldata)
 		dprintk("%s: freed slot, new seqid=%d\n", __func__,
 			clp->cl_cb_session->se_cb_seq_nr);
 	}
-}
 
-static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
-{
-	struct nfsd4_callback *cb = calldata;
-	struct nfs4_delegation *dp = to_delegation(cb);
-	struct nfs4_client *clp = cb->cb_clp;
-	struct rpc_clnt *current_rpc_client = clp->cl_cb_client;
-
-	nfsd4_cb_done(task, calldata);
-
-	if (current_rpc_client != task->tk_client) {
+	if (clp->cl_cb_client != task->tk_client) {
 		/* We're shutting down or changing cl_cb_client; leave
 		 * it to nfsd4_process_cb_update to restart the call if
 		 * necessary. */
@@ -844,45 +834,42 @@ static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
 
 	if (cb->cb_done)
 		return;
-	switch (task->tk_status) {
+
+	switch (cb->cb_ops->done(cb, task)) {
 	case 0:
+		task->tk_status = 0;
+		rpc_restart_call_prepare(task);
+		return;
+	case 1:
 		break;
-	case -EBADHANDLE:
-	case -NFS4ERR_BAD_STATEID:
-		/* Race: client probably got cb_recall
-		 * before open reply granting delegation */
-		if (dp->dl_retries--) {
-			rpc_delay(task, 2*HZ);
-			task->tk_status = 0;
-			rpc_restart_call_prepare(task);
-			return;
-		}
-	default:
+	case -1:
 		/* Network partition? */
 		nfsd4_mark_cb_down(clp, task->tk_status);
+		break;
+	default:
+		BUG();
 	}
 	cb->cb_done = true;
 }
 
-static void nfsd4_cb_recall_release(void *calldata)
+static void nfsd4_cb_release(void *calldata)
 {
 	struct nfsd4_callback *cb = calldata;
 	struct nfs4_client *clp = cb->cb_clp;
 
 	if (cb->cb_done) {
-		struct nfs4_delegation *dp = to_delegation(cb);
-
 		spin_lock(&clp->cl_lock);
 		list_del(&cb->cb_per_client);
 		spin_unlock(&clp->cl_lock);
-		nfs4_put_stid(&dp->dl_stid);
+
+		cb->cb_ops->release(cb);
 	}
 }
 
-static const struct rpc_call_ops nfsd4_cb_recall_ops = {
+static const struct rpc_call_ops nfsd4_cb_ops = {
 	.rpc_call_prepare = nfsd4_cb_prepare,
-	.rpc_call_done = nfsd4_cb_recall_done,
-	.rpc_release = nfsd4_cb_recall_release,
+	.rpc_call_done = nfsd4_cb_done,
+	.rpc_release = nfsd4_cb_release,
 };
 
 int nfsd4_create_callback_queue(void)
@@ -911,12 +898,6 @@ void nfsd4_shutdown_callback(struct nfs4_client *clp)
 	flush_workqueue(callback_wq);
 }
 
-static void nfsd4_release_cb(struct nfsd4_callback *cb)
-{
-	if (cb->cb_ops->rpc_release)
-		cb->cb_ops->rpc_release(cb);
-}
-
 /* requires cl_lock: */
 static struct nfsd4_conn * __nfsd4_find_backchannel(struct nfs4_client *clp)
 {
@@ -983,54 +964,40 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
 }
 
 static void
-nfsd4_run_callback_rpc(struct nfsd4_callback *cb)
+nfsd4_run_cb_work(struct work_struct *work)
 {
+	struct nfsd4_callback *cb =
+		container_of(work, struct nfsd4_callback, cb_work);
 	struct nfs4_client *clp = cb->cb_clp;
 	struct rpc_clnt *clnt;
 
+	if (cb->cb_ops && cb->cb_ops->prepare)
+		cb->cb_ops->prepare(cb);
+
 	if (clp->cl_flags & NFSD4_CLIENT_CB_FLAG_MASK)
 		nfsd4_process_cb_update(cb);
 
 	clnt = clp->cl_cb_client;
 	if (!clnt) {
 		/* Callback channel broken, or client killed; give up: */
-		nfsd4_release_cb(cb);
+		if (cb->cb_ops && cb->cb_ops->release)
+			cb->cb_ops->release(cb);
 		return;
 	}
 	cb->cb_msg.rpc_cred = clp->cl_cb_cred;
 	rpc_call_async(clnt, &cb->cb_msg, RPC_TASK_SOFT | RPC_TASK_SOFTCONN,
-			cb->cb_ops, cb);
-}
-
-void
-nfsd4_run_cb_null(struct work_struct *w)
-{
-	struct nfsd4_callback *cb = container_of(w, struct nfsd4_callback,
-							cb_work);
-	nfsd4_run_callback_rpc(cb);
-}
-
-void
-nfsd4_run_cb_recall(struct work_struct *w)
-{
-	struct nfsd4_callback *cb = container_of(w, struct nfsd4_callback,
-							cb_work);
-
-	nfsd4_prepare_cb_recall(to_delegation(cb));
-	nfsd4_run_callback_rpc(cb);
+			cb->cb_ops ? &nfsd4_cb_ops : &nfsd4_cb_probe_ops, cb);
 }
 
 void nfsd4_init_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
-		enum nfsd4_cb_op op)
+		struct nfsd4_callback_ops *ops, enum nfsd4_cb_op op)
 {
 	cb->cb_clp = clp;
 	cb->cb_msg.rpc_proc = &nfs4_cb_procedures[op];
 	cb->cb_msg.rpc_argp = cb;
 	cb->cb_msg.rpc_resp = cb;
-	if (op == NFSPROC4_CLNT_CB_NULL)
-		cb->cb_ops = &nfsd4_cb_probe_ops;
-	else
-		cb->cb_ops = &nfsd4_cb_recall_ops;
+	cb->cb_ops = ops;
+	INIT_WORK(&cb->cb_work, nfsd4_run_cb_work);
  	INIT_LIST_HEAD(&cb->cb_per_client);
  	cb->cb_done = true;
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5e5012f..cf1ccc4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -96,6 +96,8 @@ static struct kmem_cache *deleg_slab;
 
 static void free_session(struct nfsd4_session *);
 
+static struct nfsd4_callback_ops nfsd4_cb_recall_ops;
+
 static bool is_session_dead(struct nfsd4_session *ses)
 {
 	return ses->se_flags & NFS4_SESSION_DEAD;
@@ -652,8 +654,7 @@ alloc_init_deleg(struct nfs4_client *clp, struct svc_fh *current_fh)
 	dp->dl_type = NFS4_OPEN_DELEGATE_READ;
 	dp->dl_retries = 1;
 	nfsd4_init_cb(&dp->dl_recall, dp->dl_stid.sc_client,
-		 NFSPROC4_CLNT_CB_RECALL);
-	INIT_WORK(&dp->dl_recall.cb_work, nfsd4_run_cb_recall);
+		      &nfsd4_cb_recall_ops, NFSPROC4_CLNT_CB_RECALL);
 	return dp;
 out_dec:
 	atomic_long_dec(&num_delegations);
@@ -1869,8 +1870,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
 		free_client(clp);
 		return NULL;
 	}
-	nfsd4_init_cb(&clp->cl_cb_null, clp, NFSPROC4_CLNT_CB_NULL);
-	INIT_WORK(&clp->cl_cb_null.cb_work, nfsd4_run_cb_null);
+	nfsd4_init_cb(&clp->cl_cb_null, clp, NULL, NFSPROC4_CLNT_CB_NULL);
 	clp->cl_time = get_seconds();
 	clear_bit(0, &clp->cl_cb_slot_busy);
 	copy_verf(clp, verf);
@@ -3355,8 +3355,12 @@ nfs4_share_conflict(struct svc_fh *current_fh, unsigned int deny_type)
 	return ret;
 }
 
-void nfsd4_prepare_cb_recall(struct nfs4_delegation *dp)
+#define cb_to_delegation(cb) \
+	container_of(cb, struct nfs4_delegation, dl_recall)
+
+static void nfsd4_cb_recall_prepare(struct nfsd4_callback *cb)
 {
+	struct nfs4_delegation *dp = cb_to_delegation(cb);
 	struct nfsd_net *nn = net_generic(dp->dl_stid.sc_client->net,
 					  nfsd_net_id);
 
@@ -3377,6 +3381,43 @@ void nfsd4_prepare_cb_recall(struct nfs4_delegation *dp)
 	spin_unlock(&state_lock);
 }
 
+static int nfsd4_cb_recall_done(struct nfsd4_callback *cb,
+		struct rpc_task *task)
+{
+	struct nfs4_delegation *dp = cb_to_delegation(cb);
+
+	switch (task->tk_status) {
+	case 0:
+		return 1;
+	case -EBADHANDLE:
+	case -NFS4ERR_BAD_STATEID:
+		/*
+		 * Race: client probably got cb_recall before open reply
+		 * granting delegation.
+		 */
+		if (dp->dl_retries--) {
+			rpc_delay(task, 2 * HZ);
+			return 0;
+		}
+		/*FALLTHRU*/
+	default:
+		return -1;
+	}
+}
+		
+static void nfsd4_cb_recall_release(struct nfsd4_callback *cb)
+{
+	struct nfs4_delegation *dp = cb_to_delegation(cb);
+
+	nfs4_put_stid(&dp->dl_stid);
+}
+
+static struct nfsd4_callback_ops nfsd4_cb_recall_ops = {
+	.prepare	= nfsd4_cb_recall_prepare,
+	.done		= nfsd4_cb_recall_done,
+	.release	= nfsd4_cb_recall_release,
+};
+
 static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
 {
 	/*
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 4d10e1d..f583ce4 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -66,11 +66,17 @@ struct nfsd4_callback {
 	struct list_head cb_per_client;
 	u32 cb_minorversion;
 	struct rpc_message cb_msg;
-	const struct rpc_call_ops *cb_ops;
+	struct nfsd4_callback_ops *cb_ops;
 	struct work_struct cb_work;
 	bool cb_done;
 };
 
+struct nfsd4_callback_ops {
+	void (*prepare)(struct nfsd4_callback *);
+	int (*done)(struct nfsd4_callback *, struct rpc_task *);
+	void (*release)(struct nfsd4_callback *);
+};
+
 /*
  * A core object that represents a "common" stateid. These are generally
  * embedded within the different (more specific) stateid objects and contain
@@ -536,13 +542,11 @@ extern struct nfs4_client_reclaim *nfsd4_find_reclaim_client(const char *recdir,
 extern __be32 nfs4_check_open_reclaim(clientid_t *clid,
 		struct nfsd4_compound_state *cstate, struct nfsd_net *nn);
 extern int set_callback_cred(void);
-void nfsd4_run_cb_null(struct work_struct *w);
-void nfsd4_run_cb_recall(struct work_struct *w);
 extern void nfsd4_probe_callback(struct nfs4_client *clp);
 extern void nfsd4_probe_callback_sync(struct nfs4_client *clp);
 extern void nfsd4_change_callback(struct nfs4_client *clp, struct nfs4_cb_conn *);
 extern void nfsd4_init_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
-		enum nfsd4_cb_op op);
+		struct nfsd4_callback_ops *ops, enum nfsd4_cb_op op);
 extern void nfsd4_run_cb(struct nfsd4_callback *cb);
 extern int nfsd4_create_callback_queue(void);
 extern void nfsd4_destroy_callback_queue(void);
-- 
1.9.1


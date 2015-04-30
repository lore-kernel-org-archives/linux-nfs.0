Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:51863 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730AbbD3Jui (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2015 05:50:38 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] nfsd: fix callback restarts
Date: Thu, 30 Apr 2015 11:49:24 +0200
Message-Id: <1430387365-24348-3-git-send-email-hch@lst.de>
In-Reply-To: <1430387365-24348-1-git-send-email-hch@lst.de>
References: <1430387365-24348-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Checking the rpc_client pointer is not a reliable way to detect a backchannel
connetion failure, as the likelyhood of reusing the same slab object is
very high.  Check the RPC_TASK_KILLED flag instead, and rewrite the code to
avoid the buggy cl_callbacks list and fix the lifetime rules due to double
calls of the ->prepare callback operations method for this retry case.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4callback.c | 52 ++++++++++++++++++++++----------------------------
 fs/nfsd/nfs4state.c    |  1 -
 fs/nfsd/state.h        |  4 +---
 3 files changed, 24 insertions(+), 33 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index cd58b7c..4c993aa 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -879,13 +879,6 @@ static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
 		if (!nfsd41_cb_get_slot(clp, task))
 			return;
 	}
-	spin_lock(&clp->cl_lock);
-	if (list_empty(&cb->cb_per_client)) {
-		/* This is the first call, not a restart */
-		cb->cb_done = false;
-		list_add(&cb->cb_per_client, &clp->cl_callbacks);
-	}
-	spin_unlock(&clp->cl_lock);
 	rpc_call_start(task);
 }
 
@@ -907,16 +900,21 @@ static void nfsd4_cb_done(struct rpc_task *task, void *calldata)
 			clp->cl_cb_session->se_cb_seq_nr);
 	}
 
-	if (clp->cl_cb_client != task->tk_client) {
-		/* We're shutting down or changing cl_cb_client; leave
-		 * it to nfsd4_process_cb_update to restart the call if
-		 * necessary. */
+	/*
+	 * If the backchannel connection was shut down while this
+	 * task was queued, we need to resubmit it after setting up
+	 * a new backchannel connection.
+	 *
+	 * Note that if we lost our callback connection permanently
+	 * the submission code will error out, so we don't need to
+	 * handle that case here.
+	 */
+	if (task->tk_flags & RPC_TASK_KILLED) {
+		task->tk_status = 0;
+		cb->cb_need_restart = true;
 		return;
 	}
 
-	if (cb->cb_done)
-		return;
-
 	if (cb->cb_status) {
 		WARN_ON_ONCE(task->tk_status);
 		task->tk_status = cb->cb_status;
@@ -936,21 +934,17 @@ static void nfsd4_cb_done(struct rpc_task *task, void *calldata)
 	default:
 		BUG();
 	}
-	cb->cb_done = true;
 }
 
 static void nfsd4_cb_release(void *calldata)
 {
 	struct nfsd4_callback *cb = calldata;
-	struct nfs4_client *clp = cb->cb_clp;
-
-	if (cb->cb_done) {
-		spin_lock(&clp->cl_lock);
-		list_del(&cb->cb_per_client);
-		spin_unlock(&clp->cl_lock);
 
+	if (cb->cb_need_restart)
+		nfsd4_run_cb(cb);
+	else
 		cb->cb_ops->release(cb);
-	}
+
 }
 
 static const struct rpc_call_ops nfsd4_cb_ops = {
@@ -1045,9 +1039,6 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
 		nfsd4_mark_cb_down(clp, err);
 		return;
 	}
-	/* Yay, the callback channel's back! Restart any callbacks: */
-	list_for_each_entry(cb, &clp->cl_callbacks, cb_per_client)
-		queue_work(callback_wq, &cb->cb_work);
 }
 
 static void
@@ -1058,8 +1049,12 @@ nfsd4_run_cb_work(struct work_struct *work)
 	struct nfs4_client *clp = cb->cb_clp;
 	struct rpc_clnt *clnt;
 
-	if (cb->cb_ops && cb->cb_ops->prepare)
-		cb->cb_ops->prepare(cb);
+	if (cb->cb_need_restart) {
+		cb->cb_need_restart = false;
+	} else {
+		if (cb->cb_ops && cb->cb_ops->prepare)
+			cb->cb_ops->prepare(cb);
+	}
 
 	if (clp->cl_flags & NFSD4_CLIENT_CB_FLAG_MASK)
 		nfsd4_process_cb_update(cb);
@@ -1085,9 +1080,8 @@ void nfsd4_init_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
 	cb->cb_msg.rpc_resp = cb;
 	cb->cb_ops = ops;
 	INIT_WORK(&cb->cb_work, nfsd4_run_cb_work);
-	INIT_LIST_HEAD(&cb->cb_per_client);
 	cb->cb_status = 0;
-	cb->cb_done = true;
+	cb->cb_need_restart = false;
 }
 
 void nfsd4_run_cb(struct nfsd4_callback *cb)
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9072964..2bad0a1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1626,7 +1626,6 @@ static struct nfs4_client *alloc_client(struct xdr_netobj name)
 	INIT_LIST_HEAD(&clp->cl_openowners);
 	INIT_LIST_HEAD(&clp->cl_delegations);
 	INIT_LIST_HEAD(&clp->cl_lru);
-	INIT_LIST_HEAD(&clp->cl_callbacks);
 	INIT_LIST_HEAD(&clp->cl_revoked);
 #ifdef CONFIG_NFSD_PNFS
 	INIT_LIST_HEAD(&clp->cl_lo_states);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index e791985..dbc4f85 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -63,13 +63,12 @@ typedef struct {
 
 struct nfsd4_callback {
 	struct nfs4_client *cb_clp;
-	struct list_head cb_per_client;
 	u32 cb_minorversion;
 	struct rpc_message cb_msg;
 	struct nfsd4_callback_ops *cb_ops;
 	struct work_struct cb_work;
 	int cb_status;
-	bool cb_done;
+	bool cb_need_restart;
 };
 
 struct nfsd4_callback_ops {
@@ -334,7 +333,6 @@ struct nfs4_client {
 	int			cl_cb_state;
 	struct nfsd4_callback	cl_cb_null;
 	struct nfsd4_session	*cl_cb_session;
-	struct list_head	cl_callbacks; /* list of in-progress callbacks */
 
 	/* for all client information that callback code might need: */
 	spinlock_t		cl_lock;
-- 
1.9.1


From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 7/8] nfsd4: rearrange cb data structures
Date: Thu,  8 Apr 2010 11:59:21 -0400
Message-ID: <1270742362-9375-8-git-send-email-bfields@citi.umich.edu>
References: <1270742362-9375-1-git-send-email-bfields@citi.umich.edu>
 <1270742362-9375-2-git-send-email-bfields@citi.umich.edu>
 <1270742362-9375-3-git-send-email-bfields@citi.umich.edu>
 <1270742362-9375-4-git-send-email-bfields@citi.umich.edu>
 <1270742362-9375-5-git-send-email-bfields@citi.umich.edu>
 <1270742362-9375-6-git-send-email-bfields@citi.umich.edu>
 <1270742362-9375-7-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52056 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932756Ab0DHP4z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Apr 2010 11:56:55 -0400
In-Reply-To: <1270742362-9375-7-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mainly I just want to separate the arguments used for setting up the tcp
client from the rest.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |   25 ++++++++++++-------------
 fs/nfsd/nfs4state.c    |   20 ++++++++++----------
 fs/nfsd/state.h        |   11 ++++++-----
 3 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 5856fc8..d6c46a9 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -455,7 +455,7 @@ static int max_cb_time(void)
 }
 
 /* Reference counting, callback cleanup, etc., all look racy as heck.
- * And why is cb_set an atomic? */
+ * And why is cl_cb_set an atomic? */
 
 int setup_callback_client(struct nfs4_client *clp)
 {
@@ -481,7 +481,7 @@ int setup_callback_client(struct nfs4_client *clp)
 	if (!clp->cl_principal && (clp->cl_flavor >= RPC_AUTH_GSS_KRB5))
 		return -EINVAL;
 	if (cb->cb_minorversion) {
-		args.bc_xprt = clp->cl_cb_xprt;
+		args.bc_xprt = clp->cl_cb_conn.cb_xprt;
 		args.protocol = XPRT_TRANSPORT_BC_TCP;
 	}
 	/* Create RPC client */
@@ -491,7 +491,7 @@ int setup_callback_client(struct nfs4_client *clp)
 			PTR_ERR(client));
 		return PTR_ERR(client);
 	}
-	cb->cb_client = client;
+	clp->cl_cb_client = client;
 	return 0;
 
 }
@@ -509,7 +509,7 @@ static void nfsd4_cb_probe_done(struct rpc_task *task, void *calldata)
 	if (task->tk_status)
 		warn_no_callback_path(clp, task->tk_status);
 	else
-		atomic_set(&clp->cl_cb_conn.cb_set, 1);
+		atomic_set(&clp->cl_cb_set, 1);
 }
 
 static const struct rpc_call_ops nfsd4_cb_probe_ops = {
@@ -531,7 +531,6 @@ int set_callback_cred(void)
 
 void do_probe_callback(struct nfs4_client *clp)
 {
-	struct nfs4_cb_conn *cb = &clp->cl_cb_conn;
 	struct rpc_message msg = {
 		.rpc_proc       = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
 		.rpc_argp       = clp,
@@ -539,7 +538,7 @@ void do_probe_callback(struct nfs4_client *clp)
 	};
 	int status;
 
-	status = rpc_call_async(cb->cb_client, &msg,
+	status = rpc_call_async(clp->cl_cb_client, &msg,
 				RPC_TASK_SOFT | RPC_TASK_SOFTCONN,
 				&nfsd4_cb_probe_ops, (void *)clp);
 	if (status)
@@ -554,7 +553,7 @@ nfsd4_probe_callback(struct nfs4_client *clp)
 {
 	int status;
 
-	BUG_ON(atomic_read(&clp->cl_cb_conn.cb_set));
+	BUG_ON(atomic_read(&clp->cl_cb_set));
 
 	status = setup_callback_client(clp);
 	if (status) {
@@ -656,7 +655,7 @@ static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
 	switch (task->tk_status) {
 	case -EIO:
 		/* Network partition? */
-		atomic_set(&clp->cl_cb_conn.cb_set, 0);
+		atomic_set(&clp->cl_cb_set, 0);
 		warn_no_callback_path(clp, task->tk_status);
 	case -EBADHANDLE:
 	case -NFS4ERR_BAD_STATEID:
@@ -673,7 +672,7 @@ static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
 		rpc_restart_call(task);
 		return;
 	} else {
-		atomic_set(&clp->cl_cb_conn.cb_set, 0);
+		atomic_set(&clp->cl_cb_set, 0);
 		warn_no_callback_path(clp, task->tk_status);
 	}
 }
@@ -709,11 +708,11 @@ void nfsd4_destroy_callback_queue(void)
 void nfsd4_set_callback_client(struct nfs4_client *clp, struct rpc_clnt
 *new)
 {
-	struct rpc_clnt *old = clp->cl_cb_conn.cb_client;
+	struct rpc_clnt *old = clp->cl_cb_client;
 
-	clp->cl_cb_conn.cb_client = new;
+	clp->cl_cb_client = new;
 	/*
-	 * After this, any work that saw the old value of cb_client will
+	 * After this, any work that saw the old value of cl_cb_client will
 	 * be gone:
 	 */
 	flush_workqueue(callback_wq);
@@ -728,7 +727,7 @@ void nfsd4_set_callback_client(struct nfs4_client *clp, struct rpc_clnt
 static void _nfsd4_cb_recall(struct nfs4_delegation *dp)
 {
 	struct nfs4_client *clp = dp->dl_client;
-	struct rpc_clnt *clnt = clp->cl_cb_conn.cb_client;
+	struct rpc_clnt *clnt = clp->cl_cb_client;
 	struct nfs4_rpc_args *args = &dp->dl_recall.cb_args;
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_RECALL],
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d72ea98..efb85ca 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -726,8 +726,8 @@ expire_client(struct nfs4_client *clp)
 		release_session(ses);
 	}
 	nfsd4_set_callback_client(clp, NULL);
-	if (clp->cl_cb_xprt)
-		svc_xprt_put(clp->cl_cb_xprt);
+	if (clp->cl_cb_conn.cb_xprt)
+		svc_xprt_put(clp->cl_cb_conn.cb_xprt);
 	free_client(clp);
 }
 
@@ -814,7 +814,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
 	}
 
 	memcpy(clp->cl_recdir, recdir, HEXDIR_LEN);
-	atomic_set(&clp->cl_cb_conn.cb_set, 0);
+	atomic_set(&clp->cl_cb_set, 0);
 	INIT_LIST_HEAD(&clp->cl_idhash);
 	INIT_LIST_HEAD(&clp->cl_strhash);
 	INIT_LIST_HEAD(&clp->cl_openowners);
@@ -1308,8 +1308,8 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		cr_ses->flags &= ~SESSION4_RDMA;
 
 		if (cr_ses->flags & SESSION4_BACK_CHAN) {
-			unconf->cl_cb_xprt = rqstp->rq_xprt;
-			svc_xprt_get(unconf->cl_cb_xprt);
+			unconf->cl_cb_conn.cb_xprt = rqstp->rq_xprt;
+			svc_xprt_get(rqstp->rq_xprt);
 			rpc_copy_addr(
 				(struct sockaddr *)&unconf->cl_cb_conn.cb_addr,
 				sa);
@@ -1607,7 +1607,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		else {
 			/* XXX: We just turn off callbacks until we can handle
 			  * change request correctly. */
-			atomic_set(&conf->cl_cb_conn.cb_set, 0);
+			atomic_set(&conf->cl_cb_set, 0);
 			expire_client(unconf);
 			status = nfs_ok;
 
@@ -2320,7 +2320,7 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_sta
 {
 	struct nfs4_delegation *dp;
 	struct nfs4_stateowner *sop = stp->st_stateowner;
-	struct nfs4_cb_conn *cb = &sop->so_client->cl_cb_conn;
+	int cb_up = atomic_read(&sop->so_client->cl_cb_set);
 	struct file_lock fl, *flp = &fl;
 	int status, flag = 0;
 
@@ -2328,7 +2328,7 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_sta
 	open->op_recall = 0;
 	switch (open->op_claim_type) {
 		case NFS4_OPEN_CLAIM_PREVIOUS:
-			if (!atomic_read(&cb->cb_set))
+			if (!cb_up)
 				open->op_recall = 1;
 			flag = open->op_delegate_type;
 			if (flag == NFS4_OPEN_DELEGATE_NONE)
@@ -2339,7 +2339,7 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_sta
 			 * had the chance to reclaim theirs.... */
 			if (locks_in_grace())
 				goto out;
-			if (!atomic_read(&cb->cb_set) || !sop->so_confirmed)
+			if (!cb_up || !sop->so_confirmed)
 				goto out;
 			if (open->op_share_access & NFS4_SHARE_ACCESS_WRITE)
 				flag = NFS4_OPEN_DELEGATE_WRITE;
@@ -2510,7 +2510,7 @@ nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	renew_client(clp);
 	status = nfserr_cb_path_down;
 	if (!list_empty(&clp->cl_delegations)
-			&& !atomic_read(&clp->cl_cb_conn.cb_set))
+			&& !atomic_read(&clp->cl_cb_set))
 		goto out;
 	status = nfs_ok;
 out:
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index cef20ab..cf43812 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -107,9 +107,7 @@ struct nfs4_cb_conn {
 	u32                     cb_prog;
 	u32			cb_minorversion;
 	u32                     cb_ident;	/* minorversion 0 only */
-	/* RPC client info */
-	atomic_t		cb_set;     /* successful CB_NULL call */
-	struct rpc_clnt *       cb_client;
+	struct svc_xprt		*cb_xprt;	/* minorversion 1 only */
 };
 
 /* Maximum number of slots per session. 160 is useful for long haul TCP */
@@ -223,9 +221,13 @@ struct nfs4_client {
 	struct svc_cred		cl_cred; 	/* setclientid principal */
 	clientid_t		cl_clientid;	/* generated by server */
 	nfs4_verifier		cl_confirm;	/* generated by server */
-	struct nfs4_cb_conn	cl_cb_conn;     /* callback info */
 	u32			cl_firststate;	/* recovery dir creation */
 
+	/* for v4.0 and v4.1 callbacks: */
+	struct nfs4_cb_conn	cl_cb_conn;
+	struct rpc_clnt		*cl_cb_client;
+	atomic_t		cl_cb_set;
+
 	/* for nfs41 */
 	struct list_head	cl_sessions;
 	struct nfsd4_clid_slot	cl_cs_slot;	/* create_session slot */
@@ -236,7 +238,6 @@ struct nfs4_client {
 	/* We currently support a single back channel with a single slot */
 	unsigned long		cl_cb_slot_busy;
 	u32			cl_cb_seq_nr;
-	struct svc_xprt		*cl_cb_xprt;	/* 4.1 callback transport */
 	struct rpc_wait_queue	cl_cb_waitq;	/* backchannel callers may */
 						/* wait here for slots */
 };
-- 
1.6.3.3


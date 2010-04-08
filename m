From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 8/8] nfsd4: allow 4.0 clients to change callback path
Date: Thu,  8 Apr 2010 11:59:22 -0400
Message-ID: <1270742362-9375-9-git-send-email-bfields@citi.umich.edu>
References: <1270742362-9375-1-git-send-email-bfields@citi.umich.edu>
 <1270742362-9375-2-git-send-email-bfields@citi.umich.edu>
 <1270742362-9375-3-git-send-email-bfields@citi.umich.edu>
 <1270742362-9375-4-git-send-email-bfields@citi.umich.edu>
 <1270742362-9375-5-git-send-email-bfields@citi.umich.edu>
 <1270742362-9375-6-git-send-email-bfields@citi.umich.edu>
 <1270742362-9375-7-git-send-email-bfields@citi.umich.edu>
 <1270742362-9375-8-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52058 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932656Ab0DHP44 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Apr 2010 11:56:56 -0400
In-Reply-To: <1270742362-9375-8-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The rfc allows a client to change the callback parameters, but we didn't
previously implement it.

Teach the callbacks to rerun themselves (by placing themselves on a
workqueue) when they recognize that their rpc task has been killed and
that the callback connection has changed.

Then we can change the callback connection by setting up a new rpc
client, modifying the nfs4 client to point at it, waiting for any work
in progress to complete, and then shutting down the old client.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |   29 ++++++++++++++++++++---------
 fs/nfsd/nfs4state.c    |    7 +++----
 fs/nfsd/state.h        |    2 +-
 3 files changed, 24 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index d6c46a9..ea77aa6 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -457,9 +457,8 @@ static int max_cb_time(void)
 /* Reference counting, callback cleanup, etc., all look racy as heck.
  * And why is cl_cb_set an atomic? */
 
-int setup_callback_client(struct nfs4_client *clp)
+int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *cb)
 {
-	struct nfs4_cb_conn *cb = &clp->cl_cb_conn;
 	struct rpc_timeout	timeparms = {
 		.to_initval	= max_cb_time(),
 		.to_retries	= 0,
@@ -481,7 +480,7 @@ int setup_callback_client(struct nfs4_client *clp)
 	if (!clp->cl_principal && (clp->cl_flavor >= RPC_AUTH_GSS_KRB5))
 		return -EINVAL;
 	if (cb->cb_minorversion) {
-		args.bc_xprt = clp->cl_cb_conn.cb_xprt;
+		args.bc_xprt = cb->cb_xprt;
 		args.protocol = XPRT_TRANSPORT_BC_TCP;
 	}
 	/* Create RPC client */
@@ -491,7 +490,7 @@ int setup_callback_client(struct nfs4_client *clp)
 			PTR_ERR(client));
 		return PTR_ERR(client);
 	}
-	clp->cl_cb_client = client;
+	nfsd4_set_callback_client(clp, client);
 	return 0;
 
 }
@@ -548,14 +547,13 @@ void do_probe_callback(struct nfs4_client *clp)
 /*
  * Set up the callback client and put a NFSPROC4_CB_NULL on the wire...
  */
-void
-nfsd4_probe_callback(struct nfs4_client *clp)
+void nfsd4_probe_callback(struct nfs4_client *clp, struct nfs4_cb_conn *cb)
 {
 	int status;
 
 	BUG_ON(atomic_read(&clp->cl_cb_set));
 
-	status = setup_callback_client(clp);
+	status = setup_callback_client(clp, cb);
 	if (status) {
 		warn_no_callback_path(clp, status);
 		return;
@@ -645,18 +643,32 @@ static void nfsd4_cb_done(struct rpc_task *task, void *calldata)
 	}
 }
 
+
 static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_delegation *dp = calldata;
 	struct nfs4_client *clp = dp->dl_client;
+	struct rpc_clnt *current_rpc_client = clp->cl_cb_client;
 
 	nfsd4_cb_done(task, calldata);
 
+	if (current_rpc_client == NULL) {
+		/* We're shutting down; give up. */
+		/* XXX: err, or is it ok just to fall through
+		 * and rpc_restart_call? */
+		return;
+	}
+
 	switch (task->tk_status) {
 	case -EIO:
 		/* Network partition? */
 		atomic_set(&clp->cl_cb_set, 0);
 		warn_no_callback_path(clp, task->tk_status);
+		if (current_rpc_client != task->tk_client) {
+			/* queue a callback on the new connection: */
+			nfsd4_cb_recall(dp);
+			return;
+		}
 	case -EBADHANDLE:
 	case -NFS4ERR_BAD_STATEID:
 		/* Race: client probably got cb_recall
@@ -705,8 +717,7 @@ void nfsd4_destroy_callback_queue(void)
 	destroy_workqueue(callback_wq);
 }
 
-void nfsd4_set_callback_client(struct nfs4_client *clp, struct rpc_clnt
-*new)
+void nfsd4_set_callback_client(struct nfs4_client *clp, struct rpc_clnt *new)
 {
 	struct rpc_clnt *old = clp->cl_cb_client;
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index efb85ca..378ce9b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1318,7 +1318,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 				cstate->minorversion;
 			unconf->cl_cb_conn.cb_prog = cr_ses->callback_prog;
 			unconf->cl_cb_seq_nr = 1;
-			nfsd4_probe_callback(unconf);
+			nfsd4_probe_callback(unconf, &unconf->cl_cb_conn);
 		}
 		conf = unconf;
 	} else {
@@ -1605,9 +1605,8 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		if (!same_creds(&conf->cl_cred, &unconf->cl_cred))
 			status = nfserr_clid_inuse;
 		else {
-			/* XXX: We just turn off callbacks until we can handle
-			  * change request correctly. */
 			atomic_set(&conf->cl_cb_set, 0);
+			nfsd4_probe_callback(conf, &unconf->cl_cb_conn);
 			expire_client(unconf);
 			status = nfs_ok;
 
@@ -1641,7 +1640,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 			}
 			move_to_confirmed(unconf);
 			conf = unconf;
-			nfsd4_probe_callback(conf);
+			nfsd4_probe_callback(conf, &conf->cl_cb_conn);
 			status = nfs_ok;
 		}
 	} else if ((!conf || (conf && !same_verf(&conf->cl_confirm, &confirm)))
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index cf43812..98836fd 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -390,7 +390,7 @@ extern int nfs4_in_grace(void);
 extern __be32 nfs4_check_open_reclaim(clientid_t *clid);
 extern void nfs4_free_stateowner(struct kref *kref);
 extern int set_callback_cred(void);
-extern void nfsd4_probe_callback(struct nfs4_client *clp);
+extern void nfsd4_probe_callback(struct nfs4_client *clp, struct nfs4_cb_conn *);
 extern void nfsd4_do_callback_rpc(struct work_struct *);
 extern void nfsd4_cb_recall(struct nfs4_delegation *dp);
 extern int nfsd4_create_callback_queue(void);
-- 
1.6.3.3


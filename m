From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 4/4] nfsd4: use common rpc_cred for all callbacks
Date: Tue, 15 Sep 2009 21:07:58 -0400
Message-ID: <1253063278-30137-4-git-send-email-bfields@citi.umich.edu>
References: <20090916010604.GA29397@fieldses.org>
 <1253063278-30137-1-git-send-email-bfields@citi.umich.edu>
 <1253063278-30137-2-git-send-email-bfields@citi.umich.edu>
 <1253063278-30137-3-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33114 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752329AbZIPBHy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Sep 2009 21:07:54 -0400
In-Reply-To: <1253063278-30137-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Callbacks are always made using the machine's identity, so we can use a
single auth_generic credential shared among callbacks to all clients and
let the rpc code take care of the rest.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c     |   33 ++++++++++-----------------------
 fs/nfsd/nfs4state.c        |    6 +-----
 include/linux/nfsd/state.h |    2 +-
 3 files changed, 12 insertions(+), 29 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 4abb882..1285197 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -432,42 +432,29 @@ static const struct rpc_call_ops nfsd4_cb_probe_ops = {
 	.rpc_call_done = nfsd4_cb_probe_done,
 };
 
-static struct rpc_cred *lookup_cb_cred(struct nfs4_cb_conn *cb)
+static struct rpc_cred *callback_cred;
+
+int set_callback_cred(void)
 {
-	struct auth_cred acred = {
-		.machine_cred = 1
-	};
-	struct rpc_auth *auth = cb->cb_client->cl_auth;
-
-	/*
-	 * Note in the gss case this doesn't actually have to wait for a
-	 * gss upcall (or any calls to the client); this just creates a
-	 * non-uptodate cred which the rpc state machine will fill in with
-	 * a refresh_upcall later.
-	 */
-	return auth->au_ops->lookup_cred(auth, &acred, RPCAUTH_LOOKUP_NEW);
+	callback_cred = rpc_lookup_machine_cred();
+	if (!callback_cred)
+		return -ENOMEM;
+	return 0;
 }
 
+
 void do_probe_callback(struct nfs4_client *clp)
 {
 	struct nfs4_cb_conn *cb = &clp->cl_cb_conn;
 	struct rpc_message msg = {
 		.rpc_proc       = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
 		.rpc_argp       = clp,
+		.rpc_cred	= callback_cred
 	};
-	struct rpc_cred *cred;
 	int status;
 
-	cred = lookup_cb_cred(cb);
-	if (IS_ERR(cred)) {
-		status = PTR_ERR(cred);
-		goto out;
-	}
-	cb->cb_cred = cred;
-	msg.rpc_cred = cb->cb_cred;
 	status = rpc_call_async(cb->cb_client, &msg, RPC_TASK_SOFT,
 				&nfsd4_cb_probe_ops, (void *)clp);
-out:
 	if (status) {
 		warn_no_callback_path(clp, status);
 		put_nfs4_client(clp);
@@ -550,7 +537,7 @@ nfsd4_cb_recall(struct nfs4_delegation *dp)
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_RECALL],
 		.rpc_argp = dp,
-		.rpc_cred = clp->cl_cb_conn.cb_cred
+		.rpc_cred = callback_cred
 	};
 	int status;
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 11db40c..0445192 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -696,10 +696,6 @@ shutdown_callback_client(struct nfs4_client *clp)
 		clp->cl_cb_conn.cb_client = NULL;
 		rpc_shutdown_client(clnt);
 	}
-	if (clp->cl_cb_conn.cb_cred) {
-		put_rpccred(clp->cl_cb_conn.cb_cred);
-		clp->cl_cb_conn.cb_cred = NULL;
-	}
 }
 
 static inline void
@@ -4020,7 +4016,7 @@ __nfs4_state_start(void)
 		return -ENOMEM;
 	queue_delayed_work(laundry_wq, &laundromat_work, grace_time);
 	set_max_delegations();
-	return 0;
+	return set_callback_cred();
 }
 
 int
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 70ef5f4..9bf3aa8 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -89,7 +89,6 @@ struct nfs4_cb_conn {
 	/* RPC client info */
 	atomic_t		cb_set;     /* successful CB_NULL call */
 	struct rpc_clnt *       cb_client;
-	struct rpc_cred	*	cb_cred;
 };
 
 /* Maximum number of slots per session. 160 is useful for long haul TCP */
@@ -362,6 +361,7 @@ extern int nfs4_in_grace(void);
 extern __be32 nfs4_check_open_reclaim(clientid_t *clid);
 extern void put_nfs4_client(struct nfs4_client *clp);
 extern void nfs4_free_stateowner(struct kref *kref);
+extern int set_callback_cred(void);
 extern void nfsd4_probe_callback(struct nfs4_client *clp);
 extern void nfsd4_cb_recall(struct nfs4_delegation *dp);
 extern void nfs4_put_delegation(struct nfs4_delegation *dp);
-- 
1.6.0.4


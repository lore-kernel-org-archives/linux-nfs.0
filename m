Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57233 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754404Ab2KHAo1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Nov 2012 19:44:27 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/5] nfsd4: use callback security parameters in create_session
Date: Wed,  7 Nov 2012 19:44:20 -0500
Message-Id: <1352335463-29084-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1352335463-29084-1-git-send-email-bfields@redhat.com>
References: <1352335463-29084-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We're currently ignoring the callback security parameters specified in
create_session, and just assuming the client wants auth_sys, because
that's all the current linux client happens to care about.  But this
could cause us callbacks to fail to a client that wanted something
different.

For now, all we're doing is no longer ignoring the uid and gid passed in
the auth_sys case.  Further patches will add support for auth_null and
gss (and possibly use more of the auth_sys information; the spec wants
us to use exactly the credential we're passed, though it's hard to
imagine why a client would care).

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4callback.c |   49 ++++++++++++++++++++++++++++++++++--------------
 fs/nfsd/nfs4state.c    |    1 +
 fs/nfsd/state.h        |    1 +
 3 files changed, 37 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index bdf29c9..b32639e 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -630,6 +630,31 @@ static int max_cb_time(void)
 	return max(nfsd4_lease/10, (time_t)1) * HZ;
 }
 
+static struct rpc_cred *callback_cred;
+
+int set_callback_cred(void)
+{
+	if (callback_cred)
+		return 0;
+	callback_cred = rpc_lookup_machine_cred("nfs");
+	if (!callback_cred)
+		return -ENOMEM;
+	return 0;
+}
+
+struct rpc_cred *get_backchannel_cred(struct nfs4_client *clp, struct rpc_clnt *client, struct nfsd4_session *ses)
+{
+	if (clp->cl_minorversion == 0) {
+		return get_rpccred(callback_cred);
+	} else {
+		struct rpc_auth *auth = client->cl_auth;
+		struct auth_cred acred = {};
+
+		acred.uid = ses->se_cb_sec.uid;
+		acred.gid = ses->se_cb_sec.gid;
+		return auth->au_ops->lookup_cred(client->cl_auth, &acred, 0);
+	}
+}
 
 static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *conn, struct nfsd4_session *ses)
 {
@@ -648,6 +673,7 @@ static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *c
 		.flags		= (RPC_CLNT_CREATE_NOPING | RPC_CLNT_CREATE_QUIET),
 	};
 	struct rpc_clnt *client;
+	struct rpc_cred *cred;
 
 	if (clp->cl_minorversion == 0) {
 		if (!clp->cl_cred.cr_principal &&
@@ -675,7 +701,13 @@ static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *c
 			PTR_ERR(client));
 		return PTR_ERR(client);
 	}
+	cred = get_backchannel_cred(clp, client, ses);
+	if (IS_ERR(cred)) {
+		rpc_shutdown_client(client);
+		return PTR_ERR(cred);
+	}
 	clp->cl_cb_client = client;
+	clp->cl_cb_cred = cred;
 	return 0;
 
 }
@@ -714,18 +746,6 @@ static const struct rpc_call_ops nfsd4_cb_probe_ops = {
 	.rpc_call_done = nfsd4_cb_probe_done,
 };
 
-static struct rpc_cred *callback_cred;
-
-int set_callback_cred(void)
-{
-	if (callback_cred)
-		return 0;
-	callback_cred = rpc_lookup_machine_cred("nfs");
-	if (!callback_cred)
-		return -ENOMEM;
-	return 0;
-}
-
 static struct workqueue_struct *callback_wq;
 
 static void run_nfsd4_cb(struct nfsd4_callback *cb)
@@ -743,7 +763,6 @@ static void do_probe_callback(struct nfs4_client *clp)
 	cb->cb_msg.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL];
 	cb->cb_msg.rpc_argp = NULL;
 	cb->cb_msg.rpc_resp = NULL;
-	cb->cb_msg.rpc_cred = callback_cred;
 
 	cb->cb_ops = &nfsd4_cb_probe_ops;
 
@@ -962,6 +981,8 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
 	if (clp->cl_cb_client) {
 		rpc_shutdown_client(clp->cl_cb_client);
 		clp->cl_cb_client = NULL;
+		put_rpccred(clp->cl_cb_cred);
+		clp->cl_cb_cred = NULL;
 	}
 	if (clp->cl_cb_conn.cb_xprt) {
 		svc_xprt_put(clp->cl_cb_conn.cb_xprt);
@@ -1010,6 +1031,7 @@ void nfsd4_do_callback_rpc(struct work_struct *w)
 		nfsd4_release_cb(cb);
 		return;
 	}
+	cb->cb_msg.rpc_cred = clp->cl_cb_cred;
 	rpc_call_async(clnt, &cb->cb_msg, RPC_TASK_SOFT | RPC_TASK_SOFTCONN,
 			cb->cb_ops, cb);
 }
@@ -1025,7 +1047,6 @@ void nfsd4_cb_recall(struct nfs4_delegation *dp)
 	cb->cb_msg.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_RECALL];
 	cb->cb_msg.rpc_argp = cb;
 	cb->cb_msg.rpc_resp = cb;
-	cb->cb_msg.rpc_cred = callback_cred;
 
 	cb->cb_ops = &nfsd4_cb_recall_ops;
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index db7258c..dbbbd2f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -957,6 +957,7 @@ void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, struct nfs4
 	new->se_cb_seq_nr = 1;
 	new->se_flags = cses->flags;
 	new->se_cb_prog = cses->callback_prog;
+	new->se_cb_sec = cses->cb_sec;
 	kref_init(&new->se_ref);
 	idx = hash_sessionid(&new->se_sessionid);
 	spin_lock(&client_lock);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index df33e78..bff856c 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -250,6 +250,7 @@ struct nfs4_client {
 #define NFSD4_CLIENT_CB_FLAG_MASK	(1 << NFSD4_CLIENT_CB_UPDATE | \
 					 1 << NFSD4_CLIENT_CB_KILL)
 	unsigned long		cl_flags;
+	struct rpc_cred		*cl_cb_cred;
 	struct rpc_clnt		*cl_cb_client;
 	u32			cl_cb_ident;
 #define NFSD4_CB_UP		0
-- 
1.7.9.5


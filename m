Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:26475 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754261Ab2EZSkY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 26 May 2012 14:40:24 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 6/9] NFSv4.1: Ensure we use the correct credentials for session create/destroy
Date: Sat, 26 May 2012 14:39:57 -0400
Message-Id: <1338057600-11130-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1338057600-11130-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1338057600-11130-1-git-send-email-Trond.Myklebust@netapp.com>
 <1338057600-11130-2-git-send-email-Trond.Myklebust@netapp.com>
 <1338057600-11130-3-git-send-email-Trond.Myklebust@netapp.com>
 <1338057600-11130-4-git-send-email-Trond.Myklebust@netapp.com>
 <1338057600-11130-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h   |    4 ++--
 fs/nfs/nfs4proc.c  |   27 +++++++++++++++++----------
 fs/nfs/nfs4state.c |   10 +++++++---
 3 files changed, 26 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 5fcb1ad..a5dbe62 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -241,8 +241,8 @@ extern int nfs41_setup_sequence(struct nfs4_session *session,
 		struct rpc_task *task);
 extern void nfs4_destroy_session(struct nfs4_session *session);
 extern struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp);
-extern int nfs4_proc_create_session(struct nfs_client *);
-extern int nfs4_proc_destroy_session(struct nfs4_session *);
+extern int nfs4_proc_create_session(struct nfs_client *, struct rpc_cred *);
+extern int nfs4_proc_destroy_session(struct nfs4_session *, struct rpc_cred *);
 extern int nfs4_init_session(struct nfs_server *server);
 extern int nfs4_proc_get_lease_time(struct nfs_client *clp,
 		struct nfs_fsinfo *fsinfo);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f8817e8..8fa3a36 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5480,8 +5480,12 @@ struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
 void nfs4_destroy_session(struct nfs4_session *session)
 {
 	struct rpc_xprt *xprt;
+	struct rpc_cred *cred;
 
-	nfs4_proc_destroy_session(session);
+	cred = nfs4_get_exchange_id_cred(session->clp);
+	nfs4_proc_destroy_session(session, cred);
+	if (cred)
+		put_rpccred(cred);
 
 	rcu_read_lock();
 	xprt = rcu_dereference(session->clp->cl_rpcclient->cl_xprt);
@@ -5591,7 +5595,8 @@ static int nfs4_verify_channel_attrs(struct nfs41_create_session_args *args,
 	return nfs4_verify_back_channel_attrs(args, session);
 }
 
-static int _nfs4_proc_create_session(struct nfs_client *clp)
+static int _nfs4_proc_create_session(struct nfs_client *clp,
+		struct rpc_cred *cred)
 {
 	struct nfs4_session *session = clp->cl_session;
 	struct nfs41_create_session_args args = {
@@ -5605,6 +5610,7 @@ static int _nfs4_proc_create_session(struct nfs_client *clp)
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_CREATE_SESSION],
 		.rpc_argp = &args,
 		.rpc_resp = &res,
+		.rpc_cred = cred,
 	};
 	int status;
 
@@ -5629,7 +5635,7 @@ static int _nfs4_proc_create_session(struct nfs_client *clp)
  * It is the responsibility of the caller to verify the session is
  * expired before calling this routine.
  */
-int nfs4_proc_create_session(struct nfs_client *clp)
+int nfs4_proc_create_session(struct nfs_client *clp, struct rpc_cred *cred)
 {
 	int status;
 	unsigned *ptr;
@@ -5637,7 +5643,7 @@ int nfs4_proc_create_session(struct nfs_client *clp)
 
 	dprintk("--> %s clp=%p session=%p\n", __func__, clp, session);
 
-	status = _nfs4_proc_create_session(clp);
+	status = _nfs4_proc_create_session(clp, cred);
 	if (status)
 		goto out;
 
@@ -5659,10 +5665,15 @@ out:
  * Issue the over-the-wire RPC DESTROY_SESSION.
  * The caller must serialize access to this routine.
  */
-int nfs4_proc_destroy_session(struct nfs4_session *session)
+int nfs4_proc_destroy_session(struct nfs4_session *session,
+		struct rpc_cred *cred)
 {
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_DESTROY_SESSION],
+		.rpc_argp = session,
+		.rpc_cred = cred,
+	};
 	int status = 0;
-	struct rpc_message msg;
 
 	dprintk("--> nfs4_proc_destroy_session\n");
 
@@ -5670,10 +5681,6 @@ int nfs4_proc_destroy_session(struct nfs4_session *session)
 	if (session->clp->cl_cons_state != NFS_CS_READY)
 		return status;
 
-	msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_DESTROY_SESSION];
-	msg.rpc_argp = session;
-	msg.rpc_resp = NULL;
-	msg.rpc_cred = NULL;
 	status = rpc_call_sync(session->clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
 
 	if (status)
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 419f8c4..1587840 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -256,7 +256,7 @@ int nfs41_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
 		goto out;
 	set_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
 do_confirm:
-	status = nfs4_proc_create_session(clp);
+	status = nfs4_proc_create_session(clp, cred);
 	if (status != 0)
 		goto out;
 	clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
@@ -1717,10 +1717,12 @@ void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags)
 
 static int nfs4_reset_session(struct nfs_client *clp)
 {
+	struct rpc_cred *cred;
 	int status;
 
 	nfs4_begin_drain_session(clp);
-	status = nfs4_proc_destroy_session(clp->cl_session);
+	cred = nfs4_get_exchange_id_cred(clp);
+	status = nfs4_proc_destroy_session(clp->cl_session, cred);
 	if (status && status != -NFS4ERR_BADSESSION &&
 	    status != -NFS4ERR_DEADSESSION) {
 		status = nfs4_recovery_handle_error(clp, status);
@@ -1728,7 +1730,7 @@ static int nfs4_reset_session(struct nfs_client *clp)
 	}
 
 	memset(clp->cl_session->sess_id.data, 0, NFS4_MAX_SESSIONID_LEN);
-	status = nfs4_proc_create_session(clp);
+	status = nfs4_proc_create_session(clp, cred);
 	if (status) {
 		status = nfs4_recovery_handle_error(clp, status);
 		goto out;
@@ -1742,6 +1744,8 @@ static int nfs4_reset_session(struct nfs_client *clp)
 	if (!test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state))
 		nfs41_setup_state_renewal(clp);
 out:
+	if (cred)
+		put_rpccred(cred);
 	return status;
 }
 
-- 
1.7.7.6


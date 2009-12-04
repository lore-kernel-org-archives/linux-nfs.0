From: andros@netapp.com
Subject: [PATCH 01/11] nfs41: add create session into establish_clid
Date: Fri,  4 Dec 2009 15:25:36 -0500
Message-ID: <1259958347-9031-2-git-send-email-andros@netapp.com>
References: <1259958347-9031-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56650 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757214AbZLDUZx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Dec 2009 15:25:53 -0500
In-Reply-To: <1259958347-9031-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Reported-by: Trond Myklebust <trond.myklebust@netapp.com>

Resetting the clientid from the state manager could result in not confirming
the clientid due to create session not being called.

Move the create session call from the NFS4CLNT_SESSION_SETUP state manager
initialize session case into the NFS4CLNT_LEASE_EXPIRED case establish_clid
call.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4_fs.h   |    2 ++
 fs/nfs/nfs4proc.c  |    7 +++----
 fs/nfs/nfs4state.c |   35 ++++++++++++++---------------------
 3 files changed, 19 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 6ea07a3..99d507d 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -200,9 +200,11 @@ extern ssize_t nfs4_listxattr(struct dentry *, char *, size_t);
 /* nfs4proc.c */
 extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struct rpc_cred *);
 extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct rpc_cred *);
+extern int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred);
 extern int nfs4_proc_async_renew(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_proc_renew(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_init_clientid(struct nfs_client *, struct rpc_cred *);
+extern int nfs41_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait);
 extern struct dentry *nfs4_atomic_open(struct inode *, struct dentry *, struct nameidata *);
 extern int nfs4_open_revalidate(struct inode *, struct dentry *, int, struct nameidata *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 741a562..5c24b4b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4296,7 +4296,7 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
  * NFS4ERR_BADSESSION in the sequence operation, and will therefore
  * be in some phase of session reset.
  */
-static int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
+int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 {
 	nfs4_verifier verifier;
 	struct nfs41_exchange_id_args args = {
@@ -4582,7 +4582,6 @@ struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
 	if (!session)
 		return NULL;
 
-	set_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state);
 	/*
 	 * The create session reply races with the server back
 	 * channel probe. Mark the client NFS_CS_SESSION_INITING
@@ -4948,7 +4947,7 @@ struct nfs4_state_recovery_ops nfs41_reboot_recovery_ops = {
 	.state_flag_bit	= NFS_STATE_RECLAIM_REBOOT,
 	.recover_open	= nfs4_open_reclaim,
 	.recover_lock	= nfs4_lock_reclaim,
-	.establish_clid = nfs4_proc_exchange_id,
+	.establish_clid = nfs41_init_clientid,
 	.get_clid_cred	= nfs4_get_exchange_id_cred,
 };
 #endif /* CONFIG_NFS_V4_1 */
@@ -4968,7 +4967,7 @@ struct nfs4_state_recovery_ops nfs41_nograce_recovery_ops = {
 	.state_flag_bit	= NFS_STATE_RECLAIM_NOGRACE,
 	.recover_open	= nfs4_open_expired,
 	.recover_lock	= nfs4_lock_expired,
-	.establish_clid = nfs4_proc_exchange_id,
+	.establish_clid = nfs41_init_clientid,
 	.get_clid_cred	= nfs4_get_exchange_id_cred,
 };
 #endif /* CONFIG_NFS_V4_1 */
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 2ef4fec..8f1eb06 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -116,6 +116,19 @@ struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp)
 
 #if defined(CONFIG_NFS_V4_1)
 
+int nfs41_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
+{
+	int status;
+
+	status = nfs4_proc_exchange_id(clp, cred);
+	if (status == 0)
+		/* create session schedules state renewal upon success */
+		status = nfs4_proc_create_session(clp, 0);
+	if (status == 0)
+		nfs_mark_client_ready(clp, NFS_CS_READY);
+	return status;
+}
+
 struct rpc_cred *nfs4_get_exchange_id_cred(struct nfs_client *clp)
 {
 	struct rpc_cred *cred;
@@ -1156,7 +1169,6 @@ static void nfs4_session_recovery_handle_error(struct nfs_client *clp, int err)
 	switch (err) {
 	case -NFS4ERR_STALE_CLIENTID:
 		set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
-		set_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state);
 	}
 }
 
@@ -1182,24 +1194,8 @@ out:
 	return status;
 }
 
-static int nfs4_initialize_session(struct nfs_client *clp)
-{
-	int status;
-
-	status = nfs4_proc_create_session(clp, 0);
-	if (!status) {
-		nfs_mark_client_ready(clp, NFS_CS_READY);
-	} else if (status == -NFS4ERR_STALE_CLIENTID) {
-		set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
-		set_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state);
-	} else {
-		nfs_mark_client_ready(clp, status);
-	}
-	return status;
-}
 #else /* CONFIG_NFS_V4_1 */
 static int nfs4_reset_session(struct nfs_client *clp) { return 0; }
-static int nfs4_initialize_session(struct nfs_client *clp) { return 0; }
 #endif /* CONFIG_NFS_V4_1 */
 
 /* Set NFS4CLNT_LEASE_EXPIRED for all v4.0 errors and for recoverable errors
@@ -1252,10 +1248,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 		/* Initialize or reset the session */
 		if (test_and_clear_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state)
 		   && nfs4_has_session(clp)) {
-			if (clp->cl_cons_state == NFS_CS_SESSION_INITING)
-				status = nfs4_initialize_session(clp);
-			else
-				status = nfs4_reset_session(clp);
+			status = nfs4_reset_session(clp);
 			if (status) {
 				if (status == -NFS4ERR_STALE_CLIENTID)
 					continue;
-- 
1.6.0.6


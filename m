Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f180.google.com ([209.85.160.180]:55708 "EHLO
	mail-gh0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964992Ab3GLQbi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jul 2013 12:31:38 -0400
Received: by mail-gh0-f180.google.com with SMTP id f18so3239210ghb.39
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jul 2013 09:31:37 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe93:815b])
        by mx.google.com with ESMTPSA id o32sm69025925yhi.5.2013.07.12.09.31.36
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Jul 2013 09:31:37 -0700 (PDT)
Subject: [PATCH v1 01/19] NFS: Never use user credentials for lease renewal
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 12 Jul 2013 12:31:35 -0400
Message-ID: <20130712163135.1444.68565.stgit@seurat.1015granger.net>
In-Reply-To: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
References: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't try to use a non-UID-0 user credential for lease management,
as that credential can change out from under us.  The server will
block NFSv4 lease recovery with NFS4ERR_CLID_INUSE.

Replace minor version-specific callouts with a single function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4_fs.h     |    4 +---
 fs/nfs/nfs4proc.c    |    6 +----
 fs/nfs/nfs4session.c |    2 +-
 fs/nfs/nfs4state.c   |   55 ++++++--------------------------------------------
 4 files changed, 10 insertions(+), 57 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index a1dd768..3bc554e 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -193,7 +193,6 @@ struct nfs4_state_recovery_ops {
 	int (*recover_open)(struct nfs4_state_owner *, struct nfs4_state *);
 	int (*recover_lock)(struct nfs4_state *, struct file_lock *);
 	int (*establish_clid)(struct nfs_client *, struct rpc_cred *);
-	struct rpc_cred * (*get_clid_cred)(struct nfs_client *);
 	int (*reclaim_complete)(struct nfs_client *);
 	int (*detect_trunking)(struct nfs_client *, struct nfs_client **,
 		struct rpc_cred *);
@@ -319,7 +318,7 @@ extern void nfs4_kill_renewd(struct nfs_client *);
 extern void nfs4_renew_state(struct work_struct *);
 
 /* nfs4state.c */
-struct rpc_cred *nfs4_get_setclientid_cred(struct nfs_client *clp);
+struct rpc_cred *nfs4_get_clid_cred(struct nfs_client *clp);
 struct rpc_cred *nfs4_get_machine_cred_locked(struct nfs_client *clp);
 struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp);
 int nfs4_discover_server_trunking(struct nfs_client *clp,
@@ -327,7 +326,6 @@ int nfs4_discover_server_trunking(struct nfs_client *clp,
 int nfs40_discover_server_trunking(struct nfs_client *clp,
 			struct nfs_client **, struct rpc_cred *);
 #if defined(CONFIG_NFS_V4_1)
-struct rpc_cred *nfs4_get_exchange_id_cred(struct nfs_client *clp);
 int nfs41_discover_server_trunking(struct nfs_client *clp,
 			struct nfs_client **, struct rpc_cred *);
 extern void nfs4_schedule_session_recovery(struct nfs4_session *, int);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d7ba561..d74a2b5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5643,7 +5643,7 @@ int nfs4_destroy_clientid(struct nfs_client *clp)
 		goto out;
 	if (clp->cl_preserve_clid)
 		goto out;
-	cred = nfs4_get_exchange_id_cred(clp);
+	cred = nfs4_get_clid_cred(clp);
 	ret = nfs4_proc_destroy_clientid(clp, cred);
 	if (cred)
 		put_rpccred(cred);
@@ -6919,7 +6919,6 @@ static const struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops = {
 	.recover_open	= nfs4_open_reclaim,
 	.recover_lock	= nfs4_lock_reclaim,
 	.establish_clid = nfs4_init_clientid,
-	.get_clid_cred	= nfs4_get_setclientid_cred,
 	.detect_trunking = nfs40_discover_server_trunking,
 };
 
@@ -6930,7 +6929,6 @@ static const struct nfs4_state_recovery_ops nfs41_reboot_recovery_ops = {
 	.recover_open	= nfs4_open_reclaim,
 	.recover_lock	= nfs4_lock_reclaim,
 	.establish_clid = nfs41_init_clientid,
-	.get_clid_cred	= nfs4_get_exchange_id_cred,
 	.reclaim_complete = nfs41_proc_reclaim_complete,
 	.detect_trunking = nfs41_discover_server_trunking,
 };
@@ -6942,7 +6940,6 @@ static const struct nfs4_state_recovery_ops nfs40_nograce_recovery_ops = {
 	.recover_open	= nfs4_open_expired,
 	.recover_lock	= nfs4_lock_expired,
 	.establish_clid = nfs4_init_clientid,
-	.get_clid_cred	= nfs4_get_setclientid_cred,
 };
 
 #if defined(CONFIG_NFS_V4_1)
@@ -6952,7 +6949,6 @@ static const struct nfs4_state_recovery_ops nfs41_nograce_recovery_ops = {
 	.recover_open	= nfs41_open_expired,
 	.recover_lock	= nfs41_lock_expired,
 	.establish_clid = nfs41_init_clientid,
-	.get_clid_cred	= nfs4_get_exchange_id_cred,
 };
 #endif /* CONFIG_NFS_V4_1 */
 
diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index c4e225e..d35b816 100644
--- a/fs/nfs/nfs4session.c
+++ b/fs/nfs/nfs4session.c
@@ -441,7 +441,7 @@ void nfs4_destroy_session(struct nfs4_session *session)
 	struct rpc_xprt *xprt;
 	struct rpc_cred *cred;
 
-	cred = nfs4_get_exchange_id_cred(session->clp);
+	cred = nfs4_get_clid_cred(session->clp);
 	nfs4_proc_destroy_session(session, cred);
 	if (cred)
 		put_rpccred(cred);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 6ceece7..15fde8c 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -353,62 +353,21 @@ int nfs41_discover_server_trunking(struct nfs_client *clp,
 	return nfs41_walk_client_list(clp, result, cred);
 }
 
-struct rpc_cred *nfs4_get_exchange_id_cred(struct nfs_client *clp)
-{
-	struct rpc_cred *cred;
-
-	spin_lock(&clp->cl_lock);
-	cred = nfs4_get_machine_cred_locked(clp);
-	spin_unlock(&clp->cl_lock);
-	return cred;
-}
-
 #endif /* CONFIG_NFS_V4_1 */
 
-static struct rpc_cred *
-nfs4_get_setclientid_cred_server(struct nfs_server *server)
-{
-	struct nfs_client *clp = server->nfs_client;
-	struct rpc_cred *cred = NULL;
-	struct nfs4_state_owner *sp;
-	struct rb_node *pos;
-
-	spin_lock(&clp->cl_lock);
-	pos = rb_first(&server->state_owners);
-	if (pos != NULL) {
-		sp = rb_entry(pos, struct nfs4_state_owner, so_server_node);
-		cred = get_rpccred(sp->so_cred);
-	}
-	spin_unlock(&clp->cl_lock);
-	return cred;
-}
-
 /**
- * nfs4_get_setclientid_cred - Acquire credential for a setclientid operation
+ * nfs4_get_clid_cred - Acquire credential for a setclientid operation
  * @clp: client state handle
  *
  * Returns an rpc_cred with reference count bumped, or NULL.
  */
-struct rpc_cred *nfs4_get_setclientid_cred(struct nfs_client *clp)
+struct rpc_cred *nfs4_get_clid_cred(struct nfs_client *clp)
 {
-	struct nfs_server *server;
 	struct rpc_cred *cred;
 
 	spin_lock(&clp->cl_lock);
 	cred = nfs4_get_machine_cred_locked(clp);
 	spin_unlock(&clp->cl_lock);
-	if (cred != NULL)
-		goto out;
-
-	rcu_read_lock();
-	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
-		cred = nfs4_get_setclientid_cred_server(server);
-		if (cred != NULL)
-			break;
-	}
-	rcu_read_unlock();
-
-out:
 	return cred;
 }
 
@@ -1739,7 +1698,7 @@ static int nfs4_check_lease(struct nfs_client *clp)
 	cred = ops->get_state_renewal_cred_locked(clp);
 	spin_unlock(&clp->cl_lock);
 	if (cred == NULL) {
-		cred = nfs4_get_setclientid_cred(clp);
+		cred = nfs4_get_clid_cred(clp);
 		status = -ENOKEY;
 		if (cred == NULL)
 			goto out;
@@ -1811,7 +1770,7 @@ static int nfs4_establish_lease(struct nfs_client *clp)
 		clp->cl_mvops->reboot_recovery_ops;
 	int status;
 
-	cred = ops->get_clid_cred(clp);
+	cred = nfs4_get_clid_cred(clp);
 	if (cred == NULL)
 		return -ENOENT;
 	status = ops->establish_clid(clp, cred);
@@ -1885,7 +1844,7 @@ int nfs4_discover_server_trunking(struct nfs_client *clp,
 	mutex_lock(&nfs_clid_init_mutex);
 again:
 	status  = -ENOENT;
-	cred = ops->get_clid_cred(clp);
+	cred = nfs4_get_clid_cred(clp);
 	if (cred == NULL)
 		goto out_unlock;
 
@@ -2064,7 +2023,7 @@ static int nfs4_reset_session(struct nfs_client *clp)
 	if (!nfs4_has_session(clp))
 		return 0;
 	nfs4_begin_drain_session(clp);
-	cred = nfs4_get_exchange_id_cred(clp);
+	cred = nfs4_get_clid_cred(clp);
 	status = nfs4_proc_destroy_session(clp->cl_session, cred);
 	switch (status) {
 	case 0:
@@ -2107,7 +2066,7 @@ static int nfs4_bind_conn_to_session(struct nfs_client *clp)
 	if (!nfs4_has_session(clp))
 		return 0;
 	nfs4_begin_drain_session(clp);
-	cred = nfs4_get_exchange_id_cred(clp);
+	cred = nfs4_get_clid_cred(clp);
 	ret = nfs4_proc_bind_conn_to_session(clp, cred);
 	if (cred)
 		put_rpccred(cred);


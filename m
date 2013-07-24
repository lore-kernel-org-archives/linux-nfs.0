Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f179.google.com ([209.85.214.179]:52090 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753679Ab3GXQ2j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Jul 2013 12:28:39 -0400
Received: by mail-ob0-f179.google.com with SMTP id xk17so13231431obc.24
        for <linux-nfs@vger.kernel.org>; Wed, 24 Jul 2013 09:28:38 -0700 (PDT)
Subject: [PATCH 2/2] NFS: Never use user credentials for lease renewal
To: trond.myklebust@netapp.com
From: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 24 Jul 2013 12:28:37 -0400
Message-ID: <20130724162837.53792.14498.stgit@seurat.1015granger.net>
In-Reply-To: <20130724162632.53792.30516.stgit@seurat.1015granger.net>
References: <20130724162632.53792.30516.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Never try to use a non-UID 0 user credential for lease management,
as that credential can change out from under us.  The server will
block NFSv4 lease recovery with NFS4ERR_CLID_INUSE.

Since the mechanism to acquire a credential for lease management
is now the same for all minor versions, replace the minor version-
specific callout with a single function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4_fs.h     |    4 +---
 fs/nfs/nfs4proc.c    |    6 +----
 fs/nfs/nfs4session.c |    2 +-
 fs/nfs/nfs4state.c   |   57 +++++++-------------------------------------------
 4 files changed, 11 insertions(+), 58 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index ee81e35..d7bb59d 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -193,7 +193,6 @@ struct nfs4_state_recovery_ops {
 	int (*recover_open)(struct nfs4_state_owner *, struct nfs4_state *);
 	int (*recover_lock)(struct nfs4_state *, struct file_lock *);
 	int (*establish_clid)(struct nfs_client *, struct rpc_cred *);
-	struct rpc_cred * (*get_clid_cred)(struct nfs_client *);
 	int (*reclaim_complete)(struct nfs_client *, struct rpc_cred *);
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
index bd18847..6d23695 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6065,7 +6065,7 @@ int nfs4_destroy_clientid(struct nfs_client *clp)
 		goto out;
 	if (clp->cl_preserve_clid)
 		goto out;
-	cred = nfs4_get_exchange_id_cred(clp);
+	cred = nfs4_get_clid_cred(clp);
 	ret = nfs4_proc_destroy_clientid(clp, cred);
 	if (cred)
 		put_rpccred(cred);
@@ -7359,7 +7359,6 @@ static const struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops = {
 	.recover_open	= nfs4_open_reclaim,
 	.recover_lock	= nfs4_lock_reclaim,
 	.establish_clid = nfs4_init_clientid,
-	.get_clid_cred	= nfs4_get_setclientid_cred,
 	.detect_trunking = nfs40_discover_server_trunking,
 };
 
@@ -7370,7 +7369,6 @@ static const struct nfs4_state_recovery_ops nfs41_reboot_recovery_ops = {
 	.recover_open	= nfs4_open_reclaim,
 	.recover_lock	= nfs4_lock_reclaim,
 	.establish_clid = nfs41_init_clientid,
-	.get_clid_cred	= nfs4_get_exchange_id_cred,
 	.reclaim_complete = nfs41_proc_reclaim_complete,
 	.detect_trunking = nfs41_discover_server_trunking,
 };
@@ -7382,7 +7380,6 @@ static const struct nfs4_state_recovery_ops nfs40_nograce_recovery_ops = {
 	.recover_open	= nfs4_open_expired,
 	.recover_lock	= nfs4_lock_expired,
 	.establish_clid = nfs4_init_clientid,
-	.get_clid_cred	= nfs4_get_setclientid_cred,
 };
 
 #if defined(CONFIG_NFS_V4_1)
@@ -7392,7 +7389,6 @@ static const struct nfs4_state_recovery_ops nfs41_nograce_recovery_ops = {
 	.recover_open	= nfs41_open_expired,
 	.recover_lock	= nfs41_lock_expired,
 	.establish_clid = nfs41_init_clientid,
-	.get_clid_cred	= nfs4_get_exchange_id_cred,
 };
 #endif /* CONFIG_NFS_V4_1 */
 
diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index 01d3150..91cef18 100644
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
index f27760b..6818964 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -352,62 +352,21 @@ int nfs41_discover_server_trunking(struct nfs_client *clp,
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
 
@@ -1631,7 +1590,7 @@ static void nfs4_state_end_reclaim_reboot(struct nfs_client *clp)
 	if (!nfs4_state_clear_reclaim_reboot(clp))
 		return;
 	ops = clp->cl_mvops->reboot_recovery_ops;
-	cred = ops->get_clid_cred(clp);
+	cred = nfs4_get_clid_cred(clp);
 	nfs4_reclaim_complete(clp, ops, cred);
 	put_rpccred(cred);
 }
@@ -1745,7 +1704,7 @@ static int nfs4_check_lease(struct nfs_client *clp)
 	cred = ops->get_state_renewal_cred_locked(clp);
 	spin_unlock(&clp->cl_lock);
 	if (cred == NULL) {
-		cred = nfs4_get_setclientid_cred(clp);
+		cred = nfs4_get_clid_cred(clp);
 		status = -ENOKEY;
 		if (cred == NULL)
 			goto out;
@@ -1817,7 +1776,7 @@ static int nfs4_establish_lease(struct nfs_client *clp)
 		clp->cl_mvops->reboot_recovery_ops;
 	int status;
 
-	cred = ops->get_clid_cred(clp);
+	cred = nfs4_get_clid_cred(clp);
 	if (cred == NULL)
 		return -ENOENT;
 	status = ops->establish_clid(clp, cred);
@@ -1891,7 +1850,7 @@ int nfs4_discover_server_trunking(struct nfs_client *clp,
 	mutex_lock(&nfs_clid_init_mutex);
 again:
 	status  = -ENOENT;
-	cred = ops->get_clid_cred(clp);
+	cred = nfs4_get_clid_cred(clp);
 	if (cred == NULL)
 		goto out_unlock;
 
@@ -2069,7 +2028,7 @@ static int nfs4_reset_session(struct nfs_client *clp)
 	if (!nfs4_has_session(clp))
 		return 0;
 	nfs4_begin_drain_session(clp);
-	cred = nfs4_get_exchange_id_cred(clp);
+	cred = nfs4_get_clid_cred(clp);
 	status = nfs4_proc_destroy_session(clp->cl_session, cred);
 	switch (status) {
 	case 0:
@@ -2112,7 +2071,7 @@ static int nfs4_bind_conn_to_session(struct nfs_client *clp)
 	if (!nfs4_has_session(clp))
 		return 0;
 	nfs4_begin_drain_session(clp);
-	cred = nfs4_get_exchange_id_cred(clp);
+	cred = nfs4_get_clid_cred(clp);
 	ret = nfs4_proc_bind_conn_to_session(clp, cred);
 	if (cred)
 		put_rpccred(cred);


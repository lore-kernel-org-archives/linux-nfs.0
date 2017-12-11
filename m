Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40261 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752255AbdLKElM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 10 Dec 2017 23:41:12 -0500
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.220.254])
        by mx2.suse.de (Postfix) with ESMTP id 27010AAB5
        for <linux-nfs@vger.kernel.org>; Mon, 11 Dec 2017 04:41:11 +0000 (UTC)
From: NeilBrown <neilb@suse.com>
To: linux-nfs@vger.kernel.org
Date: Mon, 11 Dec 2017 15:40:17 +1100
Subject: [PATCH 06/19] NFSv4: don't require lock for get_renew_cred or
 get_machine_cred
Message-ID: <151296721765.24753.4086033033137304780.stgit@noble>
In-Reply-To: <151296579813.24753.5905981862981613395.stgit@noble>
References: <151296579813.24753.5905981862981613395.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This lock is no longer necessary.

If nfs4_get_renew_cred() needs to hunt through the open-state
creds for a user cred, it still takes the lock to stablize
the rbtree, but otherwise there are no races.

Note that this completely removes the lock from nfs4_renew_state().
It appears that the original need for the locking here was removed
long ago, and there is no longer anything to protect.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/nfs4_fs.h    |    6 +++---
 fs/nfs/nfs4proc.c   |    4 ++--
 fs/nfs/nfs4renewd.c |    5 +----
 fs/nfs/nfs4state.c  |   26 ++++++++++----------------
 4 files changed, 16 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b374f680830c..115f5af6663c 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -219,7 +219,7 @@ struct nfs4_add_xprt_data {
 
 struct nfs4_state_maintenance_ops {
 	int (*sched_state_renewal)(struct nfs_client *, struct rpc_cred *, unsigned);
-	struct rpc_cred * (*get_state_renewal_cred_locked)(struct nfs_client *);
+	struct rpc_cred * (*get_state_renewal_cred)(struct nfs_client *);
 	int (*renew_lease)(struct nfs_client *, struct rpc_cred *);
 };
 
@@ -417,8 +417,8 @@ extern void nfs4_set_lease_period(struct nfs_client *clp,
 
 /* nfs4state.c */
 struct rpc_cred *nfs4_get_clid_cred(struct nfs_client *clp);
-struct rpc_cred *nfs4_get_machine_cred_locked(struct nfs_client *clp);
-struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp);
+struct rpc_cred *nfs4_get_machine_cred(struct nfs_client *clp);
+struct rpc_cred *nfs4_get_renew_cred(struct nfs_client *clp);
 int nfs4_discover_server_trunking(struct nfs_client *clp,
 			struct nfs_client **);
 int nfs40_discover_server_trunking(struct nfs_client *clp,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 56fa5a16e097..8ba285b7df35 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -9388,14 +9388,14 @@ static const struct nfs4_state_recovery_ops nfs41_nograce_recovery_ops = {
 
 static const struct nfs4_state_maintenance_ops nfs40_state_renewal_ops = {
 	.sched_state_renewal = nfs4_proc_async_renew,
-	.get_state_renewal_cred_locked = nfs4_get_renew_cred_locked,
+	.get_state_renewal_cred = nfs4_get_renew_cred,
 	.renew_lease = nfs4_proc_renew,
 };
 
 #if defined(CONFIG_NFS_V4_1)
 static const struct nfs4_state_maintenance_ops nfs41_state_renewal_ops = {
 	.sched_state_renewal = nfs41_proc_async_sequence,
-	.get_state_renewal_cred_locked = nfs4_get_machine_cred_locked,
+	.get_state_renewal_cred = nfs4_get_machine_cred,
 	.renew_lease = nfs4_proc_sequence,
 };
 #endif
diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index 1f8c2ae43a8d..8880cd958210 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -68,7 +68,6 @@ nfs4_renew_state(struct work_struct *work)
 	if (test_bit(NFS_CS_STOP_RENEW, &clp->cl_res_state))
 		goto out;
 
-	spin_lock(&clp->cl_lock);
 	lease = clp->cl_lease_time;
 	last = clp->cl_last_renewal;
 	now = jiffies;
@@ -79,8 +78,7 @@ nfs4_renew_state(struct work_struct *work)
 		renew_flags |= NFS4_RENEW_DELEGATION_CB;
 
 	if (renew_flags != 0) {
-		cred = ops->get_state_renewal_cred_locked(clp);
-		spin_unlock(&clp->cl_lock);
+		cred = ops->get_state_renewal_cred(clp);
 		if (cred == NULL) {
 			if (!(renew_flags & NFS4_RENEW_DELEGATION_CB)) {
 				set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
@@ -104,7 +102,6 @@ nfs4_renew_state(struct work_struct *work)
 	} else {
 		dprintk("%s: failed to call renewd. Reason: lease not expired \n",
 				__func__);
-		spin_unlock(&clp->cl_lock);
 	}
 	nfs4_schedule_state_renewal(clp);
 out_exp:
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 9b9b5794e05d..4519b7d44c79 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -156,7 +156,7 @@ int nfs40_discover_server_trunking(struct nfs_client *clp,
 	return status;
 }
 
-struct rpc_cred *nfs4_get_machine_cred_locked(struct nfs_client *clp)
+struct rpc_cred *nfs4_get_machine_cred(struct nfs_client *clp)
 {
 	struct rpc_cred *cred = clp->cl_root_cred;
 
@@ -202,22 +202,23 @@ nfs4_get_renew_cred_server_locked(struct nfs_server *server)
 }
 
 /**
- * nfs4_get_renew_cred_locked - Acquire credential for a renew operation
+ * nfs4_get_renew_cred - Acquire credential for a renew operation
  * @clp: client state handle
  *
  * Returns an rpc_cred with reference count bumped, or NULL.
  * Caller must hold clp->cl_lock.
  */
-struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp)
+struct rpc_cred *nfs4_get_renew_cred(struct nfs_client *clp)
 {
 	struct rpc_cred *cred = NULL;
 	struct nfs_server *server;
 
 	/* Use machine credentials if available */
-	cred = nfs4_get_machine_cred_locked(clp);
+	cred = nfs4_get_machine_cred(clp);
 	if (cred != NULL)
 		goto out;
 
+	spin_lock(&clp->cl_lock);
 	rcu_read_lock();
 	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
 		cred = nfs4_get_renew_cred_server_locked(server);
@@ -225,6 +226,7 @@ struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp)
 			break;
 	}
 	rcu_read_unlock();
+	spin_unlock(&clp->cl_lock);
 
 out:
 	return cred;
@@ -394,9 +396,7 @@ struct rpc_cred *nfs4_get_clid_cred(struct nfs_client *clp)
 {
 	struct rpc_cred *cred;
 
-	spin_lock(&clp->cl_lock);
-	cred = nfs4_get_machine_cred_locked(clp);
-	spin_unlock(&clp->cl_lock);
+	cred = nfs4_get_machine_cred(clp);
 	return cred;
 }
 
@@ -1859,9 +1859,7 @@ static int nfs4_check_lease(struct nfs_client *clp)
 	/* Is the client already known to have an expired lease? */
 	if (test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state))
 		return 0;
-	spin_lock(&clp->cl_lock);
-	cred = ops->get_state_renewal_cred_locked(clp);
-	spin_unlock(&clp->cl_lock);
+	cred = ops->get_state_renewal_cred(clp);
 	if (cred == NULL) {
 		cred = nfs4_get_clid_cred(clp);
 		status = -ENOKEY;
@@ -2059,9 +2057,7 @@ static int nfs4_handle_migration(struct nfs_client *clp)
 	dprintk("%s: migration reported on \"%s\"\n", __func__,
 			clp->cl_hostname);
 
-	spin_lock(&clp->cl_lock);
-	cred = ops->get_state_renewal_cred_locked(clp);
-	spin_unlock(&clp->cl_lock);
+	cred = ops->get_state_renewal_cred(clp);
 	if (cred == NULL)
 		return -NFS4ERR_NOENT;
 
@@ -2107,9 +2103,7 @@ static int nfs4_handle_lease_moved(struct nfs_client *clp)
 	dprintk("%s: lease moved reported on \"%s\"\n", __func__,
 			clp->cl_hostname);
 
-	spin_lock(&clp->cl_lock);
-	cred = ops->get_state_renewal_cred_locked(clp);
-	spin_unlock(&clp->cl_lock);
+	cred = ops->get_state_renewal_cred(clp);
 	if (cred == NULL)
 		return -NFS4ERR_NOENT;
 



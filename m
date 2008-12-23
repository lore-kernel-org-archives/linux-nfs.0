From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 37/69] NFSv4: Return unreferenced delegations more promptly
Date: Tue, 23 Dec 2008 18:02:16 -0500
Message-ID: <20081223230216.13743.44521.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17668 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752302AbYLWXXr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:47 -0500
Received: from svlrsexc1-prd.hq.netapp.com ([10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNbsi006182
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:41 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the client is not using a delegation, the right thing to do is to return
it as soon as possible. This helps reduce the amount of state the server
has to track, as well as reducing the potential for conflicts with other
clients.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/delegation.c |   42 ++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/delegation.h |   17 ++++-------------
 fs/nfs/nfs4proc.c   |    2 ++
 fs/nfs/nfs4renewd.c |    1 +
 4 files changed, 49 insertions(+), 13 deletions(-)


diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 00c350c..e75f2f8 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -43,6 +43,27 @@ static void nfs_free_delegation(struct nfs_delegation *delegation)
 		put_rpccred(cred);
 }
 
+void nfs_mark_delegation_referenced(struct nfs_delegation *delegation)
+{
+	set_bit(NFS_DELEGATION_REFERENCED, &delegation->flags);
+}
+
+int nfs_have_delegation(struct inode *inode, int flags)
+{
+	struct nfs_delegation *delegation;
+	int ret = 0;
+
+	flags &= FMODE_READ|FMODE_WRITE;
+	rcu_read_lock();
+	delegation = rcu_dereference(NFS_I(inode)->delegation);
+	if (delegation != NULL && (delegation->type & flags) == flags) {
+		nfs_mark_delegation_referenced(delegation);
+		ret = 1;
+	}
+	rcu_read_unlock();
+	return ret;
+}
+
 static int nfs_delegation_claim_locks(struct nfs_open_context *ctx, struct nfs4_state *state)
 {
 	struct inode *inode = state->inode;
@@ -188,6 +209,7 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 	delegation->change_attr = nfsi->change_attr;
 	delegation->cred = get_rpccred(cred);
 	delegation->inode = inode;
+	delegation->flags = 1<<NFS_DELEGATION_REFERENCED;
 	spin_lock_init(&delegation->lock);
 
 	spin_lock(&clp->cl_lock);
@@ -382,6 +404,26 @@ void nfs_handle_cb_pathdown(struct nfs_client *clp)
 	nfs_client_mark_return_all_delegations(clp);
 }
 
+static void nfs_client_mark_return_unreferenced_delegations(struct nfs_client *clp)
+{
+	struct nfs_delegation *delegation;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(delegation, &clp->cl_delegations, super_list) {
+		if (test_and_clear_bit(NFS_DELEGATION_REFERENCED, &delegation->flags))
+			continue;
+		set_bit(NFS_DELEGATION_RETURN, &delegation->flags);
+		set_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state);
+	}
+	rcu_read_unlock();
+}
+
+void nfs_expire_unreferenced_delegations(struct nfs_client *clp)
+{
+	nfs_client_mark_return_unreferenced_delegations(clp);
+	nfs_delegation_run_state_manager(clp);
+}
+
 /*
  * Asynchronous delegation recall!
  */
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index 56f3eb5..2a74882 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -28,6 +28,7 @@ struct nfs_delegation {
 enum {
 	NFS_DELEGATION_NEED_RECLAIM = 0,
 	NFS_DELEGATION_RETURN,
+	NFS_DELEGATION_REFERENCED,
 };
 
 int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res);
@@ -39,6 +40,7 @@ void nfs_inode_return_delegation_noreclaim(struct inode *inode);
 struct inode *nfs_delegation_find_inode(struct nfs_client *clp, const struct nfs_fh *fhandle);
 void nfs_super_return_all_delegations(struct super_block *sb);
 void nfs_expire_all_delegations(struct nfs_client *clp);
+void nfs_expire_unreferenced_delegations(struct nfs_client *clp);
 void nfs_handle_cb_pathdown(struct nfs_client *clp);
 void nfs_client_return_marked_delegations(struct nfs_client *clp);
 
@@ -51,19 +53,8 @@ int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state
 int nfs4_lock_delegation_recall(struct nfs4_state *state, struct file_lock *fl);
 int nfs4_copy_delegation_stateid(nfs4_stateid *dst, struct inode *inode);
 
-static inline int nfs_have_delegation(struct inode *inode, int flags)
-{
-	struct nfs_delegation *delegation;
-	int ret = 0;
-
-	flags &= FMODE_READ|FMODE_WRITE;
-	rcu_read_lock();
-	delegation = rcu_dereference(NFS_I(inode)->delegation);
-	if (delegation != NULL && (delegation->type & flags) == flags)
-		ret = 1;
-	rcu_read_unlock();
-	return ret;
-}
+void nfs_mark_delegation_referenced(struct nfs_delegation *delegation);
+int nfs_have_delegation(struct inode *inode, int flags);
 
 #else
 static inline int nfs_have_delegation(struct inode *inode, int flags)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2a347d4..fc0c9d2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -421,6 +421,7 @@ static int can_open_delegated(struct nfs_delegation *delegation, mode_t open_fla
 		return 0;
 	if (test_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags))
 		return 0;
+	nfs_mark_delegation_referenced(delegation);
 	return 1;
 }
 
@@ -505,6 +506,7 @@ static int update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stat
 	else if (memcmp(deleg_cur->stateid.data, delegation->data, NFS4_STATEID_SIZE) != 0)
 		goto no_delegation_unlock;
 
+	nfs_mark_delegation_referenced(deleg_cur);
 	__update_open_stateid(state, open_stateid, &deleg_cur->stateid, open_flags);
 	ret = 1;
 no_delegation_unlock:
diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index ca557e6..f524e93 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -101,6 +101,7 @@ nfs4_renew_state(struct work_struct *work)
 	cancel_delayed_work(&clp->cl_renewd);
 	schedule_delayed_work(&clp->cl_renewd, timeout);
 	spin_unlock(&clp->cl_lock);
+	nfs_expire_unreferenced_delegations(clp);
 out:
 	dprintk("%s: done\n", __func__);
 }


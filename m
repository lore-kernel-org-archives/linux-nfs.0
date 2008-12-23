From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 30/69] NFSv4: Clean up the support for returning multiple
 delegations
Date: Tue, 23 Dec 2008 18:02:14 -0500
Message-ID: <20081223230214.13743.38083.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45954 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752230AbYLWXXp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:45 -0500
Received: from svlrsexc1-prd.hq.netapp.com ([10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNbsc006182
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:40 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a flag to mark delegations as requiring return, then run a garbage
collector. In the future, this will allow for more flexible delegation
management, where delegations may be marked for return if it turns out
that they are not being referenced.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/delegation.c |   97 ++++++++++++++++++++++++---------------------------
 fs/nfs/delegation.h |    8 +++-
 fs/nfs/super.c      |    2 +
 3 files changed, 52 insertions(+), 55 deletions(-)


diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index ebc06f2..bc9d4f9 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -256,6 +256,34 @@ static int __nfs_inode_return_delegation(struct inode *inode, struct nfs_delegat
 }
 
 /*
+ * Return all delegations that have been marked for return
+ */
+static void nfs_client_return_marked_delegations(struct nfs_client *clp)
+{
+	struct nfs_delegation *delegation;
+	struct inode *inode;
+
+restart:
+	rcu_read_lock();
+	list_for_each_entry_rcu(delegation, &clp->cl_delegations, super_list) {
+		if (!test_and_clear_bit(NFS_DELEGATION_RETURN, &delegation->flags))
+			continue;
+		inode = nfs_delegation_grab_inode(delegation);
+		if (inode == NULL)
+			continue;
+		spin_lock(&clp->cl_lock);
+		delegation = nfs_detach_delegation_locked(NFS_I(inode), NULL);
+		spin_unlock(&clp->cl_lock);
+		rcu_read_unlock();
+		if (delegation != NULL)
+			__nfs_inode_return_delegation(inode, delegation);
+		iput(inode);
+		goto restart;
+	}
+	rcu_read_unlock();
+}
+
+/*
  * This function returns the delegation without reclaiming opens
  * or protecting against delegation reclaims.
  * It is therefore really only safe to be called from
@@ -296,63 +324,46 @@ int nfs_inode_return_delegation(struct inode *inode)
 /*
  * Return all delegations associated to a super block
  */
-void nfs_return_all_delegations(struct super_block *sb)
+void nfs_super_return_all_delegations(struct super_block *sb)
 {
 	struct nfs_client *clp = NFS_SB(sb)->nfs_client;
 	struct nfs_delegation *delegation;
-	struct inode *inode;
 
 	if (clp == NULL)
 		return;
-restart:
 	rcu_read_lock();
 	list_for_each_entry_rcu(delegation, &clp->cl_delegations, super_list) {
-		inode = NULL;
 		spin_lock(&delegation->lock);
 		if (delegation->inode != NULL && delegation->inode->i_sb == sb)
-			inode = igrab(delegation->inode);
+			set_bit(NFS_DELEGATION_RETURN, &delegation->flags);
 		spin_unlock(&delegation->lock);
-		if (inode == NULL)
-			continue;
-		spin_lock(&clp->cl_lock);
-		delegation = nfs_detach_delegation_locked(NFS_I(inode), NULL);
-		spin_unlock(&clp->cl_lock);
-		rcu_read_unlock();
-		if (delegation != NULL)
-			__nfs_inode_return_delegation(inode, delegation);
-		iput(inode);
-		goto restart;
 	}
 	rcu_read_unlock();
+	nfs_client_return_marked_delegations(clp);
+}
+
+static void nfs_client_return_all_delegations(struct nfs_client *clp)
+{
+	struct nfs_delegation *delegation;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(delegation, &clp->cl_delegations, super_list)
+		set_bit(NFS_DELEGATION_RETURN, &delegation->flags);
+	rcu_read_unlock();
+	nfs_client_return_marked_delegations(clp);
 }
 
 static int nfs_do_expire_all_delegations(void *ptr)
 {
 	struct nfs_client *clp = ptr;
-	struct nfs_delegation *delegation;
-	struct inode *inode;
 
 	allow_signal(SIGKILL);
-restart:
+
 	if (test_bit(NFS4CLNT_STATE_RECOVER, &clp->cl_state) != 0)
 		goto out;
 	if (test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) == 0)
 		goto out;
-	rcu_read_lock();
-	list_for_each_entry_rcu(delegation, &clp->cl_delegations, super_list) {
-		inode = nfs_delegation_grab_inode(delegation);
-		if (inode == NULL)
-			continue;
-		spin_lock(&clp->cl_lock);
-		delegation = nfs_detach_delegation_locked(NFS_I(inode), NULL);
-		spin_unlock(&clp->cl_lock);
-		rcu_read_unlock();
-		if (delegation)
-			__nfs_inode_return_delegation(inode, delegation);
-		iput(inode);
-		goto restart;
-	}
-	rcu_read_unlock();
+	nfs_client_return_all_delegations(clp);
 out:
 	nfs_put_client(clp);
 	module_put_and_exit(0);
@@ -379,27 +390,9 @@ void nfs_expire_all_delegations(struct nfs_client *clp)
  */
 void nfs_handle_cb_pathdown(struct nfs_client *clp)
 {
-	struct nfs_delegation *delegation;
-	struct inode *inode;
-
 	if (clp == NULL)
 		return;
-restart:
-	rcu_read_lock();
-	list_for_each_entry_rcu(delegation, &clp->cl_delegations, super_list) {
-		inode = nfs_delegation_grab_inode(delegation);
-		if (inode == NULL)
-			continue;
-		spin_lock(&clp->cl_lock);
-		delegation = nfs_detach_delegation_locked(NFS_I(inode), NULL);
-		spin_unlock(&clp->cl_lock);
-		rcu_read_unlock();
-		if (delegation != NULL)
-			__nfs_inode_return_delegation(inode, delegation);
-		iput(inode);
-		goto restart;
-	}
-	rcu_read_unlock();
+	nfs_client_return_all_delegations(clp);
 }
 
 struct recall_threadargs {
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index 5e9f40e..c772bab 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -20,12 +20,16 @@ struct nfs_delegation {
 	int type;
 	loff_t maxsize;
 	__u64 change_attr;
-#define NFS_DELEGATION_NEED_RECLAIM 0
 	unsigned long flags;
 	spinlock_t lock;
 	struct rcu_head rcu;
 };
 
+enum {
+	NFS_DELEGATION_NEED_RECLAIM = 0,
+	NFS_DELEGATION_RETURN,
+};
+
 int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res);
 void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res);
 int nfs_inode_return_delegation(struct inode *inode);
@@ -33,7 +37,7 @@ int nfs_async_inode_return_delegation(struct inode *inode, const nfs4_stateid *s
 void nfs_inode_return_delegation_noreclaim(struct inode *inode);
 
 struct inode *nfs_delegation_find_inode(struct nfs_client *clp, const struct nfs_fh *fhandle);
-void nfs_return_all_delegations(struct super_block *sb);
+void nfs_super_return_all_delegations(struct super_block *sb);
 void nfs_expire_all_delegations(struct nfs_client *clp);
 void nfs_handle_cb_pathdown(struct nfs_client *clp);
 
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index d8e062f..bd4c3dd 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2433,7 +2433,7 @@ static void nfs4_kill_super(struct super_block *sb)
 {
 	struct nfs_server *server = NFS_SB(sb);
 
-	nfs_return_all_delegations(sb);
+	nfs_super_return_all_delegations(sb);
 	kill_anon_super(sb);
 
 	nfs4_renewd_prepare_shutdown(server);


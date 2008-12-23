From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 17/69] NFSv4: Fix up the dereferencing of delegation->inode
Date: Tue, 23 Dec 2008 18:02:10 -0500
Message-ID: <20081223230210.13743.65577.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17668 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752351AbYLWXXn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:43 -0500
Received: from svlrsexc2-prd.hq.netapp.com ([10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNa7S021304
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:40 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Without an extra lock, we cannot just assume that the delegation->inode is
valid when we're traversing the rcu-protected nfs_client lists. Use the
delegation->lock to ensure that it is truly valid.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/delegation.c |   39 +++++++++++++++++++++++++++++++--------
 1 files changed, 31 insertions(+), 8 deletions(-)


diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index e0cb4ee..13f2044 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -134,6 +134,17 @@ static int nfs_do_return_delegation(struct inode *inode, struct nfs_delegation *
 	return res;
 }
 
+static struct inode *nfs_delegation_grab_inode(struct nfs_delegation *delegation)
+{
+	struct inode *inode = NULL;
+
+	spin_lock(&delegation->lock);
+	if (delegation->inode != NULL)
+		inode = igrab(delegation->inode);
+	spin_unlock(&delegation->lock);
+	return inode;
+}
+
 static struct nfs_delegation *nfs_detach_delegation_locked(struct nfs_inode *nfsi, const nfs4_stateid *stateid)
 {
 	struct nfs_delegation *delegation = rcu_dereference(nfsi->delegation);
@@ -145,6 +156,7 @@ static struct nfs_delegation *nfs_detach_delegation_locked(struct nfs_inode *nfs
 				sizeof(delegation->stateid.data)) != 0)
 		goto nomatch_unlock;
 	list_del_rcu(&delegation->super_list);
+	delegation->inode = NULL;
 	nfsi->delegation_state = 0;
 	rcu_assign_pointer(nfsi->delegation, NULL);
 	spin_unlock(&delegation->lock);
@@ -298,9 +310,11 @@ void nfs_return_all_delegations(struct super_block *sb)
 restart:
 	rcu_read_lock();
 	list_for_each_entry_rcu(delegation, &clp->cl_delegations, super_list) {
-		if (delegation->inode->i_sb != sb)
-			continue;
-		inode = igrab(delegation->inode);
+		inode = NULL;
+		spin_lock(&delegation->lock);
+		if (delegation->inode != NULL && delegation->inode->i_sb == sb)
+			inode = igrab(delegation->inode);
+		spin_unlock(&delegation->lock);
 		if (inode == NULL)
 			continue;
 		spin_lock(&clp->cl_lock);
@@ -329,7 +343,7 @@ restart:
 		goto out;
 	rcu_read_lock();
 	list_for_each_entry_rcu(delegation, &clp->cl_delegations, super_list) {
-		inode = igrab(delegation->inode);
+		inode = nfs_delegation_grab_inode(delegation);
 		if (inode == NULL)
 			continue;
 		spin_lock(&clp->cl_lock);
@@ -376,7 +390,7 @@ void nfs_handle_cb_pathdown(struct nfs_client *clp)
 restart:
 	rcu_read_lock();
 	list_for_each_entry_rcu(delegation, &clp->cl_delegations, super_list) {
-		inode = igrab(delegation->inode);
+		inode = nfs_delegation_grab_inode(delegation);
 		if (inode == NULL)
 			continue;
 		spin_lock(&clp->cl_lock);
@@ -464,10 +478,14 @@ struct inode *nfs_delegation_find_inode(struct nfs_client *clp, const struct nfs
 	struct inode *res = NULL;
 	rcu_read_lock();
 	list_for_each_entry_rcu(delegation, &clp->cl_delegations, super_list) {
-		if (nfs_compare_fh(fhandle, &NFS_I(delegation->inode)->fh) == 0) {
+		spin_lock(&delegation->lock);
+		if (delegation->inode != NULL &&
+		    nfs_compare_fh(fhandle, &NFS_I(delegation->inode)->fh) == 0) {
 			res = igrab(delegation->inode);
-			break;
 		}
+		spin_unlock(&delegation->lock);
+		if (res != NULL)
+			break;
 	}
 	rcu_read_unlock();
 	return res;
@@ -491,17 +509,22 @@ void nfs_delegation_mark_reclaim(struct nfs_client *clp)
 void nfs_delegation_reap_unclaimed(struct nfs_client *clp)
 {
 	struct nfs_delegation *delegation;
+	struct inode *inode;
 restart:
 	rcu_read_lock();
 	list_for_each_entry_rcu(delegation, &clp->cl_delegations, super_list) {
 		if ((delegation->flags & NFS_DELEGATION_NEED_RECLAIM) == 0)
 			continue;
+		inode = nfs_delegation_grab_inode(delegation);
+		if (inode == NULL)
+			continue;
 		spin_lock(&clp->cl_lock);
-		delegation = nfs_detach_delegation_locked(NFS_I(delegation->inode), NULL);
+		delegation = nfs_detach_delegation_locked(NFS_I(inode), NULL);
 		spin_unlock(&clp->cl_lock);
 		rcu_read_unlock();
 		if (delegation != NULL)
 			nfs_free_delegation(delegation);
+		iput(inode);
 		goto restart;
 	}
 	rcu_read_unlock();


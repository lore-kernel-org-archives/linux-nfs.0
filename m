Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:56099 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751658Ab0LWVyi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Dec 2010 16:54:38 -0500
Received: by mail-iw0-f174.google.com with SMTP id 9so6550865iwn.19
        for <linux-nfs@vger.kernel.org>; Thu, 23 Dec 2010 13:54:37 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/4] NFS: Introduce nfs_detach_delegations()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 23 Dec 2010 16:54:35 -0500
Message-ID: <20101223215435.2344.77114.stgit@matisse.1015granger.net>
In-Reply-To: <20101223214503.2344.79300.stgit@matisse.1015granger.net>
References: <20101223214503.2344.79300.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up:  Refactor code that takes clp->cl_lock and calls
nfs_detach_delegations_locked() into its own function.

While we're changing the call sites, get rid of the second parameter
and the logic in nfs_detach_delegations_locked() that uses it, since
callers always set that parameter of nfs_detach_delegations_locked()
to NULL.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/delegation.c |   41 ++++++++++++++++++++---------------------
 1 files changed, 20 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 1fd62fc..521d71b 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -175,9 +175,9 @@ static struct inode *nfs_delegation_grab_inode(struct nfs_delegation *delegation
 	return inode;
 }
 
-static struct nfs_delegation *nfs_detach_delegation_locked(struct nfs_inode *nfsi,
-							   const nfs4_stateid *stateid,
-							   struct nfs_client *clp)
+static struct nfs_delegation *
+nfs_detach_delegation_locked(struct nfs_inode *nfsi,
+			     struct nfs_client *clp)
 {
 	struct nfs_delegation *delegation =
 		rcu_dereference_protected(nfsi->delegation,
@@ -185,22 +185,29 @@ static struct nfs_delegation *nfs_detach_delegation_locked(struct nfs_inode *nfs
 
 	if (delegation == NULL)
 		goto nomatch;
+
 	spin_lock(&delegation->lock);
-	if (stateid != NULL && memcmp(delegation->stateid.data, stateid->data,
-				sizeof(delegation->stateid.data)) != 0)
-		goto nomatch_unlock;
 	list_del_rcu(&delegation->super_list);
 	delegation->inode = NULL;
 	nfsi->delegation_state = 0;
 	rcu_assign_pointer(nfsi->delegation, NULL);
 	spin_unlock(&delegation->lock);
 	return delegation;
-nomatch_unlock:
-	spin_unlock(&delegation->lock);
 nomatch:
 	return NULL;
 }
 
+static struct nfs_delegation *nfs_detach_delegation(struct nfs_inode *nfsi,
+						    struct nfs_client *clp)
+{
+	struct nfs_delegation *delegation;
+
+	spin_lock(&clp->cl_lock);
+	delegation = nfs_detach_delegation_locked(nfsi, clp);
+	spin_unlock(&clp->cl_lock);
+	return delegation;
+}
+
 /*
  * Set up a delegation on an inode
  */
@@ -246,7 +253,7 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 			delegation = NULL;
 			goto out;
 		}
-		freeme = nfs_detach_delegation_locked(nfsi, NULL, clp);
+		freeme = nfs_detach_delegation_locked(nfsi, clp);
 	}
 	list_add_rcu(&delegation->super_list, &clp->cl_delegations);
 	nfsi->delegation_state = delegation->type;
@@ -307,9 +314,7 @@ restart:
 		inode = nfs_delegation_grab_inode(delegation);
 		if (inode == NULL)
 			continue;
-		spin_lock(&clp->cl_lock);
-		delegation = nfs_detach_delegation_locked(NFS_I(inode), NULL, clp);
-		spin_unlock(&clp->cl_lock);
+		delegation = nfs_detach_delegation(NFS_I(inode), clp);
 		rcu_read_unlock();
 		if (delegation != NULL) {
 			filemap_flush(inode->i_mapping);
@@ -338,9 +343,7 @@ void nfs_inode_return_delegation_noreclaim(struct inode *inode)
 	struct nfs_delegation *delegation;
 
 	if (rcu_access_pointer(nfsi->delegation) != NULL) {
-		spin_lock(&clp->cl_lock);
-		delegation = nfs_detach_delegation_locked(nfsi, NULL, clp);
-		spin_unlock(&clp->cl_lock);
+		delegation = nfs_detach_delegation(nfsi, clp);
 		if (delegation != NULL)
 			nfs_do_return_delegation(inode, delegation, 0);
 	}
@@ -354,9 +357,7 @@ int nfs_inode_return_delegation(struct inode *inode)
 	int err = 0;
 
 	if (rcu_access_pointer(nfsi->delegation) != NULL) {
-		spin_lock(&clp->cl_lock);
-		delegation = nfs_detach_delegation_locked(nfsi, NULL, clp);
-		spin_unlock(&clp->cl_lock);
+		delegation = nfs_detach_delegation(nfsi, clp);
 		if (delegation != NULL) {
 			nfs_wb_all(inode);
 			err = __nfs_inode_return_delegation(inode, delegation, 1);
@@ -530,9 +531,7 @@ restart:
 		inode = nfs_delegation_grab_inode(delegation);
 		if (inode == NULL)
 			continue;
-		spin_lock(&clp->cl_lock);
-		delegation = nfs_detach_delegation_locked(NFS_I(inode), NULL, clp);
-		spin_unlock(&clp->cl_lock);
+		delegation = nfs_detach_delegation(NFS_I(inode), clp);
 		rcu_read_unlock();
 		if (delegation != NULL)
 			nfs_free_delegation(delegation);


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:56184 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932737Ab2AMULR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:17 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 10/44] NFS: Export symbols needed by a v3 module
Date: Fri, 13 Jan 2012 15:10:19 -0500
Message-Id: <1326485453-1350-11-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Otherwise there would be a bunch of "symbol not defined" errors.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/dir.c   |    1 +
 fs/nfs/inode.c |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 6b2813b..a5e3a36 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2138,6 +2138,7 @@ void nfs_access_zap_cache(struct inode *inode)
 	spin_unlock(&nfs_access_lru_lock);
 	nfs_access_free_list(&head);
 }
+EXPORT_SYMBOL_GPL(nfs_access_zap_cache);
 
 static struct nfs_access_entry *nfs_access_search_rbtree(struct inode *inode, struct rpc_cred *cred)
 {
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 35db7b8..cf2bab9 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -185,6 +185,7 @@ void nfs_zap_acl_cache(struct inode *inode)
 	NFS_I(inode)->cache_validity &= ~NFS_INO_INVALID_ACL;
 	spin_unlock(&inode->i_lock);
 }
+EXPORT_SYMBOL_GPL(nfs_zap_acl_cache);
 
 void nfs_invalidate_atime(struct inode *inode)
 {
@@ -850,6 +851,7 @@ int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 		return NFS_STALE(inode) ? -ESTALE : 0;
 	return __nfs_revalidate_inode(server, inode);
 }
+EXPORT_SYMBOL_GPL(nfs_revalidate_inode);
 
 static int nfs_invalidate_mapping(struct inode *inode, struct address_space *mapping)
 {
@@ -1146,6 +1148,7 @@ int nfs_post_op_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	spin_unlock(&inode->i_lock);
 	return status;
 }
+EXPORT_SYMBOL_GPL(nfs_post_op_update_inode);
 
 /**
  * nfs_post_op_update_inode_force_wcc - try to update the inode attribute cache
-- 
1.7.8.3


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34174 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187AbcFVUsd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2016 16:48:33 -0400
Received: by mail-io0-f194.google.com with SMTP id 100so9134810ioh.1
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jun 2016 13:48:33 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 13/13] NFS: Remove unused function nfs_revalidate_mapping_protected()
Date: Wed, 22 Jun 2016 16:47:48 -0400
Message-Id: <1466628468-3958-13-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466628468-3958-12-git-send-email-trond.myklebust@primarydata.com>
References: <1466628468-3958-1-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-2-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-3-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-4-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-5-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-6-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-7-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-8-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-9-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-10-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-11-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-12-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up...

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c         | 38 ++++----------------------------------
 include/linux/nfs_fs.h |  1 -
 2 files changed, 4 insertions(+), 35 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 9521fa6154c8..3f683ae85d43 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1123,14 +1123,12 @@ out:
 }
 
 /**
- * __nfs_revalidate_mapping - Revalidate the pagecache
+ * nfs_revalidate_mapping - Revalidate the pagecache
  * @inode - pointer to host inode
  * @mapping - pointer to mapping
- * @may_lock - take inode->i_mutex?
  */
-static int __nfs_revalidate_mapping(struct inode *inode,
-		struct address_space *mapping,
-		bool may_lock)
+int nfs_revalidate_mapping(struct inode *inode,
+		struct address_space *mapping)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	unsigned long *bitlock = &nfsi->flags;
@@ -1179,12 +1177,7 @@ static int __nfs_revalidate_mapping(struct inode *inode,
 	nfsi->cache_validity &= ~NFS_INO_INVALID_DATA;
 	spin_unlock(&inode->i_lock);
 	trace_nfs_invalidate_mapping_enter(inode);
-	if (may_lock) {
-		inode_lock(inode);
-		ret = nfs_invalidate_mapping(inode, mapping);
-		inode_unlock(inode);
-	} else
-		ret = nfs_invalidate_mapping(inode, mapping);
+	ret = nfs_invalidate_mapping(inode, mapping);
 	trace_nfs_invalidate_mapping_exit(inode, ret);
 
 	clear_bit_unlock(NFS_INO_INVALIDATING, bitlock);
@@ -1194,29 +1187,6 @@ out:
 	return ret;
 }
 
-/**
- * nfs_revalidate_mapping - Revalidate the pagecache
- * @inode - pointer to host inode
- * @mapping - pointer to mapping
- */
-int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
-{
-	return __nfs_revalidate_mapping(inode, mapping, false);
-}
-
-/**
- * nfs_revalidate_mapping_protected - Revalidate the pagecache
- * @inode - pointer to host inode
- * @mapping - pointer to mapping
- *
- * Differs from nfs_revalidate_mapping() in that it grabs the inode->i_mutex
- * while invalidating the mapping.
- */
-int nfs_revalidate_mapping_protected(struct inode *inode, struct address_space *mapping)
-{
-	return __nfs_revalidate_mapping(inode, mapping, true);
-}
-
 static bool nfs_file_has_writers(struct nfs_inode *nfsi)
 {
 	struct inode *inode = &nfsi->vfs_inode;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 225d17d35277..810124b33327 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -351,7 +351,6 @@ extern int nfs_revalidate_inode_rcu(struct nfs_server *server, struct inode *ino
 extern int __nfs_revalidate_inode(struct nfs_server *, struct inode *);
 extern int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping);
 extern int nfs_revalidate_mapping_rcu(struct inode *inode);
-extern int nfs_revalidate_mapping_protected(struct inode *inode, struct address_space *mapping);
 extern int nfs_setattr(struct dentry *, struct iattr *);
 extern void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr, struct nfs_fattr *);
 extern void nfs_setsecurity(struct inode *inode, struct nfs_fattr *fattr,
-- 
2.7.4


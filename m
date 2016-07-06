Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34096 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932422AbcGFWa6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jul 2016 18:30:58 -0400
Received: by mail-it0-f68.google.com with SMTP id f6so891588ith.1
        for <linux-nfs@vger.kernel.org>; Wed, 06 Jul 2016 15:30:58 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 22/28] NFS: Remove unused function nfs_revalidate_mapping_protected()
Date: Wed,  6 Jul 2016 18:29:59 -0400
Message-Id: <1467844205-76852-23-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1467844205-76852-22-git-send-email-trond.myklebust@primarydata.com>
References: <1467844205-76852-1-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-2-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-3-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-4-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-5-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-6-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-7-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-8-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-9-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-10-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-11-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-12-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-13-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-14-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-15-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-16-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-17-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-18-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-19-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-20-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-21-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-22-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up...

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c         | 38 ++++----------------------------------
 include/linux/nfs_fs.h |  1 -
 2 files changed, 4 insertions(+), 35 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 6c0618eb5d57..0e0500f2bb6b 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1131,14 +1131,12 @@ out:
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
@@ -1187,12 +1185,7 @@ static int __nfs_revalidate_mapping(struct inode *inode,
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
@@ -1202,29 +1195,6 @@ out:
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


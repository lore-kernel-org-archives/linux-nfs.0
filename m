Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:40938 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757079AbaFTRl3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Jun 2014 13:41:29 -0400
Received: by mail-ie0-f173.google.com with SMTP id y20so3510731ier.4
        for <linux-nfs@vger.kernel.org>; Fri, 20 Jun 2014 10:41:29 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Scott Mayhew <smayhew@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/3] NFS: Don't mark the data cache as invalid if it has been flushed
Date: Fri, 20 Jun 2014 13:41:22 -0400
Message-Id: <1403286083-14345-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1403286083-14345-2-git-send-email-trond.myklebust@primarydata.com>
References: <20140620125140.GH4510@tonberry.usersys.redhat.com>
 <1403286083-14345-1-git-send-email-trond.myklebust@primarydata.com>
 <1403286083-14345-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we have functions such as nfs_write_pageuptodate() that use
the cache_validity flags to check if the data cache is valid or not,
it is a little more important to keep the flags in sync with the
state of the data cache.
In particular, we'd like to ensure that if the data cache is empty, we
don't start marking it as needing revalidation.

Reported-by: Scott Mayhew <smayhew@redhat.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c | 75 +++++++++++++++++++++++++++++++---------------------------
 1 file changed, 40 insertions(+), 35 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 51dda21ebc4e..9927913c97c2 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -147,6 +147,17 @@ int nfs_sync_mapping(struct address_space *mapping)
 	return ret;
 }
 
+static void nfs_set_cache_invalid(struct inode *inode, unsigned long flags)
+{
+	struct nfs_inode *nfsi = NFS_I(inode);
+
+	if (inode->i_mapping->nrpages == 0)
+		flags &= ~NFS_INO_INVALID_DATA;
+	nfsi->cache_validity |= flags;
+	if (flags & NFS_INO_INVALID_DATA)
+		nfs_fscache_invalidate(inode);
+}
+
 /*
  * Invalidate the local caches
  */
@@ -162,17 +173,16 @@ static void nfs_zap_caches_locked(struct inode *inode)
 
 	memset(NFS_I(inode)->cookieverf, 0, sizeof(NFS_I(inode)->cookieverf));
 	if (S_ISREG(mode) || S_ISDIR(mode) || S_ISLNK(mode)) {
-		nfs_fscache_invalidate(inode);
-		nfsi->cache_validity |= NFS_INO_INVALID_ATTR
+		nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR
 					| NFS_INO_INVALID_DATA
 					| NFS_INO_INVALID_ACCESS
 					| NFS_INO_INVALID_ACL
-					| NFS_INO_REVAL_PAGECACHE;
+					| NFS_INO_REVAL_PAGECACHE);
 	} else
-		nfsi->cache_validity |= NFS_INO_INVALID_ATTR
+		nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR
 					| NFS_INO_INVALID_ACCESS
 					| NFS_INO_INVALID_ACL
-					| NFS_INO_REVAL_PAGECACHE;
+					| NFS_INO_REVAL_PAGECACHE);
 	nfs_zap_label_cache_locked(nfsi);
 }
 
@@ -187,8 +197,7 @@ void nfs_zap_mapping(struct inode *inode, struct address_space *mapping)
 {
 	if (mapping->nrpages != 0) {
 		spin_lock(&inode->i_lock);
-		NFS_I(inode)->cache_validity |= NFS_INO_INVALID_DATA;
-		nfs_fscache_invalidate(inode);
+		nfs_set_cache_invalid(inode, NFS_INO_INVALID_DATA);
 		spin_unlock(&inode->i_lock);
 	}
 }
@@ -209,7 +218,7 @@ EXPORT_SYMBOL_GPL(nfs_zap_acl_cache);
 void nfs_invalidate_atime(struct inode *inode)
 {
 	spin_lock(&inode->i_lock);
-	NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATIME;
+	nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATIME);
 	spin_unlock(&inode->i_lock);
 }
 EXPORT_SYMBOL_GPL(nfs_invalidate_atime);
@@ -369,7 +378,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
 		inode->i_mode = fattr->mode;
 		if ((fattr->valid & NFS_ATTR_FATTR_MODE) == 0
 				&& nfs_server_capable(inode, NFS_CAP_MODE))
-			nfsi->cache_validity |= NFS_INO_INVALID_ATTR;
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
 		/* Why so? Because we want revalidate for devices/FIFOs, and
 		 * that's precisely what we have in nfs_file_inode_operations.
 		 */
@@ -415,36 +424,36 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
 		if (fattr->valid & NFS_ATTR_FATTR_ATIME)
 			inode->i_atime = fattr->atime;
 		else if (nfs_server_capable(inode, NFS_CAP_ATIME))
-			nfsi->cache_validity |= NFS_INO_INVALID_ATTR;
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
 		if (fattr->valid & NFS_ATTR_FATTR_MTIME)
 			inode->i_mtime = fattr->mtime;
 		else if (nfs_server_capable(inode, NFS_CAP_MTIME))
-			nfsi->cache_validity |= NFS_INO_INVALID_ATTR;
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
 		if (fattr->valid & NFS_ATTR_FATTR_CTIME)
 			inode->i_ctime = fattr->ctime;
 		else if (nfs_server_capable(inode, NFS_CAP_CTIME))
-			nfsi->cache_validity |= NFS_INO_INVALID_ATTR;
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
 		if (fattr->valid & NFS_ATTR_FATTR_CHANGE)
 			inode->i_version = fattr->change_attr;
 		else if (nfs_server_capable(inode, NFS_CAP_CHANGE_ATTR))
-			nfsi->cache_validity |= NFS_INO_INVALID_ATTR;
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
 		if (fattr->valid & NFS_ATTR_FATTR_SIZE)
 			inode->i_size = nfs_size_to_loff_t(fattr->size);
 		else
-			nfsi->cache_validity |= NFS_INO_INVALID_ATTR
-				| NFS_INO_REVAL_PAGECACHE;
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR
+				| NFS_INO_REVAL_PAGECACHE);
 		if (fattr->valid & NFS_ATTR_FATTR_NLINK)
 			set_nlink(inode, fattr->nlink);
 		else if (nfs_server_capable(inode, NFS_CAP_NLINK))
-			nfsi->cache_validity |= NFS_INO_INVALID_ATTR;
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
 		if (fattr->valid & NFS_ATTR_FATTR_OWNER)
 			inode->i_uid = fattr->uid;
 		else if (nfs_server_capable(inode, NFS_CAP_OWNER))
-			nfsi->cache_validity |= NFS_INO_INVALID_ATTR;
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
 		if (fattr->valid & NFS_ATTR_FATTR_GROUP)
 			inode->i_gid = fattr->gid;
 		else if (nfs_server_capable(inode, NFS_CAP_OWNER_GROUP))
-			nfsi->cache_validity |= NFS_INO_INVALID_ATTR;
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
 		if (fattr->valid & NFS_ATTR_FATTR_BLOCKS_USED)
 			inode->i_blocks = fattr->du.nfs2.blocks;
 		if (fattr->valid & NFS_ATTR_FATTR_SPACE_USED) {
@@ -550,6 +559,9 @@ static int nfs_vmtruncate(struct inode * inode, loff_t offset)
 
 	spin_lock(&inode->i_lock);
 	i_size_write(inode, offset);
+	/* Optimisation */
+	if (offset == 0)
+		NFS_I(inode)->cache_validity &= ~NFS_INO_INVALID_DATA;
 	spin_unlock(&inode->i_lock);
 
 	truncate_pagecache(inode, offset);
@@ -578,7 +590,8 @@ void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr)
 			inode->i_uid = attr->ia_uid;
 		if ((attr->ia_valid & ATTR_GID) != 0)
 			inode->i_gid = attr->ia_gid;
-		NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
+		nfs_set_cache_invalid(inode, NFS_INO_INVALID_ACCESS
+				| NFS_INO_INVALID_ACL);
 		spin_unlock(&inode->i_lock);
 	}
 	if ((attr->ia_valid & ATTR_SIZE) != 0) {
@@ -1101,7 +1114,7 @@ static unsigned long nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr
 			&& inode->i_version == fattr->pre_change_attr) {
 		inode->i_version = fattr->change_attr;
 		if (S_ISDIR(inode->i_mode))
-			nfsi->cache_validity |= NFS_INO_INVALID_DATA;
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_DATA);
 		ret |= NFS_INO_INVALID_ATTR;
 	}
 	/* If we have atomic WCC data, we may update some attributes */
@@ -1117,7 +1130,7 @@ static unsigned long nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr
 			&& timespec_equal(&inode->i_mtime, &fattr->pre_mtime)) {
 		memcpy(&inode->i_mtime, &fattr->mtime, sizeof(inode->i_mtime));
 		if (S_ISDIR(inode->i_mode))
-			nfsi->cache_validity |= NFS_INO_INVALID_DATA;
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_DATA);
 		ret |= NFS_INO_INVALID_ATTR;
 	}
 	if ((fattr->valid & NFS_ATTR_FATTR_PRESIZE)
@@ -1128,9 +1141,6 @@ static unsigned long nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr
 		ret |= NFS_INO_INVALID_ATTR;
 	}
 
-	if (nfsi->cache_validity & NFS_INO_INVALID_DATA)
-		nfs_fscache_invalidate(inode);
-
 	return ret;
 }
 
@@ -1189,7 +1199,7 @@ static int nfs_check_inode_attributes(struct inode *inode, struct nfs_fattr *fat
 		invalid |= NFS_INO_INVALID_ATIME;
 
 	if (invalid != 0)
-		nfsi->cache_validity |= invalid;
+		nfs_set_cache_invalid(inode, invalid);
 
 	nfsi->read_cache_jiffies = fattr->time_start;
 	return 0;
@@ -1402,13 +1412,11 @@ EXPORT_SYMBOL_GPL(nfs_refresh_inode);
 
 static int nfs_post_op_update_inode_locked(struct inode *inode, struct nfs_fattr *fattr)
 {
-	struct nfs_inode *nfsi = NFS_I(inode);
+	unsigned long invalid = NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
 
-	nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
-	if (S_ISDIR(inode->i_mode)) {
-		nfsi->cache_validity |= NFS_INO_INVALID_DATA;
-		nfs_fscache_invalidate(inode);
-	}
+	if (S_ISDIR(inode->i_mode))
+		invalid |= NFS_INO_INVALID_DATA;
+	nfs_set_cache_invalid(inode, invalid);
 	if ((fattr->valid & NFS_ATTR_FATTR) == 0)
 		return 0;
 	return nfs_refresh_inode_locked(inode, fattr);
@@ -1703,10 +1711,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		invalid &= ~NFS_INO_INVALID_DATA;
 	if (!NFS_PROTO(inode)->have_delegation(inode, FMODE_READ) ||
 			(save_cache_validity & NFS_INO_REVAL_FORCED))
-		nfsi->cache_validity |= invalid;
-
-	if (invalid & NFS_INO_INVALID_DATA)
-		nfs_fscache_invalidate(inode);
+		nfs_set_cache_invalid(inode, invalid);
 
 	return 0;
  out_err:
-- 
1.9.3


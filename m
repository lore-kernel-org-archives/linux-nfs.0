Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:32944 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751541AbeCTUyB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 16:54:01 -0400
Received: by mail-it0-f68.google.com with SMTP id z143-v6so13980790itc.0
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2018 13:54:01 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 5/6] NFS: More fine grained attribute tracking
Date: Tue, 20 Mar 2018 16:53:31 -0400
Message-Id: <20180320205332.94132-6-trond.myklebust@primarydata.com>
In-Reply-To: <20180320205332.94132-5-trond.myklebust@primarydata.com>
References: <20180320205332.94132-1-trond.myklebust@primarydata.com>
 <20180320205332.94132-2-trond.myklebust@primarydata.com>
 <20180320205332.94132-3-trond.myklebust@primarydata.com>
 <20180320205332.94132-4-trond.myklebust@primarydata.com>
 <20180320205332.94132-5-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, if the NFS_INO_INVALID_ATTR flag is set, for instance by
a call to nfs_post_op_update_inode_locked(), then it will not be cleared
until all the attributes have been revalidated. This means, for instance,
that NFSv4 writes will always force a full attribute revalidation.

Track the ctime, mtime, size and change attribute separately from the
other attributes so that we can have nfs_post_op_update_inode_locked()
set them correctly, and later have the cache consistency bitmask be
able to clear them.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/dir.c           |   4 +-
 fs/nfs/inode.c         | 109 +++++++++++++++++++++++++++++--------------------
 fs/nfs/nfs4proc.c      |   7 +++-
 fs/nfs/write.c         |   7 +++-
 include/linux/nfs_fs.h |  21 +++++++---
 5 files changed, 94 insertions(+), 54 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 8001f8c7ad0e..73f8b43d988c 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1272,7 +1272,9 @@ static void nfs_drop_nlink(struct inode *inode)
 	/* drop the inode if we're reasonably sure this is the last link */
 	if (inode->i_nlink == 1)
 		clear_nlink(inode);
-	NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATTR;
+	NFS_I(inode)->cache_validity |= NFS_INO_INVALID_CHANGE
+		| NFS_INO_INVALID_CTIME
+		| NFS_INO_INVALID_OTHER;
 	spin_unlock(&inode->i_lock);
 }
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 6e5a96e2e9a0..23880f45c1e4 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -452,7 +452,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
 		inode->i_mode = fattr->mode;
 		if ((fattr->valid & NFS_ATTR_FATTR_MODE) == 0
 				&& nfs_server_capable(inode, NFS_CAP_MODE))
-			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_OTHER);
 		/* Why so? Because we want revalidate for devices/FIFOs, and
 		 * that's precisely what we have in nfs_file_inode_operations.
 		 */
@@ -498,37 +498,35 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
 		if (fattr->valid & NFS_ATTR_FATTR_ATIME)
 			inode->i_atime = fattr->atime;
 		else if (nfs_server_capable(inode, NFS_CAP_ATIME))
-			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATIME);
 		if (fattr->valid & NFS_ATTR_FATTR_MTIME)
 			inode->i_mtime = fattr->mtime;
 		else if (nfs_server_capable(inode, NFS_CAP_MTIME))
-			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_MTIME);
 		if (fattr->valid & NFS_ATTR_FATTR_CTIME)
 			inode->i_ctime = fattr->ctime;
 		else if (nfs_server_capable(inode, NFS_CAP_CTIME))
-			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_CTIME);
 		if (fattr->valid & NFS_ATTR_FATTR_CHANGE)
 			inode_set_iversion_raw(inode, fattr->change_attr);
 		else
-			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR
-				| NFS_INO_REVAL_PAGECACHE);
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_CHANGE);
 		if (fattr->valid & NFS_ATTR_FATTR_SIZE)
 			inode->i_size = nfs_size_to_loff_t(fattr->size);
 		else
-			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR
-				| NFS_INO_REVAL_PAGECACHE);
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_SIZE);
 		if (fattr->valid & NFS_ATTR_FATTR_NLINK)
 			set_nlink(inode, fattr->nlink);
 		else if (nfs_server_capable(inode, NFS_CAP_NLINK))
-			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_OTHER);
 		if (fattr->valid & NFS_ATTR_FATTR_OWNER)
 			inode->i_uid = fattr->uid;
 		else if (nfs_server_capable(inode, NFS_CAP_OWNER))
-			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_OTHER);
 		if (fattr->valid & NFS_ATTR_FATTR_GROUP)
 			inode->i_gid = fattr->gid;
 		else if (nfs_server_capable(inode, NFS_CAP_OWNER_GROUP))
-			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_OTHER);
 		if (fattr->valid & NFS_ATTR_FATTR_BLOCKS_USED)
 			inode->i_blocks = fattr->du.nfs2.blocks;
 		if (fattr->valid & NFS_ATTR_FATTR_SPACE_USED) {
@@ -657,6 +655,7 @@ static int nfs_vmtruncate(struct inode * inode, loff_t offset)
  * nfs_setattr_update_inode - Update inode metadata after a setattr call.
  * @inode: pointer to struct inode
  * @attr: pointer to struct iattr
+ * @fattr: pointer to struct nfs_fattr
  *
  * Note: we do this in the *proc.c in order to ensure that
  *       it works for things like exclusive creates too.
@@ -669,6 +668,8 @@ void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr,
 
 	spin_lock(&inode->i_lock);
 	NFS_I(inode)->attr_gencount = fattr->gencount;
+	nfs_set_cache_invalid(inode, NFS_INO_INVALID_CHANGE
+			| NFS_INO_INVALID_CTIME);
 	if ((attr->ia_valid & (ATTR_MODE|ATTR_UID|ATTR_GID)) != 0) {
 		if ((attr->ia_valid & ATTR_MODE) != 0) {
 			int mode = attr->ia_mode & S_IALLUGO;
@@ -683,13 +684,12 @@ void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr,
 				| NFS_INO_INVALID_ACL);
 	}
 	if ((attr->ia_valid & ATTR_SIZE) != 0) {
+		nfs_set_cache_invalid(inode, NFS_INO_INVALID_MTIME);
 		nfs_inc_stats(inode, NFSIOS_SETATTRTRUNC);
 		nfs_vmtruncate(inode, attr->ia_size);
 	}
 	if (fattr->valid)
 		nfs_update_inode(inode, fattr);
-	else
-		NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATTR;
 	spin_unlock(&inode->i_lock);
 }
 EXPORT_SYMBOL_GPL(nfs_setattr_update_inode);
@@ -1361,33 +1361,41 @@ static int nfs_check_inode_attributes(struct inode *inode, struct nfs_fattr *fat
 	if (!nfs_file_has_buffered_writers(nfsi)) {
 		/* Verify a few of the more important attributes */
 		if ((fattr->valid & NFS_ATTR_FATTR_CHANGE) != 0 && !inode_eq_iversion_raw(inode, fattr->change_attr))
-			invalid |= NFS_INO_INVALID_ATTR | NFS_INO_REVAL_PAGECACHE;
+			invalid |= NFS_INO_INVALID_CHANGE
+				| NFS_INO_REVAL_PAGECACHE;
 
 		if ((fattr->valid & NFS_ATTR_FATTR_MTIME) && !timespec_equal(&inode->i_mtime, &fattr->mtime))
-			invalid |= NFS_INO_INVALID_ATTR;
+			invalid |= NFS_INO_INVALID_MTIME;
 
 		if ((fattr->valid & NFS_ATTR_FATTR_CTIME) && !timespec_equal(&inode->i_ctime, &fattr->ctime))
-			invalid |= NFS_INO_INVALID_ATTR;
+			invalid |= NFS_INO_INVALID_CTIME;
 
 		if (fattr->valid & NFS_ATTR_FATTR_SIZE) {
 			cur_size = i_size_read(inode);
 			new_isize = nfs_size_to_loff_t(fattr->size);
 			if (cur_size != new_isize)
-				invalid |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
+				invalid |= NFS_INO_INVALID_SIZE
+					| NFS_INO_REVAL_PAGECACHE;
 		}
 	}
 
 	/* Have any file permissions changed? */
 	if ((fattr->valid & NFS_ATTR_FATTR_MODE) && (inode->i_mode & S_IALLUGO) != (fattr->mode & S_IALLUGO))
-		invalid |= NFS_INO_INVALID_ATTR | NFS_INO_INVALID_ACCESS | NFS_INO_INVALID_ACL;
+		invalid |= NFS_INO_INVALID_ACCESS
+			| NFS_INO_INVALID_ACL
+			| NFS_INO_INVALID_OTHER;
 	if ((fattr->valid & NFS_ATTR_FATTR_OWNER) && !uid_eq(inode->i_uid, fattr->uid))
-		invalid |= NFS_INO_INVALID_ATTR | NFS_INO_INVALID_ACCESS | NFS_INO_INVALID_ACL;
+		invalid |= NFS_INO_INVALID_ACCESS
+			| NFS_INO_INVALID_ACL
+			| NFS_INO_INVALID_OTHER;
 	if ((fattr->valid & NFS_ATTR_FATTR_GROUP) && !gid_eq(inode->i_gid, fattr->gid))
-		invalid |= NFS_INO_INVALID_ATTR | NFS_INO_INVALID_ACCESS | NFS_INO_INVALID_ACL;
+		invalid |= NFS_INO_INVALID_ACCESS
+			| NFS_INO_INVALID_ACL
+			| NFS_INO_INVALID_OTHER;
 
 	/* Has the link count changed? */
 	if ((fattr->valid & NFS_ATTR_FATTR_NLINK) && inode->i_nlink != fattr->nlink)
-		invalid |= NFS_INO_INVALID_ATTR;
+		invalid |= NFS_INO_INVALID_OTHER;
 
 	if ((fattr->valid & NFS_ATTR_FATTR_ATIME) && !timespec_equal(&inode->i_atime, &fattr->atime))
 		invalid |= NFS_INO_INVALID_ATIME;
@@ -1589,10 +1597,9 @@ int nfs_refresh_inode(struct inode *inode, struct nfs_fattr *fattr)
 }
 EXPORT_SYMBOL_GPL(nfs_refresh_inode);
 
-static int nfs_post_op_update_inode_locked(struct inode *inode, struct nfs_fattr *fattr)
+static int nfs_post_op_update_inode_locked(struct inode *inode,
+		struct nfs_fattr *fattr, unsigned int invalid)
 {
-	unsigned long invalid = NFS_INO_INVALID_ATTR;
-
 	if (S_ISDIR(inode->i_mode))
 		invalid |= NFS_INO_INVALID_DATA;
 	nfs_set_cache_invalid(inode, invalid);
@@ -1621,7 +1628,9 @@ int nfs_post_op_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 
 	spin_lock(&inode->i_lock);
 	nfs_fattr_set_barrier(fattr);
-	status = nfs_post_op_update_inode_locked(inode, fattr);
+	status = nfs_post_op_update_inode_locked(inode, fattr,
+			NFS_INO_INVALID_CHANGE
+			| NFS_INO_INVALID_CTIME);
 	spin_unlock(&inode->i_lock);
 
 	return status;
@@ -1673,7 +1682,10 @@ int nfs_post_op_update_inode_force_wcc_locked(struct inode *inode, struct nfs_fa
 		fattr->valid |= NFS_ATTR_FATTR_PRESIZE;
 	}
 out_noforce:
-	status = nfs_post_op_update_inode_locked(inode, fattr);
+	status = nfs_post_op_update_inode_locked(inode, fattr,
+			NFS_INO_INVALID_CHANGE
+			| NFS_INO_INVALID_CTIME
+			| NFS_INO_INVALID_MTIME);
 	return status;
 }
 
@@ -1795,12 +1807,15 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 					inode->i_sb->s_id, inode->i_ino);
 			/* Could it be a race with writeback? */
 			if (!have_writers) {
-				invalid |= NFS_INO_INVALID_ATTR
+				invalid |= NFS_INO_INVALID_CHANGE
 					| NFS_INO_INVALID_DATA
 					| NFS_INO_INVALID_ACCESS
 					| NFS_INO_INVALID_ACL;
 				/* Force revalidate of all attributes */
-				save_cache_validity |= NFS_INO_INVALID_ATTR;
+				save_cache_validity |= NFS_INO_INVALID_CTIME
+					| NFS_INO_INVALID_MTIME
+					| NFS_INO_INVALID_SIZE
+					| NFS_INO_INVALID_OTHER;
 				if (S_ISDIR(inode->i_mode))
 					nfs_force_lookup_revalidate(inode);
 			}
@@ -1808,7 +1823,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		}
 	} else {
 		nfsi->cache_validity |= save_cache_validity &
-				(NFS_INO_INVALID_ATTR
+				(NFS_INO_INVALID_CHANGE
 				| NFS_INO_REVAL_PAGECACHE
 				| NFS_INO_REVAL_FORCED);
 		cache_revalidated = false;
@@ -1818,7 +1833,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		memcpy(&inode->i_mtime, &fattr->mtime, sizeof(inode->i_mtime));
 	} else if (server->caps & NFS_CAP_MTIME) {
 		nfsi->cache_validity |= save_cache_validity &
-				(NFS_INO_INVALID_ATTR
+				(NFS_INO_INVALID_MTIME
 				| NFS_INO_REVAL_FORCED);
 		cache_revalidated = false;
 	}
@@ -1827,7 +1842,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		memcpy(&inode->i_ctime, &fattr->ctime, sizeof(inode->i_ctime));
 	} else if (server->caps & NFS_CAP_CTIME) {
 		nfsi->cache_validity |= save_cache_validity &
-				(NFS_INO_INVALID_ATTR
+				(NFS_INO_INVALID_CTIME
 				| NFS_INO_REVAL_FORCED);
 		cache_revalidated = false;
 	}
@@ -1842,7 +1857,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 			if (!nfs_have_writebacks(inode) || new_isize > cur_isize) {
 				i_size_write(inode, new_isize);
 				if (!have_writers)
-					invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
+					invalid |= NFS_INO_INVALID_DATA;
 			}
 			dprintk("NFS: isize change on server for file %s/%ld "
 					"(%Ld to %Ld)\n",
@@ -1853,7 +1868,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		}
 	} else {
 		nfsi->cache_validity |= save_cache_validity &
-				(NFS_INO_INVALID_ATTR
+				(NFS_INO_INVALID_SIZE
 				| NFS_INO_REVAL_PAGECACHE
 				| NFS_INO_REVAL_FORCED);
 		cache_revalidated = false;
@@ -1874,55 +1889,61 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 			umode_t newmode = inode->i_mode & S_IFMT;
 			newmode |= fattr->mode & S_IALLUGO;
 			inode->i_mode = newmode;
-			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
+			invalid |= NFS_INO_INVALID_ACCESS
+				| NFS_INO_INVALID_ACL
+				| NFS_INO_INVALID_OTHER;
 		}
 	} else if (server->caps & NFS_CAP_MODE) {
 		nfsi->cache_validity |= save_cache_validity &
-				(NFS_INO_INVALID_ATTR
-				| NFS_INO_INVALID_ACCESS
+				(NFS_INO_INVALID_ACCESS
 				| NFS_INO_INVALID_ACL
+				| NFS_INO_INVALID_OTHER
 				| NFS_INO_REVAL_FORCED);
 		cache_revalidated = false;
 	}
 
 	if (fattr->valid & NFS_ATTR_FATTR_OWNER) {
 		if (!uid_eq(inode->i_uid, fattr->uid)) {
-			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
+			invalid |= NFS_INO_INVALID_ACCESS
+				| NFS_INO_INVALID_ACL
+				| NFS_INO_INVALID_OTHER;
 			inode->i_uid = fattr->uid;
 		}
 	} else if (server->caps & NFS_CAP_OWNER) {
 		nfsi->cache_validity |= save_cache_validity &
-				(NFS_INO_INVALID_ATTR
-				| NFS_INO_INVALID_ACCESS
+				(NFS_INO_INVALID_ACCESS
 				| NFS_INO_INVALID_ACL
+				| NFS_INO_INVALID_OTHER
 				| NFS_INO_REVAL_FORCED);
 		cache_revalidated = false;
 	}
 
 	if (fattr->valid & NFS_ATTR_FATTR_GROUP) {
 		if (!gid_eq(inode->i_gid, fattr->gid)) {
-			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
+			invalid |= NFS_INO_INVALID_ACCESS
+				| NFS_INO_INVALID_ACL
+				| NFS_INO_INVALID_OTHER;
 			inode->i_gid = fattr->gid;
 		}
 	} else if (server->caps & NFS_CAP_OWNER_GROUP) {
 		nfsi->cache_validity |= save_cache_validity &
-				(NFS_INO_INVALID_ATTR
-				| NFS_INO_INVALID_ACCESS
+				(NFS_INO_INVALID_ACCESS
 				| NFS_INO_INVALID_ACL
+				| NFS_INO_INVALID_OTHER
 				| NFS_INO_REVAL_FORCED);
 		cache_revalidated = false;
 	}
 
 	if (fattr->valid & NFS_ATTR_FATTR_NLINK) {
 		if (inode->i_nlink != fattr->nlink) {
-			invalid |= NFS_INO_INVALID_ATTR;
+			invalid |= NFS_INO_INVALID_OTHER;
 			if (S_ISDIR(inode->i_mode))
 				invalid |= NFS_INO_INVALID_DATA;
 			set_nlink(inode, fattr->nlink);
 		}
 	} else if (server->caps & NFS_CAP_NLINK) {
 		nfsi->cache_validity |= save_cache_validity &
-				(NFS_INO_INVALID_ATTR
+				(NFS_INO_INVALID_OTHER
 				| NFS_INO_REVAL_FORCED);
 		cache_revalidated = false;
 	}
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b4ebee12fe28..acb3350c7571 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1045,7 +1045,9 @@ static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo,
 	struct nfs_inode *nfsi = NFS_I(dir);
 
 	spin_lock(&dir->i_lock);
-	nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
+	nfsi->cache_validity |= NFS_INO_INVALID_CTIME
+		| NFS_INO_INVALID_MTIME
+		| NFS_INO_INVALID_DATA;
 	if (cinfo->atomic && cinfo->before == inode_peek_iversion_raw(dir)) {
 		nfsi->cache_validity &= ~NFS_INO_REVAL_PAGECACHE;
 		nfsi->attrtimeo_timestamp = jiffies;
@@ -5364,7 +5366,8 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 	 * so mark the attribute cache invalid.
 	 */
 	spin_lock(&inode->i_lock);
-	NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATTR;
+	NFS_I(inode)->cache_validity |= NFS_INO_INVALID_CHANGE
+		| NFS_INO_INVALID_CTIME;
 	spin_unlock(&inode->i_lock);
 	nfs_access_zap_cache(inode);
 	nfs_zap_acl_cache(inode);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e7d8ceae8f26..485ce488eb0b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1562,8 +1562,11 @@ static int nfs_writeback_done(struct rpc_task *task,
 	}
 
 	/* Deal with the suid/sgid bit corner case */
-	if (nfs_should_remove_suid(inode))
-		nfs_mark_for_revalidate(inode);
+	if (nfs_should_remove_suid(inode)) {
+		spin_lock(&inode->i_lock);
+		NFS_I(inode)->cache_validity |= NFS_INO_INVALID_OTHER;
+		spin_unlock(&inode->i_lock);
+	}
 	return 0;
 }
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 4afb11be73f4..2f129bbfaae8 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -198,7 +198,6 @@ struct nfs_inode {
 /*
  * Cache validity bit flags
  */
-#define NFS_INO_INVALID_ATTR	BIT(0)		/* cached attrs are invalid */
 #define NFS_INO_INVALID_DATA	BIT(1)		/* cached data is invalid */
 #define NFS_INO_INVALID_ATIME	BIT(2)		/* cached atime is invalid */
 #define NFS_INO_INVALID_ACCESS	BIT(3)		/* cached access cred invalid */
@@ -206,6 +205,17 @@ struct nfs_inode {
 #define NFS_INO_REVAL_PAGECACHE	BIT(5)		/* must revalidate pagecache */
 #define NFS_INO_REVAL_FORCED	BIT(6)		/* force revalidation ignoring a delegation */
 #define NFS_INO_INVALID_LABEL	BIT(7)		/* cached label is invalid */
+#define NFS_INO_INVALID_CHANGE	BIT(8)		/* cached change is invalid */
+#define NFS_INO_INVALID_CTIME	BIT(9)		/* cached ctime is invalid */
+#define NFS_INO_INVALID_MTIME	BIT(10)		/* cached mtime is invalid */
+#define NFS_INO_INVALID_SIZE	BIT(11)		/* cached size is invalid */
+#define NFS_INO_INVALID_OTHER	BIT(12)		/* other attrs are invalid */
+
+#define NFS_INO_INVALID_ATTR	(NFS_INO_INVALID_CHANGE \
+		| NFS_INO_INVALID_CTIME \
+		| NFS_INO_INVALID_MTIME \
+		| NFS_INO_INVALID_SIZE \
+		| NFS_INO_INVALID_OTHER)	/* inode metadata is invalid */
 
 /*
  * Bit offsets in flags field
@@ -292,10 +302,11 @@ static inline void nfs_mark_for_revalidate(struct inode *inode)
 	struct nfs_inode *nfsi = NFS_I(inode);
 
 	spin_lock(&inode->i_lock);
-	nfsi->cache_validity |= NFS_INO_INVALID_ATTR |
-				NFS_INO_REVAL_PAGECACHE |
-				NFS_INO_INVALID_ACCESS |
-				NFS_INO_INVALID_ACL;
+	nfsi->cache_validity |= NFS_INO_REVAL_PAGECACHE
+		| NFS_INO_INVALID_ACCESS
+		| NFS_INO_INVALID_ACL
+		| NFS_INO_INVALID_CHANGE
+		| NFS_INO_INVALID_CTIME;
 	if (S_ISDIR(inode->i_mode))
 		nfsi->cache_validity |= NFS_INO_INVALID_DATA;
 	spin_unlock(&inode->i_lock);
-- 
2.14.3


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:36098 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753609AbbL3QMD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Dec 2015 11:12:03 -0500
Received: by mail-io0-f169.google.com with SMTP id o67so354497993iof.3
        for <linux-nfs@vger.kernel.org>; Wed, 30 Dec 2015 08:12:00 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Donald Buczek <buczek@molgen.mpg.de>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2] NFS: Fix attribute cache revalidation
Date: Wed, 30 Dec 2015 11:11:32 -0500
Message-Id: <1451491892-11125-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a NFSv4 client uses the cache_consistency_bitmask in order to
request only information about the change attribute, timestamps and
size, then it has not revalidated all attributes, and hence the
attribute timeout timestamp should not be updated.

Reported-by: Donald Buczek <buczek@molgen.mpg.de>
Cc: stable@vger.kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
V2:
* Fix space borkage
* Always update nfsi->attrtimeo_timestamp on successful revalidation

 fs/nfs/inode.c | 54 +++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 39 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index c7e8b87da5b2..3e2071a177fd 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1641,6 +1641,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	unsigned long invalid = 0;
 	unsigned long now = jiffies;
 	unsigned long save_cache_validity;
+	bool cache_revalidated = true;
 
 	dfprintk(VFS, "NFS: %s(%s/%lu fh_crc=0x%08x ct=%d info=0x%x)\n",
 			__func__, inode->i_sb->s_id, inode->i_ino,
@@ -1702,22 +1703,28 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 				nfs_force_lookup_revalidate(inode);
 			inode->i_version = fattr->change_attr;
 		}
-	} else
+	} else {
 		nfsi->cache_validity |= save_cache_validity;
+		cache_revalidated = false;
+	}
 
 	if (fattr->valid & NFS_ATTR_FATTR_MTIME) {
 		memcpy(&inode->i_mtime, &fattr->mtime, sizeof(inode->i_mtime));
-	} else if (server->caps & NFS_CAP_MTIME)
+	} else if (server->caps & NFS_CAP_MTIME) {
 		nfsi->cache_validity |= save_cache_validity &
 				(NFS_INO_INVALID_ATTR
 				| NFS_INO_REVAL_FORCED);
+		cache_revalidated = false;
+	}
 
 	if (fattr->valid & NFS_ATTR_FATTR_CTIME) {
 		memcpy(&inode->i_ctime, &fattr->ctime, sizeof(inode->i_ctime));
-	} else if (server->caps & NFS_CAP_CTIME)
+	} else if (server->caps & NFS_CAP_CTIME) {
 		nfsi->cache_validity |= save_cache_validity &
 				(NFS_INO_INVALID_ATTR
 				| NFS_INO_REVAL_FORCED);
+		cache_revalidated = false;
+	}
 
 	/* Check if our cached file size is stale */
 	if (fattr->valid & NFS_ATTR_FATTR_SIZE) {
@@ -1737,19 +1744,23 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 					(long long)cur_isize,
 					(long long)new_isize);
 		}
-	} else
+	} else {
 		nfsi->cache_validity |= save_cache_validity &
 				(NFS_INO_INVALID_ATTR
 				| NFS_INO_REVAL_PAGECACHE
 				| NFS_INO_REVAL_FORCED);
+		cache_revalidated = false;
+	}
 
 
 	if (fattr->valid & NFS_ATTR_FATTR_ATIME)
 		memcpy(&inode->i_atime, &fattr->atime, sizeof(inode->i_atime));
-	else if (server->caps & NFS_CAP_ATIME)
+	else if (server->caps & NFS_CAP_ATIME) {
 		nfsi->cache_validity |= save_cache_validity &
 				(NFS_INO_INVALID_ATIME
 				| NFS_INO_REVAL_FORCED);
+		cache_revalidated = false;
+	}
 
 	if (fattr->valid & NFS_ATTR_FATTR_MODE) {
 		if ((inode->i_mode & S_IALLUGO) != (fattr->mode & S_IALLUGO)) {
@@ -1758,36 +1769,42 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 			inode->i_mode = newmode;
 			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
 		}
-	} else if (server->caps & NFS_CAP_MODE)
+	} else if (server->caps & NFS_CAP_MODE) {
 		nfsi->cache_validity |= save_cache_validity &
 				(NFS_INO_INVALID_ATTR
 				| NFS_INO_INVALID_ACCESS
 				| NFS_INO_INVALID_ACL
 				| NFS_INO_REVAL_FORCED);
+		cache_revalidated = false;
+	}
 
 	if (fattr->valid & NFS_ATTR_FATTR_OWNER) {
 		if (!uid_eq(inode->i_uid, fattr->uid)) {
 			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
 			inode->i_uid = fattr->uid;
 		}
-	} else if (server->caps & NFS_CAP_OWNER)
+	} else if (server->caps & NFS_CAP_OWNER) {
 		nfsi->cache_validity |= save_cache_validity &
 				(NFS_INO_INVALID_ATTR
 				| NFS_INO_INVALID_ACCESS
 				| NFS_INO_INVALID_ACL
 				| NFS_INO_REVAL_FORCED);
+		cache_revalidated = false;
+	}
 
 	if (fattr->valid & NFS_ATTR_FATTR_GROUP) {
 		if (!gid_eq(inode->i_gid, fattr->gid)) {
 			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
 			inode->i_gid = fattr->gid;
 		}
-	} else if (server->caps & NFS_CAP_OWNER_GROUP)
+	} else if (server->caps & NFS_CAP_OWNER_GROUP) {
 		nfsi->cache_validity |= save_cache_validity &
 				(NFS_INO_INVALID_ATTR
 				| NFS_INO_INVALID_ACCESS
 				| NFS_INO_INVALID_ACL
 				| NFS_INO_REVAL_FORCED);
+		cache_revalidated = false;
+	}
 
 	if (fattr->valid & NFS_ATTR_FATTR_NLINK) {
 		if (inode->i_nlink != fattr->nlink) {
@@ -1796,19 +1813,22 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 				invalid |= NFS_INO_INVALID_DATA;
 			set_nlink(inode, fattr->nlink);
 		}
-	} else if (server->caps & NFS_CAP_NLINK)
+	} else if (server->caps & NFS_CAP_NLINK) {
 		nfsi->cache_validity |= save_cache_validity &
 				(NFS_INO_INVALID_ATTR
 				| NFS_INO_REVAL_FORCED);
+		cache_revalidated = false;
+	}
 
 	if (fattr->valid & NFS_ATTR_FATTR_SPACE_USED) {
 		/*
 		 * report the blocks in 512byte units
 		 */
 		inode->i_blocks = nfs_calc_block_size(fattr->du.nfs3.used);
- 	}
-	if (fattr->valid & NFS_ATTR_FATTR_BLOCKS_USED)
+	} else if (fattr->valid & NFS_ATTR_FATTR_BLOCKS_USED)
 		inode->i_blocks = fattr->du.nfs2.blocks;
+	else
+		cache_revalidated = false;
 
 	/* Update attrtimeo value if we're out of the unstable period */
 	if (invalid & NFS_INO_INVALID_ATTR) {
@@ -1818,9 +1838,13 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		/* Set barrier to be more recent than all outstanding updates */
 		nfsi->attr_gencount = nfs_inc_attr_generation_counter();
 	} else {
-		if (!time_in_range_open(now, nfsi->attrtimeo_timestamp, nfsi->attrtimeo_timestamp + nfsi->attrtimeo)) {
-			if ((nfsi->attrtimeo <<= 1) > NFS_MAXATTRTIMEO(inode))
-				nfsi->attrtimeo = NFS_MAXATTRTIMEO(inode);
+		if (cache_revalidated) {
+			if (!time_in_range_open(now, nfsi->attrtimeo_timestamp,
+				nfsi->attrtimeo_timestamp + nfsi->attrtimeo)) {
+				nfsi->attrtimeo <<= 1;
+				if (nfsi->attrtimeo > NFS_MAXATTRTIMEO(inode))
+					nfsi->attrtimeo = NFS_MAXATTRTIMEO(inode);
+			}
 			nfsi->attrtimeo_timestamp = now;
 		}
 		/* Set the barrier to be more recent than this fattr */
@@ -1829,7 +1853,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	}
 
 	/* Don't declare attrcache up to date if there were no attrs! */
-	if (fattr->valid != 0)
+	if (cache_revalidated)
 		invalid &= ~NFS_INO_INVALID_ATTR;
 
 	/* Don't invalidate the data if we were to blame */
-- 
2.5.0


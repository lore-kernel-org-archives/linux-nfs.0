From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 05/30] NFSv4: Support NFSv4 optional attributes in the
 struct nfs_fattr
Date: Wed, 11 Mar 2009 14:41:06 -0400
Message-ID: <20090311184106.5578.37034.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24945 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754647AbZCKSoO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:44:14 -0400
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIi3rE021754
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:44:11 -0700 (PDT)
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, filling struct nfs_fattr is more or less an all or nothing
operation, since NFSv2 and NFSv3 have only mandatory attributes.
In NFSv4, some attributes are optional, and so we may simply not be able to
fill in those fields. Furthermore, NFSv4 allows you to specify which
attributes you are interested in retrieving, thus permitting you to
optimise away retrieval of attributes that you know will no change...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c          |  243 ++++++++++++++++++++++++++++++-----------------
 fs/nfs/nfs2xdr.c        |    2 
 fs/nfs/nfs3xdr.c        |    6 +
 fs/nfs/nfs4xdr.c        |    6 +
 include/linux/nfs_xdr.h |   48 ++++++++-
 5 files changed, 202 insertions(+), 103 deletions(-)


diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 268ce3a..b7656bd 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -249,13 +249,10 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 	struct inode *inode = ERR_PTR(-ENOENT);
 	unsigned long hash;
 
-	if ((fattr->valid & NFS_ATTR_FATTR) == 0)
+	if ((fattr->valid & NFS_ATTR_FATTR_FILEID) == 0)
 		goto out_no_inode;
-
-	if (!fattr->nlink) {
-		printk("NFS: Buggy server - nlink == 0!\n");
+	if ((fattr->valid & NFS_ATTR_FATTR_TYPE) == 0)
 		goto out_no_inode;
-	}
 
 	hash = nfs_fattr_to_ino_t(fattr);
 
@@ -291,7 +288,8 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 			    && fattr->size <= NFS_LIMIT_READDIRPLUS)
 				set_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(inode)->flags);
 			/* Deal with crossing mountpoints */
-			if (!nfs_fsid_equal(&NFS_SB(sb)->fsid, &fattr->fsid)) {
+			if ((fattr->valid & NFS_ATTR_FATTR_FSID)
+					&& !nfs_fsid_equal(&NFS_SB(sb)->fsid, &fattr->fsid)) {
 				if (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)
 					inode->i_op = &nfs_referral_inode_operations;
 				else
@@ -304,28 +302,45 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 		else
 			init_special_inode(inode, inode->i_mode, fattr->rdev);
 
+		memset(&inode->i_atime, 0, sizeof(inode->i_atime));
+		memset(&inode->i_mtime, 0, sizeof(inode->i_mtime));
+		memset(&inode->i_ctime, 0, sizeof(inode->i_ctime));
+		nfsi->change_attr = 0;
+		inode->i_size = 0;
+		inode->i_nlink = 0;
+		inode->i_uid = -2;
+		inode->i_gid = -2;
+		inode->i_blocks = 0;
+		memset(nfsi->cookieverf, 0, sizeof(nfsi->cookieverf));
+
 		nfsi->read_cache_jiffies = fattr->time_start;
 		nfsi->attr_gencount = fattr->gencount;
-		inode->i_atime = fattr->atime;
-		inode->i_mtime = fattr->mtime;
-		inode->i_ctime = fattr->ctime;
-		if (fattr->valid & NFS_ATTR_FATTR_V4)
+		if (fattr->valid & NFS_ATTR_FATTR_ATIME)
+			inode->i_atime = fattr->atime;
+		if (fattr->valid & NFS_ATTR_FATTR_MTIME)
+			inode->i_mtime = fattr->mtime;
+		if (fattr->valid & NFS_ATTR_FATTR_CTIME)
+			inode->i_ctime = fattr->ctime;
+		if (fattr->valid & NFS_ATTR_FATTR_CHANGE)
 			nfsi->change_attr = fattr->change_attr;
-		inode->i_size = nfs_size_to_loff_t(fattr->size);
-		inode->i_nlink = fattr->nlink;
-		inode->i_uid = fattr->uid;
-		inode->i_gid = fattr->gid;
-		if (fattr->valid & (NFS_ATTR_FATTR_V3 | NFS_ATTR_FATTR_V4)) {
+		if (fattr->valid & NFS_ATTR_FATTR_SIZE)
+			inode->i_size = nfs_size_to_loff_t(fattr->size);
+		if (fattr->valid & NFS_ATTR_FATTR_NLINK)
+			inode->i_nlink = fattr->nlink;
+		if (fattr->valid & NFS_ATTR_FATTR_OWNER)
+			inode->i_uid = fattr->uid;
+		if (fattr->valid & NFS_ATTR_FATTR_GROUP)
+			inode->i_gid = fattr->gid;
+		if (fattr->valid & NFS_ATTR_FATTR_BLOCKS_USED)
+			inode->i_blocks = fattr->du.nfs2.blocks;
+		if (fattr->valid & NFS_ATTR_FATTR_SPACE_USED) {
 			/*
 			 * report the blocks in 512byte units
 			 */
 			inode->i_blocks = nfs_calc_block_size(fattr->du.nfs3.used);
-		} else {
-			inode->i_blocks = fattr->du.nfs2.blocks;
 		}
 		nfsi->attrtimeo = NFS_MINATTRTIMEO(inode);
 		nfsi->attrtimeo_timestamp = now;
-		memset(nfsi->cookieverf, 0, sizeof(nfsi->cookieverf));
 		nfsi->access_cache = RB_ROOT;
 
 		unlock_new_inode(inode);
@@ -812,25 +827,31 @@ static void nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 
-	if ((fattr->valid & NFS_ATTR_WCC_V4) != 0 &&
-			nfsi->change_attr == fattr->pre_change_attr) {
+	if ((fattr->valid & NFS_ATTR_FATTR_PRECHANGE)
+			&& (fattr->valid & NFS_ATTR_FATTR_CHANGE)
+			&& nfsi->change_attr == fattr->pre_change_attr) {
 		nfsi->change_attr = fattr->change_attr;
 		if (S_ISDIR(inode->i_mode))
 			nfsi->cache_validity |= NFS_INO_INVALID_DATA;
 	}
 	/* If we have atomic WCC data, we may update some attributes */
-	if ((fattr->valid & NFS_ATTR_WCC) != 0) {
-		if (timespec_equal(&inode->i_ctime, &fattr->pre_ctime))
+	if ((fattr->valid & NFS_ATTR_FATTR_PRECTIME)
+			&& (fattr->valid & NFS_ATTR_FATTR_CTIME)
+			&& timespec_equal(&inode->i_ctime, &fattr->pre_ctime))
 			memcpy(&inode->i_ctime, &fattr->ctime, sizeof(inode->i_ctime));
-		if (timespec_equal(&inode->i_mtime, &fattr->pre_mtime)) {
+
+	if ((fattr->valid & NFS_ATTR_FATTR_PREMTIME)
+			&& (fattr->valid & NFS_ATTR_FATTR_MTIME)
+			&& timespec_equal(&inode->i_mtime, &fattr->pre_mtime)) {
 			memcpy(&inode->i_mtime, &fattr->mtime, sizeof(inode->i_mtime));
 			if (S_ISDIR(inode->i_mode))
 				nfsi->cache_validity |= NFS_INO_INVALID_DATA;
-		}
-		if (i_size_read(inode) == nfs_size_to_loff_t(fattr->pre_size) &&
-		    nfsi->npages == 0)
-			i_size_write(inode, nfs_size_to_loff_t(fattr->size));
 	}
+	if ((fattr->valid & NFS_ATTR_FATTR_PRESIZE)
+			&& (fattr->valid & NFS_ATTR_FATTR_SIZE)
+			&& i_size_read(inode) == nfs_size_to_loff_t(fattr->pre_size)
+			&& nfsi->npages == 0)
+			i_size_write(inode, nfs_size_to_loff_t(fattr->size));
 }
 
 /**
@@ -850,35 +871,39 @@ static int nfs_check_inode_attributes(struct inode *inode, struct nfs_fattr *fat
 
 
 	/* Has the inode gone and changed behind our back? */
-	if (nfsi->fileid != fattr->fileid
-			|| (inode->i_mode & S_IFMT) != (fattr->mode & S_IFMT)) {
+	if ((fattr->valid & NFS_ATTR_FATTR_FILEID) && nfsi->fileid != fattr->fileid)
+		return -EIO;
+	if ((fattr->valid & NFS_ATTR_FATTR_TYPE) && (inode->i_mode & S_IFMT) != (fattr->mode & S_IFMT))
 		return -EIO;
-	}
 
-	if ((fattr->valid & NFS_ATTR_FATTR_V4) != 0 &&
+	if ((fattr->valid & NFS_ATTR_FATTR_CHANGE) != 0 &&
 			nfsi->change_attr != fattr->change_attr)
 		invalid |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
 
 	/* Verify a few of the more important attributes */
-	if (!timespec_equal(&inode->i_mtime, &fattr->mtime))
+	if ((fattr->valid & NFS_ATTR_FATTR_MTIME) && !timespec_equal(&inode->i_mtime, &fattr->mtime))
 		invalid |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
 
-	cur_size = i_size_read(inode);
- 	new_isize = nfs_size_to_loff_t(fattr->size);
-	if (cur_size != new_isize && nfsi->npages == 0)
-		invalid |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
+	if (fattr->valid & NFS_ATTR_FATTR_SIZE) {
+		cur_size = i_size_read(inode);
+		new_isize = nfs_size_to_loff_t(fattr->size);
+		if (cur_size != new_isize && nfsi->npages == 0)
+			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
+	}
 
 	/* Have any file permissions changed? */
-	if ((inode->i_mode & S_IALLUGO) != (fattr->mode & S_IALLUGO)
-			|| inode->i_uid != fattr->uid
-			|| inode->i_gid != fattr->gid)
+	if ((fattr->valid & NFS_ATTR_FATTR_MODE) && (inode->i_mode & S_IALLUGO) != (fattr->mode & S_IALLUGO))
+		invalid |= NFS_INO_INVALID_ATTR | NFS_INO_INVALID_ACCESS | NFS_INO_INVALID_ACL;
+	if ((fattr->valid & NFS_ATTR_FATTR_OWNER) && inode->i_uid != fattr->uid)
+		invalid |= NFS_INO_INVALID_ATTR | NFS_INO_INVALID_ACCESS | NFS_INO_INVALID_ACL;
+	if ((fattr->valid & NFS_ATTR_FATTR_GROUP) && inode->i_gid != fattr->gid)
 		invalid |= NFS_INO_INVALID_ATTR | NFS_INO_INVALID_ACCESS | NFS_INO_INVALID_ACL;
 
 	/* Has the link count changed? */
-	if (inode->i_nlink != fattr->nlink)
+	if ((fattr->valid & NFS_ATTR_FATTR_NLINK) && inode->i_nlink != fattr->nlink)
 		invalid |= NFS_INO_INVALID_ATTR;
 
-	if (!timespec_equal(&inode->i_atime, &fattr->atime))
+	if ((fattr->valid & NFS_ATTR_FATTR_ATIME) && !timespec_equal(&inode->i_atime, &fattr->atime))
 		invalid |= NFS_INO_INVALID_ATIME;
 
 	if (invalid != 0)
@@ -890,11 +915,15 @@ static int nfs_check_inode_attributes(struct inode *inode, struct nfs_fattr *fat
 
 static int nfs_ctime_need_update(const struct inode *inode, const struct nfs_fattr *fattr)
 {
+	if (!(fattr->valid & NFS_ATTR_FATTR_CTIME))
+		return 0;
 	return timespec_compare(&fattr->ctime, &inode->i_ctime) > 0;
 }
 
 static int nfs_size_need_update(const struct inode *inode, const struct nfs_fattr *fattr)
 {
+	if (!(fattr->valid & NFS_ATTR_FATTR_SIZE))
+		return 0;
 	return nfs_size_to_loff_t(fattr->size) > i_size_read(inode);
 }
 
@@ -1030,20 +1059,31 @@ int nfs_post_op_update_inode_force_wcc(struct inode *inode, struct nfs_fattr *fa
 	/* Don't do a WCC update if these attributes are already stale */
 	if ((fattr->valid & NFS_ATTR_FATTR) == 0 ||
 			!nfs_inode_attrs_need_update(inode, fattr)) {
-		fattr->valid &= ~(NFS_ATTR_WCC_V4|NFS_ATTR_WCC);
+		fattr->valid &= ~(NFS_ATTR_FATTR_PRECHANGE
+				| NFS_ATTR_FATTR_PRESIZE
+				| NFS_ATTR_FATTR_PREMTIME
+				| NFS_ATTR_FATTR_PRECTIME);
 		goto out_noforce;
 	}
-	if ((fattr->valid & NFS_ATTR_FATTR_V4) != 0 &&
-			(fattr->valid & NFS_ATTR_WCC_V4) == 0) {
+	if ((fattr->valid & NFS_ATTR_FATTR_CHANGE) != 0 &&
+			(fattr->valid & NFS_ATTR_FATTR_PRECHANGE) == 0) {
 		fattr->pre_change_attr = NFS_I(inode)->change_attr;
-		fattr->valid |= NFS_ATTR_WCC_V4;
+		fattr->valid |= NFS_ATTR_FATTR_PRECHANGE;
 	}
-	if ((fattr->valid & NFS_ATTR_FATTR) != 0 &&
-			(fattr->valid & NFS_ATTR_WCC) == 0) {
+	if ((fattr->valid & NFS_ATTR_FATTR_CTIME) != 0 &&
+			(fattr->valid & NFS_ATTR_FATTR_PRECTIME) == 0) {
 		memcpy(&fattr->pre_ctime, &inode->i_ctime, sizeof(fattr->pre_ctime));
+		fattr->valid |= NFS_ATTR_FATTR_PRECTIME;
+	}
+	if ((fattr->valid & NFS_ATTR_FATTR_MTIME) != 0 &&
+			(fattr->valid & NFS_ATTR_FATTR_PREMTIME) == 0) {
 		memcpy(&fattr->pre_mtime, &inode->i_mtime, sizeof(fattr->pre_mtime));
+		fattr->valid |= NFS_ATTR_FATTR_PREMTIME;
+	}
+	if ((fattr->valid & NFS_ATTR_FATTR_SIZE) != 0 &&
+			(fattr->valid & NFS_ATTR_FATTR_PRESIZE) == 0) {
 		fattr->pre_size = i_size_read(inode);
-		fattr->valid |= NFS_ATTR_WCC;
+		fattr->valid |= NFS_ATTR_FATTR_PRESIZE;
 	}
 out_noforce:
 	status = nfs_post_op_update_inode_locked(inode, fattr);
@@ -1075,18 +1115,18 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 			__func__, inode->i_sb->s_id, inode->i_ino,
 			atomic_read(&inode->i_count), fattr->valid);
 
-	if (nfsi->fileid != fattr->fileid)
+	if ((fattr->valid & NFS_ATTR_FATTR_FILEID) && nfsi->fileid != fattr->fileid)
 		goto out_fileid;
 
 	/*
 	 * Make sure the inode's type hasn't changed.
 	 */
-	if ((inode->i_mode & S_IFMT) != (fattr->mode & S_IFMT))
+	if ((fattr->valid & NFS_ATTR_FATTR_TYPE) && (inode->i_mode & S_IFMT) != (fattr->mode & S_IFMT))
 		goto out_changed;
 
 	server = NFS_SERVER(inode);
 	/* Update the fsid? */
-	if (S_ISDIR(inode->i_mode) &&
+	if (S_ISDIR(inode->i_mode) && (fattr->valid & NFS_ATTR_FATTR_FSID) &&
 			!nfs_fsid_equal(&server->fsid, &fattr->fsid) &&
 			!test_bit(NFS_INO_MOUNTPOINT, &nfsi->flags))
 		server->fsid = fattr->fsid;
@@ -1096,14 +1136,27 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	 */
 	nfsi->read_cache_jiffies = fattr->time_start;
 
-	nfsi->cache_validity &= ~(NFS_INO_INVALID_ATTR | NFS_INO_INVALID_ATIME
-			| NFS_INO_REVAL_PAGECACHE);
+	if ((fattr->valid & NFS_ATTR_FATTR_CHANGE) || (fattr->valid & (NFS_ATTR_FATTR_MTIME|NFS_ATTR_FATTR_CTIME)))
+	    nfsi->cache_validity &= ~(NFS_INO_INVALID_ATTR
+		    | NFS_INO_INVALID_ATIME
+		    | NFS_INO_REVAL_PAGECACHE);
 
 	/* Do atomic weak cache consistency updates */
 	nfs_wcc_update_inode(inode, fattr);
 
 	/* More cache consistency checks */
-	if (!(fattr->valid & NFS_ATTR_FATTR_V4)) {
+	if (fattr->valid & NFS_ATTR_FATTR_CHANGE) {
+		if (nfsi->change_attr != fattr->change_attr) {
+			dprintk("NFS: change_attr change on server for file %s/%ld\n",
+					inode->i_sb->s_id, inode->i_ino);
+			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
+			if (S_ISDIR(inode->i_mode))
+				nfs_force_lookup_revalidate(inode);
+			nfsi->change_attr = fattr->change_attr;
+		}
+	}
+
+	if (fattr->valid & NFS_ATTR_FATTR_MTIME) {
 		/* NFSv2/v3: Check if the mtime agrees */
 		if (!timespec_equal(&inode->i_mtime, &fattr->mtime)) {
 			dprintk("NFS: mtime change on server for file %s/%ld\n",
@@ -1111,7 +1164,10 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
 			if (S_ISDIR(inode->i_mode))
 				nfs_force_lookup_revalidate(inode);
+			memcpy(&inode->i_mtime, &fattr->mtime, sizeof(inode->i_mtime));
 		}
+	}
+	if (fattr->valid & NFS_ATTR_FATTR_CTIME) {
 		/* If ctime has changed we should definitely clear access+acl caches */
 		if (!timespec_equal(&inode->i_ctime, &fattr->ctime)) {
 			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
@@ -1122,59 +1178,66 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 				invalid |= NFS_INO_INVALID_DATA;
 				nfs_force_lookup_revalidate(inode);
 			}
+			memcpy(&inode->i_ctime, &fattr->ctime, sizeof(inode->i_ctime));
 		}
-	} else if (nfsi->change_attr != fattr->change_attr) {
-		dprintk("NFS: change_attr change on server for file %s/%ld\n",
-				inode->i_sb->s_id, inode->i_ino);
-		invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
-		if (S_ISDIR(inode->i_mode))
-			nfs_force_lookup_revalidate(inode);
 	}
 
 	/* Check if our cached file size is stale */
- 	new_isize = nfs_size_to_loff_t(fattr->size);
-	cur_isize = i_size_read(inode);
-	if (new_isize != cur_isize) {
-		/* Do we perhaps have any outstanding writes, or has
-		 * the file grown beyond our last write? */
-		if (nfsi->npages == 0 || new_isize > cur_isize) {
-			i_size_write(inode, new_isize);
-			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
+	if (fattr->valid & NFS_ATTR_FATTR_SIZE) {
+		new_isize = nfs_size_to_loff_t(fattr->size);
+		cur_isize = i_size_read(inode);
+		if (new_isize != cur_isize) {
+			/* Do we perhaps have any outstanding writes, or has
+			 * the file grown beyond our last write? */
+			if (nfsi->npages == 0 || new_isize > cur_isize) {
+				i_size_write(inode, new_isize);
+				invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
+			}
+			dprintk("NFS: isize change on server for file %s/%ld\n",
+					inode->i_sb->s_id, inode->i_ino);
 		}
-		dprintk("NFS: isize change on server for file %s/%ld\n",
-				inode->i_sb->s_id, inode->i_ino);
 	}
 
 
-	memcpy(&inode->i_mtime, &fattr->mtime, sizeof(inode->i_mtime));
-	memcpy(&inode->i_ctime, &fattr->ctime, sizeof(inode->i_ctime));
-	memcpy(&inode->i_atime, &fattr->atime, sizeof(inode->i_atime));
-	nfsi->change_attr = fattr->change_attr;
+	if (fattr->valid & NFS_ATTR_FATTR_ATIME)
+		memcpy(&inode->i_atime, &fattr->atime, sizeof(inode->i_atime));
 
-	if ((inode->i_mode & S_IALLUGO) != (fattr->mode & S_IALLUGO) ||
-	    inode->i_uid != fattr->uid ||
-	    inode->i_gid != fattr->gid)
-		invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
-
-	if (inode->i_nlink != fattr->nlink) {
-		invalid |= NFS_INO_INVALID_ATTR;
-		if (S_ISDIR(inode->i_mode))
-			invalid |= NFS_INO_INVALID_DATA;
+	if (fattr->valid & NFS_ATTR_FATTR_MODE) {
+		if ((inode->i_mode & S_IALLUGO) != (fattr->mode & S_IALLUGO)) {
+			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
+			inode->i_mode = fattr->mode;
+		}
+	}
+	if (fattr->valid & NFS_ATTR_FATTR_OWNER) {
+		if (inode->i_uid != fattr->uid) {
+			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
+			inode->i_uid = fattr->uid;
+		}
+	}
+	if (fattr->valid & NFS_ATTR_FATTR_GROUP) {
+		if (inode->i_gid != fattr->gid) {
+			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
+			inode->i_gid = fattr->gid;
+		}
 	}
 
-	inode->i_mode = fattr->mode;
-	inode->i_nlink = fattr->nlink;
-	inode->i_uid = fattr->uid;
-	inode->i_gid = fattr->gid;
+	if (fattr->valid & NFS_ATTR_FATTR_NLINK) {
+		if (inode->i_nlink != fattr->nlink) {
+			invalid |= NFS_INO_INVALID_ATTR;
+			if (S_ISDIR(inode->i_mode))
+				invalid |= NFS_INO_INVALID_DATA;
+			inode->i_nlink = fattr->nlink;
+		}
+	}
 
-	if (fattr->valid & (NFS_ATTR_FATTR_V3 | NFS_ATTR_FATTR_V4)) {
+	if (fattr->valid & NFS_ATTR_FATTR_SPACE_USED) {
 		/*
 		 * report the blocks in 512byte units
 		 */
 		inode->i_blocks = nfs_calc_block_size(fattr->du.nfs3.used);
- 	} else {
- 		inode->i_blocks = fattr->du.nfs2.blocks;
  	}
+	if (fattr->valid & NFS_ATTR_FATTR_BLOCKS_USED)
+		inode->i_blocks = fattr->du.nfs2.blocks;
 
 	/* Update attrtimeo value if we're out of the unstable period */
 	if (invalid & NFS_INO_INVALID_ATTR) {
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 28bab67..bea9999 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -136,7 +136,7 @@ xdr_decode_fattr(__be32 *p, struct nfs_fattr *fattr)
 	p = xdr_decode_time(p, &fattr->atime);
 	p = xdr_decode_time(p, &fattr->mtime);
 	p = xdr_decode_time(p, &fattr->ctime);
-	fattr->valid |= NFS_ATTR_FATTR;
+	fattr->valid |= NFS_ATTR_FATTR_V2;
 	fattr->rdev = new_decode_dev(rdev);
 	if (fattr->type == NFCHR && rdev == NFS2_FIFO_DEV) {
 		fattr->type = NFFIFO;
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 6cdeacf..c0f7d02 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -177,7 +177,7 @@ xdr_decode_fattr(__be32 *p, struct nfs_fattr *fattr)
 	p = xdr_decode_time3(p, &fattr->ctime);
 
 	/* Update the mode bits */
-	fattr->valid |= (NFS_ATTR_FATTR | NFS_ATTR_FATTR_V3);
+	fattr->valid |= NFS_ATTR_FATTR_V3;
 	return p;
 }
 
@@ -233,7 +233,9 @@ xdr_decode_wcc_attr(__be32 *p, struct nfs_fattr *fattr)
 	p = xdr_decode_hyper(p, &fattr->pre_size);
 	p = xdr_decode_time3(p, &fattr->pre_mtime);
 	p = xdr_decode_time3(p, &fattr->pre_ctime);
-	fattr->valid |= NFS_ATTR_WCC;
+	fattr->valid |= NFS_ATTR_FATTR_PRESIZE
+		| NFS_ATTR_FATTR_PREMTIME
+		| NFS_ATTR_FATTR_PRECTIME;
 	return p;
 }
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 5f0ee3e..7d220da 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3012,7 +3012,7 @@ static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr, cons
 	if ((status = decode_attr_type(xdr, bitmap, &type)) != 0)
 		goto xdr_error;
 	fattr->type = nfs_type2fmt[type].nfs2type;
-	fmode = nfs_type2fmt[type].mode;
+	fattr->mode = nfs_type2fmt[type].mode;
 
 	if ((status = decode_attr_change(xdr, bitmap, &fattr->change_attr)) != 0)
 		goto xdr_error;
@@ -3026,7 +3026,7 @@ static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr, cons
 						struct nfs4_fs_locations,
 						fattr))) != 0)
 		goto xdr_error;
-	if ((status = decode_attr_mode(xdr, bitmap, &fattr->mode)) != 0)
+	if ((status = decode_attr_mode(xdr, bitmap, &fmode)) != 0)
 		goto xdr_error;
 	fattr->mode |= fmode;
 	if ((status = decode_attr_nlink(xdr, bitmap, &fattr->nlink)) != 0)
@@ -3050,7 +3050,7 @@ static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr, cons
 	if (fattr->fileid == 0 && fileid != 0)
 		fattr->fileid = fileid;
 	if ((status = verify_attr_len(xdr, savep, attrlen)) == 0)
-		fattr->valid = NFS_ATTR_FATTR | NFS_ATTR_FATTR_V3 | NFS_ATTR_FATTR_V4;
+		fattr->valid = NFS_ATTR_FATTR_V4;
 xdr_error:
 	dprintk("%s: xdr returned %d\n", __func__, -status);
 	return status;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 2e5f000..b99295e 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -27,7 +27,7 @@ static inline int nfs_fsid_equal(const struct nfs_fsid *a, const struct nfs_fsid
 }
 
 struct nfs_fattr {
-	unsigned short		valid;		/* which fields are valid */
+	unsigned int		valid;		/* which fields are valid */
 	__u64			pre_size;	/* pre_op_attr.size	  */
 	struct timespec		pre_mtime;	/* pre_op_attr.mtime	  */
 	struct timespec		pre_ctime;	/* pre_op_attr.ctime	  */
@@ -59,12 +59,46 @@ struct nfs_fattr {
 	unsigned long		gencount;
 };
 
-#define NFS_ATTR_WCC		0x0001		/* pre-op WCC data    */
-#define NFS_ATTR_FATTR		0x0002		/* post-op attributes */
-#define NFS_ATTR_FATTR_V3	0x0004		/* NFSv3 attributes */
-#define NFS_ATTR_FATTR_V4	0x0008		/* NFSv4 change attribute */
-#define NFS_ATTR_WCC_V4		0x0010		/* pre-op change attribute */
-#define NFS_ATTR_FATTR_V4_REFERRAL	0x0020		/* NFSv4 referral */
+#define NFS_ATTR_FATTR_TYPE		(1U << 0)
+#define NFS_ATTR_FATTR_MODE		(1U << 1)
+#define NFS_ATTR_FATTR_NLINK		(1U << 2)
+#define NFS_ATTR_FATTR_OWNER		(1U << 3)
+#define NFS_ATTR_FATTR_GROUP		(1U << 4)
+#define NFS_ATTR_FATTR_RDEV		(1U << 5)
+#define NFS_ATTR_FATTR_SIZE		(1U << 6)
+#define NFS_ATTR_FATTR_PRESIZE		(1U << 7)
+#define NFS_ATTR_FATTR_BLOCKS_USED	(1U << 8)
+#define NFS_ATTR_FATTR_SPACE_USED	(1U << 9)
+#define NFS_ATTR_FATTR_FSID		(1U << 10)
+#define NFS_ATTR_FATTR_FILEID		(1U << 11)
+#define NFS_ATTR_FATTR_ATIME		(1U << 12)
+#define NFS_ATTR_FATTR_MTIME		(1U << 13)
+#define NFS_ATTR_FATTR_CTIME		(1U << 14)
+#define NFS_ATTR_FATTR_PREMTIME		(1U << 15)
+#define NFS_ATTR_FATTR_PRECTIME		(1U << 16)
+#define NFS_ATTR_FATTR_CHANGE		(1U << 17)
+#define NFS_ATTR_FATTR_PRECHANGE	(1U << 18)
+#define NFS_ATTR_FATTR_V4_REFERRAL	(1U << 19)	/* NFSv4 referral */
+
+#define NFS_ATTR_FATTR (NFS_ATTR_FATTR_TYPE \
+		| NFS_ATTR_FATTR_MODE \
+		| NFS_ATTR_FATTR_NLINK \
+		| NFS_ATTR_FATTR_OWNER \
+		| NFS_ATTR_FATTR_GROUP \
+		| NFS_ATTR_FATTR_RDEV \
+		| NFS_ATTR_FATTR_SIZE \
+		| NFS_ATTR_FATTR_FSID \
+		| NFS_ATTR_FATTR_FILEID \
+		| NFS_ATTR_FATTR_ATIME \
+		| NFS_ATTR_FATTR_MTIME \
+		| NFS_ATTR_FATTR_CTIME)
+#define NFS_ATTR_FATTR_V2 (NFS_ATTR_FATTR \
+		| NFS_ATTR_FATTR_BLOCKS_USED)
+#define NFS_ATTR_FATTR_V3 (NFS_ATTR_FATTR \
+		| NFS_ATTR_FATTR_SPACE_USED)
+#define NFS_ATTR_FATTR_V4 (NFS_ATTR_FATTR \
+		| NFS_ATTR_FATTR_SPACE_USED \
+		| NFS_ATTR_FATTR_CHANGE)
 
 /*
  * Info on the file system


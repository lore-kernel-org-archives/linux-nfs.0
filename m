Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59097 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753746AbcD2M6Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Apr 2016 08:58:24 -0400
Subject: [PATCH 6/6] statx: CIFS: Return enhanced attributes
From: David Howells <dhowells@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-ext4@vger.kernel.org
Date: Fri, 29 Apr 2016 13:58:21 +0100
Message-ID: <20160429125821.23636.24489.stgit@warthog.procyon.org.uk>
In-Reply-To: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
References: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Return enhanced attributes from the CIFS filesystem.  This includes the
following:

 (1) Return the file creation time as btime.  We assume that the creation
     time won't change over the life of the inode.

 (2) Set STATX_INFO_AUTOMOUNT on referral/submount directories.

 (3) Unset STATX_INO if we made up the inode number and didn't get it from
     the server.

 (4) Unset STATX_[UG]ID if we are either returning values passed to mount
     and/or the server doesn't return them.

 (5) Set STATX_WIN_ATTRS and return windows attributes in st_win_attrs.

 (6) Set certain STATX_INFO_xxx to reflect a number of Windows file
     attributes:

	ATTR_TEMPORARY	-> STATX_INFO_TEMPORARY;
	ATTR_ENCRYPTED	-> STATX_INFO_ENCRYPTED;

 (7) Set STATX_INFO_REMOTE on all files fetched by CIFS.

 (8) Set STATX_INFO_NONSYSTEM_OWNERSHIP on all files as they all have
     Windows ownership details too.

Furthermore, what cifs_getattr() does can be controlled as follows:

 (1) If AT_NO_ATTR_SYNC is indicated then this will suppress the flushing
     of outstanding writes and the rereading of the inode's attributes with
     the server as detailed below.

 (2) Otherwise:

     (a) If AT_FORCE_ATTR_SYNC is indicated, or mtime, ctime or size are
     	 requested then the outstanding writes will be written to the
     	 server first.

     (b) The inode's attributes will be reread from the server:

     	 (i) if AT_FORCE_ATTR_SYNC is indicated;

        (ii) if the cached attributes have expired;

       (iii) extra attributes are requested that aren't normally stored.

If the inode isn't synchronised, then the cached attributes will be used -
even if expired - without reference to the server.  Some attributes may be
unavailable that would otherwise be provided.

Note that cifs_revalidate_dentry() will issue an extra operation to get the
FILE_ALL_INFO in addition to the FILE_UNIX_BASIC_INFO if it needs to
collect creation time and attributes on behalf of cifs_getattr().

[NOTE: THIS PATCH IS UNTESTED!]

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/cifs/cifsfs.h   |    4 +-
 fs/cifs/cifsglob.h |    8 ++++
 fs/cifs/dir.c      |    2 -
 fs/cifs/inode.c    |  117 ++++++++++++++++++++++++++++++++++++++++------------
 4 files changed, 101 insertions(+), 30 deletions(-)

diff --git a/fs/cifs/cifsfs.h b/fs/cifs/cifsfs.h
index 83aac8ba50b0..304f4567d207 100644
--- a/fs/cifs/cifsfs.h
+++ b/fs/cifs/cifsfs.h
@@ -67,9 +67,9 @@ extern int cifs_rmdir(struct inode *, struct dentry *);
 extern int cifs_rename2(struct inode *, struct dentry *, struct inode *,
 			struct dentry *, unsigned int);
 extern int cifs_revalidate_file_attr(struct file *filp);
-extern int cifs_revalidate_dentry_attr(struct dentry *);
+extern int cifs_revalidate_dentry_attr(struct dentry *, bool, bool);
 extern int cifs_revalidate_file(struct file *filp);
-extern int cifs_revalidate_dentry(struct dentry *);
+extern int cifs_revalidate_dentry(struct dentry *, bool, bool);
 extern int cifs_invalidate_mapping(struct inode *inode);
 extern int cifs_revalidate_mapping(struct inode *inode);
 extern int cifs_zap_mapping(struct inode *inode);
diff --git a/fs/cifs/cifsglob.h b/fs/cifs/cifsglob.h
index f2cc0b3d1af7..3225b16f7522 100644
--- a/fs/cifs/cifsglob.h
+++ b/fs/cifs/cifsglob.h
@@ -1166,7 +1166,11 @@ struct cifsInodeInfo {
 	unsigned long flags;
 	spinlock_t writers_lock;
 	unsigned int writers;		/* Number of writers on this inode */
+	bool btime_valid:1;		/* stored creation time is valid */
+	bool uid_faked:1;		/* true if i_uid is faked */
+	bool gid_faked:1;		/* true if i_gid is faked */
 	unsigned long time;		/* jiffies of last update of inode */
+	struct timespec btime;		/* creation time */
 	u64  server_eof;		/* current file size on server -- protected by i_lock */
 	u64  uniqueid;			/* server inode number */
 	u64  createtime;		/* creation time on server */
@@ -1379,6 +1383,9 @@ struct dfs_info3_param {
 #define CIFS_FATTR_NEED_REVAL		0x4
 #define CIFS_FATTR_INO_COLLISION	0x8
 #define CIFS_FATTR_UNKNOWN_NLINK	0x10
+#define CIFS_FATTR_WINATTRS_VALID	0x20	/* T if cf_btime and cf_cifsattrs valid */
+#define CIFS_FATTR_UID_FAKED		0x40	/* T if cf_uid is faked */
+#define CIFS_FATTR_GID_FAKED		0x80	/* T if cf_gid is faked */
 
 struct cifs_fattr {
 	u32		cf_flags;
@@ -1396,6 +1403,7 @@ struct cifs_fattr {
 	struct timespec	cf_atime;
 	struct timespec	cf_mtime;
 	struct timespec	cf_ctime;
+	struct timespec	cf_btime;
 };
 
 static inline void free_dfs_info_param(struct dfs_info3_param *param)
diff --git a/fs/cifs/dir.c b/fs/cifs/dir.c
index c3eb998a99bd..4984f04b0677 100644
--- a/fs/cifs/dir.c
+++ b/fs/cifs/dir.c
@@ -792,7 +792,7 @@ cifs_d_revalidate(struct dentry *direntry, unsigned int flags)
 		return -ECHILD;
 
 	if (d_really_is_positive(direntry)) {
-		if (cifs_revalidate_dentry(direntry))
+		if (cifs_revalidate_dentry(direntry, false, false))
 			return 0;
 		else {
 			/*
diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
index 5f9ad5c42180..dc1814b70c81 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -166,13 +166,21 @@ cifs_fattr_to_inode(struct inode *inode, struct cifs_fattr *fattr)
 	cifs_nlink_fattr_to_inode(inode, fattr);
 	inode->i_uid = fattr->cf_uid;
 	inode->i_gid = fattr->cf_gid;
+	if (fattr->cf_flags & CIFS_FATTR_UID_FAKED)
+		cifs_i->uid_faked = true;
+	if (fattr->cf_flags & CIFS_FATTR_GID_FAKED)
+		cifs_i->gid_faked = true;
 
 	/* if dynperm is set, don't clobber existing mode */
 	if (inode->i_state & I_NEW ||
 	    !(cifs_sb->mnt_cifs_flags & CIFS_MOUNT_DYNPERM))
 		inode->i_mode = fattr->cf_mode;
 
-	cifs_i->cifsAttrs = fattr->cf_cifsattrs;
+	if (fattr->cf_flags & CIFS_FATTR_WINATTRS_VALID) {
+		cifs_i->cifsAttrs = fattr->cf_cifsattrs;
+		cifs_i->btime = fattr->cf_btime;
+		cifs_i->btime_valid = true;
+	}
 
 	if (fattr->cf_flags & CIFS_FATTR_NEED_REVAL)
 		cifs_i->time = 0;
@@ -284,18 +292,22 @@ cifs_unix_basic_to_fattr(struct cifs_fattr *fattr, FILE_UNIX_BASIC_INFO *info,
 		u64 id = le64_to_cpu(info->Uid);
 		if (id < ((uid_t)-1)) {
 			kuid_t uid = make_kuid(&init_user_ns, id);
-			if (uid_valid(uid))
+			if (uid_valid(uid)) {
 				fattr->cf_uid = uid;
+				fattr->cf_flags |= CIFS_FATTR_UID_FAKED;
+			}
 		}
 	}
-	
+
 	fattr->cf_gid = cifs_sb->mnt_gid;
 	if (!(cifs_sb->mnt_cifs_flags & CIFS_MOUNT_OVERR_GID)) {
 		u64 id = le64_to_cpu(info->Gid);
 		if (id < ((gid_t)-1)) {
 			kgid_t gid = make_kgid(&init_user_ns, id);
-			if (gid_valid(gid))
+			if (gid_valid(gid)) {
 				fattr->cf_gid = gid;
+				fattr->cf_flags |= CIFS_FATTR_GID_FAKED;
+			}
 		}
 	}
 
@@ -324,7 +336,8 @@ cifs_create_dfs_fattr(struct cifs_fattr *fattr, struct super_block *sb)
 	fattr->cf_ctime = CURRENT_TIME;
 	fattr->cf_mtime = CURRENT_TIME;
 	fattr->cf_nlink = 2;
-	fattr->cf_flags |= CIFS_FATTR_DFS_REFERRAL;
+	fattr->cf_flags |= CIFS_FATTR_DFS_REFERRAL |
+		CIFS_FATTR_UID_FAKED | CIFS_FATTR_GID_FAKED;
 }
 
 static int
@@ -590,6 +603,7 @@ cifs_all_info_to_fattr(struct cifs_fattr *fattr, FILE_ALL_INFO *info,
 	struct cifs_tcon *tcon = cifs_sb_master_tcon(cifs_sb);
 
 	memset(fattr, 0, sizeof(*fattr));
+	fattr->cf_flags = CIFS_FATTR_WINATTRS_VALID;
 	fattr->cf_cifsattrs = le32_to_cpu(info->Attributes);
 	if (info->DeletePending)
 		fattr->cf_flags |= CIFS_FATTR_DELETE_PENDING;
@@ -601,6 +615,7 @@ cifs_all_info_to_fattr(struct cifs_fattr *fattr, FILE_ALL_INFO *info,
 
 	fattr->cf_ctime = cifs_NTtimeToUnix(info->ChangeTime);
 	fattr->cf_mtime = cifs_NTtimeToUnix(info->LastWriteTime);
+	fattr->cf_btime = cifs_NTtimeToUnix(info->CreationTime);
 
 	if (adjust_tz) {
 		fattr->cf_ctime.tv_sec += tcon->ses->server->timeAdj;
@@ -1907,7 +1922,8 @@ int cifs_revalidate_file_attr(struct file *filp)
 	return rc;
 }
 
-int cifs_revalidate_dentry_attr(struct dentry *dentry)
+int cifs_revalidate_dentry_attr(struct dentry *dentry,
+				bool want_extra_bits, bool force)
 {
 	unsigned int xid;
 	int rc = 0;
@@ -1918,7 +1934,7 @@ int cifs_revalidate_dentry_attr(struct dentry *dentry)
 	if (inode == NULL)
 		return -ENOENT;
 
-	if (!cifs_inode_needs_reval(inode))
+	if (!force && !cifs_inode_needs_reval(inode))
 		return rc;
 
 	xid = get_xid();
@@ -1935,9 +1951,12 @@ int cifs_revalidate_dentry_attr(struct dentry *dentry)
 		 full_path, inode, inode->i_count.counter,
 		 dentry, dentry->d_time, jiffies);
 
-	if (cifs_sb_master_tcon(CIFS_SB(sb))->unix_ext)
+	if (cifs_sb_master_tcon(CIFS_SB(sb))->unix_ext) {
 		rc = cifs_get_inode_info_unix(&inode, full_path, sb, xid);
-	else
+		if (rc != 0)
+			goto out;
+	}
+	if (!cifs_sb_master_tcon(CIFS_SB(sb))->unix_ext || want_extra_bits)
 		rc = cifs_get_inode_info(&inode, full_path, NULL, sb,
 					 xid, NULL);
 
@@ -1960,12 +1979,13 @@ int cifs_revalidate_file(struct file *filp)
 }
 
 /* revalidate a dentry's inode attributes */
-int cifs_revalidate_dentry(struct dentry *dentry)
+int cifs_revalidate_dentry(struct dentry *dentry,
+			   bool want_extra_bits, bool force)
 {
 	int rc;
 	struct inode *inode = d_inode(dentry);
 
-	rc = cifs_revalidate_dentry_attr(dentry);
+	rc = cifs_revalidate_dentry_attr(dentry, want_extra_bits, force);
 	if (rc)
 		return rc;
 
@@ -1978,28 +1998,62 @@ int cifs_getattr(struct vfsmount *mnt, struct dentry *dentry,
 	struct cifs_sb_info *cifs_sb = CIFS_SB(dentry->d_sb);
 	struct cifs_tcon *tcon = cifs_sb_master_tcon(cifs_sb);
 	struct inode *inode = d_inode(dentry);
+	struct cifsInodeInfo *cifs_i = CIFS_I(inode);
+	bool force = stat->query_flags & AT_FORCE_ATTR_SYNC;
+	bool want_extra_bits = false;
+	u32 info;
+	u32 attrs;
 	int rc;
 
-	/*
-	 * We need to be sure that all dirty pages are written and the server
-	 * has actual ctime, mtime and file length.
-	 */
-	if (!CIFS_CACHE_READ(CIFS_I(inode)) && inode->i_mapping &&
-	    inode->i_mapping->nrpages != 0) {
-		rc = filemap_fdatawait(inode->i_mapping);
-		if (rc) {
-			mapping_set_error(inode->i_mapping, rc);
-			return rc;
+	if (cifs_i->uid_faked)
+		stat->request_mask &= ~STATX_UID;
+	if (cifs_i->gid_faked)
+		stat->request_mask &= ~STATX_GID;
+
+	if ((stat->request_mask & STATX_BTIME && !cifs_i->btime_valid) ||
+	    stat->request_mask & STATX_WIN_ATTRS)
+		want_extra_bits = force = true;
+
+	if (!(stat->query_flags & AT_NO_ATTR_SYNC)) {
+		/* Unless we're explicitly told not to sync, we need to be sure
+		 * that all dirty pages are written and the server has actual
+		 * ctime, mtime and file length.
+		 */
+		bool flush = force;
+
+		if (stat->request_mask &
+		    (STATX_CTIME | STATX_MTIME | STATX_SIZE))
+			flush = true;
+
+		if (flush &&
+		    !CIFS_CACHE_READ(CIFS_I(inode)) && inode->i_mapping &&
+		    inode->i_mapping->nrpages != 0) {
+			rc = filemap_fdatawait(inode->i_mapping);
+			if (rc) {
+				mapping_set_error(inode->i_mapping, rc);
+				return rc;
+			}
 		}
-	}
 
-	rc = cifs_revalidate_dentry_attr(dentry);
-	if (rc)
-		return rc;
+		rc = cifs_revalidate_dentry(dentry, want_extra_bits, force);
+		if (rc)
+			return rc;
+	}
 
 	generic_fillattr(inode, stat);
 	stat->blksize = CIFS_MAX_MSGSIZE;
-	stat->ino = CIFS_I(inode)->uniqueid;
+
+	info = STATX_INFO_REMOTE | STATX_INFO_NONSYSTEM_OWNERSHIP;
+
+	if (cifs_i->btime_valid) {
+		stat->btime = cifs_i->btime;
+		stat->result_mask |= STATX_BTIME;
+	}
+
+	/* We don't promise an inode number if we made one up */
+	stat->ino = cifs_i->uniqueid;
+	if (!(cifs_sb->mnt_cifs_flags & CIFS_MOUNT_SERVER_INUM))
+		stat->result_mask &= ~STATX_INO;
 
 	/*
 	 * If on a multiuser mount without unix extensions or cifsacl being
@@ -2013,8 +2067,17 @@ int cifs_getattr(struct vfsmount *mnt, struct dentry *dentry,
 			stat->uid = current_fsuid();
 		if (!(cifs_sb->mnt_cifs_flags & CIFS_MOUNT_OVERR_GID))
 			stat->gid = current_fsgid();
+		stat->result_mask &= ~(STATX_UID | STATX_GID);
 	}
-	return rc;
+
+	attrs = cifs_i->cifsAttrs;
+	stat->win_attrs = attrs;
+	if (attrs & ATTR_TEMPORARY)	info |= STATX_INFO_TEMPORARY;
+	if (attrs & ATTR_ENCRYPTED)	info |= STATX_INFO_ENCRYPTED;
+	stat->information |= info;
+	stat->result_mask |= STATX_WIN_ATTRS;
+
+	return 0;
 }
 
 static int cifs_truncate_page(struct address_space *mapping, loff_t from)


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:7444 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750874Ab2DSOXe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Apr 2012 10:23:34 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 5/6] xstat: CIFS: Return extended attributes
To: linux-fsdevel@vger.kernel.org
Cc: dhowells@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        wine-devel@winehq.org, kfm-devel@kde.org, nautilus-list@gnome.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Date: Thu, 19 Apr 2012 15:07:06 +0100
Message-ID: <20120419140706.17272.72290.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
References: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Return extended attributes from the CIFS filesystem.  This includes the
following:

 (1) Return the file creation time as btime.  We assume that the creation time
     won't change over the life of the inode.

 (2) Set XSTAT_INFO_AUTOMOUNT on referral/submount directories.

 (3) Unset XSTAT_INO if we made up the inode number and didn't get it from the
     server.

 (4) Unset XSTAT_[UG]ID if we are either returning values passed to mount
     and/or the server doesn't return them.

 (5) Map various Windows file attributes to FS_xxx_FL flags in st_ioc_flags
     and XSTAT_INFO_xxx flags in st_information, fetching them from the server
     if we don't have them yet or don't have a current copy.

     Possibly things like Hidden, System and Archive should be FS_xxx_FL flags
     rather than XSTAT_INFO_xxx flags and st_ioc_flags should be expanded to
     64 bits.

 (6) Set XSTAT_INFO_REMOTE on all files fetched by CIFS.

 (7) Set XSTAT_INFO_NONSYSTEM_OWNERSHIP on all files as they all have Windows
     ownership details too.

 (8) Set XSTAT_INFO_HAS_ACL if CONFIG_CIFS_ACL=y as Windows ACLs are available
     on the object.

Furthermore, what cifs_getattr() does can be controlled as follows:

 (1) If AT_FORCE_ATTR_SYNC is indicated, or if the inode flags or creation time
     are requested but not yet collected, then the attributes will be reread
     unconditionally.

 (2) If the basic stats are requested or if the inode flags are requested and
     have been collected previously, then the attributes will be reread if out
     of date.

 (3) Otherwise the cached attributes will be used - even if expired - without
     reference to the server.

Note that cifs_revalidate_dentry() will issue an extra operation to get the
FILE_ALL_INFO in addition to the FILE_UNIX_BASIC_INFO if it needs to collect
creation time and attributes on behalf of cifs_getattr().

[NOTE: THIS PATCH IS UNTESTED!]

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/cifs/cifsfs.h   |    4 +-
 fs/cifs/cifsglob.h |   16 +++++--
 fs/cifs/dir.c      |    2 -
 fs/cifs/inode.c    |  120 +++++++++++++++++++++++++++++++++++++++++++++-------
 4 files changed, 118 insertions(+), 24 deletions(-)

diff --git a/fs/cifs/cifsfs.h b/fs/cifs/cifsfs.h
index d1389bb..021e327 100644
--- a/fs/cifs/cifsfs.h
+++ b/fs/cifs/cifsfs.h
@@ -56,9 +56,9 @@ extern int cifs_rmdir(struct inode *, struct dentry *);
 extern int cifs_rename(struct inode *, struct dentry *, struct inode *,
 		       struct dentry *);
 extern int cifs_revalidate_file_attr(struct file *filp);
-extern int cifs_revalidate_dentry_attr(struct dentry *);
+extern int cifs_revalidate_dentry_attr(struct dentry *, bool, bool);
 extern int cifs_revalidate_file(struct file *filp);
-extern int cifs_revalidate_dentry(struct dentry *);
+extern int cifs_revalidate_dentry(struct dentry *, bool, bool);
 extern int cifs_invalidate_mapping(struct inode *inode);
 extern int cifs_getattr(struct vfsmount *, struct dentry *, struct kstat *);
 extern int cifs_setattr(struct dentry *, struct iattr *);
diff --git a/fs/cifs/cifsglob.h b/fs/cifs/cifsglob.h
index 4ff6313..d3567da 100644
--- a/fs/cifs/cifsglob.h
+++ b/fs/cifs/cifsglob.h
@@ -621,11 +621,15 @@ struct cifsInodeInfo {
 	/* BB add in lists for dirty pages i.e. write caching info for oplock */
 	struct list_head openFileList;
 	__u32 cifsAttrs; /* e.g. DOS archive bit, sparse, compressed, system */
-	bool clientCanCacheRead;	/* read oplock */
-	bool clientCanCacheAll;		/* read and writebehind oplock */
-	bool delete_pending;		/* DELETE_ON_CLOSE is set */
-	bool invalid_mapping;		/* pagecache is invalid */
+	bool clientCanCacheRead:1;	/* read oplock */
+	bool clientCanCacheAll:1;	/* read and writebehind oplock */
+	bool delete_pending:1;		/* DELETE_ON_CLOSE is set */
+	bool invalid_mapping:1;		/* pagecache is invalid */
+	bool btime_valid:1;		/* stored creation time is valid */
+	bool uid_faked:1;		/* true if i_uid is faked */
+	bool gid_faked:1;		/* true if i_gid is faked */
 	unsigned long time;		/* jiffies of last update of inode */
+	struct timespec btime;		/* creation time */
 	u64  server_eof;		/* current file size on server -- protected by i_lock */
 	u64  uniqueid;			/* server inode number */
 	u64  createtime;		/* creation time on server */
@@ -833,6 +837,9 @@ struct dfs_info3_param {
 #define CIFS_FATTR_DELETE_PENDING	0x2
 #define CIFS_FATTR_NEED_REVAL		0x4
 #define CIFS_FATTR_INO_COLLISION	0x8
+#define CIFS_FATTR_WINATTRS_VALID	0x10	/* T if cf_btime and cf_cifsattrs valid */
+#define CIFS_FATTR_UID_FAKED		0x20	/* T if cf_uid is faked */
+#define CIFS_FATTR_GID_FAKED		0x40	/* T if cf_gid is faked */
 
 struct cifs_fattr {
 	u32		cf_flags;
@@ -850,6 +857,7 @@ struct cifs_fattr {
 	struct timespec	cf_atime;
 	struct timespec	cf_mtime;
 	struct timespec	cf_ctime;
+	struct timespec	cf_btime;
 };
 
 static inline void free_dfs_info_param(struct dfs_info3_param *param)
diff --git a/fs/cifs/dir.c b/fs/cifs/dir.c
index d172c8e..d9e03ae 100644
--- a/fs/cifs/dir.c
+++ b/fs/cifs/dir.c
@@ -664,7 +664,7 @@ cifs_d_revalidate(struct dentry *direntry, struct nameidata *nd)
 		return -ECHILD;
 
 	if (direntry->d_inode) {
-		if (cifs_revalidate_dentry(direntry))
+		if (cifs_revalidate_dentry(direntry, false, false))
 			return 0;
 		else {
 			/*
diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
index 745da3d..662d5ce 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -135,13 +135,21 @@ cifs_fattr_to_inode(struct inode *inode, struct cifs_fattr *fattr)
 	set_nlink(inode, fattr->cf_nlink);
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
@@ -248,15 +256,19 @@ cifs_unix_basic_to_fattr(struct cifs_fattr *fattr, FILE_UNIX_BASIC_INFO *info,
 		break;
 	}
 
-	if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_OVERR_UID)
+	if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_OVERR_UID) {
 		fattr->cf_uid = cifs_sb->mnt_uid;
-	else
+		fattr->cf_flags |= CIFS_FATTR_UID_FAKED;
+	} else {
 		fattr->cf_uid = le64_to_cpu(info->Uid);
+	}
 
-	if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_OVERR_GID)
+	if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_OVERR_GID) {
 		fattr->cf_gid = cifs_sb->mnt_gid;
-	else
+		fattr->cf_flags |= CIFS_FATTR_GID_FAKED;
+	} else {
 		fattr->cf_gid = le64_to_cpu(info->Gid);
+	}
 
 	fattr->cf_nlink = le64_to_cpu(info->Nlinks);
 }
@@ -283,7 +295,8 @@ cifs_create_dfs_fattr(struct cifs_fattr *fattr, struct super_block *sb)
 	fattr->cf_ctime = CURRENT_TIME;
 	fattr->cf_mtime = CURRENT_TIME;
 	fattr->cf_nlink = 2;
-	fattr->cf_flags |= CIFS_FATTR_DFS_REFERRAL;
+	fattr->cf_flags |= CIFS_FATTR_DFS_REFERRAL |
+		CIFS_FATTR_UID_FAKED | CIFS_FATTR_GID_FAKED;
 }
 
 int cifs_get_file_info_unix(struct file *filp)
@@ -510,6 +523,7 @@ cifs_all_info_to_fattr(struct cifs_fattr *fattr, FILE_ALL_INFO *info,
 	struct cifs_tcon *tcon = cifs_sb_master_tcon(cifs_sb);
 
 	memset(fattr, 0, sizeof(*fattr));
+	fattr->cf_flags = CIFS_FATTR_WINATTRS_VALID;
 	fattr->cf_cifsattrs = le32_to_cpu(info->Attributes);
 	if (info->DeletePending)
 		fattr->cf_flags |= CIFS_FATTR_DELETE_PENDING;
@@ -521,6 +535,7 @@ cifs_all_info_to_fattr(struct cifs_fattr *fattr, FILE_ALL_INFO *info,
 
 	fattr->cf_ctime = cifs_NTtimeToUnix(info->ChangeTime);
 	fattr->cf_mtime = cifs_NTtimeToUnix(info->LastWriteTime);
+	fattr->cf_btime = cifs_NTtimeToUnix(info->CreationTime);
 
 	if (adjust_tz) {
 		fattr->cf_ctime.tv_sec += tcon->ses->server->timeAdj;
@@ -1724,7 +1739,8 @@ int cifs_revalidate_file_attr(struct file *filp)
 	return rc;
 }
 
-int cifs_revalidate_dentry_attr(struct dentry *dentry)
+int cifs_revalidate_dentry_attr(struct dentry *dentry,
+				bool want_extra_bits, bool force)
 {
 	int xid;
 	int rc = 0;
@@ -1735,7 +1751,7 @@ int cifs_revalidate_dentry_attr(struct dentry *dentry)
 	if (inode == NULL)
 		return -ENOENT;
 
-	if (!cifs_inode_needs_reval(inode))
+	if (!force && !cifs_inode_needs_reval(inode))
 		return rc;
 
 	xid = GetXid();
@@ -1752,9 +1768,12 @@ int cifs_revalidate_dentry_attr(struct dentry *dentry)
 		 "%ld jiffies %ld", full_path, inode, inode->i_count.counter,
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
 
@@ -1779,12 +1798,13 @@ int cifs_revalidate_file(struct file *filp)
 }
 
 /* revalidate a dentry's inode attributes */
-int cifs_revalidate_dentry(struct dentry *dentry)
+int cifs_revalidate_dentry(struct dentry *dentry,
+			   bool want_extra_bits, bool force)
 {
 	int rc;
 	struct inode *inode = dentry->d_inode;
 
-	rc = cifs_revalidate_dentry_attr(dentry);
+	rc = cifs_revalidate_dentry_attr(dentry, want_extra_bits, force);
 	if (rc)
 		return rc;
 
@@ -1796,11 +1816,30 @@ int cifs_revalidate_dentry(struct dentry *dentry)
 int cifs_getattr(struct vfsmount *mnt, struct dentry *dentry,
 		 struct kstat *stat)
 {
+	struct cifsInodeInfo *cifs_i = CIFS_I(dentry->d_inode);
 	struct cifs_sb_info *cifs_sb = CIFS_SB(dentry->d_sb);
 	struct cifs_tcon *tcon = cifs_sb_master_tcon(cifs_sb);
 	struct inode *inode = dentry->d_inode;
+	unsigned force = stat->query_flags & AT_FORCE_ATTR_SYNC;
+	bool want_extra_bits = false;
+	u32 info, ioc = 0;
+	u32 attrs;
 	int rc;
 
+	if (cifs_i->uid_faked)
+		stat->request_mask &= ~XSTAT_UID;
+	if (cifs_i->gid_faked)
+		stat->request_mask &= ~XSTAT_GID;
+
+	if (stat->request_mask & XSTAT_BTIME && !cifs_i->btime_valid) {
+		want_extra_bits = true;
+		force = true;
+	}
+	if (stat->request_mask & XSTAT_IOC_FLAGS) {
+		want_extra_bits = true;
+		force = true;
+	}
+
 	/*
 	 * We need to be sure that all dirty pages are written and the server
 	 * has actual ctime, mtime and file length.
@@ -1814,13 +1853,14 @@ int cifs_getattr(struct vfsmount *mnt, struct dentry *dentry,
 		}
 	}
 
-	rc = cifs_revalidate_dentry_attr(dentry);
-	if (rc)
-		return rc;
+	if (force || stat->request_mask & XSTAT_BASIC_STATS) {
+		rc = cifs_revalidate_dentry(dentry, want_extra_bits, force);
+		if (rc)
+			return rc;
+	}
 
 	generic_fillattr(inode, stat);
 	stat->blksize = CIFS_MAX_MSGSIZE;
-	stat->ino = CIFS_I(inode)->uniqueid;
 
 	/*
 	 * If on a multiuser mount without unix extensions, and the admin hasn't
@@ -1834,7 +1874,53 @@ int cifs_getattr(struct vfsmount *mnt, struct dentry *dentry,
 		if (!(cifs_sb->mnt_cifs_flags & CIFS_MOUNT_OVERR_GID))
 			stat->gid = current_fsgid();
 	}
-	return rc;
+
+	info = XSTAT_INFO_REMOTE | XSTAT_INFO_NONSYSTEM_OWNERSHIP;
+#ifdef CONFIG_CIFS_ACL
+	info |= XSTAT_INFO_HAS_ACL;
+#endif
+
+	if (cifs_i->btime_valid) {
+		stat->btime = cifs_i->btime;
+		stat->result_mask |= XSTAT_BTIME;
+	}
+
+	/* We don't promise an inode number if we made one up */
+	stat->ino = cifs_i->uniqueid;
+	if (!(cifs_sb->mnt_cifs_flags & CIFS_MOUNT_SERVER_INUM))
+		stat->result_mask &= ~XSTAT_INO;
+
+	/*
+	 * If on a multiuser mount without unix extensions, and the admin
+	 * hasn't overridden them, set the ownership to the fsuid/fsgid of the
+	 * current process.
+	 */
+	if ((cifs_sb->mnt_cifs_flags & CIFS_MOUNT_MULTIUSER) &&
+	    !tcon->unix_ext) {
+		if (!(cifs_sb->mnt_cifs_flags & CIFS_MOUNT_OVERR_UID))
+			stat->uid = current_fsuid();
+		if (!(cifs_sb->mnt_cifs_flags & CIFS_MOUNT_OVERR_GID))
+			stat->gid = current_fsgid();
+	}
+	if (cifs_i->uid_faked)
+		stat->result_mask &= ~XSTAT_UID;
+	if (cifs_i->gid_faked)
+		stat->result_mask &= ~XSTAT_GID;
+
+	attrs = cifs_i->cifsAttrs;
+	if (attrs & ATTR_HIDDEN)	info |= XSTAT_INFO_HIDDEN;
+	if (attrs & ATTR_SYSTEM)	info |= XSTAT_INFO_SYSTEM;
+	if (attrs & ATTR_ARCHIVE)	info |= XSTAT_INFO_ARCHIVE;
+	if (attrs & ATTR_TEMPORARY)	info |= XSTAT_INFO_TEMPORARY;
+	if (attrs & ATTR_REPARSE)	info |= XSTAT_INFO_REPARSE_POINT;
+	if (attrs & ATTR_OFFLINE)	info |= XSTAT_INFO_OFFLINE;
+	if (attrs & ATTR_ENCRYPTED)	info |= XSTAT_INFO_ENCRYPTED;
+	stat->information |= info;
+
+	if (attrs & ATTR_READONLY)	ioc |= FS_IMMUTABLE_FL;
+	if (attrs & ATTR_COMPRESSED)	ioc |= FS_COMPR_FL;
+	stat->ioc_flags |= ioc;
+	return 0;
 }
 
 static int cifs_truncate_page(struct address_space *mapping, loff_t from)


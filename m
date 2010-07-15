From: David Howells <dhowells@redhat.com>
Subject: [PATCH 08/18] xstat: CIFS: Return extended attributes [ver #6]
Date: Thu, 15 Jul 2010 03:17:19 +0100
Message-ID: <20100715021719.5544.80265.stgit@warthog.procyon.org.uk>
References: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
	linux-kernel@vger.kernel.org, samba-technical@lists.samba.org,
	linux-ext4@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Return extended attributes from the CIFS filesystem.  This includes the
following:

 (1) Return the file creation time as btime.  We assume that the creation time
     won't change over the life of the inode.

 (2) FS_AUTOMOUNT_FL on referral/submount directories.

 (3) Deasserting XSTAT_REQUEST_INO in st_result_mask if we made up the inode
     number and didn't get it from the server.

 (4) Map various Windows file attributes to FS_xxx_FL flags in st_inode_flags,
     fetching them from the server if we don't have them yet or don't have a
     current copy.

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

 fs/cifs/cifsfs.h   |    2 +
 fs/cifs/cifsglob.h |    5 +++
 fs/cifs/dir.c      |    2 +
 fs/cifs/inode.c    |   76 ++++++++++++++++++++++++++++++++++++++++++++--------
 4 files changed, 71 insertions(+), 14 deletions(-)

diff --git a/fs/cifs/cifsfs.h b/fs/cifs/cifsfs.h
index a7eb65c..50bf70b 100644
--- a/fs/cifs/cifsfs.h
+++ b/fs/cifs/cifsfs.h
@@ -62,7 +62,7 @@ extern int cifs_rmdir(struct inode *, struct dentry *);
 extern int cifs_rename(struct inode *, struct dentry *, struct inode *,
 		       struct dentry *);
 extern int cifs_revalidate_file(struct file *filp);
-extern int cifs_revalidate_dentry(struct dentry *);
+extern int cifs_revalidate_dentry(struct dentry *, bool, bool);
 extern int cifs_getattr(struct vfsmount *, struct dentry *, struct kstat *);
 extern int cifs_setattr(struct dentry *, struct iattr *);
 
diff --git a/fs/cifs/cifsglob.h b/fs/cifs/cifsglob.h
index a88479c..f12e78d 100644
--- a/fs/cifs/cifsglob.h
+++ b/fs/cifs/cifsglob.h
@@ -396,6 +396,9 @@ struct cifsInodeInfo {
 	bool clientCanCacheAll:1;	/* read and writebehind oplock */
 	bool delete_pending:1;		/* DELETE_ON_CLOSE is set */
 	bool invalid_mapping:1;		/* pagecache is invalid */
+	bool cifsAttrs_valid:1;		/* stored cifs attributes are valid */
+	bool btime_valid:1;		/* stored creation time is valid */
+	struct timespec btime;		/* creation time */
 	u64  server_eof;		/* current file size on server */
 	u64  uniqueid;			/* server inode number */
 	struct inode vfs_inode;
@@ -508,6 +511,7 @@ struct dfs_info3_param {
 #define CIFS_FATTR_DELETE_PENDING	0x2
 #define CIFS_FATTR_NEED_REVAL		0x4
 #define CIFS_FATTR_INO_COLLISION	0x8
+#define CIFS_FATTR_WINATTRS_VALID	0x10	/* T if cf_btime and cf_cifsattrs valid */
 
 struct cifs_fattr {
 	u32		cf_flags;
@@ -524,6 +528,7 @@ struct cifs_fattr {
 	struct timespec	cf_atime;
 	struct timespec	cf_mtime;
 	struct timespec	cf_ctime;
+	struct timespec	cf_btime;
 };
 
 static inline void free_dfs_info_param(struct dfs_info3_param *param)
diff --git a/fs/cifs/dir.c b/fs/cifs/dir.c
index e7ae78b..65da30e 100644
--- a/fs/cifs/dir.c
+++ b/fs/cifs/dir.c
@@ -778,7 +778,7 @@ cifs_d_revalidate(struct dentry *direntry, struct nameidata *nd)
 	int isValid = 1;
 
 	if (direntry->d_inode) {
-		if (cifs_revalidate_dentry(direntry))
+		if (cifs_revalidate_dentry(direntry, false, false))
 			return 0;
 	} else {
 		cFYI(1, "neg dentry 0x%p name = %s",
diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
index 6f0683c..ff4a62f 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -136,7 +136,11 @@ cifs_fattr_to_inode(struct inode *inode, struct cifs_fattr *fattr)
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
@@ -468,6 +472,7 @@ cifs_all_info_to_fattr(struct cifs_fattr *fattr, FILE_ALL_INFO *info,
 		       struct cifs_sb_info *cifs_sb, bool adjust_tz)
 {
 	memset(fattr, 0, sizeof(*fattr));
+	fattr->cf_flags = CIFS_FATTR_WINATTRS_VALID;
 	fattr->cf_cifsattrs = le32_to_cpu(info->Attributes);
 	if (info->DeletePending)
 		fattr->cf_flags |= CIFS_FATTR_DELETE_PENDING;
@@ -479,6 +484,7 @@ cifs_all_info_to_fattr(struct cifs_fattr *fattr, FILE_ALL_INFO *info,
 
 	fattr->cf_ctime = cifs_NTtimeToUnix(info->ChangeTime);
 	fattr->cf_mtime = cifs_NTtimeToUnix(info->LastWriteTime);
+	fattr->cf_btime = cifs_NTtimeToUnix(info->CreationTime);
 
 	if (adjust_tz) {
 		fattr->cf_ctime.tv_sec += cifs_sb->tcon->ses->server->timeAdj;
@@ -1591,7 +1597,8 @@ check_inval:
 }
 
 /* revalidate a dentry's inode attributes */
-int cifs_revalidate_dentry(struct dentry *dentry)
+int cifs_revalidate_dentry(struct dentry *dentry, bool want_extra_bits,
+			   bool force)
 {
 	int xid;
 	int rc = 0;
@@ -1604,7 +1611,7 @@ int cifs_revalidate_dentry(struct dentry *dentry)
 
 	xid = GetXid();
 
-	if (!cifs_inode_needs_reval(inode))
+	if (!force && !cifs_inode_needs_reval(inode))
 		goto check_inval;
 
 	/* can not safely grab the rename sem here if rename calls revalidate
@@ -1619,9 +1626,12 @@ int cifs_revalidate_dentry(struct dentry *dentry)
 		 "jiffies %ld", full_path, inode, inode->i_count.counter,
 		 dentry, dentry->d_time, jiffies);
 
-	if (CIFS_SB(sb)->tcon->unix_ext)
+	if (CIFS_SB(sb)->tcon->unix_ext) {
 		rc = cifs_get_inode_info_unix(&inode, full_path, sb, xid);
-	else
+		if (rc != 0)
+			goto check_inval;
+	}
+	if (!CIFS_SB(sb)->tcon->unix_ext || want_extra_bits)
 		rc = cifs_get_inode_info(&inode, full_path, NULL, sb,
 					 xid, NULL);
 
@@ -1637,13 +1647,55 @@ check_inval:
 int cifs_getattr(struct vfsmount *mnt, struct dentry *dentry,
 	struct kstat *stat)
 {
-	int err = cifs_revalidate_dentry(dentry);
-	if (!err) {
-		generic_fillattr(dentry->d_inode, stat);
-		stat->blksize = CIFS_MAX_MSGSIZE;
-		stat->ino = CIFS_I(dentry->d_inode)->uniqueid;
-	}
-	return err;
+	struct cifsInodeInfo *cifs_i = CIFS_I(dentry->d_inode);
+	struct cifs_sb_info *cifs_sb = CIFS_SB(dentry->d_sb);
+	unsigned force = stat->query_flags & AT_FORCE_ATTR_SYNC;
+	bool want_extra_bits = false;
+	u64 iflag;
+	u32 attrs;
+	int err;
+
+	if (stat->request_mask & XSTAT_REQUEST_BTIME && !cifs_i->btime_valid) {
+		want_extra_bits = true;
+		force = true;
+	}
+
+	if (stat->request_mask & XSTAT_REQUEST_INODE_FLAGS) {
+		want_extra_bits = true;
+		if (!cifs_i->cifsAttrs_valid)
+			force = true;
+	}
+
+	if (force || stat->request_mask & XSTAT_REQUEST__BASIC_STATS) {
+		err = cifs_revalidate_dentry(dentry, want_extra_bits, force);
+		if (err)
+			return err;
+	}
+
+	generic_fillattr(&cifs_i->vfs_inode, stat);
+	stat->blksize = CIFS_MAX_MSGSIZE;
+
+	/* we don't promise an inode number if we made one up */
+	stat->ino = cifs_i->uniqueid;
+	if (!(cifs_sb->mnt_cifs_flags & CIFS_MOUNT_SERVER_INUM))
+		stat->result_mask &= ~XSTAT_REQUEST_INO;
+	if (cifs_i->btime_valid) {
+		stat->btime = cifs_i->btime;
+		stat->result_mask |= XSTAT_REQUEST_BTIME;
+	}
+	attrs = cifs_i->cifsAttrs;
+	iflag = 0;
+	if (attrs & ATTR_READONLY)	iflag |= FS_IMMUTABLE_FL;
+	if (attrs & ATTR_HIDDEN)	iflag |= FS_HIDDEN_FL;
+	if (attrs & ATTR_SYSTEM)	iflag |= FS_SYSTEM_FL;
+	if (attrs & ATTR_ARCHIVE)	iflag |= FS_ARCHIVE_FL;
+	if (attrs & ATTR_TEMPORARY)	iflag |= FS_TEMPORARY_FL;
+	if (attrs & ATTR_REPARSE)	iflag |= FS_REPARSE_POINT_FL;
+	if (attrs & ATTR_COMPRESSED)	iflag |= FS_COMPR_FL;
+	if (attrs & ATTR_OFFLINE)	iflag |= FS_OFFLINE_FL;
+	if (attrs & ATTR_ENCRYPTED)	iflag |= FS_ENCRYPTED_FL;
+	stat->inode_flags |= iflag;
+	return 0;
 }
 
 static int cifs_truncate_page(struct address_space *mapping, loff_t from)

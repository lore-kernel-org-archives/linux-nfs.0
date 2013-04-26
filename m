Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f41.google.com ([209.85.215.41]:38755 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755823Ab3DZMAB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Apr 2013 08:00:01 -0400
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-kernel@vger.kernel.org
Cc: linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: [PATCH v6 4/7] CIFS: Add O_DENY* open flags support
Date: Fri, 26 Apr 2013 16:04:18 +0400
Message-Id: <1366977861-27678-5-git-send-email-piastry@etersoft.ru>
In-Reply-To: <1366977861-27678-1-git-send-email-piastry@etersoft.ru>
References: <1366977861-27678-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Construct share_access value from O_DENY* flags and send it to
the server. Use NTCreateAndX command rather than Trans2
all the time we have any of O_DENY* flags regardless of unix
extensions support. Also change smb error mapping of
NT_STATUS_SHARING_VIOLATION to -ESHAREDENIED.

Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
---
 fs/cifs/cifsfs.c       |  2 +-
 fs/cifs/cifsglob.h     | 16 +++++++++++++++-
 fs/cifs/dir.c          |  4 ++++
 fs/cifs/file.c         | 15 +++++++++++++--
 fs/cifs/inode.c        |  5 +++--
 fs/cifs/netmisc.c      |  2 +-
 fs/cifs/smb2maperror.c |  2 +-
 fs/locks.c             | 11 ++++++++++-
 include/linux/fs.h     |  1 +
 9 files changed, 49 insertions(+), 9 deletions(-)

diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index 345fc89..92bd685 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -799,7 +799,7 @@ struct file_system_type cifs_fs_type = {
 	.name = "cifs",
 	.mount = cifs_do_mount,
 	.kill_sb = cifs_kill_sb,
-	/*  .fs_flags */
+	.fs_flags = FS_DOES_SHARELOCK,
 };
 MODULE_ALIAS_FS("cifs");
 const struct inode_operations cifs_dir_inode_ops = {
diff --git a/fs/cifs/cifsglob.h b/fs/cifs/cifsglob.h
index 80af61d..85703f6 100644
--- a/fs/cifs/cifsglob.h
+++ b/fs/cifs/cifsglob.h
@@ -465,7 +465,7 @@ struct smb_vol {
 			 CIFS_MOUNT_CIFS_BACKUPUID | CIFS_MOUNT_CIFS_BACKUPGID)
 
 #define CIFS_MS_MASK (MS_RDONLY | MS_MANDLOCK | MS_NOEXEC | MS_NOSUID | \
-		      MS_NODEV | MS_SYNCHRONOUS)
+		      MS_NODEV | MS_SYNCHRONOUS | MS_SHARELOCK)
 
 struct cifs_mnt_data {
 	struct cifs_sb_info *cifs_sb;
@@ -947,6 +947,20 @@ struct cifsFileInfo {
 	struct work_struct oplock_break; /* work for oplock breaks */
 };
 
+static inline int
+cifs_get_share_flags(unsigned int flags)
+{
+	int share_access = 0;
+
+	if (!(flags & O_DENYREAD))
+		share_access |= FILE_SHARE_READ;
+	if (!(flags & O_DENYWRITE))
+		share_access |= FILE_SHARE_WRITE;
+	if (!(flags & O_DENYDELETE))
+		share_access |= FILE_SHARE_DELETE;
+	return share_access;
+}
+
 struct cifs_io_parms {
 	__u16 netfid;
 #ifdef CONFIG_CIFS_SMB2
diff --git a/fs/cifs/dir.c b/fs/cifs/dir.c
index e5f6723..c03ad8c 100644
--- a/fs/cifs/dir.c
+++ b/fs/cifs/dir.c
@@ -216,7 +216,11 @@ cifs_do_create(struct inode *inode, struct dentry *direntry, unsigned int xid,
 		goto out;
 	}
 
+	if (IS_SHARELOCK(inode))
+		share_access = cifs_get_share_flags(oflags);
+
 	if (tcon->unix_ext && cap_unix(tcon->ses) && !tcon->broken_posix_open &&
+	    (share_access == FILE_SHARE_ALL) &&
 	    (CIFS_UNIX_POSIX_PATH_OPS_CAP &
 			le64_to_cpu(tcon->fsUnixInfo.Capability))) {
 		rc = cifs_posix_open(full_path, &newinode, inode->i_sb, mode,
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 7631b0c..febf807 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -216,6 +216,8 @@ cifs_nt_open(char *full_path, struct inode *inode, struct cifs_sb_info *cifs_sb,
  *********************************************************************/
 
 	disposition = cifs_get_disposition(f_flags);
+	if (IS_SHARELOCK(inode))
+		share_access = cifs_get_share_flags(f_flags);
 
 	/* BB pass O_SYNC flag through on file attributes .. BB */
 
@@ -428,6 +430,7 @@ int cifs_open(struct inode *inode, struct file *file)
 	int rc = -EACCES;
 	unsigned int xid;
 	__u32 oplock;
+	int share_access = FILE_SHARE_ALL;
 	struct cifs_sb_info *cifs_sb;
 	struct TCP_Server_Info *server;
 	struct cifs_tcon *tcon;
@@ -463,8 +466,12 @@ int cifs_open(struct inode *inode, struct file *file)
 	else
 		oplock = 0;
 
-	if (!tcon->broken_posix_open && tcon->unix_ext &&
-	    cap_unix(tcon->ses) && (CIFS_UNIX_POSIX_PATH_OPS_CAP &
+	if (IS_SHARELOCK(inode))
+		share_access = cifs_get_share_flags(file->f_flags);
+
+	if (!tcon->broken_posix_open && tcon->unix_ext && cap_unix(tcon->ses) &&
+	    (share_access == FILE_SHARE_ALL) &&
+	    (CIFS_UNIX_POSIX_PATH_OPS_CAP &
 				le64_to_cpu(tcon->fsUnixInfo.Capability))) {
 		/* can not refresh inode info since size could be stale */
 		rc = cifs_posix_open(full_path, &inode, inode->i_sb,
@@ -631,7 +638,11 @@ cifs_reopen_file(struct cifsFileInfo *cfile, bool can_flush)
 	else
 		oplock = 0;
 
+	if (IS_SHARELOCK(inode))
+		share_access = cifs_get_share_flags(cfile->f_flags);
+
 	if (tcon->unix_ext && cap_unix(tcon->ses) &&
+	    (share_access == FILE_SHARE_ALL) &&
 	    (CIFS_UNIX_POSIX_PATH_OPS_CAP &
 				le64_to_cpu(tcon->fsUnixInfo.Capability))) {
 		/*
diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
index ecb951f..f145971 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -1166,7 +1166,8 @@ psx_del_no_retry:
 			cifs_drop_nlink(inode);
 	} else if (rc == -ENOENT) {
 		d_drop(dentry);
-	} else if (rc == -EBUSY) {
+	} else if (rc == -ESHAREDENIED) {
+		rc = -EBUSY;
 		if (server->ops->rename_pending_delete) {
 			rc = server->ops->rename_pending_delete(full_path,
 								dentry, xid);
@@ -1513,7 +1514,7 @@ cifs_do_rename(const unsigned int xid, struct dentry *from_dentry,
 	 * source. Note that cross directory moves do not work with
 	 * rename by filehandle to various Windows servers.
 	 */
-	if (rc == 0 || rc != -EBUSY)
+	if (rc == 0 || rc != -ESHAREDENIED)
 		goto do_rename_exit;
 
 	/* open-file renames don't work across directories */
diff --git a/fs/cifs/netmisc.c b/fs/cifs/netmisc.c
index c0b25b2..a9c8bef 100644
--- a/fs/cifs/netmisc.c
+++ b/fs/cifs/netmisc.c
@@ -62,7 +62,7 @@ static const struct smb_to_posix_error mapping_table_ERRDOS[] = {
 	{ERRdiffdevice, -EXDEV},
 	{ERRnofiles, -ENOENT},
 	{ERRwriteprot, -EROFS},
-	{ERRbadshare, -EBUSY},
+	{ERRbadshare, -ESHAREDENIED},
 	{ERRlock, -EACCES},
 	{ERRunsup, -EINVAL},
 	{ERRnosuchshare, -ENXIO},
diff --git a/fs/cifs/smb2maperror.c b/fs/cifs/smb2maperror.c
index 494c912..d70b6ca 100644
--- a/fs/cifs/smb2maperror.c
+++ b/fs/cifs/smb2maperror.c
@@ -356,7 +356,7 @@ static const struct status_to_posix_error smb2_error_map_table[] = {
 	{STATUS_PORT_CONNECTION_REFUSED, -ECONNREFUSED,
 	"STATUS_PORT_CONNECTION_REFUSED"},
 	{STATUS_INVALID_PORT_HANDLE, -EIO, "STATUS_INVALID_PORT_HANDLE"},
-	{STATUS_SHARING_VIOLATION, -EBUSY, "STATUS_SHARING_VIOLATION"},
+	{STATUS_SHARING_VIOLATION, -ESHAREDENIED, "STATUS_SHARING_VIOLATION"},
 	{STATUS_QUOTA_EXCEEDED, -EDQUOT, "STATUS_QUOTA_EXCEEDED"},
 	{STATUS_INVALID_PAGE_PROTECTION, -EIO,
 	"STATUS_INVALID_PAGE_PROTECTION"},
diff --git a/fs/locks.c b/fs/locks.c
index 1cc68a9..abe8986 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -847,6 +847,10 @@ sharelock_may_delete(struct dentry *dentry)
 	if (!IS_SHARELOCK(dentry->d_inode))
 		return rc;
 
+	/* Don't check a lock on file systems that do it internally */
+	if (dentry->d_inode->i_sb->s_type->fs_flags & FS_DOES_SHARELOCK)
+		return rc;
+
 	lock_flocks();
 	for_each_lock(dentry->d_inode, before) {
 		struct file_lock *fl = *before;
@@ -873,8 +877,13 @@ sharelock_lock_file(struct file *filp)
 {
 	struct file_lock *lock;
 	int error = 0;
+	struct inode *inode = filp->f_path.dentry->d_inode;
+
+	if (!IS_SHARELOCK(inode))
+		return error;
 
-	if (!IS_SHARELOCK(filp->f_path.dentry->d_inode))
+	/* Don't set a lock on file systems that do it internally */
+	if (inode->i_sb->s_type->fs_flags & FS_DOES_SHARELOCK)
 		return error;
 
 	error = flock_make_lock(filp, &lock, deny_flags_to_cmd(filp->f_flags));
diff --git a/include/linux/fs.h b/include/linux/fs.h
index afd56b1..9487b0f 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1821,6 +1821,7 @@ struct file_system_type {
 #define FS_USERNS_MOUNT		8	/* Can be mounted by userns root */
 #define FS_USERNS_DEV_MOUNT	16 /* A userns mount does not imply MNT_NODEV */
 #define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move() during rename() internally. */
+#define FS_DOES_SHARELOCK	65536	/* FS does sharelocks internally */
 	struct dentry *(*mount) (struct file_system_type *, int,
 		       const char *, void *);
 	void (*kill_sb) (struct super_block *);
-- 
1.8.1.5


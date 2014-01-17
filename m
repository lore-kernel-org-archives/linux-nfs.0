Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f182.google.com ([209.85.217.182]:60342 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752345AbaAQKHh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jan 2014 05:07:37 -0500
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-kernel@vger.kernel.org
Cc: linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: [PATCH v7 4/7] CIFS: Add O_DENY* open flags support
Date: Fri, 17 Jan 2014 14:07:09 +0400
Message-Id: <1389953232-9428-5-git-send-email-piastry@etersoft.ru>
In-Reply-To: <1389953232-9428-1-git-send-email-piastry@etersoft.ru>
References: <1389953232-9428-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Construct share_access value from O_DENY* flags and send it to
the server. Use NTCreateAndX command rather than Trans2
all the time we have any of O_DENY* flags regardless of unix
extensions support. Also change smb error mapping of
NT_STATUS_SHARING_VIOLATION to -ESHAREDENIED.

Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
---
 fs/cifs/cifsacl.c      |    2 ++
 fs/cifs/cifsfs.c       |    2 +-
 fs/cifs/cifsglob.h     |   17 ++++++++++++++++-
 fs/cifs/cifssmb.c      |    2 +-
 fs/cifs/dir.c          |    6 ++++++
 fs/cifs/file.c         |   20 +++++++++++++++++---
 fs/cifs/inode.c        |   12 ++++++++++--
 fs/cifs/link.c         |    2 ++
 fs/cifs/netmisc.c      |    2 +-
 fs/cifs/smb1ops.c      |    3 +++
 fs/cifs/smb2inode.c    |    1 +
 fs/cifs/smb2maperror.c |    2 +-
 fs/cifs/smb2ops.c      |    6 ++++++
 fs/cifs/smb2pdu.c      |    2 +-
 fs/locks.c             |   11 ++++++++++-
 include/linux/fs.h     |    1 +
 16 files changed, 79 insertions(+), 12 deletions(-)

diff --git a/fs/cifs/cifsacl.c b/fs/cifs/cifsacl.c
index 8f9b4f7..6665602 100644
--- a/fs/cifs/cifsacl.c
+++ b/fs/cifs/cifsacl.c
@@ -912,6 +912,7 @@ static struct cifs_ntsd *get_cifs_acl_by_path(struct cifs_sb_info *cifs_sb,
 	oparms.tcon = tcon;
 	oparms.cifs_sb = cifs_sb;
 	oparms.desired_access = READ_CONTROL;
+	oparms.share_access = FILE_SHARE_ALL;
 	oparms.create_options = create_options;
 	oparms.disposition = FILE_OPEN;
 	oparms.path = path;
@@ -981,6 +982,7 @@ int set_cifs_acl(struct cifs_ntsd *pnntsd, __u32 acllen,
 	oparms.tcon = tcon;
 	oparms.cifs_sb = cifs_sb;
 	oparms.desired_access = access_flags;
+	oparms.share_access = FILE_SHARE_ALL;
 	oparms.create_options = create_options;
 	oparms.disposition = FILE_OPEN;
 	oparms.path = path;
diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index 849f613..1e07a97 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -819,7 +819,7 @@ struct file_system_type cifs_fs_type = {
 	.name = "cifs",
 	.mount = cifs_do_mount,
 	.kill_sb = cifs_kill_sb,
-	/*  .fs_flags */
+	.fs_flags = FS_DOES_SHARELOCK,
 };
 MODULE_ALIAS_FS("cifs");
 const struct inode_operations cifs_dir_inode_ops = {
diff --git a/fs/cifs/cifsglob.h b/fs/cifs/cifsglob.h
index 61228b7..acc799c 100644
--- a/fs/cifs/cifsglob.h
+++ b/fs/cifs/cifsglob.h
@@ -489,7 +489,7 @@ struct smb_vol {
 			 CIFS_MOUNT_CIFS_BACKUPUID | CIFS_MOUNT_CIFS_BACKUPGID)
 
 #define CIFS_MS_MASK (MS_RDONLY | MS_MANDLOCK | MS_NOEXEC | MS_NOSUID | \
-		      MS_NODEV | MS_SYNCHRONOUS)
+		      MS_NODEV | MS_SYNCHRONOUS | MS_SHARELOCK)
 
 struct cifs_mnt_data {
 	struct cifs_sb_info *cifs_sb;
@@ -961,6 +961,7 @@ struct cifs_open_parms {
 	struct cifs_sb_info *cifs_sb;
 	int disposition;
 	int desired_access;
+	int share_access;
 	int create_options;
 	const char *path;
 	struct cifs_fid *fid;
@@ -1005,6 +1006,20 @@ struct cifsFileInfo {
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
diff --git a/fs/cifs/cifssmb.c b/fs/cifs/cifssmb.c
index 4d881c3..e6b2b87 100644
--- a/fs/cifs/cifssmb.c
+++ b/fs/cifs/cifssmb.c
@@ -1347,7 +1347,7 @@ openRetry:
 	if (create_options & CREATE_OPTION_READONLY)
 		req->FileAttributes |= cpu_to_le32(ATTR_READONLY);
 
-	req->ShareAccess = cpu_to_le32(FILE_SHARE_ALL);
+	req->ShareAccess = cpu_to_le32(oparms->share_access);
 	req->CreateDisposition = cpu_to_le32(disposition);
 	req->CreateOptions = cpu_to_le32(create_options & CREATE_OPTIONS_MASK);
 
diff --git a/fs/cifs/dir.c b/fs/cifs/dir.c
index d3a6796..b1287601 100644
--- a/fs/cifs/dir.c
+++ b/fs/cifs/dir.c
@@ -198,6 +198,7 @@ cifs_do_create(struct inode *inode, struct dentry *direntry, unsigned int xid,
 	int rc = -ENOENT;
 	int create_options = CREATE_NOT_DIR;
 	int desired_access;
+	int share_access = FILE_SHARE_ALL;
 	struct cifs_sb_info *cifs_sb = CIFS_SB(inode->i_sb);
 	struct cifs_tcon *tcon = tlink_tcon(tlink);
 	char *full_path = NULL;
@@ -217,7 +218,11 @@ cifs_do_create(struct inode *inode, struct dentry *direntry, unsigned int xid,
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
@@ -324,6 +329,7 @@ cifs_do_create(struct inode *inode, struct dentry *direntry, unsigned int xid,
 	oparms.tcon = tcon;
 	oparms.cifs_sb = cifs_sb;
 	oparms.desired_access = desired_access;
+	oparms.share_access = share_access;
 	oparms.create_options = create_options;
 	oparms.disposition = disposition;
 	oparms.path = full_path;
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 853d6d1..ad92572 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -179,6 +179,7 @@ cifs_nt_open(char *full_path, struct inode *inode, struct cifs_sb_info *cifs_sb,
 {
 	int rc;
 	int desired_access;
+	int share_access = FILE_SHARE_ALL;
 	int disposition;
 	int create_options = CREATE_NOT_DIR;
 	FILE_ALL_INFO *buf;
@@ -215,6 +216,8 @@ cifs_nt_open(char *full_path, struct inode *inode, struct cifs_sb_info *cifs_sb,
  *********************************************************************/
 
 	disposition = cifs_get_disposition(f_flags);
+	if (IS_SHARELOCK(inode))
+		share_access = cifs_get_share_flags(f_flags);
 
 	/* BB pass O_SYNC flag through on file attributes .. BB */
 
@@ -228,6 +231,7 @@ cifs_nt_open(char *full_path, struct inode *inode, struct cifs_sb_info *cifs_sb,
 	oparms.tcon = tcon;
 	oparms.cifs_sb = cifs_sb;
 	oparms.desired_access = desired_access;
+	oparms.share_access = share_access;
 	oparms.create_options = create_options;
 	oparms.disposition = disposition;
 	oparms.path = full_path;
@@ -432,11 +436,11 @@ void cifsFileInfo_put(struct cifsFileInfo *cifs_file)
 }
 
 int cifs_open(struct inode *inode, struct file *file)
-
 {
 	int rc = -EACCES;
 	unsigned int xid;
 	__u32 oplock;
+	int share_access = FILE_SHARE_ALL;
 	struct cifs_sb_info *cifs_sb;
 	struct TCP_Server_Info *server;
 	struct cifs_tcon *tcon;
@@ -472,8 +476,12 @@ int cifs_open(struct inode *inode, struct file *file)
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
@@ -595,6 +603,7 @@ cifs_reopen_file(struct cifsFileInfo *cfile, bool can_flush)
 	struct inode *inode;
 	char *full_path = NULL;
 	int desired_access;
+	int share_access = FILE_SHARE_ALL;
 	int disposition = FILE_OPEN;
 	int create_options = CREATE_NOT_DIR;
 	struct cifs_open_parms oparms;
@@ -635,7 +644,11 @@ cifs_reopen_file(struct cifsFileInfo *cfile, bool can_flush)
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
@@ -670,6 +683,7 @@ cifs_reopen_file(struct cifsFileInfo *cfile, bool can_flush)
 	oparms.tcon = tcon;
 	oparms.cifs_sb = cifs_sb;
 	oparms.desired_access = desired_access;
+	oparms.share_access = share_access;
 	oparms.create_options = create_options;
 	oparms.disposition = disposition;
 	oparms.path = full_path;
diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
index 9cb9679..8a27905 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -441,6 +441,7 @@ cifs_sfu_type(struct cifs_fattr *fattr, const char *path,
 	oparms.tcon = tcon;
 	oparms.cifs_sb = cifs_sb;
 	oparms.desired_access = GENERIC_READ;
+	oparms.share_access = FILE_SHARE_ALL;
 	oparms.create_options = CREATE_NOT_DIR;
 	oparms.disposition = FILE_OPEN;
 	oparms.path = path;
@@ -1068,6 +1069,7 @@ cifs_rename_pending_delete(const char *full_path, struct dentry *dentry,
 	oparms.tcon = tcon;
 	oparms.cifs_sb = cifs_sb;
 	oparms.desired_access = DELETE | FILE_WRITE_ATTRIBUTES;
+	oparms.share_access = FILE_SHARE_ALL;
 	oparms.create_options = CREATE_NOT_DIR;
 	oparms.disposition = FILE_OPEN;
 	oparms.path = full_path;
@@ -1139,6 +1141,8 @@ cifs_rename_pending_delete(const char *full_path, struct dentry *dentry,
 out_close:
 	CIFSSMBClose(xid, tcon, fid.netfid);
 out:
+	if (rc == -ESHAREDENIED)
+		rc = -EBUSY;
 	kfree(info_buf);
 	cifs_put_tlink(tlink);
 	return rc;
@@ -1237,7 +1241,8 @@ psx_del_no_retry:
 			cifs_drop_nlink(inode);
 	} else if (rc == -ENOENT) {
 		d_drop(dentry);
-	} else if (rc == -EBUSY) {
+	} else if (rc == -ESHAREDENIED) {
+		rc = -EBUSY;
 		if (server->ops->rename_pending_delete) {
 			rc = server->ops->rename_pending_delete(full_path,
 								dentry, xid);
@@ -1587,7 +1592,7 @@ cifs_do_rename(const unsigned int xid, struct dentry *from_dentry,
 	 * source. Note that cross directory moves do not work with
 	 * rename by filehandle to various Windows servers.
 	 */
-	if (rc == 0 || rc != -EBUSY)
+	if (rc != -ESHAREDENIED)
 		goto do_rename_exit;
 
 	/* open-file renames don't work across directories */
@@ -1598,6 +1603,7 @@ cifs_do_rename(const unsigned int xid, struct dentry *from_dentry,
 	oparms.cifs_sb = cifs_sb;
 	/* open the file to be renamed -- we need DELETE perms */
 	oparms.desired_access = DELETE;
+	oparms.share_access = FILE_SHARE_ALL;
 	oparms.create_options = CREATE_NOT_DIR;
 	oparms.disposition = FILE_OPEN;
 	oparms.path = from_path;
@@ -1613,6 +1619,8 @@ cifs_do_rename(const unsigned int xid, struct dentry *from_dentry,
 		CIFSSMBClose(xid, tcon, fid.netfid);
 	}
 do_rename_exit:
+	if (rc == -ESHAREDENIED)
+		rc = -EBUSY;
 	cifs_put_tlink(tlink);
 	return rc;
 }
diff --git a/fs/cifs/link.c b/fs/cifs/link.c
index 46eff5e..4dbe6cd 100644
--- a/fs/cifs/link.c
+++ b/fs/cifs/link.c
@@ -329,6 +329,7 @@ cifs_query_mf_symlink(unsigned int xid, struct cifs_tcon *tcon,
 	oparms.tcon = tcon;
 	oparms.cifs_sb = cifs_sb;
 	oparms.desired_access = GENERIC_READ;
+	oparms.share_access = FILE_SHARE_ALL;
 	oparms.create_options = CREATE_NOT_DIR;
 	oparms.disposition = FILE_OPEN;
 	oparms.path = path;
@@ -373,6 +374,7 @@ cifs_create_mf_symlink(unsigned int xid, struct cifs_tcon *tcon,
 	oparms.tcon = tcon;
 	oparms.cifs_sb = cifs_sb;
 	oparms.desired_access = GENERIC_WRITE;
+	oparms.share_access = FILE_SHARE_ALL;
 	oparms.create_options = create_options;
 	oparms.disposition = FILE_OPEN;
 	oparms.path = path;
diff --git a/fs/cifs/netmisc.c b/fs/cifs/netmisc.c
index 0498845..0d159e6 100644
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
diff --git a/fs/cifs/smb1ops.c b/fs/cifs/smb1ops.c
index 9ac5bfc..569ac21 100644
--- a/fs/cifs/smb1ops.c
+++ b/fs/cifs/smb1ops.c
@@ -566,6 +566,7 @@ cifs_query_path_info(const unsigned int xid, struct cifs_tcon *tcon,
 		oparms.tcon = tcon;
 		oparms.cifs_sb = cifs_sb;
 		oparms.desired_access = FILE_READ_ATTRIBUTES;
+		oparms.share_access = FILE_SHARE_ALL;
 		oparms.create_options = 0;
 		oparms.disposition = FILE_OPEN;
 		oparms.path = full_path;
@@ -802,6 +803,7 @@ smb_set_file_info(struct inode *inode, const char *full_path,
 	oparms.tcon = tcon;
 	oparms.cifs_sb = cifs_sb;
 	oparms.desired_access = SYNCHRONIZE | FILE_WRITE_ATTRIBUTES;
+	oparms.share_access = FILE_SHARE_ALL;
 	oparms.create_options = CREATE_NOT_DIR;
 	oparms.disposition = FILE_OPEN;
 	oparms.path = full_path;
@@ -969,6 +971,7 @@ cifs_query_symlink(const unsigned int xid, struct cifs_tcon *tcon,
 	oparms.tcon = tcon;
 	oparms.cifs_sb = cifs_sb;
 	oparms.desired_access = FILE_READ_ATTRIBUTES;
+	oparms.share_access = FILE_SHARE_ALL;
 	oparms.create_options = OPEN_REPARSE_POINT;
 	oparms.disposition = FILE_OPEN;
 	oparms.path = full_path;
diff --git a/fs/cifs/smb2inode.c b/fs/cifs/smb2inode.c
index 84c012a..bb4c325 100644
--- a/fs/cifs/smb2inode.c
+++ b/fs/cifs/smb2inode.c
@@ -55,6 +55,7 @@ smb2_open_op_close(const unsigned int xid, struct cifs_tcon *tcon,
 
 	oparms.tcon = tcon;
 	oparms.desired_access = desired_access;
+	oparms.share_access = FILE_SHARE_ALL;
 	oparms.disposition = create_disposition;
 	oparms.create_options = create_options;
 	oparms.fid = &fid;
diff --git a/fs/cifs/smb2maperror.c b/fs/cifs/smb2maperror.c
index 94bd4fb..d11ad98 100644
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
diff --git a/fs/cifs/smb2ops.c b/fs/cifs/smb2ops.c
index 757da3e..8129045 100644
--- a/fs/cifs/smb2ops.c
+++ b/fs/cifs/smb2ops.c
@@ -246,6 +246,7 @@ smb3_qfs_tcon(const unsigned int xid, struct cifs_tcon *tcon)
 
 	oparms.tcon = tcon;
 	oparms.desired_access = FILE_READ_ATTRIBUTES;
+	oparms.share_access = FILE_SHARE_ALL;
 	oparms.disposition = FILE_OPEN;
 	oparms.create_options = 0;
 	oparms.fid = &fid;
@@ -280,6 +281,7 @@ smb2_qfs_tcon(const unsigned int xid, struct cifs_tcon *tcon)
 
 	oparms.tcon = tcon;
 	oparms.desired_access = FILE_READ_ATTRIBUTES;
+	oparms.share_access = FILE_SHARE_ALL;
 	oparms.disposition = FILE_OPEN;
 	oparms.create_options = 0;
 	oparms.fid = &fid;
@@ -313,6 +315,7 @@ smb2_is_path_accessible(const unsigned int xid, struct cifs_tcon *tcon,
 
 	oparms.tcon = tcon;
 	oparms.desired_access = FILE_READ_ATTRIBUTES;
+	oparms.share_access = FILE_SHARE_ALL;
 	oparms.disposition = FILE_OPEN;
 	oparms.create_options = 0;
 	oparms.fid = &fid;
@@ -721,6 +724,7 @@ smb2_query_dir_first(const unsigned int xid, struct cifs_tcon *tcon,
 
 	oparms.tcon = tcon;
 	oparms.desired_access = FILE_READ_ATTRIBUTES | FILE_READ_DATA;
+	oparms.share_access = FILE_SHARE_ALL;
 	oparms.disposition = FILE_OPEN;
 	oparms.create_options = 0;
 	oparms.fid = fid;
@@ -808,6 +812,7 @@ smb2_queryfs(const unsigned int xid, struct cifs_tcon *tcon,
 
 	oparms.tcon = tcon;
 	oparms.desired_access = FILE_READ_ATTRIBUTES;
+	oparms.share_access = FILE_SHARE_ALL;
 	oparms.disposition = FILE_OPEN;
 	oparms.create_options = 0;
 	oparms.fid = &fid;
@@ -881,6 +886,7 @@ smb2_query_symlink(const unsigned int xid, struct cifs_tcon *tcon,
 
 	oparms.tcon = tcon;
 	oparms.desired_access = FILE_READ_ATTRIBUTES;
+	oparms.share_access = FILE_SHARE_ALL;
 	oparms.disposition = FILE_OPEN;
 	oparms.create_options = 0;
 	oparms.fid = &fid;
diff --git a/fs/cifs/smb2pdu.c b/fs/cifs/smb2pdu.c
index 2013234..cca197e 100644
--- a/fs/cifs/smb2pdu.c
+++ b/fs/cifs/smb2pdu.c
@@ -1106,7 +1106,7 @@ SMB2_open(const unsigned int xid, struct cifs_open_parms *oparms, __le16 *path,
 	req->DesiredAccess = cpu_to_le32(oparms->desired_access);
 	/* File attributes ignored on open (used in create though) */
 	req->FileAttributes = cpu_to_le32(file_attributes);
-	req->ShareAccess = FILE_SHARE_ALL_LE;
+	req->ShareAccess = cpu_to_le32(oparms->share_access);
 	req->CreateDisposition = cpu_to_le32(oparms->disposition);
 	req->CreateOptions = cpu_to_le32(oparms->create_options & CREATE_OPTIONS_MASK);
 	uni_path_len = (2 * UniStrnlen((wchar_t *)path, PATH_MAX)) + 2;
diff --git a/fs/locks.c b/fs/locks.c
index c7e780a..6e78c0a 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -953,6 +953,10 @@ sharelock_may_delete(struct dentry *dentry)
 	if (!IS_SHARELOCK(inode))
 		return rc;
 
+	/* Don't check a lock on file systems that do it internally */
+	if (inode->i_sb->s_type->fs_flags & FS_DOES_SHARELOCK)
+		return rc;
+
 	spin_lock(&inode->i_lock);
 	for_each_lock(inode, before) {
 		struct file_lock *fl = *before;
@@ -981,8 +985,13 @@ sharelock_lock_file(struct file *filp)
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
index 6dc9275..1185c64 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1830,6 +1830,7 @@ struct file_system_type {
 #define FS_USERNS_MOUNT		8	/* Can be mounted by userns root */
 #define FS_USERNS_DEV_MOUNT	16 /* A userns mount does not imply MNT_NODEV */
 #define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move() during rename() internally. */
+#define FS_DOES_SHARELOCK	65536	/* FS does sharelocks internally */
 	struct dentry *(*mount) (struct file_system_type *, int,
 		       const char *, void *);
 	void (*kill_sb) (struct super_block *);
-- 
1.7.10.4


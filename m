Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f51.google.com ([209.85.215.51]:45216 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162136Ab3DEQyK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Apr 2013 12:54:10 -0400
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-kernel@vger.kernel.org
Cc: linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: [PATCH v4 3/7] CIFS: Add O_DENY* open flags support
Date: Fri,  5 Apr 2013 20:57:51 +0400
Message-Id: <1365181075-22540-4-git-send-email-piastry@etersoft.ru>
In-Reply-To: <1365181075-22540-1-git-send-email-piastry@etersoft.ru>
References: <1365181075-22540-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Construct share_access value from O_DENY* flags and send it to
the server.

Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
---
 fs/cifs/cifsglob.h | 16 +++++++++++++++-
 fs/cifs/dir.c      |  3 +++
 fs/cifs/file.c     |  4 ++++
 fs/locks.c         |  8 ++++++++
 4 files changed, 30 insertions(+), 1 deletion(-)

diff --git a/fs/cifs/cifsglob.h b/fs/cifs/cifsglob.h
index cd4bbf3..7e876b9 100644
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
index 267b608..d4331de 100644
--- a/fs/cifs/dir.c
+++ b/fs/cifs/dir.c
@@ -294,6 +294,9 @@ cifs_do_create(struct inode *inode, struct dentry *direntry, unsigned int xid,
 	else
 		cFYI(1, "Create flag not set in create function");
 
+	if (IS_SHARELOCK(inode))
+		share_access = cifs_get_share_flags(oflags);
+
 	/*
 	 * BB add processing to set equivalent of mode - e.g. via CreateX with
 	 * ACLs
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 0d524a7..9394b2b 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -210,6 +210,8 @@ cifs_nt_open(char *full_path, struct inode *inode, struct cifs_sb_info *cifs_sb,
  *********************************************************************/
 
 	disposition = cifs_get_disposition(f_flags);
+	if (IS_SHARELOCK(inode))
+		share_access = cifs_get_share_flags(f_flags);
 
 	/* BB pass O_SYNC flag through on file attributes .. BB */
 
@@ -645,6 +647,8 @@ cifs_reopen_file(struct cifsFileInfo *cfile, bool can_flush)
 	}
 
 	desired_access = cifs_convert_flags(cfile->f_flags);
+	if (IS_SHARELOCK(inode))
+		share_access = cifs_get_share_flags(cfile->f_flags);
 
 	if (backup_cred(cifs_sb))
 		create_options |= CREATE_OPEN_BACKUP_INTENT;
diff --git a/fs/locks.c b/fs/locks.c
index 1eccc75..2184ddd 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -846,10 +846,18 @@ deny_lock_file(struct file *filp)
 {
 	struct file_lock *lock;
 	int error = 0;
+	const char *fsname = filp->f_path.dentry->d_inode->i_sb->s_type->name;
 
 	if (!IS_SHARELOCK(filp->f_path.dentry->d_inode))
 		return error;
 
+	/*
+	 * Don't set a lock on CIFS file systems because they can process it
+	 * themselves.
+	 */
+	if (!strncmp(fsname, "cifs", 4))
+		return error;
+
 	error = flock_make_lock(filp, &lock, deny_flags_to_cmd(filp->f_flags));
 	if (error)
 		return error;
-- 
1.8.1.5


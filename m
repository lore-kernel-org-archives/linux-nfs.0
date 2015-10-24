Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35778 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752499AbbJXP3B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Oct 2015 11:29:01 -0400
Received: by pasz6 with SMTP id z6so144428939pas.2
        for <linux-nfs@vger.kernel.org>; Sat, 24 Oct 2015 08:29:00 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>,
        Jeff Layton <jeff.layton@primarydata.com>, bfields@fieldses.org,
        "Darrick J. Wong" <darrick.wong@oracle.com>, viro@zeniv.linux.org.uk,
        linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-cifs@vger.kernel.org,
        Steve French <steve.french@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 2/9] cifs: add .copy_file_range file operation
Date: Sun, 25 Oct 2015 07:17:09 +0800
Message-Id: <1445728636-10109-3-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1445728636-10109-1-git-send-email-tao.peng@primarydata.com>
References: <1445728636-10109-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/cifs/cifsfs.c |  22 ++++++++++++
 fs/cifs/cifsfs.h |   4 ++-
 fs/cifs/ioctl.c  | 100 +++++++++++++++++++++++++++++++------------------------
 3 files changed, 82 insertions(+), 44 deletions(-)

diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index e739950..6ef7c3c 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -910,6 +910,22 @@ const struct inode_operations cifs_symlink_inode_ops = {
 #endif
 };
 
+#ifdef CONFIG_CIFS_POSIX
+ssize_t cifs_file_copy_range(struct file *file_in, loff_t pos_in,
+			     struct file *file_out, loff_t pos_out,
+			     size_t len, unsigned int flags)
+{
+	unsigned int xid;
+	int rc;
+
+	xid = get_xid();
+	rc = cifs_file_clone_range(xid, file_in, file_out, pos_in,
+				   len, pos_out, true);
+	free_xid(xid);
+	return rc < 0 ? rc : len;
+}
+#endif
+
 const struct file_operations cifs_file_ops = {
 	.read_iter = cifs_loose_read_iter,
 	.write_iter = cifs_file_write_iter,
@@ -923,6 +939,7 @@ const struct file_operations cifs_file_ops = {
 	.llseek = cifs_llseek,
 #ifdef CONFIG_CIFS_POSIX
 	.unlocked_ioctl	= cifs_ioctl,
+	.copy_file_range = cifs_file_copy_range,
 #endif /* CONFIG_CIFS_POSIX */
 	.setlease = cifs_setlease,
 	.fallocate = cifs_fallocate,
@@ -941,6 +958,7 @@ const struct file_operations cifs_file_strict_ops = {
 	.llseek = cifs_llseek,
 #ifdef CONFIG_CIFS_POSIX
 	.unlocked_ioctl	= cifs_ioctl,
+	.copy_file_range = cifs_file_copy_range,
 #endif /* CONFIG_CIFS_POSIX */
 	.setlease = cifs_setlease,
 	.fallocate = cifs_fallocate,
@@ -959,6 +977,7 @@ const struct file_operations cifs_file_direct_ops = {
 	.splice_read = generic_file_splice_read,
 #ifdef CONFIG_CIFS_POSIX
 	.unlocked_ioctl  = cifs_ioctl,
+	.copy_file_range = cifs_file_copy_range,
 #endif /* CONFIG_CIFS_POSIX */
 	.llseek = cifs_llseek,
 	.setlease = cifs_setlease,
@@ -977,6 +996,7 @@ const struct file_operations cifs_file_nobrl_ops = {
 	.llseek = cifs_llseek,
 #ifdef CONFIG_CIFS_POSIX
 	.unlocked_ioctl	= cifs_ioctl,
+	.copy_file_range = cifs_file_copy_range,
 #endif /* CONFIG_CIFS_POSIX */
 	.setlease = cifs_setlease,
 	.fallocate = cifs_fallocate,
@@ -994,6 +1014,7 @@ const struct file_operations cifs_file_strict_nobrl_ops = {
 	.llseek = cifs_llseek,
 #ifdef CONFIG_CIFS_POSIX
 	.unlocked_ioctl	= cifs_ioctl,
+	.copy_file_range = cifs_file_copy_range,
 #endif /* CONFIG_CIFS_POSIX */
 	.setlease = cifs_setlease,
 	.fallocate = cifs_fallocate,
@@ -1011,6 +1032,7 @@ const struct file_operations cifs_file_direct_nobrl_ops = {
 	.splice_read = generic_file_splice_read,
 #ifdef CONFIG_CIFS_POSIX
 	.unlocked_ioctl  = cifs_ioctl,
+	.copy_file_range = cifs_file_copy_range,
 #endif /* CONFIG_CIFS_POSIX */
 	.llseek = cifs_llseek,
 	.setlease = cifs_setlease,
diff --git a/fs/cifs/cifsfs.h b/fs/cifs/cifsfs.h
index c3cc160..797439b 100644
--- a/fs/cifs/cifsfs.h
+++ b/fs/cifs/cifsfs.h
@@ -131,7 +131,9 @@ extern int	cifs_setxattr(struct dentry *, const char *, const void *,
 extern ssize_t	cifs_getxattr(struct dentry *, const char *, void *, size_t);
 extern ssize_t	cifs_listxattr(struct dentry *, char *, size_t);
 extern long cifs_ioctl(struct file *filep, unsigned int cmd, unsigned long arg);
-
+extern int cifs_file_clone_range(unsigned int xid, struct file *src_file,
+				 struct file *dst_file, u64 off, u64 len,
+				 u64 destoff, bool dup_extents);
 #ifdef CONFIG_CIFS_NFSD_EXPORT
 extern const struct export_operations cifs_export_ops;
 #endif /* CONFIG_CIFS_NFSD_EXPORT */
diff --git a/fs/cifs/ioctl.c b/fs/cifs/ioctl.c
index 28a77bf..bbab940 100644
--- a/fs/cifs/ioctl.c
+++ b/fs/cifs/ioctl.c
@@ -34,68 +34,36 @@
 #include "cifs_ioctl.h"
 #include <linux/btrfs.h>
 
-static long cifs_ioctl_clone(unsigned int xid, struct file *dst_file,
-			unsigned long srcfd, u64 off, u64 len, u64 destoff,
-			bool dup_extents)
+int cifs_file_clone_range(unsigned int xid, struct file *src_file,
+			  struct file *dst_file, u64 off, u64 len,
+			  u64 destoff, bool dup_extents)
 {
-	int rc;
-	struct cifsFileInfo *smb_file_target = dst_file->private_data;
+	struct inode *src_inode = file_inode(src_file);
 	struct inode *target_inode = file_inode(dst_file);
-	struct cifs_tcon *target_tcon;
-	struct fd src_file;
 	struct cifsFileInfo *smb_file_src;
-	struct inode *src_inode;
+	struct cifsFileInfo *smb_file_target;
 	struct cifs_tcon *src_tcon;
+	struct cifs_tcon *target_tcon;
+	int rc;
 
-	cifs_dbg(FYI, "ioctl clone range\n");
-	/* the destination must be opened for writing */
-	if (!(dst_file->f_mode & FMODE_WRITE)) {
-		cifs_dbg(FYI, "file target not open for write\n");
-		return -EINVAL;
-	}
-
-	/* check if target volume is readonly and take reference */
-	rc = mnt_want_write_file(dst_file);
-	if (rc) {
-		cifs_dbg(FYI, "mnt_want_write failed with rc %d\n", rc);
-		return rc;
-	}
-
-	src_file = fdget(srcfd);
-	if (!src_file.file) {
-		rc = -EBADF;
-		goto out_drop_write;
-	}
-
-	if (src_file.file->f_op->unlocked_ioctl != cifs_ioctl) {
-		rc = -EBADF;
-		cifs_dbg(VFS, "src file seems to be from a different filesystem type\n");
-		goto out_fput;
-	}
-
-	if ((!src_file.file->private_data) || (!dst_file->private_data)) {
+	if ((!src_file->private_data) || (!dst_file->private_data)) {
 		rc = -EBADF;
 		cifs_dbg(VFS, "missing cifsFileInfo on copy range src file\n");
-		goto out_fput;
+		goto out;
 	}
 
 	rc = -EXDEV;
 	smb_file_target = dst_file->private_data;
-	smb_file_src = src_file.file->private_data;
+	smb_file_src = src_file->private_data;
 	src_tcon = tlink_tcon(smb_file_src->tlink);
 	target_tcon = tlink_tcon(smb_file_target->tlink);
 
 	/* check if source and target are on same tree connection */
 	if (src_tcon != target_tcon) {
 		cifs_dbg(VFS, "file copy src and target on different volume\n");
-		goto out_fput;
+		goto out;
 	}
 
-	src_inode = file_inode(src_file.file);
-	rc = -EINVAL;
-	if (S_ISDIR(src_inode->i_mode))
-		goto out_fput;
-
 	/*
 	 * Note: cifs case is easier than btrfs since server responsible for
 	 * checks for proper open modes and file type and if it wants
@@ -131,6 +99,52 @@ out_unlock:
 	/* although unlocking in the reverse order from locking is not
 	   strictly necessary here it is a little cleaner to be consistent */
 	unlock_two_nondirectories(src_inode, target_inode);
+out:
+	return rc;
+}
+
+static long cifs_ioctl_clone(unsigned int xid, struct file *dst_file,
+			unsigned long srcfd, u64 off, u64 len, u64 destoff,
+			bool dup_extents)
+{
+	int rc;
+	struct fd src_file;
+	struct inode *src_inode;
+
+	cifs_dbg(FYI, "ioctl clone range\n");
+	/* the destination must be opened for writing */
+	if (!(dst_file->f_mode & FMODE_WRITE)) {
+		cifs_dbg(FYI, "file target not open for write\n");
+		return -EINVAL;
+	}
+
+	/* check if target volume is readonly and take reference */
+	rc = mnt_want_write_file(dst_file);
+	if (rc) {
+		cifs_dbg(FYI, "mnt_want_write failed with rc %d\n", rc);
+		return rc;
+	}
+
+	src_file = fdget(srcfd);
+	if (!src_file.file) {
+		rc = -EBADF;
+		goto out_drop_write;
+	}
+
+	if (src_file.file->f_op->unlocked_ioctl != cifs_ioctl) {
+		rc = -EBADF;
+		cifs_dbg(VFS, "src file seems to be from a different filesystem type\n");
+		goto out_fput;
+	}
+
+	src_inode = file_inode(src_file.file);
+	rc = -EINVAL;
+	if (S_ISDIR(src_inode->i_mode))
+		goto out_fput;
+
+	rc = cifs_file_clone_range(xid, src_file.file, dst_file, off, len,
+				   destoff, dup_extents);
+
 out_fput:
 	fdput(src_file);
 out_drop_write:
-- 
1.8.3.1


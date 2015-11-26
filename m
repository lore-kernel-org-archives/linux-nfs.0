Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:40743 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481AbbKZSzi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Nov 2015 13:55:38 -0500
From: Christoph Hellwig <hch@lst.de>
To: viro@zeniv.linux.org.uk
Cc: tao.peng@primarydata.com, jeff.layton@primarydata.com,
        linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org
Subject: [PATCH 1/5] cifs: implement clone_file_range operation
Date: Thu, 26 Nov 2015 19:50:55 +0100
Message-Id: <1448563859-21922-2-git-send-email-hch@lst.de>
In-Reply-To: <1448563859-21922-1-git-send-email-hch@lst.de>
References: <1448563859-21922-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

And drop the fake support for the btrfs CLONE ioctl - SMB2 copies are
chunked and do not actually implement clone semantics!

Heavily based on a previous patch from Peng Tao.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/cifs/cifsfs.c |  25 ++++++++++++++
 fs/cifs/cifsfs.h |   4 ++-
 fs/cifs/ioctl.c  | 103 +++++++++++++++++++++++++++++++------------------------
 3 files changed, 86 insertions(+), 46 deletions(-)

diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index cbc0f4b..ad7117a 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -914,6 +914,23 @@ const struct inode_operations cifs_symlink_inode_ops = {
 #endif
 };
 
+ssize_t cifs_file_copy_range(struct file *file_in, loff_t pos_in,
+			     struct file *file_out, loff_t pos_out,
+			     size_t len, unsigned int flags)
+{
+	unsigned int xid;
+	int rc;
+
+	if (flags)
+		return -EOPNOTSUPP;
+
+	xid = get_xid();
+	rc = cifs_file_clone_range(xid, file_in, file_out, pos_in,
+				   len, pos_out, true);
+	free_xid(xid);
+	return rc < 0 ? rc : len;
+}
+
 const struct file_operations cifs_file_ops = {
 	.read_iter = cifs_loose_read_iter,
 	.write_iter = cifs_file_write_iter,
@@ -926,6 +943,7 @@ const struct file_operations cifs_file_ops = {
 	.splice_read = generic_file_splice_read,
 	.llseek = cifs_llseek,
 	.unlocked_ioctl	= cifs_ioctl,
+	.copy_file_range = cifs_file_copy_range,
 	.setlease = cifs_setlease,
 	.fallocate = cifs_fallocate,
 };
@@ -942,6 +960,8 @@ const struct file_operations cifs_file_strict_ops = {
 	.splice_read = generic_file_splice_read,
 	.llseek = cifs_llseek,
 	.unlocked_ioctl	= cifs_ioctl,
+	.copy_file_range = cifs_file_copy_range,
+	.copy_file_range = cifs_file_copy_range,
 	.setlease = cifs_setlease,
 	.fallocate = cifs_fallocate,
 };
@@ -958,6 +978,7 @@ const struct file_operations cifs_file_direct_ops = {
 	.mmap = cifs_file_mmap,
 	.splice_read = generic_file_splice_read,
 	.unlocked_ioctl  = cifs_ioctl,
+	.copy_file_range = cifs_file_copy_range,
 	.llseek = cifs_llseek,
 	.setlease = cifs_setlease,
 	.fallocate = cifs_fallocate,
@@ -974,6 +995,7 @@ const struct file_operations cifs_file_nobrl_ops = {
 	.splice_read = generic_file_splice_read,
 	.llseek = cifs_llseek,
 	.unlocked_ioctl	= cifs_ioctl,
+	.copy_file_range = cifs_file_copy_range,
 	.setlease = cifs_setlease,
 	.fallocate = cifs_fallocate,
 };
@@ -989,6 +1011,7 @@ const struct file_operations cifs_file_strict_nobrl_ops = {
 	.splice_read = generic_file_splice_read,
 	.llseek = cifs_llseek,
 	.unlocked_ioctl	= cifs_ioctl,
+	.copy_file_range = cifs_file_copy_range,
 	.setlease = cifs_setlease,
 	.fallocate = cifs_fallocate,
 };
@@ -1004,6 +1027,7 @@ const struct file_operations cifs_file_direct_nobrl_ops = {
 	.mmap = cifs_file_mmap,
 	.splice_read = generic_file_splice_read,
 	.unlocked_ioctl  = cifs_ioctl,
+	.copy_file_range = cifs_file_copy_range,
 	.llseek = cifs_llseek,
 	.setlease = cifs_setlease,
 	.fallocate = cifs_fallocate,
@@ -1014,6 +1038,7 @@ const struct file_operations cifs_dir_ops = {
 	.release = cifs_closedir,
 	.read    = generic_read_dir,
 	.unlocked_ioctl  = cifs_ioctl,
+	.copy_file_range = cifs_file_copy_range,
 	.llseek = generic_file_llseek,
 };
 
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
index 35cf990..4f92f5c 100644
--- a/fs/cifs/ioctl.c
+++ b/fs/cifs/ioctl.c
@@ -34,73 +34,43 @@
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
 
 	cifs_dbg(FYI, "ioctl clone range\n");
-	/* the destination must be opened for writing */
-	if (!(dst_file->f_mode & FMODE_WRITE)) {
-		cifs_dbg(FYI, "file target not open for write\n");
-		return -EINVAL;
-	}
 
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
+	if (!src_file->private_data || !dst_file->private_data) {
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
 
 	/* check source and target on same server (or volume if dup_extents) */
 	if (dup_extents && (src_tcon != target_tcon)) {
 		cifs_dbg(VFS, "source and target of copy not on same share\n");
-		goto out_fput;
+		goto out;
 	}
 
 	if (!dup_extents && (src_tcon->ses != target_tcon->ses)) {
 		cifs_dbg(VFS, "source and target of copy not on same server\n");
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
@@ -136,6 +106,52 @@ out_unlock:
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
@@ -258,9 +274,6 @@ long cifs_ioctl(struct file *filep, unsigned int command, unsigned long arg)
 		case CIFS_IOC_COPYCHUNK_FILE:
 			rc = cifs_ioctl_clone(xid, filep, arg, 0, 0, 0, false);
 			break;
-		case BTRFS_IOC_CLONE:
-			rc = cifs_ioctl_clone(xid, filep, arg, 0, 0, 0, true);
-			break;
 		case CIFS_IOC_SET_INTEGRITY:
 			if (pSMBFile == NULL)
 				break;
-- 
1.9.1


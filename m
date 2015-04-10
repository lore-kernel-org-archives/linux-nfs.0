Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58485 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756341AbbDJWBB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Apr 2015 18:01:01 -0400
From: Zach Brown <zab@redhat.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-scsi@vger.kernel.org
Subject: [PATCH RFC 3/3] btrfs: add .copy_file_range file operation
Date: Fri, 10 Apr 2015 15:00:36 -0700
Message-Id: <1428703236-24735-4-git-send-email-zab@redhat.com>
In-Reply-To: <1428703236-24735-1-git-send-email-zab@redhat.com>
References: <1428703236-24735-1-git-send-email-zab@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This rearranges the existing COPY_RANGE ioctl implementation so that the
.copy_file_range file operation can call the core loop that copies file
data extent items.

The extent copying loop is lifted up into its own function.  It retains
the core btrfs error checks that should be shared.

Signed-off-by: Zach Brown <zab@redhat.com>
---
 fs/btrfs/ctree.h |  3 ++
 fs/btrfs/file.c  |  1 +
 fs/btrfs/ioctl.c | 91 ++++++++++++++++++++++++++++++++------------------------
 3 files changed, 56 insertions(+), 39 deletions(-)

diff --git a/fs/btrfs/ctree.h b/fs/btrfs/ctree.h
index f9c89ca..f7cfa26 100644
--- a/fs/btrfs/ctree.h
+++ b/fs/btrfs/ctree.h
@@ -3958,6 +3958,9 @@ int btrfs_dirty_pages(struct btrfs_root *root, struct inode *inode,
 		      loff_t pos, size_t write_bytes,
 		      struct extent_state **cached);
 int btrfs_fdatawrite_range(struct inode *inode, loff_t start, loff_t end);
+ssize_t btrfs_copy_file_range(struct file *file_in, loff_t pos_in,
+			      struct file *file_out, loff_t pos_out,
+			      size_t len, int flags);
 
 /* tree-defrag.c */
 int btrfs_defrag_leaves(struct btrfs_trans_handle *trans,
diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index 30982bb..49989899 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -2820,6 +2820,7 @@ const struct file_operations btrfs_file_operations = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl	= btrfs_ioctl,
 #endif
+	.copy_file_range = btrfs_copy_file_range,
 };
 
 void btrfs_auto_defrag_exit(void)
diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index 74609b9..0eb008e 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -3537,17 +3537,16 @@ out:
 	return ret;
 }
 
-static noinline long btrfs_ioctl_clone(struct file *file, unsigned long srcfd,
-				       u64 off, u64 olen, u64 destoff)
+static noinline int btrfs_clone_files(struct file *file, struct file *file_src,
+					u64 off, u64 olen, u64 destoff)
 {
 	struct inode *inode = file_inode(file);
+	struct inode *src = file_inode(file_src);
 	struct btrfs_root *root = BTRFS_I(inode)->root;
-	struct fd src_file;
-	struct inode *src;
 	int ret;
 	u64 len = olen;
 	u64 bs = root->fs_info->sb->s_blocksize;
-	int same_inode = 0;
+	int same_inode = src == inode;
 
 	/*
 	 * TODO:
@@ -3560,49 +3559,20 @@ static noinline long btrfs_ioctl_clone(struct file *file, unsigned long srcfd,
 	 *   be either compressed or non-compressed.
 	 */
 
-	/* the destination must be opened for writing */
-	if (!(file->f_mode & FMODE_WRITE) || (file->f_flags & O_APPEND))
-		return -EINVAL;
-
 	if (btrfs_root_readonly(root))
 		return -EROFS;
 
-	ret = mnt_want_write_file(file);
-	if (ret)
-		return ret;
-
-	src_file = fdget(srcfd);
-	if (!src_file.file) {
-		ret = -EBADF;
-		goto out_drop_write;
-	}
-
-	ret = -EXDEV;
-	if (src_file.file->f_path.mnt != file->f_path.mnt)
-		goto out_fput;
-
-	src = file_inode(src_file.file);
-
-	ret = -EINVAL;
-	if (src == inode)
-		same_inode = 1;
-
-	/* the src must be open for reading */
-	if (!(src_file.file->f_mode & FMODE_READ))
-		goto out_fput;
+	if (file_src->f_path.mnt != file->f_path.mnt ||
+	    src->i_sb != inode->i_sb)
+		return -EXDEV;
 
 	/* don't make the dst file partly checksummed */
 	if ((BTRFS_I(src)->flags & BTRFS_INODE_NODATASUM) !=
 	    (BTRFS_I(inode)->flags & BTRFS_INODE_NODATASUM))
-		goto out_fput;
+		return -EINVAL;
 
-	ret = -EISDIR;
 	if (S_ISDIR(src->i_mode) || S_ISDIR(inode->i_mode))
-		goto out_fput;
-
-	ret = -EXDEV;
-	if (src->i_sb != inode->i_sb)
-		goto out_fput;
+		return -EISDIR;
 
 	if (!same_inode) {
 		if (inode < src) {
@@ -3690,6 +3660,49 @@ out_unlock:
 	} else {
 		mutex_unlock(&src->i_mutex);
 	}
+	return ret;
+}
+
+ssize_t btrfs_copy_file_range(struct file *file_in, loff_t pos_in,
+			      struct file *file_out, loff_t pos_out,
+			      size_t len, int flags)
+{
+	ssize_t ret;
+
+	ret = btrfs_clone_files(file_out, file_in, pos_in, len, pos_out);
+	if (ret == 0)
+		ret = len;
+	return ret;
+}
+
+static noinline long btrfs_ioctl_clone(struct file *file, unsigned long srcfd,
+				       u64 off, u64 olen, u64 destoff)
+{
+	struct fd src_file;
+	int ret;
+
+	/* the destination must be opened for writing */
+	if (!(file->f_mode & FMODE_WRITE) || (file->f_flags & O_APPEND))
+		return -EINVAL;
+
+	ret = mnt_want_write_file(file);
+	if (ret)
+		return ret;
+
+	src_file = fdget(srcfd);
+	if (!src_file.file) {
+		ret = -EBADF;
+		goto out_drop_write;
+	}
+
+	/* the src must be open for reading */
+	if (!(src_file.file->f_mode & FMODE_READ)) {
+		ret = -EINVAL;
+		goto out_fput;
+	}
+
+	ret = btrfs_clone_files(file, src_file.file, off, olen, destoff);
+
 out_fput:
 	fdput(src_file);
 out_drop_write:
-- 
2.1.0


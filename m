Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1105 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757894Ab3ENVQH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 May 2013 17:16:07 -0400
From: Zach Brown <zab@redhat.com>
To: "Martin K. Petersen" <martin.petersen@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [RFC v0 3/4] btrfs: add .copy_range file operation
Date: Tue, 14 May 2013 14:15:25 -0700
Message-Id: <1368566126-17610-4-git-send-email-zab@redhat.com>
In-Reply-To: <1368566126-17610-1-git-send-email-zab@redhat.com>
References: <1368566126-17610-1-git-send-email-zab@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This rearranges the existing COPY_RANGE ioctl implementation so that the
.copy_range file operation can call the core loop that copies file data
extent items.

The extent copying loop is lifted up into its own function.  It retains
the core btrfs error checks that should be shared between the
CLONE_RANGE ioctl and copy_range syscall.

Signed-off-by: Zach Brown <zab@redhat.com>
---
 fs/btrfs/ctree.h |   3 ++
 fs/btrfs/file.c  |   1 +
 fs/btrfs/ioctl.c | 122 +++++++++++++++++++++++++++++++++----------------------
 3 files changed, 77 insertions(+), 49 deletions(-)

diff --git a/fs/btrfs/ctree.h b/fs/btrfs/ctree.h
index 63c328a..bf9555c 100644
--- a/fs/btrfs/ctree.h
+++ b/fs/btrfs/ctree.h
@@ -3612,6 +3612,9 @@ int btrfs_dirty_pages(struct btrfs_root *root, struct inode *inode,
 		      struct page **pages, size_t num_pages,
 		      loff_t pos, size_t write_bytes,
 		      struct extent_state **cached);
+ssize_t btrfs_copy_range(struct file *file_in, loff_t pos_in,
+			 struct file *file_out, loff_t pos_out,
+			 size_t count);
 
 /* tree-defrag.c */
 int btrfs_defrag_leaves(struct btrfs_trans_handle *trans,
diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index 4205ba7..d75cc07 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -2460,6 +2460,7 @@ const struct file_operations btrfs_file_operations = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl	= btrfs_ioctl,
 #endif
+	.copy_range	= btrfs_copy_range,
 };
 
 void btrfs_auto_defrag_exit(void)
diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index 0de4a2f..ac035d8 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -2463,13 +2463,10 @@ out:
 	return ret;
 }
 
-static noinline long btrfs_ioctl_clone(struct file *file, unsigned long srcfd,
-				       u64 off, u64 olen, u64 destoff)
+static noinline int btrfs_clone_extents(struct inode *inode, struct inode *src,
+					u64 off, u64 olen, u64 destoff)
 {
-	struct inode *inode = file_inode(file);
 	struct btrfs_root *root = BTRFS_I(inode)->root;
-	struct fd src_file;
-	struct inode *src;
 	struct btrfs_trans_handle *trans;
 	struct btrfs_path *path;
 	struct extent_buffer *leaf;
@@ -2491,59 +2488,22 @@ static noinline long btrfs_ioctl_clone(struct file *file, unsigned long srcfd,
 	 *   they don't overlap)?
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
-		goto out_fput;
-
-	/* the src must be open for reading */
-	if (!(src_file.file->f_mode & FMODE_READ))
-		goto out_fput;
-
 	/* don't make the dst file partly checksummed */
 	if ((BTRFS_I(src)->flags & BTRFS_INODE_NODATASUM) !=
 	    (BTRFS_I(inode)->flags & BTRFS_INODE_NODATASUM))
-		goto out_fput;
-
-	ret = -EISDIR;
-	if (S_ISDIR(src->i_mode) || S_ISDIR(inode->i_mode))
-		goto out_fput;
-
-	ret = -EXDEV;
-	if (src->i_sb != inode->i_sb)
-		goto out_fput;
+		return -EINVAL;
 
-	ret = -ENOMEM;
 	buf = vmalloc(btrfs_level_size(root, 0));
 	if (!buf)
-		goto out_fput;
+		return -ENOMEM;
 
 	path = btrfs_alloc_path();
 	if (!path) {
 		vfree(buf);
-		goto out_fput;
+		return -ENOMEM;
 	}
 	path->reada = 2;
 
@@ -2555,10 +2515,7 @@ static noinline long btrfs_ioctl_clone(struct file *file, unsigned long srcfd,
 		mutex_lock_nested(&inode->i_mutex, I_MUTEX_CHILD);
 	}
 
-	/* determine range to clone */
-	ret = -EINVAL;
-	if (off + len > src->i_size || off + len < off)
-		goto out_unlock;
+	/* CLONE_RANGE can have len == 0, copy_range won't */
 	if (len == 0)
 		olen = len = src->i_size - off;
 	/* if we extend to eof, continue to block boundary */
@@ -2566,6 +2523,7 @@ static noinline long btrfs_ioctl_clone(struct file *file, unsigned long srcfd,
 		len = ALIGN(src->i_size, bs) - off;
 
 	/* verify the end result is block aligned */
+	ret = -EINVAL;
 	if (!IS_ALIGNED(off, bs) || !IS_ALIGNED(off + len, bs) ||
 	    !IS_ALIGNED(destoff, bs))
 		goto out_unlock;
@@ -2849,6 +2807,72 @@ out_unlock:
 	mutex_unlock(&inode->i_mutex);
 	vfree(buf);
 	btrfs_free_path(path);
+	return ret;
+}
+
+ssize_t btrfs_copy_range(struct file *file_in, loff_t pos_in,
+			 struct file *file_out, loff_t pos_out,
+			 size_t count)
+{
+	ssize_t ret;
+
+	ret = btrfs_clone_extents(file_inode(file_out), file_inode(file_in),
+				  pos_in, count, pos_out);
+	if (ret == 0)
+		ret = count;
+	return ret;
+}
+
+static noinline long btrfs_ioctl_clone(struct file *file, unsigned long srcfd,
+				       u64 off, u64 len, u64 destoff)
+{
+	struct inode *inode = file_inode(file);
+	struct fd src_file;
+	struct inode *src;
+	long ret;
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
+	ret = -EXDEV;
+	if (src_file.file->f_path.mnt != file->f_path.mnt)
+		goto out_fput;
+
+	src = file_inode(src_file.file);
+
+	ret = -EINVAL;
+	if (src == inode)
+		goto out_fput;
+
+	/* the src must be open for reading */
+	if (!(src_file.file->f_mode & FMODE_READ))
+		goto out_fput;
+
+	ret = -EISDIR;
+	if (S_ISDIR(src->i_mode) || S_ISDIR(inode->i_mode))
+		goto out_fput;
+
+	ret = -EXDEV;
+	if (src->i_sb != inode->i_sb)
+		goto out_fput;
+
+	ret = -EINVAL;
+	if (off + len > src->i_size || off + len < off)
+		goto out_fput;
+
+	ret = btrfs_clone_extents(inode, src, off, len, destoff);
+
 out_fput:
 	fdput(src_file);
 out_drop_write:
-- 
1.7.11.7


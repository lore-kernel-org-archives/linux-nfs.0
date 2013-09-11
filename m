Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41776 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754053Ab3IKRQp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Sep 2013 13:16:45 -0400
From: Zach Brown <zab@redhat.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Bryan Schumaker <bjschuma@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Wong <normalperson@yhbt.net>
Subject: [PATCH 3/3] btrfs: implement .splice_direct extent copying
Date: Wed, 11 Sep 2013 10:06:50 -0700
Message-Id: <1378919210-10372-4-git-send-email-zab@redhat.com>
In-Reply-To: <1378919210-10372-1-git-send-email-zab@redhat.com>
References: <1378919210-10372-1-git-send-email-zab@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch re-uses the existing btrfs file cloning ioctl code to
implement the .splice_direct copy offloading file operation.

The existing extent item copying btrfs_ioctl_clone() is renamed to a
shared btrfs_clone_extents().  The ioctl specific code (mostly simple
entry-point stuff that splice() already does elsewhere) is moved to a
new much smaller btrfs_ioctl_clone().

btrfs_splice_direct() thus inherits the conservative limitations of the
btrfs clone ioctl: it only allows block-aligned copies between files on
the same snapshot.

Signed-off-by: Zach Brown <zab@redhat.com>
---
 fs/btrfs/ctree.h |  2 ++
 fs/btrfs/file.c  | 11 ++++++++++
 fs/btrfs/ioctl.c | 64 +++++++++++++++++++++++++++++++-------------------------
 3 files changed, 48 insertions(+), 29 deletions(-)

diff --git a/fs/btrfs/ctree.h b/fs/btrfs/ctree.h
index e795bf1..f73830e 100644
--- a/fs/btrfs/ctree.h
+++ b/fs/btrfs/ctree.h
@@ -3648,6 +3648,8 @@ int btrfs_defrag_file(struct inode *inode, struct file *file,
 		      u64 newer_than, unsigned long max_pages);
 void btrfs_get_block_group_info(struct list_head *groups_list,
 				struct btrfs_ioctl_space_info *space);
+long btrfs_clone_extents(struct file *file, struct file *src_file, u64 off,
+			 u64 olen, u64 destoff);
 
 /* file.c */
 int btrfs_auto_defrag_init(void);
diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index 4d2eb64..82aec93 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -2557,6 +2557,16 @@ out:
 	return offset;
 }
 
+static long btrfs_splice_direct(struct file *in, loff_t in_pos,
+				struct file *out, loff_t out_pos, size_t len,
+				unsigned int flags)
+{
+	int ret = btrfs_clone_extents(out, in, in_pos, len, out_pos);
+	if (ret == 0)
+		ret = len;
+	return ret;
+}
+
 const struct file_operations btrfs_file_operations = {
 	.llseek		= btrfs_file_llseek,
 	.read		= do_sync_read,
@@ -2573,6 +2583,7 @@ const struct file_operations btrfs_file_operations = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl	= btrfs_ioctl,
 #endif
+	.splice_direct	= btrfs_splice_direct,
 };
 
 void btrfs_auto_defrag_exit(void)
diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index 238a055..cddf6ef 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -2469,13 +2469,12 @@ out:
 	return ret;
 }
 
-static noinline long btrfs_ioctl_clone(struct file *file, unsigned long srcfd,
-				       u64 off, u64 olen, u64 destoff)
+long btrfs_clone_extents(struct file *file, struct file *src_file, u64 off,
+			 u64 olen, u64 destoff)
 {
 	struct inode *inode = file_inode(file);
+	struct inode *src = file_inode(src_file);
 	struct btrfs_root *root = BTRFS_I(inode)->root;
-	struct fd src_file;
-	struct inode *src;
 	struct btrfs_trans_handle *trans;
 	struct btrfs_path *path;
 	struct extent_buffer *leaf;
@@ -2498,10 +2497,6 @@ static noinline long btrfs_ioctl_clone(struct file *file, unsigned long srcfd,
 	 *   they don't overlap)?
 	 */
 
-	/* the destination must be opened for writing */
-	if (!(file->f_mode & FMODE_WRITE) || (file->f_flags & O_APPEND))
-		return -EINVAL;
-
 	if (btrfs_root_readonly(root))
 		return -EROFS;
 
@@ -2509,48 +2504,36 @@ static noinline long btrfs_ioctl_clone(struct file *file, unsigned long srcfd,
 	if (ret)
 		return ret;
 
-	src_file = fdget(srcfd);
-	if (!src_file.file) {
-		ret = -EBADF;
-		goto out_drop_write;
-	}
-
 	ret = -EXDEV;
-	if (src_file.file->f_path.mnt != file->f_path.mnt)
-		goto out_fput;
-
-	src = file_inode(src_file.file);
+	if (src_file->f_path.mnt != file->f_path.mnt)
+		goto out_drop_write;
 
 	ret = -EINVAL;
 	if (src == inode)
 		same_inode = 1;
 
-	/* the src must be open for reading */
-	if (!(src_file.file->f_mode & FMODE_READ))
-		goto out_fput;
-
 	/* don't make the dst file partly checksummed */
 	if ((BTRFS_I(src)->flags & BTRFS_INODE_NODATASUM) !=
 	    (BTRFS_I(inode)->flags & BTRFS_INODE_NODATASUM))
-		goto out_fput;
+		goto out_drop_write;
 
 	ret = -EISDIR;
 	if (S_ISDIR(src->i_mode) || S_ISDIR(inode->i_mode))
-		goto out_fput;
+		goto out_drop_write;
 
 	ret = -EXDEV;
 	if (src->i_sb != inode->i_sb)
-		goto out_fput;
+		goto out_drop_write;
 
 	ret = -ENOMEM;
 	buf = vmalloc(btrfs_level_size(root, 0));
 	if (!buf)
-		goto out_fput;
+		goto out_drop_write;
 
 	path = btrfs_alloc_path();
 	if (!path) {
 		vfree(buf);
-		goto out_fput;
+		goto out_drop_write;
 	}
 	path->reada = 2;
 
@@ -2867,13 +2850,36 @@ out_unlock:
 		mutex_unlock(&inode->i_mutex);
 	vfree(buf);
 	btrfs_free_path(path);
-out_fput:
-	fdput(src_file);
 out_drop_write:
 	mnt_drop_write_file(file);
 	return ret;
 }
 
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
+	src_file = fdget(srcfd);
+	if (!src_file.file)
+		return -EBADF;
+
+	/* the src must be open for reading */
+	if (!(src_file.file->f_mode & FMODE_READ))
+		ret = -EINVAL;
+	else
+		ret = btrfs_clone_extents(file, src_file.file, off, olen,
+					  destoff);
+
+	fdput(src_file);
+	return ret;
+}
+
 static long btrfs_ioctl_clone_range(struct file *file, void __user *argp)
 {
 	struct btrfs_ioctl_clone_range_args args;
-- 
1.7.11.7


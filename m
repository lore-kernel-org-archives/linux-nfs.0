Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33104 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756358AbbHZISr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2015 04:18:47 -0400
Received: by pacti10 with SMTP id ti10so80529127pac.0
        for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2015 01:18:47 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>, bfields@fieldses.org,
        Jeff Layton <jeff.layton@primarydata.com>, linux-nfs@vger.kernel.org,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        linux-btrfs@vger.kernel.org, Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH-RFC-RESEND 2/9] vfs/btrfs: add .clone_range file operation
Date: Wed, 26 Aug 2015 16:16:43 +0800
Message-Id: <1440577010-122867-3-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1440577010-122867-1-git-send-email-tao.peng@primarydata.com>
References: <1440577010-122867-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also add vfs callers in do_vfs_ioctl(). Now btrfs CLONE
ioctl goes through vfs_file_clone_range().

One question to btrfs developers:
Does btrfs_clone() ever return a positive value? If it does, what does it mean
to users?

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/btrfs/ctree.h           |  2 ++
 fs/btrfs/file.c            |  1 +
 fs/btrfs/ioctl.c           | 68 +++++-----------------------------------------
 fs/ioctl.c                 |  6 ++++
 include/uapi/linux/btrfs.h | 10 -------
 5 files changed, 16 insertions(+), 71 deletions(-)

diff --git a/fs/btrfs/ctree.h b/fs/btrfs/ctree.h
index aac314e..af3e224 100644
--- a/fs/btrfs/ctree.h
+++ b/fs/btrfs/ctree.h
@@ -3969,6 +3969,8 @@ void btrfs_get_block_group_info(struct list_head *groups_list,
 				struct btrfs_ioctl_space_info *space);
 void update_ioctl_balance_args(struct btrfs_fs_info *fs_info, int lock,
 			       struct btrfs_ioctl_balance_args *bargs);
+int btrfs_file_clone_range(struct file *src_file, struct file *dst_file,
+			   loff_t off, size_t olen, loff_t destoff);
 
 
 /* file.c */
diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index b823fac..c9170fd 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -2813,6 +2813,7 @@ const struct file_operations btrfs_file_operations = {
 	.fsync		= btrfs_sync_file,
 	.fallocate	= btrfs_fallocate,
 	.unlocked_ioctl	= btrfs_ioctl,
+	.clone_range	= btrfs_file_clone_range,
 #ifdef CONFIG_COMPAT
 	.compat_ioctl	= btrfs_ioctl,
 #endif
diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index 0770c91..3d026c8 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -3719,13 +3719,12 @@ out:
 	return ret;
 }
 
-static noinline long btrfs_ioctl_clone(struct file *file, unsigned long srcfd,
-				       u64 off, u64 olen, u64 destoff)
+int btrfs_file_clone_range(struct file *src_file, struct file *dst_file,
+			   loff_t off, size_t olen, loff_t destoff)
 {
-	struct inode *inode = file_inode(file);
+	struct inode *inode = file_inode(dst_file);
 	struct btrfs_root *root = BTRFS_I(inode)->root;
-	struct fd src_file;
-	struct inode *src;
+	struct inode *src = file_inode(src_file);
 	int ret;
 	u64 len = olen;
 	u64 bs = root->fs_info->sb->s_blocksize;
@@ -3742,49 +3741,16 @@ static noinline long btrfs_ioctl_clone(struct file *file, unsigned long srcfd,
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
-
 	/* don't make the dst file partly checksummed */
 	if ((BTRFS_I(src)->flags & BTRFS_INODE_NODATASUM) !=
 	    (BTRFS_I(inode)->flags & BTRFS_INODE_NODATASUM))
-		goto out_fput;
-
-	ret = -EISDIR;
-	if (S_ISDIR(src->i_mode) || S_ISDIR(inode->i_mode))
-		goto out_fput;
+		return -EINVAL;
 
-	ret = -EXDEV;
-	if (src->i_sb != inode->i_sb)
-		goto out_fput;
+	if (src == inode)
+		same_inode = 1;
 
 	if (!same_inode) {
 		if (inode < src) {
@@ -3800,8 +3766,6 @@ static noinline long btrfs_ioctl_clone(struct file *file, unsigned long srcfd,
 
 	/* determine range to clone */
 	ret = -EINVAL;
-	if (off + len > src->i_size || off + len < off)
-		goto out_unlock;
 	if (len == 0)
 		olen = len = src->i_size - off;
 	/* if we extend to eof, continue to block boundary */
@@ -3877,23 +3841,9 @@ out_unlock:
 	} else {
 		mutex_unlock(&src->i_mutex);
 	}
-out_fput:
-	fdput(src_file);
-out_drop_write:
-	mnt_drop_write_file(file);
 	return ret;
 }
 
-static long btrfs_ioctl_clone_range(struct file *file, void __user *argp)
-{
-	struct btrfs_ioctl_clone_range_args args;
-
-	if (copy_from_user(&args, argp, sizeof(args)))
-		return -EFAULT;
-	return btrfs_ioctl_clone(file, args.src_fd, args.src_offset,
-				 args.src_length, args.dest_offset);
-}
-
 /*
  * there are many ways the trans_start and trans_end ioctls can lead
  * to deadlocks.  They should only be used by applications that
@@ -5433,10 +5383,6 @@ long btrfs_ioctl(struct file *file, unsigned int
 		return btrfs_ioctl_dev_info(root, argp);
 	case BTRFS_IOC_BALANCE:
 		return btrfs_ioctl_balance(file, NULL);
-	case BTRFS_IOC_CLONE:
-		return btrfs_ioctl_clone(file, arg, 0, 0, 0);
-	case BTRFS_IOC_CLONE_RANGE:
-		return btrfs_ioctl_clone_range(file, argp);
 	case BTRFS_IOC_TRANS_START:
 		return btrfs_ioctl_trans_start(file);
 	case BTRFS_IOC_TRANS_END:
diff --git a/fs/ioctl.c b/fs/ioctl.c
index 726c5d7..41c6080 100644
--- a/fs/ioctl.c
+++ b/fs/ioctl.c
@@ -624,6 +624,12 @@ int do_vfs_ioctl(struct file *filp, unsigned int fd, unsigned int cmd,
 	case FIGETBSZ:
 		return put_user(inode->i_sb->s_blocksize, argp);
 
+	case FICLONE:
+		return ioctl_file_clone(filp, arg, 0, 0, 0);
+
+	case FICLONERANGE:
+		return ioctl_file_clone_range(filp, argp);
+
 	default:
 		if (S_ISREG(inode->i_mode))
 			error = file_ioctl(filp, cmd, arg);
diff --git a/include/uapi/linux/btrfs.h b/include/uapi/linux/btrfs.h
index b6dec05..c3a23d3 100644
--- a/include/uapi/linux/btrfs.h
+++ b/include/uapi/linux/btrfs.h
@@ -316,12 +316,6 @@ struct btrfs_ioctl_search_args_v2 {
 	__u64 buf[0];                       /* out - found items */
 };
 
-struct btrfs_ioctl_clone_range_args {
-  __s64 src_fd;
-  __u64 src_offset, src_length;
-  __u64 dest_offset;
-};
-
 /* flags for the defrag range ioctl */
 #define BTRFS_DEFRAG_RANGE_COMPRESS 1
 #define BTRFS_DEFRAG_RANGE_START_IO 2
@@ -548,7 +542,6 @@ static inline char *btrfs_err_str(enum btrfs_err_code err_code)
 #define BTRFS_IOC_TRANS_END    _IO(BTRFS_IOCTL_MAGIC, 7)
 #define BTRFS_IOC_SYNC         _IO(BTRFS_IOCTL_MAGIC, 8)
 
-#define BTRFS_IOC_CLONE        _IOW(BTRFS_IOCTL_MAGIC, 9, int)
 #define BTRFS_IOC_ADD_DEV _IOW(BTRFS_IOCTL_MAGIC, 10, \
 				   struct btrfs_ioctl_vol_args)
 #define BTRFS_IOC_RM_DEV _IOW(BTRFS_IOCTL_MAGIC, 11, \
@@ -556,9 +549,6 @@ static inline char *btrfs_err_str(enum btrfs_err_code err_code)
 #define BTRFS_IOC_BALANCE _IOW(BTRFS_IOCTL_MAGIC, 12, \
 				   struct btrfs_ioctl_vol_args)
 
-#define BTRFS_IOC_CLONE_RANGE _IOW(BTRFS_IOCTL_MAGIC, 13, \
-				  struct btrfs_ioctl_clone_range_args)
-
 #define BTRFS_IOC_SUBVOL_CREATE _IOW(BTRFS_IOCTL_MAGIC, 14, \
 				   struct btrfs_ioctl_vol_args)
 #define BTRFS_IOC_SNAP_DESTROY _IOW(BTRFS_IOCTL_MAGIC, 15, \
-- 
1.8.3.1


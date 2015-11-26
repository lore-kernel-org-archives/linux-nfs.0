Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:40775 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753408AbbKZSzp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Nov 2015 13:55:45 -0500
From: Christoph Hellwig <hch@lst.de>
To: viro@zeniv.linux.org.uk
Cc: tao.peng@primarydata.com, jeff.layton@primarydata.com,
        linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org
Subject: [PATCH 3/5] vfs: pull btrfs clone API to vfs layer
Date: Thu, 26 Nov 2015 19:50:57 +0100
Message-Id: <1448563859-21922-4-git-send-email-hch@lst.de>
In-Reply-To: <1448563859-21922-1-git-send-email-hch@lst.de>
References: <1448563859-21922-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The btrfs ioctl clones are now adopted by other file systems:
NFS since 4.3 and XFS a few kernel in the future, as well as the
previous (incorrect) usage by CIFS.  To avoid growth of various
slightly incompatible implementation add one to the core VFS
code.  Note that clones are different from file copies in various
ways:

 - they are atomic vs other writers
 - they support whole file clones
 - they support 64-bit legth clones
 - they do not allow partial success (aka short writes)
 - clones are expected to be a fast metadata operation

Because of that it would be rather cumbersome to try to piggyback
them on top of the recent clone_file_range infrastructure.

Based on earlier work from Peng Tao.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/btrfs/ctree.h         |   3 +-
 fs/btrfs/file.c          |   1 +
 fs/btrfs/ioctl.c         |  49 ++--------------------
 fs/ioctl.c               |  29 +++++++++++++
 fs/nfs/nfs42proc.c       |   1 +
 fs/nfs/nfs4file.c        | 107 ++++++++---------------------------------------
 fs/read_write.c          |  71 +++++++++++++++++++++++++++++++
 include/linux/fs.h       |   7 +++-
 include/uapi/linux/fs.h  |   9 ++++
 include/uapi/linux/nfs.h |  11 -----
 10 files changed, 140 insertions(+), 148 deletions(-)

diff --git a/fs/btrfs/ctree.h b/fs/btrfs/ctree.h
index dd7d888..adc997f 100644
--- a/fs/btrfs/ctree.h
+++ b/fs/btrfs/ctree.h
@@ -4021,7 +4021,6 @@ void btrfs_get_block_group_info(struct list_head *groups_list,
 void update_ioctl_balance_args(struct btrfs_fs_info *fs_info, int lock,
 			       struct btrfs_ioctl_balance_args *bargs);
 
-
 /* file.c */
 int btrfs_auto_defrag_init(void);
 void btrfs_auto_defrag_exit(void);
@@ -4054,6 +4053,8 @@ int btrfs_fdatawrite_range(struct inode *inode, loff_t start, loff_t end);
 ssize_t btrfs_copy_file_range(struct file *file_in, loff_t pos_in,
 			      struct file *file_out, loff_t pos_out,
 			      size_t len, unsigned int flags);
+int btrfs_clone_file_range(struct file *file_in, loff_t pos_in,
+			   struct file *file_out, loff_t pos_out, u64 len);
 
 /* tree-defrag.c */
 int btrfs_defrag_leaves(struct btrfs_trans_handle *trans,
diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index 1c0ee74..3b61b0a 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -2921,6 +2921,7 @@ const struct file_operations btrfs_file_operations = {
 	.compat_ioctl	= btrfs_ioctl,
 #endif
 	.copy_file_range = btrfs_copy_file_range,
+	.clone_file_range = btrfs_clone_file_range,
 };
 
 void btrfs_auto_defrag_exit(void)
diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index 0f92735..85b1cae 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -3906,49 +3906,10 @@ ssize_t btrfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	return ret;
 }
 
-static noinline long btrfs_ioctl_clone(struct file *file, unsigned long srcfd,
-				       u64 off, u64 olen, u64 destoff)
+int btrfs_clone_file_range(struct file *src_file, loff_t off,
+		struct file *dst_file, loff_t destoff, u64 len)
 {
-	struct fd src_file;
-	int ret;
-
-	/* the destination must be opened for writing */
-	if (!(file->f_mode & FMODE_WRITE) || (file->f_flags & O_APPEND))
-		return -EINVAL;
-
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
-	/* the src must be open for reading */
-	if (!(src_file.file->f_mode & FMODE_READ)) {
-		ret = -EINVAL;
-		goto out_fput;
-	}
-
-	ret = btrfs_clone_files(file, src_file.file, off, olen, destoff);
-
-out_fput:
-	fdput(src_file);
-out_drop_write:
-	mnt_drop_write_file(file);
-	return ret;
-}
-
-static long btrfs_ioctl_clone_range(struct file *file, void __user *argp)
-{
-	struct btrfs_ioctl_clone_range_args args;
-
-	if (copy_from_user(&args, argp, sizeof(args)))
-		return -EFAULT;
-	return btrfs_ioctl_clone(file, args.src_fd, args.src_offset,
-				 args.src_length, args.dest_offset);
+	return btrfs_clone_files(dst_file, src_file, off, len, destoff);
 }
 
 /*
@@ -5498,10 +5459,6 @@ long btrfs_ioctl(struct file *file, unsigned int
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
index 5d01d26..84c6e79 100644
--- a/fs/ioctl.c
+++ b/fs/ioctl.c
@@ -215,6 +215,29 @@ static int ioctl_fiemap(struct file *filp, unsigned long arg)
 	return error;
 }
 
+static long ioctl_file_clone(struct file *dst_file, unsigned long srcfd,
+			     u64 off, u64 olen, u64 destoff)
+{
+	struct fd src_file = fdget(srcfd);
+	int ret;
+
+	if (!src_file.file)
+		return -EBADF;
+	ret = vfs_clone_file_range(src_file.file, off, dst_file, destoff, olen);
+	fdput(src_file);
+	return ret;
+}
+
+static long ioctl_file_clone_range(struct file *file, void __user *argp)
+{
+	struct file_clone_range args;
+
+	if (copy_from_user(&args, argp, sizeof(args)))
+		return -EFAULT;
+	return ioctl_file_clone(file, args.src_fd, args.src_offset,
+				args.src_length, args.dest_offset);
+}
+
 #ifdef CONFIG_BLOCK
 
 static inline sector_t logical_to_blk(struct inode *inode, loff_t offset)
@@ -600,6 +623,12 @@ int do_vfs_ioctl(struct file *filp, unsigned int fd, unsigned int cmd,
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
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 3e92a3c..303d22e 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -284,6 +284,7 @@ static int _nfs42_proc_clone(struct rpc_message *msg, struct file *src_f,
 		.dst_fh = NFS_FH(dst_inode),
 		.src_offset = src_offset,
 		.dst_offset = dst_offset,
+		.count = count,
 		.dst_bitmask = server->cache_consistency_bitmask,
 	};
 	struct nfs42_clone_res res = {
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 4aa5719..f46d087 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -194,63 +194,32 @@ static long nfs42_fallocate(struct file *filep, int mode, loff_t offset, loff_t
 	return nfs42_proc_allocate(filep, offset, len);
 }
 
-static noinline long
-nfs42_ioctl_clone(struct file *dst_file, unsigned long srcfd,
-		  u64 src_off, u64 dst_off, u64 count)
+static int nfs42_clone_file_range(struct file *src_file, loff_t src_off,
+		struct file *dst_file, loff_t dst_off, u64 count)
 {
 	struct inode *dst_inode = file_inode(dst_file);
 	struct nfs_server *server = NFS_SERVER(dst_inode);
-	struct fd src_file;
-	struct inode *src_inode;
+	struct inode *src_inode = file_inode(src_file);
 	unsigned int bs = server->clone_blksize;
+	bool same_inode = false;
 	int ret;
 
-	/* dst file must be opened for writing */
-	if (!(dst_file->f_mode & FMODE_WRITE))
-		return -EINVAL;
-
-	ret = mnt_want_write_file(dst_file);
-	if (ret)
-		return ret;
-
-	src_file = fdget(srcfd);
-	if (!src_file.file) {
-		ret = -EBADF;
-		goto out_drop_write;
-	}
-
-	src_inode = file_inode(src_file.file);
-
-	/* src and dst must be different files */
-	ret = -EINVAL;
-	if (src_inode == dst_inode)
-		goto out_fput;
-
-	/* src file must be opened for reading */
-	if (!(src_file.file->f_mode & FMODE_READ))
-		goto out_fput;
-
-	/* src and dst must be regular files */
-	ret = -EISDIR;
-	if (!S_ISREG(src_inode->i_mode) || !S_ISREG(dst_inode->i_mode))
-		goto out_fput;
-
-	ret = -EXDEV;
-	if (src_file.file->f_path.mnt != dst_file->f_path.mnt ||
-	    src_inode->i_sb != dst_inode->i_sb)
-		goto out_fput;
-
 	/* check alignment w.r.t. clone_blksize */
 	ret = -EINVAL;
 	if (bs) {
 		if (!IS_ALIGNED(src_off, bs) || !IS_ALIGNED(dst_off, bs))
-			goto out_fput;
+			goto out;
 		if (!IS_ALIGNED(count, bs) && i_size_read(src_inode) != (src_off + count))
-			goto out_fput;
+			goto out;
 	}
 
+	if (src_inode == dst_inode)
+		same_inode = true;
+
 	/* XXX: do we lock at all? what if server needs CB_RECALL_LAYOUT? */
-	if (dst_inode < src_inode) {
+	if (same_inode) {
+		mutex_lock(&src_inode->i_mutex);
+	} else if (dst_inode < src_inode) {
 		mutex_lock_nested(&dst_inode->i_mutex, I_MUTEX_PARENT);
 		mutex_lock_nested(&src_inode->i_mutex, I_MUTEX_CHILD);
 	} else {
@@ -267,7 +236,7 @@ nfs42_ioctl_clone(struct file *dst_file, unsigned long srcfd,
 	if (ret)
 		goto out_unlock;
 
-	ret = nfs42_proc_clone(src_file.file, dst_file, src_off, dst_off, count);
+	ret = nfs42_proc_clone(src_file, dst_file, src_off, dst_off, count);
 
 	/* truncate inode page cache of the dst range so that future reads can fetch
 	 * new data from server */
@@ -275,56 +244,20 @@ nfs42_ioctl_clone(struct file *dst_file, unsigned long srcfd,
 		truncate_inode_pages_range(&dst_inode->i_data, dst_off, dst_off + count - 1);
 
 out_unlock:
-	if (dst_inode < src_inode) {
+	if (same_inode) {
+		mutex_unlock(&src_inode->i_mutex);
+	} else if (dst_inode < src_inode) {
 		mutex_unlock(&src_inode->i_mutex);
 		mutex_unlock(&dst_inode->i_mutex);
 	} else {
 		mutex_unlock(&dst_inode->i_mutex);
 		mutex_unlock(&src_inode->i_mutex);
 	}
-out_fput:
-	fdput(src_file);
-out_drop_write:
-	mnt_drop_write_file(dst_file);
+out:
 	return ret;
 }
-
-static long nfs42_ioctl_clone_range(struct file *dst_file, void __user *argp)
-{
-	struct nfs_ioctl_clone_range_args args;
-
-	if (copy_from_user(&args, argp, sizeof(args)))
-		return -EFAULT;
-
-	return nfs42_ioctl_clone(dst_file, args.src_fd, args.src_off, args.dst_off, args.count);
-}
-#else
-static long nfs42_ioctl_clone(struct file *dst_file, unsigned long srcfd,
-		u64 src_off, u64 dst_off, u64 count)
-{
-	return -ENOTTY;
-}
-
-static long nfs42_ioctl_clone_range(struct file *dst_file, void __user *argp)
-{
-	return -ENOTTY;
-}
 #endif /* CONFIG_NFS_V4_2 */
 
-long nfs4_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
-{
-	void __user *argp = (void __user *)arg;
-
-	switch (cmd) {
-	case NFS_IOC_CLONE:
-		return nfs42_ioctl_clone(file, arg, 0, 0, 0);
-	case NFS_IOC_CLONE_RANGE:
-		return nfs42_ioctl_clone_range(file, argp);
-	}
-
-	return -ENOTTY;
-}
-
 const struct file_operations nfs4_file_operations = {
 #ifdef CONFIG_NFS_V4_2
 	.llseek		= nfs4_file_llseek,
@@ -344,12 +277,8 @@ const struct file_operations nfs4_file_operations = {
 	.splice_write	= iter_file_splice_write,
 #ifdef CONFIG_NFS_V4_2
 	.fallocate	= nfs42_fallocate,
+	.clone_file_range = nfs42_clone_file_range,
 #endif /* CONFIG_NFS_V4_2 */
 	.check_flags	= nfs_check_flags,
 	.setlease	= simple_nosetlease,
-#ifdef CONFIG_COMPAT
-	.unlocked_ioctl = nfs4_ioctl,
-#else
-	.compat_ioctl	= nfs4_ioctl,
-#endif /* CONFIG_COMPAT */
 };
diff --git a/fs/read_write.c b/fs/read_write.c
index 48157dd..095e209 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1451,3 +1451,74 @@ out1:
 out2:
 	return ret;
 }
+
+static int clone_verify_area(struct file *file, loff_t pos, u64 len, bool write)
+{
+	struct inode *inode = file_inode(file);
+
+	if (unlikely(pos < 0))
+		return -EINVAL;
+
+	 if (unlikely((loff_t) (pos + len) < 0))
+		return -EINVAL;
+
+	if (unlikely(inode->i_flctx && mandatory_lock(inode))) {
+		loff_t end = len ? pos + len - 1 : OFFSET_MAX;
+		int retval;
+
+		retval = locks_mandatory_area(file, pos, end, write);
+		if (retval < 0)
+			return retval;
+	}
+
+	return security_file_permission(file, write ? MAY_WRITE : MAY_READ);
+}
+
+int vfs_clone_file_range(struct file *file_in, loff_t pos_in,
+		struct file *file_out, loff_t pos_out, u64 len)
+{
+	struct inode *inode_in = file_inode(file_in);
+	struct inode *inode_out = file_inode(file_out);
+	int ret;
+
+	if (inode_in->i_sb != inode_out->i_sb ||
+	    file_in->f_path.mnt != file_out->f_path.mnt)
+		return -EXDEV;
+
+	if (S_ISDIR(inode_in->i_mode) || S_ISDIR(inode_out->i_mode))
+		return -EISDIR;
+	if (!S_ISREG(inode_in->i_mode) || !S_ISREG(inode_out->i_mode))
+		return -EOPNOTSUPP;
+
+	if (!(file_in->f_mode & FMODE_READ) ||
+	    !(file_out->f_mode & FMODE_WRITE) ||
+	    (file_out->f_flags & O_APPEND) ||
+	    !file_in->f_op->clone_file_range)
+		return -EBADF;
+
+	ret = clone_verify_area(file_in, pos_in, len, false);
+	if (ret)
+		return ret;
+
+	ret = clone_verify_area(file_out, pos_out, len, true);
+	if (ret)
+		return ret;
+
+	if (pos_in + len > i_size_read(inode_in))
+		return -EINVAL;
+
+	ret = mnt_want_write_file(file_out);
+	if (ret)
+		return ret;
+
+	ret = file_in->f_op->clone_file_range(file_in, pos_in,
+			file_out, pos_out, len);
+	if (!ret) {
+		fsnotify_access(file_in);
+		fsnotify_modify(file_out);
+	}
+
+	mnt_drop_write_file(file_out);
+	return ret;
+}
+EXPORT_SYMBOL(vfs_clone_file_range);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index e640f791..75ce095 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1629,7 +1629,10 @@ struct file_operations {
 #ifndef CONFIG_MMU
 	unsigned (*mmap_capabilities)(struct file *);
 #endif
-	ssize_t (*copy_file_range)(struct file *, loff_t, struct file *, loff_t, size_t, unsigned int);
+	ssize_t (*copy_file_range)(struct file *, loff_t, struct file *,
+			loff_t, size_t, unsigned int);
+	int (*clone_file_range)(struct file *, loff_t, struct file *, loff_t,
+			u64);
 };
 
 struct inode_operations {
@@ -1683,6 +1686,8 @@ extern ssize_t vfs_writev(struct file *, const struct iovec __user *,
 		unsigned long, loff_t *);
 extern ssize_t vfs_copy_file_range(struct file *, loff_t , struct file *,
 				   loff_t, size_t, unsigned int);
+extern int vfs_clone_file_range(struct file *file_in, loff_t pos_in,
+		struct file *file_out, loff_t pos_out, u64 len);
 
 struct super_operations {
    	struct inode *(*alloc_inode)(struct super_block *sb);
diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
index f15d980..cd5db7f 100644
--- a/include/uapi/linux/fs.h
+++ b/include/uapi/linux/fs.h
@@ -39,6 +39,13 @@
 #define RENAME_EXCHANGE		(1 << 1)	/* Exchange source and dest */
 #define RENAME_WHITEOUT		(1 << 2)	/* Whiteout source */
 
+struct file_clone_range {
+	__s64 src_fd;
+	__u64 src_offset;
+	__u64 src_length;
+	__u64 dest_offset;
+};
+
 struct fstrim_range {
 	__u64 start;
 	__u64 len;
@@ -159,6 +166,8 @@ struct inodes_stat_t {
 #define FIFREEZE	_IOWR('X', 119, int)	/* Freeze */
 #define FITHAW		_IOWR('X', 120, int)	/* Thaw */
 #define FITRIM		_IOWR('X', 121, struct fstrim_range)	/* Trim */
+#define FICLONE		_IOW(0x94, 9, int)
+#define FICLONERANGE	_IOW(0x94, 13, struct file_clone_range)
 
 #define	FS_IOC_GETFLAGS			_IOR('f', 1, long)
 #define	FS_IOC_SETFLAGS			_IOW('f', 2, long)
diff --git a/include/uapi/linux/nfs.h b/include/uapi/linux/nfs.h
index 654bae3..5e62961 100644
--- a/include/uapi/linux/nfs.h
+++ b/include/uapi/linux/nfs.h
@@ -33,17 +33,6 @@
 
 #define NFS_PIPE_DIRNAME "nfs"
 
-/* NFS ioctls */
-/* Let's follow btrfs lead on CLONE to avoid messing userspace */
-#define NFS_IOC_CLONE		_IOW(0x94, 9, int)
-#define NFS_IOC_CLONE_RANGE	_IOW(0x94, 13, int)
-
-struct nfs_ioctl_clone_range_args {
-	__s64 src_fd;
-	__u64 src_off, count;
-	__u64 dst_off;
-};
-
 /*
  * NFS stats. The good thing with these values is that NFSv3 errors are
  * a superset of NFSv2 errors (with the exception of NFSERR_WFLUSH which
-- 
1.9.1


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34855 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752620AbbJXP3P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Oct 2015 11:29:15 -0400
Received: by pasz6 with SMTP id z6so144431897pas.2
        for <linux-nfs@vger.kernel.org>; Sat, 24 Oct 2015 08:29:14 -0700 (PDT)
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
Subject: [PATCH 4/9] vfs: pull btrfs clone API to vfs layer
Date: Sun, 25 Oct 2015 07:17:11 +0800
Message-Id: <1445728636-10109-5-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1445728636-10109-1-git-send-email-tao.peng@primarydata.com>
References: <1445728636-10109-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that a few file systems are adding clone functionality, namingly
btrfs, CIFS, NFS (in another series) and XFS
(ttp://oss.sgi.com/archives/xfs/2015-06/msg00407.html), it makes sense
to pull the ioctl to common code.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/ioctl.c              | 40 ++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/fs.h |  9 +++++++++
 2 files changed, 49 insertions(+)

diff --git a/fs/ioctl.c b/fs/ioctl.c
index 5d01d26..9a78426 100644
--- a/fs/ioctl.c
+++ b/fs/ioctl.c
@@ -215,6 +215,40 @@ static int ioctl_fiemap(struct file *filp, unsigned long arg)
 	return error;
 }
 
+static long ioctl_file_clone(struct file *dst_file, unsigned long srcfd,
+			     u64 off, u64 olen, u64 destoff)
+{
+	struct fd src_file = fdget(srcfd);
+	struct inode *src_inode;
+	int ret;
+
+	if (!src_file.file)
+		return -EBADF;
+	/* olen == 0 means src off to eof */
+	if (olen == 0) {
+		src_inode = file_inode(src_file.file);
+		olen = i_size_read(src_inode) - off;
+	}
+	ret = vfs_copy_file_range(src_file.file, off, dst_file,
+				  destoff, olen, COPY_FILE_CLONE_ONLY);
+	/* vfs_copy_file_range returns bytes copied */
+	if (ret > 0)
+		ret = 0;
+
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
@@ -600,6 +634,12 @@ int do_vfs_ioctl(struct file *filp, unsigned int fd, unsigned int cmd,
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
diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
index 9b964a5..ac7f1c5 100644
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
+#define FICLONE		_IOW(0x94, 9, int)	/* Clone */
+#define FICLONERANGE	_IOW(0x94, 13, struct file_clone_range)	/* Clone range */
 
 #define	FS_IOC_GETFLAGS			_IOR('f', 1, long)
 #define	FS_IOC_SETFLAGS			_IOW('f', 2, long)
-- 
1.8.3.1


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34030 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752715AbbJXP3g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Oct 2015 11:29:36 -0400
Received: by padhk11 with SMTP id hk11so144713338pad.1
        for <linux-nfs@vger.kernel.org>; Sat, 24 Oct 2015 08:29:35 -0700 (PDT)
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
Subject: [PATCH 7/9] nfs42: remove private clone ioctl handler
Date: Sun, 25 Oct 2015 07:17:14 +0800
Message-Id: <1445728636-10109-8-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1445728636-10109-1-git-send-email-tao.peng@primarydata.com>
References: <1445728636-10109-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

BTRFS_IOC_CLONE/BTRFS_IOC_CLONE_RANGE is now handled
by generic layer and goes through the .copy_file_range
method.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/nfs4file.c | 96 -------------------------------------------------------
 1 file changed, 96 deletions(-)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index f1924d8..181b67b 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -240,99 +240,8 @@ out_unlock:
 out:
 	return ret < 0 ? ret : len;
 }
-
-static noinline long
-nfs42_ioctl_clone(struct file *dst_file, unsigned long srcfd,
-		  u64 src_off, u64 dst_off, u64 count)
-{
-	struct inode *dst_inode = file_inode(dst_file);
-	struct fd src_file;
-	struct inode *src_inode;
-	int ret;
-
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
-	ret = nfs42_copy_file_range(src_file.file, src_off, dst_file,
-				    dst_off, count, 0);
-	if (ret > 0)
-		ret = 0;
-
-out_fput:
-	fdput(src_file);
-out_drop_write:
-	mnt_drop_write_file(dst_file);
-	return ret;
-}
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
@@ -356,9 +265,4 @@ const struct file_operations nfs4_file_operations = {
 #endif /* CONFIG_NFS_V4_2 */
 	.check_flags	= nfs_check_flags,
 	.setlease	= simple_nosetlease,
-#ifdef CONFIG_COMPAT
-	.unlocked_ioctl = nfs4_ioctl,
-#else
-	.compat_ioctl	= nfs4_ioctl,
-#endif /* CONFIG_COMPAT */
 };
-- 
1.8.3.1


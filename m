Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34904 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681AbbJXP3V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Oct 2015 11:29:21 -0400
Received: by pasz6 with SMTP id z6so144433312pas.2
        for <linux-nfs@vger.kernel.org>; Sat, 24 Oct 2015 08:29:21 -0700 (PDT)
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
Subject: [PATCH 5/9] btrfs: remove btrfs_ioctl_clone(_range)
Date: Sun, 25 Oct 2015 07:17:12 +0800
Message-Id: <1445728636-10109-6-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1445728636-10109-1-git-send-email-tao.peng@primarydata.com>
References: <1445728636-10109-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

BTRFS_IOC_CLONE/BTRFS_IOC_CLONE_RANGE is now handled
by generic layer and goes through the .copy_file_range
method.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/btrfs/ioctl.c | 49 -------------------------------------------------
 1 file changed, 49 deletions(-)

diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index d3697e8..b568e24 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -3854,51 +3854,6 @@ ssize_t btrfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	return ret;
 }
 
-static noinline long btrfs_ioctl_clone(struct file *file, unsigned long srcfd,
-				       u64 off, u64 olen, u64 destoff)
-{
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
-}
-
 /*
  * there are many ways the trans_start and trans_end ioctls can lead
  * to deadlocks.  They should only be used by applications that
@@ -5438,10 +5393,6 @@ long btrfs_ioctl(struct file *file, unsigned int
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
-- 
1.8.3.1


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:53198 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754175AbbKMIn0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Nov 2015 03:43:26 -0500
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Peng Tao <tao.peng@primarydata.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] nfs: use btrfs ioctl defintions for clone
Date: Fri, 13 Nov 2015 09:38:48 +0100
Message-Id: <1447403929-13743-5-git-send-email-hch@lst.de>
In-Reply-To: <1447403929-13743-1-git-send-email-hch@lst.de>
References: <1447403929-13743-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFS CLONE_RANGE defintion was wrong and thus never worked.  Fix this
by simply using the btrfs ioctl defintion.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/nfs4file.c        | 10 ++++++----
 include/uapi/linux/nfs.h | 11 -----------
 2 files changed, 6 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 4b4dd89..5f63f2d 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -7,6 +7,7 @@
 #include <linux/file.h>
 #include <linux/falloc.h>
 #include <linux/nfs_fs.h>
+#include <uapi/linux/btrfs.h>	/* BTRFS_IOC_CLONE/BTRFS_IOC_CLONE_RANGE */
 #include "delegation.h"
 #include "internal.h"
 #include "iostat.h"
@@ -300,12 +301,13 @@ out_drop_write:
 
 static long nfs42_ioctl_clone_range(struct file *dst_file, void __user *argp)
 {
-	struct nfs_ioctl_clone_range_args args;
+	struct btrfs_ioctl_clone_range_args args;
 
 	if (copy_from_user(&args, argp, sizeof(args)))
 		return -EFAULT;
 
-	return nfs42_ioctl_clone(dst_file, args.src_fd, args.src_off, args.dst_off, args.count);
+	return nfs42_ioctl_clone(dst_file, args.src_fd, args.src_offset,
+				 args.dest_offset, args.src_length);
 }
 #else
 static long nfs42_ioctl_clone(struct file *dst_file, unsigned long srcfd,
@@ -325,9 +327,9 @@ long nfs4_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	void __user *argp = (void __user *)arg;
 
 	switch (cmd) {
-	case NFS_IOC_CLONE:
+	case BTRFS_IOC_CLONE:
 		return nfs42_ioctl_clone(file, arg, 0, 0, 0);
-	case NFS_IOC_CLONE_RANGE:
+	case BTRFS_IOC_CLONE_RANGE:
 		return nfs42_ioctl_clone_range(file, argp);
 	}
 
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


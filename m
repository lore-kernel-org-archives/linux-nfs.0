Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34530 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754043AbbIYK0X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Sep 2015 06:26:23 -0400
Received: by padhy16 with SMTP id hy16so102666175pad.1
        for <linux-nfs@vger.kernel.org>; Fri, 25 Sep 2015 03:26:23 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 6/6] nfs42: add NFS_IOC_CLONE_RANGE ioctl
Date: Sat, 26 Sep 2015 02:24:39 +0800
Message-Id: <1443205479-13563-7-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1443205479-13563-1-git-send-email-tao.peng@primarydata.com>
References: <1443205479-13563-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It follows btrfs BTRFS_IOC_CLONE_RANGE lead on ioctl number and
arguments.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/nfs4file.c        | 14 ++++++++++++++
 include/uapi/linux/nfs.h |  9 ++++++++-
 2 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 4f463dd..4384a1d 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -288,14 +288,28 @@ out_drop_write:
 	mnt_drop_write_file(dst_file);
 	return ret;
 }
+
+static long nfs42_ioctl_clone_range(struct file *dst_file, void __user *argp)
+{
+	struct nfs_ioctl_clone_range_args args;
+
+	if (copy_from_user(&args, argp, sizeof(args)))
+		return -EFAULT;
+
+	return nfs42_ioctl_clone(dst_file, args.src_fd, args.src_off, args.dst_off, args.count);
+}
 #endif /* CONFIG_NFS_V4_2 */
 
 long nfs4_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 {
+	void __user *argp = (void __user *)arg;
+
 	switch (cmd) {
 #ifdef CONFIG_NFS_V4_2
 	case NFS_IOC_CLONE:
 		return nfs42_ioctl_clone(file, arg, 0, 0, 0);
+	case NFS_IOC_CLONE_RANGE:
+		return nfs42_ioctl_clone_range(file, argp);
 #endif
 	}
 
diff --git a/include/uapi/linux/nfs.h b/include/uapi/linux/nfs.h
index d85748d..c6b86cc 100644
--- a/include/uapi/linux/nfs.h
+++ b/include/uapi/linux/nfs.h
@@ -33,7 +33,14 @@
 
 /* NFS ioctls */
 /* Let's follow btrfs lead on CLONE to avoid messing userspace */
-#define NFS_IOC_CLONE	_IOW(0x94, 9, int)
+#define NFS_IOC_CLONE		_IOW(0x94, 9, int)
+#define NFS_IOC_CLONE_RANGE	_IOW(0x94, 13, int)
+
+struct nfs_ioctl_clone_range_args {
+	__s64 src_fd;
+	__u64 src_off, count;
+	__u64 dst_off;
+};
 
 /*
  * NFS stats. The good thing with these values is that NFSv3 errors are
-- 
1.8.3.1


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33551 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451AbbGMJHf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 05:07:35 -0400
Received: by padck2 with SMTP id ck2so39614322pad.0
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2015 02:07:34 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH v2 8/8] nfs42: add NFS_IOC_CLONE_RANGE ioctl
Date: Mon, 13 Jul 2015 17:06:08 +0800
Message-Id: <1436778368-65447-9-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1436778368-65447-1-git-send-email-tao.peng@primarydata.com>
References: <1436778368-65447-1-git-send-email-tao.peng@primarydata.com>
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
index e450a5f..f37b74c 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -262,14 +262,28 @@ out_drop_write:
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


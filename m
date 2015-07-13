Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35793 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038AbbGMFvh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 01:51:37 -0400
Received: by pactm7 with SMTP id tm7so201356988pac.2
        for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2015 22:51:36 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 5/7] nfs42: add NFS_IOC_CLONE ioctl
Date: Mon, 13 Jul 2015 13:50:53 +0800
Message-Id: <1436766655-10696-6-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1436766655-10696-1-git-send-email-tao.peng@primarydata.com>
References: <1436766655-10696-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It can be called by user space to CLONE two files.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/nfs4file.c        | 102 +++++++++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/nfs.h |   4 ++
 2 files changed, 106 insertions(+)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index dcd39d4..dfa6620 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -4,6 +4,7 @@
  *  Copyright (C) 1992  Rick Sladkey
  */
 #include <linux/fs.h>
+#include <linux/file.h>
 #include <linux/falloc.h>
 #include <linux/nfs_fs.h>
 #include "internal.h"
@@ -166,8 +167,104 @@ static long nfs42_fallocate(struct file *filep, int mode, loff_t offset, loff_t
 		return nfs42_proc_deallocate(filep, offset, len);
 	return nfs42_proc_allocate(filep, offset, len);
 }
+
+static noinline long
+nfs42_ioctl_clone(struct file *dst_file, unsigned long srcfd,
+		  u64 src_off, u64 dst_off, u64 count)
+{
+	struct inode *dst_inode = file_inode(dst_file);
+	struct fd src_file;
+	struct inode *src_inode;
+	int ret;
+
+	/* dst file must be opened for writing */
+	if (!(dst_file->f_mode & FMODE_WRITE))
+		return -EINVAL;
+
+	ret = mnt_want_write_file(dst_file);
+	if (ret)
+		return ret;
+
+	src_file = fdget(srcfd);
+	if (!src_file.file) {
+		ret = -EBADF;
+		goto out_drop_write;
+	}
+
+	src_inode = file_inode(src_file.file);
+
+	/* src and dst must be different files */
+	ret = -EINVAL;
+	if (src_inode == dst_inode)
+		goto out_fput;
+
+	/* src file must be opened for reading */
+	if (!(src_file.file->f_mode & FMODE_READ))
+		goto out_fput;
+
+	/* src and dst must be regular files */
+	ret = -EISDIR;
+	if (!S_ISREG(src_inode->i_mode) || !S_ISREG(dst_inode->i_mode))
+		goto out_fput;
+
+	ret = -EXDEV;
+	if (src_file.file->f_path.mnt != dst_file->f_path.mnt ||
+	    src_inode->i_sb != dst_inode->i_sb)
+		goto out_fput;
+
+	/* XXX: do we lock at all? what if server needs CB_RECALL_LAYOUT? */
+	if (dst_inode < src_inode) {
+		mutex_lock_nested(&dst_inode->i_mutex, I_MUTEX_PARENT);
+		mutex_lock_nested(&src_inode->i_mutex, I_MUTEX_CHILD);
+	} else {
+		mutex_lock_nested(&src_inode->i_mutex, I_MUTEX_PARENT);
+		mutex_lock_nested(&dst_inode->i_mutex, I_MUTEX_CHILD);
+	}
+
+	/* flush all pending writes on both src and dst so that server
+	 * has the latest data */
+	ret = nfs_sync_inode(src_inode);
+	if (ret)
+		goto out_unlock;
+	ret = nfs_sync_inode(dst_inode);
+	if (ret)
+		goto out_unlock;
+
+	ret = nfs42_proc_clone(src_file.file, dst_file, src_off, dst_off, count);
+
+	/* truncate inode page cache of the dst range so that future reads can fetch
+	 * new data from server */
+	if (!ret)
+		truncate_inode_pages_range(&dst_inode->i_data, dst_off, dst_off + count - 1);
+
+out_unlock:
+	if (dst_inode < src_inode) {
+		mutex_unlock(&src_inode->i_mutex);
+		mutex_unlock(&dst_inode->i_mutex);
+	} else {
+		mutex_unlock(&dst_inode->i_mutex);
+		mutex_unlock(&src_inode->i_mutex);
+	}
+out_fput:
+	fdput(src_file);
+out_drop_write:
+	mnt_drop_write_file(dst_file);
+	return ret;
+}
 #endif /* CONFIG_NFS_V4_2 */
 
+long nfs4_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
+{
+	switch (cmd) {
+#ifdef CONFIG_NFS_V4_2
+	case NFS_IOC_CLONE:
+		return nfs42_ioctl_clone(file, arg, 0, 0, 0);
+#endif
+	}
+
+	return -ENOTTY;
+}
+
 const struct file_operations nfs4_file_operations = {
 #ifdef CONFIG_NFS_V4_2
 	.llseek		= nfs4_file_llseek,
@@ -190,4 +287,9 @@ const struct file_operations nfs4_file_operations = {
 #endif /* CONFIG_NFS_V4_2 */
 	.check_flags	= nfs_check_flags,
 	.setlease	= simple_nosetlease,
+#ifdef CONFIG_COMPAT
+	.unlocked_ioctl = nfs4_ioctl,
+#else
+	.compat_ioctl	= nfs4_ioctl,
+#endif /* CONFIG_COMPAT */
 };
diff --git a/include/uapi/linux/nfs.h b/include/uapi/linux/nfs.h
index 5199a36..fd48708 100644
--- a/include/uapi/linux/nfs.h
+++ b/include/uapi/linux/nfs.h
@@ -31,6 +31,10 @@
 
 #define NFS_PIPE_DIRNAME "nfs"
 
+/* NFS ioctl */
+#define NFS_IOCTL_MAGIC 'n'
+#define NFS_IOC_CLONE	_IOW(NFS_IOCTL_MAGIC, 1, int)
+
 /*
  * NFS stats. The good thing with these values is that NFSv3 errors are
  * a superset of NFSv2 errors (with the exception of NFSERR_WFLUSH which
-- 
1.8.3.1


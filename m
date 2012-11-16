Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:25413 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750804Ab2KPCbe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Nov 2012 21:31:34 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH 1/4] NFS: Add an ioctl to allow applications limited control over caching
Date: Thu, 15 Nov 2012 21:31:25 -0500
Message-Id: <1353033088-47163-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add an ioctl that allows an application to force the NFS client to
revalidate the attributes and/or data for a regular file, or
directory.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/Makefile   |  2 +-
 fs/nfs/dir.c      |  4 +++
 fs/nfs/file.c     |  4 +++
 fs/nfs/internal.h |  3 ++
 fs/nfs/ioctl.c    | 86 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/ioctl.h    | 35 ++++++++++++++++++++++
 fs/nfs/nfs4file.c |  4 +++
 7 files changed, 137 insertions(+), 1 deletion(-)
 create mode 100644 fs/nfs/ioctl.c
 create mode 100644 fs/nfs/ioctl.h

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index b7db608..581db7a 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -7,7 +7,7 @@ obj-$(CONFIG_NFS_FS) += nfs.o
 nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o \
 			   direct.o pagelist.o read.o symlink.o unlink.o \
 			   write.o namespace.o mount_clnt.o \
-			   dns_resolve.o cache_lib.o
+			   dns_resolve.o cache_lib.o ioctl.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
 nfs-$(CONFIG_SYSCTL)	+= sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ce8cb92..10ad886 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -58,6 +58,10 @@ const struct file_operations nfs_dir_operations = {
 	.open		= nfs_opendir,
 	.release	= nfs_closedir,
 	.fsync		= nfs_fsync_dir,
+	.unlocked_ioctl = nfs_ioctl,
+#ifdef CONFIG_COMPAT
+	.compat_ioctl	= nfs_ioctl,
+#endif
 };
 
 const struct address_space_operations nfs_dir_aops = {
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 582bb88..deefa62 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -925,5 +925,9 @@ const struct file_operations nfs_file_operations = {
 	.splice_write	= nfs_file_splice_write,
 	.check_flags	= nfs_check_flags,
 	.setlease	= nfs_setlease,
+	.unlocked_ioctl = nfs_ioctl,
+#ifdef CONFIG_COMPAT
+	.compat_ioctl	= nfs_ioctl,
+#endif
 };
 EXPORT_SYMBOL_GPL(nfs_file_operations);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index e1827b0..4b425bd 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -481,6 +481,9 @@ extern int nfs41_walk_client_list(struct nfs_client *clp,
 				struct nfs_client **result,
 				struct rpc_cred *cred);
 
+/* ioctl.c */
+extern long nfs_ioctl(struct file *filp, unsigned int cmd, unsigned long arg);
+
 /*
  * Determine the device name as a string
  */
diff --git a/fs/nfs/ioctl.c b/fs/nfs/ioctl.c
new file mode 100644
index 0000000..9da5f7d
--- /dev/null
+++ b/fs/nfs/ioctl.c
@@ -0,0 +1,86 @@
+/*
+ * linux/fs/nfs/ioctl.c
+ *
+ * Copyright (C) 2012 Trond Myklebust <Trond.Myklebust@netapp.com>
+ *
+ * nfs ioctl implementation
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/fs.h>
+#include <linux/nfs_fs.h>
+#include "internal.h"
+#include "ioctl.h"
+
+static long nfs_ioctl_cache_revalidate(struct file *filp, bool metadata, bool data)
+{
+	struct inode *inode = filp->f_path.dentry->d_inode;
+	struct nfs_inode *nfsi = NFS_I(inode);
+	umode_t mode = inode->i_mode;
+	unsigned long invalid = 0;
+	long ret = -EINVAL;
+
+	if (metadata)
+		invalid |= NFS_INO_INVALID_ATTR
+			| NFS_INO_INVALID_ACCESS
+			| NFS_INO_INVALID_ACL;
+	if (data)
+		invalid |= NFS_INO_INVALID_DATA;
+
+	switch (mode & S_IFMT) {
+	default:
+		goto out;
+	case S_IFDIR:
+		spin_lock(&inode->i_lock);
+		if (data)
+			nfsi->cache_change_attribute++;
+		nfsi->cache_validity |= invalid;
+		spin_unlock(&inode->i_lock);
+		break;
+	case S_IFREG:
+		vfs_fsync(filp, 1);
+		if (data)
+			invalid |= NFS_INO_REVAL_PAGECACHE;
+	case S_IFLNK:
+		spin_lock(&inode->i_lock);
+		nfsi->cache_validity |= invalid;
+		spin_unlock(&inode->i_lock);
+	}
+	ret = nfs_revalidate_inode(NFS_SERVER(inode), inode);
+	if (ret == 0)
+		ret = nfs_revalidate_mapping(inode, filp->f_mapping);
+
+out:
+	return ret;
+}
+
+static long nfs_ioctl_cachectl(struct file *filp, struct nfs_cachectl __user *argp)
+{
+	u64 cmd;
+
+	if (!(filp->f_mode & (FMODE_READ|FMODE_WRITE)))
+		return -EBADF;
+	if (get_user(cmd, &argp->cmd))
+		return -EFAULT;
+	switch (cmd) {
+	case NFS_CACHECTL_REVALIDATE_ALL:
+		return nfs_ioctl_cache_revalidate(filp, true, true);
+	case NFS_CACHECTL_REVALIDATE_METADATA:
+		return nfs_ioctl_cache_revalidate(filp, true, false);
+	case NFS_CACHECTL_REVALIDATE_DATA:
+		return nfs_ioctl_cache_revalidate(filp, false, true);
+	}
+	return -EINVAL;
+}
+
+long nfs_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
+{
+	void __user *argp = (void __user *)arg;
+
+	switch (cmd) {
+	case NFS_IOC_CACHECTL:
+		return nfs_ioctl_cachectl(filp, argp);
+	}
+	return -ENOTTY;
+}
diff --git a/fs/nfs/ioctl.h b/fs/nfs/ioctl.h
new file mode 100644
index 0000000..cf79f0d
--- /dev/null
+++ b/fs/nfs/ioctl.h
@@ -0,0 +1,35 @@
+/*
+ * linux/fs/nfs/ioctl.h
+ *
+ * Copyright (C) 2012 Trond Myklebust <Trond.Myklebust@netapp.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License v2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ *
+ * nfs ioctl definitions
+ *
+ */
+
+#include <uapi/linux/ioctl.h>
+
+/* Cache revalidation modes */
+#define NFS_CACHECTL_REVALIDATE_ALL		1
+#define NFS_CACHECTL_REVALIDATE_METADATA	2
+#define NFS_CACHECTL_REVALIDATE_DATA		3
+
+struct nfs_cachectl {
+	u64 cmd;
+};
+
+#define NFS_IOC_CACHECTL	_IOW('N', 1, struct nfs_cachectl)
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index e769930..b221690 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -133,4 +133,8 @@ const struct file_operations nfs4_file_operations = {
 	.splice_write	= nfs_file_splice_write,
 	.check_flags	= nfs_check_flags,
 	.setlease	= nfs_setlease,
+	.unlocked_ioctl = nfs_ioctl,
+#ifdef CONFIG_COMPAT
+	.compat_ioctl	= nfs_ioctl,
+#endif
 };
-- 
1.7.11.7


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:47039 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932765Ab2AMULd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:33 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 33/44] NFS: Move over the v4_file_operations structure
Date: Fri, 13 Jan 2012 15:10:42 -0500
Message-Id: <1326485453-1350-34-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

So it can be used by the module.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Makefile    |    2 +-
 fs/nfs/file.c      |   32 --------------------------------
 fs/nfs/nfs4/file.c |   38 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 39 insertions(+), 33 deletions(-)
 create mode 100644 fs/nfs/nfs4/file.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 94d8631..041f947 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -14,7 +14,7 @@ nfs-$(CONFIG_NFS_V4)	+= nfs4/proc.o nfs4/xdr.o nfs4/state.o nfs4/renewd.o \
 			   nfs4/callback.o nfs4/callback_xdr.o \
 			   nfs4/callback_proc.o nfs4/namespace.o \
 			   nfs4/client.o nfs4/module.o nfs4/sysctl.o \
-			   nfs4/getroot.o nfs4/inode.o
+			   nfs4/getroot.o nfs4/inode.o nfs4/file.o
 nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index a691996..2728f4e 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -844,35 +844,3 @@ int nfs_setlease(struct file *file, long arg, struct file_lock **fl)
 	return -EINVAL;
 }
 EXPORT_SYMBOL_GPL(nfs_setlease);
-
-#ifdef CONFIG_NFS_V4
-static int
-nfs4_file_open(struct inode *inode, struct file *filp)
-{
-	/*
-	 * NFSv4 opens are handled in d_lookup and d_revalidate. If we get to
-	 * this point, then something is very wrong
-	 */
-	dprintk("NFS: %s called! inode=%p filp=%p\n", __func__, inode, filp);
-	return -ENOTDIR;
-}
-
-const struct file_operations nfs4_file_operations = {
-	.llseek		= nfs_file_llseek,
-	.read		= do_sync_read,
-	.write		= do_sync_write,
-	.aio_read	= nfs_file_read,
-	.aio_write	= nfs_file_write,
-	.mmap		= nfs_file_mmap,
-	.open		= nfs4_file_open,
-	.flush		= nfs_file_flush,
-	.release	= nfs_file_release,
-	.fsync		= nfs_file_fsync,
-	.lock		= nfs_lock,
-	.flock		= nfs_flock,
-	.splice_read	= nfs_file_splice_read,
-	.splice_write	= nfs_file_splice_write,
-	.check_flags	= nfs_check_flags,
-	.setlease	= nfs_setlease,
-};
-#endif /* CONFIG_NFS_V4 */
diff --git a/fs/nfs/nfs4/file.c b/fs/nfs/nfs4/file.c
new file mode 100644
index 0000000..6b6a4c8
--- /dev/null
+++ b/fs/nfs/nfs4/file.c
@@ -0,0 +1,38 @@
+/*
+ *  Copyright (C) 1992  Rick Sladkey
+ */
+#include <linux/fs.h>
+#include <linux/nfs_fs.h>
+#include "../nfs.h"
+
+#define NFSDBG_FACILITY		NFSDBG_FILE
+
+static int
+nfs4_file_open(struct inode *inode, struct file *filp)
+{
+	/*
+	 * NFSv4 opens are handled in d_lookup and d_revalidate. If we get to
+	 * this point, then something is very wrong
+	 */
+	dprintk("NFS: %s called! inode=%p filp=%p\n", __func__, inode, filp);
+	return -ENOTDIR;
+}
+
+const struct file_operations nfs4_file_operations = {
+	.llseek		= nfs_file_llseek,
+	.read		= do_sync_read,
+	.write		= do_sync_write,
+	.aio_read	= nfs_file_read,
+	.aio_write	= nfs_file_write,
+	.mmap		= nfs_file_mmap,
+	.open		= nfs4_file_open,
+	.flush		= nfs_file_flush,
+	.release	= nfs_file_release,
+	.fsync		= nfs_file_fsync,
+	.lock		= nfs_lock,
+	.flock		= nfs_flock,
+	.splice_read	= nfs_file_splice_read,
+	.splice_write	= nfs_file_splice_write,
+	.check_flags	= nfs_check_flags,
+	.setlease	= nfs_setlease,
+};
-- 
1.7.8.3


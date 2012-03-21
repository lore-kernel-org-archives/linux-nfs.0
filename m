Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31911 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759043Ab2CUPVW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 11:21:22 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 18/23] NFS: Create a v4-specific fsync function
Date: Wed, 21 Mar 2012 11:20:48 -0400
Message-Id: <1332343253-24970-19-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
References: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

NFS v4 needs its own fsync function for the pnfs layoutcommit.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Makefile   |    2 +-
 fs/nfs/file.c     |   86 +++++++++++++++++++----------------------------------
 fs/nfs/nfs.h      |   17 +++++++++++
 fs/nfs/nfs4file.c |   57 +++++++++++++++++++++++++++++++++++
 fs/nfs/write.c    |    1 -
 5 files changed, 105 insertions(+), 58 deletions(-)
 create mode 100644 fs/nfs/nfs4file.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 8028e09..85aafee 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -13,7 +13,7 @@ nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   nfs4super.o delegation.o idmap.o \
 			   callback.o callback_xdr.o callback_proc.o \
 			   nfs4namespace.o nfs4sysctl.o nfs4client.o \
-			   nfs4getroot.o
+			   nfs4getroot.o nfs4file.o
 nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index c678c00..d169c2b 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -37,7 +37,6 @@
 #include "internal.h"
 #include "iostat.h"
 #include "fscache.h"
-#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_FILE
 
@@ -55,7 +54,7 @@ EXPORT_SYMBOL_GPL(nfs_file_inode_operations);
 # define IS_SWAPFILE(inode)	(0)
 #endif
 
-static int nfs_check_flags(int flags)
+int nfs_check_flags(int flags)
 {
 	if ((flags & (O_APPEND | O_DIRECT)) == (O_APPEND | O_DIRECT))
 		return -EINVAL;
@@ -84,7 +83,7 @@ nfs_file_open(struct inode *inode, struct file *filp)
 	return res;
 }
 
-static int
+int
 nfs_file_release(struct inode *inode, struct file *filp)
 {
 	dprintk("NFS: release(%s/%s)\n",
@@ -126,7 +125,7 @@ force_reval:
 	return __nfs_revalidate_inode(server, inode);
 }
 
-static loff_t nfs_file_llseek(struct file *filp, loff_t offset, int origin)
+loff_t nfs_file_llseek(struct file *filp, loff_t offset, int origin)
 {
 	dprintk("NFS: llseek file(%s/%s, %lld, %d)\n",
 			filp->f_path.dentry->d_parent->d_name.name,
@@ -151,7 +150,7 @@ static loff_t nfs_file_llseek(struct file *filp, loff_t offset, int origin)
 /*
  * Flush all dirty pages, and check for write errors.
  */
-static int
+int
 nfs_file_flush(struct file *file, fl_owner_t id)
 {
 	struct dentry	*dentry = file->f_path.dentry;
@@ -169,7 +168,7 @@ nfs_file_flush(struct file *file, fl_owner_t id)
 	return vfs_fsync(file, 0);
 }
 
-static ssize_t
+ssize_t
 nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
 		unsigned long nr_segs, loff_t pos)
 {
@@ -193,7 +192,7 @@ nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
 	return result;
 }
 
-static ssize_t
+ssize_t
 nfs_file_splice_read(struct file *filp, loff_t *ppos,
 		     struct pipe_inode_info *pipe, size_t count,
 		     unsigned int flags)
@@ -215,7 +214,7 @@ nfs_file_splice_read(struct file *filp, loff_t *ppos,
 	return res;
 }
 
-static int
+int
 nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
 {
 	struct dentry *dentry = file->f_path.dentry;
@@ -248,8 +247,8 @@ nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
  * nfs_file_write() that a write error occurred, and hence cause it to
  * fall back to doing a synchronous write.
  */
-static int
-nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
+int
+nfs_file_fsync_commit(struct file *file, loff_t start, loff_t end, int datasync)
 {
 	struct dentry *dentry = file->f_path.dentry;
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
@@ -261,9 +260,6 @@ nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 			dentry->d_parent->d_name.name, dentry->d_name.name,
 			datasync);
 
-	ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
-	mutex_lock(&inode->i_mutex);
-
 	nfs_inc_stats(inode, NFSIOS_VFSFSYNC);
 	have_error = test_and_clear_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
 	status = nfs_commit_inode(inode, FLUSH_SYNC);
@@ -274,10 +270,20 @@ nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 		ret = xchg(&ctx->error, 0);
 	if (!ret && status < 0)
 		ret = status;
-	if (!ret && !datasync)
-		/* application has asked for meta-data sync */
-		ret = pnfs_layoutcommit_inode(inode, true);
+	return ret;
+}
+
+static int
+nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
+{
+	int ret;
+	struct inode *inode = file->f_path.dentry->d_inode;
+
+	ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
+	mutex_lock(&inode->i_mutex);
+	ret = nfs_file_fsync_commit(file, start, end, datasync);
 	mutex_unlock(&inode->i_mutex);
+
 	return ret;
 }
 
@@ -555,8 +561,8 @@ static int nfs_need_sync_write(struct file *filp, struct inode *inode)
 	return 0;
 }
 
-static ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
-				unsigned long nr_segs, loff_t pos)
+ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
+		       unsigned long nr_segs, loff_t pos)
 {
 	struct dentry * dentry = iocb->ki_filp->f_path.dentry;
 	struct inode * inode = dentry->d_inode;
@@ -607,9 +613,9 @@ out_swapfile:
 	goto out;
 }
 
-static ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
-				     struct file *filp, loff_t *ppos,
-				     size_t count, unsigned int flags)
+ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
+			      struct file *filp, loff_t *ppos,
+			      size_t count, unsigned int flags)
 {
 	struct dentry *dentry = filp->f_path.dentry;
 	struct inode *inode = dentry->d_inode;
@@ -761,7 +767,7 @@ out:
 /*
  * Lock a (portion of) a file
  */
-static int nfs_lock(struct file *filp, int cmd, struct file_lock *fl)
+int nfs_lock(struct file *filp, int cmd, struct file_lock *fl)
 {
 	struct inode *inode = filp->f_mapping->host;
 	int ret = -ENOLCK;
@@ -801,7 +807,7 @@ out_err:
 /*
  * Lock a (portion of) a file
  */
-static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
+int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
 {
 	struct inode *inode = filp->f_mapping->host;
 	int is_local = 0;
@@ -831,7 +837,7 @@ static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
  * There is no protocol support for leases, so we have no way to implement
  * them correctly in the face of opens by other clients.
  */
-static int nfs_setlease(struct file *file, long arg, struct file_lock **fl)
+int nfs_setlease(struct file *file, long arg, struct file_lock **fl)
 {
 	dprintk("NFS: setlease(%s/%s, arg=%ld)\n",
 			file->f_path.dentry->d_parent->d_name.name,
@@ -858,35 +864,3 @@ const struct file_operations nfs_file_operations = {
 	.setlease	= nfs_setlease,
 };
 EXPORT_SYMBOL_GPL(nfs_file_operations);
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
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index fa0b531..b5771d5 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -85,6 +85,23 @@ int nfs_link(struct dentry *, struct inode *, struct dentry *);
 int nfs_mknod(struct inode *, struct dentry *, umode_t, dev_t);
 int nfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *);
 
+/* Exported in file.c */
+int nfs_file_fsync_commit(struct file *, loff_t, loff_t, int);
+loff_t nfs_file_llseek(struct file *, loff_t, int);
+ssize_t nfs_file_read(struct kiocb *, const struct iovec *, unsigned long, loff_t);
+ssize_t nfs_file_write(struct kiocb *, const struct iovec *, unsigned long, loff_t);
+int nfs_file_mmap(struct file *, struct vm_area_struct *);
+int nfs_file_flush(struct file *, fl_owner_t);
+int nfs_file_release(struct inode *, struct file *);
+int nfs_lock(struct file *, int, struct file_lock *);
+int nfs_flock(struct file *, int, struct file_lock *);
+ssize_t nfs_file_splice_read(struct file *, loff_t *, struct pipe_inode_info *,
+			     size_t, unsigned int);
+ssize_t nfs_file_splice_write(struct pipe_inode_info *, struct file *, loff_t *,
+			      size_t, unsigned int);
+int nfs_check_flags(int);
+int nfs_setlease(struct file *, long, struct file_lock **);
+
 /* Exported in getroot.c */
 int nfs_superblock_set_dummy_root(struct super_block *, struct inode *);
 
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
new file mode 100644
index 0000000..6c52345
--- /dev/null
+++ b/fs/nfs/nfs4file.c
@@ -0,0 +1,57 @@
+/*
+ * Copyright (c) 2012 Netapp, Inc. All rights reserved.
+ */
+#include <linux/fs.h>
+#include <linux/nfs_fs.h>
+
+#include "nfs.h"
+#include "pnfs.h"
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
+static int
+nfs4_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
+{
+	int ret;
+	struct inode *inode = file->f_path.dentry->d_inode;
+
+	ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
+	mutex_lock(&inode->i_mutex);
+	ret = nfs_file_fsync_commit(file, start, end, datasync);
+	if (!ret && !datasync)
+		/* application has asked for meta-data sync */
+		ret = pnfs_layoutcommit_inode(inode, true);
+	mutex_unlock(&inode->i_mutex);
+
+	return ret;
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
+	.fsync		= nfs4_file_fsync,
+	.lock		= nfs_lock,
+	.flock		= nfs_flock,
+	.splice_read	= nfs_file_splice_read,
+	.splice_write	= nfs_file_splice_write,
+	.check_flags	= nfs_check_flags,
+	.setlease	= nfs_setlease,
+};
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 5e30b57..e4a72d6 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -26,7 +26,6 @@
 
 #include "internal.h"
 #include "iostat.h"
-#include "nfs4_fs.h"
 #include "fscache.h"
 #include "pnfs.h"
 #include "nfs.h"
-- 
1.7.9.4


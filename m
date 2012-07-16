Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:2020 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751888Ab2GPUj2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jul 2012 16:39:28 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 06/12] NFS: Split out NFS v4 file operations
Date: Mon, 16 Jul 2012 16:39:15 -0400
Message-Id: <1342471161-22452-7-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1342471161-22452-1-git-send-email-bjschuma@netapp.com>
References: <1342471161-22452-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This patch moves the NFS v4 file functions into a new file that is only
compiled when CONFIG_NFS_V4 is enabled.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Makefile   |   2 +-
 fs/nfs/file.c     | 151 ++++++------------------------------------------------
 fs/nfs/internal.h |  17 ++++++
 fs/nfs/nfs4file.c | 126 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 160 insertions(+), 136 deletions(-)
 create mode 100644 fs/nfs/nfs4file.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 4a78e76..e882a38 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -13,7 +13,7 @@ nfs-$(CONFIG_NFS_V2)	+= proc.o nfs2xdr.o
 nfs-$(CONFIG_NFS_V3)	+= nfs3proc.o nfs3xdr.o
 nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3acl.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
-			   nfs4super.o delegation.o idmap.o \
+			   nfs4super.o nfs4file.o delegation.o idmap.o \
 			   callback.o callback_xdr.o callback_proc.o \
 			   nfs4namespace.o
 nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 7623917..70d124a 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -35,7 +35,6 @@
 #include "internal.h"
 #include "iostat.h"
 #include "fscache.h"
-#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_FILE
 
@@ -46,7 +45,7 @@ static const struct vm_operations_struct nfs_file_vm_ops;
 # define IS_SWAPFILE(inode)	(0)
 #endif
 
-static int nfs_check_flags(int flags)
+int nfs_check_flags(int flags)
 {
 	if ((flags & (O_APPEND | O_DIRECT)) == (O_APPEND | O_DIRECT))
 		return -EINVAL;
@@ -75,7 +74,7 @@ nfs_file_open(struct inode *inode, struct file *filp)
 	return res;
 }
 
-static int
+int
 nfs_file_release(struct inode *inode, struct file *filp)
 {
 	dprintk("NFS: release(%s/%s)\n",
@@ -117,7 +116,7 @@ force_reval:
 	return __nfs_revalidate_inode(server, inode);
 }
 
-static loff_t nfs_file_llseek(struct file *filp, loff_t offset, int origin)
+loff_t nfs_file_llseek(struct file *filp, loff_t offset, int origin)
 {
 	dprintk("NFS: llseek file(%s/%s, %lld, %d)\n",
 			filp->f_path.dentry->d_parent->d_name.name,
@@ -142,7 +141,7 @@ static loff_t nfs_file_llseek(struct file *filp, loff_t offset, int origin)
 /*
  * Flush all dirty pages, and check for write errors.
  */
-static int
+int
 nfs_file_flush(struct file *file, fl_owner_t id)
 {
 	struct dentry	*dentry = file->f_path.dentry;
@@ -167,7 +166,7 @@ nfs_file_flush(struct file *file, fl_owner_t id)
 	return vfs_fsync(file, 0);
 }
 
-static ssize_t
+ssize_t
 nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
 		unsigned long nr_segs, loff_t pos)
 {
@@ -191,7 +190,7 @@ nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
 	return result;
 }
 
-static ssize_t
+ssize_t
 nfs_file_splice_read(struct file *filp, loff_t *ppos,
 		     struct pipe_inode_info *pipe, size_t count,
 		     unsigned int flags)
@@ -213,7 +212,7 @@ nfs_file_splice_read(struct file *filp, loff_t *ppos,
 	return res;
 }
 
-static int
+int
 nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
 {
 	struct dentry *dentry = file->f_path.dentry;
@@ -246,7 +245,7 @@ nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
  * nfs_file_write() that a write error occurred, and hence cause it to
  * fall back to doing a synchronous write.
  */
-static int
+int
 nfs_file_fsync_commit(struct file *file, loff_t start, loff_t end, int datasync)
 {
 	struct dentry *dentry = file->f_path.dentry;
@@ -561,8 +560,8 @@ static int nfs_need_sync_write(struct file *filp, struct inode *inode)
 	return 0;
 }
 
-static ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
-				unsigned long nr_segs, loff_t pos)
+ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
+		       unsigned long nr_segs, loff_t pos)
 {
 	struct dentry * dentry = iocb->ki_filp->f_path.dentry;
 	struct inode * inode = dentry->d_inode;
@@ -613,9 +612,9 @@ out_swapfile:
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
@@ -767,7 +766,7 @@ out:
 /*
  * Lock a (portion of) a file
  */
-static int nfs_lock(struct file *filp, int cmd, struct file_lock *fl)
+int nfs_lock(struct file *filp, int cmd, struct file_lock *fl)
 {
 	struct inode *inode = filp->f_mapping->host;
 	int ret = -ENOLCK;
@@ -807,7 +806,7 @@ out_err:
 /*
  * Lock a (portion of) a file
  */
-static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
+int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
 {
 	struct inode *inode = filp->f_mapping->host;
 	int is_local = 0;
@@ -837,7 +836,7 @@ static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
  * There is no protocol support for leases, so we have no way to implement
  * them correctly in the face of opens by other clients.
  */
-static int nfs_setlease(struct file *file, long arg, struct file_lock **fl)
+int nfs_setlease(struct file *file, long arg, struct file_lock **fl)
 {
 	dprintk("NFS: setlease(%s/%s, arg=%ld)\n",
 			file->f_path.dentry->d_parent->d_name.name,
@@ -863,121 +862,3 @@ const struct file_operations nfs_file_operations = {
 	.check_flags	= nfs_check_flags,
 	.setlease	= nfs_setlease,
 };
-
-#ifdef CONFIG_NFS_V4
-static int
-nfs4_file_open(struct inode *inode, struct file *filp)
-{
-	struct nfs_open_context *ctx;
-	struct dentry *dentry = filp->f_path.dentry;
-	struct dentry *parent = NULL;
-	struct inode *dir;
-	unsigned openflags = filp->f_flags;
-	struct iattr attr;
-	int err;
-
-	BUG_ON(inode != dentry->d_inode);
-	/*
-	 * If no cached dentry exists or if it's negative, NFSv4 handled the
-	 * opens in ->lookup() or ->create().
-	 *
-	 * We only get this far for a cached positive dentry.  We skipped
-	 * revalidation, so handle it here by dropping the dentry and returning
-	 * -EOPENSTALE.  The VFS will retry the lookup/create/open.
-	 */
-
-	dprintk("NFS: open file(%s/%s)\n",
-		dentry->d_parent->d_name.name,
-		dentry->d_name.name);
-
-	if ((openflags & O_ACCMODE) == 3)
-		openflags--;
-
-	/* We can't create new files here */
-	openflags &= ~(O_CREAT|O_EXCL);
-
-	parent = dget_parent(dentry);
-	dir = parent->d_inode;
-
-	ctx = alloc_nfs_open_context(filp->f_path.dentry, filp->f_mode);
-	err = PTR_ERR(ctx);
-	if (IS_ERR(ctx))
-		goto out;
-
-	attr.ia_valid = ATTR_OPEN;
-	if (openflags & O_TRUNC) {
-		attr.ia_valid |= ATTR_SIZE;
-		attr.ia_size = 0;
-		nfs_wb_all(inode);
-	}
-
-	inode = NFS_PROTO(dir)->open_context(dir, ctx, openflags, &attr);
-	if (IS_ERR(inode)) {
-		err = PTR_ERR(inode);
-		switch (err) {
-		case -EPERM:
-		case -EACCES:
-		case -EDQUOT:
-		case -ENOSPC:
-		case -EROFS:
-			goto out_put_ctx;
-		default:
-			goto out_drop;
-		}
-	}
-	iput(inode);
-	if (inode != dentry->d_inode)
-		goto out_drop;
-
-	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
-	nfs_file_set_open_context(filp, ctx);
-	err = 0;
-
-out_put_ctx:
-	put_nfs_open_context(ctx);
-out:
-	dput(parent);
-	return err;
-
-out_drop:
-	d_drop(dentry);
-	err = -EOPENSTALE;
-	goto out_put_ctx;
-}
-
-static int
-nfs4_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
-{
-	int ret;
-	struct inode *inode = file->f_path.dentry->d_inode;
-
-	ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
-	mutex_lock(&inode->i_mutex);
-	ret = nfs_file_fsync_commit(file, start, end, datasync);
-	if (!ret && !datasync)
-		/* application has asked for meta-data sync */
-		ret = pnfs_layoutcommit_inode(inode, true);
-	mutex_unlock(&inode->i_mutex);
-
-	return ret;
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
-	.fsync		= nfs4_file_fsync,
-	.lock		= nfs_lock,
-	.flock		= nfs_flock,
-	.splice_read	= nfs_file_splice_read,
-	.splice_write	= nfs_file_splice_write,
-	.check_flags	= nfs_check_flags,
-	.setlease	= nfs_setlease,
-};
-#endif /* CONFIG_NFS_V4 */
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 35a8ffe..ca7200a 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -257,6 +257,23 @@ int nfs_link(struct dentry *, struct inode *, struct dentry *);
 int nfs_mknod(struct inode *, struct dentry *, umode_t, dev_t);
 int nfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *);
 
+/* file.c */
+int nfs_file_fsync_commit(struct file *, loff_t, loff_t, int);
+loff_t nfs_file_llseek(struct file *, loff_t, int);
+int nfs_file_flush(struct file *, fl_owner_t);
+ssize_t nfs_file_read(struct kiocb *, const struct iovec *, unsigned long, loff_t);
+ssize_t nfs_file_splice_read(struct file *, loff_t *, struct pipe_inode_info *,
+			     size_t, unsigned int);
+int nfs_file_mmap(struct file *, struct vm_area_struct *);
+ssize_t nfs_file_write(struct kiocb *, const struct iovec *, unsigned long, loff_t);
+int nfs_file_release(struct inode *, struct file *);
+int nfs_lock(struct file *, int, struct file_lock *);
+int nfs_flock(struct file *, int, struct file_lock *);
+ssize_t nfs_file_splice_write(struct pipe_inode_info *, struct file *, loff_t *,
+			      size_t, unsigned int);
+int nfs_check_flags(int);
+int nfs_setlease(struct file *, long, struct file_lock **);
+
 /* inode.c */
 extern struct workqueue_struct *nfsiod_workqueue;
 extern struct inode *nfs_alloc_inode(struct super_block *sb);
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
new file mode 100644
index 0000000..acb65e7
--- /dev/null
+++ b/fs/nfs/nfs4file.c
@@ -0,0 +1,126 @@
+/*
+ *  linux/fs/nfs/file.c
+ *
+ *  Copyright (C) 1992  Rick Sladkey
+ */
+#include <linux/nfs_fs.h>
+#include "internal.h"
+#include "pnfs.h"
+
+#define NFSDBG_FACILITY		NFSDBG_FILE
+
+static int
+nfs4_file_open(struct inode *inode, struct file *filp)
+{
+	struct nfs_open_context *ctx;
+	struct dentry *dentry = filp->f_path.dentry;
+	struct dentry *parent = NULL;
+	struct inode *dir;
+	unsigned openflags = filp->f_flags;
+	struct iattr attr;
+	int err;
+
+	BUG_ON(inode != dentry->d_inode);
+	/*
+	 * If no cached dentry exists or if it's negative, NFSv4 handled the
+	 * opens in ->lookup() or ->create().
+	 *
+	 * We only get this far for a cached positive dentry.  We skipped
+	 * revalidation, so handle it here by dropping the dentry and returning
+	 * -EOPENSTALE.  The VFS will retry the lookup/create/open.
+	 */
+
+	dprintk("NFS: open file(%s/%s)\n",
+		dentry->d_parent->d_name.name,
+		dentry->d_name.name);
+
+	if ((openflags & O_ACCMODE) == 3)
+		openflags--;
+
+	/* We can't create new files here */
+	openflags &= ~(O_CREAT|O_EXCL);
+
+	parent = dget_parent(dentry);
+	dir = parent->d_inode;
+
+	ctx = alloc_nfs_open_context(filp->f_path.dentry, filp->f_mode);
+	err = PTR_ERR(ctx);
+	if (IS_ERR(ctx))
+		goto out;
+
+	attr.ia_valid = ATTR_OPEN;
+	if (openflags & O_TRUNC) {
+		attr.ia_valid |= ATTR_SIZE;
+		attr.ia_size = 0;
+		nfs_wb_all(inode);
+	}
+
+	inode = NFS_PROTO(dir)->open_context(dir, ctx, openflags, &attr);
+	if (IS_ERR(inode)) {
+		err = PTR_ERR(inode);
+		switch (err) {
+		case -EPERM:
+		case -EACCES:
+		case -EDQUOT:
+		case -ENOSPC:
+		case -EROFS:
+			goto out_put_ctx;
+		default:
+			goto out_drop;
+		}
+	}
+	iput(inode);
+	if (inode != dentry->d_inode)
+		goto out_drop;
+
+	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
+	nfs_file_set_open_context(filp, ctx);
+	err = 0;
+
+out_put_ctx:
+	put_nfs_open_context(ctx);
+out:
+	dput(parent);
+	return err;
+
+out_drop:
+	d_drop(dentry);
+	err = -EOPENSTALE;
+	goto out_put_ctx;
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
-- 
1.7.11.2


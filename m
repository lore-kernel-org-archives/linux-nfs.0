Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16076 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754185Ab0GLWKV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Jul 2010 18:10:21 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/3] NFS: Fix up the fsync code
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Date: Mon, 12 Jul 2010 18:09:32 -0400
Message-ID: <20100712220932.20019.21170.stgit@heimdal.trondhjem.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Christoph points out that the VFS will always flush out data before calling
nfs_fsync(), so we can dispense with a full call to nfs_wb_all(), and
replace that with a simpler call to nfs_commit_inode().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/file.c     |   50 +++++++++++++++++++++-----------------------------
 fs/nfs/internal.h |    1 +
 fs/nfs/write.c    |    4 ++--
 3 files changed, 24 insertions(+), 31 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 36a5e74..4bf7306 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -202,31 +202,6 @@ static loff_t nfs_file_llseek(struct file *filp, loff_t offset, int origin)
 }
 
 /*
- * Helper for nfs_file_flush() and nfs_file_fsync()
- *
- * Notice that it clears the NFS_CONTEXT_ERROR_WRITE before synching to
- * disk, but it retrieves and clears ctx->error after synching, despite
- * the two being set at the same time in nfs_context_set_write_error().
- * This is because the former is used to notify the _next_ call to
- * nfs_file_write() that a write error occured, and hence cause it to
- * fall back to doing a synchronous write.
- */
-static int nfs_do_fsync(struct nfs_open_context *ctx, struct inode *inode)
-{
-	int have_error, status;
-	int ret = 0;
-
-	have_error = test_and_clear_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
-	status = nfs_wb_all(inode);
-	have_error |= test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
-	if (have_error)
-		ret = xchg(&ctx->error, 0);
-	if (!ret)
-		ret = status;
-	return ret;
-}
-
-/*
  * Flush all dirty pages, and check for write errors.
  */
 static int
@@ -245,7 +220,7 @@ nfs_file_flush(struct file *file, fl_owner_t id)
 		return 0;
 
 	/* Flush writes to the server and return any errors */
-	return nfs_do_fsync(ctx, inode);
+	return vfs_fsync(file, 0);
 }
 
 static ssize_t
@@ -320,6 +295,13 @@ nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
  * Flush any dirty pages for this process, and check for write errors.
  * The return status from this call provides a reliable indication of
  * whether any write errors occurred for this process.
+ *
+ * Notice that it clears the NFS_CONTEXT_ERROR_WRITE before synching to
+ * disk, but it retrieves and clears ctx->error after synching, despite
+ * the two being set at the same time in nfs_context_set_write_error().
+ * This is because the former is used to notify the _next_ call to
+ * nfs_file_write() that a write error occured, and hence cause it to
+ * fall back to doing a synchronous write.
  */
 static int
 nfs_file_fsync(struct file *file, int datasync)
@@ -327,13 +309,23 @@ nfs_file_fsync(struct file *file, int datasync)
 	struct dentry *dentry = file->f_path.dentry;
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
 	struct inode *inode = dentry->d_inode;
+	int have_error, status;
+	int ret = 0;
+
 
 	dprintk("NFS: fsync file(%s/%s) datasync %d\n",
 			dentry->d_parent->d_name.name, dentry->d_name.name,
 			datasync);
 
 	nfs_inc_stats(inode, NFSIOS_VFSFSYNC);
-	return nfs_do_fsync(ctx, inode);
+	have_error = test_and_clear_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
+	status = nfs_commit_inode(inode, FLUSH_SYNC);
+	have_error |= test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
+	if (have_error)
+		ret = xchg(&ctx->error, 0);
+	if (!ret)
+		ret = status;
+	return ret;
 }
 
 /*
@@ -639,7 +631,7 @@ static ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
 
 	/* Return error values for O_DSYNC and IS_SYNC() */
 	if (result >= 0 && nfs_need_sync_write(iocb->ki_filp, inode)) {
-		int err = nfs_do_fsync(nfs_file_open_context(iocb->ki_filp), inode);
+		int err = vfs_fsync(iocb->ki_filp, 0);
 		if (err < 0)
 			result = err;
 	}
@@ -675,7 +667,7 @@ static ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
 		written = ret;
 
 	if (ret >= 0 && nfs_need_sync_write(filp, inode)) {
-		int err = nfs_do_fsync(nfs_file_open_context(filp), inode);
+		int err = vfs_fsync(filp, 0);
 		if (err < 0)
 			ret = err;
 	}
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index d8bd619..bdaaedf 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -251,6 +251,7 @@ extern int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh);
 extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
 
 /* write.c */
+extern int nfs_commit_inode(struct inode *inode, int how);
 extern void nfs_write_prepare(struct rpc_task *task, void *calldata);
 #ifdef CONFIG_MIGRATION
 extern int nfs_migrate_page(struct address_space *,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 5eccea1..8fda8a7 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1382,7 +1382,7 @@ static const struct rpc_call_ops nfs_commit_ops = {
 	.rpc_release = nfs_commit_release,
 };
 
-static int nfs_commit_inode(struct inode *inode, int how)
+int nfs_commit_inode(struct inode *inode, int how)
 {
 	LIST_HEAD(head);
 	int may_wait = how & FLUSH_SYNC;
@@ -1446,7 +1446,7 @@ out_mark_dirty:
 	return ret;
 }
 #else
-static int nfs_commit_inode(struct inode *inode, int how)
+int nfs_commit_inode(struct inode *inode, int how)
 {
 	return 0;
 }


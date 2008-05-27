From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/7] NFS: Make nfs_fsync methods consistent
Date: Tue, 27 May 2008 16:29:07 -0400
Message-ID: <20080527202907.6651.15778.stgit@ellison.1015granger.net>
References: <20080527202347.6651.54668.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:23515 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758083AbYE0UbU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 May 2008 16:31:20 -0400
In-Reply-To: <20080527202347.6651.54668.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Report the same debugging info, count function calls the same,
and use similar function naming in nfs_fsync_dir() and nfs_fsync().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/dir.c  |    3 ++-
 fs/nfs/file.c |   12 +++++++-----
 2 files changed, 9 insertions(+), 6 deletions(-)


diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 58d43da..1bc8bc6 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -629,10 +629,11 @@ out:
  */
 static int nfs_fsync_dir(struct file *filp, struct dentry *dentry, int datasync)
 {
-	dfprintk(VFS, "NFS: fsync_dir(%s/%s) datasync %d\n",
+	dfprintk(VFS, "NFS: fsync dir(%s/%s) datasync %d\n",
 			dentry->d_parent->d_name.name, dentry->d_name.name,
 			datasync);
 
+	nfs_inc_stats(dentry->d_inode, NFSIOS_VFSFSYNC);
 	return 0;
 }
 
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index d84a3d8..e452903 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -50,7 +50,7 @@ static ssize_t nfs_file_read(struct kiocb *, const struct iovec *iov,
 static ssize_t nfs_file_write(struct kiocb *, const struct iovec *iov,
 				unsigned long nr_segs, loff_t pos);
 static int  nfs_file_flush(struct file *, fl_owner_t id);
-static int  nfs_fsync(struct file *, struct dentry *dentry, int datasync);
+static int  nfs_file_fsync(struct file *, struct dentry *dentry, int datasync);
 static int nfs_check_flags(int flags);
 static int nfs_lock(struct file *filp, int cmd, struct file_lock *fl);
 static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl);
@@ -72,7 +72,7 @@ const struct file_operations nfs_file_operations = {
 	.open		= nfs_file_open,
 	.flush		= nfs_file_flush,
 	.release	= nfs_file_release,
-	.fsync		= nfs_fsync,
+	.fsync		= nfs_file_fsync,
 	.lock		= nfs_lock,
 	.flock		= nfs_flock,
 	.splice_read	= nfs_file_splice_read,
@@ -181,7 +181,7 @@ static loff_t nfs_file_llseek(struct file *filp, loff_t offset, int origin)
 }
 
 /*
- * Helper for nfs_file_flush() and nfs_fsync()
+ * Helper for nfs_file_flush() and nfs_file_fsync()
  *
  * Notice that it clears the NFS_CONTEXT_ERROR_WRITE before synching to
  * disk, but it retrieves and clears ctx->error after synching, despite
@@ -296,12 +296,14 @@ nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
  * whether any write errors occurred for this process.
  */
 static int
-nfs_fsync(struct file *file, struct dentry *dentry, int datasync)
+nfs_file_fsync(struct file *file, struct dentry *dentry, int datasync)
 {
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
 	struct inode *inode = dentry->d_inode;
 
-	dfprintk(VFS, "nfs: fsync(%s/%ld)\n", inode->i_sb->s_id, inode->i_ino);
+	dfprintk(VFS, "NFS: fsync file(%s/%s) datasync %d\n",
+			dentry->d_parent->d_name.name, dentry->d_name.name,
+			datasync);
 
 	nfs_inc_stats(inode, NFSIOS_VFSFSYNC);
 	return nfs_do_fsync(ctx, inode);


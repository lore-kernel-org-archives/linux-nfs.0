Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:65521 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757943Ab2FTTyH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jun 2012 15:54:07 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 03/10] NFS: Create a v4-specific fsync function
Date: Wed, 20 Jun 2012 15:53:42 -0400
Message-Id: <1340222029-18027-4-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1340222029-18027-1-git-send-email-bjschuma@netapp.com>
References: <1340222029-18027-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

v2 and v3 don't need to worry about doing a pnfs layoutcommit.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/file.c | 40 ++++++++++++++++++++++++++++++++--------
 1 file changed, 32 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index a6708e6b..8941ac4 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -265,7 +265,7 @@ nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
  * fall back to doing a synchronous write.
  */
 static int
-nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
+nfs_file_fsync_commit(struct file *file, loff_t start, loff_t end, int datasync)
 {
 	struct dentry *dentry = file->f_path.dentry;
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
@@ -277,9 +277,6 @@ nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 			dentry->d_parent->d_name.name, dentry->d_name.name,
 			datasync);
 
-	ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
-	mutex_lock(&inode->i_mutex);
-
 	nfs_inc_stats(inode, NFSIOS_VFSFSYNC);
 	have_error = test_and_clear_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
 	status = nfs_commit_inode(inode, FLUSH_SYNC);
@@ -290,10 +287,20 @@ nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
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
 
@@ -956,6 +963,23 @@ out_drop:
 	goto out_put_ctx;
 }
 
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
 const struct file_operations nfs4_file_operations = {
 	.llseek		= nfs_file_llseek,
 	.read		= do_sync_read,
@@ -966,7 +990,7 @@ const struct file_operations nfs4_file_operations = {
 	.open		= nfs4_file_open,
 	.flush		= nfs_file_flush,
 	.release	= nfs_file_release,
-	.fsync		= nfs_file_fsync,
+	.fsync		= nfs4_file_fsync,
 	.lock		= nfs_lock,
 	.flock		= nfs_flock,
 	.splice_read	= nfs_file_splice_read,
-- 
1.7.11


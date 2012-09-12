Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:40792 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750726Ab2ILTIo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Sep 2012 15:08:44 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFS: Fix fdatasync/fsync() when confronted with a server reboot
Date: Wed, 12 Sep 2012 15:08:36 -0400
Message-Id: <1347476917-34642-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server reboots before it can commit the unstable writes to disk,
then nfs_commit_release_pages() will detect this when it compares the
verifier returned by COMMIT to the one returned by WRITE. When this
happens, the client needs to resend those writes in order to guarantee
that they make it to stable storage.

This patch adds a signalling mechanism to notify fsync() that it
needs to retry all writes before it can exit.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/file.c          | 34 ++++++++++++++++++++++------------
 fs/nfs/nfs4file.c      | 22 ++++++++++++----------
 fs/nfs/write.c         |  1 +
 include/linux/nfs_fs.h |  1 +
 4 files changed, 36 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 6a7fcab..cc9b566 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -259,7 +259,7 @@ nfs_file_fsync_commit(struct file *file, loff_t start, loff_t end, int datasync)
 	struct dentry *dentry = file->f_path.dentry;
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
 	struct inode *inode = dentry->d_inode;
-	int have_error, status;
+	int have_error, do_resend, status;
 	int ret = 0;
 
 	dprintk("NFS: fsync file(%s/%s) datasync %d\n",
@@ -267,15 +267,23 @@ nfs_file_fsync_commit(struct file *file, loff_t start, loff_t end, int datasync)
 			datasync);
 
 	nfs_inc_stats(inode, NFSIOS_VFSFSYNC);
+	do_resend = test_and_clear_bit(NFS_CONTEXT_RESEND_WRITES, &ctx->flags);
 	have_error = test_and_clear_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
 	status = nfs_commit_inode(inode, FLUSH_SYNC);
-	if (status >= 0 && ret < 0)
-		status = ret;
 	have_error |= test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
-	if (have_error)
+	if (have_error) {
 		ret = xchg(&ctx->error, 0);
-	if (!ret && status < 0)
+		if (ret)
+			goto out;
+	}
+	if (status < 0) {
 		ret = status;
+		goto out;
+	}
+	do_resend |= test_bit(NFS_CONTEXT_RESEND_WRITES, &ctx->flags);
+	if (do_resend)
+		ret = -EAGAIN;
+out:
 	return ret;
 }
 EXPORT_SYMBOL_GPL(nfs_file_fsync_commit);
@@ -286,13 +294,15 @@ nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	int ret;
 	struct inode *inode = file->f_path.dentry->d_inode;
 
-	ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
-	if (ret != 0)
-		goto out;
-	mutex_lock(&inode->i_mutex);
-	ret = nfs_file_fsync_commit(file, start, end, datasync);
-	mutex_unlock(&inode->i_mutex);
-out:
+	do {
+		ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
+		if (ret != 0)
+			break;
+		mutex_lock(&inode->i_mutex);
+		ret = nfs_file_fsync_commit(file, start, end, datasync);
+		mutex_unlock(&inode->i_mutex);
+	} while (ret == -EAGAIN);
+
 	return ret;
 }
 
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index eb5eb8e..eef1b38 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -95,16 +95,18 @@ nfs4_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	int ret;
 	struct inode *inode = file->f_path.dentry->d_inode;
 
-	ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
-	if (ret != 0)
-		goto out;
-	mutex_lock(&inode->i_mutex);
-	ret = nfs_file_fsync_commit(file, start, end, datasync);
-	if (!ret && !datasync)
-		/* application has asked for meta-data sync */
-		ret = pnfs_layoutcommit_inode(inode, true);
-	mutex_unlock(&inode->i_mutex);
-out:
+	do {
+		ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
+		if (ret != 0)
+			break;
+		mutex_lock(&inode->i_mutex);
+		ret = nfs_file_fsync_commit(file, start, end, datasync);
+		if (!ret && !datasync)
+			/* application has asked for meta-data sync */
+			ret = pnfs_layoutcommit_inode(inode, true);
+		mutex_unlock(&inode->i_mutex);
+	} while (ret == -EAGAIN);
+
 	return ret;
 }
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e1b5fe4..9347ab7 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1580,6 +1580,7 @@ static void nfs_commit_release_pages(struct nfs_commit_data *data)
 		/* We have a mismatch. Write the page again */
 		dprintk(" mismatch\n");
 		nfs_mark_request_dirty(req);
+		set_bit(NFS_CONTEXT_RESEND_WRITES, &req->wb_context->flags);
 	next:
 		nfs_unlock_and_release_request(req);
 	}
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 869eac0..383f331 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -103,6 +103,7 @@ struct nfs_open_context {
 
 	unsigned long flags;
 #define NFS_CONTEXT_ERROR_WRITE		(0)
+#define NFS_CONTEXT_RESEND_WRITES	(1)
 	int error;
 
 	struct list_head list;
-- 
1.7.11.4


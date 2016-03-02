Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40123 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755518AbcCBQf7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Mar 2016 11:35:59 -0500
Received: from chello080109146114.tirol.surfer.at ([80.109.146.114] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.85 #2 (Red Hat Linux))
	id 1ab9kj-00027o-F1
	for linux-nfs@vger.kernel.org; Wed, 02 Mar 2016 16:35:57 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] nfs: remove nfs4_file_fsync
Date: Wed,  2 Mar 2016 17:35:54 +0100
Message-Id: <1456936555-22602-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The only difference to nfs_file_fsync is the call to pnfs_sync_inode.  But
pnfs_sync_inode is just an inline that calls a pNFS layout driver method
if CONFIG_PNFS is designed, and thus can be called just fine from the core
NFS module.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/file.c     |  8 +++++---
 fs/nfs/internal.h |  2 +-
 fs/nfs/nfs4file.c | 33 +--------------------------------
 3 files changed, 7 insertions(+), 36 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 748bb81..cdf8621 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -233,7 +233,7 @@ EXPORT_SYMBOL_GPL(nfs_file_mmap);
  * nfs_file_write() that a write error occurred, and hence cause it to
  * fall back to doing a synchronous write.
  */
-int
+static int
 nfs_file_fsync_commit(struct file *file, loff_t start, loff_t end, int datasync)
 {
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
@@ -263,9 +263,8 @@ nfs_file_fsync_commit(struct file *file, loff_t start, loff_t end, int datasync)
 out:
 	return ret;
 }
-EXPORT_SYMBOL_GPL(nfs_file_fsync_commit);
 
-static int
+int
 nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 {
 	int ret;
@@ -280,6 +279,8 @@ nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 			break;
 		inode_lock(inode);
 		ret = nfs_file_fsync_commit(file, start, end, datasync);
+		if (!ret)
+			ret = pnfs_sync_inode(inode, !!datasync);
 		inode_unlock(inode);
 		/*
 		 * If nfs_file_fsync_commit detected a server reboot, then
@@ -293,6 +294,7 @@ nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	trace_nfs_fsync_exit(inode, ret);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nfs_file_fsync);
 
 /*
  * Decide whether a read/modify/write cycle may be more efficient
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 9a547aa..c41c5f5 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -358,7 +358,7 @@ int nfs_mknod(struct inode *, struct dentry *, umode_t, dev_t);
 int nfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *);
 
 /* file.c */
-int nfs_file_fsync_commit(struct file *, loff_t, loff_t, int);
+int nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync);
 loff_t nfs_file_llseek(struct file *, loff_t, int);
 ssize_t nfs_file_read(struct kiocb *, struct iov_iter *);
 ssize_t nfs_file_splice_read(struct file *, loff_t *, struct pipe_inode_info *,
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 57ca1c8..22c35ab 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -128,37 +128,6 @@ nfs4_file_flush(struct file *file, fl_owner_t id)
 	return vfs_fsync(file, 0);
 }
 
-static int
-nfs4_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
-{
-	int ret;
-	struct inode *inode = file_inode(file);
-
-	trace_nfs_fsync_enter(inode);
-
-	nfs_inode_dio_wait(inode);
-	do {
-		ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
-		if (ret != 0)
-			break;
-		inode_lock(inode);
-		ret = nfs_file_fsync_commit(file, start, end, datasync);
-		if (!ret)
-			ret = pnfs_sync_inode(inode, !!datasync);
-		inode_unlock(inode);
-		/*
-		 * If nfs_file_fsync_commit detected a server reboot, then
-		 * resend all dirty pages that might have been covered by
-		 * the NFS_CONTEXT_RESEND_WRITES flag
-		 */
-		start = 0;
-		end = LLONG_MAX;
-	} while (ret == -EAGAIN);
-
-	trace_nfs_fsync_exit(inode, ret);
-	return ret;
-}
-
 #ifdef CONFIG_NFS_V4_2
 static loff_t nfs4_file_llseek(struct file *filep, loff_t offset, int whence)
 {
@@ -266,7 +235,7 @@ const struct file_operations nfs4_file_operations = {
 	.open		= nfs4_file_open,
 	.flush		= nfs4_file_flush,
 	.release	= nfs_file_release,
-	.fsync		= nfs4_file_fsync,
+	.fsync		= nfs_file_fsync,
 	.lock		= nfs_lock,
 	.flock		= nfs_flock,
 	.splice_read	= nfs_file_splice_read,
-- 
2.1.4


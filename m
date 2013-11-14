Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:53522 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757760Ab3KNQun (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Nov 2013 11:50:43 -0500
Message-Id: <20131114165041.628633448@bombadil.infradead.org>
Date: Thu, 14 Nov 2013 08:50:31 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/7] nfs: merge nfs_direct_read into nfs_file_direct_read
References: <20131114165027.355613182@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Simple code cleanup to prepare for later fixes.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/direct.c |  107 +++++++++++++++++++++++++------------------------------
 1 file changed, 49 insertions(+), 58 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 62ea415..8312796 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -458,14 +458,55 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 	return 0;
 }
 
-static ssize_t nfs_direct_read(struct kiocb *iocb, const struct iovec *iov,
-			       unsigned long nr_segs, loff_t pos, bool uio)
+/**
+ * nfs_file_direct_read - file direct read operation for NFS files
+ * @iocb: target I/O control block
+ * @iov: vector of user buffers into which to read data
+ * @nr_segs: size of iov vector
+ * @pos: byte offset in file where reading starts
+ *
+ * We use this function for direct reads instead of calling
+ * generic_file_aio_read() in order to avoid gfar's check to see if
+ * the request starts before the end of the file.  For that check
+ * to work, we must generate a GETATTR before each direct read, and
+ * even then there is a window between the GETATTR and the subsequent
+ * READ where the file size could change.  Our preference is simply
+ * to do all reads the application wants, and the server will take
+ * care of managing the end of file boundary.
+ *
+ * This function also eliminates unnecessarily updating the file's
+ * atime locally, as the NFS server sets the file's atime, and this
+ * client must read the updated atime from the server back into its
+ * cache.
+ */
+ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec *iov,
+				unsigned long nr_segs, loff_t pos, bool uio)
 {
-	ssize_t result = -ENOMEM;
-	struct inode *inode = iocb->ki_filp->f_mapping->host;
+	struct file *file = iocb->ki_filp;
+	struct address_space *mapping = file->f_mapping;
+	struct inode *inode = mapping->host;
 	struct nfs_direct_req *dreq;
 	struct nfs_lock_context *l_ctx;
+	ssize_t result = -EINVAL;
+	size_t count;
+
+	count = iov_length(iov, nr_segs);
+	nfs_add_stats(mapping->host, NFSIOS_DIRECTREADBYTES, count);
+
+	dfprintk(FILE, "NFS: direct read(%pD2, %zd@%Ld)\n",
+		file, count, (long long) pos);
+
+	result = 0;
+	if (!count)
+		goto out;
+
+	result = nfs_sync_mapping(mapping);
+	if (result)
+		goto out;
+
+	task_io_account_read(count);
 
+	result = -ENOMEM;
 	dreq = nfs_direct_req_alloc();
 	if (dreq == NULL)
 		goto out;
@@ -484,8 +525,11 @@ static ssize_t nfs_direct_read(struct kiocb *iocb, const struct iovec *iov,
 
 	NFS_I(inode)->read_io += iov_length(iov, nr_segs);
 	result = nfs_direct_read_schedule_iovec(dreq, iov, nr_segs, pos, uio);
-	if (!result)
+	if (!result) {
 		result = nfs_direct_wait(dreq);
+		if (result > 0)
+			iocb->ki_pos = pos + result;
+	}
 out_release:
 	nfs_direct_req_release(dreq);
 out:
@@ -889,59 +933,6 @@ out:
 }
 
 /**
- * nfs_file_direct_read - file direct read operation for NFS files
- * @iocb: target I/O control block
- * @iov: vector of user buffers into which to read data
- * @nr_segs: size of iov vector
- * @pos: byte offset in file where reading starts
- *
- * We use this function for direct reads instead of calling
- * generic_file_aio_read() in order to avoid gfar's check to see if
- * the request starts before the end of the file.  For that check
- * to work, we must generate a GETATTR before each direct read, and
- * even then there is a window between the GETATTR and the subsequent
- * READ where the file size could change.  Our preference is simply
- * to do all reads the application wants, and the server will take
- * care of managing the end of file boundary.
- *
- * This function also eliminates unnecessarily updating the file's
- * atime locally, as the NFS server sets the file's atime, and this
- * client must read the updated atime from the server back into its
- * cache.
- */
-ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec *iov,
-				unsigned long nr_segs, loff_t pos, bool uio)
-{
-	ssize_t retval = -EINVAL;
-	struct file *file = iocb->ki_filp;
-	struct address_space *mapping = file->f_mapping;
-	size_t count;
-
-	count = iov_length(iov, nr_segs);
-	nfs_add_stats(mapping->host, NFSIOS_DIRECTREADBYTES, count);
-
-	dfprintk(FILE, "NFS: direct read(%pD2, %zd@%Ld)\n",
-		file, count, (long long) pos);
-
-	retval = 0;
-	if (!count)
-		goto out;
-
-	retval = nfs_sync_mapping(mapping);
-	if (retval)
-		goto out;
-
-	task_io_account_read(count);
-
-	retval = nfs_direct_read(iocb, iov, nr_segs, pos, uio);
-	if (retval > 0)
-		iocb->ki_pos = pos + retval;
-
-out:
-	return retval;
-}
-
-/**
  * nfs_file_direct_write - file direct write operation for NFS files
  * @iocb: target I/O control block
  * @iov: vector of user buffers from which to write data
-- 
1.7.10.4



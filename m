Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:53516 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757757Ab3KNQun (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Nov 2013 11:50:43 -0500
Message-Id: <20131114165041.810777094@bombadil.infradead.org>
Date: Thu, 14 Nov 2013 08:50:32 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 5/7] nfs: merge nfs_direct_write into nfs_file_direct_write
References: <20131114165027.355613182@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Simple code cleanup to prepare for later fixes.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/direct.c |   91 +++++++++++++++++++++++++------------------------------
 1 file changed, 41 insertions(+), 50 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 8312796..c32db2a 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -898,40 +898,6 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 	return 0;
 }
 
-static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
-				unsigned long nr_segs, loff_t pos,
-				size_t count, bool uio)
-{
-	ssize_t result = -ENOMEM;
-	struct inode *inode = iocb->ki_filp->f_mapping->host;
-	struct nfs_direct_req *dreq;
-	struct nfs_lock_context *l_ctx;
-
-	dreq = nfs_direct_req_alloc();
-	if (!dreq)
-		goto out;
-
-	dreq->inode = inode;
-	dreq->bytes_left = count;
-	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
-	l_ctx = nfs_get_lock_context(dreq->ctx);
-	if (IS_ERR(l_ctx)) {
-		result = PTR_ERR(l_ctx);
-		goto out_release;
-	}
-	dreq->l_ctx = l_ctx;
-	if (!is_sync_kiocb(iocb))
-		dreq->iocb = iocb;
-
-	result = nfs_direct_write_schedule_iovec(dreq, iov, nr_segs, pos, uio);
-	if (!result)
-		result = nfs_direct_wait(dreq);
-out_release:
-	nfs_direct_req_release(dreq);
-out:
-	return result;
-}
-
 /**
  * nfs_file_direct_write - file direct write operation for NFS files
  * @iocb: target I/O control block
@@ -957,9 +923,12 @@ out:
 ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 				unsigned long nr_segs, loff_t pos, bool uio)
 {
-	ssize_t retval = -EINVAL;
+	ssize_t result = -EINVAL;
 	struct file *file = iocb->ki_filp;
 	struct address_space *mapping = file->f_mapping;
+	struct inode *inode = mapping->host;
+	struct nfs_direct_req *dreq;
+	struct nfs_lock_context *l_ctx;
 	size_t count;
 
 	count = iov_length(iov, nr_segs);
@@ -968,35 +937,57 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	dfprintk(FILE, "NFS: direct write(%pD2, %zd@%Ld)\n",
 		file, count, (long long) pos);
 
-	retval = generic_write_checks(file, &pos, &count, 0);
-	if (retval)
+	result = generic_write_checks(file, &pos, &count, 0);
+	if (result)
 		goto out;
 
-	retval = -EINVAL;
+	result = -EINVAL;
 	if ((ssize_t) count < 0)
 		goto out;
-	retval = 0;
+	result = 0;
 	if (!count)
 		goto out;
 
-	retval = nfs_sync_mapping(mapping);
-	if (retval)
+	result = nfs_sync_mapping(mapping);
+	if (result)
 		goto out;
 
 	task_io_account_write(count);
 
-	retval = nfs_direct_write(iocb, iov, nr_segs, pos, count, uio);
-	if (retval > 0) {
-		struct inode *inode = mapping->host;
+	result = -ENOMEM;
+	dreq = nfs_direct_req_alloc();
+	if (!dreq)
+		goto out;
 
-		iocb->ki_pos = pos + retval;
-		spin_lock(&inode->i_lock);
-		if (i_size_read(inode) < iocb->ki_pos)
-			i_size_write(inode, iocb->ki_pos);
-		spin_unlock(&inode->i_lock);
+	dreq->inode = inode;
+	dreq->bytes_left = count;
+	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
+	l_ctx = nfs_get_lock_context(dreq->ctx);
+	if (IS_ERR(l_ctx)) {
+		result = PTR_ERR(l_ctx);
+		goto out_release;
+	}
+	dreq->l_ctx = l_ctx;
+	if (!is_sync_kiocb(iocb))
+		dreq->iocb = iocb;
+
+	result = nfs_direct_write_schedule_iovec(dreq, iov, nr_segs, pos, uio);
+	if (!result) {
+		result = nfs_direct_wait(dreq);
+		if (result > 0) {
+			struct inode *inode = mapping->host;
+
+			iocb->ki_pos = pos + result;
+			spin_lock(&inode->i_lock);
+			if (i_size_read(inode) < iocb->ki_pos)
+				i_size_write(inode, iocb->ki_pos);
+			spin_unlock(&inode->i_lock);
+		}
 	}
+out_release:
+	nfs_direct_req_release(dreq);
 out:
-	return retval;
+	return result;
 }
 
 /**
-- 
1.7.10.4



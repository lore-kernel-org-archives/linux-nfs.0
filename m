Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:53513 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757755Ab3KNQun (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Nov 2013 11:50:43 -0500
Message-Id: <20131114165042.205194841@bombadil.infradead.org>
Date: Thu, 14 Nov 2013 08:50:34 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 7/7] nfs: page cache invalidation for dio
References: <20131114165027.355613182@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make sure to properly invalidate the pagecache before performing direct I/O,
so that no stale pages are left around.  This matches what the generic
direct I/O code does.  Also take the i_mutex over the direct write submission
to avoid the lifelock vs truncate waiting for i_dio_count to decrease, and
to avoid having the pagecache easily repopulated while direct I/O is in
progrss.  Again matching the generic direct I/O code.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/direct.c |   29 +++++++++++++++++++++++++++--
 1 file changed, 27 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 6cc7fe1..2b778fc 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -939,9 +939,12 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	struct inode *inode = mapping->host;
 	struct nfs_direct_req *dreq;
 	struct nfs_lock_context *l_ctx;
+	loff_t end;
 	size_t count;
 
 	count = iov_length(iov, nr_segs);
+	end = (pos + count - 1) >> PAGE_CACHE_SHIFT;
+
 	nfs_add_stats(mapping->host, NFSIOS_DIRECTWRITTENBYTES, count);
 
 	dfprintk(FILE, "NFS: direct write(%pD2, %zd@%Ld)\n",
@@ -958,16 +961,25 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	if (!count)
 		goto out;
 
+	mutex_lock(&inode->i_mutex);
+
 	result = nfs_sync_mapping(mapping);
 	if (result)
-		goto out;
+		goto out_unlock;
+
+	if (mapping->nrpages) {
+		result = invalidate_inode_pages2_range(mapping,
+					pos >> PAGE_CACHE_SHIFT, end);
+		if (result)
+			goto out_unlock;
+	}
 
 	task_io_account_write(count);
 
 	result = -ENOMEM;
 	dreq = nfs_direct_req_alloc();
 	if (!dreq)
-		goto out;
+		goto out_unlock;
 
 	dreq->inode = inode;
 	dreq->bytes_left = count;
@@ -982,6 +994,14 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 		dreq->iocb = iocb;
 
 	result = nfs_direct_write_schedule_iovec(dreq, iov, nr_segs, pos, uio);
+	
+	if (mapping->nrpages) {
+		invalidate_inode_pages2_range(mapping,
+					      pos >> PAGE_CACHE_SHIFT, end);
+	}
+
+	mutex_unlock(&inode->i_mutex);
+
 	if (!result) {
 		result = nfs_direct_wait(dreq);
 		if (result > 0) {
@@ -994,8 +1014,13 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 			spin_unlock(&inode->i_lock);
 		}
 	}
+	nfs_direct_req_release(dreq);
+	return result;
+
 out_release:
 	nfs_direct_req_release(dreq);
+out_unlock:
+	mutex_unlock(&inode->i_mutex);
 out:
 	return result;
 }
-- 
1.7.10.4



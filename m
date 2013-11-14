Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:53514 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757759Ab3KNQun (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Nov 2013 11:50:43 -0500
Message-Id: <20131114165042.013211118@bombadil.infradead.org>
Date: Thu, 14 Nov 2013 08:50:33 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 6/7] nfs: take i_mutex during direct I/O reads
References: <20131114165027.355613182@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We'll need the i_mutex to prevent i_dio_count from incrementing while
truncate is waiting for it to reach zero, and protects against having
the pagecache repopulated after we flushed it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/direct.c |   14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index c32db2a..6cc7fe1 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -500,16 +500,17 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec *iov,
 	if (!count)
 		goto out;
 
+	mutex_lock(&inode->i_mutex);
 	result = nfs_sync_mapping(mapping);
 	if (result)
-		goto out;
+		goto out_unlock;
 
 	task_io_account_read(count);
 
 	result = -ENOMEM;
 	dreq = nfs_direct_req_alloc();
 	if (dreq == NULL)
-		goto out;
+		goto out_unlock;
 
 	dreq->inode = inode;
 	dreq->bytes_left = iov_length(iov, nr_segs);
@@ -525,13 +526,22 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec *iov,
 
 	NFS_I(inode)->read_io += iov_length(iov, nr_segs);
 	result = nfs_direct_read_schedule_iovec(dreq, iov, nr_segs, pos, uio);
+
+	mutex_unlock(&inode->i_mutex);
+
 	if (!result) {
 		result = nfs_direct_wait(dreq);
 		if (result > 0)
 			iocb->ki_pos = pos + result;
 	}
+
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



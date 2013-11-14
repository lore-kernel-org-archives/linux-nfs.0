Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:53511 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756330Ab3KNQun (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Nov 2013 11:50:43 -0500
Message-Id: <20131114165041.425130333@bombadil.infradead.org>
Date: Thu, 14 Nov 2013 08:50:30 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/7] nfs: increment i_dio_count for reads, too
References: <20131114165027.355613182@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

i_dio_count is used to protect dio access against truncate.  We want
to make sure there are no dio reads pending either when doing a
truncate.  I suspect on plain NFS things might work even without
this, but once we use a pnfs layout driver that access backing devices
directly things will go bad without the proper synchronization.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/direct.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 3dd8823..62ea415 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -235,10 +235,10 @@ static void nfs_direct_complete(struct nfs_direct_req *dreq, bool write)
 		spin_unlock(&inode->i_lock);
 	}
 
-	if (write) {
+	if (write)
 		nfs_zap_mapping(inode, inode->i_mapping);
-		inode_dio_done(inode);
-	}
+
+	inode_dio_done(inode);
 
 	if (dreq->iocb) {
 		long res = (long) dreq->error;
@@ -419,6 +419,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 					      loff_t pos, bool uio)
 {
 	struct nfs_pageio_descriptor desc;
+	struct inode *inode = dreq->inode;
 	ssize_t result = -EINVAL;
 	size_t requested_bytes = 0;
 	unsigned long seg;
@@ -427,6 +428,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 			     &nfs_direct_read_completion_ops);
 	get_dreq(dreq);
 	desc.pg_dreq = dreq;
+	atomic_inc(&inode->i_dio_count);
 
 	for (seg = 0; seg < nr_segs; seg++) {
 		const struct iovec *vec = &iov[seg];
@@ -446,6 +448,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 	 * generic layer handle the completion.
 	 */
 	if (requested_bytes == 0) {
+		inode_dio_done(inode);
 		nfs_direct_req_release(dreq);
 		return result < 0 ? result : -EIO;
 	}
-- 
1.7.10.4



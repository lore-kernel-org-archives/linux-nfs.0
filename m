Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:53519 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757754Ab3KNQun (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Nov 2013 11:50:43 -0500
Message-Id: <20131114165041.295995198@bombadil.infradead.org>
Date: Thu, 14 Nov 2013 08:50:29 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/7] nfs: defer inode_dio_done call until size update is done
References: <20131114165027.355613182@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to have the I/O fully finished before telling the truncate code
that we are done.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/direct.c |   32 +++++++++++++++-----------------
 1 file changed, 15 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 653c2e8..3dd8823 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -226,21 +226,27 @@ static void nfs_direct_complete(struct nfs_direct_req *dreq, bool write)
 {
 	struct inode *inode = dreq->inode;
 
-	if (dreq->iocb) {
+	if (dreq->iocb && write) {
 		loff_t pos = dreq->iocb->ki_pos + dreq->count;
+
+		spin_lock(&inode->i_lock);
+		if (i_size_read(inode) < pos)
+			i_size_write(inode, pos);
+		spin_unlock(&inode->i_lock);
+	}
+
+	if (write) {
+		nfs_zap_mapping(inode, inode->i_mapping);
+		inode_dio_done(inode);
+	}
+
+	if (dreq->iocb) {
 		long res = (long) dreq->error;
 		if (!res)
 			res = (long) dreq->count;
-
-		if (write) {
-			spin_lock(&inode->i_lock);
-			if (i_size_read(inode) < pos)
-				i_size_write(inode, pos);
-			spin_unlock(&inode->i_lock);
-		}
-
 		aio_complete(dreq->iocb, res, 0);
 	}
+
 	complete_all(&dreq->completion);
 
 	nfs_direct_req_release(dreq);
@@ -483,12 +489,6 @@ out:
 	return result;
 }
 
-static void nfs_inode_dio_write_done(struct inode *inode)
-{
-	nfs_zap_mapping(inode, inode->i_mapping);
-	inode_dio_done(inode);
-}
-
 #if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 {
@@ -604,7 +604,6 @@ static void nfs_direct_write_schedule_work(struct work_struct *work)
 			nfs_direct_write_reschedule(dreq);
 			break;
 		default:
-			nfs_inode_dio_write_done(dreq->inode);
 			nfs_direct_complete(dreq, true);
 	}
 }
@@ -621,7 +620,6 @@ static void nfs_direct_write_schedule_work(struct work_struct *work)
 
 static void nfs_direct_write_complete(struct nfs_direct_req *dreq, struct inode *inode)
 {
-	nfs_inode_dio_write_done(inode);
 	nfs_direct_complete(dreq, true);
 }
 #endif
-- 
1.7.10.4



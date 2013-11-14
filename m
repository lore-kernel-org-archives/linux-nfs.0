Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:53524 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757762Ab3KNQun (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Nov 2013 11:50:43 -0500
Message-Id: <20131114165041.155176197@bombadil.infradead.org>
Date: Thu, 14 Nov 2013 08:50:28 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/7] nfs: fix size updates for aio writes
References: <20131114165027.355613182@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_file_direct_write only updates the inode size if it succeeded and
returned the number of bytes written.  But in the AIO case nfs_direct_wait
turns the return value into -EIOCBQUEUED and we skip the size update.

Instead the aio completion path should updated it, which this patch
does.  The implementation is a little hacky because there is no obvious
way to find out we are called for a write in nfs_direct_complete.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/direct.c |   21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index d71d66c..653c2e8 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -222,12 +222,23 @@ out:
  * Synchronous I/O uses a stack-allocated iocb.  Thus we can't trust
  * the iocb is still valid here if this is a synchronous request.
  */
-static void nfs_direct_complete(struct nfs_direct_req *dreq)
+static void nfs_direct_complete(struct nfs_direct_req *dreq, bool write)
 {
+	struct inode *inode = dreq->inode;
+
 	if (dreq->iocb) {
+		loff_t pos = dreq->iocb->ki_pos + dreq->count;
 		long res = (long) dreq->error;
 		if (!res)
 			res = (long) dreq->count;
+
+		if (write) {
+			spin_lock(&inode->i_lock);
+			if (i_size_read(inode) < pos)
+				i_size_write(inode, pos);
+			spin_unlock(&inode->i_lock);
+		}
+
 		aio_complete(dreq->iocb, res, 0);
 	}
 	complete_all(&dreq->completion);
@@ -272,7 +283,7 @@ static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
 	}
 out_put:
 	if (put_dreq(dreq))
-		nfs_direct_complete(dreq);
+		nfs_direct_complete(dreq, false);
 	hdr->release(hdr);
 }
 
@@ -434,7 +445,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 	}
 
 	if (put_dreq(dreq))
-		nfs_direct_complete(dreq);
+		nfs_direct_complete(dreq, false);
 	return 0;
 }
 
@@ -594,7 +605,7 @@ static void nfs_direct_write_schedule_work(struct work_struct *work)
 			break;
 		default:
 			nfs_inode_dio_write_done(dreq->inode);
-			nfs_direct_complete(dreq);
+			nfs_direct_complete(dreq, true);
 	}
 }
 
@@ -611,7 +622,7 @@ static void nfs_direct_write_schedule_work(struct work_struct *work)
 static void nfs_direct_write_complete(struct nfs_direct_req *dreq, struct inode *inode)
 {
 	nfs_inode_dio_write_done(inode);
-	nfs_direct_complete(dreq);
+	nfs_direct_complete(dreq, true);
 }
 #endif
 
-- 
1.7.10.4



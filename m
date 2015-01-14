Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:57876 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751717AbbANJns (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jan 2015 04:43:48 -0500
From: Christoph Hellwig <hch@lst.de>
To: Jens Axboe <axboe@fb.com>
Cc: David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Subject: [PATCH 04/12] block_dev: only write bdev inode on close
Date: Wed, 14 Jan 2015 10:42:33 +0100
Message-Id: <1421228561-16857-5-git-send-email-hch@lst.de>
In-Reply-To: <1421228561-16857-1-git-send-email-hch@lst.de>
References: <1421228561-16857-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since 018a17bdc865 ("bdi: reimplement bdev_inode_switch_bdi()") the
block device code writes out all dirty data whenever switching the
backing_dev_info for a block device inode.  But a block device inode can
only be dirtied when it is in use, which means we only have to write it
out on the final blkdev_put, but not when doing a blkdev_get.

Factoring out the write out from the bdi list switch prepares from
removing the list switch later in the series.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Acked-by: Tejun Heo <tj@kernel.org>
---
 fs/block_dev.c | 31 +++++++++++++++++++------------
 1 file changed, 19 insertions(+), 12 deletions(-)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index b48c41b..026ca7b 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -49,6 +49,17 @@ inline struct block_device *I_BDEV(struct inode *inode)
 }
 EXPORT_SYMBOL(I_BDEV);
 
+static void bdev_write_inode(struct inode *inode)
+{
+	spin_lock(&inode->i_lock);
+	while (inode->i_state & I_DIRTY) {
+		spin_unlock(&inode->i_lock);
+		WARN_ON_ONCE(write_inode_now(inode, true));
+		spin_lock(&inode->i_lock);
+	}
+	spin_unlock(&inode->i_lock);
+}
+
 /*
  * Move the inode from its current bdi to a new bdi.  Make sure the inode
  * is clean before moving so that it doesn't linger on the old bdi.
@@ -56,16 +67,10 @@ EXPORT_SYMBOL(I_BDEV);
 static void bdev_inode_switch_bdi(struct inode *inode,
 			struct backing_dev_info *dst)
 {
-	while (true) {
-		spin_lock(&inode->i_lock);
-		if (!(inode->i_state & I_DIRTY)) {
-			inode->i_data.backing_dev_info = dst;
-			spin_unlock(&inode->i_lock);
-			return;
-		}
-		spin_unlock(&inode->i_lock);
-		WARN_ON_ONCE(write_inode_now(inode, true));
-	}
+	spin_lock(&inode->i_lock);
+	WARN_ON_ONCE(inode->i_state & I_DIRTY);
+	inode->i_data.backing_dev_info = dst;
+	spin_unlock(&inode->i_lock);
 }
 
 /* Kill _all_ buffers and pagecache , dirty or not.. */
@@ -1464,9 +1469,11 @@ static void __blkdev_put(struct block_device *bdev, fmode_t mode, int for_part)
 		WARN_ON_ONCE(bdev->bd_holders);
 		sync_blockdev(bdev);
 		kill_bdev(bdev);
-		/* ->release can cause the old bdi to disappear,
-		 * so must switch it out first
+		/*
+		 * ->release can cause the queue to disappear, so flush all
+		 * dirty data before.
 		 */
+		bdev_write_inode(bdev->bd_inode);
 		bdev_inode_switch_bdi(bdev->bd_inode,
 					&default_backing_dev_info);
 	}
-- 
1.9.1


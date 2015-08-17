Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:42595 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755036AbbHQQoO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Aug 2015 12:44:14 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] pnfs/blocklayout: pass proper file mode to blkdev_get/put
Date: Mon, 17 Aug 2015 18:41:00 +0200
Message-Id: <1439829661-1505-5-git-send-email-hch@lst.de>
In-Reply-To: <1439829661-1505-1-git-send-email-hch@lst.de>
References: <1439829661-1505-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We generally want to read and write to a block device that's used by
the pNFS block layout client (and even if it's read only the server
has no way of telling us).  Add FMODE_WRITE to the mode argument
so that we don't incorrectly tell the block driver that we want a
read-only open.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/dev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
index d76993a..a861bbd 100644
--- a/fs/nfs/blocklayout/dev.c
+++ b/fs/nfs/blocklayout/dev.c
@@ -22,7 +22,7 @@ bl_free_device(struct pnfs_block_dev *dev)
 		kfree(dev->children);
 	} else {
 		if (dev->bdev)
-			blkdev_put(dev->bdev, FMODE_READ);
+			blkdev_put(dev->bdev, FMODE_READ | FMODE_WRITE);
 	}
 }
 
@@ -200,7 +200,7 @@ bl_parse_simple(struct nfs_server *server, struct pnfs_block_dev *d,
 	if (!dev)
 		return -EIO;
 
-	d->bdev = blkdev_get_by_dev(dev, FMODE_READ, NULL);
+	d->bdev = blkdev_get_by_dev(dev, FMODE_READ | FMODE_WRITE, NULL);
 	if (IS_ERR(d->bdev)) {
 		printk(KERN_WARNING "pNFS: failed to open device %d:%d (%ld)\n",
 			MAJOR(dev), MINOR(dev), PTR_ERR(d->bdev));
-- 
1.9.1


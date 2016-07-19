Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41674 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752866AbcGSLbS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Jul 2016 07:31:18 -0400
From: Artem Savkov <asavkov@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, trond.myklebust@primarydata.com, hch@lst.de,
        Artem Savkov <asavkov@redhat.com>
Subject: [PATCH] Fix NULL pointer dereference in bl_free_device().
Date: Tue, 19 Jul 2016 13:30:51 +0200
Message-Id: <1468927851-2186-1-git-send-email-asavkov@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When bl_parse_deviceid() fails in bl_alloc_deviceid_node() on
blkdev_get_by_*() step we get an pnfs_block_dev struct that is
uninitialized except for bdev field which is set to whatever error
blkdev_get_by_*() returns.  bl_free_device() then tries to call
blkdev_put() if bdev is not 0 resulting in a wrong pointer dereference.

Fixing this by making sure bdev is not an error code in bl_free_device().

Signed-off-by: Artem Savkov <asavkov@redhat.com>
---
 fs/nfs/blocklayout/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
index 118252f..7db3af0 100644
--- a/fs/nfs/blocklayout/dev.c
+++ b/fs/nfs/blocklayout/dev.c
@@ -33,7 +33,7 @@ bl_free_device(struct pnfs_block_dev *dev)
 				pr_err("failed to unregister PR key.\n");
 		}
 
-		if (dev->bdev)
+		if (dev->bdev && !IS_ERR(dev->bdev))
 			blkdev_put(dev->bdev, FMODE_READ | FMODE_WRITE);
 	}
 }
-- 
2.5.5


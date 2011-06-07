Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:44101 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756044Ab1FGRfs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:35:48 -0400
Date: Tue, 7 Jun 2011 13:35:42 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 84/88] pnfs-block: fix blocklayoutdev.c for new
 blkdev_get_by_dev()
Message-ID: <749b82c976b5056af3ab7818eef4952c07d3ecba.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

blkdev_get has been replaced by blkdev_get_by_dev in 2.6.38, which now handles
exclusive use too (which we don't use).  Fix uses in blocklayout to match.

Signed-off-by: Jim Rees <rees@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayoutdev.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index 17bd25a..23469e3 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -55,7 +55,7 @@ struct block_device *nfs4_blkdev_get(dev_t dev)
 	struct block_device *bd;
 
 	dprintk("%s enter\n", __func__);
-	bd = open_by_devnum(dev, FMODE_READ);
+	bd = blkdev_get_by_dev(dev, FMODE_READ, NULL);
 	if (IS_ERR(bd))
 		goto fail;
 	return bd;
@@ -72,7 +72,6 @@ int nfs4_blkdev_put(struct block_device *bdev)
 {
 	dprintk("%s for device %d:%d\n", __func__, MAJOR(bdev->bd_dev),
 			MINOR(bdev->bd_dev));
-	bd_release(bdev);
 	return blkdev_put(bdev, FMODE_READ);
 }
 
-- 
1.7.4.1


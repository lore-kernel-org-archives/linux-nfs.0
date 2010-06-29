From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] SQUASHME: pnfs-block: nfs4_blk_add_block_disk ret must be signed
Date: Tue, 29 Jun 2010 15:06:51 +0300
Message-ID: <1277813211-13902-1-git-send-email-bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:27724 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752175Ab0F2MGy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jun 2010 08:06:54 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

otherwise checking for ret < 0 is futile.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayoutdev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index ef39c36..a866f5c 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -105,7 +105,8 @@ nfs4_blk_add_block_disk(struct device *cdev,
 	static char *claim_ptr = "I belong to pnfs block driver";
 	struct block_device *bdev;
 	struct gendisk *gd;
-	unsigned int major, minor, ret = 0;
+	unsigned int major, minor;
+	int ret;
 	dev_t dev;
 
 	dprintk("%s enter \n", __func__);
-- 
1.6.6.1


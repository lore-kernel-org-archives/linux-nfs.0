Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:51196 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752214AbaHUQHk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Aug 2014 12:07:40 -0400
Received: from ip-64-134-168-64.public.wayport.net ([64.134.168.64] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XKUtm-0000Ac-VN
	for linux-nfs@vger.kernel.org; Thu, 21 Aug 2014 16:07:39 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 11/19] pnfs/blocklayout: improve GETDEVICEINFO error reporting
Date: Thu, 21 Aug 2014 11:09:27 -0500
Message-Id: <1408637375-11343-12-git-send-email-hch@lst.de>
In-Reply-To: <1408637375-11343-1-git-send-email-hch@lst.de>
References: <pnfs block layout driver fixes V2>
 <1408637375-11343-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tell userspace what stage of GETDEVICEINFO failed so that there is a chance
to debug it, especially with the userspace daemon clusterf***k in the block
layout driver.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/blocklayoutdev.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index 04303b5..63f77925 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -150,7 +150,7 @@ nfs4_blk_decode_device(struct nfs_server *server,
 	remove_wait_queue(&nn->bl_wq, &wq);
 
 	if (reply->status != BL_DEVICE_REQUEST_PROC) {
-		dprintk("%s failed to open device: %d\n",
+		printk(KERN_WARNING "%s failed to decode device: %d\n",
 			__func__, reply->status);
 		rv = ERR_PTR(-EINVAL);
 		goto out;
@@ -159,7 +159,8 @@ nfs4_blk_decode_device(struct nfs_server *server,
 	bd = blkdev_get_by_dev(MKDEV(reply->major, reply->minor),
 			       FMODE_READ, NULL);
 	if (IS_ERR(bd)) {
-		dprintk("%s failed to open device : %ld\n", __func__,
+		printk(KERN_WARNING "%s failed to open device %d:%d (%ld)\n",
+			__func__, reply->major, reply->minor,
 			PTR_ERR(bd));
 		rv = ERR_CAST(bd);
 		goto out;
-- 
1.9.1


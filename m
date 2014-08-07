Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:45777 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754037AbaHGHVi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Aug 2014 03:21:38 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 09/17] pnfs/blocklayout: improve GETDEVICEINFO error reporting
Date: Thu,  7 Aug 2014 09:23:41 +0200
Message-Id: <1407396229-4785-10-git-send-email-hch@lst.de>
In-Reply-To: <1407396229-4785-1-git-send-email-hch@lst.de>
References: <1407396229-4785-1-git-send-email-hch@lst.de>
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


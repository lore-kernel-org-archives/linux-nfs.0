Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:49126 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754191AbcGHJlv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jul 2016 05:41:51 -0400
Received: from i60-34-157-115.s41.a006.ap.plala.or.jp ([60.34.157.115] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.85_2 #1 (Red Hat Linux))
	id 1bLSHy-0007Zy-Vz
	for linux-nfs@vger.kernel.org; Fri, 08 Jul 2016 09:41:39 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] nfs/blocklayout: use proper fmode for opening block devices
Date: Fri,  8 Jul 2016 18:41:28 +0900
Message-Id: <1467970890-11237-2-git-send-email-hch@lst.de>
In-Reply-To: <1467970890-11237-1-git-send-email-hch@lst.de>
References: <1467970890-11237-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This was fixed for the original block layout code a while ago, but also
needs to be fixed for the SCSI layout path.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/dev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
index e5b8967..7fb9c07 100644
--- a/fs/nfs/blocklayout/dev.c
+++ b/fs/nfs/blocklayout/dev.c
@@ -316,7 +316,7 @@ bl_parse_scsi(struct nfs_server *server, struct pnfs_block_dev *d,
 		return -EINVAL;
 	}
 
-	d->bdev = blkdev_get_by_path(devname, FMODE_READ, NULL);
+	d->bdev = blkdev_get_by_path(devname, FMODE_READ | FMODE_WRITE, NULL);
 	if (IS_ERR(d->bdev)) {
 		pr_warn("pNFS: failed to open device %s (%ld)\n",
 			devname, PTR_ERR(d->bdev));
@@ -352,7 +352,7 @@ bl_parse_scsi(struct nfs_server *server, struct pnfs_block_dev *d,
 	return 0;
 
 out_blkdev_put:
-	blkdev_put(d->bdev, FMODE_READ);
+	blkdev_put(d->bdev, FMODE_READ | FMODE_WRITE);
 	return error;
 }
 
-- 
2.1.4


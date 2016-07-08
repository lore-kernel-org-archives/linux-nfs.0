Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:49128 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754251AbcGHJlv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jul 2016 05:41:51 -0400
Received: from i60-34-157-115.s41.a006.ap.plala.or.jp ([60.34.157.115] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.85_2 #1 (Red Hat Linux))
	id 1bLSI1-0007a8-B2
	for linux-nfs@vger.kernel.org; Fri, 08 Jul 2016 09:41:41 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] nfs/blocklayout: refactor open-by-wwn
Date: Fri,  8 Jul 2016 18:41:29 +0900
Message-Id: <1467970890-11237-3-git-send-email-hch@lst.de>
In-Reply-To: <1467970890-11237-1-git-send-email-hch@lst.de>
References: <1467970890-11237-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current code works with the standard udev/systemd names, but we'll have
to add another method in the next patch.  Refactor it into a separate helper
to make room for the new variant.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/dev.c | 53 ++++++++++++++++++++++++------------------------
 1 file changed, 27 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
index 7fb9c07..ea70883 100644
--- a/fs/nfs/blocklayout/dev.c
+++ b/fs/nfs/blocklayout/dev.c
@@ -287,44 +287,45 @@ bl_validate_designator(struct pnfs_block_volume *v)
 	}
 }
 
+/*
+ * Try to open the udev path for the WWN.  At least on Debian the udev
+ * by-id path will always point to the dm-multipath device if one exists.
+ */
+static struct block_device *
+bl_open_udev_path(struct pnfs_block_volume *v)
+{
+	struct block_device *bdev;
+	const char *devname;
+
+	devname = kasprintf(GFP_KERNEL, "/dev/disk/by-id/wwn-0x%*phN",
+				v->scsi.designator_len, v->scsi.designator);
+	if (!devname)
+		return ERR_PTR(-ENOMEM);
+
+	bdev = blkdev_get_by_path(devname, FMODE_READ | FMODE_WRITE, NULL);
+	if (IS_ERR(bdev)) {
+		pr_warn("pNFS: failed to open device %s (%ld)\n",
+			devname, PTR_ERR(bdev));
+	}
+
+	kfree(devname);
+	return bdev;
+}
+
 static int
 bl_parse_scsi(struct nfs_server *server, struct pnfs_block_dev *d,
 		struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask)
 {
 	struct pnfs_block_volume *v = &volumes[idx];
 	const struct pr_ops *ops;
-	const char *devname;
 	int error;
 
 	if (!bl_validate_designator(v))
 		return -EINVAL;
 
-	switch (v->scsi.designator_len) {
-	case 8:
-		devname = kasprintf(GFP_KERNEL, "/dev/disk/by-id/wwn-0x%8phN",
-				v->scsi.designator);
-		break;
-	case 12:
-		devname = kasprintf(GFP_KERNEL, "/dev/disk/by-id/wwn-0x%12phN",
-				v->scsi.designator);
-		break;
-	case 16:
-		devname = kasprintf(GFP_KERNEL, "/dev/disk/by-id/wwn-0x%16phN",
-				v->scsi.designator);
-		break;
-	default:
-		return -EINVAL;
-	}
-
-	d->bdev = blkdev_get_by_path(devname, FMODE_READ | FMODE_WRITE, NULL);
-	if (IS_ERR(d->bdev)) {
-		pr_warn("pNFS: failed to open device %s (%ld)\n",
-			devname, PTR_ERR(d->bdev));
-		kfree(devname);
+	d->bdev = bl_open_udev_path(v);
+	if (IS_ERR(d->bdev))
 		return PTR_ERR(d->bdev);
-	}
-
-	kfree(devname);
 
 	d->len = i_size_read(d->bdev->bd_inode);
 	d->map = bl_map_simple;
-- 
2.1.4


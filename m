Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:49131 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754262AbcGHJlv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jul 2016 05:41:51 -0400
Received: from i60-34-157-115.s41.a006.ap.plala.or.jp ([60.34.157.115] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.85_2 #1 (Red Hat Linux))
	id 1bLSI3-0007aH-EF
	for linux-nfs@vger.kernel.org; Fri, 08 Jul 2016 09:41:43 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] nfs/blocklayout: support RH/Fedora dm-mpath device nodes
Date: Fri,  8 Jul 2016 18:41:30 +0900
Message-Id: <1467970890-11237-4-git-send-email-hch@lst.de>
In-Reply-To: <1467970890-11237-1-git-send-email-hch@lst.de>
References: <1467970890-11237-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of reusing the wwn-* names for multipath devices nodes RHEL and
Fedora introduce new dm-mpath-uuid-* nodes with a slightly different
naming scheme.  Try these names first to ensure we always get a
multipath-capable device if it exists.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/dev.c | 26 +++++++++++++++++++++++++-
 1 file changed, 25 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
index ea70883..436bb30 100644
--- a/fs/nfs/blocklayout/dev.c
+++ b/fs/nfs/blocklayout/dev.c
@@ -312,6 +312,28 @@ bl_open_udev_path(struct pnfs_block_volume *v)
 	return bdev;
 }
 
+/*
+ * Try to open the RH/Fedora specific dm-mpath udev path for this WWN, as the
+ * wwn- links will only point to the first discovered SCSI device there.
+ */
+static struct block_device *
+bl_open_dm_mpath_udev_path(struct pnfs_block_volume *v)
+{
+	struct block_device *bdev;
+	const char *devname;
+
+	devname = kasprintf(GFP_KERNEL,
+			"/dev/disk/by-id/dm-uuid-mpath-%d%*phN",
+			v->scsi.designator_type,
+			v->scsi.designator_len, v->scsi.designator);
+	if (!devname)
+		return ERR_PTR(-ENOMEM);
+
+	bdev = blkdev_get_by_path(devname, FMODE_READ | FMODE_WRITE, NULL);
+	kfree(devname);
+	return bdev;
+}
+
 static int
 bl_parse_scsi(struct nfs_server *server, struct pnfs_block_dev *d,
 		struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask)
@@ -323,7 +345,9 @@ bl_parse_scsi(struct nfs_server *server, struct pnfs_block_dev *d,
 	if (!bl_validate_designator(v))
 		return -EINVAL;
 
-	d->bdev = bl_open_udev_path(v);
+	d->bdev = bl_open_dm_mpath_udev_path(v);
+	if (IS_ERR(d->bdev))
+		d->bdev = bl_open_udev_path(v);
 	if (IS_ERR(d->bdev))
 		return PTR_ERR(d->bdev);
 
-- 
2.1.4


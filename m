Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38480 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753091AbdLHRxA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Dec 2017 12:53:00 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 2/3] pnfs/blocklayout: Revalidate SCSI disks after registration
Date: Fri,  8 Dec 2017 12:52:58 -0500
Message-Id: <7849a32ce8d429791eed114275496ec213dfaeb7.1512748321.git.bcodding@redhat.com>
In-Reply-To: <cover.1512748321.git.bcodding@redhat.com>
References: <cover.1512748321.git.bcodding@redhat.com>
In-Reply-To: <cover.1512748321.git.bcodding@redhat.com>
References: <cover.1512748321.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a SCSI device already has an exclusive access registrants only
reservation, the device's size cannot be known by the client until after
registration.  We should therefore delay setting the block device's length
until after the registration and revalidation of the disk.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/blocklayout/dev.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
index a69ef4e9c24c..4d319098f83b 100644
--- a/fs/nfs/blocklayout/dev.c
+++ b/fs/nfs/blocklayout/dev.c
@@ -366,7 +366,6 @@ bl_parse_scsi(struct nfs_server *server, struct pnfs_block_dev *d,
 		return PTR_ERR(bdev);
 	d->bdev = bdev;
 
-	d->len = i_size_read(d->bdev->bd_inode);
 	d->map = bl_map_simple;
 	d->pr_key = v->scsi.pr_key;
 
@@ -388,6 +387,13 @@ bl_parse_scsi(struct nfs_server *server, struct pnfs_block_dev *d,
 		goto out_blkdev_put;
 	}
 
+	error = revalidate_disk(d->bdev->bd_disk);
+	if (error) {
+		pr_err("pNFS: failed to revalidate block device %s.",
+				d->bdev->bd_disk->disk_name);
+		goto out_blkdev_put;
+	}
+	d->len = i_size_read(d->bdev->bd_inode);
 	d->pr_registered = true;
 	return 0;
 
-- 
2.9.3


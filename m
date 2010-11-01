Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:32830 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751047Ab0KARkE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Nov 2010 13:40:04 -0400
Date: Mon, 1 Nov 2010 13:40:01 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, sfaibish <sfaibish@emc.com>,
        peter honeyman <honey@citi.umich.edu>
Subject: [PATCH] Return failure from bl_initialize_mountpoint if we can't
 get the device for the disk list.
Message-ID: <20101101174001.GA6731@merit.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Jim Rees <rees@umich.edu>
---
 fs/nfs/blocklayout/blocklayout.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 57a7f04..b3ab4cb 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -677,7 +677,7 @@ static void free_blk_mountid(struct block_mount_id *mid)
 	}
 }
 
-/* This is mostly copied form the filelayout's get_device_info function.
+/* This is mostly copied from the filelayout's get_device_info function.
  * It seems much of this should be at the generic pnfs level.
  */
 static struct pnfs_block_dev *
@@ -796,8 +796,10 @@ bl_initialize_mountpoint(struct nfs_server *server, const struct nfs_fh *fh)
 			bdev = nfs4_blk_get_deviceinfo(server, fh,
 						     &dlist->dev_id[i],
 						     &block_disklist);
-			if (!bdev)
+			if (!bdev) {
+				status = -ENODEV;
 				goto out_error;
+			}
 			spin_lock(&b_mt_id->bm_lock);
 			list_add(&bdev->bm_node, &b_mt_id->bm_devlist);
 			spin_unlock(&b_mt_id->bm_lock);
-- 
1.7.1


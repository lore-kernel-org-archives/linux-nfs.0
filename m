Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:52475 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755985Ab1FGRfO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:35:14 -0400
Date: Tue, 7 Jun 2011 13:35:13 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 79/88] SQUASHME: pnfs-block: Return failure from
 bl_initialize_mountpoint
Message-ID: <8e0ac5f6ac5077568f8ac20807b57be83dd9ca60.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

if we can't get the device for the disk list.

Signed-off-by: Jim Rees <rees@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 5be912e..5f11fb8 100644
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
@@ -796,8 +796,10 @@ bl_set_layoutdriver(struct nfs_server *server, const struct nfs_fh *fh)
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
1.7.4.1


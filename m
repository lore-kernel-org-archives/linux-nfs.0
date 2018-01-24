Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41890 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933959AbeAXOsY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 24 Jan 2018 09:48:24 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: [PATCH] pnfs/blocklayout: Ensure disk address in block device map
Date: Wed, 24 Jan 2018 09:48:23 -0500
Message-Id: <8d0b4d04a683809e9986396840abcba1f5110dff.1516805178.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's possible that the device map is smaller than the offset into the
device for the I/O we're adding.  This probably indicates an error of some
sort (such as the dev->len = 0 due to the device being unreadable), so
let's add a check for it and bail out.  Otherwise, we risk botching the bio
calculations that follow.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/blocklayout/blocklayout.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 334570888649..6259ef20ee3e 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -137,6 +137,11 @@ bl_alloc_init_bio(int npg, struct block_device *bdev, sector_t disk_sector,
 	return bio;
 }
 
+static bool offset_in_map(sector_t isect, struct pnfs_block_dev_map *map)
+{
+	return isect >= map->start && isect < map->start + map->len;
+}
+
 static struct bio *
 do_add_page_to_bio(struct bio *bio, int npg, int rw, sector_t isect,
 		struct page *page, struct pnfs_block_dev_map *map,
@@ -156,8 +161,8 @@ do_add_page_to_bio(struct bio *bio, int npg, int rw, sector_t isect,
 
 	/* translate to physical disk offset */
 	disk_addr = (u64)isect << SECTOR_SHIFT;
-	if (disk_addr < map->start || disk_addr >= map->start + map->len) {
-		if (!dev->map(dev, disk_addr, map))
+	if (!offset_in_map(isect, map)) {
+		if (!dev->map(dev, disk_addr, map) || !offset_in_map(isect, map))
 			return ERR_PTR(-EIO);
 		bio = bl_submit_bio(bio);
 	}
-- 
2.9.3


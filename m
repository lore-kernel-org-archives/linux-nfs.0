Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40014 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751045AbeAYOg1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Jan 2018 09:36:27 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trondmy@gmail.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: [PATCH 2/2 v2] pnfs/blocklayout: Ensure disk address in block device map
Date: Thu, 25 Jan 2018 09:36:26 -0500
Message-Id: <449f4f239fbe974884b5823fba7c4551b57bc35b.1516887234.git.bcodding@redhat.com>
In-Reply-To: <03d5c8ee208f21b89a8d8ae9c7b8d15d9f7cd277.1516887234.git.bcodding@redhat.com>
References: <03d5c8ee208f21b89a8d8ae9c7b8d15d9f7cd277.1516887234.git.bcodding@redhat.com>
In-Reply-To: <03d5c8ee208f21b89a8d8ae9c7b8d15d9f7cd277.1516887234.git.bcodding@redhat.com>
References: <03d5c8ee208f21b89a8d8ae9c7b8d15d9f7cd277.1516887234.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's possible that the device map is smaller than the offset into the device
for the I/O we're adding.  Add a check for it and bail out, otherwise we
risk botching the bio calculations that follow.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/blocklayout/blocklayout.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 334570888649..9919d9e98fa6 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -137,6 +137,11 @@ bl_alloc_init_bio(int npg, struct block_device *bdev, sector_t disk_sector,
 	return bio;
 }
 
+static bool offset_in_map(u64 offset, struct pnfs_block_dev_map *map)
+{
+	return offset >= map->start && offset < map->start + map->len;
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
+	if (!offset_in_map(disk_addr, map)) {
+		if (!dev->map(dev, disk_addr, map) || !offset_in_map(disk_addr, map))
 			return ERR_PTR(-EIO);
 		bio = bl_submit_bio(bio);
 	}
-- 
2.9.3


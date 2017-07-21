Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.73]:52863 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752780AbdGUUQD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Jul 2017 16:16:03 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Benjamin Coddington <bcodding@redhat.com>,
        Alexey Dobriyan <adobriyan@gmail.com>,
        Jens Axboe <axboe@fb.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] [RESEND] nfs: blocklayout: avoid warnings on 32-bit sector_t
Date: Fri, 21 Jul 2017 22:15:18 +0200
Message-Id: <20170721201547.3358107-1-arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

sector_t can be either 32-bit or 64-bit wide, but in the former
case, the NFS blocklayout code produces a couple of warnings:

blocklayout.c: In function 'bl_read_pagelist':
blocklayout.c:225:45: error: large integer implicitly truncated to unsigned type [-Werror=overflow]
  struct pnfs_block_dev_map map = { .start = NFS4_MAX_UINT64 };
                                             ^
blocklayout.c:282:16: error: large integer implicitly truncated to unsigned type [-Werror=overflow]
    map.start = NFS4_MAX_UINT64;
                ^
blocklayout.c: In function 'bl_write_pagelist':
blocklayout.c:368:45: error: large integer implicitly truncated to unsigned type [-Werror=overflow]
  struct pnfs_block_dev_map map = { .start = NFS4_MAX_UINT64 };
                                             ^
blocklayout.c: In function 'bl_free_layout_hdr':
blocklayout.c:443:37: error: large integer implicitly truncated to unsigned type [-Werror=overflow]
  err = ext_tree_remove(bl, true, 0, LLONG_MAX);
                                     ^
blocklayout.c: In function 'bl_return_range':
blocklayout.c:708:9: error: large integer implicitly truncated to unsigned type [-Werror=overflow]
   end = round_down(NFS4_MAX_UINT64, PAGE_SIZE);

In all instances, NFS4_MAX_UINT64 is meant to just refer to the largest
representable unsigned integer, and the warning is for the implicit
type conversiont to a smaller type. As the conversion is ok, we
can use an explict cast to stop the warning.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 5c83746a0cf2 ("pnfs/blocklayout: in-kernel GETDEVICEINFO XDR parsing")
---
I sent this on Jan 25 2016 but got no reply while the problem
remains in linux-4.6-rc1. Please apply.
---
 fs/nfs/blocklayout/blocklayout.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index d8863a804b15..52044865c40b 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -224,7 +224,7 @@ static enum pnfs_try_status
 bl_read_pagelist(struct nfs_pgio_header *header)
 {
 	struct pnfs_block_layout *bl = BLK_LSEG2EXT(header->lseg);
-	struct pnfs_block_dev_map map = { .start = NFS4_MAX_UINT64 };
+	struct pnfs_block_dev_map map = { .start = (sector_t)NFS4_MAX_UINT64 };
 	struct bio *bio = NULL;
 	struct pnfs_block_extent be;
 	sector_t isect, extent_length = 0;
@@ -281,7 +281,7 @@ bl_read_pagelist(struct nfs_pgio_header *header)
 			zero_user_segment(pages[i], pg_offset, pg_len);
 
 			/* invalidate map */
-			map.start = NFS4_MAX_UINT64;
+			map.start = (sector_t)NFS4_MAX_UINT64;
 		} else {
 			bio = do_add_page_to_bio(bio,
 						 header->page_array.npages - i,
@@ -368,7 +368,7 @@ static enum pnfs_try_status
 bl_write_pagelist(struct nfs_pgio_header *header, int sync)
 {
 	struct pnfs_block_layout *bl = BLK_LSEG2EXT(header->lseg);
-	struct pnfs_block_dev_map map = { .start = NFS4_MAX_UINT64 };
+	struct pnfs_block_dev_map map = { .start = (sector_t)NFS4_MAX_UINT64 };
 	struct bio *bio = NULL;
 	struct pnfs_block_extent be;
 	sector_t isect, extent_length = 0;
@@ -443,7 +443,7 @@ static void bl_free_layout_hdr(struct pnfs_layout_hdr *lo)
 
 	dprintk("%s enter\n", __func__);
 
-	err = ext_tree_remove(bl, true, 0, LLONG_MAX);
+	err = ext_tree_remove(bl, true, 0, (sector_t)LLONG_MAX);
 	WARN_ON(err);
 
 	kfree(bl);
@@ -721,7 +721,7 @@ bl_return_range(struct pnfs_layout_hdr *lo,
 
 		end = offset + (range->length >> SECTOR_SHIFT);
 	} else {
-		end = round_down(NFS4_MAX_UINT64, PAGE_SIZE);
+		end = round_down((sector_t)NFS4_MAX_UINT64, PAGE_SIZE);
 	}
 
 	ext_tree_remove(bl, range->iomode & IOMODE_RW, offset, end);
-- 
2.9.0


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:45781 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754072AbaHGHVk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Aug 2014 03:21:40 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 11/17] pnfs/blocklayout: correctly decrement extent length
Date: Thu,  7 Aug 2014 09:23:43 +0200
Message-Id: <1407396229-4785-12-git-send-email-hch@lst.de>
In-Reply-To: <1407396229-4785-1-git-send-email-hch@lst.de>
References: <1407396229-4785-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we do non-page sized reads we can underflow the extent_length variable
and read incorrect data.  Fix the extent_length calculation and change to
defensive <= checks for the extent length in the read and write path.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/blocklayout.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 5427ae7..87a633d 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -272,7 +272,7 @@ bl_read_pagelist(struct nfs_pgio_header *hdr)
 	isect = (sector_t) (f_offset >> SECTOR_SHIFT);
 	/* Code assumes extents are page-aligned */
 	for (i = pg_index; i < hdr->page_array.npages; i++) {
-		if (!extent_length) {
+		if (extent_length <= 0) {
 			/* We've used up the previous extent */
 			bl_put_extent(be);
 			bl_put_extent(cow_read);
@@ -303,6 +303,7 @@ bl_read_pagelist(struct nfs_pgio_header *hdr)
 			f_offset += pg_len;
 			bytes_left -= pg_len;
 			isect += (pg_offset >> SECTOR_SHIFT);
+			extent_length -= (pg_offset >> SECTOR_SHIFT);
 		} else {
 			pg_offset = 0;
 			pg_len = PAGE_CACHE_SIZE;
@@ -333,7 +334,7 @@ bl_read_pagelist(struct nfs_pgio_header *hdr)
 			}
 		}
 		isect += (pg_len >> SECTOR_SHIFT);
-		extent_length -= PAGE_CACHE_SECTORS;
+		extent_length -= (pg_len >> SECTOR_SHIFT);
 	}
 	if ((isect << SECTOR_SHIFT) >= header->inode->i_size) {
 		hdr->res.eof = 1;
@@ -797,7 +798,7 @@ next_page:
 	/* Middle pages */
 	pg_index = header->args.pgbase >> PAGE_CACHE_SHIFT;
 	for (i = pg_index; i < header->page_array.npages; i++) {
-		if (!extent_length) {
+		if (extent_length <= 0) {
 			/* We've used up the previous extent */
 			bl_put_extent(be);
 			bl_put_extent(cow_read);
-- 
1.9.1


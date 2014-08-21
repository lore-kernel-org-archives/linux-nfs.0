Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:51197 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234AbaHUQHm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Aug 2014 12:07:42 -0400
Received: from ip-64-134-168-64.public.wayport.net ([64.134.168.64] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XKUto-0000Ag-T8
	for linux-nfs@vger.kernel.org; Thu, 21 Aug 2014 16:07:41 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 12/19] pnfs/blocklayout: plug block queues
Date: Thu, 21 Aug 2014 11:09:28 -0500
Message-Id: <1408637375-11343-13-git-send-email-hch@lst.de>
In-Reply-To: <1408637375-11343-1-git-send-email-hch@lst.de>
References: <pnfs block layout driver fixes V2>
 <1408637375-11343-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make sure the block queue is plugged when performing pNFS blocklayout I/O.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/blocklayout.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 6c1a421..5427ae7 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -255,6 +255,7 @@ bl_read_pagelist(struct nfs_pgio_header *hdr)
 	struct page **pages = hdr->args.pages;
 	int pg_index = hdr->args.pgbase >> PAGE_CACHE_SHIFT;
 	const bool is_dio = (header->dreq != NULL);
+	struct blk_plug plug;
 
 	dprintk("%s enter nr_pages %u offset %lld count %u\n", __func__,
 		hdr->page_array.npages, f_offset,
@@ -266,6 +267,8 @@ bl_read_pagelist(struct nfs_pgio_header *hdr)
 	par->pnfs_callback = bl_end_par_io_read;
 	/* At this point, we can no longer jump to use_mds */
 
+	blk_start_plug(&plug);
+
 	isect = (sector_t) (f_offset >> SECTOR_SHIFT);
 	/* Code assumes extents are page-aligned */
 	for (i = pg_index; i < hdr->page_array.npages; i++) {
@@ -342,6 +345,7 @@ out:
 	bl_put_extent(be);
 	bl_put_extent(cow_read);
 	bl_submit_bio(READ, bio);
+	blk_finish_plug(&plug);
 	put_parallel(par);
 	return PNFS_ATTEMPTED;
 
@@ -688,9 +692,12 @@ bl_write_pagelist(struct nfs_pgio_header *header, int sync)
 	u64 temp;
 	int npg_per_block =
 	    NFS_SERVER(header->inode)->pnfs_blksize >> PAGE_CACHE_SHIFT;
+	struct blk_plug plug;
 
 	dprintk("%s enter, %Zu@%lld\n", __func__, count, offset);
 
+	blk_start_plug(&plug);
+
 	if (header->dreq != NULL &&
 	    (!IS_ALIGNED(offset, NFS_SERVER(header->inode)->pnfs_blksize) ||
 	     !IS_ALIGNED(count, NFS_SERVER(header->inode)->pnfs_blksize))) {
@@ -894,9 +901,11 @@ out:
 	bl_put_extent(be);
 	bl_put_extent(cow_read);
 	bl_submit_bio(WRITE, bio);
+	blk_finish_plug(&plug);
 	put_parallel(par);
 	return PNFS_ATTEMPTED;
 out_mds:
+	blk_finish_plug(&plug);
 	bl_put_extent(be);
 	bl_put_extent(cow_read);
 	kfree(par);
-- 
1.9.1


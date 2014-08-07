Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:45779 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754238AbaHGHVj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Aug 2014 03:21:39 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 10/17] pnfs/blocklayout: plug block queues
Date: Thu,  7 Aug 2014 09:23:42 +0200
Message-Id: <1407396229-4785-11-git-send-email-hch@lst.de>
In-Reply-To: <1407396229-4785-1-git-send-email-hch@lst.de>
References: <1407396229-4785-1-git-send-email-hch@lst.de>
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


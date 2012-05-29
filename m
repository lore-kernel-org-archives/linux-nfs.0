Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:56796 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025Ab2E2Ejj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 May 2012 00:39:39 -0400
Received: by mail-pb0-f46.google.com with SMTP id rp8so5401164pbb.19
        for <linux-nfs@vger.kernel.org>; Mon, 28 May 2012 21:39:39 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, bharrosh@panasas.com,
        Peng Tao <tao.peng@emc.com>
Subject: [PATCH-v2 3/3] pnfsblock: call blk_plug functions for direct IO
Date: Tue, 29 May 2012 12:38:54 +0800
Message-Id: <1338266334-11490-4-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1338266334-11490-1-git-send-email-bergwolf@gmail.com>
References: <1338266334-11490-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS DIO bypasses generic DIO code path. So we need to plug/unplug
on our own.

Signed-off-by: Peng Tao <tao.peng@emc.com>
---
 fs/nfs/blocklayout/blocklayout.c |   47 +++++++++++++++++++++++++++++++++++++-
 1 files changed, 46 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index bab432f..b48b08b 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -251,6 +251,7 @@ bl_read_pagelist(struct nfs_read_data *rdata)
 
 	dprintk("%s enter nr_pages %u offset %lld count %u\n", __func__,
 	       rdata->pages.npages, f_offset, (unsigned int)rdata->args.count);
+	BUG_ON(header->dreq && header->layout_private == NULL);
 
 	if (!bl_check_alignment(f_offset, rdata->args.count, PAGE_CACHE_MASK))
 		goto use_mds;
@@ -320,9 +321,17 @@ out:
 	bl_put_extent(cow_read);
 	bl_submit_bio(READ, bio);
 	put_parallel(par);
+	if (header->dreq && !header->moreio) {
+		blk_finish_plug((struct blk_plug *)header->layout_private);
+		kfree(header->layout_private);
+	}
 	return PNFS_ATTEMPTED;
 
- use_mds:
+use_mds:
+	if (header->dreq) {
+		blk_finish_plug((struct blk_plug *)header->layout_private);
+		kfree(header->layout_private);
+	}
 	dprintk("Giving up and using normal NFS\n");
 	return PNFS_NOT_ATTEMPTED;
 }
@@ -575,6 +584,8 @@ bl_write_pagelist(struct nfs_write_data *wdata, int sync)
 	unsigned long blkmask = PAGE_CACHE_MASK;
 
 	dprintk("%s enter, %Zu@%lld\n", __func__, count, offset);
+	BUG_ON(header->dreq && header->layout_private == NULL);
+
 	/* Check for alignment first */
 	if (header->dreq)
 		blkmask = NFS_SERVER(header->inode)->pnfs_blksize - 1;
@@ -740,8 +751,16 @@ out:
 	bl_put_extent(be);
 	bl_submit_bio(WRITE, bio);
 	put_parallel(par);
+	if (header->dreq && !header->moreio) {
+		blk_finish_plug((struct blk_plug *)header->layout_private);
+		kfree(header->layout_private);
+	}
 	return PNFS_ATTEMPTED;
 out_mds:
+	if (header->dreq) {
+		blk_finish_plug((struct blk_plug *)header->layout_private);
+		kfree(header->layout_private);
+	}
 	bl_put_extent(be);
 	kfree(par);
 	return PNFS_NOT_ATTEMPTED;
@@ -1017,15 +1036,30 @@ bl_clear_layoutdriver(struct nfs_server *server)
 static void
 bl_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 {
+	BUG_ON(pgio->pg_layout_private != NULL);
+
 	if (!bl_check_alignment(req->wb_offset, req->wb_bytes, PAGE_CACHE_MASK))
 		nfs_pageio_reset_read_mds(pgio);
 	else
 		pnfs_generic_pg_init_read(pgio, req);
+
+	if (pgio->pg_dreq && pgio->pg_lseg) {
+		struct blk_plug *plug;
+		/* Freed in bl_read_pagelist */
+		plug = kmalloc(sizeof(struct blk_plug), GFP_KERNEL);
+		if (plug != NULL) {
+			blk_start_plug(plug);
+			pgio->pg_layout_private = plug;
+		} else
+			nfs_pageio_reset_read_mds(pgio);
+	}
 }
 
 static void
 bl_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 {
+	BUG_ON(pgio->pg_layout_private != NULL);
+
 	if (pgio->pg_dreq) {
 		/* Direct write should be blksize aligned */
 		unsigned blkmask = NFS_SERVER(pgio->pg_inode)->pnfs_blksize - 1;
@@ -1038,6 +1072,17 @@ bl_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 		nfs_pageio_reset_write_mds(pgio);
 	else
 		pnfs_generic_pg_init_write(pgio, req);
+
+	if (pgio->pg_dreq && pgio->pg_lseg) {
+		struct blk_plug *plug;
+		/* Freed in bl_write_pagelist */
+		plug = kmalloc(sizeof(struct blk_plug), GFP_NOFS);
+		if (plug != NULL) {
+			blk_start_plug(plug);
+			pgio->pg_layout_private = plug;
+		} else
+			nfs_pageio_reset_write_mds(pgio);
+	}
 }
 
 static const struct nfs_pageio_ops bl_pg_read_ops = {
-- 
1.7.1.262.g5ef3d


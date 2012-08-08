Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:50212 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754641Ab2HHByp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Aug 2012 21:54:45 -0400
Received: by ggnl2 with SMTP id l2so274786ggn.19
        for <linux-nfs@vger.kernel.org>; Tue, 07 Aug 2012 18:54:44 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] Revert "pnfsblock: bail out partial page IO"
Date: Wed,  8 Aug 2012 09:54:11 +0800
Message-Id: <1344390854-1771-2-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1344390854-1771-1-git-send-email-bergwolf@gmail.com>
References: <1344390854-1771-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit 159e0561e322dd8008fff59e36efff8d2bdd0b0e in favor
of a complete alignment fix.

Signed-off-by: Peng Tao <tao.peng@emc.com>
---
 fs/nfs/blocklayout/blocklayout.c |   39 ++-----------------------------------
 1 files changed, 3 insertions(+), 36 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index dd392ed..7ae8a60 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -228,14 +228,6 @@ bl_end_par_io_read(void *data, int unused)
 	schedule_work(&rdata->task.u.tk_work);
 }
 
-static bool
-bl_check_alignment(u64 offset, u32 len, unsigned long blkmask)
-{
-	if ((offset & blkmask) || (len & blkmask))
-		return false;
-	return true;
-}
-
 static enum pnfs_try_status
 bl_read_pagelist(struct nfs_read_data *rdata)
 {
@@ -252,9 +244,6 @@ bl_read_pagelist(struct nfs_read_data *rdata)
 	dprintk("%s enter nr_pages %u offset %lld count %u\n", __func__,
 	       rdata->pages.npages, f_offset, (unsigned int)rdata->args.count);
 
-	if (!bl_check_alignment(f_offset, rdata->args.count, PAGE_CACHE_MASK))
-		goto use_mds;
-
 	par = alloc_parallel(rdata);
 	if (!par)
 		goto use_mds;
@@ -563,7 +552,7 @@ bl_write_pagelist(struct nfs_write_data *wdata, int sync)
 	struct bio *bio = NULL;
 	struct pnfs_block_extent *be = NULL, *cow_read = NULL;
 	sector_t isect, last_isect = 0, extent_length = 0;
-	struct parallel_io *par = NULL;
+	struct parallel_io *par;
 	loff_t offset = wdata->args.offset;
 	size_t count = wdata->args.count;
 	struct page **pages = wdata->args.pages;
@@ -574,10 +563,6 @@ bl_write_pagelist(struct nfs_write_data *wdata, int sync)
 	    NFS_SERVER(header->inode)->pnfs_blksize >> PAGE_CACHE_SHIFT;
 
 	dprintk("%s enter, %Zu@%lld\n", __func__, count, offset);
-	/* Check for alignment first */
-	if (!bl_check_alignment(offset, count, PAGE_CACHE_MASK))
-		goto out_mds;
-
 	/* At this point, wdata->pages is a (sequential) list of nfs_pages.
 	 * We want to write each, and if there is an error set pnfs_error
 	 * to have it redone using nfs.
@@ -1011,32 +996,14 @@ bl_clear_layoutdriver(struct nfs_server *server)
 	return 0;
 }
 
-static void
-bl_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
-{
-	if (!bl_check_alignment(req->wb_offset, req->wb_bytes, PAGE_CACHE_MASK))
-		nfs_pageio_reset_read_mds(pgio);
-	else
-		pnfs_generic_pg_init_read(pgio, req);
-}
-
-static void
-bl_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
-{
-	if (!bl_check_alignment(req->wb_offset, req->wb_bytes, PAGE_CACHE_MASK))
-		nfs_pageio_reset_write_mds(pgio);
-	else
-		pnfs_generic_pg_init_write(pgio, req);
-}
-
 static const struct nfs_pageio_ops bl_pg_read_ops = {
-	.pg_init = bl_pg_init_read,
+	.pg_init = pnfs_generic_pg_init_read,
 	.pg_test = pnfs_generic_pg_test,
 	.pg_doio = pnfs_generic_pg_readpages,
 };
 
 static const struct nfs_pageio_ops bl_pg_write_ops = {
-	.pg_init = bl_pg_init_write,
+	.pg_init = pnfs_generic_pg_init_write,
 	.pg_test = pnfs_generic_pg_test,
 	.pg_doio = pnfs_generic_pg_writepages,
 };
-- 
1.7.1.262.g5ef3d


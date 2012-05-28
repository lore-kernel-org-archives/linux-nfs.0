Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:56902 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753757Ab2E1SKm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 May 2012 14:10:42 -0400
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org,
        stable@vger.kernel.org, Peng Tao <tao.peng@emc.com>
Subject: [PATCH] pnfsblock: bail out partial page IO
Date: Tue, 29 May 2012 02:07:23 +0800
Message-Id: <1338228443-4883-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Current block layout driver read/write code assumes page
aligned IO in many places. Add a checker to validate the assumption.

Cc: stable@vger.kernel.org
Signed-off-by: Peng Tao <tao.peng@emc.com>
---
This is the minimal patch for buffer IO case. I will cook DIO alignment checker
based on it, since DIO isn't needed for stable.

 fs/nfs/blocklayout/blocklayout.c |   39 +++++++++++++++++++++++++++++++++++--
 1 files changed, 36 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 7ae8a60..447f8d1 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -228,6 +228,14 @@ bl_end_par_io_read(void *data, int unused)
 	schedule_work(&rdata->task.u.tk_work);
 }
 
+static bool
+bl_nfspage_aligned(u64 offset, u32 len, u32 blkmask)
+{
+	if ((offset & blkmask) || (len & blkmask))
+		return false;
+	return true;
+}
+
 static enum pnfs_try_status
 bl_read_pagelist(struct nfs_read_data *rdata)
 {
@@ -244,6 +252,9 @@ bl_read_pagelist(struct nfs_read_data *rdata)
 	dprintk("%s enter nr_pages %u offset %lld count %u\n", __func__,
 	       rdata->pages.npages, f_offset, (unsigned int)rdata->args.count);
 
+	if (!bl_nfspage_aligned(f_offset, rdata->args.count, PAGE_CACHE_MASK))
+		goto use_mds;
+
 	par = alloc_parallel(rdata);
 	if (!par)
 		goto use_mds;
@@ -552,7 +563,7 @@ bl_write_pagelist(struct nfs_write_data *wdata, int sync)
 	struct bio *bio = NULL;
 	struct pnfs_block_extent *be = NULL, *cow_read = NULL;
 	sector_t isect, last_isect = 0, extent_length = 0;
-	struct parallel_io *par;
+	struct parallel_io *par = NULL;
 	loff_t offset = wdata->args.offset;
 	size_t count = wdata->args.count;
 	struct page **pages = wdata->args.pages;
@@ -563,6 +574,10 @@ bl_write_pagelist(struct nfs_write_data *wdata, int sync)
 	    NFS_SERVER(header->inode)->pnfs_blksize >> PAGE_CACHE_SHIFT;
 
 	dprintk("%s enter, %Zu@%lld\n", __func__, count, offset);
+	/* Check for alignment first */
+	if (!bl_nfspage_aligned(offset, count, PAGE_CACHE_MASK))
+		goto out_mds;
+
 	/* At this point, wdata->pages is a (sequential) list of nfs_pages.
 	 * We want to write each, and if there is an error set pnfs_error
 	 * to have it redone using nfs.
@@ -996,14 +1011,32 @@ bl_clear_layoutdriver(struct nfs_server *server)
 	return 0;
 }
 
+static void
+bl_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
+{
+	if (!bl_nfspage_aligned(req->wb_offset, req->wb_bytes, PAGE_CACHE_MASK))
+		nfs_pageio_reset_read_mds(pgio);
+	else
+		pnfs_generic_pg_init_read(pgio, req);
+}
+
+static void
+bl_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
+{
+	if (!bl_nfspage_aligned(req->wb_offset, req->wb_bytes, PAGE_CACHE_MASK))
+		nfs_pageio_reset_write_mds(pgio);
+	else
+		pnfs_generic_pg_init_write(pgio, req);
+}
+
 static const struct nfs_pageio_ops bl_pg_read_ops = {
-	.pg_init = pnfs_generic_pg_init_read,
+	.pg_init = bl_pg_init_read,
 	.pg_test = pnfs_generic_pg_test,
 	.pg_doio = pnfs_generic_pg_readpages,
 };
 
 static const struct nfs_pageio_ops bl_pg_write_ops = {
-	.pg_init = pnfs_generic_pg_init_write,
+	.pg_init = bl_pg_init_write,
 	.pg_test = pnfs_generic_pg_test,
 	.pg_doio = pnfs_generic_pg_writepages,
 };
-- 
1.7.1.262.g5ef3d


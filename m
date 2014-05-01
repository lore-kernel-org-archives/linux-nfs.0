Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:58055 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871AbaEATOk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 May 2014 15:14:40 -0400
Received: by mail-ie0-f174.google.com with SMTP id ar20so3999886iec.19
        for <linux-nfs@vger.kernel.org>; Thu, 01 May 2014 12:14:40 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 2/3] nfs: rename members of nfs_pgio_data
Date: Thu,  1 May 2014 15:14:52 -0400
Message-Id: <1398971693-82399-3-git-send-email-dros@primarydata.com>
In-Reply-To: <1398971693-82399-1-git-send-email-dros@primarydata.com>
References: <1398971693-82399-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rename "verf" to "rpc_verf" and "pages" to "page_array" to prepare for
merge of nfs_pgio_data and nfs_pgio_header.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/blocklayout/blocklayout.c | 15 +++++++++------
 fs/nfs/objlayout/objlayout.c     |  4 ++--
 fs/nfs/pageio.c                  | 10 +++++-----
 fs/nfs/write.c                   |  4 ++--
 include/linux/nfs_xdr.h          |  4 ++--
 5 files changed, 20 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 9b431f4..2dfeac1 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -258,7 +258,8 @@ bl_read_pagelist(struct nfs_pgio_data *rdata)
 	const bool is_dio = (header->dreq != NULL);
 
 	dprintk("%s enter nr_pages %u offset %lld count %u\n", __func__,
-	       rdata->pages.npages, f_offset, (unsigned int)rdata->args.count);
+		rdata->page_array.npages, f_offset,
+		(unsigned int)rdata->args.count);
 
 	par = alloc_parallel(rdata);
 	if (!par)
@@ -268,7 +269,7 @@ bl_read_pagelist(struct nfs_pgio_data *rdata)
 
 	isect = (sector_t) (f_offset >> SECTOR_SHIFT);
 	/* Code assumes extents are page-aligned */
-	for (i = pg_index; i < rdata->pages.npages; i++) {
+	for (i = pg_index; i < rdata->page_array.npages; i++) {
 		if (!extent_length) {
 			/* We've used up the previous extent */
 			bl_put_extent(be);
@@ -317,7 +318,8 @@ bl_read_pagelist(struct nfs_pgio_data *rdata)
 			struct pnfs_block_extent *be_read;
 
 			be_read = (hole && cow_read) ? cow_read : be;
-			bio = do_add_page_to_bio(bio, rdata->pages.npages - i,
+			bio = do_add_page_to_bio(bio,
+						 rdata->page_array.npages - i,
 						 READ,
 						 isect, pages[i], be_read,
 						 bl_end_io_read, par,
@@ -699,7 +701,7 @@ bl_write_pagelist(struct nfs_pgio_data *wdata, int sync)
 		dprintk("pnfsblock nonblock aligned DIO writes. Resend MDS\n");
 		goto out_mds;
 	}
-	/* At this point, wdata->pages is a (sequential) list of nfs_pages.
+	/* At this point, wdata->page_aray is a (sequential) list of nfs_pages.
 	 * We want to write each, and if there is an error set pnfs_error
 	 * to have it redone using nfs.
 	 */
@@ -791,7 +793,7 @@ next_page:
 
 	/* Middle pages */
 	pg_index = wdata->args.pgbase >> PAGE_CACHE_SHIFT;
-	for (i = pg_index; i < wdata->pages.npages; i++) {
+	for (i = pg_index; i < wdata->page_array.npages; i++) {
 		if (!extent_length) {
 			/* We've used up the previous extent */
 			bl_put_extent(be);
@@ -862,7 +864,8 @@ next_page:
 		}
 
 
-		bio = do_add_page_to_bio(bio, wdata->pages.npages - i, WRITE,
+		bio = do_add_page_to_bio(bio, wdata->page_array.npages - i,
+					 WRITE,
 					 isect, pages[i], be,
 					 bl_end_io_write, par,
 					 pg_offset, pg_len);
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 2f955f6..5e95196 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -329,7 +329,7 @@ objlayout_write_done(struct objlayout_io_res *oir, ssize_t status, bool sync)
 	oir->status = wdata->task.tk_status = status;
 	if (status >= 0) {
 		wdata->res.count = status;
-		wdata->verf.committed = oir->committed;
+		wdata->rpc_verf.committed = oir->committed;
 	} else {
 		wdata->header->pnfs_error = status;
 	}
@@ -337,7 +337,7 @@ objlayout_write_done(struct objlayout_io_res *oir, ssize_t status, bool sync)
 	/* must not use oir after this point */
 
 	dprintk("%s: Return status %zd committed %d sync=%d\n", __func__,
-		status, wdata->verf.committed, sync);
+		status, wdata->rpc_verf.committed, sync);
 
 	if (sync)
 		pnfs_ld_write_done(wdata);
diff --git a/fs/nfs/pageio.c b/fs/nfs/pageio.c
index de8bcb4..c6a5263 100644
--- a/fs/nfs/pageio.c
+++ b/fs/nfs/pageio.c
@@ -53,8 +53,8 @@ void nfs_pgio_data_destroy(struct nfs_pgio_data *data)
 	struct nfs_pgio_header *hdr = data->header;
 
 	put_nfs_open_context(data->args.context);
-	if (data->pages.pagevec != data->pages.page_array)
-		kfree(data->pages.pagevec);
+	if (data->page_array.pagevec != data->page_array.page_array)
+		kfree(data->page_array.pagevec);
 	if (atomic_dec_and_test(&hdr->refcnt))
 		hdr->completion_ops->completion(hdr);
 }
@@ -74,7 +74,7 @@ static void nfs_pgio_rpcsetup(struct nfs_pgio_data *data,
 	/* pnfs_set_layoutcommit needs this */
 	data->mds_offset = data->args.offset;
 	data->args.pgbase = req->wb_pgbase + offset;
-	data->args.pages  = data->pages.pagevec;
+	data->args.pages  = data->page_array.pagevec;
 	data->args.count  = count;
 	data->args.context = get_nfs_open_context(req->wb_context);
 	data->args.lock_context = req->wb_lock_context;
@@ -92,7 +92,7 @@ static void nfs_pgio_rpcsetup(struct nfs_pgio_data *data,
 	data->res.fattr   = &data->fattr;
 	data->res.count   = count;
 	data->res.eof     = 0;
-	data->res.verf    = &data->verf;
+	data->res.verf    = &data->rpc_verf;
 	nfs_fattr_init(&data->fattr);
 }
 
@@ -184,7 +184,7 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
 
 	data = &hdr->data;
 	nfs_init_cinfo(&cinfo, desc->pg_inode, desc->pg_dreq);
-	pages = data->pages.pagevec;
+	pages = data->page_array.pagevec;
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index ffcbb2d..04fbd1c 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1093,8 +1093,8 @@ static void nfs_writeback_release_common(struct nfs_pgio_data *data)
 		if (test_bit(NFS_IOHDR_NEED_RESCHED, &hdr->flags))
 			; /* Do nothing */
 		else if (!test_and_set_bit(NFS_IOHDR_NEED_COMMIT, &hdr->flags))
-			memcpy(&hdr->verf, &data->verf, sizeof(hdr->verf));
-		else if (memcmp(&hdr->verf, &data->verf, sizeof(hdr->verf)))
+			memcpy(&hdr->verf, &data->rpc_verf, sizeof(hdr->verf));
+		else if (memcmp(&hdr->verf, &data->rpc_verf, sizeof(hdr->verf)))
 			set_bit(NFS_IOHDR_NEED_RESCHED, &hdr->flags);
 		spin_unlock(&hdr->lock);
 	}
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index a7ccc8c..8564539 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1261,13 +1261,13 @@ struct nfs_pgio_data {
 	struct list_head	list;
 	struct rpc_task		task;
 	struct nfs_fattr	fattr;
-	struct nfs_writeverf	verf;		/* Used for writes */
+	struct nfs_writeverf	rpc_verf;	/* Used for writes */
 	struct nfs_pgio_args	args;		/* argument struct */
 	struct nfs_pgio_res	res;		/* result struct */
 	unsigned long		timestamp;	/* For lease renewal */
 	int (*pgio_done_cb)(struct rpc_task *task, struct nfs_pgio_data *data);
 	__u64			mds_offset;	/* Filelayout dense stripe */
-	struct nfs_page_array	pages;
+	struct nfs_page_array	page_array;
 	struct nfs_client	*ds_clp;	/* pNFS data server */
 	int			ds_idx;		/* ds index if ds_clp is set */
 };
-- 
1.8.5.2 (Apple Git-48)


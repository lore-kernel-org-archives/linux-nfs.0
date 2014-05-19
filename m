Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:59073 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003AbaESPPR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2014 11:15:17 -0400
Received: by mail-ie0-f182.google.com with SMTP id as1so2302245iec.27
        for <linux-nfs@vger.kernel.org>; Mon, 19 May 2014 08:15:16 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 2/8] nfs: rename members of nfs_pgio_data
Date: Mon, 19 May 2014 11:15:02 -0400
Message-Id: <1400512508-7530-3-git-send-email-dros@primarydata.com>
In-Reply-To: <1400512508-7530-1-git-send-email-dros@primarydata.com>
References: <1400512508-7530-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rename "verf" to "writeverf" and "pages" to "page_array" to prepare for
merge of nfs_pgio_data and nfs_pgio_header.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/blocklayout/blocklayout.c | 17 ++++++++++-------
 fs/nfs/objlayout/objlayout.c     |  4 ++--
 fs/nfs/pagelist.c                | 12 ++++++------
 fs/nfs/write.c                   |  9 +++++----
 include/linux/nfs_xdr.h          |  4 ++--
 5 files changed, 25 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 9b431f4..36b01ce 100644
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
@@ -446,7 +448,7 @@ static void bl_end_par_io_write(void *data, int num_se)
 	}
 
 	wdata->task.tk_status = wdata->header->pnfs_error;
-	wdata->verf.committed = NFS_FILE_SYNC;
+	wdata->writeverf.committed = NFS_FILE_SYNC;
 	INIT_WORK(&wdata->task.u.tk_work, bl_write_cleanup);
 	schedule_work(&wdata->task.u.tk_work);
 }
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
index 2f955f6..71dd662 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -329,7 +329,7 @@ objlayout_write_done(struct objlayout_io_res *oir, ssize_t status, bool sync)
 	oir->status = wdata->task.tk_status = status;
 	if (status >= 0) {
 		wdata->res.count = status;
-		wdata->verf.committed = oir->committed;
+		wdata->writeverf.committed = oir->committed;
 	} else {
 		wdata->header->pnfs_error = status;
 	}
@@ -337,7 +337,7 @@ objlayout_write_done(struct objlayout_io_res *oir, ssize_t status, bool sync)
 	/* must not use oir after this point */
 
 	dprintk("%s: Return status %zd committed %d sync=%d\n", __func__,
-		status, wdata->verf.committed, sync);
+		status, wdata->writeverf.committed, sync);
 
 	if (sync)
 		pnfs_ld_write_done(wdata);
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 6101ab8..37f407a 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -485,7 +485,7 @@ EXPORT_SYMBOL_GPL(nfs_pgio_header_free);
 static bool nfs_pgio_data_init(struct nfs_pgio_header *hdr,
 			       unsigned int pagecount)
 {
-	if (nfs_pgarray_set(&hdr->data.pages, pagecount)) {
+	if (nfs_pgarray_set(&hdr->data.page_array, pagecount)) {
 		hdr->data.header = hdr;
 		atomic_inc(&hdr->refcnt);
 		return true;
@@ -502,8 +502,8 @@ void nfs_pgio_data_destroy(struct nfs_pgio_data *data)
 	struct nfs_pgio_header *hdr = data->header;
 
 	put_nfs_open_context(data->args.context);
-	if (data->pages.pagevec != data->pages.page_array)
-		kfree(data->pages.pagevec);
+	if (data->page_array.pagevec != data->page_array.page_array)
+		kfree(data->page_array.pagevec);
 	if (atomic_dec_and_test(&hdr->refcnt))
 		hdr->completion_ops->completion(hdr);
 }
@@ -531,7 +531,7 @@ static void nfs_pgio_rpcsetup(struct nfs_pgio_data *data,
 	/* pnfs_set_layoutcommit needs this */
 	data->mds_offset = data->args.offset;
 	data->args.pgbase = req->wb_pgbase + offset;
-	data->args.pages  = data->pages.pagevec;
+	data->args.pages  = data->page_array.pagevec;
 	data->args.count  = count;
 	data->args.context = get_nfs_open_context(req->wb_context);
 	data->args.lock_context = req->wb_lock_context;
@@ -549,7 +549,7 @@ static void nfs_pgio_rpcsetup(struct nfs_pgio_data *data,
 	data->res.fattr   = &data->fattr;
 	data->res.count   = count;
 	data->res.eof     = 0;
-	data->res.verf    = &data->verf;
+	data->res.verf    = &data->writeverf;
 	nfs_fattr_init(&data->fattr);
 }
 
@@ -719,7 +719,7 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
 
 	data = &hdr->data;
 	nfs_init_cinfo(&cinfo, desc->pg_inode, desc->pg_dreq);
-	pages = data->pages.pagevec;
+	pages = data->page_array.pagevec;
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 3b8892b..a0ba22c 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -598,9 +598,9 @@ nfs_clear_request_commit(struct nfs_page *req)
 static inline
 int nfs_write_need_commit(struct nfs_pgio_data *data)
 {
-	if (data->verf.committed == NFS_DATA_SYNC)
+	if (data->writeverf.committed == NFS_DATA_SYNC)
 		return data->header->lseg == NULL;
-	return data->verf.committed != NFS_FILE_SYNC;
+	return data->writeverf.committed != NFS_FILE_SYNC;
 }
 
 #else
@@ -1093,8 +1093,9 @@ static void nfs_writeback_release_common(struct nfs_pgio_data *data)
 		if (test_bit(NFS_IOHDR_NEED_RESCHED, &hdr->flags))
 			; /* Do nothing */
 		else if (!test_and_set_bit(NFS_IOHDR_NEED_COMMIT, &hdr->flags))
-			memcpy(&hdr->verf, &data->verf, sizeof(hdr->verf));
-		else if (memcmp(&hdr->verf, &data->verf, sizeof(hdr->verf)))
+			memcpy(&hdr->verf, &data->writeverf, sizeof(hdr->verf));
+		else if (memcmp(&hdr->verf, &data->writeverf,
+			 sizeof(hdr->verf)))
 			set_bit(NFS_IOHDR_NEED_RESCHED, &hdr->flags);
 		spin_unlock(&hdr->lock);
 	}
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index e1c9437..bb18dba 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1262,13 +1262,13 @@ struct nfs_pgio_data {
 	struct list_head	list;
 	struct rpc_task		task;
 	struct nfs_fattr	fattr;
-	struct nfs_writeverf	verf;		/* Used for writes */
+	struct nfs_writeverf	writeverf;	/* Used for writes */
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


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:34188 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757415Ab2DTSgu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 14:36:50 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH v2 12/28] NFS: create common nfs_pgio_header for both read and write
Date: Fri, 20 Apr 2012 14:35:54 -0400
Message-Id: <1334946970-27470-13-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334946970-27470-1-git-send-email-iisaman@netapp.com>
References: <1334946970-27470-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to avoid duplicating all the data in nfs_read_data whenever we
split it up into multiple RPC calls (either due to a short read result
or due to rsize < PAGE_SIZE), we split out the bits that are the same
per RPC call into a separate "header" structure.

The goal this patch moves towards is to have a single header
refcounted by several rpc_data structures.  Thus, want to always refer
from rpc_data to the header, and not the other way.  This patch comes
close to that ideal, but the directio code currently needs some
special casing, isolated in the nfs_direct_[read_write]hdr_release()
functions.  This will be dealt with in a future patch.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/blocklayout/blocklayout.c |   79 ++++++++++++++++-------------
 fs/nfs/direct.c                  |   73 ++++++++++++++++++--------
 fs/nfs/internal.h                |    4 ++
 fs/nfs/nfs3proc.c                |   14 +++--
 fs/nfs/nfs4filelayout.c          |   40 ++++++++------
 fs/nfs/nfs4proc.c                |   44 +++++++++-------
 fs/nfs/objlayout/objio_osd.c     |   16 +++---
 fs/nfs/objlayout/objlayout.c     |   19 ++++---
 fs/nfs/pnfs.c                    |  102 +++++++++++++++++++++----------------
 fs/nfs/proc.c                    |   10 +++-
 fs/nfs/read.c                    |   89 ++++++++++++++++++--------------
 fs/nfs/write.c                   |  104 +++++++++++++++++++++-----------------
 include/linux/nfs_fs.h           |   12 ----
 include/linux/nfs_xdr.h          |   48 ++++++++++--------
 14 files changed, 376 insertions(+), 278 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 9c94297..192e16a 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -185,7 +185,6 @@ static void bl_end_io_read(struct bio *bio, int err)
 	struct parallel_io *par = bio->bi_private;
 	const int uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
 	struct bio_vec *bvec = bio->bi_io_vec + bio->bi_vcnt - 1;
-	struct nfs_read_data *rdata = (struct nfs_read_data *)par->data;
 
 	do {
 		struct page *page = bvec->bv_page;
@@ -196,9 +195,12 @@ static void bl_end_io_read(struct bio *bio, int err)
 			SetPageUptodate(page);
 	} while (bvec >= bio->bi_io_vec);
 	if (!uptodate) {
-		if (!rdata->pnfs_error)
-			rdata->pnfs_error = -EIO;
-		pnfs_set_lo_fail(rdata->lseg);
+		struct nfs_read_data *rdata = par->data;
+		struct nfs_pgio_header *header = rdata->header;
+
+		if (!header->pnfs_error)
+			header->pnfs_error = -EIO;
+		pnfs_set_lo_fail(header->lseg);
 	}
 	bio_put(bio);
 	put_parallel(par);
@@ -219,7 +221,7 @@ bl_end_par_io_read(void *data, int unused)
 {
 	struct nfs_read_data *rdata = data;
 
-	rdata->task.tk_status = rdata->pnfs_error;
+	rdata->task.tk_status = rdata->header->pnfs_error;
 	INIT_WORK(&rdata->task.u.tk_work, bl_read_cleanup);
 	schedule_work(&rdata->task.u.tk_work);
 }
@@ -227,6 +229,7 @@ bl_end_par_io_read(void *data, int unused)
 static enum pnfs_try_status
 bl_read_pagelist(struct nfs_read_data *rdata)
 {
+	struct nfs_pgio_header *header = rdata->header;
 	int i, hole;
 	struct bio *bio = NULL;
 	struct pnfs_block_extent *be = NULL, *cow_read = NULL;
@@ -254,10 +257,10 @@ bl_read_pagelist(struct nfs_read_data *rdata)
 			bl_put_extent(cow_read);
 			bio = bl_submit_bio(READ, bio);
 			/* Get the next one */
-			be = bl_find_get_extent(BLK_LSEG2EXT(rdata->lseg),
+			be = bl_find_get_extent(BLK_LSEG2EXT(header->lseg),
 					     isect, &cow_read);
 			if (!be) {
-				rdata->pnfs_error = -EIO;
+				header->pnfs_error = -EIO;
 				goto out;
 			}
 			extent_length = be->be_length -
@@ -284,7 +287,7 @@ bl_read_pagelist(struct nfs_read_data *rdata)
 						 isect, pages[i], be_read,
 						 bl_end_io_read, par);
 			if (IS_ERR(bio)) {
-				rdata->pnfs_error = PTR_ERR(bio);
+				header->pnfs_error = PTR_ERR(bio);
 				bio = NULL;
 				goto out;
 			}
@@ -292,9 +295,9 @@ bl_read_pagelist(struct nfs_read_data *rdata)
 		isect += PAGE_CACHE_SECTORS;
 		extent_length -= PAGE_CACHE_SECTORS;
 	}
-	if ((isect << SECTOR_SHIFT) >= rdata->inode->i_size) {
+	if ((isect << SECTOR_SHIFT) >= header->inode->i_size) {
 		rdata->res.eof = 1;
-		rdata->res.count = rdata->inode->i_size - f_offset;
+		rdata->res.count = header->inode->i_size - f_offset;
 	} else {
 		rdata->res.count = (isect << SECTOR_SHIFT) - f_offset;
 	}
@@ -343,7 +346,6 @@ static void bl_end_io_write_zero(struct bio *bio, int err)
 	struct parallel_io *par = bio->bi_private;
 	const int uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
 	struct bio_vec *bvec = bio->bi_io_vec + bio->bi_vcnt - 1;
-	struct nfs_write_data *wdata = (struct nfs_write_data *)par->data;
 
 	do {
 		struct page *page = bvec->bv_page;
@@ -356,9 +358,12 @@ static void bl_end_io_write_zero(struct bio *bio, int err)
 	} while (bvec >= bio->bi_io_vec);
 
 	if (unlikely(!uptodate)) {
-		if (!wdata->pnfs_error)
-			wdata->pnfs_error = -EIO;
-		pnfs_set_lo_fail(wdata->lseg);
+		struct nfs_write_data *data = par->data;
+		struct nfs_pgio_header *header = data->header;
+
+		if (!header->pnfs_error)
+			header->pnfs_error = -EIO;
+		pnfs_set_lo_fail(header->lseg);
 	}
 	bio_put(bio);
 	put_parallel(par);
@@ -368,12 +373,13 @@ static void bl_end_io_write(struct bio *bio, int err)
 {
 	struct parallel_io *par = bio->bi_private;
 	const int uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
-	struct nfs_write_data *wdata = (struct nfs_write_data *)par->data;
+	struct nfs_write_data *data = par->data;
+	struct nfs_pgio_header *header = data->header;
 
 	if (!uptodate) {
-		if (!wdata->pnfs_error)
-			wdata->pnfs_error = -EIO;
-		pnfs_set_lo_fail(wdata->lseg);
+		if (!header->pnfs_error)
+			header->pnfs_error = -EIO;
+		pnfs_set_lo_fail(header->lseg);
 	}
 	bio_put(bio);
 	put_parallel(par);
@@ -389,9 +395,9 @@ static void bl_write_cleanup(struct work_struct *work)
 	dprintk("%s enter\n", __func__);
 	task = container_of(work, struct rpc_task, u.tk_work);
 	wdata = container_of(task, struct nfs_write_data, task);
-	if (likely(!wdata->pnfs_error)) {
+	if (likely(!wdata->header->pnfs_error)) {
 		/* Marks for LAYOUTCOMMIT */
-		mark_extents_written(BLK_LSEG2EXT(wdata->lseg),
+		mark_extents_written(BLK_LSEG2EXT(wdata->header->lseg),
 				     wdata->args.offset, wdata->args.count);
 	}
 	pnfs_ld_write_done(wdata);
@@ -402,12 +408,12 @@ static void bl_end_par_io_write(void *data, int num_se)
 {
 	struct nfs_write_data *wdata = data;
 
-	if (unlikely(wdata->pnfs_error)) {
-		bl_free_short_extents(&BLK_LSEG2EXT(wdata->lseg)->bl_inval,
+	if (unlikely(wdata->header->pnfs_error)) {
+		bl_free_short_extents(&BLK_LSEG2EXT(wdata->header->lseg)->bl_inval,
 					num_se);
 	}
 
-	wdata->task.tk_status = wdata->pnfs_error;
+	wdata->task.tk_status = wdata->header->pnfs_error;
 	wdata->verf.committed = NFS_FILE_SYNC;
 	INIT_WORK(&wdata->task.u.tk_work, bl_write_cleanup);
 	schedule_work(&wdata->task.u.tk_work);
@@ -538,6 +544,7 @@ check_page:
 static enum pnfs_try_status
 bl_write_pagelist(struct nfs_write_data *wdata, int sync)
 {
+	struct nfs_pgio_header *header = wdata->header;
 	int i, ret, npg_zero, pg_index, last = 0;
 	struct bio *bio = NULL;
 	struct pnfs_block_extent *be = NULL, *cow_read = NULL;
@@ -550,7 +557,7 @@ bl_write_pagelist(struct nfs_write_data *wdata, int sync)
 	pgoff_t index;
 	u64 temp;
 	int npg_per_block =
-	    NFS_SERVER(wdata->inode)->pnfs_blksize >> PAGE_CACHE_SHIFT;
+	    NFS_SERVER(header->inode)->pnfs_blksize >> PAGE_CACHE_SHIFT;
 
 	dprintk("%s enter, %Zu@%lld\n", __func__, count, offset);
 	/* At this point, wdata->pages is a (sequential) list of nfs_pages.
@@ -564,7 +571,7 @@ bl_write_pagelist(struct nfs_write_data *wdata, int sync)
 	/* At this point, have to be more careful with error handling */
 
 	isect = (sector_t) ((offset & (long)PAGE_CACHE_MASK) >> SECTOR_SHIFT);
-	be = bl_find_get_extent(BLK_LSEG2EXT(wdata->lseg), isect, &cow_read);
+	be = bl_find_get_extent(BLK_LSEG2EXT(header->lseg), isect, &cow_read);
 	if (!be || !is_writable(be, isect)) {
 		dprintk("%s no matching extents!\n", __func__);
 		goto out_mds;
@@ -595,10 +602,10 @@ fill_invalid_ext:
 			dprintk("%s zero %dth page: index %lu isect %llu\n",
 				__func__, npg_zero, index,
 				(unsigned long long)isect);
-			page = bl_find_get_zeroing_page(wdata->inode, index,
+			page = bl_find_get_zeroing_page(header->inode, index,
 							cow_read);
 			if (unlikely(IS_ERR(page))) {
-				wdata->pnfs_error = PTR_ERR(page);
+				header->pnfs_error = PTR_ERR(page);
 				goto out;
 			} else if (page == NULL)
 				goto next_page;
@@ -610,7 +617,7 @@ fill_invalid_ext:
 					__func__, ret);
 				end_page_writeback(page);
 				page_cache_release(page);
-				wdata->pnfs_error = ret;
+				header->pnfs_error = ret;
 				goto out;
 			}
 			if (likely(!bl_push_one_short_extent(be->be_inval)))
@@ -618,11 +625,11 @@ fill_invalid_ext:
 			else {
 				end_page_writeback(page);
 				page_cache_release(page);
-				wdata->pnfs_error = -ENOMEM;
+				header->pnfs_error = -ENOMEM;
 				goto out;
 			}
 			/* FIXME: This should be done in bi_end_io */
-			mark_extents_written(BLK_LSEG2EXT(wdata->lseg),
+			mark_extents_written(BLK_LSEG2EXT(header->lseg),
 					     page->index << PAGE_CACHE_SHIFT,
 					     PAGE_CACHE_SIZE);
 
@@ -630,7 +637,7 @@ fill_invalid_ext:
 						 isect, page, be,
 						 bl_end_io_write_zero, par);
 			if (IS_ERR(bio)) {
-				wdata->pnfs_error = PTR_ERR(bio);
+				header->pnfs_error = PTR_ERR(bio);
 				bio = NULL;
 				goto out;
 			}
@@ -651,10 +658,10 @@ next_page:
 			bl_put_extent(be);
 			bio = bl_submit_bio(WRITE, bio);
 			/* Get the next one */
-			be = bl_find_get_extent(BLK_LSEG2EXT(wdata->lseg),
+			be = bl_find_get_extent(BLK_LSEG2EXT(header->lseg),
 					     isect, NULL);
 			if (!be || !is_writable(be, isect)) {
-				wdata->pnfs_error = -EINVAL;
+				header->pnfs_error = -EINVAL;
 				goto out;
 			}
 			if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
@@ -662,7 +669,7 @@ next_page:
 								be->be_inval)))
 					par->bse_count++;
 				else {
-					wdata->pnfs_error = -ENOMEM;
+					header->pnfs_error = -ENOMEM;
 					goto out;
 				}
 			}
@@ -675,7 +682,7 @@ next_page:
 			if (unlikely(ret)) {
 				dprintk("%s bl_mark_sectors_init fail %d\n",
 					__func__, ret);
-				wdata->pnfs_error = ret;
+				header->pnfs_error = ret;
 				goto out;
 			}
 		}
@@ -683,7 +690,7 @@ next_page:
 					 isect, pages[i], be,
 					 bl_end_io_write, par);
 		if (IS_ERR(bio)) {
-			wdata->pnfs_error = PTR_ERR(bio);
+			header->pnfs_error = PTR_ERR(bio);
 			bio = NULL;
 			goto out;
 		}
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index fb7fbaa..56176af 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -242,7 +242,7 @@ static void nfs_direct_read_release(void *calldata)
 {
 
 	struct nfs_read_data *data = calldata;
-	struct nfs_direct_req *dreq = (struct nfs_direct_req *) data->req;
+	struct nfs_direct_req *dreq = (struct nfs_direct_req *)data->header->req;
 	int status = data->task.tk_status;
 
 	spin_lock(&dreq->lock);
@@ -269,6 +269,15 @@ static const struct rpc_call_ops nfs_read_direct_ops = {
 	.rpc_release = nfs_direct_read_release,
 };
 
+static void nfs_direct_readhdr_release(struct nfs_read_header *rhdr)
+{
+	struct nfs_read_data *data = &rhdr->rpc_data;
+
+	if (data->pagevec != data->page_array)
+		kfree(data->pagevec);
+	nfs_readhdr_free(&rhdr->header);
+}
+
 /*
  * For each rsize'd chunk of the user's buffer, dispatch an NFS READ
  * operation.  If nfs_readdata_alloc() or get_user_pages() fails,
@@ -301,6 +310,7 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 	ssize_t started = 0;
 
 	do {
+		struct nfs_read_header *rhdr;
 		struct nfs_read_data *data;
 		size_t bytes;
 
@@ -308,23 +318,24 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 		bytes = min(rsize,count);
 
 		result = -ENOMEM;
-		data = nfs_readdata_alloc(nfs_page_array_len(pgbase, bytes));
-		if (unlikely(!data))
+		rhdr = nfs_readhdr_alloc(nfs_page_array_len(pgbase, bytes));
+		if (unlikely(!rhdr))
 			break;
+		data = &rhdr->rpc_data;
 
 		down_read(&current->mm->mmap_sem);
 		result = get_user_pages(current, current->mm, user_addr,
 					data->npages, 1, 0, data->pagevec, NULL);
 		up_read(&current->mm->mmap_sem);
 		if (result < 0) {
-			nfs_readdata_free(data);
+			nfs_direct_readhdr_release(rhdr);
 			break;
 		}
 		if ((unsigned)result < data->npages) {
 			bytes = result * PAGE_SIZE;
 			if (bytes <= pgbase) {
 				nfs_direct_release_pages(data->pagevec, result);
-				nfs_readdata_free(data);
+				nfs_direct_readhdr_release(rhdr);
 				break;
 			}
 			bytes -= pgbase;
@@ -333,9 +344,9 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 
 		get_dreq(dreq);
 
-		data->req = (struct nfs_page *) dreq;
-		data->inode = inode;
-		data->cred = msg.rpc_cred;
+		rhdr->header.req = (struct nfs_page *) dreq;
+		rhdr->header.inode = inode;
+		rhdr->header.cred = msg.rpc_cred;
 		data->args.fh = NFS_FH(inode);
 		data->args.context = get_nfs_open_context(ctx);
 		data->args.lock_context = dreq->l_ctx;
@@ -447,13 +458,23 @@ out:
 	return result;
 }
 
+static void nfs_direct_writehdr_release(struct nfs_write_header *whdr)
+{
+	struct nfs_write_data *data = &whdr->rpc_data;
+
+	if (data->pagevec != data->page_array)
+		kfree(data->pagevec);
+	nfs_writehdr_free(&whdr->header);
+}
+
 static void nfs_direct_free_writedata(struct nfs_direct_req *dreq)
 {
 	while (!list_empty(&dreq->rewrite_list)) {
-		struct nfs_write_data *data = list_entry(dreq->rewrite_list.next, struct nfs_write_data, pages);
-		list_del(&data->pages);
-		nfs_direct_release_pages(data->pagevec, data->npages);
-		nfs_writedata_free(data);
+		struct nfs_pgio_header *hdr = list_entry(dreq->rewrite_list.next, struct nfs_pgio_header, pages);
+		struct nfs_write_header *whdr = container_of(hdr, struct nfs_write_header, header);
+		list_del(&hdr->pages);
+		nfs_direct_release_pages(whdr->rpc_data.pagevec, whdr->rpc_data.npages);
+		nfs_direct_writehdr_release(whdr);
 	}
 }
 
@@ -463,6 +484,7 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 	struct inode *inode = dreq->inode;
 	struct list_head *p;
 	struct nfs_write_data *data;
+	struct nfs_pgio_header *hdr;
 	struct rpc_task *task;
 	struct rpc_message msg = {
 		.rpc_cred = dreq->ctx->cred,
@@ -479,7 +501,8 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 	get_dreq(dreq);
 
 	list_for_each(p, &dreq->rewrite_list) {
-		data = list_entry(p, struct nfs_write_data, pages);
+		hdr = list_entry(p, struct nfs_pgio_header, pages);
+		data = &(container_of(hdr, struct nfs_write_header, header))->rpc_data;
 
 		get_dreq(dreq);
 
@@ -652,7 +675,8 @@ static void nfs_direct_write_result(struct rpc_task *task, void *calldata)
 static void nfs_direct_write_release(void *calldata)
 {
 	struct nfs_write_data *data = calldata;
-	struct nfs_direct_req *dreq = (struct nfs_direct_req *) data->req;
+	struct nfs_pgio_header *hdr = data->header;
+	struct nfs_direct_req *dreq = (struct nfs_direct_req *) hdr->req;
 	int status = data->task.tk_status;
 
 	spin_lock(&dreq->lock);
@@ -684,7 +708,7 @@ out_unlock:
 	spin_unlock(&dreq->lock);
 
 	if (put_dreq(dreq))
-		nfs_direct_write_complete(dreq, data->inode);
+		nfs_direct_write_complete(dreq, hdr->inode);
 }
 
 static const struct rpc_call_ops nfs_write_direct_ops = {
@@ -725,6 +749,7 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 	ssize_t started = 0;
 
 	do {
+		struct nfs_write_header *whdr;
 		struct nfs_write_data *data;
 		size_t bytes;
 
@@ -732,23 +757,25 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 		bytes = min(wsize,count);
 
 		result = -ENOMEM;
-		data = nfs_writedata_alloc(nfs_page_array_len(pgbase, bytes));
-		if (unlikely(!data))
+		whdr = nfs_writehdr_alloc(nfs_page_array_len(pgbase, bytes));
+		if (unlikely(!whdr))
 			break;
 
+		data = &whdr->rpc_data;
+
 		down_read(&current->mm->mmap_sem);
 		result = get_user_pages(current, current->mm, user_addr,
 					data->npages, 0, 0, data->pagevec, NULL);
 		up_read(&current->mm->mmap_sem);
 		if (result < 0) {
-			nfs_writedata_free(data);
+			nfs_direct_writehdr_release(whdr);
 			break;
 		}
 		if ((unsigned)result < data->npages) {
 			bytes = result * PAGE_SIZE;
 			if (bytes <= pgbase) {
 				nfs_direct_release_pages(data->pagevec, result);
-				nfs_writedata_free(data);
+				nfs_direct_writehdr_release(whdr);
 				break;
 			}
 			bytes -= pgbase;
@@ -757,11 +784,11 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 
 		get_dreq(dreq);
 
-		list_move_tail(&data->pages, &dreq->rewrite_list);
+		list_move_tail(&whdr->header.pages, &dreq->rewrite_list);
 
-		data->req = (struct nfs_page *) dreq;
-		data->inode = inode;
-		data->cred = msg.rpc_cred;
+		whdr->header.req = (struct nfs_page *) dreq;
+		whdr->header.inode = inode;
+		whdr->header.cred = msg.rpc_cred;
 		data->args.fh = NFS_FH(inode);
 		data->args.context = ctx;
 		data->args.lock_context = dreq->l_ctx;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index abdf40c..9b2b8bf 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -296,6 +296,8 @@ extern int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh);
 
 struct nfs_pageio_descriptor;
 /* read.c */
+extern struct nfs_read_header *nfs_readhdr_alloc(unsigned int npages);
+extern void nfs_readhdr_free(struct nfs_pgio_header *hdr);
 extern int nfs_initiate_read(struct rpc_clnt *clnt,
 			     struct nfs_read_data *data,
 			     const struct rpc_call_ops *call_ops);
@@ -309,6 +311,8 @@ extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
 extern void nfs_readdata_release(struct nfs_read_data *rdata);
 
 /* write.c */
+extern struct nfs_write_header *nfs_writehdr_alloc(unsigned int npages);
+extern void nfs_writehdr_free(struct nfs_pgio_header *hdr);
 extern int nfs_generic_flush(struct nfs_pageio_descriptor *desc,
 		struct list_head *head);
 extern void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor *pgio,
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index b1daca7..56dcefc 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -811,11 +811,13 @@ nfs3_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
 
 static int nfs3_read_done(struct rpc_task *task, struct nfs_read_data *data)
 {
-	if (nfs3_async_handle_jukebox(task, data->inode))
+	struct inode *inode = data->header->inode;
+
+	if (nfs3_async_handle_jukebox(task, inode))
 		return -EAGAIN;
 
-	nfs_invalidate_atime(data->inode);
-	nfs_refresh_inode(data->inode, &data->fattr);
+	nfs_invalidate_atime(inode);
+	nfs_refresh_inode(inode, &data->fattr);
 	return 0;
 }
 
@@ -831,10 +833,12 @@ static void nfs3_proc_read_rpc_prepare(struct rpc_task *task, struct nfs_read_da
 
 static int nfs3_write_done(struct rpc_task *task, struct nfs_write_data *data)
 {
-	if (nfs3_async_handle_jukebox(task, data->inode))
+	struct inode *inode = data->header->inode;
+
+	if (nfs3_async_handle_jukebox(task, inode))
 		return -EAGAIN;
 	if (task->tk_status >= 0)
-		nfs_post_op_update_inode_force_wcc(data->inode, data->res.fattr);
+		nfs_post_op_update_inode_force_wcc(inode, data->res.fattr);
 	return 0;
 }
 
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index c536328..ad1d680 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -148,6 +148,7 @@ wait_on_recovery:
 static int filelayout_read_done_cb(struct rpc_task *task,
 				struct nfs_read_data *data)
 {
+	struct nfs_pgio_header *hdr = data->header;
 	int reset = 0;
 
 	dprintk("%s DS read\n", __func__);
@@ -157,7 +158,7 @@ static int filelayout_read_done_cb(struct rpc_task *task,
 		dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
 			__func__, data->ds_clp, data->ds_clp->cl_session);
 		if (reset) {
-			pnfs_set_lo_fail(data->lseg);
+			pnfs_set_lo_fail(hdr->lseg);
 			nfs4_reset_read(task, data);
 		}
 		rpc_restart_call_prepare(task);
@@ -175,13 +176,15 @@ static int filelayout_read_done_cb(struct rpc_task *task,
 static void
 filelayout_set_layoutcommit(struct nfs_write_data *wdata)
 {
-	if (FILELAYOUT_LSEG(wdata->lseg)->commit_through_mds ||
+	struct nfs_pgio_header *hdr = wdata->header;
+
+	if (FILELAYOUT_LSEG(hdr->lseg)->commit_through_mds ||
 	    wdata->res.verf->committed == NFS_FILE_SYNC)
 		return;
 
 	pnfs_set_layoutcommit(wdata);
-	dprintk("%s ionde %lu pls_end_pos %lu\n", __func__, wdata->inode->i_ino,
-		(unsigned long) NFS_I(wdata->inode)->layout->plh_lwb);
+	dprintk("%s ionde %lu pls_end_pos %lu\n", __func__, hdr->inode->i_ino,
+		(unsigned long) NFS_I(hdr->inode)->layout->plh_lwb);
 }
 
 /*
@@ -210,27 +213,28 @@ static void filelayout_read_call_done(struct rpc_task *task, void *data)
 	dprintk("--> %s task->tk_status %d\n", __func__, task->tk_status);
 
 	/* Note this may cause RPC to be resent */
-	rdata->mds_ops->rpc_call_done(task, data);
+	rdata->header->mds_ops->rpc_call_done(task, data);
 }
 
 static void filelayout_read_count_stats(struct rpc_task *task, void *data)
 {
 	struct nfs_read_data *rdata = data;
 
-	rpc_count_iostats(task, NFS_SERVER(rdata->inode)->client->cl_metrics);
+	rpc_count_iostats(task, NFS_SERVER(rdata->header->inode)->client->cl_metrics);
 }
 
 static void filelayout_read_release(void *data)
 {
 	struct nfs_read_data *rdata = data;
 
-	put_lseg(rdata->lseg);
-	rdata->mds_ops->rpc_release(data);
+	put_lseg(rdata->header->lseg);
+	rdata->header->mds_ops->rpc_release(data);
 }
 
 static int filelayout_write_done_cb(struct rpc_task *task,
 				struct nfs_write_data *data)
 {
+	struct nfs_pgio_header *hdr = data->header;
 	int reset = 0;
 
 	if (filelayout_async_handle_error(task, data->args.context->state,
@@ -238,7 +242,7 @@ static int filelayout_write_done_cb(struct rpc_task *task,
 		dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
 			__func__, data->ds_clp, data->ds_clp->cl_session);
 		if (reset) {
-			pnfs_set_lo_fail(data->lseg);
+			pnfs_set_lo_fail(hdr->lseg);
 			nfs4_reset_write(task, data);
 		}
 		rpc_restart_call_prepare(task);
@@ -297,22 +301,22 @@ static void filelayout_write_call_done(struct rpc_task *task, void *data)
 	struct nfs_write_data *wdata = data;
 
 	/* Note this may cause RPC to be resent */
-	wdata->mds_ops->rpc_call_done(task, data);
+	wdata->header->mds_ops->rpc_call_done(task, data);
 }
 
 static void filelayout_write_count_stats(struct rpc_task *task, void *data)
 {
 	struct nfs_write_data *wdata = data;
 
-	rpc_count_iostats(task, NFS_SERVER(wdata->inode)->client->cl_metrics);
+	rpc_count_iostats(task, NFS_SERVER(wdata->header->inode)->client->cl_metrics);
 }
 
 static void filelayout_write_release(void *data)
 {
 	struct nfs_write_data *wdata = data;
 
-	put_lseg(wdata->lseg);
-	wdata->mds_ops->rpc_release(data);
+	put_lseg(wdata->header->lseg);
+	wdata->header->mds_ops->rpc_release(data);
 }
 
 static void filelayout_commit_prepare(struct rpc_task *task, void *data)
@@ -377,7 +381,8 @@ static const struct rpc_call_ops filelayout_commit_call_ops = {
 static enum pnfs_try_status
 filelayout_read_pagelist(struct nfs_read_data *data)
 {
-	struct pnfs_layout_segment *lseg = data->lseg;
+	struct nfs_pgio_header *hdr = data->header;
+	struct pnfs_layout_segment *lseg = hdr->lseg;
 	struct nfs4_pnfs_ds *ds;
 	loff_t offset = data->args.offset;
 	u32 j, idx;
@@ -385,7 +390,7 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 	int status;
 
 	dprintk("--> %s ino %lu pgbase %u req %Zu@%llu\n",
-		__func__, data->inode->i_ino,
+		__func__, hdr->inode->i_ino,
 		data->args.pgbase, (size_t)data->args.count, offset);
 
 	if (test_bit(NFS_DEVICEID_INVALID, &FILELAYOUT_DEVID_NODE(lseg)->flags))
@@ -423,7 +428,8 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 static enum pnfs_try_status
 filelayout_write_pagelist(struct nfs_write_data *data, int sync)
 {
-	struct pnfs_layout_segment *lseg = data->lseg;
+	struct nfs_pgio_header *hdr = data->header;
+	struct pnfs_layout_segment *lseg = hdr->lseg;
 	struct nfs4_pnfs_ds *ds;
 	loff_t offset = data->args.offset;
 	u32 j, idx;
@@ -445,7 +451,7 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
 		return PNFS_NOT_ATTEMPTED;
 	}
 	dprintk("%s ino %lu sync %d req %Zu@%llu DS: %s\n", __func__,
-		data->inode->i_ino, sync, (size_t) data->args.count, offset,
+		hdr->inode->i_ino, sync, (size_t) data->args.count, offset,
 		ds->ds_remotestr);
 
 	data->write_done_cb = filelayout_write_done_cb;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 54f6268..75d5959 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3281,12 +3281,12 @@ static int nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
 
 void __nfs4_read_done_cb(struct nfs_read_data *data)
 {
-	nfs_invalidate_atime(data->inode);
+	nfs_invalidate_atime(data->header->inode);
 }
 
 static int nfs4_read_done_cb(struct rpc_task *task, struct nfs_read_data *data)
 {
-	struct nfs_server *server = NFS_SERVER(data->inode);
+	struct nfs_server *server = NFS_SERVER(data->header->inode);
 
 	if (nfs4_async_handle_error(task, server, data->args.context->state) == -EAGAIN) {
 		rpc_restart_call_prepare(task);
@@ -3321,7 +3321,7 @@ static void nfs4_proc_read_setup(struct nfs_read_data *data, struct rpc_message
 
 static void nfs4_proc_read_rpc_prepare(struct rpc_task *task, struct nfs_read_data *data)
 {
-	if (nfs4_setup_sequence(NFS_SERVER(data->inode),
+	if (nfs4_setup_sequence(NFS_SERVER(data->header->inode),
 				&data->args.seq_args,
 				&data->res.seq_res,
 				task))
@@ -3332,22 +3332,25 @@ static void nfs4_proc_read_rpc_prepare(struct rpc_task *task, struct nfs_read_da
 /* Reset the the nfs_read_data to send the read to the MDS. */
 void nfs4_reset_read(struct rpc_task *task, struct nfs_read_data *data)
 {
+	struct nfs_pgio_header *hdr = data->header;
+	struct inode *inode = hdr->inode;
+
 	dprintk("%s Reset task for i/o through\n", __func__);
-	put_lseg(data->lseg);
-	data->lseg = NULL;
+	put_lseg(hdr->lseg);
+	hdr->lseg = NULL;
+	data->ds_clp = NULL;
 	/* offsets will differ in the dense stripe case */
 	data->args.offset = data->mds_offset;
-	data->ds_clp = NULL;
-	data->args.fh     = NFS_FH(data->inode);
+	data->args.fh     = NFS_FH(inode);
 	data->read_done_cb = nfs4_read_done_cb;
-	task->tk_ops = data->mds_ops;
-	rpc_task_reset_client(task, NFS_CLIENT(data->inode));
+	task->tk_ops = hdr->mds_ops;
+	rpc_task_reset_client(task, NFS_CLIENT(inode));
 }
 EXPORT_SYMBOL_GPL(nfs4_reset_read);
 
 static int nfs4_write_done_cb(struct rpc_task *task, struct nfs_write_data *data)
 {
-	struct inode *inode = data->inode;
+	struct inode *inode = data->header->inode;
 	
 	if (nfs4_async_handle_error(task, NFS_SERVER(inode), data->args.context->state) == -EAGAIN) {
 		rpc_restart_call_prepare(task);
@@ -3371,25 +3374,28 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 /* Reset the the nfs_write_data to send the write to the MDS. */
 void nfs4_reset_write(struct rpc_task *task, struct nfs_write_data *data)
 {
+	struct nfs_pgio_header *hdr = data->header;
+	struct inode *inode = hdr->inode;
+
 	dprintk("%s Reset task for i/o through\n", __func__);
-	put_lseg(data->lseg);
-	data->lseg          = NULL;
-	data->ds_clp        = NULL;
+	put_lseg(hdr->lseg);
+	hdr->lseg        = NULL;
+	data->ds_clp     = NULL;
 	data->write_done_cb = nfs4_write_done_cb;
-	data->args.fh       = NFS_FH(data->inode);
+	data->args.fh       = NFS_FH(inode);
 	data->args.bitmask  = data->res.server->cache_consistency_bitmask;
 	data->args.offset   = data->mds_offset;
 	data->res.fattr     = &data->fattr;
-	task->tk_ops        = data->mds_ops;
-	rpc_task_reset_client(task, NFS_CLIENT(data->inode));
+	task->tk_ops        = hdr->mds_ops;
+	rpc_task_reset_client(task, NFS_CLIENT(inode));
 }
 EXPORT_SYMBOL_GPL(nfs4_reset_write);
 
 static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_message *msg)
 {
-	struct nfs_server *server = NFS_SERVER(data->inode);
+	struct nfs_server *server = NFS_SERVER(data->header->inode);
 
-	if (data->lseg) {
+	if (data->header->lseg) {
 		data->args.bitmask = NULL;
 		data->res.fattr = NULL;
 	} else
@@ -3405,7 +3411,7 @@ static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_messag
 
 static void nfs4_proc_write_rpc_prepare(struct rpc_task *task, struct nfs_write_data *data)
 {
-	if (nfs4_setup_sequence(NFS_SERVER(data->inode),
+	if (nfs4_setup_sequence(NFS_SERVER(data->header->inode),
 				&data->args.seq_args,
 				&data->res.seq_res,
 				task))
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 4bff4a3..fbf4874 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -440,11 +440,12 @@ static void _read_done(struct ore_io_state *ios, void *private)
 
 int objio_read_pagelist(struct nfs_read_data *rdata)
 {
+	struct nfs_pgio_header *hdr = rdata->header;
 	struct objio_state *objios;
 	int ret;
 
-	ret = objio_alloc_io_state(NFS_I(rdata->inode)->layout, true,
-			rdata->lseg, rdata->args.pages, rdata->args.pgbase,
+	ret = objio_alloc_io_state(NFS_I(hdr->inode)->layout, true,
+			hdr->lseg, rdata->args.pages, rdata->args.pgbase,
 			rdata->args.offset, rdata->args.count, rdata,
 			GFP_KERNEL, &objios);
 	if (unlikely(ret))
@@ -483,12 +484,12 @@ static struct page *__r4w_get_page(void *priv, u64 offset, bool *uptodate)
 {
 	struct objio_state *objios = priv;
 	struct nfs_write_data *wdata = objios->oir.rpcdata;
+	struct address_space *mapping = wdata->header->inode->i_mapping;
 	pgoff_t index = offset / PAGE_SIZE;
-	struct page *page = find_get_page(wdata->inode->i_mapping, index);
+	struct page *page = find_get_page(mapping, index);
 
 	if (!page) {
-		page = find_or_create_page(wdata->inode->i_mapping,
-						index, GFP_NOFS);
+		page = find_or_create_page(mapping, index, GFP_NOFS);
 		if (unlikely(!page)) {
 			dprintk("%s: grab_cache_page Failed index=0x%lx\n",
 				__func__, index);
@@ -518,11 +519,12 @@ static const struct _ore_r4w_op _r4w_op = {
 
 int objio_write_pagelist(struct nfs_write_data *wdata, int how)
 {
+	struct nfs_pgio_header *hdr = wdata->header;
 	struct objio_state *objios;
 	int ret;
 
-	ret = objio_alloc_io_state(NFS_I(wdata->inode)->layout, false,
-			wdata->lseg, wdata->args.pages, wdata->args.pgbase,
+	ret = objio_alloc_io_state(NFS_I(hdr->inode)->layout, false,
+			hdr->lseg, wdata->args.pages, wdata->args.pgbase,
 			wdata->args.offset, wdata->args.count, wdata, GFP_NOFS,
 			&objios);
 	if (unlikely(ret))
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 8d45f1c..3f83fc2 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -258,7 +258,7 @@ objlayout_read_done(struct objlayout_io_res *oir, ssize_t status, bool sync)
 	if (status >= 0)
 		rdata->res.count = status;
 	else
-		rdata->pnfs_error = status;
+		rdata->header->pnfs_error = status;
 	objlayout_iodone(oir);
 	/* must not use oir after this point */
 
@@ -279,12 +279,14 @@ objlayout_read_done(struct objlayout_io_res *oir, ssize_t status, bool sync)
 enum pnfs_try_status
 objlayout_read_pagelist(struct nfs_read_data *rdata)
 {
+	struct nfs_pgio_header *hdr = rdata->header;
+	struct inode *inode = hdr->inode;
 	loff_t offset = rdata->args.offset;
 	size_t count = rdata->args.count;
 	int err;
 	loff_t eof;
 
-	eof = i_size_read(rdata->inode);
+	eof = i_size_read(inode);
 	if (unlikely(offset + count > eof)) {
 		if (offset >= eof) {
 			err = 0;
@@ -297,17 +299,17 @@ objlayout_read_pagelist(struct nfs_read_data *rdata)
 	}
 
 	rdata->res.eof = (offset + count) >= eof;
-	_fix_verify_io_params(rdata->lseg, &rdata->args.pages,
+	_fix_verify_io_params(hdr->lseg, &rdata->args.pages,
 			      &rdata->args.pgbase,
 			      rdata->args.offset, rdata->args.count);
 
 	dprintk("%s: inode(%lx) offset 0x%llx count 0x%Zx eof=%d\n",
-		__func__, rdata->inode->i_ino, offset, count, rdata->res.eof);
+		__func__, inode->i_ino, offset, count, rdata->res.eof);
 
 	err = objio_read_pagelist(rdata);
  out:
 	if (unlikely(err)) {
-		rdata->pnfs_error = err;
+		hdr->pnfs_error = err;
 		dprintk("%s: Returned Error %d\n", __func__, err);
 		return PNFS_NOT_ATTEMPTED;
 	}
@@ -340,7 +342,7 @@ objlayout_write_done(struct objlayout_io_res *oir, ssize_t status, bool sync)
 		wdata->res.count = status;
 		wdata->verf.committed = oir->committed;
 	} else {
-		wdata->pnfs_error = status;
+		wdata->header->pnfs_error = status;
 	}
 	objlayout_iodone(oir);
 	/* must not use oir after this point */
@@ -363,15 +365,16 @@ enum pnfs_try_status
 objlayout_write_pagelist(struct nfs_write_data *wdata,
 			 int how)
 {
+	struct nfs_pgio_header *hdr = wdata->header;
 	int err;
 
-	_fix_verify_io_params(wdata->lseg, &wdata->args.pages,
+	_fix_verify_io_params(hdr->lseg, &wdata->args.pages,
 			      &wdata->args.pgbase,
 			      wdata->args.offset, wdata->args.count);
 
 	err = objio_write_pagelist(wdata, how);
 	if (unlikely(err)) {
-		wdata->pnfs_error = err;
+		hdr->pnfs_error = err;
 		dprintk("%s: Returned Error %d\n", __func__, err);
 		return PNFS_NOT_ATTEMPTED;
 	}
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e4aee9d..b00170a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1191,13 +1191,15 @@ static int pnfs_write_done_resend_to_mds(struct inode *inode, struct list_head *
 
 static void pnfs_ld_handle_write_error(struct nfs_write_data *data)
 {
-	dprintk("pnfs write error = %d\n", data->pnfs_error);
-	if (NFS_SERVER(data->inode)->pnfs_curr_ld->flags &
+	struct nfs_pgio_header *hdr = data->header;
+
+	dprintk("pnfs write error = %d\n", hdr->pnfs_error);
+	if (NFS_SERVER(hdr->inode)->pnfs_curr_ld->flags &
 	    PNFS_LAYOUTRET_ON_ERROR) {
-		clear_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(data->inode)->flags);
-		pnfs_return_layout(data->inode);
+		clear_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(hdr->inode)->flags);
+		pnfs_return_layout(hdr->inode);
 	}
-	data->task.tk_status = pnfs_write_done_resend_to_mds(data->inode, &data->pages);
+	data->task.tk_status = pnfs_write_done_resend_to_mds(hdr->inode, &hdr->pages);
 }
 
 /*
@@ -1205,13 +1207,15 @@ static void pnfs_ld_handle_write_error(struct nfs_write_data *data)
  */
 void pnfs_ld_write_done(struct nfs_write_data *data)
 {
-	if (likely(!data->pnfs_error)) {
+	struct nfs_pgio_header *hdr = data->header;
+
+	if (!hdr->pnfs_error) {
 		pnfs_set_layoutcommit(data);
-		data->mds_ops->rpc_call_done(&data->task, data);
+		hdr->mds_ops->rpc_call_done(&data->task, data);
 	} else
 		pnfs_ld_handle_write_error(data);
-	put_lseg(data->lseg);
-	data->mds_ops->rpc_release(data);
+	put_lseg(hdr->lseg);
+	hdr->mds_ops->rpc_release(data);
 }
 EXPORT_SYMBOL_GPL(pnfs_ld_write_done);
 
@@ -1219,12 +1223,14 @@ static void
 pnfs_write_through_mds(struct nfs_pageio_descriptor *desc,
 		struct nfs_write_data *data)
 {
-	list_splice_tail_init(&data->pages, &desc->pg_list);
-	if (data->req && list_empty(&data->req->wb_list))
-		nfs_list_add_request(data->req, &desc->pg_list);
+	struct nfs_pgio_header *hdr = data->header;
+
+	list_splice_tail_init(&hdr->pages, &desc->pg_list);
+	if (hdr->req && list_empty(&hdr->req->wb_list))
+		nfs_list_add_request(hdr->req, &desc->pg_list);
 	nfs_pageio_reset_write_mds(desc);
 	desc->pg_recoalesce = 1;
-	put_lseg(data->lseg);
+	put_lseg(hdr->lseg);
 	nfs_writedata_release(data);
 }
 
@@ -1234,20 +1240,21 @@ pnfs_try_to_write_data(struct nfs_write_data *wdata,
 			struct pnfs_layout_segment *lseg,
 			int how)
 {
-	struct inode *inode = wdata->inode;
+	struct nfs_pgio_header *hdr = wdata->header;
+	struct inode *inode = hdr->inode;
 	enum pnfs_try_status trypnfs;
 	struct nfs_server *nfss = NFS_SERVER(inode);
 
-	wdata->mds_ops = call_ops;
-	wdata->lseg = get_lseg(lseg);
+	hdr->mds_ops = call_ops;
+	hdr->lseg = get_lseg(lseg);
 
 	dprintk("%s: Writing ino:%lu %u@%llu (how %d)\n", __func__,
 		inode->i_ino, wdata->args.count, wdata->args.offset, how);
 
 	trypnfs = nfss->pnfs_curr_ld->write_pagelist(wdata, how);
 	if (trypnfs == PNFS_NOT_ATTEMPTED) {
-		put_lseg(wdata->lseg);
-		wdata->lseg = NULL;
+		put_lseg(hdr->lseg);
+		hdr->lseg = NULL;
 	} else
 		nfs_inc_stats(inode, NFSIOS_PNFS_WRITE);
 
@@ -1318,13 +1325,15 @@ static int pnfs_read_done_resend_to_mds(struct inode *inode, struct list_head *h
 
 static void pnfs_ld_handle_read_error(struct nfs_read_data *data)
 {
-	dprintk("pnfs read error = %d\n", data->pnfs_error);
-	if (NFS_SERVER(data->inode)->pnfs_curr_ld->flags &
+	struct nfs_pgio_header *hdr = data->header;
+
+	dprintk("pnfs read error = %d\n", hdr->pnfs_error);
+	if (NFS_SERVER(hdr->inode)->pnfs_curr_ld->flags &
 	    PNFS_LAYOUTRET_ON_ERROR) {
-		clear_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(data->inode)->flags);
-		pnfs_return_layout(data->inode);
+		clear_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(hdr->inode)->flags);
+		pnfs_return_layout(hdr->inode);
 	}
-	data->task.tk_status = pnfs_read_done_resend_to_mds(data->inode, &data->pages);
+	data->task.tk_status = pnfs_read_done_resend_to_mds(hdr->inode, &hdr->pages);
 }
 
 /*
@@ -1332,13 +1341,15 @@ static void pnfs_ld_handle_read_error(struct nfs_read_data *data)
  */
 void pnfs_ld_read_done(struct nfs_read_data *data)
 {
-	if (likely(!data->pnfs_error)) {
+	struct nfs_pgio_header *hdr = data->header;
+
+	if (likely(!hdr->pnfs_error)) {
 		__nfs4_read_done_cb(data);
-		data->mds_ops->rpc_call_done(&data->task, data);
+		hdr->mds_ops->rpc_call_done(&data->task, data);
 	} else
 		pnfs_ld_handle_read_error(data);
-	put_lseg(data->lseg);
-	data->mds_ops->rpc_release(data);
+	put_lseg(hdr->lseg);
+	hdr->mds_ops->rpc_release(data);
 }
 EXPORT_SYMBOL_GPL(pnfs_ld_read_done);
 
@@ -1346,9 +1357,11 @@ static void
 pnfs_read_through_mds(struct nfs_pageio_descriptor *desc,
 		struct nfs_read_data *data)
 {
-	list_splice_tail_init(&data->pages, &desc->pg_list);
-	if (data->req && list_empty(&data->req->wb_list))
-		nfs_list_add_request(data->req, &desc->pg_list);
+	struct nfs_pgio_header *hdr = data->header;
+
+	list_splice_tail_init(&hdr->pages, &desc->pg_list);
+	if (hdr->req && list_empty(&hdr->req->wb_list))
+		nfs_list_add_request(hdr->req, &desc->pg_list);
 	nfs_pageio_reset_read_mds(desc);
 	desc->pg_recoalesce = 1;
 	nfs_readdata_release(data);
@@ -1362,20 +1375,21 @@ pnfs_try_to_read_data(struct nfs_read_data *rdata,
 		       const struct rpc_call_ops *call_ops,
 		       struct pnfs_layout_segment *lseg)
 {
-	struct inode *inode = rdata->inode;
+	struct nfs_pgio_header *hdr = rdata->header;
+	struct inode *inode = hdr->inode;
 	struct nfs_server *nfss = NFS_SERVER(inode);
 	enum pnfs_try_status trypnfs;
 
-	rdata->mds_ops = call_ops;
-	rdata->lseg = get_lseg(lseg);
+	hdr->mds_ops = call_ops;
+	hdr->lseg = get_lseg(lseg);
 
 	dprintk("%s: Reading ino:%lu %u@%llu\n",
 		__func__, inode->i_ino, rdata->args.count, rdata->args.offset);
 
 	trypnfs = nfss->pnfs_curr_ld->read_pagelist(rdata);
 	if (trypnfs == PNFS_NOT_ATTEMPTED) {
-		put_lseg(rdata->lseg);
-		rdata->lseg = NULL;
+		put_lseg(hdr->lseg);
+		hdr->lseg = NULL;
 	} else {
 		nfs_inc_stats(inode, NFSIOS_PNFS_READ);
 	}
@@ -1450,30 +1464,32 @@ EXPORT_SYMBOL_GPL(pnfs_set_lo_fail);
 void
 pnfs_set_layoutcommit(struct nfs_write_data *wdata)
 {
-	struct nfs_inode *nfsi = NFS_I(wdata->inode);
+	struct nfs_pgio_header *hdr = wdata->header;
+	struct inode *inode = hdr->inode;
+	struct nfs_inode *nfsi = NFS_I(inode);
 	loff_t end_pos = wdata->mds_offset + wdata->res.count;
 	bool mark_as_dirty = false;
 
-	spin_lock(&nfsi->vfs_inode.i_lock);
+	spin_lock(&inode->i_lock);
 	if (!test_and_set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
 		mark_as_dirty = true;
 		dprintk("%s: Set layoutcommit for inode %lu ",
-			__func__, wdata->inode->i_ino);
+			__func__, inode->i_ino);
 	}
-	if (!test_and_set_bit(NFS_LSEG_LAYOUTCOMMIT, &wdata->lseg->pls_flags)) {
+	if (!test_and_set_bit(NFS_LSEG_LAYOUTCOMMIT, &hdr->lseg->pls_flags)) {
 		/* references matched in nfs4_layoutcommit_release */
-		get_lseg(wdata->lseg);
+		get_lseg(hdr->lseg);
 	}
 	if (end_pos > nfsi->layout->plh_lwb)
 		nfsi->layout->plh_lwb = end_pos;
-	spin_unlock(&nfsi->vfs_inode.i_lock);
+	spin_unlock(&inode->i_lock);
 	dprintk("%s: lseg %p end_pos %llu\n",
-		__func__, wdata->lseg, nfsi->layout->plh_lwb);
+		__func__, hdr->lseg, nfsi->layout->plh_lwb);
 
 	/* if pnfs_layoutcommit_inode() runs between inode locks, the next one
 	 * will be a noop because NFS_INO_LAYOUTCOMMIT will not be set */
 	if (mark_as_dirty)
-		mark_inode_dirty_sync(wdata->inode);
+		mark_inode_dirty_sync(inode);
 }
 EXPORT_SYMBOL_GPL(pnfs_set_layoutcommit);
 
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index bf80503..22ee705 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -641,12 +641,14 @@ nfs_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
 
 static int nfs_read_done(struct rpc_task *task, struct nfs_read_data *data)
 {
+	struct inode *inode = data->header->inode;
+
 	if (nfs_async_handle_expired_key(task))
 		return -EAGAIN;
 
-	nfs_invalidate_atime(data->inode);
+	nfs_invalidate_atime(inode);
 	if (task->tk_status >= 0) {
-		nfs_refresh_inode(data->inode, data->res.fattr);
+		nfs_refresh_inode(inode, data->res.fattr);
 		/* Emulate the eof flag, which isn't normally needed in NFSv2
 		 * as it is guaranteed to always return the file attributes
 		 */
@@ -668,11 +670,13 @@ static void nfs_proc_read_rpc_prepare(struct rpc_task *task, struct nfs_read_dat
 
 static int nfs_write_done(struct rpc_task *task, struct nfs_write_data *data)
 {
+	struct inode *inode = data->header->inode;
+
 	if (nfs_async_handle_expired_key(task))
 		return -EAGAIN;
 
 	if (task->tk_status >= 0)
-		nfs_post_op_update_inode_force_wcc(data->inode, data->res.fattr);
+		nfs_post_op_update_inode_force_wcc(inode, data->res.fattr);
 	return 0;
 }
 
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 4ddba67..d6d4682 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -35,19 +35,24 @@ static const struct rpc_call_ops nfs_read_full_ops;
 
 static struct kmem_cache *nfs_rdata_cachep;
 
-struct nfs_read_data *nfs_readdata_alloc(unsigned int pagecount)
+struct nfs_read_header *nfs_readhdr_alloc(unsigned int pagecount)
 {
-	struct nfs_read_data *p;
+	struct nfs_read_header *p;
 
 	p = kmem_cache_zalloc(nfs_rdata_cachep, GFP_KERNEL);
 	if (p) {
-		INIT_LIST_HEAD(&p->pages);
-		p->npages = pagecount;
-		if (pagecount <= ARRAY_SIZE(p->page_array))
-			p->pagevec = p->page_array;
+		struct nfs_pgio_header *hdr = &p->header;
+		struct nfs_read_data *data = &p->rpc_data;
+
+		INIT_LIST_HEAD(&hdr->pages);
+		INIT_LIST_HEAD(&data->list);
+		data->npages = pagecount;
+		data->header = hdr;
+		if (pagecount <= ARRAY_SIZE(data->page_array))
+			data->pagevec = data->page_array;
 		else {
-			p->pagevec = kcalloc(pagecount, sizeof(struct page *), GFP_KERNEL);
-			if (!p->pagevec) {
+			data->pagevec = kcalloc(pagecount, sizeof(struct page *), GFP_KERNEL);
+			if (!data->pagevec) {
 				kmem_cache_free(nfs_rdata_cachep, p);
 				p = NULL;
 			}
@@ -56,17 +61,19 @@ struct nfs_read_data *nfs_readdata_alloc(unsigned int pagecount)
 	return p;
 }
 
-void nfs_readdata_free(struct nfs_read_data *p)
+void nfs_readhdr_free(struct nfs_pgio_header *hdr)
 {
-	if (p && (p->pagevec != &p->page_array[0]))
-		kfree(p->pagevec);
-	kmem_cache_free(nfs_rdata_cachep, p);
+	struct nfs_read_header *rhdr = container_of(hdr, struct nfs_read_header, header);
+
+	kmem_cache_free(nfs_rdata_cachep, rhdr);
 }
 
 void nfs_readdata_release(struct nfs_read_data *rdata)
 {
 	put_nfs_open_context(rdata->args.context);
-	nfs_readdata_free(rdata);
+	if (rdata->pagevec != rdata->page_array)
+		kfree(rdata->pagevec);
+	nfs_readhdr_free(rdata->header);
 }
 
 static
@@ -173,13 +180,13 @@ int nfs_initiate_read(struct rpc_clnt *clnt,
 		      struct nfs_read_data *data,
 		      const struct rpc_call_ops *call_ops)
 {
-	struct inode *inode = data->inode;
+	struct inode *inode = data->header->inode;
 	int swap_flags = IS_SWAPFILE(inode) ? NFS_RPC_SWAPFLAGS : 0;
 	struct rpc_task *task;
 	struct rpc_message msg = {
 		.rpc_argp = &data->args,
 		.rpc_resp = &data->res,
-		.rpc_cred = data->cred,
+		.rpc_cred = data->header->cred,
 	};
 	struct rpc_task_setup task_setup_data = {
 		.task = &data->task,
@@ -216,11 +223,11 @@ EXPORT_SYMBOL_GPL(nfs_initiate_read);
 static void nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 		unsigned int count, unsigned int offset)
 {
-	struct inode *inode = req->wb_context->dentry->d_inode;
+	struct inode *inode = data->header->inode;
 
-	data->req	  = req;
-	data->inode	  = inode;
-	data->cred	  = req->wb_context->cred;
+	data->header->req	  = req;
+	data->header->inode	  = inode;
+	data->header->cred	  = req->wb_context->cred;
 
 	data->args.fh     = NFS_FH(inode);
 	data->args.offset = req_offset(req) + offset;
@@ -239,7 +246,7 @@ static void nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 static int nfs_do_read(struct nfs_read_data *data,
 		const struct rpc_call_ops *call_ops)
 {
-	struct inode *inode = data->args.context->dentry->d_inode;
+	struct inode *inode = data->header->inode;
 
 	return nfs_initiate_read(NFS_CLIENT(inode), data, call_ops);
 }
@@ -293,6 +300,7 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc, struct list_head
 {
 	struct nfs_page *req = nfs_list_entry(desc->pg_list.next);
 	struct page *page = req->wb_page;
+	struct nfs_read_header *rhdr;
 	struct nfs_read_data *data;
 	size_t rsize = desc->pg_bsize, nbytes;
 	unsigned int offset;
@@ -306,9 +314,10 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc, struct list_head
 	do {
 		size_t len = min(nbytes,rsize);
 
-		data = nfs_readdata_alloc(1);
-		if (!data)
+		rhdr = nfs_readhdr_alloc(1);
+		if (!rhdr)
 			goto out_bad;
+		data = &rhdr->rpc_data;
 		data->pagevec[0] = page;
 		nfs_read_rpcsetup(req, data, len, offset);
 		list_add(&data->list, res);
@@ -333,26 +342,28 @@ static int nfs_pagein_one(struct nfs_pageio_descriptor *desc, struct list_head *
 {
 	struct nfs_page		*req;
 	struct page		**pages;
+	struct nfs_read_header	*rhdr;
 	struct nfs_read_data	*data;
 	struct list_head *head = &desc->pg_list;
 	int ret = 0;
 
-	data = nfs_readdata_alloc(nfs_page_array_len(desc->pg_base,
-						     desc->pg_count));
-	if (!data) {
+	rhdr = nfs_readhdr_alloc(nfs_page_array_len(desc->pg_base,
+						    desc->pg_count));
+	if (!rhdr) {
 		nfs_async_read_error(head);
 		ret = -ENOMEM;
 		goto out;
 	}
 
+	data = &rhdr->rpc_data;
 	pages = data->pagevec;
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
-		nfs_list_add_request(req, &data->pages);
+		nfs_list_add_request(req, &rhdr->header.pages);
 		*pages++ = req->wb_page;
 	}
-	req = nfs_list_entry(data->pages.next);
+	req = nfs_list_entry(rhdr->header.pages.next);
 
 	nfs_read_rpcsetup(req, data, desc->pg_count, 0);
 	list_add(&data->list, res);
@@ -390,20 +401,21 @@ static const struct nfs_pageio_ops nfs_pageio_read_ops = {
  */
 int nfs_readpage_result(struct rpc_task *task, struct nfs_read_data *data)
 {
+	struct inode *inode = data->header->inode;
 	int status;
 
 	dprintk("NFS: %s: %5u, (status %d)\n", __func__, task->tk_pid,
 			task->tk_status);
 
-	status = NFS_PROTO(data->inode)->read_done(task, data);
+	status = NFS_PROTO(inode)->read_done(task, data);
 	if (status != 0)
 		return status;
 
-	nfs_add_stats(data->inode, NFSIOS_SERVERREADBYTES, data->res.count);
+	nfs_add_stats(inode, NFSIOS_SERVERREADBYTES, data->res.count);
 
 	if (task->tk_status == -ESTALE) {
-		set_bit(NFS_INO_STALE, &NFS_I(data->inode)->flags);
-		nfs_mark_for_revalidate(data->inode);
+		set_bit(NFS_INO_STALE, &NFS_I(inode)->flags);
+		nfs_mark_for_revalidate(inode);
 	}
 	return 0;
 }
@@ -417,7 +429,7 @@ static void nfs_readpage_retry(struct rpc_task *task, struct nfs_read_data *data
 		return;
 
 	/* This is a short read! */
-	nfs_inc_stats(data->inode, NFSIOS_SHORTREAD);
+	nfs_inc_stats(data->header->inode, NFSIOS_SHORTREAD);
 	/* Has the server at least made some progress? */
 	if (resp->count == 0)
 		return;
@@ -449,7 +461,7 @@ static void nfs_readpage_result_partial(struct rpc_task *task, void *calldata)
 static void nfs_readpage_release_partial(void *calldata)
 {
 	struct nfs_read_data *data = calldata;
-	struct nfs_page *req = data->req;
+	struct nfs_page *req = data->header->req;
 	struct page *page = req->wb_page;
 	int status = data->task.tk_status;
 
@@ -461,13 +473,13 @@ static void nfs_readpage_release_partial(void *calldata)
 			SetPageUptodate(page);
 		nfs_readpage_release(req);
 	}
-	nfs_readdata_release(calldata);
+	nfs_readdata_release(data);
 }
 
 void nfs_read_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_read_data *data = calldata;
-	NFS_PROTO(data->inode)->read_rpc_prepare(task, data);
+	NFS_PROTO(data->header->inode)->read_rpc_prepare(task, data);
 }
 
 static const struct rpc_call_ops nfs_read_partial_ops = {
@@ -524,9 +536,10 @@ static void nfs_readpage_result_full(struct rpc_task *task, void *calldata)
 static void nfs_readpage_release_full(void *calldata)
 {
 	struct nfs_read_data *data = calldata;
+	struct nfs_pgio_header *hdr = data->header;
 
-	while (!list_empty(&data->pages)) {
-		struct nfs_page *req = nfs_list_entry(data->pages.next);
+	while (!list_empty(&hdr->pages)) {
+		struct nfs_page *req = nfs_list_entry(hdr->pages.next);
 
 		nfs_list_remove_request(req);
 		nfs_readpage_release(req);
@@ -685,7 +698,7 @@ out:
 int __init nfs_init_readpagecache(void)
 {
 	nfs_rdata_cachep = kmem_cache_create("nfs_read_data",
-					     sizeof(struct nfs_read_data),
+					     sizeof(struct nfs_read_header),
 					     0, SLAB_HWCACHE_ALIGN,
 					     NULL);
 	if (nfs_rdata_cachep == NULL)
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 76735dd..dbb5c0a 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -69,19 +69,24 @@ void nfs_commit_free(struct nfs_commit_data *p)
 }
 EXPORT_SYMBOL_GPL(nfs_commit_free);
 
-struct nfs_write_data *nfs_writedata_alloc(unsigned int pagecount)
+struct nfs_write_header *nfs_writehdr_alloc(unsigned int pagecount)
 {
-	struct nfs_write_data *p = mempool_alloc(nfs_wdata_mempool, GFP_NOFS);
+	struct nfs_write_header *p = mempool_alloc(nfs_wdata_mempool, GFP_NOFS);
 
 	if (p) {
+		struct nfs_pgio_header *hdr = &p->header;
+		struct nfs_write_data *data = &p->rpc_data;
+
 		memset(p, 0, sizeof(*p));
-		INIT_LIST_HEAD(&p->pages);
-		p->npages = pagecount;
-		if (pagecount <= ARRAY_SIZE(p->page_array))
-			p->pagevec = p->page_array;
+		INIT_LIST_HEAD(&hdr->pages);
+		INIT_LIST_HEAD(&data->list);
+		data->npages = pagecount;
+		data->header = hdr;
+		if (pagecount <= ARRAY_SIZE(data->page_array))
+			data->pagevec = data->page_array;
 		else {
-			p->pagevec = kcalloc(pagecount, sizeof(struct page *), GFP_NOFS);
-			if (!p->pagevec) {
+			data->pagevec = kcalloc(pagecount, sizeof(struct page *), GFP_NOFS);
+			if (!data->pagevec) {
 				mempool_free(p, nfs_wdata_mempool);
 				p = NULL;
 			}
@@ -90,17 +95,18 @@ struct nfs_write_data *nfs_writedata_alloc(unsigned int pagecount)
 	return p;
 }
 
-void nfs_writedata_free(struct nfs_write_data *p)
+void nfs_writehdr_free(struct nfs_pgio_header *hdr)
 {
-	if (p && (p->pagevec != &p->page_array[0]))
-		kfree(p->pagevec);
-	mempool_free(p, nfs_wdata_mempool);
+	struct nfs_write_header *whdr = container_of(hdr, struct nfs_write_header, header);
+	mempool_free(whdr, nfs_wdata_mempool);
 }
 
 void nfs_writedata_release(struct nfs_write_data *wdata)
 {
 	put_nfs_open_context(wdata->args.context);
-	nfs_writedata_free(wdata);
+	if (wdata->pagevec != wdata->page_array)
+		kfree(wdata->pagevec);
+	nfs_writehdr_free(wdata->header);
 }
 
 static void nfs_context_set_write_error(struct nfs_open_context *ctx, int error)
@@ -507,9 +513,8 @@ static inline
 int nfs_write_need_commit(struct nfs_write_data *data)
 {
 	if (data->verf.committed == NFS_DATA_SYNC)
-		return data->lseg == NULL;
-	else
-		return data->verf.committed != NFS_FILE_SYNC;
+		return data->header->lseg == NULL;
+	return data->verf.committed != NFS_FILE_SYNC;
 }
 
 static inline
@@ -517,7 +522,7 @@ int nfs_reschedule_unstable_write(struct nfs_page *req,
 				  struct nfs_write_data *data)
 {
 	if (test_and_clear_bit(PG_NEED_COMMIT, &req->wb_flags)) {
-		nfs_mark_request_commit(req, data->lseg);
+		nfs_mark_request_commit(req, data->header->lseg);
 		return 1;
 	}
 	if (test_and_clear_bit(PG_NEED_RESCHED, &req->wb_flags)) {
@@ -841,13 +846,13 @@ int nfs_initiate_write(struct rpc_clnt *clnt,
 		       const struct rpc_call_ops *call_ops,
 		       int how)
 {
-	struct inode *inode = data->inode;
+	struct inode *inode = data->header->inode;
 	int priority = flush_task_priority(how);
 	struct rpc_task *task;
 	struct rpc_message msg = {
 		.rpc_argp = &data->args,
 		.rpc_resp = &data->res,
-		.rpc_cred = data->cred,
+		.rpc_cred = data->header->cred,
 	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = clnt,
@@ -896,14 +901,15 @@ static void nfs_write_rpcsetup(struct nfs_page *req,
 		unsigned int count, unsigned int offset,
 		int how)
 {
+	struct nfs_pgio_header *hdr = data->header;
 	struct inode *inode = req->wb_context->dentry->d_inode;
 
 	/* Set up the RPC argument and reply structs
 	 * NB: take care not to mess about with data->commit et al. */
 
-	data->req = req;
-	data->inode = inode = req->wb_context->dentry->d_inode;
-	data->cred = req->wb_context->cred;
+	hdr->req = req;
+	hdr->inode = inode = req->wb_context->dentry->d_inode;
+	hdr->cred = req->wb_context->cred;
 
 	data->args.fh     = NFS_FH(inode);
 	data->args.offset = req_offset(req) + offset;
@@ -935,7 +941,7 @@ static int nfs_do_write(struct nfs_write_data *data,
 		const struct rpc_call_ops *call_ops,
 		int how)
 {
-	struct inode *inode = data->args.context->dentry->d_inode;
+	struct inode *inode = data->header->inode;
 
 	return nfs_initiate_write(NFS_CLIENT(inode), data, call_ops, how);
 }
@@ -981,6 +987,7 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc, struct list_head
 {
 	struct nfs_page *req = nfs_list_entry(desc->pg_list.next);
 	struct page *page = req->wb_page;
+	struct nfs_write_header *whdr;
 	struct nfs_write_data *data;
 	size_t wsize = desc->pg_bsize, nbytes;
 	unsigned int offset;
@@ -1000,9 +1007,10 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc, struct list_head
 	do {
 		size_t len = min(nbytes, wsize);
 
-		data = nfs_writedata_alloc(1);
-		if (!data)
+		whdr = nfs_writehdr_alloc(1);
+		if (!whdr)
 			goto out_bad;
+		data = &whdr->rpc_data;
 		data->pagevec[0] = page;
 		nfs_write_rpcsetup(req, data, len, offset, desc->pg_ioflags);
 		list_add(&data->list, res);
@@ -1036,13 +1044,14 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc, struct list_head *r
 {
 	struct nfs_page		*req;
 	struct page		**pages;
+	struct nfs_write_header	*whdr;
 	struct nfs_write_data	*data;
 	struct list_head *head = &desc->pg_list;
 	int ret = 0;
 
-	data = nfs_writedata_alloc(nfs_page_array_len(desc->pg_base,
-						      desc->pg_count));
-	if (!data) {
+	whdr = nfs_writehdr_alloc(nfs_page_array_len(desc->pg_base,
+						     desc->pg_count));
+	if (!whdr) {
 		while (!list_empty(head)) {
 			req = nfs_list_entry(head->next);
 			nfs_list_remove_request(req);
@@ -1051,14 +1060,15 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc, struct list_head *r
 		ret = -ENOMEM;
 		goto out;
 	}
+	data = &whdr->rpc_data;
 	pages = data->pagevec;
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
-		nfs_list_add_request(req, &data->pages);
+		nfs_list_add_request(req, &whdr->header.pages);
 		*pages++ = req->wb_page;
 	}
-	req = nfs_list_entry(data->pages.next);
+	req = nfs_list_entry(whdr->header.pages.next);
 
 	if ((desc->pg_ioflags & FLUSH_COND_STABLE) &&
 	    (desc->pg_moreio || NFS_I(desc->pg_inode)->ncommit))
@@ -1126,10 +1136,11 @@ static void nfs_writeback_done_partial(struct rpc_task *task, void *calldata)
 
 	dprintk("NFS: %5u write(%s/%lld %d@%lld)",
 		task->tk_pid,
-		data->req->wb_context->dentry->d_inode->i_sb->s_id,
+		data->header->inode->i_sb->s_id,
 		(long long)
-		  NFS_FILEID(data->req->wb_context->dentry->d_inode),
-		data->req->wb_bytes, (long long)req_offset(data->req));
+		  NFS_FILEID(data->header->inode),
+		data->header->req->wb_bytes,
+		(long long)req_offset(data->header->req));
 
 	nfs_writeback_done(task, data);
 }
@@ -1137,7 +1148,7 @@ static void nfs_writeback_done_partial(struct rpc_task *task, void *calldata)
 static void nfs_writeback_release_partial(void *calldata)
 {
 	struct nfs_write_data	*data = calldata;
-	struct nfs_page		*req = data->req;
+	struct nfs_page		*req = data->header->req;
 	struct page		*page = req->wb_page;
 	int status = data->task.tk_status;
 
@@ -1169,13 +1180,13 @@ static void nfs_writeback_release_partial(void *calldata)
 out:
 	if (atomic_dec_and_test(&req->wb_complete))
 		nfs_writepage_release(req, data);
-	nfs_writedata_release(calldata);
+	nfs_writedata_release(data);
 }
 
 void nfs_write_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_write_data *data = calldata;
-	NFS_PROTO(data->inode)->write_rpc_prepare(task, data);
+	NFS_PROTO(data->header->inode)->write_rpc_prepare(task, data);
 }
 
 void nfs_commit_prepare(struct rpc_task *task, void *calldata)
@@ -1208,11 +1219,12 @@ static void nfs_writeback_done_full(struct rpc_task *task, void *calldata)
 static void nfs_writeback_release_full(void *calldata)
 {
 	struct nfs_write_data	*data = calldata;
+	struct nfs_pgio_header *hdr = data->header;
 	int status = data->task.tk_status;
 
 	/* Update attributes as result of writeback. */
-	while (!list_empty(&data->pages)) {
-		struct nfs_page *req = nfs_list_entry(data->pages.next);
+	while (!list_empty(&hdr->pages)) {
+		struct nfs_page *req = nfs_list_entry(hdr->pages.next);
 		struct page *page = req->wb_page;
 
 		nfs_list_remove_request(req);
@@ -1233,7 +1245,7 @@ static void nfs_writeback_release_full(void *calldata)
 
 		if (nfs_write_need_commit(data)) {
 			memcpy(&req->wb_verf, &data->verf, sizeof(req->wb_verf));
-			nfs_mark_request_commit(req, data->lseg);
+			nfs_mark_request_commit(req, hdr->lseg);
 			dprintk(" marked for commit\n");
 			goto next;
 		}
@@ -1244,7 +1256,7 @@ remove_request:
 		nfs_unlock_request(req);
 		nfs_end_page_writeback(page);
 	}
-	nfs_writedata_release(calldata);
+	nfs_writedata_release(data);
 }
 
 static const struct rpc_call_ops nfs_write_full_ops = {
@@ -1261,6 +1273,7 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct nfs_writeargs	*argp = &data->args;
 	struct nfs_writeres	*resp = &data->res;
+	struct inode		*inode = data->header->inode;
 	int status;
 
 	dprintk("NFS: %5u nfs_writeback_done (status %d)\n",
@@ -1273,10 +1286,10 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 	 * another writer had changed the file, but some applications
 	 * depend on tighter cache coherency when writing.
 	 */
-	status = NFS_PROTO(data->inode)->write_done(task, data);
+	status = NFS_PROTO(inode)->write_done(task, data);
 	if (status != 0)
 		return;
-	nfs_add_stats(data->inode, NFSIOS_SERVERWRITTENBYTES, resp->count);
+	nfs_add_stats(inode, NFSIOS_SERVERWRITTENBYTES, resp->count);
 
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 	if (resp->verf->committed < argp->stable && task->tk_status >= 0) {
@@ -1294,7 +1307,7 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 		if (time_before(complain, jiffies)) {
 			dprintk("NFS:       faulty NFS server %s:"
 				" (committed = %d) != (stable = %d)\n",
-				NFS_SERVER(data->inode)->nfs_client->cl_hostname,
+				NFS_SERVER(inode)->nfs_client->cl_hostname,
 				resp->verf->committed, argp->stable);
 			complain = jiffies + 300 * HZ;
 		}
@@ -1304,7 +1317,7 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 	if (task->tk_status >= 0 && resp->count < argp->count) {
 		static unsigned long    complain;
 
-		nfs_inc_stats(data->inode, NFSIOS_SHORTWRITE);
+		nfs_inc_stats(inode, NFSIOS_SHORTWRITE);
 
 		/* Has the server at least made some progress? */
 		if (resp->count != 0) {
@@ -1333,7 +1346,6 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 		/* Can't do anything about it except throw an error. */
 		task->tk_status = -EIO;
 	}
-	return;
 }
 
 
@@ -1745,7 +1757,7 @@ int nfs_migrate_page(struct address_space *mapping, struct page *newpage,
 int __init nfs_init_writepagecache(void)
 {
 	nfs_wdata_cachep = kmem_cache_create("nfs_write_data",
-					     sizeof(struct nfs_write_data),
+					     sizeof(struct nfs_write_header),
 					     0, SLAB_HWCACHE_ALIGN,
 					     NULL);
 	if (nfs_wdata_cachep == NULL)
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index d5d68f3..8d3a2b8 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -569,12 +569,6 @@ nfs_have_writebacks(struct inode *inode)
 }
 
 /*
- * Allocate nfs_write_data structures
- */
-extern struct nfs_write_data *nfs_writedata_alloc(unsigned int npages);
-extern void nfs_writedata_free(struct nfs_write_data *);
-
-/*
  * linux/fs/nfs/read.c
  */
 extern int  nfs_readpage(struct file *, struct page *);
@@ -585,12 +579,6 @@ extern int  nfs_readpage_async(struct nfs_open_context *, struct inode *,
 			       struct page *);
 
 /*
- * Allocate nfs_read_data structures
- */
-extern struct nfs_read_data *nfs_readdata_alloc(unsigned int npages);
-extern void nfs_readdata_free(struct nfs_read_data *);
-
-/*
  * linux/fs/nfs3proc.c
  */
 #ifdef CONFIG_NFS_V3_ACL
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 2aff66d..0e31c44 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1163,52 +1163,58 @@ struct nfs_page;
 #define NFS_PAGEVEC_SIZE	(8U)
 
 struct nfs_read_data {
+	struct nfs_pgio_header	*header;
+	struct list_head	list;
 	struct rpc_task		task;
-	struct inode		*inode;
-	struct rpc_cred		*cred;
 	struct nfs_fattr	fattr;	/* fattr storage */
-	struct list_head	pages;	/* Coalesced read requests */
-	struct list_head	list;	/* lists of struct nfs_read_data */
-	struct nfs_page		*req;	/* multi ops per nfs_page */
 	struct page		**pagevec;
 	unsigned int		npages;	/* Max length of pagevec */
 	struct nfs_readargs args;
 	struct nfs_readres  res;
 	unsigned long		timestamp;	/* For lease renewal */
-	struct pnfs_layout_segment *lseg;
-	struct nfs_client	*ds_clp;	/* pNFS data server */
-	const struct rpc_call_ops *mds_ops;
 	int (*read_done_cb) (struct rpc_task *task, struct nfs_read_data *data);
 	__u64			mds_offset;
-	int			pnfs_error;
 	struct page		*page_array[NFS_PAGEVEC_SIZE];
+	struct nfs_client	*ds_clp;	/* pNFS data server */
+};
+
+struct nfs_pgio_header {
+	struct inode		*inode;
+	struct rpc_cred		*cred;
+	struct list_head	pages;
+	struct nfs_page		*req;
+	struct pnfs_layout_segment *lseg;
+	const struct rpc_call_ops *mds_ops;
+	int			pnfs_error;
+};
+
+struct nfs_read_header {
+	struct nfs_pgio_header	header;
+	struct nfs_read_data	rpc_data;
 };
 
 struct nfs_direct_req;
 
 struct nfs_write_data {
+	struct nfs_pgio_header	*header;
+	struct list_head	list;
 	struct rpc_task		task;
-	struct inode		*inode;
-	struct rpc_cred		*cred;
 	struct nfs_fattr	fattr;
 	struct nfs_writeverf	verf;
-	struct list_head	pages;		/* Coalesced requests we wish to flush */
-	struct list_head	list;		/* lists of struct nfs_write_data */
-	struct nfs_page		*req;		/* multi ops per nfs_page */
 	struct page		**pagevec;
 	unsigned int		npages;		/* Max length of pagevec */
 	struct nfs_writeargs	args;		/* argument struct */
 	struct nfs_writeres	res;		/* result struct */
-	struct pnfs_layout_segment *lseg;
-	struct nfs_client	*ds_clp;	/* pNFS data server */
-	const struct rpc_call_ops *mds_ops;
-	int (*write_done_cb) (struct rpc_task *task, struct nfs_write_data *data);
-#ifdef CONFIG_NFS_V4
 	unsigned long		timestamp;	/* For lease renewal */
-#endif
+	int (*write_done_cb) (struct rpc_task *task, struct nfs_write_data *data);
 	__u64			mds_offset;	/* Filelayout dense stripe */
-	int			pnfs_error;
 	struct page		*page_array[NFS_PAGEVEC_SIZE];
+	struct nfs_client	*ds_clp;	/* pNFS data server */
+};
+
+struct nfs_write_header {
+	struct nfs_pgio_header	header;
+	struct nfs_write_data	rpc_data;
 };
 
 struct nfs_commit_data {
-- 
1.7.2.1


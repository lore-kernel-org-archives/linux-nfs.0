Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:40478 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753757Ab1GUTew (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jul 2011 15:34:52 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH v2 24/25] pnfsblock: write_pagelist handle zero invalid extents
Date: Thu, 21 Jul 2011 15:34:24 -0400
Message-Id: <1311276865-29484-25-git-send-email-rees@umich.edu>
In-Reply-To: <1311276865-29484-1-git-send-email-rees@umich.edu>
References: <1311276865-29484-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Peng Tao <bergwolf@gmail.com>

For invalid extents, find other pages in the same fsblock and write them out.

[pnfsblock: write_begin]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <benny@tonian.com>
Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/blocklayout/blocklayout.c |  275 ++++++++++++++++++++++++++++++++------
 1 files changed, 233 insertions(+), 42 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 190b61f..f104a66 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -35,6 +35,7 @@
 #include <linux/mount.h>
 #include <linux/namei.h>
 #include <linux/bio.h>		/* struct bio */
+#include <linux/buffer_head.h>	/* various write calls */
 
 #include "blocklayout.h"
 
@@ -79,12 +80,8 @@ static int is_hole(struct pnfs_block_extent *be, sector_t isect)
  */
 static int is_writable(struct pnfs_block_extent *be, sector_t isect)
 {
-	if (be->be_state == PNFS_BLOCK_READWRITE_DATA)
-		return 1;
-	else if (be->be_state != PNFS_BLOCK_INVALID_DATA)
-		return 0;
-	else
-		return is_sector_initialized(be->be_inval, isect);
+	return (be->be_state == PNFS_BLOCK_READWRITE_DATA ||
+		be->be_state == PNFS_BLOCK_INVALID_DATA);
 }
 
 static int
@@ -370,6 +367,31 @@ static void mark_extents_written(struct pnfs_block_layout *bl,
 	}
 }
 
+static void bl_end_io_write_zero(struct bio *bio, int err)
+{
+	struct parallel_io *par = bio->bi_private;
+	const int uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
+	struct bio_vec *bvec = bio->bi_io_vec + bio->bi_vcnt - 1;
+	struct nfs_write_data *wdata = (struct nfs_write_data *)par->data;
+
+	do {
+		struct page *page = bvec->bv_page;
+
+		if (--bvec >= bio->bi_io_vec)
+			prefetchw(&bvec->bv_page->flags);
+		/* This is the zeroing page we added */
+		end_page_writeback(page);
+		page_cache_release(page);
+	} while (bvec >= bio->bi_io_vec);
+	if (!uptodate) {
+		if (!wdata->pnfs_error)
+			wdata->pnfs_error = -EIO;
+		bl_set_lo_fail(wdata->lseg);
+	}
+	bio_put(bio);
+	put_parallel(par);
+}
+
 /* This is basically copied from mpage_end_io_read */
 static void bl_end_io_write(struct bio *bio, int err)
 {
@@ -396,11 +418,8 @@ static void bl_write_cleanup(struct work_struct *work)
 	dprintk("%s enter\n", __func__);
 	task = container_of(work, struct rpc_task, u.tk_work);
 	wdata = container_of(task, struct nfs_write_data, task);
-	if (!wdata->task.tk_status) {
+	if (!wdata->pnfs_error) {
 		/* Marks for LAYOUTCOMMIT */
-		/* BUG - this should be called after each bio, not after
-		 * all finish, unless have some way of storing success/failure
-		 */
 		mark_extents_written(BLK_LSEG2EXT(wdata->lseg),
 				     wdata->args.offset, wdata->args.count);
 	}
@@ -408,30 +427,105 @@ static void bl_write_cleanup(struct work_struct *work)
 }
 
 /* Called when last of bios associated with a bl_write_pagelist call finishes */
-static void
-bl_end_par_io_write(void *data)
+static void bl_end_par_io_write(void *data)
 {
 	struct nfs_write_data *wdata = data;
 
-	/* STUB - ignoring error handling */
 	wdata->task.tk_status = 0;
 	wdata->verf.committed = NFS_FILE_SYNC;
 	INIT_WORK(&wdata->task.u.tk_work, bl_write_cleanup);
 	schedule_work(&wdata->task.u.tk_work);
 }
 
+/* STUB - mark intersection of layout and page as bad, so is not
+ * used again.
+ */
+static void mark_bad_read(void)
+{
+	return;
+}
+
+/*
+ * map_block:  map a requested I/0 block (isect) into an offset in the LVM
+ * block_device
+ */
+static void
+map_block(struct buffer_head *bh, sector_t isect, struct pnfs_block_extent *be)
+{
+	dprintk("%s enter be=%p\n", __func__, be);
+
+	set_buffer_mapped(bh);
+	bh->b_bdev = be->be_mdev;
+	bh->b_blocknr = (isect - be->be_f_offset + be->be_v_offset) >>
+	    (be->be_mdev->bd_inode->i_blkbits - SECTOR_SHIFT);
+
+	dprintk("%s isect %llu, bh->b_blocknr %ld, using bsize %Zd\n",
+		__func__, (unsigned long long)isect, (long)bh->b_blocknr,
+		bh->b_size);
+	return;
+}
+
+/* Given an unmapped page, zero it or read in page for COW, page is locked
+ * by caller.
+ */
+static int
+init_page_for_write(struct page *page, struct pnfs_block_extent *cow_read)
+{
+	struct buffer_head *bh = NULL;
+	int ret = 0;
+	sector_t isect;
+
+	dprintk("%s enter, %p\n", __func__, page);
+	BUG_ON(PageUptodate(page));
+	if (!cow_read) {
+		zero_user_segment(page, 0, PAGE_SIZE);
+		SetPageUptodate(page);
+		goto cleanup;
+	}
+
+	bh = alloc_page_buffers(page, PAGE_CACHE_SIZE, 0);
+	if (!bh) {
+		ret = -ENOMEM;
+		goto cleanup;
+	}
+
+	isect = (sector_t) page->index << PAGE_CACHE_SECTOR_SHIFT;
+	map_block(bh, isect, cow_read);
+	if (!bh_uptodate_or_lock(bh))
+		ret = bh_submit_read(bh);
+	if (ret)
+		goto cleanup;
+	SetPageUptodate(page);
+
+cleanup:
+	bl_put_extent(cow_read);
+	if (bh)
+		free_buffer_head(bh);
+	if (ret) {
+		/* Need to mark layout with bad read...should now
+		 * just use nfs4 for reads and writes.
+		 */
+		mark_bad_read();
+	}
+	return ret;
+}
+
 static enum pnfs_try_status
 bl_write_pagelist(struct nfs_write_data *wdata, int sync)
 {
-	int i;
+	int i, ret, npg_zero, pg_index, last = 0;
 	struct bio *bio = NULL;
-	struct pnfs_block_extent *be = NULL;
-	sector_t isect, extent_length = 0;
+	struct pnfs_block_extent *be = NULL, *cow_read = NULL;
+	sector_t isect, last_isect = 0, extent_length = 0;
 	struct parallel_io *par;
 	loff_t offset = wdata->args.offset;
 	size_t count = wdata->args.count;
 	struct page **pages = wdata->args.pages;
-	int pg_index = wdata->args.pgbase >> PAGE_CACHE_SHIFT;
+	struct page *page;
+	pgoff_t index;
+	u64 temp;
+	int npg_per_block =
+	    NFS_SERVER(wdata->inode)->pnfs_blksize >> PAGE_CACHE_SHIFT;
 
 	dprintk("%s enter, %Zu@%lld\n", __func__, count, offset);
 	if (!wdata->lseg) {
@@ -443,11 +537,8 @@ bl_write_pagelist(struct nfs_write_data *wdata, int sync)
 		return PNFS_NOT_ATTEMPTED;
 	}
 	/* At this point, wdata->pages is a (sequential) list of nfs_pages.
-	 * We want to write each, and if there is an error remove it from
-	 * list and call
-	 * nfs_retry_request(req) to have it redone using nfs.
-	 * QUEST? Do as block or per req?  Think have to do per block
-	 * as part of end_bio
+	 * We want to write each, and if there is an error set pnfs_error
+	 * to have it redone using nfs.
 	 */
 	par = alloc_parallel(wdata);
 	if (!par)
@@ -458,7 +549,91 @@ bl_write_pagelist(struct nfs_write_data *wdata, int sync)
 	/* At this point, have to be more careful with error handling */
 
 	isect = (sector_t) ((offset & (long)PAGE_CACHE_MASK) >> SECTOR_SHIFT);
-	for (i = pg_index; i < wdata->npages ; i++) {
+	be = bl_find_get_extent(BLK_LSEG2EXT(wdata->lseg), isect, &cow_read);
+	if (!be || !is_writable(be, isect)) {
+		dprintk("%s no matching extents!\n", __func__);
+		wdata->pnfs_error = -EINVAL;
+		goto out;
+	}
+
+	/* First page inside INVALID extent */
+	if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
+		temp = offset >> PAGE_CACHE_SHIFT;
+		npg_zero = do_div(temp, npg_per_block);
+		isect = (sector_t) (((offset - npg_zero * PAGE_CACHE_SIZE) &
+				     (long)PAGE_CACHE_MASK) >> SECTOR_SHIFT);
+		extent_length = be->be_length - (isect - be->be_f_offset);
+
+fill_invalid_ext:
+		dprintk("%s need to zero %d pages\n", __func__, npg_zero);
+		for (;npg_zero > 0; npg_zero--) {
+			/* page ref released in bl_end_io_write_zero */
+			index = isect >> PAGE_CACHE_SECTOR_SHIFT;
+			dprintk("%s zero %dth page: index %lu isect %llu\n",
+				__func__, npg_zero, index,
+				(unsigned long long)isect);
+			page =
+			    find_or_create_page(wdata->inode->i_mapping, index,
+						GFP_NOFS);
+			if (!page) {
+				dprintk("%s oom\n", __func__);
+				wdata->pnfs_error = -ENOMEM;
+				goto out;
+			}
+
+			/* PageDirty: Other will write this out
+			 * PageWriteback: Other is writing this out
+			 * PageUptodate: It was read before
+			 * sector_initialized: already written out
+			 */
+			if (PageDirty(page) || PageWriteback(page) ||
+			    is_sector_initialized(be->be_inval, isect)) {
+				print_page(page);
+				unlock_page(page);
+				page_cache_release(page);
+				goto next_page;
+			}
+			if (!PageUptodate(page)) {
+				/* New page, readin or zero it */
+				init_page_for_write(page, cow_read);
+			}
+			set_page_writeback(page);
+			unlock_page(page);
+
+			ret = bl_mark_sectors_init(be->be_inval, isect,
+						       PAGE_CACHE_SECTORS,
+						       NULL);
+			if (unlikely(ret)) {
+				dprintk("%s bl_mark_sectors_init fail %d\n",
+					__func__, ret);
+				end_page_writeback(page);
+				page_cache_release(page);
+				wdata->pnfs_error = ret;
+				goto out;
+			}
+			bio = bl_add_page_to_bio(bio, npg_zero, WRITE,
+						 isect, page, be,
+						 bl_end_io_write_zero, par);
+			if (IS_ERR(bio)) {
+				wdata->pnfs_error = PTR_ERR(bio);
+				goto out;
+			}
+			/* FIXME: This should be done in bi_end_io */
+			mark_extents_written(BLK_LSEG2EXT(wdata->lseg),
+					     page->index << PAGE_CACHE_SHIFT,
+					     PAGE_CACHE_SIZE);
+next_page:
+			isect += PAGE_CACHE_SECTORS;
+			extent_length -= PAGE_CACHE_SECTORS;
+		}
+		if (last)
+			goto write_done;
+	}
+	bio = bl_submit_bio(WRITE, bio);
+
+	/* Middle pages */
+	pg_index = wdata->args.pgbase >> PAGE_CACHE_SHIFT;
+	for (i = pg_index; i < wdata->npages; i++) {
 		if (!extent_length) {
 			/* We've used up the previous extent */
 			bl_put_extent(be);
@@ -467,35 +642,51 @@ bl_write_pagelist(struct nfs_write_data *wdata, int sync)
 			be = bl_find_get_extent(BLK_LSEG2EXT(wdata->lseg),
 					     isect, NULL);
 			if (!be || !is_writable(be, isect)) {
-				wdata->pnfs_error = -ENOMEM;
+				wdata->pnfs_error = -EINVAL;
 				goto out;
 			}
 			extent_length = be->be_length -
-				(isect - be->be_f_offset);
+			    (isect - be->be_f_offset);
 		}
-		for (;;) {
-			if (!bio) {
-				bio = bio_alloc(GFP_NOIO, wdata->npages - i);
-				if (!bio) {
-					wdata->pnfs_error = -ENOMEM;
-					goto out;
-				}
-				bio->bi_sector = isect - be->be_f_offset +
-					be->be_v_offset;
-				bio->bi_bdev = be->be_mdev;
-				bio->bi_end_io = bl_end_io_write;
-				bio->bi_private = par;
+		if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
+			ret = bl_mark_sectors_init(be->be_inval, isect,
+						       PAGE_CACHE_SECTORS,
+						       NULL);
+			if (unlikely(ret)) {
+				dprintk("%s bl_mark_sectors_init fail %d\n",
+					__func__, ret);
+				wdata->pnfs_error = ret;
+				goto out;
 			}
-			if (bio_add_page(bio, pages[i], PAGE_SIZE, 0))
-				break;
-			bio = bl_submit_bio(WRITE, bio);
+		}
+		bio = bl_add_page_to_bio(bio, wdata->npages - i, WRITE,
+					 isect, pages[i], be,
+					 bl_end_io_write, par);
+		if (IS_ERR(bio)) {
+			wdata->pnfs_error = PTR_ERR(bio);
+			goto out;
 		}
 		isect += PAGE_CACHE_SECTORS;
+		last_isect = isect;
 		extent_length -= PAGE_CACHE_SECTORS;
 	}
-	wdata->res.count = (isect << SECTOR_SHIFT) - (offset);
-	if (count < wdata->res.count)
+
+	/* Last page inside INVALID extent */
+	if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
+		bio = bl_submit_bio(WRITE, bio);
+		temp = last_isect >> PAGE_CACHE_SECTOR_SHIFT;
+		npg_zero = npg_per_block - do_div(temp, npg_per_block);
+		if (npg_zero < npg_per_block) {
+			last = 1;
+			goto fill_invalid_ext;
+		}
+	}
+
+write_done:
+	wdata->res.count = (last_isect << SECTOR_SHIFT) - (offset);
+	if (count < wdata->res.count) {
 		wdata->res.count = count;
+	}
 out:
 	bl_put_extent(be);
 	bl_submit_bio(WRITE, bio);
-- 
1.7.4.1


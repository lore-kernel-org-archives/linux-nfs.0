Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:61954 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932078Ab1GNScY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jul 2011 14:32:24 -0400
Received: by eyx24 with SMTP id 24so325991eyx.19
        for <linux-nfs@vger.kernel.org>; Thu, 14 Jul 2011 11:32:22 -0700 (PDT)
Message-ID: <4E1F3630.1090708@tonian.com>
Date: Thu, 14 Jul 2011 21:32:16 +0300
From: Benny Halevy <bhalevy@tonian.com>
To: Jim Rees <rees@umich.edu>
CC: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: block layout patches
References: <20110714165004.GA2607@merit.edu> <20110714165348.GA13287@infradead.org> <20110714170924.GC2607@merit.edu>
In-Reply-To: <20110714170924.GC2607@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-07-14 20:09, Jim Rees wrote:
> Christoph Hellwig wrote:
> 
>   Err, what about actually posting them for review first?  The only thing
>   so far has been all that squashme mess.
> 
> Sorry for the missing context.  About a month ago I sent out an 88 patch set
> for pNFS Bakeathon.  That was a squashme mess.  Later I sent a 35 patch set,
> and got back a number of comments.  That's had a number of re-writes
> resulting in the current patch set, which is 28 patches.
> 
> While you're certainly welcome to review what's there now, it's mostly meant
> for Benny to pull into his tree to resolve any issues merging with other
> pNFS patches that haven't gone upstream yet.

I've pulled (rebased actually) your for-trond branch into my tree.
The new tip is at pnfs-all-3.0-rc7-2011-07-14
I like how using bl_add_page_to_bio turned out.
For the record, the diff against pnfs-block.orig is down below
(it does not include whitespace changes)

Benny

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 8531fd7..aa4f6ed 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -75,12 +75,8 @@ static int is_hole(struct pnfs_block_extent *be, sector_t isect)
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
@@ -109,7 +105,7 @@ static inline struct parallel_io *alloc_parallel(void *data)
 {
 	struct parallel_io *rv;

-	rv  = kmalloc(sizeof(*rv), GFP_KERNEL);
+	rv  = kmalloc(sizeof(*rv), GFP_NOFS);
 	if (rv) {
 		rv->data = data;
 		kref_init(&rv->refcnt);
@@ -143,42 +139,83 @@ bl_submit_bio(int rw, struct bio *bio)
 		get_parallel(bio->bi_private);
 		dprintk("%s submitting %s bio %u@%llu\n", __func__,
 			rw == READ ? "read" : "write",
-			bio->bi_size, (u64)bio->bi_sector);
+			bio->bi_size, (unsigned long long)bio->bi_sector);
 		submit_bio(rw, bio);
 	}
 	return NULL;
 }

-static inline void
-bl_done_with_rpage(struct page *page, const int ok)
+static struct bio *bl_alloc_init_bio(int npg, sector_t isect,
+				     struct pnfs_block_extent *be,
+				     void (*end_io)(struct bio *, int err),
+				     struct parallel_io *par)
 {
-	if (ok) {
-		ClearPagePnfsErr(page);
-		SetPageUptodate(page);
+	struct bio *bio;
+
+	bio = bio_alloc(GFP_NOIO, npg);
+	if (!bio)
+		return NULL;
+
+	bio->bi_sector = isect - be->be_f_offset + be->be_v_offset;
+	bio->bi_bdev = be->be_mdev;
+	bio->bi_end_io = end_io;
+	bio->bi_private = par;
+	return bio;
+}
+
+static struct bio *bl_add_page_to_bio(struct bio *bio, int npg, int rw,
+				      sector_t isect, struct page *page,
+				      struct pnfs_block_extent *be,
+				      void (*end_io)(struct bio *, int err),
+				      struct parallel_io *par)
+{
+retry:
+	if (!bio) {
+		bio = bl_alloc_init_bio(npg, isect, be, end_io, par);
+		if (!bio)
+			return ERR_PTR(-ENOMEM);
+	}
+	if (bio_add_page(bio, page, PAGE_CACHE_SIZE, 0) < PAGE_CACHE_SIZE) {
+		bio = bl_submit_bio(rw, bio);
+		goto retry;
+	}
+	return bio;
+}
+
+static void bl_set_lo_fail(struct pnfs_layout_segment *lseg)
+{
+	if (lseg->pls_range.iomode == IOMODE_RW) {
+		dprintk("%s Setting layout IOMODE_RW fail bit\n", __func__);
+		set_bit(lo_fail_bit(IOMODE_RW), &lseg->pls_layout->plh_flags);
 	} else {
-		ClearPageUptodate(page);
-		SetPageError(page);
-		SetPagePnfsErr(page);
+		dprintk("%s Setting layout IOMODE_READ fail bit\n", __func__);
+		set_bit(lo_fail_bit(IOMODE_READ), &lseg->pls_layout->plh_flags);
 	}
-	/* Page is unlocked via rpc_release.  Should really be done here. */
 }

 /* This is basically copied from mpage_end_io_read */
 static void bl_end_io_read(struct bio *bio, int err)
 {
-	void *data = bio->bi_private;
+	struct parallel_io *par = bio->bi_private;
 	const int uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
 	struct bio_vec *bvec = bio->bi_io_vec + bio->bi_vcnt - 1;
+	struct nfs_read_data *rdata = (struct nfs_read_data *)par->data;

 	do {
 		struct page *page = bvec->bv_page;

 		if (--bvec >= bio->bi_io_vec)
 			prefetchw(&bvec->bv_page->flags);
-		bl_done_with_rpage(page, uptodate);
+		if (uptodate)
+			SetPageUptodate(page);
 	} while (bvec >= bio->bi_io_vec);
+	if (!uptodate) {
+		if (!rdata->pnfs_error)
+			rdata->pnfs_error = -EIO;
+		bl_set_lo_fail(rdata->lseg);
+	}
 	bio_put(bio);
-	put_parallel(data);
+	put_parallel(par);
 }

 static void bl_read_cleanup(struct work_struct *work)
@@ -228,13 +265,7 @@ bl_read_pagelist(struct nfs_read_data *rdata)
 		dprintk("%s dont_like_caller failed\n", __func__);
 		goto use_mds;
 	}
-	if ((rdata->npages == 1) && PagePnfsErr(rdata->req->wb_page)) {
-		/* We want to fall back to mds in case of read_page
-		 * after error on read_pages.
-		 */
-		dprintk("%s PG_pnfserr set\n", __func__);
-		goto use_mds;
-	}
+
 	par = alloc_parallel(rdata);
 	if (!par)
 		goto use_mds;
@@ -243,21 +274,20 @@ bl_read_pagelist(struct nfs_read_data *rdata)
 	par->pnfs_callback = bl_end_par_io_read;
 	/* At this point, we can no longer jump to use_mds */

-	isect = (sector_t) (f_offset >> 9);
+	isect = (sector_t) (f_offset >> SECTOR_SHIFT);
 	/* Code assumes extents are page-aligned */
 	for (i = pg_index; i < rdata->npages; i++) {
 		if (!extent_length) {
 			/* We've used up the previous extent */
-			put_extent(be);
-			put_extent(cow_read);
+			bl_put_extent(be);
+			bl_put_extent(cow_read);
 			bio = bl_submit_bio(READ, bio);
 			/* Get the next one */
-			be = find_get_extent(BLK_LSEG2EXT(rdata->lseg),
+			be = bl_find_get_extent(BLK_LSEG2EXT(rdata->lseg),
 					     isect, &cow_read);
 			if (!be) {
-				/* Error out this page */
-				bl_done_with_rpage(pages[i], 0);
-				break;
+				rdata->pnfs_error = -EIO;
+				goto out;
 			}
 			extent_length = be->be_length -
 				(isect - be->be_f_offset);
@@ -272,45 +302,33 @@ bl_read_pagelist(struct nfs_read_data *rdata)
 			bio = bl_submit_bio(READ, bio);
 			/* Fill hole w/ zeroes w/o accessing device */
 			dprintk("%s Zeroing page for hole\n", __func__);
-			zero_user(pages[i], 0,
-				  min_t(int, PAGE_CACHE_SIZE, count));
+			zero_user_segment(pages[i], 0, PAGE_CACHE_SIZE);
 			print_page(pages[i]);
-			bl_done_with_rpage(pages[i], 1);
+			SetPageUptodate(pages[i]);
 		} else {
 			struct pnfs_block_extent *be_read;

 			be_read = (hole && cow_read) ? cow_read : be;
-			for (;;) {
-				if (!bio) {
-					bio = bio_alloc(GFP_NOIO, rdata->npages - i);
-					if (!bio) {
-						/* Error out this page */
-						bl_done_with_rpage(pages[i], 0);
-						break;
-					}
-					bio->bi_sector = isect -
-						be_read->be_f_offset +
-						be_read->be_v_offset;
-					bio->bi_bdev = be_read->be_mdev;
-					bio->bi_end_io = bl_end_io_read;
-					bio->bi_private = par;
-				}
-				if (bio_add_page(bio, pages[i], PAGE_SIZE, 0))
-					break;
-				bio = bl_submit_bio(READ, bio);
+			bio = bl_add_page_to_bio(bio, rdata->npages - i, READ,
+						 isect, pages[i], be_read,
+						 bl_end_io_read, par);
+			if (IS_ERR(bio)) {
+				rdata->pnfs_error = PTR_ERR(bio);
+				goto out;
 			}
 		}
-		isect += PAGE_CACHE_SIZE >> 9;
-		extent_length -= PAGE_CACHE_SIZE >> 9;
+		isect += PAGE_CACHE_SECTORS;
+		extent_length -= PAGE_CACHE_SECTORS;
 	}
-	if ((isect << 9) >= rdata->inode->i_size) {
+	if ((isect << SECTOR_SHIFT) >= rdata->inode->i_size) {
 		rdata->res.eof = 1;
 		rdata->res.count = rdata->inode->i_size - f_offset;
 	} else {
-		rdata->res.count = (isect << 9) - f_offset;
+		rdata->res.count = (isect << SECTOR_SHIFT) - f_offset;
 	}
-	put_extent(be);
-	put_extent(cow_read);
+out:
+	bl_put_extent(be);
+	bl_put_extent(cow_read);
 	bl_submit_bio(READ, bio);
 	put_parallel(par);
 	return PNFS_ATTEMPTED;
@@ -329,56 +347,60 @@ static void mark_extents_written(struct pnfs_block_layout *bl,
 	dprintk("%s(%llu, %u)\n", __func__, offset, count);
 	if (count == 0)
 		return;
-	isect = (offset & (long)(PAGE_CACHE_MASK)) >> 9;
+	isect = (offset & (long)(PAGE_CACHE_MASK)) >> SECTOR_SHIFT;
 	end = (offset + count + PAGE_CACHE_SIZE - 1) & (long)(PAGE_CACHE_MASK);
-	end >>= 9;
+	end >>= SECTOR_SHIFT;
 	while (isect < end) {
 		sector_t len;
-		be = find_get_extent(bl, isect, NULL);
+		be = bl_find_get_extent(bl, isect, NULL);
 		BUG_ON(!be); /* FIXME */
 		len = min(end, be->be_f_offset + be->be_length) - isect;
 		if (be->be_state == PNFS_BLOCK_INVALID_DATA)
 			mark_for_commit(be, isect, len); /* What if fails? */
 		isect += len;
-		put_extent(be);
-	}
-}
-
-/* STUB - this needs thought */
-static inline void
-bl_done_with_wpage(struct page *page, const int ok)
-{
-	if (!ok) {
-		SetPageError(page);
-		SetPagePnfsErr(page);
-		/* This is an inline copy of nfs_zap_mapping */
-		/* This is oh so fishy, and needs deep thought */
-		if (page->mapping->nrpages != 0) {
-			struct inode *inode = page->mapping->host;
-			spin_lock(&inode->i_lock);
-			NFS_I(inode)->cache_validity |= NFS_INO_INVALID_DATA;
-			spin_unlock(&inode->i_lock);
-		}
+		bl_put_extent(be);
 	}
-	/* end_page_writeback called in rpc_release.  Should be done here. */
 }

-/* This is basically copied from mpage_end_io_read */
-static void bl_end_io_write(struct bio *bio, int err)
+static void bl_end_io_write_zero(struct bio *bio, int err)
 {
-	void *data = bio->bi_private;
+	struct parallel_io *par = bio->bi_private;
 	const int uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
 	struct bio_vec *bvec = bio->bi_io_vec + bio->bi_vcnt - 1;
+	struct nfs_write_data *wdata = (struct nfs_write_data *)par->data;

 	do {
 		struct page *page = bvec->bv_page;

 		if (--bvec >= bio->bi_io_vec)
 			prefetchw(&bvec->bv_page->flags);
-		bl_done_with_wpage(page, uptodate);
+		/* This is the zeroing page we added */
+		end_page_writeback(page);
+		page_cache_release(page);
 	} while (bvec >= bio->bi_io_vec);
+	if (!uptodate) {
+		if (!wdata->pnfs_error)
+			wdata->pnfs_error = -EIO;
+		bl_set_lo_fail(wdata->lseg);
+	}
 	bio_put(bio);
-	put_parallel(data);
+	put_parallel(par);
+}
+
+/* This is basically copied from mpage_end_io_read */
+static void bl_end_io_write(struct bio *bio, int err)
+{
+	struct parallel_io *par = bio->bi_private;
+	const int uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
+	struct nfs_write_data *wdata = (struct nfs_write_data *)par->data;
+
+	if (!uptodate) {
+		if (!wdata->pnfs_error)
+			wdata->pnfs_error = -EIO;
+		bl_set_lo_fail(wdata->lseg);
+	}
+	bio_put(bio);
+	put_parallel(par);
 }

 /* Function scheduled for call during bl_end_par_io_write,
@@ -391,11 +413,8 @@ static void bl_write_cleanup(struct work_struct *work)
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
@@ -403,31 +422,103 @@ static void bl_write_cleanup(struct work_struct *work)
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
+	dprintk("%s isect %ld, bh->b_blocknr %ld, using bsize %Zd\n",
+		__func__, (long)isect, (long)bh->b_blocknr, bh->b_size);
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
-bl_write_pagelist(struct nfs_write_data *wdata,
-		  int sync)
+bl_write_pagelist(struct nfs_write_data *wdata, int sync)
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
+	int npg_per_block =
+	    NFS_SERVER(wdata->inode)->pnfs_blksize >> PAGE_CACHE_SHIFT;

 	dprintk("%s enter, %Zu@%lld\n", __func__, count, offset);
 	if (!wdata->lseg) {
@@ -439,11 +530,8 @@ bl_write_pagelist(struct nfs_write_data *wdata,
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
@@ -453,49 +541,145 @@ bl_write_pagelist(struct nfs_write_data *wdata,
 	par->pnfs_callback = bl_end_par_io_write;
 	/* At this point, have to be more careful with error handling */

-	isect = (sector_t) ((offset & (long)PAGE_CACHE_MASK) >> 9);
+	isect = (sector_t) ((offset & (long)PAGE_CACHE_MASK) >> SECTOR_SHIFT);
+	be = bl_find_get_extent(BLK_LSEG2EXT(wdata->lseg), isect, &cow_read);
+	if (!be || !is_writable(be, isect)) {
+		dprintk("%s no matching extents!\n", __func__);
+		wdata->pnfs_error = -EINVAL;
+		goto out;
+	}
+
+	/* First page inside INVALID extent */
+	if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
+		npg_zero = (offset >> PAGE_CACHE_SHIFT) % npg_per_block;
+		isect = (sector_t) (((offset - npg_zero * PAGE_CACHE_SIZE) &
+				     (long)PAGE_CACHE_MASK) >> SECTOR_SHIFT);
+		extent_length = be->be_length - (isect - be->be_f_offset);
+
+fill_invalid_ext:
+		dprintk("%s need to zero %d pages\n", __func__, npg_zero);
+		for (;npg_zero > 0; npg_zero--) {
+			/* page ref released in bl_end_io_write_zero */
+			index = isect >> PAGE_CACHE_SECTOR_SHIFT;
+			dprintk("%s zero %dth page: index %lu isect %lu\n",
+				__func__, npg_zero, index, isect);
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
 	for (i = pg_index; i < wdata->npages ; i++) {
 		if (!extent_length) {
 			/* We've used up the previous extent */
-			put_extent(be);
+			bl_put_extent(be);
 			bio = bl_submit_bio(WRITE, bio);
 			/* Get the next one */
-			be = find_get_extent(BLK_LSEG2EXT(wdata->lseg),
+			be = bl_find_get_extent(BLK_LSEG2EXT(wdata->lseg),
 					     isect, NULL);
 			if (!be || !is_writable(be, isect)) {
-				/* FIXME */
-				bl_done_with_wpage(pages[i], 0);
-				break;
+				wdata->pnfs_error = -EINVAL;
+				goto out;
 			}
 			extent_length = be->be_length -
 				(isect - be->be_f_offset);
 		}
-		for (;;) {
-			if (!bio) {
-				bio = bio_alloc(GFP_NOIO, wdata->npages - i);
-				if (!bio) {
-					/* Error out this page */
-					/* FIXME */
-					bl_done_with_wpage(pages[i], 0);
-					break;
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
-				bio->bi_sector = isect - be->be_f_offset +
-					be->be_v_offset;
-				bio->bi_bdev = be->be_mdev;
-				bio->bi_end_io = bl_end_io_write;
-				bio->bi_private = par;
 			}
-			if (bio_add_page(bio, pages[i], PAGE_SIZE, 0))
-				break;
+		bio = bl_add_page_to_bio(bio, wdata->npages - i, WRITE,
+					 isect, pages[i], be,
+					 bl_end_io_write, par);
+		if (IS_ERR(bio)) {
+			wdata->pnfs_error = PTR_ERR(bio);
+			goto out;
+		}
+		isect += PAGE_CACHE_SECTORS;
+		last_isect = isect;
+		extent_length -= PAGE_CACHE_SECTORS;
+	}
+
+	/* Last page inside INVALID extent */
+	if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
 			bio = bl_submit_bio(WRITE, bio);
+		npg_zero = npg_per_block -
+		    (last_isect >> PAGE_CACHE_SECTOR_SHIFT) % npg_per_block;
+		if (npg_zero < npg_per_block) {
+			last = 1;
+			goto fill_invalid_ext;
 		}
-		isect += PAGE_CACHE_SIZE >> 9;
-		extent_length -= PAGE_CACHE_SIZE >> 9;
 	}
-	wdata->res.count = (isect << 9) - (offset);
-	if (count < wdata->res.count)
+
+write_done:
+	wdata->res.count = (last_isect << SECTOR_SHIFT) - (offset);
+	if (count < wdata->res.count) {
 		wdata->res.count = count;
-	put_extent(be);
+	}
+out:
+	bl_put_extent(be);
 	bl_submit_bio(WRITE, bio);
 	put_parallel(par);
 	return PNFS_ATTEMPTED;
@@ -515,7 +699,7 @@ release_extents(struct pnfs_block_layout *bl, struct pnfs_layout_range *range)
 					      struct pnfs_block_extent,
 					      be_node);
 			list_del(&be->be_node);
-			put_extent(be);
+			bl_put_extent(be);
 		}
 	}
 	spin_unlock(&bl->bl_ext_lock);
@@ -558,7 +742,7 @@ static struct pnfs_layout_hdr *bl_alloc_layout_hdr(struct inode *inode,
 	INIT_LIST_HEAD(&bl->bl_commit);
 	INIT_LIST_HEAD(&bl->bl_committing);
 	bl->bl_count = 0;
-	bl->bl_blocksize = NFS_SERVER(inode)->pnfs_blksize >> 9;
+	bl->bl_blocksize = NFS_SERVER(inode)->pnfs_blksize >> SECTOR_SHIFT;
 	INIT_INVAL_MARKS(&bl->bl_inval, bl->bl_blocksize);
 	return &bl->bl_layout;
 }
@@ -569,11 +753,8 @@ static void bl_free_lseg(struct pnfs_layout_segment *lseg)
 	kfree(lseg);
 }

-/* Because the generic infrastructure does not correctly merge layouts,
- * we pretty much ignore lseg, and store all data layout wide, so we
- * can correctly merge.  Eventually we should push some correct merge
- * behavior up to the generic code, as the current behavior tends to
- * cause lots of unnecessary overlapping LAYOUTGET requests.
+/* We pretty much ignore lseg, and store all data layout wide, so we
+ * can correctly merge.
  */
 static struct pnfs_layout_segment *bl_alloc_lseg(struct pnfs_layout_hdr *lo,
 						 struct nfs4_layoutget_res *lgr,
@@ -583,9 +764,9 @@ static struct pnfs_layout_segment *bl_alloc_lseg(struct pnfs_layout_hdr *lo,
 	int status;

 	dprintk("%s enter\n", __func__);
-	lseg = kzalloc(sizeof(*lseg) + 0, gfp_flags);
+	lseg = kzalloc(sizeof(*lseg), gfp_flags);
 	if (!lseg)
-		return NULL;
+		return ERR_PTR(-ENOMEM);
 	status = nfs4_blk_process_layoutget(lo, lgr, gfp_flags);
 	if (status) {
 		/* We don't want to call the full-blown bl_free_lseg,
@@ -659,19 +840,19 @@ nfs4_blk_get_deviceinfo(struct nfs_server *server, const struct nfs_fh *fh,
 	dprintk("%s max_resp_sz %u max_pages %d\n",
 		__func__, max_resp_sz, max_pages);

-	dev = kmalloc(sizeof(*dev), GFP_KERNEL);
+	dev = kmalloc(sizeof(*dev), GFP_NOFS);
 	if (!dev) {
 		dprintk("%s kmalloc failed\n", __func__);
 		return NULL;
 	}

-	pages = kzalloc(max_pages * sizeof(struct page *), GFP_KERNEL);
+	pages = kzalloc(max_pages * sizeof(struct page *), GFP_NOFS);
 	if (pages == NULL) {
 		kfree(dev);
 		return NULL;
 	}
 	for (i = 0; i < max_pages; i++) {
-		pages[i] = alloc_page(GFP_KERNEL);
+		pages[i] = alloc_page(GFP_NOFS);
 		if (!pages[i])
 			goto out_free;
 	}
@@ -721,7 +902,7 @@ bl_set_layoutdriver(struct nfs_server *server, const struct nfs_fh *fh)
 		dprintk("%s Server did not return blksize\n", __func__);
 		return -EINVAL;
 	}
-	b_mt_id = kzalloc(sizeof(struct block_mount_id), GFP_KERNEL);
+	b_mt_id = kzalloc(sizeof(struct block_mount_id), GFP_NOFS);
 	if (!b_mt_id) {
 		status = -ENOMEM;
 		goto out_error;
@@ -730,9 +911,11 @@ bl_set_layoutdriver(struct nfs_server *server, const struct nfs_fh *fh)
 	spin_lock_init(&b_mt_id->bm_lock);
 	INIT_LIST_HEAD(&b_mt_id->bm_devlist);

-	dlist = kmalloc(sizeof(struct pnfs_devicelist), GFP_KERNEL);
-	if (!dlist)
+	dlist = kmalloc(sizeof(struct pnfs_devicelist), GFP_NOFS);
+	if (!dlist) {
+		status = -ENOMEM;
 		goto out_error;
+	}
 	dlist->eof = 0;
 	while (!dlist->eof) {
 		status = nfs4_proc_getdevicelist(server, fh, dlist);
@@ -783,268 +966,14 @@ bl_clear_layoutdriver(struct nfs_server *server)
 	return 0;
 }

-/* STUB - mark intersection of layout and page as bad, so is not
- * used again.
- */
-static void mark_bad_read(void)
-{
-	return;
-}
-
-/* Copied from buffer.c */
-static void __end_buffer_read_notouch(struct buffer_head *bh, int uptodate)
-{
-	if (uptodate) {
-		set_buffer_uptodate(bh);
-	} else {
-		/* This happens, due to failed READA attempts. */
-		clear_buffer_uptodate(bh);
-	}
-	unlock_buffer(bh);
-}
-
-/* Copied from buffer.c */
-static void end_buffer_read_nobh(struct buffer_head *bh, int uptodate)
-{
-	__end_buffer_read_notouch(bh, uptodate);
-}
-
-/*
- * map_block:  map a requested I/0 block (isect) into an offset in the LVM
- * meta block_device
- */
-static void
-map_block(sector_t isect, struct pnfs_block_extent *be, struct buffer_head *bh)
-{
-	dprintk("%s enter be=%p\n", __func__, be);
-
-	set_buffer_mapped(bh);
-	bh->b_bdev = be->be_mdev;
-	bh->b_blocknr = (isect - be->be_f_offset + be->be_v_offset) >>
-		(be->be_mdev->bd_inode->i_blkbits - 9);
-
-	dprintk("%s isect %ld, bh->b_blocknr %ld, using bsize %Zd\n",
-				__func__, (long)isect,
-				(long)bh->b_blocknr,
-				bh->b_size);
-	return;
-}
-
-/* Given an unmapped page, zero it (or read in page for COW),
- * and set appropriate flags/markings, but it is safe to not initialize
- * the range given in [from, to).
- */
-/* This is loosely based on nobh_write_begin */
-static int
-init_page_for_write(struct pnfs_block_layout *bl, struct page *page,
-		    unsigned from, unsigned to, sector_t **pages_to_mark)
-{
-	struct buffer_head *bh;
-	int inval, ret = -EIO;
-	struct pnfs_block_extent *be = NULL, *cow_read = NULL;
-	sector_t isect;
-
-	dprintk("%s enter, %p\n", __func__, page);
-	bh = alloc_page_buffers(page, PAGE_CACHE_SIZE, 0);
-	if (!bh) {
-		ret = -ENOMEM;
-		goto cleanup;
-	}
-
-	isect = (sector_t)page->index << (PAGE_CACHE_SHIFT - 9);
-	be = find_get_extent(bl, isect, &cow_read);
-	if (!be)
-		goto cleanup;
-	inval = is_hole(be, isect);
-	dprintk("%s inval=%i, from=%u, to=%u\n", __func__, inval, from, to);
-	if (inval) {
-		if (be->be_state == PNFS_BLOCK_NONE_DATA) {
-			dprintk("%s PANIC - got NONE_DATA extent %p\n",
-				__func__, be);
-			goto cleanup;
-		}
-		map_block(isect, be, bh);
-		unmap_underlying_metadata(bh->b_bdev, bh->b_blocknr);
-	}
-	if (PageUptodate(page)) {
-		/* Do nothing */
-	} else if (inval & !cow_read) {
-		zero_user_segments(page, 0, from, to, PAGE_CACHE_SIZE);
-	} else if (0 < from || PAGE_CACHE_SIZE > to) {
-		struct pnfs_block_extent *read_extent;
-
-		read_extent = (inval && cow_read) ? cow_read : be;
-		map_block(isect, read_extent, bh);
-		lock_buffer(bh);
-		bh->b_end_io = end_buffer_read_nobh;
-		submit_bh(READ, bh);
-		dprintk("%s: Waiting for buffer read\n", __func__);
-		/* XXX Don't really want to hold layout lock here */
-		wait_on_buffer(bh);
-		if (!buffer_uptodate(bh))
-			goto cleanup;
-	}
-	if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
-		/* There is a BUG here if is a short copy after write_begin,
-		 * but I think this is a generic fs bug.  The problem is that
-		 * we have marked the page as initialized, but it is possible
-		 * that the section not copied may never get copied.
-		 */
-		ret = mark_initialized_sectors(be->be_inval, isect,
-					       PAGE_CACHE_SECTORS,
-					       pages_to_mark);
-		/* Want to preallocate mem so above can't fail */
-		if (ret)
-			goto cleanup;
-	}
-	SetPageMappedToDisk(page);
-	ret = 0;
-
-cleanup:
-	free_buffer_head(bh);
-	put_extent(be);
-	put_extent(cow_read);
-	if (ret) {
-		/* Need to mark layout with bad read...should now
-		 * just use nfs4 for reads and writes.
-		 */
-		mark_bad_read();
-	}
-	return ret;
-}
-
-static int
-bl_write_begin(struct pnfs_layout_segment *lseg, struct page *page, loff_t pos,
-	       unsigned count, struct pnfs_fsdata *fsdata)
-{
-	unsigned from, to;
-	int ret;
-	sector_t *pages_to_mark = NULL;
-	struct pnfs_block_layout *bl = BLK_LSEG2EXT(lseg);
-
-	dprintk("%s enter, %u@%lld\n", __func__, count, pos);
-	print_page(page);
-	/* The following code assumes blocksize >= PAGE_CACHE_SIZE */
-	if (bl->bl_blocksize < (PAGE_CACHE_SIZE >> 9)) {
-		dprintk("%s Can't handle blocksize %llu\n", __func__,
-			(u64)bl->bl_blocksize);
-		put_lseg(fsdata->lseg);
-		fsdata->lseg = NULL;
-		return 0;
-	}
-	if (PageMappedToDisk(page)) {
-		/* Basically, this is a flag that says we have
-		 * successfully called write_begin already on this page.
-		 */
-		/* NOTE - there are cache consistency issues here.
-		 * For example, what if the layout is recalled, then regained?
-		 * If the file is closed and reopened, will the page flags
-		 * be reset?  If not, we'll have to use layout info instead of
-		 * the page flag.
-		 */
-		return 0;
-	}
-	from = pos & (PAGE_CACHE_SIZE - 1);
-	to = from + count;
-	ret = init_page_for_write(bl, page, from, to, &pages_to_mark);
-	if (ret) {
-		dprintk("%s init page failed with %i", __func__, ret);
-		/* Revert back to plain NFS and just continue on with
-		 * write.  This assumes there is no request attached, which
-		 * should be true if we get here.
-		 */
-		BUG_ON(PagePrivate(page));
-		put_lseg(fsdata->lseg);
-		fsdata->lseg = NULL;
-		kfree(pages_to_mark);
-		ret = 0;
-	} else {
-		fsdata->private = pages_to_mark;
-	}
-	return ret;
-}
-
-/* CAREFUL - what happens if copied < count??? */
-static int
-bl_write_end(struct inode *inode, struct page *page, loff_t pos,
-	     unsigned count, unsigned copied, struct pnfs_layout_segment *lseg)
-{
-	dprintk("%s enter, %u@%lld, lseg=%p\n", __func__, count, pos, lseg);
-	print_page(page);
-	if (lseg)
-		SetPageUptodate(page);
-	return 0;
-}
-
-/* Return any memory allocated to fsdata->private, and take advantage
- * of no page locks to mark pages noted in write_begin as needing
- * initialization.
- */
-static void
-bl_write_end_cleanup(struct file *filp, struct pnfs_fsdata *fsdata)
-{
-	struct page *page;
-	pgoff_t index;
-	sector_t *pos;
-	struct address_space *mapping = filp->f_mapping;
-	struct pnfs_fsdata *fake_data;
-	struct pnfs_layout_segment *lseg;
-
-	if (!fsdata)
-		return;
-	lseg = fsdata->lseg;
-	if (!lseg)
-		return;
-	pos = fsdata->private;
-	if (!pos)
-		return;
-	dprintk("%s enter with pos=%llu\n", __func__, (u64)(*pos));
-	for (; *pos != ~0; pos++) {
-		index = *pos >> (PAGE_CACHE_SHIFT - 9);
-		/* XXX How do we properly deal with failures here??? */
-		page = grab_cache_page_write_begin(mapping, index, 0);
-		if (!page) {
-			printk(KERN_ERR "%s BUG BUG BUG NoMem\n", __func__);
-			continue;
-		}
-		dprintk("%s: Examining block page\n", __func__);
-		print_page(page);
-		if (!PageMappedToDisk(page)) {
-			/* XXX How do we properly deal with failures here??? */
-			dprintk("%s Marking block page\n", __func__);
-			init_page_for_write(BLK_LSEG2EXT(fsdata->lseg), page,
-					    PAGE_CACHE_SIZE, PAGE_CACHE_SIZE,
-					    NULL);
-			print_page(page);
-			fake_data = kzalloc(sizeof(*fake_data), GFP_KERNEL);
-			if (!fake_data) {
-				printk(KERN_ERR "%s BUG BUG BUG NoMem\n",
-				       __func__);
-				unlock_page(page);
-				continue;
-			}
-			get_lseg(lseg);
-			fake_data->lseg = lseg;
-			fake_data->bypass_eof = 1;
-			mapping->a_ops->write_end(filp, mapping,
-						  index << PAGE_CACHE_SHIFT,
-						  PAGE_CACHE_SIZE,
-						  PAGE_CACHE_SIZE,
-						  page, fake_data);
-			/* Note fake_data is freed by nfs_write_end */
-		} else
-			unlock_page(page);
-	}
-	kfree(fsdata->private);
-	fsdata->private = NULL;
-}
-
 static const struct nfs_pageio_ops bl_pg_read_ops = {
+	.pg_init = pnfs_generic_pg_init_read,
 	.pg_test = pnfs_generic_pg_test,
 	.pg_doio = nfs_generic_pg_readpages,
 };

 static const struct nfs_pageio_ops bl_pg_write_ops = {
+	.pg_init = pnfs_generic_pg_init_write,
 	.pg_test = pnfs_generic_pg_test,
 	.pg_doio = nfs_generic_pg_writepages,
 };
@@ -1054,9 +983,6 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
 	.name = "LAYOUT_BLOCK_VOLUME",
 	.read_pagelist			= bl_read_pagelist,
 	.write_pagelist			= bl_write_pagelist,
-	.write_begin			= bl_write_begin,
-	.write_end			= bl_write_end,
-	.write_end_cleanup		= bl_write_end_cleanup,
 	.alloc_layout_hdr		= bl_alloc_layout_hdr,
 	.free_layout_hdr		= bl_free_layout_hdr,
 	.alloc_lseg			= bl_alloc_lseg,
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 6b7718b..4111de7 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -32,15 +32,12 @@
 #ifndef FS_NFS_NFS4BLOCKLAYOUT_H
 #define FS_NFS_NFS4BLOCKLAYOUT_H

+#include <linux/device-mapper.h>
 #include <linux/nfs_fs.h>
 #include "../pnfs.h"

-#define PAGE_CACHE_SECTORS (PAGE_CACHE_SIZE >> 9)
-
-#define PG_pnfserr PG_owner_priv_1
-#define PagePnfsErr(page)	test_bit(PG_pnfserr, &(page)->flags)
-#define SetPagePnfsErr(page)	set_bit(PG_pnfserr, &(page)->flags)
-#define ClearPagePnfsErr(page)	clear_bit(PG_pnfserr, &(page)->flags)
+#define PAGE_CACHE_SECTORS (PAGE_CACHE_SIZE >> SECTOR_SHIFT)
+#define PAGE_CACHE_SECTOR_SHIFT (PAGE_CACHE_SHIFT - SECTOR_SHIFT)

 struct block_mount_id {
 	spinlock_t			bm_lock;    /* protects list */
@@ -105,14 +102,14 @@ enum exstate4 {

 #define MY_MAX_TAGS (15) /* tag bitnums used must be less than this */

-struct my_tree_t {
+struct my_tree {
 	sector_t		mtt_step_size;	/* Internal sector alignment */
 	struct list_head	mtt_stub; /* Should be a radix tree */
 };

 struct pnfs_inval_markings {
 	spinlock_t	im_lock;
-	struct my_tree_t im_tree;	/* Sectors that need LAYOUTCOMMIT */
+	struct my_tree	im_tree;	/* Sectors that need LAYOUTCOMMIT */
 	sector_t	im_block_size;	/* Server blocksize in sectors */
 };

@@ -193,51 +190,6 @@ BLK_LSEG2EXT(struct pnfs_layout_segment *lseg)
 	return BLK_LO2EXT(lseg->pls_layout);
 }

-uint32_t *blk_overflow(uint32_t *p, uint32_t *end, size_t nbytes);
-
-#define BLK_READBUF(p, e, nbytes)  do { \
-	p = blk_overflow(p, e, nbytes); \
-	if (!p) { \
-		printk(KERN_WARNING \
-			"%s: reply buffer overflowed in line %d.\n", \
-			__func__, __LINE__); \
-		goto out_err; \
-	} \
-} while (0)
-
-#define READ32(x)         (x) = ntohl(*p++)
-#define READ64(x)         do {                  \
-	(x) = (uint64_t)ntohl(*p++) << 32;           \
-	(x) |= ntohl(*p++);                     \
-} while (0)
-#define COPYMEM(x, nbytes) do {                 \
-	memcpy((x), p, nbytes);                 \
-	p += XDR_QUADLEN(nbytes);               \
-} while (0)
-#define READ_DEVID(x)	COPYMEM((x)->data, NFS4_DEVICEID4_SIZE)
-#define READ_SECTOR(x)     do { \
-	READ64(tmp); \
-	if (tmp & 0x1ff) { \
-		printk(KERN_WARNING \
-		       "%s Value not 512-byte aligned at line %d\n", \
-		       __func__, __LINE__);			     \
-		goto out_err; \
-	} \
-	(x) = tmp >> 9; \
-} while (0)
-
-#define WRITE32(n)               do { \
-	*p++ = htonl(n); \
-	} while (0)
-#define WRITE64(n)               do {                           \
-	*p++ = htonl((uint32_t)((n) >> 32));			\
-	*p++ = htonl((uint32_t)(n));				\
-} while (0)
-#define WRITEMEM(ptr, nbytes)     do {                          \
-	p = xdr_encode_opaque_fixed(p, ptr, nbytes);	\
-} while (0)
-#define WRITE_DEVID(x)  WRITEMEM((x)->data, NFS4_DEVICEID4_SIZE)
-
 /* blocklayoutdev.c */
 struct block_device *nfs4_blkdev_get(dev_t dev);
 int nfs4_blkdev_put(struct block_device *bdev);
@@ -250,12 +202,12 @@ int nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
 void free_block_dev(struct pnfs_block_dev *bdev);
 /* extents.c */
 struct pnfs_block_extent *
-find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
+bl_find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
 		struct pnfs_block_extent **cow_read);
-int mark_initialized_sectors(struct pnfs_inval_markings *marks,
+int bl_mark_sectors_init(struct pnfs_inval_markings *marks,
 			     sector_t offset, sector_t length,
 			     sector_t **pages);
-void put_extent(struct pnfs_block_extent *be);
+void bl_put_extent(struct pnfs_block_extent *be);
 struct pnfs_block_extent *alloc_extent(void);
 struct pnfs_block_extent *get_extent(struct pnfs_block_extent *be);
 int is_sector_initialized(struct pnfs_inval_markings *marks, sector_t isect);
@@ -265,7 +217,7 @@ int encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 void clean_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 				   const struct nfs4_layoutcommit_args *arg,
 				   int status);
-int add_and_merge_extent(struct pnfs_block_layout *bl,
+int bl_add_merge_extent(struct pnfs_block_layout *bl,
 			 struct pnfs_block_extent *new);
 int mark_for_commit(struct pnfs_block_extent *be,
 		    sector_t offset, sector_t length);
diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index a90eb6b..1f7fd3f 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -40,14 +40,18 @@

 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD

-uint32_t *blk_overflow(uint32_t *p, uint32_t *end, size_t nbytes)
+static int decode_sector_number(__be32 **rp, sector_t *sp)
 {
-	uint32_t *q = p + XDR_QUADLEN(nbytes);
-	if (unlikely(q > end || q < p))
-		return NULL;
-	return p;
+	uint64_t s;
+
+	*rp = xdr_decode_hyper(*rp, &s);
+	if (s & 0x1ff) {
+		printk(KERN_WARNING "%s: sector not aligned\n", __func__);
+		return -1;
+	}
+	*sp = s >> SECTOR_SHIFT;
+	return 0;
 }
-EXPORT_SYMBOL(blk_overflow);

 /* Open a block_device by device number. */
 struct block_device *nfs4_blkdev_get(dev_t dev)
@@ -75,8 +79,8 @@ int nfs4_blkdev_put(struct block_device *bdev)
 	return blkdev_put(bdev, FMODE_READ);
 }

-/* Decodes pnfs_block_deviceaddr4 (draft-8) which is XDR encoded
- * in dev->dev_addr_buf.
+/*
+ * Decodes pnfs_block_deviceaddr4 which is XDR encoded in dev->dev_addr_buf.
  */
 struct pnfs_block_dev *
 nfs4_blk_decode_device(struct nfs_server *server,
@@ -127,7 +131,7 @@ nfs4_blk_decode_device(struct nfs_server *server,
 		goto out_err;
 	}

-	rv = kzalloc(sizeof(*rv), GFP_KERNEL);
+	rv = kzalloc(sizeof(*rv), GFP_NOFS);
 	if (!rv)
 		goto out_err;

@@ -241,12 +245,11 @@ nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
 	struct xdr_buf buf;
 	struct page *scratch;
 	__be32 *p;
-	uint64_t tmp; /* Used by READSECTOR */
 	struct layout_verification lv = {
 		.mode = lgr->range.iomode,
-		.start = lgr->range.offset >> 9,
-		.inval = lgr->range.offset >> 9,
-		.cowread = lgr->range.offset >> 9,
+		.start = lgr->range.offset >> SECTOR_SHIFT,
+		.inval = lgr->range.offset >> SECTOR_SHIFT,
+		.cowread = lgr->range.offset >> SECTOR_SHIFT,
 	};
 	LIST_HEAD(extents);

@@ -263,7 +266,7 @@ nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
 	if (unlikely(!p))
 		goto out_err;

-	READ32(count);
+	count = be32_to_cpup(p++);

 	dprintk("%s enter, number of extents %i\n", __func__, count);
 	p = xdr_inline_decode(&stream, (28 + NFS4_DEVICEID4_SIZE) * count);
@@ -280,7 +283,8 @@ nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
 			status = -ENOMEM;
 			goto out_err;
 		}
-		READ_DEVID(&be->be_devid);
+		memcpy(&be->be_devid, p, NFS4_DEVICEID4_SIZE);
+		p += XDR_QUADLEN(NFS4_DEVICEID4_SIZE);
 		be->be_mdev = translate_devid(lo, &be->be_devid);
 		if (!be->be_mdev)
 			goto out_err;
@@ -288,10 +292,13 @@ nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
 		/* The next three values are read in as bytes,
 		 * but stored as 512-byte sector lengths
 		 */
-		READ_SECTOR(be->be_f_offset);
-		READ_SECTOR(be->be_length);
-		READ_SECTOR(be->be_v_offset);
-		READ32(be->be_state);
+		if (decode_sector_number(&p, &be->be_f_offset) < 0)
+			goto out_err;
+		if (decode_sector_number(&p, &be->be_length) < 0)
+			goto out_err;
+		if (decode_sector_number(&p, &be->be_v_offset) < 0)
+			goto out_err;
+		be->be_state = be32_to_cpup(p++);
 		if (be->be_state == PNFS_BLOCK_INVALID_DATA)
 			be->be_inval = &bl->bl_inval;
 		if (verify_extent(be, &lv)) {
@@ -300,7 +307,8 @@ nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
 		}
 		list_add_tail(&be->be_node, &extents);
 	}
-	if (lgr->range.offset + lgr->range.length != lv.start << 9) {
+	if (lgr->range.offset + lgr->range.length !=
+			lv.start << SECTOR_SHIFT) {
 		dprintk("%s Final length mismatch\n", __func__);
 		be = NULL;
 		goto out_err;
@@ -316,7 +324,7 @@ nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
 	spin_lock(&bl->bl_ext_lock);
 	list_for_each_entry_safe(be, save, &extents, be_node) {
 		list_del(&be->be_node);
-		status = add_and_merge_extent(bl, be);
+		status = bl_add_merge_extent(bl, be);
 		if (status) {
 			spin_unlock(&bl->bl_ext_lock);
 			/* This is a fairly catastrophic error, as the
@@ -335,12 +343,12 @@ nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
 	return status;

  out_err:
-	put_extent(be);
+	bl_put_extent(be);
 	while (!list_empty(&extents)) {
 		be = list_first_entry(&extents, struct pnfs_block_extent,
 				      be_node);
 		list_del(&be->be_node);
-		put_extent(be);
+		bl_put_extent(be);
 	}
 	goto out;
 }
diff --git a/fs/nfs/blocklayout/blocklayoutdm.c b/fs/nfs/blocklayout/blocklayoutdm.c
index 097dd05..9b9946e 100644
--- a/fs/nfs/blocklayout/blocklayoutdm.c
+++ b/fs/nfs/blocklayout/blocklayoutdm.c
@@ -38,15 +38,6 @@

 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD

-/* Defines used for calculating memory usage in nfs4_blk_flatten() */
-#define ARGSIZE   24    /* Max bytes needed for linear target arg string */
-#define SPECSIZE (sizeof8(struct dm_target_spec) + ARGSIZE)
-#define SPECS_PER_PAGE (PAGE_SIZE / SPECSIZE)
-#define SPEC_HEADER_ADJUST (SPECS_PER_PAGE - \
-			    (PAGE_SIZE - sizeof8(struct dm_ioctl)) / SPECSIZE)
-#define roundup8(x) (((x)+7) & ~7)
-#define sizeof8(x) roundup8(sizeof(x))
-
 static int dev_remove(dev_t dev)
 {
 	int ret = 1;
@@ -90,18 +81,17 @@ out:
 /*
  * Release meta device
  */
-static int nfs4_blk_metadev_release(struct pnfs_block_dev *bdev)
+static void nfs4_blk_metadev_release(struct pnfs_block_dev *bdev)
 {
 	int rv;

 	dprintk("%s Releasing\n", __func__);
-	/* XXX Check return? */
 	rv = nfs4_blkdev_put(bdev->bm_mdev);
-	dprintk("%s nfs4_blkdev_put returns %d\n", __func__, rv);
+	if (rv)
+		printk("%s nfs4_blkdev_put returns %d\n", __func__, rv);

 	rv = dev_remove(bdev->bm_mdev->bd_dev);
 	dprintk("%s Returns %d\n", __func__, rv);
-	return rv;
 }

 void free_block_dev(struct pnfs_block_dev *bdev)
@@ -112,7 +102,6 @@ void free_block_dev(struct pnfs_block_dev *bdev)
 				__func__,
 				MAJOR(bdev->bm_mdev->bd_dev),
 				MINOR(bdev->bm_mdev->bd_dev));
-			/* XXX Check status ?? */
 			nfs4_blk_metadev_release(bdev);
 		}
 		kfree(bdev);
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index a62d29f..b22e85b 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -55,7 +55,7 @@ static inline sector_t normalize_up(sector_t s, int base)
 /* Complete stub using list while determine API wanted */

 /* Returns tags, or negative */
-static int32_t _find_entry(struct my_tree_t *tree, u64 s)
+static int32_t _find_entry(struct my_tree *tree, u64 s)
 {
 	struct pnfs_inval_tracking *pos;

@@ -72,7 +72,7 @@ static int32_t _find_entry(struct my_tree_t *tree, u64 s)
 }

 static inline
-int _has_tag(struct my_tree_t *tree, u64 s, int32_t tag)
+int _has_tag(struct my_tree *tree, u64 s, int32_t tag)
 {
 	int32_t tags;

@@ -89,7 +89,7 @@ int _has_tag(struct my_tree_t *tree, u64 s, int32_t tag)
  * If storage is not NULL, newly created entry will use it.
  * Returns number of entries added, or negative on error.
  */
-static int _add_entry(struct my_tree_t *tree, u64 s, int32_t tag,
+static int _add_entry(struct my_tree *tree, u64 s, int32_t tag,
 		      struct pnfs_inval_tracking *storage)
 {
 	int found = 0;
@@ -113,7 +113,7 @@ static int _add_entry(struct my_tree_t *tree, u64 s, int32_t tag,
 		if (storage)
 			new = storage;
 		else {
-			new = kmalloc(sizeof(*new), GFP_KERNEL);
+			new = kmalloc(sizeof(*new), GFP_NOFS);
 			if (!new)
 				return -ENOMEM;
 		}
@@ -126,7 +126,7 @@ static int _add_entry(struct my_tree_t *tree, u64 s, int32_t tag,

 /* XXXX Really want option to not create */
 /* Over range, unions tag with existing entries, else creates entry with tag */
-static int _set_range(struct my_tree_t *tree, int32_t tag, u64 s, u64 length)
+static int _set_range(struct my_tree *tree, int32_t tag, u64 s, u64 length)
 {
 	u64 i;

@@ -139,7 +139,7 @@ static int _set_range(struct my_tree_t *tree, int32_t tag, u64 s, u64 length)
 }

 /* Ensure that future operations on given range of tree will not malloc */
-static int _preload_range(struct my_tree_t *tree, u64 offset, u64 length)
+static int _preload_range(struct my_tree *tree, u64 offset, u64 length)
 {
 	u64 start, end, s;
 	int count, i, used = 0, status = -ENOMEM;
@@ -151,12 +151,12 @@ static int _preload_range(struct my_tree_t *tree, u64 offset, u64 length)
 	count = (int)(end - start) / (int)tree->mtt_step_size;

 	/* Pre-malloc what memory we might need */
-	storage = kmalloc(sizeof(*storage) * count, GFP_KERNEL);
+	storage = kmalloc(sizeof(*storage) * count, GFP_NOFS);
 	if (!storage)
 		return -ENOMEM;
 	for (i = 0; i < count; i++) {
 		storage[i] = kmalloc(sizeof(struct pnfs_inval_tracking),
-				     GFP_KERNEL);
+				     GFP_NOFS);
 		if (!storage[i])
 			goto out_cleanup;
 	}
@@ -219,7 +219,7 @@ int is_sector_initialized(struct pnfs_inval_markings *marks, sector_t isect)

 /* Assume start, end already sector aligned */
 static int
-_range_has_tag(struct my_tree_t *tree, u64 start, u64 end, int32_t tag)
+_range_has_tag(struct my_tree *tree, u64 start, u64 end, int32_t tag)
 {
 	struct pnfs_inval_tracking *pos;
 	u64 expect = 0;
@@ -265,7 +265,7 @@ static int is_range_written(struct pnfs_inval_markings *marks,
  * complete initialization later.
  */
 /* Currently assumes offset is page-aligned */
-int mark_initialized_sectors(struct pnfs_inval_markings *marks,
+int bl_mark_sectors_init(struct pnfs_inval_markings *marks,
 			     sector_t offset, sector_t length,
 			     sector_t **pages)
 {
@@ -278,7 +278,7 @@ int mark_initialized_sectors(struct pnfs_inval_markings *marks,
 		2 * (marks->im_block_size / (PAGE_CACHE_SECTORS)));
 	dprintk("%s set max=%llu\n", __func__, (u64)s);
 	if (pages) {
-		array = kmalloc(s * sizeof(sector_t), GFP_KERNEL);
+		array = kmalloc(s * sizeof(sector_t), GFP_NOFS);
 		if (!array)
 			goto outerr;
 		array[0] = ~0;
@@ -372,7 +372,7 @@ void print_clist(struct list_head *list, unsigned int count)
 /* Note: In theory, we should do more checking that devid's match between
  * old and new, but if they don't, the lists are too corrupt to salvage anyway.
  */
-/* Note this is very similar to add_and_merge_extent */
+/* Note this is very similar to bl_add_merge_extent */
 static void add_to_commitlist(struct pnfs_block_layout *bl,
 			      struct pnfs_block_short_extent *new)
 {
@@ -448,7 +448,7 @@ int mark_for_commit(struct pnfs_block_extent *be,
 						    struct pnfs_block_layout,
 						    bl_inval);

-	new = kmalloc(sizeof(*new), GFP_KERNEL);
+	new = kmalloc(sizeof(*new), GFP_NOFS);
 	if (!new)
 		return -ENOMEM;

@@ -511,7 +511,7 @@ destroy_extent(struct kref *kref)
 }

 void
-put_extent(struct pnfs_block_extent *be)
+bl_put_extent(struct pnfs_block_extent *be)
 {
 	if (be) {
 		dprintk("%s enter %p (%i)\n", __func__, be,
@@ -524,7 +524,7 @@ struct pnfs_block_extent *alloc_extent(void)
 {
 	struct pnfs_block_extent *be;

-	be = kmalloc(sizeof(struct pnfs_block_extent), GFP_KERNEL);
+	be = kmalloc(sizeof(struct pnfs_block_extent), GFP_NOFS);
 	if (!be)
 		return NULL;
 	INIT_LIST_HEAD(&be->be_node);
@@ -566,15 +566,15 @@ extents_consistent(struct pnfs_block_extent *old, struct pnfs_block_extent *new)
 /* Adds new to appropriate list in bl, modifying new and removing existing
  * extents as appropriate to deal with overlaps.
  *
- * See find_get_extent for list constraints.
+ * See bl_find_get_extent for list constraints.
  *
  * Refcount on new is already set.  If end up not using it, or error out,
  * need to put the reference.
  *
- * Lock is held by caller.
+ * bl->bl_ext_lock is held by caller.
  */
 int
-add_and_merge_extent(struct pnfs_block_layout *bl,
+bl_add_merge_extent(struct pnfs_block_layout *bl,
 		     struct pnfs_block_extent *new)
 {
 	struct pnfs_block_extent *be, *tmp;
@@ -598,7 +598,7 @@ add_and_merge_extent(struct pnfs_block_layout *bl,
 				if (extents_consistent(be, new)) {
 					dprintk("%s: new is subset, ignoring\n",
 						__func__);
-					put_extent(new);
+					bl_put_extent(new);
 					return 0;
 				} else {
 					goto out_err;
@@ -614,7 +614,7 @@ add_and_merge_extent(struct pnfs_block_layout *bl,
 					new->be_v_offset = be->be_v_offset;
 					dprintk("%s: removing %p\n", __func__, be);
 					list_del(&be->be_node);
-					put_extent(be);
+					bl_put_extent(be);
 				} else {
 					goto out_err;
 				}
@@ -625,7 +625,7 @@ add_and_merge_extent(struct pnfs_block_layout *bl,
 				/* extend new to fully replace be */
 				dprintk("%s: removing %p\n", __func__, be);
 				list_del(&be->be_node);
-				put_extent(be);
+				bl_put_extent(be);
 			} else {
 				goto out_err;
 			}
@@ -638,7 +638,7 @@ add_and_merge_extent(struct pnfs_block_layout *bl,
 					new->be_f_offset - new->be_length;
 				dprintk("%s: removing %p\n", __func__, be);
 				list_del(&be->be_node);
-				put_extent(be);
+				bl_put_extent(be);
 			} else {
 				goto out_err;
 			}
@@ -656,7 +656,7 @@ add_and_merge_extent(struct pnfs_block_layout *bl,
 	return 0;

  out_err:
-	put_extent(new);
+	bl_put_extent(new);
 	return -EIO;
 }

@@ -669,7 +669,7 @@ add_and_merge_extent(struct pnfs_block_layout *bl,
  * 2. For any given isect, there is at most one extents that matches.
  */
 struct pnfs_block_extent *
-find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
+bl_find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
 	    struct pnfs_block_extent **cow_read)
 {
 	struct pnfs_block_extent *be, *cow, *ret;
@@ -693,7 +693,7 @@ find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
 				if (!ret)
 					ret = be;
 				else if (be->be_state != PNFS_BLOCK_READ_DATA)
-					put_extent(be);
+					bl_put_extent(be);
 				else
 					cow = be;
 				break;
@@ -707,9 +707,9 @@ find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
 	return ret;
 }

-/* Similar to find_get_extent, but called with lock held, and ignores cow */
+/* Similar to bl_find_get_extent, but called with lock held, and ignores cow */
 static struct pnfs_block_extent *
-find_get_extent_locked(struct pnfs_block_layout *bl, sector_t isect)
+bl_find_get_extent_locked(struct pnfs_block_layout *bl, sector_t isect)
 {
 	struct pnfs_block_extent *be, *ret = NULL;
 	int i;
@@ -742,7 +742,6 @@ encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 {
 	struct pnfs_block_short_extent *lce, *save;
 	unsigned int count = 0;
-	struct list_head *ranges = &bl->bl_committing;
 	__be32 *p, *xdr_start;

 	dprintk("%s enter\n", __func__);
@@ -761,13 +760,13 @@ encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 		p = xdr_reserve_space(xdr, 7 * 4 + sizeof(lce->bse_devid.data));
 		if (!p)
 			break;
-		WRITE_DEVID(&lce->bse_devid);
-		WRITE64(lce->bse_f_offset << 9);
-		WRITE64(lce->bse_length << 9);
-		WRITE64(0LL);
-		WRITE32(PNFS_BLOCK_READWRITE_DATA);
+		p = xdr_encode_opaque_fixed(p, lce->bse_devid.data, NFS4_DEVICEID4_SIZE);
+		p = xdr_encode_hyper(p, lce->bse_f_offset << SECTOR_SHIFT);
+		p = xdr_encode_hyper(p, lce->bse_length << SECTOR_SHIFT);
+		p = xdr_encode_hyper(p, 0LL);
+		*p++ = cpu_to_be32(PNFS_BLOCK_READWRITE_DATA);
 		list_del(&lce->bse_node);
-		list_add_tail(&lce->bse_node, ranges);
+		list_add_tail(&lce->bse_node, &bl->bl_committing);
 		bl->bl_count--;
 		count++;
 	}
@@ -816,9 +815,9 @@ _front_merge(struct pnfs_block_extent *be, struct list_head *head,
 	_prep_new_extent(storage, prev, prev->be_f_offset,
 			 prev->be_length + be->be_length, prev->be_state);
 	list_replace(&prev->be_node, &storage->be_node);
-	put_extent(prev);
+	bl_put_extent(prev);
 	list_del(&be->be_node);
-	put_extent(be);
+	bl_put_extent(be);
 	return storage;

  no_merge:
@@ -837,15 +836,15 @@ set_to_rw(struct pnfs_block_layout *bl, u64 offset, u64 length)

 	dprintk("%s(%llu, %llu)\n", __func__, offset, length);
 	/* Create storage for up to three new extents e1, e2, e3 */
-	e1 = kmalloc(sizeof(*e1), GFP_KERNEL);
-	e2 = kmalloc(sizeof(*e2), GFP_KERNEL);
-	e3 = kmalloc(sizeof(*e3), GFP_KERNEL);
+	e1 = kmalloc(sizeof(*e1), GFP_ATOMIC);
+	e2 = kmalloc(sizeof(*e2), GFP_ATOMIC);
+	e3 = kmalloc(sizeof(*e3), GFP_ATOMIC);
 	/* BUG - we are ignoring any failure */
 	if (!e1 || !e2 || !e3)
 		goto out_nosplit;

 	spin_lock(&bl->bl_ext_lock);
-	be = find_get_extent_locked(bl, offset);
+	be = bl_find_get_extent_locked(bl, offset);
 	rv = be->be_f_offset + be->be_length;
 	if (be->be_state != PNFS_BLOCK_INVALID_DATA) {
 		spin_unlock(&bl->bl_ext_lock);
@@ -883,7 +882,7 @@ set_to_rw(struct pnfs_block_layout *bl, u64 offset, u64 length)
 		children[i] = NULL;
 	new = children[0];
 	list_replace(&be->be_node, &new->be_node);
-	put_extent(be);
+	bl_put_extent(be);
 	new = _front_merge(new, &bl->bl_extents[RW_EXTENT], merge1);
 	for (j = 1; j < i; j++) {
 		old = new;
@@ -901,7 +900,7 @@ set_to_rw(struct pnfs_block_layout *bl, u64 offset, u64 length)
 	/* Since we removed the base reference above, be is now scheduled for
 	 * destruction.
 	 */
-	put_extent(be);
+	bl_put_extent(be);
 	dprintk("%s returns %llu after split\n", __func__, rv);
 	return rv;

@@ -921,7 +920,7 @@ clean_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 	struct pnfs_block_short_extent *lce, *save;

 	dprintk("%s status %d\n", __func__, status);
-	list_for_each_entry_safe_reverse(lce, save, &bl->bl_committing, bse_node) {
+	list_for_each_entry_safe(lce, save, &bl->bl_committing, bse_node) {
 		if (likely(!status)) {
 			u64 offset = lce->bse_f_offset;
 			u64 end = offset + lce->bse_length;
@@ -933,6 +932,7 @@ clean_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,

 			kfree(lce);
 		} else {
+			list_del(&lce->bse_node);
 			spin_lock(&bl->bl_ext_lock);
 			add_to_commitlist(bl, lce);
 			spin_unlock(&bl->bl_ext_lock);
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 1768762..2f093ed 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -384,15 +384,12 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
 	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
 	struct page *page;
 	int once_thru = 0;
-	struct pnfs_layout_segment *lseg;

 	dfprintk(PAGECACHE, "NFS: write_begin(%s/%s(%ld), %u@%lld)\n",
 		file->f_path.dentry->d_parent->d_name.name,
 		file->f_path.dentry->d_name.name,
 		mapping->host->i_ino, len, (long long) pos);
-	lseg = pnfs_update_layout(mapping->host,
-				  nfs_file_open_context(file),
-				  pos, len, IOMODE_RW, GFP_NOFS);
+
 start:
 	/*
 	 * Prevent starvation issues if someone is doing a consistency
@@ -412,9 +409,6 @@ start:
 	if (ret) {
 		unlock_page(page);
 		page_cache_release(page);
-		*pagep = NULL;
-		*fsdata = NULL;
-		goto out;
 	} else if (!once_thru &&
 		   nfs_want_read_modify_write(file, page, pos, len)) {
 		once_thru = 1;
@@ -423,12 +417,6 @@ start:
 		if (!ret)
 			goto start;
 	}
-	ret = pnfs_write_begin(file, page, pos, len, lseg, fsdata);
- out:
-	if (ret) {
-		put_lseg(lseg);
-		*fsdata = NULL;
-	}
 	return ret;
 }

@@ -438,7 +426,6 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 {
 	unsigned offset = pos & (PAGE_CACHE_SIZE - 1);
 	int status;
-	struct pnfs_layout_segment *lseg;

 	dfprintk(PAGECACHE, "NFS: write_end(%s/%s(%ld), %u@%lld)\n",
 		file->f_path.dentry->d_parent->d_name.name,
@@ -465,17 +452,10 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 			zero_user_segment(page, pglen, PAGE_CACHE_SIZE);
 	}

-	lseg = nfs4_pull_lseg_from_fsdata(file, fsdata);
-	status = pnfs_write_end(file, page, pos, len, copied, lseg);
-	if (status)
-		goto out;
-	status = nfs_updatepage(file, page, offset, copied, lseg, fsdata);
+	status = nfs_updatepage(file, page, offset, copied);

-out:
 	unlock_page(page);
 	page_cache_release(page);
-	pnfs_write_end_cleanup(file, fsdata);
-	put_lseg(lseg);

 	if (status < 0)
 		return status;
@@ -597,7 +577,7 @@ static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)

 	ret = VM_FAULT_LOCKED;
 	if (nfs_flush_incompatible(filp, page) == 0 &&
-	    nfs_updatepage(filp, page, 0, pagelen, NULL, NULL) == 0)
+	    nfs_updatepage(filp, page, 0, pagelen) == 0)
 		goto out;

 	ret = VM_FAULT_SIGBUS;
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index af9bf9e..6d7f937 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -170,7 +170,7 @@ filelayout_set_layoutcommit(struct nfs_write_data *wdata)

 	pnfs_set_layoutcommit(wdata);
 	dprintk("%s ionde %lu pls_end_pos %lu\n", __func__, wdata->inode->i_ino,
-		(unsigned long) wdata->lseg->pls_end_pos);
+		(unsigned long) NFS_I(wdata->inode)->layout->plh_lwb);
 }

 /*
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ace9d37..795033c5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5963,10 +5963,16 @@ nfs4_layoutcommit_done(struct rpc_task *task, void *calldata)
 static void nfs4_layoutcommit_release(void *calldata)
 {
 	struct nfs4_layoutcommit_data *data = calldata;
+	struct pnfs_layout_segment *lseg, *tmp;

 	pnfs_cleanup_layoutcommit(data->args.inode, data);
 	/* Matched by references in pnfs_set_layoutcommit */
-	put_lseg(data->lseg);
+	list_for_each_entry_safe(lseg, tmp, &data->lseg_list, pls_lc_list) {
+		list_del_init(&lseg->pls_lc_list);
+		if (test_and_clear_bit(NFS_LSEG_LAYOUTCOMMIT,
+				       &lseg->pls_flags))
+			put_lseg(lseg);
+	}
 	put_rpccred(data->cred);
 	kfree(data);
 }
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 84a19d4..07c41b2 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2679,7 +2679,7 @@ static void nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req,
 	struct compound_hdr hdr = {
 		.nops	= 0,
 	};
-	const u32 lease_bitmap[3] = { FATTR4_WORD0_LEASE_TIME, 0, 0 };
+	const u32 lease_bitmap[3] = { FATTR4_WORD0_LEASE_TIME };

 	encode_compound_hdr(xdr, req, &hdr);
 	encode_setclientid_confirm(xdr, arg, &hdr);
@@ -2823,7 +2823,7 @@ static void nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req,
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->la_seq_args),
 	};
-	const u32 lease_bitmap[3] = { FATTR4_WORD0_LEASE_TIME, 0, 0 };
+	const u32 lease_bitmap[3] = { FATTR4_WORD0_LEASE_TIME };

 	encode_compound_hdr(xdr, req, &hdr);
 	encode_sequence(xdr, &args->la_seq_args, &hdr);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 42979e5..8e11419 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -46,11 +46,6 @@ static DEFINE_SPINLOCK(pnfs_spinlock);
  */
 static LIST_HEAD(pnfs_modules_tbl);

-/*
- * layoutget prefetch size
- */
-unsigned int pnfs_layout_prefetch_kb;
-
 /* Return the registered pnfs layout driver module matching given id */
 static struct pnfs_layoutdriver_type *
 find_pnfs_driver_locked(u32 id)
@@ -240,6 +235,7 @@ static void
 init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
 {
 	INIT_LIST_HEAD(&lseg->pls_list);
+	INIT_LIST_HEAD(&lseg->pls_lc_list);
 	atomic_set(&lseg->pls_refcount, 1);
 	smp_mb();
 	set_bit(NFS_LSEG_VALID, &lseg->pls_flags);
@@ -929,16 +925,6 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
 }

 /*
- * Set layout prefetch length.
- */
-static void
-pnfs_set_layout_prefetch(struct pnfs_layout_range *range)
-{
-	if (range->length < (pnfs_layout_prefetch_kb << 10))
-		range->length = pnfs_layout_prefetch_kb << 10;
-}
-
-/*
  * Layout segment is retreived from the server if not cached.
  * The appropriate layout segment is referenced and returned to the caller.
  */
@@ -990,8 +976,6 @@ pnfs_update_layout(struct inode *ino,

 	if (pnfs_layoutgets_blocked(lo, NULL, 0))
 		goto out_unlock;
-
-	pnfs_set_layout_prefetch(&arg);
 	atomic_inc(&lo->plh_outstanding);

 	get_layout_hdr(lo);
@@ -1022,6 +1006,10 @@ pnfs_update_layout(struct inode *ino,
 		list_del_init(&lo->plh_layouts);
 		spin_unlock(&clp->cl_lock);
 	}
+	if (first) {
+		lo->plh_lc_cred =
+			get_rpccred(ctx->state->owner->so_cred);
+	}
 	atomic_dec(&lo->plh_outstanding);
 	put_layout_hdr(lo);
 out:
@@ -1223,41 +1211,6 @@ pnfs_try_to_write_data(struct nfs_write_data *wdata,
 }

 /*
- * This gives the layout driver an opportunity to read in page "around"
- * the data to be written.  It returns 0 on success, otherwise an error code
- * which will either be passed up to user, or ignored if
- * some previous part of write succeeded.
- * Note the range [pos, pos+len-1] is entirely within the page.
- */
-int _pnfs_write_begin(struct inode *inode, struct page *page,
-		      loff_t pos, unsigned len,
-		      struct pnfs_layout_segment *lseg,
-		      struct pnfs_fsdata **fsdata)
-{
-	struct pnfs_fsdata *data;
-	int status = 0;
-
-	dprintk("--> %s: pos=%llu len=%u\n",
-		__func__, (unsigned long long)pos, len);
-	data = kzalloc(sizeof(struct pnfs_fsdata), GFP_KERNEL);
-	if (!data) {
-		status = -ENOMEM;
-		goto out;
-	}
-	data->lseg = lseg; /* refcount passed into data to be managed there */
-	status = NFS_SERVER(inode)->pnfs_curr_ld->write_begin(
-						lseg, page, pos, len, data);
-	if (status) {
-		kfree(data);
-		data = NULL;
-	}
-out:
-	*fsdata = data;
-	dprintk("<-- %s: status=%d\n", __func__, status);
-	return status;
-}
-
-/*
  * Called by non rpc-based layout drivers
  */
 int
@@ -1308,53 +1261,41 @@ pnfs_try_to_read_data(struct nfs_read_data *rdata,
 }

 /*
- * Currently there is only one (whole file) write lseg.
+ * There can be multiple RW segments.
  */
-static struct pnfs_layout_segment *pnfs_list_write_lseg(struct inode *inode)
+static void pnfs_list_write_lseg(struct inode *inode, struct list_head *listp)
 {
-	struct pnfs_layout_segment *lseg, *rv = NULL;
-	loff_t max_pos = 0;
+	struct pnfs_layout_segment *lseg;

 	list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list) {
-		if (lseg->pls_range.iomode == IOMODE_RW) {
-			if (max_pos < lseg->pls_end_pos)
-				max_pos = lseg->pls_end_pos;
-			if (test_and_clear_bit
-			    (NFS_LSEG_LAYOUTCOMMIT, &lseg->pls_flags))
-				rv = lseg;
+		if (lseg->pls_range.iomode == IOMODE_RW &&
+		    test_bit(NFS_LSEG_LAYOUTCOMMIT, &lseg->pls_flags))
+			list_add(&lseg->pls_lc_list, listp);
 		}
 	}
-	rv->pls_end_pos = max_pos;
-
-	return rv;
-}

 void
 pnfs_set_layoutcommit(struct nfs_write_data *wdata)
 {
 	struct nfs_inode *nfsi = NFS_I(wdata->inode);
 	loff_t end_pos = wdata->mds_offset + wdata->res.count;
-	loff_t isize = i_size_read(wdata->inode);
 	bool mark_as_dirty = false;

 	spin_lock(&nfsi->vfs_inode.i_lock);
 	if (!test_and_set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
-		/* references matched in nfs4_layoutcommit_release */
-		get_lseg(wdata->lseg);
-		set_bit(NFS_LSEG_LAYOUTCOMMIT, &wdata->lseg->pls_flags);
-		wdata->lseg->pls_lc_cred =
-			get_rpccred(wdata->args.context->state->owner->so_cred);
 		mark_as_dirty = true;
 		dprintk("%s: Set layoutcommit for inode %lu ",
 			__func__, wdata->inode->i_ino);
 	}
-	if (end_pos > isize)
-		end_pos = isize;
-	if (end_pos > wdata->lseg->pls_end_pos)
-		wdata->lseg->pls_end_pos = end_pos;
+	if (!test_and_set_bit(NFS_LSEG_LAYOUTCOMMIT, &wdata->lseg->pls_flags)) {
+		/* references matched in nfs4_layoutcommit_release */
+		get_lseg(wdata->lseg);
+	}
+	if (end_pos > nfsi->layout->plh_lwb)
+		nfsi->layout->plh_lwb = end_pos;
 	spin_unlock(&nfsi->vfs_inode.i_lock);
 	dprintk("%s: lseg %p end_pos %llu\n",
-		__func__, wdata->lseg, wdata->lseg->pls_end_pos);
+		__func__, wdata->lseg, nfsi->layout->plh_lwb);

 	/* if pnfs_layoutcommit_inode() runs between inode locks, the next one
 	 * will be a noop because NFS_INO_LAYOUTCOMMIT will not be set */
@@ -1373,12 +1314,6 @@ void pnfs_cleanup_layoutcommit(struct inode *inode,
 							 data);
 }

-void pnfs_free_fsdata(struct pnfs_fsdata *fsdata)
-{
-	/* lseg refcounting handled directly in nfs_write_end */
-	kfree(fsdata);
-}
-
 /*
  * For the LAYOUT4_NFSV4_1_FILES layout type, NFS_DATA_SYNC WRITEs and
  * NFS_UNSTABLE WRITEs with a COMMIT to data servers must store enough
@@ -1392,8 +1327,6 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 {
 	struct nfs4_layoutcommit_data *data;
 	struct nfs_inode *nfsi = NFS_I(inode);
-	struct pnfs_layout_segment *lseg;
-	struct rpc_cred *cred;
 	loff_t end_pos;
 	int status = 0;

@@ -1410,30 +1343,25 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 		goto out;
 	}

+	INIT_LIST_HEAD(&data->lseg_list);
 	spin_lock(&inode->i_lock);
 	if (!test_and_clear_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
 		spin_unlock(&inode->i_lock);
 		kfree(data);
 		goto out;
 	}
-	/*
-	 * Currently only one (whole file) write lseg which is referenced
-	 * in pnfs_set_layoutcommit and will be found.
-	 */
-	lseg = pnfs_list_write_lseg(inode);

-	end_pos = lseg->pls_end_pos;
-	cred = lseg->pls_lc_cred;
-	lseg->pls_end_pos = 0;
-	lseg->pls_lc_cred = NULL;
+	pnfs_list_write_lseg(inode, &data->lseg_list);
+
+	end_pos = nfsi->layout->plh_lwb;
+	nfsi->layout->plh_lwb = 0;

 	memcpy(&data->args.stateid.data, nfsi->layout->plh_stateid.data,
 		sizeof(nfsi->layout->plh_stateid.data));
 	spin_unlock(&inode->i_lock);

 	data->args.inode = inode;
-	data->lseg = lseg;
-	data->cred = cred;
+	data->cred = nfsi->layout->plh_lc_cred;
 	nfs_fattr_init(&data->fattr);
 	data->args.bitmask = NFS_SERVER(inode)->cache_consistency_bitmask;
 	data->res.fattr = &data->fattr;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 6f7fa9f..f14e4f6 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -41,12 +41,11 @@ enum {

 struct pnfs_layout_segment {
 	struct list_head pls_list;
+	struct list_head pls_lc_list;
 	struct pnfs_layout_range pls_range;
 	atomic_t pls_refcount;
 	unsigned long pls_flags;
 	struct pnfs_layout_hdr *pls_layout;
-	struct rpc_cred	*pls_lc_cred; /* LAYOUTCOMMIT credential */
-	loff_t pls_end_pos; /* LAYOUTCOMMIT write end */
 };

 enum pnfs_try_status {
@@ -54,12 +53,6 @@ enum pnfs_try_status {
 	PNFS_NOT_ATTEMPTED = 1,
 };

-struct pnfs_fsdata {
-	struct pnfs_layout_segment *lseg;
-	int bypass_eof;
-	void *private;
-};
-
 #ifdef CONFIG_NFS_V4_1

 #define LAYOUT_NFSV4_1_MODULE_PREFIX "nfs-layouttype4"
@@ -113,14 +106,6 @@ struct pnfs_layoutdriver_type {
 	 */
 	enum pnfs_try_status (*read_pagelist) (struct nfs_read_data *nfs_data);
 	enum pnfs_try_status (*write_pagelist) (struct nfs_write_data *nfs_data, int how);
-	int (*write_begin) (struct pnfs_layout_segment *lseg, struct page *page,
-			    loff_t pos, unsigned count,
-			    struct pnfs_fsdata *fsdata);
-	int (*write_end)(struct inode *inode, struct page *page, loff_t pos,
-			 unsigned count, unsigned copied,
-			 struct pnfs_layout_segment *lseg);
-	void (*write_end_cleanup)(struct file *filp,
-				  struct pnfs_fsdata *fsdata);

 	void (*free_deviceid_node) (struct nfs4_deviceid_node *);

@@ -146,6 +131,8 @@ struct pnfs_layout_hdr {
 	unsigned long		plh_block_lgets; /* block LAYOUTGET if >0 */
 	u32			plh_barrier; /* ignore lower seqids */
 	unsigned long		plh_flags;
+	loff_t			plh_lwb; /* last write byte for layoutcommit */
+	struct rpc_cred		*plh_lc_cred; /* layoutcommit cred */
 	struct inode		*plh_inode;
 };

@@ -180,7 +167,6 @@ extern int nfs4_proc_layoutget(struct nfs4_layoutget *lgp);
 extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp);

 /* pnfs.c */
-extern unsigned int pnfs_layout_prefetch_kb;
 void get_layout_hdr(struct pnfs_layout_hdr *lo);
 void put_lseg(struct pnfs_layout_segment *lseg);

@@ -196,7 +182,6 @@ enum pnfs_try_status pnfs_try_to_read_data(struct nfs_read_data *,
 void pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *, struct nfs_page *);
 void pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *, struct nfs_page *);
 bool pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev, struct nfs_page *req);
-void pnfs_free_fsdata(struct pnfs_fsdata *fsdata);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_free_lseg_list(struct list_head *tmp_list);
 void pnfs_destroy_layout(struct nfs_inode *);
@@ -208,10 +193,6 @@ void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 int pnfs_choose_layoutget_stateid(nfs4_stateid *dst,
 				  struct pnfs_layout_hdr *lo,
 				  struct nfs4_state *open_state);
-int _pnfs_write_begin(struct inode *inode, struct page *page,
-		      loff_t pos, unsigned len,
-		      struct pnfs_layout_segment *lseg,
-		      struct pnfs_fsdata **fsdata);
 int mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
 				struct pnfs_layout_range *recall_range);
@@ -329,13 +310,6 @@ static inline void pnfs_clear_request_commit(struct nfs_page *req)
 		put_lseg(req->wb_commit_lseg);
 }

-static inline int pnfs_grow_ok(struct pnfs_layout_segment *lseg,
-			       struct pnfs_fsdata *fsdata)
-{
-	return !fsdata  || ((struct pnfs_layout_segment *)fsdata == lseg) ||
-		!fsdata->bypass_eof;
-}
-
 /* Should the pNFS client commit and return the layout upon a setattr */
 static inline bool
 pnfs_ld_layoutret_on_setattr(struct inode *inode)
@@ -346,49 +320,6 @@ pnfs_ld_layoutret_on_setattr(struct inode *inode)
 		PNFS_LAYOUTRET_ON_SETATTR;
 }

-static inline int pnfs_write_begin(struct file *filp, struct page *page,
-				   loff_t pos, unsigned len,
-				   struct pnfs_layout_segment *lseg,
-				   void **fsdata)
-{
-	struct inode *inode = filp->f_dentry->d_inode;
-	struct nfs_server *nfss = NFS_SERVER(inode);
-	int status = 0;
-
-	*fsdata = lseg;
-	if (lseg && nfss->pnfs_curr_ld->write_begin)
-		status = _pnfs_write_begin(inode, page, pos, len, lseg,
-					   (struct pnfs_fsdata **) fsdata);
-	return status;
-}
-
-/* CAREFUL - what happens if copied < len??? */
-static inline int pnfs_write_end(struct file *filp, struct page *page,
-				 loff_t pos, unsigned len, unsigned copied,
-				 struct pnfs_layout_segment *lseg)
-{
-	struct inode *inode = filp->f_dentry->d_inode;
-	struct nfs_server *nfss = NFS_SERVER(inode);
-
-	if (nfss->pnfs_curr_ld && nfss->pnfs_curr_ld->write_end)
-		return nfss->pnfs_curr_ld->write_end(inode, page, pos, len,
-						     copied, lseg);
-	else
-		return 0;
-}
-
-static inline void pnfs_write_end_cleanup(struct file *filp, void *fsdata)
-{
-	struct nfs_server *nfss = NFS_SERVER(filp->f_dentry->d_inode);
-
-	if (fsdata && nfss->pnfs_curr_ld) {
-		if (nfss->pnfs_curr_ld->write_end_cleanup)
-			nfss->pnfs_curr_ld->write_end_cleanup(filp, fsdata);
-		if (nfss->pnfs_curr_ld->write_begin)
-			pnfs_free_fsdata(fsdata);
-	}
-}
-
 static inline int pnfs_return_layout(struct inode *ino)
 {
 	struct nfs_inode *nfsi = NFS_I(ino);
@@ -400,19 +331,6 @@ static inline int pnfs_return_layout(struct inode *ino)
 	return 0;
 }

-static inline struct pnfs_layout_segment *
-nfs4_pull_lseg_from_fsdata(struct file *filp, void *fsdata)
-{
-	if (fsdata) {
-		struct nfs_server *nfss = NFS_SERVER(filp->f_dentry->d_inode);
-
-		if (nfss->pnfs_curr_ld && nfss->pnfs_curr_ld->write_begin)
-			return ((struct pnfs_fsdata *) fsdata)->lseg;
-		return (struct pnfs_layout_segment *)fsdata;
-	}
-	return NULL;
-}
-
 #else  /* CONFIG_NFS_V4_1 */

 static inline void pnfs_destroy_all_layouts(struct nfs_client *clp)
@@ -433,12 +351,6 @@ static inline void put_lseg(struct pnfs_layout_segment *lseg)
 {
 }

-static inline int pnfs_grow_ok(struct pnfs_layout_segment *lseg,
-			       struct pnfs_fsdata *fsdata)
-{
-	return 1;
-}
-
 static inline enum pnfs_try_status
 pnfs_try_to_read_data(struct nfs_read_data *data,
 		      const struct rpc_call_ops *call_ops)
@@ -458,26 +370,6 @@ static inline int pnfs_return_layout(struct inode *ino)
 	return 0;
 }

-static inline int pnfs_write_begin(struct file *filp, struct page *page,
-				   loff_t pos, unsigned len,
-				   struct pnfs_layout_segment *lseg,
-				   void **fsdata)
-{
-	*fsdata = NULL;
-	return 0;
-}
-
-static inline int pnfs_write_end(struct file *filp, struct page *page,
-				 loff_t pos, unsigned len, unsigned copied,
-				 struct pnfs_layout_segment *lseg)
-{
-	return 0;
-}
-
-static inline void pnfs_write_end_cleanup(struct file *filp, void *fsdata)
-{
-}
-
 static inline bool
 pnfs_ld_layoutret_on_setattr(struct inode *inode)
 {
@@ -554,13 +446,6 @@ static inline int pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 static inline void nfs4_deviceid_purge_client(struct nfs_client *ncl)
 {
 }
-
-static inline struct pnfs_layout_segment *
-nfs4_pull_lseg_from_fsdata(struct file *filp, void *fsdata)
-{
-	return NULL;
-}
-
 #endif /* CONFIG_NFS_V4_1 */

 #endif /* FS_NFS_PNFS_H */
diff --git a/fs/nfs/sysctl.c b/fs/nfs/sysctl.c
index 79a5134..978aaeb 100644
--- a/fs/nfs/sysctl.c
+++ b/fs/nfs/sysctl.c
@@ -14,7 +14,6 @@
 #include <linux/nfs_fs.h>

 #include "callback.h"
-#include "pnfs.h"

 #ifdef CONFIG_NFS_V4
 static const int nfs_set_port_min = 0;
@@ -43,15 +42,6 @@ static ctl_table nfs_cb_sysctls[] = {
 	},
 #endif /* CONFIG_NFS_USE_NEW_IDMAPPER */
 #endif
-#ifdef CONFIG_NFS_V4_1
-	{
-		.procname	= "pnfs_layout_prefetch_kb",
-		.data		= &pnfs_layout_prefetch_kb,
-		.maxlen		= sizeof(pnfs_layout_prefetch_kb),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-#endif
 	{
 		.procname	= "nfs_mountpoint_timeout",
 		.data		= &nfs_mountpoint_expiry_timeout,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 1185262..574ec0e 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -673,9 +673,7 @@ out:
 }

 static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
-		unsigned int offset, unsigned int count,
-		struct pnfs_layout_segment *lseg, void *fsdata)
-
+		unsigned int offset, unsigned int count)
 {
 	struct nfs_page	*req;

@@ -683,7 +681,6 @@ static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
 	if (IS_ERR(req))
 		return PTR_ERR(req);
 	/* Update file length */
-	if (pnfs_grow_ok(lseg, fsdata))
 		nfs_grow_file(page, offset, count);
 	nfs_mark_uptodate(page, req->wb_pgbase, req->wb_bytes);
 	nfs_mark_request_dirty(req);
@@ -737,8 +734,7 @@ static int nfs_write_pageuptodate(struct page *page, struct inode *inode)
  * things with a page scheduled for an RPC call (e.g. invalidate it).
  */
 int nfs_updatepage(struct file *file, struct page *page,
-		unsigned int offset, unsigned int count,
-		struct pnfs_layout_segment *lseg, void *fsdata)
+		unsigned int offset, unsigned int count)
 {
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
 	struct inode	*inode = page->mapping->host;
@@ -763,7 +759,7 @@ int nfs_updatepage(struct file *file, struct page *page,
 		offset = 0;
 	}

-	status = nfs_writepage_setup(ctx, page, offset, count, lseg, fsdata);
+	status = nfs_writepage_setup(ctx, page, offset, count);
 	if (status < 0)
 		nfs_set_pageerror(page);

diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index e459379..1b93b9c 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -510,8 +510,7 @@ extern int  nfs_congestion_kb;
 extern int  nfs_writepage(struct page *page, struct writeback_control *wbc);
 extern int  nfs_writepages(struct address_space *, struct writeback_control *);
 extern int  nfs_flush_incompatible(struct file *file, struct page *page);
-extern int nfs_updatepage(struct file *, struct page *, unsigned int,
-			  unsigned int, struct pnfs_layout_segment *, void *);
+extern int  nfs_updatepage(struct file *, struct page *, unsigned int, unsigned int);
 extern void nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);

 /*
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 065e941..27c12c7 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -275,7 +275,7 @@ struct nfs4_layoutcommit_res {
 struct nfs4_layoutcommit_data {
 	struct rpc_task task;
 	struct nfs_fattr fattr;
-	struct pnfs_layout_segment *lseg;
+	struct list_head lseg_list;
 	struct rpc_cred *cred;
 	struct nfs4_layoutcommit_args args;
 	struct nfs4_layoutcommit_res res;

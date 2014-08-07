Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:45783 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754267AbaHGHVl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Aug 2014 03:21:41 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 12/17] pnfs/blocklayout: remove read-modify-write handling in bl_write_pagelist
Date: Thu,  7 Aug 2014 09:23:44 +0200
Message-Id: <1407396229-4785-13-git-send-email-hch@lst.de>
In-Reply-To: <1407396229-4785-1-git-send-email-hch@lst.de>
References: <1407396229-4785-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the new PNFS_READ_WHOLE_PAGE flag to offload read-modify-write
handling to core nfs code, and remove a huge chunk of deadlock prone
mess from the block layout writeback path.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/blocklayout.c | 500 +++++----------------------------------
 1 file changed, 64 insertions(+), 436 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 87a633d..6484b9f 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -35,7 +35,6 @@
 #include <linux/mount.h>
 #include <linux/namei.h>
 #include <linux/bio.h>		/* struct bio */
-#include <linux/buffer_head.h>	/* various write calls */
 #include <linux/prefetch.h>
 #include <linux/pagevec.h>
 
@@ -188,16 +187,6 @@ retry:
 	return bio;
 }
 
-static struct bio *bl_add_page_to_bio(struct bio *bio, int npg, int rw,
-				      sector_t isect, struct page *page,
-				      struct pnfs_block_extent *be,
-				      void (*end_io)(struct bio *, int err),
-				      struct parallel_io *par)
-{
-	return do_add_page_to_bio(bio, npg, rw, isect, page, be,
-				  end_io, par, 0, PAGE_CACHE_SIZE);
-}
-
 /* This is basically copied from mpage_end_io_read */
 static void bl_end_io_read(struct bio *bio, int err)
 {
@@ -293,8 +282,8 @@ bl_read_pagelist(struct nfs_pgio_header *hdr)
 			}
 		}
 
+		pg_offset = f_offset & ~PAGE_CACHE_MASK;
 		if (is_dio) {
-			pg_offset = f_offset & ~PAGE_CACHE_MASK;
 			if (pg_offset + bytes_left > PAGE_CACHE_SIZE)
 				pg_len = PAGE_CACHE_SIZE - pg_offset;
 			else
@@ -305,7 +294,7 @@ bl_read_pagelist(struct nfs_pgio_header *hdr)
 			isect += (pg_offset >> SECTOR_SHIFT);
 			extent_length -= (pg_offset >> SECTOR_SHIFT);
 		} else {
-			pg_offset = 0;
+			BUG_ON(pg_offset != 0);
 			pg_len = PAGE_CACHE_SIZE;
 		}
 
@@ -383,29 +372,6 @@ static void mark_extents_written(struct pnfs_block_layout *bl,
 	}
 }
 
-static void bl_end_io_write_zero(struct bio *bio, int err)
-{
-	struct parallel_io *par = bio->bi_private;
-	struct bio_vec *bvec;
-	int i;
-
-	bio_for_each_segment_all(bvec, bio, i) {
-		/* This is the zeroing page we added */
-		end_page_writeback(bvec->bv_page);
-		page_cache_release(bvec->bv_page);
-	}
-
-	if (unlikely(err)) {
-		struct nfs_pgio_header *header = par->data;
-
-		if (!header->pnfs_error)
-			header->pnfs_error = -EIO;
-		pnfs_set_lo_fail(header->lseg);
-	}
-	bio_put(bio);
-	put_parallel(par);
-}
-
 static void bl_end_io_write(struct bio *bio, int err)
 {
 	struct parallel_io *par = bio->bi_private;
@@ -455,256 +421,22 @@ static void bl_end_par_io_write(void *data, int num_se)
 	schedule_work(&hdr->task.u.tk_work);
 }
 
-/* FIXME STUB - mark intersection of layout and page as bad, so is not
- * used again.
- */
-static void mark_bad_read(void)
-{
-	return;
-}
-
-/*
- * map_block:  map a requested I/0 block (isect) into an offset in the LVM
- * block_device
- */
-static void
-map_block(struct buffer_head *bh, sector_t isect, struct pnfs_block_extent *be)
-{
-	dprintk("%s enter be=%p\n", __func__, be);
-
-	set_buffer_mapped(bh);
-	bh->b_bdev = be->be_mdev;
-	bh->b_blocknr = (isect - be->be_f_offset + be->be_v_offset) >>
-	    (be->be_mdev->bd_inode->i_blkbits - SECTOR_SHIFT);
-
-	dprintk("%s isect %llu, bh->b_blocknr %ld, using bsize %Zd\n",
-		__func__, (unsigned long long)isect, (long)bh->b_blocknr,
-		bh->b_size);
-	return;
-}
-
-static void
-bl_read_single_end_io(struct bio *bio, int error)
-{
-	struct bio_vec *bvec = bio->bi_io_vec + bio->bi_vcnt - 1;
-	struct page *page = bvec->bv_page;
-
-	/* Only one page in bvec */
-	unlock_page(page);
-}
-
-static int
-bl_do_readpage_sync(struct page *page, struct pnfs_block_extent *be,
-		    unsigned int offset, unsigned int len)
-{
-	struct bio *bio;
-	struct page *shadow_page;
-	sector_t isect;
-	char *kaddr, *kshadow_addr;
-	int ret = 0;
-
-	dprintk("%s: offset %u len %u\n", __func__, offset, len);
-
-	shadow_page = alloc_page(GFP_NOFS | __GFP_HIGHMEM);
-	if (shadow_page == NULL)
-		return -ENOMEM;
-
-	bio = bio_alloc(GFP_NOIO, 1);
-	if (bio == NULL)
-		return -ENOMEM;
-
-	isect = (page->index << PAGE_CACHE_SECTOR_SHIFT) +
-		(offset / SECTOR_SIZE);
-
-	bio->bi_iter.bi_sector = isect - be->be_f_offset + be->be_v_offset;
-	bio->bi_bdev = be->be_mdev;
-	bio->bi_end_io = bl_read_single_end_io;
-
-	lock_page(shadow_page);
-	if (bio_add_page(bio, shadow_page,
-			 SECTOR_SIZE, round_down(offset, SECTOR_SIZE)) == 0) {
-		unlock_page(shadow_page);
-		bio_put(bio);
-		return -EIO;
-	}
-
-	submit_bio(READ, bio);
-	wait_on_page_locked(shadow_page);
-	if (unlikely(!test_bit(BIO_UPTODATE, &bio->bi_flags))) {
-		ret = -EIO;
-	} else {
-		kaddr = kmap_atomic(page);
-		kshadow_addr = kmap_atomic(shadow_page);
-		memcpy(kaddr + offset, kshadow_addr + offset, len);
-		kunmap_atomic(kshadow_addr);
-		kunmap_atomic(kaddr);
-	}
-	__free_page(shadow_page);
-	bio_put(bio);
-
-	return ret;
-}
-
-static int
-bl_read_partial_page_sync(struct page *page, struct pnfs_block_extent *be,
-			  unsigned int dirty_offset, unsigned int dirty_len,
-			  bool full_page)
-{
-	int ret = 0;
-	unsigned int start, end;
-
-	if (full_page) {
-		start = 0;
-		end = PAGE_CACHE_SIZE;
-	} else {
-		start = round_down(dirty_offset, SECTOR_SIZE);
-		end = round_up(dirty_offset + dirty_len, SECTOR_SIZE);
-	}
-
-	dprintk("%s: offset %u len %d\n", __func__, dirty_offset, dirty_len);
-	if (!be) {
-		zero_user_segments(page, start, dirty_offset,
-				   dirty_offset + dirty_len, end);
-		if (start == 0 && end == PAGE_CACHE_SIZE &&
-		    trylock_page(page)) {
-			SetPageUptodate(page);
-			unlock_page(page);
-		}
-		return ret;
-	}
-
-	if (start != dirty_offset)
-		ret = bl_do_readpage_sync(page, be, start, dirty_offset - start);
-
-	if (!ret && (dirty_offset + dirty_len < end))
-		ret = bl_do_readpage_sync(page, be, dirty_offset + dirty_len,
-					  end - dirty_offset - dirty_len);
-
-	return ret;
-}
-
-/* Given an unmapped page, zero it or read in page for COW, page is locked
- * by caller.
- */
-static int
-init_page_for_write(struct page *page, struct pnfs_block_extent *cow_read)
-{
-	struct buffer_head *bh = NULL;
-	int ret = 0;
-	sector_t isect;
-
-	dprintk("%s enter, %p\n", __func__, page);
-	BUG_ON(PageUptodate(page));
-	if (!cow_read) {
-		zero_user_segment(page, 0, PAGE_SIZE);
-		SetPageUptodate(page);
-		goto cleanup;
-	}
-
-	bh = alloc_page_buffers(page, PAGE_CACHE_SIZE, 0);
-	if (!bh) {
-		ret = -ENOMEM;
-		goto cleanup;
-	}
-
-	isect = (sector_t) page->index << PAGE_CACHE_SECTOR_SHIFT;
-	map_block(bh, isect, cow_read);
-	if (!bh_uptodate_or_lock(bh))
-		ret = bh_submit_read(bh);
-	if (ret)
-		goto cleanup;
-	SetPageUptodate(page);
-
-cleanup:
-	if (bh)
-		free_buffer_head(bh);
-	if (ret) {
-		/* Need to mark layout with bad read...should now
-		 * just use nfs4 for reads and writes.
-		 */
-		mark_bad_read();
-	}
-	return ret;
-}
-
-/* Find or create a zeroing page marked being writeback.
- * Return ERR_PTR on error, NULL to indicate skip this page and page itself
- * to indicate write out.
- */
-static struct page *
-bl_find_get_zeroing_page(struct inode *inode, pgoff_t index,
-			struct pnfs_block_extent *cow_read)
-{
-	struct page *page;
-	int locked = 0;
-	page = find_get_page(inode->i_mapping, index);
-	if (page)
-		goto check_page;
-
-	page = find_or_create_page(inode->i_mapping, index, GFP_NOFS);
-	if (unlikely(!page)) {
-		dprintk("%s oom\n", __func__);
-		return ERR_PTR(-ENOMEM);
-	}
-	locked = 1;
-
-check_page:
-	/* PageDirty: Other will write this out
-	 * PageWriteback: Other is writing this out
-	 * PageUptodate: It was read before
-	 */
-	if (PageDirty(page) || PageWriteback(page)) {
-		print_page(page);
-		if (locked)
-			unlock_page(page);
-		page_cache_release(page);
-		return NULL;
-	}
-
-	if (!locked) {
-		lock_page(page);
-		locked = 1;
-		goto check_page;
-	}
-	if (!PageUptodate(page)) {
-		/* New page, readin or zero it */
-		init_page_for_write(page, cow_read);
-	}
-	set_page_writeback(page);
-	unlock_page(page);
-
-	return page;
-}
-
 static enum pnfs_try_status
 bl_write_pagelist(struct nfs_pgio_header *header, int sync)
 {
-	int i, ret, npg_zero, pg_index, last = 0;
+	int i, ret;
 	struct bio *bio = NULL;
-	struct pnfs_block_extent *be = NULL, *cow_read = NULL;
-	sector_t isect, last_isect = 0, extent_length = 0;
+	struct pnfs_block_extent *be = NULL;
+	sector_t isect, extent_length = 0;
 	struct parallel_io *par = NULL;
 	loff_t offset = header->args.offset;
 	size_t count = header->args.count;
-	unsigned int pg_offset, pg_len, saved_len;
 	struct page **pages = header->args.pages;
-	struct page *page;
-	pgoff_t index;
-	u64 temp;
-	int npg_per_block =
-	    NFS_SERVER(header->inode)->pnfs_blksize >> PAGE_CACHE_SHIFT;
+	int pg_index = pg_index = header->args.pgbase >> PAGE_CACHE_SHIFT;
 	struct blk_plug plug;
 
 	dprintk("%s enter, %Zu@%lld\n", __func__, count, offset);
 
-	blk_start_plug(&plug);
-
-	if (header->dreq != NULL &&
-	    (!IS_ALIGNED(offset, NFS_SERVER(header->inode)->pnfs_blksize) ||
-	     !IS_ALIGNED(count, NFS_SERVER(header->inode)->pnfs_blksize))) {
-		dprintk("pnfsblock nonblock aligned DIO writes. Resend MDS\n");
-		goto out_mds;
-	}
 	/* At this point, header->page_aray is a (sequential) list of nfs_pages.
 	 * We want to write each, and if there is an error set pnfs_error
 	 * to have it redone using nfs.
@@ -715,97 +447,20 @@ bl_write_pagelist(struct nfs_pgio_header *header, int sync)
 	par->pnfs_callback = bl_end_par_io_write;
 	/* At this point, have to be more careful with error handling */
 
-	isect = (sector_t) ((offset & (long)PAGE_CACHE_MASK) >> SECTOR_SHIFT);
-	be = bl_find_get_extent(BLK_LSEG2EXT(header->lseg), isect, &cow_read);
-	if (!be || !is_writable(be, isect)) {
-		dprintk("%s no matching extents!\n", __func__);
-		goto out_mds;
-	}
-
-	/* First page inside INVALID extent */
-	if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
-		if (likely(!bl_push_one_short_extent(be->be_inval)))
-			par->bse_count++;
-		else
-			goto out_mds;
-		temp = offset >> PAGE_CACHE_SHIFT;
-		npg_zero = do_div(temp, npg_per_block);
-		isect = (sector_t) (((offset - npg_zero * PAGE_CACHE_SIZE) &
-				     (long)PAGE_CACHE_MASK) >> SECTOR_SHIFT);
-		extent_length = be->be_length - (isect - be->be_f_offset);
-
-fill_invalid_ext:
-		dprintk("%s need to zero %d pages\n", __func__, npg_zero);
-		for (;npg_zero > 0; npg_zero--) {
-			if (bl_is_sector_init(be->be_inval, isect)) {
-				dprintk("isect %llu already init\n",
-					(unsigned long long)isect);
-				goto next_page;
-			}
-			/* page ref released in bl_end_io_write_zero */
-			index = isect >> PAGE_CACHE_SECTOR_SHIFT;
-			dprintk("%s zero %dth page: index %lu isect %llu\n",
-				__func__, npg_zero, index,
-				(unsigned long long)isect);
-			page = bl_find_get_zeroing_page(header->inode, index,
-							cow_read);
-			if (unlikely(IS_ERR(page))) {
-				header->pnfs_error = PTR_ERR(page);
-				goto out;
-			} else if (page == NULL)
-				goto next_page;
-
-			ret = bl_mark_sectors_init(be->be_inval, isect,
-						       PAGE_CACHE_SECTORS);
-			if (unlikely(ret)) {
-				dprintk("%s bl_mark_sectors_init fail %d\n",
-					__func__, ret);
-				end_page_writeback(page);
-				page_cache_release(page);
-				header->pnfs_error = ret;
-				goto out;
-			}
-			if (likely(!bl_push_one_short_extent(be->be_inval)))
-				par->bse_count++;
-			else {
-				end_page_writeback(page);
-				page_cache_release(page);
-				header->pnfs_error = -ENOMEM;
-				goto out;
-			}
-			/* FIXME: This should be done in bi_end_io */
-			mark_extents_written(BLK_LSEG2EXT(header->lseg),
-					     page->index << PAGE_CACHE_SHIFT,
-					     PAGE_CACHE_SIZE);
-
-			bio = bl_add_page_to_bio(bio, npg_zero, WRITE,
-						 isect, page, be,
-						 bl_end_io_write_zero, par);
-			if (IS_ERR(bio)) {
-				header->pnfs_error = PTR_ERR(bio);
-				bio = NULL;
-				goto out;
-			}
-next_page:
-			isect += PAGE_CACHE_SECTORS;
-			extent_length -= PAGE_CACHE_SECTORS;
-		}
-		if (last)
-			goto write_done;
-	}
-	bio = bl_submit_bio(WRITE, bio);
+	blk_start_plug(&plug);
 
-	/* Middle pages */
-	pg_index = header->args.pgbase >> PAGE_CACHE_SHIFT;
+	/* we always write out the whole page */
+	offset = offset & (loff_t)PAGE_CACHE_MASK;
+	isect = offset >> SECTOR_SHIFT;
+	
 	for (i = pg_index; i < header->page_array.npages; i++) {
 		if (extent_length <= 0) {
 			/* We've used up the previous extent */
 			bl_put_extent(be);
-			bl_put_extent(cow_read);
 			bio = bl_submit_bio(WRITE, bio);
 			/* Get the next one */
 			be = bl_find_get_extent(BLK_LSEG2EXT(header->lseg),
-					     isect, &cow_read);
+					     isect, NULL);
 			if (!be || !is_writable(be, isect)) {
 				header->pnfs_error = -EINVAL;
 				goto out;
@@ -823,25 +478,10 @@ next_page:
 			    (isect - be->be_f_offset);
 		}
 
-		dprintk("%s offset %lld count %Zu\n", __func__, offset, count);
-		pg_offset = offset & ~PAGE_CACHE_MASK;
-		if (pg_offset + count > PAGE_CACHE_SIZE)
-			pg_len = PAGE_CACHE_SIZE - pg_offset;
-		else
-			pg_len = count;
+		BUG_ON(offset & ~PAGE_CACHE_MASK);
 
-		saved_len = pg_len;
 		if (be->be_state == PNFS_BLOCK_INVALID_DATA &&
 		    !bl_is_sector_init(be->be_inval, isect)) {
-			ret = bl_read_partial_page_sync(pages[i], cow_read,
-							pg_offset, pg_len, true);
-			if (ret) {
-				dprintk("%s bl_read_partial_page_sync fail %d\n",
-					__func__, ret);
-				header->pnfs_error = ret;
-				goto out;
-			}
-
 			ret = bl_mark_sectors_init(be->be_inval, isect,
 						       PAGE_CACHE_SECTORS);
 			if (unlikely(ret)) {
@@ -850,66 +490,31 @@ next_page:
 				header->pnfs_error = ret;
 				goto out;
 			}
-
-			/* Expand to full page write */
-			pg_offset = 0;
-			pg_len = PAGE_CACHE_SIZE;
-		} else if  ((pg_offset & (SECTOR_SIZE - 1)) ||
-			    (pg_len & (SECTOR_SIZE - 1))){
-			/* ahh, nasty case. We have to do sync full sector
-			 * read-modify-write cycles.
-			 */
-			unsigned int saved_offset = pg_offset;
-			ret = bl_read_partial_page_sync(pages[i], be, pg_offset,
-							pg_len, false);
-			pg_offset = round_down(pg_offset, SECTOR_SIZE);
-			pg_len = round_up(saved_offset + pg_len, SECTOR_SIZE)
-				 - pg_offset;
 		}
 
-
 		bio = do_add_page_to_bio(bio, header->page_array.npages - i,
-					 WRITE,
-					 isect, pages[i], be,
+					 WRITE, isect, pages[i], be,
 					 bl_end_io_write, par,
-					 pg_offset, pg_len);
+					 0, PAGE_CACHE_SIZE);
 		if (IS_ERR(bio)) {
 			header->pnfs_error = PTR_ERR(bio);
 			bio = NULL;
 			goto out;
 		}
-		offset += saved_len;
-		count -= saved_len;
+		offset += PAGE_CACHE_SIZE;
+		count -= PAGE_CACHE_SIZE;
 		isect += PAGE_CACHE_SECTORS;
-		last_isect = isect;
 		extent_length -= PAGE_CACHE_SECTORS;
 	}
 
-	/* Last page inside INVALID extent */
-	if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
-		bio = bl_submit_bio(WRITE, bio);
-		temp = last_isect >> PAGE_CACHE_SECTOR_SHIFT;
-		npg_zero = npg_per_block - do_div(temp, npg_per_block);
-		if (npg_zero < npg_per_block) {
-			last = 1;
-			goto fill_invalid_ext;
-		}
-	}
-
-write_done:
 	header->res.count = header->args.count;
 out:
 	bl_put_extent(be);
-	bl_put_extent(cow_read);
 	bl_submit_bio(WRITE, bio);
 	blk_finish_plug(&plug);
 	put_parallel(par);
 	return PNFS_ATTEMPTED;
 out_mds:
-	blk_finish_plug(&plug);
-	bl_put_extent(be);
-	bl_put_extent(cow_read);
-	kfree(par);
 	return PNFS_NOT_ATTEMPTED;
 }
 
@@ -1188,20 +793,45 @@ bl_clear_layoutdriver(struct nfs_server *server)
 }
 
 static bool
-is_aligned_req(struct nfs_page *req, unsigned int alignment)
+is_aligned_req(struct nfs_pageio_descriptor *pgio,
+		struct nfs_page *req, unsigned int alignment)
 {
-	return IS_ALIGNED(req->wb_offset, alignment) &&
-	       IS_ALIGNED(req->wb_bytes, alignment);
+	/*
+	 * Always accept buffered writes, higher layers take care of the
+	 * right alignment.
+	 */
+	if (pgio->pg_dreq == NULL)
+		return true;
+
+	if (!IS_ALIGNED(req->wb_offset, alignment))
+		return false;
+
+	if (IS_ALIGNED(req->wb_bytes, alignment))
+		return true;
+
+	if (req_offset(req) + req->wb_bytes == i_size_read(pgio->pg_inode)) {
+		/*
+		 * If the write goes up to the inode size, just write
+		 * the full page.  Data past the inode size is
+		 * guaranteed to be zeroed by the higher level client
+		 * code, and this behaviour is mandated by RFC 5663
+		 * section 2.3.2.
+		 */
+		return true;
+	}
+
+	return false;
 }
 
 static void
 bl_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 {
-	if (pgio->pg_dreq != NULL &&
-	    !is_aligned_req(req, SECTOR_SIZE))
+	if (!is_aligned_req(pgio, req, SECTOR_SIZE)) {
 		nfs_pageio_reset_read_mds(pgio);
-	else
-		pnfs_generic_pg_init_read(pgio, req);
+		return;
+	}
+
+	pnfs_generic_pg_init_read(pgio, req);
 }
 
 /*
@@ -1212,10 +842,8 @@ static size_t
 bl_pg_test_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 		struct nfs_page *req)
 {
-	if (pgio->pg_dreq != NULL &&
-	    !is_aligned_req(req, SECTOR_SIZE))
+	if (!is_aligned_req(pgio, req, SECTOR_SIZE))
 		return 0;
-
 	return pnfs_generic_pg_test(pgio, prev, req);
 }
 
@@ -1245,19 +873,20 @@ static u64 pnfs_num_cont_bytes(struct inode *inode, pgoff_t idx)
 static void
 bl_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 {
-	if (pgio->pg_dreq != NULL &&
-	    !is_aligned_req(req, PAGE_CACHE_SIZE)) {
+	u64 wb_size;
+
+	if (!is_aligned_req(pgio, req, PAGE_SIZE)) {
 		nfs_pageio_reset_write_mds(pgio);
-	} else {
-		u64 wb_size;
-		if (pgio->pg_dreq == NULL)
-			wb_size = pnfs_num_cont_bytes(pgio->pg_inode,
-						      req->wb_index);
-		else
-			wb_size = nfs_dreq_bytes_left(pgio->pg_dreq);
-
-		pnfs_generic_pg_init_write(pgio, req, wb_size);
+		return;
 	}
+
+	if (pgio->pg_dreq == NULL)
+		wb_size = pnfs_num_cont_bytes(pgio->pg_inode,
+					      req->wb_index);
+	else
+		wb_size = nfs_dreq_bytes_left(pgio->pg_dreq);
+
+	pnfs_generic_pg_init_write(pgio, req, wb_size);
 }
 
 /*
@@ -1268,10 +897,8 @@ static size_t
 bl_pg_test_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 		 struct nfs_page *req)
 {
-	if (pgio->pg_dreq != NULL &&
-	    !is_aligned_req(req, PAGE_CACHE_SIZE))
+	if (!is_aligned_req(pgio, req, PAGE_SIZE))
 		return 0;
-
 	return pnfs_generic_pg_test(pgio, prev, req);
 }
 
@@ -1291,6 +918,7 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
 	.id				= LAYOUT_BLOCK_VOLUME,
 	.name				= "LAYOUT_BLOCK_VOLUME",
 	.owner				= THIS_MODULE,
+	.flags				= PNFS_READ_WHOLE_PAGE,
 	.read_pagelist			= bl_read_pagelist,
 	.write_pagelist			= bl_write_pagelist,
 	.alloc_layout_hdr		= bl_alloc_layout_hdr,
-- 
1.9.1


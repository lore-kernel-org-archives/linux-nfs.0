Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:51906 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043Ab2GZPhK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jul 2012 11:37:10 -0400
Received: by ghrr11 with SMTP id r11so2105804ghr.19
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jul 2012 08:37:10 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: bharrosh@panasas.com, bhalevy@tonian.com
Subject: [PATCH] pnfsblock: fix partial page buffer wirte
Date: Thu, 26 Jul 2012 23:36:37 +0800
Message-Id: <1343316997-1795-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If applications use flock to protect its write range, generic NFS
will not do read-modify-write cycle at page cache level. Therefore
LD should know how to handle non-page/sector aligned writes.
Otherwise there will be data corruption.

Cc: stable <stable@vger.kernel.org>
Signed-off-by: Peng Tao <tao.peng@emc.com>
---
 fs/nfs/blocklayout/blocklayout.c |  177 +++++++++++++++++++++++++++++++++++---
 fs/nfs/blocklayout/blocklayout.h |    1 +
 2 files changed, 166 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 7ae8a60..39fa002 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -162,25 +162,39 @@ static struct bio *bl_alloc_init_bio(int npg, sector_t isect,
 	return bio;
 }
 
-static struct bio *bl_add_page_to_bio(struct bio *bio, int npg, int rw,
+static struct bio *do_add_page_to_bio(struct bio *bio, int npg, int rw,
 				      sector_t isect, struct page *page,
 				      struct pnfs_block_extent *be,
 				      void (*end_io)(struct bio *, int err),
-				      struct parallel_io *par)
+				      struct parallel_io *par,
+				      unsigned int offset, int len)
 {
+	isect = isect + (offset >> SECTOR_SHIFT);
+	dprintk("%s: npg %d rw %d isect %llu offset %u len %d\n", __func__,
+		npg, rw, (unsigned long long)isect, offset, len);
 retry:
 	if (!bio) {
 		bio = bl_alloc_init_bio(npg, isect, be, end_io, par);
 		if (!bio)
 			return ERR_PTR(-ENOMEM);
 	}
-	if (bio_add_page(bio, page, PAGE_CACHE_SIZE, 0) < PAGE_CACHE_SIZE) {
+	if (bio_add_page(bio, page, len, offset) < len) {
 		bio = bl_submit_bio(rw, bio);
 		goto retry;
 	}
 	return bio;
 }
 
+static struct bio *bl_add_page_to_bio(struct bio *bio, int npg, int rw,
+				      sector_t isect, struct page *page,
+				      struct pnfs_block_extent *be,
+				      void (*end_io)(struct bio *, int err),
+				      struct parallel_io *par)
+{
+	return do_add_page_to_bio(bio, npg, rw, isect, page, be,
+				  end_io, par, 0, PAGE_CACHE_SIZE);
+}
+
 /* This is basically copied from mpage_end_io_read */
 static void bl_end_io_read(struct bio *bio, int err)
 {
@@ -450,6 +464,106 @@ map_block(struct buffer_head *bh, sector_t isect, struct pnfs_block_extent *be)
 	return;
 }
 
+static void
+bl_read_single_end_io(struct bio *bio, int error)
+{
+	struct bio_vec *bvec = bio->bi_io_vec + bio->bi_vcnt - 1;
+	struct page *page = bvec->bv_page;
+
+	/* Only one page in bvec */
+	unlock_page(page);
+}
+
+static int
+bl_do_readpage_sync(struct page *page, struct pnfs_block_extent *be,
+		    unsigned int offset, unsigned int len)
+{
+	struct bio *bio;
+	struct page *shadow_page;
+	sector_t isect;
+	char *kaddr, *kshadow_addr;
+	int ret = 0;
+
+	dprintk("%s: offset %u len %u\n", __func__, offset, len);
+
+	shadow_page = alloc_page(GFP_NOFS | __GFP_HIGHMEM);
+	if (shadow_page == NULL)
+		return -ENOMEM;
+
+	bio = bio_alloc(GFP_NOIO, 1);
+	if (bio == NULL)
+		return -ENOMEM;
+
+	isect = (page->index << PAGE_CACHE_SECTOR_SHIFT) +
+		(offset >> SECTOR_SHIFT);
+
+	bio->bi_sector = isect - be->be_f_offset + be->be_v_offset;
+	bio->bi_bdev = be->be_mdev;
+	bio->bi_end_io = bl_read_single_end_io;
+
+	lock_page(shadow_page);
+	if (bio_add_page(bio, shadow_page,
+			 SECTOR_SIZE, round_down(offset, SECTOR_SIZE)) == 0) {
+		unlock_page(shadow_page);
+		bio_put(bio);
+		return -EIO;
+	}
+
+	submit_bio(READ, bio);
+	wait_on_page_locked(shadow_page);
+	if (unlikely(!test_bit(BIO_UPTODATE, &bio->bi_flags))) {
+		ret = -EIO;
+	} else {
+		kaddr = kmap_atomic(page);
+		kshadow_addr = kmap_atomic(shadow_page);
+		memcpy(kaddr + offset, kshadow_addr + offset, len);
+		kunmap_atomic(kshadow_addr);
+		kunmap_atomic(kaddr);
+	}
+	__free_page(shadow_page);
+	bio_put(bio);
+
+	return ret;
+}
+
+static int
+bl_read_partial_page_sync(struct page *page, struct pnfs_block_extent *be,
+			  unsigned int dirty_offset, unsigned int dirty_len,
+			  bool full_page)
+{
+	int ret = 0;
+	unsigned int start, end;
+
+	if (full_page) {
+		start = 0;
+		end = PAGE_CACHE_SIZE;
+	} else {
+		start = round_down(dirty_offset, SECTOR_SIZE);
+		end = round_up(dirty_offset + dirty_len, SECTOR_SIZE);
+	}
+
+	dprintk("%s: offset %u len %d\n", __func__, dirty_offset, dirty_len);
+	if (!be) {
+		zero_user_segments(page, start, dirty_offset,
+				   dirty_offset + dirty_len, end);
+		if (start == 0 && end == PAGE_CACHE_SIZE &&
+		    trylock_page(page)) {
+			SetPageUptodate(page);
+			unlock_page(page);
+		}
+		return ret;
+	}
+
+	if (start != dirty_offset)
+		ret = bl_do_readpage_sync(page, be, start, dirty_offset - start);
+
+	if (!ret && (dirty_offset + dirty_len < end))
+		ret = bl_do_readpage_sync(page, be, dirty_offset + dirty_len,
+					  end - dirty_offset - dirty_len);
+
+	return ret;
+}
+
 /* Given an unmapped page, zero it or read in page for COW, page is locked
  * by caller.
  */
@@ -483,7 +597,6 @@ init_page_for_write(struct page *page, struct pnfs_block_extent *cow_read)
 	SetPageUptodate(page);
 
 cleanup:
-	bl_put_extent(cow_read);
 	if (bh)
 		free_buffer_head(bh);
 	if (ret) {
@@ -555,6 +668,7 @@ bl_write_pagelist(struct nfs_write_data *wdata, int sync)
 	struct parallel_io *par;
 	loff_t offset = wdata->args.offset;
 	size_t count = wdata->args.count;
+	unsigned int pg_offset, pg_len, saved_len;
 	struct page **pages = wdata->args.pages;
 	struct page *page;
 	pgoff_t index;
@@ -659,10 +773,11 @@ next_page:
 		if (!extent_length) {
 			/* We've used up the previous extent */
 			bl_put_extent(be);
+			bl_put_extent(cow_read);
 			bio = bl_submit_bio(WRITE, bio);
 			/* Get the next one */
 			be = bl_find_get_extent(BLK_LSEG2EXT(header->lseg),
-					     isect, NULL);
+					     isect, &cow_read);
 			if (!be || !is_writable(be, isect)) {
 				header->pnfs_error = -EINVAL;
 				goto out;
@@ -679,7 +794,26 @@ next_page:
 			extent_length = be->be_length -
 			    (isect - be->be_f_offset);
 		}
-		if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
+
+		dprintk("%s offset %lld count %Zu\n", __func__, offset, count);
+		pg_offset = offset & ~PAGE_CACHE_MASK;
+		if (pg_offset + count > PAGE_CACHE_SIZE)
+			pg_len = PAGE_CACHE_SIZE - pg_offset;
+		else
+			pg_len = count;
+
+		saved_len = pg_len;
+		if (be->be_state == PNFS_BLOCK_INVALID_DATA &&
+		    !bl_is_sector_init(be->be_inval, isect)) {
+			ret = bl_read_partial_page_sync(pages[i], cow_read,
+							pg_offset, pg_len, true);
+			if (ret) {
+				dprintk("%s bl_read_partial_page_sync fail %d\n",
+					__func__, ret);
+				header->pnfs_error = ret;
+				goto out;
+			}
+
 			ret = bl_mark_sectors_init(be->be_inval, isect,
 						       PAGE_CACHE_SECTORS);
 			if (unlikely(ret)) {
@@ -688,15 +822,35 @@ next_page:
 				header->pnfs_error = ret;
 				goto out;
 			}
+
+			/* Expand to full page write */
+			pg_offset = 0;
+			pg_len = PAGE_CACHE_SIZE;
+		} else if  ((pg_offset & (SECTOR_SIZE - 1)) ||
+			    (pg_len & (SECTOR_SIZE - 1))){
+			/* ahh, nasty case. We have to do sync full sector
+			 * read-modify-write cycles.
+			 */
+			unsigned int saved_offset = pg_offset;
+			ret = bl_read_partial_page_sync(pages[i], be, pg_offset,
+							pg_len, false);
+			pg_offset = round_down(pg_offset, SECTOR_SIZE);
+			pg_len = round_up(saved_offset + pg_len, SECTOR_SIZE)
+				 - pg_offset;
 		}
-		bio = bl_add_page_to_bio(bio, wdata->pages.npages - i, WRITE,
+
+
+		bio = do_add_page_to_bio(bio, wdata->pages.npages - i, WRITE,
 					 isect, pages[i], be,
-					 bl_end_io_write, par);
+					 bl_end_io_write, par,
+					 pg_offset, pg_len);
 		if (IS_ERR(bio)) {
 			header->pnfs_error = PTR_ERR(bio);
 			bio = NULL;
 			goto out;
 		}
+		offset += saved_len;
+		count -= saved_len;
 		isect += PAGE_CACHE_SECTORS;
 		last_isect = isect;
 		extent_length -= PAGE_CACHE_SECTORS;
@@ -714,17 +868,16 @@ next_page:
 	}
 
 write_done:
-	wdata->res.count = (last_isect << SECTOR_SHIFT) - (offset);
-	if (count < wdata->res.count) {
-		wdata->res.count = count;
-	}
+	wdata->res.count = wdata->args.count;
 out:
 	bl_put_extent(be);
+	bl_put_extent(cow_read);
 	bl_submit_bio(WRITE, bio);
 	put_parallel(par);
 	return PNFS_ATTEMPTED;
 out_mds:
 	bl_put_extent(be);
+	bl_put_extent(cow_read);
 	kfree(par);
 	return PNFS_NOT_ATTEMPTED;
 }
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 0335069..39bb51a 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -41,6 +41,7 @@
 
 #define PAGE_CACHE_SECTORS (PAGE_CACHE_SIZE >> SECTOR_SHIFT)
 #define PAGE_CACHE_SECTOR_SHIFT (PAGE_CACHE_SHIFT - SECTOR_SHIFT)
+#define SECTOR_SIZE (1 << SECTOR_SHIFT)
 
 struct block_mount_id {
 	spinlock_t			bm_lock;    /* protects list */
-- 
1.7.1.262.g5ef3d


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:57829 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226Ab1GGQ0V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jul 2011 12:26:21 -0400
Message-Id: <bc6242314f8e620722ab3707f0771e30e3a3e188.1310055433.git.rees@umich.edu>
In-Reply-To: <cover.1310055433.git.rees@umich.edu>
References: <cover.1310055433.git.rees@umich.edu>
Subject: [PATCH 6/6] pnfs-block: mark IO error with NFS_LAYOUT_{RW|RO}_FAILED
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Thu,  7 Jul 2011 12:26:19 -0400
From: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Peng Tao <bergwolf@gmail.com>

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/blocklayout/blocklayout.c |   90 ++++++++++++++-----------------------
 fs/nfs/blocklayout/blocklayout.h |    5 --
 2 files changed, 34 insertions(+), 61 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 804eee6..65daed9 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -143,35 +143,40 @@ static struct bio *bl_submit_bio(int rw, struct bio *bio)
 	return NULL;
 }
 
-static inline void bl_done_with_rpage(struct page *page, const int ok)
+static void bl_set_lo_fail(struct pnfs_layout_segment *lseg)
 {
-	if (ok) {
-		ClearPagePnfsErr(page);
-		SetPageUptodate(page);
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
@@ -219,13 +224,7 @@ static enum pnfs_try_status bl_read_pagelist(struct nfs_read_data *rdata)
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
@@ -246,9 +245,8 @@ static enum pnfs_try_status bl_read_pagelist(struct nfs_read_data *rdata)
 			be = find_get_extent(BLK_LSEG2EXT(rdata->lseg),
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
@@ -263,10 +261,9 @@ static enum pnfs_try_status bl_read_pagelist(struct nfs_read_data *rdata)
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
 
@@ -277,9 +274,8 @@ static enum pnfs_try_status bl_read_pagelist(struct nfs_read_data *rdata)
 					    bio_alloc(GFP_NOIO,
 						      rdata->npages - i);
 					if (!bio) {
-						/* Error out this page */
-						bl_done_with_rpage(pages[i], 0);
-						break;
+						rdata->pnfs_error = -ENOMEM;
+						goto out;
 					}
 					bio->bi_sector = isect -
 					    be_read->be_f_offset +
@@ -302,6 +298,7 @@ static enum pnfs_try_status bl_read_pagelist(struct nfs_read_data *rdata)
 	} else {
 		rdata->res.count = (isect << 9) - f_offset;
 	}
+out:
 	put_extent(be);
 	put_extent(cow_read);
 	bl_submit_bio(READ, bio);
@@ -337,22 +334,6 @@ static void mark_extents_written(struct pnfs_block_layout *bl,
 	}
 }
 
-static inline void bl_done_with_wpage(struct page *page, const int ok)
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
-	}
-}
-
 static void bl_end_io_write_zero(struct bio *bio, int err)
 {
 	struct parallel_io *par = bio->bi_private;
@@ -365,13 +346,15 @@ static void bl_end_io_write_zero(struct bio *bio, int err)
 
 		if (--bvec >= bio->bi_io_vec)
 			prefetchw(&bvec->bv_page->flags);
-		bl_done_with_wpage(page, uptodate);
 		/* This is the zeroing page we added */
 		end_page_writeback(page);
 		page_cache_release(page);
 	} while (bvec >= bio->bi_io_vec);
-	if (!uptodate && !wdata->pnfs_error)
-		wdata->pnfs_error = -EIO;
+	if (!uptodate) {
+		if (!wdata->pnfs_error)
+			wdata->pnfs_error = -EIO;
+		bl_set_lo_fail(wdata->lseg);
+	}
 	bio_put(bio);
 	put_parallel(par);
 }
@@ -380,18 +363,13 @@ static void bl_end_io_write(struct bio *bio, int err)
 {
 	struct parallel_io *par = bio->bi_private;
 	const int uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
-	struct bio_vec *bvec = bio->bi_io_vec + bio->bi_vcnt - 1;
 	struct nfs_write_data *wdata = (struct nfs_write_data *)par->data;
 
-	do {
-		struct page *page = bvec->bv_page;
-
-		if (--bvec >= bio->bi_io_vec)
-			prefetchw(&bvec->bv_page->flags);
-		bl_done_with_wpage(page, uptodate);
-	} while (bvec >= bio->bi_io_vec);
-	if (!uptodate && !wdata->pnfs_error)
-		wdata->pnfs_error = -EIO;
+	if (!uptodate) {
+		if (!wdata->pnfs_error)
+			wdata->pnfs_error = -EIO;
+		bl_set_lo_fail(wdata->lseg);
+	}
 	bio_put(bio);
 	put_parallel(par);
 }
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index d923acc..e2b2a50 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -37,11 +37,6 @@
 
 #define PAGE_CACHE_SECTORS (PAGE_CACHE_SIZE >> 9)
 
-#define PG_pnfserr PG_owner_priv_1
-#define PagePnfsErr(page)	test_bit(PG_pnfserr, &(page)->flags)
-#define SetPagePnfsErr(page)	set_bit(PG_pnfserr, &(page)->flags)
-#define ClearPagePnfsErr(page)	clear_bit(PG_pnfserr, &(page)->flags)
-
 struct block_mount_id {
 	spinlock_t			bm_lock;    /* protects list */
 	struct list_head		bm_devlist; /* holds pnfs_block_dev */
-- 
1.7.4.1


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:53819 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755936Ab1FGR3s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:29:48 -0400
Date: Tue, 7 Jun 2011 13:29:46 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 33/88] pnfsblock: bl_write_pagelist
Message-ID: <15ecb4872bab4715ed7a275160e36f82e23c9e89.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Note: When upper layer's read/write request cannot be fulfilled, the block
layout driver shouldn't silently mark the page as error. It should do
what can be done and  leave the rest to the upper layer. To do so, we
should set rdata/wdata->res.count properly.

When upper layer re-send the read/write request to finish the rest
part of the request, pgbase is the position where we should start at.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfsblock: handle errors when read or write pagelist.]
Signed-off-by: Zhang Jingwang <yyalone@gmail.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |  141 ++++++++++++++++++++++++++++++++++++-
 1 files changed, 137 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 9c46f5a..df0cfe4 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -335,9 +335,69 @@ bl_read_pagelist(struct pnfs_layout_type *lo,
 	return PNFS_NOT_ATTEMPTED;
 }
 
-/* FRED - It can indicate bytes written in wdata->res.count.
- * It can indicate error status in wdata->task.tk_status.
+/* STUB - this needs thought */
+static inline void
+bl_done_with_wpage(struct page *page, const int ok)
+{
+	if (!ok) {
+		SetPageError(page);
+		SetPagePnfsErr(page);
+		/* This is an inline copy of nfs_zap_mapping */
+		/* This is oh so fishy, and needs deep thought */
+		if (page->mapping->nrpages != 0) {
+			struct inode *inode = page->mapping->host;
+			spin_lock(&inode->i_lock);
+			NFS_I(inode)->cache_validity |= NFS_INO_INVALID_DATA;
+			spin_unlock(&inode->i_lock);
+		}
+	}
+	/* end_page_writeback called in rpc_release.  Should be done here. */
+}
+
+/* This is basically copied from mpage_end_io_read */
+static void bl_end_io_write(struct bio *bio, int err)
+{
+	void *data = bio->bi_private;
+	const int uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
+	struct bio_vec *bvec = bio->bi_io_vec + bio->bi_vcnt - 1;
+
+	do {
+		struct page *page = bvec->bv_page;
+
+		if (--bvec >= bio->bi_io_vec)
+			prefetchw(&bvec->bv_page->flags);
+		bl_done_with_wpage(page, uptodate);
+	} while (bvec >= bio->bi_io_vec);
+	bio_put(bio);
+	put_parallel(data);
+}
+
+/* Function scheduled for call during bl_end_par_io_write,
+ * it marks sectors as written and extends the commitlist.
  */
+static void bl_write_cleanup(struct work_struct *work)
+{
+	struct rpc_task *task;
+	struct nfs_write_data *wdata;
+	dprintk("%s enter\n", __func__);
+	task = container_of(work, struct rpc_task, u.tk_work);
+	wdata = container_of(task, struct nfs_write_data, task);
+	pnfs_callback_ops->nfs_writelist_complete(wdata);
+}
+
+/* Called when last of bios associated with a bl_write_pagelist call finishes */
+static void
+bl_end_par_io_write(void *data)
+{
+	struct nfs_write_data *wdata = data;
+
+	/* STUB - ignoring error handling */
+	wdata->task.tk_status = 0;
+	wdata->verf.committed = NFS_FILE_SYNC;
+	INIT_WORK(&wdata->task.u.tk_work, bl_write_cleanup);
+	schedule_work(&wdata->task.u.tk_work);
+}
+
 static enum pnfs_try_status
 bl_write_pagelist(struct pnfs_layout_type *lo,
 		struct page **pages,
@@ -348,8 +408,81 @@ bl_write_pagelist(struct pnfs_layout_type *lo,
 		int sync,
 		struct nfs_write_data *wdata)
 {
-	dprintk("%s enter - just using nfs\n", __func__);
-	return PNFS_NOT_ATTEMPTED;
+	int i;
+	struct bio *bio = NULL;
+	struct pnfs_block_extent *be = NULL;
+	sector_t isect, extent_length = 0;
+	struct parallel_io *par;
+	int pg_index = pgbase >> PAGE_CACHE_SHIFT;
+
+	dprintk("%s enter, %Zu@%lld\n", __func__, count, offset);
+	if (!test_bit(PG_USE_PNFS, &wdata->req->wb_flags)) {
+		dprintk("PG_USE_PNFS not set\n");
+		return PNFS_NOT_ATTEMPTED;
+	}
+	if (dont_like_caller(wdata->req)) {
+		dprintk("%s dont_like_caller failed\n", __func__);
+		return PNFS_NOT_ATTEMPTED;
+	}
+	/* At this point, wdata->pages is a (sequential) list of nfs_pages.
+	 * We want to write each, and if there is an error remove it from
+	 * list and call
+	 * nfs_retry_request(req) to have it redone using nfs.
+	 * QUEST? Do as block or per req?  Think have to do per block
+	 * as part of end_bio
+	 */
+	par = alloc_parallel(wdata);
+	if (!par)
+		return PNFS_NOT_ATTEMPTED;
+	par->call_ops = *wdata->pdata.call_ops;
+	par->call_ops.rpc_call_done = bl_rpc_do_nothing;
+	par->pnfs_callback = bl_end_par_io_write;
+	/* At this point, have to be more careful with error handling */
+
+	isect = (sector_t) ((offset & (long)PAGE_CACHE_MASK) >> 9);
+	for (i = pg_index; i < nr_pages; i++) {
+		if (!extent_length) {
+			/* We've used up the previous extent */
+			put_extent(be);
+			bio = bl_submit_bio(WRITE, bio);
+			/* Get the next one */
+			be = find_get_extent(BLK_LSEG2EXT(wdata->pdata.lseg),
+					     isect, NULL);
+			if (!be || !is_writable(be, isect)) {
+				/* FIXME */
+				bl_done_with_wpage(pages[i], 0);
+				break;
+			}
+			extent_length = be->be_length -
+				(isect - be->be_f_offset);
+		}
+		for (;;) {
+			if (!bio) {
+				bio = bio_alloc(GFP_NOIO, nr_pages - i);
+				if (!bio) {
+					/* Error out this page */
+					/* FIXME */
+					bl_done_with_wpage(pages[i], 0);
+					break;
+				}
+				bio->bi_sector = isect - be->be_f_offset +
+					be->be_v_offset;
+				bio->bi_bdev = be->be_mdev;
+				bio->bi_end_io = bl_end_io_write;
+				bio->bi_private = par;
+			}
+			if (bio_add_page(bio, pages[i], PAGE_SIZE, 0))
+				break;
+			bio = bl_submit_bio(WRITE, bio);
+		}
+		isect += PAGE_CACHE_SIZE >> 9;
+		extent_length -= PAGE_CACHE_SIZE >> 9;
+	}
+	wdata->res.count = (isect << 9) - (offset & (long)PAGE_CACHE_MASK);
+	put_extent(be);
+	bl_submit_bio(WRITE, bio);
+	put_parallel(par);
+	return PNFS_ATTEMPTED;
 }
 
 /* FIXME - range ignored */
-- 
1.7.4.1


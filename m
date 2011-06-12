Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:45761 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754708Ab1FLXpF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jun 2011 19:45:05 -0400
Message-Id: <3a429ab8cbc640af4408161e3b6020315ed40d1b.1307921138.git.rees@umich.edu>
In-Reply-To: <cover.1307921137.git.rees@umich.edu>
References: <cover.1307921137.git.rees@umich.edu>
Date: Sun, 12 Jun 2011 19:45:02 -0400
Subject: [PATCH 30/34] pnfsblock: bl_write_pagelist
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Cc: peter honeyman <honey@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Note: When upper layer's read/write request cannot be fulfilled, the block
layout driver shouldn't silently mark the page as error. It should do
what can be done and  leave the rest to the upper layer. To do so, we
should set rdata/wdata->res.count properly.

When upper layer re-send the read/write request to finish the rest
part of the request, pgbase is the position where we should start at.

[pnfsblock: bl_write_pagelist adjust for missing PG_USE_PNFS]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfsblock: handle errors when read or write pagelist.]
Signed-off-by: Zhang Jingwang <yyalone@gmail.com>
[pnfs-block: use new write_pagelist api]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |  147 +++++++++++++++++++++++++++++++++++++-
 1 files changed, 146 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 9361e5b..03ce7c3 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -320,11 +320,156 @@ bl_read_pagelist(struct nfs_read_data *rdata)
 	return PNFS_NOT_ATTEMPTED;
 }
 
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
+ */
+static void bl_write_cleanup(struct work_struct *work)
+{
+	struct rpc_task *task;
+	struct nfs_write_data *wdata;
+	dprintk("%s enter\n", __func__);
+	task = container_of(work, struct rpc_task, u.tk_work);
+	wdata = container_of(task, struct nfs_write_data, task);
+	pnfs_ld_write_done(wdata);
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
 bl_write_pagelist(struct nfs_write_data *wdata,
 		  int sync)
 {
-	return PNFS_NOT_ATTEMPTED;
+	int i;
+	struct bio *bio = NULL;
+	struct pnfs_block_extent *be = NULL;
+	sector_t isect, extent_length = 0;
+	struct parallel_io *par;
+	loff_t offset = wdata->args.offset;
+	size_t count = wdata->args.count;
+	struct page **pages = wdata->args.pages;
+	int pg_index = wdata->args.pgbase >> PAGE_CACHE_SHIFT;
+
+	dprintk("%s enter, %Zu@%lld\n", __func__, count, offset);
+	if (!wdata->lseg) {
+		dprintk("%s no lseg, falling back to MDS\n", __func__);
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
+	par->call_ops = *wdata->mds_ops;
+	par->call_ops.rpc_call_done = bl_rpc_do_nothing;
+	par->pnfs_callback = bl_end_par_io_write;
+	/* At this point, have to be more careful with error handling */
+
+	isect = (sector_t) ((offset & (long)PAGE_CACHE_MASK) >> 9);
+	for (i = pg_index; i < wdata->npages ; i++) {
+		if (!extent_length) {
+			/* We've used up the previous extent */
+			put_extent(be);
+			bio = bl_submit_bio(WRITE, bio);
+			/* Get the next one */
+			be = find_get_extent(BLK_LSEG2EXT(wdata->lseg),
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
+				bio = bio_alloc(GFP_NOIO, wdata->npages - i);
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
+	wdata->res.count = (isect << 9) - (offset);
+	if (count < wdata->res.count) {
+		wdata->res.count = count;
+	}
+	/* pnfs_set_layoutcommit needs this */
+	wdata->mds_offset = offset;
+	put_extent(be);
+	bl_submit_bio(WRITE, bio);
+	put_parallel(par);
+	return PNFS_ATTEMPTED;
 }
 
 /* FIXME - range ignored */
-- 
1.7.4.1


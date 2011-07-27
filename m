Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:34783 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754558Ab1G0SlZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 14:41:25 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH v3 21/25] pnfsblock: bl_write_pagelist
Date: Wed, 27 Jul 2011 14:40:44 -0400
Message-Id: <1311792048-12551-22-git-send-email-rees@umich.edu>
In-Reply-To: <1311792048-12551-1-git-send-email-rees@umich.edu>
References: <1311792048-12551-1-git-send-email-rees@umich.edu>
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

[pnfsblock: bl_write_pagelist support functions]
[pnfsblock: bl_write_pagelist adjust for missing PG_USE_PNFS]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfsblock: handle errors when read or write pagelist.]
Signed-off-by: Zhang Jingwang <yyalone@gmail.com>
[pnfs-block: use new write_pagelist api]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>

[SQUASHME: pnfsblock: mds_offset is set in the generic layer]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>

[pnfsblock: mark IO error with NFS_LAYOUT_{RW|RO}_FAILED]
Signed-off-by: Peng Tao <peng_tao@emc.com>
[pnfsblock: SQUASHME: adjust to API change]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfsblock: fixup blksize alignment in bl_setup_layoutcommit]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
[pnfsblock: bl_write_pagelist adjust for missing PG_USE_PNFS]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfsblock: handle errors when read or write pagelist.]
Signed-off-by: Zhang Jingwang <yyalone@gmail.com>
[pnfs-block: use new write_pagelist api]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfs/blocklayout/blocklayout.c |  137 +++++++++++++++++++++++++++++++++++++-
 1 files changed, 134 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 6e90371..963b3ea 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -74,6 +74,19 @@ static int is_hole(struct pnfs_block_extent *be, sector_t isect)
 		return !is_sector_initialized(be->be_inval, isect);
 }
 
+/* Given the be associated with isect, determine if page data can be
+ * written to disk.
+ */
+static int is_writable(struct pnfs_block_extent *be, sector_t isect)
+{
+	if (be->be_state == PNFS_BLOCK_READWRITE_DATA)
+		return 1;
+	else if (be->be_state != PNFS_BLOCK_INVALID_DATA)
+		return 0;
+	else
+		return is_sector_initialized(be->be_inval, isect);
+}
+
 static int
 dont_like_caller(struct nfs_page *req)
 {
@@ -333,11 +346,129 @@ out:
 	return PNFS_NOT_ATTEMPTED;
 }
 
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
-bl_write_pagelist(struct nfs_write_data *wdata,
-		  int sync)
+bl_write_pagelist(struct nfs_write_data *wdata, int sync)
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
+	isect = (sector_t) ((offset & (long)PAGE_CACHE_MASK) >> SECTOR_SHIFT);
+	for (i = pg_index; i < wdata->npages ; i++) {
+		if (!extent_length) {
+			/* We've used up the previous extent */
+			bl_put_extent(be);
+			bio = bl_submit_bio(WRITE, bio);
+			/* Get the next one */
+			be = bl_find_get_extent(BLK_LSEG2EXT(wdata->lseg),
+					     isect, NULL);
+			if (!be || !is_writable(be, isect)) {
+				wdata->pnfs_error = -ENOMEM;
+				goto out;
+			}
+			extent_length = be->be_length -
+				(isect - be->be_f_offset);
+		}
+		for (;;) {
+			if (!bio) {
+				bio = bio_alloc(GFP_NOIO, wdata->npages - i);
+				if (!bio) {
+					wdata->pnfs_error = -ENOMEM;
+					goto out;
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
+		isect += PAGE_CACHE_SECTORS;
+		extent_length -= PAGE_CACHE_SECTORS;
+	}
+	wdata->res.count = (isect << SECTOR_SHIFT) - (offset);
+	if (count < wdata->res.count)
+		wdata->res.count = count;
+out:
+	bl_put_extent(be);
+	bl_submit_bio(WRITE, bio);
+	put_parallel(par);
+	return PNFS_ATTEMPTED;
 }
 
 /* FIXME - range ignored */
-- 
1.7.4.1


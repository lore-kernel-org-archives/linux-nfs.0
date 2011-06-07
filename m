Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:53675 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755722Ab1FGR3S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:29:18 -0400
Date: Tue, 7 Jun 2011 13:29:16 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 29/88] pnfsblock: write_begin
Message-ID: <9f0047679d383a01f328c19d56ea5967f39b7ae6.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Implements bl_write_begin and bl_do_flush, allowing block driver to read
in page "around" the data that is about to be copied to the page.

[pnfsblock: fix 64-bit compiler warnings for write_begin]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |  196 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 196 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 99de9e3..b3ad99d 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -32,6 +32,7 @@
 #include <linux/module.h>
 #include <linux/init.h>
 
+#include <linux/buffer_head.h> /* various write calls */
 #include <linux/bio.h> /* struct bio */
 #include <linux/vmalloc.h>
 #include "blocklayout.h"
@@ -637,6 +638,186 @@ bl_uninitialize_mountpoint(struct pnfs_mount_type *mtype)
 	return 0;
 }
 
+/* STUB - mark intersection of layout and page as bad, so is not
+ * used again.
+ */
+static void mark_bad_read(void)
+{
+	return;
+}
+
+/* Copied from buffer.c */
+static void __end_buffer_read_notouch(struct buffer_head *bh, int uptodate)
+{
+	if (uptodate) {
+		set_buffer_uptodate(bh);
+	} else {
+		/* This happens, due to failed READA attempts. */
+		clear_buffer_uptodate(bh);
+	}
+	unlock_buffer(bh);
+}
+
+/* Copied from buffer.c */
+static void end_buffer_read_nobh(struct buffer_head *bh, int uptodate)
+{
+	__end_buffer_read_notouch(bh, uptodate);
+}
+
+/*
+ * map_block:  map a requested I/0 block (isect) into an offset in the LVM
+ * meta block_device
+ */
+static void
+map_block(sector_t isect, struct pnfs_block_extent *be, struct buffer_head *bh)
+{
+	dprintk("%s enter be=%p\n", __func__, be);
+
+	set_buffer_mapped(bh);
+	bh->b_bdev = be->be_mdev;
+	bh->b_blocknr = (isect - be->be_f_offset + be->be_v_offset) >>
+		(be->be_mdev->bd_inode->i_blkbits - 9);
+
+	dprintk("%s isect %ld, bh->b_blocknr %ld, using bsize %Zd\n",
+				__func__, (long)isect,
+				(long)bh->b_blocknr,
+				bh->b_size);
+	return;
+}
+
+/* Given an unmapped page, zero it (or read in page for COW),
+ * and set appropriate flags/markings, but it is safe to not initialize
+ * the range given in [from, to).
+ */
+/* This is loosely based on nobh_write_begin */
+static int
+init_page_for_write(struct pnfs_block_layout *bl, struct page *page,
+		    unsigned from, unsigned to, sector_t **pages_to_mark)
+{
+	struct buffer_head *bh;
+	int inval, ret = -EIO;
+	struct pnfs_block_extent *be = NULL, *cow_read = NULL;
+	sector_t isect;
+
+	dprintk("%s enter, %p\n", __func__, page);
+	bh = alloc_page_buffers(page, PAGE_CACHE_SIZE, 0);
+	if (!bh) {
+		ret = -ENOMEM;
+		goto cleanup;
+	}
+
+	isect = (sector_t)page->index << (PAGE_CACHE_SHIFT - 9);
+	be = find_get_extent(bl, isect, &cow_read);
+	if (!be)
+		goto cleanup;
+	inval = is_hole(be, isect);
+	dprintk("%s inval=%i, from=%u, to=%u\n", __func__, inval, from, to);
+	if (inval) {
+		if (be->be_state == PNFS_BLOCK_NONE_DATA) {
+			dprintk("%s PANIC - got NONE_DATA extent %p\n",
+				__func__, be);
+			goto cleanup;
+		}
+		map_block(isect, be, bh);
+		unmap_underlying_metadata(bh->b_bdev, bh->b_blocknr);
+	}
+	if (PageUptodate(page)) {
+		/* Do nothing */
+	} else if (inval & !cow_read) {
+		zero_user_segments(page, 0, from, to, PAGE_CACHE_SIZE);
+	} else if (0 < from || PAGE_CACHE_SIZE > to) {
+		struct pnfs_block_extent *read_extent;
+
+		read_extent = (inval && cow_read) ? cow_read : be;
+		map_block(isect, read_extent, bh);
+		lock_buffer(bh);
+		bh->b_end_io = end_buffer_read_nobh;
+		submit_bh(READ, bh);
+		dprintk("%s: Waiting for buffer read\n", __func__);
+		/* XXX Don't really want to hold layout lock here */
+		wait_on_buffer(bh);
+		if (!buffer_uptodate(bh))
+			goto cleanup;
+	}
+	if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
+		/* There is a BUG here if is a short copy after write_begin,
+		 * but I think this is a generic fs bug.  The problem is that
+		 * we have marked the page as initialized, but it is possible
+		 * that the section not copied may never get copied.
+		 */
+		ret = mark_initialized_sectors(be->be_inval, isect,
+					       PAGE_CACHE_SECTORS,
+					       pages_to_mark);
+		/* Want to preallocate mem so above can't fail */
+		if (ret)
+			goto cleanup;
+	}
+	SetPageMappedToDisk(page);
+	ret = 0;
+
+cleanup:
+	free_buffer_head(bh);
+	put_extent(be);
+	put_extent(cow_read);
+	if (ret) {
+		/* Need to mark layout with bad read...should now
+		 * just use nfs4 for reads and writes.
+		 */
+		mark_bad_read();
+	}
+	return ret;
+}
+
+static int
+bl_write_begin(struct pnfs_layout_segment *lseg, struct page *page, loff_t pos,
+	       unsigned count, struct pnfs_fsdata *fsdata)
+{
+	unsigned from, to;
+	int ret;
+	sector_t *pages_to_mark = NULL;
+	struct pnfs_block_layout *bl = BLK_LSEG2EXT(lseg);
+
+	dprintk("%s enter, %u@%lld\n", __func__, count, pos);
+	print_page(page);
+	/* The following code assumes blocksize >= PAGE_CACHE_SIZE */
+	if (bl->bl_blocksize < (PAGE_CACHE_SIZE >> 9)) {
+		dprintk("%s Can't handle blocksize %llu\n", __func__,
+			(u64)bl->bl_blocksize);
+		fsdata->ok_to_use_pnfs = 0;
+		return 0;
+	}
+	fsdata->ok_to_use_pnfs = 1;
+	if (PageMappedToDisk(page)) {
+		/* Basically, this is a flag that says we have
+		 * successfully called write_begin already on this page.
+		 */
+		/* NOTE - there are cache consistency issues here.
+		 * For example, what if the layout is recalled, then regained?
+		 * If the file is closed and reopened, will the page flags
+		 * be reset?  If not, we'll have to use layout info instead of
+		 * the page flag.
+		 */
+		return 0;
+	}
+	from = pos & (PAGE_CACHE_SIZE - 1);
+	to = from + count;
+	ret = init_page_for_write(bl, page, from, to, &pages_to_mark);
+	if (ret) {
+		dprintk("%s init page failed with %i", __func__, ret);
+		/* Revert back to plain NFS and just continue on with
+		 * write.  This assumes there is no request attached, which
+		 * should be true if we get here.
+		 */
+		BUG_ON(PagePrivate(page));
+		fsdata->ok_to_use_pnfs = 0;
+		kfree(pages_to_mark);
+		ret = 0;
+	} else {
+		fsdata->private = pages_to_mark;
+	}
+	return ret;
+}
+
 static ssize_t
 bl_get_stripesize(struct pnfs_layout_type *lo)
 {
@@ -663,10 +844,24 @@ bl_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	return 1;
 }
 
+/* This checks if old req will likely use same io method as soon
+ * to be created request, and returns False if they are the same.
+ */
+static int
+bl_do_flush(struct pnfs_layout_segment *lseg, struct nfs_page *req,
+	    struct pnfs_fsdata *fsdata)
+{
+	int will_try_pnfs;
+	dprintk("%s enter\n", __func__);
+	will_try_pnfs = fsdata ? (fsdata->ok_to_use_pnfs) : (lseg != NULL);
+	return will_try_pnfs != test_bit(PG_USE_PNFS, &req->wb_flags);
+}
+
 static struct layoutdriver_io_operations blocklayout_io_operations = {
 	.commit				= bl_commit,
 	.read_pagelist			= bl_read_pagelist,
 	.write_pagelist			= bl_write_pagelist,
+	.write_begin			= bl_write_begin,
 	.alloc_layout			= bl_alloc_layout,
 	.free_layout			= bl_free_layout,
 	.alloc_lseg			= bl_alloc_lseg,
@@ -683,6 +878,7 @@ static struct layoutdriver_policy_operations blocklayout_policy_operations = {
 	.get_read_threshold		= bl_get_io_threshold,
 	.get_write_threshold		= bl_get_io_threshold,
 	.pg_test			= bl_pg_test,
+	.do_flush			= bl_do_flush,
 };
 
 static struct pnfs_layoutdriver_type blocklayout_type = {
-- 
1.7.4.1


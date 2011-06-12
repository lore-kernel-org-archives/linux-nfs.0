Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:60829 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754698Ab1FLXox (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jun 2011 19:44:53 -0400
Message-Id: <8343b9a2ee015cf4c8119e5d7d008bfad25762bb.1307921138.git.rees@umich.edu>
In-Reply-To: <cover.1307921137.git.rees@umich.edu>
References: <cover.1307921137.git.rees@umich.edu>
Date: Sun, 12 Jun 2011 19:44:50 -0400
Subject: [PATCH 25/34] pnfsblock: bl_read_pagelist
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

[pnfsblock: read path error handling]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfsblock: handle errors when read or write pagelist.]
Signed-off-by: Zhang Jingwang <yyalone@gmail.com>
[pnfs-block: use new read_pagelist api]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |  259 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 259 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 2cc5be7..63fddca 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -31,6 +31,7 @@
  */
 #include <linux/module.h>
 #include <linux/init.h>
+#include <linux/bio.h> /* struct bio */
 #include <linux/vmalloc.h>
 #include "blocklayout.h"
 
@@ -40,9 +41,267 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Andy Adamson <andros@citi.umich.edu>");
 MODULE_DESCRIPTION("The NFSv4.1 pNFS Block layout driver");
 
+static void print_page(struct page *page)
+{
+	dprintk("PRINTPAGE page %p\n", page);
+	dprintk("        PagePrivate %d\n", PagePrivate(page));
+	dprintk("        PageUptodate %d\n", PageUptodate(page));
+	dprintk("        PageError %d\n", PageError(page));
+	dprintk("        PageDirty %d\n", PageDirty(page));
+	dprintk("        PageReferenced %d\n", PageReferenced(page));
+	dprintk("        PageLocked %d\n", PageLocked(page));
+	dprintk("        PageWriteback %d\n", PageWriteback(page));
+	dprintk("        PageMappedToDisk %d\n", PageMappedToDisk(page));
+	dprintk("\n");
+}
+
+/* Given the be associated with isect, determine if page data needs to be
+ * initialized.
+ */
+static int is_hole(struct pnfs_block_extent *be, sector_t isect)
+{
+	if (be->be_state == PNFS_BLOCK_NONE_DATA)
+		return 1;
+	else if (be->be_state != PNFS_BLOCK_INVALID_DATA)
+		return 0;
+	else
+		return !is_sector_initialized(be->be_inval, isect);
+}
+
+static int
+dont_like_caller(struct nfs_page *req)
+{
+	if (atomic_read(&req->wb_complete)) {
+		/* Called by _multi */
+		return 1;
+	} else {
+		/* Called by _one */
+		return 0;
+	}
+}
+
+/* The data we are handed might be spread across several bios.  We need
+ * to track when the last one is finished.
+ */
+struct parallel_io {
+	struct kref refcnt;
+	struct rpc_call_ops call_ops;
+	void (*pnfs_callback) (void *data);
+	void *data;
+};
+
+static inline struct parallel_io *alloc_parallel(void *data)
+{
+	struct parallel_io *rv;
+
+	rv  = kmalloc(sizeof(*rv), GFP_KERNEL);
+	if (rv) {
+		rv->data = data;
+		kref_init(&rv->refcnt);
+	}
+	return rv;
+}
+
+static inline void get_parallel(struct parallel_io *p)
+{
+	kref_get(&p->refcnt);
+}
+
+static void destroy_parallel(struct kref *kref)
+{
+	struct parallel_io *p = container_of(kref, struct parallel_io, refcnt);
+
+	dprintk("%s enter\n", __func__);
+	p->pnfs_callback(p->data);
+	kfree(p);
+}
+
+static inline void put_parallel(struct parallel_io *p)
+{
+	kref_put(&p->refcnt, destroy_parallel);
+}
+
+static struct bio *
+bl_submit_bio(int rw, struct bio *bio)
+{
+	if (bio) {
+		get_parallel(bio->bi_private);
+		dprintk("%s submitting %s bio %u@%llu\n", __func__,
+			rw == READ ? "read" : "write",
+			bio->bi_size, (u64)bio->bi_sector);
+		submit_bio(rw, bio);
+	}
+	return NULL;
+}
+
+static inline void
+bl_done_with_rpage(struct page *page, const int ok)
+{
+	if (ok) {
+		ClearPagePnfsErr(page);
+		SetPageUptodate(page);
+	} else {
+		ClearPageUptodate(page);
+		SetPageError(page);
+		SetPagePnfsErr(page);
+	}
+	/* Page is unlocked via rpc_release.  Should really be done here. */
+}
+
+/* This is basically copied from mpage_end_io_read */
+static void bl_end_io_read(struct bio *bio, int err)
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
+		bl_done_with_rpage(page, uptodate);
+	} while (bvec >= bio->bi_io_vec);
+	bio_put(bio);
+	put_parallel(data);
+}
+
+static void bl_read_cleanup(struct work_struct *work)
+{
+	struct rpc_task *task;
+	struct nfs_read_data *rdata;
+	dprintk("%s enter\n", __func__);
+	task = container_of(work, struct rpc_task, u.tk_work);
+	rdata = container_of(task, struct nfs_read_data, task);
+	pnfs_ld_read_done(rdata);
+}
+
+static void
+bl_end_par_io_read(void *data)
+{
+	struct nfs_read_data *rdata = data;
+
+	INIT_WORK(&rdata->task.u.tk_work, bl_read_cleanup);
+	schedule_work(&rdata->task.u.tk_work);
+}
+
+/* We don't want normal .rpc_call_done callback used, so we replace it
+ * with this stub.
+ */
+static void bl_rpc_do_nothing(struct rpc_task *task, void *calldata)
+{
+	return;
+}
+
 static enum pnfs_try_status
 bl_read_pagelist(struct nfs_read_data *rdata)
 {
+	int i, hole;
+	struct bio *bio = NULL;
+	struct pnfs_block_extent *be = NULL, *cow_read = NULL;
+	sector_t isect, extent_length = 0;
+	struct parallel_io *par;
+	loff_t f_offset = rdata->args.offset;
+	size_t count = rdata->args.count;
+	struct page **pages = rdata->args.pages;
+	int pg_index = rdata->args.pgbase >> PAGE_CACHE_SHIFT;
+
+	dprintk("%s enter nr_pages %u offset %lld count %Zd\n", __func__,
+	       rdata->npages, f_offset, count);
+
+	if (dont_like_caller(rdata->req)) {
+		dprintk("%s dont_like_caller failed\n", __func__);
+		goto use_mds;
+	}
+	if ((rdata->npages == 1) && PagePnfsErr(rdata->req->wb_page)) {
+		/* We want to fall back to mds in case of read_page
+		 * after error on read_pages.
+		 */
+		dprintk("%s PG_pnfserr set\n", __func__);
+		goto use_mds;
+	}
+	par = alloc_parallel(rdata);
+	if (!par)
+		goto use_mds;
+	par->call_ops = *rdata->mds_ops;
+	par->call_ops.rpc_call_done = bl_rpc_do_nothing;
+	par->pnfs_callback = bl_end_par_io_read;
+	/* At this point, we can no longer jump to use_mds */
+
+	isect = (sector_t) (f_offset >> 9);
+	/* Code assumes extents are page-aligned */
+	for (i = pg_index; i < rdata->npages; i++) {
+		if (!extent_length) {
+			/* We've used up the previous extent */
+			put_extent(be);
+			put_extent(cow_read);
+			bio = bl_submit_bio(READ, bio);
+			/* Get the next one */
+			be = find_get_extent(BLK_LSEG2EXT(rdata->lseg),
+					     isect, &cow_read);
+			if (!be) {
+				/* Error out this page */
+				bl_done_with_rpage(pages[i], 0);
+				break;
+			}
+			extent_length = be->be_length -
+				(isect - be->be_f_offset);
+			if (cow_read) {
+				sector_t cow_length = cow_read->be_length -
+					(isect - cow_read->be_f_offset);
+				extent_length = min(extent_length, cow_length);
+			}
+		}
+		hole = is_hole(be, isect);
+		if (hole && !cow_read) {
+			bio = bl_submit_bio(READ, bio);
+			/* Fill hole w/ zeroes w/o accessing device */
+			dprintk("%s Zeroing page for hole\n", __func__);
+			zero_user(pages[i], 0,
+				  min_t(int, PAGE_CACHE_SIZE, count));
+			print_page(pages[i]);
+			bl_done_with_rpage(pages[i], 1);
+		} else {
+			struct pnfs_block_extent *be_read;
+
+			be_read = (hole && cow_read) ? cow_read : be;
+			for (;;) {
+				if (!bio) {
+					bio = bio_alloc(GFP_NOIO, rdata->npages - i);
+					if (!bio) {
+						/* Error out this page */
+						bl_done_with_rpage(pages[i], 0);
+						break;
+					}
+					bio->bi_sector = isect -
+						be_read->be_f_offset +
+						be_read->be_v_offset;
+					bio->bi_bdev = be_read->be_mdev;
+					bio->bi_end_io = bl_end_io_read;
+					bio->bi_private = par;
+				}
+				if (bio_add_page(bio, pages[i], PAGE_SIZE, 0))
+					break;
+				bio = bl_submit_bio(READ, bio);
+			}
+		}
+		isect += PAGE_CACHE_SIZE >> 9;
+		extent_length -= PAGE_CACHE_SIZE >> 9;
+	}
+	if ((isect << 9) >= rdata->inode->i_size) {
+		rdata->res.eof = 1;
+		rdata->res.count = rdata->inode->i_size - f_offset;
+	} else {
+		rdata->res.count = (isect << 9) - f_offset;
+	}
+	put_extent(be);
+	put_extent(cow_read);
+	bl_submit_bio(READ, bio);
+	put_parallel(par);
+	return PNFS_ATTEMPTED;
+
+ use_mds:
+	dprintk("Giving up and using normal NFS\n");
 	return PNFS_NOT_ATTEMPTED;
 }
 
-- 
1.7.4.1


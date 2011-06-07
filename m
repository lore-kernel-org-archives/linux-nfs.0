Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:53542 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755760Ab1FGR2z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:28:55 -0400
Date: Tue, 7 Jun 2011 13:28:53 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 25/88] pnfsblock: bl_read_pagelist
Message-ID: <af090774e030f83bbf50ced8dc3051caba1d9833.1307464382.git.rees@umich.edu>
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
 fs/nfs/blocklayout/blocklayout.c |  252 +++++++++++++++++++++++++++++++++++++-
 fs/nfs/blocklayout/blocklayout.h |    1 +
 fs/nfs/blocklayout/extents.c     |    6 +
 3 files changed, 256 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index f54e9a9..22ea965 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -32,6 +32,7 @@
 #include <linux/module.h>
 #include <linux/init.h>
 
+#include <linux/bio.h> /* struct bio */
 #include <linux/vmalloc.h>
 #include "blocklayout.h"
 
@@ -44,6 +45,45 @@ MODULE_DESCRIPTION("The NFSv4.1 pNFS Block layout driver");
 /* Callback operations to the pNFS client */
 struct pnfs_client_operations *pnfs_callback_ops;
 
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
 static enum pnfs_try_status
 bl_commit(struct pnfs_layout_type *lo,
 		int sync,
@@ -53,16 +93,222 @@ bl_commit(struct pnfs_layout_type *lo,
 	return PNFS_NOT_ATTEMPTED;
 }
 
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
+		SetPageUptodate(page);
+	} else {
+		ClearPageUptodate(page);
+		SetPageError(page);
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
+	pnfs_callback_ops->nfs_readlist_complete(rdata);
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
 bl_read_pagelist(struct pnfs_layout_type *lo,
 		struct page **pages,
 		unsigned int pgbase,
 		unsigned nr_pages,
-		loff_t offset,
+		loff_t f_offset,
 		size_t count,
-		struct nfs_read_data *nfs_data)
+		struct nfs_read_data *rdata)
 {
-	dprintk("%s enter\n", __func__);
+	int i, hole;
+	struct bio *bio = NULL;
+	struct pnfs_block_extent *be = NULL, *cow_read = NULL;
+	sector_t isect, extent_length = 0;
+	struct parallel_io *par;
+	int pg_index = pgbase >> PAGE_CACHE_SHIFT;
+
+	dprintk("%s enter nr_pages %u offset %lld count %Zd\n", __func__,
+	       nr_pages, f_offset, count);
+
+	if (dont_like_caller(rdata->req)) {
+		dprintk("%s dont_like_caller failed\n", __func__);
+		goto use_mds;
+	}
+	par = alloc_parallel(rdata);
+	if (!par)
+		goto use_mds;
+	par->call_ops = *rdata->pdata.call_ops;
+	par->call_ops.rpc_call_done = bl_rpc_do_nothing;
+	par->pnfs_callback = bl_end_par_io_read;
+	/* At this point, we can no longer jump to use_mds */
+
+	isect = (sector_t) (f_offset >> 9);
+	/* Code assumes extents are page-aligned */
+	for (i = pg_index; i < nr_pages; i++) {
+		if (!extent_length) {
+			/* We've used up the previous extent */
+			put_extent(be);
+			put_extent(cow_read);
+			bio = bl_submit_bio(READ, bio);
+			/* Get the next one */
+			be = find_get_extent(BLK_LSEG2EXT(rdata->pdata.lseg),
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
+					bio = bio_alloc(GFP_NOIO, nr_pages - i);
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
 
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index e992b94..8b06c93 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -208,6 +208,7 @@ find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
 		struct pnfs_block_extent **cow_read);
 void put_extent(struct pnfs_block_extent *be);
 struct pnfs_block_extent *alloc_extent(void);
+int is_sector_initialized(struct pnfs_inval_markings *marks, sector_t isect);
 int add_and_merge_extent(struct pnfs_block_layout *bl,
 			 struct pnfs_block_extent *new);
 #endif /* FS_NFS_NFS4BLOCKLAYOUT_H */
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index 944f824..31fe359 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -33,6 +33,12 @@
 #include "blocklayout.h"
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
 
+int is_sector_initialized(struct pnfs_inval_markings *marks, sector_t isect)
+{
+       /* STUB */
+       return 0;
+}
+
 static void print_bl_extent(struct pnfs_block_extent *be)
 {
 	dprintk("PRINT EXTENT extent %p\n", be);
-- 
1.7.4.1


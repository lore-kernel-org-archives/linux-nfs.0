From: Jim Rees <rees@umich.edu>
Subject: [PATCH v1 20/25] pnfsblock: bl_read_pagelist
Date: Sun, 17 Jul 2011 19:59:07 -0400
Message-ID: <1310947152-12255-21-git-send-email-rees@umich.edu>
References: <1310947152-12255-1-git-send-email-rees@umich.edu>
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:37633 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756418Ab1GQX7r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 17 Jul 2011 19:59:47 -0400
In-Reply-To: <1310947152-12255-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <iisaman@citi.umich.edu>

Note: When upper layer's read/write request cannot be fulfilled, the block
layout driver shouldn't silently mark the page as error. It should do
what can be done and  leave the rest to the upper layer. To do so, we
should set rdata/wdata->res.count properly.

When upper layer re-send the read/write request to finish the rest
part of the request, pgbase is the position where we should start at.

[pnfsblock: mark IO error with NFS_LAYOUT_{RW|RO}_FAILED]
Signed-off-by: Peng Tao <peng_tao@emc.com>
[pnfsblock: read path error handling]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfsblock: handle errors when read or write pagelist.]
Signed-off-by: Zhang Jingwang <yyalone@gmail.com>
[pnfs-block: use new read_pagelist api]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <benny@tonian.com>
---
 fs/nfs/blocklayout/blocklayout.c |  282 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 282 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index ca22903..282ef50 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -29,10 +29,12 @@
  * of the software, even if it has been or is hereafter advised of the
  * possibility of such damages.
  */
+
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/mount.h>
 #include <linux/namei.h>
+#include <linux/bio.h>		/* struct bio */
 #include <linux/vmalloc.h>
 
 #include "blocklayout.h"
@@ -46,9 +48,289 @@ MODULE_DESCRIPTION("The NFSv4.1 pNFS Block layout driver");
 struct dentry *bl_device_pipe;
 wait_queue_head_t bl_wq;
 
+static void print_page(struct page *page)
+{
+	dprintk("PRINTPAGE page %p\n", page);
+	dprintk("	PagePrivate %d\n", PagePrivate(page));
+	dprintk("	PageUptodate %d\n", PageUptodate(page));
+	dprintk("	PageError %d\n", PageError(page));
+	dprintk("	PageDirty %d\n", PageDirty(page));
+	dprintk("	PageReferenced %d\n", PageReferenced(page));
+	dprintk("	PageLocked %d\n", PageLocked(page));
+	dprintk("	PageWriteback %d\n", PageWriteback(page));
+	dprintk("	PageMappedToDisk %d\n", PageMappedToDisk(page));
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
+	rv  = kmalloc(sizeof(*rv), GFP_NOFS);
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
+			bio->bi_size, (unsigned long long)bio->bi_sector);
+		submit_bio(rw, bio);
+	}
+	return NULL;
+}
+
+static struct bio *bl_alloc_init_bio(int npg, sector_t isect,
+				     struct pnfs_block_extent *be,
+				     void (*end_io)(struct bio *, int err),
+				     struct parallel_io *par)
+{
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
+	} else {
+		dprintk("%s Setting layout IOMODE_READ fail bit\n", __func__);
+		set_bit(lo_fail_bit(IOMODE_READ), &lseg->pls_layout->plh_flags);
+	}
+}
+
+/* This is basically copied from mpage_end_io_read */
+static void bl_end_io_read(struct bio *bio, int err)
+{
+	struct parallel_io *par = bio->bi_private;
+	const int uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
+	struct bio_vec *bvec = bio->bi_io_vec + bio->bi_vcnt - 1;
+	struct nfs_read_data *rdata = (struct nfs_read_data *)par->data;
+
+	do {
+		struct page *page = bvec->bv_page;
+
+		if (--bvec >= bio->bi_io_vec)
+			prefetchw(&bvec->bv_page->flags);
+		if (uptodate)
+			SetPageUptodate(page);
+	} while (bvec >= bio->bi_io_vec);
+	if (!uptodate) {
+		if (!rdata->pnfs_error)
+			rdata->pnfs_error = -EIO;
+		bl_set_lo_fail(rdata->lseg);
+	}
+	bio_put(bio);
+	put_parallel(par);
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
+
+	par = alloc_parallel(rdata);
+	if (!par)
+		goto use_mds;
+	par->call_ops = *rdata->mds_ops;
+	par->call_ops.rpc_call_done = bl_rpc_do_nothing;
+	par->pnfs_callback = bl_end_par_io_read;
+	/* At this point, we can no longer jump to use_mds */
+
+	isect = (sector_t) (f_offset >> SECTOR_SHIFT);
+	/* Code assumes extents are page-aligned */
+	for (i = pg_index; i < rdata->npages; i++) {
+		if (!extent_length) {
+			/* We've used up the previous extent */
+			bl_put_extent(be);
+			bl_put_extent(cow_read);
+			bio = bl_submit_bio(READ, bio);
+			/* Get the next one */
+			be = bl_find_get_extent(BLK_LSEG2EXT(rdata->lseg),
+					     isect, &cow_read);
+			if (!be) {
+				rdata->pnfs_error = -EIO;
+				goto out;
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
+			zero_user_segment(pages[i], 0, PAGE_CACHE_SIZE);
+			print_page(pages[i]);
+			SetPageUptodate(pages[i]);
+		} else {
+			struct pnfs_block_extent *be_read;
+
+			be_read = (hole && cow_read) ? cow_read : be;
+			bio = bl_add_page_to_bio(bio, rdata->npages - i, READ,
+						 isect, pages[i], be_read,
+						 bl_end_io_read, par);
+			if (IS_ERR(bio)) {
+				rdata->pnfs_error = PTR_ERR(bio);
+				goto out;
+			}
+		}
+		isect += PAGE_CACHE_SECTORS;
+		extent_length -= PAGE_CACHE_SECTORS;
+	}
+	if ((isect << SECTOR_SHIFT) >= rdata->inode->i_size) {
+		rdata->res.eof = 1;
+		rdata->res.count = rdata->inode->i_size - f_offset;
+	} else {
+		rdata->res.count = (isect << SECTOR_SHIFT) - f_offset;
+	}
+out:
+	bl_put_extent(be);
+	bl_put_extent(cow_read);
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


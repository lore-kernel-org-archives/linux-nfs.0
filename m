Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:52257 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755594Ab1JDKhB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Oct 2011 06:37:01 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>, Brent Welch <welch@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 18/19] pnfs-obj: move to ore 02: move to ORE
Date: Tue, 4 Oct 2011 12:36:50 +0200
Message-ID: <1317724610-27857-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4E8ADEDA.4050709@panasas.com>
References: <4E8ADEDA.4050709@panasas.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

In this patch we are actually moving to the ORE.
(Object Raid Engine).

objio_state holds a pointer to an ore_io_state. Once
we have an ore_io_state at hand we can call the ore
for reading/writting. We register on the done path
to kick off the nfs io_done mechanism.

Again for Ease of reviewing the old code is "#if 0"
but is not removed so the diff command works better.
The old code will be removed in the next patch.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |  133 +++++++++++++++++++-----------------------
 1 files changed, 59 insertions(+), 74 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index bd7ec26..00b3849 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -44,12 +44,6 @@
 
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
 
-#define _LLU(x) ((unsigned long long)x)
-
-enum { BIO_MAX_PAGES_KMALLOC =
-		(PAGE_SIZE - sizeof(struct bio)) / sizeof(struct bio_vec),
-};
-
 struct objio_dev_ent {
 	struct nfs4_deviceid_node id_node;
 	struct ore_dev od;
@@ -124,37 +118,13 @@ OBJIO_LSEG(struct pnfs_layout_segment *lseg)
 	return container_of(lseg, struct objio_segment, lseg);
 }
 
-struct objio_state;
-typedef int (*objio_done_fn)(struct objio_state *ios);
-
 struct objio_state {
 	/* Generic layer */
 	struct objlayout_io_res oir;
 
-	struct page **pages;
-	unsigned pgbase;
-	unsigned nr_pages;
-	unsigned long count;
-	loff_t offset;
 	bool sync;
-
-	struct ore_layout *layout;
-	struct ore_components *oc;
-
-	struct kref kref;
-	objio_done_fn done;
-	void *private;
-
-	unsigned long length;
-	unsigned numdevs; /* Actually used devs in this IO */
-	/* A per-device variable array of size numdevs */
-	struct _objio_per_comp {
-		struct bio *bio;
-		struct osd_request *or;
-		unsigned long length;
-		u64 offset;
-		unsigned dev;
-	} per_dev[];
+	/*FIXME: Support for extra_bytes at ore_get_rw_state() */
+	struct ore_io_state *ios;
 };
 
 /* Send and wait for a get_device_info of devices in the layout,
@@ -374,16 +344,16 @@ void objio_free_lseg(struct pnfs_layout_segment *lseg)
 }
 
 static int
-objio_alloc_io_state(struct pnfs_layout_hdr *pnfs_layout_type,
+objio_alloc_io_state(struct pnfs_layout_hdr *pnfs_layout_type, bool is_reading,
 	struct pnfs_layout_segment *lseg, struct page **pages, unsigned pgbase,
 	loff_t offset, size_t count, void *rpcdata, gfp_t gfp_flags,
 	struct objio_state **outp)
 {
 	struct objio_segment *objio_seg = OBJIO_LSEG(lseg);
-	struct objio_state *ios;
+	struct ore_io_state *ios;
+	int ret;
 	struct __alloc_objio_state {
 		struct objio_state objios;
-		struct _objio_per_comp per_dev[objio_seg->oc.numdevs];
 		struct pnfs_osd_ioerr ioerrs[objio_seg->oc.numdevs];
 	} *aos;
 
@@ -391,30 +361,33 @@ objio_alloc_io_state(struct pnfs_layout_hdr *pnfs_layout_type,
 	if (unlikely(!aos))
 		return -ENOMEM;
 
-	ios = &aos->objios;
-
-	ios->layout = &objio_seg->layout;
-	ios->oc = &objio_seg->oc;
 	objlayout_init_ioerrs(&aos->objios.oir, objio_seg->oc.numdevs,
 			aos->ioerrs, rpcdata, pnfs_layout_type);
 
+	ret = ore_get_rw_state(&objio_seg->layout, &objio_seg->oc, is_reading,
+			       offset, count, &ios);
+	if (unlikely(ret)) {
+		kfree(aos);
+		return ret;
+	}
+
 	ios->pages = pages;
 	ios->pgbase = pgbase;
-	ios->nr_pages = (pgbase + count + PAGE_SIZE - 1) >> PAGE_SHIFT;
-	ios->offset = offset;
-	ios->count = count;
-	ios->sync = 0;
+	ios->private = aos;
 	BUG_ON(ios->nr_pages > (pgbase + count + PAGE_SIZE - 1) >> PAGE_SHIFT);
 
-	*outp = ios;
+	aos->objios.sync = 0;
+	aos->objios.ios = ios;
+	*outp = &aos->objios;
 	return 0;
 }
 
 void objio_free_result(struct objlayout_io_res *oir)
 {
-	struct objio_state *ios = container_of(oir, struct objio_state, oir);
+	struct objio_state *objios = container_of(oir, struct objio_state, oir);
 
-	kfree(ios);
+	ore_put_io_state(objios->ios);
+	kfree(objios);
 }
 
 enum pnfs_osd_errno osd_pri_2_pnfs_err(enum osd_err_priority oep)
@@ -447,7 +420,7 @@ enum pnfs_osd_errno osd_pri_2_pnfs_err(enum osd_err_priority oep)
 	}
 }
 
-static void __on_dev_error(struct objio_state *ios, bool is_write,
+static void __on_dev_error(struct ore_io_state *ios,
 	struct ore_dev *od, unsigned dev_index, enum osd_err_priority oep,
 	u64 dev_offset, u64  dev_len)
 {
@@ -465,9 +438,10 @@ static void __on_dev_error(struct objio_state *ios, bool is_write,
 
 	objlayout_io_set_result(&objios->oir, comp,
 				&pooid, osd_pri_2_pnfs_err(oep),
-				dev_offset, dev_len, is_write);
+				dev_offset, dev_len, !ios->reading);
 }
 
+#if 0
 static void _clear_bio(struct bio *bio)
 {
 	struct bio_vec *bv;
@@ -786,26 +760,28 @@ static int _io_exec(struct objio_state *ios)
 
 	return ret;
 }
+#endif
 
 /*
  * read
  */
-static int _read_done(struct objio_state *ios)
+static void _read_done(struct ore_io_state *ios, void *private)
 {
+	struct objio_state *objios = private;
 	ssize_t status;
-	int ret = _io_check(ios, false);
+	int ret = ore_check_io(ios, &__on_dev_error);
 
-	_io_free(ios);
+	/* FIXME: _io_free(ios) can we dealocate the libosd resources; */
 
 	if (likely(!ret))
 		status = ios->length;
 	else
 		status = ret;
 
-	objlayout_read_done(&ios->oir, status, ios->sync);
-	return ret;
+	objlayout_read_done(&objios->oir, status, objios->sync);
 }
 
+#if 0
 static int _read_mirrors(struct objio_state *ios, unsigned cur_comp)
 {
 	struct osd_request *or = NULL;
@@ -860,49 +836,50 @@ err:
 	_io_free(ios);
 	return ret;
 }
+#endif
 
 int objio_read_pagelist(struct nfs_read_data *rdata)
 {
-	struct objio_state *ios;
+	struct objio_state *objios;
 	int ret;
 
-	ret = objio_alloc_io_state(NFS_I(rdata->inode)->layout,
+	ret = objio_alloc_io_state(NFS_I(rdata->inode)->layout, true,
 			rdata->lseg, rdata->args.pages, rdata->args.pgbase,
 			rdata->args.offset, rdata->args.count, rdata,
-			GFP_KERNEL, &ios);
-	if (unlikely(ret))
-		return ret;
-
-	ret = _io_rw_pagelist(ios, GFP_KERNEL);
+			GFP_KERNEL, &objios);
 	if (unlikely(ret))
 		return ret;
 
-	return _read_exec(ios);
+	objios->ios->done = _read_done;
+	dprintk("%s: offset=0x%llx length=0x%x\n", __func__,
+		rdata->args.offset, rdata->args.count);
+	return ore_read(objios->ios);
 }
 
 /*
  * write
  */
-static int _write_done(struct objio_state *ios)
+static void _write_done(struct ore_io_state *ios, void *private)
 {
+	struct objio_state *objios = private;
 	ssize_t status;
-	int ret = _io_check(ios, true);
+	int ret = ore_check_io(ios, &__on_dev_error);
 
-	_io_free(ios);
+	/* FIXME: _io_free(ios) can we dealocate the libosd resources; */
 
 	if (likely(!ret)) {
 		/* FIXME: should be based on the OSD's persistence model
 		 * See OSD2r05 Section 4.13 Data persistence model */
-		ios->oir.committed = NFS_FILE_SYNC;
+		objios->oir.committed = NFS_FILE_SYNC;
 		status = ios->length;
 	} else {
 		status = ret;
 	}
 
-	objlayout_write_done(&ios->oir, status, ios->sync);
-	return ret;
+	objlayout_write_done(&objios->oir, status, objios->sync);
 }
 
+#if 0
 static int _write_mirrors(struct objio_state *ios, unsigned cur_comp)
 {
 	struct _objio_per_comp *master_dev = &ios->per_dev[cur_comp];
@@ -984,27 +961,35 @@ err:
 	_io_free(ios);
 	return ret;
 }
+#endif
 
 int objio_write_pagelist(struct nfs_write_data *wdata, int how)
 {
-	struct objio_state *ios;
+	struct objio_state *objios;
 	int ret;
 
-	ret = objio_alloc_io_state(NFS_I(wdata->inode)->layout,
+	ret = objio_alloc_io_state(NFS_I(wdata->inode)->layout, false,
 			wdata->lseg, wdata->args.pages, wdata->args.pgbase,
 			wdata->args.offset, wdata->args.count, wdata, GFP_NOFS,
-			&ios);
+			&objios);
 	if (unlikely(ret))
 		return ret;
 
-	ios->sync = 0 != (how & FLUSH_SYNC);
+	objios->sync = 0 != (how & FLUSH_SYNC);
 
-	/* TODO: ios->stable = stable; */
-	ret = _io_rw_pagelist(ios, GFP_NOFS);
+	if (!objios->sync)
+		objios->ios->done = _write_done;
+
+	dprintk("%s: offset=0x%llx length=0x%x\n", __func__,
+		wdata->args.offset, wdata->args.count);
+	ret = ore_write(objios->ios);
 	if (unlikely(ret))
 		return ret;
 
-	return _write_exec(ios);
+	if (objios->sync)
+		_write_done(objios->ios, objios);
+
+	return 0;
 }
 
 static bool objio_pg_test(struct nfs_pageio_descriptor *pgio,
-- 
1.7.2.3


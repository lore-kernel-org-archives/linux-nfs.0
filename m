Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:20232 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754816Ab1EULGf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 May 2011 07:06:35 -0400
Message-ID: <4DD79CB4.5000200@panasas.com>
Date: Sat, 21 May 2011 14:06:28 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs-obj: git diff pnfs-all-2.6.38 to pnfs-submit. Without the reordering
References: <4DD79273.9030202@panasas.com> <1305973798-17250-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <1305973798-17250-1-git-send-email-bharrosh@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Just for review. These are the actual code changes made by Benny
since the last tests at Connectathon

Thanks
Boaz
---
git diff --stat -p -M pnfs/pnfs-all-2.6.38 REORDER_REVERT -- fs/nfs/objlayout/ include/linux/pnfs_osd_xdr.h
 fs/nfs/objlayout/Kbuild             |    2 +-
 fs/nfs/objlayout/objio_osd.c        |   39 +----------
 fs/nfs/objlayout/objlayout.c        |  121 ++++++++++++++++-------------------
 fs/nfs/objlayout/objlayout.h        |   19 ++----
 fs/nfs/objlayout/panfs_shim.c       |   18 +-----
 fs/nfs/objlayout/pnfs_osd_xdr_cli.c |   55 +++++++---------
 include/linux/pnfs_osd_xdr.h        |   26 ++++----
 7 files changed, 102 insertions(+), 178 deletions(-)

diff --git a/fs/nfs/objlayout/Kbuild b/fs/nfs/objlayout/Kbuild
index 9addfe8..6cb585f 100644
--- a/fs/nfs/objlayout/Kbuild
+++ b/fs/nfs/objlayout/Kbuild
@@ -1,7 +1,7 @@
 #
 # Makefile for the pNFS Objects Layout Driver kernel module
 #
-objlayoutdriver-y := pnfs_osd_xdr_cli.o objlayout.o objio_osd.o
+objlayoutdriver-y := objio_osd.o pnfs_osd_xdr_cli.o objlayout.o
 obj-$(CONFIG_PNFS_OBJLAYOUT) += objlayoutdriver.o
 
 #
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index ea19404..a2cb9a3 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -1,12 +1,10 @@
 /*
- *  objio_osd.c
- *
  *  pNFS Objects layout implementation over open-osd initiator library
  *
- *  Copyright (C) 2009 Panasas Inc.
+ *  Copyright (C) 2009 Panasas Inc. [year of first publication]
  *  All rights reserved.
  *
- *  Benny Halevy <bharrosh@panasas.com>
+ *  Benny Halevy <bhalevy@panasas.com>
  *  Boaz Harrosh <bharrosh@panasas.com>
  *
  *  This program is free software; you can redistribute it and/or modify
@@ -40,11 +38,7 @@
  */
 
 #include <linux/module.h>
-#include <scsi/scsi_device.h>
-#include <scsi/osd_attributes.h>
 #include <scsi/osd_initiator.h>
-#include <scsi/osd_sec.h>
-#include <scsi/osd_sense.h>
 
 #include "objlayout.h"
 
@@ -855,7 +849,7 @@ static ssize_t _write_done(struct objio_state *ios)
 	if (likely(!ret)) {
 		/* FIXME: should be based on the OSD's persistence model
 		 * See OSD2r05 Section 4.13 Data persistence model */
-		ios->ol_state.committed = NFS_UNSTABLE; //NFS_FILE_SYNC;
+		ios->ol_state.committed = NFS_FILE_SYNC;
 		status = ios->length;
 	} else {
 		status = ret;
@@ -909,7 +903,6 @@ static int _write_mirrors(struct objio_state *ios, unsigned cur_comp)
 			per_dev->offset =  master_dev->offset;
 		} else {
 			bio = master_dev->bio;
-			/* FIXME: bio_set_dir() */
 			bio->bi_rw |= REQ_WRITE;
 		}
 
@@ -966,34 +959,13 @@ ssize_t objio_write_pagelist(struct objlayout_io_state *ol_state, bool stable)
 	return _write_exec(ios);
 }
 
-/*
- * Policy Operations
- */
-
-/*
- * Get the max [rw]size
- */
-static ssize_t
-objlayout_get_blocksize(void)
-{
-	ssize_t sz = BIO_MAX_PAGES_KMALLOC * PAGE_SIZE;
-
-	return sz;
-}
-
-/*
- * Don't gather across stripes, but rather gather (coalesce) up to
- * the stripe size.
- *
- * FIXME: change interface to use merge_align, merge_count
- */
 static struct pnfs_layoutdriver_type objlayout_type = {
 	.id = LAYOUT_OSD2_OBJECTS,
 	.name = "LAYOUT_OSD2_OBJECTS",
 	.flags                   = PNFS_LAYOUTRET_ON_SETATTR,
 
 	.set_layoutdriver        = objlayout_set_layoutdriver,
-	.clear_layoutdriver      = objlayout_clear_layoutdriver,
+	.unset_layoutdriver      = objlayout_unset_layoutdriver,
 
 	.alloc_layout_hdr        = objlayout_alloc_layout_hdr,
 	.free_layout_hdr         = objlayout_free_layout_hdr,
@@ -1001,11 +973,8 @@ static struct pnfs_layoutdriver_type objlayout_type = {
 	.alloc_lseg              = objlayout_alloc_lseg,
 	.free_lseg               = objlayout_free_lseg,
 
-	.get_blocksize           = objlayout_get_blocksize,
-
 	.read_pagelist           = objlayout_read_pagelist,
 	.write_pagelist          = objlayout_write_pagelist,
-	.commit                  = objlayout_commit,
 
 	.encode_layoutcommit	 = objlayout_encode_layoutcommit,
 	.encode_layoutreturn     = objlayout_encode_layoutreturn,
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 14a1e97..a04e232 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -1,9 +1,7 @@
 /*
- *  objlayout.c
+ *  pNFS Objects layout driver high level definitions
  *
- *  pNFS layout driver for Panasas OSDs
- *
- *  Copyright (C) 2007-2009 Panasas Inc.
+ *  Copyright (C) 2007 Panasas Inc. [year of first publication]
  *  All rights reserved.
  *
  *  Benny Halevy <bhalevy@panasas.com>
@@ -84,23 +82,39 @@ struct pnfs_layout_segment *
 objlayout_alloc_lseg(struct pnfs_layout_hdr *pnfslay,
 		     struct nfs4_layoutget_res *lgr)
 {
-	int status;
-	void *layout = lgr->layout.buf;
-	struct objlayout_segment *objlseg;
+	int status = -ENOMEM;
+	struct xdr_stream stream;
+	struct xdr_buf buf = {
+		.pages =  lgr->layoutp->pages,
+		.page_len =  lgr->layoutp->len,
+		.buflen =  lgr->layoutp->len,
+		.len = lgr->layoutp->len,
+	};
+	struct page *scratch;
+	__be32 *p;
+	struct objlayout_segment *objlseg = NULL;
 	struct pnfs_osd_layout *pnfs_osd_layout;
 
-	dprintk("%s: Begin pnfslay %p layout %p\n", __func__, pnfslay, layout);
+	dprintk("%s: Begin pnfslay %p\n", __func__, pnfslay);
+
+	scratch = alloc_page(GFP_KERNEL);
+	if (!scratch)
+		goto err_nofree;
+
+	xdr_init_decode(&stream, &buf, NULL);
+	xdr_set_scratch_buffer(&stream, page_address(scratch), PAGE_SIZE);
 
-	BUG_ON(!layout);
+	p = xdr_inline_decode(&stream, pnfs_osd_data_map_xdr_sz() << 2);
+	if (unlikely(!p))
+		goto err;
 
-	status = -ENOMEM;
 	objlseg = kzalloc(sizeof(*objlseg) +
-			  pnfs_osd_layout_incore_sz(layout), GFP_KERNEL);
+			  pnfs_osd_layout_incore_sz(p), GFP_KERNEL);
 	if (!objlseg)
 		goto err;
 
 	pnfs_osd_layout = (struct pnfs_osd_layout *)objlseg->pnfs_osd_layout;
-	pnfs_osd_xdr_decode_layout(pnfs_osd_layout, layout);
+	pnfs_osd_xdr_decode_layout(pnfs_osd_layout, p);
 
 	objlseg->lseg.pls_range = lgr->range;
 	status = objio_alloc_lseg(&objlseg->internal, pnfslay, &objlseg->lseg,
@@ -108,11 +122,15 @@ objlayout_alloc_lseg(struct pnfs_layout_hdr *pnfslay,
 	if (status)
 		goto err;
 
+	__free_page(scratch);
+
 	dprintk("%s: Return %p\n", __func__, &objlseg->lseg);
 	return &objlseg->lseg;
 
- err:
+err:
 	kfree(objlseg);
+	__free_page(scratch);
+err_nofree:
 	return ERR_PTR(status);
 }
 
@@ -161,7 +179,6 @@ static struct objlayout_io_state *
 objlayout_alloc_io_state(struct pnfs_layout_hdr *pnfs_layout_type,
 			struct page **pages,
 			unsigned pgbase,
-			unsigned nr_pages,
 			loff_t offset,
 			size_t count,
 			struct pnfs_layout_segment *lseg,
@@ -171,7 +188,6 @@ objlayout_alloc_io_state(struct pnfs_layout_hdr *pnfs_layout_type,
 		container_of(lseg, struct objlayout_segment, lseg);
 	struct objlayout_io_state *state;
 	u64 lseg_end_offset;
-	size_t size_nr_pages;
 
 	dprintk("%s: allocating io_state\n", __func__);
 	if (objio_alloc_io_state(objlseg->internal, &state))
@@ -186,24 +202,16 @@ objlayout_alloc_io_state(struct pnfs_layout_hdr *pnfs_layout_type,
 	}
 
 	if (pgbase > PAGE_SIZE) {
-		unsigned n = pgbase >> PAGE_SHIFT;
-
+		pages += pgbase >> PAGE_SHIFT;
 		pgbase &= ~PAGE_MASK;
-		pages += n;
-		nr_pages -= n;
 	}
 
-	size_nr_pages = (pgbase + count + PAGE_SIZE - 1) >> PAGE_SHIFT;
-	BUG_ON(nr_pages < size_nr_pages);
-	if (nr_pages > size_nr_pages)
-		nr_pages = size_nr_pages;
-
 	INIT_LIST_HEAD(&state->err_list);
 	state->objlseg = objlseg;
 	state->rpcdata = rpcdata;
 	state->pages = pages;
 	state->pgbase = pgbase;
-	state->nr_pages = nr_pages;
+	state->nr_pages = (pgbase + count + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	state->offset = offset;
 	state->count = count;
 	state->sync = 0;
@@ -280,32 +288,6 @@ objlayout_io_set_result(struct objlayout_io_state *state, unsigned index,
 	}
 }
 
-static void _rpc_commit_complete(struct work_struct *work)
-{
-	struct rpc_task *task;
-	struct nfs_write_data *wdata;
-
-	dprintk("%s enter\n", __func__);
-	task = container_of(work, struct rpc_task, u.tk_work);
-	wdata = container_of(task, struct nfs_write_data, task);
-
-	pnfs_commit_done(wdata);
-}
-
-/*
- * Commit data remotely on OSDs
- */
-enum pnfs_try_status
-objlayout_commit(struct nfs_write_data *wdata, int how)
-{
-	int status = PNFS_ATTEMPTED;
-
-	INIT_WORK(&wdata->task.u.tk_work, _rpc_commit_complete);
-	schedule_work(&wdata->task.u.tk_work);
-	dprintk("%s: Return %d\n", __func__, status);
-	return status;
-}
-
 /* Function scheduled on rpc workqueue to call ->nfs_readlist_complete().
  * This is because the osd completion is called with ints-off from
  * the block layer
@@ -319,7 +301,7 @@ static void _rpc_read_complete(struct work_struct *work)
 	task = container_of(work, struct rpc_task, u.tk_work);
 	rdata = container_of(task, struct nfs_read_data, task);
 
-	pnfs_read_done(rdata);
+	pnfs_ld_read_done(rdata);
 }
 
 void
@@ -340,7 +322,7 @@ objlayout_read_done(struct objlayout_io_state *state, ssize_t status, bool sync)
 	/* must not use state after this point */
 
 	if (sync)
-		pnfs_read_done(rdata);
+		pnfs_ld_read_done(rdata);
 	else {
 		INIT_WORK(&rdata->task.u.tk_work, _rpc_read_complete);
 		schedule_work(&rdata->task.u.tk_work);
@@ -351,7 +333,7 @@ objlayout_read_done(struct objlayout_io_state *state, ssize_t status, bool sync)
  * Perform sync or async reads.
  */
 enum pnfs_try_status
-objlayout_read_pagelist(struct nfs_read_data *rdata, unsigned nr_pages)
+objlayout_read_pagelist(struct nfs_read_data *rdata)
 {
 	loff_t offset = rdata->args.offset;
 	size_t count = rdata->args.count;
@@ -375,8 +357,8 @@ objlayout_read_pagelist(struct nfs_read_data *rdata, unsigned nr_pages)
 
 	state = objlayout_alloc_io_state(NFS_I(rdata->inode)->layout,
 					 rdata->args.pages, rdata->args.pgbase,
-					 nr_pages, offset, count,
-					 rdata->pdata.lseg, rdata);
+					 offset, count,
+					 rdata->lseg, rdata);
 	if (unlikely(!state)) {
 		status = -ENOMEM;
 		goto out;
@@ -387,7 +369,7 @@ objlayout_read_pagelist(struct nfs_read_data *rdata, unsigned nr_pages)
 	status = objio_read_pagelist(state);
  out:
 	dprintk("%s: Return status %Zd\n", __func__, status);
-	rdata->pdata.pnfs_error = status;
+	rdata->pnfs_error = status;
 	return PNFS_ATTEMPTED;
 }
 
@@ -404,7 +386,7 @@ static void _rpc_write_complete(struct work_struct *work)
 	task = container_of(work, struct rpc_task, u.tk_work);
 	wdata = container_of(task, struct nfs_write_data, task);
 
-	pnfs_writeback_done(wdata);
+	pnfs_ld_write_done(wdata);
 }
 
 void
@@ -430,7 +412,7 @@ objlayout_write_done(struct objlayout_io_state *state, ssize_t status,
 	/* must not use state after this point */
 
 	if (sync)
-		pnfs_writeback_done(wdata);
+		pnfs_ld_write_done(wdata);
 	else {
 		INIT_WORK(&wdata->task.u.tk_work, _rpc_write_complete);
 		schedule_work(&wdata->task.u.tk_work);
@@ -442,7 +424,6 @@ objlayout_write_done(struct objlayout_io_state *state, ssize_t status,
  */
 enum pnfs_try_status
 objlayout_write_pagelist(struct nfs_write_data *wdata,
-			 unsigned nr_pages,
 			 int how)
 {
 	struct objlayout_io_state *state;
@@ -454,10 +435,9 @@ objlayout_write_pagelist(struct nfs_write_data *wdata,
 	state = objlayout_alloc_io_state(NFS_I(wdata->inode)->layout,
 					 wdata->args.pages,
 					 wdata->args.pgbase,
-					 nr_pages,
 					 wdata->args.offset,
 					 wdata->args.count,
-					 wdata->pdata.lseg, wdata);
+					 wdata->lseg, wdata);
 	if (unlikely(!state)) {
 		status = -ENOMEM;
 		goto out;
@@ -468,7 +448,7 @@ objlayout_write_pagelist(struct nfs_write_data *wdata,
 	status = objio_write_pagelist(state, how & FLUSH_STABLE);
  out:
 	dprintk("%s: Return status %Zd\n", __func__, status);
-	wdata->pdata.pnfs_error = status;
+	wdata->pnfs_error = status;
 	return PNFS_ATTEMPTED;
 }
 
@@ -648,6 +628,8 @@ objlayout_encode_layoutreturn(struct pnfs_layout_hdr *pnfslay,
 			last_xdr = xdr->p;
 			res = pnfs_osd_xdr_encode_ioerr(xdr, &state->ioerrs[i]);
 		}
+
+		/* TODO: use xdr_write_pages */
 		if (unlikely(res)) {
 			/* no space for even one error descriptor */
 			BUG_ON(last_xdr == start + 1);
@@ -672,6 +654,10 @@ loop_done:
 	dprintk("%s: Return\n", __func__);
 }
 
+
+/*
+ * Get Device Info API for io engines
+ */
 struct objlayout_deviceinfo {
 	struct page *page;
 	struct pnfs_osd_deviceaddr da; /* This must be last */
@@ -687,7 +673,7 @@ int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
 	struct objlayout_deviceinfo *odi;
 	struct pnfs_device pd;
 	struct super_block *sb;
-	struct page *page;
+	struct page *page, **pages;
 	size_t sz;
 	u32 *p;
 	int err;
@@ -696,7 +682,8 @@ int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
 	if (!page)
 		return -ENOMEM;
 
-	pd.area = page_address(page);
+	pages = &page;
+	pd.pages = pages;
 
 	memcpy(&pd.dev_id, d_id, sizeof(*d_id));
 	pd.layout_type = LAYOUT_OSD2_OBJECTS;
@@ -711,7 +698,7 @@ int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
 	if (err)
 		goto err_out;
 
-	p = pd.area;
+	p = page_address(page);
 	sz = pnfs_osd_xdr_deviceaddr_incore_sz(p);
 	odi = kzalloc(sz + (sizeof(*odi) - sizeof(odi->da)), GFP_KERNEL);
 	if (!odi) {
@@ -765,7 +752,7 @@ objlayout_set_layoutdriver(struct nfs_server *server,
  * layoutdriver private data.
  */
 int
-objlayout_clear_layoutdriver(struct nfs_server *server)
+objlayout_unset_layoutdriver(struct nfs_server *server)
 {
 	dprintk("%s: Begin %p\n", __func__, server->pnfs_ld_data);
 	objio_fini_mt(server->pnfs_ld_data);
diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
index 57c29ec..38abb01 100644
--- a/fs/nfs/objlayout/objlayout.h
+++ b/fs/nfs/objlayout/objlayout.h
@@ -1,10 +1,8 @@
 /*
- *  objlayout.h
- *
  *  Data types and function declerations for interfacing with the
  *  pNFS standard object layout driver.
  *
- *  Copyright (C) 2007-2009 Panasas Inc.
+ *  Copyright (C) 2007 Panasas Inc. [year of first publication]
  *  All rights reserved.
  *
  *  Benny Halevy <bhalevy@panasas.com>
@@ -167,10 +165,9 @@ extern void objlayout_put_deviceinfo(struct pnfs_osd_deviceaddr *deviceaddr);
  * exported generic objects function vectors
  */
 
-extern int objlayout_set_layoutdriver(
-	struct nfs_server *,
-	const struct nfs_fh *);
-extern int objlayout_clear_layoutdriver(struct nfs_server *);
+extern int objlayout_set_layoutdriver(struct nfs_server *,
+	const struct nfs_fh *mntfh);
+extern int objlayout_unset_layoutdriver(struct nfs_server *);
 
 extern struct pnfs_layout_hdr *objlayout_alloc_layout_hdr(struct inode *);
 extern void objlayout_free_layout_hdr(struct pnfs_layout_hdr *);
@@ -181,16 +178,10 @@ extern struct pnfs_layout_segment *objlayout_alloc_lseg(
 extern void objlayout_free_lseg(struct pnfs_layout_segment *);
 
 extern enum pnfs_try_status objlayout_read_pagelist(
-	struct nfs_read_data *,
-	unsigned nr_pages);
+	struct nfs_read_data *);
 
 extern enum pnfs_try_status objlayout_write_pagelist(
 	struct nfs_write_data *,
-	unsigned nr_pages,
-	int how);
-
-extern enum pnfs_try_status objlayout_commit(
-	struct nfs_write_data *,
 	int how);
 
 extern void objlayout_encode_layoutcommit(
diff --git a/fs/nfs/objlayout/panfs_shim.c b/fs/nfs/objlayout/panfs_shim.c
index cc18bbf..718ea0c 100644
--- a/fs/nfs/objlayout/panfs_shim.c
+++ b/fs/nfs/objlayout/panfs_shim.c
@@ -627,19 +627,6 @@ EXPORT_SYMBOL(panfs_shim_unregister);
 #define PANLAYOUT_MAX_GATHER_STRIPES 8
 
 /*
- * Get the max [rw]size
- */
-static ssize_t
-panlayout_get_blocksize(void)
-{
-	ssize_t sz = (PANLAYOUT_MAX_STRIPE_WIDTH-1) *
-		      PANLAYOUT_DEF_STRIPE_UNIT *
-		      PANLAYOUT_MAX_GATHER_STRIPES;
-	dprintk("%s: Return %Zd\n", __func__, sz);
-	return sz;
-}
-
-/*
  * Don't gather across stripes, but rather gather (coalesce) up to
  * the stripe size.
  *
@@ -653,7 +640,7 @@ static struct pnfs_layoutdriver_type panlayout_type = {
 	.flags                   = PNFS_LAYOUTRET_ON_SETATTR,
 
 	.set_layoutdriver        = objlayout_set_layoutdriver,
-	.clear_layoutdriver      = objlayout_clear_layoutdriver,
+	.unset_layoutdriver      = objlayout_unset_layoutdriver,
 
 	.alloc_layout_hdr        = objlayout_alloc_layout_hdr,
 	.free_layout_hdr         = objlayout_free_layout_hdr,
@@ -661,11 +648,8 @@ static struct pnfs_layoutdriver_type panlayout_type = {
 	.alloc_lseg              = objlayout_alloc_lseg,
 	.free_lseg               = objlayout_free_lseg,
 
-	.get_blocksize           = panlayout_get_blocksize,
-
 	.read_pagelist           = objlayout_read_pagelist,
 	.write_pagelist          = objlayout_write_pagelist,
-	.commit                  = objlayout_commit,
 
 	.encode_layoutcommit	 = objlayout_encode_layoutcommit,
 	.encode_layoutreturn     = objlayout_encode_layoutreturn,
diff --git a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
index d05c6be..4dea458 100644
--- a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
+++ b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
@@ -1,9 +1,7 @@
 /*
- *  pnfs_osd_xdr.c
- *
  *  Object-Based pNFS Layout XDR layer
  *
- *  Copyright (C) 2007-2009 Panasas Inc.
+ *  Copyright (C) 2007 Panasas Inc. [year of first publication]
  *  All rights reserved.
  *
  *  Benny Halevy <bhalevy@panasas.com>
@@ -43,10 +41,7 @@
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
 
 /*
- * The following implementation is based on these Internet Drafts:
- *
- * draft-ietf-nfsv4-minorversion-21
- * draft-ietf-nfsv4-pnfs-obj-12
+ * The following implementation is based on RFC5664
  */
 
 /*
@@ -56,8 +51,8 @@
  * 	u64			oid_object_id;
  * };
  */
-static inline u32 *
-pnfs_osd_xdr_decode_objid(u32 *p, struct pnfs_osd_objid *objid)
+static inline __be32 *
+pnfs_osd_xdr_decode_objid(__be32 *p, struct pnfs_osd_objid *objid)
 {
 	COPYMEM(objid->oid_device_id.data, sizeof(objid->oid_device_id.data));
 	READ64(objid->oid_partition_id);
@@ -65,8 +60,8 @@ pnfs_osd_xdr_decode_objid(u32 *p, struct pnfs_osd_objid *objid)
 	return p;
 }
 
-static inline u32 *
-pnfs_osd_xdr_decode_opaque_cred(u32 *p,
+static inline __be32 *
+pnfs_osd_xdr_decode_opaque_cred(__be32 *p,
 				struct pnfs_osd_opaque_cred *opaque_cred)
 {
 	READ32(opaque_cred->cred_len);
@@ -83,8 +78,8 @@ pnfs_osd_xdr_decode_opaque_cred(u32 *p,
  * 	struct pnfs_osd_opaque_cred	oc_cap;
  * };
  */
-static inline u32 *
-pnfs_osd_xdr_decode_object_cred(u32 *p, struct pnfs_osd_object_cred *comp,
+static inline __be32 *
+pnfs_osd_xdr_decode_object_cred(__be32 *p, struct pnfs_osd_object_cred *comp,
 				u8 **credp)
 {
 	u8 *cred;
@@ -116,7 +111,7 @@ pnfs_osd_xdr_decode_object_cred(u32 *p, struct pnfs_osd_object_cred *comp,
  * };
  */
 static inline u32 *
-pnfs_osd_xdr_decode_data_map(u32 *p, struct pnfs_osd_data_map *data_map)
+pnfs_osd_xdr_decode_data_map(__be32 *p, struct pnfs_osd_data_map *data_map)
 {
 	READ32(data_map->odm_num_comps);
 	READ64(data_map->odm_stripe_unit);
@@ -137,10 +132,10 @@ pnfs_osd_xdr_decode_data_map(u32 *p, struct pnfs_osd_data_map *data_map)
 }
 
 struct pnfs_osd_layout *
-pnfs_osd_xdr_decode_layout(struct pnfs_osd_layout *layout, u32 *p)
+pnfs_osd_xdr_decode_layout(struct pnfs_osd_layout *layout, __be32 *p)
 {
 	int i;
-	u32 *start = p;
+	__be32 *start = p;
 	struct pnfs_osd_object_cred *comp;
 	u8 *cred;
 
@@ -178,8 +173,8 @@ pnfs_osd_xdr_decode_layout(struct pnfs_osd_layout *layout, u32 *p)
  *       should not be freed while the returned information is in use.
  */
 
-u32 *__xdr_read_calc_nfs4_string(
-	u32 *p, struct nfs4_string *str, u8 **freespace)
+__be32 *__xdr_read_calc_nfs4_string(
+	__be32 *p, struct nfs4_string *str, u8 **freespace)
 {
 	u32 len;
 	char *data;
@@ -209,8 +204,8 @@ u32 *__xdr_read_calc_nfs4_string(
 	return p;
 }
 
-u32 *__xdr_read_calc_u8_opaque(
-	u32 *p, struct nfs4_string *str)
+__be32 *__xdr_read_calc_u8_opaque(
+	__be32 *p, struct nfs4_string *str)
 {
 	u32 len;
 
@@ -231,8 +226,8 @@ u32 *__xdr_read_calc_u8_opaque(
  * 	struct nfs4_string	oti_scsi_device_id;
  * };
  */
-u32 *__xdr_read_calc_targetid(
-	u32 *p, struct pnfs_osd_targetid* targetid, u8 **freespace)
+__be32 *__xdr_read_calc_targetid(
+	__be32 *p, struct pnfs_osd_targetid* targetid, u8 **freespace)
 {
 	u32 oti_type;
 
@@ -256,8 +251,8 @@ u32 *__xdr_read_calc_targetid(
  * 	struct nfs4_string	r_addr;
  * };
  */
-u32 *__xdr_read_calc_net_addr(
-	u32 *p, struct pnfs_osd_net_addr* netaddr, u8 **freespace)
+__be32 *__xdr_read_calc_net_addr(
+	__be32 *p, struct pnfs_osd_net_addr* netaddr, u8 **freespace)
 {
 
 	p = __xdr_read_calc_nfs4_string(p,
@@ -277,8 +272,8 @@ u32 *__xdr_read_calc_net_addr(
  * 	struct pnfs_osd_net_addr	ota_netaddr;
  * };
  */
-u32 *__xdr_read_calc_targetaddr(
-	u32 *p, struct pnfs_osd_targetaddr *targetaddr, u8 **freespace)
+__be32 *__xdr_read_calc_targetaddr(
+	__be32 *p, struct pnfs_osd_targetaddr *targetaddr, u8 **freespace)
 {
 	u32 ota_available;
 
@@ -305,8 +300,8 @@ u32 *__xdr_read_calc_targetaddr(
  * 	struct nfs4_string		oda_osdname;
  * };
  */
-u32 *__xdr_read_calc_deviceaddr(
-	u32 *p, struct pnfs_osd_deviceaddr *deviceaddr, u8 **freespace)
+__be32 *__xdr_read_calc_deviceaddr(
+	__be32 *p, struct pnfs_osd_deviceaddr *deviceaddr, u8 **freespace)
 {
 	p = __xdr_read_calc_targetid(p,
 			deviceaddr ? &deviceaddr->oda_targetid : NULL,
@@ -338,7 +333,7 @@ u32 *__xdr_read_calc_deviceaddr(
 	return p;
 }
 
-size_t pnfs_osd_xdr_deviceaddr_incore_sz(u32 *p)
+size_t pnfs_osd_xdr_deviceaddr_incore_sz(__be32 *p)
 {
 	u8 *null_freespace = NULL;
 	size_t sz;
@@ -350,7 +345,7 @@ size_t pnfs_osd_xdr_deviceaddr_incore_sz(u32 *p)
 }
 
 void pnfs_osd_xdr_decode_deviceaddr(
-	struct pnfs_osd_deviceaddr *deviceaddr, u32 *p)
+	struct pnfs_osd_deviceaddr *deviceaddr, __be32 *p)
 {
 	u8 *freespace = (u8 *)(deviceaddr + 1);
 
diff --git a/include/linux/pnfs_osd_xdr.h b/include/linux/pnfs_osd_xdr.h
index b404f33..aed693f 100644
--- a/include/linux/pnfs_osd_xdr.h
+++ b/include/linux/pnfs_osd_xdr.h
@@ -1,9 +1,7 @@
 /*
- *  pnfs_osd_xdr.h
- *
  *  pNFS-osd on-the-wire data structures
  *
- *  Copyright (C) 2007-2009 Panasas Inc.
+ *  Copyright (C) 2007 Panasas Inc. [year of first publication]
  *  All rights reserved.
  *
  *  Benny Halevy <bhalevy@panasas.com>
@@ -154,7 +152,7 @@ struct pnfs_osd_opaque_cred {
 };
 
 static inline int
-pnfs_osd_opaque_cred_xdr_sz(u32 *p)
+pnfs_osd_opaque_cred_xdr_sz(__be32 *p)
 {
 	u32 *start = p;
 	u32 n;
@@ -165,7 +163,7 @@ pnfs_osd_opaque_cred_xdr_sz(u32 *p)
 }
 
 static inline size_t
-pnfs_osd_opaque_cred_incore_sz(u32 *p)
+pnfs_osd_opaque_cred_incore_sz(__be32 *p)
 {
 	u32 n;
 
@@ -195,9 +193,9 @@ struct pnfs_osd_object_cred {
 };
 
 static inline int
-pnfs_osd_object_cred_xdr_sz(u32 *p)
+pnfs_osd_object_cred_xdr_sz(__be32 *p)
 {
-	u32 *start = p;
+	__be32 *start = p;
 
 	p += pnfs_osd_objid_xdr_sz() + 2;
 	p += pnfs_osd_opaque_cred_xdr_sz(p);
@@ -206,7 +204,7 @@ pnfs_osd_object_cred_xdr_sz(u32 *p)
 }
 
 static inline size_t
-pnfs_osd_object_cred_incore_sz(u32 *p)
+pnfs_osd_object_cred_incore_sz(__be32 *p)
 {
 	size_t sz = sizeof(struct pnfs_osd_object_cred);
 
@@ -231,9 +229,9 @@ struct pnfs_osd_layout {
 };
 
 static inline int
-pnfs_osd_layout_xdr_sz(u32 *p)
+pnfs_osd_layout_xdr_sz(__be32 *p)
 {
-	u32 *start = p;
+	__be32 *start = p;
 	u32 n;
 
 	p += pnfs_osd_data_map_xdr_sz() + 1;
@@ -244,7 +242,7 @@ pnfs_osd_layout_xdr_sz(u32 *p)
 }
 
 static inline size_t
-pnfs_osd_layout_incore_sz(u32 *p)
+pnfs_osd_layout_incore_sz(__be32 *p)
 {
 	u32 n;
 	size_t sz;
@@ -399,7 +397,7 @@ pnfs_osd_ioerr_xdr_sz(void)
 
 /* Layout helpers */
 extern struct pnfs_osd_layout *pnfs_osd_xdr_decode_layout(
-	struct pnfs_osd_layout *layout, u32 *p);
+	struct pnfs_osd_layout *layout, __be32 *p);
 
 extern int pnfs_osd_xdr_encode_layout(
 	struct exp_xdr_stream *xdr,
@@ -408,7 +406,7 @@ extern int pnfs_osd_xdr_encode_layout(
 /* Device Info helpers */
 
 /* First pass calculate total size for space needed */
-extern size_t pnfs_osd_xdr_deviceaddr_incore_sz(u32 *p);
+extern size_t pnfs_osd_xdr_deviceaddr_incore_sz(__be32 *p);
 
 /* Note: some strings pointed to inside @deviceaddr might point
  * to space inside @p. @p should stay valid while @deviceaddr
@@ -417,7 +415,7 @@ extern size_t pnfs_osd_xdr_deviceaddr_incore_sz(u32 *p);
  * calculated in first pass by pnfs_osd_xdr_deviceaddr_incore_sz()
  */
 extern void pnfs_osd_xdr_decode_deviceaddr(
-	struct pnfs_osd_deviceaddr *deviceaddr, u32 *p);
+	struct pnfs_osd_deviceaddr *deviceaddr, __be32 *p);
 
 /* For Servers */
 extern int pnfs_osd_xdr_encode_deviceaddr(


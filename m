Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:57181 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366Ab1DTR2m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 13:28:42 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC 19/27] pnfs-obj: objlayout driver skeleton
Date: Wed, 20 Apr 2011 20:28:39 +0300
Message-Id: <1303320519-21676-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DAF0DE1.6020609@panasas.com>
References: <4DAF0DE1.6020609@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

* Add the objlayout middleware and initial driver skeleton.
* Establish API with IO engine.
* Add an empty objio_osd IO engine that does nothing and just requests
  IO through the MDS.

At this stage the layoutdriver is loadable and registers with the pnfs
client to provide osd layouts. But it does not actually do anything.

[Some extra debug-prints]
[move objlayout to the PNFS_LD dprint channel]
[bug in last conversion to embedded pnfs_layout_segment]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[convert APIs pnfs-post-submit]
[get rid of threshold policy ops]
[git rid of PNFS_LAYOUTGET_ON_OPEN]
[use new alloc/free_layout API]
[use new commit api]
[use new read_pagelist api]
[use new write_pagelist api]
[apply types rename]
[convert to new pnfs-submit changes]
[deprecate get_stripesize]
[use {set,clear}_layoutdriver]
[use pnfs_layout_hdr and layout_segment field prefix]
[deprecate get_blocksize, commit methods]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/Kbuild      |    2 +-
 fs/nfs/objlayout/objio_osd.c |  210 ++++++++++++++++++++
 fs/nfs/objlayout/objlayout.c |  435 ++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/objlayout/objlayout.h |  155 +++++++++++++++
 include/linux/nfs4.h         |    2 +
 5 files changed, 803 insertions(+), 1 deletions(-)
 create mode 100644 fs/nfs/objlayout/objio_osd.c
 create mode 100644 fs/nfs/objlayout/objlayout.c
 create mode 100644 fs/nfs/objlayout/objlayout.h

diff --git a/fs/nfs/objlayout/Kbuild b/fs/nfs/objlayout/Kbuild
index c326738..a45339c 100644
--- a/fs/nfs/objlayout/Kbuild
+++ b/fs/nfs/objlayout/Kbuild
@@ -1,5 +1,5 @@
 #
 # Makefile for the pNFS Objects Layout Driver kernel module
 #
-objlayoutdriver-y := pnfs_osd_xdr_cli.o
+objlayoutdriver-y := pnfs_osd_xdr_cli.o objlayout.o objio_osd.o
 obj-$(CONFIG_PNFS_OBJLAYOUT) += objlayoutdriver.o
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
new file mode 100644
index 0000000..4b88c0a
--- /dev/null
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -0,0 +1,210 @@
+/*
+ *  objio_osd.c
+ *
+ *  pNFS Objects layout implementation over open-osd initiator library
+ *
+ *  Copyright (C) 2009 Panasas Inc.
+ *  All rights reserved.
+ *
+ *  Benny Halevy <bharrosh@panasas.com>
+ *  Boaz Harrosh <bharrosh@panasas.com>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License version 2
+ *  See the file COPYING included with this distribution for more details.
+ *
+ *  Redistribution and use in source and binary forms, with or without
+ *  modification, are permitted provided that the following conditions
+ *  are met:
+ *
+ *  1. Redistributions of source code must retain the above copyright
+ *     notice, this list of conditions and the following disclaimer.
+ *  2. Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in the
+ *     documentation and/or other materials provided with the distribution.
+ *  3. Neither the name of the Panasas company nor the names of its
+ *     contributors may be used to endorse or promote products derived
+ *     from this software without specific prior written permission.
+ *
+ *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
+ *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+ *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+ *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+ *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <linux/module.h>
+#include <scsi/scsi_device.h>
+#include <scsi/osd_attributes.h>
+#include <scsi/osd_initiator.h>
+#include <scsi/osd_sec.h>
+#include <scsi/osd_sense.h>
+
+#include "objlayout.h"
+
+#define NFSDBG_FACILITY         NFSDBG_PNFS_LD
+
+#define _LLU(x) ((unsigned long long)x)
+
+enum { BIO_MAX_PAGES_KMALLOC =
+		(PAGE_SIZE - sizeof(struct bio)) / sizeof(struct bio_vec),
+};
+
+/* A per mountpoint struct currently for device cache */
+struct objio_mount_type {
+	struct list_head dev_list;
+	spinlock_t dev_list_lock;
+};
+
+struct objio_segment {
+	struct pnfs_osd_layout *layout;
+};
+
+struct objio_state {
+	/* Generic layer */
+	struct objlayout_io_state ol_state;
+
+	struct objio_segment *objio_seg;
+};
+
+int objio_alloc_lseg(void **outp,
+	struct pnfs_layout_hdr *pnfslay,
+	struct pnfs_layout_segment *lseg,
+	struct pnfs_osd_layout *layout)
+{
+	struct objio_segment *objio_seg;
+
+	objio_seg = kzalloc(sizeof(*objio_seg), GFP_KERNEL);
+	if (!objio_seg)
+		return -ENOMEM;
+
+	objio_seg->layout = layout;
+
+	*outp = objio_seg;
+	return 0;
+}
+
+void objio_free_lseg(void *p)
+{
+	struct objio_segment *objio_seg = p;
+
+	kfree(objio_seg);
+}
+
+int objio_alloc_io_state(void *seg, struct objlayout_io_state **outp)
+{
+	struct objio_segment *objio_seg = seg;
+	struct objio_state *ios;
+
+	ios = kzalloc(sizeof(*ios), GFP_KERNEL);
+	if (unlikely(!ios))
+		return -ENOMEM;
+
+	ios->objio_seg = objio_seg;
+
+	*outp = &ios->ol_state;
+	return 0;
+}
+
+void objio_free_io_state(struct objlayout_io_state *ol_state)
+{
+	struct objio_state *ios = container_of(ol_state, struct objio_state,
+					       ol_state);
+
+	kfree(ios);
+}
+
+/*
+ * read
+ */
+ssize_t objio_read_pagelist(struct objlayout_io_state *ol_state)
+{
+	return -EIO;
+}
+
+/*
+ * write
+ */
+ssize_t objio_write_pagelist(struct objlayout_io_state *ol_state, bool stable)
+{
+	return -EIO;
+}
+
+/*
+ * Policy Operations
+ */
+
+/*
+ * Don't gather across stripes, but rather gather (coalesce) up to
+ * the stripe size.
+ *
+ * FIXME: change interface to use merge_align, merge_count
+ */
+static struct pnfs_layoutdriver_type objlayout_type = {
+	.id = LAYOUT_OSD2_OBJECTS,
+	.name = "LAYOUT_OSD2_OBJECTS",
+	.flags                   = PNFS_LAYOUTRET_ON_SETATTR,
+
+	.set_layoutdriver        = objlayout_set_layoutdriver,
+	.unset_layoutdriver      = objlayout_unset_layoutdriver,
+
+	.alloc_layout_hdr        = objlayout_alloc_layout_hdr,
+	.free_layout_hdr         = objlayout_free_layout_hdr,
+
+	.alloc_lseg              = objlayout_alloc_lseg,
+	.free_lseg               = objlayout_free_lseg,
+
+	.read_pagelist           = objlayout_read_pagelist,
+	.write_pagelist          = objlayout_write_pagelist,
+};
+
+void *objio_init_mt(void)
+{
+	struct objio_mount_type *omt = kzalloc(sizeof(*omt), GFP_KERNEL);
+
+	if (!omt)
+		return ERR_PTR(-ENOMEM);
+
+	return omt;
+}
+
+void objio_fini_mt(void *mountid)
+{
+	kfree(mountid);
+}
+
+MODULE_DESCRIPTION("pNFS Layout Driver for OSD2 objects");
+MODULE_AUTHOR("Benny Halevy <bhalevy@panasas.com>");
+MODULE_LICENSE("GPL");
+
+static int __init
+objlayout_init(void)
+{
+	int ret = pnfs_register_layoutdriver(&objlayout_type);
+
+	if (ret)
+		printk(KERN_INFO
+			"%s: Registering OSD pNFS Layout Driver failed: error=%d\n",
+			__func__, ret);
+	else
+		printk(KERN_INFO "%s: Registered OSD pNFS Layout Driver\n",
+			__func__);
+	return ret;
+}
+
+static void __exit
+objlayout_exit(void)
+{
+	pnfs_unregister_layoutdriver(&objlayout_type);
+	printk(KERN_INFO "%s: Unregistered OSD pNFS Layout Driver\n",
+	       __func__);
+}
+
+module_init(objlayout_init);
+module_exit(objlayout_exit);
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
new file mode 100644
index 0000000..ae14a24
--- /dev/null
+++ b/fs/nfs/objlayout/objlayout.c
@@ -0,0 +1,435 @@
+/*
+ *  objlayout.c
+ *
+ *  pNFS layout driver for Panasas OSDs
+ *
+ *  Copyright (C) 2007-2009 Panasas Inc.
+ *  All rights reserved.
+ *
+ *  Benny Halevy <bhalevy@panasas.com>
+ *  Boaz Harrosh <bharrosh@panasas.com>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License version 2
+ *  See the file COPYING included with this distribution for more details.
+ *
+ *  Redistribution and use in source and binary forms, with or without
+ *  modification, are permitted provided that the following conditions
+ *  are met:
+ *
+ *  1. Redistributions of source code must retain the above copyright
+ *     notice, this list of conditions and the following disclaimer.
+ *  2. Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in the
+ *     documentation and/or other materials provided with the distribution.
+ *  3. Neither the name of the Panasas company nor the names of its
+ *     contributors may be used to endorse or promote products derived
+ *     from this software without specific prior written permission.
+ *
+ *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
+ *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+ *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+ *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+ *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include "objlayout.h"
+
+#define NFSDBG_FACILITY         NFSDBG_PNFS_LD
+
+struct pnfs_client_operations *pnfs_client_ops;
+
+/*
+ * Create a objlayout layout structure for the given inode and return it.
+ */
+struct pnfs_layout_hdr *
+objlayout_alloc_layout_hdr(struct inode *inode)
+{
+	struct objlayout *objlay;
+
+	objlay = kzalloc(sizeof(struct objlayout), GFP_KERNEL);
+	dprintk("%s: Return %p\n", __func__, objlay);
+	return &objlay->pnfs_layout;
+}
+
+/*
+ * Free an objlayout layout structure
+ */
+void
+objlayout_free_layout_hdr(struct pnfs_layout_hdr *lo)
+{
+	struct objlayout *objlay = OBJLAYOUT(lo);
+
+	dprintk("%s: objlay %p\n", __func__, objlay);
+
+	kfree(objlay);
+}
+
+/*
+ * Unmarshall layout and store it in pnfslay.
+ */
+struct pnfs_layout_segment *
+objlayout_alloc_lseg(struct pnfs_layout_hdr *pnfslay,
+		     struct nfs4_layoutget_res *lgr)
+{
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
+	struct pnfs_osd_layout *pnfs_osd_layout;
+
+	dprintk("%s: Begin pnfslay %p\n", __func__, pnfslay);
+
+	scratch = alloc_page(GFP_KERNEL);
+	if (!scratch)
+		goto err_nofree;
+
+	xdr_init_decode(&stream, &buf, NULL);
+	xdr_set_scratch_buffer(&stream, page_address(scratch), PAGE_SIZE);
+
+	/* FIXME: presuming whole layout fits in the first page,
+	   need to use the xdr decoding helpers rather than the READXX macros */
+	p = xdr_inline_decode(&stream, pnfs_osd_data_map_xdr_sz() << 2);
+	if (unlikely(!p))
+		goto err;
+
+	objlseg = kzalloc(sizeof(*objlseg) +
+			  pnfs_osd_layout_incore_sz(p), GFP_KERNEL);
+	if (!objlseg)
+		goto err;
+
+	pnfs_osd_layout = (struct pnfs_osd_layout *)objlseg->pnfs_osd_layout;
+	pnfs_osd_xdr_decode_layout(pnfs_osd_layout, p);
+
+	objlseg->lseg.pls_range = lgr->range;
+	status = objio_alloc_lseg(&objlseg->internal, pnfslay, &objlseg->lseg,
+				  pnfs_osd_layout);
+	if (status)
+		goto err;
+
+	__free_page(scratch);
+
+	dprintk("%s: Return %p\n", __func__, &objlseg->lseg);
+	return &objlseg->lseg;
+
+err:
+	kfree(objlseg);
+	__free_page(scratch);
+err_nofree:
+	return ERR_PTR(status);
+}
+
+/*
+ * Free a layout segement
+ */
+void
+objlayout_free_lseg(struct pnfs_layout_segment *lseg)
+{
+	struct objlayout_segment *objlseg;
+
+	dprintk("%s: freeing layout segment %p\n", __func__, lseg);
+
+	if (unlikely(!lseg))
+		return;
+
+	objlseg = container_of(lseg, struct objlayout_segment, lseg);
+	objio_free_lseg(objlseg->internal);
+	kfree(objlseg);
+}
+
+/*
+ * I/O Operations
+ */
+static inline u64
+end_offset(u64 start, u64 len)
+{
+	u64 end;
+
+	end = start + len;
+	return end >= start ? end : NFS4_MAX_UINT64;
+}
+
+/* last octet in a range */
+static inline u64
+last_byte_offset(u64 start, u64 len)
+{
+	u64 end;
+
+	BUG_ON(!len);
+	end = start + len;
+	return end > start ? end - 1 : NFS4_MAX_UINT64;
+}
+
+static struct objlayout_io_state *
+objlayout_alloc_io_state(struct pnfs_layout_hdr *pnfs_layout_type,
+			struct page **pages,
+			unsigned pgbase,
+			loff_t offset,
+			size_t count,
+			struct pnfs_layout_segment *lseg,
+			void *rpcdata)
+{
+	struct objlayout_segment *objlseg =
+		container_of(lseg, struct objlayout_segment, lseg);
+	struct objlayout_io_state *state;
+	u64 lseg_end_offset;
+
+	dprintk("%s: allocating io_state\n", __func__);
+	if (objio_alloc_io_state(objlseg->internal, &state))
+		return NULL;
+
+	BUG_ON(offset < lseg->pls_range.offset);
+	lseg_end_offset = end_offset(lseg->pls_range.offset, lseg->pls_range.length);
+	BUG_ON(offset >= lseg_end_offset);
+	if (offset + count > lseg_end_offset) {
+		count = lseg->pls_range.length - (offset - lseg->pls_range.offset);
+		dprintk("%s: truncated count %Zd\n", __func__, count);
+	}
+
+	if (pgbase > PAGE_SIZE) {
+		pages += pgbase >> PAGE_SHIFT;
+		pgbase &= ~PAGE_MASK;
+	}
+
+	state->objlseg = objlseg;
+	state->rpcdata = rpcdata;
+	state->pages = pages;
+	state->pgbase = pgbase;
+	state->nr_pages = (pgbase + count + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	state->offset = offset;
+	state->count = count;
+	state->sync = 0;
+
+	return state;
+}
+
+static void
+objlayout_free_io_state(struct objlayout_io_state *state)
+{
+	dprintk("%s: freeing io_state\n", __func__);
+	if (unlikely(!state))
+		return;
+
+	objio_free_io_state(state);
+}
+
+/*
+ * I/O done common code
+ */
+static void
+objlayout_iodone(struct objlayout_io_state *state)
+{
+	dprintk("%s: state %p status\n", __func__, state);
+
+	objlayout_free_io_state(state);
+}
+
+/* Function scheduled on rpc workqueue to call ->nfs_readlist_complete().
+ * This is because the osd completion is called with ints-off from
+ * the block layer
+ */
+static void _rpc_read_complete(struct work_struct *work)
+{
+	struct rpc_task *task;
+	struct nfs_read_data *rdata;
+
+	dprintk("%s enter\n", __func__);
+	task = container_of(work, struct rpc_task, u.tk_work);
+	rdata = container_of(task, struct nfs_read_data, task);
+
+	pnfs_read_done(rdata);
+}
+
+void
+objlayout_read_done(struct objlayout_io_state *state, ssize_t status, bool sync)
+{
+	int eof = state->eof;
+	struct nfs_read_data *rdata;
+
+	state->status = status;
+	dprintk("%s: Begin status=%ld eof=%d\n", __func__, status, eof);
+	rdata = state->rpcdata;
+	rdata->task.tk_status = status;
+	if (status >= 0) {
+		rdata->res.count = status;
+		rdata->res.eof = eof;
+	}
+	objlayout_iodone(state);
+	/* must not use state after this point */
+
+	if (sync)
+		pnfs_read_done(rdata);
+	else {
+		INIT_WORK(&rdata->task.u.tk_work, _rpc_read_complete);
+		schedule_work(&rdata->task.u.tk_work);
+	}
+}
+
+/*
+ * Perform sync or async reads.
+ */
+enum pnfs_try_status
+objlayout_read_pagelist(struct nfs_read_data *rdata)
+{
+	loff_t offset = rdata->args.offset;
+	size_t count = rdata->args.count;
+	struct objlayout_io_state *state;
+	ssize_t status = 0;
+	loff_t eof;
+
+	dprintk("%s: Begin inode %p offset %llu count %d\n",
+		__func__, rdata->inode, offset, (int)count);
+
+	eof = i_size_read(rdata->inode);
+	if (unlikely(offset + count > eof)) {
+		if (offset >= eof) {
+			status = 0;
+			rdata->res.count = 0;
+			rdata->res.eof = 1;
+			goto out;
+		}
+		count = eof - offset;
+	}
+
+	state = objlayout_alloc_io_state(NFS_I(rdata->inode)->layout,
+					 rdata->args.pages, rdata->args.pgbase,
+					 offset, count,
+					 rdata->lseg, rdata);
+	if (unlikely(!state)) {
+		status = -ENOMEM;
+		goto out;
+	}
+
+	state->eof = state->offset + state->count >= eof;
+
+	status = objio_read_pagelist(state);
+ out:
+	dprintk("%s: Return status %Zd\n", __func__, status);
+	rdata->pnfs_error = status;
+	return PNFS_ATTEMPTED;
+}
+
+/* Function scheduled on rpc workqueue to call ->nfs_writelist_complete().
+ * This is because the osd completion is called with ints-off from
+ * the block layer
+ */
+static void _rpc_write_complete(struct work_struct *work)
+{
+	struct rpc_task *task;
+	struct nfs_write_data *wdata;
+
+	dprintk("%s enter\n", __func__);
+	task = container_of(work, struct rpc_task, u.tk_work);
+	wdata = container_of(task, struct nfs_write_data, task);
+
+	pnfs_write_done(wdata);
+}
+
+void
+objlayout_write_done(struct objlayout_io_state *state, ssize_t status,
+		     bool sync)
+{
+	struct nfs_write_data *wdata;
+
+	dprintk("%s: Begin\n", __func__);
+	wdata = state->rpcdata;
+	state->status = status;
+	wdata->task.tk_status = status;
+	if (status >= 0) {
+		wdata->res.count = status;
+		wdata->verf.committed = state->committed;
+		dprintk("%s: Return status %d committed %d\n",
+			__func__, wdata->task.tk_status,
+			wdata->verf.committed);
+	} else
+		dprintk("%s: Return status %d\n",
+			__func__, wdata->task.tk_status);
+	objlayout_iodone(state);
+	/* must not use state after this point */
+
+	if (sync)
+		pnfs_write_done(wdata);
+	else {
+		INIT_WORK(&wdata->task.u.tk_work, _rpc_write_complete);
+		schedule_work(&wdata->task.u.tk_work);
+	}
+}
+
+/*
+ * Perform sync or async writes.
+ */
+enum pnfs_try_status
+objlayout_write_pagelist(struct nfs_write_data *wdata,
+			 int how)
+{
+	struct objlayout_io_state *state;
+	ssize_t status;
+
+	dprintk("%s: Begin inode %p offset %llu count %u\n",
+		__func__, wdata->inode, wdata->args.offset, wdata->args.count);
+
+	state = objlayout_alloc_io_state(NFS_I(wdata->inode)->layout,
+					 wdata->args.pages,
+					 wdata->args.pgbase,
+					 wdata->args.offset,
+					 wdata->args.count,
+					 wdata->lseg, wdata);
+	if (unlikely(!state)) {
+		status = -ENOMEM;
+		goto out;
+	}
+
+	state->sync = how & FLUSH_SYNC;
+
+	status = objio_write_pagelist(state, how & FLUSH_STABLE);
+ out:
+	dprintk("%s: Return status %Zd\n", __func__, status);
+	wdata->pnfs_error = status;
+	return PNFS_ATTEMPTED;
+}
+
+/*
+ * Perform the objio specific init_mt method.
+ * Set the layout driver private data pointer for later use.
+ */
+int
+objlayout_set_layoutdriver(struct nfs_server *server)
+{
+	void *data;
+
+	data = objio_init_mt();
+	if (IS_ERR(data)) {
+		printk(KERN_INFO "%s: objlayout lib not ready err=%ld\n",
+		       __func__, PTR_ERR(data));
+		return PTR_ERR(data);
+	}
+	server->pnfs_ld_data = data;
+
+	dprintk("%s: Return data=%p\n", __func__, data);
+	return 0;
+}
+
+/*
+ * Perform the objio specific fini_mt method to release the
+ * layoutdriver private data.
+ */
+int
+objlayout_unset_layoutdriver(struct nfs_server *server)
+{
+	dprintk("%s: Begin %p\n", __func__, server->pnfs_ld_data);
+	objio_fini_mt(server->pnfs_ld_data);
+	return 0;
+}
diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
new file mode 100644
index 0000000..24b36d4
--- /dev/null
+++ b/fs/nfs/objlayout/objlayout.h
@@ -0,0 +1,155 @@
+/*
+ *  objlayout.h
+ *
+ *  Data types and function declerations for interfacing with the
+ *  pNFS standard object layout driver.
+ *
+ *  Copyright (C) 2007-2009 Panasas Inc.
+ *  All rights reserved.
+ *
+ *  Benny Halevy <bhalevy@panasas.com>
+ *  Boaz Harrosh <bharrosh@panasas.com>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License version 2
+ *  See the file COPYING included with this distribution for more details.
+ *
+ *  Redistribution and use in source and binary forms, with or without
+ *  modification, are permitted provided that the following conditions
+ *  are met:
+ *
+ *  1. Redistributions of source code must retain the above copyright
+ *     notice, this list of conditions and the following disclaimer.
+ *  2. Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in the
+ *     documentation and/or other materials provided with the distribution.
+ *  3. Neither the name of the Panasas company nor the names of its
+ *     contributors may be used to endorse or promote products derived
+ *     from this software without specific prior written permission.
+ *
+ *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
+ *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+ *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+ *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+ *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef _OBJLAYOUT_H
+#define _OBJLAYOUT_H
+
+#include <linux/nfs_fs.h>
+#include <linux/pnfs_osd_xdr.h>
+#include "../pnfs.h"
+
+/*
+ * in-core layout segment
+ */
+struct objlayout_segment {
+	struct pnfs_layout_segment lseg;
+	void *internal;    /* for provider internal use */
+	u8 pnfs_osd_layout[];
+};
+
+/*
+ * per-inode layout
+ */
+struct objlayout {
+	struct pnfs_layout_hdr pnfs_layout;
+};
+
+static inline struct objlayout *
+OBJLAYOUT(struct pnfs_layout_hdr *lo)
+{
+	return container_of(lo, struct objlayout, pnfs_layout);
+}
+
+/*
+ * per-I/O operation state
+ * embedded in objects provider io_state data structure
+ */
+struct objlayout_io_state {
+	struct objlayout_segment *objlseg;
+
+	struct page **pages;
+	unsigned pgbase;
+	unsigned nr_pages;
+	unsigned long count;
+	loff_t offset;
+	bool sync;
+
+	void *rpcdata;
+	int status;             /* res */
+	int eof;                /* res */
+	int committed;          /* res */
+};
+
+/*
+ * Raid engine I/O API
+ */
+extern void *objio_init_mt(void);
+extern void objio_fini_mt(void *mt);
+
+extern int objio_alloc_lseg(void **outp,
+	struct pnfs_layout_hdr *pnfslay,
+	struct pnfs_layout_segment *lseg,
+	struct pnfs_osd_layout *layout);
+extern void objio_free_lseg(void *p);
+
+extern int objio_alloc_io_state(void *seg, struct objlayout_io_state **outp);
+extern void objio_free_io_state(struct objlayout_io_state *state);
+
+extern ssize_t objio_read_pagelist(struct objlayout_io_state *ol_state);
+extern ssize_t objio_write_pagelist(struct objlayout_io_state *ol_state,
+				    bool stable);
+
+/*
+ * callback API
+ */
+extern void objlayout_io_set_result(struct objlayout_io_state *state,
+				    unsigned index, int osd_error,
+				    u64 offset, u64 length, bool is_write);
+
+extern void objlayout_read_done(struct objlayout_io_state *state,
+				ssize_t status, bool sync);
+extern void objlayout_write_done(struct objlayout_io_state *state,
+				 ssize_t status, bool sync);
+
+/*
+ * exported generic objects function vectors
+ */
+
+extern int objlayout_set_layoutdriver(struct nfs_server *);
+extern int objlayout_unset_layoutdriver(struct nfs_server *);
+
+extern struct pnfs_layout_hdr *objlayout_alloc_layout_hdr(struct inode *);
+extern void objlayout_free_layout_hdr(struct pnfs_layout_hdr *);
+
+extern struct pnfs_layout_segment *objlayout_alloc_lseg(
+	struct pnfs_layout_hdr *,
+	struct nfs4_layoutget_res *);
+extern void objlayout_free_lseg(struct pnfs_layout_segment *);
+
+extern enum pnfs_try_status objlayout_read_pagelist(
+	struct nfs_read_data *);
+
+extern enum pnfs_try_status objlayout_write_pagelist(
+	struct nfs_write_data *,
+	int how);
+
+extern void objlayout_encode_layoutcommit(
+	struct pnfs_layout_hdr *,
+	struct xdr_stream *,
+	const struct nfs4_layoutcommit_args *);
+
+extern void objlayout_encode_layoutreturn(
+	struct pnfs_layout_hdr *,
+	struct xdr_stream *,
+	const struct nfs4_layoutreturn_args *);
+
+#endif /* _OBJLAYOUT_H */
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 9376eaf..54556ca6 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -585,6 +585,8 @@ enum pnfs_layouttype {
 	LAYOUT_NFSV4_1_FILES  = 1,
 	LAYOUT_OSD2_OBJECTS = 2,
 	LAYOUT_BLOCK_VOLUME = 3,
+
+	NFS4_PNFS_PRIVATE_LAYOUT = 0x80000000
 };
 
 /* used for both layout return and recall */
-- 
1.7.3.4


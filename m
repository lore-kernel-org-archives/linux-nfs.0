Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:34756 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752387Ab1EPQXQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2011 12:23:16 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, bharrosh@panasas.com
Subject: [PATCH v3 19/29] pnfs-obj: read/write implementation
Date: Mon, 16 May 2011 09:23:13 -0700
Message-Id: <1305562993-7992-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DD14D8E.1070701@panasas.com>
References: <4DD14D8E.1070701@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

With the use of the in-kernel osd library. Implement read/write
of data from/to osd-objects according to information specified
in the objects-layout.

TODO: Only a limited Mirror arrangement is implemented. stripping/raid
      will come in at later patches.

[pnfs-obj: objio: cleanup un-indent _read_mirrors]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[added FIXME comment]
[use REQ flags rather than BIO flags]
[squashed with objlayout driver skeleton]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |  470 ++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/objlayout/objlayout.c |  277 +++++++++++++++++++++++++
 fs/nfs/objlayout/objlayout.h |   63 ++++++
 3 files changed, 810 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 9baae80..93b9580 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -44,6 +44,12 @@
 
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
 
+#define _LLU(x) ((unsigned long long)x)
+
+enum { BIO_MAX_PAGES_KMALLOC =
+		(PAGE_SIZE - sizeof(struct bio)) / sizeof(struct bio_vec),
+};
+
 /* A per mountpoint struct currently for device cache */
 struct objio_mount_type {
 	struct list_head dev_list;
@@ -213,6 +219,60 @@ out:
 	return err;
 }
 
+struct objio_state;
+typedef ssize_t (*objio_done_fn)(struct objio_state *ios);
+
+struct objio_state {
+	/* Generic layer */
+	struct objlayout_io_state ol_state;
+
+	struct objio_segment *objio_seg;
+
+	struct kref kref;
+	objio_done_fn done;
+	void *private;
+
+	unsigned long length;
+	unsigned numdevs; /* Actually used devs in this IO */
+	/* A per-device variable array of size numdevs */
+	struct _objio_per_comp {
+		struct bio *bio;
+		struct osd_request *or;
+	} per_dev[];
+};
+
+static int _verify_data_map(struct pnfs_osd_layout *layout)
+{
+	struct pnfs_osd_data_map *data_map = &layout->olo_map;
+
+/* FIXME: Only Mirror arangment for now. if not so, do not mount */
+	if (data_map->odm_group_width || data_map->odm_group_depth) {
+		printk(KERN_ERR "Group width/depth not supported\n");
+		return -ENOTSUPP;
+	}
+	if (data_map->odm_num_comps != layout->olo_num_comps) {
+		printk(KERN_ERR "odm_num_comps(%u) != olo_num_comps(%u)\n",
+			  data_map->odm_num_comps, layout->olo_num_comps);
+		return -ENOTSUPP;
+	}
+	if (data_map->odm_raid_algorithm != PNFS_OSD_RAID_0) {
+		printk(KERN_ERR "Only RAID_0 for now\n");
+		return -ENOTSUPP;
+	}
+	if (data_map->odm_num_comps != data_map->odm_mirror_cnt + 1) {
+		printk(KERN_ERR "Mirror only!, num_comps=%u mirrors=%u\n",
+			  data_map->odm_num_comps, data_map->odm_mirror_cnt);
+		return -ENOTSUPP;
+	}
+
+	if (data_map->odm_stripe_unit != PAGE_SIZE) {
+		printk(KERN_ERR "Stripe Unit != PAGE_SIZE not supported\n");
+		return -ENOTSUPP;
+	}
+
+	return 0;
+}
+
 int objio_alloc_lseg(void **outp,
 	struct pnfs_layout_hdr *pnfslay,
 	struct pnfs_layout_segment *lseg,
@@ -221,6 +281,10 @@ int objio_alloc_lseg(void **outp,
 	struct objio_segment *objio_seg;
 	int err;
 
+	err = _verify_data_map(layout);
+	if (unlikely(err))
+		return err;
+
 	objio_seg = kzalloc(sizeof(*objio_seg) +
 			(layout->olo_num_comps - 1) * sizeof(objio_seg->ods[0]),
 			GFP_KERNEL);
@@ -249,6 +313,406 @@ void objio_free_lseg(void *p)
 	kfree(objio_seg);
 }
 
+int objio_alloc_io_state(void *seg, struct objlayout_io_state **outp)
+{
+	struct objio_segment *objio_seg = seg;
+	struct objio_state *ios;
+	const unsigned first_size = sizeof(*ios) +
+				objio_seg->num_comps * sizeof(ios->per_dev[0]);
+
+	dprintk("%s: num_comps=%d\n", __func__, objio_seg->num_comps);
+	ios = kzalloc(first_size, GFP_KERNEL);
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
+enum pnfs_osd_errno osd_pri_2_pnfs_err(enum osd_err_priority oep)
+{
+	switch (oep) {
+	case OSD_ERR_PRI_NO_ERROR:
+		return (enum pnfs_osd_errno)0;
+
+	case OSD_ERR_PRI_CLEAR_PAGES:
+		BUG_ON(1);
+		return 0;
+
+	case OSD_ERR_PRI_RESOURCE:
+		return PNFS_OSD_ERR_RESOURCE;
+	case OSD_ERR_PRI_BAD_CRED:
+		return PNFS_OSD_ERR_BAD_CRED;
+	case OSD_ERR_PRI_NO_ACCESS:
+		return PNFS_OSD_ERR_NO_ACCESS;
+	case OSD_ERR_PRI_UNREACHABLE:
+		return PNFS_OSD_ERR_UNREACHABLE;
+	case OSD_ERR_PRI_NOT_FOUND:
+		return PNFS_OSD_ERR_NOT_FOUND;
+	case OSD_ERR_PRI_NO_SPACE:
+		return PNFS_OSD_ERR_NO_SPACE;
+	default:
+		WARN_ON(1);
+		/* fallthrough */
+	case OSD_ERR_PRI_EIO:
+		return PNFS_OSD_ERR_EIO;
+	}
+}
+
+static void _clear_bio(struct bio *bio)
+{
+	struct bio_vec *bv;
+	unsigned i;
+
+	__bio_for_each_segment(bv, bio, i, 0) {
+		unsigned this_count = bv->bv_len;
+
+		if (likely(PAGE_SIZE == this_count))
+			clear_highpage(bv->bv_page);
+		else
+			zero_user(bv->bv_page, bv->bv_offset, this_count);
+	}
+}
+
+static int _io_check(struct objio_state *ios, bool is_write)
+{
+	enum osd_err_priority oep = OSD_ERR_PRI_NO_ERROR;
+	int lin_ret = 0;
+	int i;
+
+	for (i = 0; i <  ios->numdevs; i++) {
+		struct osd_sense_info osi;
+		struct osd_request *or = ios->per_dev[i].or;
+		int ret;
+
+		if (!or)
+			continue;
+
+		ret = osd_req_decode_sense(or, &osi);
+		if (likely(!ret))
+			continue;
+
+		if (OSD_ERR_PRI_CLEAR_PAGES == osi.osd_err_pri) {
+			/* start read offset passed endof file */
+			BUG_ON(is_write);
+			_clear_bio(ios->per_dev[i].bio);
+			dprintk("%s: start read offset passed end of file "
+				"offset=0x%llx, length=0x%lx\n", __func__,
+				_LLU(ios->ol_state.offset), ios->length);
+
+			continue; /* we recovered */
+		}
+
+		if (osi.osd_err_pri >= oep) {
+			oep = osi.osd_err_pri;
+			lin_ret = ret;
+		}
+	}
+
+	return lin_ret;
+}
+
+/*
+ * Common IO state helpers.
+ */
+static void _io_free(struct objio_state *ios)
+{
+	unsigned i;
+
+	for (i = 0; i < ios->numdevs; i++) {
+		struct _objio_per_comp *per_dev = &ios->per_dev[i];
+
+		if (per_dev->or) {
+			osd_end_request(per_dev->or);
+			per_dev->or = NULL;
+		}
+
+		if (per_dev->bio) {
+			bio_put(per_dev->bio);
+			per_dev->bio = NULL;
+		}
+	}
+}
+
+static int _io_rw_pagelist(struct objio_state *ios)
+{
+	u64 length = ios->ol_state.count;
+	unsigned pgbase = ios->ol_state.pgbase;
+	unsigned nr_pages = ios->ol_state.nr_pages;
+	struct page **pages = ios->ol_state.pages;
+	struct bio *master_bio;
+	unsigned bio_size = min_t(unsigned, nr_pages, BIO_MAX_PAGES_KMALLOC);
+
+	master_bio = bio_kmalloc(GFP_KERNEL, bio_size);
+	if (unlikely(!master_bio)) {
+		dprintk("%s: Faild to alloc bio pages=%d\n",
+			__func__, bio_size);
+		return -ENOMEM;
+	}
+
+	ios->per_dev[0].bio = master_bio;
+
+	while (length) {
+		unsigned cur_len, added_len;
+
+		cur_len = min_t(u64, length, PAGE_SIZE - pgbase);
+
+		added_len = bio_add_pc_page(
+			osd_request_queue(ios->objio_seg->ods[0]),
+			master_bio, *pages, cur_len, pgbase);
+		if (unlikely(cur_len != added_len))
+			break;
+
+		pgbase = 0;
+		++pages;
+		length -= cur_len;
+		ios->length += cur_len;
+	}
+
+	/* this should never happen */
+	WARN_ON(!ios->length);
+
+	return 0;
+}
+
+static ssize_t _sync_done(struct objio_state *ios)
+{
+	struct completion *waiting = ios->private;
+
+	complete(waiting);
+	return 0;
+}
+
+static void _last_io(struct kref *kref)
+{
+	struct objio_state *ios = container_of(kref, struct objio_state, kref);
+
+	ios->done(ios);
+}
+
+static void _done_io(struct osd_request *or, void *p)
+{
+	struct objio_state *ios = p;
+
+	kref_put(&ios->kref, _last_io);
+}
+
+static ssize_t _io_exec(struct objio_state *ios)
+{
+	DECLARE_COMPLETION_ONSTACK(wait);
+	ssize_t status = 0; /* sync status */
+	unsigned i;
+	objio_done_fn saved_done_fn = ios->done;
+	bool sync = ios->ol_state.sync;
+
+	if (sync) {
+		ios->done = _sync_done;
+		ios->private = &wait;
+	}
+
+	kref_init(&ios->kref);
+
+	for (i = 0; i < ios->numdevs; i++) {
+		struct osd_request *or = ios->per_dev[i].or;
+
+		if (!or)
+			continue;
+
+		kref_get(&ios->kref);
+		osd_execute_request_async(or, _done_io, ios);
+	}
+
+	kref_put(&ios->kref, _last_io);
+
+	if (sync) {
+		wait_for_completion(&wait);
+		status = saved_done_fn(ios);
+	}
+
+	return status;
+}
+
+/*
+ * read
+ */
+static ssize_t _read_done(struct objio_state *ios)
+{
+	ssize_t status;
+	int ret = _io_check(ios, false);
+
+	_io_free(ios);
+
+	if (likely(!ret))
+		status = ios->length;
+	else
+		status = ret;
+
+	objlayout_read_done(&ios->ol_state, status, ios->ol_state.sync);
+	return status;
+}
+
+static ssize_t _read_exec(struct objio_state *ios)
+{
+	struct osd_request *or = NULL;
+	struct _objio_per_comp *per_dev = &ios->per_dev[0];
+	unsigned dev = 0;
+	struct pnfs_osd_object_cred *cred =
+			&ios->objio_seg->layout->olo_comps[dev];
+	struct osd_obj_id obj = {
+		.partition = cred->oc_object_id.oid_partition_id,
+		.id = cred->oc_object_id.oid_object_id,
+	};
+	int ret;
+
+	or = osd_start_request(ios->objio_seg->ods[dev], GFP_KERNEL);
+	if (unlikely(!or)) {
+		ret = -ENOMEM;
+		goto err;
+	}
+	per_dev->or = or;
+	ios->numdevs++;
+
+	osd_req_read(or, &obj, ios->ol_state.offset, per_dev->bio, ios->length);
+
+	ret = osd_finalize_request(or, 0, cred->oc_cap.cred, NULL);
+	if (ret) {
+		dprintk("%s: Faild to osd_finalize_request() => %d\n",
+			__func__, ret);
+		goto err;
+	}
+
+	dprintk("%s: obj=0x%llx start=0x%llx length=0x%lx\n",
+		__func__, obj.id, _LLU(ios->ol_state.offset), ios->length);
+	ios->done = _read_done;
+	return _io_exec(ios); /* In sync mode exec returns the io status */
+
+err:
+	_io_free(ios);
+	return ret;
+}
+
+ssize_t objio_read_pagelist(struct objlayout_io_state *ol_state)
+{
+	struct objio_state *ios = container_of(ol_state, struct objio_state,
+					       ol_state);
+	int ret;
+
+	ret = _io_rw_pagelist(ios);
+	if (unlikely(ret))
+		return ret;
+
+	return _read_exec(ios);
+}
+
+/*
+ * write
+ */
+static ssize_t _write_done(struct objio_state *ios)
+{
+	ssize_t status;
+	int ret = _io_check(ios, true);
+
+	_io_free(ios);
+
+	if (likely(!ret)) {
+		/* FIXME: should be based on the OSD's persistence model
+		 * See OSD2r05 Section 4.13 Data persistence model */
+		ios->ol_state.committed = NFS_FILE_SYNC;
+		status = ios->length;
+	} else {
+		status = ret;
+	}
+
+	objlayout_write_done(&ios->ol_state, status, ios->ol_state.sync);
+	return status;
+}
+
+static int _write_exec(struct objio_state *ios)
+{
+	int i, ret;
+	struct bio *master_bio = ios->per_dev[0].bio;
+
+	for (i = 0; i < ios->objio_seg->num_comps; i++) {
+		struct osd_request *or = NULL;
+		struct pnfs_osd_object_cred *cred =
+					&ios->objio_seg->layout->olo_comps[i];
+		struct osd_obj_id obj = {cred->oc_object_id.oid_partition_id,
+					 cred->oc_object_id.oid_object_id};
+		struct _objio_per_comp *per_dev = &ios->per_dev[i];
+		struct bio *bio;
+
+		or = osd_start_request(ios->objio_seg->ods[i], GFP_KERNEL);
+		if (unlikely(!or)) {
+			ret = -ENOMEM;
+			goto err;
+		}
+		per_dev->or = or;
+		ios->numdevs++;
+
+		if (i != 0) {
+			bio = bio_kmalloc(GFP_KERNEL, master_bio->bi_max_vecs);
+			if (unlikely(!bio)) {
+				dprintk("Faild to allocate BIO size=%u\n",
+					master_bio->bi_max_vecs);
+				ret = -ENOMEM;
+				goto err;
+			}
+
+			__bio_clone(bio, master_bio);
+			bio->bi_bdev = NULL;
+			bio->bi_next = NULL;
+			per_dev->bio = bio;
+		} else {
+			bio = master_bio;
+			bio->bi_rw |= REQ_WRITE;
+		}
+
+		osd_req_write(or, &obj, ios->ol_state.offset, bio, ios->length);
+
+		ret = osd_finalize_request(or, 0, cred->oc_cap.cred, NULL);
+		if (ret) {
+			dprintk("%s: Faild to osd_finalize_request() => %d\n",
+				__func__, ret);
+			goto err;
+		}
+
+		dprintk("%s: [%d] obj=0x%llx start=0x%llx length=0x%lx\n",
+			__func__, i, obj.id, _LLU(ios->ol_state.offset),
+			ios->length);
+	}
+
+	ios->done = _write_done;
+	return _io_exec(ios); /* In sync mode exec returns the io->status */
+
+err:
+	_io_free(ios);
+	return ret;
+}
+
+ssize_t objio_write_pagelist(struct objlayout_io_state *ol_state, bool stable)
+{
+	struct objio_state *ios = container_of(ol_state, struct objio_state,
+					       ol_state);
+	int ret;
+
+	/* TODO: ios->stable = stable; */
+	ret = _io_rw_pagelist(ios);
+	if (unlikely(ret))
+		return ret;
+
+	return _write_exec(ios);
+}
+
 static struct pnfs_layoutdriver_type objlayout_type = {
 	.id = LAYOUT_OSD2_OBJECTS,
 	.name = "LAYOUT_OSD2_OBJECTS",
@@ -256,8 +720,14 @@ static struct pnfs_layoutdriver_type objlayout_type = {
 	.set_layoutdriver        = objlayout_set_layoutdriver,
 	.unset_layoutdriver      = objlayout_unset_layoutdriver,
 
+	.alloc_layout_hdr        = objlayout_alloc_layout_hdr,
+	.free_layout_hdr         = objlayout_free_layout_hdr,
+
 	.alloc_lseg              = objlayout_alloc_lseg,
 	.free_lseg               = objlayout_free_lseg,
+
+	.read_pagelist           = objlayout_read_pagelist,
+	.write_pagelist          = objlayout_write_pagelist,
 };
 
 void *objio_init_mt(void)
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 75c158a..04fcadd 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -44,6 +44,32 @@
 struct pnfs_client_operations *pnfs_client_ops;
 
 /*
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
  * Unmarshall layout and store it in pnfslay.
  */
 struct pnfs_layout_segment *
@@ -219,3 +245,254 @@ objlayout_unset_layoutdriver(struct nfs_server *server)
 	objio_fini_mt(server->pnfs_ld_data);
 	return 0;
 }
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
+	pnfs_ld_read_done(rdata);
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
+		pnfs_ld_read_done(rdata);
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
+	pnfs_ld_write_done(wdata);
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
+		pnfs_ld_write_done(wdata);
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
diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
index 55caa64..54dbd55 100644
--- a/fs/nfs/objlayout/objlayout.h
+++ b/fs/nfs/objlayout/objlayout.h
@@ -55,6 +55,39 @@ struct objlayout_segment {
 };
 
 /*
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
  * Raid engine I/O API
  */
 extern void *objio_init_mt(void);
@@ -66,12 +99,35 @@ extern int objio_alloc_lseg(void **outp,
 	struct pnfs_osd_layout *layout);
 extern void objio_free_lseg(void *p);
 
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
 /*
  * exported generic objects function vectors
  */
+
 extern int objlayout_set_layoutdriver(struct nfs_server *);
 extern int objlayout_unset_layoutdriver(struct nfs_server *);
 
+extern struct pnfs_layout_hdr *objlayout_alloc_layout_hdr(struct inode *);
+extern void objlayout_free_layout_hdr(struct pnfs_layout_hdr *);
+
 extern struct pnfs_layout_segment *objlayout_alloc_lseg(
 	struct pnfs_layout_hdr *,
 	struct nfs4_layoutget_res *);
@@ -81,4 +137,11 @@ extern int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
 	struct nfs4_deviceid *d_id, struct pnfs_osd_deviceaddr **deviceaddr);
 extern void objlayout_put_deviceinfo(struct pnfs_osd_deviceaddr *deviceaddr);
 
+extern enum pnfs_try_status objlayout_read_pagelist(
+	struct nfs_read_data *);
+
+extern enum pnfs_try_status objlayout_write_pagelist(
+	struct nfs_write_data *,
+	int how);
+
 #endif /* _OBJLAYOUT_H */
-- 
1.7.3.4


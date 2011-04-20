Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:57188 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366Ab1DTR24 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 13:28:56 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC 21/27] pnfs-obj: objio_osd real IO implementation
Date: Wed, 20 Apr 2011 20:28:53 +0300
Message-Id: <1303320533-21750-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DAF0DE1.6020609@panasas.com>
References: <4DAF0DE1.6020609@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Boaz Harrosh <bharrosh@panasas.com>

With the use of the in-kernel osd library. Implement read/write
of data from/to osd-objects according to information specified
in the objects-layout.

TODO: Only a limited Mirror arrangement is implemented. stripping/raid
      will come in at later patches.

[pnfs-obj: objio: cleanup un-indent _read_mirrors]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[added FIXME comment]
[use REQ flags rather than BIO flags]
  As they were converged starting 2.6.36
[fix REQ flags usage]
fixes "pnfs-obj use REQ flags rather than BIO flags"

Cc: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |  418 +++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 415 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index a24bf82..75d4ebb 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -142,11 +142,26 @@ struct objio_segment {
 	struct osd_dev	*ods[1];
 };
 
+struct objio_state;
+typedef ssize_t (*objio_done_fn)(struct objio_state *ios);
+
 struct objio_state {
 	/* Generic layer */
 	struct objlayout_io_state ol_state;
 
 	struct objio_segment *objio_seg;
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
 };
 
 /* Send and wait for a get_device_info of devices in the layout,
@@ -232,6 +247,38 @@ out:
 	return err;
 }
 
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
@@ -240,6 +287,10 @@ int objio_alloc_lseg(void **outp,
 	struct objio_segment *objio_seg;
 	int err;
 
+	err = _verify_data_map(layout);
+	if (unlikely(err))
+		return err;
+
 	objio_seg = kzalloc(sizeof(*objio_seg) +
 			(layout->olo_num_comps - 1) * sizeof(objio_seg->ods[0]),
 			GFP_KERNEL);
@@ -272,8 +323,11 @@ int objio_alloc_io_state(void *seg, struct objlayout_io_state **outp)
 {
 	struct objio_segment *objio_seg = seg;
 	struct objio_state *ios;
+	const unsigned first_size = sizeof(*ios) +
+				objio_seg->num_comps * sizeof(ios->per_dev[0]);
 
-	ios = kzalloc(sizeof(*ios), GFP_KERNEL);
+	dprintk("%s: num_comps=%d\n", __func__, objio_seg->num_comps);
+	ios = kzalloc(first_size, GFP_KERNEL);
 	if (unlikely(!ios))
 		return -ENOMEM;
 
@@ -291,20 +345,378 @@ void objio_free_io_state(struct objlayout_io_state *ol_state)
 	kfree(ios);
 }
 
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
 /*
  * read
  */
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
 ssize_t objio_read_pagelist(struct objlayout_io_state *ol_state)
 {
-	return -EIO;
+	struct objio_state *ios = container_of(ol_state, struct objio_state,
+					       ol_state);
+	int ret;
+
+	ret = _io_rw_pagelist(ios);
+	if (unlikely(ret))
+		return ret;
+
+	return _read_exec(ios);
 }
 
 /*
  * write
  */
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
 ssize_t objio_write_pagelist(struct objlayout_io_state *ol_state, bool stable)
 {
-	return -EIO;
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
 }
 
 /*
-- 
1.7.3.4


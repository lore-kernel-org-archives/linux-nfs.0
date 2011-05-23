Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:9127 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756329Ab1EWQia (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 12:38:30 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH v6 20/26] pnfs-obj: osd raid engine read/write implementation
Date: Mon, 23 May 2011 19:38:19 +0300
Message-Id: <1306168699-11685-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DDA8C3D.5080706@panasas.com>
References: <4DDA8C3D.5080706@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Boaz Harrosh <bharrosh@panasas.com>

With the use of the in-kernel osd library. Implement read/write
of data from/to osd-objects according to information specified
in the objects-layout.

Support for stripping over mirrors with a received stripe_unit.
There are however a few constrains which are not supported:
 1. Stripe Unit must be a multiple of PAGE_SIZE
 2. stripe length (stripe_unit * number_of_stripes) can not be
    bigger then 32bit.

Also support raid-groups and partial-layout. Partial-layout is
when not all the groups are received on the line, addressing
only a partial range of the file.

TODO:
  Only raid0! raid 4/5/6 support will come at later stage

A none supported layout will send IO through the MDS

[Important fallout from the last rebase]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[gfp_flags]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |  603 ++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/objlayout/objlayout.c |  254 ++++++++++++++++++
 fs/nfs/objlayout/objlayout.h |   42 +++
 3 files changed, 899 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index a71f58e..04fc2bf 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -46,6 +46,10 @@
 
 #define _LLU(x) ((unsigned long long)x)
 
+enum { BIO_MAX_PAGES_KMALLOC =
+		(PAGE_SIZE - sizeof(struct bio)) / sizeof(struct bio_vec),
+};
+
 struct objio_dev_ent {
 	struct nfs4_deviceid_node id_node;
 	struct osd_dev *od;
@@ -126,6 +130,31 @@ OBJIO_LSEG(struct pnfs_layout_segment *lseg)
 	return container_of(lseg, struct objio_segment, lseg);
 }
 
+struct objio_state;
+typedef ssize_t (*objio_done_fn)(struct objio_state *ios);
+
+struct objio_state {
+	/* Generic layer */
+	struct objlayout_io_state ol_state;
+
+	struct objio_segment *layout;
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
+		unsigned long length;
+		u64 offset;
+		unsigned dev;
+	} per_dev[];
+};
+
 /* Send and wait for a get_device_info of devices in the layout,
    then look them up with the osd_initiator library */
 static struct objio_dev_ent *_device_lookup(struct pnfs_layout_hdr *pnfslay,
@@ -347,6 +376,576 @@ void objio_free_lseg(struct pnfs_layout_segment *lseg)
 	kfree(objio_seg);
 }
 
+int objio_alloc_io_state(struct pnfs_layout_segment *lseg,
+			 struct objlayout_io_state **outp,
+			 gfp_t gfp_flags)
+{
+	struct objio_segment *objio_seg = OBJIO_LSEG(lseg);
+	struct objio_state *ios;
+	const unsigned first_size = sizeof(*ios) +
+				objio_seg->num_comps * sizeof(ios->per_dev[0]);
+
+	dprintk("%s: num_comps=%d\n", __func__, objio_seg->num_comps);
+	ios = kzalloc(first_size, gfp_flags);
+	if (unlikely(!ios))
+		return -ENOMEM;
+
+	ios->layout = objio_seg;
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
+		unsigned dev;
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
+				_LLU(ios->per_dev[i].offset),
+				ios->per_dev[i].length);
+
+			continue; /* we recovered */
+		}
+		dev = ios->per_dev[i].dev;
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
+struct osd_dev *_io_od(struct objio_state *ios, unsigned dev)
+{
+	unsigned min_dev = ios->layout->comps_index;
+	unsigned max_dev = min_dev + ios->layout->num_comps;
+
+	BUG_ON(dev < min_dev || max_dev <= dev);
+	return ios->layout->ods[dev - min_dev]->od;
+}
+
+struct _striping_info {
+	u64 obj_offset;
+	u64 group_length;
+	unsigned dev;
+	unsigned unit_off;
+};
+
+static void _calc_stripe_info(struct objio_state *ios, u64 file_offset,
+			      struct _striping_info *si)
+{
+	u32	stripe_unit = ios->layout->stripe_unit;
+	u32	group_width = ios->layout->group_width;
+	u64	group_depth = ios->layout->group_depth;
+	u32	U = stripe_unit * group_width;
+
+	u64	T = U * group_depth;
+	u64	S = T * ios->layout->group_count;
+	u64	M = div64_u64(file_offset, S);
+
+	/*
+	G = (L - (M * S)) / T
+	H = (L - (M * S)) % T
+	*/
+	u64	LmodU = file_offset - M * S;
+	u32	G = div64_u64(LmodU, T);
+	u64	H = LmodU - G * T;
+
+	u32	N = div_u64(H, U);
+
+	div_u64_rem(file_offset, stripe_unit, &si->unit_off);
+	si->obj_offset = si->unit_off + (N * stripe_unit) +
+				  (M * group_depth * stripe_unit);
+
+	/* "H - (N * U)" is just "H % U" so it's bound to u32 */
+	si->dev = (u32)(H - (N * U)) / stripe_unit + G * group_width;
+	si->dev *= ios->layout->mirrors_p1;
+
+	si->group_length = T - H;
+}
+
+static int _add_stripe_unit(struct objio_state *ios,  unsigned *cur_pg,
+		unsigned pgbase, struct _objio_per_comp *per_dev, int cur_len,
+		gfp_t gfp_flags)
+{
+	unsigned pg = *cur_pg;
+	struct request_queue *q =
+			osd_request_queue(_io_od(ios, per_dev->dev));
+
+	per_dev->length += cur_len;
+
+	if (per_dev->bio == NULL) {
+		unsigned stripes = ios->layout->num_comps /
+						     ios->layout->mirrors_p1;
+		unsigned pages_in_stripe = stripes *
+				      (ios->layout->stripe_unit / PAGE_SIZE);
+		unsigned bio_size = (ios->ol_state.nr_pages + pages_in_stripe) /
+				    stripes;
+
+		per_dev->bio = bio_kmalloc(gfp_flags, bio_size);
+		if (unlikely(!per_dev->bio)) {
+			dprintk("Faild to allocate BIO size=%u\n", bio_size);
+			return -ENOMEM;
+		}
+	}
+
+	while (cur_len > 0) {
+		unsigned pglen = min_t(unsigned, PAGE_SIZE - pgbase, cur_len);
+		unsigned added_len;
+
+		BUG_ON(ios->ol_state.nr_pages <= pg);
+		cur_len -= pglen;
+
+		added_len = bio_add_pc_page(q, per_dev->bio,
+					ios->ol_state.pages[pg], pglen, pgbase);
+		if (unlikely(pglen != added_len))
+			return -ENOMEM;
+		pgbase = 0;
+		++pg;
+	}
+	BUG_ON(cur_len);
+
+	*cur_pg = pg;
+	return 0;
+}
+
+static int _prepare_one_group(struct objio_state *ios, u64 length,
+			      struct _striping_info *si, unsigned *last_pg,
+			      gfp_t gfp_flags)
+{
+	unsigned stripe_unit = ios->layout->stripe_unit;
+	unsigned mirrors_p1 = ios->layout->mirrors_p1;
+	unsigned devs_in_group = ios->layout->group_width * mirrors_p1;
+	unsigned dev = si->dev;
+	unsigned first_dev = dev - (dev % devs_in_group);
+	unsigned max_comp = ios->numdevs ? ios->numdevs - mirrors_p1 : 0;
+	unsigned cur_pg = *last_pg;
+	int ret = 0;
+
+	while (length) {
+		struct _objio_per_comp *per_dev = &ios->per_dev[dev];
+		unsigned cur_len, page_off = 0;
+
+		if (!per_dev->length) {
+			per_dev->dev = dev;
+			if (dev < si->dev) {
+				per_dev->offset = si->obj_offset + stripe_unit -
+								   si->unit_off;
+				cur_len = stripe_unit;
+			} else if (dev == si->dev) {
+				per_dev->offset = si->obj_offset;
+				cur_len = stripe_unit - si->unit_off;
+				page_off = si->unit_off & ~PAGE_MASK;
+				BUG_ON(page_off &&
+				      (page_off != ios->ol_state.pgbase));
+			} else { /* dev > si->dev */
+				per_dev->offset = si->obj_offset - si->unit_off;
+				cur_len = stripe_unit;
+			}
+
+			if (max_comp < dev)
+				max_comp = dev;
+		} else {
+			cur_len = stripe_unit;
+		}
+		if (cur_len >= length)
+			cur_len = length;
+
+		ret = _add_stripe_unit(ios, &cur_pg, page_off , per_dev,
+				       cur_len, gfp_flags);
+		if (unlikely(ret))
+			goto out;
+
+		dev += mirrors_p1;
+		dev = (dev % devs_in_group) + first_dev;
+
+		length -= cur_len;
+		ios->length += cur_len;
+	}
+out:
+	ios->numdevs = max_comp + mirrors_p1;
+	*last_pg = cur_pg;
+	return ret;
+}
+
+static int _io_rw_pagelist(struct objio_state *ios, gfp_t gfp_flags)
+{
+	u64 length = ios->ol_state.count;
+	u64 offset = ios->ol_state.offset;
+	struct _striping_info si;
+	unsigned last_pg = 0;
+	int ret = 0;
+
+	while (length) {
+		_calc_stripe_info(ios, offset, &si);
+
+		if (length < si.group_length)
+			si.group_length = length;
+
+		ret = _prepare_one_group(ios, si.group_length, &si, &last_pg, gfp_flags);
+		if (unlikely(ret))
+			goto out;
+
+		offset += si.group_length;
+		length -= si.group_length;
+	}
+
+out:
+	if (!ios->length)
+		return ret;
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
+static int _read_mirrors(struct objio_state *ios, unsigned cur_comp)
+{
+	struct osd_request *or = NULL;
+	struct _objio_per_comp *per_dev = &ios->per_dev[cur_comp];
+	unsigned dev = per_dev->dev;
+	struct pnfs_osd_object_cred *cred =
+			&ios->layout->comps[dev];
+	struct osd_obj_id obj = {
+		.partition = cred->oc_object_id.oid_partition_id,
+		.id = cred->oc_object_id.oid_object_id,
+	};
+	int ret;
+
+	or = osd_start_request(_io_od(ios, dev), GFP_KERNEL);
+	if (unlikely(!or)) {
+		ret = -ENOMEM;
+		goto err;
+	}
+	per_dev->or = or;
+
+	osd_req_read(or, &obj, per_dev->offset, per_dev->bio, per_dev->length);
+
+	ret = osd_finalize_request(or, 0, cred->oc_cap.cred, NULL);
+	if (ret) {
+		dprintk("%s: Faild to osd_finalize_request() => %d\n",
+			__func__, ret);
+		goto err;
+	}
+
+	dprintk("%s:[%d] dev=%d obj=0x%llx start=0x%llx length=0x%lx\n",
+		__func__, cur_comp, dev, obj.id, _LLU(per_dev->offset),
+		per_dev->length);
+
+err:
+	return ret;
+}
+
+static ssize_t _read_exec(struct objio_state *ios)
+{
+	unsigned i;
+	int ret;
+
+	for (i = 0; i < ios->numdevs; i += ios->layout->mirrors_p1) {
+		if (!ios->per_dev[i].length)
+			continue;
+		ret = _read_mirrors(ios, i);
+		if (unlikely(ret))
+			goto err;
+	}
+
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
+	ret = _io_rw_pagelist(ios, GFP_KERNEL);
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
+static int _write_mirrors(struct objio_state *ios, unsigned cur_comp)
+{
+	struct _objio_per_comp *master_dev = &ios->per_dev[cur_comp];
+	unsigned dev = ios->per_dev[cur_comp].dev;
+	unsigned last_comp = cur_comp + ios->layout->mirrors_p1;
+	int ret;
+
+	for (; cur_comp < last_comp; ++cur_comp, ++dev) {
+		struct osd_request *or = NULL;
+		struct pnfs_osd_object_cred *cred =
+					&ios->layout->comps[dev];
+		struct osd_obj_id obj = {
+			.partition = cred->oc_object_id.oid_partition_id,
+			.id = cred->oc_object_id.oid_object_id,
+		};
+		struct _objio_per_comp *per_dev = &ios->per_dev[cur_comp];
+		struct bio *bio;
+
+		or = osd_start_request(_io_od(ios, dev), GFP_NOFS);
+		if (unlikely(!or)) {
+			ret = -ENOMEM;
+			goto err;
+		}
+		per_dev->or = or;
+
+		if (per_dev != master_dev) {
+			bio = bio_kmalloc(GFP_NOFS,
+					  master_dev->bio->bi_max_vecs);
+			if (unlikely(!bio)) {
+				dprintk("Faild to allocate BIO size=%u\n",
+					master_dev->bio->bi_max_vecs);
+				ret = -ENOMEM;
+				goto err;
+			}
+
+			__bio_clone(bio, master_dev->bio);
+			bio->bi_bdev = NULL;
+			bio->bi_next = NULL;
+			per_dev->bio = bio;
+			per_dev->dev = dev;
+			per_dev->length = master_dev->length;
+			per_dev->offset =  master_dev->offset;
+		} else {
+			bio = master_dev->bio;
+			bio->bi_rw |= REQ_WRITE;
+		}
+
+		osd_req_write(or, &obj, per_dev->offset, bio, per_dev->length);
+
+		ret = osd_finalize_request(or, 0, cred->oc_cap.cred, NULL);
+		if (ret) {
+			dprintk("%s: Faild to osd_finalize_request() => %d\n",
+				__func__, ret);
+			goto err;
+		}
+
+		dprintk("%s:[%d] dev=%d obj=0x%llx start=0x%llx length=0x%lx\n",
+			__func__, cur_comp, dev, obj.id, _LLU(per_dev->offset),
+			per_dev->length);
+	}
+
+err:
+	return ret;
+}
+
+static ssize_t _write_exec(struct objio_state *ios)
+{
+	unsigned i;
+	int ret;
+
+	for (i = 0; i < ios->numdevs; i += ios->layout->mirrors_p1) {
+		if (!ios->per_dev[i].length)
+			continue;
+		ret = _write_mirrors(ios, i);
+		if (unlikely(ret))
+			goto err;
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
+	ret = _io_rw_pagelist(ios, GFP_NOFS);
+	if (unlikely(ret))
+		return ret;
+
+	return _write_exec(ios);
+}
+
+/*
+ * objlayout_pg_test(). Called by nfs_can_coalesce_requests()
+ *
+ * return 1 :  coalesce page
+ * return 0 :  don't coalesce page
+ */
+int
+objlayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
+		   struct nfs_page *req)
+{
+	return 1;
+}
 
 static struct pnfs_layoutdriver_type objlayout_type = {
 	.id = LAYOUT_OSD2_OBJECTS,
@@ -358,6 +957,10 @@ static struct pnfs_layoutdriver_type objlayout_type = {
 	.alloc_lseg              = objlayout_alloc_lseg,
 	.free_lseg               = objlayout_free_lseg,
 
+	.read_pagelist           = objlayout_read_pagelist,
+	.write_pagelist          = objlayout_write_pagelist,
+	.pg_test                 = objlayout_pg_test,
+
 	.free_deviceid_node	 = objio_free_deviceid_node,
 };
 
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index f14b4da..5157ef6 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -129,6 +129,260 @@ objlayout_free_lseg(struct pnfs_layout_segment *lseg)
 }
 
 /*
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
+			void *rpcdata,
+			gfp_t gfp_flags)
+{
+	struct objlayout_io_state *state;
+	u64 lseg_end_offset;
+
+	dprintk("%s: allocating io_state\n", __func__);
+	if (objio_alloc_io_state(lseg, &state, gfp_flags))
+		return NULL;
+
+	BUG_ON(offset < lseg->pls_range.offset);
+	lseg_end_offset = end_offset(lseg->pls_range.offset,
+				     lseg->pls_range.length);
+	BUG_ON(offset >= lseg_end_offset);
+	if (offset + count > lseg_end_offset) {
+		count = lseg->pls_range.length -
+				(offset - lseg->pls_range.offset);
+		dprintk("%s: truncated count %Zd\n", __func__, count);
+	}
+
+	if (pgbase > PAGE_SIZE) {
+		pages += pgbase >> PAGE_SHIFT;
+		pgbase &= ~PAGE_MASK;
+	}
+
+	state->lseg = lseg;
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
+					 rdata->lseg, rdata,
+					 GFP_KERNEL);
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
+					 wdata->lseg, wdata,
+					 GFP_NOFS);
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
  * Get Device Info API for io engines
  */
 struct objlayout_deviceinfo {
diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
index fa02621..9a405e8 100644
--- a/fs/nfs/objlayout/objlayout.h
+++ b/fs/nfs/objlayout/objlayout.h
@@ -59,6 +59,26 @@ OBJLAYOUT(struct pnfs_layout_hdr *lo)
 }
 
 /*
+ * per-I/O operation state
+ * embedded in objects provider io_state data structure
+ */
+struct objlayout_io_state {
+	struct pnfs_layout_segment *lseg;
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
 extern int objio_alloc_lseg(struct pnfs_layout_segment **outp,
@@ -68,9 +88,24 @@ extern int objio_alloc_lseg(struct pnfs_layout_segment **outp,
 	gfp_t gfp_flags);
 extern void objio_free_lseg(struct pnfs_layout_segment *lseg);
 
+extern int objio_alloc_io_state(
+	struct pnfs_layout_segment *lseg,
+	struct objlayout_io_state **outp,
+	gfp_t gfp_flags);
+extern void objio_free_io_state(struct objlayout_io_state *state);
+
+extern ssize_t objio_read_pagelist(struct objlayout_io_state *ol_state);
+extern ssize_t objio_write_pagelist(struct objlayout_io_state *ol_state,
+				    bool stable);
+
 /*
  * callback API
  */
+extern void objlayout_read_done(struct objlayout_io_state *state,
+				ssize_t status, bool sync);
+extern void objlayout_write_done(struct objlayout_io_state *state,
+				 ssize_t status, bool sync);
+
 extern int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
 	struct nfs4_deviceid *d_id, struct pnfs_osd_deviceaddr **deviceaddr,
 	gfp_t gfp_flags);
@@ -89,4 +124,11 @@ extern struct pnfs_layout_segment *objlayout_alloc_lseg(
 	gfp_t gfp_flags);
 extern void objlayout_free_lseg(struct pnfs_layout_segment *);
 
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


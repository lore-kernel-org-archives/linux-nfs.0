Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38076 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753724Ab1EIRLs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 13:11:48 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Boaz Harrosh <bharrosh@panasas.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 28/29] pnfs-obj: objio_osd: RAID0 support
Date: Mon,  9 May 2011 20:11:39 +0300
Message-Id: <1304961099-4831-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DC81E8C.6040901@panasas.com>
References: <4DC81E8C.6040901@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Boaz Harrosh <bharrosh@panasas.com>

Support for stripping over mirrors with a received stripe_unit.
There are however a few constrains which are not supported:
1. Stripe Unit must be a multiple of PAGE_SIZE
2. stripe length (stripe_unit * number_of_stripes) can not be
   bigger then 32bit.
3. group width/depth not yet supported

[pnfs-obj: RAID0 micro optimization and cleanups]
[pnfs-obj: objio_osd: Prepare for groups]
[Support partial layouts]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |  293 ++++++++++++++++++++++++++++++++----------
 1 files changed, 227 insertions(+), 66 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 0988e1e..6da4aa2 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -131,6 +131,10 @@ out:
 struct objio_segment {
 	struct pnfs_osd_layout *layout;
 
+	unsigned mirrors_p1;
+	unsigned stripe_unit;
+	unsigned group_width;	/* Data stripe_units without integrity comps */
+
 	unsigned num_comps;
 	/* variable length */
 	struct osd_dev	*ods[1];
@@ -238,35 +242,44 @@ struct objio_state {
 	struct _objio_per_comp {
 		struct bio *bio;
 		struct osd_request *or;
+		unsigned long length;
+		u64 offset;
+		unsigned dev;
 	} per_dev[];
 };
 
 static int _verify_data_map(struct pnfs_osd_layout *layout)
 {
 	struct pnfs_osd_data_map *data_map = &layout->olo_map;
+	u64 stripe_length;
 
-/* FIXME: Only Mirror arangment for now. if not so, do not mount */
+/* FIXME: Only raid0 !group_width/depth for now. if not so, do not mount */
 	if (data_map->odm_group_width || data_map->odm_group_depth) {
 		printk(KERN_ERR "Group width/depth not supported\n");
 		return -ENOTSUPP;
 	}
-	if (data_map->odm_num_comps != layout->olo_num_comps) {
-		printk(KERN_ERR "odm_num_comps(%u) != olo_num_comps(%u)\n",
-			  data_map->odm_num_comps, layout->olo_num_comps);
-		return -ENOTSUPP;
-	}
 	if (data_map->odm_raid_algorithm != PNFS_OSD_RAID_0) {
 		printk(KERN_ERR "Only RAID_0 for now\n");
 		return -ENOTSUPP;
 	}
-	if (data_map->odm_num_comps != data_map->odm_mirror_cnt + 1) {
-		printk(KERN_ERR "Mirror only!, num_comps=%u mirrors=%u\n",
+	if (0 != (data_map->odm_num_comps % (data_map->odm_mirror_cnt + 1))) {
+		printk(KERN_ERR "Data Map wrong, num_comps=%u mirrors=%u\n",
 			  data_map->odm_num_comps, data_map->odm_mirror_cnt);
+		return -EINVAL;
+	}
+
+	stripe_length = data_map->odm_stripe_unit * (data_map->odm_num_comps /
+						(data_map->odm_mirror_cnt + 1));
+	if (stripe_length >= (1ULL << 32)) {
+		printk(KERN_ERR "Total Stripe length(0x%llx)"
+			  " >= 32bit is not supported\n", _LLU(stripe_length));
 		return -ENOTSUPP;
 	}
 
-	if (data_map->odm_stripe_unit != PAGE_SIZE) {
-		printk(KERN_ERR "Stripe Unit != PAGE_SIZE not supported\n");
+	if (0 != (data_map->odm_stripe_unit & ~PAGE_MASK)) {
+		printk(KERN_ERR "Stripe Unit(0x%llx)"
+			  " must be Multples of PAGE_SIZE(0x%lx)\n",
+			  _LLU(data_map->odm_stripe_unit), PAGE_SIZE);
 		return -ENOTSUPP;
 	}
 
@@ -296,6 +309,11 @@ int objio_alloc_lseg(void **outp,
 	if (err)
 		goto free_seg;
 
+	objio_seg->mirrors_p1 = layout->olo_map.odm_mirror_cnt + 1;
+	objio_seg->stripe_unit = layout->olo_map.odm_stripe_unit;
+	objio_seg->group_width = layout->olo_map.odm_num_comps /
+							objio_seg->mirrors_p1;
+
 	*outp = objio_seg;
 	return 0;
 
@@ -412,13 +430,15 @@ static int _io_check(struct objio_state *ios, bool is_write)
 			_clear_bio(ios->per_dev[i].bio);
 			dprintk("%s: start read offset passed end of file "
 				"offset=0x%llx, length=0x%lx\n", __func__,
-				_LLU(ios->ol_state.offset), ios->length);
+				_LLU(ios->per_dev[i].offset),
+				ios->per_dev[i].length);
 
 			continue; /* we recovered */
 		}
-		objlayout_io_set_result(&ios->ol_state, i,
+		objlayout_io_set_result(&ios->ol_state, ios->per_dev[i].dev,
 					osd_pri_2_pnfs_err(osi.osd_err_pri),
-					ios->ol_state.offset, ios->length,
+					ios->per_dev[i].offset,
+					ios->per_dev[i].length,
 					is_write);
 
 		if (osi.osd_err_pri >= oep) {
@@ -452,47 +472,150 @@ static void _io_free(struct objio_state *ios)
 	}
 }
 
-static int _io_rw_pagelist(struct objio_state *ios)
+struct osd_dev * _io_od(struct objio_state *ios, unsigned dev)
 {
-	u64 length = ios->ol_state.count;
-	unsigned pgbase = ios->ol_state.pgbase;
-	unsigned nr_pages = ios->ol_state.nr_pages;
-	struct page **pages = ios->ol_state.pages;
-	struct bio *master_bio;
-	unsigned bio_size = min_t(unsigned, nr_pages, BIO_MAX_PAGES_KMALLOC);
-
-	master_bio = bio_kmalloc(GFP_KERNEL, bio_size);
-	if (unlikely(!master_bio)) {
-		dprintk("%s: Faild to alloc bio pages=%d\n",
-			__func__, bio_size);
-		return -ENOMEM;
+	unsigned min_dev = ios->objio_seg->layout->olo_comps_index;
+	unsigned max_dev = min_dev + ios->ol_state.num_comps;
+
+	BUG_ON(dev < min_dev || max_dev <= dev);
+	return ios->objio_seg->ods[dev - min_dev];
+}
+
+struct _striping_info {
+	u64 obj_offset;
+	unsigned dev;
+	unsigned unit_off;
+};
+
+static void _calc_stripe_info(struct objio_state *ios, u64 file_offset,
+			      struct _striping_info *si)
+{
+	u32	stripe_unit = ios->objio_seg->stripe_unit;
+	u32	group_width = ios->objio_seg->group_width;
+	u32	U = stripe_unit * group_width;
+
+	u32	LmodU;
+	u64 	N = div_u64_rem(file_offset, U, &LmodU);
+
+	si->unit_off = LmodU % stripe_unit;
+	si->obj_offset = N * stripe_unit + si->unit_off;
+	si->dev = LmodU / stripe_unit;
+	si->dev *= ios->objio_seg->mirrors_p1;
+}
+
+static int _add_stripe_unit(struct objio_state *ios,  unsigned *cur_pg,
+		unsigned pgbase, struct _objio_per_comp *per_dev, int cur_len)
+{
+	unsigned pg = *cur_pg;
+	struct request_queue *q =
+			osd_request_queue(_io_od(ios, per_dev->dev));
+
+	per_dev->length += cur_len;
+
+	if (per_dev->bio == NULL) {
+		unsigned stripes = ios->ol_state.num_comps /
+						     ios->objio_seg->mirrors_p1;
+		unsigned pages_in_stripe = stripes *
+				      (ios->objio_seg->stripe_unit / PAGE_SIZE);
+		unsigned bio_size = (ios->ol_state.nr_pages + pages_in_stripe) /
+				    stripes;
+
+		per_dev->bio = bio_kmalloc(GFP_KERNEL, bio_size);
+		if (unlikely(!per_dev->bio)) {
+			dprintk("Faild to allocate BIO size=%u\n", bio_size);
+			return -ENOMEM;
+		}
 	}
 
-	ios->per_dev[0].bio = master_bio;
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
+static int _prepare_pages(struct objio_state *ios, struct _striping_info *si)
+{
+	u64 length = ios->ol_state.count;
+	unsigned stripe_unit = ios->objio_seg->stripe_unit;
+	unsigned mirrors_p1 = ios->objio_seg->mirrors_p1;
+	unsigned dev = si->dev;
+	unsigned comp = 0;
+	unsigned stripes = 0;
+	unsigned cur_pg = 0;
+	int ret = 0;
 
 	while (length) {
-		unsigned cur_len, added_len;
+		struct _objio_per_comp *per_dev = &ios->per_dev[comp];
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
 
-		cur_len = min_t(u64, length, PAGE_SIZE - pgbase);
+			stripes++;
 
-		added_len = bio_add_pc_page(
-			osd_request_queue(ios->objio_seg->ods[0]),
-			master_bio, *pages, cur_len, pgbase);
-		if (unlikely(cur_len != added_len))
-			break;
+			dev += mirrors_p1;
+			dev %= ios->ol_state.num_comps;
+		} else {
+			cur_len = stripe_unit;
+		}
+		if (cur_len >= length)
+			cur_len = length;
+
+		ret = _add_stripe_unit(ios, &cur_pg, page_off , per_dev,
+				       cur_len);
+		if (unlikely(ret))
+			goto out;
+
+		comp += mirrors_p1;
+		comp %= ios->ol_state.num_comps;
 
-		pgbase = 0;
-		++pages;
 		length -= cur_len;
 		ios->length += cur_len;
 	}
+out:
+	if (!ios->length)
+		return ret;
 
-	/* this should never happen */
-	WARN_ON(!ios->length);
-
+	ios->numdevs = stripes * mirrors_p1;
 	return 0;
 }
 
+static int _io_rw_pagelist(struct objio_state *ios)
+{
+	struct _striping_info si;
+
+	_calc_stripe_info(ios, ios->ol_state.count, &si);
+	return _prepare_pages(ios, &si);
+}
+
 static ssize_t _sync_done(struct objio_state *ios)
 {
 	struct completion *waiting = ios->private;
@@ -569,11 +692,11 @@ static ssize_t _read_done(struct objio_state *ios)
 	return status;
 }
 
-static ssize_t _read_exec(struct objio_state *ios)
+static int _read_mirrors(struct objio_state *ios, unsigned cur_comp)
 {
 	struct osd_request *or = NULL;
-	struct _objio_per_comp *per_dev = &ios->per_dev[0];
-	unsigned dev = 0;
+	struct _objio_per_comp *per_dev = &ios->per_dev[cur_comp];
+	unsigned dev = per_dev->dev;
 	struct pnfs_osd_object_cred *cred =
 			&ios->objio_seg->layout->olo_comps[dev];
 	struct osd_obj_id obj = {
@@ -582,15 +705,14 @@ static ssize_t _read_exec(struct objio_state *ios)
 	};
 	int ret;
 
-	or = osd_start_request(ios->objio_seg->ods[dev], GFP_KERNEL);
+	or = osd_start_request(_io_od(ios, dev), GFP_KERNEL);
 	if (unlikely(!or)) {
 		ret = -ENOMEM;
 		goto err;
 	}
 	per_dev->or = or;
-	ios->numdevs++;
 
-	osd_req_read(or, &obj, ios->ol_state.offset, per_dev->bio, ios->length);
+	osd_req_read(or, &obj, per_dev->offset, per_dev->bio, per_dev->length);
 
 	ret = osd_finalize_request(or, 0, cred->oc_cap.cred, NULL);
 	if (ret) {
@@ -599,8 +721,25 @@ static ssize_t _read_exec(struct objio_state *ios)
 		goto err;
 	}
 
-	dprintk("%s: obj=0x%llx start=0x%llx length=0x%lx\n",
-		__func__, obj.id, _LLU(ios->ol_state.offset), ios->length);
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
+	for (i = 0; i < ios->numdevs; i += ios->objio_seg->mirrors_p1) {
+		ret = _read_mirrors(ios, i);
+		if (unlikely(ret))
+			goto err;
+	}
+
 	ios->done = _read_done;
 	return _io_exec(ios); /* In sync mode exec returns the io status */
 
@@ -645,47 +784,54 @@ static ssize_t _write_done(struct objio_state *ios)
 	return status;
 }
 
-static int _write_exec(struct objio_state *ios)
+static int _write_mirrors(struct objio_state *ios, unsigned cur_comp)
 {
-	int i, ret;
-	struct bio *master_bio = ios->per_dev[0].bio;
+	struct _objio_per_comp *master_dev = &ios->per_dev[cur_comp];
+	unsigned dev = ios->per_dev[cur_comp].dev;
+	unsigned last_comp = cur_comp + ios->objio_seg->mirrors_p1;
+	int ret;
 
-	for (i = 0; i < ios->objio_seg->num_comps; i++) {
+	for (; cur_comp < last_comp; ++cur_comp, ++dev) {
 		struct osd_request *or = NULL;
 		struct pnfs_osd_object_cred *cred =
-					&ios->objio_seg->layout->olo_comps[i];
-		struct osd_obj_id obj = {cred->oc_object_id.oid_partition_id,
-					 cred->oc_object_id.oid_object_id};
-		struct _objio_per_comp *per_dev = &ios->per_dev[i];
+					&ios->objio_seg->layout->olo_comps[dev];
+		struct osd_obj_id obj = {
+			.partition = cred->oc_object_id.oid_partition_id,
+			.id = cred->oc_object_id.oid_object_id,
+		};
+		struct _objio_per_comp *per_dev = &ios->per_dev[cur_comp];
 		struct bio *bio;
 
-		or = osd_start_request(ios->objio_seg->ods[i], GFP_KERNEL);
+		or = osd_start_request(_io_od(ios, dev), GFP_KERNEL);
 		if (unlikely(!or)) {
 			ret = -ENOMEM;
 			goto err;
 		}
 		per_dev->or = or;
-		ios->numdevs++;
 
-		if (i != 0) {
-			bio = bio_kmalloc(GFP_KERNEL, master_bio->bi_max_vecs);
+		if (per_dev != master_dev) {
+			bio = bio_kmalloc(GFP_KERNEL,
+					  master_dev->bio->bi_max_vecs);
 			if (unlikely(!bio)) {
 				dprintk("Faild to allocate BIO size=%u\n",
-					master_bio->bi_max_vecs);
+					master_dev->bio->bi_max_vecs);
 				ret = -ENOMEM;
 				goto err;
 			}
 
-			__bio_clone(bio, master_bio);
+			__bio_clone(bio, master_dev->bio);
 			bio->bi_bdev = NULL;
 			bio->bi_next = NULL;
 			per_dev->bio = bio;
+			per_dev->dev = dev;
+			per_dev->length = master_dev->length;
+			per_dev->offset =  master_dev->offset;
 		} else {
-			bio = master_bio;
+			bio = master_dev->bio;
 			bio->bi_rw |= REQ_WRITE;
 		}
 
-		osd_req_write(or, &obj, ios->ol_state.offset, bio, ios->length);
+		osd_req_write(or, &obj, per_dev->offset, bio, per_dev->length);
 
 		ret = osd_finalize_request(or, 0, cred->oc_cap.cred, NULL);
 		if (ret) {
@@ -694,9 +840,24 @@ static int _write_exec(struct objio_state *ios)
 			goto err;
 		}
 
-		dprintk("%s: [%d] obj=0x%llx start=0x%llx length=0x%lx\n",
-			__func__, i, obj.id, _LLU(ios->ol_state.offset),
-			ios->length);
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
+	for (i = 0; i < ios->numdevs; i += ios->objio_seg->mirrors_p1) {
+		ret = _write_mirrors(ios, i);
+		if (unlikely(ret))
+			goto err;
 	}
 
 	ios->done = _write_done;
-- 
1.7.3.4


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:57235 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366Ab1DTR3j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 13:29:39 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC 27/27] pnfs-obj: objio_osd: groups support
Date: Wed, 20 Apr 2011 20:29:36 +0300
Message-Id: <1303320576-21972-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DAF0DE1.6020609@panasas.com>
References: <4DAF0DE1.6020609@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Boaz Harrosh <bharrosh@panasas.com>

* _calc_stripe_info() changes to accommodate for grouping
  calculations. Returns additional information

* old _prepare_pages() becomes _prepare_one_group()
  which stores pages belonging to one device group.

* Iterates on all groups calling _prepare_one_group().

* Enable mounting of groups data_maps (group_width != 0)

TODO:
  Support for parial layout will come in next patch

[Support partial layouts]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |  135 +++++++++++++++++++++++++++++++++---------
 1 files changed, 106 insertions(+), 29 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 5c141d0..47e8695 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -140,6 +140,8 @@ struct objio_segment {
 	unsigned mirrors_p1;
 	unsigned stripe_unit;
 	unsigned group_width;	/* Data stripe_units without integrity comps */
+	u64 group_depth;
+	unsigned group_count;
 
 	unsigned num_comps;
 	/* variable length */
@@ -258,12 +260,9 @@ static int _verify_data_map(struct pnfs_osd_layout *layout)
 {
 	struct pnfs_osd_data_map *data_map = &layout->olo_map;
 	u64 stripe_length;
+	u32 group_width;
 
-/* FIXME: Only raid0 !group_width/depth for now. if not so, do not mount */
-	if (data_map->odm_group_width || data_map->odm_group_depth) {
-		printk(KERN_ERR "Group width/depth not supported\n");
-		return -ENOTSUPP;
-	}
+/* FIXME: Only raid0 for now. if not go through MDS */
 	if (data_map->odm_raid_algorithm != PNFS_OSD_RAID_0) {
 		printk(KERN_ERR "Only RAID_0 for now\n");
 		return -ENOTSUPP;
@@ -274,8 +273,13 @@ static int _verify_data_map(struct pnfs_osd_layout *layout)
 		return -EINVAL;
 	}
 
-	stripe_length = data_map->odm_stripe_unit * (data_map->odm_num_comps /
-						(data_map->odm_mirror_cnt + 1));
+	if (data_map->odm_group_width)
+		group_width = data_map->odm_group_width;
+	else
+		group_width = data_map->odm_num_comps /
+						(data_map->odm_mirror_cnt + 1);
+
+	stripe_length = (u64)data_map->odm_stripe_unit * group_width;
 	if (stripe_length >= (1ULL << 32)) {
 		printk(KERN_ERR "Total Stripe length(0x%llx)"
 			  " >= 32bit is not supported\n", _LLU(stripe_length));
@@ -317,8 +321,18 @@ int objio_alloc_lseg(void **outp,
 
 	objio_seg->mirrors_p1 = layout->olo_map.odm_mirror_cnt + 1;
 	objio_seg->stripe_unit = layout->olo_map.odm_stripe_unit;
-	objio_seg->group_width = layout->olo_map.odm_num_comps /
-							objio_seg->mirrors_p1;
+	if (layout->olo_map.odm_group_width) {
+		objio_seg->group_width = layout->olo_map.odm_group_width;
+		objio_seg->group_depth = layout->olo_map.odm_group_depth;
+		objio_seg->group_count = layout->olo_map.odm_num_comps /
+						objio_seg->mirrors_p1 /
+						objio_seg->group_width;
+	} else {
+		objio_seg->group_width = layout->olo_map.odm_num_comps /
+						objio_seg->mirrors_p1;
+		objio_seg->group_depth = -1;
+		objio_seg->group_count = 1;
+	}
 
 	*outp = objio_seg;
 	return 0;
@@ -489,6 +503,9 @@ struct osd_dev * _io_od(struct objio_state *ios, unsigned dev)
 
 struct _striping_info {
 	u64 obj_offset;
+	u64 group_length;
+	u64 total_group_length;
+	u64 Major;
 	unsigned dev;
 	unsigned unit_off;
 };
@@ -498,15 +515,34 @@ static void _calc_stripe_info(struct objio_state *ios, u64 file_offset,
 {
 	u32	stripe_unit = ios->objio_seg->stripe_unit;
 	u32	group_width = ios->objio_seg->group_width;
+	u64	group_depth = ios->objio_seg->group_depth;
 	u32	U = stripe_unit * group_width;
 
-	u32	LmodU;
-	u64 	N = div_u64_rem(file_offset, U, &LmodU);
+	u64	T = U * group_depth;
+	u64	S = T * ios->objio_seg->group_count;
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
 
-	si->unit_off = LmodU % stripe_unit;
-	si->obj_offset = N * stripe_unit + si->unit_off;
-	si->dev = LmodU / stripe_unit;
+	/* "H - (N * U)" is just "H % U" so it's bound to u32 */
+	si->dev = (u32)(H - (N * U)) / stripe_unit + G * group_width;
 	si->dev *= ios->objio_seg->mirrors_p1;
+
+	si->group_length = T - H;
+	si->total_group_length = T;
+	si->Major = M;
 }
 
 static int _add_stripe_unit(struct objio_state *ios,  unsigned *cur_pg,
@@ -553,15 +589,18 @@ static int _add_stripe_unit(struct objio_state *ios,  unsigned *cur_pg,
 	return 0;
 }
 
-static int _prepare_pages(struct objio_state *ios, struct _striping_info *si)
+static int _prepare_one_group(struct objio_state *ios, u64 length,
+			      struct _striping_info *si, unsigned first_comp,
+			      unsigned *last_pg)
 {
-	u64 length = ios->ol_state.count;
 	unsigned stripe_unit = ios->objio_seg->stripe_unit;
 	unsigned mirrors_p1 = ios->objio_seg->mirrors_p1;
+	unsigned devs_in_group = ios->objio_seg->group_width * mirrors_p1;
 	unsigned dev = si->dev;
-	unsigned comp = 0;
-	unsigned stripes = 0;
-	unsigned cur_pg = 0;
+	unsigned first_dev = dev - (dev % devs_in_group);
+	unsigned comp = first_comp + (dev - first_dev);
+	unsigned max_comp = ios->numdevs ? ios->numdevs - mirrors_p1 : 0;
+	unsigned cur_pg = *last_pg;
 	int ret = 0;
 
 	while (length) {
@@ -585,10 +624,11 @@ static int _prepare_pages(struct objio_state *ios, struct _striping_info *si)
 				cur_len = stripe_unit;
 			}
 
-			stripes++;
+			if (max_comp < comp)
+				max_comp = comp;
 
 			dev += mirrors_p1;
-			dev %= ios->ol_state.num_comps;
+			dev = (dev % devs_in_group) + first_dev;
 		} else {
 			cur_len = stripe_unit;
 		}
@@ -601,25 +641,58 @@ static int _prepare_pages(struct objio_state *ios, struct _striping_info *si)
 			goto out;
 
 		comp += mirrors_p1;
-		comp %= ios->ol_state.num_comps;
+		comp = (comp % devs_in_group) + first_comp;
 
 		length -= cur_len;
 		ios->length += cur_len;
 	}
 out:
-	if (!ios->length)
-		return ret;
-
-	ios->numdevs = stripes * mirrors_p1;
-	return 0;
+	ios->numdevs = max_comp + mirrors_p1;
+	*last_pg = cur_pg;
+	return ret;
 }
 
 static int _io_rw_pagelist(struct objio_state *ios)
 {
+	u64 length = ios->ol_state.count;
 	struct _striping_info si;
+	unsigned devs_in_group = ios->objio_seg->group_width *
+				 ios->objio_seg->mirrors_p1;
+	unsigned first_comp = 0;
+	unsigned num_comps = ios->objio_seg->layout->olo_map.odm_num_comps;
+	unsigned last_pg = 0;
+	int ret = 0;
 
-	_calc_stripe_info(ios, ios->ol_state.count, &si);
-	return _prepare_pages(ios, &si);
+	_calc_stripe_info(ios, ios->ol_state.offset, &si);
+	while (length) {
+		if (length < si.group_length)
+			si.group_length = length;
+
+		ret = _prepare_one_group(ios, si.group_length, &si, first_comp,
+					 &last_pg);
+		if (unlikely(ret))
+			goto out;
+
+		length -= si.group_length;
+
+		si.group_length = si.total_group_length;
+		si.unit_off = 0;
+		++si.Major;
+		si.obj_offset = si.Major * ios->objio_seg->stripe_unit *
+						ios->objio_seg->group_depth;
+
+		si.dev = (si.dev - (si.dev % devs_in_group)) + devs_in_group;
+		si.dev %= num_comps;
+
+		first_comp += devs_in_group;
+		first_comp %= num_comps;
+	}
+
+out:
+	if (!ios->length)
+		return ret;
+
+	return 0;
 }
 
 static ssize_t _sync_done(struct objio_state *ios)
@@ -741,6 +814,8 @@ static ssize_t _read_exec(struct objio_state *ios)
 	int ret;
 
 	for (i = 0; i < ios->numdevs; i += ios->objio_seg->mirrors_p1) {
+		if (!ios->per_dev[i].length)
+			continue;
 		ret = _read_mirrors(ios, i);
 		if (unlikely(ret))
 			goto err;
@@ -861,6 +936,8 @@ static ssize_t _write_exec(struct objio_state *ios)
 	int ret;
 
 	for (i = 0; i < ios->numdevs; i += ios->objio_seg->mirrors_p1) {
+		if (!ios->per_dev[i].length)
+			continue;
 		ret = _write_mirrors(ios, i);
 		if (unlikely(ret))
 			goto err;
-- 
1.7.3.4


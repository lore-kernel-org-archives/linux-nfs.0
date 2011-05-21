Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:19755 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434Ab1EUKbF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 May 2011 06:31:05 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 03/13] SQUASHME: pnfs-obj: Rename ios->objio_seg => ios->layout
Date: Sat, 21 May 2011 13:30:54 +0300
Message-Id: <1305973854-17307-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DD79273.9030202@panasas.com>
References: <4DD79273.9030202@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This is what the exofs raid engine calls it. As we transition
to use exofs_io_state directly and drop objio_io_start.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |   48 +++++++++++++++++++++---------------------
 1 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 9524d93..1289dff 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -150,7 +150,7 @@ struct objio_state {
 	/* Generic layer */
 	struct objlayout_io_state ol_state;
 
-	struct objio_segment *objio_seg;
+	struct objio_segment *layout;
 
 	struct kref kref;
 	objio_done_fn done;
@@ -359,7 +359,7 @@ int objio_alloc_io_state(void *seg, struct objlayout_io_state **outp)
 	if (unlikely(!ios))
 		return -ENOMEM;
 
-	ios->objio_seg = objio_seg;
+	ios->layout = objio_seg;
 	ios->ol_state.ioerrs = ((void *)ios) + first_size;
 	ios->ol_state.num_comps = objio_seg->num_comps;
 
@@ -488,11 +488,11 @@ static void _io_free(struct objio_state *ios)
 
 struct osd_dev * _io_od(struct objio_state *ios, unsigned dev)
 {
-	unsigned min_dev = ios->objio_seg->comps_index;
+	unsigned min_dev = ios->layout->comps_index;
 	unsigned max_dev = min_dev + ios->ol_state.num_comps;
 
 	BUG_ON(dev < min_dev || max_dev <= dev);
-	return ios->objio_seg->ods[dev - min_dev];
+	return ios->layout->ods[dev - min_dev];
 }
 
 struct _striping_info {
@@ -507,13 +507,13 @@ struct _striping_info {
 static void _calc_stripe_info(struct objio_state *ios, u64 file_offset,
 			      struct _striping_info *si)
 {
-	u32	stripe_unit = ios->objio_seg->stripe_unit;
-	u32	group_width = ios->objio_seg->group_width;
-	u64	group_depth = ios->objio_seg->group_depth;
+	u32	stripe_unit = ios->layout->stripe_unit;
+	u32	group_width = ios->layout->group_width;
+	u64	group_depth = ios->layout->group_depth;
 	u32	U = stripe_unit * group_width;
 
 	u64	T = U * group_depth;
-	u64	S = T * ios->objio_seg->group_count;
+	u64	S = T * ios->layout->group_count;
 	u64	M = div64_u64(file_offset, S);
 
 	/*
@@ -532,7 +532,7 @@ static void _calc_stripe_info(struct objio_state *ios, u64 file_offset,
 
 	/* "H - (N * U)" is just "H % U" so it's bound to u32 */
 	si->dev = (u32)(H - (N * U)) / stripe_unit + G * group_width;
-	si->dev *= ios->objio_seg->mirrors_p1;
+	si->dev *= ios->layout->mirrors_p1;
 
 	si->group_length = T - H;
 	si->total_group_length = T;
@@ -550,9 +550,9 @@ static int _add_stripe_unit(struct objio_state *ios,  unsigned *cur_pg,
 
 	if (per_dev->bio == NULL) {
 		unsigned stripes = ios->ol_state.num_comps /
-						     ios->objio_seg->mirrors_p1;
+						     ios->layout->mirrors_p1;
 		unsigned pages_in_stripe = stripes *
-				      (ios->objio_seg->stripe_unit / PAGE_SIZE);
+				      (ios->layout->stripe_unit / PAGE_SIZE);
 		unsigned bio_size = (ios->ol_state.nr_pages + pages_in_stripe) /
 				    stripes;
 
@@ -587,9 +587,9 @@ static int _prepare_one_group(struct objio_state *ios, u64 length,
 			      struct _striping_info *si, unsigned first_comp,
 			      unsigned *last_pg)
 {
-	unsigned stripe_unit = ios->objio_seg->stripe_unit;
-	unsigned mirrors_p1 = ios->objio_seg->mirrors_p1;
-	unsigned devs_in_group = ios->objio_seg->group_width * mirrors_p1;
+	unsigned stripe_unit = ios->layout->stripe_unit;
+	unsigned mirrors_p1 = ios->layout->mirrors_p1;
+	unsigned devs_in_group = ios->layout->group_width * mirrors_p1;
 	unsigned dev = si->dev;
 	unsigned first_dev = dev - (dev % devs_in_group);
 	unsigned comp = first_comp + (dev - first_dev);
@@ -650,10 +650,10 @@ static int _io_rw_pagelist(struct objio_state *ios)
 {
 	u64 length = ios->ol_state.count;
 	struct _striping_info si;
-	unsigned devs_in_group = ios->objio_seg->group_width *
-				 ios->objio_seg->mirrors_p1;
+	unsigned devs_in_group = ios->layout->group_width *
+				 ios->layout->mirrors_p1;
 	unsigned first_comp = 0;
-	unsigned num_comps = devs_in_group * ios->objio_seg->group_count;
+	unsigned num_comps = devs_in_group * ios->layout->group_count;
 	unsigned last_pg = 0;
 	int ret = 0;
 
@@ -672,8 +672,8 @@ static int _io_rw_pagelist(struct objio_state *ios)
 		si.group_length = si.total_group_length;
 		si.unit_off = 0;
 		++si.Major;
-		si.obj_offset = si.Major * ios->objio_seg->stripe_unit *
-						ios->objio_seg->group_depth;
+		si.obj_offset = si.Major * ios->layout->stripe_unit *
+						ios->layout->group_depth;
 
 		si.dev = (si.dev - (si.dev % devs_in_group)) + devs_in_group;
 		si.dev %= num_comps;
@@ -771,7 +771,7 @@ static int _read_mirrors(struct objio_state *ios, unsigned cur_comp)
 	struct _objio_per_comp *per_dev = &ios->per_dev[cur_comp];
 	unsigned dev = per_dev->dev;
 	struct pnfs_osd_object_cred *cred =
-			&ios->objio_seg->comps[dev];
+			&ios->layout->comps[dev];
 	struct osd_obj_id obj = {
 		.partition = cred->oc_object_id.oid_partition_id,
 		.id = cred->oc_object_id.oid_object_id,
@@ -807,7 +807,7 @@ static ssize_t _read_exec(struct objio_state *ios)
 	unsigned i;
 	int ret;
 
-	for (i = 0; i < ios->numdevs; i += ios->objio_seg->mirrors_p1) {
+	for (i = 0; i < ios->numdevs; i += ios->layout->mirrors_p1) {
 		if (!ios->per_dev[i].length)
 			continue;
 		ret = _read_mirrors(ios, i);
@@ -863,13 +863,13 @@ static int _write_mirrors(struct objio_state *ios, unsigned cur_comp)
 {
 	struct _objio_per_comp *master_dev = &ios->per_dev[cur_comp];
 	unsigned dev = ios->per_dev[cur_comp].dev;
-	unsigned last_comp = cur_comp + ios->objio_seg->mirrors_p1;
+	unsigned last_comp = cur_comp + ios->layout->mirrors_p1;
 	int ret;
 
 	for (; cur_comp < last_comp; ++cur_comp, ++dev) {
 		struct osd_request *or = NULL;
 		struct pnfs_osd_object_cred *cred =
-					&ios->objio_seg->comps[dev];
+					&ios->layout->comps[dev];
 		struct osd_obj_id obj = {
 			.partition = cred->oc_object_id.oid_partition_id,
 			.id = cred->oc_object_id.oid_object_id,
@@ -929,7 +929,7 @@ static ssize_t _write_exec(struct objio_state *ios)
 	unsigned i;
 	int ret;
 
-	for (i = 0; i < ios->numdevs; i += ios->objio_seg->mirrors_p1) {
+	for (i = 0; i < ios->numdevs; i += ios->layout->mirrors_p1) {
 		if (!ios->per_dev[i].length)
 			continue;
 		ret = _write_mirrors(ios, i);
-- 
1.7.2.3


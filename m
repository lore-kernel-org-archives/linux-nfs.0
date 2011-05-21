Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:19752 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434Ab1EUKau (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 May 2011 06:30:50 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 02/13] SQUASHME: pnfs-obj: objio_segment only needs the pnfs_osd_layout->olo_comps
Date: Sat, 21 May 2011 13:30:39 +0300
Message-Id: <1305973839-17279-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DD79273.9030202@panasas.com>
References: <4DD79273.9030202@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

All of struct pnfs_osd_layout is duplicated / enhanced in
objio_segment the only information we used from the generic
pnfs_osd_layout was the pnfs_osd_object_cred *olo_comps
array and the olo_comps_index. Embed these into objio_segment
directly.

This patch is a part of a patchset that will convert the
pnfs-obj code to use the exofs io_engine instead of duplicating
it here.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index a2cb9a3..9524d93 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -129,7 +129,7 @@ out:
 }
 
 struct objio_segment {
-	struct pnfs_osd_layout *layout;
+	struct pnfs_osd_object_cred *comps;
 
 	unsigned mirrors_p1;
 	unsigned stripe_unit;
@@ -137,6 +137,7 @@ struct objio_segment {
 	u64 group_depth;
 	unsigned group_count;
 
+	unsigned comps_index;
 	unsigned num_comps;
 	/* variable length */
 	struct osd_dev	*ods[1];
@@ -172,7 +173,6 @@ struct objio_state {
 static struct osd_dev *_device_lookup(struct pnfs_layout_hdr *pnfslay,
 			       struct objio_segment *objio_seg, unsigned comp)
 {
-	struct pnfs_osd_layout *layout = objio_seg->layout;
 	struct pnfs_osd_deviceaddr *deviceaddr;
 	struct nfs4_deviceid *d_id;
 	struct osd_dev *od;
@@ -180,7 +180,7 @@ static struct osd_dev *_device_lookup(struct pnfs_layout_hdr *pnfslay,
 	struct objio_mount_type *omt = NFS_SERVER(pnfslay->plh_inode)->pnfs_ld_data;
 	int err;
 
-	d_id = &layout->olo_comps[comp].oc_object_id.oid_device_id;
+	d_id = &objio_seg->comps[comp].oc_object_id.oid_device_id;
 
 	od = _dev_list_find(omt, d_id);
 	if (od)
@@ -227,12 +227,11 @@ out:
 static int objio_devices_lookup(struct pnfs_layout_hdr *pnfslay,
 	struct objio_segment *objio_seg)
 {
-	struct pnfs_osd_layout *layout = objio_seg->layout;
-	unsigned i, num_comps = layout->olo_num_comps;
+	unsigned i;
 	int err;
 
 	/* lookup all devices */
-	for (i = 0; i < num_comps; i++) {
+	for (i = 0; i < objio_seg->num_comps; i++) {
 		struct osd_dev *od;
 
 		od = _device_lookup(pnfslay, objio_seg, i);
@@ -242,7 +241,6 @@ static int objio_devices_lookup(struct pnfs_layout_hdr *pnfslay,
 		}
 		objio_seg->ods[i] = od;
 	}
-	objio_seg->num_comps = num_comps;
 	err = 0;
 
 out:
@@ -308,7 +306,9 @@ int objio_alloc_lseg(void **outp,
 	if (!objio_seg)
 		return -ENOMEM;
 
-	objio_seg->layout = layout;
+	objio_seg->comps_index = layout->olo_comps_index;
+	objio_seg->num_comps = layout->olo_num_comps;
+	objio_seg->comps = layout->olo_comps;
 	err = objio_devices_lookup(pnfslay, objio_seg);
 	if (err)
 		goto free_seg;
@@ -488,7 +488,7 @@ static void _io_free(struct objio_state *ios)
 
 struct osd_dev * _io_od(struct objio_state *ios, unsigned dev)
 {
-	unsigned min_dev = ios->objio_seg->layout->olo_comps_index;
+	unsigned min_dev = ios->objio_seg->comps_index;
 	unsigned max_dev = min_dev + ios->ol_state.num_comps;
 
 	BUG_ON(dev < min_dev || max_dev <= dev);
@@ -653,7 +653,7 @@ static int _io_rw_pagelist(struct objio_state *ios)
 	unsigned devs_in_group = ios->objio_seg->group_width *
 				 ios->objio_seg->mirrors_p1;
 	unsigned first_comp = 0;
-	unsigned num_comps = ios->objio_seg->layout->olo_map.odm_num_comps;
+	unsigned num_comps = devs_in_group * ios->objio_seg->group_count;
 	unsigned last_pg = 0;
 	int ret = 0;
 
@@ -771,7 +771,7 @@ static int _read_mirrors(struct objio_state *ios, unsigned cur_comp)
 	struct _objio_per_comp *per_dev = &ios->per_dev[cur_comp];
 	unsigned dev = per_dev->dev;
 	struct pnfs_osd_object_cred *cred =
-			&ios->objio_seg->layout->olo_comps[dev];
+			&ios->objio_seg->comps[dev];
 	struct osd_obj_id obj = {
 		.partition = cred->oc_object_id.oid_partition_id,
 		.id = cred->oc_object_id.oid_object_id,
@@ -869,7 +869,7 @@ static int _write_mirrors(struct objio_state *ios, unsigned cur_comp)
 	for (; cur_comp < last_comp; ++cur_comp, ++dev) {
 		struct osd_request *or = NULL;
 		struct pnfs_osd_object_cred *cred =
-					&ios->objio_seg->layout->olo_comps[dev];
+					&ios->objio_seg->comps[dev];
 		struct osd_obj_id obj = {
 			.partition = cred->oc_object_id.oid_partition_id,
 			.id = cred->oc_object_id.oid_object_id,
-- 
1.7.2.3


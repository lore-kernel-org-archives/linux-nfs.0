Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:19769 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753648Ab1EUKcI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 May 2011 06:32:08 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 07/13] SQUASHME: pnfs-obj: Avoid double allocation logic in objlayout_alloc_lseg
Date: Sat, 21 May 2011 13:31:57 +0300
Message-Id: <1305973917-17416-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DD79273.9030202@panasas.com>
References: <4DD79273.9030202@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Push down objlayout_alloc_lseg() logic into the io-engines. This
avoids the generic layer from separately allocating the complete
pnfs_osd_layout structure, then allocating a second structure for
the io-engine's internal segment information. The io-engines have
better knowledge of what is actually needed and what can be
discarded, and can allocate everything at once.

The duplication of code, decoding the pnfs_osd_layout, is very small
since most of it is abstracted inside the _xdr_ layer routines.

TODO: Convert panlayout. It is mostly done (On the old version of
this) In my tree.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |  102 +++++++++++++++++++++++++++++++-----------
 fs/nfs/objlayout/objlayout.c |   78 +++++---------------------------
 fs/nfs/objlayout/objlayout.h |   25 ++++-------
 3 files changed, 97 insertions(+), 108 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index f3f7640..7e46d2b 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -128,7 +128,14 @@ out:
 	return 0;
 }
 
+struct caps_buffers {
+	u8 caps_key[OSD_CRYPTO_KEYID_SIZE];
+	u8 creds[OSD_CAP_LEN];
+};
+
 struct objio_segment {
+	struct pnfs_layout_segment lseg;
+
 	struct pnfs_osd_object_cred *comps;
 
 	unsigned mirrors_p1;
@@ -143,6 +150,12 @@ struct objio_segment {
 	struct osd_dev	*ods[1];
 };
 
+static inline struct objio_segment *
+OBJIO_LSEG(struct pnfs_layout_segment *lseg)
+{
+	return container_of(lseg, struct objio_segment, lseg);
+}
+
 struct objio_state;
 typedef ssize_t (*objio_done_fn)(struct objio_state *ios);
 
@@ -188,7 +201,8 @@ static struct osd_dev *_device_lookup(struct pnfs_layout_hdr *pnfslay,
 
 	err = objlayout_get_deviceinfo(pnfslay, d_id, &deviceaddr);
 	if (unlikely(err)) {
-		dprintk("%s: objlayout_get_deviceinfo=>%d\n", __func__, err);
+		dprintk("%s: objlayout_get_deviceinfo dev(%llx:%llx) =>%d \n",
+			__func__, _DEVID_LO(d_id), _DEVID_HI(d_id), err);
 		return ERR_PTR(err);
 	}
 
@@ -288,66 +302,102 @@ static int _verify_data_map(struct pnfs_osd_layout *layout)
 	return 0;
 }
 
-int objio_alloc_lseg(void **outp,
+static void copy_single_comp(struct pnfs_osd_object_cred *cur_comp,
+			     struct pnfs_osd_object_cred *src_comp,
+			     struct caps_buffers *caps_p)
+{
+	WARN_ON(src_comp->oc_cap_key.cred_len > sizeof(caps_p->caps_key));
+	WARN_ON(src_comp->oc_cap.cred_len > sizeof(caps_p->creds));
+
+	*cur_comp = *src_comp;
+
+	memcpy(caps_p->caps_key, src_comp->oc_cap_key.cred,
+	       sizeof(caps_p->caps_key));
+	cur_comp->oc_cap_key.cred = caps_p->caps_key;
+
+	memcpy(caps_p->creds, src_comp->oc_cap.cred,
+	       sizeof(caps_p->creds));
+	cur_comp->oc_cap.cred = caps_p->creds;
+}
+
+extern int objio_alloc_lseg(struct pnfs_layout_segment **outp,
 	struct pnfs_layout_hdr *pnfslay,
-	struct pnfs_layout_segment *lseg,
-	struct pnfs_osd_layout *layout)
+	struct pnfs_layout_range *range,
+	struct xdr_stream *xdr)
 {
 	struct objio_segment *objio_seg;
+	struct pnfs_osd_xdr_decode_layout_iter iter;
+	struct pnfs_osd_layout layout;
+	struct pnfs_osd_object_cred *cur_comp, src_comp;
+	struct caps_buffers *caps_p;
+
 	int err;
 
-	err = _verify_data_map(layout);
+	err = pnfs_osd_xdr_decode_layout_map(&layout, &iter, xdr);
+	if (unlikely(err))
+		return err;
+
+	err = _verify_data_map(&layout);
 	if (unlikely(err))
 		return err;
 
 	objio_seg = kzalloc(sizeof(*objio_seg) +
-			(layout->olo_num_comps - 1) * sizeof(objio_seg->ods[0]),
-			GFP_KERNEL);
+			    sizeof(*objio_seg->comps) * layout.olo_num_comps +
+			    sizeof(struct caps_buffers) * layout.olo_num_comps,
+			    GFP_KERNEL);
 	if (!objio_seg)
 		return -ENOMEM;
 
-	objio_seg->comps_index = layout->olo_comps_index;
-	objio_seg->num_comps = layout->olo_num_comps;
-	objio_seg->comps = layout->olo_comps;
+	cur_comp = objio_seg->comps = (void *)(objio_seg + 1);
+	caps_p = (void *)(cur_comp + layout.olo_num_comps);
+	while(pnfs_osd_xdr_decode_layout_comp(&src_comp, &iter, xdr, &err)) {
+		copy_single_comp(cur_comp++, &src_comp, caps_p++);
+	}
+	if (unlikely(err))
+		goto err;
+
+	objio_seg->num_comps = layout.olo_num_comps;
+	objio_seg->comps_index = layout.olo_comps_index;
 	err = objio_devices_lookup(pnfslay, objio_seg);
 	if (err)
-		goto free_seg;
-
-	objio_seg->mirrors_p1 = layout->olo_map.odm_mirror_cnt + 1;
-	objio_seg->stripe_unit = layout->olo_map.odm_stripe_unit;
-	if (layout->olo_map.odm_group_width) {
-		objio_seg->group_width = layout->olo_map.odm_group_width;
-		objio_seg->group_depth = layout->olo_map.odm_group_depth;
-		objio_seg->group_count = layout->olo_map.odm_num_comps /
+		goto err;
+
+	objio_seg->mirrors_p1 = layout.olo_map.odm_mirror_cnt + 1;
+	objio_seg->stripe_unit = layout.olo_map.odm_stripe_unit;
+	if (layout.olo_map.odm_group_width) {
+		objio_seg->group_width = layout.olo_map.odm_group_width;
+		objio_seg->group_depth = layout.olo_map.odm_group_depth;
+		objio_seg->group_count = layout.olo_map.odm_num_comps /
 						objio_seg->mirrors_p1 /
 						objio_seg->group_width;
 	} else {
-		objio_seg->group_width = layout->olo_map.odm_num_comps /
+		objio_seg->group_width = layout.olo_map.odm_num_comps /
 						objio_seg->mirrors_p1;
 		objio_seg->group_depth = -1;
 		objio_seg->group_count = 1;
 	}
 
-	*outp = objio_seg;
+	*outp = &objio_seg->lseg;
 	return 0;
 
-free_seg:
-	dprintk("%s: Error: return %d\n", __func__, err);
+err:
 	kfree(objio_seg);
+	dprintk("%s: Error: return %d\n", __func__, err);
 	*outp = NULL;
 	return err;
 }
 
-void objio_free_lseg(void *p)
+void objio_free_lseg(struct pnfs_layout_segment *lseg)
 {
-	struct objio_segment *objio_seg = p;
+	struct objio_segment *objio_seg = OBJIO_LSEG(lseg);
 
 	kfree(objio_seg);
 }
 
-int objio_alloc_io_state(void *seg, struct objlayout_io_state **outp)
+int objio_alloc_io_state(struct pnfs_layout_segment *lseg,
+			 struct objlayout_io_state **outp)
 {
-	struct objio_segment *objio_seg = seg;
+	struct objio_segment *objio_seg = OBJIO_LSEG(lseg);
 	struct objio_state *ios;
 	const unsigned first_size = sizeof(*ios) +
 				objio_seg->num_comps * sizeof(ios->per_dev[0]);
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index c80f06c..e3c42fc 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -75,28 +75,6 @@ objlayout_free_layout_hdr(struct pnfs_layout_hdr *lo)
 	kfree(objlay);
 }
 
-struct caps_buffers {
-	u8 caps_key[OSD_CRYPTO_KEYID_SIZE];
-	u8 creds[OSD_CAP_LEN];
-};
-
-static void copy_single_comp(struct pnfs_osd_object_cred *cur_comp,
-			     struct pnfs_osd_object_cred *src_comp,
-			     struct caps_buffers *caps_p)
-{
-	WARN_ON(src_comp->oc_cap_key.cred_len > sizeof(caps_p->caps_key) >> 2);
-	WARN_ON(src_comp->oc_cap.cred_len > sizeof(caps_p->creds) >> 2);
-	*cur_comp = *src_comp;
-
-	memcpy(caps_p->caps_key, src_comp->oc_cap_key.cred,
-	       sizeof(caps_p->caps_key));
-	cur_comp->oc_cap_key.cred = caps_p->caps_key;
-
-	memcpy(caps_p->creds, src_comp->oc_cap.cred,
-	       sizeof(caps_p->creds));
-	cur_comp->oc_cap.cred = caps_p->creds;
-}
-
 /*
  * Unmarshall layout and store it in pnfslay.
  */
@@ -113,11 +91,7 @@ objlayout_alloc_lseg(struct pnfs_layout_hdr *pnfslay,
 		.len = lgr->layoutp->len,
 	};
 	struct page *scratch;
-	struct objlayout_segment *objlseg = NULL;
-	struct pnfs_osd_layout *layout;
-	struct pnfs_osd_object_cred *cur_comp, src_comp;
-	struct caps_buffers *caps_p;
-	struct pnfs_osd_xdr_decode_layout_iter iter;
+	struct pnfs_layout_segment *lseg;
 
 	dprintk("%s: Begin pnfslay %p\n", __func__, pnfslay);
 
@@ -128,44 +102,22 @@ objlayout_alloc_lseg(struct pnfs_layout_hdr *pnfslay,
 	xdr_init_decode(&stream, &buf, NULL);
 	xdr_set_scratch_buffer(&stream, page_address(scratch), PAGE_SIZE);
 
-	layout = &objlseg->layout;
-	status = pnfs_osd_xdr_decode_layout_map(layout, &iter, &stream);
-	if (unlikely(status))
-		goto err;
-
-	objlseg = kzalloc(sizeof(*objlseg) +
-			  sizeof(*layout->olo_comps) * layout->olo_num_comps +
-			  sizeof(struct caps_buffers) * layout->olo_num_comps,
-			  GFP_KERNEL);
-	if (unlikely(!objlseg)) {
-		status = -ENOMEM;
+	status = objio_alloc_lseg(&lseg, pnfslay, &lgr->range, &stream);
+	if (unlikely(status)) {
+		dprintk("%s: objio_alloc_lseg Return err %d\n", __func__,
+			status);
 		goto err;
 	}
 
-	cur_comp = layout->olo_comps = (void *)(objlseg + 1);
-	caps_p = (void *)(cur_comp + layout->olo_num_comps);
-	while(pnfs_osd_xdr_decode_layout_comp(&src_comp, &iter, &stream,
-					      &status)) {
-		copy_single_comp(cur_comp++, &src_comp, caps_p++);
-	}
-	if (unlikely(status))
-		goto err;
-
-	objlseg->lseg.pls_range = lgr->range;
-	status = objio_alloc_lseg(&objlseg->internal, pnfslay, &objlseg->lseg,
-				  layout);
-	if (status)
-		goto err;
-
 	__free_page(scratch);
 
-	dprintk("%s: Return %p\n", __func__, &objlseg->lseg);
-	return &objlseg->lseg;
+	dprintk("%s: Return %p\n", __func__, lseg);
+	return lseg;
 
 err:
-	kfree(objlseg);
 	__free_page(scratch);
 err_nofree:
+	dprintk("%s: Err Return=>%d\n", __func__, status);
 	return ERR_PTR(status);
 }
 
@@ -175,16 +127,12 @@ err_nofree:
 void
 objlayout_free_lseg(struct pnfs_layout_segment *lseg)
 {
-	struct objlayout_segment *objlseg;
-
 	dprintk("%s: freeing layout segment %p\n", __func__, lseg);
 
 	if (unlikely(!lseg))
 		return;
 
-	objlseg = container_of(lseg, struct objlayout_segment, lseg);
-	objio_free_lseg(objlseg->internal);
-	kfree(objlseg);
+	objio_free_lseg(lseg);
 }
 
 /*
@@ -219,13 +167,11 @@ objlayout_alloc_io_state(struct pnfs_layout_hdr *pnfs_layout_type,
 			struct pnfs_layout_segment *lseg,
 			void *rpcdata)
 {
-	struct objlayout_segment *objlseg =
-		container_of(lseg, struct objlayout_segment, lseg);
 	struct objlayout_io_state *state;
 	u64 lseg_end_offset;
 
 	dprintk("%s: allocating io_state\n", __func__);
-	if (objio_alloc_io_state(objlseg->internal, &state))
+	if (objio_alloc_io_state(lseg, &state))
 		return NULL;
 
 	BUG_ON(offset < lseg->pls_range.offset);
@@ -242,7 +188,7 @@ objlayout_alloc_io_state(struct pnfs_layout_hdr *pnfs_layout_type,
 	}
 
 	INIT_LIST_HEAD(&state->err_list);
-	state->objlseg = objlseg;
+	state->lseg = lseg;
 	state->rpcdata = rpcdata;
 	state->pages = pages;
 	state->pgbase = pgbase;
@@ -275,7 +221,7 @@ objlayout_iodone(struct objlayout_io_state *state)
 	if (likely(state->status >= 0)) {
 		objlayout_free_io_state(state);
 	} else {
-		struct objlayout *objlay = OBJLAYOUT(state->objlseg->lseg.pls_layout);
+		struct objlayout *objlay = OBJLAYOUT(state->lseg->pls_layout);
 
 		spin_lock(&objlay->lock);
 		objlay->delta_space_valid = OBJ_DSU_INVALID;
diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
index 01a3e4f..83bc36f 100644
--- a/fs/nfs/objlayout/objlayout.h
+++ b/fs/nfs/objlayout/objlayout.h
@@ -46,15 +46,6 @@
 #include "../pnfs.h"
 
 /*
- * in-core layout segment
- */
-struct objlayout_segment {
-	struct pnfs_layout_segment lseg;
-	void *internal;    /* for provider internal use */
-	struct pnfs_osd_layout layout;
-};
-
-/*
  * per-inode layout
  */
 struct objlayout {
@@ -84,7 +75,7 @@ OBJLAYOUT(struct pnfs_layout_hdr *lo)
  * embedded in objects provider io_state data structure
  */
 struct objlayout_io_state {
-	struct objlayout_segment *objlseg;
+	struct pnfs_layout_segment *lseg;
 
 	struct page **pages;
 	unsigned pgbase;
@@ -115,13 +106,15 @@ struct objlayout_io_state {
 extern void *objio_init_mt(void);
 extern void objio_fini_mt(void *mt);
 
-extern int objio_alloc_lseg(void **outp,
+extern int objio_alloc_lseg(struct pnfs_layout_segment **outp,
 	struct pnfs_layout_hdr *pnfslay,
-	struct pnfs_layout_segment *lseg,
-	struct pnfs_osd_layout *layout);
-extern void objio_free_lseg(void *p);
+	struct pnfs_layout_range *range,
+	struct xdr_stream *xdr);
+extern void objio_free_lseg(struct pnfs_layout_segment *lseg);
 
-extern int objio_alloc_io_state(void *seg, struct objlayout_io_state **outp);
+extern int objio_alloc_io_state(
+	struct pnfs_layout_segment *lseg,
+	struct objlayout_io_state **outp);
 extern void objio_free_io_state(struct objlayout_io_state *state);
 
 extern ssize_t objio_read_pagelist(struct objlayout_io_state *ol_state);
@@ -138,7 +131,7 @@ extern void objlayout_io_set_result(struct objlayout_io_state *state,
 static inline void
 objlayout_add_delta_space_used(struct objlayout_io_state *state, s64 space_used)
 {
-	struct objlayout *objlay = OBJLAYOUT(state->objlseg->lseg.pls_layout);
+	struct objlayout *objlay = OBJLAYOUT(state->lseg->pls_layout);
 
 	/* If one of the I/Os errored out and the delta_space_used was
 	 * invalid we render the complete report as invalid. Protocol mandate
-- 
1.7.2.3


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:52245 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755712Ab1JDKgb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Oct 2011 06:36:31 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>, Brent Welch <welch@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 17/19] pnfs-obj: move to ore 01: ore_layout & ore_components
Date: Tue, 4 Oct 2011 12:36:21 +0200
Message-ID: <1317724581-27825-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4E8ADEDA.4050709@panasas.com>
References: <4E8ADEDA.4050709@panasas.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

For Ease of reviewing I split the move to ore into 3 parts
	move to ore 01: ore_layout & ore_components
	move to ore 02: move to ORE
	move to ore 03: Remove old raid engine

This patch modifies the objio_lseg, layout-segment level
and devices and components arrays to use the ORE types.

Though it will be removed soon, also the raid engine
is modified to actually compile, possibly run, with
the new types. So it is the same old raid engine but
with some new ORE types.

For Ease of reviewing, some of the old code is
"#if 0" but is not removed so the diff command works
better. The old code will be removed in the 3rd patch.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |  272 ++++++++++++++++++++----------------------
 1 files changed, 128 insertions(+), 144 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 2347e0a..bd7ec26 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -38,7 +38,7 @@
  */
 
 #include <linux/module.h>
-#include <scsi/osd_initiator.h>
+#include <scsi/osd_ore.h>
 
 #include "objlayout.h"
 
@@ -52,7 +52,7 @@ enum { BIO_MAX_PAGES_KMALLOC =
 
 struct objio_dev_ent {
 	struct nfs4_deviceid_node id_node;
-	struct osd_dev *od;
+	struct ore_dev od;
 };
 
 static void
@@ -60,8 +60,8 @@ objio_free_deviceid_node(struct nfs4_deviceid_node *d)
 {
 	struct objio_dev_ent *de = container_of(d, struct objio_dev_ent, id_node);
 
-	dprintk("%s: free od=%p\n", __func__, de->od);
-	osduld_put_device(de->od);
+	dprintk("%s: free od=%p\n", __func__, de->od.od);
+	osduld_put_device(de->od.od);
 	kfree(de);
 }
 
@@ -98,12 +98,12 @@ _dev_list_add(const struct nfs_server *nfss,
 				nfss->pnfs_curr_ld,
 				nfss->nfs_client,
 				d_id);
-	de->od = od;
+	de->od.od = od;
 
 	d = nfs4_insert_deviceid_node(&de->id_node);
 	n = container_of(d, struct objio_dev_ent, id_node);
 	if (n != de) {
-		dprintk("%s: Race with other n->od=%p\n", __func__, n->od);
+		dprintk("%s: Race with other n->od=%p\n", __func__, n->od.od);
 		objio_free_deviceid_node(&de->id_node);
 		de = n;
 	}
@@ -111,28 +111,11 @@ _dev_list_add(const struct nfs_server *nfss,
 	return de;
 }
 
-struct caps_buffers {
-	u8 caps_key[OSD_CRYPTO_KEYID_SIZE];
-	u8 creds[OSD_CAP_LEN];
-};
-
 struct objio_segment {
 	struct pnfs_layout_segment lseg;
 
-	struct pnfs_osd_object_cred *comps;
-
-	unsigned mirrors_p1;
-	unsigned stripe_unit;
-	unsigned group_width;	/* Data stripe_units without integrity comps */
-	u64 group_depth;
-	unsigned group_count;
-
-	unsigned max_io_size;
-
-	unsigned comps_index;
-	unsigned num_comps;
-	/* variable length */
-	struct objio_dev_ent *ods[];
+	struct ore_layout layout;
+	struct ore_components oc;
 };
 
 static inline struct objio_segment *
@@ -155,7 +138,8 @@ struct objio_state {
 	loff_t offset;
 	bool sync;
 
-	struct objio_segment *layout;
+	struct ore_layout *layout;
+	struct ore_components *oc;
 
 	struct kref kref;
 	objio_done_fn done;
@@ -175,32 +159,33 @@ struct objio_state {
 
 /* Send and wait for a get_device_info of devices in the layout,
    then look them up with the osd_initiator library */
-static struct objio_dev_ent *_device_lookup(struct pnfs_layout_hdr *pnfslay,
-				struct objio_segment *objio_seg, unsigned comp,
-				gfp_t gfp_flags)
+static int objio_devices_lookup(struct pnfs_layout_hdr *pnfslay,
+	struct objio_segment *objio_seg, unsigned c, struct nfs4_deviceid *d_id,
+	gfp_t gfp_flags)
 {
 	struct pnfs_osd_deviceaddr *deviceaddr;
-	struct nfs4_deviceid *d_id;
 	struct objio_dev_ent *ode;
 	struct osd_dev *od;
 	struct osd_dev_info odi;
 	int err;
 
-	d_id = &objio_seg->comps[comp].oc_object_id.oid_device_id;
-
 	ode = _dev_list_find(NFS_SERVER(pnfslay->plh_inode), d_id);
-	if (ode)
-		return ode;
+	if (ode) {
+		objio_seg->oc.ods[c] = &ode->od; /* must use container_of */
+		return 0;
+	}
 
 	err = objlayout_get_deviceinfo(pnfslay, d_id, &deviceaddr, gfp_flags);
 	if (unlikely(err)) {
 		dprintk("%s: objlayout_get_deviceinfo dev(%llx:%llx) =>%d\n",
 			__func__, _DEVID_LO(d_id), _DEVID_HI(d_id), err);
-		return ERR_PTR(err);
+		return err;
 	}
 
 	odi.systemid_len = deviceaddr->oda_systemid.len;
 	if (odi.systemid_len > sizeof(odi.systemid)) {
+		dprintk("%s: odi.systemid_len > sizeof(systemid=%zd)\n",
+			__func__, sizeof(odi.systemid));
 		err = -EINVAL;
 		goto out;
 	} else if (odi.systemid_len)
@@ -225,38 +210,15 @@ static struct objio_dev_ent *_device_lookup(struct pnfs_layout_hdr *pnfslay,
 
 	ode = _dev_list_add(NFS_SERVER(pnfslay->plh_inode), d_id, od,
 			    gfp_flags);
-
+	objio_seg->oc.ods[c] = &ode->od; /* must use container_of */
+	dprintk("Adding new dev_id(%llx:%llx)\n",
+		_DEVID_LO(d_id), _DEVID_HI(d_id));
 out:
-	dprintk("%s: return=%d\n", __func__, err);
 	objlayout_put_deviceinfo(deviceaddr);
-	return err ? ERR_PTR(err) : ode;
-}
-
-static int objio_devices_lookup(struct pnfs_layout_hdr *pnfslay,
-	struct objio_segment *objio_seg,
-	gfp_t gfp_flags)
-{
-	unsigned i;
-	int err;
-
-	/* lookup all devices */
-	for (i = 0; i < objio_seg->num_comps; i++) {
-		struct objio_dev_ent *ode;
-
-		ode = _device_lookup(pnfslay, objio_seg, i, gfp_flags);
-		if (unlikely(IS_ERR(ode))) {
-			err = PTR_ERR(ode);
-			goto out;
-		}
-		objio_seg->ods[i] = ode;
-	}
-	err = 0;
-
-out:
-	dprintk("%s: return=%d\n", __func__, err);
 	return err;
 }
 
+#if 0
 static int _verify_data_map(struct pnfs_osd_layout *layout)
 {
 	struct pnfs_osd_data_map *data_map = &layout->olo_map;
@@ -296,23 +258,45 @@ static int _verify_data_map(struct pnfs_osd_layout *layout)
 
 	return 0;
 }
+#endif
 
-static void copy_single_comp(struct pnfs_osd_object_cred *cur_comp,
-			     struct pnfs_osd_object_cred *src_comp,
-			     struct caps_buffers *caps_p)
+static void copy_single_comp(struct ore_components *oc, unsigned c,
+			     struct pnfs_osd_object_cred *src_comp)
 {
-	WARN_ON(src_comp->oc_cap_key.cred_len > sizeof(caps_p->caps_key));
-	WARN_ON(src_comp->oc_cap.cred_len > sizeof(caps_p->creds));
+	struct ore_comp *ocomp = &oc->comps[c];
 
-	*cur_comp = *src_comp;
+	WARN_ON(src_comp->oc_cap_key.cred_len > 0); /* libosd is NO_SEC only */
+	WARN_ON(src_comp->oc_cap.cred_len > sizeof(ocomp->cred));
 
-	memcpy(caps_p->caps_key, src_comp->oc_cap_key.cred,
-	       sizeof(caps_p->caps_key));
-	cur_comp->oc_cap_key.cred = caps_p->caps_key;
+	ocomp->obj.partition = src_comp->oc_object_id.oid_partition_id;
+	ocomp->obj.id = src_comp->oc_object_id.oid_object_id;
 
-	memcpy(caps_p->creds, src_comp->oc_cap.cred,
-	       sizeof(caps_p->creds));
-	cur_comp->oc_cap.cred = caps_p->creds;
+	memcpy(ocomp->cred, src_comp->oc_cap.cred, sizeof(ocomp->cred));
+}
+
+int __alloc_objio_seg(unsigned numdevs, gfp_t gfp_flags,
+		       struct objio_segment **pseg)
+{
+	struct __alloc_objio_segment {
+		struct objio_segment olseg;
+		struct ore_dev *ods[numdevs];
+		struct ore_comp	comps[numdevs];
+	} *aolseg;
+
+	aolseg = kzalloc(sizeof(*aolseg), gfp_flags);
+	if (unlikely(!aolseg)) {
+		dprintk("%s: Faild allocation numdevs=%d size=%zd\n", __func__,
+			numdevs, sizeof(*aolseg));
+		return -ENOMEM;
+	}
+
+	aolseg->olseg.oc.numdevs = numdevs;
+	aolseg->olseg.oc.single_comp = EC_MULTPLE_COMPS;
+	aolseg->olseg.oc.comps = aolseg->comps;
+	aolseg->olseg.oc.ods = aolseg->ods;
+
+	*pseg = &aolseg->olseg;
+	return 0;
 }
 
 int objio_alloc_lseg(struct pnfs_layout_segment **outp,
@@ -324,59 +308,43 @@ int objio_alloc_lseg(struct pnfs_layout_segment **outp,
 	struct objio_segment *objio_seg;
 	struct pnfs_osd_xdr_decode_layout_iter iter;
 	struct pnfs_osd_layout layout;
-	struct pnfs_osd_object_cred *cur_comp, src_comp;
-	struct caps_buffers *caps_p;
+	struct pnfs_osd_object_cred src_comp;
+	unsigned cur_comp;
 	int err;
 
 	err = pnfs_osd_xdr_decode_layout_map(&layout, &iter, xdr);
 	if (unlikely(err))
 		return err;
 
-	err = _verify_data_map(&layout);
+	err = __alloc_objio_seg(layout.olo_num_comps, gfp_flags, &objio_seg);
 	if (unlikely(err))
 		return err;
 
-	objio_seg = kzalloc(sizeof(*objio_seg) +
-			    sizeof(objio_seg->ods[0]) * layout.olo_num_comps +
-			    sizeof(*objio_seg->comps) * layout.olo_num_comps +
-			    sizeof(struct caps_buffers) * layout.olo_num_comps,
-			    gfp_flags);
-	if (!objio_seg)
-		return -ENOMEM;
+	objio_seg->layout.stripe_unit = layout.olo_map.odm_stripe_unit;
+	objio_seg->layout.group_width = layout.olo_map.odm_group_width;
+	objio_seg->layout.group_depth = layout.olo_map.odm_group_depth;
+	objio_seg->layout.mirrors_p1 = layout.olo_map.odm_mirror_cnt + 1;
+	objio_seg->layout.raid_algorithm = layout.olo_map.odm_raid_algorithm;
 
-	objio_seg->comps = (void *)(objio_seg->ods + layout.olo_num_comps);
-	cur_comp = objio_seg->comps;
-	caps_p = (void *)(cur_comp + layout.olo_num_comps);
-	while (pnfs_osd_xdr_decode_layout_comp(&src_comp, &iter, xdr, &err))
-		copy_single_comp(cur_comp++, &src_comp, caps_p++);
+	err = ore_verify_layout(layout.olo_map.odm_num_comps,
+					  &objio_seg->layout);
 	if (unlikely(err))
 		goto err;
 
-	objio_seg->num_comps = layout.olo_num_comps;
-	objio_seg->comps_index = layout.olo_comps_index;
-	err = objio_devices_lookup(pnfslay, objio_seg, gfp_flags);
-	if (err)
-		goto err;
-
-	objio_seg->mirrors_p1 = layout.olo_map.odm_mirror_cnt + 1;
-	objio_seg->stripe_unit = layout.olo_map.odm_stripe_unit;
-	if (layout.olo_map.odm_group_width) {
-		objio_seg->group_width = layout.olo_map.odm_group_width;
-		objio_seg->group_depth = layout.olo_map.odm_group_depth;
-		objio_seg->group_count = layout.olo_map.odm_num_comps /
-						objio_seg->mirrors_p1 /
-						objio_seg->group_width;
-	} else {
-		objio_seg->group_width = layout.olo_map.odm_num_comps /
-						objio_seg->mirrors_p1;
-		objio_seg->group_depth = -1;
-		objio_seg->group_count = 1;
+	objio_seg->oc.first_dev = layout.olo_comps_index;
+	cur_comp = 0;
+	while (pnfs_osd_xdr_decode_layout_comp(&src_comp, &iter, xdr, &err)) {
+		copy_single_comp(&objio_seg->oc, cur_comp, &src_comp);
+		err = objio_devices_lookup(pnfslay, objio_seg, cur_comp,
+					   &src_comp.oc_object_id.oid_device_id,
+					   gfp_flags);
+		if (err)
+			goto err;
+		++cur_comp;
 	}
-
-	/* Cache this calculation it will hit for every page */
-	objio_seg->max_io_size = (BIO_MAX_PAGES_KMALLOC * PAGE_SIZE -
-				  objio_seg->stripe_unit) *
-				 objio_seg->group_width;
+	/* pnfs_osd_xdr_decode_layout_comp returns false on error */
+	if (unlikely(err))
+		goto err;
 
 	*outp = &objio_seg->lseg;
 	return 0;
@@ -393,10 +361,14 @@ void objio_free_lseg(struct pnfs_layout_segment *lseg)
 	int i;
 	struct objio_segment *objio_seg = OBJIO_LSEG(lseg);
 
-	for (i = 0; i < objio_seg->num_comps; i++) {
-		if (!objio_seg->ods[i])
+	for (i = 0; i < objio_seg->oc.numdevs; i++) {
+		struct ore_dev *od = objio_seg->oc.ods[i];
+		struct objio_dev_ent *ode;
+
+		if (!od)
 			break;
-		nfs4_put_deviceid_node(&objio_seg->ods[i]->id_node);
+		ode = container_of(od, typeof(*ode), od);
+		nfs4_put_deviceid_node(&ode->id_node);
 	}
 	kfree(objio_seg);
 }
@@ -411,8 +383,8 @@ objio_alloc_io_state(struct pnfs_layout_hdr *pnfs_layout_type,
 	struct objio_state *ios;
 	struct __alloc_objio_state {
 		struct objio_state objios;
-		struct _objio_per_comp per_dev[objio_seg->num_comps];
-		struct pnfs_osd_ioerr ioerrs[objio_seg->num_comps];
+		struct _objio_per_comp per_dev[objio_seg->oc.numdevs];
+		struct pnfs_osd_ioerr ioerrs[objio_seg->oc.numdevs];
 	} *aos;
 
 	aos = kzalloc(sizeof(*aos), gfp_flags);
@@ -421,8 +393,9 @@ objio_alloc_io_state(struct pnfs_layout_hdr *pnfs_layout_type,
 
 	ios = &aos->objios;
 
-	ios->layout = objio_seg;
-	objlayout_init_ioerrs(&aos->objios.oir, objio_seg->num_comps,
+	ios->layout = &objio_seg->layout;
+	ios->oc = &objio_seg->oc;
+	objlayout_init_ioerrs(&aos->objios.oir, objio_seg->oc.numdevs,
 			aos->ioerrs, rpcdata, pnfs_layout_type);
 
 	ios->pages = pages;
@@ -474,6 +447,27 @@ enum pnfs_osd_errno osd_pri_2_pnfs_err(enum osd_err_priority oep)
 	}
 }
 
+static void __on_dev_error(struct objio_state *ios, bool is_write,
+	struct ore_dev *od, unsigned dev_index, enum osd_err_priority oep,
+	u64 dev_offset, u64  dev_len)
+{
+	struct objio_state *objios = ios->private;
+	struct pnfs_osd_objid pooid;
+	struct objio_dev_ent *ode = container_of(od, typeof(*ode), od);
+	/* FIXME: what to do with more-then-one-group layouts. We need to
+	 * translate from ore_io_state index to oc->comps index
+	 */
+	unsigned comp = dev_index;
+
+	pooid.oid_device_id = ode->id_node.deviceid;
+	pooid.oid_partition_id = ios->oc->comps[comp].obj.partition;
+	pooid.oid_object_id = ios->oc->comps[comp].obj.id;
+
+	objlayout_io_set_result(&objios->oir, comp,
+				&pooid, osd_pri_2_pnfs_err(oep),
+				dev_offset, dev_len, is_write);
+}
+
 static void _clear_bio(struct bio *bio)
 {
 	struct bio_vec *bv;
@@ -518,12 +512,9 @@ static int _io_check(struct objio_state *ios, bool is_write)
 
 			continue; /* we recovered */
 		}
-		objlayout_io_set_result(&ios->oir, i,
-					&ios->layout->comps[i].oc_object_id,
-					osd_pri_2_pnfs_err(osi.osd_err_pri),
-					ios->per_dev[i].offset,
-					ios->per_dev[i].length,
-					is_write);
+		__on_dev_error(ios, is_write, ios->oc->ods[i],
+				ios->per_dev[i].dev, osi.osd_err_pri,
+				ios->per_dev[i].offset, ios->per_dev[i].length);
 
 		if (osi.osd_err_pri >= oep) {
 			oep = osi.osd_err_pri;
@@ -558,11 +549,11 @@ static void _io_free(struct objio_state *ios)
 
 struct osd_dev *_io_od(struct objio_state *ios, unsigned dev)
 {
-	unsigned min_dev = ios->layout->comps_index;
-	unsigned max_dev = min_dev + ios->layout->num_comps;
+	unsigned min_dev = ios->oc->first_dev;
+	unsigned max_dev = min_dev + ios->oc->numdevs;
 
 	BUG_ON(dev < min_dev || max_dev <= dev);
-	return ios->layout->ods[dev - min_dev]->od;
+	return ios->oc->ods[dev - min_dev]->od;
 }
 
 struct _striping_info {
@@ -820,12 +811,9 @@ static int _read_mirrors(struct objio_state *ios, unsigned cur_comp)
 	struct osd_request *or = NULL;
 	struct _objio_per_comp *per_dev = &ios->per_dev[cur_comp];
 	unsigned dev = per_dev->dev;
-	struct pnfs_osd_object_cred *cred =
-			&ios->layout->comps[cur_comp];
-	struct osd_obj_id obj = {
-		.partition = cred->oc_object_id.oid_partition_id,
-		.id = cred->oc_object_id.oid_object_id,
-	};
+	struct ore_comp *cred =
+			&ios->oc->comps[cur_comp];
+	struct osd_obj_id obj = cred->obj;
 	int ret;
 
 	or = osd_start_request(_io_od(ios, dev), GFP_KERNEL);
@@ -837,7 +825,7 @@ static int _read_mirrors(struct objio_state *ios, unsigned cur_comp)
 
 	osd_req_read(or, &obj, per_dev->offset, per_dev->bio, per_dev->length);
 
-	ret = osd_finalize_request(or, 0, cred->oc_cap.cred, NULL);
+	ret = osd_finalize_request(or, 0, cred->cred, NULL);
 	if (ret) {
 		dprintk("%s: Faild to osd_finalize_request() => %d\n",
 			__func__, ret);
@@ -924,12 +912,8 @@ static int _write_mirrors(struct objio_state *ios, unsigned cur_comp)
 
 	for (; cur_comp < last_comp; ++cur_comp, ++dev) {
 		struct osd_request *or = NULL;
-		struct pnfs_osd_object_cred *cred =
-					&ios->layout->comps[cur_comp];
-		struct osd_obj_id obj = {
-			.partition = cred->oc_object_id.oid_partition_id,
-			.id = cred->oc_object_id.oid_object_id,
-		};
+		struct ore_comp *cred = &ios->oc->comps[cur_comp];
+		struct osd_obj_id obj = cred->obj;
 		struct _objio_per_comp *per_dev = &ios->per_dev[cur_comp];
 		struct bio *bio;
 
@@ -964,7 +948,7 @@ static int _write_mirrors(struct objio_state *ios, unsigned cur_comp)
 
 		osd_req_write(or, &obj, per_dev->offset, bio, per_dev->length);
 
-		ret = osd_finalize_request(or, 0, cred->oc_cap.cred, NULL);
+		ret = osd_finalize_request(or, 0, cred->cred, NULL);
 		if (ret) {
 			dprintk("%s: Faild to osd_finalize_request() => %d\n",
 				__func__, ret);
@@ -1030,7 +1014,7 @@ static bool objio_pg_test(struct nfs_pageio_descriptor *pgio,
 		return false;
 
 	return pgio->pg_count + req->wb_bytes <=
-			OBJIO_LSEG(pgio->pg_lseg)->max_io_size;
+			OBJIO_LSEG(pgio->pg_lseg)->layout.max_io_length;
 }
 
 static const struct nfs_pageio_ops objio_pg_read_ops = {
-- 
1.7.2.3


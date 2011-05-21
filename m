Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:19759 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752929Ab1EUKbd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 May 2011 06:31:33 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 05/13] SQUASHME: pnfs-obj: Convert layout and deviceinfo decoding to new XDR
Date: Sat, 21 May 2011 13:31:21 +0300
Message-Id: <1305973881-17361-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DD79273.9030202@panasas.com>
References: <4DD79273.9030202@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Change layout_decoding API into two parts, avoid double pass
and allocations.

It is better for users to first inspect the map information
before attempting to decoding the comps array. This is so
the proper dynamic allocations can be made.

So break up pnfs_osd_xdr_decode_layout() into:
	1. pnfs_osd_xdr_decode_layout_map()
	2. while (pnfs_osd_xdr_decode_layout_comp()) ...

With new API it is easy to convert every thing to a single
pass and use the new XDR API.

get deviceinfo is not using an xdr_stream but is also converted
to more uptodate coding style.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objlayout.c        |   60 +++++--
 fs/nfs/objlayout/objlayout.h        |    2 +-
 fs/nfs/objlayout/pnfs_osd_xdr_cli.c |  349 +++++++++++++++++------------------
 include/linux/pnfs_osd_xdr.h        |  181 ++++++-------------
 4 files changed, 271 insertions(+), 321 deletions(-)

diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index a04e232..1ab9bdc 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -75,6 +75,28 @@ objlayout_free_layout_hdr(struct pnfs_layout_hdr *lo)
 	kfree(objlay);
 }
 
+struct caps_buffers {
+	u8 caps_key[OSD_CRYPTO_KEYID_SIZE];
+	u8 creds[OSD_CAP_LEN];
+};
+
+static void copy_single_comp(struct pnfs_osd_object_cred *cur_comp,
+			     struct pnfs_osd_object_cred *src_comp,
+			     struct caps_buffers *caps_p)
+{
+	WARN_ON(src_comp->oc_cap_key.cred_len > sizeof(caps_p->caps_key) >> 2);
+	WARN_ON(src_comp->oc_cap.cred_len > sizeof(caps_p->creds) >> 2);
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
 /*
  * Unmarshall layout and store it in pnfslay.
  */
@@ -91,9 +113,11 @@ objlayout_alloc_lseg(struct pnfs_layout_hdr *pnfslay,
 		.len = lgr->layoutp->len,
 	};
 	struct page *scratch;
-	__be32 *p;
 	struct objlayout_segment *objlseg = NULL;
-	struct pnfs_osd_layout *pnfs_osd_layout;
+	struct pnfs_osd_layout *layout;
+	struct pnfs_osd_object_cred *cur_comp, src_comp;
+	struct caps_buffers *caps_p;
+	struct pnfs_osd_xdr_decode_layout_iter iter;
 
 	dprintk("%s: Begin pnfslay %p\n", __func__, pnfslay);
 
@@ -104,21 +128,32 @@ objlayout_alloc_lseg(struct pnfs_layout_hdr *pnfslay,
 	xdr_init_decode(&stream, &buf, NULL);
 	xdr_set_scratch_buffer(&stream, page_address(scratch), PAGE_SIZE);
 
-	p = xdr_inline_decode(&stream, pnfs_osd_data_map_xdr_sz() << 2);
-	if (unlikely(!p))
+	layout = &objlseg->layout;
+	status = pnfs_osd_xdr_decode_layout_map(layout, &iter, &stream);
+	if (unlikely(status))
 		goto err;
 
 	objlseg = kzalloc(sizeof(*objlseg) +
-			  pnfs_osd_layout_incore_sz(p), GFP_KERNEL);
-	if (!objlseg)
+			  sizeof(*layout->olo_comps) * layout->olo_num_comps +
+			  sizeof(struct caps_buffers) * layout->olo_num_comps,
+			  GFP_KERNEL);
+	if (unlikely(!objlseg)) {
+		status = -ENOMEM;
 		goto err;
+	}
 
-	pnfs_osd_layout = (struct pnfs_osd_layout *)objlseg->pnfs_osd_layout;
-	pnfs_osd_xdr_decode_layout(pnfs_osd_layout, p);
+	cur_comp = layout->olo_comps = (void *)(objlseg + 1);
+	caps_p = (void *)(cur_comp + layout->olo_num_comps);
+	while(pnfs_osd_xdr_decode_layout_comp(&src_comp, &iter, &stream,
+					      &status)) {
+		copy_single_comp(cur_comp++, &src_comp, caps_p++);
+	}
+	if (unlikely(status))
+		goto err;
 
 	objlseg->lseg.pls_range = lgr->range;
 	status = objio_alloc_lseg(&objlseg->internal, pnfslay, &objlseg->lseg,
-				  pnfs_osd_layout);
+				  layout);
 	if (status)
 		goto err;
 
@@ -263,8 +298,7 @@ objlayout_io_set_result(struct objlayout_io_state *state, unsigned index,
 
 	BUG_ON(index >= state->num_comps);
 	if (osd_error) {
-		struct pnfs_osd_layout *layout =
-			(typeof(layout))state->objlseg->pnfs_osd_layout;
+		struct pnfs_osd_layout *layout = &state->objlseg->layout;
 
 		ioerr->oer_component = layout->olo_comps[index].oc_object_id;
 		ioerr->oer_comp_offset = offset;
@@ -674,7 +708,6 @@ int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
 	struct pnfs_device pd;
 	struct super_block *sb;
 	struct page *page, **pages;
-	size_t sz;
 	u32 *p;
 	int err;
 
@@ -699,8 +732,7 @@ int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
 		goto err_out;
 
 	p = page_address(page);
-	sz = pnfs_osd_xdr_deviceaddr_incore_sz(p);
-	odi = kzalloc(sz + (sizeof(*odi) - sizeof(odi->da)), GFP_KERNEL);
+	odi = kzalloc(sizeof(*odi), GFP_KERNEL);
 	if (!odi) {
 		err = -ENOMEM;
 		goto err_out;
diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
index 38abb01..6ea54f6 100644
--- a/fs/nfs/objlayout/objlayout.h
+++ b/fs/nfs/objlayout/objlayout.h
@@ -51,7 +51,7 @@
 struct objlayout_segment {
 	struct pnfs_layout_segment lseg;
 	void *internal;    /* for provider internal use */
-	u8 pnfs_osd_layout[];
+	struct pnfs_osd_layout layout;
 };
 
 /*
diff --git a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
index 4dea458..b55131c 100644
--- a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
+++ b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
@@ -5,6 +5,7 @@
  *  All rights reserved.
  *
  *  Benny Halevy <bhalevy@panasas.com>
+ *  Boaz Harrosh <bharrosh@panasas.com>
  *
  *  This program is free software; you can redistribute it and/or modify
  *  it under the terms of the GNU General Public License version 2
@@ -49,24 +50,42 @@
  * 	struct pnfs_deviceid	oid_device_id;
  * 	u64			oid_partition_id;
  * 	u64			oid_object_id;
- * };
+ * }; // xdr size 32 bytes
  */
-static inline __be32 *
-pnfs_osd_xdr_decode_objid(__be32 *p, struct pnfs_osd_objid *objid)
+static __be32 *
+_osd_xdr_decode_objid(__be32 *p, struct pnfs_osd_objid *objid)
 {
-	COPYMEM(objid->oid_device_id.data, sizeof(objid->oid_device_id.data));
-	READ64(objid->oid_partition_id);
-	READ64(objid->oid_object_id);
+	p = xdr_decode_opaque_fixed(p, objid->oid_device_id.data,
+				    sizeof(objid->oid_device_id.data));
+
+	p = xdr_decode_hyper(p, &objid->oid_partition_id);
+	p = xdr_decode_hyper(p, &objid->oid_object_id);
 	return p;
 }
-
-static inline __be32 *
-pnfs_osd_xdr_decode_opaque_cred(__be32 *p,
-				struct pnfs_osd_opaque_cred *opaque_cred)
+/*
+ * struct pnfs_osd_opaque_cred {
+ * 	u32 cred_len;
+ * 	void *cred;
+ * }; // xdr size [variable]
+ * The return pointers are from the xdr buffer
+ */
+static int
+_osd_xdr_decode_opaque_cred(struct pnfs_osd_opaque_cred *opaque_cred,
+			    struct xdr_stream *xdr)
 {
-	READ32(opaque_cred->cred_len);
-	COPYMEM(opaque_cred->cred, opaque_cred->cred_len);
-	return p;
+	__be32 *p = xdr_inline_decode(xdr, 1);
+
+	if (!p)
+		return -EINVAL;
+
+	opaque_cred->cred_len = be32_to_cpu(*p++);
+
+	p = xdr_inline_decode(xdr, opaque_cred->cred_len);
+	if (!p)
+		return -EINVAL;
+
+	opaque_cred->cred = p;
+	return 0;
 }
 
 /*
@@ -76,28 +95,28 @@ pnfs_osd_xdr_decode_opaque_cred(__be32 *p,
  * 	u32				oc_cap_key_sec;
  * 	struct pnfs_osd_opaque_cred	oc_cap_key
  * 	struct pnfs_osd_opaque_cred	oc_cap;
- * };
+ * }; // xdr size 32 + 4 + 4 + [variable] + [variable]
  */
-static inline __be32 *
-pnfs_osd_xdr_decode_object_cred(__be32 *p, struct pnfs_osd_object_cred *comp,
-				u8 **credp)
+static int
+_osd_xdr_decode_object_cred(struct pnfs_osd_object_cred *comp,
+			    struct xdr_stream *xdr)
 {
-	u8 *cred;
+	__be32 *p = xdr_inline_decode(xdr, 32 + 4 + 4);
+	int ret;
+
+	if (!p)
+		return -EIO;
 
-	p = pnfs_osd_xdr_decode_objid(p, &comp->oc_object_id);
-	READ32(comp->oc_osd_version);
-	READ32(comp->oc_cap_key_sec);
+	p = _osd_xdr_decode_objid(p, &comp->oc_object_id);
+	comp->oc_osd_version = be32_to_cpup(p++);
+	comp->oc_cap_key_sec = be32_to_cpup(p);
 
-	cred = *credp;
-	comp->oc_cap_key.cred = cred;
-	p = pnfs_osd_xdr_decode_opaque_cred(p, &comp->oc_cap_key);
-	cred = (u8 *)((u32 *)cred + XDR_QUADLEN(comp->oc_cap_key.cred_len));
-	comp->oc_cap.cred = cred;
-	p = pnfs_osd_xdr_decode_opaque_cred(p, &comp->oc_cap);
-	cred = (u8 *)((u32 *)cred + XDR_QUADLEN(comp->oc_cap.cred_len));
-	*credp = cred;
+	ret = _osd_xdr_decode_opaque_cred(&comp->oc_cap_key, xdr);
+	if (unlikely(ret))
+		return ret;
 
-	return p;
+	ret = _osd_xdr_decode_opaque_cred(&comp->oc_cap, xdr);
+	return ret;
 }
 
 /*
@@ -108,17 +127,23 @@ pnfs_osd_xdr_decode_object_cred(__be32 *p, struct pnfs_osd_object_cred *comp,
  * 	u32	odm_group_depth;
  * 	u32	odm_mirror_cnt;
  * 	u32	odm_raid_algorithm;
- * };
+ * }; // xdr size 4 + 8 + 4 + 4 + 4 + 4
  */
-static inline u32 *
-pnfs_osd_xdr_decode_data_map(__be32 *p, struct pnfs_osd_data_map *data_map)
+static inline int
+_osd_data_map_xdr_sz(void)
 {
-	READ32(data_map->odm_num_comps);
-	READ64(data_map->odm_stripe_unit);
-	READ32(data_map->odm_group_width);
-	READ32(data_map->odm_group_depth);
-	READ32(data_map->odm_mirror_cnt);
-	READ32(data_map->odm_raid_algorithm);
+	return 4 + 8 + 4 + 4 + 4 + 4;
+}
+
+static __be32 *
+_osd_xdr_decode_data_map(__be32 *p, struct pnfs_osd_data_map *data_map)
+{
+	data_map->odm_num_comps = be32_to_cpup(p++);
+	p = xdr_decode_hyper(p, &data_map->odm_stripe_unit);
+	data_map->odm_group_width = be32_to_cpup(p++);
+	data_map->odm_group_depth = be32_to_cpup(p++);
+	data_map->odm_mirror_cnt = be32_to_cpup(p++);
+	data_map->odm_raid_algorithm = be32_to_cpup(p++);
 	dprintk("%s: odm_num_comps=%u odm_stripe_unit=%llu odm_group_width=%u "
 		"odm_group_depth=%u odm_mirror_cnt=%u odm_raid_algorithm=%u\n",
 		__func__,
@@ -131,92 +156,74 @@ pnfs_osd_xdr_decode_data_map(__be32 *p, struct pnfs_osd_data_map *data_map)
 	return p;
 }
 
-struct pnfs_osd_layout *
-pnfs_osd_xdr_decode_layout(struct pnfs_osd_layout *layout, __be32 *p)
+int pnfs_osd_xdr_decode_layout_map(struct pnfs_osd_layout *layout,
+	struct pnfs_osd_xdr_decode_layout_iter *iter, struct xdr_stream *xdr)
+{
+	__be32 *p;
+
+	memset(iter, 0, sizeof(*iter));
+
+	p = xdr_inline_decode(xdr, _osd_data_map_xdr_sz() + 4 + 4);
+	if (unlikely(!p))
+		return -EINVAL;
+
+	p = _osd_xdr_decode_data_map(p, &layout->olo_map);
+	layout->olo_comps_index = be32_to_cpup(p++);
+	layout->olo_num_comps = be32_to_cpup(p++);
+	iter->total_comps = layout->olo_num_comps;
+	return 0;
+}
+
+bool pnfs_osd_xdr_decode_layout_comp(struct pnfs_osd_object_cred *comp,
+	struct pnfs_osd_xdr_decode_layout_iter *iter, struct xdr_stream *xdr,
+	int *err)
 {
-	int i;
-	__be32 *start = p;
-	struct pnfs_osd_object_cred *comp;
-	u8 *cred;
-
-	p = pnfs_osd_xdr_decode_data_map(p, &layout->olo_map);
-	READ32(layout->olo_comps_index);
-	READ32(layout->olo_num_comps);
-	layout->olo_comps = (struct pnfs_osd_object_cred *)(layout + 1);
-	comp = layout->olo_comps;
-	cred = (u8 *)(comp + layout->olo_num_comps);
-	dprintk("%s: comps_index=%u num_comps=%u\n",
-		__func__, layout->olo_comps_index, layout->olo_num_comps);
-	for (i = 0; i < layout->olo_num_comps; i++) {
-		p = pnfs_osd_xdr_decode_object_cred(p, comp, &cred);
-		dprintk("%s: comp[%d]=dev(%llx:%llx) par=0x%llx obj=0x%llx "
-			"key_len=%u cap_len=%u\n",
-			__func__, i,
-			_DEVID_LO(&comp->oc_object_id.oid_device_id),
-			_DEVID_HI(&comp->oc_object_id.oid_device_id),
-			comp->oc_object_id.oid_partition_id,
-			comp->oc_object_id.oid_object_id,
-			comp->oc_cap_key.cred_len, comp->oc_cap.cred_len);
-		comp++;
+	BUG_ON(iter->decoded_comps > iter->total_comps);
+	if (iter->decoded_comps == iter->total_comps)
+		return false;
+
+	*err = _osd_xdr_decode_object_cred(comp, xdr);
+	if (unlikely(*err)) {
+		dprintk("%s: _osd_xdr_decode_object_cred=>%d decoded_comps=%d "
+			"total_comps=%d\n",__func__, *err,
+			iter->decoded_comps, iter->total_comps);
+		return false; /* stop the loop */
 	}
-	dprintk("%s: xdr_size=%Zd end=%p in_core_size=%Zd\n", __func__,
-	       (char *)p - (char *)start, cred, (char *)cred - (char *)layout);
-	return layout;
+	dprintk("%s: dev(%llx:%llx) par=0x%llx obj=0x%llx "
+		"key_len=%u cap_len=%u\n",
+		__func__,
+		_DEVID_LO(&comp->oc_object_id.oid_device_id),
+		_DEVID_HI(&comp->oc_object_id.oid_device_id),
+		comp->oc_object_id.oid_partition_id,
+		comp->oc_object_id.oid_object_id,
+		comp->oc_cap_key.cred_len, comp->oc_cap.cred_len);
+
+	iter->decoded_comps++;
+	return true;
 }
 
 /*
  * Get Device Information Decoding
  *
- * Note: since Device Information is currently done synchronously, most
- *       of the actual fields are left inside the rpc buffer and are only
+ * Note: since Device Information is currently done synchronously, all
+ *       variable strings fields are left inside the rpc buffer and are only
  *       pointed to by the pnfs_osd_deviceaddr members. So the read buffer
  *       should not be freed while the returned information is in use.
  */
-
-__be32 *__xdr_read_calc_nfs4_string(
-	__be32 *p, struct nfs4_string *str, u8 **freespace)
-{
-	u32 len;
-	char *data;
-	bool need_copy;
-
-	READ32(len);
-	data = (char *)p;
-
-	if (data[len]) { /* Not null terminated we'll need extra space */
-		data = *freespace;
-		*freespace += len + 1;
-		need_copy = true;
-	} else {
-		need_copy = false;
-	}
-
-	if (str) {
-		str->len = len;
-		str->data = data;
-		if (need_copy) {
-			memcpy(data, p, len);
-			data[len] = 0;
-		}
-	}
-
-	p += XDR_QUADLEN(len);
-	return p;
-}
-
-__be32 *__xdr_read_calc_u8_opaque(
-	__be32 *p, struct nfs4_string *str)
+/*
+ *struct nfs4_string {
+ *	unsigned int len;
+ *	char *data;
+ *}; // size [variable]
+ * NOTE: Returned string points to inside the XDR buffer
+ */
+static __be32 *
+__read_u8_opaque(__be32 *p, struct nfs4_string *str)
 {
-	u32 len;
-
-	READ32(len);
+	str->len = be32_to_cpup(p++);
+	str->data = (char *)p;
 
-	if (str) {
-		str->len = len;
-		str->data = (char *)p;
-	}
-
-	p += XDR_QUADLEN(len);
+	p += XDR_QUADLEN(str->len);
 	return p;
 }
 
@@ -224,22 +231,20 @@ __be32 *__xdr_read_calc_u8_opaque(
  * struct pnfs_osd_targetid {
  * 	u32			oti_type;
  * 	struct nfs4_string	oti_scsi_device_id;
- * };
+ * };// size 4 + [variable]
  */
-__be32 *__xdr_read_calc_targetid(
-	__be32 *p, struct pnfs_osd_targetid* targetid, u8 **freespace)
+static __be32 *
+__read_targetid(__be32 *p, struct pnfs_osd_targetid* targetid)
 {
 	u32 oti_type;
 
-	READ32(oti_type);
-	if (targetid)
-		targetid->oti_type = oti_type;
+	oti_type = be32_to_cpup(p++);
+	targetid->oti_type = oti_type;
 
 	switch (oti_type) {
 	case OBJ_TARGET_SCSI_NAME:
 	case OBJ_TARGET_SCSI_DEVICE_ID:
-		p = __xdr_read_calc_u8_opaque(p,
-			targetid ? &targetid->oti_scsi_device_id : NULL);
+		p = __read_u8_opaque(p, &targetid->oti_scsi_device_id);
 	}
 
 	return p;
@@ -251,17 +256,11 @@ __be32 *__xdr_read_calc_targetid(
  * 	struct nfs4_string	r_addr;
  * };
  */
-__be32 *__xdr_read_calc_net_addr(
-	__be32 *p, struct pnfs_osd_net_addr* netaddr, u8 **freespace)
+static __be32 *
+__read_net_addr(__be32 *p, struct pnfs_osd_net_addr* netaddr)
 {
-
-	p = __xdr_read_calc_nfs4_string(p,
-			netaddr ? &netaddr->r_netid : NULL,
-			freespace);
-
-	p = __xdr_read_calc_nfs4_string(p,
-			netaddr ? &netaddr->r_addr : NULL,
-			freespace);
+	p = __read_u8_opaque(p, &netaddr->r_netid);
+	p = __read_u8_opaque(p, &netaddr->r_addr);
 
 	return p;
 }
@@ -272,19 +271,16 @@ __be32 *__xdr_read_calc_net_addr(
  * 	struct pnfs_osd_net_addr	ota_netaddr;
  * };
  */
-__be32 *__xdr_read_calc_targetaddr(
-	__be32 *p, struct pnfs_osd_targetaddr *targetaddr, u8 **freespace)
+static __be32 *
+__read_targetaddr(__be32 *p, struct pnfs_osd_targetaddr *targetaddr)
 {
 	u32 ota_available;
 
-	READ32(ota_available);
-	if (targetaddr)
-		targetaddr->ota_available = ota_available;
+	ota_available = be32_to_cpup(p++);
+	targetaddr->ota_available = ota_available;
 
 	if (ota_available) {
-		p = __xdr_read_calc_net_addr(p,
-				targetaddr ? &targetaddr->ota_netaddr : NULL,
-				freespace);
+		p = __read_net_addr(p, &targetaddr->ota_netaddr);
 	}
 
 	return p;
@@ -300,56 +296,49 @@ __be32 *__xdr_read_calc_targetaddr(
  * 	struct nfs4_string		oda_osdname;
  * };
  */
-__be32 *__xdr_read_calc_deviceaddr(
-	__be32 *p, struct pnfs_osd_deviceaddr *deviceaddr, u8 **freespace)
-{
-	p = __xdr_read_calc_targetid(p,
-			deviceaddr ? &deviceaddr->oda_targetid : NULL,
-			freespace);
-
-	p = __xdr_read_calc_targetaddr(p,
-			deviceaddr ? &deviceaddr->oda_targetaddr : NULL,
-			freespace);
-
-	if (deviceaddr)
-		COPYMEM(deviceaddr->oda_lun, sizeof(deviceaddr->oda_lun));
-	else
-		p += XDR_QUADLEN(sizeof(deviceaddr->oda_lun));
-
-	p = __xdr_read_calc_u8_opaque(p,
-			deviceaddr ? &deviceaddr->oda_systemid : NULL);
-
-	if (deviceaddr) {
-		p = pnfs_osd_xdr_decode_object_cred(p,
-				&deviceaddr->oda_root_obj_cred, freespace);
-	} else {
-		*freespace += pnfs_osd_object_cred_incore_sz(p);
-		p += pnfs_osd_object_cred_xdr_sz(p);
-	}
-
-	p = __xdr_read_calc_u8_opaque(p,
-			deviceaddr ? &deviceaddr->oda_osdname : NULL);
 
-	return p;
+/* We need this version for the pnfs_osd_xdr_decode_deviceaddr which does
+ * not have an xdr_stream
+ */
+static __be32 *
+__read_opaque_cred(__be32 *p,
+			      struct pnfs_osd_opaque_cred *opaque_cred)
+{
+	opaque_cred->cred_len = be32_to_cpu(*p++);
+	opaque_cred->cred = p;
+	return p + XDR_QUADLEN(opaque_cred->cred_len);
 }
 
-size_t pnfs_osd_xdr_deviceaddr_incore_sz(__be32 *p)
+static __be32 *
+__read_object_cred(__be32 *p, struct pnfs_osd_object_cred *comp)
 {
-	u8 *null_freespace = NULL;
-	size_t sz;
-
-	__xdr_read_calc_deviceaddr(p, NULL, &null_freespace);
-	sz = sizeof(struct pnfs_osd_deviceaddr) + (size_t)null_freespace;
+	p = _osd_xdr_decode_objid(p, &comp->oc_object_id);
+	comp->oc_osd_version = be32_to_cpup(p++);
+	comp->oc_cap_key_sec = be32_to_cpup(p++);
 
-	return sz;
+	p = __read_opaque_cred(p, &comp->oc_cap_key);
+	p = __read_opaque_cred(p, &comp->oc_cap);
+	return p;
 }
 
 void pnfs_osd_xdr_decode_deviceaddr(
 	struct pnfs_osd_deviceaddr *deviceaddr, __be32 *p)
 {
-	u8 *freespace = (u8 *)(deviceaddr + 1);
+	p = __read_targetid(p, &deviceaddr->oda_targetid);
+
+	p = __read_targetaddr(p, &deviceaddr->oda_targetaddr);
+
+	p = xdr_decode_opaque_fixed(p, deviceaddr->oda_lun,
+				    sizeof(deviceaddr->oda_lun));
+
+	p = __read_u8_opaque(p, &deviceaddr->oda_systemid);
 
-	__xdr_read_calc_deviceaddr(p, deviceaddr, &freespace);
+	p = __read_object_cred(p, &deviceaddr->oda_root_obj_cred);
+
+	p = __read_u8_opaque(p, &deviceaddr->oda_osdname);
+
+	/* libosd likes this terminated in dbg. It's last, so no problems */
+	deviceaddr->oda_osdname.data[deviceaddr->oda_osdname.len] = 0;
 }
 
 /*
@@ -357,13 +346,13 @@ void pnfs_osd_xdr_decode_deviceaddr(
  * 	u32	dsu_valid;
  * 	s64	dsu_delta;
  * 	u32	olu_ioerr_flag;
- * };
+ * }; xdr size 4 + 8 + 4
  */
 int
 pnfs_osd_xdr_encode_layoutupdate(struct xdr_stream *xdr,
 				 struct pnfs_osd_layoutupdate *lou)
 {
-	__be32 *p = xdr_reserve_space(xdr, 16);
+	__be32 *p = xdr_reserve_space(xdr,  4 + 8 + 4);
 
 	if (!p)
 		return -E2BIG;
diff --git a/include/linux/pnfs_osd_xdr.h b/include/linux/pnfs_osd_xdr.h
index aed693f..e4c2b25 100644
--- a/include/linux/pnfs_osd_xdr.h
+++ b/include/linux/pnfs_osd_xdr.h
@@ -5,6 +5,7 @@
  *  All rights reserved.
  *
  *  Benny Halevy <bhalevy@panasas.com>
+ *  Boaz Harrosh <bharrosh@panasas.com>
  *
  *  This program is free software; you can redistribute it and/or modify
  *  it under the terms of the GNU General Public License version 2
@@ -46,26 +47,6 @@
 #define PNFS_OSD_OSDNAME_MAXSIZE 256
 
 /*
- * START OF "GENERIC" DECODE ROUTINES.
- *   These may look a little ugly since they are imported from a "generic"
- * set of XDR encode/decode routines which are intended to be shared by
- * all of our NFSv4 implementations (OpenBSD, MacOS X...).
- *
- * If the pain of reading these is too great, it should be a straightforward
- * task to translate them into Linux-specific versions which are more
- * consistent with the style used in NFSv2/v3...
- */
-#define READ32(x)         (x) = ntohl(*p++)
-#define READ64(x)         do {			\
-	(x) = (u64)ntohl(*p++) << 32;		\
-	(x) |= ntohl(*p++);			\
-} while (0)
-#define COPYMEM(x, nbytes) do {			\
-	memcpy((x), p, nbytes);			\
-	p += XDR_QUADLEN(nbytes);		\
-} while (0)
-
-/*
  * draft-ietf-nfsv4-minorversion-22
  * draft-ietf-nfsv4-pnfs-obj-12
  */
@@ -97,18 +78,6 @@ struct pnfs_osd_data_map {
 	u32	odm_raid_algorithm;
 };
 
-static inline int
-pnfs_osd_data_map_xdr_sz(void)
-{
-	return 1 + 2 + 1 + 1 + 1 + 1;
-}
-
-static inline size_t
-pnfs_osd_data_map_incore_sz(void)
-{
-	return sizeof(struct pnfs_osd_data_map);
-}
-
 /*   struct pnfs_osd_objid4 {
  *       deviceid4       oid_device_id;
  *       uint64_t        oid_partition_id;
@@ -121,12 +90,15 @@ struct pnfs_osd_objid {
 	u64			oid_object_id;
 };
 
-/* For printout. I use "dev(%llx:%llx)", _DEVID_LO(), _DEVID_HI BE style */
+/* For printout. I use:
+ * kprint("dev(%llx:%llx)", _DEVID_LO(pointer), _DEVID_HI(pointer));
+ * BE style
+ */
 #define _DEVID_LO(oid_device_id) \
-	(unsigned long long)be64_to_cpup((__be64 *)oid_device_id.data)
+	(unsigned long long)be64_to_cpup((__be64 *)(oid_device_id)->data)
 
 #define _DEVID_HI(oid_device_id) \
-	(unsigned long long)be64_to_cpup(((__be64 *)oid_device_id.data) + 1)
+	(unsigned long long)be64_to_cpup(((__be64 *)(oid_device_id)->data) + 1)
 
 static inline int
 pnfs_osd_objid_xdr_sz(void)
@@ -134,12 +106,6 @@ pnfs_osd_objid_xdr_sz(void)
 	return (NFS4_DEVICEID4_SIZE / 4) + 2 + 2;
 }
 
-static inline size_t
-pnfs_osd_objid_incore_sz(void)
-{
-	return sizeof(struct pnfs_osd_objid);
-}
-
 enum pnfs_osd_version {
 	PNFS_OSD_MISSING              = 0,
 	PNFS_OSD_VERSION_1            = 1,
@@ -148,29 +114,9 @@ enum pnfs_osd_version {
 
 struct pnfs_osd_opaque_cred {
 	u32 cred_len;
-	u8 *cred;
+	void *cred;
 };
 
-static inline int
-pnfs_osd_opaque_cred_xdr_sz(__be32 *p)
-{
-	u32 *start = p;
-	u32 n;
-
-	READ32(n);
-	p += XDR_QUADLEN(n);
-	return p - start;
-}
-
-static inline size_t
-pnfs_osd_opaque_cred_incore_sz(__be32 *p)
-{
-	u32 n;
-
-	READ32(n);
-	return XDR_QUADLEN(n) * 4;
-}
-
 enum pnfs_osd_cap_key_sec {
 	PNFS_OSD_CAP_KEY_SEC_NONE     = 0,
 	PNFS_OSD_CAP_KEY_SEC_SSV      = 1,
@@ -192,29 +138,6 @@ struct pnfs_osd_object_cred {
 	struct pnfs_osd_opaque_cred	oc_cap;
 };
 
-static inline int
-pnfs_osd_object_cred_xdr_sz(__be32 *p)
-{
-	__be32 *start = p;
-
-	p += pnfs_osd_objid_xdr_sz() + 2;
-	p += pnfs_osd_opaque_cred_xdr_sz(p);
-	p += pnfs_osd_opaque_cred_xdr_sz(p);
-	return p - start;
-}
-
-static inline size_t
-pnfs_osd_object_cred_incore_sz(__be32 *p)
-{
-	size_t sz = sizeof(struct pnfs_osd_object_cred);
-
-	p += pnfs_osd_objid_xdr_sz() + 2;
-	sz += pnfs_osd_opaque_cred_incore_sz(p);
-	p += pnfs_osd_opaque_cred_xdr_sz(p);
-	sz += pnfs_osd_opaque_cred_incore_sz(p);
-	return sz;
-}
-
 /*   struct pnfs_osd_layout4 {
  *       pnfs_osd_data_map4      olo_map;
  *       uint32_t                olo_comps_index;
@@ -228,37 +151,7 @@ struct pnfs_osd_layout {
 	struct pnfs_osd_object_cred	*olo_comps;
 };
 
-static inline int
-pnfs_osd_layout_xdr_sz(__be32 *p)
-{
-	__be32 *start = p;
-	u32 n;
-
-	p += pnfs_osd_data_map_xdr_sz() + 1;
-	READ32(n);
-	while ((int)(n--) > 0)
-		p += pnfs_osd_object_cred_xdr_sz(p);
-	return p - start;
-}
-
-static inline size_t
-pnfs_osd_layout_incore_sz(__be32 *p)
-{
-	u32 n;
-	size_t sz;
-
-	p += pnfs_osd_data_map_xdr_sz() + 1;
-	READ32(n);
-	sz = sizeof(struct pnfs_osd_layout);
-	while ((int)(n--) > 0) {
-		sz += pnfs_osd_object_cred_incore_sz(p);
-		p += pnfs_osd_object_cred_xdr_sz(p);
-	}
-	return sz;
-}
-
 /* Device Address */
-
 enum pnfs_osd_targetid_type {
 	OBJ_TARGET_ANON = 1,
 	OBJ_TARGET_SCSI_NAME = 2,
@@ -387,32 +280,68 @@ struct pnfs_osd_ioerr {
 	u32			oer_errno;
 };
 
+/* FIXME: remove */
 static inline unsigned
 pnfs_osd_ioerr_xdr_sz(void)
 {
 	return pnfs_osd_objid_xdr_sz() + 2 + 2 + 1 + 1;
 }
 
-/* OSD XDR API */
 
+/* OSD XDR API */
 /* Layout helpers */
-extern struct pnfs_osd_layout *pnfs_osd_xdr_decode_layout(
-	struct pnfs_osd_layout *layout, __be32 *p);
+/* Layout decoding is done in two parts:
+ * 1. First Call pnfs_osd_xdr_decode_layout_map to read in only the header part
+ *    of the layout. @iter members need not be initialized.
+ *    Returned:
+ *             @layout members are set. (@layout->olo_comps set to NULL).
+ *
+ *             Zero on success, or negative error if passed xdr is broken.
+ *
+ * 2. 2nd Call pnfs_osd_xdr_decode_layout_comp() in a loop until it returns
+ *    false, to decode the next component.
+ *    Returned:
+ *       true if there is more to decode or false if we are done or error.
+ *
+ * Example:
+ *	struct pnfs_osd_xdr_decode_layout_iter iter;
+ *	struct pnfs_osd_layout layout;
+ *	struct pnfs_osd_object_cred comp;
+ *	int status;
+ *
+ *	status = pnfs_osd_xdr_decode_layout_map(&layout, &iter, xdr);
+ *	if (unlikely(status))
+ *		goto err;
+ *	while(pnfs_osd_xdr_decode_layout_comp(&comp, &iter, xdr, &status)) {
+ *		// All of @comp strings point to inside the xdr_buffer
+ *		// or scrach buffer. Copy them out to user memory eg.
+ *		copy_single_comp(dest_comp++, &comp);
+ *	}
+ *	if (unlikely(status))
+ *		goto err;
+ */
+
+struct pnfs_osd_xdr_decode_layout_iter {
+	unsigned total_comps;
+	unsigned decoded_comps;
+};
 
+extern int pnfs_osd_xdr_decode_layout_map(struct pnfs_osd_layout *layout,
+	struct pnfs_osd_xdr_decode_layout_iter *iter, struct xdr_stream *xdr);
+
+extern bool pnfs_osd_xdr_decode_layout_comp(struct pnfs_osd_object_cred *comp,
+	struct pnfs_osd_xdr_decode_layout_iter *iter, struct xdr_stream *xdr,
+	int *err);
+
+/* Layout encoding */
 extern int pnfs_osd_xdr_encode_layout(
 	struct exp_xdr_stream *xdr,
 	struct pnfs_osd_layout *layout);
 
 /* Device Info helpers */
 
-/* First pass calculate total size for space needed */
-extern size_t pnfs_osd_xdr_deviceaddr_incore_sz(__be32 *p);
-
-/* Note: some strings pointed to inside @deviceaddr might point
- * to space inside @p. @p should stay valid while @deviceaddr
- * is in use.
- * It is assumed that @deviceaddr points to bigger memory of size
- * calculated in first pass by pnfs_osd_xdr_deviceaddr_incore_sz()
+/* Note: All strings inside @deviceaddr point to space inside @p.
+ * @p should stay valid while @deviceaddr is in use.
  */
 extern void pnfs_osd_xdr_decode_deviceaddr(
 	struct pnfs_osd_deviceaddr *deviceaddr, __be32 *p);
-- 
1.7.2.3


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:34671 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751200Ab1EPQWg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2011 12:22:36 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, bharrosh@panasas.com
Subject: [PATCH v3 14/29] pnfs-obj: objio_osd device information retrieval and caching
Date: Mon, 16 May 2011 09:22:32 -0700
Message-Id: <1305562952-7810-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DD14D8E.1070701@panasas.com>
References: <4DD14D8E.1070701@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Boaz Harrosh <bharrosh@panasas.com>

When a new layout is received in objio_alloc_lseg all device_ids
referenced are retrieved. The device information is queried for from MDS
and then the osd_device is looked-up from the osd-initiator library. The
devices are cached in a per-mount-point list, for later use. At unmount
all devices are "put" back to the library.

objlayout_get_deviceinfo(), objlayout_put_deviceinfo() middleware
API for retrieving device information given a device_id.

TODO: The device cache can get big. Cap its size. Keep an LRU and start
      to return devices which were not used, when list gets to big, or
      when new entries allocation fail.

[Some extra debug-prints]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[convert APIs pnfs-post-submit]
[apply types rename]
[convert to new pnfs-submit changes]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c        |  166 ++++++++++++++++++++++++++++++-
 fs/nfs/objlayout/objlayout.c        |   67 +++++++++++++
 fs/nfs/objlayout/objlayout.h        |    4 +
 fs/nfs/objlayout/pnfs_osd_xdr_cli.c |  188 +++++++++++++++++++++++++++++++++++
 4 files changed, 424 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index c5f69c6..026e600 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -38,28 +38,192 @@
  */
 
 #include <linux/module.h>
+#include <scsi/osd_initiator.h>
 
 #include "objlayout.h"
 
+#define NFSDBG_FACILITY         NFSDBG_PNFS_LD
+
+/* A per mountpoint struct currently for device cache */
+struct objio_mount_type {
+	struct list_head dev_list;
+	spinlock_t dev_list_lock;
+};
+
+struct _dev_ent {
+	struct list_head list;
+	struct nfs4_deviceid d_id;
+	struct osd_dev *od;
+};
+
+static struct osd_dev *___dev_list_find(struct objio_mount_type *omt,
+	struct nfs4_deviceid *d_id)
+{
+	struct list_head *le;
+
+	list_for_each(le, &omt->dev_list) {
+		struct _dev_ent *de = list_entry(le, struct _dev_ent, list);
+
+		if (0 == memcmp(&de->d_id, d_id, sizeof(*d_id)))
+			return de->od;
+	}
+
+	return NULL;
+}
+
+static struct osd_dev *_dev_list_find(struct objio_mount_type *omt,
+	struct nfs4_deviceid *d_id)
+{
+	struct osd_dev *od;
+
+	spin_lock(&omt->dev_list_lock);
+	od = ___dev_list_find(omt, d_id);
+	spin_unlock(&omt->dev_list_lock);
+	return od;
+}
+
+static int _dev_list_add(struct objio_mount_type *omt,
+	struct nfs4_deviceid *d_id, struct osd_dev *od)
+{
+	struct _dev_ent *de = kzalloc(sizeof(*de), GFP_KERNEL);
+
+	if (!de)
+		return -ENOMEM;
+
+	spin_lock(&omt->dev_list_lock);
+
+	if (___dev_list_find(omt, d_id)) {
+		kfree(de);
+		goto out;
+	}
+
+	de->d_id = *d_id;
+	de->od = od;
+	list_add(&de->list, &omt->dev_list);
+
+out:
+	spin_unlock(&omt->dev_list_lock);
+	return 0;
+}
+
 struct objio_segment {
 	struct pnfs_osd_layout *layout;
+
+	unsigned num_comps;
+	/* variable length */
+	struct osd_dev	*ods[1];
 };
 
+/* Send and wait for a get_device_info of devices in the layout,
+   then look them up with the osd_initiator library */
+static struct osd_dev *_device_lookup(struct pnfs_layout_hdr *pnfslay,
+			       struct objio_segment *objio_seg, unsigned comp)
+{
+	struct pnfs_osd_layout *layout = objio_seg->layout;
+	struct pnfs_osd_deviceaddr *deviceaddr;
+	struct nfs4_deviceid *d_id;
+	struct osd_dev *od;
+	struct osd_dev_info odi;
+	struct objio_mount_type *omt = NFS_SERVER(pnfslay->plh_inode)->pnfs_ld_data;
+	int err;
+
+	d_id = &layout->olo_comps[comp].oc_object_id.oid_device_id;
+
+	od = _dev_list_find(omt, d_id);
+	if (od)
+		return od;
+
+	err = objlayout_get_deviceinfo(pnfslay, d_id, &deviceaddr);
+	if (unlikely(err)) {
+		dprintk("%s: objlayout_get_deviceinfo=>%d\n", __func__, err);
+		return ERR_PTR(err);
+	}
+
+	odi.systemid_len = deviceaddr->oda_systemid.len;
+	if (odi.systemid_len > sizeof(odi.systemid)) {
+		err = -EINVAL;
+		goto out;
+	} else if (odi.systemid_len)
+		memcpy(odi.systemid, deviceaddr->oda_systemid.data,
+		       odi.systemid_len);
+	odi.osdname_len	 = deviceaddr->oda_osdname.len;
+	odi.osdname	 = (u8 *)deviceaddr->oda_osdname.data;
+
+	if (!odi.osdname_len && !odi.systemid_len) {
+		dprintk("%s: !odi.osdname_len && !odi.systemid_len\n",
+			__func__);
+		err = -ENODEV;
+		goto out;
+	}
+
+	od = osduld_info_lookup(&odi);
+	if (unlikely(IS_ERR(od))) {
+		err = PTR_ERR(od);
+		dprintk("%s: osduld_info_lookup => %d\n", __func__, err);
+		goto out;
+	}
+
+	_dev_list_add(omt, d_id, od);
+
+out:
+	dprintk("%s: return=%d\n", __func__, err);
+	objlayout_put_deviceinfo(deviceaddr);
+	return err ? ERR_PTR(err) : od;
+}
+
+static int objio_devices_lookup(struct pnfs_layout_hdr *pnfslay,
+	struct objio_segment *objio_seg)
+{
+	struct pnfs_osd_layout *layout = objio_seg->layout;
+	unsigned i, num_comps = layout->olo_num_comps;
+	int err;
+
+	/* lookup all devices */
+	for (i = 0; i < num_comps; i++) {
+		struct osd_dev *od;
+
+		od = _device_lookup(pnfslay, objio_seg, i);
+		if (unlikely(IS_ERR(od))) {
+			err = PTR_ERR(od);
+			goto out;
+		}
+		objio_seg->ods[i] = od;
+	}
+	objio_seg->num_comps = num_comps;
+	err = 0;
+
+out:
+	dprintk("%s: return=%d\n", __func__, err);
+	return err;
+}
+
 int objio_alloc_lseg(void **outp,
 	struct pnfs_layout_hdr *pnfslay,
 	struct pnfs_layout_segment *lseg,
 	struct pnfs_osd_layout *layout)
 {
 	struct objio_segment *objio_seg;
+	int err;
 
-	objio_seg = kzalloc(sizeof(*objio_seg), GFP_KERNEL);
+	objio_seg = kzalloc(sizeof(*objio_seg) +
+			(layout->olo_num_comps - 1) * sizeof(objio_seg->ods[0]),
+			GFP_KERNEL);
 	if (!objio_seg)
 		return -ENOMEM;
 
 	objio_seg->layout = layout;
+	err = objio_devices_lookup(pnfslay, objio_seg);
+	if (err)
+		goto free_seg;
 
 	*outp = objio_seg;
 	return 0;
+
+free_seg:
+	dprintk("%s: Error: return %d\n", __func__, err);
+	kfree(objio_seg);
+	*outp = NULL;
+	return err;
 }
 
 void objio_free_lseg(void *p)
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 7401dd3..68b2a29 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -119,3 +119,70 @@ objlayout_free_lseg(struct pnfs_layout_segment *lseg)
 	objio_free_lseg(objlseg->internal);
 	kfree(objlseg);
 }
+
+struct objlayout_deviceinfo {
+	struct page *page;
+	struct pnfs_osd_deviceaddr da; /* This must be last */
+};
+
+/* Initialize and call nfs_getdeviceinfo, then decode and return a
+ * "struct pnfs_osd_deviceaddr *" Eventually objlayout_put_deviceinfo()
+ * should be called.
+ */
+int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
+	struct nfs4_deviceid *d_id, struct pnfs_osd_deviceaddr **deviceaddr)
+{
+	struct objlayout_deviceinfo *odi;
+	struct pnfs_device pd;
+	struct super_block *sb;
+	struct page *page, **pages;
+	size_t sz;
+	u32 *p;
+	int err;
+
+	page = alloc_page(GFP_KERNEL);
+	if (!page)
+		return -ENOMEM;
+
+	pages = &page;
+	pd.pages = pages;
+
+	memcpy(&pd.dev_id, d_id, sizeof(*d_id));
+	pd.layout_type = LAYOUT_OSD2_OBJECTS;
+	pd.pages = &page;
+	pd.pgbase = 0;
+	pd.pglen = PAGE_SIZE;
+	pd.mincount = 0;
+
+	sb = pnfslay->plh_inode->i_sb;
+	err = nfs4_proc_getdeviceinfo(NFS_SERVER(pnfslay->plh_inode), &pd);
+	dprintk("%s nfs_getdeviceinfo returned %d\n", __func__, err);
+	if (err)
+		goto err_out;
+
+	p = page_address(page);
+	sz = pnfs_osd_xdr_deviceaddr_incore_sz(p);
+	odi = kzalloc(sz + (sizeof(*odi) - sizeof(odi->da)), GFP_KERNEL);
+	if (!odi) {
+		err = -ENOMEM;
+		goto err_out;
+	}
+	pnfs_osd_xdr_decode_deviceaddr(&odi->da, p);
+	odi->page = page;
+	*deviceaddr = &odi->da;
+	return 0;
+
+err_out:
+	__free_page(page);
+	return err;
+}
+
+void objlayout_put_deviceinfo(struct pnfs_osd_deviceaddr *deviceaddr)
+{
+	struct objlayout_deviceinfo *odi = container_of(deviceaddr,
+						struct objlayout_deviceinfo,
+						da);
+
+	__free_page(odi->page);
+	kfree(odi);
+}
diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
index 8c0fb1c..416a3b9 100644
--- a/fs/nfs/objlayout/objlayout.h
+++ b/fs/nfs/objlayout/objlayout.h
@@ -72,4 +72,8 @@ extern struct pnfs_layout_segment *objlayout_alloc_lseg(
 	struct nfs4_layoutget_res *);
 extern void objlayout_free_lseg(struct pnfs_layout_segment *);
 
+extern int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
+	struct nfs4_deviceid *d_id, struct pnfs_osd_deviceaddr **deviceaddr);
+extern void objlayout_put_deviceinfo(struct pnfs_osd_deviceaddr *deviceaddr);
+
 #endif /* _OBJLAYOUT_H */
diff --git a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
index a2a2e91..cc2de07 100644
--- a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
+++ b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
@@ -163,3 +163,191 @@ pnfs_osd_xdr_decode_layout(struct pnfs_osd_layout *layout, __be32 *p)
 	       (char *)p - (char *)start, cred, (char *)cred - (char *)layout);
 	return layout;
 }
+
+/*
+ * Get Device Information Decoding
+ *
+ * Note: since Device Information is currently done synchronously, most
+ *       of the actual fields are left inside the rpc buffer and are only
+ *       pointed to by the pnfs_osd_deviceaddr members. So the read buffer
+ *       should not be freed while the returned information is in use.
+ */
+
+__be32 *__xdr_read_calc_nfs4_string(
+	__be32 *p, struct nfs4_string *str, u8 **freespace)
+{
+	u32 len;
+	char *data;
+	bool need_copy;
+
+	READ32(len);
+	data = (char *)p;
+
+	if (data[len]) { /* Not null terminated we'll need extra space */
+		data = *freespace;
+		*freespace += len + 1;
+		need_copy = true;
+	} else {
+		need_copy = false;
+	}
+
+	if (str) {
+		str->len = len;
+		str->data = data;
+		if (need_copy) {
+			memcpy(data, p, len);
+			data[len] = 0;
+		}
+	}
+
+	p += XDR_QUADLEN(len);
+	return p;
+}
+
+__be32 *__xdr_read_calc_u8_opaque(
+	__be32 *p, struct nfs4_string *str)
+{
+	u32 len;
+
+	READ32(len);
+
+	if (str) {
+		str->len = len;
+		str->data = (char *)p;
+	}
+
+	p += XDR_QUADLEN(len);
+	return p;
+}
+
+/*
+ * struct pnfs_osd_targetid {
+ * 	u32			oti_type;
+ * 	struct nfs4_string	oti_scsi_device_id;
+ * };
+ */
+__be32 *__xdr_read_calc_targetid(
+	__be32 *p, struct pnfs_osd_targetid* targetid, u8 **freespace)
+{
+	u32 oti_type;
+
+	READ32(oti_type);
+	if (targetid)
+		targetid->oti_type = oti_type;
+
+	switch (oti_type) {
+	case OBJ_TARGET_SCSI_NAME:
+	case OBJ_TARGET_SCSI_DEVICE_ID:
+		p = __xdr_read_calc_u8_opaque(p,
+			targetid ? &targetid->oti_scsi_device_id : NULL);
+	}
+
+	return p;
+}
+
+/*
+ * struct pnfs_osd_net_addr {
+ * 	struct nfs4_string	r_netid;
+ * 	struct nfs4_string	r_addr;
+ * };
+ */
+__be32 *__xdr_read_calc_net_addr(
+	__be32 *p, struct pnfs_osd_net_addr* netaddr, u8 **freespace)
+{
+
+	p = __xdr_read_calc_nfs4_string(p,
+			netaddr ? &netaddr->r_netid : NULL,
+			freespace);
+
+	p = __xdr_read_calc_nfs4_string(p,
+			netaddr ? &netaddr->r_addr : NULL,
+			freespace);
+
+	return p;
+}
+
+/*
+ * struct pnfs_osd_targetaddr {
+ * 	u32				ota_available;
+ * 	struct pnfs_osd_net_addr	ota_netaddr;
+ * };
+ */
+__be32 *__xdr_read_calc_targetaddr(
+	__be32 *p, struct pnfs_osd_targetaddr *targetaddr, u8 **freespace)
+{
+	u32 ota_available;
+
+	READ32(ota_available);
+	if (targetaddr)
+		targetaddr->ota_available = ota_available;
+
+	if (ota_available) {
+		p = __xdr_read_calc_net_addr(p,
+				targetaddr ? &targetaddr->ota_netaddr : NULL,
+				freespace);
+	}
+
+	return p;
+}
+
+/*
+ * struct pnfs_osd_deviceaddr {
+ * 	struct pnfs_osd_targetid	oda_targetid;
+ * 	struct pnfs_osd_targetaddr	oda_targetaddr;
+ * 	u8				oda_lun[8];
+ * 	struct nfs4_string		oda_systemid;
+ * 	struct pnfs_osd_object_cred	oda_root_obj_cred;
+ * 	struct nfs4_string		oda_osdname;
+ * };
+ */
+__be32 *__xdr_read_calc_deviceaddr(
+	__be32 *p, struct pnfs_osd_deviceaddr *deviceaddr, u8 **freespace)
+{
+	p = __xdr_read_calc_targetid(p,
+			deviceaddr ? &deviceaddr->oda_targetid : NULL,
+			freespace);
+
+	p = __xdr_read_calc_targetaddr(p,
+			deviceaddr ? &deviceaddr->oda_targetaddr : NULL,
+			freespace);
+
+	if (deviceaddr)
+		COPYMEM(deviceaddr->oda_lun, sizeof(deviceaddr->oda_lun));
+	else
+		p += XDR_QUADLEN(sizeof(deviceaddr->oda_lun));
+
+	p = __xdr_read_calc_u8_opaque(p,
+			deviceaddr ? &deviceaddr->oda_systemid : NULL);
+
+	if (deviceaddr) {
+		p = pnfs_osd_xdr_decode_object_cred(p,
+				&deviceaddr->oda_root_obj_cred, freespace);
+	} else {
+		*freespace += pnfs_osd_object_cred_incore_sz(p);
+		p += pnfs_osd_object_cred_xdr_sz(p);
+	}
+
+	p = __xdr_read_calc_u8_opaque(p,
+			deviceaddr ? &deviceaddr->oda_osdname : NULL);
+
+	return p;
+}
+
+size_t pnfs_osd_xdr_deviceaddr_incore_sz(__be32 *p)
+{
+	u8 *null_freespace = NULL;
+	size_t sz;
+
+	__xdr_read_calc_deviceaddr(p, NULL, &null_freespace);
+	sz = sizeof(struct pnfs_osd_deviceaddr) + (size_t)null_freespace;
+
+	return sz;
+}
+
+void pnfs_osd_xdr_decode_deviceaddr(
+	struct pnfs_osd_deviceaddr *deviceaddr, __be32 *p)
+{
+	u8 *freespace = (u8 *)(deviceaddr + 1);
+
+	__xdr_read_calc_deviceaddr(p, deviceaddr, &freespace);
+}
-- 
1.7.3.4


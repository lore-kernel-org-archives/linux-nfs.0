Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38862 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752279Ab1EVQvL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 May 2011 12:51:11 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 12/23] pnfs-obj: objio_osd device information retrieval and caching
Date: Sun, 22 May 2011 19:50:51 +0300
Message-Id: <1306083051-10952-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DD93D3E.9010909@panasas.com>
References: <4DD93D3E.9010909@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

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

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |  147 ++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/objlayout/objlayout.c |   67 +++++++++++++++++++
 fs/nfs/objlayout/objlayout.h |    7 ++
 3 files changed, 221 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index e898b72..d34c3a2 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -46,6 +46,68 @@
 
 #define _LLU(x) ((unsigned long long)x)
 
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
 struct caps_buffers {
 	u8 caps_key[OSD_CRYPTO_KEYID_SIZE];
 	u8 creds[OSD_CAP_LEN];
@@ -74,6 +136,88 @@ OBJIO_LSEG(struct pnfs_layout_segment *lseg)
 	return container_of(lseg, struct objio_segment, lseg);
 }
 
+/* Send and wait for a get_device_info of devices in the layout,
+   then look them up with the osd_initiator library */
+static struct osd_dev *_device_lookup(struct pnfs_layout_hdr *pnfslay,
+			       struct objio_segment *objio_seg, unsigned comp)
+{
+	struct pnfs_osd_deviceaddr *deviceaddr;
+	struct nfs4_deviceid *d_id;
+	struct osd_dev *od;
+	struct osd_dev_info odi;
+	struct objio_mount_type *omt =
+				   NFS_SERVER(pnfslay->plh_inode)->pnfs_ld_data;
+	int err;
+
+	d_id = &objio_seg->comps[comp].oc_object_id.oid_device_id;
+
+	od = _dev_list_find(omt, d_id);
+	if (od)
+		return od;
+
+	err = objlayout_get_deviceinfo(pnfslay, d_id, &deviceaddr);
+	if (unlikely(err)) {
+		dprintk("%s: objlayout_get_deviceinfo dev(%llx:%llx) =>%d\n",
+			__func__, _DEVID_LO(d_id), _DEVID_HI(d_id), err);
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
+	unsigned i;
+	int err;
+
+	/* lookup all devices */
+	for (i = 0; i < objio_seg->num_comps; i++) {
+		struct osd_dev *od;
+
+		od = _device_lookup(pnfslay, objio_seg, i);
+		if (unlikely(IS_ERR(od))) {
+			err = PTR_ERR(od);
+			goto out;
+		}
+		objio_seg->ods[i] = od;
+	}
+	err = 0;
+
+out:
+	dprintk("%s: return=%d\n", __func__, err);
+	return err;
+}
+
 static int _verify_data_map(struct pnfs_osd_layout *layout)
 {
 	struct pnfs_osd_data_map *data_map = &layout->olo_map;
@@ -170,6 +314,9 @@ extern int objio_alloc_lseg(struct pnfs_layout_segment **outp,
 
 	objio_seg->num_comps = layout.olo_num_comps;
 	objio_seg->comps_index = layout.olo_comps_index;
+	err = objio_devices_lookup(pnfslay, objio_seg);
+	if (err)
+		goto err;
 
 	objio_seg->mirrors_p1 = layout.olo_map.odm_mirror_cnt + 1;
 	objio_seg->stripe_unit = layout.olo_map.odm_stripe_unit;
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 509eb65..adf9e2f 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -101,3 +101,70 @@ objlayout_free_lseg(struct pnfs_layout_segment *lseg)
 	objio_free_lseg(lseg);
 }
 
+/*
+ * Get Device Info API for io engines
+ */
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
+	odi = kzalloc(sizeof(*odi), GFP_KERNEL);
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
index f6f649f..01c6e8e 100644
--- a/fs/nfs/objlayout/objlayout.h
+++ b/fs/nfs/objlayout/objlayout.h
@@ -54,6 +54,13 @@ extern int objio_alloc_lseg(struct pnfs_layout_segment **outp,
 	struct xdr_stream *xdr);
 extern void objio_free_lseg(struct pnfs_layout_segment *lseg);
 /*
+ * callback API
+ */
+extern int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
+	struct nfs4_deviceid *d_id, struct pnfs_osd_deviceaddr **deviceaddr);
+extern void objlayout_put_deviceinfo(struct pnfs_osd_deviceaddr *deviceaddr);
+
+/*
  * exported generic objects function vectors
  */
 
-- 
1.7.2.3


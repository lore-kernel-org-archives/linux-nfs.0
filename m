Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:57182 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366Ab1DTR2t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 13:28:49 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC 20/27] pnfs-obj: objio_osd device information retrieval and caching
Date: Wed, 20 Apr 2011 20:28:46 +0300
Message-Id: <1303320526-21713-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DAF0DE1.6020609@panasas.com>
References: <4DAF0DE1.6020609@panasas.com>
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

TODO: The device cache can get big. Cap it's size. Keep an LRU and start
      to return devices which were not used, when list gets to big, or
      when new entries allocation fail.

[Some extra debug-prints]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[convert APIs pnfs-post-submit]
[apply types rename]
[convert to new pnfs-submit changes]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |  176 +++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/objlayout/objlayout.c |   67 ++++++++++++++++
 fs/nfs/objlayout/objlayout.h |    4 +
 3 files changed, 246 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 4b88c0a..a24bf82 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -62,8 +62,84 @@ struct objio_mount_type {
 	spinlock_t dev_list_lock;
 };
 
+struct _dev_ent {
+	struct list_head list;
+	struct nfs4_deviceid d_id;
+	struct osd_dev *od;
+};
+
+static void _dev_list_remove_all(struct objio_mount_type *omt)
+{
+	spin_lock(&omt->dev_list_lock);
+
+	while (!list_empty(&omt->dev_list)) {
+		struct _dev_ent *de = list_entry(omt->dev_list.next,
+				 struct _dev_ent, list);
+
+		list_del_init(&de->list);
+		osduld_put_device(de->od);
+		kfree(de);
+	}
+
+	spin_unlock(&omt->dev_list_lock);
+}
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
 
 struct objio_state {
@@ -73,21 +149,116 @@ struct objio_state {
 	struct objio_segment *objio_seg;
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
@@ -171,11 +342,14 @@ void *objio_init_mt(void)
 	if (!omt)
 		return ERR_PTR(-ENOMEM);
 
+	INIT_LIST_HEAD(&omt->dev_list);
+	spin_lock_init(&omt->dev_list_lock);
 	return omt;
 }
 
 void objio_fini_mt(void *mountid)
 {
+	_dev_list_remove_all(mountid);
 	kfree(mountid);
 }
 
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index ae14a24..7c4c744 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -401,6 +401,73 @@ objlayout_write_pagelist(struct nfs_write_data *wdata,
 	return PNFS_ATTEMPTED;
 }
 
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
+
 /*
  * Perform the objio specific init_mt method.
  * Set the layout driver private data pointer for later use.
diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
index 24b36d4..7a63d34 100644
--- a/fs/nfs/objlayout/objlayout.h
+++ b/fs/nfs/objlayout/objlayout.h
@@ -120,6 +120,10 @@ extern void objlayout_read_done(struct objlayout_io_state *state,
 extern void objlayout_write_done(struct objlayout_io_state *state,
 				 ssize_t status, bool sync);
 
+extern int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
+	struct nfs4_deviceid *d_id, struct pnfs_osd_deviceaddr **deviceaddr);
+extern void objlayout_put_deviceinfo(struct pnfs_osd_deviceaddr *deviceaddr);
+
 /*
  * exported generic objects function vectors
  */
-- 
1.7.3.4


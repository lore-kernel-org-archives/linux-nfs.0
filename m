Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:43535 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752795Ab1EVX6z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 May 2011 19:58:55 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v5 23/38] SQUASHME: pnfs-obj: use global device cache
Date: Mon, 23 May 2011 02:58:40 +0300
Message-Id: <1306108720-28762-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DD99F9B.2040406@panasas.com>
References: <4DD99F9B.2040406@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |  102 ++++++++++++++++++++----------------------
 1 files changed, 49 insertions(+), 53 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 752bf7a..bcc8468 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -46,66 +46,55 @@
 
 #define _LLU(x) ((unsigned long long)x)
 
-/* A per mountpoint struct currently for device cache */
-struct objio_mount_type {
-	struct list_head dev_list;
-	spinlock_t dev_list_lock;
-};
-
-struct _dev_ent {
-	struct list_head list;
-	struct nfs4_deviceid d_id;
+struct objio_dev_ent {
+	struct nfs4_deviceid_node id_node;
 	struct osd_dev *od;
 };
 
-static struct osd_dev *___dev_list_find(struct objio_mount_type *omt,
-	struct nfs4_deviceid *d_id)
+static void
+objio_free_deviceid_node(struct nfs4_deviceid_node *d)
 {
-	struct list_head *le;
+	struct objio_dev_ent *de = container_of(d, struct objio_dev_ent, id_node);
 
-	list_for_each(le, &omt->dev_list) {
-		struct _dev_ent *de = list_entry(le, struct _dev_ent, list);
-
-		if (0 == memcmp(&de->d_id, d_id, sizeof(*d_id)))
-			return de->od;
-	}
-
-	return NULL;
+	osduld_put_device(de->od);
+	kfree(de);
 }
 
-static struct osd_dev *_dev_list_find(struct objio_mount_type *omt,
-	struct nfs4_deviceid *d_id)
+static struct objio_dev_ent *_dev_list_find(const struct nfs_client *clp,
+	const struct nfs4_deviceid *d_id)
 {
-	struct osd_dev *od;
+	struct nfs4_deviceid_node *d;
 
-	spin_lock(&omt->dev_list_lock);
-	od = ___dev_list_find(omt, d_id);
-	spin_unlock(&omt->dev_list_lock);
-	return od;
+	d = nfs4_find_get_deviceid(clp, d_id);
+	if (!d)
+		return NULL;
+	return container_of(d, struct objio_dev_ent, id_node);
 }
 
-static int _dev_list_add(struct objio_mount_type *omt,
-	struct nfs4_deviceid *d_id, struct osd_dev *od,
+static int _dev_list_add(const struct nfs_server *nfss,
+	const struct nfs4_deviceid *d_id, struct osd_dev *od,
 	gfp_t gfp_flags)
 {
-	struct _dev_ent *de = kzalloc(sizeof(*de), gfp_flags);
+	struct nfs4_deviceid_node *d;
+	struct objio_dev_ent *de = kzalloc(sizeof(*de), gfp_flags);
+	struct objio_dev_ent *n;
 
 	if (!de)
 		return -ENOMEM;
 
-	spin_lock(&omt->dev_list_lock);
+	nfs4_init_deviceid_node(&de->id_node,
+				nfss->pnfs_curr_ld,
+				nfss->nfs_client,
+				d_id);
+	de->od = od;
 
-	if (___dev_list_find(omt, d_id)) {
-		kfree(de);
-		goto out;
+	d = nfs4_insert_deviceid_node(&de->id_node);
+	n = container_of(d, struct objio_dev_ent, id_node);
+	if (n != de) {
+		BUG_ON(n->od != od);
+		objio_free_deviceid_node(&de->id_node);
 	}
 
-	de->d_id = *d_id;
-	de->od = od;
-	list_add(&de->list, &omt->dev_list);
-
-out:
-	spin_unlock(&omt->dev_list_lock);
 	return 0;
 }
 
@@ -128,7 +117,7 @@ struct objio_segment {
 	unsigned comps_index;
 	unsigned num_comps;
 	/* variable length */
-	struct osd_dev	*ods[1];
+	struct objio_dev_ent *ods[1];
 };
 
 static inline struct objio_segment *
@@ -139,23 +128,22 @@ OBJIO_LSEG(struct pnfs_layout_segment *lseg)
 
 /* Send and wait for a get_device_info of devices in the layout,
    then look them up with the osd_initiator library */
-static struct osd_dev *_device_lookup(struct pnfs_layout_hdr *pnfslay,
+static struct objio_dev_ent *_device_lookup(struct pnfs_layout_hdr *pnfslay,
 				struct objio_segment *objio_seg, unsigned comp,
 				gfp_t gfp_flags)
 {
 	struct pnfs_osd_deviceaddr *deviceaddr;
 	struct nfs4_deviceid *d_id;
+	struct objio_dev_ent *ode;
 	struct osd_dev *od;
 	struct osd_dev_info odi;
-	struct objio_mount_type *omt =
-				   NFS_SERVER(pnfslay->plh_inode)->pnfs_ld_data;
 	int err;
 
 	d_id = &objio_seg->comps[comp].oc_object_id.oid_device_id;
 
-	od = _dev_list_find(omt, d_id);
-	if (od)
-		return od;
+	ode = _dev_list_find(NFS_SERVER(pnfslay->plh_inode)->nfs_client, d_id);
+	if (ode)
+		return ode;
 
 	err = objlayout_get_deviceinfo(pnfslay, d_id, &deviceaddr, gfp_flags);
 	if (unlikely(err)) {
@@ -188,7 +176,7 @@ static struct osd_dev *_device_lookup(struct pnfs_layout_hdr *pnfslay,
 		goto out;
 	}
 
-	_dev_list_add(omt, d_id, od, gfp_flags);
+	_dev_list_add(NFS_SERVER(pnfslay->plh_inode), d_id, od, gfp_flags);
 
 out:
 	dprintk("%s: return=%d\n", __func__, err);
@@ -205,14 +193,14 @@ static int objio_devices_lookup(struct pnfs_layout_hdr *pnfslay,
 
 	/* lookup all devices */
 	for (i = 0; i < objio_seg->num_comps; i++) {
-		struct osd_dev *od;
+		struct objio_dev_ent *ode;
 
-		od = _device_lookup(pnfslay, objio_seg, i, gfp_flags);
-		if (unlikely(IS_ERR(od))) {
-			err = PTR_ERR(od);
+		ode = _device_lookup(pnfslay, objio_seg, i, gfp_flags);
+		if (unlikely(IS_ERR(ode))) {
+			err = PTR_ERR(ode);
 			goto out;
 		}
-		objio_seg->ods[i] = od;
+		objio_seg->ods[i] = ode;
 	}
 	err = 0;
 
@@ -348,8 +336,14 @@ err:
 
 void objio_free_lseg(struct pnfs_layout_segment *lseg)
 {
+	int i;
 	struct objio_segment *objio_seg = OBJIO_LSEG(lseg);
 
+	for (i = 0; i < objio_seg->num_comps; i++) {
+		if (!objio_seg->ods[i])
+			break;
+		nfs4_put_deviceid_node(&objio_seg->ods[i]->id_node);
+	}
 	kfree(objio_seg);
 }
 
@@ -360,6 +354,8 @@ static struct pnfs_layoutdriver_type objlayout_type = {
 
 	.alloc_lseg              = objlayout_alloc_lseg,
 	.free_lseg               = objlayout_free_lseg,
+
+	.free_deviceid_node	 = objio_free_deviceid_node,
 };
 
 MODULE_DESCRIPTION("pNFS Layout Driver for OSD2 objects");
-- 
1.7.3.4


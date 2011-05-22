Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38888 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752279Ab1EVQwH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 May 2011 12:52:07 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Cc: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 15/23] pnfs-obj: define per-mount and per-inode private structures
Date: Sun, 22 May 2011 19:51:48 +0300
Message-Id: <1306083108-11034-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DD93D3E.9010909@panasas.com>
References: <4DD93D3E.9010909@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

allocate and deallocate per-mount device cache

allocate and deallocate per-inode private
pnfs_layout_hdr.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |   40 ++++++++++++++++++++++++++++
 fs/nfs/objlayout/objlayout.c |   59 ++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/objlayout/objlayout.h |   22 +++++++++++++++
 3 files changed, 121 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index d34c3a2..90038ef 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -58,6 +58,22 @@ struct _dev_ent {
 	struct osd_dev *od;
 };
 
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
 static struct osd_dev *___dev_list_find(struct objio_mount_type *omt,
 	struct nfs4_deviceid *d_id)
 {
@@ -355,10 +371,34 @@ static struct pnfs_layoutdriver_type objlayout_type = {
 	.id = LAYOUT_OSD2_OBJECTS,
 	.name = "LAYOUT_OSD2_OBJECTS",
 
+	.set_layoutdriver        = objlayout_set_layoutdriver,
+	.unset_layoutdriver      = objlayout_unset_layoutdriver,
+
+	.alloc_layout_hdr        = objlayout_alloc_layout_hdr,
+	.free_layout_hdr         = objlayout_free_layout_hdr,
+
 	.alloc_lseg              = objlayout_alloc_lseg,
 	.free_lseg               = objlayout_free_lseg,
 };
 
+void *objio_init_mt(void)
+{
+	struct objio_mount_type *omt = kzalloc(sizeof(*omt), GFP_KERNEL);
+
+	if (!omt)
+		return ERR_PTR(-ENOMEM);
+
+	INIT_LIST_HEAD(&omt->dev_list);
+	spin_lock_init(&omt->dev_list_lock);
+	return omt;
+}
+
+void objio_fini_mt(void *mountid)
+{
+	_dev_list_remove_all(mountid);
+	kfree(mountid);
+}
+
 MODULE_DESCRIPTION("pNFS Layout Driver for OSD2 objects");
 MODULE_AUTHOR("Benny Halevy <bhalevy@panasas.com>");
 MODULE_LICENSE("GPL");
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index adf9e2f..c6b26ff 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -42,6 +42,32 @@
 
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
 /*
+ * Create a objlayout layout structure for the given inode and return it.
+ */
+struct pnfs_layout_hdr *
+objlayout_alloc_layout_hdr(struct inode *inode)
+{
+	struct objlayout *objlay;
+
+	objlay = kzalloc(sizeof(struct objlayout), GFP_KERNEL);
+	dprintk("%s: Return %p\n", __func__, objlay);
+	return &objlay->pnfs_layout;
+}
+
+/*
+ * Free an objlayout layout structure
+ */
+void
+objlayout_free_layout_hdr(struct pnfs_layout_hdr *lo)
+{
+	struct objlayout *objlay = OBJLAYOUT(lo);
+
+	dprintk("%s: objlay %p\n", __func__, objlay);
+
+	kfree(objlay);
+}
+
+/*
  * Unmarshall layout and store it in pnfslay.
  */
 struct pnfs_layout_segment *
@@ -168,3 +194,36 @@ void objlayout_put_deviceinfo(struct pnfs_osd_deviceaddr *deviceaddr)
 	__free_page(odi->page);
 	kfree(odi);
 }
+
+/*
+ * Perform the objio specific init_mt method.
+ * Set the layout driver private data pointer for later use.
+ */
+int
+objlayout_set_layoutdriver(struct nfs_server *server)
+{
+	void *data;
+
+	data = objio_init_mt();
+	if (IS_ERR(data)) {
+		printk(KERN_INFO "%s: objlayout lib not ready err=%ld\n",
+		       __func__, PTR_ERR(data));
+		return PTR_ERR(data);
+	}
+	server->pnfs_ld_data = data;
+
+	dprintk("%s: Return data=%p\n", __func__, data);
+	return 0;
+}
+
+/*
+ * Perform the objio specific fini_mt method to release the
+ * layoutdriver private data.
+ */
+int
+objlayout_unset_layoutdriver(struct nfs_server *server)
+{
+	dprintk("%s: Begin %p\n", __func__, server->pnfs_ld_data);
+	objio_fini_mt(server->pnfs_ld_data);
+	return 0;
+}
diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
index 01c6e8e..ab2d901 100644
--- a/fs/nfs/objlayout/objlayout.h
+++ b/fs/nfs/objlayout/objlayout.h
@@ -46,8 +46,24 @@
 #include "../pnfs.h"
 
 /*
+ * per-inode layout
+ */
+struct objlayout {
+	struct pnfs_layout_hdr pnfs_layout;
+};
+
+static inline struct objlayout *
+OBJLAYOUT(struct pnfs_layout_hdr *lo)
+{
+	return container_of(lo, struct objlayout, pnfs_layout);
+}
+
+/*
  * Raid engine I/O API
  */
+extern void *objio_init_mt(void);
+extern void objio_fini_mt(void *mt);
+
 extern int objio_alloc_lseg(struct pnfs_layout_segment **outp,
 	struct pnfs_layout_hdr *pnfslay,
 	struct pnfs_layout_range *range,
@@ -64,6 +80,12 @@ extern void objlayout_put_deviceinfo(struct pnfs_osd_deviceaddr *deviceaddr);
  * exported generic objects function vectors
  */
 
+extern int objlayout_set_layoutdriver(struct nfs_server *);
+extern int objlayout_unset_layoutdriver(struct nfs_server *);
+
+extern struct pnfs_layout_hdr *objlayout_alloc_layout_hdr(struct inode *);
+extern void objlayout_free_layout_hdr(struct pnfs_layout_hdr *);
+
 extern struct pnfs_layout_segment *objlayout_alloc_lseg(
 	struct pnfs_layout_hdr *,
 	struct nfs4_layoutget_res *);
-- 
1.7.2.3


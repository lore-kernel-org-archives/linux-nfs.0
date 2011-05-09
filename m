Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38007 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753781Ab1EIRJb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 13:09:31 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Boaz Harrosh <bharrosh@panasas.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 16/29] pnfs-obj: objlayout set/unset layout driver methods
Date: Mon,  9 May 2011 20:09:21 +0300
Message-Id: <1304960961-4381-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DC81E8C.6040901@panasas.com>
References: <4DC81E8C.6040901@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

allocate and deallocate per-mount device cache

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |   37 +++++++++++++++++++++++++++++++++++++
 fs/nfs/objlayout/objlayout.c |   33 +++++++++++++++++++++++++++++++++
 fs/nfs/objlayout/objlayout.h |    5 +++++
 3 files changed, 75 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 026e600..9baae80 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -56,6 +56,22 @@ struct _dev_ent {
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
@@ -237,10 +253,31 @@ static struct pnfs_layoutdriver_type objlayout_type = {
 	.id = LAYOUT_OSD2_OBJECTS,
 	.name = "LAYOUT_OSD2_OBJECTS",
 
+	.set_layoutdriver        = objlayout_set_layoutdriver,
+	.unset_layoutdriver      = objlayout_unset_layoutdriver,
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
index 68b2a29..75c158a 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -186,3 +186,36 @@ void objlayout_put_deviceinfo(struct pnfs_osd_deviceaddr *deviceaddr)
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
index 416a3b9..55caa64 100644
--- a/fs/nfs/objlayout/objlayout.h
+++ b/fs/nfs/objlayout/objlayout.h
@@ -57,6 +57,9 @@ struct objlayout_segment {
 /*
  * Raid engine I/O API
  */
+extern void *objio_init_mt(void);
+extern void objio_fini_mt(void *mt);
+
 extern int objio_alloc_lseg(void **outp,
 	struct pnfs_layout_hdr *pnfslay,
 	struct pnfs_layout_segment *lseg,
@@ -66,6 +69,8 @@ extern void objio_free_lseg(void *p);
 /*
  * exported generic objects function vectors
  */
+extern int objlayout_set_layoutdriver(struct nfs_server *);
+extern int objlayout_unset_layoutdriver(struct nfs_server *);
 
 extern struct pnfs_layout_segment *objlayout_alloc_lseg(
 	struct pnfs_layout_hdr *,
-- 
1.7.3.4


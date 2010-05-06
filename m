From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 7/7] SQUASHME: pnfs-obj: convert APIs pnfs-post-submit
Date: Thu,  6 May 2010 22:24:34 +0300
Message-ID: <1273173874-27874-1-git-send-email-bhalevy@panasas.com>
References: <4BE3166F.7060800@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:21195 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755238Ab0EFTYj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 May 2010 15:24:39 -0400
In-Reply-To: <4BE3166F.7060800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c  |    4 ++--
 fs/nfs/objlayout/objlayout.c  |   36 ++++++++++++++++--------------------
 fs/nfs/objlayout/panfs_shim.c |    2 +-
 3 files changed, 19 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index b23f845..642d6fa 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -183,7 +183,7 @@ static struct osd_dev *_device_lookup(struct pnfs_layout_type *pnfslay,
 	struct pnfs_deviceid *d_id;
 	struct osd_dev *od;
 	struct osd_dev_info odi;
-	struct objio_mount_type *omt = PNFS_MOUNTID(pnfslay)->mountid;
+	struct objio_mount_type *omt = PNFS_NFS_SERVER(pnfslay)->pnfs_ld_data;
 	int err;
 
 	d_id = &layout->olo_comps[comp].oc_object_id.oid_device_id;
@@ -1015,7 +1015,7 @@ objlayout_get_stripesize(struct pnfs_layout_type *pnfslay)
  * Get the max [rw]size
  */
 static ssize_t
-objlayout_get_blocksize(struct pnfs_mount_type *mountid)
+objlayout_get_blocksize(void)
 {
 	ssize_t sz = BIO_MAX_PAGES_KMALLOC * PAGE_SIZE;
 
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 3d40fad..880d987 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -56,7 +56,7 @@ struct pnfs_client_operations *pnfs_client_ops;
  * Create a objlayout layout structure for the given inode and return it.
  */
 static void *
-objlayout_alloc_layout(struct pnfs_mount_type *mountid, struct inode *inode)
+objlayout_alloc_layout(struct inode *inode)
 {
 	struct objlayout *objlay;
 
@@ -706,7 +706,7 @@ int objlayout_get_deviceinfo(struct pnfs_layout_type *pnfslay,
 	pd.mincount = 0;
 
 	sb = PNFS_INODE(pnfslay)->i_sb;
-	err = pnfs_client_ops->nfs_getdeviceinfo(sb, &pd);
+	err = pnfs_client_ops->nfs_getdeviceinfo(PNFS_NFS_SERVER(pnfslay), &pd);
 	dprintk("%s nfs_getdeviceinfo returned %d\n", __func__, err);
 	if (err)
 		goto err_out;
@@ -744,36 +744,32 @@ void objlayout_put_deviceinfo(struct pnfs_osd_deviceaddr *deviceaddr)
  * Return the pnfs_mount_type structure so the
  * pNFS_client can refer to the mount point later on.
  */
-static struct pnfs_mount_type *
-objlayout_initialize_mountpoint(struct super_block *sb, struct nfs_fh *fh)
+static int
+objlayout_initialize_mountpoint(struct nfs_server *server,
+				const struct nfs_fh *mntfh)
 {
-	struct pnfs_mount_type *mt;
-
-	mt = kzalloc(sizeof(*mt), GFP_KERNEL);
-	if (!mt)
-		return NULL;
+	void *data;
 
-	mt->mountid = objio_init_mt();
-	if (IS_ERR(mt->mountid)) {
+	data = objio_init_mt();
+	if (IS_ERR(data)) {
 		printk(KERN_INFO "%s: objlayout lib not ready err=%ld\n",
-		       __func__, PTR_ERR(mt->mountid));
-		kfree(mt);
-		return NULL;
+		       __func__, PTR_ERR(data));
+		return PTR_ERR(data);
 	}
+	server->pnfs_ld_data = data;
 
-	dprintk("%s: Return %p\n", __func__, mt);
-	return mt;
+	dprintk("%s: Return data=%p\n", __func__, data);
+	return 0;
 }
 
 /*
  * Uninitialize a mountpoint
  */
 static int
-objlayout_uninitialize_mountpoint(struct pnfs_mount_type *mt)
+objlayout_uninitialize_mountpoint(struct nfs_server *server)
 {
-	dprintk("%s: Begin %p\n", __func__, mt);
-	objio_fini_mt(mt->mountid);
-	kfree(mt);
+	dprintk("%s: Begin %p\n", __func__, server->pnfs_ld_data);
+	objio_fini_mt(server->pnfs_ld_data);
 	return 0;
 }
 
diff --git a/fs/nfs/objlayout/panfs_shim.c b/fs/nfs/objlayout/panfs_shim.c
index 414831e..6033d2b 100644
--- a/fs/nfs/objlayout/panfs_shim.c
+++ b/fs/nfs/objlayout/panfs_shim.c
@@ -654,7 +654,7 @@ panlayout_get_stripesize(struct pnfs_layout_type *pnfslay)
  * Get the max [rw]size
  */
 static ssize_t
-panlayout_get_blocksize(struct pnfs_mount_type *mountid)
+panlayout_get_blocksize(void)
 {
 	ssize_t sz = (PANLAYOUT_MAX_STRIPE_WIDTH-1) *
 		      PANLAYOUT_DEF_STRIPE_UNIT *
-- 
1.6.5.1


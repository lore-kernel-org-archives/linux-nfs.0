From: andros@netapp.com
Subject: [PATCH 3/3] SQUASHME pnfs-submit: file layout driver generic device ID cache
Date: Fri, 16 Apr 2010 11:52:55 -0400
Message-ID: <1271433175-4631-4-git-send-email-andros@netapp.com>
References: <1271433175-4631-1-git-send-email-andros@netapp.com>
 <1271433175-4631-2-git-send-email-andros@netapp.com>
 <1271433175-4631-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs-Xh+NVF5n0LLYtjvyW6yDsg@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22196 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932191Ab0DPPwx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 11:52:53 -0400
In-Reply-To: <1271433175-4631-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Replace the per superblock deviceid cache with the generic deviceid cache.

Embed struct nfs4_deviceid into struct nfs4_file_layout_dsaddr, the file layout
specific deviceid structure.  Provide a free_deviceid_callback.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c            |    1 +
 fs/nfs/nfs4filelayout.c    |   31 +++-----
 fs/nfs/nfs4filelayout.h    |   12 +--
 fs/nfs/nfs4filelayoutdev.c |  190 ++++++++------------------------------------
 4 files changed, 51 insertions(+), 183 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index e1d1646..82775b7 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -38,6 +38,7 @@
 #include <net/ipv6.h>
 #include <linux/nfs_xdr.h>
 #include <linux/sunrpc/bc_xprt.h>
+#include <linux/nfs4_pnfs.h>
 
 #include <asm/system.h>
 
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 0530b59..c155586 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -76,17 +76,11 @@ filelayout_initialize_mountpoint(struct super_block *sb, struct nfs_fh *fh)
 {
 	struct filelayout_mount_type *fl_mt;
 	struct pnfs_mount_type *mt;
-	int status;
 
 	fl_mt = kmalloc(sizeof(struct filelayout_mount_type), GFP_KERNEL);
 	if (!fl_mt)
 		goto error_ret;
 
-	/* Initialize nfs4 file layout specific device list structure */
-	fl_mt->hlist = kmalloc(sizeof(struct nfs4_pnfs_dev_hlist), GFP_KERNEL);
-	if (!fl_mt->hlist)
-		goto cleanup_fl_mt;
-
 	mt = kmalloc(sizeof(struct pnfs_mount_type), GFP_KERNEL);
 	if (!mt)
 		goto cleanup_fl_mt;
@@ -94,11 +88,11 @@ filelayout_initialize_mountpoint(struct super_block *sb, struct nfs_fh *fh)
 	fl_mt->fl_sb = sb;
 	mt->mountid = (void *)fl_mt;
 
-	status = nfs4_pnfs_devlist_init(fl_mt->hlist);
-	if (status)
+	if (nfs4_alloc_init_deviceid_cache(NFS_SB(sb)->nfs_client,
+					   nfs4_fl_free_deviceid_callback))
 		goto cleanup_mt;
 
-	dprintk("%s: device list has been initialized successfully\n",
+	dprintk("%s: deviceid cache has been initialized successfully\n",
 		__func__);
 	return mt;
 
@@ -106,11 +100,10 @@ cleanup_mt: ;
 	kfree(mt);
 
 cleanup_fl_mt: ;
-	kfree(fl_mt->hlist);
 	kfree(fl_mt);
 
 error_ret: ;
-	printk(KERN_WARNING "%s: device list could not be initialized\n",
+	printk(KERN_WARNING "%s: deviceid cache could not be initialized\n",
 		__func__);
 
 	return NULL;
@@ -123,13 +116,14 @@ filelayout_uninitialize_mountpoint(struct pnfs_mount_type *mountid)
 {
 	struct filelayout_mount_type *fl_mt = NULL;
 
+	dprintk("--> %s\n", __func__);
 	if (mountid) {
-		fl_mt = (struct filelayout_mount_type *)mountid->mountid;
+		struct nfs4_deviceid_cache *cache;
 
-		if (fl_mt != NULL) {
-			nfs4_pnfs_devlist_destroy(fl_mt->hlist);
-			kfree(fl_mt);
-		}
+		fl_mt = (struct filelayout_mount_type *)mountid->mountid;
+		cache = NFS_SB(fl_mt->fl_sb)->nfs_client->cl_devid_cache;
+		nfs4_put_deviceid_cache(cache);
+		kfree(fl_mt);
 		kfree(mountid);
 	}
 	return 0;
@@ -381,8 +375,7 @@ filelayout_check_layout(struct pnfs_layout_type *lo,
 	struct nfs_server *nfss = NFS_SERVER(PNFS_INODE(lo));
 
 	dprintk("--> %s\n", __func__);
-	dsaddr = nfs4_pnfs_device_item_find(FILE_MT(PNFS_INODE(lo))->hlist,
-					     &fl->dev_id);
+	dsaddr = nfs4_pnfs_device_item_find(nfss->nfs_client, &fl->dev_id);
 	if (dsaddr == NULL) {
 		dsaddr = get_device_info(PNFS_INODE(lo), &fl->dev_id);
 		if (dsaddr == NULL) {
@@ -618,7 +611,7 @@ filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
 	stripesz = filelayout_get_stripesize(layoutid);
 	dprintk("%s stripesize %Zd\n", __func__, stripesz);
 
-	dsaddr = nfs4_pnfs_device_item_find(FILE_MT(data->inode)->hlist,
+	dsaddr = nfs4_pnfs_device_item_find(NFS_SERVER(data->inode)->nfs_client,
 					     &nfslay->dev_id);
 	if (dsaddr == NULL) {
 		data->pdata.pnfs_error = -EIO;
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 12498a2..2cb05bd 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -43,8 +43,7 @@ struct nfs4_pnfs_ds {
 };
 
 struct nfs4_file_layout_dsaddr {
-	struct hlist_node	hash_node;   /* nfs4_pnfs_dev_hlist dev_list */
-	struct pnfs_deviceid	dev_id;
+	struct nfs4_deviceid	deviceid;
 	u32 			stripe_count;
 	u8			*stripe_indices;
 	u32			ds_num;
@@ -86,15 +85,13 @@ struct nfs4_filelayout {
 
 struct filelayout_mount_type {
 	struct super_block *fl_sb;
-	struct nfs4_pnfs_dev_hlist *hlist;
 };
 
 extern struct pnfs_client_operations *pnfs_callback_ops;
 
+extern void nfs4_fl_free_deviceid_callback(struct rcu_head *);
 extern void print_ds(struct nfs4_pnfs_ds *ds);
 char *deviceid_fmt(const struct pnfs_deviceid *dev_id);
-int  nfs4_pnfs_devlist_init(struct nfs4_pnfs_dev_hlist *hlist);
-void nfs4_pnfs_devlist_destroy(struct nfs4_pnfs_dev_hlist *hlist);
 int nfs4_pnfs_dserver_get(struct pnfs_layout_segment *lseg,
 			  loff_t offset,
 			  size_t count,
@@ -102,9 +99,8 @@ int nfs4_pnfs_dserver_get(struct pnfs_layout_segment *lseg,
 u32 filelayout_dserver_get_index(loff_t offset,
 				 struct nfs4_file_layout_dsaddr *di,
 				 struct nfs4_filelayout_segment *layout);
-struct nfs4_file_layout_dsaddr *
-nfs4_pnfs_device_item_find(struct nfs4_pnfs_dev_hlist *hlist,
-			   struct pnfs_deviceid *dev_id);
+extern struct nfs4_file_layout_dsaddr *
+nfs4_pnfs_device_item_find(struct nfs_client *, struct pnfs_deviceid *dev_id);
 struct nfs4_file_layout_dsaddr *
 get_device_info(struct inode *inode, struct pnfs_deviceid *dev_id);
 
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 813ddbb..411ffcb 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -45,6 +45,7 @@
 
 #include <linux/utsname.h>
 #include <linux/vmalloc.h>
+#include <linux/nfs4_pnfs.h>
 #include <linux/pnfs_xdr.h>
 #include "nfs4filelayout.h"
 #include "internal.h"
@@ -98,42 +99,6 @@ deviceid_fmt(const struct pnfs_deviceid *dev_id)
 	return buf;
 }
 
-unsigned long
-_deviceid_hash(const struct pnfs_deviceid *dev_id)
-{
-	unsigned char *cptr = (unsigned char *)dev_id->data;
-	unsigned int nbytes = NFS4_PNFS_DEVICEID4_SIZE;
-	u64 x = 0;
-
-	while (nbytes--) {
-		x *= 37;
-		x += *cptr++;
-	}
-	return x & NFS4_PNFS_DEV_HASH_MASK;
-}
-
-/* Assumes lock is held */
-static inline struct nfs4_file_layout_dsaddr *
-_device_lookup(struct nfs4_pnfs_dev_hlist *hlist,
-	       const struct pnfs_deviceid *dev_id)
-{
-	unsigned long      hash;
-	struct hlist_node *np;
-
-	dprintk("_device_lookup: dev_id=%s\n", deviceid_fmt(dev_id));
-
-	hash = _deviceid_hash(dev_id);
-
-	hlist_for_each(np, &hlist->dev_list[hash]) {
-		struct nfs4_file_layout_dsaddr *dsaddr;
-		dsaddr = hlist_entry(np, struct nfs4_file_layout_dsaddr,
-				  hash_node);
-		if (!memcmp(&dsaddr->dev_id, dev_id, NFS4_PNFS_DEVICEID4_SIZE))
-			return dsaddr;
-	}
-	return NULL;
-}
-
 /* nfs4_ds_cache_lock is held */
 static inline struct nfs4_pnfs_ds *
 _data_server_lookup(u32 ip_addr, u32 port)
@@ -152,22 +117,6 @@ _data_server_lookup(u32 ip_addr, u32 port)
 	return NULL;
 }
 
-
-/* Assumes lock is held */
-static inline void
-_device_add(struct nfs4_pnfs_dev_hlist *hlist,
-	    struct nfs4_file_layout_dsaddr *dsaddr)
-{
-	unsigned long      hash;
-
-	dprintk("_device_add: dev_id=%s ds_list:\n",
-		deviceid_fmt(&dsaddr->dev_id));
-	print_ds_list(dsaddr);
-
-	hash = _deviceid_hash(&dsaddr->dev_id);
-	hlist_add_head(&dsaddr->hash_node, &hlist->dev_list[hash]);
-}
-
 /* Create an rpc to the data server defined in 'dev_list' */
 static int
 nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
@@ -269,118 +218,47 @@ out_put:
 static void
 destroy_ds(struct nfs4_pnfs_ds *ds)
 {
+	dprintk("--> %s\n", __func__);
+	print_ds(ds);
+
 	if (ds->ds_clp)
 		nfs_put_client(ds->ds_clp);
 	kfree(ds);
 }
 
-/* Assumes lock is NOT held */
 static void
-nfs4_pnfs_device_destroy(struct nfs4_file_layout_dsaddr *dsaddr,
-			 struct nfs4_pnfs_dev_hlist *hlist)
+nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
 {
 	struct nfs4_pnfs_ds *ds;
-	LIST_HEAD(release);
 	int i;
 
-	if (!dsaddr)
-		return;
-
-	dprintk("%s: dev_id=%s\ndev_list:\n", __func__,
-		deviceid_fmt(&dsaddr->dev_id));
-	print_ds_list(dsaddr);
-
-	write_lock(&hlist->dev_lock);
-	hlist_del_init(&dsaddr->hash_node);
+	dprintk("%s: device id=%s\n", __func__,
+		deviceid_fmt(&dsaddr->deviceid.de_id));
 
 	for (i = 0; i < dsaddr->ds_num; i++) {
 		ds = dsaddr->ds_list[i];
 		if (ds != NULL) {
-			/* if we are last user - move to release list */
 			if (atomic_dec_and_lock(&ds->ds_count,
 						&nfs4_ds_cache_lock)) {
 				list_del_init(&ds->ds_node);
 				spin_unlock(&nfs4_ds_cache_lock);
-				list_add(&ds->ds_node, &release);
+				destroy_ds(ds);
 			}
 		}
 	}
-	write_unlock(&hlist->dev_lock);
-	while (!list_empty(&release)) {
-		ds = list_entry(release.next, struct nfs4_pnfs_ds, ds_node);
-		list_del(&ds->ds_node);
-		destroy_ds(ds);
-	}
+	kfree(dsaddr->stripe_indices);
 	kfree(dsaddr);
 }
 
-int
-nfs4_pnfs_devlist_init(struct nfs4_pnfs_dev_hlist *hlist)
-{
-	int i;
-
-	rwlock_init(&hlist->dev_lock);
-
-	for (i = 0; i < NFS4_PNFS_DEV_HASH_SIZE; i++) {
-		INIT_HLIST_HEAD(&hlist->dev_list[i]);
-	}
-
-	return 0;
-}
-
-/* De-alloc all devices for a mount point.  This is called in
- * nfs4_kill_super.
- */
 void
-nfs4_pnfs_devlist_destroy(struct nfs4_pnfs_dev_hlist *hlist)
-{
-	int i;
-
-	if (hlist == NULL)
-		return;
-
-	/* No lock held, as synchronization should occur at upper levels */
-	for (i = 0; i < NFS4_PNFS_DEV_HASH_SIZE; i++) {
-		struct hlist_node *np, *next;
-
-		hlist_for_each_safe(np, next, &hlist->dev_list[i]) {
-			struct nfs4_file_layout_dsaddr *dsaddr;
-			dsaddr = hlist_entry(np,
-					     struct nfs4_file_layout_dsaddr,
-					     hash_node);
-			/* nfs4_pnfs_device_destroy grabs hlist->dev_lock */
-			nfs4_pnfs_device_destroy(dsaddr, hlist);
-		}
-	}
-}
-
-/*
- * Add the device to the list of available devices for this mount point.
- * The * rpc client is created during first I/O.
- */
-static int
-nfs4_pnfs_device_add(struct filelayout_mount_type *mt,
-		     struct nfs4_file_layout_dsaddr *dsaddr)
+nfs4_fl_free_deviceid_callback(struct rcu_head *rcu)
 {
-	struct nfs4_file_layout_dsaddr *tmp_dsaddr;
-	struct nfs4_pnfs_dev_hlist *hlist = mt->hlist;
-
-	dprintk("nfs4_pnfs_device_add\n");
-
-	/* Write lock, do lookup again, and then add device */
-	write_lock(&hlist->dev_lock);
-	tmp_dsaddr = _device_lookup(hlist, &dsaddr->dev_id);
-	if (tmp_dsaddr == NULL)
-		_device_add(hlist, dsaddr);
-	write_unlock(&hlist->dev_lock);
-
-	/* Cleanup, if device was recently added */
-	if (tmp_dsaddr != NULL) {
-		dprintk(" device found, not adding (after creation)\n");
-		nfs4_pnfs_device_destroy(dsaddr, hlist);
-	}
+	struct nfs4_deviceid *device =
+		container_of(rcu, struct nfs4_deviceid, de_rcu);
+	struct nfs4_file_layout_dsaddr *dsaddr =
+		container_of(device, struct nfs4_file_layout_dsaddr, deviceid);
 
-	return 0;
+	nfs4_fl_free_deviceid(dsaddr);
 }
 
 static void
@@ -514,7 +392,8 @@ decode_device(struct inode *ino, struct pnfs_device *pdev)
 	dsaddr->stripe_count = cnt;
 	dsaddr->ds_num = num;
 
-	memcpy(&dsaddr->dev_id, &pdev->dev_id, NFS4_PNFS_DEVICEID4_SIZE);
+	memcpy(&dsaddr->deviceid.de_id, &pdev->dev_id,
+	       NFS4_PNFS_DEVICEID4_SIZE);
 
 	/* Go back an read stripe indices */
 	p = indicesp;
@@ -553,19 +432,20 @@ decode_device(struct inode *ino, struct pnfs_device *pdev)
 			}
 		}
 	}
+	nfs4_init_deviceid_node(&dsaddr->deviceid);
+
 	return dsaddr;
 
 out_err_free:
-	nfs4_pnfs_device_destroy(dsaddr, FILE_MT(ino)->hlist);
+	nfs4_fl_free_deviceid(dsaddr);
 out_err:
 	dprintk("%s ERROR: returning NULL\n", __func__);
 	return NULL;
 }
 
-/* Decode the opaque device specified in 'dev'
- * and add it to the list of available devices for this
- * mount point.
- * Must at some point be followed up with nfs4_pnfs_device_destroy
+/*
+ * Decode the opaque device specified in 'dev'
+ * and add it to the list of available devices
  */
 static struct nfs4_file_layout_dsaddr*
 decode_and_add_device(struct inode *inode, struct pnfs_device *dev)
@@ -574,14 +454,13 @@ decode_and_add_device(struct inode *inode, struct pnfs_device *dev)
 
 	dsaddr = decode_device(inode, dev);
 	if (!dsaddr) {
-		printk(KERN_WARNING "%s: Could not decode device\n",
+		printk(KERN_WARNING "%s: Could not decode or add device\n",
 			__func__);
-		nfs4_pnfs_device_destroy(dsaddr, FILE_MT(inode)->hlist);
 		return NULL;
 	}
 
-	if (nfs4_pnfs_device_add(FILE_MT(inode), dsaddr))
-		return NULL;
+	nfs4_add_deviceid(NFS_SERVER(inode)->nfs_client->cl_devid_cache,
+			 &dsaddr->deviceid);
 
 	return dsaddr;
 }
@@ -660,16 +539,15 @@ out_free:
 }
 
 struct nfs4_file_layout_dsaddr *
-nfs4_pnfs_device_item_find(struct nfs4_pnfs_dev_hlist *hlist,
-			   struct pnfs_deviceid *dev_id)
+nfs4_pnfs_device_item_find(struct nfs_client *clp, struct pnfs_deviceid *id)
 {
-	struct nfs4_file_layout_dsaddr *dsaddr;
-
-	read_lock(&hlist->dev_lock);
-	dsaddr = _device_lookup(hlist, dev_id);
-	read_unlock(&hlist->dev_lock);
+	struct nfs4_deviceid *d;
 
-	return dsaddr;
+	d = nfs4_find_deviceid(clp->cl_devid_cache, id);
+	dprintk("%s device id (%s) nfs4_deviceid %p\n", __func__,
+		deviceid_fmt(id), d);
+	return (d == NULL) ? NULL :
+		container_of(d, struct nfs4_file_layout_dsaddr, deviceid);
 }
 
 /* Want res = ((offset / layout->stripe_unit) % dsaddr->stripe_count)
@@ -707,7 +585,7 @@ nfs4_pnfs_dserver_get(struct pnfs_layout_segment *lseg,
 	if (!layout)
 		return 1;
 
-	dsaddr = nfs4_pnfs_device_item_find(FILE_MT(inode)->hlist,
+	dsaddr = nfs4_pnfs_device_item_find(NFS_SERVER(inode)->nfs_client,
 					    &layout->dev_id);
 	if (dsaddr == NULL)
 		return 1;
-- 
1.6.6


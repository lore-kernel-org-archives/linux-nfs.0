Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39366 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757129Ab1CAR35 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Mar 2011 12:29:57 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Subject: [PATCH pNFS wave 3 Version 3 16/18] NFSv4.1 move deviceid cache to filelayout driver
Date: Mon, 28 Feb 2011 20:34:21 -0500
Message-Id: <1298943263-2886-17-git-send-email-andros@netapp.com>
In-Reply-To: <1298943263-2886-16-git-send-email-andros@netapp.com>
References: <1298943263-2886-1-git-send-email-andros@netapp.com>
 <1298943263-2886-2-git-send-email-andros@netapp.com>
 <1298943263-2886-3-git-send-email-andros@netapp.com>
 <1298943263-2886-4-git-send-email-andros@netapp.com>
 <1298943263-2886-5-git-send-email-andros@netapp.com>
 <1298943263-2886-6-git-send-email-andros@netapp.com>
 <1298943263-2886-7-git-send-email-andros@netapp.com>
 <1298943263-2886-8-git-send-email-andros@netapp.com>
 <1298943263-2886-9-git-send-email-andros@netapp.com>
 <1298943263-2886-10-git-send-email-andros@netapp.com>
 <1298943263-2886-11-git-send-email-andros@netapp.com>
 <1298943263-2886-12-git-send-email-andros@netapp.com>
 <1298943263-2886-13-git-send-email-andros@netapp.com>
 <1298943263-2886-14-git-send-email-andros@netapp.com>
 <1298943263-2886-15-git-send-email-andros@netapp.com>
 <1298943263-2886-16-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Christoph Hellwig <hch@infradead.org>

No need for generic cache with only one user.
Keep a simple hash of deviceids in the filelayout driver.

Signed-off-by: Christoph Hellwig <hch@infradead.org>
Acked-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c    |   46 +++-----------
 fs/nfs/nfs4filelayout.h    |    8 ++-
 fs/nfs/nfs4filelayoutdev.c |  106 +++++++++++++++++++++++---------
 fs/nfs/pnfs.c              |  147 +-------------------------------------------
 fs/nfs/pnfs.h              |   48 --------------
 include/linux/nfs_fs_sb.h  |    1 -
 6 files changed, 92 insertions(+), 264 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 19aa3b0..abb1481 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -42,32 +42,6 @@ MODULE_DESCRIPTION("The NFSv4 file layout driver");
 
 #define FILELAYOUT_POLL_RETRY_MAX     (15*HZ)
 
-static int
-filelayout_set_layoutdriver(struct nfs_server *nfss)
-{
-	int status = pnfs_alloc_init_deviceid_cache(nfss->nfs_client,
-						nfs4_fl_free_deviceid_callback);
-	if (status) {
-		printk(KERN_WARNING "%s: deviceid cache could not be "
-			"initialized\n", __func__);
-		return status;
-	}
-	dprintk("%s: deviceid cache has been initialized successfully\n",
-		__func__);
-	return 0;
-}
-
-/* Clear out the layout by destroying its device list */
-static int
-filelayout_clear_layoutdriver(struct nfs_server *nfss)
-{
-	dprintk("--> %s\n", __func__);
-
-	if (nfss->nfs_client->cl_devid_cache)
-		pnfs_put_deviceid_cache(nfss->nfs_client);
-	return 0;
-}
-
 static loff_t
 filelayout_get_dense_offset(struct nfs4_filelayout_segment *flseg,
 			    loff_t offset)
@@ -295,7 +269,7 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
 	}
 
 	/* find and reference the deviceid */
-	dsaddr = nfs4_fl_find_get_deviceid(nfss->nfs_client, id);
+	dsaddr = nfs4_fl_find_get_deviceid(id);
 	if (dsaddr == NULL) {
 		dsaddr = get_device_info(lo->plh_inode, id);
 		if (dsaddr == NULL)
@@ -330,7 +304,7 @@ out:
 	dprintk("--> %s returns %d\n", __func__, status);
 	return status;
 out_put:
-	pnfs_put_deviceid(nfss->nfs_client->cl_devid_cache, &dsaddr->deviceid);
+	nfs4_fl_put_deviceid(dsaddr);
 	goto out;
 }
 
@@ -439,12 +413,10 @@ filelayout_alloc_lseg(struct pnfs_layout_hdr *layoutid,
 static void
 filelayout_free_lseg(struct pnfs_layout_segment *lseg)
 {
-	struct nfs_server *nfss = NFS_SERVER(lseg->pls_layout->plh_inode);
 	struct nfs4_filelayout_segment *fl = FILELAYOUT_LSEG(lseg);
 
 	dprintk("--> %s\n", __func__);
-	pnfs_put_deviceid(nfss->nfs_client->cl_devid_cache,
-			  &fl->dsaddr->deviceid);
+	nfs4_fl_put_deviceid(fl->dsaddr);
 	_filelayout_free_lseg(fl);
 }
 
@@ -474,13 +446,11 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 }
 
 static struct pnfs_layoutdriver_type filelayout_type = {
-	.id = LAYOUT_NFSV4_1_FILES,
-	.name = "LAYOUT_NFSV4_1_FILES",
-	.owner = THIS_MODULE,
-	.set_layoutdriver = filelayout_set_layoutdriver,
-	.clear_layoutdriver = filelayout_clear_layoutdriver,
-	.alloc_lseg              = filelayout_alloc_lseg,
-	.free_lseg               = filelayout_free_lseg,
+	.id			= LAYOUT_NFSV4_1_FILES,
+	.name			= "LAYOUT_NFSV4_1_FILES",
+	.owner			= THIS_MODULE,
+	.alloc_lseg		= filelayout_alloc_lseg,
+	.free_lseg		= filelayout_free_lseg,
 	.pg_test		= filelayout_pg_test,
 	.read_pagelist		= filelayout_read_pagelist,
 };
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 9fef76e..23f1e1e 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -56,7 +56,9 @@ struct nfs4_pnfs_ds {
 };
 
 struct nfs4_file_layout_dsaddr {
-	struct pnfs_deviceid_node	deviceid;
+	struct hlist_node		node;
+	struct nfs4_deviceid		deviceid;
+	atomic_t			ref;
 	u32				stripe_count;
 	u8				*stripe_indices;
 	u32				ds_num;
@@ -86,7 +88,6 @@ FILELAYOUT_LSEG(struct pnfs_layout_segment *lseg)
 extern struct nfs_fh *
 nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, u32 j);
 
-extern void nfs4_fl_free_deviceid_callback(struct pnfs_deviceid_node *);
 extern void print_ds(struct nfs4_pnfs_ds *ds);
 extern void print_deviceid(struct nfs4_deviceid *dev_id);
 u32 nfs4_fl_calc_j_index(struct pnfs_layout_segment *lseg, loff_t offset);
@@ -94,7 +95,8 @@ u32 nfs4_fl_calc_ds_index(struct pnfs_layout_segment *lseg, u32 j);
 struct nfs4_pnfs_ds *nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg,
 					u32 ds_idx);
 extern struct nfs4_file_layout_dsaddr *
-nfs4_fl_find_get_deviceid(struct nfs_client *, struct nfs4_deviceid *dev_id);
+nfs4_fl_find_get_deviceid(struct nfs4_deviceid *dev_id);
+extern void nfs4_fl_put_deviceid(struct nfs4_file_layout_dsaddr *dsaddr);
 struct nfs4_file_layout_dsaddr *
 get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id);
 
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index e8496f3..ac38c75 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -37,6 +37,30 @@
 #define NFSDBG_FACILITY		NFSDBG_PNFS_LD
 
 /*
+ * Device ID RCU cache. A device ID is unique per client ID and layout type.
+ */
+#define NFS4_FL_DEVICE_ID_HASH_BITS	5
+#define NFS4_FL_DEVICE_ID_HASH_SIZE	(1 << NFS4_FL_DEVICE_ID_HASH_BITS)
+#define NFS4_FL_DEVICE_ID_HASH_MASK	(NFS4_FL_DEVICE_ID_HASH_SIZE - 1)
+
+static inline u32
+nfs4_fl_deviceid_hash(struct nfs4_deviceid *id)
+{
+	unsigned char *cptr = (unsigned char *)id->data;
+	unsigned int nbytes = NFS4_DEVICEID4_SIZE;
+	u32 x = 0;
+
+	while (nbytes--) {
+		x *= 37;
+		x += *cptr++;
+	}
+	return x & NFS4_FL_DEVICE_ID_HASH_MASK;
+}
+
+static struct hlist_head filelayout_deviceid_cache[NFS4_FL_DEVICE_ID_HASH_SIZE];
+static DEFINE_SPINLOCK(filelayout_deviceid_lock);
+
+/*
  * Data server cache
  *
  * Data servers can be mapped to different device ids.
@@ -183,7 +207,7 @@ nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
 	struct nfs4_pnfs_ds *ds;
 	int i;
 
-	print_deviceid(&dsaddr->deviceid.de_id);
+	print_deviceid(&dsaddr->deviceid);
 
 	for (i = 0; i < dsaddr->ds_num; i++) {
 		ds = dsaddr->ds_list[i];
@@ -200,15 +224,6 @@ nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
 	kfree(dsaddr);
 }
 
-void
-nfs4_fl_free_deviceid_callback(struct pnfs_deviceid_node *device)
-{
-	struct nfs4_file_layout_dsaddr *dsaddr =
-		container_of(device, struct nfs4_file_layout_dsaddr, deviceid);
-
-	nfs4_fl_free_deviceid(dsaddr);
-}
-
 static struct nfs4_pnfs_ds *
 nfs4_pnfs_ds_add(struct inode *inode, u32 ip_addr, u32 port)
 {
@@ -357,7 +372,7 @@ decode_device(struct inode *ino, struct pnfs_device *pdev)
 	dsaddr->stripe_count = cnt;
 	dsaddr->ds_num = num;
 
-	memcpy(&dsaddr->deviceid.de_id, &pdev->dev_id, sizeof(pdev->dev_id));
+	memcpy(&dsaddr->deviceid, &pdev->dev_id, sizeof(pdev->dev_id));
 
 	/* Go back an read stripe indices */
 	p = indicesp;
@@ -407,28 +422,37 @@ out_err:
 }
 
 /*
- * Decode the opaque device specified in 'dev'
- * and add it to the list of available devices.
- * If the deviceid is already cached, nfs4_add_deviceid will return
- * a pointer to the cached struct and throw away the new.
+ * Decode the opaque device specified in 'dev' and add it to the cache of
+ * available devices.
  */
-static struct nfs4_file_layout_dsaddr*
+static struct nfs4_file_layout_dsaddr *
 decode_and_add_device(struct inode *inode, struct pnfs_device *dev)
 {
-	struct nfs4_file_layout_dsaddr *dsaddr;
-	struct pnfs_deviceid_node *d;
+	struct nfs4_file_layout_dsaddr *d, *new;
+	long hash;
 
-	dsaddr = decode_device(inode, dev);
-	if (!dsaddr) {
+	new = decode_device(inode, dev);
+	if (!new) {
 		printk(KERN_WARNING "%s: Could not decode or add device\n",
 			__func__);
 		return NULL;
 	}
 
-	d = pnfs_add_deviceid(NFS_SERVER(inode)->nfs_client->cl_devid_cache,
-			      &dsaddr->deviceid);
+	spin_lock(&filelayout_deviceid_lock);
+	d = nfs4_fl_find_get_deviceid(&new->deviceid);
+	if (d) {
+		spin_unlock(&filelayout_deviceid_lock);
+		nfs4_fl_free_deviceid(new);
+		return d;
+	}
+
+	INIT_HLIST_NODE(&new->node);
+	atomic_set(&new->ref, 1);
+	hash = nfs4_fl_deviceid_hash(&new->deviceid);
+	hlist_add_head_rcu(&new->node, &filelayout_deviceid_cache[hash]);
+	spin_unlock(&filelayout_deviceid_lock);
 
-	return container_of(d, struct nfs4_file_layout_dsaddr, deviceid);
+	return new;
 }
 
 /*
@@ -503,14 +527,38 @@ out_free:
 	return dsaddr;
 }
 
-struct nfs4_file_layout_dsaddr *
-nfs4_fl_find_get_deviceid(struct nfs_client *clp, struct nfs4_deviceid *id)
+void
+nfs4_fl_put_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
 {
-	struct pnfs_deviceid_node *d;
+	if (atomic_dec_and_lock(&dsaddr->ref, &filelayout_deviceid_lock)) {
+		hlist_del_rcu(&dsaddr->node);
+		spin_unlock(&filelayout_deviceid_lock);
+
+		synchronize_rcu();
+		nfs4_fl_free_deviceid(dsaddr);
+	}
+}
 
-	d = pnfs_find_get_deviceid(clp->cl_devid_cache, id);
-	return (d == NULL) ? NULL :
-		container_of(d, struct nfs4_file_layout_dsaddr, deviceid);
+struct nfs4_file_layout_dsaddr *
+nfs4_fl_find_get_deviceid(struct nfs4_deviceid *id)
+{
+	struct nfs4_file_layout_dsaddr *d;
+	struct hlist_node *n;
+	long hash = nfs4_fl_deviceid_hash(id);
+
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(d, n, &filelayout_deviceid_cache[hash], node) {
+		if (!memcmp(&d->deviceid, id, sizeof(*id))) {
+			if (!atomic_inc_not_zero(&d->ref))
+				goto fail;
+			rcu_read_unlock();
+			return d;
+		}
+	}
+fail:
+	rcu_read_unlock();
+	return NULL;
 }
 
 /*
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 86c154b..1f4c153 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -75,10 +75,8 @@ find_pnfs_driver(u32 id)
 void
 unset_pnfs_layoutdriver(struct nfs_server *nfss)
 {
-	if (nfss->pnfs_curr_ld) {
-		nfss->pnfs_curr_ld->clear_layoutdriver(nfss);
+	if (nfss->pnfs_curr_ld)
 		module_put(nfss->pnfs_curr_ld->owner);
-	}
 	nfss->pnfs_curr_ld = NULL;
 }
 
@@ -116,13 +114,7 @@ set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
 		goto out_no_driver;
 	}
 	server->pnfs_curr_ld = ld_type;
-	if (ld_type->set_layoutdriver(server)) {
-		printk(KERN_ERR
-		       "%s: Error initializing mount point for layout driver %u.\n",
-		       __func__, id);
-		module_put(ld_type->owner);
-		goto out_no_driver;
-	}
+
 	dprintk("%s: pNFS module for %u set\n", __func__, id);
 	return;
 
@@ -906,138 +898,3 @@ pnfs_try_to_read_data(struct nfs_read_data *rdata,
 	dprintk("%s End (trypnfs:%d)\n", __func__, trypnfs);
 	return trypnfs;
 }
-
-/*
- * Device ID cache. Currently supports one layout type per struct nfs_client.
- * Add layout type to the lookup key to expand to support multiple types.
- */
-int
-pnfs_alloc_init_deviceid_cache(struct nfs_client *clp,
-			 void (*free_callback)(struct pnfs_deviceid_node *))
-{
-	struct pnfs_deviceid_cache *c;
-
-	c = kzalloc(sizeof(struct pnfs_deviceid_cache), GFP_KERNEL);
-	if (!c)
-		return -ENOMEM;
-	spin_lock(&clp->cl_lock);
-	if (clp->cl_devid_cache != NULL) {
-		atomic_inc(&clp->cl_devid_cache->dc_ref);
-		dprintk("%s [kref [%d]]\n", __func__,
-			atomic_read(&clp->cl_devid_cache->dc_ref));
-		kfree(c);
-	} else {
-		/* kzalloc initializes hlists */
-		spin_lock_init(&c->dc_lock);
-		atomic_set(&c->dc_ref, 1);
-		c->dc_free_callback = free_callback;
-		clp->cl_devid_cache = c;
-		dprintk("%s [new]\n", __func__);
-	}
-	spin_unlock(&clp->cl_lock);
-	return 0;
-}
-EXPORT_SYMBOL_GPL(pnfs_alloc_init_deviceid_cache);
-
-/*
- * Called from pnfs_layoutdriver_type->free_lseg
- * last layout segment reference frees deviceid
- */
-void
-pnfs_put_deviceid(struct pnfs_deviceid_cache *c,
-		  struct pnfs_deviceid_node *devid)
-{
-	struct nfs4_deviceid *id = &devid->de_id;
-	struct pnfs_deviceid_node *d;
-	struct hlist_node *n;
-	long h = nfs4_deviceid_hash(id);
-
-	dprintk("%s [%d]\n", __func__, atomic_read(&devid->de_ref));
-	if (!atomic_dec_and_lock(&devid->de_ref, &c->dc_lock))
-		return;
-
-	hlist_for_each_entry_rcu(d, n, &c->dc_deviceids[h], de_node)
-		if (!memcmp(&d->de_id, id, sizeof(*id))) {
-			hlist_del_rcu(&d->de_node);
-			spin_unlock(&c->dc_lock);
-			synchronize_rcu();
-			c->dc_free_callback(devid);
-			return;
-		}
-	spin_unlock(&c->dc_lock);
-	/* Why wasn't it found in  the list? */
-	BUG();
-}
-EXPORT_SYMBOL_GPL(pnfs_put_deviceid);
-
-/* Find and reference a deviceid */
-struct pnfs_deviceid_node *
-pnfs_find_get_deviceid(struct pnfs_deviceid_cache *c, struct nfs4_deviceid *id)
-{
-	struct pnfs_deviceid_node *d;
-	struct hlist_node *n;
-	long hash = nfs4_deviceid_hash(id);
-
-	dprintk("--> %s hash %ld\n", __func__, hash);
-	rcu_read_lock();
-	hlist_for_each_entry_rcu(d, n, &c->dc_deviceids[hash], de_node) {
-		if (!memcmp(&d->de_id, id, sizeof(*id))) {
-			if (!atomic_inc_not_zero(&d->de_ref)) {
-				goto fail;
-			} else {
-				rcu_read_unlock();
-				return d;
-			}
-		}
-	}
-fail:
-	rcu_read_unlock();
-	return NULL;
-}
-EXPORT_SYMBOL_GPL(pnfs_find_get_deviceid);
-
-/*
- * Add a deviceid to the cache.
- * GETDEVICEINFOs for same deviceid can race. If deviceid is found, discard new
- */
-struct pnfs_deviceid_node *
-pnfs_add_deviceid(struct pnfs_deviceid_cache *c, struct pnfs_deviceid_node *new)
-{
-	struct pnfs_deviceid_node *d;
-	long hash = nfs4_deviceid_hash(&new->de_id);
-
-	dprintk("--> %s hash %ld\n", __func__, hash);
-	spin_lock(&c->dc_lock);
-	d = pnfs_find_get_deviceid(c, &new->de_id);
-	if (d) {
-		spin_unlock(&c->dc_lock);
-		dprintk("%s [discard]\n", __func__);
-		c->dc_free_callback(new);
-		return d;
-	}
-	INIT_HLIST_NODE(&new->de_node);
-	atomic_set(&new->de_ref, 1);
-	hlist_add_head_rcu(&new->de_node, &c->dc_deviceids[hash]);
-	spin_unlock(&c->dc_lock);
-	dprintk("%s [new]\n", __func__);
-	return new;
-}
-EXPORT_SYMBOL_GPL(pnfs_add_deviceid);
-
-void
-pnfs_put_deviceid_cache(struct nfs_client *clp)
-{
-	struct pnfs_deviceid_cache *local = clp->cl_devid_cache;
-
-	dprintk("--> %s ({%d})\n", __func__, atomic_read(&local->dc_ref));
-	if (atomic_dec_and_lock(&local->dc_ref, &clp->cl_lock)) {
-		int i;
-		/* Verify cache is empty */
-		for (i = 0; i < NFS4_DEVICE_ID_HASH_SIZE; i++)
-			BUG_ON(!hlist_empty(&local->dc_deviceids[i]));
-		clp->cl_devid_cache = NULL;
-		spin_unlock(&clp->cl_lock);
-		kfree(local);
-	}
-}
-EXPORT_SYMBOL_GPL(pnfs_put_deviceid_cache);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 585023f..acbb778 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -68,8 +68,6 @@ struct pnfs_layoutdriver_type {
 	const u32 id;
 	const char *name;
 	struct module *owner;
-	int (*set_layoutdriver) (struct nfs_server *);
-	int (*clear_layoutdriver) (struct nfs_server *);
 	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_hdr *layoutid, struct nfs4_layoutget_res *lgr);
 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
 
@@ -106,52 +104,6 @@ struct pnfs_device {
 	unsigned int  pglen;
 };
 
-/*
- * Device ID RCU cache. A device ID is unique per client ID and layout type.
- */
-#define NFS4_DEVICE_ID_HASH_BITS	5
-#define NFS4_DEVICE_ID_HASH_SIZE	(1 << NFS4_DEVICE_ID_HASH_BITS)
-#define NFS4_DEVICE_ID_HASH_MASK	(NFS4_DEVICE_ID_HASH_SIZE - 1)
-
-static inline u32
-nfs4_deviceid_hash(struct nfs4_deviceid *id)
-{
-	unsigned char *cptr = (unsigned char *)id->data;
-	unsigned int nbytes = NFS4_DEVICEID4_SIZE;
-	u32 x = 0;
-
-	while (nbytes--) {
-		x *= 37;
-		x += *cptr++;
-	}
-	return x & NFS4_DEVICE_ID_HASH_MASK;
-}
-
-struct pnfs_deviceid_node {
-	struct hlist_node	de_node;
-	struct nfs4_deviceid	de_id;
-	atomic_t		de_ref;
-};
-
-struct pnfs_deviceid_cache {
-	spinlock_t		dc_lock;
-	atomic_t		dc_ref;
-	void			(*dc_free_callback)(struct pnfs_deviceid_node *);
-	struct hlist_head	dc_deviceids[NFS4_DEVICE_ID_HASH_SIZE];
-};
-
-extern int pnfs_alloc_init_deviceid_cache(struct nfs_client *,
-			void (*free_callback)(struct pnfs_deviceid_node *));
-extern void pnfs_put_deviceid_cache(struct nfs_client *);
-extern struct pnfs_deviceid_node *pnfs_find_get_deviceid(
-				struct pnfs_deviceid_cache *,
-				struct nfs4_deviceid *);
-extern struct pnfs_deviceid_node *pnfs_add_deviceid(
-				struct pnfs_deviceid_cache *,
-				struct pnfs_deviceid_node *);
-extern void pnfs_put_deviceid(struct pnfs_deviceid_cache *c,
-			      struct pnfs_deviceid_node *devid);
-
 extern int pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *);
 extern void pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *);
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 2669a9a..7f71698 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -81,7 +81,6 @@ struct nfs_client {
 	u32			cl_exchange_flags;
 	struct nfs4_session	*cl_session; 	/* sharred session */
 	struct list_head	cl_layouts;
-	struct pnfs_deviceid_cache *cl_devid_cache; /* pNFS deviceid cache */
 #endif /* CONFIG_NFS_V4_1 */
 
 #ifdef CONFIG_NFS_FSCACHE
-- 
1.6.6


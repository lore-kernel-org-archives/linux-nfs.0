Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:45567 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754999Ab1BOQCN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2011 11:02:13 -0500
Date: Tue, 15 Feb 2011 11:02:09 -0500
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Christoph Hellwig <hch@infradead.org>, Fred Isaman <iisaman@netapp.com>,
        andros@netapp.com, trond.myklebust@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 08/16] pnfs: wave 3: lseg refcounting
Message-ID: <20110215160209.GA31704@infradead.org>
References: <1297711116-3139-1-git-send-email-andros@netapp.com>
 <1297711116-3139-9-git-send-email-andros@netapp.com>
 <20110215092531.GB29871@infradead.org>
 <AANLkTik+dVSmWgO6LRANo2xTt6iMqQ7ehvgqk-igQFhM@mail.gmail.com>
 <20110215145828.GA18038@infradead.org>
 <4D5A94CD.4030508@panasas.com>
 <20110215150628.GA24358@infradead.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110215150628.GA24358@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

FYI that whole device layout cache thingy looks like a complete fucking
mess to me.

It's nothing but a trivial hash lookup which is only used in the file
layout driver.  But instead of just having a hash allocated in the file
layout driver on module load, and a trivial opencoded lookup for it it's
a massively overcomplicated set of routines.  Please rip this stuff out
before doing further work in this area.

The patch below removes the maze of pointless abstractions and just
keeps a simple hash of deviceids in the filelayout driver.


Index: linux-2.6/fs/nfs/nfs4filelayout.c
===================================================================
--- linux-2.6.orig/fs/nfs/nfs4filelayout.c	2011-02-15 16:10:51.108421283 +0100
+++ linux-2.6/fs/nfs/nfs4filelayout.c	2011-02-15 16:55:22.087422176 +0100
@@ -40,32 +40,6 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Dean Hildebrand <dhildebz@umich.edu>");
 MODULE_DESCRIPTION("The NFSv4 file layout driver");
 
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
 /*
  * filelayout_check_layout()
  *
@@ -99,7 +73,7 @@ filelayout_check_layout(struct pnfs_layo
 	}
 
 	/* find and reference the deviceid */
-	dsaddr = nfs4_fl_find_get_deviceid(nfss->nfs_client, id);
+	dsaddr = nfs4_fl_find_get_deviceid(id);
 	if (dsaddr == NULL) {
 		dsaddr = get_device_info(lo->plh_inode, id);
 		if (dsaddr == NULL)
@@ -134,7 +108,7 @@ out:
 	dprintk("--> %s returns %d\n", __func__, status);
 	return status;
 out_put:
-	pnfs_put_deviceid(nfss->nfs_client->cl_devid_cache, &dsaddr->deviceid);
+	nfs4_fl_put_deviceid(dsaddr);
 	goto out;
 }
 
@@ -243,23 +217,19 @@ filelayout_alloc_lseg(struct pnfs_layout
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
 };
 
 static int __init nfs4filelayout_init(void)
Index: linux-2.6/fs/nfs/nfs4filelayout.h
===================================================================
--- linux-2.6.orig/fs/nfs/nfs4filelayout.h	2011-02-15 16:30:25.270920897 +0100
+++ linux-2.6/fs/nfs/nfs4filelayout.h	2011-02-15 16:47:50.063445740 +0100
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
@@ -83,11 +85,11 @@ FILELAYOUT_LSEG(struct pnfs_layout_segme
 			    generic_hdr);
 }
 
-extern void nfs4_fl_free_deviceid_callback(struct pnfs_deviceid_node *);
 extern void print_ds(struct nfs4_pnfs_ds *ds);
 extern void print_deviceid(struct nfs4_deviceid *dev_id);
 extern struct nfs4_file_layout_dsaddr *
-nfs4_fl_find_get_deviceid(struct nfs_client *, struct nfs4_deviceid *dev_id);
+nfs4_fl_find_get_deviceid(struct nfs4_deviceid *dev_id);
+extern void nfs4_fl_put_deviceid(struct nfs4_file_layout_dsaddr *dsaddr);
 struct nfs4_file_layout_dsaddr *
 get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id);
 
Index: linux-2.6/fs/nfs/nfs4filelayoutdev.c
===================================================================
--- linux-2.6.orig/fs/nfs/nfs4filelayoutdev.c	2011-02-15 16:23:03.480487362 +0100
+++ linux-2.6/fs/nfs/nfs4filelayoutdev.c	2011-02-15 16:55:02.894924739 +0100
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
@@ -122,7 +146,7 @@ nfs4_fl_free_deviceid(struct nfs4_file_l
 	struct nfs4_pnfs_ds *ds;
 	int i;
 
-	print_deviceid(&dsaddr->deviceid.de_id);
+	print_deviceid(&dsaddr->deviceid);
 
 	for (i = 0; i < dsaddr->ds_num; i++) {
 		ds = dsaddr->ds_list[i];
@@ -139,15 +163,6 @@ nfs4_fl_free_deviceid(struct nfs4_file_l
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
@@ -296,7 +311,7 @@ decode_device(struct inode *ino, struct
 	dsaddr->stripe_count = cnt;
 	dsaddr->ds_num = num;
 
-	memcpy(&dsaddr->deviceid.de_id, &pdev->dev_id, sizeof(pdev->dev_id));
+	memcpy(&dsaddr->deviceid, &pdev->dev_id, sizeof(pdev->dev_id));
 
 	/* Go back an read stripe indices */
 	p = indicesp;
@@ -346,28 +361,37 @@ out_err:
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
@@ -442,12 +466,36 @@ out_free:
 	return dsaddr;
 }
 
+void
+nfs4_fl_put_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
+{
+	if (atomic_dec_and_lock(&dsaddr->ref, &filelayout_deviceid_lock)) {
+		hlist_del_rcu(&dsaddr->node);
+		spin_unlock(&filelayout_deviceid_lock);
+
+		synchronize_rcu();
+		nfs4_fl_free_deviceid(dsaddr);
+	}
+}
+
 struct nfs4_file_layout_dsaddr *
-nfs4_fl_find_get_deviceid(struct nfs_client *clp, struct nfs4_deviceid *id)
+nfs4_fl_find_get_deviceid(struct nfs4_deviceid *id)
 {
-	struct pnfs_deviceid_node *d;
+	struct nfs4_file_layout_dsaddr *d;
+	struct hlist_node *n;
+	long hash = nfs4_fl_deviceid_hash(id);
+
 
-	d = pnfs_find_get_deviceid(clp->cl_devid_cache, id);
-	return (d == NULL) ? NULL :
-		container_of(d, struct nfs4_file_layout_dsaddr, deviceid);
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
Index: linux-2.6/fs/nfs/pnfs.c
===================================================================
--- linux-2.6.orig/fs/nfs/pnfs.c	2011-02-15 16:10:33.284421051 +0100
+++ linux-2.6/fs/nfs/pnfs.c	2011-02-15 16:21:47.115422052 +0100
@@ -74,10 +74,8 @@ find_pnfs_driver(u32 id)
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
 
@@ -115,13 +113,7 @@ set_pnfs_layoutdriver(struct nfs_server
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
 
@@ -828,138 +820,3 @@ out_forget_reply:
 	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
 	goto out;
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
Index: linux-2.6/fs/nfs/pnfs.h
===================================================================
--- linux-2.6.orig/fs/nfs/pnfs.h	2011-02-15 16:10:51.088421060 +0100
+++ linux-2.6/fs/nfs/pnfs.h	2011-02-15 16:21:34.995159583 +0100
@@ -61,8 +61,6 @@ struct pnfs_layoutdriver_type {
 	const u32 id;
 	const char *name;
 	struct module *owner;
-	int (*set_layoutdriver) (struct nfs_server *);
-	int (*clear_layoutdriver) (struct nfs_server *);
 	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_hdr *layoutid, struct nfs4_layoutget_res *lgr);
 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
 };
@@ -90,52 +88,6 @@ struct pnfs_device {
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
 
Index: linux-2.6/include/linux/nfs_fs_sb.h
===================================================================
--- linux-2.6.orig/include/linux/nfs_fs_sb.h	2011-02-15 16:16:45.976420895 +0100
+++ linux-2.6/include/linux/nfs_fs_sb.h	2011-02-15 16:16:50.347380534 +0100
@@ -79,7 +79,6 @@ struct nfs_client {
 	u32			cl_exchange_flags;
 	struct nfs4_session	*cl_session; 	/* sharred session */
 	struct list_head	cl_layouts;
-	struct pnfs_deviceid_cache *cl_devid_cache; /* pNFS deviceid cache */
 #endif /* CONFIG_NFS_V4_1 */
 
 #ifdef CONFIG_NFS_FSCACHE

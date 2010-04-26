From: andros@netapp.com
Subject: [PATCH 1/3] SQUASHME pnfs_submit: generic device ID cache
Date: Mon, 26 Apr 2010 12:18:17 -0400
Message-ID: <1272298699-11411-2-git-send-email-andros@netapp.com>
References: <1272298699-11411-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14524 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752918Ab0DZQSR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Apr 2010 12:18:17 -0400
In-Reply-To: <1272298699-11411-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

A shared RCU device ID cache servicing multiple mounts of a single layout type
per meta data server (struct nfs_client).

Device IDs of type deviceid4 are required by all layout types, long lived and
read at each I/O.  They are added to the deviceid cache at first reference by
a layout via GETDEVICEINFO and (currently) are only removed at umount.

Reference count the device ID cache for each mounted file system
in the initialize_mountpoint layoutdriver_io_operation.

Dereference the device id cache on file system in the uninitialize_mountpoint
layoutdriver_io_operation called at umount

Each layoutsegment assigns a pointer and takes a reference to the
nfs4_deviceid structure identified by the layout deviceid.
This is so that there are no deviceid lookups for the normal I/O path.

Even thought required by all layouttypes, the deviceid is not exposed in the
LAYOUTGET4res but is instead hidden in the opaque layouttype4.

Therefore, each layout type alloc_lseg calls nfs4_set_layout_deviceid,
and free_lseg calls nfs4_unset_layout_deviceid.

While the file layout driver will not cache very many deviceid's, the object
and block layout drivers could cache 100's for a large installation.
Use an hlist.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c             |  167 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs4_pnfs.h |   50 +++++++++++++
 include/linux/nfs_fs_sb.h |    1 +
 3 files changed, 218 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 91572aa..bf906cc 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -45,6 +45,7 @@
 #include <linux/nfs4.h>
 #include <linux/pnfs_xdr.h>
 #include <linux/nfs4_pnfs.h>
+#include <linux/rculist.h>
 
 #include "internal.h"
 #include "nfs4_fs.h"
@@ -2296,3 +2297,169 @@ struct pnfs_client_operations pnfs_ops = {
 
 EXPORT_SYMBOL(pnfs_unregister_layoutdriver);
 EXPORT_SYMBOL(pnfs_register_layoutdriver);
+
+
+/* Device ID cache. Supports one layout type per struct nfs_client */
+int
+nfs4_alloc_init_deviceid_cache(struct nfs_client *clp,
+			 void (*free_callback)(struct kref *))
+{
+	struct nfs4_deviceid_cache *c;
+
+	c = kzalloc(sizeof(struct nfs4_deviceid_cache), GFP_KERNEL);
+	if (!c)
+		return -ENOMEM;
+	spin_lock(&clp->cl_lock);
+	if (clp->cl_devid_cache != NULL) {
+		kref_get(&clp->cl_devid_cache->dc_kref);
+		spin_unlock(&clp->cl_lock);
+		dprintk("%s [kref [%d]]\n", __func__,
+			atomic_read(&clp->cl_devid_cache->dc_kref.refcount));
+		kfree(c);
+	} else {
+		int i;
+
+		spin_lock_init(&c->dc_lock);
+		for (i = 0; i < NFS4_DEVICE_ID_HASH_SIZE ; i++)
+			INIT_HLIST_HEAD(&c->dc_deviceids[i]);
+		kref_init(&c->dc_kref);
+		c->dc_free_callback = free_callback;
+		clp->cl_devid_cache = c;
+		spin_unlock(&clp->cl_lock);
+		dprintk("%s [new]\n", __func__);
+	}
+	return 0;
+}
+EXPORT_SYMBOL(nfs4_alloc_init_deviceid_cache);
+
+void
+nfs4_init_deviceid_node(struct nfs4_deviceid *d)
+{
+	INIT_HLIST_NODE(&d->de_node);
+	kref_init(&d->de_kref);
+}
+EXPORT_SYMBOL(nfs4_init_deviceid_node);
+
+/* Called from layoutdriver_io_operations->alloc_lseg */
+void
+nfs4_set_layout_deviceid(struct pnfs_layout_segment *l, struct nfs4_deviceid *d)
+{
+	dprintk("%s [%d]\n", __func__, atomic_read(&d->de_kref.refcount));
+	l->deviceid = d;
+	kref_get(&d->de_kref);
+}
+EXPORT_SYMBOL(nfs4_set_layout_deviceid);
+
+/* Called from layoutdriver_io_operations->free_lseg */
+void
+nfs4_unset_layout_deviceid(struct pnfs_layout_segment *l,
+			   struct nfs4_deviceid *d,
+			   void (*free_callback)(struct kref *))
+{
+	dprintk("%s [%d]\n", __func__, atomic_read(&d->de_kref.refcount));
+	l->deviceid = NULL;
+	kref_put(&d->de_kref, free_callback);
+}
+EXPORT_SYMBOL(nfs4_unset_layout_deviceid);
+
+struct nfs4_deviceid *
+nfs4_find_deviceid(struct nfs4_deviceid_cache *c, struct pnfs_deviceid *id)
+{
+	struct nfs4_deviceid *d;
+	struct hlist_node *n;
+	long hash = nfs4_deviceid_hash(id);
+
+	dprintk("--> %s hash %ld\n", __func__, hash);
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(d, n, &c->dc_deviceids[hash], de_node) {
+		if (!memcmp(&d->de_id, id, NFS4_PNFS_DEVICEID4_SIZE)) {
+			rcu_read_unlock();
+			return d;
+		}
+	}
+	rcu_read_unlock();
+	return NULL;
+}
+EXPORT_SYMBOL(nfs4_find_deviceid);
+
+/*
+ * Add or kref_get a deviceid.
+ * GETDEVICEINFOs for same deviceid can race. If deviceid is found, discard new
+ */
+struct nfs4_deviceid *
+nfs4_add_deviceid(struct nfs4_deviceid_cache *c, struct nfs4_deviceid *new)
+{
+	struct nfs4_deviceid *d;
+	struct hlist_node *n;
+	long hash = nfs4_deviceid_hash(&new->de_id);
+
+	dprintk("--> %s hash %ld\n", __func__, hash);
+	spin_lock(&c->dc_lock);
+	hlist_for_each_entry_rcu(d, n, &c->dc_deviceids[hash], de_node) {
+		if (!memcmp(&d->de_id, &new->de_id, NFS4_PNFS_DEVICEID4_SIZE)) {
+			spin_unlock(&c->dc_lock);
+			dprintk("%s [discard]\n", __func__);
+			c->dc_free_callback(&new->de_kref);
+			return d;
+		}
+	}
+	hlist_add_head_rcu(&new->de_node, &c->dc_deviceids[hash]);
+	spin_unlock(&c->dc_lock);
+	dprintk("%s [new]\n", __func__);
+	return new;
+}
+EXPORT_SYMBOL(nfs4_add_deviceid);
+
+static int
+nfs4_remove_deviceid(struct nfs4_deviceid_cache *c, long hash)
+{
+	struct nfs4_deviceid *d;
+	struct hlist_node *n;
+
+	dprintk("--> %s hash %ld\n", __func__, hash);
+	spin_lock(&c->dc_lock);
+	hlist_for_each_entry_rcu(d, n, &c->dc_deviceids[hash], de_node) {
+		hlist_del_rcu(&d->de_node);
+		spin_unlock(&c->dc_lock);
+		synchronize_rcu();
+		dprintk("%s [%d]\n", __func__,
+			atomic_read(&d->de_kref.refcount));
+		kref_put(&d->de_kref, c->dc_free_callback);
+		return 1;
+	}
+	spin_unlock(&c->dc_lock);
+	return 0;
+}
+
+static void
+nfs4_free_deviceid_cache(struct kref *kref)
+{
+	struct nfs4_deviceid_cache *cache =
+		container_of(kref, struct nfs4_deviceid_cache, dc_kref);
+	int more;
+	long i;
+
+	for (i = 0; i < NFS4_DEVICE_ID_HASH_SIZE; i++) {
+		more = 1;
+		while (more)
+			more = nfs4_remove_deviceid(cache, i);
+	}
+	kfree(cache);
+}
+
+void
+nfs4_put_deviceid_cache(struct nfs_client *clp)
+{
+	struct nfs4_deviceid_cache *tmp = clp->cl_devid_cache;
+	int refcount;
+
+	dprintk("--> %s cl_devid_cache %p\n", __func__, clp->cl_devid_cache);
+	spin_lock(&clp->cl_lock);
+	refcount = atomic_read(&clp->cl_devid_cache->dc_kref.refcount);
+	if (refcount == 1)
+		clp->cl_devid_cache = NULL;
+	spin_unlock(&clp->cl_lock);
+	dprintk("%s [%d]\n", __func__, refcount);
+	kref_put(&tmp->dc_kref, nfs4_free_deviceid_cache);
+}
+EXPORT_SYMBOL(nfs4_put_deviceid_cache);
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 3caac60..3b7aeb7 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -106,6 +106,7 @@ struct pnfs_layout_segment {
 	struct kref kref;
 	bool valid;
 	struct pnfs_layout_type *layout;
+	struct nfs4_deviceid *deviceid;
 	u8 ld_data[];			/* layout driver private data */
 };
 
@@ -275,6 +276,55 @@ struct pnfs_devicelist {
 	struct pnfs_deviceid	dev_id[NFS4_PNFS_GETDEVLIST_MAXNUM];
 };
 
+/*
+ * Device ID RCU cache. A device ID is unique per client ID and layout type.
+ */
+#define NFS4_DEVICE_ID_HASH_BITS	5
+#define NFS4_DEVICE_ID_HASH_SIZE	(1 << NFS4_DEVICE_ID_HASH_BITS)
+#define NFS4_DEVICE_ID_HASH_MASK	(NFS4_DEVICE_ID_HASH_SIZE - 1)
+
+static inline u32
+nfs4_deviceid_hash(struct pnfs_deviceid *id)
+{
+	unsigned char *cptr = (unsigned char *)id->data;
+	unsigned int nbytes = NFS4_PNFS_DEVICEID4_SIZE;
+	u32 x = 0;
+
+	while (nbytes--) {
+		x *= 37;
+		x += *cptr++;
+	}
+	return x & NFS4_DEVICE_ID_HASH_MASK;
+}
+
+struct nfs4_deviceid_cache {
+	spinlock_t		dc_lock;
+	struct kref		dc_kref;
+	void			(*dc_free_callback)(struct kref *);
+	struct hlist_head	dc_deviceids[NFS4_DEVICE_ID_HASH_SIZE];
+};
+
+/* Device ID cache node */
+struct nfs4_deviceid {
+	struct hlist_node	de_node;
+	struct pnfs_deviceid	de_id;
+	struct kref		de_kref;
+};
+
+extern int nfs4_alloc_init_deviceid_cache(struct nfs_client *,
+				void (*free_callback)(struct kref *));
+extern void nfs4_put_deviceid_cache(struct nfs_client *);
+extern void nfs4_init_deviceid_node(struct nfs4_deviceid *);
+extern struct nfs4_deviceid *nfs4_find_deviceid(struct nfs4_deviceid_cache *,
+				struct pnfs_deviceid *);
+extern struct nfs4_deviceid *nfs4_add_deviceid(struct nfs4_deviceid_cache *,
+				struct nfs4_deviceid *);
+extern void nfs4_set_layout_deviceid(struct pnfs_layout_segment *,
+				struct nfs4_deviceid *);
+extern void nfs4_unset_layout_deviceid(struct pnfs_layout_segment *,
+				struct nfs4_deviceid *,
+				void (*free_callback)(struct kref *));
+
 /* pNFS client callback functions.
  * These operations allow the layout driver to access pNFS client
  * specific information or call pNFS client->server operations.
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 8522461..ef2e18e 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -87,6 +87,7 @@ struct nfs_client {
 	u32			cl_exchange_flags;
 	struct nfs4_session	*cl_session; 	/* sharred session */
 	struct list_head	cl_lo_inodes;	/* Inodes having layouts */
+	struct nfs4_deviceid_cache *cl_devid_cache; /* pNFS deviceid cache */
 #endif /* CONFIG_NFS_V4_1 */
 
 #ifdef CONFIG_NFS_FSCACHE
-- 
1.6.6


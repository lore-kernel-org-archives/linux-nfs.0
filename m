Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50613 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753921Ab0HMVcP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:15 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 12/50] pnfs_submit: generic pnfs deviceid cache
Date: Fri, 13 Aug 2010 17:31:24 -0400
Message-Id: <1281735122-1496-13-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-12-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
 <1281735122-1496-12-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c             |  141 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs4_pnfs.h |   44 ++++++++++++++
 include/linux/nfs_fs_sb.h |    1 +
 include/linux/pnfs_xdr.h  |    5 ++
 4 files changed, 191 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4c78277..e17835e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -193,3 +193,144 @@ pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
 
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
+	long i;
+
+	for (i = 0; i < NFS4_DEVICE_ID_HASH_SIZE; i++)
+		while (nfs4_remove_deviceid(cache, i))
+			;
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
index 7240d7e..a3fa1d2 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -12,6 +12,7 @@
 #ifndef LINUX_NFS4_PNFS_H
 #define LINUX_NFS4_PNFS_H
 
+#include <linux/pnfs_xdr.h>
 
 /* Per-layout driver specific registration structure */
 struct pnfs_layoutdriver_type {
@@ -34,6 +35,49 @@ struct layoutdriver_io_operations {
 struct layoutdriver_policy_operations {
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
 /* pNFS client callback functions.
  * These operations allow the layout driver to access pNFS client
  * specific information or call pNFS client->server operations.
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index e683128..4544b52 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -82,6 +82,7 @@ struct nfs_client {
 	/* The flags used for obtaining the clientid during EXCHANGE_ID */
 	u32			cl_exchange_flags;
 	struct nfs4_session	*cl_session; 	/* sharred session */
+	struct nfs4_deviceid_cache *cl_devid_cache; /* pNFS deviceid cache */
 #endif /* CONFIG_NFS_V4_1 */
 
 #ifdef CONFIG_NFS_FSCACHE
diff --git a/include/linux/pnfs_xdr.h b/include/linux/pnfs_xdr.h
index bcbfbe0..1decc11 100644
--- a/include/linux/pnfs_xdr.h
+++ b/include/linux/pnfs_xdr.h
@@ -12,5 +12,10 @@
 #ifndef LINUX_PNFS_XDR_H
 #define LINUX_PNFS_XDR_H
 
+#define NFS4_PNFS_DEVICEID4_SIZE 16
+
+struct pnfs_deviceid {
+	char data[NFS4_PNFS_DEVICEID4_SIZE];
+};
 
 #endif /* LINUX_PNFS_XDR_H */
-- 
1.6.2.5


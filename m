Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:8952 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755905Ab1EWQfE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 12:35:04 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH v6 04/26] NFSv4.1: purge deviceid cache on nfs_free_client
Date: Mon, 23 May 2011 19:34:55 +0300
Message-Id: <1306168495-11079-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DDA8C3D.5080706@panasas.com>
References: <4DDA8C3D.5080706@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Use the pnfs_layoutdriver_type both as a qualifier for the deviceid,
distinguishing deviceid from different layout types on the server,
and for freeing the layout-driver allocated structure containing the
nfs4_deviceid_node.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c            |    2 +
 fs/nfs/nfs4filelayout.c    |    7 +++++
 fs/nfs/nfs4filelayout.h    |    1 +
 fs/nfs/nfs4filelayoutdev.c |    9 ++++---
 fs/nfs/pnfs.h              |   11 +++++++++
 fs/nfs/pnfs_dev.c          |   53 +++++++++++++++++++++++++++++++++++++++++--
 6 files changed, 76 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 139be96..b3dc2b8 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -290,6 +290,8 @@ static void nfs_free_client(struct nfs_client *clp)
 	if (clp->cl_machine_cred != NULL)
 		put_rpccred(clp->cl_machine_cred);
 
+	nfs4_deviceid_purge_client(clp);
+
 	kfree(clp->cl_hostname);
 	kfree(clp);
 
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index c8e7afe..c181a8b 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -862,6 +862,12 @@ filelayout_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
 	return -ENOMEM;
 }
 
+static void
+filelayout_free_deveiceid_node(struct nfs4_deviceid_node *d)
+{
+	nfs4_fl_free_deviceid(container_of(d, struct nfs4_file_layout_dsaddr, id_node));
+}
+
 static struct pnfs_layoutdriver_type filelayout_type = {
 	.id			= LAYOUT_NFSV4_1_FILES,
 	.name			= "LAYOUT_NFSV4_1_FILES",
@@ -874,6 +880,7 @@ static struct pnfs_layoutdriver_type filelayout_type = {
 	.commit_pagelist	= filelayout_commit_pagelist,
 	.read_pagelist		= filelayout_read_pagelist,
 	.write_pagelist		= filelayout_write_pagelist,
+	.free_deviceid_node	= filelayout_free_deveiceid_node,
 };
 
 static int __init nfs4filelayout_init(void)
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 0ace0a2..cebe01e 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -98,6 +98,7 @@ u32 nfs4_fl_calc_ds_index(struct pnfs_layout_segment *lseg, u32 j);
 struct nfs4_pnfs_ds *nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg,
 					u32 ds_idx);
 extern void nfs4_fl_put_deviceid(struct nfs4_file_layout_dsaddr *dsaddr);
+extern void nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr);
 struct nfs4_file_layout_dsaddr *
 get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id, gfp_t gfp_flags);
 
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index eda4527..5914659 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -156,7 +156,7 @@ destroy_ds(struct nfs4_pnfs_ds *ds)
 	kfree(ds);
 }
 
-static void
+void
 nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
 {
 	struct nfs4_pnfs_ds *ds;
@@ -386,7 +386,9 @@ decode_device(struct inode *ino, struct pnfs_device *pdev, gfp_t gfp_flags)
 	dsaddr->stripe_indices = stripe_indices;
 	stripe_indices = NULL;
 	dsaddr->ds_num = num;
-	nfs4_init_deviceid_node(&dsaddr->id_node, NFS_SERVER(ino)->nfs_client,
+	nfs4_init_deviceid_node(&dsaddr->id_node,
+				NFS_SERVER(ino)->pnfs_curr_ld,
+				NFS_SERVER(ino)->nfs_client,
 				&pdev->dev_id);
 
 	for (i = 0; i < dsaddr->ds_num; i++) {
@@ -548,8 +550,7 @@ out_free:
 void
 nfs4_fl_put_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
 {
-	if (nfs4_put_deviceid_node(&dsaddr->id_node))
-		nfs4_fl_free_deviceid(dsaddr);
+	nfs4_put_deviceid_node(&dsaddr->id_node);
 }
 
 /*
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 3831ad0..9667a62 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -65,6 +65,8 @@ enum {
 	NFS_LAYOUT_DESTROYED,		/* no new use of layout allowed */
 };
 
+struct nfs4_deviceid_node;
+
 /* Per-layout driver specific registration structure */
 struct pnfs_layoutdriver_type {
 	struct list_head pnfs_tblid;
@@ -90,6 +92,8 @@ struct pnfs_layoutdriver_type {
 	 */
 	enum pnfs_try_status (*read_pagelist) (struct nfs_read_data *nfs_data);
 	enum pnfs_try_status (*write_pagelist) (struct nfs_write_data *nfs_data, int how);
+
+	void (*free_deviceid_node) (struct nfs4_deviceid_node *);
 };
 
 struct pnfs_layout_hdr {
@@ -160,6 +164,7 @@ int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
 /* pnfs_dev.c */
 struct nfs4_deviceid_node {
 	struct hlist_node		node;
+	const struct pnfs_layoutdriver_type *ld;
 	const struct nfs_client		*nfs_client;
 	struct nfs4_deviceid		deviceid;
 	atomic_t			ref;
@@ -169,10 +174,12 @@ void nfs4_print_deviceid(const struct nfs4_deviceid *dev_id);
 struct nfs4_deviceid_node *nfs4_find_get_deviceid(const struct nfs_client *, const struct nfs4_deviceid *);
 struct nfs4_deviceid_node *nfs4_unhash_put_deviceid(const struct nfs_client *, const struct nfs4_deviceid *);
 void nfs4_init_deviceid_node(struct nfs4_deviceid_node *,
+			     const struct pnfs_layoutdriver_type *,
 			     const struct nfs_client *,
 			     const struct nfs4_deviceid *);
 struct nfs4_deviceid_node *nfs4_insert_deviceid_node(struct nfs4_deviceid_node *);
 bool nfs4_put_deviceid_node(struct nfs4_deviceid_node *);
+void nfs4_deviceid_purge_client(const struct nfs_client *);
 
 static inline int lo_fail_bit(u32 iomode)
 {
@@ -349,6 +356,10 @@ static inline int pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 {
 	return 0;
 }
+
+static inline void nfs4_deviceid_purge_client(struct nfs_client *)
+{
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 #endif /* FS_NFS_PNFS_H */
diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index bf05189..3cd7854 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -96,11 +96,15 @@ EXPORT_SYMBOL_GPL(nfs4_find_get_deviceid);
 
 void
 nfs4_init_deviceid_node(struct nfs4_deviceid_node *d,
+			const struct pnfs_layoutdriver_type *ld,
 			const struct nfs_client *nfs_client,
 			const struct nfs4_deviceid *id)
 {
+	INIT_HLIST_NODE(&d->node);
+	d->ld = ld;
 	d->nfs_client = nfs_client;
 	d->deviceid = *id;
+	atomic_set(&d->ref, 1);
 }
 EXPORT_SYMBOL_GPL(nfs4_init_deviceid_node);
 
@@ -108,7 +112,10 @@ EXPORT_SYMBOL_GPL(nfs4_init_deviceid_node);
  * Uniquely initialize and insert a deviceid node into cache
  *
  * @new new deviceid node
- *      Note that the caller must set up new->nfs_client and new->deviceid
+ *      Note that the caller must set up the following members:
+ *        new->ld
+ *        new->nfs_client
+ *        new->deviceid
  *
  * @ret the inserted node, if none found, otherwise, the found entry.
  */
@@ -125,8 +132,6 @@ nfs4_insert_deviceid_node(struct nfs4_deviceid_node *new)
 		return d;
 	}
 
-	INIT_HLIST_NODE(&new->node);
-	atomic_set(&new->ref, 1);
 	hash = nfs4_deviceid_hash(&new->deviceid);
 	hlist_add_head_rcu(&new->node, &nfs4_deviceid_cache[hash]);
 	spin_unlock(&nfs4_deviceid_lock);
@@ -151,6 +156,48 @@ nfs4_put_deviceid_node(struct nfs4_deviceid_node *d)
 	hlist_del_init_rcu(&d->node);
 	spin_unlock(&nfs4_deviceid_lock);
 	synchronize_rcu();
+	if (d->ld->free_deviceid_node)
+		d->ld->free_deviceid_node(d);
 	return true;
 }
 EXPORT_SYMBOL_GPL(nfs4_put_deviceid_node);
+
+static void
+_deviceid_purge_client(const struct nfs_client *clp, long hash)
+{
+	struct nfs4_deviceid_node *d;
+	struct hlist_node *n, *next;
+	HLIST_HEAD(tmp);
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(d, n, &nfs4_deviceid_cache[hash], node)
+		if (d->nfs_client == clp && atomic_read(&d->ref)) {
+			hlist_del_init_rcu(&d->node);
+			hlist_add_head(&d->node, &tmp);
+		}
+	rcu_read_unlock();
+
+	if (hlist_empty(&tmp))
+		return;
+
+	synchronize_rcu();
+	hlist_for_each_entry_safe(d, n, next, &tmp, node)
+		if (!atomic_dec_and_test(&d->ref)) {
+			if (d->ld->free_deviceid_node)
+				d->ld->free_deviceid_node(d);
+			else
+				kfree(d);
+		}
+}
+
+void
+nfs4_deviceid_purge_client(const struct nfs_client *clp)
+{
+	long h;
+
+	spin_lock(&nfs4_deviceid_lock);
+	for (h = 0; h < NFS4_DEVICE_ID_HASH_SIZE; h++)
+		_deviceid_purge_client(clp, h);
+	spin_unlock(&nfs4_deviceid_lock);
+}
+EXPORT_SYMBOL_GPL(nfs4_deviceid_purge_client);
-- 
1.7.3.4


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:57074 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752194Ab1EYV04 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2011 17:26:56 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v8 04/32] NFSv4.1: make deviceid cache global
Date: Thu, 26 May 2011 00:26:54 +0300
Message-Id: <1306358814-16931-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DDD7392.6040505@panasas.com>
References: <4DDD7392.6040505@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Move deviceid cache from the pnfs files layout driver to the
generic layer in preparation for the objects layout driver.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/Makefile            |    2 +-
 fs/nfs/nfs4filelayout.c    |   10 ++-
 fs/nfs/nfs4filelayout.h    |    8 +--
 fs/nfs/nfs4filelayoutdev.c |  104 ++++-------------------------
 fs/nfs/pnfs.h              |   17 +++++
 fs/nfs/pnfs_dev.c          |  156 ++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 194 insertions(+), 103 deletions(-)
 create mode 100644 fs/nfs/pnfs_dev.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 4776ff9..7516a8a 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -15,7 +15,7 @@ nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   delegation.o idmap.o \
 			   callback.o callback_xdr.o callback_proc.o \
 			   nfs4namespace.o
-nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o
+nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
 
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 571c1b0..4c67a6f 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -421,6 +421,7 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
 			struct nfs4_deviceid *id,
 			gfp_t gfp_flags)
 {
+	struct nfs4_deviceid_node *d;
 	struct nfs4_file_layout_dsaddr *dsaddr;
 	int status = -EINVAL;
 	struct nfs_server *nfss = NFS_SERVER(lo->plh_inode);
@@ -440,12 +441,13 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
 	}
 
 	/* find and reference the deviceid */
-	dsaddr = nfs4_fl_find_get_deviceid(NFS_SERVER(lo->plh_inode)->nfs_client, id);
-	if (dsaddr == NULL) {
+	d = nfs4_find_get_deviceid(NFS_SERVER(lo->plh_inode)->nfs_client, id);
+	if (d == NULL) {
 		dsaddr = get_device_info(lo->plh_inode, id, gfp_flags);
 		if (dsaddr == NULL)
 			goto out;
-	}
+	} else
+		dsaddr = container_of(d, struct nfs4_file_layout_dsaddr, id_node);
 	fl->dsaddr = dsaddr;
 
 	if (fl->first_stripe_index < 0 ||
@@ -535,7 +537,7 @@ filelayout_decode_layout(struct pnfs_layout_hdr *flo,
 
 	memcpy(id, p, sizeof(*id));
 	p += XDR_QUADLEN(NFS4_DEVICEID4_SIZE);
-	print_deviceid(id);
+	nfs4_print_deviceid(id);
 
 	nfl_util = be32_to_cpup(p++);
 	if (nfl_util & NFL4_UFLG_COMMIT_THRU_MDS)
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 301b955..0ace0a2 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -59,10 +59,7 @@ struct nfs4_pnfs_ds {
 #define NFS4_DEVICE_ID_NEG_ENTRY	0x00000001
 
 struct nfs4_file_layout_dsaddr {
-	struct hlist_node		node;
-	struct nfs_client		*nfs_client;
-	struct nfs4_deviceid		deviceid;
-	atomic_t			ref;
+	struct nfs4_deviceid_node	id_node;
 	unsigned long			flags;
 	u32				stripe_count;
 	u8				*stripe_indices;
@@ -96,13 +93,10 @@ extern struct nfs_fh *
 nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, u32 j);
 
 extern void print_ds(struct nfs4_pnfs_ds *ds);
-extern void print_deviceid(struct nfs4_deviceid *dev_id);
 u32 nfs4_fl_calc_j_index(struct pnfs_layout_segment *lseg, loff_t offset);
 u32 nfs4_fl_calc_ds_index(struct pnfs_layout_segment *lseg, u32 j);
 struct nfs4_pnfs_ds *nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg,
 					u32 ds_idx);
-extern struct nfs4_file_layout_dsaddr *
-nfs4_fl_find_get_deviceid(struct nfs_client *, struct nfs4_deviceid *dev_id);
 extern void nfs4_fl_put_deviceid(struct nfs4_file_layout_dsaddr *dsaddr);
 struct nfs4_file_layout_dsaddr *
 get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id, gfp_t gfp_flags);
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 42e3266..eda4527 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -37,30 +37,6 @@
 #define NFSDBG_FACILITY		NFSDBG_PNFS_LD
 
 /*
- * Device ID RCU cache. A device ID is unique per client ID and layout type.
- */
-#define NFS4_FL_DEVICE_ID_HASH_BITS	5
-#define NFS4_FL_DEVICE_ID_HASH_SIZE	(1 << NFS4_FL_DEVICE_ID_HASH_BITS)
-#define NFS4_FL_DEVICE_ID_HASH_MASK	(NFS4_FL_DEVICE_ID_HASH_SIZE - 1)
-
-static inline u32
-nfs4_fl_deviceid_hash(struct nfs4_deviceid *id)
-{
-	unsigned char *cptr = (unsigned char *)id->data;
-	unsigned int nbytes = NFS4_DEVICEID4_SIZE;
-	u32 x = 0;
-
-	while (nbytes--) {
-		x *= 37;
-		x += *cptr++;
-	}
-	return x & NFS4_FL_DEVICE_ID_HASH_MASK;
-}
-
-static struct hlist_head filelayout_deviceid_cache[NFS4_FL_DEVICE_ID_HASH_SIZE];
-static DEFINE_SPINLOCK(filelayout_deviceid_lock);
-
-/*
  * Data server cache
  *
  * Data servers can be mapped to different device ids.
@@ -89,27 +65,6 @@ print_ds(struct nfs4_pnfs_ds *ds)
 		ds->ds_clp ? ds->ds_clp->cl_exchange_flags : 0);
 }
 
-void
-print_ds_list(struct nfs4_file_layout_dsaddr *dsaddr)
-{
-	int i;
-
-	ifdebug(FACILITY) {
-		printk("%s dsaddr->ds_num %d\n", __func__,
-		       dsaddr->ds_num);
-		for (i = 0; i < dsaddr->ds_num; i++)
-			print_ds(dsaddr->ds_list[i]);
-	}
-}
-
-void print_deviceid(struct nfs4_deviceid *id)
-{
-	u32 *p = (u32 *)id;
-
-	dprintk("%s: device id= [%x%x%x%x]\n", __func__,
-		p[0], p[1], p[2], p[3]);
-}
-
 /* nfs4_ds_cache_lock is held */
 static struct nfs4_pnfs_ds *
 _data_server_lookup_locked(u32 ip_addr, u32 port)
@@ -207,7 +162,7 @@ nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
 	struct nfs4_pnfs_ds *ds;
 	int i;
 
-	print_deviceid(&dsaddr->deviceid);
+	nfs4_print_deviceid(&dsaddr->id_node.deviceid);
 
 	for (i = 0; i < dsaddr->ds_num; i++) {
 		ds = dsaddr->ds_list[i];
@@ -431,8 +386,8 @@ decode_device(struct inode *ino, struct pnfs_device *pdev, gfp_t gfp_flags)
 	dsaddr->stripe_indices = stripe_indices;
 	stripe_indices = NULL;
 	dsaddr->ds_num = num;
-	dsaddr->nfs_client = NFS_SERVER(ino)->nfs_client;
-	memcpy(&dsaddr->deviceid, &pdev->dev_id, sizeof(pdev->dev_id));
+	nfs4_init_deviceid_node(&dsaddr->id_node, NFS_SERVER(ino)->nfs_client,
+				&pdev->dev_id);
 
 	for (i = 0; i < dsaddr->ds_num; i++) {
 		int j;
@@ -505,8 +460,8 @@ out_err:
 static struct nfs4_file_layout_dsaddr *
 decode_and_add_device(struct inode *inode, struct pnfs_device *dev, gfp_t gfp_flags)
 {
-	struct nfs4_file_layout_dsaddr *d, *new;
-	long hash;
+	struct nfs4_deviceid_node *d;
+	struct nfs4_file_layout_dsaddr *n, *new;
 
 	new = decode_device(inode, dev, gfp_flags);
 	if (!new) {
@@ -515,20 +470,13 @@ decode_and_add_device(struct inode *inode, struct pnfs_device *dev, gfp_t gfp_fl
 		return NULL;
 	}
 
-	spin_lock(&filelayout_deviceid_lock);
-	d = nfs4_fl_find_get_deviceid(new->nfs_client, &new->deviceid);
-	if (d) {
-		spin_unlock(&filelayout_deviceid_lock);
+	d = nfs4_insert_deviceid_node(&new->id_node);
+	n = container_of(d, struct nfs4_file_layout_dsaddr, id_node);
+	if (n != new) {
 		nfs4_fl_free_deviceid(new);
-		return d;
+		return n;
 	}
 
-	INIT_HLIST_NODE(&new->node);
-	atomic_set(&new->ref, 1);
-	hash = nfs4_fl_deviceid_hash(&new->deviceid);
-	hlist_add_head_rcu(&new->node, &filelayout_deviceid_cache[hash]);
-	spin_unlock(&filelayout_deviceid_lock);
-
 	return new;
 }
 
@@ -600,34 +548,8 @@ out_free:
 void
 nfs4_fl_put_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
 {
-	if (atomic_dec_and_lock(&dsaddr->ref, &filelayout_deviceid_lock)) {
-		hlist_del_rcu(&dsaddr->node);
-		spin_unlock(&filelayout_deviceid_lock);
-
-		synchronize_rcu();
+	if (nfs4_put_deviceid_node(&dsaddr->id_node))
 		nfs4_fl_free_deviceid(dsaddr);
-	}
-}
-
-struct nfs4_file_layout_dsaddr *
-nfs4_fl_find_get_deviceid(struct nfs_client *clp, struct nfs4_deviceid *id)
-{
-	struct nfs4_file_layout_dsaddr *d;
-	struct hlist_node *n;
-	long hash = nfs4_fl_deviceid_hash(id);
-
-	rcu_read_lock();
-	hlist_for_each_entry_rcu(d, n, &filelayout_deviceid_cache[hash], node) {
-		if (d->nfs_client == clp && !memcmp(&d->deviceid, id, sizeof(*id))) {
-			if (!atomic_inc_not_zero(&d->ref))
-				goto fail;
-			rcu_read_unlock();
-			return d;
-		}
-	}
-fail:
-	rcu_read_unlock();
-	return NULL;
 }
 
 /*
@@ -675,15 +597,15 @@ static void
 filelayout_mark_devid_negative(struct nfs4_file_layout_dsaddr *dsaddr,
 			       int err, u32 ds_addr)
 {
-	u32 *p = (u32 *)&dsaddr->deviceid;
+	u32 *p = (u32 *)&dsaddr->id_node.deviceid;
 
 	printk(KERN_ERR "NFS: data server %x connection error %d."
 		" Deviceid [%x%x%x%x] marked out of use.\n",
 		ds_addr, err, p[0], p[1], p[2], p[3]);
 
-	spin_lock(&filelayout_deviceid_lock);
+	spin_lock(&nfs4_ds_cache_lock);
 	dsaddr->flags |= NFS4_DEVICE_ID_NEG_ENTRY;
-	spin_unlock(&filelayout_deviceid_lock);
+	spin_unlock(&nfs4_ds_cache_lock);
 }
 
 struct nfs4_pnfs_ds *
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 720bb9d..3831ad0 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -157,6 +157,23 @@ bool pnfs_roc_drain(struct inode *ino, u32 *barrier);
 void pnfs_set_layoutcommit(struct nfs_write_data *wdata);
 int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
 
+/* pnfs_dev.c */
+struct nfs4_deviceid_node {
+	struct hlist_node		node;
+	const struct nfs_client		*nfs_client;
+	struct nfs4_deviceid		deviceid;
+	atomic_t			ref;
+};
+
+void nfs4_print_deviceid(const struct nfs4_deviceid *dev_id);
+struct nfs4_deviceid_node *nfs4_find_get_deviceid(const struct nfs_client *, const struct nfs4_deviceid *);
+struct nfs4_deviceid_node *nfs4_unhash_put_deviceid(const struct nfs_client *, const struct nfs4_deviceid *);
+void nfs4_init_deviceid_node(struct nfs4_deviceid_node *,
+			     const struct nfs_client *,
+			     const struct nfs4_deviceid *);
+struct nfs4_deviceid_node *nfs4_insert_deviceid_node(struct nfs4_deviceid_node *);
+bool nfs4_put_deviceid_node(struct nfs4_deviceid_node *);
+
 static inline int lo_fail_bit(u32 iomode)
 {
 	return iomode == IOMODE_RW ?
diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
new file mode 100644
index 0000000..bf05189
--- /dev/null
+++ b/fs/nfs/pnfs_dev.c
@@ -0,0 +1,156 @@
+/*
+ *  Device operations for the pnfs client.
+ *
+ *  Copyright (c) 2002
+ *  The Regents of the University of Michigan
+ *  All Rights Reserved
+ *
+ *  Dean Hildebrand <dhildebz@umich.edu>
+ *  Garth Goodson   <Garth.Goodson@netapp.com>
+ *
+ *  Permission is granted to use, copy, create derivative works, and
+ *  redistribute this software and such derivative works for any purpose,
+ *  so long as the name of the University of Michigan is not used in
+ *  any advertising or publicity pertaining to the use or distribution
+ *  of this software without specific, written prior authorization. If
+ *  the above copyright notice or any other identification of the
+ *  University of Michigan is included in any copy of any portion of
+ *  this software, then the disclaimer below must also be included.
+ *
+ *  This software is provided as is, without representation or warranty
+ *  of any kind either express or implied, including without limitation
+ *  the implied warranties of merchantability, fitness for a particular
+ *  purpose, or noninfringement.  The Regents of the University of
+ *  Michigan shall not be liable for any damages, including special,
+ *  indirect, incidental, or consequential damages, with respect to any
+ *  claim arising out of or in connection with the use of the software,
+ *  even if it has been or is hereafter advised of the possibility of
+ *  such damages.
+ */
+
+#include "pnfs.h"
+
+#define NFSDBG_FACILITY		NFSDBG_PNFS
+
+/*
+ * Device ID RCU cache. A device ID is unique per server and layout type.
+ */
+#define NFS4_DEVICE_ID_HASH_BITS	5
+#define NFS4_DEVICE_ID_HASH_SIZE	(1 << NFS4_DEVICE_ID_HASH_BITS)
+#define NFS4_DEVICE_ID_HASH_MASK	(NFS4_DEVICE_ID_HASH_SIZE - 1)
+
+static struct hlist_head nfs4_deviceid_cache[NFS4_DEVICE_ID_HASH_SIZE];
+static DEFINE_SPINLOCK(nfs4_deviceid_lock);
+
+void
+nfs4_print_deviceid(const struct nfs4_deviceid *id)
+{
+	u32 *p = (u32 *)id;
+
+	dprintk("%s: device id= [%x%x%x%x]\n", __func__,
+		p[0], p[1], p[2], p[3]);
+}
+EXPORT_SYMBOL_GPL(nfs4_print_deviceid);
+
+static inline u32
+nfs4_deviceid_hash(const struct nfs4_deviceid *id)
+{
+	unsigned char *cptr = (unsigned char *)id->data;
+	unsigned int nbytes = NFS4_DEVICEID4_SIZE;
+	u32 x = 0;
+
+	while (nbytes--) {
+		x *= 37;
+		x += *cptr++;
+	}
+	return x & NFS4_DEVICE_ID_HASH_MASK;
+}
+
+/*
+ * Lookup a deviceid in cache and get a reference count on it if found
+ *
+ * @clp nfs_client associated with deviceid
+ * @id deviceid to look up
+ */
+struct nfs4_deviceid_node *
+nfs4_find_get_deviceid(const struct nfs_client *clp, const struct nfs4_deviceid *id)
+{
+	struct nfs4_deviceid_node *d;
+	struct hlist_node *n;
+	long hash = nfs4_deviceid_hash(id);
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(d, n, &nfs4_deviceid_cache[hash], node) {
+		if (d->nfs_client == clp && !memcmp(&d->deviceid, id, sizeof(*id))) {
+			if (!atomic_inc_not_zero(&d->ref))
+				goto fail;
+			rcu_read_unlock();
+			return d;
+		}
+	}
+fail:
+	rcu_read_unlock();
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(nfs4_find_get_deviceid);
+
+void
+nfs4_init_deviceid_node(struct nfs4_deviceid_node *d,
+			const struct nfs_client *nfs_client,
+			const struct nfs4_deviceid *id)
+{
+	d->nfs_client = nfs_client;
+	d->deviceid = *id;
+}
+EXPORT_SYMBOL_GPL(nfs4_init_deviceid_node);
+
+/*
+ * Uniquely initialize and insert a deviceid node into cache
+ *
+ * @new new deviceid node
+ *      Note that the caller must set up new->nfs_client and new->deviceid
+ *
+ * @ret the inserted node, if none found, otherwise, the found entry.
+ */
+struct nfs4_deviceid_node *
+nfs4_insert_deviceid_node(struct nfs4_deviceid_node *new)
+{
+	struct nfs4_deviceid_node *d;
+	long hash;
+
+	spin_lock(&nfs4_deviceid_lock);
+	d = nfs4_find_get_deviceid(new->nfs_client, &new->deviceid);
+	if (d) {
+		spin_unlock(&nfs4_deviceid_lock);
+		return d;
+	}
+
+	INIT_HLIST_NODE(&new->node);
+	atomic_set(&new->ref, 1);
+	hash = nfs4_deviceid_hash(&new->deviceid);
+	hlist_add_head_rcu(&new->node, &nfs4_deviceid_cache[hash]);
+	spin_unlock(&nfs4_deviceid_lock);
+
+	return new;
+}
+EXPORT_SYMBOL_GPL(nfs4_insert_deviceid_node);
+
+/*
+ * Dereference a deviceid node and delete it when its reference count drops
+ * to zero.
+ *
+ * @d deviceid node to put
+ *
+ * @ret true iff the node was deleted
+ */
+bool
+nfs4_put_deviceid_node(struct nfs4_deviceid_node *d)
+{
+	if (!atomic_dec_and_lock(&d->ref, &nfs4_deviceid_lock))
+		return false;
+	hlist_del_init_rcu(&d->node);
+	spin_unlock(&nfs4_deviceid_lock);
+	synchronize_rcu();
+	return true;
+}
+EXPORT_SYMBOL_GPL(nfs4_put_deviceid_node);
-- 
1.7.3.4


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36907 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753348Ab2A3Uxn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jan 2012 15:53:43 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] [RFC] NFS - filelayout DS rpc mountstats support
Date: Mon, 30 Jan 2012 15:53:40 -0500
Message-Id: <1327956820-2772-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The RPC stats displayed in /self/proc/mountstats are collected in the sunrpc
layer and are collected per rpc_client.  This has worked for NFS thus far
since only one nfs_client (and it's associated rpc_client) was ever associated
with a mountpoint.

Now with NFS4.1+PNFS+filelayout, NFS can have more than one nfs_client
associated with a mountpoint!  Note that the rpc stats are hung off of the
rpc_client - so even if two connections share the same transport, they will
not use the same stats structure (ie when MDS == DS).

This patch -- admittedly ugly -- poles holes through the PNFS layout driver
to print the stats for rpc_client structures for the dataserver connections
with the filelayout driver.

I took the approach of keeping them separate in the /proc/self/mountstats
output to avoid doing too much in the kernel.  If we agree this is the way to
go, I'll update mountstats(1) to combine them for the default output (much in
the same way that averaging is done in userland instead of kernel here).
The alternative is to poke holes in the sunrpc layer to allow combining stats.

Again, I don't love this solution - it seems like a hack.  The other option
I can see is changing the rpc layer to have support for linking several
rpc_client structures to use the same stat struct, but this would likely look
like a huge hack too.

Thoughts?
---
 fs/nfs/nfs4filelayout.c    |   19 +++++++++++++++++++
 fs/nfs/nfs4filelayout.h    |    2 ++
 fs/nfs/nfs4filelayoutdev.c |   19 +++++++++++++++++++
 fs/nfs/pnfs.h              |   17 +++++++++++++++++
 fs/nfs/pnfs_dev.c          |   36 ++++++++++++++++++++++++++++++++++++
 fs/nfs/super.c             |    1 +
 6 files changed, 94 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index b4f8f96..ce20ac3 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -916,6 +916,24 @@ filelayout_free_deveiceid_node(struct nfs4_deviceid_node *d)
 	nfs4_fl_free_deviceid(container_of(d, struct nfs4_file_layout_dsaddr, id_node));
 }
 
+static void
+_rpc_print_iostats_cb(struct nfs4_deviceid_node *d, void *ctx)
+{
+	struct seq_file *m;
+	struct nfs4_file_layout_dsaddr *dsaddr;
+
+	m = (struct seq_file *)ctx;
+	dsaddr = container_of(d, struct nfs4_file_layout_dsaddr, id_node);
+	nfs4_fl_rpc_print_iostats(m, dsaddr);
+}
+
+static void
+filelayout_rpc_print_iostats(struct seq_file *m, const struct nfs_server *nfss)
+{
+	nfs4_foreach_deviceid(nfss->pnfs_curr_ld, nfss->nfs_client,
+			      _rpc_print_iostats_cb, m);
+}
+
 static struct pnfs_layoutdriver_type filelayout_type = {
 	.id			= LAYOUT_NFSV4_1_FILES,
 	.name			= "LAYOUT_NFSV4_1_FILES",
@@ -930,6 +948,7 @@ static struct pnfs_layoutdriver_type filelayout_type = {
 	.read_pagelist		= filelayout_read_pagelist,
 	.write_pagelist		= filelayout_write_pagelist,
 	.free_deviceid_node	= filelayout_free_deveiceid_node,
+	.rpc_print_iostats	= filelayout_rpc_print_iostats,
 };
 
 static int __init nfs4filelayout_init(void)
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 2e42284..6942992 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -110,6 +110,8 @@ u32 nfs4_fl_calc_j_index(struct pnfs_layout_segment *lseg, loff_t offset);
 u32 nfs4_fl_calc_ds_index(struct pnfs_layout_segment *lseg, u32 j);
 struct nfs4_pnfs_ds *nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg,
 					u32 ds_idx);
+void nfs4_fl_rpc_print_iostats(struct seq_file *,
+			       struct nfs4_file_layout_dsaddr *);
 extern void nfs4_fl_put_deviceid(struct nfs4_file_layout_dsaddr *dsaddr);
 extern void nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr);
 struct nfs4_file_layout_dsaddr *
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 6eb59b0..1a03a14 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -31,6 +31,8 @@
 #include <linux/nfs_fs.h>
 #include <linux/vmalloc.h>
 
+#include <linux/sunrpc/metrics.h>
+
 #include "internal.h"
 #include "nfs4filelayout.h"
 
@@ -829,6 +831,23 @@ filelayout_mark_devid_negative(struct nfs4_file_layout_dsaddr *dsaddr,
 	spin_unlock(&nfs4_ds_cache_lock);
 }
 
+void
+nfs4_fl_rpc_print_iostats(struct seq_file *m,
+			  struct nfs4_file_layout_dsaddr *dsaddr)
+{
+	struct nfs4_pnfs_ds *ds;
+	u32 i;
+
+	for (i = 0; i < dsaddr->ds_num; i++) {
+		ds = dsaddr->ds_list[i];
+
+		if (ds && ds->ds_clp) {
+			seq_printf(m, "PNFS Dataserver %s\n", ds->ds_remotestr);
+			rpc_print_iostats(m, ds->ds_clp->cl_rpcclient);
+		}
+	}
+}
+
 struct nfs4_pnfs_ds *
 nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 53d593a..86433d8 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -119,6 +119,9 @@ struct pnfs_layoutdriver_type {
 	void (*encode_layoutcommit) (struct pnfs_layout_hdr *layoutid,
 				     struct xdr_stream *xdr,
 				     const struct nfs4_layoutcommit_args *args);
+
+	void (*rpc_print_iostats) (struct seq_file *m,
+				   const struct nfs_server *nfss);
 };
 
 struct pnfs_layout_hdr {
@@ -231,6 +234,7 @@ struct nfs4_deviceid_node {
 
 void nfs4_print_deviceid(const struct nfs4_deviceid *dev_id);
 struct nfs4_deviceid_node *nfs4_find_get_deviceid(const struct pnfs_layoutdriver_type *, const struct nfs_client *, const struct nfs4_deviceid *);
+void nfs4_foreach_deviceid(const struct pnfs_layoutdriver_type *, const struct nfs_client *, void (*callback)(struct nfs4_deviceid_node *, void *), void *);
 void nfs4_delete_deviceid(const struct pnfs_layoutdriver_type *, const struct nfs_client *, const struct nfs4_deviceid *);
 void nfs4_init_deviceid_node(struct nfs4_deviceid_node *,
 			     const struct pnfs_layoutdriver_type *,
@@ -328,6 +332,13 @@ static inline int pnfs_return_layout(struct inode *ino)
 	return 0;
 }
 
+static inline void
+pnfs_rpc_print_iostats(struct seq_file *m, struct nfs_server *nfss)
+{
+	if (pnfs_enabled_sb(nfss) && nfss->pnfs_curr_ld->rpc_print_iostats)
+		nfss->pnfs_curr_ld->rpc_print_iostats(m, nfss);
+}
+
 #else  /* CONFIG_NFS_V4_1 */
 
 static inline void pnfs_destroy_all_layouts(struct nfs_client *clp)
@@ -429,6 +440,12 @@ static inline int pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 static inline void nfs4_deviceid_purge_client(struct nfs_client *ncl)
 {
 }
+
+static inline void
+pnfs_rpc_print_iostats(struct seq_file *m, struct nfs_server *nfss)
+{
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 #endif /* FS_NFS_PNFS_H */
diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index 4f359d2..5a65668 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -115,6 +115,42 @@ nfs4_find_get_deviceid(const struct pnfs_layoutdriver_type *ld,
 }
 EXPORT_SYMBOL_GPL(nfs4_find_get_deviceid);
 
+
+/*
+ * Apply callback function to each entry in the cache that matches
+ * the specified layout driver and nfs_client (of the MDS)
+ */
+void
+_nfs4_foreach_deviceid(const struct pnfs_layoutdriver_type *ld,
+		       const struct nfs_client *clp,
+		       void (*callback)(struct nfs4_deviceid_node *, void *),
+		       void *ctx)
+{
+	struct nfs4_deviceid_node *d;
+	struct hlist_node *n;
+	long hash;
+
+	for (hash = 0; hash < NFS4_DEVICE_ID_HASH_SIZE; hash++) {
+		hlist_for_each_entry_rcu(d, n, &nfs4_deviceid_cache[hash], node)
+			if (d->ld == ld && d->nfs_client == clp) {
+				if (atomic_read(&d->ref))
+					callback(d, ctx);
+			}
+	}
+}
+
+void
+nfs4_foreach_deviceid(const struct pnfs_layoutdriver_type *ld,
+		      const struct nfs_client *clp,
+		      void (*callback)(struct nfs4_deviceid_node *, void *),
+		      void *ctx)
+{
+	rcu_read_lock();
+	_nfs4_foreach_deviceid(ld, clp, callback, ctx);
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL_GPL(nfs4_foreach_deviceid);
+
 /*
  * Remove a deviceid from cache
  *
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b79f2a1..5d8e00b 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -869,6 +869,7 @@ static int nfs_show_stats(struct seq_file *m, struct dentry *root)
 	seq_printf(m, "\n");
 
 	rpc_print_iostats(m, nfss->client);
+	pnfs_rpc_print_iostats(m, nfss);
 
 	return 0;
 }
-- 
1.7.4.4


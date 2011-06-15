Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14943 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754343Ab1FPP1O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jun 2011 11:27:14 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Bakeathon 2/2] NFSv4.1: do not use deviceids after MDS clientid invalidation
Date: Wed, 15 Jun 2011 17:52:40 -0400
Message-Id: <1308174760-22825-2-git-send-email-andros@netapp.com>
In-Reply-To: <1308174760-22825-1-git-send-email-andros@netapp.com>
References: <1308174760-22825-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Mark all deviceids established under an expired MDS clientid as invalid.
Stop all new i/o through DS and send through the MDS.
Don't use any new LAYOUTGETs that use the invalid deviceid. Purge all layouts
established under the expired MDS clientid.
Remove the MDS clientid deviceid and data servers reference

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   10 ++++++++++
 fs/nfs/nfs4filelayout.h |    6 ++++++
 fs/nfs/pnfs.c           |    3 +++
 fs/nfs/pnfs.h           |    8 ++++++++
 fs/nfs/pnfs_dev.c       |   25 +++++++++++++++++++++++++
 5 files changed, 52 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 8f16112..4f7caab 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -333,6 +333,9 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 		__func__, data->inode->i_ino,
 		data->args.pgbase, (size_t)data->args.count, offset);
 
+	if (test_bit(NFS_DEVICEID_INVALID, &FILELAYOUT_DEVID_NODE(lseg)->flags))
+		return PNFS_NOT_ATTEMPTED;
+
 	/* Retrieve the correct rpc_client for the byte range */
 	j = nfs4_fl_calc_j_index(lseg, offset);
 	idx = nfs4_fl_calc_ds_index(lseg, j);
@@ -372,6 +375,9 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
 	struct nfs_fh *fh;
 	int status;
 
+	if (test_bit(NFS_DEVICEID_INVALID, &FILELAYOUT_DEVID_NODE(lseg)->flags))
+		return PNFS_NOT_ATTEMPTED;
+
 	/* Retrieve the correct rpc_client for the byte range */
 	j = nfs4_fl_calc_j_index(lseg, offset);
 	idx = nfs4_fl_calc_ds_index(lseg, j);
@@ -456,6 +462,10 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
 			goto out;
 	} else
 		dsaddr = container_of(d, struct nfs4_file_layout_dsaddr, id_node);
+	/* Found deviceid is being reaped */
+	if (test_bit(NFS_DEVICEID_INVALID, &dsaddr->id_node.flags))
+			goto out_put;
+
 	fl->dsaddr = dsaddr;
 
 	if (fl->first_stripe_index < 0 ||
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 68cce73..f067329 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -96,6 +96,12 @@ FILELAYOUT_LSEG(struct pnfs_layout_segment *lseg)
 			    generic_hdr);
 }
 
+static inline struct nfs4_deviceid_node *
+FILELAYOUT_DEVID_NODE(struct pnfs_layout_segment *lseg)
+{
+	return (&(FILELAYOUT_LSEG(lseg)->dsaddr->id_node));
+}
+
 extern struct nfs_fh *
 nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, u32 j);
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b3994e1..a4b5e72 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -452,6 +452,9 @@ pnfs_destroy_all_layouts(struct nfs_client *clp)
 	struct pnfs_layout_hdr *lo;
 	LIST_HEAD(tmp_list);
 
+	nfs4_mark_client_deviceid(clp);
+	nfs4_deviceid_purge_client(clp);
+
 	spin_lock(&clp->cl_lock);
 	rcu_read_lock();
 	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index e46edac..a0be016 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -192,12 +192,20 @@ struct pnfs_layout_segment *pnfs_update_layout(struct inode *ino,
 					       enum pnfs_iomode iomode,
 					       gfp_t gfp_flags);
 
+void nfs4_mark_client_deviceid(struct nfs_client *clp);
+
+/* nfs4_deviceid_flags */
+enum {
+	NFS_DEVICEID_INVALID = 0,       /* set when MDS clientid recalled */
+};
+
 /* pnfs_dev.c */
 struct nfs4_deviceid_node {
 	struct hlist_node		node;
 	struct hlist_node		tmpnode;
 	const struct pnfs_layoutdriver_type *ld;
 	const struct nfs_client		*nfs_client;
+	unsigned long 			flags;
 	struct nfs4_deviceid		deviceid;
 	atomic_t			ref;
 };
diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index b868cfb..e8f93f9 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -156,6 +156,7 @@ nfs4_init_deviceid_node(struct nfs4_deviceid_node *d,
 	INIT_HLIST_NODE(&d->tmpnode);
 	d->ld = ld;
 	d->nfs_client = nfs_client;
+	d->flags = 0;
 	d->deviceid = *id;
 	atomic_set(&d->ref, 1);
 }
@@ -253,3 +254,27 @@ nfs4_deviceid_purge_client(const struct nfs_client *clp)
 	for (h = 0; h < NFS4_DEVICE_ID_HASH_SIZE; h++)
 		_deviceid_purge_client(clp, h);
 }
+
+/*
+ * Stop use of all deviceids associated with an nfs_client
+ */
+void
+nfs4_mark_client_deviceid(struct nfs_client *clp)
+{
+	struct nfs4_deviceid_node *d;
+	struct hlist_node *n;
+	int i;
+
+	spin_lock(&nfs4_deviceid_lock);
+	rcu_read_lock();
+	for (i = 0; i < NFS4_DEVICE_ID_HASH_SIZE; i ++){
+		hlist_for_each_entry_rcu(d, n, &nfs4_deviceid_cache[i], node)
+			if (d->nfs_client == clp)
+				set_bit(NFS_DEVICEID_INVALID, &d->flags);
+	}
+	rcu_read_unlock();
+	spin_unlock(&nfs4_deviceid_lock);
+
+	synchronize_rcu();
+}
+EXPORT_SYMBOL_GPL(nfs4_mark_client_deviceid);
-- 
1.7.3.1


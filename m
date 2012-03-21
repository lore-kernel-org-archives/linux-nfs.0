Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36490 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753000Ab2CUTqw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 15:46:52 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 02/12] NFSv4.1: cleanup filelayout invalid deviceid handling
Date: Wed, 21 Mar 2012 15:46:14 -0400
Message-Id: <1332359184-1887-3-git-send-email-andros@netapp.com>
In-Reply-To: <1332359184-1887-1-git-send-email-andros@netapp.com>
References: <1332359184-1887-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Move the invalid deviceid test into nfs4_fl_prepare_ds, called by the
filelayout read, write, and commit routines. NFS4_DEVICE_ID_NEG_ENTRY
is no longer needed.
Remove redundant printk's - filelayout_mark_devid_invalid prints a KERN_WARNING.

An invalid device prevents pNFS io.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c    |   10 ----------
 fs/nfs/nfs4filelayout.h    |   21 +++++++++++++++++----
 fs/nfs/nfs4filelayoutdev.c |   37 +++++++++++--------------------------
 3 files changed, 28 insertions(+), 40 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 36a65ce..cb9ea7e 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -392,9 +392,6 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 		__func__, data->inode->i_ino,
 		data->args.pgbase, (size_t)data->args.count, offset);
 
-	if (test_bit(NFS_DEVICEID_INVALID, &FILELAYOUT_DEVID_NODE(lseg)->flags))
-		return PNFS_NOT_ATTEMPTED;
-
 	/* Retrieve the correct rpc_client for the byte range */
 	j = nfs4_fl_calc_j_index(lseg, offset);
 	idx = nfs4_fl_calc_ds_index(lseg, j);
@@ -434,16 +431,11 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
 	struct nfs_fh *fh;
 	int status;
 
-	if (test_bit(NFS_DEVICEID_INVALID, &FILELAYOUT_DEVID_NODE(lseg)->flags))
-		return PNFS_NOT_ATTEMPTED;
-
 	/* Retrieve the correct rpc_client for the byte range */
 	j = nfs4_fl_calc_j_index(lseg, offset);
 	idx = nfs4_fl_calc_ds_index(lseg, j);
 	ds = nfs4_fl_prepare_ds(lseg, idx);
 	if (!ds) {
-		printk(KERN_ERR "NFS: %s: prepare_ds failed, use MDS\n",
-			__func__);
 		set_bit(lo_fail_bit(IOMODE_RW), &lseg->pls_layout->plh_flags);
 		set_bit(lo_fail_bit(IOMODE_READ), &lseg->pls_layout->plh_flags);
 		return PNFS_NOT_ATTEMPTED;
@@ -922,8 +914,6 @@ static int filelayout_initiate_commit(struct nfs_write_data *data, int how)
 	idx = calc_ds_index_from_commit(lseg, data->ds_commit_index);
 	ds = nfs4_fl_prepare_ds(lseg, idx);
 	if (!ds) {
-		printk(KERN_ERR "NFS: %s: prepare_ds failed, use MDS\n",
-			__func__);
 		set_bit(lo_fail_bit(IOMODE_RW), &lseg->pls_layout->plh_flags);
 		set_bit(lo_fail_bit(IOMODE_READ), &lseg->pls_layout->plh_flags);
 		prepare_to_resend_writes(data);
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 21190bb..b54b389 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -62,12 +62,8 @@ struct nfs4_pnfs_ds {
 	atomic_t		ds_count;
 };
 
-/* nfs4_file_layout_dsaddr flags */
-#define NFS4_DEVICE_ID_NEG_ENTRY	0x00000001
-
 struct nfs4_file_layout_dsaddr {
 	struct nfs4_deviceid_node	id_node;
-	unsigned long			flags;
 	u32				stripe_count;
 	u8				*stripe_indices;
 	u32				ds_num;
@@ -107,6 +103,23 @@ FILELAYOUT_DEVID_NODE(struct pnfs_layout_segment *lseg)
 	return &FILELAYOUT_LSEG(lseg)->dsaddr->id_node;
 }
 
+static inline void
+filelayout_mark_devid_invalid(struct nfs4_deviceid_node *node)
+{
+	u32 *p = (u32 *)&node->deviceid;
+
+	printk(KERN_WARNING "NFS: Deviceid [%x%x%x%x] marked out of use.\n",
+		p[0], p[1], p[2], p[3]);
+
+	set_bit(NFS_DEVICEID_INVALID, &node->flags);
+}
+
+static inline bool
+filelayout_test_devid_invalid(struct nfs4_deviceid_node *node)
+{
+	return test_bit(NFS_DEVICEID_INVALID, &node->flags);
+}
+
 extern struct nfs_fh *
 nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, u32 j);
 
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index a866bbd..2b8ae96 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -791,48 +791,33 @@ nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, u32 j)
 	return flseg->fh_array[i];
 }
 
-static void
-filelayout_mark_devid_negative(struct nfs4_file_layout_dsaddr *dsaddr,
-			       int err, const char *ds_remotestr)
-{
-	u32 *p = (u32 *)&dsaddr->id_node.deviceid;
-
-	printk(KERN_ERR "NFS: data server %s connection error %d."
-		" Deviceid [%x%x%x%x] marked out of use.\n",
-		ds_remotestr, err, p[0], p[1], p[2], p[3]);
-
-	spin_lock(&nfs4_ds_cache_lock);
-	dsaddr->flags |= NFS4_DEVICE_ID_NEG_ENTRY;
-	spin_unlock(&nfs4_ds_cache_lock);
-}
-
 struct nfs4_pnfs_ds *
 nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 {
 	struct nfs4_file_layout_dsaddr *dsaddr = FILELAYOUT_LSEG(lseg)->dsaddr;
 	struct nfs4_pnfs_ds *ds = dsaddr->ds_list[ds_idx];
+	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(lseg);
+
+	if (filelayout_test_devid_invalid(devid))
+		return NULL;
 
 	if (ds == NULL) {
 		printk(KERN_ERR "NFS: %s: No data server for offset index %d\n",
 			__func__, ds_idx);
-		return NULL;
+		goto mark_dev_invalid;
 	}
 
 	if (!ds->ds_clp) {
 		struct nfs_server *s = NFS_SERVER(lseg->pls_layout->plh_inode);
 		int err;
 
-		if (dsaddr->flags & NFS4_DEVICE_ID_NEG_ENTRY) {
-			/* Already tried to connect, don't try again */
-			dprintk("%s Deviceid marked out of use\n", __func__);
-			return NULL;
-		}
 		err = nfs4_ds_connect(s, ds);
-		if (err) {
-			filelayout_mark_devid_negative(dsaddr, err,
-						       ds->ds_remotestr);
-			return NULL;
-		}
+		if (err)
+			goto mark_dev_invalid;
 	}
 	return ds;
+
+mark_dev_invalid:
+	filelayout_mark_devid_invalid(devid);
+	return NULL;
 }
-- 
1.7.6.4


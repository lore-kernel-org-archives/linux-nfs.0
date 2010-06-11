From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 06/26] pnfs-submit: filelayout: clean and breakup nfs4_pnfs_dserver_get
Date: Fri, 11 Jun 2010 03:31:33 -0400
Message-ID: <1276241513-17942-7-git-send-email-iisaman@netapp.com>
References: <1276241513-17942-1-git-send-email-iisaman@netapp.com>
 <1276241513-17942-2-git-send-email-iisaman@netapp.com>
 <1276241513-17942-3-git-send-email-iisaman@netapp.com>
 <1276241513-17942-4-git-send-email-iisaman@netapp.com>
 <1276241513-17942-5-git-send-email-iisaman@netapp.com>
 <1276241513-17942-6-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64287 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754075Ab0FKHcU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 03:32:20 -0400
Received: from localhost.localdomain (lesleyk-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5B7W3tx024376
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:32:08 -0700 (PDT)
In-Reply-To: <1276241513-17942-6-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rewrite nfs4_pnfs_dserver_get as two functions, nfs4_fl_calc_ds_index() and
nfs4_fl_prepare_ds().  This cleans up the code a bit and prepares for more
extensive rewrite of filelayout_commit().

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c    |   75 ++++++++++++----------------------
 fs/nfs/nfs4filelayout.h    |   33 +++++++--------
 fs/nfs/nfs4filelayoutdev.c |   95 +++++++++++++++----------------------------
 3 files changed, 75 insertions(+), 128 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index b0cda5d..2ffca74 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -196,8 +196,8 @@ filelayout_read_pagelist(struct pnfs_layout_type *layoutid,
 {
 	struct inode *inode = PNFS_INODE(layoutid);
 	struct nfs4_filelayout_segment *flseg;
-	struct nfs4_pnfs_dserver dserver;
-	int status;
+	struct nfs4_pnfs_ds *ds;
+	u32 idx;
 
 	dprintk("--> %s ino %lu nr_pages %d pgbase %u req %Zu@%llu\n",
 		__func__, inode->i_ino, nr_pages, pgbase, count, offset);
@@ -205,23 +205,19 @@ filelayout_read_pagelist(struct pnfs_layout_type *layoutid,
 	flseg = LSEG_LD_DATA(data->pdata.lseg);
 
 	/* Retrieve the correct rpc_client for the byte range */
-	status = nfs4_pnfs_dserver_get(data->pdata.lseg,
-				       offset,
-				       count,
-				       &dserver);
-	if (status) {
-		printk(KERN_ERR "%s: dserver get failed status %d use MDS\n",
-		       __func__, status);
+	idx = nfs4_fl_calc_ds_index(data->pdata.lseg, offset);
+	ds = nfs4_fl_prepare_ds(data->pdata.lseg, idx);
+	if (!ds) {
+		printk(KERN_ERR "%s: prepare_ds failed, use MDS\n", __func__);
 		return PNFS_NOT_ATTEMPTED;
 	}
-
 	dprintk("%s USE DS:ip %x %s\n", __func__,
-		htonl(dserver.ds->ds_ip_addr), dserver.ds->r_addr);
+		htonl(ds->ds_ip_addr), ds->r_addr);
 
 	/* just try the first data server for the index..*/
-	data->fldata.pnfs_client = dserver.ds->ds_clp->cl_rpcclient;
-	data->fldata.ds_nfs_client = dserver.ds->ds_clp;
-	data->args.fh = dserver.fh;
+	data->fldata.ds_nfs_client = ds->ds_clp;
+	data->fldata.pnfs_client = ds->ds_clp->cl_rpcclient;
+	data->args.fh = nfs4_fl_select_ds_fh(flseg, idx);
 
 	/* Now get the file offset on the dserver
 	 * Set the read offset to this offset, and
@@ -255,32 +251,26 @@ filelayout_write_pagelist(struct pnfs_layout_type *layoutid,
 {
 	struct inode *inode = PNFS_INODE(layoutid);
 	struct nfs4_filelayout_segment *flseg = LSEG_LD_DATA(data->pdata.lseg);
-	struct nfs4_pnfs_dserver dserver;
-	int status;
+	struct nfs4_pnfs_ds *ds;
+	u32 idx;
 
 	dprintk("--> %s ino %lu nr_pages %d pgbase %u req %Zu@%llu sync %d\n",
 		__func__, inode->i_ino, nr_pages, pgbase, count, offset, sync);
 
 	/* Retrieve the correct rpc_client for the byte range */
-	status = nfs4_pnfs_dserver_get(data->pdata.lseg,
-				       offset,
-				       count,
-				       &dserver);
-
-	if (status) {
-		printk(KERN_ERR "%s: dserver get failed status %d use MDS\n",
-		       __func__, status);
+	idx = nfs4_fl_calc_ds_index(data->pdata.lseg, offset);
+	ds = nfs4_fl_prepare_ds(data->pdata.lseg, idx);
+	if (!ds) {
+		printk(KERN_ERR "%s: prepare_ds failed, use MDS\n", __func__);
 		return PNFS_NOT_ATTEMPTED;
 	}
-
 	dprintk("%s ino %lu %Zu@%llu DS:%x:%hu %s\n",
 		__func__, inode->i_ino, count, offset,
-		htonl(dserver.ds->ds_ip_addr), ntohs(dserver.ds->ds_port),
-		dserver.ds->r_addr);
+		htonl(ds->ds_ip_addr), ntohs(ds->ds_port), ds->r_addr);
 
-	data->fldata.pnfs_client = dserver.ds->ds_clp->cl_rpcclient;
-	data->fldata.ds_nfs_client = dserver.ds->ds_clp;
-	data->args.fh = dserver.fh;
+	data->fldata.ds_nfs_client = ds->ds_clp;
+	data->fldata.pnfs_client = ds->ds_clp->cl_rpcclient;
+	data->args.fh = nfs4_fl_select_ds_fh(flseg, idx);
 
 	/* Get the file offset on the dserver. Set the write offset to
 	 * this offset and save the original offset.
@@ -568,15 +558,12 @@ filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
 {
 	struct nfs4_filelayout_segment *nfslay;
 	struct nfs_write_data   *dsdata = NULL;
-	struct nfs4_pnfs_dserver dserver;
 	struct nfs4_pnfs_ds *ds;
 	struct nfs_page *req, *reqt;
 	struct list_head *pos, *tmp, head, head2;
 	loff_t file_offset, comp_offset;
 	size_t stripesz, cbytes;
-	int status;
 	enum pnfs_try_status trypnfs = PNFS_ATTEMPTED;
-	struct nfs4_file_layout_dsaddr *dsaddr;
 	u32 idx1, idx2;
 
 	nfslay = LSEG_LD_DATA(data->pdata.lseg);
@@ -593,9 +580,6 @@ filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
 	stripesz = filelayout_get_stripesize(layoutid);
 	dprintk("%s stripesize %Zd\n", __func__, stripesz);
 
-	dsaddr = container_of(data->pdata.lseg->deviceid,
-			      struct nfs4_file_layout_dsaddr, deviceid);
-
 	INIT_LIST_HEAD(&head);
 	INIT_LIST_HEAD(&head2);
 	list_add(&head, &data->pages);
@@ -609,19 +593,13 @@ filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
 		file_offset = (loff_t)req->wb_index << PAGE_CACHE_SHIFT;
 
 		/* Get dserver for the current page */
-		status = nfs4_pnfs_dserver_get(data->pdata.lseg,
-					       file_offset,
-					       req->wb_bytes,
-					       &dserver);
-		if (status) {
+		idx1 = nfs4_fl_calc_ds_index(data->pdata.lseg, file_offset);
+		ds = nfs4_fl_prepare_ds(data->pdata.lseg, idx1);
+		if (!ds) {
 			data->pdata.pnfs_error = -EIO;
 			goto err_rewind;
 		}
 
-		/* Get its index */
-		idx1 = filelayout_dserver_get_index(file_offset, dsaddr,
-						    nfslay);
-
 		/* Gather all pages going to the current data server by
 		 * comparing their indices.
 		 * XXX: This recalculates the indices unecessarily.
@@ -630,8 +608,8 @@ filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
 		list_for_each_safe(pos, tmp, &head) {
 			reqt = nfs_list_entry(pos);
 			comp_offset = (loff_t)reqt->wb_index << PAGE_CACHE_SHIFT;
-			idx2 = filelayout_dserver_get_index(comp_offset,
-							    dsaddr, nfslay);
+			idx2 = nfs4_fl_calc_ds_index(data->pdata.lseg,
+						     comp_offset);
 			if (idx1 == idx2) {
 				nfs_list_remove_request(reqt);
 				nfs_list_add_request(reqt, &head2);
@@ -655,10 +633,9 @@ filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
 		list_add(&dsdata->pages, &head2);
 		list_del_init(&head2);
 
-		ds = dserver.ds;
 		dsdata->fldata.pnfs_client = ds->ds_clp->cl_rpcclient;
 		dsdata->fldata.ds_nfs_client = ds->ds_clp;
-		dsdata->args.fh = dserver.fh;
+		dsdata->args.fh = nfs4_fl_select_ds_fh(nfslay, idx1);
 
 		dprintk("%s: Initiating commit: %Zu@%llu USE DS:\n",
 			__func__, cbytes, file_offset);
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index fbf307c..3697926 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -26,6 +26,9 @@
 
 #define FILE_MT(inode) ((struct filelayout_mount_type *) \
 			(NFS_SERVER(inode)->pnfs_mountid->mountid))
+#define FILE_DSADDR(lseg) (container_of(lseg->deviceid, \
+					struct nfs4_file_layout_dsaddr, \
+					deviceid))
 
 enum stripetype4 {
 	STRIPE_SPARSE = 1,
@@ -55,16 +58,6 @@ struct nfs4_pnfs_dev_hlist {
 	struct hlist_head	dev_list[NFS4_PNFS_DEV_HASH_SIZE];
 };
 
-/*
- * Used for I/O, Maps a stripe index to a layout file handle and a
- * multipath data server.
- */
-
-struct nfs4_pnfs_dserver {
-	struct nfs_fh        *fh;
-	struct nfs4_pnfs_ds	*ds;
-};
-
 struct nfs4_filelayout_segment {
 	u32 stripe_type;
 	u32 commit_through_mds;
@@ -87,18 +80,24 @@ struct filelayout_mount_type {
 	struct super_block *fl_sb;
 };
 
+static inline struct nfs_fh *
+nfs4_fl_select_ds_fh(struct nfs4_filelayout_segment *flseg, u32 idx)
+{
+	/* FRED - what about case == 0??? */
+	if (flseg->num_fh == 1)
+		return &flseg->fh_array[0];
+	else
+		return &flseg->fh_array[idx];
+}
+
 extern struct pnfs_client_operations *pnfs_callback_ops;
 
 extern void nfs4_fl_free_deviceid_callback(struct kref *);
 extern void print_ds(struct nfs4_pnfs_ds *ds);
 char *deviceid_fmt(const struct pnfs_deviceid *dev_id);
-int nfs4_pnfs_dserver_get(struct pnfs_layout_segment *lseg,
-			  loff_t offset,
-			  size_t count,
-			  struct nfs4_pnfs_dserver *dserver);
-u32 filelayout_dserver_get_index(loff_t offset,
-				 struct nfs4_file_layout_dsaddr *di,
-				 struct nfs4_filelayout_segment *layout);
+u32 nfs4_fl_calc_ds_index(struct pnfs_layout_segment *lseg, loff_t offset);
+struct nfs4_pnfs_ds *nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg,
+					u32 ds_idx);
 extern struct nfs4_file_layout_dsaddr *
 nfs4_pnfs_device_item_find(struct nfs_client *, struct pnfs_deviceid *dev_id);
 struct nfs4_file_layout_dsaddr *
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index f5eb5f1..404dd5f 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -554,90 +554,61 @@ nfs4_pnfs_device_item_find(struct nfs_client *clp, struct pnfs_deviceid *id)
 		container_of(d, struct nfs4_file_layout_dsaddr, deviceid);
 }
 
-/* Want res = ((offset / layout->stripe_unit) % dsaddr->stripe_count)
+/* Want res = (offset - layout->pattern_offset)/ layout->stripe_unit
  * Then: ((res + fsi) % dsaddr->stripe_count)
  */
-u32
-filelayout_dserver_get_index(loff_t offset,
-			     struct nfs4_file_layout_dsaddr *dsaddr,
-			     struct nfs4_filelayout_segment *layout)
+static inline u32
+_nfs4_fl_calc_j_index(loff_t offset,
+		      struct nfs4_file_layout_dsaddr *dsaddr,
+		      struct nfs4_filelayout_segment *layout)
 {
-	u64 tmp, tmp2;
+	u64 tmp;
 
-	tmp = offset;
+	tmp = offset - layout->pattern_offset;
 	do_div(tmp, layout->stripe_unit);
-	tmp2 = do_div(tmp, dsaddr->stripe_count) + layout->first_stripe_index;
-	return do_div(tmp2, dsaddr->stripe_count);
+	tmp += layout->first_stripe_index;
+	return do_div(tmp, dsaddr->stripe_count);
 }
 
-/* Retrieve the rpc client for a specified byte range
- * in 'inode' by filling in the contents of 'dserver'.
- */
-int
-nfs4_pnfs_dserver_get(struct pnfs_layout_segment *lseg,
-		      loff_t offset,
-		      size_t count,
-		      struct nfs4_pnfs_dserver *dserver)
+u32
+nfs4_fl_calc_ds_index(struct pnfs_layout_segment *lseg, loff_t offset)
 {
-	struct nfs4_filelayout_segment *layout = LSEG_LD_DATA(lseg);
-	struct inode *inode = PNFS_INODE(lseg->layout);
-	struct nfs_server *mds_srv = NFS_SERVER(inode);
+	struct nfs4_filelayout_segment *flseg = LSEG_LD_DATA(lseg);
 	struct nfs4_file_layout_dsaddr *dsaddr;
-	u64 tmp, tmp2;
-	u32 stripe_idx, end_idx, ds_idx;
-
-	if (!layout)
-		return 1;
-
-	dsaddr = container_of(lseg->deviceid, struct nfs4_file_layout_dsaddr,
-			      deviceid);
-
-	stripe_idx = filelayout_dserver_get_index(offset, dsaddr, layout);
-
-	/* For debugging, ensure entire requested range is in this dserver */
-	tmp = offset + count - 1;
-	do_div(tmp, layout->stripe_unit);
-	tmp2 = do_div(tmp, dsaddr->stripe_count) + layout->first_stripe_index;
-	end_idx = do_div(tmp2, dsaddr->stripe_count);
+	u32 j;
 
-	dprintk("%s: offset=%Lu, count=%Zu, si=%u, dsi=%u, "
-		"stripe_count=%u, stripe_unit=%u first_stripe_index %u\n",
-		__func__,
-		offset, count, stripe_idx, end_idx, dsaddr->stripe_count,
-		layout->stripe_unit, layout->first_stripe_index);
+	dsaddr = FILE_DSADDR(lseg);
+	j = _nfs4_fl_calc_j_index(offset, dsaddr, flseg);
+	return dsaddr->stripe_indices[j];
+}
 
-	BUG_ON(end_idx != stripe_idx);
-	BUG_ON(stripe_idx >= dsaddr->stripe_count);
+struct nfs4_pnfs_ds *
+nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
+{
+	struct nfs4_filelayout_segment *flseg = LSEG_LD_DATA(lseg);
+	struct nfs4_file_layout_dsaddr *dsaddr;
 
-	ds_idx = dsaddr->stripe_indices[stripe_idx];
+	dsaddr = FILE_DSADDR(lseg);
 	if (dsaddr->ds_list[ds_idx] == NULL) {
-		printk(KERN_ERR "%s: No data server for device id (%s)!! \n",
-			__func__, deviceid_fmt(&layout->dev_id));
-		return 1;
+		printk(KERN_ERR "%s: No data server for device id (%s)!!\n",
+			__func__, deviceid_fmt(&flseg->dev_id));
+		return NULL;
 	}
 
 	if (!dsaddr->ds_list[ds_idx]->ds_clp) {
 		int err;
 
-		err = nfs4_pnfs_ds_create(mds_srv, dsaddr->ds_list[ds_idx]);
+		err = nfs4_pnfs_ds_create(PNFS_NFS_SERVER(lseg->layout),
+					  dsaddr->ds_list[ds_idx]);
 		if (err) {
 			printk(KERN_ERR "%s nfs4_pnfs_ds_create error %d\n",
 			       __func__, err);
-			return 1;
+			return NULL;
 		}
 	}
-	dserver->ds = dsaddr->ds_list[ds_idx];
+	dprintk("%s: dev_id=%s, ds_idx=%u\n",
+		__func__, deviceid_fmt(&flseg->dev_id), ds_idx);
 
-	if (layout->num_fh == 1)
-		dserver->fh = &layout->fh_array[0];
-	else
-		dserver->fh = &layout->fh_array[ds_idx];
-
-	dprintk("%s: dev_id=%s, ip:port=%s, ds_idx=%u stripe_idx=%u, "
-		"offset=%llu, count=%Zu\n",
-		__func__, deviceid_fmt(&layout->dev_id),
-		dserver->ds->r_addr,
-		ds_idx, stripe_idx, offset, count);
-
-	return 0;
+	return dsaddr->ds_list[ds_idx];
 }
+
-- 
1.6.6.1


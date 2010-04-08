From: andros@netapp.com
Subject: [PATCH 03/14] SQUASHME pnfs_submit: remove multilist4 caching
Date: Thu,  8 Apr 2010 15:53:59 -0400
Message-ID: <1270756450-5570-4-git-send-email-andros@netapp.com>
References: <1270756450-5570-1-git-send-email-andros@netapp.com>
 <1270756450-5570-2-git-send-email-andros@netapp.com>
 <1270756450-5570-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47475 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933059Ab0DHTy4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Apr 2010 15:54:56 -0400
In-Reply-To: <1270756450-5570-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

We only support the use of the first multipath4 data server.

Remove the multipath structures from struct nfs4_file_layout_dsaddr
and regroup it's allocation to fit the new strucuture.

Refactor the associated debug print routines.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c    |   44 ++++---------
 fs/nfs/nfs4filelayout.h    |   12 +---
 fs/nfs/nfs4filelayoutdev.c |  151 +++++++++++++++++++-------------------------
 3 files changed, 81 insertions(+), 126 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index ffc3ef2..abdf691 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -252,7 +252,6 @@ filelayout_read_pagelist(struct pnfs_layout_type *layoutid,
 	struct inode *inode = PNFS_INODE(layoutid);
 	struct nfs4_filelayout_segment *flseg;
 	struct nfs4_pnfs_dserver dserver;
-	struct nfs4_pnfs_ds *ds;
 	int status;
 
 	dprintk("--> %s ino %lu nr_pages %d pgbase %u req %Zu@%llu\n",
@@ -271,14 +270,12 @@ filelayout_read_pagelist(struct pnfs_layout_type *layoutid,
 		return PNFS_NOT_ATTEMPTED;
 	}
 
-	ds = dserver.multipath->ds_list[0];
-
 	dprintk("%s USE DS:ip %x %s\n", __func__,
-		htonl(ds->ds_ip_addr), ds->r_addr);
+		htonl(dserver.ds->ds_ip_addr), dserver.ds->r_addr);
 
 	/* just try the first data server for the index..*/
-	data->fldata.pnfs_client = ds->ds_clp->cl_rpcclient;
-	data->fldata.ds_nfs_client = ds->ds_clp;
+	data->fldata.pnfs_client = dserver.ds->ds_clp->cl_rpcclient;
+	data->fldata.ds_nfs_client = dserver.ds->ds_clp;
 	data->args.fh = dserver.fh;
 
 	/* Now get the file offset on the dserver
@@ -300,16 +297,6 @@ filelayout_read_pagelist(struct pnfs_layout_type *layoutid,
 	return PNFS_ATTEMPTED;
 }
 
-void
-print_ds(struct nfs4_pnfs_ds *ds)
-{
-	dprintk("        ds->ds_ip_addr %x\n", htonl(ds->ds_ip_addr));
-	dprintk("        ds->ds_port %hu\n", ntohs(ds->ds_port));
-	dprintk("        ds->ds_clp %p\n", ds->ds_clp);
-	dprintk("        ds->ds_count %d\n", atomic_read(&ds->ds_count));
-	dprintk("        %s\n", ds->r_addr);
-}
-
 /* Perform async writes. */
 static enum pnfs_try_status
 filelayout_write_pagelist(struct pnfs_layout_type *layoutid,
@@ -324,7 +311,6 @@ filelayout_write_pagelist(struct pnfs_layout_type *layoutid,
 	struct inode *inode = PNFS_INODE(layoutid);
 	struct nfs4_filelayout_segment *flseg = LSEG_LD_DATA(data->pdata.lseg);
 	struct nfs4_pnfs_dserver dserver;
-	struct nfs4_pnfs_ds *ds;
 	int status;
 
 	dprintk("--> %s ino %lu nr_pages %d pgbase %u req %Zu@%llu sync %d\n",
@@ -342,16 +328,13 @@ filelayout_write_pagelist(struct pnfs_layout_type *layoutid,
 		return PNFS_NOT_ATTEMPTED;
 	}
 
-	/* use the first multipath data server */
-	ds = dserver.multipath->ds_list[0];
-
 	dprintk("%s ino %lu %Zu@%llu DS:%x:%hu %s\n",
 		__func__, inode->i_ino, count, offset,
-		htonl(ds->ds_ip_addr), ntohs(ds->ds_port),
-		ds->r_addr);
+		htonl(dserver.ds->ds_ip_addr), ntohs(dserver.ds->ds_port),
+		dserver.ds->r_addr);
 
-	data->fldata.pnfs_client = ds->ds_clp->cl_rpcclient;
-	data->fldata.ds_nfs_client = ds->ds_clp;
+	data->fldata.pnfs_client = dserver.ds->ds_clp->cl_rpcclient;
+	data->fldata.ds_nfs_client = dserver.ds->ds_clp;
 	data->args.fh = dserver.fh;
 
 	/* Get the file offset on the dserver. Set the write offset to
@@ -396,8 +379,8 @@ filelayout_free_layout(void *layoutid)
  * Make sure layout segment parameters are sane WRT the device.
  *
  * Notes:
- * 1) current code insists that # stripe index = # multipath devices which
- *    is wrong.
+ * 1) current code insists that # stripe index = # data servers in ds_list
+ *    which is wrong.
  * 2) pattern_offset is ignored and must == 0 which is wrong;
  * 3) the pattern_offset needs to be a mutliple of the stripe unit.
  * 4) stripe unit is multiple of page size
@@ -443,9 +426,9 @@ filelayout_check_layout(struct pnfs_layout_type *lo,
 	}
 
 	/* XXX only support SPARSE packing. Don't support use MDS open fh */
-	if (!(fl->num_fh == 1 || fl->num_fh == dsaddr->multipath_count)) {
-		dprintk("%s num_fh %u not equal to 1 or multipath_count %u\n",
-			__func__, fl->num_fh, dsaddr->multipath_count);
+	if (!(fl->num_fh == 1 || fl->num_fh == dsaddr->ds_num)) {
+		dprintk("%s num_fh %u not equal to 1 or ds_num %u\n",
+			__func__, fl->num_fh, dsaddr->ds_num);
 		goto out;
 	}
 
@@ -714,8 +697,7 @@ filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
 		list_add(&dsdata->pages, &head2);
 		list_del_init(&head2);
 
-		/* Just try the first multipath data server */
-		ds = dserver.multipath->ds_list[0];
+		ds = dserver.ds;
 		dsdata->fldata.pnfs_client = ds->ds_clp->cl_rpcclient;
 		dsdata->fldata.ds_nfs_client = ds->ds_clp;
 		dsdata->args.fh = dserver.fh;
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 3821989..0df1eaf 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -42,18 +42,13 @@ struct nfs4_pnfs_ds {
 	char r_addr[29];
 };
 
-struct nfs4_multipath {
-	int 			num_ds;
-	struct nfs4_pnfs_ds	*ds_list[NFS4_PNFS_MAX_MULTI_DS];
-};
-
 struct nfs4_file_layout_dsaddr {
 	struct hlist_node	hash_node;   /* nfs4_pnfs_dev_hlist dev_list */
 	struct pnfs_deviceid	dev_id;
 	u32 			stripe_count;
 	u8			*stripe_indices;
-	u32			multipath_count;
-	struct nfs4_multipath	*multipath_list;
+	u32			ds_num;
+	struct nfs4_pnfs_ds	*ds_list[1];
 };
 
 struct nfs4_pnfs_dev_hlist {
@@ -69,7 +64,7 @@ struct nfs4_pnfs_dev_hlist {
 
 struct nfs4_pnfs_dserver {
 	struct nfs_fh        *fh;
-	struct nfs4_multipath *multipath;
+	struct nfs4_pnfs_ds	*ds;
 };
 
 struct nfs4_filelayout_segment {
@@ -97,6 +92,7 @@ struct filelayout_mount_type {
 
 extern struct pnfs_client_operations *pnfs_callback_ops;
 
+extern void print_ds(struct nfs4_pnfs_ds *ds);
 char *deviceid_fmt(const struct pnfs_deviceid *dev_id);
 int  nfs4_pnfs_devlist_init(struct nfs4_pnfs_dev_hlist *hlist);
 void nfs4_pnfs_devlist_destroy(struct nfs4_pnfs_dev_hlist *hlist);
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index ebb9845..ea25bd2 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -53,43 +53,31 @@
 #define NFSDBG_FACILITY		NFSDBG_PNFS_LD
 
 void
-print_ds_list(struct nfs4_multipath *multipath)
+print_ds(struct nfs4_pnfs_ds *ds)
 {
-	struct nfs4_pnfs_ds *ds;
-	int i;
-
-	ds = multipath->ds_list[0];
 	if (ds == NULL) {
 		dprintk("%s NULL device \n", __func__);
 		return;
 	}
-	for (i = 0; i < multipath->num_ds; i++) {
-		dprintk("        ip_addr %x\n", ntohl(ds->ds_ip_addr));
-		dprintk("        port %hu\n", ntohs(ds->ds_port));
-		dprintk("        client %p\n", ds->ds_clp);
-		dprintk("        ref count %d\n", atomic_read(&ds->ds_count));
-		if (ds->ds_clp)
-			dprintk("        cl_exchange_flags %x\n",
+	dprintk("        ip_addr %x\n", ntohl(ds->ds_ip_addr));
+	dprintk("        port %hu\n", ntohs(ds->ds_port));
+	dprintk("        client %p\n", ds->ds_clp);
+	dprintk("        ref count %d\n", atomic_read(&ds->ds_count));
+	if (ds->ds_clp)
+		dprintk("        cl_exchange_flags %x\n",
 					    ds->ds_clp->cl_exchange_flags);
-		dprintk("        ip:port %s\n", ds->r_addr);
-		ds++;
-	}
+	dprintk("        ip:port %s\n", ds->r_addr);
 }
 
 void
-print_multipath_list(struct nfs4_file_layout_dsaddr *dsaddr)
+print_ds_list(struct nfs4_file_layout_dsaddr *dsaddr)
 {
-	struct nfs4_multipath *multipath;
 	int i;
 
-	multipath = &dsaddr->multipath_list[0];
-	dprintk("%s dsaddr->multipath_count %d\n", __func__,
-		dsaddr->multipath_count);
-	for (i = 0; i < dsaddr->multipath_count; i++) {
-		dprintk("        num_ds %d\n", multipath->num_ds);
-		print_ds_list(multipath);
-		multipath++;
-	}
+	dprintk("%s dsaddr->ds_num %d\n", __func__,
+		dsaddr->ds_num);
+	for (i = 0; i < dsaddr->ds_num; i++)
+		print_ds(dsaddr->ds_list[i]);
 }
 
 /* Debugging function assuming a 64bit major/minor split of the deviceid */
@@ -174,9 +162,9 @@ _device_add(struct nfs4_pnfs_dev_hlist *hlist,
 {
 	unsigned long      hash;
 
-	dprintk("_device_add: dev_id=%s\nmultipath_list:\n",
+	dprintk("_device_add: dev_id=%s ds_list:\n",
 		deviceid_fmt(&dsaddr->dev_id));
-	print_multipath_list(dsaddr);
+	print_ds_list(dsaddr);
 
 	hash = _deviceid_hash(&dsaddr->dev_id);
 	hlist_add_head(&dsaddr->hash_node, &hlist->dev_list[hash]);
@@ -306,34 +294,29 @@ static void
 nfs4_pnfs_device_destroy(struct nfs4_file_layout_dsaddr *dsaddr,
 			 struct nfs4_pnfs_dev_hlist *hlist)
 {
-	struct nfs4_multipath *multipath;
 	struct nfs4_pnfs_ds *ds;
 	HLIST_HEAD(release);
-	int i, j;
+	int i;
 
 	if (!dsaddr)
 		return;
 
 	dprintk("%s: dev_id=%s\ndev_list:\n", __func__,
 		deviceid_fmt(&dsaddr->dev_id));
-	print_multipath_list(dsaddr);
+	print_ds_list(dsaddr);
 
 	write_lock(&hlist->dev_lock);
 	hlist_del_init(&dsaddr->hash_node);
 
-	multipath = &dsaddr->multipath_list[0];
-	for (i = 0; i < dsaddr->multipath_count; i++) {
-		for (j = 0; j < multipath->num_ds; j++) {
-			ds = multipath->ds_list[j];
-			if (ds != NULL) {
-				/* if we are last user - move to release list */
-				if (atomic_dec_and_test(&ds->ds_count)) {
-					hlist_del_init(&ds->ds_node);
-					hlist_add_head(&ds->ds_node, &release);
-				}
+	for (i = 0; i < dsaddr->ds_num; i++) {
+		ds = dsaddr->ds_list[i];
+		if (ds != NULL) {
+			/* if we are last user - move to release list */
+			if (atomic_dec_and_test(&ds->ds_count)) {
+				hlist_del_init(&ds->ds_node);
+				hlist_add_head(&ds->ds_node, &release);
 			}
 		}
-		multipath++;
 	}
 	write_unlock(&hlist->dev_lock);
 	while (!hlist_empty(&release)) {
@@ -341,8 +324,6 @@ nfs4_pnfs_device_destroy(struct nfs4_file_layout_dsaddr *dsaddr,
 		hlist_del(&ds->ds_node);
 		destroy_ds(ds);
 	}
-	kfree(dsaddr->multipath_list);
-	kfree(dsaddr->stripe_indices);
 	kfree(dsaddr);
 }
 
@@ -540,47 +521,44 @@ static struct nfs4_file_layout_dsaddr*
 decode_device(struct filelayout_mount_type *mt, struct pnfs_device *pdev)
 {
 	int i, dummy;
+	u32 cnt, num;
 	u8 *indexp;
 	uint32_t *p = (u32 *)pdev->area, *indicesp;
 	struct nfs4_file_layout_dsaddr *dsaddr;
-	struct nfs4_multipath *multipath;
-
-	dsaddr = kzalloc(sizeof(*dsaddr), GFP_KERNEL);
-	if (!dsaddr)
-		goto out_err;
 
 	/* Get the stripe count (number of stripe index) */
-	READ32(dsaddr->stripe_count);
-	dprintk("%s stripe count  %d\n", __func__, dsaddr->stripe_count);
-	if (dsaddr->stripe_count > NFS4_PNFS_MAX_STRIPE_CNT) {
+	READ32(cnt);
+	dprintk("%s stripe count  %d\n", __func__, cnt);
+	if (cnt > NFS4_PNFS_MAX_STRIPE_CNT) {
 		printk(KERN_WARNING "%s: stripe count %d greater than "
 		       "supported maximum %d\n", __func__,
-			dsaddr->stripe_count, NFS4_PNFS_MAX_STRIPE_CNT);
-		dsaddr->stripe_count = 0;
-		goto out_err_free;
+			cnt, NFS4_PNFS_MAX_STRIPE_CNT);
+		goto out_err;
 	}
 
 	/* Check the multipath list count */
 	indicesp = p;
-	p += XDR_QUADLEN(dsaddr->stripe_count << 2);
-	READ32(dsaddr->multipath_count);
-	dprintk("%s multipath_count %u\n", __func__, dsaddr->multipath_count);
-	if (dsaddr->multipath_count > NFS4_PNFS_MAX_MULTI_CNT) {
+	p += XDR_QUADLEN(cnt << 2);
+	READ32(num);
+	dprintk("%s ds_num %u\n", __func__, num);
+	if (num > NFS4_PNFS_MAX_MULTI_CNT) {
 		printk(KERN_WARNING "%s: multipath count %d greater than "
 			"supported maximum %d\n", __func__,
-			dsaddr->multipath_count, NFS4_PNFS_MAX_MULTI_CNT);
-		dsaddr->multipath_count = 0;
-		goto out_err_free;
+			num, NFS4_PNFS_MAX_MULTI_CNT);
+		goto out_err;
 	}
-	dsaddr->stripe_indices = kzalloc(sizeof(u8) * dsaddr->stripe_count,
-					 GFP_KERNEL);
+	dsaddr = kzalloc(sizeof(*dsaddr) +
+			(sizeof(struct nfs4_pnfs_ds *) * (num - 1)),
+			GFP_KERNEL);
+	if (!dsaddr)
+		goto out_err;
+
+	dsaddr->stripe_indices = kzalloc(sizeof(u8) * cnt, GFP_KERNEL);
 	if (!dsaddr->stripe_indices)
 		goto out_err_free;
 
-	dsaddr->multipath_list = kzalloc(sizeof(struct nfs4_multipath) *
-					 dsaddr->multipath_count, GFP_KERNEL);
-	if (!dsaddr->multipath_list)
-		goto out_err_free;
+	dsaddr->stripe_count = cnt;
+	dsaddr->ds_num = num;
 
 	memcpy(&dsaddr->dev_id, &pdev->dev_id, NFS4_PNFS_DEVICEID4_SIZE);
 
@@ -595,19 +573,22 @@ decode_device(struct filelayout_mount_type *mt, struct pnfs_device *pdev)
 	/* Skip already read multipath list count */
 	p++;
 
-	multipath = &dsaddr->multipath_list[0];
-	for (i = 0; i < dsaddr->multipath_count; i++) {
+	for (i = 0; i < dsaddr->ds_num; i++) {
 		int j;
 
-		READ32(multipath->num_ds);
-		if (multipath->num_ds > NFS4_PNFS_MAX_MULTI_DS) {
+		READ32(dummy); /* multipath count */
+		if (dummy > 1) {
 			printk(KERN_WARNING
 			       "%s: Multipath count %d not supported, "
-			       "skipping all greater than %d\n", __func__,
-				multipath->num_ds, NFS4_PNFS_MAX_MULTI_DS);
+			       "skipping all greater than 1\n", __func__,
+				dummy);
 		}
-		for (j = 0; j < multipath->num_ds; j++) {
-			if (j >= NFS4_PNFS_MAX_MULTI_DS) {
+		for (j = 0; j < dummy; j++) {
+			if (j == 0) {
+				dsaddr->ds_list[i] = decode_and_add_ds(&p, mt);
+				if (dsaddr->ds_list[i] == NULL)
+					goto out_err_free;
+			} else {
 				u32 len;
 				/* skip extra multipath */
 				READ32(len);
@@ -616,11 +597,7 @@ decode_device(struct filelayout_mount_type *mt, struct pnfs_device *pdev)
 				p += XDR_QUADLEN(len);
 				continue;
 			}
-			multipath->ds_list[j] = decode_and_add_ds(&p, mt);
-			if (multipath->ds_list[j] == NULL)
-				goto out_err_free;
 		}
-		multipath++;
 	}
 	return dsaddr;
 
@@ -771,7 +748,7 @@ nfs4_pnfs_dserver_get(struct pnfs_layout_segment *lseg,
 	struct inode *inode = PNFS_INODE(lseg->layout);
 	struct nfs4_file_layout_dsaddr *dsaddr;
 	u64 tmp, tmp2;
-	u32 stripe_idx, end_idx, multipath_idx;
+	u32 stripe_idx, end_idx, ds_idx;
 
 	if (!layout)
 		return 1;
@@ -798,10 +775,10 @@ nfs4_pnfs_dserver_get(struct pnfs_layout_segment *lseg,
 	BUG_ON(end_idx != stripe_idx);
 	BUG_ON(stripe_idx >= dsaddr->stripe_count);
 
-	multipath_idx = dsaddr->stripe_indices[stripe_idx];
-	dserver->multipath = &dsaddr->multipath_list[multipath_idx];
+	ds_idx = dsaddr->stripe_indices[stripe_idx];
+	dserver->ds = dsaddr->ds_list[ds_idx];
 
-	if (dserver->multipath == NULL) {
+	if (dserver->ds == NULL) {
 		printk(KERN_ERR "%s: No data server for device id (%s)!! \n",
 			__func__, deviceid_fmt(&layout->dev_id));
 		return 1;
@@ -809,13 +786,13 @@ nfs4_pnfs_dserver_get(struct pnfs_layout_segment *lseg,
 	if (layout->num_fh == 1)
 		dserver->fh = &layout->fh_array[0];
 	else
-		dserver->fh = &layout->fh_array[multipath_idx];
+		dserver->fh = &layout->fh_array[ds_idx];
 
-	dprintk("%s: dev_id=%s, ip:port=%s, multipath_idx=%u stripe_idx=%u, "
+	dprintk("%s: dev_id=%s, ip:port=%s, ds_idx=%u stripe_idx=%u, "
 		"offset=%llu, count=%Zu\n",
 		__func__, deviceid_fmt(&layout->dev_id),
-		dserver->multipath->ds_list[0]->r_addr,
-		multipath_idx, stripe_idx, offset, count);
+		dserver->ds->r_addr,
+		ds_idx, stripe_idx, offset, count);
 
 	return 0;
 }
-- 
1.6.6


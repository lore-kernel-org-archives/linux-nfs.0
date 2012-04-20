Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:28519 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757419Ab2DTSsJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 14:48:09 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH v3 06/25] NFS4.1: Add lseg to struct nfs4_fl_commit_bucket
Date: Fri, 20 Apr 2012 14:47:38 -0400
Message-Id: <1334947677-28864-7-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
References: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also create a commit_info structure to hold the bucket array and push
it up from the lseg to the layout where it really belongs.

While we are at it, fix a refcounting bug due to an (incorrect)
implicit assumption that filelayout_scan_ds_commit_list always
completely emptied the src list.

This clarifies refcounting, removes the ugly find_only_write_lseg
functions, and pushes the file layout commit code along on the path to
supporting multiple lsegs.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |  216 +++++++++++++++++++++++++++--------------------
 fs/nfs/nfs4filelayout.h |   20 ++++-
 2 files changed, 144 insertions(+), 92 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 5acfd9e..15aeba2 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -650,10 +650,66 @@ filelayout_free_lseg(struct pnfs_layout_segment *lseg)
 
 	dprintk("--> %s\n", __func__);
 	nfs4_fl_put_deviceid(fl->dsaddr);
-	kfree(fl->commit_buckets);
+	/* This assumes a single RW lseg */
+	if (lseg->pls_range.iomode == IOMODE_RW) {
+		struct nfs4_filelayout *flo;
+
+		flo = FILELAYOUT_FROM_HDR(lseg->pls_layout);
+		flo->commit_info.nbuckets = 0;
+		kfree(flo->commit_info.buckets);
+		flo->commit_info.buckets = NULL;
+	}
 	_filelayout_free_lseg(fl);
 }
 
+static int
+filelayout_alloc_commit_info(struct pnfs_layout_segment *lseg,
+			     gfp_t gfp_flags)
+{
+	struct nfs4_filelayout_segment *fl = FILELAYOUT_LSEG(lseg);
+	struct nfs4_filelayout *flo = FILELAYOUT_FROM_HDR(lseg->pls_layout);
+
+	struct nfs4_fl_commit_bucket *buckets;
+	int size;
+
+	if (fl->commit_through_mds)
+		return 0;
+	if (flo->commit_info.nbuckets != 0) {
+		/* This assumes there is only one IOMODE_RW lseg.  What
+		 * we really want to do is have a layout_hdr level
+		 * dictionary of <multipath_list4, fh> keys, each
+		 * associated with a struct list_head, populated by calls
+		 * to filelayout_write_pagelist().
+		 * */
+		return 0;
+	}
+
+	size = (fl->stripe_type == STRIPE_SPARSE) ?
+		fl->dsaddr->ds_num : fl->dsaddr->stripe_count;
+
+	buckets = kcalloc(size, sizeof(struct nfs4_fl_commit_bucket),
+			  gfp_flags);
+	if (!buckets)
+		return -ENOMEM;
+	else {
+		int i;
+
+		spin_lock(&lseg->pls_layout->plh_inode->i_lock);
+		if (flo->commit_info.nbuckets != 0)
+			kfree(buckets);
+		else {
+			flo->commit_info.buckets = buckets;
+			flo->commit_info.nbuckets = size;
+			for (i = 0; i < size; i++) {
+				INIT_LIST_HEAD(&buckets[i].written);
+				INIT_LIST_HEAD(&buckets[i].committing);
+			}
+		}
+		spin_unlock(&lseg->pls_layout->plh_inode->i_lock);
+		return 0;
+	}
+}
+
 static struct pnfs_layout_segment *
 filelayout_alloc_lseg(struct pnfs_layout_hdr *layoutid,
 		      struct nfs4_layoutget_res *lgr,
@@ -673,29 +729,6 @@ filelayout_alloc_lseg(struct pnfs_layout_hdr *layoutid,
 		_filelayout_free_lseg(fl);
 		return NULL;
 	}
-
-	/* This assumes there is only one IOMODE_RW lseg.  What
-	 * we really want to do is have a layout_hdr level
-	 * dictionary of <multipath_list4, fh> keys, each
-	 * associated with a struct list_head, populated by calls
-	 * to filelayout_write_pagelist().
-	 * */
-	if ((!fl->commit_through_mds) && (lgr->range.iomode == IOMODE_RW)) {
-		int i;
-		int size = (fl->stripe_type == STRIPE_SPARSE) ?
-			fl->dsaddr->ds_num : fl->dsaddr->stripe_count;
-
-		fl->commit_buckets = kcalloc(size, sizeof(struct nfs4_fl_commit_bucket), gfp_flags);
-		if (!fl->commit_buckets) {
-			filelayout_free_lseg(&fl->generic_hdr);
-			return NULL;
-		}
-		fl->number_of_buckets = size;
-		for (i = 0; i < size; i++) {
-			INIT_LIST_HEAD(&fl->commit_buckets[i].written);
-			INIT_LIST_HEAD(&fl->commit_buckets[i].committing);
-		}
-	}
 	return &fl->generic_hdr;
 }
 
@@ -747,6 +780,8 @@ static void
 filelayout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 			 struct nfs_page *req)
 {
+	int status;
+
 	BUG_ON(pgio->pg_lseg != NULL);
 
 	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
@@ -757,7 +792,16 @@ filelayout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 					   GFP_NOFS);
 	/* If no lseg, fall back to write through mds */
 	if (pgio->pg_lseg == NULL)
-		nfs_pageio_reset_write_mds(pgio);
+		goto out_mds;
+	status = filelayout_alloc_commit_info(pgio->pg_lseg, GFP_NOFS);
+	if (status < 0) {
+		put_lseg(pgio->pg_lseg);
+		pgio->pg_lseg = NULL;
+		goto out_mds;
+	}
+	return;
+out_mds:
+	nfs_pageio_reset_write_mds(pgio);
 }
 
 static const struct nfs_pageio_ops filelayout_pg_read_ops = {
@@ -793,17 +837,13 @@ filelayout_clear_request_commit(struct nfs_page *req)
 	if (!test_and_clear_bit(PG_COMMIT_TO_DS, &req->wb_flags))
 		goto out;
 	if (list_is_singular(&req->wb_list)) {
-		struct pnfs_layout_segment *lseg;
+		struct nfs4_fl_commit_bucket *bucket;
 
-		/* From here we can find the bucket, but for the moment,
-		 * since there is only one relevant lseg...
-		 */
-		list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list) {
-			if (lseg->pls_range.iomode == IOMODE_RW) {
-				freeme = lseg;
-				break;
-			}
-		}
+		bucket = list_first_entry(&req->wb_list,
+					  struct nfs4_fl_commit_bucket,
+					  written);
+		freeme = bucket->wlseg;
+		bucket->wlseg = NULL;
 	}
 out:
 	nfs_request_remove_commit_list(req);
@@ -818,6 +858,7 @@ filelayout_choose_commit_list(struct nfs_page *req,
 	struct nfs4_filelayout_segment *fl = FILELAYOUT_LSEG(lseg);
 	u32 i, j;
 	struct list_head *list;
+	struct nfs4_fl_commit_bucket *buckets;
 
 	if (fl->commit_through_mds)
 		return &NFS_I(req->wb_context->dentry->d_inode)->commit_list;
@@ -831,15 +872,16 @@ filelayout_choose_commit_list(struct nfs_page *req,
 	j = nfs4_fl_calc_j_index(lseg,
 				 (loff_t)req->wb_index << PAGE_CACHE_SHIFT);
 	i = select_bucket_index(fl, j);
-	list = &fl->commit_buckets[i].written;
+	buckets = FILELAYOUT_FROM_HDR(lseg->pls_layout)->commit_info.buckets;
+	list = &buckets[i].written;
 	if (list_empty(list)) {
 		/* Non-empty buckets hold a reference on the lseg.  That ref
 		 * is normally transferred to the COMMIT call and released
 		 * there.  It could also be released if the last req is pulled
 		 * off due to a rewrite, in which case it will be done in
-		 * filelayout_remove_commit_req
+		 * filelayout_clear_request_commit
 		 */
-		get_lseg(lseg);
+		buckets[i].wlseg = get_lseg(lseg);
 	}
 	set_bit(PG_COMMIT_TO_DS, &req->wb_flags);
 	return list;
@@ -908,32 +950,6 @@ static int filelayout_initiate_commit(struct nfs_write_data *data, int how)
 				   &filelayout_commit_call_ops, how);
 }
 
-/*
- * This is only useful while we are using whole file layouts.
- */
-static struct pnfs_layout_segment *
-find_only_write_lseg_locked(struct inode *inode)
-{
-	struct pnfs_layout_segment *lseg;
-
-	list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list)
-		if (lseg->pls_range.iomode == IOMODE_RW)
-			return lseg;
-	return NULL;
-}
-
-static struct pnfs_layout_segment *find_only_write_lseg(struct inode *inode)
-{
-	struct pnfs_layout_segment *rv;
-
-	spin_lock(&inode->i_lock);
-	rv = find_only_write_lseg_locked(inode);
-	if (rv)
-		get_lseg(rv);
-	spin_unlock(&inode->i_lock);
-	return rv;
-}
-
 static int
 filelayout_scan_ds_commit_list(struct nfs4_fl_commit_bucket *bucket, int max,
 		spinlock_t *lock)
@@ -955,6 +971,13 @@ filelayout_scan_ds_commit_list(struct nfs4_fl_commit_bucket *bucket, int max,
 		if (ret == max)
 			break;
 	}
+	if (ret) {
+		bucket->clseg = bucket->wlseg;
+		if (list_empty(src))
+			bucket->wlseg = NULL;
+		else
+			get_lseg(bucket->clseg);
+	}
 	return ret;
 }
 
@@ -964,18 +987,14 @@ filelayout_scan_ds_commit_list(struct nfs4_fl_commit_bucket *bucket, int max,
 static int filelayout_scan_commit_lists(struct inode *inode, int max,
 		spinlock_t *lock)
 {
-	struct pnfs_layout_segment *lseg;
-	struct nfs4_filelayout_segment *fl;
+	struct nfs4_fl_commit_info *fl_cinfo;
 	int i, rv = 0, cnt;
 
-	lseg = find_only_write_lseg_locked(inode);
-	if (!lseg)
-		goto out_done;
-	fl = FILELAYOUT_LSEG(lseg);
-	if (fl->commit_through_mds)
+	fl_cinfo = &FILELAYOUT_FROM_HDR(NFS_I(inode)->layout)->commit_info;
+	if (fl_cinfo->nbuckets == 0)
 		goto out_done;
-	for (i = 0; i < fl->number_of_buckets && max != 0; i++) {
-		cnt = filelayout_scan_ds_commit_list(&fl->commit_buckets[i],
+	for (i = 0; i < fl_cinfo->nbuckets && max != 0; i++) {
+		cnt = filelayout_scan_ds_commit_list(&fl_cinfo->buckets[i],
 				max, lock);
 		max -= cnt;
 		rv += cnt;
@@ -987,38 +1006,35 @@ out_done:
 static unsigned int
 alloc_ds_commits(struct inode *inode, struct list_head *list)
 {
-	struct pnfs_layout_segment *lseg;
-	struct nfs4_filelayout_segment *fl;
+	struct nfs4_fl_commit_info *fl_cinfo;
+	struct nfs4_fl_commit_bucket *bucket;
 	struct nfs_write_data *data;
 	int i, j;
 	unsigned int nreq = 0;
 
-	/* Won't need this when non-whole file layout segments are supported
-	 * instead we will use a pnfs_layout_hdr structure */
-	lseg = find_only_write_lseg(inode);
-	if (!lseg)
-		return 0;
-	fl = FILELAYOUT_LSEG(lseg);
-	for (i = 0; i < fl->number_of_buckets; i++) {
-		if (list_empty(&fl->commit_buckets[i].committing))
+	fl_cinfo = &FILELAYOUT_FROM_HDR(NFS_I(inode)->layout)->commit_info;
+	bucket = fl_cinfo->buckets;
+	for (i = 0; i < fl_cinfo->nbuckets; i++, bucket++) {
+		if (list_empty(&bucket->committing))
 			continue;
 		data = nfs_commitdata_alloc();
 		if (!data)
 			break;
 		data->ds_commit_index = i;
-		data->lseg = lseg;
+		data->lseg = bucket->clseg;
+		bucket->clseg = NULL;
 		list_add(&data->pages, list);
 		nreq++;
 	}
 
 	/* Clean up on error */
-	for (j = i; j < fl->number_of_buckets; j++) {
-		if (list_empty(&fl->commit_buckets[i].committing))
+	for (j = i; j < fl_cinfo->nbuckets; j++, bucket++) {
+		if (list_empty(&bucket->committing))
 			continue;
-		nfs_retry_commit(&fl->commit_buckets[i].committing, lseg);
-		put_lseg(lseg);  /* associated with emptying bucket */
+		nfs_retry_commit(&bucket->committing, bucket->clseg);
+		put_lseg(bucket->clseg);
+		bucket->clseg = NULL;
 	}
-	put_lseg(lseg);
 	/* Caller will clean up entries put on list */
 	return nreq;
 }
@@ -1058,7 +1074,10 @@ filelayout_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
 			nfs_initiate_commit(data, NFS_CLIENT(inode),
 					    data->mds_ops, how);
 		} else {
-			nfs_init_commit(data, &FILELAYOUT_LSEG(data->lseg)->commit_buckets[data->ds_commit_index].committing, data->lseg);
+			struct nfs4_fl_commit_info *fl_cinfo;
+
+			fl_cinfo = &FILELAYOUT_FROM_HDR(data->lseg->pls_layout)->commit_info;
+			nfs_init_commit(data, &fl_cinfo->buckets[data->ds_commit_index].committing, data->lseg);
 			filelayout_initiate_commit(data, how);
 		}
 	}
@@ -1072,10 +1091,27 @@ filelayout_free_deveiceid_node(struct nfs4_deviceid_node *d)
 	nfs4_fl_free_deviceid(container_of(d, struct nfs4_file_layout_dsaddr, id_node));
 }
 
+static struct pnfs_layout_hdr *
+filelayout_alloc_layout_hdr(struct inode *inode, gfp_t gfp_flags)
+{
+	struct nfs4_filelayout *flo;
+
+	flo = kzalloc(sizeof(*flo), gfp_flags);
+	return &flo->generic_hdr;
+}
+
+static void
+filelayout_free_layout_hdr(struct pnfs_layout_hdr *lo)
+{
+	kfree(FILELAYOUT_FROM_HDR(lo));
+}
+
 static struct pnfs_layoutdriver_type filelayout_type = {
 	.id			= LAYOUT_NFSV4_1_FILES,
 	.name			= "LAYOUT_NFSV4_1_FILES",
 	.owner			= THIS_MODULE,
+	.alloc_layout_hdr	= filelayout_alloc_layout_hdr,
+	.free_layout_hdr	= filelayout_free_layout_hdr,
 	.alloc_lseg		= filelayout_alloc_lseg,
 	.free_lseg		= filelayout_free_lseg,
 	.pg_read_ops		= &filelayout_pg_read_ops,
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 21190bb..333a3ac 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -77,6 +77,13 @@ struct nfs4_file_layout_dsaddr {
 struct nfs4_fl_commit_bucket {
 	struct list_head written;
 	struct list_head committing;
+	struct pnfs_layout_segment *wlseg;
+	struct pnfs_layout_segment *clseg;
+};
+
+struct nfs4_fl_commit_info {
+	int nbuckets;
+	struct nfs4_fl_commit_bucket *buckets;
 };
 
 struct nfs4_filelayout_segment {
@@ -89,10 +96,19 @@ struct nfs4_filelayout_segment {
 	struct nfs4_file_layout_dsaddr *dsaddr; /* Point to GETDEVINFO data */
 	unsigned int num_fh;
 	struct nfs_fh **fh_array;
-	struct nfs4_fl_commit_bucket *commit_buckets; /* Sort commits to ds */
-	int number_of_buckets;
 };
 
+struct nfs4_filelayout {
+	struct pnfs_layout_hdr generic_hdr;
+	struct nfs4_fl_commit_info commit_info;
+};
+
+static inline struct nfs4_filelayout *
+FILELAYOUT_FROM_HDR(struct pnfs_layout_hdr *lo)
+{
+	return container_of(lo, struct nfs4_filelayout, generic_hdr);
+}
+
 static inline struct nfs4_filelayout_segment *
 FILELAYOUT_LSEG(struct pnfs_layout_segment *lseg)
 {
-- 
1.7.2.1


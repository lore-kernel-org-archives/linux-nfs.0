Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:62895 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754809Ab2CVFj6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Mar 2012 01:39:58 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/2] NFS4.1: Add lseg to struct nfs4_fl_commit_bucket
Date: Thu, 22 Mar 2012 01:39:35 -0400
Message-Id: <1332394775-31783-2-git-send-email-iisaman@netapp.com>
In-Reply-To: <1332394775-31783-1-git-send-email-iisaman@netapp.com>
References: <1332394775-31783-1-git-send-email-iisaman@netapp.com>
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
 fs/nfs/nfs4filelayout.c |  148 ++++++++++++++++++++++++----------------------
 fs/nfs/nfs4filelayout.h |   20 ++++++-
 2 files changed, 95 insertions(+), 73 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index a8623bb..4ce0a62 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -650,7 +650,14 @@ filelayout_free_lseg(struct pnfs_layout_segment *lseg)
 
 	dprintk("--> %s\n", __func__);
 	nfs4_fl_put_deviceid(fl->dsaddr);
-	kfree(fl->commit_buckets);
+	/* This assumes a single RW lseg */
+	if (lseg->pls_range.iomode == IOMODE_RW) {
+		struct nfs4_filelayout *flo;
+
+		flo = FILELAYOUT_FROM_HDR(lseg->pls_layout);
+		kfree(flo->commit_info);
+		flo->commit_info = NULL;
+	}
 	_filelayout_free_lseg(fl);
 }
 
@@ -681,19 +688,27 @@ filelayout_alloc_lseg(struct pnfs_layout_hdr *layoutid,
 	 * to filelayout_write_pagelist().
 	 * */
 	if ((!fl->commit_through_mds) && (lgr->range.iomode == IOMODE_RW)) {
+		struct nfs4_filelayout *flo = FILELAYOUT_FROM_HDR(layoutid);
 		int i;
 		int size = (fl->stripe_type == STRIPE_SPARSE) ?
 			fl->dsaddr->ds_num : fl->dsaddr->stripe_count;
 
-		fl->commit_buckets = kcalloc(size, sizeof(struct nfs4_fl_commit_bucket), gfp_flags);
-		if (!fl->commit_buckets) {
+		if (flo->commit_info) {
+			/* Shouldn't happen if only one IOMODE_RW lseg */
+			_filelayout_free_lseg(fl);
+			return NULL;
+		}
+		flo->commit_info = kzalloc(sizeof(*flo->commit_info) +
+				    size * sizeof(struct nfs4_fl_commit_bucket),
+				    gfp_flags);
+		if (!flo->commit_info) {
 			filelayout_free_lseg(&fl->generic_hdr);
 			return NULL;
 		}
-		fl->number_of_buckets = size;
+		flo->commit_info->nbuckets = size;
 		for (i = 0; i < size; i++) {
-			INIT_LIST_HEAD(&fl->commit_buckets[i].written);
-			INIT_LIST_HEAD(&fl->commit_buckets[i].committing);
+			INIT_LIST_HEAD(&flo->commit_info->buckets[i].written);
+			INIT_LIST_HEAD(&flo->commit_info->buckets[i].committing);
 		}
 	}
 	return &fl->generic_hdr;
@@ -793,17 +808,13 @@ filelayout_clear_request_commit(struct nfs_page *req)
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
@@ -818,6 +829,7 @@ filelayout_choose_commit_list(struct nfs_page *req,
 	struct nfs4_filelayout_segment *fl = FILELAYOUT_LSEG(lseg);
 	u32 i, j;
 	struct list_head *list;
+	struct nfs4_fl_commit_info *fl_cinfo;
 
 	if (fl->commit_through_mds)
 		return &NFS_I(req->wb_context->dentry->d_inode)->commit_list;
@@ -831,15 +843,16 @@ filelayout_choose_commit_list(struct nfs_page *req,
 	j = nfs4_fl_calc_j_index(lseg,
 				 (loff_t)req->wb_index << PAGE_CACHE_SHIFT);
 	i = select_bucket_index(fl, j);
-	list = &fl->commit_buckets[i].written;
+	fl_cinfo = FILELAYOUT_FROM_HDR(lseg->pls_layout)->commit_info;
+	list = &fl_cinfo->buckets[i].written;
 	if (list_empty(list)) {
 		/* Non-empty buckets hold a reference on the lseg.  That ref
 		 * is normally transferred to the COMMIT call and released
 		 * there.  It could also be released if the last req is pulled
 		 * off due to a rewrite, in which case it will be done in
-		 * filelayout_remove_commit_req
+		 * filelayout_clear_request_commit
 		 */
-		get_lseg(lseg);
+		fl_cinfo->buckets[i].wlseg = get_lseg(lseg);
 	}
 	set_bit(PG_COMMIT_TO_DS, &req->wb_flags);
 	return list;
@@ -908,32 +921,6 @@ static int filelayout_initiate_commit(struct nfs_write_data *data, int how)
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
@@ -955,6 +942,13 @@ filelayout_scan_ds_commit_list(struct nfs4_fl_commit_bucket *bucket, int max,
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
 
@@ -964,18 +958,14 @@ filelayout_scan_ds_commit_list(struct nfs4_fl_commit_bucket *bucket, int max,
 static int filelayout_scan_commit_lists(struct inode *inode, int max,
 		spinlock_t *lock)
 {
-	struct pnfs_layout_segment *lseg;
-	struct nfs4_filelayout_segment *fl;
+	struct nfs4_fl_commit_info *fl_cinfo;
 	int i, rv = 0, cnt;
 
-	lseg = find_only_write_lseg_locked(inode);
-	if (!lseg)
+	fl_cinfo = FILELAYOUT_FROM_HDR(NFS_I(inode)->layout)->commit_info;
+	if (fl_cinfo == NULL)
 		goto out_done;
-	fl = FILELAYOUT_LSEG(lseg);
-	if (fl->commit_through_mds)
-		goto out_done;
-	for (i = 0; i < fl->number_of_buckets && max != 0; i++) {
-		cnt = filelayout_scan_ds_commit_list(&fl->commit_buckets[i],
+	for (i = 0; i < fl_cinfo->nbuckets && max != 0; i++) {
+		cnt = filelayout_scan_ds_commit_list(&fl_cinfo->buckets[i],
 				max, lock);
 		max -= cnt;
 		rv += cnt;
@@ -987,38 +977,34 @@ out_done:
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
+	fl_cinfo = FILELAYOUT_FROM_HDR(NFS_I(inode)->layout)->commit_info;
+	for (i = 0, bucket = fl_cinfo->buckets; i < fl_cinfo->nbuckets; i++, bucket++) {
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
@@ -1060,7 +1046,10 @@ filelayout_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
 			nfs_initiate_commit(data, NFS_CLIENT(inode),
 					    data->mds_ops, how);
 		} else {
-			nfs_init_commit(data, &FILELAYOUT_LSEG(data->lseg)->commit_buckets[data->ds_commit_index].committing, data->lseg);
+			struct nfs4_fl_commit_info *fl_cinfo;
+
+			fl_cinfo = FILELAYOUT_FROM_HDR(data->lseg->pls_layout)->commit_info;
+			nfs_init_commit(data, &fl_cinfo->buckets[data->ds_commit_index].committing, data->lseg);
 			filelayout_initiate_commit(data, how);
 		}
 	}
@@ -1074,10 +1063,27 @@ filelayout_free_deveiceid_node(struct nfs4_deviceid_node *d)
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
index 21190bb..7d75c03 100644
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
+	struct nfs4_fl_commit_bucket buckets[0];
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
+	struct nfs4_fl_commit_info *commit_info;
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


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:58808 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932826Ab2DTSsT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 14:48:19 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH v3 21/25] NFS: create struct nfs_commit_info
Date: Fri, 20 Apr 2012 14:47:53 -0400
Message-Id: <1334947677-28864-22-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
References: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is COMMIT that is handled the most differently between
the paged and direct paths.  Create a structure that encapsulates
everything either path needs to know about the commit state.

We could use void to hide some of the layout driver stuff, but
Trond suggests pulling it out to ensure type checking, given the
huge changes being made, and the fact that it doesn't interfere
with other drivers.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/inode.c          |    6 +-
 fs/nfs/internal.h       |   12 +++-
 fs/nfs/nfs4filelayout.c |  119 ++++++++++++++++++++----------------
 fs/nfs/nfs4filelayout.h |   14 +----
 fs/nfs/pnfs.h           |   72 ++++++++++++++-------
 fs/nfs/write.c          |  158 +++++++++++++++++++++++++++-------------------
 include/linux/nfs_fs.h  |    5 +-
 include/linux/nfs_xdr.h |   27 ++++++++
 8 files changed, 248 insertions(+), 165 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index e8bbfa5..59a12c6 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1547,7 +1547,7 @@ static inline void nfs4_init_once(struct nfs_inode *nfsi)
 	nfsi->delegation_state = 0;
 	init_rwsem(&nfsi->rwsem);
 	nfsi->layout = NULL;
-	atomic_set(&nfsi->commits_outstanding, 0);
+	atomic_set(&nfsi->commit_info.rpcs_out, 0);
 #endif
 }
 
@@ -1559,9 +1559,9 @@ static void init_once(void *foo)
 	INIT_LIST_HEAD(&nfsi->open_files);
 	INIT_LIST_HEAD(&nfsi->access_cache_entry_lru);
 	INIT_LIST_HEAD(&nfsi->access_cache_inode_lru);
-	INIT_LIST_HEAD(&nfsi->commit_list);
+	INIT_LIST_HEAD(&nfsi->commit_info.list);
 	nfsi->npages = 0;
-	nfsi->ncommit = 0;
+	nfsi->commit_info.ncommit = 0;
 	atomic_set(&nfsi->silly_count, 1);
 	INIT_HLIST_HEAD(&nfsi->silly_list);
 	init_waitqueue_head(&nfsi->waitqueue);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 50d85e5..53d148b 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -346,12 +346,18 @@ extern void nfs_init_commit(struct nfs_commit_data *data,
 			    struct list_head *head,
 			    struct pnfs_layout_segment *lseg);
 void nfs_retry_commit(struct list_head *page_list,
-		      struct pnfs_layout_segment *lseg);
+		      struct pnfs_layout_segment *lseg,
+		      struct nfs_commit_info *cinfo);
 void nfs_commit_clear_lock(struct nfs_inode *nfsi);
 void nfs_commitdata_release(struct nfs_commit_data *data);
 void nfs_commit_release_pages(struct nfs_commit_data *data);
-void nfs_request_add_commit_list(struct nfs_page *req, struct list_head *head);
-void nfs_request_remove_commit_list(struct nfs_page *req);
+void nfs_request_add_commit_list(struct nfs_page *req, struct list_head *dst,
+				 struct nfs_commit_info *cinfo);
+void nfs_request_remove_commit_list(struct nfs_page *req,
+				    struct nfs_commit_info *cinfo);
+void nfs_init_cinfo(struct nfs_commit_info *cinfo,
+		    struct inode *inode,
+		    struct nfs_direct_req *dreq);
 
 #ifdef CONFIG_MIGRATION
 extern int nfs_migrate_page(struct address_space *,
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index e40523f..fe2cb55 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -347,9 +347,11 @@ static void filelayout_commit_count_stats(struct rpc_task *task, void *data)
 static void filelayout_commit_release(void *calldata)
 {
 	struct nfs_commit_data *data = calldata;
+	struct nfs_commit_info cinfo;
 
 	nfs_commit_release_pages(data);
-	if (atomic_dec_and_test(&NFS_I(data->inode)->commits_outstanding))
+	nfs_init_cinfo(&cinfo, data->inode, data->dreq);
+	if (atomic_dec_and_test(&cinfo.mds->rpcs_out))
 		nfs_commit_clear_lock(NFS_I(data->inode));
 	put_lseg(data->lseg);
 	nfs_commitdata_release(data);
@@ -695,17 +697,16 @@ filelayout_free_lseg(struct pnfs_layout_segment *lseg)
 
 static int
 filelayout_alloc_commit_info(struct pnfs_layout_segment *lseg,
+			     struct nfs_commit_info *cinfo,
 			     gfp_t gfp_flags)
 {
 	struct nfs4_filelayout_segment *fl = FILELAYOUT_LSEG(lseg);
-	struct nfs4_filelayout *flo = FILELAYOUT_FROM_HDR(lseg->pls_layout);
-
-	struct nfs4_fl_commit_bucket *buckets;
+	struct pnfs_commit_bucket *buckets;
 	int size;
 
 	if (fl->commit_through_mds)
 		return 0;
-	if (flo->commit_info.nbuckets != 0) {
+	if (cinfo->ds->nbuckets != 0) {
 		/* This assumes there is only one IOMODE_RW lseg.  What
 		 * we really want to do is have a layout_hdr level
 		 * dictionary of <multipath_list4, fh> keys, each
@@ -718,25 +719,25 @@ filelayout_alloc_commit_info(struct pnfs_layout_segment *lseg,
 	size = (fl->stripe_type == STRIPE_SPARSE) ?
 		fl->dsaddr->ds_num : fl->dsaddr->stripe_count;
 
-	buckets = kcalloc(size, sizeof(struct nfs4_fl_commit_bucket),
+	buckets = kcalloc(size, sizeof(struct pnfs_commit_bucket),
 			  gfp_flags);
 	if (!buckets)
 		return -ENOMEM;
 	else {
 		int i;
 
-		spin_lock(&lseg->pls_layout->plh_inode->i_lock);
-		if (flo->commit_info.nbuckets != 0)
+		spin_lock(cinfo->lock);
+		if (cinfo->ds->nbuckets != 0)
 			kfree(buckets);
 		else {
-			flo->commit_info.buckets = buckets;
-			flo->commit_info.nbuckets = size;
+			cinfo->ds->buckets = buckets;
+			cinfo->ds->nbuckets = size;
 			for (i = 0; i < size; i++) {
 				INIT_LIST_HEAD(&buckets[i].written);
 				INIT_LIST_HEAD(&buckets[i].committing);
 			}
 		}
-		spin_unlock(&lseg->pls_layout->plh_inode->i_lock);
+		spin_unlock(cinfo->lock);
 		return 0;
 	}
 }
@@ -821,6 +822,7 @@ static void
 filelayout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 			 struct nfs_page *req)
 {
+	struct nfs_commit_info cinfo;
 	int status;
 
 	BUG_ON(pgio->pg_lseg != NULL);
@@ -836,7 +838,8 @@ filelayout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 	/* If no lseg, fall back to write through mds */
 	if (pgio->pg_lseg == NULL)
 		goto out_mds;
-	status = filelayout_alloc_commit_info(pgio->pg_lseg, GFP_NOFS);
+	nfs_init_cinfo(&cinfo, pgio->pg_inode, pgio->pg_dreq);
+	status = filelayout_alloc_commit_info(pgio->pg_lseg, &cinfo, GFP_NOFS);
 	if (status < 0) {
 		put_lseg(pgio->pg_lseg);
 		pgio->pg_lseg = NULL;
@@ -871,40 +874,42 @@ static u32 select_bucket_index(struct nfs4_filelayout_segment *fl, u32 j)
  * If this will make the bucket empty, it will need to put the lseg reference.
  */
 static void
-filelayout_clear_request_commit(struct nfs_page *req)
+filelayout_clear_request_commit(struct nfs_page *req,
+				struct nfs_commit_info *cinfo)
 {
 	struct pnfs_layout_segment *freeme = NULL;
-	struct inode *inode = req->wb_context->dentry->d_inode;
 
-	spin_lock(&inode->i_lock);
+	spin_lock(cinfo->lock);
 	if (!test_and_clear_bit(PG_COMMIT_TO_DS, &req->wb_flags))
 		goto out;
+	cinfo->ds->nwritten--;
 	if (list_is_singular(&req->wb_list)) {
-		struct nfs4_fl_commit_bucket *bucket;
+		struct pnfs_commit_bucket *bucket;
 
 		bucket = list_first_entry(&req->wb_list,
-					  struct nfs4_fl_commit_bucket,
+					  struct pnfs_commit_bucket,
 					  written);
 		freeme = bucket->wlseg;
 		bucket->wlseg = NULL;
 	}
 out:
-	nfs_request_remove_commit_list(req);
-	spin_unlock(&inode->i_lock);
+	nfs_request_remove_commit_list(req, cinfo);
+	spin_unlock(cinfo->lock);
 	put_lseg(freeme);
 }
 
 static struct list_head *
 filelayout_choose_commit_list(struct nfs_page *req,
-			      struct pnfs_layout_segment *lseg)
+			      struct pnfs_layout_segment *lseg,
+			      struct nfs_commit_info *cinfo)
 {
 	struct nfs4_filelayout_segment *fl = FILELAYOUT_LSEG(lseg);
 	u32 i, j;
 	struct list_head *list;
-	struct nfs4_fl_commit_bucket *buckets;
+	struct pnfs_commit_bucket *buckets;
 
 	if (fl->commit_through_mds)
-		return &NFS_I(req->wb_context->dentry->d_inode)->commit_list;
+		return &cinfo->mds->list;
 
 	/* Note that we are calling nfs4_fl_calc_j_index on each page
 	 * that ends up being committed to a data server.  An attractive
@@ -914,7 +919,7 @@ filelayout_choose_commit_list(struct nfs_page *req,
 	 */
 	j = nfs4_fl_calc_j_index(lseg, req_offset(req));
 	i = select_bucket_index(fl, j);
-	buckets = FILELAYOUT_FROM_HDR(lseg->pls_layout)->commit_info.buckets;
+	buckets = cinfo->ds->buckets;
 	list = &buckets[i].written;
 	if (list_empty(list)) {
 		/* Non-empty buckets hold a reference on the lseg.  That ref
@@ -926,17 +931,19 @@ filelayout_choose_commit_list(struct nfs_page *req,
 		buckets[i].wlseg = get_lseg(lseg);
 	}
 	set_bit(PG_COMMIT_TO_DS, &req->wb_flags);
+	cinfo->ds->nwritten++;
 	return list;
 }
 
 static void
 filelayout_mark_request_commit(struct nfs_page *req,
-		struct pnfs_layout_segment *lseg)
+			       struct pnfs_layout_segment *lseg,
+			       struct nfs_commit_info *cinfo)
 {
 	struct list_head *list;
 
-	list = filelayout_choose_commit_list(req, lseg);
-	nfs_request_add_commit_list(req, list);
+	list = filelayout_choose_commit_list(req, lseg, cinfo);
+	nfs_request_add_commit_list(req, list, cinfo);
 }
 
 static u32 calc_ds_index_from_commit(struct pnfs_layout_segment *lseg, u32 i)
@@ -993,8 +1000,9 @@ static int filelayout_initiate_commit(struct nfs_commit_data *data, int how)
 }
 
 static int
-filelayout_scan_ds_commit_list(struct nfs4_fl_commit_bucket *bucket, int max,
-		spinlock_t *lock)
+filelayout_scan_ds_commit_list(struct pnfs_commit_bucket *bucket,
+			       struct nfs_commit_info *cinfo,
+			       int max)
 {
 	struct list_head *src = &bucket->written;
 	struct list_head *dst = &bucket->committing;
@@ -1004,9 +1012,9 @@ filelayout_scan_ds_commit_list(struct nfs4_fl_commit_bucket *bucket, int max,
 	list_for_each_entry_safe(req, tmp, src, wb_list) {
 		if (!nfs_lock_request(req))
 			continue;
-		if (cond_resched_lock(lock))
+		if (cond_resched_lock(cinfo->lock))
 			list_safe_reset_next(req, tmp, wb_list);
-		nfs_request_remove_commit_list(req);
+		nfs_request_remove_commit_list(req, cinfo);
 		clear_bit(PG_COMMIT_TO_DS, &req->wb_flags);
 		nfs_list_add_request(req, dst);
 		ret++;
@@ -1014,6 +1022,8 @@ filelayout_scan_ds_commit_list(struct nfs4_fl_commit_bucket *bucket, int max,
 			break;
 	}
 	if (ret) {
+		cinfo->ds->nwritten -= ret;
+		cinfo->ds->ncommitting += ret;
 		bucket->clseg = bucket->wlseg;
 		if (list_empty(src))
 			bucket->wlseg = NULL;
@@ -1024,37 +1034,32 @@ filelayout_scan_ds_commit_list(struct nfs4_fl_commit_bucket *bucket, int max,
 }
 
 /* Move reqs from written to committing lists, returning count of number moved.
- * Note called with i_lock held.
+ * Note called with cinfo->lock held.
  */
-static int filelayout_scan_commit_lists(struct inode *inode, int max,
-		spinlock_t *lock)
+static int filelayout_scan_commit_lists(struct nfs_commit_info *cinfo,
+					int max)
 {
-	struct nfs4_fl_commit_info *fl_cinfo;
 	int i, rv = 0, cnt;
 
-	fl_cinfo = &FILELAYOUT_FROM_HDR(NFS_I(inode)->layout)->commit_info;
-	if (fl_cinfo->nbuckets == 0)
-		goto out_done;
-	for (i = 0; i < fl_cinfo->nbuckets && max != 0; i++) {
-		cnt = filelayout_scan_ds_commit_list(&fl_cinfo->buckets[i],
-				max, lock);
+	for (i = 0; i < cinfo->ds->nbuckets && max != 0; i++) {
+		cnt = filelayout_scan_ds_commit_list(&cinfo->ds->buckets[i],
+						     cinfo, max);
 		max -= cnt;
 		rv += cnt;
 	}
-out_done:
 	return rv;
 }
 
 static unsigned int
-alloc_ds_commits(struct inode *inode, struct list_head *list)
+alloc_ds_commits(struct nfs_commit_info *cinfo, struct list_head *list)
 {
-	struct nfs4_fl_commit_info *fl_cinfo;
-	struct nfs4_fl_commit_bucket *bucket;
+	struct pnfs_ds_commit_info *fl_cinfo;
+	struct pnfs_commit_bucket *bucket;
 	struct nfs_commit_data *data;
 	int i, j;
 	unsigned int nreq = 0;
 
-	fl_cinfo = &FILELAYOUT_FROM_HDR(NFS_I(inode)->layout)->commit_info;
+	fl_cinfo = cinfo->ds;
 	bucket = fl_cinfo->buckets;
 	for (i = 0; i < fl_cinfo->nbuckets; i++, bucket++) {
 		if (list_empty(&bucket->committing))
@@ -1073,7 +1078,7 @@ alloc_ds_commits(struct inode *inode, struct list_head *list)
 	for (j = i; j < fl_cinfo->nbuckets; j++, bucket++) {
 		if (list_empty(&bucket->committing))
 			continue;
-		nfs_retry_commit(&bucket->committing, bucket->clseg);
+		nfs_retry_commit(&bucket->committing, bucket->clseg, cinfo);
 		put_lseg(bucket->clseg);
 		bucket->clseg = NULL;
 	}
@@ -1084,7 +1089,7 @@ alloc_ds_commits(struct inode *inode, struct list_head *list)
 /* This follows nfs_commit_list pretty closely */
 static int
 filelayout_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
-			   int how)
+			   int how, struct nfs_commit_info *cinfo)
 {
 	struct nfs_commit_data *data, *tmp;
 	LIST_HEAD(list);
@@ -1097,17 +1102,17 @@ filelayout_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
 			list_add(&data->pages, &list);
 			nreq++;
 		} else
-			nfs_retry_commit(mds_pages, NULL);
+			nfs_retry_commit(mds_pages, NULL, cinfo);
 	}
 
-	nreq += alloc_ds_commits(inode, &list);
+	nreq += alloc_ds_commits(cinfo, &list);
 
 	if (nreq == 0) {
 		nfs_commit_clear_lock(NFS_I(inode));
 		goto out;
 	}
 
-	atomic_add(nreq, &NFS_I(inode)->commits_outstanding);
+	atomic_add(nreq, &cinfo->mds->rpcs_out);
 
 	list_for_each_entry_safe(data, tmp, &list, pages) {
 		list_del_init(&data->pages);
@@ -1116,14 +1121,15 @@ filelayout_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
 			nfs_initiate_commit(NFS_CLIENT(inode), data,
 					    data->mds_ops, how);
 		} else {
-			struct nfs4_fl_commit_info *fl_cinfo;
+			struct pnfs_commit_bucket *buckets;
 
-			fl_cinfo = &FILELAYOUT_FROM_HDR(data->lseg->pls_layout)->commit_info;
-			nfs_init_commit(data, &fl_cinfo->buckets[data->ds_commit_index].committing, data->lseg);
+			buckets = cinfo->ds->buckets;
+			nfs_init_commit(data, &buckets[data->ds_commit_index].committing, data->lseg);
 			filelayout_initiate_commit(data, how);
 		}
 	}
 out:
+	cinfo->ds->ncommitting = 0;
 	return PNFS_ATTEMPTED;
 }
 
@@ -1148,6 +1154,12 @@ filelayout_free_layout_hdr(struct pnfs_layout_hdr *lo)
 	kfree(FILELAYOUT_FROM_HDR(lo));
 }
 
+static struct pnfs_ds_commit_info *
+filelayout_get_ds_info(struct inode *inode)
+{
+	return &FILELAYOUT_FROM_HDR(NFS_I(inode)->layout)->commit_info;
+}
+
 static struct pnfs_layoutdriver_type filelayout_type = {
 	.id			= LAYOUT_NFSV4_1_FILES,
 	.name			= "LAYOUT_NFSV4_1_FILES",
@@ -1158,6 +1170,7 @@ static struct pnfs_layoutdriver_type filelayout_type = {
 	.free_lseg		= filelayout_free_lseg,
 	.pg_read_ops		= &filelayout_pg_read_ops,
 	.pg_write_ops		= &filelayout_pg_write_ops,
+	.get_ds_info		= &filelayout_get_ds_info,
 	.mark_request_commit	= filelayout_mark_request_commit,
 	.clear_request_commit	= filelayout_clear_request_commit,
 	.scan_commit_lists	= filelayout_scan_commit_lists,
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 333a3ac..96b89bb 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -74,18 +74,6 @@ struct nfs4_file_layout_dsaddr {
 	struct nfs4_pnfs_ds		*ds_list[1];
 };
 
-struct nfs4_fl_commit_bucket {
-	struct list_head written;
-	struct list_head committing;
-	struct pnfs_layout_segment *wlseg;
-	struct pnfs_layout_segment *clseg;
-};
-
-struct nfs4_fl_commit_info {
-	int nbuckets;
-	struct nfs4_fl_commit_bucket *buckets;
-};
-
 struct nfs4_filelayout_segment {
 	struct pnfs_layout_segment generic_hdr;
 	u32 stripe_type;
@@ -100,7 +88,7 @@ struct nfs4_filelayout_segment {
 
 struct nfs4_filelayout {
 	struct pnfs_layout_hdr generic_hdr;
-	struct nfs4_fl_commit_info commit_info;
+	struct pnfs_ds_commit_info commit_info;
 };
 
 static inline struct nfs4_filelayout *
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 734e4ef..4cd8760 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -94,11 +94,18 @@ struct pnfs_layoutdriver_type {
 	const struct nfs_pageio_ops *pg_read_ops;
 	const struct nfs_pageio_ops *pg_write_ops;
 
+	struct pnfs_ds_commit_info *(*get_ds_info) (struct inode *inode);
 	void (*mark_request_commit) (struct nfs_page *req,
-					struct pnfs_layout_segment *lseg);
-	void (*clear_request_commit) (struct nfs_page *req);
-	int (*scan_commit_lists) (struct inode *inode, int max, spinlock_t *lock);
-	int (*commit_pagelist)(struct inode *inode, struct list_head *mds_pages, int how);
+				     struct pnfs_layout_segment *lseg,
+				     struct nfs_commit_info *cinfo);
+	void (*clear_request_commit) (struct nfs_page *req,
+				      struct nfs_commit_info *cinfo);
+	int (*scan_commit_lists) (struct nfs_commit_info *cinfo,
+				  int max);
+	int (*commit_pagelist)(struct inode *inode,
+			       struct list_head *mds_pages,
+			       int how,
+			       struct nfs_commit_info *cinfo);
 
 	/*
 	 * Return PNFS_ATTEMPTED to indicate the layout code has attempted
@@ -263,49 +270,57 @@ static inline int pnfs_enabled_sb(struct nfs_server *nfss)
 }
 
 static inline int
-pnfs_commit_list(struct inode *inode, struct list_head *mds_pages, int how)
+pnfs_commit_list(struct inode *inode, struct list_head *mds_pages, int how,
+		 struct nfs_commit_info *cinfo)
 {
-	if (!test_and_clear_bit(NFS_INO_PNFS_COMMIT, &NFS_I(inode)->flags))
+	if (cinfo->ds == NULL || cinfo->ds->ncommitting == 0)
 		return PNFS_NOT_ATTEMPTED;
-	return NFS_SERVER(inode)->pnfs_curr_ld->commit_pagelist(inode, mds_pages, how);
+	return NFS_SERVER(inode)->pnfs_curr_ld->commit_pagelist(inode, mds_pages, how, cinfo);
+}
+
+static inline struct pnfs_ds_commit_info *
+pnfs_get_ds_info(struct inode *inode)
+{
+	struct pnfs_layoutdriver_type *ld = NFS_SERVER(inode)->pnfs_curr_ld;
+
+	if (ld == NULL || ld->get_ds_info == NULL)
+		return NULL;
+	return ld->get_ds_info(inode);
 }
 
 static inline bool
-pnfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg)
+pnfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg,
+			 struct nfs_commit_info *cinfo)
 {
 	struct inode *inode = req->wb_context->dentry->d_inode;
 	struct pnfs_layoutdriver_type *ld = NFS_SERVER(inode)->pnfs_curr_ld;
 
 	if (lseg == NULL || ld->mark_request_commit == NULL)
 		return false;
-	ld->mark_request_commit(req, lseg);
+	ld->mark_request_commit(req, lseg, cinfo);
 	return true;
 }
 
 static inline bool
-pnfs_clear_request_commit(struct nfs_page *req)
+pnfs_clear_request_commit(struct nfs_page *req, struct nfs_commit_info *cinfo)
 {
 	struct inode *inode = req->wb_context->dentry->d_inode;
 	struct pnfs_layoutdriver_type *ld = NFS_SERVER(inode)->pnfs_curr_ld;
 
 	if (ld == NULL || ld->clear_request_commit == NULL)
 		return false;
-	ld->clear_request_commit(req);
+	ld->clear_request_commit(req, cinfo);
 	return true;
 }
 
 static inline int
-pnfs_scan_commit_lists(struct inode *inode, int max, spinlock_t *lock)
+pnfs_scan_commit_lists(struct inode *inode, struct nfs_commit_info *cinfo,
+		       int max)
 {
-	struct pnfs_layoutdriver_type *ld = NFS_SERVER(inode)->pnfs_curr_ld;
-	int ret;
-
-	if (ld == NULL || ld->scan_commit_lists == NULL)
+	if (cinfo->ds == NULL || cinfo->ds->nwritten == 0)
 		return 0;
-	ret = ld->scan_commit_lists(inode, max, lock);
-	if (ret != 0)
-		set_bit(NFS_INO_PNFS_COMMIT, &NFS_I(inode)->flags);
-	return ret;
+	else
+		return NFS_SERVER(inode)->pnfs_curr_ld->scan_commit_lists(cinfo, max);
 }
 
 /* Should the pNFS client commit and return the layout upon a setattr */
@@ -409,25 +424,34 @@ static inline bool pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, st
 }
 
 static inline int
-pnfs_commit_list(struct inode *inode, struct list_head *mds_pages, int how)
+pnfs_commit_list(struct inode *inode, struct list_head *mds_pages, int how,
+		 struct nfs_commit_info *cinfo)
 {
 	return PNFS_NOT_ATTEMPTED;
 }
 
+static inline struct pnfs_ds_commit_info *
+pnfs_get_ds_info(struct inode *inode)
+{
+	return NULL;
+}
+
 static inline bool
-pnfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg)
+pnfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg,
+			 struct nfs_commit_info *cinfo)
 {
 	return false;
 }
 
 static inline bool
-pnfs_clear_request_commit(struct nfs_page *req)
+pnfs_clear_request_commit(struct nfs_page *req, struct nfs_commit_info *cinfo)
 {
 	return false;
 }
 
 static inline int
-pnfs_scan_commit_lists(struct inode *inode, int max, spinlock_t *lock)
+pnfs_scan_commit_lists(struct inode *inode, struct nfs_commit_info *cinfo,
+		       int max)
 {
 	return 0;
 }
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 2500f1c..18bf700 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -452,65 +452,79 @@ nfs_mark_request_dirty(struct nfs_page *req)
 /**
  * nfs_request_add_commit_list - add request to a commit list
  * @req: pointer to a struct nfs_page
- * @head: commit list head
+ * @dst: commit list head
+ * @cinfo: holds list lock and accounting info
  *
- * This sets the PG_CLEAN bit, updates the inode global count of
+ * This sets the PG_CLEAN bit, updates the cinfo count of
  * number of outstanding requests requiring a commit as well as
  * the MM page stats.
  *
- * The caller must _not_ hold the inode->i_lock, but must be
+ * The caller must _not_ hold the cinfo->lock, but must be
  * holding the nfs_page lock.
  */
 void
-nfs_request_add_commit_list(struct nfs_page *req, struct list_head *head)
+nfs_request_add_commit_list(struct nfs_page *req, struct list_head *dst,
+			    struct nfs_commit_info *cinfo)
 {
-	struct inode *inode = req->wb_context->dentry->d_inode;
-
 	set_bit(PG_CLEAN, &(req)->wb_flags);
-	spin_lock(&inode->i_lock);
-	nfs_list_add_request(req, head);
-	NFS_I(inode)->ncommit++;
-	spin_unlock(&inode->i_lock);
+	spin_lock(cinfo->lock);
+	nfs_list_add_request(req, dst);
+	cinfo->mds->ncommit++;
+	spin_unlock(cinfo->lock);
 	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_RECLAIMABLE);
-	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
+	__mark_inode_dirty(req->wb_context->dentry->d_inode, I_DIRTY_DATASYNC);
 }
 EXPORT_SYMBOL_GPL(nfs_request_add_commit_list);
 
 /**
  * nfs_request_remove_commit_list - Remove request from a commit list
  * @req: pointer to a nfs_page
+ * @cinfo: holds list lock and accounting info
  *
- * This clears the PG_CLEAN bit, and updates the inode global count of
+ * This clears the PG_CLEAN bit, and updates the cinfo's count of
  * number of outstanding requests requiring a commit
  * It does not update the MM page stats.
  *
- * The caller _must_ hold the inode->i_lock and the nfs_page lock.
+ * The caller _must_ hold the cinfo->lock and the nfs_page lock.
  */
 void
-nfs_request_remove_commit_list(struct nfs_page *req)
+nfs_request_remove_commit_list(struct nfs_page *req,
+			       struct nfs_commit_info *cinfo)
 {
-	struct inode *inode = req->wb_context->dentry->d_inode;
-
 	if (!test_and_clear_bit(PG_CLEAN, &(req)->wb_flags))
 		return;
 	nfs_list_remove_request(req);
-	NFS_I(inode)->ncommit--;
+	cinfo->mds->ncommit--;
 }
 EXPORT_SYMBOL_GPL(nfs_request_remove_commit_list);
 
+static void nfs_init_cinfo_from_inode(struct nfs_commit_info *cinfo,
+				      struct inode *inode)
+{
+	cinfo->lock = &inode->i_lock;
+	cinfo->mds = &NFS_I(inode)->commit_info;
+	cinfo->ds = pnfs_get_ds_info(inode);
+}
+
+void nfs_init_cinfo(struct nfs_commit_info *cinfo,
+		    struct inode *inode,
+		    struct nfs_direct_req *dreq)
+{
+	nfs_init_cinfo_from_inode(cinfo, inode);
+}
+EXPORT_SYMBOL_GPL(nfs_init_cinfo);
 
 /*
  * Add a request to the inode's commit list.
  */
 static void
-nfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg)
+nfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg,
+			struct nfs_commit_info *cinfo)
 {
-	struct inode *inode = req->wb_context->dentry->d_inode;
-
-	if (pnfs_mark_request_commit(req, lseg))
+	if (pnfs_mark_request_commit(req, lseg, cinfo))
 		return;
-	nfs_request_add_commit_list(req, &NFS_I(inode)->commit_list);
+	nfs_request_add_commit_list(req, &cinfo->mds->list, cinfo);
 }
 
 static void
@@ -525,11 +539,13 @@ nfs_clear_request_commit(struct nfs_page *req)
 {
 	if (test_bit(PG_CLEAN, &req->wb_flags)) {
 		struct inode *inode = req->wb_context->dentry->d_inode;
+		struct nfs_commit_info cinfo;
 
-		if (!pnfs_clear_request_commit(req)) {
-			spin_lock(&inode->i_lock);
-			nfs_request_remove_commit_list(req);
-			spin_unlock(&inode->i_lock);
+		nfs_init_cinfo_from_inode(&cinfo, inode);
+		if (!pnfs_clear_request_commit(req, &cinfo)) {
+			spin_lock(cinfo.lock);
+			nfs_request_remove_commit_list(req, &cinfo);
+			spin_unlock(cinfo.lock);
 		}
 		nfs_clear_page_commit(req->wb_page);
 	}
@@ -545,7 +561,8 @@ int nfs_write_need_commit(struct nfs_write_data *data)
 
 #else
 static void
-nfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg)
+nfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg,
+			struct nfs_commit_info *cinfo)
 {
 }
 
@@ -564,10 +581,12 @@ int nfs_write_need_commit(struct nfs_write_data *data)
 
 static void nfs_write_completion(struct nfs_pgio_header *hdr)
 {
+	struct nfs_commit_info cinfo;
 	unsigned long bytes = 0;
 
 	if (test_bit(NFS_IOHDR_REDO, &hdr->flags))
 		goto out;
+	nfs_init_cinfo_from_inode(&cinfo, hdr->inode);
 	while (!list_empty(&hdr->pages)) {
 		struct nfs_page *req = nfs_list_entry(hdr->pages.next);
 		struct page *page = req->wb_page;
@@ -585,7 +604,7 @@ static void nfs_write_completion(struct nfs_pgio_header *hdr)
 			goto next;
 		}
 		if (test_bit(NFS_IOHDR_NEED_COMMIT, &hdr->flags)) {
-			nfs_mark_request_commit(req, hdr->lseg);
+			nfs_mark_request_commit(req, hdr->lseg, &cinfo);
 			goto next;
 		}
 remove_req:
@@ -599,16 +618,16 @@ out:
 }
 
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
-static int
-nfs_need_commit(struct nfs_inode *nfsi)
+static unsigned long
+nfs_reqs_to_commit(struct nfs_commit_info *cinfo)
 {
-	return nfsi->ncommit > 0;
+	return cinfo->mds->ncommit;
 }
 
-/* i_lock held by caller */
+/* cinfo->lock held by caller */
 static int
-nfs_scan_commit_list(struct list_head *src, struct list_head *dst, int max,
-		spinlock_t *lock)
+nfs_scan_commit_list(struct list_head *src, struct list_head *dst,
+		     struct nfs_commit_info *cinfo, int max)
 {
 	struct nfs_page *req, *tmp;
 	int ret = 0;
@@ -616,9 +635,9 @@ nfs_scan_commit_list(struct list_head *src, struct list_head *dst, int max,
 	list_for_each_entry_safe(req, tmp, src, wb_list) {
 		if (!nfs_lock_request(req))
 			continue;
-		if (cond_resched_lock(lock))
+		if (cond_resched_lock(cinfo->lock))
 			list_safe_reset_next(req, tmp, wb_list);
-		nfs_request_remove_commit_list(req);
+		nfs_request_remove_commit_list(req, cinfo);
 		nfs_list_add_request(req, dst);
 		ret++;
 		if (ret == max)
@@ -630,37 +649,38 @@ nfs_scan_commit_list(struct list_head *src, struct list_head *dst, int max,
 /*
  * nfs_scan_commit - Scan an inode for commit requests
  * @inode: NFS inode to scan
- * @dst: destination list
+ * @dst: mds destination list
+ * @cinfo: mds and ds lists of reqs ready to commit
  *
  * Moves requests from the inode's 'commit' request list.
  * The requests are *not* checked to ensure that they form a contiguous set.
  */
 static int
-nfs_scan_commit(struct inode *inode, struct list_head *dst)
+nfs_scan_commit(struct inode *inode, struct list_head *dst,
+		struct nfs_commit_info *cinfo)
 {
-	struct nfs_inode *nfsi = NFS_I(inode);
 	int ret = 0;
 
-	spin_lock(&inode->i_lock);
-	if (nfsi->ncommit > 0) {
+	spin_lock(cinfo->lock);
+	if (cinfo->mds->ncommit > 0) {
 		const int max = INT_MAX;
 
-		ret = nfs_scan_commit_list(&nfsi->commit_list, dst, max,
-				&inode->i_lock);
-		ret += pnfs_scan_commit_lists(inode, max - ret,
-				&inode->i_lock);
+		ret = nfs_scan_commit_list(&cinfo->mds->list, dst,
+					   cinfo, max);
+		ret += pnfs_scan_commit_lists(inode, cinfo, max - ret);
 	}
-	spin_unlock(&inode->i_lock);
+	spin_unlock(cinfo->lock);
 	return ret;
 }
 
 #else
-static inline int nfs_need_commit(struct nfs_inode *nfsi)
+static unsigned long nfs_reqs_to_commit(struct nfs_commit_info *cinfo)
 {
 	return 0;
 }
 
-static inline int nfs_scan_commit(struct inode *inode, struct list_head *dst)
+static inline int nfs_scan_commit(struct inode *inode, struct list_head *dst,
+				  struct nfs_commit_info *cinfo)
 {
 	return 0;
 }
@@ -929,7 +949,7 @@ EXPORT_SYMBOL_GPL(nfs_initiate_write);
  */
 static void nfs_write_rpcsetup(struct nfs_write_data *data,
 		unsigned int count, unsigned int offset,
-		int how)
+		int how, struct nfs_commit_info *cinfo)
 {
 	struct nfs_page *req = data->header->req;
 
@@ -950,7 +970,7 @@ static void nfs_write_rpcsetup(struct nfs_write_data *data,
 	case 0:
 		break;
 	case FLUSH_COND_STABLE:
-		if (nfs_need_commit(NFS_I(data->header->inode)))
+		if (nfs_reqs_to_commit(cinfo))
 			break;
 	default:
 		data->args.stable = NFS_FILE_SYNC;
@@ -1034,12 +1054,14 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc,
 	unsigned int offset;
 	int requests = 0;
 	int ret = 0;
+	struct nfs_commit_info cinfo;
 
+	nfs_init_cinfo(&cinfo, desc->pg_inode, desc->pg_dreq);
 	nfs_list_remove_request(req);
 	nfs_list_add_request(req, &hdr->pages);
 
 	if ((desc->pg_ioflags & FLUSH_COND_STABLE) &&
-	    (desc->pg_moreio || NFS_I(desc->pg_inode)->ncommit ||
+	    (desc->pg_moreio || nfs_reqs_to_commit(&cinfo) ||
 	     desc->pg_count > wsize))
 		desc->pg_ioflags &= ~FLUSH_COND_STABLE;
 
@@ -1053,7 +1075,7 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc,
 		if (!data)
 			goto out_bad;
 		data->pages.pagevec[0] = page;
-		nfs_write_rpcsetup(data, len, offset, desc->pg_ioflags);
+		nfs_write_rpcsetup(data, len, offset, desc->pg_ioflags, &cinfo);
 		list_add(&data->list, &hdr->rpc_list);
 		requests++;
 		nbytes -= len;
@@ -1088,6 +1110,7 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc,
 	struct nfs_write_data	*data;
 	struct list_head *head = &desc->pg_list;
 	int ret = 0;
+	struct nfs_commit_info cinfo;
 
 	data = nfs_writedata_alloc(hdr, nfs_page_array_len(desc->pg_base,
 							   desc->pg_count));
@@ -1097,6 +1120,7 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc,
 		goto out;
 	}
 
+	nfs_init_cinfo(&cinfo, desc->pg_inode, desc->pg_dreq);
 	pages = data->pages.pagevec;
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
@@ -1106,11 +1130,11 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc,
 	}
 
 	if ((desc->pg_ioflags & FLUSH_COND_STABLE) &&
-	    (desc->pg_moreio || NFS_I(desc->pg_inode)->ncommit))
+	    (desc->pg_moreio || nfs_reqs_to_commit(&cinfo)))
 		desc->pg_ioflags &= ~FLUSH_COND_STABLE;
 
 	/* Set up the argument struct */
-	nfs_write_rpcsetup(data, desc->pg_count, 0, desc->pg_ioflags);
+	nfs_write_rpcsetup(data, desc->pg_count, 0, desc->pg_ioflags, &cinfo);
 	list_add(&data->list, &hdr->rpc_list);
 	desc->pg_rpc_callops = &nfs_write_common_ops;
 out:
@@ -1417,14 +1441,15 @@ void nfs_init_commit(struct nfs_commit_data *data,
 EXPORT_SYMBOL_GPL(nfs_init_commit);
 
 void nfs_retry_commit(struct list_head *page_list,
-		      struct pnfs_layout_segment *lseg)
+		      struct pnfs_layout_segment *lseg,
+		      struct nfs_commit_info *cinfo)
 {
 	struct nfs_page *req;
 
 	while (!list_empty(page_list)) {
 		req = nfs_list_entry(page_list->next);
 		nfs_list_remove_request(req);
-		nfs_mark_request_commit(req, lseg);
+		nfs_mark_request_commit(req, lseg, cinfo);
 		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
 			     BDI_RECLAIMABLE);
@@ -1437,7 +1462,8 @@ EXPORT_SYMBOL_GPL(nfs_retry_commit);
  * Commit dirty pages
  */
 static int
-nfs_commit_list(struct inode *inode, struct list_head *head, int how)
+nfs_commit_list(struct inode *inode, struct list_head *head, int how,
+		struct nfs_commit_info *cinfo)
 {
 	struct nfs_commit_data	*data;
 
@@ -1450,7 +1476,7 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
 	nfs_init_commit(data, head, NULL);
 	return nfs_initiate_commit(NFS_CLIENT(inode), data, data->mds_ops, how);
  out_bad:
-	nfs_retry_commit(head, NULL);
+	nfs_retry_commit(head, NULL, cinfo);
 	nfs_commit_clear_lock(NFS_I(inode));
 	return -ENOMEM;
 }
@@ -1524,30 +1550,32 @@ static const struct rpc_call_ops nfs_commit_ops = {
 };
 
 static int nfs_generic_commit_list(struct inode *inode, struct list_head *head,
-				   int how)
+				   int how, struct nfs_commit_info *cinfo)
 {
 	int status;
 
-	status = pnfs_commit_list(inode, head, how);
+	status = pnfs_commit_list(inode, head, how, cinfo);
 	if (status == PNFS_NOT_ATTEMPTED)
-		status = nfs_commit_list(inode, head, how);
+		status = nfs_commit_list(inode, head, how, cinfo);
 	return status;
 }
 
 int nfs_commit_inode(struct inode *inode, int how)
 {
 	LIST_HEAD(head);
+	struct nfs_commit_info cinfo;
 	int may_wait = how & FLUSH_SYNC;
 	int res;
 
 	res = nfs_commit_set_lock(NFS_I(inode), may_wait);
 	if (res <= 0)
 		goto out_mark_dirty;
-	res = nfs_scan_commit(inode, &head);
+	nfs_init_cinfo_from_inode(&cinfo, inode);
+	res = nfs_scan_commit(inode, &head, &cinfo);
 	if (res) {
 		int error;
 
-		error = nfs_generic_commit_list(inode, &head, how);
+		error = nfs_generic_commit_list(inode, &head, how, &cinfo);
 		if (error < 0)
 			return error;
 		if (!may_wait)
@@ -1578,14 +1606,14 @@ static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_contr
 	int ret = 0;
 
 	/* no commits means nothing needs to be done */
-	if (!nfsi->ncommit)
+	if (!nfsi->commit_info.ncommit)
 		return ret;
 
 	if (wbc->sync_mode == WB_SYNC_NONE) {
 		/* Don't commit yet if this is a non-blocking flush and there
 		 * are a lot of outstanding writes for this mapping.
 		 */
-		if (nfsi->ncommit <= (nfsi->npages >> 1))
+		if (nfsi->commit_info.ncommit <= (nfsi->npages >> 1))
 			goto out_mark_dirty;
 
 		/* don't wait for the COMMIT response */
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 8d3a2b8..8a88c16 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -179,8 +179,7 @@ struct nfs_inode {
 	__be32			cookieverf[2];
 
 	unsigned long		npages;
-	unsigned long		ncommit;
-	struct list_head	commit_list;
+	struct nfs_mds_commit_info commit_info;
 
 	/* Open contexts for shared mmap writes */
 	struct list_head	open_files;
@@ -201,7 +200,6 @@ struct nfs_inode {
 
 	/* pNFS layout information */
 	struct pnfs_layout_hdr *layout;
-	atomic_t		commits_outstanding;
 #endif /* CONFIG_NFS_V4*/
 #ifdef CONFIG_NFS_FSCACHE
 	struct fscache_cookie	*fscache;
@@ -230,7 +228,6 @@ struct nfs_inode {
 #define NFS_INO_FSCACHE		(5)		/* inode can be cached by FS-Cache */
 #define NFS_INO_FSCACHE_LOCK	(6)		/* FS-Cache cookie management lock */
 #define NFS_INO_COMMIT		(7)		/* inode is committing unstable writes */
-#define NFS_INO_PNFS_COMMIT	(8)		/* use pnfs code for commit */
 #define NFS_INO_LAYOUTCOMMIT	(9)		/* layoutcommit required */
 #define NFS_INO_LAYOUTCOMMITTING (10)		/* layoutcommit inflight */
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 938d30a..2884ced 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1074,6 +1074,21 @@ struct nfstime4 {
 };
 
 #ifdef CONFIG_NFS_V4_1
+
+struct pnfs_commit_bucket {
+	struct list_head written;
+	struct list_head committing;
+	struct pnfs_layout_segment *wlseg;
+	struct pnfs_layout_segment *clseg;
+};
+
+struct pnfs_ds_commit_info {
+	int nwritten;
+	int ncommitting;
+	int nbuckets;
+	struct pnfs_commit_bucket *buckets;
+};
+
 #define NFS4_EXCHANGE_ID_LEN	(48)
 struct nfs41_exchange_id_args {
 	struct nfs_client		*client;
@@ -1237,6 +1252,18 @@ struct nfs_write_header {
 	struct nfs_write_data	rpc_data;
 };
 
+struct nfs_mds_commit_info {
+	atomic_t rpcs_out;
+	unsigned long		ncommit;
+	struct list_head	list;
+};
+
+struct nfs_commit_info {
+	spinlock_t			*lock;
+	struct nfs_mds_commit_info	*mds;
+	struct pnfs_ds_commit_info	*ds;
+};
+
 struct nfs_commit_data {
 	struct rpc_task		task;
 	struct inode		*inode;
-- 
1.7.2.1


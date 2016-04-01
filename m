Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42405 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752044AbcDARqu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Apr 2016 13:46:50 -0400
From: Dave Wysochanski <dwysocha@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Save struct inode * inside nfs_commit_info to clarify usage of i_lock
Date: Fri,  1 Apr 2016 13:45:09 -0400
Message-Id: <1459532709-2792-1-git-send-email-dwysocha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit ea2cf22 created nfs_commit_info and saved &inode->i_lock inside
this NFS specific structure.  This obscures the usage of i_lock.
Instead, save struct inode * so later it's clear the spinlock taken is
i_lock.

Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 fs/nfs/direct.c                        | 10 +++++-----
 fs/nfs/filelayout/filelayout.c         |  4 ++--
 fs/nfs/flexfilelayout/flexfilelayout.c |  4 ++--
 fs/nfs/pnfs_nfs.c                      | 32 ++++++++++++++++----------------
 fs/nfs/write.c                         | 16 ++++++++--------
 include/linux/nfs_xdr.h                |  2 +-
 6 files changed, 34 insertions(+), 34 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 7a0cfd3..13d49d5 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -275,7 +275,7 @@ static void nfs_direct_release_pages(struct page **pages, unsigned int npages)
 void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
 			      struct nfs_direct_req *dreq)
 {
-	cinfo->lock = &dreq->inode->i_lock;
+	cinfo->inode = dreq->inode;
 	cinfo->mds = &dreq->mds_cinfo;
 	cinfo->ds = &dreq->ds_cinfo;
 	cinfo->dreq = dreq;
@@ -632,13 +632,13 @@ nfs_direct_write_scan_commit_list(struct inode *inode,
 				  struct list_head *list,
 				  struct nfs_commit_info *cinfo)
 {
-	spin_lock(cinfo->lock);
+	spin_lock(&cinfo->inode->i_lock);
 #ifdef CONFIG_NFS_V4_1
 	if (cinfo->ds != NULL && cinfo->ds->nwritten != 0)
 		NFS_SERVER(inode)->pnfs_curr_ld->recover_commit_reqs(list, cinfo);
 #endif
 	nfs_scan_commit_list(&cinfo->mds->list, list, cinfo, 0);
-	spin_unlock(cinfo->lock);
+	spin_unlock(&cinfo->inode->i_lock);
 }
 
 static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
@@ -673,13 +673,13 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 		if (!nfs_pageio_add_request(&desc, req)) {
 			nfs_list_remove_request(req);
 			nfs_list_add_request(req, &failed);
-			spin_lock(cinfo.lock);
+			spin_lock(&cinfo.inode->i_lock);
 			dreq->flags = 0;
 			if (desc.pg_error < 0)
 				dreq->error = desc.pg_error;
 			else
 				dreq->error = -EIO;
-			spin_unlock(cinfo.lock);
+			spin_unlock(&cinfo.inode->i_lock);
 		}
 		nfs_release_request(req);
 	}
diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 3384dc8..3e50057 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -795,7 +795,7 @@ filelayout_alloc_commit_info(struct pnfs_layout_segment *lseg,
 		buckets[i].direct_verf.committed = NFS_INVALID_STABLE_HOW;
 	}
 
-	spin_lock(cinfo->lock);
+	spin_lock(&cinfo->inode->i_lock);
 	if (cinfo->ds->nbuckets >= size)
 		goto out;
 	for (i = 0; i < cinfo->ds->nbuckets; i++) {
@@ -811,7 +811,7 @@ filelayout_alloc_commit_info(struct pnfs_layout_segment *lseg,
 	swap(cinfo->ds->buckets, buckets);
 	cinfo->ds->nbuckets = size;
 out:
-	spin_unlock(cinfo->lock);
+	spin_unlock(&cinfo->inode->i_lock);
 	kfree(buckets);
 	return 0;
 }
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 0cb1abd..3b398f7 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -745,7 +745,7 @@ ff_layout_alloc_commit_info(struct pnfs_layout_segment *lseg,
 	else {
 		int i;
 
-		spin_lock(cinfo->lock);
+		spin_lock(&cinfo->inode->i_lock);
 		if (cinfo->ds->nbuckets != 0)
 			kfree(buckets);
 		else {
@@ -759,7 +759,7 @@ ff_layout_alloc_commit_info(struct pnfs_layout_segment *lseg,
 					NFS_INVALID_STABLE_HOW;
 			}
 		}
-		spin_unlock(cinfo->lock);
+		spin_unlock(&cinfo->inode->i_lock);
 		return 0;
 	}
 }
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 4aaed89..d2a7c9f 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -61,7 +61,7 @@ EXPORT_SYMBOL_GPL(pnfs_generic_commit_release);
 
 /* The generic layer is about to remove the req from the commit list.
  * If this will make the bucket empty, it will need to put the lseg reference.
- * Note this must be called holding the inode (/cinfo) lock
+ * Note this must be called holding i_lock
  */
 void
 pnfs_generic_clear_request_commit(struct nfs_page *req,
@@ -98,7 +98,7 @@ pnfs_generic_transfer_commit_list(struct list_head *src, struct list_head *dst,
 		if (!nfs_lock_request(req))
 			continue;
 		kref_get(&req->wb_kref);
-		if (cond_resched_lock(cinfo->lock))
+		if (cond_resched_lock(&cinfo->inode->i_lock))
 			list_safe_reset_next(req, tmp, wb_list);
 		nfs_request_remove_commit_list(req, cinfo);
 		clear_bit(PG_COMMIT_TO_DS, &req->wb_flags);
@@ -119,7 +119,7 @@ pnfs_generic_scan_ds_commit_list(struct pnfs_commit_bucket *bucket,
 	struct list_head *dst = &bucket->committing;
 	int ret;
 
-	lockdep_assert_held(cinfo->lock);
+	lockdep_assert_held(&cinfo->inode->i_lock);
 	ret = pnfs_generic_transfer_commit_list(src, dst, cinfo, max);
 	if (ret) {
 		cinfo->ds->nwritten -= ret;
@@ -142,7 +142,7 @@ int pnfs_generic_scan_commit_lists(struct nfs_commit_info *cinfo,
 {
 	int i, rv = 0, cnt;
 
-	lockdep_assert_held(cinfo->lock);
+	lockdep_assert_held(&cinfo->inode->i_lock);
 	for (i = 0; i < cinfo->ds->nbuckets && max != 0; i++) {
 		cnt = pnfs_generic_scan_ds_commit_list(&cinfo->ds->buckets[i],
 						       cinfo, max);
@@ -161,16 +161,16 @@ void pnfs_generic_recover_commit_reqs(struct list_head *dst,
 	struct pnfs_layout_segment *freeme;
 	int i;
 
-	lockdep_assert_held(cinfo->lock);
+	lockdep_assert_held(&cinfo->inode->i_lock);
 restart:
 	for (i = 0, b = cinfo->ds->buckets; i < cinfo->ds->nbuckets; i++, b++) {
 		if (pnfs_generic_transfer_commit_list(&b->written, dst,
 						      cinfo, 0)) {
 			freeme = b->wlseg;
 			b->wlseg = NULL;
-			spin_unlock(cinfo->lock);
+			spin_unlock(&cinfo->inode->i_lock);
 			pnfs_put_lseg(freeme);
-			spin_lock(cinfo->lock);
+			spin_lock(&cinfo->inode->i_lock);
 			goto restart;
 		}
 	}
@@ -186,7 +186,7 @@ static void pnfs_generic_retry_commit(struct nfs_commit_info *cinfo, int idx)
 	LIST_HEAD(pages);
 	int i;
 
-	spin_lock(cinfo->lock);
+	spin_lock(&cinfo->inode->i_lock);
 	for (i = idx; i < fl_cinfo->nbuckets; i++) {
 		bucket = &fl_cinfo->buckets[i];
 		if (list_empty(&bucket->committing))
@@ -194,12 +194,12 @@ static void pnfs_generic_retry_commit(struct nfs_commit_info *cinfo, int idx)
 		freeme = bucket->clseg;
 		bucket->clseg = NULL;
 		list_splice_init(&bucket->committing, &pages);
-		spin_unlock(cinfo->lock);
+		spin_unlock(&cinfo->inode->i_lock);
 		nfs_retry_commit(&pages, freeme, cinfo, i);
 		pnfs_put_lseg(freeme);
-		spin_lock(cinfo->lock);
+		spin_lock(&cinfo->inode->i_lock);
 	}
-	spin_unlock(cinfo->lock);
+	spin_unlock(&cinfo->inode->i_lock);
 }
 
 static unsigned int
@@ -238,11 +238,11 @@ void pnfs_fetch_commit_bucket_list(struct list_head *pages,
 	struct pnfs_commit_bucket *bucket;
 
 	bucket = &cinfo->ds->buckets[data->ds_commit_index];
-	spin_lock(cinfo->lock);
+	spin_lock(&cinfo->inode->i_lock);
 	list_splice_init(&bucket->committing, pages);
 	data->lseg = bucket->clseg;
 	bucket->clseg = NULL;
-	spin_unlock(cinfo->lock);
+	spin_unlock(&cinfo->inode->i_lock);
 
 }
 
@@ -874,12 +874,12 @@ pnfs_layout_mark_request_commit(struct nfs_page *req,
 	struct list_head *list;
 	struct pnfs_commit_bucket *buckets;
 
-	spin_lock(cinfo->lock);
+	spin_lock(&cinfo->inode->i_lock);
 	buckets = cinfo->ds->buckets;
 	list = &buckets[ds_commit_idx].written;
 	if (list_empty(list)) {
 		if (!pnfs_is_valid_lseg(lseg)) {
-			spin_unlock(cinfo->lock);
+			spin_unlock(&cinfo->inode->i_lock);
 			cinfo->completion_ops->resched_write(cinfo, req);
 			return;
 		}
@@ -896,7 +896,7 @@ pnfs_layout_mark_request_commit(struct nfs_page *req,
 	cinfo->ds->nwritten++;
 
 	nfs_request_add_commit_list_locked(req, list, cinfo);
-	spin_unlock(cinfo->lock);
+	spin_unlock(&cinfo->inode->i_lock);
 	nfs_mark_page_unstable(req->wb_page, cinfo);
 }
 EXPORT_SYMBOL_GPL(pnfs_layout_mark_request_commit);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 5754835..21753f8 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -804,7 +804,7 @@ nfs_page_search_commits_for_head_request_locked(struct nfs_inode *nfsi,
  * number of outstanding requests requiring a commit as well as
  * the MM page stats.
  *
- * The caller must hold the cinfo->lock, and the nfs_page lock.
+ * The caller must hold cinfo->inode->i_lock, and the nfs_page lock.
  */
 void
 nfs_request_add_commit_list_locked(struct nfs_page *req, struct list_head *dst,
@@ -832,9 +832,9 @@ EXPORT_SYMBOL_GPL(nfs_request_add_commit_list_locked);
 void
 nfs_request_add_commit_list(struct nfs_page *req, struct nfs_commit_info *cinfo)
 {
-	spin_lock(cinfo->lock);
+	spin_lock(&cinfo->inode->i_lock);
 	nfs_request_add_commit_list_locked(req, &cinfo->mds->list, cinfo);
-	spin_unlock(cinfo->lock);
+	spin_unlock(&cinfo->inode->i_lock);
 	nfs_mark_page_unstable(req->wb_page, cinfo);
 }
 EXPORT_SYMBOL_GPL(nfs_request_add_commit_list);
@@ -864,7 +864,7 @@ EXPORT_SYMBOL_GPL(nfs_request_remove_commit_list);
 static void nfs_init_cinfo_from_inode(struct nfs_commit_info *cinfo,
 				      struct inode *inode)
 {
-	cinfo->lock = &inode->i_lock;
+	cinfo->inode = inode;
 	cinfo->mds = &NFS_I(inode)->commit_info;
 	cinfo->ds = pnfs_get_ds_info(inode);
 	cinfo->dreq = NULL;
@@ -967,7 +967,7 @@ nfs_reqs_to_commit(struct nfs_commit_info *cinfo)
 	return cinfo->mds->ncommit;
 }
 
-/* cinfo->lock held by caller */
+/* cinfo->inode->i_lock held by caller */
 int
 nfs_scan_commit_list(struct list_head *src, struct list_head *dst,
 		     struct nfs_commit_info *cinfo, int max)
@@ -979,7 +979,7 @@ nfs_scan_commit_list(struct list_head *src, struct list_head *dst,
 		if (!nfs_lock_request(req))
 			continue;
 		kref_get(&req->wb_kref);
-		if (cond_resched_lock(cinfo->lock))
+		if (cond_resched_lock(&cinfo->inode->i_lock))
 			list_safe_reset_next(req, tmp, wb_list);
 		nfs_request_remove_commit_list(req, cinfo);
 		nfs_list_add_request(req, dst);
@@ -1005,7 +1005,7 @@ nfs_scan_commit(struct inode *inode, struct list_head *dst,
 {
 	int ret = 0;
 
-	spin_lock(cinfo->lock);
+	spin_lock(&cinfo->inode->i_lock);
 	if (cinfo->mds->ncommit > 0) {
 		const int max = INT_MAX;
 
@@ -1013,7 +1013,7 @@ nfs_scan_commit(struct inode *inode, struct list_head *dst,
 					   cinfo, max);
 		ret += pnfs_scan_commit_lists(inode, cinfo, max - ret);
 	}
-	spin_unlock(cinfo->lock);
+	spin_unlock(&cinfo->inode->i_lock);
 	return ret;
 }
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index d320906..cb9982d 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1431,7 +1431,7 @@ struct nfs_commit_completion_ops {
 };
 
 struct nfs_commit_info {
-	spinlock_t			*lock;	/* inode->i_lock */
+	struct inode 			*inode;	/* Needed for inode->i_lock */
 	struct nfs_mds_commit_info	*mds;
 	struct pnfs_ds_commit_info	*ds;
 	struct nfs_direct_req		*dreq;	/* O_DIRECT request */
-- 
2.5.5


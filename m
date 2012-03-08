Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55779 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758868Ab2CHW3k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Mar 2012 17:29:40 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/2] NFS: remove nfs_inode radix tree
Date: Thu,  8 Mar 2012 17:29:35 -0500
Message-Id: <1331245775-1995-2-git-send-email-iisaman@netapp.com>
In-Reply-To: <1331245775-1995-1-git-send-email-iisaman@netapp.com>
References: <1331245775-1995-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The radix tree is only being used to compile lists of reqs needing commit.
It is simpler to just put the reqs directly into a list.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/inode.c           |    2 +-
 fs/nfs/internal.h        |    2 +
 fs/nfs/nfs4filelayout.c  |  109 +++++++++++++++++++++++++++++++++--------
 fs/nfs/nfs4filelayout.h  |    7 ++-
 fs/nfs/pagelist.c        |   61 -----------------------
 fs/nfs/pnfs.h            |   82 ++++++++++++++++---------------
 fs/nfs/write.c           |  120 +++++++++++++++++++++++++--------------------
 include/linux/nfs_fs.h   |    6 +--
 include/linux/nfs_page.h |   13 +-----
 9 files changed, 208 insertions(+), 194 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 70e25c9..1a19f8d 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1560,7 +1560,7 @@ static void init_once(void *foo)
 	INIT_LIST_HEAD(&nfsi->open_files);
 	INIT_LIST_HEAD(&nfsi->access_cache_entry_lru);
 	INIT_LIST_HEAD(&nfsi->access_cache_inode_lru);
-	INIT_RADIX_TREE(&nfsi->nfs_page_tree, GFP_ATOMIC);
+	INIT_LIST_HEAD(&nfsi->commit_list);
 	nfsi->npages = 0;
 	nfsi->ncommit = 0;
 	atomic_set(&nfsi->silly_count, 1);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 0c3648a..04a9147 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -308,6 +308,8 @@ extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
 extern void nfs_readdata_release(struct nfs_read_data *rdata);
 
 /* write.c */
+extern int nfs_scan_commit_list(struct list_head *src, struct list_head *dst,
+				int max);
 extern int nfs_generic_flush(struct nfs_pageio_descriptor *desc,
 		struct list_head *head);
 extern void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor *pgio,
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index b2d3bb5..1ab8bd9 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -687,14 +687,16 @@ filelayout_alloc_lseg(struct pnfs_layout_hdr *layoutid,
 		int size = (fl->stripe_type == STRIPE_SPARSE) ?
 			fl->dsaddr->ds_num : fl->dsaddr->stripe_count;
 
-		fl->commit_buckets = kcalloc(size, sizeof(struct list_head), gfp_flags);
+		fl->commit_buckets = kcalloc(size, sizeof(struct nfs4_fl_commit_bucket), gfp_flags);
 		if (!fl->commit_buckets) {
 			filelayout_free_lseg(&fl->generic_hdr);
 			return NULL;
 		}
 		fl->number_of_buckets = size;
-		for (i = 0; i < size; i++)
-			INIT_LIST_HEAD(&fl->commit_buckets[i]);
+		for (i = 0; i < size; i++) {
+			INIT_LIST_HEAD(&fl->commit_buckets[i].written);
+			INIT_LIST_HEAD(&fl->commit_buckets[i].committing);
+		}
 	}
 	return &fl->generic_hdr;
 }
@@ -772,11 +774,6 @@ static const struct nfs_pageio_ops filelayout_pg_write_ops = {
 	.pg_doio = pnfs_generic_pg_writepages,
 };
 
-static bool filelayout_mark_pnfs_commit(struct pnfs_layout_segment *lseg)
-{
-	return !FILELAYOUT_LSEG(lseg)->commit_through_mds;
-}
-
 static u32 select_bucket_index(struct nfs4_filelayout_segment *fl, u32 j)
 {
 	if (fl->stripe_type == STRIPE_SPARSE)
@@ -785,13 +782,39 @@ static u32 select_bucket_index(struct nfs4_filelayout_segment *fl, u32 j)
 		return j;
 }
 
-struct list_head *filelayout_choose_commit_list(struct nfs_page *req)
+/* The generic layer is about to remove the req from the commit list.
+ * If this will make the bucket empty, it will need to put the lseg reference.
+ * Note inode lock is held, so we can't do the put here.
+ */
+static struct pnfs_layout_segment *
+filelayout_remove_commit_req(struct nfs_page *req)
+{
+	if (list_is_singular(&req->wb_list)) {
+		struct inode *inode = req->wb_context->dentry->d_inode;
+		struct pnfs_layout_segment *lseg;
+
+		/* From here we can find the bucket, but for the moment,
+		 * since there is only one relevant lseg...
+		 */
+		list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list) {
+			if (lseg->pls_range.iomode == IOMODE_RW)
+				return lseg;
+		}
+	}
+	return NULL;
+}
+
+static struct list_head *
+filelayout_choose_commit_list(struct nfs_page *req,
+			      struct pnfs_layout_segment *lseg)
 {
-	struct pnfs_layout_segment *lseg = req->wb_commit_lseg;
 	struct nfs4_filelayout_segment *fl = FILELAYOUT_LSEG(lseg);
 	u32 i, j;
 	struct list_head *list;
 
+	if (fl->commit_through_mds)
+		return &NFS_I(req->wb_context->dentry->d_inode)->commit_list;
+
 	/* Note that we are calling nfs4_fl_calc_j_index on each page
 	 * that ends up being committed to a data server.  An attractive
 	 * alternative is to add a field to nfs_write_data and nfs_page
@@ -801,9 +824,14 @@ struct list_head *filelayout_choose_commit_list(struct nfs_page *req)
 	j = nfs4_fl_calc_j_index(lseg,
 				 (loff_t)req->wb_index << PAGE_CACHE_SHIFT);
 	i = select_bucket_index(fl, j);
-	list = &fl->commit_buckets[i];
+	list = &fl->commit_buckets[i].written;
 	if (list_empty(list)) {
-		/* Non-empty buckets hold a reference on the lseg */
+		/* Non-empty buckets hold a reference on the lseg.  That ref
+		 * is normally transferred to the COMMIT call and released
+		 * there.  It could also be released if the last req is pulled
+		 * off due to a rewrite, in which case it will be done in
+		 * filelayout_remove_commit_req
+		 */
 		get_lseg(lseg);
 	}
 	return list;
@@ -865,18 +893,56 @@ static int filelayout_initiate_commit(struct nfs_write_data *data, int how)
 /*
  * This is only useful while we are using whole file layouts.
  */
-static struct pnfs_layout_segment *find_only_write_lseg(struct inode *inode)
+static struct pnfs_layout_segment *
+find_only_write_lseg_locked(struct inode *inode)
 {
-	struct pnfs_layout_segment *lseg, *rv = NULL;
+	struct pnfs_layout_segment *lseg;
 
-	spin_lock(&inode->i_lock);
 	list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list)
 		if (lseg->pls_range.iomode == IOMODE_RW)
-			rv = get_lseg(lseg);
+			return get_lseg(lseg);
+	return NULL;
+}
+
+static struct pnfs_layout_segment *find_only_write_lseg(struct inode *inode)
+{
+	struct pnfs_layout_segment *rv;
+
+	spin_lock(&inode->i_lock);
+	rv = find_only_write_lseg_locked(inode);
 	spin_unlock(&inode->i_lock);
 	return rv;
 }
 
+/* Move reqs from written to committing lists, returning count of number moved.
+ * Note called with i_lock held.
+ */
+static int filelayout_scan_commit_lists(struct inode *inode, int max)
+{
+	struct pnfs_layout_segment *lseg;
+	struct nfs4_filelayout_segment *fl;
+	int i, rv = 0, cnt;
+
+	lseg = find_only_write_lseg_locked(inode);
+	if (!lseg)
+		return 0;
+	fl = FILELAYOUT_LSEG(lseg);
+	if (fl->commit_through_mds)
+		goto out_put;
+	for (i = 0; i < fl->number_of_buckets; i++) {
+		if (list_empty(&fl->commit_buckets[i].written))
+			continue;
+		cnt = nfs_scan_commit_list(&fl->commit_buckets[i].written,
+					   &fl->commit_buckets[i].committing,
+					   max);
+		max -= cnt;
+		rv += cnt;
+	}
+out_put:
+	put_lseg(lseg);
+	return rv;
+}
+
 static int alloc_ds_commits(struct inode *inode, struct list_head *list)
 {
 	struct pnfs_layout_segment *lseg;
@@ -891,7 +957,7 @@ static int alloc_ds_commits(struct inode *inode, struct list_head *list)
 		return 0;
 	fl = FILELAYOUT_LSEG(lseg);
 	for (i = 0; i < fl->number_of_buckets; i++) {
-		if (list_empty(&fl->commit_buckets[i]))
+		if (list_empty(&fl->commit_buckets[i].committing))
 			continue;
 		data = nfs_commitdata_alloc();
 		if (!data)
@@ -905,9 +971,9 @@ static int alloc_ds_commits(struct inode *inode, struct list_head *list)
 
 out_bad:
 	for (j = i; j < fl->number_of_buckets; j++) {
-		if (list_empty(&fl->commit_buckets[i]))
+		if (list_empty(&fl->commit_buckets[i].committing))
 			continue;
-		nfs_retry_commit(&fl->commit_buckets[i], lseg);
+		nfs_retry_commit(&fl->commit_buckets[i].committing, lseg);
 		put_lseg(lseg);  /* associated with emptying bucket */
 	}
 	put_lseg(lseg);
@@ -942,7 +1008,7 @@ filelayout_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
 			nfs_initiate_commit(data, NFS_CLIENT(inode),
 					    data->mds_ops, how);
 		} else {
-			nfs_init_commit(data, &FILELAYOUT_LSEG(data->lseg)->commit_buckets[data->ds_commit_index], data->lseg);
+			nfs_init_commit(data, &FILELAYOUT_LSEG(data->lseg)->commit_buckets[data->ds_commit_index].committing, data->lseg);
 			filelayout_initiate_commit(data, how);
 		}
 	}
@@ -972,8 +1038,9 @@ static struct pnfs_layoutdriver_type filelayout_type = {
 	.free_lseg		= filelayout_free_lseg,
 	.pg_read_ops		= &filelayout_pg_read_ops,
 	.pg_write_ops		= &filelayout_pg_write_ops,
-	.mark_pnfs_commit	= filelayout_mark_pnfs_commit,
 	.choose_commit_list	= filelayout_choose_commit_list,
+	.remove_commit_req	= filelayout_remove_commit_req,
+	.scan_commit_lists	= filelayout_scan_commit_lists,
 	.commit_pagelist	= filelayout_commit_pagelist,
 	.read_pagelist		= filelayout_read_pagelist,
 	.write_pagelist		= filelayout_write_pagelist,
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 2e42284..21190bb 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -74,6 +74,11 @@ struct nfs4_file_layout_dsaddr {
 	struct nfs4_pnfs_ds		*ds_list[1];
 };
 
+struct nfs4_fl_commit_bucket {
+	struct list_head written;
+	struct list_head committing;
+};
+
 struct nfs4_filelayout_segment {
 	struct pnfs_layout_segment generic_hdr;
 	u32 stripe_type;
@@ -84,7 +89,7 @@ struct nfs4_filelayout_segment {
 	struct nfs4_file_layout_dsaddr *dsaddr; /* Point to GETDEVINFO data */
 	unsigned int num_fh;
 	struct nfs_fh **fh_array;
-	struct list_head *commit_buckets; /* Sort commits to ds */
+	struct nfs4_fl_commit_bucket *commit_buckets; /* Sort commits to ds */
 	int number_of_buckets;
 };
 
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index fc5b54b..d21fcea 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -396,67 +396,6 @@ void nfs_pageio_cond_complete(struct nfs_pageio_descriptor *desc, pgoff_t index)
 	}
 }
 
-#define NFS_SCAN_MAXENTRIES 16
-/**
- * nfs_scan_list - Scan a list for matching requests
- * @nfsi: NFS inode
- * @dst: Destination list
- * @idx_start: lower bound of page->index to scan
- * @npages: idx_start + npages sets the upper bound to scan.
- * @tag: tag to scan for
- *
- * Moves elements from one of the inode request lists.
- * If the number of requests is set to 0, the entire address_space
- * starting at index idx_start, is scanned.
- * The requests are *not* checked to ensure that they form a contiguous set.
- * You must be holding the inode's i_lock when calling this function
- */
-int nfs_scan_list(struct nfs_inode *nfsi,
-		struct list_head *dst, pgoff_t idx_start,
-		unsigned int npages, int tag)
-{
-	struct nfs_page *pgvec[NFS_SCAN_MAXENTRIES];
-	struct nfs_page *req;
-	pgoff_t idx_end;
-	int found, i;
-	int res;
-	struct list_head *list;
-
-	res = 0;
-	if (npages == 0)
-		idx_end = ~0;
-	else
-		idx_end = idx_start + npages - 1;
-
-	for (;;) {
-		found = radix_tree_gang_lookup_tag(&nfsi->nfs_page_tree,
-				(void **)&pgvec[0], idx_start,
-				NFS_SCAN_MAXENTRIES, tag);
-		if (found <= 0)
-			break;
-		for (i = 0; i < found; i++) {
-			req = pgvec[i];
-			if (req->wb_index > idx_end)
-				goto out;
-			idx_start = req->wb_index + 1;
-			if (nfs_lock_request_dontget(req)) {
-				kref_get(&req->wb_kref);
-				radix_tree_tag_clear(&nfsi->nfs_page_tree,
-						req->wb_index, tag);
-				list = pnfs_choose_commit_list(req, dst);
-				nfs_list_add_request(req, list);
-				res++;
-				if (res == INT_MAX)
-					goto out;
-			}
-		}
-		/* for latency reduction */
-		cond_resched_lock(&nfsi->vfs_inode.i_lock);
-	}
-out:
-	return res;
-}
-
 int __init nfs_init_nfspagecache(void)
 {
 	nfs_page_cachep = kmem_cache_create("nfs_page",
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 8088d51..ef92f67 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -94,11 +94,10 @@ struct pnfs_layoutdriver_type {
 	const struct nfs_pageio_ops *pg_read_ops;
 	const struct nfs_pageio_ops *pg_write_ops;
 
-	/* Returns true if layoutdriver wants to divert this request to
-	 * driver's commit routine.
-	 */
-	bool (*mark_pnfs_commit)(struct pnfs_layout_segment *lseg);
-	struct list_head * (*choose_commit_list) (struct nfs_page *req);
+	struct list_head * (*choose_commit_list) (struct nfs_page *req,
+					struct pnfs_layout_segment *lseg);
+	struct pnfs_layout_segment *(*remove_commit_req) (struct nfs_page *req);
+	int (*scan_commit_lists) (struct inode *inode, int max);
 	int (*commit_pagelist)(struct inode *inode, struct list_head *mds_pages, int how);
 
 	/*
@@ -262,20 +261,6 @@ static inline int pnfs_enabled_sb(struct nfs_server *nfss)
 	return nfss->pnfs_curr_ld != NULL;
 }
 
-static inline void
-pnfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg)
-{
-	if (lseg) {
-		struct pnfs_layoutdriver_type *ld;
-
-		ld = NFS_SERVER(req->wb_page->mapping->host)->pnfs_curr_ld;
-		if (ld->mark_pnfs_commit && ld->mark_pnfs_commit(lseg)) {
-			set_bit(PG_PNFS_COMMIT, &req->wb_flags);
-			req->wb_commit_lseg = get_lseg(lseg);
-		}
-	}
-}
-
 static inline int
 pnfs_commit_list(struct inode *inode, struct list_head *mds_pages, int how)
 {
@@ -285,26 +270,38 @@ pnfs_commit_list(struct inode *inode, struct list_head *mds_pages, int how)
 }
 
 static inline struct list_head *
-pnfs_choose_commit_list(struct nfs_page *req, struct list_head *mds)
+pnfs_choose_commit_list(struct nfs_page *req, struct pnfs_layout_segment *lseg)
 {
+	struct inode *inode = req->wb_context->dentry->d_inode;
 	struct list_head *rv;
 
-	if (test_and_clear_bit(PG_PNFS_COMMIT, &req->wb_flags)) {
-		struct inode *inode = req->wb_commit_lseg->pls_layout->plh_inode;
-
-		set_bit(NFS_INO_PNFS_COMMIT, &NFS_I(inode)->flags);
-		rv = NFS_SERVER(inode)->pnfs_curr_ld->choose_commit_list(req);
-		/* matched by ref taken when PG_PNFS_COMMIT is set */
-		put_lseg(req->wb_commit_lseg);
-	} else
-		rv = mds;
+	if (lseg && NFS_SERVER(inode)->pnfs_curr_ld->choose_commit_list)
+		rv = NFS_SERVER(inode)->pnfs_curr_ld->choose_commit_list(req, lseg);
+	else
+		rv = &NFS_I(inode)->commit_list;
 	return rv;
 }
 
-static inline void pnfs_clear_request_commit(struct nfs_page *req)
+static inline struct pnfs_layout_segment *
+pnfs_clear_request_commit(struct nfs_page *req)
 {
-	if (test_and_clear_bit(PG_PNFS_COMMIT, &req->wb_flags))
-		put_lseg(req->wb_commit_lseg);
+	struct inode *inode = req->wb_context->dentry->d_inode;
+
+	if (NFS_SERVER(inode)->pnfs_curr_ld &&
+	    NFS_SERVER(inode)->pnfs_curr_ld->remove_commit_req)
+		return NFS_SERVER(inode)->pnfs_curr_ld->remove_commit_req(req);
+	else
+		return NULL;
+}
+
+static inline int
+pnfs_scan_commit_lists(struct inode *inode, int max)
+{
+	if (NFS_SERVER(inode)->pnfs_curr_ld &&
+	    NFS_SERVER(inode)->pnfs_curr_ld->scan_commit_lists)
+		return NFS_SERVER(inode)->pnfs_curr_ld->scan_commit_lists(inode, max);
+	else
+		return 0;
 }
 
 /* Should the pNFS client commit and return the layout upon a setattr */
@@ -400,11 +397,6 @@ static inline bool pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, st
 	return false;
 }
 
-static inline void
-pnfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg)
-{
-}
-
 static inline int
 pnfs_commit_list(struct inode *inode, struct list_head *mds_pages, int how)
 {
@@ -412,13 +404,23 @@ pnfs_commit_list(struct inode *inode, struct list_head *mds_pages, int how)
 }
 
 static inline struct list_head *
-pnfs_choose_commit_list(struct nfs_page *req, struct list_head *mds)
+pnfs_choose_commit_list(struct nfs_page *req, struct pnfs_layout_segment *lseg)
 {
-	return mds;
+	struct inode *inode = req->wb_context->dentry->d_inode;
+
+	return &NFS_I(inode)->commit_list;
 }
 
-static inline void pnfs_clear_request_commit(struct nfs_page *req)
+static inline struct pnfs_layout_segment *
+pnfs_clear_request_commit(struct nfs_page *req)
 {
+	return NULL;
+}
+
+static inline int
+pnfs_scan_commit_lists(struct inode *inode, int max)
+{
+	return 0;
 }
 
 static inline int pnfs_layoutcommit_inode(struct inode *inode, bool sync)
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index fd8a4f0..a630ad6 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -375,21 +375,14 @@ out_err:
 /*
  * Insert a write request into an inode
  */
-static int nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
+static void nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
-	int error;
-
-	error = radix_tree_preload(GFP_NOFS);
-	if (error != 0)
-		goto out;
 
 	/* Lock the request! */
 	nfs_lock_request_dontget(req);
 
 	spin_lock(&inode->i_lock);
-	error = radix_tree_insert(&nfsi->nfs_page_tree, req->wb_index, req);
-	BUG_ON(error);
 	if (!nfsi->npages && nfs_have_delegation(inode, FMODE_WRITE))
 		inode->i_version++;
 	set_bit(PG_MAPPED, &req->wb_flags);
@@ -398,11 +391,10 @@ static int nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
 	nfsi->npages++;
 	kref_get(&req->wb_kref);
 	spin_unlock(&inode->i_lock);
-	radix_tree_preload_end();
-out:
-	return error;
 }
 
+static struct pnfs_layout_segment *nfs_clear_request_commit(struct nfs_page *req);
+
 /*
  * Remove a write request from an inode
  */
@@ -410,16 +402,18 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 {
 	struct inode *inode = req->wb_context->dentry->d_inode;
 	struct nfs_inode *nfsi = NFS_I(inode);
+	struct pnfs_layout_segment *lseg;
 
 	BUG_ON (!NFS_WBACK_BUSY(req));
 
 	spin_lock(&inode->i_lock);
+	lseg = nfs_clear_request_commit(req);
 	set_page_private(req->wb_page, 0);
 	ClearPagePrivate(req->wb_page);
 	clear_bit(PG_MAPPED, &req->wb_flags);
-	radix_tree_delete(&nfsi->nfs_page_tree, req->wb_index);
 	nfsi->npages--;
 	spin_unlock(&inode->i_lock);
+	put_lseg(lseg);
 	nfs_release_request(req);
 }
 
@@ -438,31 +432,38 @@ nfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg)
 {
 	struct inode *inode = req->wb_context->dentry->d_inode;
 	struct nfs_inode *nfsi = NFS_I(inode);
+	struct list_head *clist;
 
+	clist = pnfs_choose_commit_list(req, lseg);
 	spin_lock(&inode->i_lock);
 	set_bit(PG_CLEAN, &(req)->wb_flags);
-	radix_tree_tag_set(&nfsi->nfs_page_tree,
-			req->wb_index,
-			NFS_PAGE_TAG_COMMIT);
+	nfs_list_add_request(req, clist);
 	nfsi->ncommit++;
 	spin_unlock(&inode->i_lock);
-	pnfs_mark_request_commit(req, lseg);
 	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_RECLAIMABLE);
 	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
 }
 
-static int
+static void
+nfs_clear_page_commit(struct page *page)
+{
+	dec_zone_page_state(page, NR_UNSTABLE_NFS);
+	dec_bdi_stat(page->mapping->backing_dev_info, BDI_RECLAIMABLE);
+}
+
+static struct pnfs_layout_segment *
 nfs_clear_request_commit(struct nfs_page *req)
 {
-	struct page *page = req->wb_page;
+	struct pnfs_layout_segment *lseg = NULL;
 
 	if (test_and_clear_bit(PG_CLEAN, &(req)->wb_flags)) {
-		dec_zone_page_state(page, NR_UNSTABLE_NFS);
-		dec_bdi_stat(page->mapping->backing_dev_info, BDI_RECLAIMABLE);
-		return 1;
+		nfs_clear_page_commit(req->wb_page);
+		lseg = pnfs_clear_request_commit(req);
+		NFS_I(req->wb_context->dentry->d_inode)->ncommit--;
+		list_del(&req->wb_list);
 	}
-	return 0;
+	return lseg;
 }
 
 static inline
@@ -494,10 +495,10 @@ nfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg)
 {
 }
 
-static inline int
+static inline struct pnfs_layout_segment *
 nfs_clear_request_commit(struct nfs_page *req)
 {
-	return 0;
+	return NULL;
 }
 
 static inline
@@ -518,46 +519,67 @@ int nfs_reschedule_unstable_write(struct nfs_page *req,
 static int
 nfs_need_commit(struct nfs_inode *nfsi)
 {
-	return radix_tree_tagged(&nfsi->nfs_page_tree, NFS_PAGE_TAG_COMMIT);
+	return nfsi->ncommit > 0;
 }
 
+/* i_lock held by caller */
+int
+nfs_scan_commit_list(struct list_head *src, struct list_head *dst, int max)
+{
+	struct nfs_page *req, *tmp;
+	int ret = 0;
+
+	list_for_each_entry_safe(req, tmp, src, wb_list) {
+		if (nfs_lock_request_dontget(req)) {
+			kref_get(&req->wb_kref);
+			list_move_tail(&req->wb_list, dst);
+			clear_bit(PG_CLEAN, &(req)->wb_flags);
+			ret++;
+			if (ret == max)
+				break;
+		}
+	}
+	return ret;
+}
+EXPORT_SYMBOL_GPL(nfs_scan_commit_list);
+
 /*
  * nfs_scan_commit - Scan an inode for commit requests
  * @inode: NFS inode to scan
  * @dst: destination list
- * @idx_start: lower bound of page->index to scan.
- * @npages: idx_start + npages sets the upper bound to scan.
  *
  * Moves requests from the inode's 'commit' request list.
  * The requests are *not* checked to ensure that they form a contiguous set.
  */
 static int
-nfs_scan_commit(struct inode *inode, struct list_head *dst, pgoff_t idx_start, unsigned int npages)
+nfs_scan_commit(struct inode *inode, struct list_head *dst)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
-	int ret;
-
-	if (!nfs_need_commit(nfsi))
-		return 0;
+	int ret = 0;
 
 	spin_lock(&inode->i_lock);
-	ret = nfs_scan_list(nfsi, dst, idx_start, npages, NFS_PAGE_TAG_COMMIT);
-	if (ret > 0)
+	if (nfsi->ncommit > 0) {
+		int pnfs_ret;
+
+		ret = nfs_scan_commit_list(&nfsi->commit_list, dst, INT_MAX);
+		pnfs_ret = pnfs_scan_commit_lists(inode, INT_MAX - ret);
+		if (pnfs_ret) {
+			ret += pnfs_ret;
+			set_bit(NFS_INO_PNFS_COMMIT, &nfsi->flags);
+		}
 		nfsi->ncommit -= ret;
+	}
 	spin_unlock(&inode->i_lock);
-
-	if (nfs_need_commit(NFS_I(inode)))
-		__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
-
 	return ret;
 }
+
 #else
 static inline int nfs_need_commit(struct nfs_inode *nfsi)
 {
 	return 0;
 }
 
-static inline int nfs_scan_commit(struct inode *inode, struct list_head *dst, pgoff_t idx_start, unsigned int npages)
+static inline int nfs_scan_commit(struct inode *inode, struct list_head *dst)
 {
 	return 0;
 }
@@ -579,6 +601,7 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 	unsigned int rqend;
 	unsigned int end;
 	int error;
+	struct pnfs_layout_segment *lseg = NULL;
 
 	if (!PagePrivate(page))
 		return NULL;
@@ -614,12 +637,7 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 		spin_lock(&inode->i_lock);
 	}
 
-	if (nfs_clear_request_commit(req) &&
-	    radix_tree_tag_clear(&NFS_I(inode)->nfs_page_tree,
-				 req->wb_index, NFS_PAGE_TAG_COMMIT) != NULL) {
-		NFS_I(inode)->ncommit--;
-		pnfs_clear_request_commit(req);
-	}
+	lseg = nfs_clear_request_commit(req);
 
 	/* Okay, the request matches. Update the region */
 	if (offset < req->wb_offset) {
@@ -632,6 +650,7 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 		req->wb_bytes = rqend - req->wb_offset;
 out_unlock:
 	spin_unlock(&inode->i_lock);
+	put_lseg(lseg);
 	return req;
 out_flushme:
 	spin_unlock(&inode->i_lock);
@@ -653,7 +672,6 @@ static struct nfs_page * nfs_setup_write_request(struct nfs_open_context* ctx,
 {
 	struct inode *inode = page->mapping->host;
 	struct nfs_page	*req;
-	int error;
 
 	req = nfs_try_to_update_request(inode, page, offset, bytes);
 	if (req != NULL)
@@ -661,11 +679,7 @@ static struct nfs_page * nfs_setup_write_request(struct nfs_open_context* ctx,
 	req = nfs_create_request(ctx, inode, page, offset, bytes);
 	if (IS_ERR(req))
 		goto out;
-	error = nfs_inode_add_request(inode, req);
-	if (error != 0) {
-		nfs_release_request(req);
-		req = ERR_PTR(error);
-	}
+	nfs_inode_add_request(inode, req);
 out:
 	return req;
 }
@@ -1458,7 +1472,7 @@ void nfs_commit_release_pages(struct nfs_write_data *data)
 	while (!list_empty(&data->pages)) {
 		req = nfs_list_entry(data->pages.next);
 		nfs_list_remove_request(req);
-		nfs_clear_request_commit(req);
+		nfs_clear_page_commit(req->wb_page);
 
 		dprintk("NFS:       commit (%s/%lld %d@%lld)",
 			req->wb_context->dentry->d_sb->s_id,
@@ -1515,7 +1529,7 @@ int nfs_commit_inode(struct inode *inode, int how)
 	res = nfs_commit_set_lock(NFS_I(inode), may_wait);
 	if (res <= 0)
 		goto out_mark_dirty;
-	res = nfs_scan_commit(inode, &head, 0, 0);
+	res = nfs_scan_commit(inode, &head);
 	if (res) {
 		int error;
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index ce8e436..0a63ab2 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -171,13 +171,9 @@ struct nfs_inode {
 	 */
 	__be32			cookieverf[2];
 
-	/*
-	 * This is the list of dirty unwritten pages.
-	 */
-	struct radix_tree_root	nfs_page_tree;
-
 	unsigned long		npages;
 	unsigned long		ncommit;
+	struct list_head	commit_list;
 
 	/* Open contexts for shared mmap writes */
 	struct list_head	open_files;
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 65b563f..50856e9 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -19,11 +19,6 @@
 #include <linux/kref.h>
 
 /*
- * Valid flags for the radix tree
- */
-#define NFS_PAGE_TAG_COMMIT	1
-
-/*
  * Valid flags for a dirty buffer
  */
 enum {
@@ -32,16 +27,12 @@ enum {
 	PG_CLEAN,
 	PG_NEED_COMMIT,
 	PG_NEED_RESCHED,
-	PG_PNFS_COMMIT,
 	PG_PARTIAL_READ_FAILED,
 };
 
 struct nfs_inode;
 struct nfs_page {
-	union {
-		struct list_head	wb_list;	/* Defines state of page: */
-		struct pnfs_layout_segment *wb_commit_lseg; /* Used when PG_PNFS_COMMIT set */
-	};
+	struct list_head	wb_list;	/* Defines state of page: */
 	struct page		*wb_page;	/* page to read in/write out */
 	struct nfs_open_context	*wb_context;	/* File state context info */
 	struct nfs_lock_context	*wb_lock_context;	/* lock context info */
@@ -89,8 +80,6 @@ extern	struct nfs_page *nfs_create_request(struct nfs_open_context *ctx,
 extern	void nfs_release_request(struct nfs_page *req);
 
 
-extern	int nfs_scan_list(struct nfs_inode *nfsi, struct list_head *dst,
-			  pgoff_t idx_start, unsigned int npages, int tag);
 extern	void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 			     struct inode *inode,
 			     const struct nfs_pageio_ops *pg_ops,
-- 
1.7.2.1


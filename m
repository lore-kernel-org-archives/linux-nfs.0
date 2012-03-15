Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:16283 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755998Ab2COX7v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Mar 2012 19:59:51 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH] NFSv4.1: Clean ups and bugfixes for the pNFS read/writeback/commit code
Date: Thu, 15 Mar 2012 19:59:43 -0400
Message-Id: <1331855983-24264-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move more pnfs-isms out of the generic commit code.

Bugfixes:

- filelayout_scan_commit_lists doesn't need to get/put the lseg.
  In fact since it is run under the inode->i_lock, the lseg_put()
  can deadlock.

- Ensure that we distinguish between what needs to be done for
  commit-to-data server and what needs to be done for commit-to-MDS
  using the new flag PG_COMMIT_TO_DS. Otherwise we may end up calling
  put_lseg() on a bucket for a struct nfs_page that got written
  through the MDS.

- Fix a case where we were using list_del() on an nfs_page->wb_list
  instead of list_del_init().

Cleanups:

- Let the files layout manage the commit lists for the pNFS case.
  Don't expose stuff like pnfs_choose_commit_list, and the fact
  that the commit buckets hold references to the layout segment
  in common code.

- Cast out the put_lseg() calls for the struct nfs_read/write_data->lseg
  into the pNFS layer from whence they came.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/internal.h        |    4 +-
 fs/nfs/nfs4filelayout.c  |   77 ++++++++++++++++++++++++-------
 fs/nfs/pnfs.c            |    3 +
 fs/nfs/pnfs.h            |   43 ++++++++---------
 fs/nfs/read.c            |    1 -
 fs/nfs/write.c           |  113 +++++++++++++++++++++++++++++-----------------
 include/linux/nfs_page.h |   11 +++++
 7 files changed, 168 insertions(+), 84 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 04a9147..2476dc6 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -308,8 +308,6 @@ extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
 extern void nfs_readdata_release(struct nfs_read_data *rdata);
 
 /* write.c */
-extern int nfs_scan_commit_list(struct list_head *src, struct list_head *dst,
-				int max);
 extern int nfs_generic_flush(struct nfs_pageio_descriptor *desc,
 		struct list_head *head);
 extern void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor *pgio,
@@ -334,6 +332,8 @@ void nfs_retry_commit(struct list_head *page_list,
 void nfs_commit_clear_lock(struct nfs_inode *nfsi);
 void nfs_commitdata_release(void *data);
 void nfs_commit_release_pages(struct nfs_write_data *data);
+void nfs_request_add_commit_list(struct nfs_page *req, struct list_head *head);
+void nfs_request_remove_commit_list(struct nfs_page *req);
 
 #ifdef CONFIG_MIGRATION
 extern int nfs_migrate_page(struct address_space *,
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 379a085..c210f02 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -224,6 +224,7 @@ static void filelayout_read_release(void *data)
 {
 	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
 
+	put_lseg(rdata->lseg);
 	rdata->mds_ops->rpc_release(data);
 }
 
@@ -310,6 +311,7 @@ static void filelayout_write_release(void *data)
 {
 	struct nfs_write_data *wdata = (struct nfs_write_data *)data;
 
+	put_lseg(wdata->lseg);
 	wdata->mds_ops->rpc_release(data);
 }
 
@@ -320,6 +322,7 @@ static void filelayout_commit_release(void *data)
 	nfs_commit_release_pages(wdata);
 	if (atomic_dec_and_test(&NFS_I(wdata->inode)->commits_outstanding))
 		nfs_commit_clear_lock(NFS_I(wdata->inode));
+	put_lseg(wdata->lseg);
 	nfs_commitdata_release(wdata);
 }
 
@@ -781,9 +784,15 @@ static u32 select_bucket_index(struct nfs4_filelayout_segment *fl, u32 j)
  * If this will make the bucket empty, it will need to put the lseg reference.
  * Note inode lock is held, so we can't do the put here.
  */
-static struct pnfs_layout_segment *
-filelayout_remove_commit_req(struct nfs_page *req)
+static void
+filelayout_clear_request_commit(struct nfs_page *req)
 {
+	struct pnfs_layout_segment *freeme = NULL;
+	struct inode *inode = req->wb_context->dentry->d_inode;
+
+	spin_lock(&inode->i_lock);
+	if (!test_and_clear_bit(PG_COMMIT_TO_DS, &req->wb_flags))
+		goto out;
 	if (list_is_singular(&req->wb_list)) {
 		struct inode *inode = req->wb_context->dentry->d_inode;
 		struct pnfs_layout_segment *lseg;
@@ -792,11 +801,16 @@ filelayout_remove_commit_req(struct nfs_page *req)
 		 * since there is only one relevant lseg...
 		 */
 		list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list) {
-			if (lseg->pls_range.iomode == IOMODE_RW)
-				return lseg;
+			if (lseg->pls_range.iomode == IOMODE_RW) {
+				freeme = lseg;
+				break;
+			}
 		}
 	}
-	return NULL;
+out:
+	nfs_request_remove_commit_list(req);
+	spin_unlock(&inode->i_lock);
+	put_lseg(freeme);
 }
 
 static struct list_head *
@@ -829,9 +843,20 @@ filelayout_choose_commit_list(struct nfs_page *req,
 		 */
 		get_lseg(lseg);
 	}
+	set_bit(PG_COMMIT_TO_DS, &req->wb_flags);
 	return list;
 }
 
+static void
+filelayout_mark_request_commit(struct nfs_page *req,
+		struct pnfs_layout_segment *lseg)
+{
+	struct list_head *list;
+
+	list = filelayout_choose_commit_list(req, lseg);
+	nfs_request_add_commit_list(req, list);
+}
+
 static u32 calc_ds_index_from_commit(struct pnfs_layout_segment *lseg, u32 i)
 {
 	struct nfs4_filelayout_segment *flseg = FILELAYOUT_LSEG(lseg);
@@ -895,7 +920,7 @@ find_only_write_lseg_locked(struct inode *inode)
 
 	list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list)
 		if (lseg->pls_range.iomode == IOMODE_RW)
-			return get_lseg(lseg);
+			return lseg;
 	return NULL;
 }
 
@@ -905,10 +930,33 @@ static struct pnfs_layout_segment *find_only_write_lseg(struct inode *inode)
 
 	spin_lock(&inode->i_lock);
 	rv = find_only_write_lseg_locked(inode);
+	if (rv)
+		get_lseg(rv);
 	spin_unlock(&inode->i_lock);
 	return rv;
 }
 
+static int
+filelayout_scan_ds_commit_list(struct nfs4_fl_commit_bucket *bucket, int max)
+{
+	struct list_head *src = &bucket->written;
+	struct list_head *dst = &bucket->committing;
+	struct nfs_page *req, *tmp;
+	int ret = 0;
+
+	list_for_each_entry_safe(req, tmp, src, wb_list) {
+		if (!nfs_lock_request(req))
+			continue;
+		nfs_request_remove_commit_list(req);
+		clear_bit(PG_COMMIT_TO_DS, &req->wb_flags);
+		nfs_list_add_request(req, dst);
+		ret++;
+		if (ret == max)
+			break;
+	}
+	return ret;
+}
+
 /* Move reqs from written to committing lists, returning count of number moved.
  * Note called with i_lock held.
  */
@@ -920,21 +968,16 @@ static int filelayout_scan_commit_lists(struct inode *inode, int max)
 
 	lseg = find_only_write_lseg_locked(inode);
 	if (!lseg)
-		return 0;
+		goto out_done;
 	fl = FILELAYOUT_LSEG(lseg);
 	if (fl->commit_through_mds)
-		goto out_put;
+		goto out_done;
 	for (i = 0; i < fl->number_of_buckets; i++) {
-		if (list_empty(&fl->commit_buckets[i].written))
-			continue;
-		cnt = nfs_scan_commit_list(&fl->commit_buckets[i].written,
-					   &fl->commit_buckets[i].committing,
-					   max);
+		cnt = filelayout_scan_ds_commit_list(&fl->commit_buckets[i], max);
 		max -= cnt;
 		rv += cnt;
 	}
-out_put:
-	put_lseg(lseg);
+out_done:
 	return rv;
 }
 
@@ -1033,8 +1076,8 @@ static struct pnfs_layoutdriver_type filelayout_type = {
 	.free_lseg		= filelayout_free_lseg,
 	.pg_read_ops		= &filelayout_pg_read_ops,
 	.pg_write_ops		= &filelayout_pg_write_ops,
-	.choose_commit_list	= filelayout_choose_commit_list,
-	.remove_commit_req	= filelayout_remove_commit_req,
+	.mark_request_commit	= filelayout_mark_request_commit,
+	.clear_request_commit	= filelayout_clear_request_commit,
 	.scan_commit_lists	= filelayout_scan_commit_lists,
 	.commit_pagelist	= filelayout_commit_pagelist,
 	.read_pagelist		= filelayout_read_pagelist,
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6f1c1e3..b5d4515 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1210,6 +1210,7 @@ void pnfs_ld_write_done(struct nfs_write_data *data)
 		}
 		data->task.tk_status = pnfs_write_done_resend_to_mds(data->inode, &data->pages);
 	}
+	put_lseg(data->lseg);
 	data->mds_ops->rpc_release(data);
 }
 EXPORT_SYMBOL_GPL(pnfs_ld_write_done);
@@ -1223,6 +1224,7 @@ pnfs_write_through_mds(struct nfs_pageio_descriptor *desc,
 		nfs_list_add_request(data->req, &desc->pg_list);
 	nfs_pageio_reset_write_mds(desc);
 	desc->pg_recoalesce = 1;
+	put_lseg(data->lseg);
 	nfs_writedata_release(data);
 }
 
@@ -1323,6 +1325,7 @@ void pnfs_ld_read_done(struct nfs_read_data *data)
 		data->mds_ops->rpc_call_done(&data->task, data);
 	} else
 		pnfs_ld_handle_read_error(data);
+	put_lseg(data->lseg);
 	data->mds_ops->rpc_release(data);
 }
 EXPORT_SYMBOL_GPL(pnfs_ld_read_done);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index ef92f67..bdcf77c 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -94,9 +94,9 @@ struct pnfs_layoutdriver_type {
 	const struct nfs_pageio_ops *pg_read_ops;
 	const struct nfs_pageio_ops *pg_write_ops;
 
-	struct list_head * (*choose_commit_list) (struct nfs_page *req,
+	void (*mark_request_commit) (struct nfs_page *req,
 					struct pnfs_layout_segment *lseg);
-	struct pnfs_layout_segment *(*remove_commit_req) (struct nfs_page *req);
+	void (*clear_request_commit) (struct nfs_page *req);
 	int (*scan_commit_lists) (struct inode *inode, int max);
 	int (*commit_pagelist)(struct inode *inode, struct list_head *mds_pages, int how);
 
@@ -269,29 +269,28 @@ pnfs_commit_list(struct inode *inode, struct list_head *mds_pages, int how)
 	return NFS_SERVER(inode)->pnfs_curr_ld->commit_pagelist(inode, mds_pages, how);
 }
 
-static inline struct list_head *
-pnfs_choose_commit_list(struct nfs_page *req, struct pnfs_layout_segment *lseg)
+static inline bool
+pnfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg)
 {
 	struct inode *inode = req->wb_context->dentry->d_inode;
-	struct list_head *rv;
+	struct pnfs_layoutdriver_type *ld = NFS_SERVER(inode)->pnfs_curr_ld;
 
-	if (lseg && NFS_SERVER(inode)->pnfs_curr_ld->choose_commit_list)
-		rv = NFS_SERVER(inode)->pnfs_curr_ld->choose_commit_list(req, lseg);
-	else
-		rv = &NFS_I(inode)->commit_list;
-	return rv;
+	if (lseg == NULL || ld->mark_request_commit == NULL)
+		return false;
+	ld->mark_request_commit(req, lseg);
+	return true;
 }
 
-static inline struct pnfs_layout_segment *
+static inline bool
 pnfs_clear_request_commit(struct nfs_page *req)
 {
 	struct inode *inode = req->wb_context->dentry->d_inode;
+	struct pnfs_layoutdriver_type *ld = NFS_SERVER(inode)->pnfs_curr_ld;
 
-	if (NFS_SERVER(inode)->pnfs_curr_ld &&
-	    NFS_SERVER(inode)->pnfs_curr_ld->remove_commit_req)
-		return NFS_SERVER(inode)->pnfs_curr_ld->remove_commit_req(req);
-	else
-		return NULL;
+	if (ld == NULL || ld->clear_request_commit == NULL)
+		return false;
+	ld->clear_request_commit(req);
+	return true;
 }
 
 static inline int
@@ -403,18 +402,16 @@ pnfs_commit_list(struct inode *inode, struct list_head *mds_pages, int how)
 	return PNFS_NOT_ATTEMPTED;
 }
 
-static inline struct list_head *
-pnfs_choose_commit_list(struct nfs_page *req, struct pnfs_layout_segment *lseg)
+static inline bool
+pnfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg)
 {
-	struct inode *inode = req->wb_context->dentry->d_inode;
-
-	return &NFS_I(inode)->commit_list;
+	return false;
 }
 
-static inline struct pnfs_layout_segment *
+static inline bool
 pnfs_clear_request_commit(struct nfs_page *req)
 {
-	return NULL;
+	return false;
 }
 
 static inline int
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 3c2540d..2662c02 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -66,7 +66,6 @@ void nfs_readdata_free(struct nfs_read_data *p)
 
 void nfs_readdata_release(struct nfs_read_data *rdata)
 {
-	put_lseg(rdata->lseg);
 	put_nfs_open_context(rdata->args.context);
 	nfs_readdata_free(rdata);
 }
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index a630ad6..6f55281 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -100,7 +100,6 @@ void nfs_writedata_free(struct nfs_write_data *p)
 
 void nfs_writedata_release(struct nfs_write_data *wdata)
 {
-	put_lseg(wdata->lseg);
 	put_nfs_open_context(wdata->args.context);
 	nfs_writedata_free(wdata);
 }
@@ -393,8 +392,6 @@ static void nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
 	spin_unlock(&inode->i_lock);
 }
 
-static struct pnfs_layout_segment *nfs_clear_request_commit(struct nfs_page *req);
-
 /*
  * Remove a write request from an inode
  */
@@ -402,18 +399,15 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 {
 	struct inode *inode = req->wb_context->dentry->d_inode;
 	struct nfs_inode *nfsi = NFS_I(inode);
-	struct pnfs_layout_segment *lseg;
 
 	BUG_ON (!NFS_WBACK_BUSY(req));
 
 	spin_lock(&inode->i_lock);
-	lseg = nfs_clear_request_commit(req);
 	set_page_private(req->wb_page, 0);
 	ClearPagePrivate(req->wb_page);
 	clear_bit(PG_MAPPED, &req->wb_flags);
 	nfsi->npages--;
 	spin_unlock(&inode->i_lock);
-	put_lseg(lseg);
 	nfs_release_request(req);
 }
 
@@ -424,26 +418,68 @@ nfs_mark_request_dirty(struct nfs_page *req)
 }
 
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
-/*
- * Add a request to the inode's commit list.
+/**
+ * nfs_request_add_commit_list - add request to a commit list
+ * @req: pointer to a struct nfs_page
+ * @head: commit list head
+ *
+ * This sets the PG_CLEAN bit, updates the inode global count of
+ * number of outstanding requests requiring a commit as well as
+ * the MM page stats.
+ *
+ * The caller must _not_ hold the inode->i_lock.
  */
-static void
-nfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg)
+void
+nfs_request_add_commit_list(struct nfs_page *req, struct list_head *head)
 {
 	struct inode *inode = req->wb_context->dentry->d_inode;
-	struct nfs_inode *nfsi = NFS_I(inode);
-	struct list_head *clist;
 
-	clist = pnfs_choose_commit_list(req, lseg);
-	spin_lock(&inode->i_lock);
 	set_bit(PG_CLEAN, &(req)->wb_flags);
-	nfs_list_add_request(req, clist);
-	nfsi->ncommit++;
+	spin_lock(&inode->i_lock);
+	nfs_list_add_request(req, head);
+	NFS_I(inode)->ncommit++;
 	spin_unlock(&inode->i_lock);
 	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_RECLAIMABLE);
 	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
 }
+EXPORT_SYMBOL_GPL(nfs_request_add_commit_list);
+
+/**
+ * nfs_request_remove_commit_list - Remove request from a commit list
+ * @req: pointer to a nfs_page
+ *
+ * This clears the PG_CLEAN bit, and updates the inode global count of
+ * number of outstanding requests requiring a commit
+ * It does not update the MM page stats.
+ *
+ * The caller _must_ hold the inode->i_lock.
+ */
+void
+nfs_request_remove_commit_list(struct nfs_page *req)
+{
+	struct inode *inode = req->wb_context->dentry->d_inode;
+
+	if (!test_and_clear_bit(PG_CLEAN, &(req)->wb_flags))
+		return;
+	nfs_list_remove_request(req);
+	NFS_I(inode)->ncommit--;
+}
+EXPORT_SYMBOL_GPL(nfs_request_remove_commit_list);
+
+
+/*
+ * Add a request to the inode's commit list.
+ */
+static void
+nfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg)
+{
+	struct inode *inode = req->wb_context->dentry->d_inode;
+
+	if (pnfs_mark_request_commit(req, lseg))
+		return;
+	nfs_request_add_commit_list(req, &NFS_I(inode)->commit_list);
+}
 
 static void
 nfs_clear_page_commit(struct page *page)
@@ -452,18 +488,19 @@ nfs_clear_page_commit(struct page *page)
 	dec_bdi_stat(page->mapping->backing_dev_info, BDI_RECLAIMABLE);
 }
 
-static struct pnfs_layout_segment *
+static void
 nfs_clear_request_commit(struct nfs_page *req)
 {
-	struct pnfs_layout_segment *lseg = NULL;
+	if (test_bit(PG_CLEAN, &req->wb_flags)) {
+		struct inode *inode = req->wb_context->dentry->d_inode;
 
-	if (test_and_clear_bit(PG_CLEAN, &(req)->wb_flags)) {
+		if (!pnfs_clear_request_commit(req)) {
+			spin_lock(&inode->i_lock);
+			nfs_request_remove_commit_list(req);
+			spin_unlock(&inode->i_lock);
+		}
 		nfs_clear_page_commit(req->wb_page);
-		lseg = pnfs_clear_request_commit(req);
-		NFS_I(req->wb_context->dentry->d_inode)->ncommit--;
-		list_del(&req->wb_list);
 	}
-	return lseg;
 }
 
 static inline
@@ -490,15 +527,14 @@ int nfs_reschedule_unstable_write(struct nfs_page *req,
 	return 0;
 }
 #else
-static inline void
+static void
 nfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg)
 {
 }
 
-static inline struct pnfs_layout_segment *
+static void
 nfs_clear_request_commit(struct nfs_page *req)
 {
-	return NULL;
 }
 
 static inline
@@ -523,25 +559,23 @@ nfs_need_commit(struct nfs_inode *nfsi)
 }
 
 /* i_lock held by caller */
-int
+static int
 nfs_scan_commit_list(struct list_head *src, struct list_head *dst, int max)
 {
 	struct nfs_page *req, *tmp;
 	int ret = 0;
 
 	list_for_each_entry_safe(req, tmp, src, wb_list) {
-		if (nfs_lock_request_dontget(req)) {
-			kref_get(&req->wb_kref);
-			list_move_tail(&req->wb_list, dst);
-			clear_bit(PG_CLEAN, &(req)->wb_flags);
-			ret++;
-			if (ret == max)
-				break;
-		}
+		if (!nfs_lock_request(req))
+			continue;
+		nfs_request_remove_commit_list(req);
+		nfs_list_add_request(req, dst);
+		ret++;
+		if (ret == max)
+			break;
 	}
 	return ret;
 }
-EXPORT_SYMBOL_GPL(nfs_scan_commit_list);
 
 /*
  * nfs_scan_commit - Scan an inode for commit requests
@@ -601,7 +635,6 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 	unsigned int rqend;
 	unsigned int end;
 	int error;
-	struct pnfs_layout_segment *lseg = NULL;
 
 	if (!PagePrivate(page))
 		return NULL;
@@ -637,8 +670,6 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 		spin_lock(&inode->i_lock);
 	}
 
-	lseg = nfs_clear_request_commit(req);
-
 	/* Okay, the request matches. Update the region */
 	if (offset < req->wb_offset) {
 		req->wb_offset = offset;
@@ -650,7 +681,7 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 		req->wb_bytes = rqend - req->wb_offset;
 out_unlock:
 	spin_unlock(&inode->i_lock);
-	put_lseg(lseg);
+	nfs_clear_request_commit(req);
 	return req;
 out_flushme:
 	spin_unlock(&inode->i_lock);
@@ -1337,7 +1368,6 @@ void nfs_commitdata_release(void *data)
 {
 	struct nfs_write_data *wdata = data;
 
-	put_lseg(wdata->lseg);
 	put_nfs_open_context(wdata->args.context);
 	nfs_commit_free(wdata);
 }
@@ -1647,6 +1677,7 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 		if (req == NULL)
 			break;
 		if (nfs_lock_request_dontget(req)) {
+			nfs_clear_request_commit(req);
 			nfs_inode_remove_request(req);
 			/*
 			 * In case nfs_inode_remove_request has marked the
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 50856e9..eac30d6 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -28,6 +28,7 @@ enum {
 	PG_NEED_COMMIT,
 	PG_NEED_RESCHED,
 	PG_PARTIAL_READ_FAILED,
+	PG_COMMIT_TO_DS,
 };
 
 struct nfs_inode;
@@ -104,6 +105,16 @@ nfs_lock_request_dontget(struct nfs_page *req)
 	return !test_and_set_bit(PG_BUSY, &req->wb_flags);
 }
 
+static inline int
+nfs_lock_request(struct nfs_page *req)
+{
+	if (test_and_set_bit(PG_BUSY, &req->wb_flags))
+		return 0;
+	kref_get(&req->wb_kref);
+	return 1;
+}
+
+
 /**
  * nfs_list_add_request - Insert a request into a list
  * @req: request
-- 
1.7.7.6


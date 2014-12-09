Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f178.google.com ([209.85.192.178]:34441 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752298AbaLIULP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Dec 2014 15:11:15 -0500
Received: by mail-pd0-f178.google.com with SMTP id r10so1204278pdi.37
        for <linux-nfs@vger.kernel.org>; Tue, 09 Dec 2014 12:11:14 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] pnfs: Prepare for flexfiles by pulling out common code
Date: Tue,  9 Dec 2014 12:11:04 -0800
Message-Id: <1418155864-111389-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The flexfilelayout driver will share some common code
with the filelayout driver. This set of changes refactors
that common code out to avoid any module depenencies.

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfs/filelayout/filelayout.c    | 290 ++------------------------------------
 fs/nfs/filelayout/filelayout.h    |  11 --
 fs/nfs/filelayout/filelayoutdev.c |   2 +-
 fs/nfs/pnfs.c                     | 274 +++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.h                     |  21 +++
 5 files changed, 310 insertions(+), 288 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 7afb52f..4af9acc 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -118,13 +118,6 @@ static void filelayout_reset_read(struct nfs_pgio_header *hdr)
 	}
 }
 
-static void filelayout_fenceme(struct inode *inode, struct pnfs_layout_hdr *lo)
-{
-	if (!test_and_clear_bit(NFS_LAYOUT_RETURN, &lo->plh_flags))
-		return;
-	pnfs_return_layout(inode);
-}
-
 static int filelayout_async_handle_error(struct rpc_task *task,
 					 struct nfs4_state *state,
 					 struct nfs_client *clp,
@@ -339,16 +332,6 @@ static void filelayout_read_count_stats(struct rpc_task *task, void *data)
 	rpc_count_iostats(task, NFS_SERVER(hdr->inode)->client->cl_metrics);
 }
 
-static void filelayout_read_release(void *data)
-{
-	struct nfs_pgio_header *hdr = data;
-	struct pnfs_layout_hdr *lo = hdr->lseg->pls_layout;
-
-	filelayout_fenceme(lo->plh_inode, lo);
-	nfs_put_client(hdr->ds_clp);
-	hdr->mds_ops->rpc_release(data);
-}
-
 static int filelayout_write_done_cb(struct rpc_task *task,
 				struct nfs_pgio_header *hdr)
 {
@@ -371,17 +354,6 @@ static int filelayout_write_done_cb(struct rpc_task *task,
 	return 0;
 }
 
-/* Fake up some data that will cause nfs_commit_release to retry the writes. */
-static void prepare_to_resend_writes(struct nfs_commit_data *data)
-{
-	struct nfs_page *first = nfs_list_entry(data->pages.next);
-
-	data->task.tk_status = 0;
-	memcpy(&data->verf.verifier, &first->wb_verf,
-	       sizeof(data->verf.verifier));
-	data->verf.verifier.data[0]++; /* ensure verifier mismatch */
-}
-
 static int filelayout_commit_done_cb(struct rpc_task *task,
 				     struct nfs_commit_data *data)
 {
@@ -393,7 +365,7 @@ static int filelayout_commit_done_cb(struct rpc_task *task,
 
 	switch (err) {
 	case -NFS4ERR_RESET_TO_MDS:
-		prepare_to_resend_writes(data);
+		pnfs_ld_prepare_to_resend_writes(data);
 		return -EAGAIN;
 	case -EAGAIN:
 		rpc_restart_call_prepare(task);
@@ -451,16 +423,6 @@ static void filelayout_write_count_stats(struct rpc_task *task, void *data)
 	rpc_count_iostats(task, NFS_SERVER(hdr->inode)->client->cl_metrics);
 }
 
-static void filelayout_write_release(void *data)
-{
-	struct nfs_pgio_header *hdr = data;
-	struct pnfs_layout_hdr *lo = hdr->lseg->pls_layout;
-
-	filelayout_fenceme(lo->plh_inode, lo);
-	nfs_put_client(hdr->ds_clp);
-	hdr->mds_ops->rpc_release(data);
-}
-
 static void filelayout_commit_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs_commit_data *wdata = data;
@@ -471,14 +433,6 @@ static void filelayout_commit_prepare(struct rpc_task *task, void *data)
 			task);
 }
 
-static void filelayout_write_commit_done(struct rpc_task *task, void *data)
-{
-	struct nfs_commit_data *wdata = data;
-
-	/* Note this may cause RPC to be resent */
-	wdata->mds_ops->rpc_call_done(task, data);
-}
-
 static void filelayout_commit_count_stats(struct rpc_task *task, void *data)
 {
 	struct nfs_commit_data *cdata = data;
@@ -486,35 +440,25 @@ static void filelayout_commit_count_stats(struct rpc_task *task, void *data)
 	rpc_count_iostats(task, NFS_SERVER(cdata->inode)->client->cl_metrics);
 }
 
-static void filelayout_commit_release(void *calldata)
-{
-	struct nfs_commit_data *data = calldata;
-
-	data->completion_ops->completion(data);
-	pnfs_put_lseg(data->lseg);
-	nfs_put_client(data->ds_clp);
-	nfs_commitdata_release(data);
-}
-
 static const struct rpc_call_ops filelayout_read_call_ops = {
 	.rpc_call_prepare = filelayout_read_prepare,
 	.rpc_call_done = filelayout_read_call_done,
 	.rpc_count_stats = filelayout_read_count_stats,
-	.rpc_release = filelayout_read_release,
+	.rpc_release = pnfs_ld_rw_release,
 };
 
 static const struct rpc_call_ops filelayout_write_call_ops = {
 	.rpc_call_prepare = filelayout_write_prepare,
 	.rpc_call_done = filelayout_write_call_done,
 	.rpc_count_stats = filelayout_write_count_stats,
-	.rpc_release = filelayout_write_release,
+	.rpc_release = pnfs_ld_rw_release,
 };
 
 static const struct rpc_call_ops filelayout_commit_call_ops = {
 	.rpc_call_prepare = filelayout_commit_prepare,
-	.rpc_call_done = filelayout_write_commit_done,
+	.rpc_call_done = pnfs_ld_write_commit_done,
 	.rpc_count_stats = filelayout_commit_count_stats,
-	.rpc_release = filelayout_commit_release,
+	.rpc_release = pnfs_ld_commit_release,
 };
 
 static enum pnfs_try_status
@@ -1004,33 +948,6 @@ static u32 select_bucket_index(struct nfs4_filelayout_segment *fl, u32 j)
 		return j;
 }
 
-/* The generic layer is about to remove the req from the commit list.
- * If this will make the bucket empty, it will need to put the lseg reference.
- * Note this is must be called holding the inode (/cinfo) lock
- */
-static void
-filelayout_clear_request_commit(struct nfs_page *req,
-				struct nfs_commit_info *cinfo)
-{
-	struct pnfs_layout_segment *freeme = NULL;
-
-	if (!test_and_clear_bit(PG_COMMIT_TO_DS, &req->wb_flags))
-		goto out;
-	cinfo->ds->nwritten--;
-	if (list_is_singular(&req->wb_list)) {
-		struct pnfs_commit_bucket *bucket;
-
-		bucket = list_first_entry(&req->wb_list,
-					  struct pnfs_commit_bucket,
-					  written);
-		freeme = bucket->wlseg;
-		bucket->wlseg = NULL;
-	}
-out:
-	nfs_request_remove_commit_list(req, cinfo);
-	pnfs_put_lseg_locked(freeme);
-}
-
 static void
 filelayout_mark_request_commit(struct nfs_page *req,
 			       struct pnfs_layout_segment *lseg,
@@ -1064,7 +981,7 @@ filelayout_mark_request_commit(struct nfs_page *req,
 		 * is normally transferred to the COMMIT call and released
 		 * there.  It could also be released if the last req is pulled
 		 * off due to a rewrite, in which case it will be done in
-		 * filelayout_clear_request_commit
+		 * pnfs_ld_clear_request_commit
 		 */
 		buckets[i].wlseg = pnfs_get_lseg(lseg);
 	}
@@ -1142,97 +1059,11 @@ static int filelayout_initiate_commit(struct nfs_commit_data *data, int how)
 				   &filelayout_commit_call_ops, how,
 				   RPC_TASK_SOFTCONN);
 out_err:
-	prepare_to_resend_writes(data);
-	filelayout_commit_release(data);
+	pnfs_ld_prepare_to_resend_writes(data);
+	pnfs_ld_commit_release(data);
 	return -EAGAIN;
 }
 
-static int
-transfer_commit_list(struct list_head *src, struct list_head *dst,
-		     struct nfs_commit_info *cinfo, int max)
-{
-	struct nfs_page *req, *tmp;
-	int ret = 0;
-
-	list_for_each_entry_safe(req, tmp, src, wb_list) {
-		if (!nfs_lock_request(req))
-			continue;
-		kref_get(&req->wb_kref);
-		if (cond_resched_lock(cinfo->lock))
-			list_safe_reset_next(req, tmp, wb_list);
-		nfs_request_remove_commit_list(req, cinfo);
-		clear_bit(PG_COMMIT_TO_DS, &req->wb_flags);
-		nfs_list_add_request(req, dst);
-		ret++;
-		if ((ret == max) && !cinfo->dreq)
-			break;
-	}
-	return ret;
-}
-
-/* Note called with cinfo->lock held. */
-static int
-filelayout_scan_ds_commit_list(struct pnfs_commit_bucket *bucket,
-			       struct nfs_commit_info *cinfo,
-			       int max)
-{
-	struct list_head *src = &bucket->written;
-	struct list_head *dst = &bucket->committing;
-	int ret;
-
-	ret = transfer_commit_list(src, dst, cinfo, max);
-	if (ret) {
-		cinfo->ds->nwritten -= ret;
-		cinfo->ds->ncommitting += ret;
-		bucket->clseg = bucket->wlseg;
-		if (list_empty(src))
-			bucket->wlseg = NULL;
-		else
-			pnfs_get_lseg(bucket->clseg);
-	}
-	return ret;
-}
-
-/* Move reqs from written to committing lists, returning count of number moved.
- * Note called with cinfo->lock held.
- */
-static int filelayout_scan_commit_lists(struct nfs_commit_info *cinfo,
-					int max)
-{
-	int i, rv = 0, cnt;
-
-	for (i = 0; i < cinfo->ds->nbuckets && max != 0; i++) {
-		cnt = filelayout_scan_ds_commit_list(&cinfo->ds->buckets[i],
-						     cinfo, max);
-		max -= cnt;
-		rv += cnt;
-	}
-	return rv;
-}
-
-/* Pull everything off the committing lists and dump into @dst */
-static void filelayout_recover_commit_reqs(struct list_head *dst,
-					   struct nfs_commit_info *cinfo)
-{
-	struct pnfs_commit_bucket *b;
-	struct pnfs_layout_segment *freeme;
-	int i;
-
-restart:
-	spin_lock(cinfo->lock);
-	for (i = 0, b = cinfo->ds->buckets; i < cinfo->ds->nbuckets; i++, b++) {
-		if (transfer_commit_list(&b->written, dst, cinfo, 0)) {
-			freeme = b->wlseg;
-			b->wlseg = NULL;
-			spin_unlock(cinfo->lock);
-			pnfs_put_lseg(freeme);
-			goto restart;
-		}
-	}
-	cinfo->ds->nwritten = 0;
-	spin_unlock(cinfo->lock);
-}
-
 /* filelayout_search_commit_reqs - Search lists in @cinfo for the head reqest
  *				   for @page
  * @cinfo - commit info for current inode
@@ -1263,108 +1094,15 @@ filelayout_search_commit_reqs(struct nfs_commit_info *cinfo, struct page *page)
 	return NULL;
 }
 
-static void filelayout_retry_commit(struct nfs_commit_info *cinfo, int idx)
-{
-	struct pnfs_ds_commit_info *fl_cinfo = cinfo->ds;
-	struct pnfs_commit_bucket *bucket;
-	struct pnfs_layout_segment *freeme;
-	int i;
-
-	for (i = idx; i < fl_cinfo->nbuckets; i++) {
-		bucket = &fl_cinfo->buckets[i];
-		if (list_empty(&bucket->committing))
-			continue;
-		nfs_retry_commit(&bucket->committing, bucket->clseg, cinfo);
-		spin_lock(cinfo->lock);
-		freeme = bucket->clseg;
-		bucket->clseg = NULL;
-		spin_unlock(cinfo->lock);
-		pnfs_put_lseg(freeme);
-	}
-}
-
-static unsigned int
-alloc_ds_commits(struct nfs_commit_info *cinfo, struct list_head *list)
-{
-	struct pnfs_ds_commit_info *fl_cinfo;
-	struct pnfs_commit_bucket *bucket;
-	struct nfs_commit_data *data;
-	int i;
-	unsigned int nreq = 0;
-
-	fl_cinfo = cinfo->ds;
-	bucket = fl_cinfo->buckets;
-	for (i = 0; i < fl_cinfo->nbuckets; i++, bucket++) {
-		if (list_empty(&bucket->committing))
-			continue;
-		data = nfs_commitdata_alloc();
-		if (!data)
-			break;
-		data->ds_commit_index = i;
-		spin_lock(cinfo->lock);
-		data->lseg = bucket->clseg;
-		bucket->clseg = NULL;
-		spin_unlock(cinfo->lock);
-		list_add(&data->pages, list);
-		nreq++;
-	}
-
-	/* Clean up on error */
-	filelayout_retry_commit(cinfo, i);
-	/* Caller will clean up entries put on list */
-	return nreq;
-}
-
 /* This follows nfs_commit_list pretty closely */
 static int
 filelayout_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
 			   int how, struct nfs_commit_info *cinfo)
 {
-	struct nfs_commit_data *data, *tmp;
-	LIST_HEAD(list);
-	unsigned int nreq = 0;
-
-	if (!list_empty(mds_pages)) {
-		data = nfs_commitdata_alloc();
-		if (data != NULL) {
-			data->lseg = NULL;
-			list_add(&data->pages, &list);
-			nreq++;
-		} else {
-			nfs_retry_commit(mds_pages, NULL, cinfo);
-			filelayout_retry_commit(cinfo, 0);
-			cinfo->completion_ops->error_cleanup(NFS_I(inode));
-			return -ENOMEM;
-		}
-	}
-
-	nreq += alloc_ds_commits(cinfo, &list);
-
-	if (nreq == 0) {
-		cinfo->completion_ops->error_cleanup(NFS_I(inode));
-		goto out;
-	}
-
-	atomic_add(nreq, &cinfo->mds->rpcs_out);
-
-	list_for_each_entry_safe(data, tmp, &list, pages) {
-		list_del_init(&data->pages);
-		if (!data->lseg) {
-			nfs_init_commit(data, mds_pages, NULL, cinfo);
-			nfs_initiate_commit(NFS_CLIENT(inode), data,
-					    data->mds_ops, how, 0);
-		} else {
-			struct pnfs_commit_bucket *buckets;
-
-			buckets = cinfo->ds->buckets;
-			nfs_init_commit(data, &buckets[data->ds_commit_index].committing, data->lseg, cinfo);
-			filelayout_initiate_commit(data, how);
-		}
-	}
-out:
-	cinfo->ds->ncommitting = 0;
-	return PNFS_ATTEMPTED;
+	return pnfs_ld_commit_pagelist(inode, mds_pages, how, cinfo,
+				       filelayout_initiate_commit);
 }
+
 static struct nfs4_deviceid_node *
 filelayout_alloc_deviceid_node(struct nfs_server *server,
 		struct pnfs_device *pdev, gfp_t gfp_flags)
@@ -1421,9 +1159,9 @@ static struct pnfs_layoutdriver_type filelayout_type = {
 	.pg_write_ops		= &filelayout_pg_write_ops,
 	.get_ds_info		= &filelayout_get_ds_info,
 	.mark_request_commit	= filelayout_mark_request_commit,
-	.clear_request_commit	= filelayout_clear_request_commit,
-	.scan_commit_lists	= filelayout_scan_commit_lists,
-	.recover_commit_reqs	= filelayout_recover_commit_reqs,
+	.clear_request_commit	= pnfs_ld_clear_request_commit,
+	.scan_commit_lists	= pnfs_ld_scan_commit_lists,
+	.recover_commit_reqs	= pnfs_ld_recover_commit_reqs,
 	.search_commit_reqs	= filelayout_search_commit_reqs,
 	.commit_pagelist	= filelayout_commit_pagelist,
 	.read_pagelist		= filelayout_read_pagelist,
diff --git a/fs/nfs/filelayout/filelayout.h b/fs/nfs/filelayout/filelayout.h
index 7c9f800..a5ce9b4 100644
--- a/fs/nfs/filelayout/filelayout.h
+++ b/fs/nfs/filelayout/filelayout.h
@@ -119,17 +119,6 @@ FILELAYOUT_DEVID_NODE(struct pnfs_layout_segment *lseg)
 	return &FILELAYOUT_LSEG(lseg)->dsaddr->id_node;
 }
 
-static inline void
-filelayout_mark_devid_invalid(struct nfs4_deviceid_node *node)
-{
-	u32 *p = (u32 *)&node->deviceid;
-
-	printk(KERN_WARNING "NFS: Deviceid [%x%x%x%x] marked out of use.\n",
-		p[0], p[1], p[2], p[3]);
-
-	set_bit(NFS_DEVICEID_INVALID, &node->flags);
-}
-
 static inline bool
 filelayout_test_devid_invalid(struct nfs4_deviceid_node *node)
 {
diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/filelayoutdev.c
index bfecac7..6cb3451 100644
--- a/fs/nfs/filelayout/filelayoutdev.c
+++ b/fs/nfs/filelayout/filelayoutdev.c
@@ -708,7 +708,7 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 	if (ds == NULL) {
 		printk(KERN_ERR "NFS: %s: No data server for offset index %d\n",
 			__func__, ds_idx);
-		filelayout_mark_devid_invalid(devid);
+		pnfs_ld_mark_devid_invalid(devid);
 		goto out;
 	}
 	smp_rmb();
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0a5dda4..ae858fc 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1978,3 +1978,277 @@ struct nfs4_threshold *pnfs_mdsthreshold_alloc(void)
 	}
 	return thp;
 }
+
+static void pnfs_ld_fenceme(struct inode *inode, struct pnfs_layout_hdr *lo)
+{
+	if (!test_and_clear_bit(NFS_LAYOUT_RETURN, &lo->plh_flags))
+		return;
+	pnfs_return_layout(inode);
+}
+
+void pnfs_ld_rw_release(void *data)
+{
+	struct nfs_pgio_header *hdr = data;
+	struct pnfs_layout_hdr *lo = hdr->lseg->pls_layout;
+
+	pnfs_ld_fenceme(lo->plh_inode, lo);
+	nfs_put_client(hdr->ds_clp);
+	hdr->mds_ops->rpc_release(data);
+}
+EXPORT_SYMBOL_GPL(pnfs_ld_rw_release);
+
+/* Fake up some data that will cause nfs_commit_release to retry the writes. */
+void pnfs_ld_prepare_to_resend_writes(struct nfs_commit_data *data)
+{
+	struct nfs_page *first = nfs_list_entry(data->pages.next);
+
+	data->task.tk_status = 0;
+	memcpy(&data->verf.verifier, &first->wb_verf,
+	       sizeof(data->verf.verifier));
+	data->verf.verifier.data[0]++; /* ensure verifier mismatch */
+}
+EXPORT_SYMBOL_GPL(pnfs_ld_prepare_to_resend_writes);
+
+void pnfs_ld_write_commit_done(struct rpc_task *task, void *data)
+{
+	struct nfs_commit_data *wdata = data;
+
+	/* Note this may cause RPC to be resent */
+	wdata->mds_ops->rpc_call_done(task, data);
+}
+EXPORT_SYMBOL_GPL(pnfs_ld_write_commit_done);
+
+void pnfs_ld_commit_release(void *calldata)
+{
+	struct nfs_commit_data *data = calldata;
+
+	data->completion_ops->completion(data);
+	pnfs_put_lseg(data->lseg);
+	nfs_put_client(data->ds_clp);
+	nfs_commitdata_release(data);
+}
+EXPORT_SYMBOL_GPL(pnfs_ld_commit_release);
+
+/* The generic layer is about to remove the req from the commit list.
+ * If this will make the bucket empty, it will need to put the lseg reference.
+ * Note this is must be called holding the inode (/cinfo) lock
+ */
+void
+pnfs_ld_clear_request_commit(struct nfs_page *req,
+			     struct nfs_commit_info *cinfo)
+{
+	struct pnfs_layout_segment *freeme = NULL;
+
+	if (!test_and_clear_bit(PG_COMMIT_TO_DS, &req->wb_flags))
+		goto out;
+	cinfo->ds->nwritten--;
+	if (list_is_singular(&req->wb_list)) {
+		struct pnfs_commit_bucket *bucket;
+
+		bucket = list_first_entry(&req->wb_list,
+					  struct pnfs_commit_bucket,
+					  written);
+		freeme = bucket->wlseg;
+		bucket->wlseg = NULL;
+	}
+out:
+	nfs_request_remove_commit_list(req, cinfo);
+	pnfs_put_lseg_locked(freeme);
+}
+EXPORT_SYMBOL_GPL(pnfs_ld_clear_request_commit);
+
+static int
+pnfs_ld_transfer_commit_list(struct list_head *src, struct list_head *dst,
+			     struct nfs_commit_info *cinfo, int max)
+{
+	struct nfs_page *req, *tmp;
+	int ret = 0;
+
+	list_for_each_entry_safe(req, tmp, src, wb_list) {
+		if (!nfs_lock_request(req))
+			continue;
+		kref_get(&req->wb_kref);
+		if (cond_resched_lock(cinfo->lock))
+			list_safe_reset_next(req, tmp, wb_list);
+		nfs_request_remove_commit_list(req, cinfo);
+		clear_bit(PG_COMMIT_TO_DS, &req->wb_flags);
+		nfs_list_add_request(req, dst);
+		ret++;
+		if ((ret == max) && !cinfo->dreq)
+			break;
+	}
+	return ret;
+}
+
+/* Note called with cinfo->lock held. */
+static int
+pnfs_ld_scan_ds_commit_list(struct pnfs_commit_bucket *bucket,
+			    struct nfs_commit_info *cinfo,
+			    int max)
+{
+	struct list_head *src = &bucket->written;
+	struct list_head *dst = &bucket->committing;
+	int ret;
+
+	ret = pnfs_ld_transfer_commit_list(src, dst, cinfo, max);
+	if (ret) {
+		cinfo->ds->nwritten -= ret;
+		cinfo->ds->ncommitting += ret;
+		bucket->clseg = bucket->wlseg;
+		if (list_empty(src))
+			bucket->wlseg = NULL;
+		else
+			pnfs_get_lseg(bucket->clseg);
+	}
+	return ret;
+}
+
+/* Move reqs from written to committing lists, returning count of number moved.
+ * Note called with cinfo->lock held.
+ */
+int pnfs_ld_scan_commit_lists(struct nfs_commit_info *cinfo,
+			      int max)
+{
+	int i, rv = 0, cnt;
+
+	for (i = 0; i < cinfo->ds->nbuckets && max != 0; i++) {
+		cnt = pnfs_ld_scan_ds_commit_list(&cinfo->ds->buckets[i],
+						  cinfo, max);
+		max -= cnt;
+		rv += cnt;
+	}
+	return rv;
+}
+EXPORT_SYMBOL_GPL(pnfs_ld_scan_commit_lists);
+
+/* Pull everything off the committing lists and dump into @dst */
+void pnfs_ld_recover_commit_reqs(struct list_head *dst,
+				 struct nfs_commit_info *cinfo)
+{
+	struct pnfs_commit_bucket *b;
+	struct pnfs_layout_segment *freeme;
+	int i;
+
+restart:
+	spin_lock(cinfo->lock);
+	for (i = 0, b = cinfo->ds->buckets; i < cinfo->ds->nbuckets; i++, b++) {
+		if (pnfs_ld_transfer_commit_list(&b->written, dst, cinfo, 0)) {
+			freeme = b->wlseg;
+			b->wlseg = NULL;
+			spin_unlock(cinfo->lock);
+			pnfs_put_lseg(freeme);
+			goto restart;
+		}
+	}
+	cinfo->ds->nwritten = 0;
+	spin_unlock(cinfo->lock);
+}
+EXPORT_SYMBOL_GPL(pnfs_ld_recover_commit_reqs);
+
+static void pnfs_ld_retry_commit(struct nfs_commit_info *cinfo, int idx)
+{
+	struct pnfs_ds_commit_info *fl_cinfo = cinfo->ds;
+	struct pnfs_commit_bucket *bucket;
+	struct pnfs_layout_segment *freeme;
+	int i;
+
+	for (i = idx; i < fl_cinfo->nbuckets; i++) {
+		bucket = &fl_cinfo->buckets[i];
+		if (list_empty(&bucket->committing))
+			continue;
+		nfs_retry_commit(&bucket->committing, bucket->clseg, cinfo);
+		spin_lock(cinfo->lock);
+		freeme = bucket->clseg;
+		bucket->clseg = NULL;
+		spin_unlock(cinfo->lock);
+		pnfs_put_lseg(freeme);
+	}
+}
+
+static unsigned int
+pnfs_ld_alloc_ds_commits(struct nfs_commit_info *cinfo, struct list_head *list)
+{
+	struct pnfs_ds_commit_info *fl_cinfo;
+	struct pnfs_commit_bucket *bucket;
+	struct nfs_commit_data *data;
+	int i;
+	unsigned int nreq = 0;
+
+	fl_cinfo = cinfo->ds;
+	bucket = fl_cinfo->buckets;
+	for (i = 0; i < fl_cinfo->nbuckets; i++, bucket++) {
+		if (list_empty(&bucket->committing))
+			continue;
+		data = nfs_commitdata_alloc();
+		if (!data)
+			break;
+		data->ds_commit_index = i;
+		spin_lock(cinfo->lock);
+		data->lseg = bucket->clseg;
+		bucket->clseg = NULL;
+		spin_unlock(cinfo->lock);
+		list_add(&data->pages, list);
+		nreq++;
+	}
+
+	/* Clean up on error */
+	pnfs_ld_retry_commit(cinfo, i);
+	return nreq;
+}
+
+/* This follows nfs_commit_list pretty closely */
+int
+pnfs_ld_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
+			int how, struct nfs_commit_info *cinfo,
+			int (*initiate_commit)(struct nfs_commit_data *data,
+					       int how))
+{
+	struct nfs_commit_data *data, *tmp;
+	LIST_HEAD(list);
+	unsigned int nreq = 0;
+
+	if (!list_empty(mds_pages)) {
+		data = nfs_commitdata_alloc();
+		if (data != NULL) {
+			data->lseg = NULL;
+			list_add(&data->pages, &list);
+			nreq++;
+		} else {
+			nfs_retry_commit(mds_pages, NULL, cinfo);
+			pnfs_ld_retry_commit(cinfo, 0);
+			cinfo->completion_ops->error_cleanup(NFS_I(inode));
+			return -ENOMEM;
+		}
+	}
+
+	nreq += pnfs_ld_alloc_ds_commits(cinfo, &list);
+
+	if (nreq == 0) {
+		cinfo->completion_ops->error_cleanup(NFS_I(inode));
+		goto out;
+	}
+
+	atomic_add(nreq, &cinfo->mds->rpcs_out);
+
+	list_for_each_entry_safe(data, tmp, &list, pages) {
+		list_del_init(&data->pages);
+		if (!data->lseg) {
+			nfs_init_commit(data, mds_pages, NULL, cinfo);
+			nfs_initiate_commit(NFS_CLIENT(inode), data,
+					    data->mds_ops, how, 0);
+		} else {
+			struct pnfs_commit_bucket *buckets;
+
+			buckets = cinfo->ds->buckets;
+			nfs_init_commit(data,
+					&buckets[data->ds_commit_index].committing,
+					data->lseg,
+					cinfo);
+			initiate_commit(data, how);
+		}
+	}
+out:
+	cinfo->ds->ncommitting = 0;
+	return PNFS_ATTEMPTED;
+}
+EXPORT_SYMBOL_GPL(pnfs_ld_commit_pagelist);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 9ae5b76..d9bae31 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -229,6 +229,21 @@ void pnfs_set_layoutcommit(struct nfs_pgio_header *);
 void pnfs_commit_set_layoutcommit(struct nfs_commit_data *data);
 void pnfs_cleanup_layoutcommit(struct nfs4_layoutcommit_data *data);
 int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
+void pnfs_ld_clear_request_commit(struct nfs_page *req,
+				  struct nfs_commit_info *cinfo);
+void pnfs_ld_commit_release(void *calldata);
+void pnfs_ld_prepare_to_resend_writes(struct nfs_commit_data *data);
+void pnfs_ld_rw_release(void *data);
+void pnfs_ld_recover_commit_reqs(struct list_head *dst,
+				 struct nfs_commit_info *cinfo);
+int pnfs_ld_commit_pagelist(struct inode *inode,
+			    struct list_head *mds_pages,
+			    int how,
+			    struct nfs_commit_info *cinfo,
+			    int (*initiate_commit)(struct nfs_commit_data *data,
+						   int how));
+int pnfs_ld_scan_commit_lists(struct nfs_commit_info *cinfo, int max);
+void pnfs_ld_write_commit_done(struct rpc_task *task, void *data);
 int _pnfs_return_layout(struct inode *);
 int pnfs_commit_and_return_layout(struct inode *);
 void pnfs_ld_write_done(struct nfs_pgio_header *);
@@ -317,6 +332,12 @@ pnfs_get_ds_info(struct inode *inode)
 	return ld->get_ds_info(inode);
 }
 
+static inline void
+pnfs_ld_mark_devid_invalid(struct nfs4_deviceid_node *node)
+{
+	set_bit(NFS_DEVICEID_INVALID, &node->flags);
+}
+
 static inline bool
 pnfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg,
 			 struct nfs_commit_info *cinfo)
-- 
1.9.3


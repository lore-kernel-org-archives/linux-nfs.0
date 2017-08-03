Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:37853 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751944AbdHCNqA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 09:46:00 -0400
Received: by mail-io0-f194.google.com with SMTP id c74so1293810iod.4
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 06:46:00 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 21/28] NFSv4: Use a mutex to protect the per-inode commit lists
Date: Thu,  3 Aug 2017 09:45:16 -0400
Message-Id: <20170803134523.4922-22-trond.myklebust@primarydata.com>
In-Reply-To: <20170803134523.4922-21-trond.myklebust@primarydata.com>
References: <20170803134523.4922-1-trond.myklebust@primarydata.com>
 <20170803134523.4922-2-trond.myklebust@primarydata.com>
 <20170803134523.4922-3-trond.myklebust@primarydata.com>
 <20170803134523.4922-4-trond.myklebust@primarydata.com>
 <20170803134523.4922-5-trond.myklebust@primarydata.com>
 <20170803134523.4922-6-trond.myklebust@primarydata.com>
 <20170803134523.4922-7-trond.myklebust@primarydata.com>
 <20170803134523.4922-8-trond.myklebust@primarydata.com>
 <20170803134523.4922-9-trond.myklebust@primarydata.com>
 <20170803134523.4922-10-trond.myklebust@primarydata.com>
 <20170803134523.4922-11-trond.myklebust@primarydata.com>
 <20170803134523.4922-12-trond.myklebust@primarydata.com>
 <20170803134523.4922-13-trond.myklebust@primarydata.com>
 <20170803134523.4922-14-trond.myklebust@primarydata.com>
 <20170803134523.4922-15-trond.myklebust@primarydata.com>
 <20170803134523.4922-16-trond.myklebust@primarydata.com>
 <20170803134523.4922-17-trond.myklebust@primarydata.com>
 <20170803134523.4922-18-trond.myklebust@primarydata.com>
 <20170803134523.4922-19-trond.myklebust@primarydata.com>
 <20170803134523.4922-20-trond.myklebust@primarydata.com>
 <20170803134523.4922-21-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The commit lists can get very large, so using the inode->i_lock can
end up affecting general metadata performance.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/direct.c        |  4 ++--
 fs/nfs/inode.c         |  1 +
 fs/nfs/pnfs_nfs.c      | 15 +++++++--------
 fs/nfs/write.c         | 24 ++++++++++++------------
 include/linux/nfs_fs.h |  1 +
 5 files changed, 23 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 6fb9fad2d1e6..d2972d537469 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -616,13 +616,13 @@ nfs_direct_write_scan_commit_list(struct inode *inode,
 				  struct list_head *list,
 				  struct nfs_commit_info *cinfo)
 {
-	spin_lock(&cinfo->inode->i_lock);
+	mutex_lock(&NFS_I(cinfo->inode)->commit_mutex);
 #ifdef CONFIG_NFS_V4_1
 	if (cinfo->ds != NULL && cinfo->ds->nwritten != 0)
 		NFS_SERVER(inode)->pnfs_curr_ld->recover_commit_reqs(list, cinfo);
 #endif
 	nfs_scan_commit_list(&cinfo->mds->list, list, cinfo, 0);
-	spin_unlock(&cinfo->inode->i_lock);
+	mutex_unlock(&NFS_I(cinfo->inode)->commit_mutex);
 }
 
 static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 109279d6d91b..34d9ebbc0dfd 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -2016,6 +2016,7 @@ static void init_once(void *foo)
 	nfsi->commit_info.ncommit = 0;
 	atomic_set(&nfsi->commit_info.rpcs_out, 0);
 	init_rwsem(&nfsi->rmdir_sem);
+	mutex_init(&nfsi->commit_mutex);
 	nfs4_init_once(nfsi);
 }
 
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 25f28fa64c57..2cdee8ce2094 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -98,14 +98,13 @@ pnfs_generic_transfer_commit_list(struct list_head *src, struct list_head *dst,
 		if (!nfs_lock_request(req))
 			continue;
 		kref_get(&req->wb_kref);
-		if (cond_resched_lock(&cinfo->inode->i_lock))
-			list_safe_reset_next(req, tmp, wb_list);
 		nfs_request_remove_commit_list(req, cinfo);
 		clear_bit(PG_COMMIT_TO_DS, &req->wb_flags);
 		nfs_list_add_request(req, dst);
 		ret++;
 		if ((ret == max) && !cinfo->dreq)
 			break;
+		cond_resched();
 	}
 	return ret;
 }
@@ -119,7 +118,7 @@ pnfs_generic_scan_ds_commit_list(struct pnfs_commit_bucket *bucket,
 	struct list_head *dst = &bucket->committing;
 	int ret;
 
-	lockdep_assert_held(&cinfo->inode->i_lock);
+	lockdep_assert_held(&NFS_I(cinfo->inode)->commit_mutex);
 	ret = pnfs_generic_transfer_commit_list(src, dst, cinfo, max);
 	if (ret) {
 		cinfo->ds->nwritten -= ret;
@@ -142,7 +141,7 @@ int pnfs_generic_scan_commit_lists(struct nfs_commit_info *cinfo,
 {
 	int i, rv = 0, cnt;
 
-	lockdep_assert_held(&cinfo->inode->i_lock);
+	lockdep_assert_held(&NFS_I(cinfo->inode)->commit_mutex);
 	for (i = 0; i < cinfo->ds->nbuckets && max != 0; i++) {
 		cnt = pnfs_generic_scan_ds_commit_list(&cinfo->ds->buckets[i],
 						       cinfo, max);
@@ -162,7 +161,7 @@ void pnfs_generic_recover_commit_reqs(struct list_head *dst,
 	int nwritten;
 	int i;
 
-	lockdep_assert_held(&cinfo->inode->i_lock);
+	lockdep_assert_held(&NFS_I(cinfo->inode)->commit_mutex);
 restart:
 	for (i = 0, b = cinfo->ds->buckets; i < cinfo->ds->nbuckets; i++, b++) {
 		nwritten = pnfs_generic_transfer_commit_list(&b->written,
@@ -953,12 +952,12 @@ pnfs_layout_mark_request_commit(struct nfs_page *req,
 	struct list_head *list;
 	struct pnfs_commit_bucket *buckets;
 
-	spin_lock(&cinfo->inode->i_lock);
+	mutex_lock(&NFS_I(cinfo->inode)->commit_mutex);
 	buckets = cinfo->ds->buckets;
 	list = &buckets[ds_commit_idx].written;
 	if (list_empty(list)) {
 		if (!pnfs_is_valid_lseg(lseg)) {
-			spin_unlock(&cinfo->inode->i_lock);
+			mutex_unlock(&NFS_I(cinfo->inode)->commit_mutex);
 			cinfo->completion_ops->resched_write(cinfo, req);
 			return;
 		}
@@ -975,7 +974,7 @@ pnfs_layout_mark_request_commit(struct nfs_page *req,
 	cinfo->ds->nwritten++;
 
 	nfs_request_add_commit_list_locked(req, list, cinfo);
-	spin_unlock(&cinfo->inode->i_lock);
+	mutex_unlock(&NFS_I(cinfo->inode)->commit_mutex);
 	nfs_mark_page_unstable(req->wb_page, cinfo);
 }
 EXPORT_SYMBOL_GPL(pnfs_layout_mark_request_commit);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 8d8fa6d4cfcc..5ab5ca24b48a 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -195,7 +195,7 @@ nfs_page_find_swap_request(struct page *page)
 	struct nfs_page *req = NULL;
 	if (!PageSwapCache(page))
 		return NULL;
-	spin_lock(&inode->i_lock);
+	mutex_lock(&nfsi->commit_mutex);
 	if (PageSwapCache(page)) {
 		req = nfs_page_search_commits_for_head_request_locked(nfsi,
 			page);
@@ -204,7 +204,7 @@ nfs_page_find_swap_request(struct page *page)
 			kref_get(&req->wb_kref);
 		}
 	}
-	spin_unlock(&inode->i_lock);
+	mutex_unlock(&nfsi->commit_mutex);
 	return req;
 }
 
@@ -856,7 +856,8 @@ nfs_page_search_commits_for_head_request_locked(struct nfs_inode *nfsi,
  * number of outstanding requests requiring a commit as well as
  * the MM page stats.
  *
- * The caller must hold cinfo->inode->i_lock, and the nfs_page lock.
+ * The caller must hold NFS_I(cinfo->inode)->commit_mutex, and the
+ * nfs_page lock.
  */
 void
 nfs_request_add_commit_list_locked(struct nfs_page *req, struct list_head *dst,
@@ -884,9 +885,9 @@ EXPORT_SYMBOL_GPL(nfs_request_add_commit_list_locked);
 void
 nfs_request_add_commit_list(struct nfs_page *req, struct nfs_commit_info *cinfo)
 {
-	spin_lock(&cinfo->inode->i_lock);
+	mutex_lock(&NFS_I(cinfo->inode)->commit_mutex);
 	nfs_request_add_commit_list_locked(req, &cinfo->mds->list, cinfo);
-	spin_unlock(&cinfo->inode->i_lock);
+	mutex_unlock(&NFS_I(cinfo->inode)->commit_mutex);
 	if (req->wb_page)
 		nfs_mark_page_unstable(req->wb_page, cinfo);
 }
@@ -964,11 +965,11 @@ nfs_clear_request_commit(struct nfs_page *req)
 		struct nfs_commit_info cinfo;
 
 		nfs_init_cinfo_from_inode(&cinfo, inode);
-		spin_lock(&inode->i_lock);
+		mutex_lock(&NFS_I(inode)->commit_mutex);
 		if (!pnfs_clear_request_commit(req, &cinfo)) {
 			nfs_request_remove_commit_list(req, &cinfo);
 		}
-		spin_unlock(&inode->i_lock);
+		mutex_unlock(&NFS_I(inode)->commit_mutex);
 		nfs_clear_page_commit(req->wb_page);
 	}
 }
@@ -1027,7 +1028,7 @@ nfs_reqs_to_commit(struct nfs_commit_info *cinfo)
 	return cinfo->mds->ncommit;
 }
 
-/* cinfo->inode->i_lock held by caller */
+/* NFS_I(cinfo->inode)->commit_mutex held by caller */
 int
 nfs_scan_commit_list(struct list_head *src, struct list_head *dst,
 		     struct nfs_commit_info *cinfo, int max)
@@ -1039,13 +1040,12 @@ nfs_scan_commit_list(struct list_head *src, struct list_head *dst,
 		if (!nfs_lock_request(req))
 			continue;
 		kref_get(&req->wb_kref);
-		if (cond_resched_lock(&cinfo->inode->i_lock))
-			list_safe_reset_next(req, tmp, wb_list);
 		nfs_request_remove_commit_list(req, cinfo);
 		nfs_list_add_request(req, dst);
 		ret++;
 		if ((ret == max) && !cinfo->dreq)
 			break;
+		cond_resched();
 	}
 	return ret;
 }
@@ -1065,7 +1065,7 @@ nfs_scan_commit(struct inode *inode, struct list_head *dst,
 {
 	int ret = 0;
 
-	spin_lock(&cinfo->inode->i_lock);
+	mutex_lock(&NFS_I(cinfo->inode)->commit_mutex);
 	if (cinfo->mds->ncommit > 0) {
 		const int max = INT_MAX;
 
@@ -1073,7 +1073,7 @@ nfs_scan_commit(struct inode *inode, struct list_head *dst,
 					   cinfo, max);
 		ret += pnfs_scan_commit_lists(inode, cinfo, max - ret);
 	}
-	spin_unlock(&cinfo->inode->i_lock);
+	mutex_unlock(&NFS_I(cinfo->inode)->commit_mutex);
 	return ret;
 }
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 5cc91d6381a3..121a702888b4 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -163,6 +163,7 @@ struct nfs_inode {
 	/* Readers: in-flight sillydelete RPC calls */
 	/* Writers: rmdir */
 	struct rw_semaphore	rmdir_sem;
+	struct mutex		commit_mutex;
 
 #if IS_ENABLED(CONFIG_NFS_V4)
 	struct nfs4_cached_acl	*nfs4_acl;
-- 
2.13.3


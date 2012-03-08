Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55779 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753889Ab2CHW3j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Mar 2012 17:29:39 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/2] NFS: remove NFS_PAGE_TAG_LOCKED
Date: Thu,  8 Mar 2012 17:29:34 -0500
Message-Id: <1331245775-1995-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The last real use of this tag was removed by
commit 7f2f12d963 NFS: Simplify nfs_wb_page()

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pagelist.c        |   32 +-------------------------------
 fs/nfs/write.c           |   20 +++++++++-----------
 include/linux/nfs_page.h |    3 ---
 3 files changed, 10 insertions(+), 45 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 77a184e..fc5b54b 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -107,36 +107,6 @@ void nfs_unlock_request(struct nfs_page *req)
 	nfs_release_request(req);
 }
 
-/**
- * nfs_set_page_tag_locked - Tag a request as locked
- * @req:
- */
-int nfs_set_page_tag_locked(struct nfs_page *req)
-{
-	if (!nfs_lock_request_dontget(req))
-		return 0;
-	if (test_bit(PG_MAPPED, &req->wb_flags))
-		radix_tree_tag_set(&NFS_I(req->wb_context->dentry->d_inode)->nfs_page_tree, req->wb_index, NFS_PAGE_TAG_LOCKED);
-	return 1;
-}
-
-/**
- * nfs_clear_page_tag_locked - Clear request tag and wake up sleepers
- */
-void nfs_clear_page_tag_locked(struct nfs_page *req)
-{
-	if (test_bit(PG_MAPPED, &req->wb_flags)) {
-		struct inode *inode = req->wb_context->dentry->d_inode;
-		struct nfs_inode *nfsi = NFS_I(inode);
-
-		spin_lock(&inode->i_lock);
-		radix_tree_tag_clear(&nfsi->nfs_page_tree, req->wb_index, NFS_PAGE_TAG_LOCKED);
-		nfs_unlock_request(req);
-		spin_unlock(&inode->i_lock);
-	} else
-		nfs_unlock_request(req);
-}
-
 /*
  * nfs_clear_request - Free up all resources allocated to the request
  * @req:
@@ -469,7 +439,7 @@ int nfs_scan_list(struct nfs_inode *nfsi,
 			if (req->wb_index > idx_end)
 				goto out;
 			idx_start = req->wb_index + 1;
-			if (nfs_set_page_tag_locked(req)) {
+			if (nfs_lock_request_dontget(req)) {
 				kref_get(&req->wb_kref);
 				radix_tree_tag_clear(&nfsi->nfs_page_tree,
 						req->wb_index, tag);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0b1831d..fd8a4f0 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -236,10 +236,10 @@ static struct nfs_page *nfs_find_and_lock_request(struct page *page, bool nonblo
 		req = nfs_page_find_request_locked(page);
 		if (req == NULL)
 			break;
-		if (nfs_set_page_tag_locked(req))
+		if (nfs_lock_request_dontget(req))
 			break;
 		/* Note: If we hold the page lock, as is the case in nfs_writepage,
-		 *	 then the call to nfs_set_page_tag_locked() will always
+		 *	 then the call to nfs_lock_request_dontget() will always
 		 *	 succeed provided that someone hasn't already marked the
 		 *	 request as dirty (in which case we don't care).
 		 */
@@ -397,8 +397,6 @@ static int nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
 	set_page_private(req->wb_page, (unsigned long)req);
 	nfsi->npages++;
 	kref_get(&req->wb_kref);
-	radix_tree_tag_set(&nfsi->nfs_page_tree, req->wb_index,
-				NFS_PAGE_TAG_LOCKED);
 	spin_unlock(&inode->i_lock);
 	radix_tree_preload_end();
 out:
@@ -604,7 +602,7 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 		    || end < req->wb_offset)
 			goto out_flushme;
 
-		if (nfs_set_page_tag_locked(req))
+		if (nfs_lock_request_dontget(req))
 			break;
 
 		/* The request is locked, so wait and then retry */
@@ -684,7 +682,7 @@ static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
 	nfs_grow_file(page, offset, count);
 	nfs_mark_uptodate(page, req->wb_pgbase, req->wb_bytes);
 	nfs_mark_request_dirty(req);
-	nfs_clear_page_tag_locked(req);
+	nfs_unlock_request(req);
 	return 0;
 }
 
@@ -777,7 +775,7 @@ static void nfs_writepage_release(struct nfs_page *req,
 
 	if (PageError(req->wb_page) || !nfs_reschedule_unstable_write(req, data))
 		nfs_inode_remove_request(req);
-	nfs_clear_page_tag_locked(req);
+	nfs_unlock_request(req);
 	nfs_end_page_writeback(page);
 }
 
@@ -925,7 +923,7 @@ static void nfs_redirty_request(struct nfs_page *req)
 	struct page *page = req->wb_page;
 
 	nfs_mark_request_dirty(req);
-	nfs_clear_page_tag_locked(req);
+	nfs_unlock_request(req);
 	nfs_end_page_writeback(page);
 }
 
@@ -1199,7 +1197,7 @@ static void nfs_writeback_release_full(void *calldata)
 remove_request:
 		nfs_inode_remove_request(req);
 	next:
-		nfs_clear_page_tag_locked(req);
+		nfs_unlock_request(req);
 		nfs_end_page_writeback(page);
 	}
 	nfs_writedata_release(calldata);
@@ -1411,7 +1409,7 @@ void nfs_retry_commit(struct list_head *page_list,
 		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
 			     BDI_RECLAIMABLE);
-		nfs_clear_page_tag_locked(req);
+		nfs_unlock_request(req);
 	}
 }
 EXPORT_SYMBOL_GPL(nfs_retry_commit);
@@ -1486,7 +1484,7 @@ void nfs_commit_release_pages(struct nfs_write_data *data)
 		dprintk(" mismatch\n");
 		nfs_mark_request_dirty(req);
 	next:
-		nfs_clear_page_tag_locked(req);
+		nfs_unlock_request(req);
 	}
 }
 EXPORT_SYMBOL_GPL(nfs_commit_release_pages);
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index ab465fe..65b563f 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -21,7 +21,6 @@
 /*
  * Valid flags for the radix tree
  */
-#define NFS_PAGE_TAG_LOCKED	0
 #define NFS_PAGE_TAG_COMMIT	1
 
 /*
@@ -106,8 +105,6 @@ extern bool nfs_generic_pg_test(struct nfs_pageio_descriptor *desc,
 				struct nfs_page *req);
 extern  int nfs_wait_on_request(struct nfs_page *);
 extern	void nfs_unlock_request(struct nfs_page *req);
-extern	int nfs_set_page_tag_locked(struct nfs_page *req);
-extern  void nfs_clear_page_tag_locked(struct nfs_page *req);
 
 /*
  * Lock the page of an asynchronous request without getting a new reference
-- 
1.7.2.1


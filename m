Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:30151 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756932Ab2EITSv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 May 2012 15:18:51 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 3/5] NFS: Clean up - simplify nfs_lock_request()
Date: Wed,  9 May 2012 15:18:41 -0400
Message-Id: <1336591123-23400-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1336591123-23400-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1336591123-23400-1-git-send-email-Trond.Myklebust@netapp.com>
 <1336591123-23400-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We only have two places where we need to grab a reference when trying
to lock the nfs_page. We're better off making that explicit.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/direct.c          |    1 +
 fs/nfs/write.c           |   11 ++++++-----
 include/linux/nfs_page.h |   14 ++------------
 3 files changed, 9 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 257d009..465ea84 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -657,6 +657,7 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_pageio_descriptor *d
 				break;
 			}
 			nfs_lock_request(req);
+			kref_get(&req->wb_kref);
 			req->wb_index = pos >> PAGE_SHIFT;
 			req->wb_offset = pos & ~PAGE_MASK;
 			if (!nfs_pageio_add_request(desc, req)) {
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 8382329..553f7ef 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -260,10 +260,10 @@ static struct nfs_page *nfs_find_and_lock_request(struct page *page, bool nonblo
 		req = nfs_page_find_request_locked(page);
 		if (req == NULL)
 			break;
-		if (nfs_lock_request_dontget(req))
+		if (nfs_lock_request(req))
 			break;
 		/* Note: If we hold the page lock, as is the case in nfs_writepage,
-		 *	 then the call to nfs_lock_request_dontget() will always
+		 *	 then the call to nfs_lock_request() will always
 		 *	 succeed provided that someone hasn't already marked the
 		 *	 request as dirty (in which case we don't care).
 		 */
@@ -406,7 +406,7 @@ static void nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
 	struct nfs_inode *nfsi = NFS_I(inode);
 
 	/* Lock the request! */
-	nfs_lock_request_dontget(req);
+	nfs_lock_request(req);
 
 	spin_lock(&inode->i_lock);
 	if (!nfsi->npages && nfs_have_delegation(inode, FMODE_WRITE))
@@ -651,6 +651,7 @@ nfs_scan_commit_list(struct list_head *src, struct list_head *dst,
 	list_for_each_entry_safe(req, tmp, src, wb_list) {
 		if (!nfs_lock_request(req))
 			continue;
+		kref_get(&req->wb_kref);
 		if (cond_resched_lock(cinfo->lock))
 			list_safe_reset_next(req, tmp, wb_list);
 		nfs_request_remove_commit_list(req, cinfo);
@@ -741,7 +742,7 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 		    || end < req->wb_offset)
 			goto out_flushme;
 
-		if (nfs_lock_request_dontget(req))
+		if (nfs_lock_request(req))
 			break;
 
 		/* The request is locked, so wait and then retry */
@@ -1717,7 +1718,7 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 		req = nfs_page_find_request(page);
 		if (req == NULL)
 			break;
-		if (nfs_lock_request_dontget(req)) {
+		if (nfs_lock_request(req)) {
 			nfs_clear_request_commit(req);
 			nfs_inode_remove_request(req);
 			/*
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index ef75042..263f30a 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -99,24 +99,14 @@ extern	void nfs_unlock_request(struct nfs_page *req);
 extern void nfs_unlock_request_dont_release(struct nfs_page *req);
 
 /*
- * Lock the page of an asynchronous request without getting a new reference
+ * Lock the page of an asynchronous request
  */
 static inline int
-nfs_lock_request_dontget(struct nfs_page *req)
-{
-	return !test_and_set_bit(PG_BUSY, &req->wb_flags);
-}
-
-static inline int
 nfs_lock_request(struct nfs_page *req)
 {
-	if (test_and_set_bit(PG_BUSY, &req->wb_flags))
-		return 0;
-	kref_get(&req->wb_kref);
-	return 1;
+	return !test_and_set_bit(PG_BUSY, &req->wb_flags);
 }
 
-
 /**
  * nfs_list_add_request - Insert a request into a list
  * @req: request
-- 
1.7.7.6


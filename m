From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 002/112] NFS: Clean up the write request locking.
Date: Fri, 25 Jan 2008 11:37:24 -0500
Message-ID: <20080125163723.31887.57302.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14368 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755933AbYAYRAH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:07 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxsf0010226
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:03 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that we set/clear NFS_PAGE_TAG_LOCKED when the nfs_page is hashed.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/pagelist.c        |   13 ++++++++-----
 fs/nfs/write.c           |   16 +++++++---------
 include/linux/nfs_page.h |   13 +------------
 3 files changed, 16 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 345bb9b..3b3dbb9 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -111,13 +111,14 @@ void nfs_unlock_request(struct nfs_page *req)
  * nfs_set_page_tag_locked - Tag a request as locked
  * @req:
  */
-static int nfs_set_page_tag_locked(struct nfs_page *req)
+int nfs_set_page_tag_locked(struct nfs_page *req)
 {
 	struct nfs_inode *nfsi = NFS_I(req->wb_context->path.dentry->d_inode);
 
-	if (!nfs_lock_request(req))
+	if (!nfs_lock_request_dontget(req))
 		return 0;
-	radix_tree_tag_set(&nfsi->nfs_page_tree, req->wb_index, NFS_PAGE_TAG_LOCKED);
+	if (req->wb_page != NULL)
+		radix_tree_tag_set(&nfsi->nfs_page_tree, req->wb_index, NFS_PAGE_TAG_LOCKED);
 	return 1;
 }
 
@@ -132,9 +133,10 @@ void nfs_clear_page_tag_locked(struct nfs_page *req)
 	if (req->wb_page != NULL) {
 		spin_lock(&inode->i_lock);
 		radix_tree_tag_clear(&nfsi->nfs_page_tree, req->wb_index, NFS_PAGE_TAG_LOCKED);
+		nfs_unlock_request(req);
 		spin_unlock(&inode->i_lock);
-	}
-	nfs_unlock_request(req);
+	} else
+		nfs_unlock_request(req);
 }
 
 /**
@@ -421,6 +423,7 @@ int nfs_scan_list(struct nfs_inode *nfsi,
 				goto out;
 			idx_start = req->wb_index + 1;
 			if (nfs_set_page_tag_locked(req)) {
+				kref_get(&req->wb_kref);
 				nfs_list_remove_request(req);
 				radix_tree_tag_clear(&nfsi->nfs_page_tree,
 						req->wb_index, tag);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 51cc1bd..092e79c 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -196,7 +196,7 @@ static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
 	}
 	/* Update file length */
 	nfs_grow_file(page, offset, count);
-	nfs_unlock_request(req);
+	nfs_clear_page_tag_locked(req);
 	return 0;
 }
 
@@ -252,7 +252,6 @@ static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 				struct page *page)
 {
 	struct inode *inode = page->mapping->host;
-	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_page *req;
 	int ret;
 
@@ -263,10 +262,10 @@ static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 			spin_unlock(&inode->i_lock);
 			return 0;
 		}
-		if (nfs_lock_request_dontget(req))
+		if (nfs_set_page_tag_locked(req))
 			break;
 		/* Note: If we hold the page lock, as is the case in nfs_writepage,
-		 *	 then the call to nfs_lock_request_dontget() will always
+		 *	 then the call to nfs_set_page_tag_locked() will always
 		 *	 succeed provided that someone hasn't already marked the
 		 *	 request as dirty (in which case we don't care).
 		 */
@@ -280,7 +279,7 @@ static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 	if (test_bit(PG_NEED_COMMIT, &req->wb_flags)) {
 		/* This request is marked for commit */
 		spin_unlock(&inode->i_lock);
-		nfs_unlock_request(req);
+		nfs_clear_page_tag_locked(req);
 		nfs_pageio_complete(pgio);
 		return 0;
 	}
@@ -288,8 +287,6 @@ static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 		spin_unlock(&inode->i_lock);
 		BUG();
 	}
-	radix_tree_tag_set(&nfsi->nfs_page_tree, req->wb_index,
-			NFS_PAGE_TAG_LOCKED);
 	spin_unlock(&inode->i_lock);
 	nfs_pageio_add_request(pgio, req);
 	return 0;
@@ -381,6 +378,7 @@ static int nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
 	set_page_private(req->wb_page, (unsigned long)req);
 	nfsi->npages++;
 	kref_get(&req->wb_kref);
+	radix_tree_tag_set(&nfsi->nfs_page_tree, req->wb_index, NFS_PAGE_TAG_LOCKED);
 	return 0;
 }
 
@@ -596,7 +594,7 @@ static struct nfs_page * nfs_update_request(struct nfs_open_context* ctx,
 		spin_lock(&inode->i_lock);
 		req = nfs_page_find_request_locked(page);
 		if (req) {
-			if (!nfs_lock_request_dontget(req)) {
+			if (!nfs_set_page_tag_locked(req)) {
 				int error;
 
 				spin_unlock(&inode->i_lock);
@@ -646,7 +644,7 @@ static struct nfs_page * nfs_update_request(struct nfs_open_context* ctx,
 	    || req->wb_page != page
 	    || !nfs_dirty_request(req)
 	    || offset > rqend || end < req->wb_offset) {
-		nfs_unlock_request(req);
+		nfs_clear_page_tag_locked(req);
 		return ERR_PTR(-EBUSY);
 	}
 
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 30dbcc1..a1676e1 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -83,6 +83,7 @@ extern	void nfs_pageio_complete(struct nfs_pageio_descriptor *desc);
 extern	void nfs_pageio_cond_complete(struct nfs_pageio_descriptor *, pgoff_t);
 extern  int nfs_wait_on_request(struct nfs_page *);
 extern	void nfs_unlock_request(struct nfs_page *req);
+extern	int nfs_set_page_tag_locked(struct nfs_page *req);
 extern  void nfs_clear_page_tag_locked(struct nfs_page *req);
 
 
@@ -95,18 +96,6 @@ nfs_lock_request_dontget(struct nfs_page *req)
 	return !test_and_set_bit(PG_BUSY, &req->wb_flags);
 }
 
-/*
- * Lock the page of an asynchronous request and take a reference
- */
-static inline int
-nfs_lock_request(struct nfs_page *req)
-{
-	if (test_and_set_bit(PG_BUSY, &req->wb_flags))
-		return 0;
-	kref_get(&req->wb_kref);
-	return 1;
-}
-
 /**
  * nfs_list_add_request - Insert a request into a list
  * @req: request

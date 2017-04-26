Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34546 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932446AbdDZQn5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Apr 2017 12:43:57 -0400
Received: by mail-io0-f196.google.com with SMTP id h41so1109927ioi.1
        for <linux-nfs@vger.kernel.org>; Wed, 26 Apr 2017 09:43:56 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSv4: Don't special case "launder"
Date: Wed, 26 Apr 2017 12:43:51 -0400
Message-Id: <20170426164351.123953-2-trond.myklebust@primarydata.com>
In-Reply-To: <20170426164351.123953-1-trond.myklebust@primarydata.com>
References: <20170426164351.123953-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the client receives a fatal server error from nfs_pageio_add_request(),
then we should always truncate the page on which the error occurred.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/file.c          |  2 +-
 fs/nfs/write.c         | 27 +++++++++++----------------
 include/linux/nfs_fs.h | 14 +-------------
 3 files changed, 13 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index bebed885b6e4..5713eb32a45e 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -482,7 +482,7 @@ static int nfs_launder_page(struct page *page)
 		inode->i_ino, (long long)page_offset(page));
 
 	nfs_fscache_wait_on_page_write(nfsi, page);
-	return nfs_wb_launder_page(inode, page);
+	return nfs_wb_page(inode, page);
 }
 
 static int nfs_swap_activate(struct swap_info_struct *sis, struct file *file,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 2e654940478f..59e21cc0a266 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -586,8 +586,7 @@ nfs_error_is_fatal_on_server(int err)
  * May return an error if the user signalled nfs_wait_on_request().
  */
 static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
-				struct page *page, bool nonblock,
-				bool launder)
+				struct page *page, bool nonblock)
 {
 	struct nfs_page *req;
 	int ret = 0;
@@ -610,13 +609,11 @@ static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 	if (!nfs_pageio_add_request(pgio, req)) {
 		ret = pgio->pg_error;
 		/*
-		 * Remove the problematic req upon fatal errors
-		 * in launder case, while other dirty pages can
-		 * still be around until they get flushed.
+		 * Remove the problematic req upon fatal errors on the server
 		 */
 		if (nfs_error_is_fatal(ret)) {
 			nfs_context_set_write_error(req->wb_context, ret);
-			if (launder)
+			if (nfs_error_is_fatal_on_server(ret))
 				goto out_launder;
 		}
 		nfs_redirty_request(req);
@@ -632,13 +629,12 @@ static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 }
 
 static int nfs_do_writepage(struct page *page, struct writeback_control *wbc,
-			    struct nfs_pageio_descriptor *pgio, bool launder)
+			    struct nfs_pageio_descriptor *pgio)
 {
 	int ret;
 
 	nfs_pageio_cond_complete(pgio, page_index(page));
-	ret = nfs_page_async_flush(pgio, page, wbc->sync_mode == WB_SYNC_NONE,
-				   launder);
+	ret = nfs_page_async_flush(pgio, page, wbc->sync_mode == WB_SYNC_NONE);
 	if (ret == -EAGAIN) {
 		redirty_page_for_writepage(wbc, page);
 		ret = 0;
@@ -650,8 +646,7 @@ static int nfs_do_writepage(struct page *page, struct writeback_control *wbc,
  * Write an mmapped page to the server.
  */
 static int nfs_writepage_locked(struct page *page,
-				struct writeback_control *wbc,
-				bool launder)
+				struct writeback_control *wbc)
 {
 	struct nfs_pageio_descriptor pgio;
 	struct inode *inode = page_file_mapping(page)->host;
@@ -660,7 +655,7 @@ static int nfs_writepage_locked(struct page *page,
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGE);
 	nfs_pageio_init_write(&pgio, inode, 0,
 				false, &nfs_async_write_completion_ops);
-	err = nfs_do_writepage(page, wbc, &pgio, launder);
+	err = nfs_do_writepage(page, wbc, &pgio);
 	nfs_pageio_complete(&pgio);
 	if (err < 0)
 		return err;
@@ -673,7 +668,7 @@ int nfs_writepage(struct page *page, struct writeback_control *wbc)
 {
 	int ret;
 
-	ret = nfs_writepage_locked(page, wbc, false);
+	ret = nfs_writepage_locked(page, wbc);
 	unlock_page(page);
 	return ret;
 }
@@ -682,7 +677,7 @@ static int nfs_writepages_callback(struct page *page, struct writeback_control *
 {
 	int ret;
 
-	ret = nfs_do_writepage(page, wbc, data, false);
+	ret = nfs_do_writepage(page, wbc, data);
 	unlock_page(page);
 	return ret;
 }
@@ -2013,7 +2008,7 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 /*
  * Write back all requests on one page - we do this before reading it.
  */
-int nfs_wb_single_page(struct inode *inode, struct page *page, bool launder)
+int nfs_wb_page(struct inode *inode, struct page *page)
 {
 	loff_t range_start = page_file_offset(page);
 	loff_t range_end = range_start + (loff_t)(PAGE_SIZE - 1);
@@ -2030,7 +2025,7 @@ int nfs_wb_single_page(struct inode *inode, struct page *page, bool launder)
 	for (;;) {
 		wait_on_page_writeback(page);
 		if (clear_page_dirty_for_io(page)) {
-			ret = nfs_writepage_locked(page, &wbc, launder);
+			ret = nfs_writepage_locked(page, &wbc);
 			if (ret < 0)
 				goto out_error;
 			continue;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 9aa044e76820..bb0eb2c9acca 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -500,25 +500,13 @@ extern int  nfs_updatepage(struct file *, struct page *, unsigned int, unsigned
  */
 extern int nfs_sync_inode(struct inode *inode);
 extern int nfs_wb_all(struct inode *inode);
-extern int nfs_wb_single_page(struct inode *inode, struct page *page, bool launder);
+extern int nfs_wb_page(struct inode *inode, struct page *page);
 extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
 extern int  nfs_commit_inode(struct inode *, int);
 extern struct nfs_commit_data *nfs_commitdata_alloc(bool never_fail);
 extern void nfs_commit_free(struct nfs_commit_data *data);
 
 static inline int
-nfs_wb_launder_page(struct inode *inode, struct page *page)
-{
-	return nfs_wb_single_page(inode, page, true);
-}
-
-static inline int
-nfs_wb_page(struct inode *inode, struct page *page)
-{
-	return nfs_wb_single_page(inode, page, false);
-}
-
-static inline int
 nfs_have_writebacks(struct inode *inode)
 {
 	return NFS_I(inode)->nrequests != 0;
-- 
2.9.3


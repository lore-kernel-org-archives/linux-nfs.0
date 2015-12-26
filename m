Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:34607 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753309AbbLZXVn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Dec 2015 18:21:43 -0500
Received: by mail-io0-f169.google.com with SMTP id e126so280361879ioa.1
        for <linux-nfs@vger.kernel.org>; Sat, 26 Dec 2015 15:21:43 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 06/14] nfs: only remove page from mapping if launder_page fails
Date: Sat, 26 Dec 2015 18:20:52 -0500
Message-Id: <1451172060-28238-6-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451172060-28238-5-git-send-email-trond.myklebust@primarydata.com>
References: <1451172060-28238-1-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-2-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-3-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-4-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

Instead of dropping pages when write fails, only do it when
we get fatal failure in launder_page write back.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/file.c          |  2 +-
 fs/nfs/write.c         | 39 +++++++++++++++++++++++----------------
 include/linux/nfs_fs.h | 14 +++++++++++++-
 3 files changed, 37 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 461425bec4da..5d91c0f35b4f 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -537,7 +537,7 @@ static int nfs_launder_page(struct page *page)
 		inode->i_ino, (long long)page_offset(page));
 
 	nfs_fscache_wait_on_page_write(nfsi, page);
-	return nfs_wb_page(inode, page);
+	return nfs_wb_launder_page(inode, page);
 }
 
 static int nfs_swap_activate(struct swap_info_struct *sis, struct file *file,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 58fa3eb5c11c..c4c12b13c56d 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -562,7 +562,8 @@ static void nfs_write_error_remove_page(struct nfs_page *req)
  * May return an error if the user signalled nfs_wait_on_request().
  */
 static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
-				struct page *page, bool nonblock)
+				struct page *page, bool nonblock,
+				bool launder)
 {
 	struct nfs_page *req;
 	int ret = 0;
@@ -581,17 +582,19 @@ static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 	if (!nfs_pageio_add_request(pgio, req)) {
 		ret = pgio->pg_error;
 		/*
-		 * Remove the problematic req upon fatal errors,
-		 * while other dirty pages can still be around
-		 * until they get flushed.
+		 * Remove the problematic req upon fatal errors
+		 * in launder case, while other dirty pages can
+		 * still be around until they get flushed.
 		 */
 		if (nfs_error_is_fatal(ret)) {
 			nfs_context_set_write_error(req->wb_context, ret);
-			nfs_write_error_remove_page(req);
-		} else {
-			nfs_redirty_request(req);
-			ret = -EAGAIN;
+			if (launder) {
+				nfs_write_error_remove_page(req);
+				goto out;
+			}
 		}
+		nfs_redirty_request(req);
+		ret = -EAGAIN;
 	} else
 		nfs_add_stats(page_file_mapping(page)->host,
 				NFSIOS_WRITEPAGES, 1);
@@ -599,12 +602,14 @@ out:
 	return ret;
 }
 
-static int nfs_do_writepage(struct page *page, struct writeback_control *wbc, struct nfs_pageio_descriptor *pgio)
+static int nfs_do_writepage(struct page *page, struct writeback_control *wbc,
+			    struct nfs_pageio_descriptor *pgio, bool launder)
 {
 	int ret;
 
 	nfs_pageio_cond_complete(pgio, page_file_index(page));
-	ret = nfs_page_async_flush(pgio, page, wbc->sync_mode == WB_SYNC_NONE);
+	ret = nfs_page_async_flush(pgio, page, wbc->sync_mode == WB_SYNC_NONE,
+				   launder);
 	if (ret == -EAGAIN) {
 		redirty_page_for_writepage(wbc, page);
 		ret = 0;
@@ -615,7 +620,9 @@ static int nfs_do_writepage(struct page *page, struct writeback_control *wbc, st
 /*
  * Write an mmapped page to the server.
  */
-static int nfs_writepage_locked(struct page *page, struct writeback_control *wbc)
+static int nfs_writepage_locked(struct page *page,
+				struct writeback_control *wbc,
+				bool launder)
 {
 	struct nfs_pageio_descriptor pgio;
 	struct inode *inode = page_file_mapping(page)->host;
@@ -624,7 +631,7 @@ static int nfs_writepage_locked(struct page *page, struct writeback_control *wbc
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGE);
 	nfs_pageio_init_write(&pgio, inode, wb_priority(wbc),
 				false, &nfs_async_write_completion_ops);
-	err = nfs_do_writepage(page, wbc, &pgio);
+	err = nfs_do_writepage(page, wbc, &pgio, launder);
 	nfs_pageio_complete(&pgio);
 	if (err < 0)
 		return err;
@@ -637,7 +644,7 @@ int nfs_writepage(struct page *page, struct writeback_control *wbc)
 {
 	int ret;
 
-	ret = nfs_writepage_locked(page, wbc);
+	ret = nfs_writepage_locked(page, wbc, false);
 	unlock_page(page);
 	return ret;
 }
@@ -646,7 +653,7 @@ static int nfs_writepages_callback(struct page *page, struct writeback_control *
 {
 	int ret;
 
-	ret = nfs_do_writepage(page, wbc, data);
+	ret = nfs_do_writepage(page, wbc, data, false);
 	unlock_page(page);
 	return ret;
 }
@@ -1933,7 +1940,7 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 /*
  * Write back all requests on one page - we do this before reading it.
  */
-int nfs_wb_page(struct inode *inode, struct page *page)
+int nfs_wb_single_page(struct inode *inode, struct page *page, bool launder)
 {
 	loff_t range_start = page_file_offset(page);
 	loff_t range_end = range_start + (loff_t)(PAGE_CACHE_SIZE - 1);
@@ -1950,7 +1957,7 @@ int nfs_wb_page(struct inode *inode, struct page *page)
 	for (;;) {
 		wait_on_page_writeback(page);
 		if (clear_page_dirty_for_io(page)) {
-			ret = nfs_writepage_locked(page, &wbc);
+			ret = nfs_writepage_locked(page, &wbc, launder);
 			if (ret < 0)
 				goto out_error;
 			continue;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index f1dd05b5564b..ced7eb1932fb 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -515,13 +515,25 @@ extern int  nfs_updatepage(struct file *, struct page *, unsigned int, unsigned
  */
 extern int nfs_sync_inode(struct inode *inode);
 extern int nfs_wb_all(struct inode *inode);
-extern int nfs_wb_page(struct inode *inode, struct page* page);
+extern int nfs_wb_single_page(struct inode *inode, struct page *page, bool launder);
 extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
 extern int  nfs_commit_inode(struct inode *, int);
 extern struct nfs_commit_data *nfs_commitdata_alloc(void);
 extern void nfs_commit_free(struct nfs_commit_data *data);
 
 static inline int
+nfs_wb_launder_page(struct inode *inode, struct page *page)
+{
+	return nfs_wb_single_page(inode, page, true);
+}
+
+static inline int
+nfs_wb_page(struct inode *inode, struct page *page)
+{
+	return nfs_wb_single_page(inode, page, false);
+}
+
+static inline int
 nfs_have_writebacks(struct inode *inode)
 {
 	return NFS_I(inode)->nrequests != 0;
-- 
2.5.0


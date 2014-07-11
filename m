Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:62717 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754113AbaGKOUz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jul 2014 10:20:55 -0400
Received: by mail-ie0-f172.google.com with SMTP id rd18so936735iec.31
        for <linux-nfs@vger.kernel.org>; Fri, 11 Jul 2014 07:20:55 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 3/5] nfs: change find_request to find_head_request
Date: Fri, 11 Jul 2014 10:20:47 -0400
Message-Id: <1405088449-11268-4-git-send-email-dros@primarydata.com>
In-Reply-To: <1405088449-11268-1-git-send-email-dros@primarydata.com>
References: <1405088449-11268-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_page_find_request_locked* should find the head request for that page.
Rename the functions and add comments to make this clear, and fix a bug
that could return a subrequest when page_private isn't set on the page.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/write.c | 33 ++++++++++++++++++++++++---------
 1 file changed, 24 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 827b57b..2e2b9f1 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -91,8 +91,15 @@ static void nfs_context_set_write_error(struct nfs_open_context *ctx, int error)
 	set_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
 }
 
+/*
+ * nfs_page_find_head_request_locked - find head request associated with @page
+ *
+ * must be called while holding the inode lock.
+ *
+ * returns matching head request with reference held, or NULL if not found.
+ */
 static struct nfs_page *
-nfs_page_find_request_locked(struct nfs_inode *nfsi, struct page *page)
+nfs_page_find_head_request_locked(struct nfs_inode *nfsi, struct page *page)
 {
 	struct nfs_page *req = NULL;
 
@@ -104,25 +111,33 @@ nfs_page_find_request_locked(struct nfs_inode *nfsi, struct page *page)
 		/* Linearly search the commit list for the correct req */
 		list_for_each_entry_safe(freq, t, &nfsi->commit_info.list, wb_list) {
 			if (freq->wb_page == page) {
-				req = freq;
+				req = freq->wb_head;
 				break;
 			}
 		}
 	}
 
-	if (req)
+	if (req) {
+		WARN_ON_ONCE(req->wb_head != req);
+
 		kref_get(&req->wb_kref);
+	}
 
 	return req;
 }
 
-static struct nfs_page *nfs_page_find_request(struct page *page)
+/*
+ * nfs_page_find_head_request - find head request associated with @page
+ *
+ * returns matching head request with reference held, or NULL if not found.
+ */
+static struct nfs_page *nfs_page_find_head_request(struct page *page)
 {
 	struct inode *inode = page_file_mapping(page)->host;
 	struct nfs_page *req = NULL;
 
 	spin_lock(&inode->i_lock);
-	req = nfs_page_find_request_locked(NFS_I(inode), page);
+	req = nfs_page_find_head_request_locked(NFS_I(inode), page);
 	spin_unlock(&inode->i_lock);
 	return req;
 }
@@ -282,7 +297,7 @@ static struct nfs_page *nfs_find_and_lock_request(struct page *page, bool nonblo
 
 	spin_lock(&inode->i_lock);
 	for (;;) {
-		req = nfs_page_find_request_locked(NFS_I(inode), page);
+		req = nfs_page_find_head_request_locked(NFS_I(inode), page);
 		if (req == NULL)
 			break;
 		if (nfs_lock_request(req))
@@ -767,7 +782,7 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 	spin_lock(&inode->i_lock);
 
 	for (;;) {
-		req = nfs_page_find_request_locked(NFS_I(inode), page);
+		req = nfs_page_find_head_request_locked(NFS_I(inode), page);
 		if (req == NULL)
 			goto out_unlock;
 
@@ -875,7 +890,7 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
 	 * dropped page.
 	 */
 	do {
-		req = nfs_page_find_request(page);
+		req = nfs_page_find_head_request(page);
 		if (req == NULL)
 			return 0;
 		l_ctx = req->wb_lock_context;
@@ -1561,7 +1576,7 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 
 	for (;;) {
 		wait_on_page_writeback(page);
-		req = nfs_page_find_request(page);
+		req = nfs_page_find_head_request(page);
 		if (req == NULL)
 			break;
 		if (nfs_lock_request(req)) {
-- 
1.8.5.2 (Apple Git-48)


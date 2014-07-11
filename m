Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f174.google.com ([209.85.213.174]:63770 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754113AbaGKOU5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jul 2014 10:20:57 -0400
Received: by mail-ig0-f174.google.com with SMTP id c1so4305107igq.13
        for <linux-nfs@vger.kernel.org>; Fri, 11 Jul 2014 07:20:56 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 5/5] nfs: handle multiple reqs in nfs_wb_page_cancel
Date: Fri, 11 Jul 2014 10:20:49 -0400
Message-Id: <1405088449-11268-6-git-send-email-dros@primarydata.com>
In-Reply-To: <1405088449-11268-1-git-send-email-dros@primarydata.com>
References: <1405088449-11268-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use nfs_lock_and_join_requests to merge all subrequests into the head request -
this cancels and dereferences all subrequests.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/write.c | 41 +++++++++++++++++++++--------------------
 1 file changed, 21 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 4dab432..dac9b31c 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1784,27 +1784,28 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 	struct nfs_page *req;
 	int ret = 0;
 
-	for (;;) {
-		wait_on_page_writeback(page);
-		req = nfs_page_find_head_request(page);
-		if (req == NULL)
-			break;
-		if (nfs_lock_request(req)) {
-			nfs_clear_request_commit(req);
-			nfs_inode_remove_request(req);
-			/*
-			 * In case nfs_inode_remove_request has marked the
-			 * page as being dirty
-			 */
-			cancel_dirty_page(page, PAGE_CACHE_SIZE);
-			nfs_unlock_and_release_request(req);
-			break;
-		}
-		ret = nfs_wait_on_request(req);
-		nfs_release_request(req);
-		if (ret < 0)
-			break;
+	wait_on_page_writeback(page);
+
+	/* blocking call to cancel all requests and join to a single (head)
+	 * request */
+	req = nfs_lock_and_join_requests(page, false);
+
+	if (IS_ERR(req)) {
+		ret = PTR_ERR(req);
+	} else if (req) {
+		/* all requests from this page have been cancelled by
+		 * nfs_lock_and_join_requests, so just remove the head
+		 * request from the inode / page_private pointer and
+		 * release it */
+		nfs_inode_remove_request(req);
+		/*
+		 * In case nfs_inode_remove_request has marked the
+		 * page as being dirty
+		 */
+		cancel_dirty_page(page, PAGE_CACHE_SIZE);
+		nfs_unlock_and_release_request(req);
 	}
+
 	return ret;
 }
 
-- 
1.8.5.2 (Apple Git-48)


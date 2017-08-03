Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33243 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751944AbdHCNp6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 09:45:58 -0400
Received: by mail-it0-f67.google.com with SMTP id m34so1323205iti.0
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 06:45:57 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 19/28] NFSv4: Convert nfs_lock_and_join_requests() to use nfs_page_find_head_request()
Date: Thu,  3 Aug 2017 09:45:14 -0400
Message-Id: <20170803134523.4922-20-trond.myklebust@primarydata.com>
In-Reply-To: <20170803134523.4922-19-trond.myklebust@primarydata.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hide the locking from nfs_lock_and_join_requests() so that we can
separate out the requirements for swapcache pages.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 35 ++++++++++++++++++++---------------
 1 file changed, 20 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 759e37d26acf..a06167e20b72 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -154,6 +154,14 @@ static void nfs_context_set_write_error(struct nfs_open_context *ctx, int error)
 	set_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
 }
 
+static struct nfs_page *
+nfs_page_private_request(struct page *page)
+{
+	if (!PagePrivate(page))
+		return NULL;
+	return (struct nfs_page *)page_private(page);
+}
+
 /*
  * nfs_page_find_head_request_locked - find head request associated with @page
  *
@@ -164,11 +172,10 @@ static void nfs_context_set_write_error(struct nfs_open_context *ctx, int error)
 static struct nfs_page *
 nfs_page_find_head_request_locked(struct nfs_inode *nfsi, struct page *page)
 {
-	struct nfs_page *req = NULL;
+	struct nfs_page *req;
 
-	if (PagePrivate(page))
-		req = (struct nfs_page *)page_private(page);
-	else if (unlikely(PageSwapCache(page)))
+	req = nfs_page_private_request(page);
+	if (!req && unlikely(PageSwapCache(page)))
 		req = nfs_page_search_commits_for_head_request_locked(nfsi,
 			page);
 
@@ -448,31 +455,29 @@ nfs_lock_and_join_requests(struct page *page)
 	int ret;
 
 try_again:
-	if (!(PagePrivate(page) || PageSwapCache(page)))
-		return NULL;
-	spin_lock(&inode->i_lock);
 	/*
 	 * A reference is taken only on the head request which acts as a
 	 * reference to the whole page group - the group will not be destroyed
 	 * until the head reference is released.
 	 */
-	head = nfs_page_find_head_request_locked(NFS_I(inode), page);
-
-	if (!head) {
-		spin_unlock(&inode->i_lock);
+	head = nfs_page_find_head_request(page);
+	if (!head)
 		return NULL;
-	}
 
 	/* lock the page head first in order to avoid an ABBA inefficiency */
 	if (!nfs_lock_request(head)) {
-		spin_unlock(&inode->i_lock);
 		ret = nfs_wait_on_request(head);
 		nfs_release_request(head);
 		if (ret < 0)
 			return ERR_PTR(ret);
 		goto try_again;
 	}
-	spin_unlock(&inode->i_lock);
+
+	/* Ensure that nobody removed the request before we locked it */
+	if (head != nfs_page_private_request(page) && !PageSwapCache(page)) {
+		nfs_unlock_and_release_request(head);
+		goto try_again;
+	}
 
 	ret = nfs_page_group_lock(head);
 	if (ret < 0) {
@@ -559,7 +564,7 @@ nfs_lock_and_join_requests(struct page *page)
 		return NULL;
 	}
 
-	/* still holds ref on head from nfs_page_find_head_request_locked
+	/* still holds ref on head from nfs_page_find_head_request
 	 * and still has lock on head from lock loop */
 	return head;
 }
-- 
2.13.3


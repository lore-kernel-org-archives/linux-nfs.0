Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35481 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751247AbdHCNp7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 09:45:59 -0400
Received: by mail-io0-f195.google.com with SMTP id h70so452906ioi.2
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 06:45:59 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 20/28] NFS: Refactor nfs_page_find_head_request()
Date: Thu,  3 Aug 2017 09:45:15 -0400
Message-Id: <20170803134523.4922-21-trond.myklebust@primarydata.com>
In-Reply-To: <20170803134523.4922-20-trond.myklebust@primarydata.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Split out the 2 cases so that we can treat the locking differently.
The issue is that the locking in the pageswapcache cache is highly
linked to the commit list locking.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 42 ++++++++++++++++++++++++++++++------------
 1 file changed, 30 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index a06167e20b72..8d8fa6d4cfcc 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -170,20 +170,41 @@ nfs_page_private_request(struct page *page)
  * returns matching head request with reference held, or NULL if not found.
  */
 static struct nfs_page *
-nfs_page_find_head_request_locked(struct nfs_inode *nfsi, struct page *page)
+nfs_page_find_private_request(struct page *page)
 {
+	struct inode *inode = page_file_mapping(page)->host;
 	struct nfs_page *req;
 
+	if (!PagePrivate(page))
+		return NULL;
+	spin_lock(&inode->i_lock);
 	req = nfs_page_private_request(page);
-	if (!req && unlikely(PageSwapCache(page)))
-		req = nfs_page_search_commits_for_head_request_locked(nfsi,
-			page);
-
 	if (req) {
 		WARN_ON_ONCE(req->wb_head != req);
 		kref_get(&req->wb_kref);
 	}
+	spin_unlock(&inode->i_lock);
+	return req;
+}
 
+static struct nfs_page *
+nfs_page_find_swap_request(struct page *page)
+{
+	struct inode *inode = page_file_mapping(page)->host;
+	struct nfs_inode *nfsi = NFS_I(inode);
+	struct nfs_page *req = NULL;
+	if (!PageSwapCache(page))
+		return NULL;
+	spin_lock(&inode->i_lock);
+	if (PageSwapCache(page)) {
+		req = nfs_page_search_commits_for_head_request_locked(nfsi,
+			page);
+		if (req) {
+			WARN_ON_ONCE(req->wb_head != req);
+			kref_get(&req->wb_kref);
+		}
+	}
+	spin_unlock(&inode->i_lock);
 	return req;
 }
 
@@ -194,14 +215,11 @@ nfs_page_find_head_request_locked(struct nfs_inode *nfsi, struct page *page)
  */
 static struct nfs_page *nfs_page_find_head_request(struct page *page)
 {
-	struct inode *inode = page_file_mapping(page)->host;
-	struct nfs_page *req = NULL;
+	struct nfs_page *req;
 
-	if (PagePrivate(page) || PageSwapCache(page)) {
-		spin_lock(&inode->i_lock);
-		req = nfs_page_find_head_request_locked(NFS_I(inode), page);
-		spin_unlock(&inode->i_lock);
-	}
+	req = nfs_page_find_private_request(page);
+	if (!req)
+		req = nfs_page_find_swap_request(page);
 	return req;
 }
 
-- 
2.13.3


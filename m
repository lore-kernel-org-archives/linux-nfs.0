Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33281 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751944AbdHCNqE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 09:46:04 -0400
Received: by mail-it0-f68.google.com with SMTP id m34so1323560iti.0
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 06:46:04 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 24/28] NFS: Switch to using mapping->private_lock for page writeback lookups.
Date: Thu,  3 Aug 2017 09:45:19 -0400
Message-Id: <20170803134523.4922-25-trond.myklebust@primarydata.com>
In-Reply-To: <20170803134523.4922-24-trond.myklebust@primarydata.com>
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
 <20170803134523.4922-22-trond.myklebust@primarydata.com>
 <20170803134523.4922-23-trond.myklebust@primarydata.com>
 <20170803134523.4922-24-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Switch from using the inode->i_lock for this to avoid contention with
other metadata manipulation.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 27 ++++++++++++++++-----------
 1 file changed, 16 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 12479c25028e..866702823869 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -172,18 +172,18 @@ nfs_page_private_request(struct page *page)
 static struct nfs_page *
 nfs_page_find_private_request(struct page *page)
 {
-	struct inode *inode = page_file_mapping(page)->host;
+	struct address_space *mapping = page_file_mapping(page);
 	struct nfs_page *req;
 
 	if (!PagePrivate(page))
 		return NULL;
-	spin_lock(&inode->i_lock);
+	spin_lock(&mapping->private_lock);
 	req = nfs_page_private_request(page);
 	if (req) {
 		WARN_ON_ONCE(req->wb_head != req);
 		kref_get(&req->wb_kref);
 	}
-	spin_unlock(&inode->i_lock);
+	spin_unlock(&mapping->private_lock);
 	return req;
 }
 
@@ -743,6 +743,7 @@ int nfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
  */
 static void nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
 {
+	struct address_space *mapping = page_file_mapping(req->wb_page);
 	struct nfs_inode *nfsi = NFS_I(inode);
 
 	WARN_ON_ONCE(req->wb_this_page != req);
@@ -750,19 +751,23 @@ static void nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
 	/* Lock the request! */
 	nfs_lock_request(req);
 
-	spin_lock(&inode->i_lock);
-	if (!nfs_have_writebacks(inode) &&
-	    NFS_PROTO(inode)->have_delegation(inode, FMODE_WRITE))
-		inode->i_version++;
 	/*
 	 * Swap-space should not get truncated. Hence no need to plug the race
 	 * with invalidate/truncate.
 	 */
+	spin_lock(&mapping->private_lock);
+	if (!nfs_have_writebacks(inode) &&
+	    NFS_PROTO(inode)->have_delegation(inode, FMODE_WRITE)) {
+		spin_lock(&inode->i_lock);
+		inode->i_version++;
+		spin_unlock(&inode->i_lock);
+	}
 	if (likely(!PageSwapCache(req->wb_page))) {
 		set_bit(PG_MAPPED, &req->wb_flags);
 		SetPagePrivate(req->wb_page);
 		set_page_private(req->wb_page, (unsigned long)req);
 	}
+	spin_unlock(&mapping->private_lock);
 	atomic_long_inc(&nfsi->nrequests);
 	/* this a head request for a page group - mark it as having an
 	 * extra reference so sub groups can follow suit.
@@ -770,7 +775,6 @@ static void nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
 	 * adding subrequests. */
 	WARN_ON(test_and_set_bit(PG_INODE_REF, &req->wb_flags));
 	kref_get(&req->wb_kref);
-	spin_unlock(&inode->i_lock);
 }
 
 /*
@@ -778,7 +782,8 @@ static void nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
  */
 static void nfs_inode_remove_request(struct nfs_page *req)
 {
-	struct inode *inode = d_inode(req->wb_context->dentry);
+	struct address_space *mapping = page_file_mapping(req->wb_page);
+	struct inode *inode = mapping->host;
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_page *head;
 
@@ -786,13 +791,13 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 	if (nfs_page_group_sync_on_bit(req, PG_REMOVE)) {
 		head = req->wb_head;
 
-		spin_lock(&inode->i_lock);
+		spin_lock(&mapping->private_lock);
 		if (likely(head->wb_page && !PageSwapCache(head->wb_page))) {
 			set_page_private(head->wb_page, 0);
 			ClearPagePrivate(head->wb_page);
 			clear_bit(PG_MAPPED, &head->wb_flags);
 		}
-		spin_unlock(&inode->i_lock);
+		spin_unlock(&mapping->private_lock);
 	}
 
 	if (test_and_clear_bit(PG_INODE_REF, &req->wb_flags))
-- 
2.13.3


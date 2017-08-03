Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36473 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751600AbdHCNpe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 09:45:34 -0400
Received: by mail-it0-f68.google.com with SMTP id r9so1312688ita.3
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 06:45:33 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 02/28] NFS: Reduce lock contention in nfs_page_find_head_request()
Date: Thu,  3 Aug 2017 09:44:57 -0400
Message-Id: <20170803134523.4922-3-trond.myklebust@primarydata.com>
In-Reply-To: <20170803134523.4922-2-trond.myklebust@primarydata.com>
References: <20170803134523.4922-1-trond.myklebust@primarydata.com>
 <20170803134523.4922-2-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a lockless check for whether or not the page might be carrying
an existing writeback before we grab the inode->i_lock.

Reported-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 1d447e37f472..06e150c4e315 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -190,9 +190,11 @@ static struct nfs_page *nfs_page_find_head_request(struct page *page)
 	struct inode *inode = page_file_mapping(page)->host;
 	struct nfs_page *req = NULL;
 
-	spin_lock(&inode->i_lock);
-	req = nfs_page_find_head_request_locked(NFS_I(inode), page);
-	spin_unlock(&inode->i_lock);
+	if (PagePrivate(page) || PageSwapCache(page)) {
+		spin_lock(&inode->i_lock);
+		req = nfs_page_find_head_request_locked(NFS_I(inode), page);
+		spin_unlock(&inode->i_lock);
+	}
 	return req;
 }
 
-- 
2.13.3


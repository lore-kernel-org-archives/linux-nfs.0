Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34778 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753354AbdGSWKE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Jul 2017 18:10:04 -0400
Received: by mail-io0-f194.google.com with SMTP id f66so821522iof.1
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 15:10:03 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 02/20] NFS: Reduce lock contention in nfs_page_find_head_request()
Date: Wed, 19 Jul 2017 18:09:37 -0400
Message-Id: <20170719220955.58210-3-trond.myklebust@primarydata.com>
In-Reply-To: <20170719220955.58210-2-trond.myklebust@primarydata.com>
References: <20170719220955.58210-1-trond.myklebust@primarydata.com>
 <20170719220955.58210-2-trond.myklebust@primarydata.com>
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


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33078 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753904AbdGSWKE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Jul 2017 18:10:04 -0400
Received: by mail-io0-f196.google.com with SMTP id n64so823950ioo.0
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 15:10:04 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 03/20] NFS: Reduce lock contention in nfs_try_to_update_request()
Date: Wed, 19 Jul 2017 18:09:38 -0400
Message-Id: <20170719220955.58210-4-trond.myklebust@primarydata.com>
In-Reply-To: <20170719220955.58210-3-trond.myklebust@primarydata.com>
References: <20170719220955.58210-1-trond.myklebust@primarydata.com>
 <20170719220955.58210-2-trond.myklebust@primarydata.com>
 <20170719220955.58210-3-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Micro-optimisation to move the lockless check into the for(;;) loop.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 06e150c4e315..bb019096c331 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1097,13 +1097,12 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 	unsigned int end;
 	int error;
 
-	if (!PagePrivate(page))
-		return NULL;
-
 	end = offset + bytes;
-	spin_lock(&inode->i_lock);
 
 	for (;;) {
+		if (!(PagePrivate(page) || PageSwapCache(page)))
+			return NULL;
+		spin_lock(&inode->i_lock);
 		req = nfs_page_find_head_request_locked(NFS_I(inode), page);
 		if (req == NULL)
 			goto out_unlock;
@@ -1132,7 +1131,6 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 		nfs_release_request(req);
 		if (error != 0)
 			goto out_err;
-		spin_lock(&inode->i_lock);
 	}
 
 	/* Okay, the request matches. Update the region */
-- 
2.13.3


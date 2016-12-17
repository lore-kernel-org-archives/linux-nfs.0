Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34639 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756637AbcLQS1W (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Dec 2016 13:27:22 -0500
Received: by mail-it0-f67.google.com with SMTP id 75so6187406ite.1
        for <linux-nfs@vger.kernel.org>; Sat, 17 Dec 2016 10:27:22 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 7/9] NFS: Fix and clean up the access cache validity checking
Date: Sat, 17 Dec 2016 13:27:09 -0500
Message-Id: <20161217182711.10643-8-trond.myklebust@primarydata.com>
In-Reply-To: <20161217182711.10643-7-trond.myklebust@primarydata.com>
References: <20161217182711.10643-1-trond.myklebust@primarydata.com>
 <20161217182711.10643-2-trond.myklebust@primarydata.com>
 <20161217182711.10643-3-trond.myklebust@primarydata.com>
 <20161217182711.10643-4-trond.myklebust@primarydata.com>
 <20161217182711.10643-5-trond.myklebust@primarydata.com>
 <20161217182711.10643-6-trond.myklebust@primarydata.com>
 <20161217182711.10643-7-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The access cache needs to check whether or not the mode bits, ownership,
or ACL has changed or the cache has timed out.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/dir.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 8f706f3e5c05..fad81041f5ab 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2286,8 +2286,7 @@ static int nfs_access_get_cached(struct inode *inode, struct rpc_cred *cred, str
 		if (cache == NULL)
 			goto out;
 		/* Found an entry, is our attribute cache valid? */
-		if (!nfs_attribute_cache_expired(inode) &&
-		    !(nfsi->cache_validity & NFS_INO_INVALID_ATTR))
+		if (!nfs_check_cache_invalid(inode, NFS_INO_INVALID_ACCESS))
 			break;
 		err = -ECHILD;
 		if (!may_block)
@@ -2335,12 +2334,12 @@ static int nfs_access_get_cached_rcu(struct inode *inode, struct rpc_cred *cred,
 		cache = NULL;
 	if (cache == NULL)
 		goto out;
-	err = nfs_revalidate_inode_rcu(NFS_SERVER(inode), inode);
-	if (err)
+	if (nfs_check_cache_invalid(inode, NFS_INO_INVALID_ACCESS))
 		goto out;
 	res->jiffies = cache->jiffies;
 	res->cred = cache->cred;
 	res->mask = cache->mask;
+	err = 0;
 out:
 	rcu_read_unlock();
 	return err;
@@ -2492,12 +2491,13 @@ EXPORT_SYMBOL_GPL(nfs_may_open);
 static int nfs_execute_ok(struct inode *inode, int mask)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
-	int ret;
+	int ret = 0;
 
-	if (mask & MAY_NOT_BLOCK)
-		ret = nfs_revalidate_inode_rcu(server, inode);
-	else
-		ret = nfs_revalidate_inode(server, inode);
+	if (nfs_check_cache_invalid(inode, NFS_INO_INVALID_ACCESS)) {
+		if (mask & MAY_NOT_BLOCK)
+			return -ECHILD;
+		ret = __nfs_revalidate_inode(server, inode);
+	}
 	if (ret == 0 && !execute_ok(inode))
 		ret = -EACCES;
 	return ret;
-- 
2.9.3


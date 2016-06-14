Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33151 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752710AbcFNTFj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2016 15:05:39 -0400
Received: by mail-it0-f65.google.com with SMTP id i6so432622ith.0
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2016 12:05:39 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 02/12] NFS: Cache access checks more aggressively
Date: Tue, 14 Jun 2016 15:05:05 -0400
Message-Id: <1465931115-30784-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1465931115-30784-1-git-send-email-trond.myklebust@primarydata.com>
References: <1465931115-30784-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If an attribute revalidation fails, then we already know that we'll
zap the access cache. If, OTOH, the inode isn't changing, there should
be no need to eject access calls just because they are old.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/dir.c | 42 ++++++++++++++++++++++++------------------
 1 file changed, 24 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index aaf7bd0cbae2..d76f0b2b3ee2 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2232,17 +2232,30 @@ static int nfs_access_get_cached(struct inode *inode, struct rpc_cred *cred, str
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_access_entry *cache;
-	int err = -ENOENT;
+	bool retry = true;
+	int err;
 
 	spin_lock(&inode->i_lock);
-	if (nfsi->cache_validity & NFS_INO_INVALID_ACCESS)
-		goto out_zap;
-	cache = nfs_access_search_rbtree(inode, cred);
-	if (cache == NULL)
-		goto out;
-	if (!nfs_have_delegated_attributes(inode) &&
-	    !time_in_range_open(jiffies, cache->jiffies, cache->jiffies + nfsi->attrtimeo))
-		goto out_stale;
+	for(;;) {
+		if (nfsi->cache_validity & NFS_INO_INVALID_ACCESS)
+			goto out_zap;
+		cache = nfs_access_search_rbtree(inode, cred);
+		err = -ENOENT;
+		if (cache == NULL)
+			goto out;
+		/* Found an entry, is our attribute cache valid? */
+		if (!nfs_attribute_cache_expired(inode) &&
+		    !(nfsi->cache_validity & NFS_INO_INVALID_ATTR))
+			break;
+		if (!retry)
+			goto out_zap;
+		spin_unlock(&inode->i_lock);
+		err = __nfs_revalidate_inode(NFS_SERVER(inode), inode);
+		if (err)
+			return err;
+		spin_lock(&inode->i_lock);
+		retry = false;
+	}
 	res->jiffies = cache->jiffies;
 	res->cred = cache->cred;
 	res->mask = cache->mask;
@@ -2251,12 +2264,6 @@ static int nfs_access_get_cached(struct inode *inode, struct rpc_cred *cred, str
 out:
 	spin_unlock(&inode->i_lock);
 	return err;
-out_stale:
-	rb_erase(&cache->rb_node, &nfsi->access_cache);
-	list_del(&cache->lru);
-	spin_unlock(&inode->i_lock);
-	nfs_access_free_entry(cache);
-	return -ENOENT;
 out_zap:
 	spin_unlock(&inode->i_lock);
 	nfs_access_zap_cache(inode);
@@ -2283,13 +2290,12 @@ static int nfs_access_get_cached_rcu(struct inode *inode, struct rpc_cred *cred,
 		cache = NULL;
 	if (cache == NULL)
 		goto out;
-	if (!nfs_have_delegated_attributes(inode) &&
-	    !time_in_range_open(jiffies, cache->jiffies, cache->jiffies + nfsi->attrtimeo))
+	err = nfs_revalidate_inode_rcu(NFS_SERVER(inode), inode);
+	if (err)
 		goto out;
 	res->jiffies = cache->jiffies;
 	res->cred = cache->cred;
 	res->mask = cache->mask;
-	err = 0;
 out:
 	rcu_read_unlock();
 	return err;
-- 
2.5.5


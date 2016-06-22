Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35029 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821AbcFVUsU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2016 16:48:20 -0400
Received: by mail-io0-f193.google.com with SMTP id u25so8584761iou.2
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jun 2016 13:48:19 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 02/13] NFS: Cache access checks more aggressively
Date: Wed, 22 Jun 2016 16:47:37 -0400
Message-Id: <1466628468-3958-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466628468-3958-1-git-send-email-trond.myklebust@primarydata.com>
References: <1466628468-3958-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If an attribute revalidation fails, then we already know that we'll
zap the access cache. If, OTOH, the inode isn't changing, there should
be no need to eject access calls just because they are old.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/dir.c | 52 +++++++++++++++++++++++++++++++---------------------
 1 file changed, 31 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index aaf7bd0cbae2..210b33636fe4 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2228,21 +2228,37 @@ static struct nfs_access_entry *nfs_access_search_rbtree(struct inode *inode, st
 	return NULL;
 }
 
-static int nfs_access_get_cached(struct inode *inode, struct rpc_cred *cred, struct nfs_access_entry *res)
+static int nfs_access_get_cached(struct inode *inode, struct rpc_cred *cred, struct nfs_access_entry *res, bool may_block)
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
+		err = -ECHILD;
+		if (!may_block)
+			goto out;
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
@@ -2251,12 +2267,6 @@ static int nfs_access_get_cached(struct inode *inode, struct rpc_cred *cred, str
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
@@ -2283,13 +2293,12 @@ static int nfs_access_get_cached_rcu(struct inode *inode, struct rpc_cred *cred,
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
@@ -2378,18 +2387,19 @@ EXPORT_SYMBOL_GPL(nfs_access_set_mask);
 static int nfs_do_access(struct inode *inode, struct rpc_cred *cred, int mask)
 {
 	struct nfs_access_entry cache;
+	bool may_block = (mask & MAY_NOT_BLOCK) == 0;
 	int status;
 
 	trace_nfs_access_enter(inode);
 
 	status = nfs_access_get_cached_rcu(inode, cred, &cache);
 	if (status != 0)
-		status = nfs_access_get_cached(inode, cred, &cache);
+		status = nfs_access_get_cached(inode, cred, &cache, may_block);
 	if (status == 0)
 		goto out_cached;
 
 	status = -ECHILD;
-	if (mask & MAY_NOT_BLOCK)
+	if (!may_block)
 		goto out;
 
 	/* Be clever: ask server to check for all possible rights */
-- 
2.7.4


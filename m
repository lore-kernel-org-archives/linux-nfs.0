Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f173.google.com ([209.85.213.173]:39139 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752161AbaHFRog (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Aug 2014 13:44:36 -0400
Received: by mail-ig0-f173.google.com with SMTP id h18so9099454igc.0
        for <linux-nfs@vger.kernel.org>; Wed, 06 Aug 2014 10:44:36 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/6] nfsd: Remove the cache_hash list
Date: Wed,  6 Aug 2014 13:44:22 -0400
Message-Id: <1407347065-17463-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1407347065-17463-3-git-send-email-trond.myklebust@primarydata.com>
References: <1407347065-17463-1-git-send-email-trond.myklebust@primarydata.com>
 <1407347065-17463-2-git-send-email-trond.myklebust@primarydata.com>
 <1407347065-17463-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that the lru list is per-bucket, we don't need a second list for
searches.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/cache.h    |  1 -
 fs/nfsd/nfscache.c | 19 ++-----------------
 2 files changed, 2 insertions(+), 18 deletions(-)

diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
index b582f9ab6b2a..dd96a3830004 100644
--- a/fs/nfsd/cache.h
+++ b/fs/nfsd/cache.h
@@ -18,7 +18,6 @@
  * is much larger than a sockaddr_in6.
  */
 struct svc_cacherep {
-	struct hlist_node	c_hash;
 	struct list_head	c_lru;
 
 	unsigned char		c_state,	/* unused, inprog, done */
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index c01f44eb7fe4..8abec475f80f 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -28,7 +28,6 @@
 #define TARGET_BUCKET_SIZE	64
 
 struct nfsd_drc_bucket {
-	struct hlist_head cache_hash;
 	struct list_head lru_head;
 };
 
@@ -137,7 +136,6 @@ nfsd_reply_cache_alloc(void)
 		rp->c_state = RC_UNUSED;
 		rp->c_type = RC_NOCACHE;
 		INIT_LIST_HEAD(&rp->c_lru);
-		INIT_HLIST_NODE(&rp->c_hash);
 	}
 	return rp;
 }
@@ -149,8 +147,6 @@ nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
 		drc_mem_usage -= rp->c_replvec.iov_len;
 		kfree(rp->c_replvec.iov_base);
 	}
-	if (!hlist_unhashed(&rp->c_hash))
-		hlist_del(&rp->c_hash);
 	list_del(&rp->c_lru);
 	--num_drc_entries;
 	drc_mem_usage -= sizeof(*rp);
@@ -233,16 +229,6 @@ lru_put_end(struct nfsd_drc_bucket *b, struct svc_cacherep *rp)
 	schedule_delayed_work(&cache_cleaner, RC_EXPIRE);
 }
 
-/*
- * Move a cache entry from one hash list to another
- */
-static void
-hash_refile(struct nfsd_drc_bucket *b, struct svc_cacherep *rp)
-{
-	hlist_del_init(&rp->c_hash);
-	hlist_add_head(&rp->c_hash, &b->cache_hash);
-}
-
 static long
 prune_bucket(struct nfsd_drc_bucket *b)
 {
@@ -386,10 +372,10 @@ nfsd_cache_search(struct nfsd_drc_bucket *b, struct svc_rqst *rqstp,
 		__wsum csum)
 {
 	struct svc_cacherep	*rp, *ret = NULL;
-	struct hlist_head 	*rh = &b->cache_hash;
+	struct list_head 	*rh = &b->lru_head;
 	unsigned int		entries = 0;
 
-	hlist_for_each_entry(rp, rh, c_hash) {
+	list_for_each_entry(rp, rh, c_lru) {
 		++entries;
 		if (nfsd_cache_match(rqstp, csum, rp)) {
 			ret = rp;
@@ -479,7 +465,6 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 	rp->c_len = rqstp->rq_arg.len;
 	rp->c_csum = csum;
 
-	hash_refile(b, rp);
 	lru_put_end(b, rp);
 
 	/* release any buffer */
-- 
1.9.3


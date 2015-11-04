Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:35967 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964926AbbKDQCf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Nov 2015 11:02:35 -0500
Received: by qgad10 with SMTP id d10so43590478qga.3
        for <linux-nfs@vger.kernel.org>; Wed, 04 Nov 2015 08:02:35 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: remove recurring workqueue job to clean DRC
Date: Wed,  4 Nov 2015 11:02:29 -0500
Message-Id: <1446652949-16672-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We have a shrinker, we clean out the cache when nfsd is shut down, and
prune the chains on each request. A recurring workqueue job seems like
unnecessary overhead. Just remove it.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfscache.c | 26 --------------------------
 1 file changed, 26 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 46ec934f5dee..8af64b6ffe91 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -63,7 +63,6 @@ static unsigned int		longest_chain;
 static unsigned int		longest_chain_cachesize;
 
 static int	nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *vec);
-static void	cache_cleaner_func(struct work_struct *unused);
 static unsigned long nfsd_reply_cache_count(struct shrinker *shrink,
 					    struct shrink_control *sc);
 static unsigned long nfsd_reply_cache_scan(struct shrinker *shrink,
@@ -76,13 +75,6 @@ static struct shrinker nfsd_reply_cache_shrinker = {
 };
 
 /*
- * locking for the reply cache:
- * A cache entry is "single use" if c_state == RC_INPROG
- * Otherwise, it when accessing _prev or _next, the lock must be held.
- */
-static DECLARE_DELAYED_WORK(cache_cleaner, cache_cleaner_func);
-
-/*
  * Put a cap on the size of the DRC based on the amount of available
  * low memory in the machine.
  *
@@ -203,7 +195,6 @@ void nfsd_reply_cache_shutdown(void)
 	unsigned int i;
 
 	unregister_shrinker(&nfsd_reply_cache_shrinker);
-	cancel_delayed_work_sync(&cache_cleaner);
 
 	for (i = 0; i < drc_hashsize; i++) {
 		struct list_head *head = &drc_hashtbl[i].lru_head;
@@ -232,7 +223,6 @@ lru_put_end(struct nfsd_drc_bucket *b, struct svc_cacherep *rp)
 {
 	rp->c_timestamp = jiffies;
 	list_move_tail(&rp->c_lru, &b->lru_head);
-	schedule_delayed_work(&cache_cleaner, RC_EXPIRE);
 }
 
 static long
@@ -266,7 +256,6 @@ prune_cache_entries(void)
 {
 	unsigned int i;
 	long freed = 0;
-	bool cancel = true;
 
 	for (i = 0; i < drc_hashsize; i++) {
 		struct nfsd_drc_bucket *b = &drc_hashtbl[i];
@@ -275,26 +264,11 @@ prune_cache_entries(void)
 			continue;
 		spin_lock(&b->cache_lock);
 		freed += prune_bucket(b);
-		if (!list_empty(&b->lru_head))
-			cancel = false;
 		spin_unlock(&b->cache_lock);
 	}
-
-	/*
-	 * Conditionally rearm the job to run in RC_EXPIRE since we just
-	 * ran the pruner.
-	 */
-	if (!cancel)
-		mod_delayed_work(system_wq, &cache_cleaner, RC_EXPIRE);
 	return freed;
 }
 
-static void
-cache_cleaner_func(struct work_struct *unused)
-{
-	prune_cache_entries();
-}
-
 static unsigned long
 nfsd_reply_cache_count(struct shrinker *shrink, struct shrink_control *sc)
 {
-- 
2.4.3


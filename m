Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f52.google.com ([209.85.192.52]:36849 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752923AbaHCRGJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Aug 2014 13:06:09 -0400
Received: by mail-qg0-f52.google.com with SMTP id f51so7976125qge.11
        for <linux-nfs@vger.kernel.org>; Sun, 03 Aug 2014 10:06:08 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/6] nfsd: convert the lru list into a per-bucket thing
Date: Sun,  3 Aug 2014 13:06:00 -0400
Message-Id: <1407085564-3227-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1407085564-3227-2-git-send-email-trond.myklebust@primarydata.com>
References: <1407085564-3227-1-git-send-email-trond.myklebust@primarydata.com>
 <1407085564-3227-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfscache.c | 73 +++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 50 insertions(+), 23 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index c9e25bc7ea56..a387d443641f 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -29,10 +29,10 @@
 
 struct nfsd_drc_bucket {
 	struct hlist_head cache_hash;
+	struct list_head lru_head;
 };
 
 static struct nfsd_drc_bucket	*drc_hashtbl;
-static struct list_head 	lru_head;
 static struct kmem_cache	*drc_slab;
 
 /* max number of entries allowed in the cache */
@@ -40,6 +40,7 @@ static unsigned int		max_drc_entries;
 
 /* number of significant bits in the hash value */
 static unsigned int		maskbits;
+static unsigned int		drc_hashsize;
 
 /*
  * Stats and other tracking of on the duplicate reply cache. All of these and
@@ -167,8 +168,8 @@ nfsd_reply_cache_free(struct svc_cacherep *rp)
 int nfsd_reply_cache_init(void)
 {
 	unsigned int hashsize;
+	unsigned int i;
 
-	INIT_LIST_HEAD(&lru_head);
 	max_drc_entries = nfsd_cache_size_limit();
 	num_drc_entries = 0;
 	hashsize = nfsd_hashsize(max_drc_entries);
@@ -183,6 +184,9 @@ int nfsd_reply_cache_init(void)
 	drc_hashtbl = kcalloc(hashsize, sizeof(*drc_hashtbl), GFP_KERNEL);
 	if (!drc_hashtbl)
 		goto out_nomem;
+	for (i = 0; i < hashsize; i++)
+		INIT_LIST_HEAD(&drc_hashtbl[i].lru_head);
+	drc_hashsize = hashsize;
 
 	return 0;
 out_nomem:
@@ -194,17 +198,22 @@ out_nomem:
 void nfsd_reply_cache_shutdown(void)
 {
 	struct svc_cacherep	*rp;
+	unsigned int i;
 
 	unregister_shrinker(&nfsd_reply_cache_shrinker);
 	cancel_delayed_work_sync(&cache_cleaner);
 
-	while (!list_empty(&lru_head)) {
-		rp = list_entry(lru_head.next, struct svc_cacherep, c_lru);
-		nfsd_reply_cache_free_locked(rp);
+	for (i = 0; i < drc_hashsize; i++) {
+		struct list_head *head = &drc_hashtbl[i].lru_head;
+		while (!list_empty(head)) {
+			rp = list_first_entry(head, struct svc_cacherep, c_lru);
+			nfsd_reply_cache_free_locked(rp);
+		}
 	}
 
 	kfree (drc_hashtbl);
 	drc_hashtbl = NULL;
+	drc_hashsize = 0;
 
 	if (drc_slab) {
 		kmem_cache_destroy(drc_slab);
@@ -217,10 +226,10 @@ void nfsd_reply_cache_shutdown(void)
  * not already scheduled.
  */
 static void
-lru_put_end(struct svc_cacherep *rp)
+lru_put_end(struct nfsd_drc_bucket *b, struct svc_cacherep *rp)
 {
 	rp->c_timestamp = jiffies;
-	list_move_tail(&rp->c_lru, &lru_head);
+	list_move_tail(&rp->c_lru, &b->lru_head);
 	schedule_delayed_work(&cache_cleaner, RC_EXPIRE);
 }
 
@@ -234,17 +243,13 @@ hash_refile(struct nfsd_drc_bucket *b, struct svc_cacherep *rp)
 	hlist_add_head(&rp->c_hash, &b->cache_hash);
 }
 
-/*
- * Walk the LRU list and prune off entries that are older than RC_EXPIRE.
- * Also prune the oldest ones when the total exceeds the max number of entries.
- */
 static long
-prune_cache_entries(void)
+prune_bucket(struct nfsd_drc_bucket *b)
 {
 	struct svc_cacherep *rp, *tmp;
 	long freed = 0;
 
-	list_for_each_entry_safe(rp, tmp, &lru_head, c_lru) {
+	list_for_each_entry_safe(rp, tmp, &b->lru_head, c_lru) {
 		/*
 		 * Don't free entries attached to calls that are still
 		 * in-progress, but do keep scanning the list.
@@ -257,16 +262,33 @@ prune_cache_entries(void)
 		nfsd_reply_cache_free_locked(rp);
 		freed++;
 	}
+	return freed;
+}
+
+/*
+ * Walk the LRU list and prune off entries that are older than RC_EXPIRE.
+ * Also prune the oldest ones when the total exceeds the max number of entries.
+ */
+static long
+prune_cache_entries(void)
+{
+	unsigned int i;
+	long freed = 0;
+	bool cancel = true;
+
+	for (i = 0; i < drc_hashsize; i++) {
+		struct nfsd_drc_bucket *b = &drc_hashtbl[i];
+
+		freed += prune_bucket(b);
+		if (!list_empty(&b->lru_head))
+			cancel = false;
+	}
 
 	/*
-	 * Conditionally rearm the job. If we cleaned out the list, then
-	 * cancel any pending run (since there won't be any work to do).
-	 * Otherwise, we rearm the job or modify the existing one to run in
-	 * RC_EXPIRE since we just ran the pruner.
+	 * Conditionally rearm the job to run in RC_EXPIRE since we just
+	 * ran the pruner.
 	 */
-	if (list_empty(&lru_head))
-		cancel_delayed_work(&cache_cleaner);
-	else
+	if (!cancel)
 		mod_delayed_work(system_wq, &cache_cleaner, RC_EXPIRE);
 	return freed;
 }
@@ -458,7 +480,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 	rp->c_csum = csum;
 
 	hash_refile(b, rp);
-	lru_put_end(rp);
+	lru_put_end(b, rp);
 
 	/* release any buffer */
 	if (rp->c_type == RC_REPLBUFF) {
@@ -475,7 +497,7 @@ found_entry:
 	nfsdstats.rchits++;
 	/* We found a matching entry which is either in progress or done. */
 	age = jiffies - rp->c_timestamp;
-	lru_put_end(rp);
+	lru_put_end(b, rp);
 
 	rtn = RC_DROPIT;
 	/* Request being processed or excessive rexmits */
@@ -530,12 +552,17 @@ nfsd_cache_update(struct svc_rqst *rqstp, int cachetype, __be32 *statp)
 {
 	struct svc_cacherep *rp = rqstp->rq_cacherep;
 	struct kvec	*resv = &rqstp->rq_res.head[0], *cachv;
+	u32		hash;
+	struct nfsd_drc_bucket *b;
 	int		len;
 	size_t		bufsize = 0;
 
 	if (!rp)
 		return;
 
+	hash = nfsd_cache_hash(rp->c_xid);
+	b = &drc_hashtbl[hash];
+
 	len = resv->iov_len - ((char*)statp - (char*)resv->iov_base);
 	len >>= 2;
 
@@ -568,7 +595,7 @@ nfsd_cache_update(struct svc_rqst *rqstp, int cachetype, __be32 *statp)
 	}
 	spin_lock(&cache_lock);
 	drc_mem_usage += bufsize;
-	lru_put_end(rp);
+	lru_put_end(b, rp);
 	rp->c_secure = rqstp->rq_secure;
 	rp->c_type = cachetype;
 	rp->c_state = RC_DONE;
-- 
1.9.3


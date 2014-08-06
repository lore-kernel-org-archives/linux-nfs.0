Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:58888 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752161AbaHFRoj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Aug 2014 13:44:39 -0400
Received: by mail-ig0-f176.google.com with SMTP id hn18so9071224igb.15
        for <linux-nfs@vger.kernel.org>; Wed, 06 Aug 2014 10:44:38 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 5/6] nfsd: split DRC global spinlock into per-bucket locks
Date: Wed,  6 Aug 2014 13:44:24 -0400
Message-Id: <1407347065-17463-6-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1407347065-17463-5-git-send-email-trond.myklebust@primarydata.com>
References: <1407347065-17463-1-git-send-email-trond.myklebust@primarydata.com>
 <1407347065-17463-2-git-send-email-trond.myklebust@primarydata.com>
 <1407347065-17463-3-git-send-email-trond.myklebust@primarydata.com>
 <1407347065-17463-4-git-send-email-trond.myklebust@primarydata.com>
 <1407347065-17463-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfscache.c | 43 ++++++++++++++++++++-----------------------
 1 file changed, 20 insertions(+), 23 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index dc909091349b..74603654b7f9 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -29,6 +29,7 @@
 
 struct nfsd_drc_bucket {
 	struct list_head lru_head;
+	spinlock_t cache_lock;
 };
 
 static struct nfsd_drc_bucket	*drc_hashtbl;
@@ -79,7 +80,6 @@ static struct shrinker nfsd_reply_cache_shrinker = {
  * A cache entry is "single use" if c_state == RC_INPROG
  * Otherwise, it when accessing _prev or _next, the lock must be held.
  */
-static DEFINE_SPINLOCK(cache_lock);
 static DECLARE_DELAYED_WORK(cache_cleaner, cache_cleaner_func);
 
 /*
@@ -154,11 +154,11 @@ nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
 }
 
 static void
-nfsd_reply_cache_free(struct svc_cacherep *rp)
+nfsd_reply_cache_free(struct nfsd_drc_bucket *b, struct svc_cacherep *rp)
 {
-	spin_lock(&cache_lock);
+	spin_lock(&b->cache_lock);
 	nfsd_reply_cache_free_locked(rp);
-	spin_unlock(&cache_lock);
+	spin_unlock(&b->cache_lock);
 }
 
 int nfsd_reply_cache_init(void)
@@ -180,8 +180,10 @@ int nfsd_reply_cache_init(void)
 	drc_hashtbl = kcalloc(hashsize, sizeof(*drc_hashtbl), GFP_KERNEL);
 	if (!drc_hashtbl)
 		goto out_nomem;
-	for (i = 0; i < hashsize; i++)
+	for (i = 0; i < hashsize; i++) {
 		INIT_LIST_HEAD(&drc_hashtbl[i].lru_head);
+		spin_lock_init(&drc_hashtbl[i].cache_lock);
+	}
 	drc_hashsize = hashsize;
 
 	return 0;
@@ -265,9 +267,13 @@ prune_cache_entries(void)
 	for (i = 0; i < drc_hashsize; i++) {
 		struct nfsd_drc_bucket *b = &drc_hashtbl[i];
 
+		if (list_empty(&b->lru_head))
+			continue;
+		spin_lock(&b->cache_lock);
 		freed += prune_bucket(b);
 		if (!list_empty(&b->lru_head))
 			cancel = false;
+		spin_unlock(&b->cache_lock);
 	}
 
 	/*
@@ -282,9 +288,7 @@ prune_cache_entries(void)
 static void
 cache_cleaner_func(struct work_struct *unused)
 {
-	spin_lock(&cache_lock);
 	prune_cache_entries();
-	spin_unlock(&cache_lock);
 }
 
 static unsigned long
@@ -296,12 +300,7 @@ nfsd_reply_cache_count(struct shrinker *shrink, struct shrink_control *sc)
 static unsigned long
 nfsd_reply_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
 {
-	unsigned long freed;
-
-	spin_lock(&cache_lock);
-	freed = prune_cache_entries();
-	spin_unlock(&cache_lock);
-	return freed;
+	return prune_cache_entries();
 }
 /*
  * Walk an xdr_buf and get a CRC for at most the first RC_CSUMLEN bytes
@@ -426,14 +425,14 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 	 * preallocate an entry.
 	 */
 	rp = nfsd_reply_cache_alloc();
-	spin_lock(&cache_lock);
+	spin_lock(&b->cache_lock);
 	if (likely(rp)) {
 		atomic_inc(&num_drc_entries);
 		drc_mem_usage += sizeof(*rp);
 	}
 
 	/* go ahead and prune the cache */
-	prune_cache_entries();
+	prune_bucket(b);
 
 	found = nfsd_cache_search(b, rqstp, csum);
 	if (found) {
@@ -470,7 +469,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 	}
 	rp->c_type = RC_NOCACHE;
  out:
-	spin_unlock(&cache_lock);
+	spin_unlock(&b->cache_lock);
 	return rtn;
 
 found_entry:
@@ -548,7 +547,7 @@ nfsd_cache_update(struct svc_rqst *rqstp, int cachetype, __be32 *statp)
 
 	/* Don't cache excessive amounts of data and XDR failures */
 	if (!statp || len > (256 >> 2)) {
-		nfsd_reply_cache_free(rp);
+		nfsd_reply_cache_free(b, rp);
 		return;
 	}
 
@@ -563,23 +562,23 @@ nfsd_cache_update(struct svc_rqst *rqstp, int cachetype, __be32 *statp)
 		bufsize = len << 2;
 		cachv->iov_base = kmalloc(bufsize, GFP_KERNEL);
 		if (!cachv->iov_base) {
-			nfsd_reply_cache_free(rp);
+			nfsd_reply_cache_free(b, rp);
 			return;
 		}
 		cachv->iov_len = bufsize;
 		memcpy(cachv->iov_base, statp, bufsize);
 		break;
 	case RC_NOCACHE:
-		nfsd_reply_cache_free(rp);
+		nfsd_reply_cache_free(b, rp);
 		return;
 	}
-	spin_lock(&cache_lock);
+	spin_lock(&b->cache_lock);
 	drc_mem_usage += bufsize;
 	lru_put_end(b, rp);
 	rp->c_secure = rqstp->rq_secure;
 	rp->c_type = cachetype;
 	rp->c_state = RC_DONE;
-	spin_unlock(&cache_lock);
+	spin_unlock(&b->cache_lock);
 	return;
 }
 
@@ -610,7 +609,6 @@ nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *data)
  */
 static int nfsd_reply_cache_stats_show(struct seq_file *m, void *v)
 {
-	spin_lock(&cache_lock);
 	seq_printf(m, "max entries:           %u\n", max_drc_entries);
 	seq_printf(m, "num entries:           %u\n",
 			atomic_read(&num_drc_entries));
@@ -622,7 +620,6 @@ static int nfsd_reply_cache_stats_show(struct seq_file *m, void *v)
 	seq_printf(m, "payload misses:        %u\n", payload_misses);
 	seq_printf(m, "longest chain len:     %u\n", longest_chain);
 	seq_printf(m, "cachesize at longest:  %u\n", longest_chain_cachesize);
-	spin_unlock(&cache_lock);
 	return 0;
 }
 
-- 
1.9.3


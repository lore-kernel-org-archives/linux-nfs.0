Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:33088 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755648Ab3LELBE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Dec 2013 06:01:04 -0500
Received: by mail-qa0-f46.google.com with SMTP id f11so7486814qae.5
        for <linux-nfs@vger.kernel.org>; Thu, 05 Dec 2013 03:01:03 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH RFC 3/3] nfsd: convert DRC code to use list_lru
Date: Thu,  5 Dec 2013 06:00:53 -0500
Message-Id: <1386241253-5781-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1386241253-5781-1-git-send-email-jlayton@redhat.com>
References: <1386241253-5781-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rather than keeping our own LRU list, convert the nfsd DRC code to use
the new list_lru routines.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 94 ++++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 66 insertions(+), 28 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index f8f060f..7f5480f 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -13,6 +13,7 @@
 #include <linux/highmem.h>
 #include <linux/log2.h>
 #include <linux/hash.h>
+#include <linux/list_lru.h>
 #include <net/checksum.h>
 
 #include "nfsd.h"
@@ -28,7 +29,7 @@
 #define TARGET_BUCKET_SIZE	64
 
 static struct hlist_head *	cache_hash;
-static struct list_head 	lru_head;
+static struct list_lru		lru_head;
 static struct kmem_cache	*drc_slab;
 
 /* max number of entries allowed in the cache */
@@ -132,7 +133,7 @@ nfsd_reply_cache_alloc(void)
 }
 
 static void
-nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
+__nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
 {
 	if (rp->c_type == RC_REPLBUFF && rp->c_replvec.iov_base) {
 		drc_mem_usage -= rp->c_replvec.iov_len;
@@ -140,13 +141,26 @@ nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
 	}
 	if (!hlist_unhashed(&rp->c_hash))
 		hlist_del(&rp->c_hash);
-	list_del(&rp->c_lru);
 	--num_drc_entries;
 	drc_mem_usage -= sizeof(*rp);
 	kmem_cache_free(drc_slab, rp);
 }
 
 static void
+nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
+{
+	list_lru_del(&lru_head, &rp->c_lru);
+	__nfsd_reply_cache_free_locked(rp);
+}
+
+static void
+nfsd_reply_cache_free_isolate(struct svc_cacherep *rp)
+{
+	list_del(&rp->c_lru);
+	__nfsd_reply_cache_free_locked(rp);
+}
+
+static void
 nfsd_reply_cache_free(struct svc_cacherep *rp)
 {
 	spin_lock(&cache_lock);
@@ -156,50 +170,66 @@ nfsd_reply_cache_free(struct svc_cacherep *rp)
 
 int nfsd_reply_cache_init(void)
 {
+	int ret;
 	unsigned int hashsize;
 
-	INIT_LIST_HEAD(&lru_head);
 	max_drc_entries = nfsd_cache_size_limit();
 	num_drc_entries = 0;
 	hashsize = nfsd_hashsize(max_drc_entries);
 	maskbits = ilog2(hashsize);
 
 	register_shrinker(&nfsd_reply_cache_shrinker);
+
+	ret = list_lru_init(&lru_head);
+	if (ret)
+		goto out_error;
+
+	ret = -ENOMEM;
 	drc_slab = kmem_cache_create("nfsd_drc", sizeof(struct svc_cacherep),
 					0, 0, NULL);
 	if (!drc_slab)
-		goto out_nomem;
+		goto out_error;
 
 	cache_hash = kcalloc(hashsize, sizeof(struct hlist_head), GFP_KERNEL);
 	if (!cache_hash)
-		goto out_nomem;
+		goto out_error;
 
 	return 0;
-out_nomem:
-	printk(KERN_ERR "nfsd: failed to allocate reply cache\n");
+out_error:
+	printk(KERN_ERR "nfsd: failed to setup reply cache: %d\n", ret);
 	nfsd_reply_cache_shutdown();
-	return -ENOMEM;
+	return ret;
 }
 
-void nfsd_reply_cache_shutdown(void)
+static enum lru_status
+nfsd_purge_lru_entry(struct list_head *item, spinlock_t *lock, void *cb_arg)
 {
-	struct svc_cacherep	*rp;
+	struct svc_cacherep *rp = list_entry(item, struct svc_cacherep, c_lru);
 
+	nfsd_reply_cache_free_locked(rp);
+	return LRU_REMOVED;
+}
+
+void nfsd_reply_cache_shutdown(void)
+{
 	unregister_shrinker(&nfsd_reply_cache_shrinker);
 	cancel_delayed_work_sync(&cache_cleaner);
 
-	while (!list_empty(&lru_head)) {
-		rp = list_entry(lru_head.next, struct svc_cacherep, c_lru);
-		nfsd_reply_cache_free_locked(rp);
-	}
+	/* In principle, nothing should be altering the list now, but... */
+	spin_lock(&cache_lock);
+	list_lru_walk(&lru_head, nfsd_purge_lru_entry, NULL, ULONG_MAX);
+	spin_unlock(&cache_lock);
 
-	kfree (cache_hash);
+	kfree(cache_hash);
 	cache_hash = NULL;
 
 	if (drc_slab) {
 		kmem_cache_destroy(drc_slab);
 		drc_slab = NULL;
 	}
+
+	list_lru_destroy(&lru_head);
+	memset(&lru_head, 0, sizeof(lru_head));
 }
 
 /*
@@ -210,7 +240,8 @@ static void
 lru_put_end(struct svc_cacherep *rp)
 {
 	rp->c_timestamp = jiffies;
-	list_move_tail(&rp->c_lru, &lru_head);
+	list_lru_del(&lru_head, &rp->c_lru);
+	list_lru_add(&lru_head, &rp->c_lru);
 	schedule_delayed_work(&cache_cleaner, RC_EXPIRE);
 }
 
@@ -231,23 +262,30 @@ nfsd_cache_entry_expired(struct svc_cacherep *rp)
 	       time_after(jiffies, rp->c_timestamp + RC_EXPIRE);
 }
 
+static enum lru_status
+nfsd_purge_expired_entry(struct list_head *item, spinlock_t *lock, void *cb_arg)
+{
+	struct svc_cacherep *rp = list_entry(item, struct svc_cacherep, c_lru);
+
+	if (!nfsd_cache_entry_expired(rp) &&
+	    num_drc_entries <= max_drc_entries)
+		return LRU_SKIP_REST;
+
+	nfsd_reply_cache_free_isolate(rp);
+	return LRU_REMOVED;
+}
+
 /*
  * Walk the LRU list and prune off entries that are older than RC_EXPIRE.
  * Also prune the oldest ones when the total exceeds the max number of entries.
  */
-static long
+static unsigned long
 prune_cache_entries(void)
 {
-	struct svc_cacherep *rp, *tmp;
-	long freed = 0;
+	unsigned long freed;
 
-	list_for_each_entry_safe(rp, tmp, &lru_head, c_lru) {
-		if (!nfsd_cache_entry_expired(rp) &&
-		    num_drc_entries <= max_drc_entries)
-			break;
-		nfsd_reply_cache_free_locked(rp);
-		freed++;
-	}
+	freed = list_lru_walk(&lru_head, nfsd_purge_expired_entry, NULL,
+				ULONG_MAX);
 
 	/*
 	 * Conditionally rearm the job. If we cleaned out the list, then
@@ -255,7 +293,7 @@ prune_cache_entries(void)
 	 * Otherwise, we rearm the job or modify the existing one to run in
 	 * RC_EXPIRE since we just ran the pruner.
 	 */
-	if (list_empty(&lru_head))
+	if (num_drc_entries == 0)
 		cancel_delayed_work(&cache_cleaner);
 	else
 		mod_delayed_work(system_wq, &cache_cleaner, RC_EXPIRE);
-- 
1.8.4.2


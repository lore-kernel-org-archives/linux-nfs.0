From: Greg Banks <gnb@sgi.com>
Subject: [patch 17/29] knfsd: make the reply cache SMP-friendly
Date: Wed, 01 Apr 2009 07:28:17 +1100
Message-ID: <20090331202944.005574000@sgi.com>
References: <20090331202800.739621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [218.185.19.242] ([218.185.19.242]:22583 "EHLO inara.melbourne"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761643AbZCaVCl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 17:02:41 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make the reply cache scale better on large multiprocessor NFS servers,
by splitting the global lock into multiple locks one in each hash
bucket.  To avoid introducing a new global contention point, the
global LRU list of reply cache entries is split into multiple LRU
lists, one per hash bucket.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 fs/nfsd/nfscache.c |  166 ++++++++++++++++++++++++++++++------------
 1 file changed, 121 insertions(+), 45 deletions(-)

Index: bfields/fs/nfsd/nfscache.c
===================================================================
--- bfields.orig/fs/nfsd/nfscache.c
+++ bfields/fs/nfsd/nfscache.c
@@ -8,6 +8,9 @@
  * it does things a bit differently.
  *
  * Copyright (C) 1995, 1996 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
+ *
+ * SMP lock splitting by Greg Banks <gnb@sgi.com>
+ *     Copyright (c) 2005-2009 Silicon Graphics, Inc.
  */
 
 #include <linux/kernel.h>
@@ -27,11 +30,43 @@
  * Solaris2:	1024
  * DEC Unix:	512-4096
  */
-#define CACHESIZE		1024
-#define HASHSIZE		64
+/* number of buckets used to manage LRU lists and cache locks (power of 2) */
+#ifdef CONFIG_SMP
+#define CACHE_NUM_BUCKETS	64
+#else
+#define CACHE_NUM_BUCKETS	1
+#endif
+/* number of entries in all LRU lists (power of 2) */
+#define CACHE_SIZE		(1024)
+/* largest possible number of entries in LRU per bucket */
+#define CACHE_BUCKET_MAX_SIZE	(CACHE_SIZE/CACHE_NUM_BUCKETS)
+/* log2 of largest desired hash chain length */
+#define MAX_CHAIN_ORDER		2
+/* initial and maximum size of the per-bucket hash table */
+#define HASHSIZE		((CACHE_SIZE>>MAX_CHAIN_ORDER)/CACHE_NUM_BUCKETS)
+
+/*
+ * locking for the reply cache:
+ * A cache entry is "single use" if c_state == RC_INPROG
+ * Otherwise, it when accessing _prev or _next, the lock for the
+ * appropriate bucket must be held.
+ *
+ * On uniprocessor systems, we have a single global lock and LRU
+ * list.  However on multiprocessor systems, to reduce contention
+ * on that spinlock under heavy nonidempotent load (think chmod -R)
+ * we use multiple buckets.  The lower few bits of the hash index
+ * are used to index the buckets.
+ */
+struct svc_cache_bucket
+{
+	spinlock_t lock;
+	struct list_head lru;
+	unsigned int size;
+	struct hlist_head *hash;
+} ____cacheline_aligned_in_smp;
 
-static struct hlist_head *	cache_hash;
-static struct list_head 	lru_head;
+static struct svc_cache_bucket	cache_buckets[CACHE_NUM_BUCKETS];
+#define bucket_for_hash(hash)	(&cache_buckets[(hash) & (CACHE_NUM_BUCKETS-1)])
 static int			cache_disabled = 1;
 
 /*
@@ -49,39 +84,70 @@ static inline u32 request_hash(u32 xid, 
 	h ^= (xid >> 24);
 	h ^= ((xid & 0xff0000) >> 8);
 	h ^= sin->sin_addr.s_addr;
-	return h & (HASHSIZE-1);
+	return h;
 }
 
 static int	nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *vec);
 
 /*
- * locking for the reply cache:
- * A cache entry is "single use" if c_state == RC_INPROG
- * Otherwise, it when accessing _prev or _next, the lock must be held.
+ * Initialise the reply cache data structures.
+ * Called without cache_lock, uses it internally.  Returns
+ * 0 on success, an error otherwise.
  */
-static DEFINE_SPINLOCK(cache_lock);
-
-int nfsd_reply_cache_init(void)
+static int nfsd_cache_bucket_init(struct svc_cache_bucket *b, unsigned int num)
 {
-	struct svc_cacherep	*rp;
-	int			i;
+	struct svc_cacherep *rp;
+	unsigned int i;
+	LIST_HEAD(lru);
 
-	INIT_LIST_HEAD(&lru_head);
-	i = CACHESIZE;
+	/* allocate new entries without the lock, keep them on their own list */
+	i = num;
 	while (i) {
 		rp = kmalloc(sizeof(*rp), GFP_KERNEL);
 		if (!rp)
 			goto out_nomem;
-		list_add(&rp->c_lru, &lru_head);
+		list_add(&rp->c_lru, &lru);
 		rp->c_state = RC_UNUSED;
 		rp->c_type = RC_NOCACHE;
 		INIT_HLIST_NODE(&rp->c_hash);
 		i--;
 	}
 
-	cache_hash = kcalloc (HASHSIZE, sizeof(struct hlist_head), GFP_KERNEL);
-	if (!cache_hash)
-		goto out_nomem;
+	/* add the new entries */
+	spin_lock(&b->lock);
+
+	b->size = num;
+	list_splice(&lru, &b->lru);
+
+	spin_unlock(&b->lock);
+	return 0;
+
+out_nomem:
+	/* free any entries we've allocated but not spliced in */
+	while (!list_empty(&lru)) {
+		rp = list_entry(lru.next, struct svc_cacherep, c_lru);
+		list_del(&rp->c_lru);
+		kfree (rp);
+	}
+	return -ENOMEM;
+}
+
+int nfsd_reply_cache_init(void)
+{
+	unsigned int bucket;
+
+	for (bucket = 0 ; bucket < CACHE_NUM_BUCKETS ; bucket++)
+	{
+		struct svc_cache_bucket *b = &cache_buckets[bucket];
+
+		INIT_LIST_HEAD(&b->lru);
+		spin_lock_init(&b->lock);
+		if (nfsd_cache_bucket_init(b, CACHE_SIZE/CACHE_NUM_BUCKETS))
+			goto out_nomem;
+		b->hash = kcalloc (HASHSIZE, sizeof(struct hlist_head), GFP_KERNEL);
+		if (!b->hash)
+			goto out_nomem;
+	}
 
 	cache_disabled = 0;
 	return 0;
@@ -94,28 +160,32 @@ out_nomem:
 void nfsd_reply_cache_shutdown(void)
 {
 	struct svc_cacherep	*rp;
+	unsigned int bucket;
 
-	while (!list_empty(&lru_head)) {
-		rp = list_entry(lru_head.next, struct svc_cacherep, c_lru);
-		if (rp->c_state == RC_DONE && rp->c_type == RC_REPLBUFF)
-			kfree(rp->c_replvec.iov_base);
-		list_del(&rp->c_lru);
-		kfree(rp);
+	for (bucket = 0 ; bucket < CACHE_NUM_BUCKETS ; bucket++)
+	{
+		struct svc_cache_bucket *b = &cache_buckets[bucket];
+
+		while (!list_empty(&b->lru)) {
+			rp = list_entry(b->lru.next, struct svc_cacherep, c_lru);
+			if (rp->c_state == RC_DONE && rp->c_type == RC_REPLBUFF)
+				kfree(rp->c_replvec.iov_base);
+			list_del(&rp->c_lru);
+			kfree(rp);
+		}
+		kfree (b->hash);
+		b->hash = NULL;
 	}
 
 	cache_disabled = 1;
-
-	kfree (cache_hash);
-	cache_hash = NULL;
 }
 
 /*
  * Move cache entry to end of LRU list
  */
-static void
-lru_put_end(struct svc_cacherep *rp)
+static inline void lru_put_end(struct svc_cache_bucket *b, struct svc_cacherep *rp)
 {
-	list_move_tail(&rp->c_lru, &lru_head);
+	list_move_tail(&rp->c_lru, &b->lru);
 }
 
 /*
@@ -134,8 +204,9 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 				vers = rqstp->rq_vers,
 				proc = rqstp->rq_proc,
 				h;
+	struct svc_cache_bucket *b;
 	unsigned long		age;
-	int rtn;
+	int			rtn;
 
 	rqstp->rq_cacherep = NULL;
 	if (cache_disabled || type == RC_NOCACHE) {
@@ -143,11 +214,13 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 		return RC_DOIT;
 	}
 	h = request_hash(xid, svc_addr_in(rqstp));
+	b = bucket_for_hash(h);
+	h = (h / CACHE_NUM_BUCKETS) & (HASHSIZE-1);
 
-	spin_lock(&cache_lock);
+	spin_lock(&b->lock);
 	rtn = RC_DOIT;
 
-	rh = &cache_hash[h];
+	rh = &b->hash[h];
 	hlist_for_each_entry(rp, hn, rh, c_hash) {
 		if (rp->c_state != RC_UNUSED &&
 		    xid == rp->c_xid && proc == rp->c_proc &&
@@ -163,10 +236,10 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	/* This loop shouldn't take more than a few iterations normally */
 	{
 	int	safe = 0;
-	list_for_each_entry(rp, &lru_head, c_lru) {
+	list_for_each_entry(rp, &b->lru, c_lru) {
 		if (rp->c_state != RC_INPROG)
 			break;
-		if (safe++ > CACHESIZE) {
+		if (safe++ > b->size) {
 			printk("nfsd: loop in repcache LRU list\n");
 			cache_disabled = 1;
 			goto out;
@@ -175,7 +248,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	}
 
 	/* All entries on the LRU are in-progress. This should not happen */
-	if (&rp->c_lru == &lru_head) {
+	if (&rp->c_lru == &b->lru) {
 		static int	complaints;
 
 		printk(KERN_WARNING "nfsd: all repcache entries locked!\n");
@@ -197,7 +270,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 
 	/* Move the cache entry from one hash list to another */
 	hlist_del_init(&rp->c_hash);
-	hlist_add_head(&rp->c_hash, cache_hash + h);
+	hlist_add_head(&rp->c_hash, b->hash + h);
 
 	/* release any buffer */
 	if (rp->c_type == RC_REPLBUFF) {
@@ -206,14 +279,14 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	}
 	rp->c_type = RC_NOCACHE;
  out:
-	spin_unlock(&cache_lock);
+	spin_unlock(&b->lock);
 	return rtn;
 
 found_entry:
 	/* We found a matching entry which is either in progress or done. */
 	age = jiffies - rp->c_timestamp;
 	rp->c_timestamp = jiffies;
-	lru_put_end(rp);
+	lru_put_end(b, rp);
 
 	rtn = RC_DROPIT;
 	/* Request being processed or excessive rexmits */
@@ -269,10 +342,13 @@ nfsd_cache_update(struct svc_rqst *rqstp
 	struct svc_cacherep *rp;
 	struct kvec	*resv = &rqstp->rq_res.head[0], *cachv;
 	int		len;
+	struct svc_cache_bucket *b;
 
 	if (!(rp = rqstp->rq_cacherep) || cache_disabled)
 		return;
 
+	b = bucket_for_hash(request_hash(rp->c_xid, &rp->c_addr));
+
 	len = resv->iov_len - ((char*)statp - (char*)resv->iov_base);
 	len >>= 2;
 
@@ -292,22 +368,22 @@ nfsd_cache_update(struct svc_rqst *rqstp
 		cachv = &rp->c_replvec;
 		cachv->iov_base = kmalloc(len << 2, GFP_KERNEL);
 		if (!cachv->iov_base) {
-			spin_lock(&cache_lock);
+			spin_lock(&b->lock);
 			rp->c_state = RC_UNUSED;
-			spin_unlock(&cache_lock);
+			spin_unlock(&b->lock);
 			return;
 		}
 		cachv->iov_len = len << 2;
 		memcpy(cachv->iov_base, statp, len << 2);
 		break;
 	}
-	spin_lock(&cache_lock);
-	lru_put_end(rp);
+	spin_lock(&b->lock);
+	lru_put_end(b, rp);
 	rp->c_secure = rqstp->rq_secure;
 	rp->c_type = cachetype;
 	rp->c_state = RC_DONE;
 	rp->c_timestamp = jiffies;
-	spin_unlock(&cache_lock);
+	spin_unlock(&b->lock);
 	return;
 }
 

--
Greg

From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 4/8] knfsd: repcache: split hash index
Date: Wed, 11 Oct 2006 21:27:24 +1000
Message-ID: <1160566044.8530.13.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GXcFH-0001QG-37
	for nfs@lists.sourceforge.net; Wed, 11 Oct 2006 04:27:31 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GXcFH-0005TB-L3
	for nfs@lists.sourceforge.net; Wed, 11 Oct 2006 04:27:32 -0700
To: Neil Brown <neilb@suse.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

knfsd: Split the duplicate request cache hash into multiple buckets
on SMP platforms, to avoid lock contention and bouncing cachelines.

Each non-idempotent NFS call (such as WRITE calls) exercises the
repcache twice: a lookup before the call is dispatched and an insert
afterward.  On write-heavy workloads, the single repcache spinlock
is a contention point.

On a 4 cpu Altix A350, running at circa 80,000 nonidempotent
calls per second, this change reduced CPU usage in nfsd_cache_lookup()
from 27.1% to 12.8% (out of 400%).

The hash index itself is also split into multiple smaller allocations,
one per bucket.  This allows the total effective size of the index to
be larger than without running the risk of running into the kmalloc()
size limit (an earlier version of this patch set resized the hash
index and would run into that limit).

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 fs/nfsd/nfscache.c |  166 ++++++++++++++++++++++++++++++------------
 1 files changed, 120 insertions(+), 46 deletions(-)

Index: linux-git-20061009/fs/nfsd/nfscache.c
===================================================================
--- linux-git-20061009.orig/fs/nfsd/nfscache.c	2006-10-10 16:37:52.170497220 +1000
+++ linux-git-20061009/fs/nfsd/nfscache.c	2006-10-10 16:39:12.624126466 +1000
@@ -8,6 +8,9 @@
  * it does things a bit differently.
  *
  * Copyright (C) 1995, 1996 Olaf Kirch <okir@monad.swb.de>
+ *
+ * SMP lock splitting by Greg Banks <gnb@melbourne.sgi.com>
+ *     Copyright (c) 2005-2006 Silicon Graphics, Inc.
  */
 
 #include <linux/kernel.h>
@@ -28,10 +31,43 @@
  * DEC Unix:	512-4096
  */
 #define CACHESIZE		1024
-#define HASHSIZE		64
+/* number of buckets used to manage LRU lists and cache locks (power of 2) */
+#ifdef CONFIG_SMP
+#define CACHE_NUM_BUCKETS	64
+#else
+#define CACHE_NUM_BUCKETS	1
+#endif
+/* largest possible number of entries in all LRU lists (power of 2) */
+#define CACHE_MAX_SIZE		(16*1024*CACHE_NUM_BUCKETS)
+/* largest possible number of entries in LRU per bucket */
+#define CACHE_BUCKET_MAX_SIZE	(CACHE_MAX_SIZE/CACHE_NUM_BUCKETS)
+/* log2 of largest desired hash chain length */
+#define MAX_CHAIN_ORDER		2
+/* size of the per-bucket hash table */
+#define HASHSIZE		((CACHE_MAX_SIZE>>MAX_CHAIN_ORDER)/CACHE_NUM_BUCKETS)
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
 
-static struct hlist_head *	hash_list;
-static struct list_head 	lru_head;
+static struct svc_cache_bucket	cache_buckets[CACHE_NUM_BUCKETS];
+#define bucket_for_hash(hash)	(&cache_buckets[(hash) & (CACHE_NUM_BUCKETS-1)])
 static int			cache_disabled = 1;
 
 /*
@@ -45,31 +81,30 @@ request_hash(u32 xid)
 	u32 h = xid;
 	h ^= (xid >> 24);
 	h ^= ((xid & 0xff0000) >> 8);
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
-void
-nfsd_cache_init(void)
+static void
+nfsd_cache_bucket_init(struct svc_cache_bucket *b, unsigned int nrecs)
 {
 	struct svc_cacherep	*rp;
-	int			i;
+	unsigned int		i;
+	LIST_HEAD(lru);
 
-	INIT_LIST_HEAD(&lru_head);
-	i = CACHESIZE;
+	/* allocate new entries without the lock, keep them on their own list */
+	i = nrecs;
 	while (i) {
 		rp = kmalloc(sizeof(*rp), GFP_KERNEL);
 		if (!rp)
 			break;
-		list_add(&rp->c_lru, &lru_head);
+		list_add(&rp->c_lru, &lru);
 		rp->c_state = RC_UNUSED;
 		rp->c_type = RC_NOCACHE;
 		INIT_HLIST_NODE(&rp->c_hash);
@@ -77,17 +112,41 @@ nfsd_cache_init(void)
 	}
 
 	if (i)
-		printk (KERN_ERR "nfsd: cannot allocate all %d cache entries, only got %d\n",
-			CACHESIZE, CACHESIZE-i);
+		printk (KERN_ERR "nfsd: cannot allocate all %u cache entries, only got %u\n",
+			nrecs, nrecs-i);
 
-	hash_list = kmalloc (HASHSIZE * sizeof(struct hlist_head), GFP_KERNEL);
-	if (!hash_list) {
-		nfsd_cache_shutdown();
-		printk (KERN_ERR "nfsd: cannot allocate %Zd bytes for hash list\n",
-			HASHSIZE * sizeof(struct hlist_head));
-		return;
+
+	/* add the new entries */
+	spin_lock(&b->lock);
+
+	b->size += (nrecs-i);
+	list_splice(&lru, &b->lru);
+
+	spin_unlock(&b->lock);
+}
+
+void
+nfsd_cache_init(void)
+{
+	unsigned int bucket;
+
+	for (bucket = 0 ; bucket < CACHE_NUM_BUCKETS ; bucket++)
+	{
+		struct svc_cache_bucket *b = &cache_buckets[bucket];
+
+		INIT_LIST_HEAD(&b->lru);
+		spin_lock_init(&b->lock);
+		nfsd_cache_bucket_init(b, CACHESIZE/CACHE_NUM_BUCKETS);
+
+		b->hash = kmalloc (HASHSIZE * sizeof(struct hlist_head), GFP_KERNEL);
+		if (!b->hash) {
+			nfsd_cache_shutdown();
+			printk (KERN_ERR "nfsd: cannot allocate %Zd bytes for hash index\n",
+				HASHSIZE * sizeof(struct hlist_head));
+			return;
+		}
+		memset(b->hash, 0, HASHSIZE * sizeof(struct hlist_head));
 	}
-	memset(hash_list, 0, HASHSIZE * sizeof(struct hlist_head));
 
 	cache_disabled = 0;
 }
@@ -96,28 +155,34 @@ void
 nfsd_cache_shutdown(void)
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
 
-	kfree (hash_list);
-	hash_list = NULL;
 }
 
 /*
  * Move cache entry to end of LRU list
  */
 static void
-lru_put_end(struct svc_cacherep *rp)
+lru_put_end(struct svc_cache_bucket *b, struct svc_cacherep *rp)
 {
-	list_move_tail(&rp->c_lru, &lru_head);
+	list_move_tail(&rp->c_lru, &b->lru);
 }
 
 /*
@@ -135,20 +200,26 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 				proto =  rqstp->rq_prot,
 				vers = rqstp->rq_vers,
 				proc = rqstp->rq_proc;
+	u32			h;
+	struct svc_cache_bucket *b;
 	unsigned long		age;
 	int			rtn;
 	int			safe = 0;
 
+	h = request_hash(xid);
+	b = bucket_for_hash(h);
+	h = (h / CACHE_NUM_BUCKETS) & (HASHSIZE-1);
+
 	rqstp->rq_cacherep = NULL;
 	if (cache_disabled || type == RC_NOCACHE) {
 		nfsdstats.rcnocache++;
 		return RC_DOIT;
 	}
 
-	spin_lock(&cache_lock);
+	spin_lock(&b->lock);
 	rtn = RC_DOIT;
 
-	rh = &hash_list[request_hash(xid)];
+	rh = &b->hash[h];
 	hlist_for_each_entry(rp, hn, rh, c_hash) {
 		if (rp->c_state != RC_UNUSED &&
 		    xid == rp->c_xid && proc == rp->c_proc &&
@@ -162,10 +233,10 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	nfsdstats.rcmisses++;
 
 	/* This loop shouldn't take more than a few iterations normally */
-	list_for_each_entry(rp, &lru_head, c_lru) {
+	list_for_each_entry(rp, &b->lru, c_lru) {
 		if (rp->c_state != RC_INPROG)
 			break;
-		if (safe++ > CACHESIZE) {
+		if (safe++ > b->size) {
 			printk("nfsd: loop in repcache LRU list\n");
 			cache_disabled = 1;
 			goto out;
@@ -195,7 +266,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 
  	/* Move the cache entry from one hash list to another */
 	hlist_del_init(&rp->c_hash);
-	hlist_add_head(&rp->c_hash, hash_list + request_hash(rp->c_xid));
+	hlist_add_head(&rp->c_hash, b->hash + h);
 
 	/* release any buffer */
 	if (rp->c_type == RC_REPLBUFF) {
@@ -204,14 +275,14 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
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
@@ -267,10 +338,13 @@ nfsd_cache_update(struct svc_rqst *rqstp
 	struct svc_cacherep *rp;
 	struct kvec	*resv = &rqstp->rq_res.head[0], *cachv;
 	int		len;
+	struct svc_cache_bucket *b;
 
 	if (!(rp = rqstp->rq_cacherep) || cache_disabled)
 		return;
 
+	b = bucket_for_hash(request_hash(rp->c_xid));
+
 	len = resv->iov_len - ((char*)statp - (char*)resv->iov_base);
 	len >>= 2;
 
@@ -290,22 +364,22 @@ nfsd_cache_update(struct svc_rqst *rqstp
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
 

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

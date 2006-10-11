From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 5/8] knfsd: repcache: dynamically expand under load
Date: Wed, 11 Oct 2006 21:28:08 +1000
Message-ID: <1160566088.8530.15.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GXcFx-0001Vy-Pj
	for nfs@lists.sourceforge.net; Wed, 11 Oct 2006 04:28:13 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GXcFy-0007Mn-Df
	for nfs@lists.sourceforge.net; Wed, 11 Oct 2006 04:28:14 -0700
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

knfsd: The duplicate request cache has a static size whose value
was chosen in the dim mists of history and is now far too small for
the data structure to be useful.  So, allow it to expand on demand,
when too young an entry falls off the end of an LRU chain.

There is no way to tune the maximum size or minimum age parameters at
runtime, nor has any provision been made for shrinking the repcache
under memory pressure.  The maximum size observed, on a multi-CPU
multi-NIC machine handling an extreme workload of about 80,000
non-idempotent calls per second, has been only about 16MiB.

An earlier version of this patch set contained code that also expanded
the hash index under load, but testing shows that merely overallocating
the initial hash index provides a good enough index for observed
loads so the extra complexity was not considered worthwhile.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 fs/nfsd/nfscache.c |   66 ++++++++++++++++++++++++++++++++++++++----
 1 files changed, 61 insertions(+), 5 deletions(-)

Index: linux-git-20061009/fs/nfsd/nfscache.c
===================================================================
--- linux-git-20061009.orig/fs/nfsd/nfscache.c	2006-10-10 16:39:12.624126466 +1000
+++ linux-git-20061009/fs/nfsd/nfscache.c	2006-10-10 16:41:07.121363949 +1000
@@ -9,7 +9,7 @@
  *
  * Copyright (C) 1995, 1996 Olaf Kirch <okir@monad.swb.de>
  *
- * SMP lock splitting by Greg Banks <gnb@melbourne.sgi.com>
+ * Dynamic expansion and SMP lock splitting by Greg Banks <gnb@melbourne.sgi.com>
  *     Copyright (c) 2005-2006 Silicon Graphics, Inc.
  */
 
@@ -24,11 +24,21 @@
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/cache.h>
 
-/* Size of reply cache. Common values are:
+/* Initial size of reply cache. Common values are:
  * 4.3BSD:	128
  * 4.4BSD:	256
  * Solaris2:	1024
  * DEC Unix:	512-4096
+ *
+ * All these values reflect network packet rates and NFS loads common
+ * somewhen around 1990, and are utterly inadequate for modern NFS
+ * servers.  To be at all effective the reply cache needs to hold all
+ * NFS calls seen by the server for at least a client RPC timeout period
+ * (typically 1.1 seconds), and to handle weird IP routing issues should
+ * really hold 120 seconds of traffic.  A modern NFS server can be
+ * fielding upwards of 10,000 calls per second, which means the default
+ * cache size of 1024 holds about 102 milliseconds'  traffic, i.e. the
+ * default size is three orders of magnitude too small.
  */
 #define CACHESIZE		1024
 /* number of buckets used to manage LRU lists and cache locks (power of 2) */
@@ -41,10 +51,16 @@
 #define CACHE_MAX_SIZE		(16*1024*CACHE_NUM_BUCKETS)
 /* largest possible number of entries in LRU per bucket */
 #define CACHE_BUCKET_MAX_SIZE	(CACHE_MAX_SIZE/CACHE_NUM_BUCKETS)
+/* number of entries each bucket will expand by */
+#define CACHE_BUCKET_INCREMENT	(1024/CACHE_NUM_BUCKETS)
 /* log2 of largest desired hash chain length */
 #define MAX_CHAIN_ORDER		2
 /* size of the per-bucket hash table */
 #define HASHSIZE		((CACHE_MAX_SIZE>>MAX_CHAIN_ORDER)/CACHE_NUM_BUCKETS)
+/* the cache attempts to expand if an entry younger than this is evicted */
+#define CACHE_THRESH_AGE	(11 * HZ / 10)  /* in jiffies */
+/* parameters for rate limiting cache expansion */
+#define CACHE_RATE_JIFFIES	(HZ/2)
 
 /*
  * locking for the reply cache:
@@ -64,6 +80,9 @@ struct svc_cache_bucket
 	struct list_head lru;
 	unsigned int size;
 	struct hlist_head *hash;
+	/* parameters for expand rate limiting */
+	unsigned long last;
+	unsigned long nhits;
 } ____cacheline_aligned_in_smp;
 
 static struct svc_cache_bucket	cache_buckets[CACHE_NUM_BUCKETS];
@@ -87,12 +106,12 @@ request_hash(u32 xid)
 static int	nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *vec);
 
 /*
- * Initialise the reply cache data structures.
+ * Expand (or initialise) the reply cache data structures.
  * Called without cache_lock, uses it internally.  Returns
  * 0 on success, an error otherwise.
  */
 static void
-nfsd_cache_bucket_init(struct svc_cache_bucket *b, unsigned int nrecs)
+nfsd_cache_bucket_expand(struct svc_cache_bucket *b, unsigned int nrecs)
 {
 	struct svc_cacherep	*rp;
 	unsigned int		i;
@@ -136,7 +155,7 @@ nfsd_cache_init(void)
 
 		INIT_LIST_HEAD(&b->lru);
 		spin_lock_init(&b->lock);
-		nfsd_cache_bucket_init(b, CACHESIZE/CACHE_NUM_BUCKETS);
+		nfsd_cache_bucket_expand(b, CACHESIZE/CACHE_NUM_BUCKETS);
 
 		b->hash = kmalloc (HASHSIZE * sizeof(struct hlist_head), GFP_KERNEL);
 		if (!b->hash) {
@@ -186,6 +205,28 @@ lru_put_end(struct svc_cache_bucket *b, 
 }
 
 /*
+ * Decide whether it is time to expand the cache.  Returns 1 iff
+ * the cache is to be expanded.  Called with bucket lock held.
+ */
+static int
+nfsd_cache_expand_ratelimit(struct svc_cache_bucket *b)
+{
+	unsigned long now = jiffies;
+
+	b->nhits++;
+	if (b->last == 0) {
+		b->last = now;
+	} else if ((now - b->last) > CACHE_RATE_JIFFIES &&
+		   b->nhits > (b->size >> 4)) {
+		b->nhits = 0;
+		b->last = now;
+		return 1;
+	}
+	return 0;
+}
+
+
+/*
  * Try to find an entry matching the current call in the cache. When none
  * is found, we grab the oldest unlocked entry off the LRU list.
  * Note that no operation within the loop may sleep.
@@ -205,6 +246,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	unsigned long		age;
 	int			rtn;
 	int			safe = 0;
+	int			expand = 0;
 
 	h = request_hash(xid);
 	b = bucket_for_hash(h);
@@ -255,6 +297,18 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 		goto out;
 	}
 
+	if (rp->c_state != RC_UNUSED) {
+		/* reusing an existing cache entry */
+		age = jiffies - rp->c_timestamp;
+		if (age < CACHE_THRESH_AGE &&
+		    b->size < CACHE_BUCKET_MAX_SIZE &&
+		    nfsd_cache_expand_ratelimit(b)) {
+			expand = CACHE_BUCKET_INCREMENT;
+			if (b->size + expand > CACHE_BUCKET_MAX_SIZE)
+				expand = CACHE_BUCKET_MAX_SIZE - b->size;
+		}
+	}
+
 	rqstp->rq_cacherep = rp;
 	rp->c_state = RC_INPROG;
 	rp->c_xid = xid;
@@ -276,6 +330,8 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	rp->c_type = RC_NOCACHE;
  out:
 	spin_unlock(&b->lock);
+	if (expand)
+		nfsd_cache_bucket_expand(b, expand);
 	return rtn;
 
 found_entry:

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

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f173.google.com ([209.85.214.173]:38617 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755161Ab3CSNL6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Mar 2013 09:11:58 -0400
Received: by mail-ob0-f173.google.com with SMTP id dn14so393617obc.32
        for <linux-nfs@vger.kernel.org>; Tue, 19 Mar 2013 06:11:58 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 6/6] nfsd: scale up the number of DRC hash buckets with cache size
Date: Tue, 19 Mar 2013 09:11:46 -0400
Message-Id: <1363698706-22036-7-git-send-email-jlayton@redhat.com>
In-Reply-To: <1363698706-22036-1-git-send-email-jlayton@redhat.com>
References: <1363698706-22036-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We've now increased the size of the duplicate reply cache by quite a
bit, but the number of hash buckets has not changed. So, we've gone from
an average hash chain length of 16 in the old code to 4096 when the
cache is its largest. Change the code to scale out the number of buckets
with the max size of the cache.

At the same time, we also need to fix the hash function since the
existing one isn't really suitable when there are more than 256 buckets.
Move instead to use the stock hash_32 function for this. Testing on a
machine that had 2048 buckets showed that this gave a smaller
longest:average ratio than the existing hash function:

The formula here is longest hash bucket searched divided by average
number of entries per bucket at the time that we saw that longest
bucket:

    old hash: 68/(39258/2048) == 3.547404
    hash_32:  45/(33773/2048) == 2.728807

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 44 +++++++++++++++++++++++++++++---------------
 1 file changed, 29 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 17cb0d6..eb25877 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -11,6 +11,8 @@
 #include <linux/slab.h>
 #include <linux/sunrpc/addr.h>
 #include <linux/highmem.h>
+#include <linux/log2.h>
+#include <linux/hash.h>
 #include <net/checksum.h>
 
 #include "nfsd.h"
@@ -18,7 +20,12 @@
 
 #define NFSDDBG_FACILITY	NFSDDBG_REPCACHE
 
-#define HASHSIZE		64
+/*
+ * We use this value to determine the number of hash buckets from the max
+ * cache size, the idea being that when the cache is at its maximum number
+ * of entries, then this should be the average number of entries per bucket.
+ */
+#define TARGET_BUCKET_SIZE	64
 
 static struct hlist_head *	cache_hash;
 static struct list_head 	lru_head;
@@ -27,6 +34,9 @@ static struct kmem_cache	*drc_slab;
 /* max number of entries allowed in the cache */
 static unsigned int		max_drc_entries;
 
+/* number of significant bits in the hash value */
+static unsigned int		maskbits;
+
 /*
  * Stats and other tracking of on the duplicate reply cache. All of these and
  * the "rc" fields in nfsdstats are protected by the cache_lock
@@ -47,16 +57,6 @@ static unsigned int		longest_chain;
 /* size of cache when we saw the longest hash chain */
 static unsigned int		longest_chain_cachesize;
 
-/*
- * Calculate the hash index from an XID.
- */
-static inline u32 request_hash(u32 xid)
-{
-	u32 h = xid;
-	h ^= (xid >> 24);
-	return h & (HASHSIZE-1);
-}
-
 static int	nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *vec);
 static void	cache_cleaner_func(struct work_struct *unused);
 static int 	nfsd_reply_cache_shrink(struct shrinker *shrink,
@@ -103,6 +103,16 @@ nfsd_cache_size_limit(void)
 	return min_t(unsigned int, limit, 256*1024);
 }
 
+/*
+ * Compute the number of hash buckets we need. Divide the max cachesize by
+ * the "target" max bucket size, and round up to next power of two.
+ */
+static unsigned int
+nfsd_hashsize(unsigned int limit)
+{
+	return roundup_pow_of_two(limit / TARGET_BUCKET_SIZE);
+}
+
 static struct svc_cacherep *
 nfsd_reply_cache_alloc(void)
 {
@@ -143,9 +153,13 @@ nfsd_reply_cache_free(struct svc_cacherep *rp)
 
 int nfsd_reply_cache_init(void)
 {
+	unsigned int hashsize;
+
 	INIT_LIST_HEAD(&lru_head);
 	max_drc_entries = nfsd_cache_size_limit();
 	num_drc_entries = 0;
+	hashsize = nfsd_hashsize(max_drc_entries);
+	maskbits = ilog2(hashsize);
 
 	register_shrinker(&nfsd_reply_cache_shrinker);
 	drc_slab = kmem_cache_create("nfsd_drc", sizeof(struct svc_cacherep),
@@ -153,7 +167,7 @@ int nfsd_reply_cache_init(void)
 	if (!drc_slab)
 		goto out_nomem;
 
-	cache_hash = kcalloc(HASHSIZE, sizeof(struct hlist_head), GFP_KERNEL);
+	cache_hash = kcalloc(hashsize, sizeof(struct hlist_head), GFP_KERNEL);
 	if (!cache_hash)
 		goto out_nomem;
 
@@ -204,7 +218,7 @@ static void
 hash_refile(struct svc_cacherep *rp)
 {
 	hlist_del_init(&rp->c_hash);
-	hlist_add_head(&rp->c_hash, cache_hash + request_hash(rp->c_xid));
+	hlist_add_head(&rp->c_hash, cache_hash + hash_32(rp->c_xid, maskbits));
 }
 
 static inline bool
@@ -329,7 +343,7 @@ nfsd_cache_search(struct svc_rqst *rqstp, __wsum csum)
 	struct hlist_head 	*rh;
 	unsigned int		entries = 0;
 
-	rh = &cache_hash[request_hash(rqstp->rq_xid)];
+	rh = &cache_hash[hash_32(rqstp->rq_xid, maskbits)];
 	hlist_for_each_entry(rp, rh, c_hash) {
 		++entries;
 		if (nfsd_cache_match(rqstp, csum, rp)) {
@@ -588,7 +602,7 @@ static int nfsd_reply_cache_stats_show(struct seq_file *m, void *v)
 	spin_lock(&cache_lock);
 	seq_printf(m, "max entries:           %u\n", max_drc_entries);
 	seq_printf(m, "num entries:           %u\n", num_drc_entries);
-	seq_printf(m, "hash buckets:          %u\n", HASHSIZE);
+	seq_printf(m, "hash buckets:          %u\n", 1 << maskbits);
 	seq_printf(m, "mem usage:             %u\n", drc_mem_usage);
 	seq_printf(m, "cache hits:            %u\n", nfsdstats.rchits);
 	seq_printf(m, "cache misses:          %u\n", nfsdstats.rcmisses);
-- 
1.7.11.7


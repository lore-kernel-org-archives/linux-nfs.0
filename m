Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:38339 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754014AbaHFRoi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Aug 2014 13:44:38 -0400
Received: by mail-ie0-f180.google.com with SMTP id at20so3259074iec.39
        for <linux-nfs@vger.kernel.org>; Wed, 06 Aug 2014 10:44:37 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/6] nfsd: convert num_drc_entries to an atomic_t
Date: Wed,  6 Aug 2014 13:44:23 -0400
Message-Id: <1407347065-17463-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1407347065-17463-4-git-send-email-trond.myklebust@primarydata.com>
References: <1407347065-17463-1-git-send-email-trond.myklebust@primarydata.com>
 <1407347065-17463-2-git-send-email-trond.myklebust@primarydata.com>
 <1407347065-17463-3-git-send-email-trond.myklebust@primarydata.com>
 <1407347065-17463-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...so we can remove the spinlocking around it.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfscache.c | 28 ++++++++++++----------------
 1 file changed, 12 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 8abec475f80f..dc909091349b 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -47,7 +47,7 @@ static unsigned int		drc_hashsize;
  */
 
 /* total number of entries */
-static unsigned int		num_drc_entries;
+static atomic_t			num_drc_entries;
 
 /* cache misses due only to checksum comparison failures */
 static unsigned int		payload_misses;
@@ -148,7 +148,7 @@ nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
 		kfree(rp->c_replvec.iov_base);
 	}
 	list_del(&rp->c_lru);
-	--num_drc_entries;
+	atomic_dec(&num_drc_entries);
 	drc_mem_usage -= sizeof(*rp);
 	kmem_cache_free(drc_slab, rp);
 }
@@ -167,7 +167,7 @@ int nfsd_reply_cache_init(void)
 	unsigned int i;
 
 	max_drc_entries = nfsd_cache_size_limit();
-	num_drc_entries = 0;
+	atomic_set(&num_drc_entries, 0);
 	hashsize = nfsd_hashsize(max_drc_entries);
 	maskbits = ilog2(hashsize);
 
@@ -242,7 +242,7 @@ prune_bucket(struct nfsd_drc_bucket *b)
 		 */
 		if (rp->c_state == RC_INPROG)
 			continue;
-		if (num_drc_entries <= max_drc_entries &&
+		if (atomic_read(&num_drc_entries) <= max_drc_entries &&
 		    time_before(jiffies, rp->c_timestamp + RC_EXPIRE))
 			break;
 		nfsd_reply_cache_free_locked(rp);
@@ -290,13 +290,7 @@ cache_cleaner_func(struct work_struct *unused)
 static unsigned long
 nfsd_reply_cache_count(struct shrinker *shrink, struct shrink_control *sc)
 {
-	unsigned long num;
-
-	spin_lock(&cache_lock);
-	num = num_drc_entries;
-	spin_unlock(&cache_lock);
-
-	return num;
+	return atomic_read(&num_drc_entries);
 }
 
 static unsigned long
@@ -386,11 +380,12 @@ nfsd_cache_search(struct nfsd_drc_bucket *b, struct svc_rqst *rqstp,
 	/* tally hash chain length stats */
 	if (entries > longest_chain) {
 		longest_chain = entries;
-		longest_chain_cachesize = num_drc_entries;
+		longest_chain_cachesize = atomic_read(&num_drc_entries);
 	} else if (entries == longest_chain) {
 		/* prefer to keep the smallest cachesize possible here */
-		longest_chain_cachesize = min(longest_chain_cachesize,
-						num_drc_entries);
+		longest_chain_cachesize = min_t(unsigned int,
+				longest_chain_cachesize,
+				atomic_read(&num_drc_entries));
 	}
 
 	return ret;
@@ -433,7 +428,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 	rp = nfsd_reply_cache_alloc();
 	spin_lock(&cache_lock);
 	if (likely(rp)) {
-		++num_drc_entries;
+		atomic_inc(&num_drc_entries);
 		drc_mem_usage += sizeof(*rp);
 	}
 
@@ -617,7 +612,8 @@ static int nfsd_reply_cache_stats_show(struct seq_file *m, void *v)
 {
 	spin_lock(&cache_lock);
 	seq_printf(m, "max entries:           %u\n", max_drc_entries);
-	seq_printf(m, "num entries:           %u\n", num_drc_entries);
+	seq_printf(m, "num entries:           %u\n",
+			atomic_read(&num_drc_entries));
 	seq_printf(m, "hash buckets:          %u\n", 1 << maskbits);
 	seq_printf(m, "mem usage:             %u\n", drc_mem_usage);
 	seq_printf(m, "cache hits:            %u\n", nfsdstats.rchits);
-- 
1.9.3


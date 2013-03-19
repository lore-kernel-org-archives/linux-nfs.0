Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f179.google.com ([209.85.214.179]:64331 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752078Ab3CSNL5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Mar 2013 09:11:57 -0400
Received: by mail-ob0-f179.google.com with SMTP id un3so392490obb.10
        for <linux-nfs@vger.kernel.org>; Tue, 19 Mar 2013 06:11:57 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 5/6] nfsd: keep stats on worst hash balancing seen so far
Date: Tue, 19 Mar 2013 09:11:45 -0400
Message-Id: <1363698706-22036-6-git-send-email-jlayton@redhat.com>
In-Reply-To: <1363698706-22036-1-git-send-email-jlayton@redhat.com>
References: <1363698706-22036-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The typical case with the DRC is a cache miss, so if we keep track of
the max number of entries that we've ever walked over in a search, then
we should have a reasonable estimate of the longest hash chain that
we've ever seen.

With that, we'll also keep track of the total size of the cache when we
see the longest chain. In the case of a tie, we prefer to track the
smallest total cache size in order to properly gauge the worst-case
ratio of max vs. avg chain length.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 31 +++++++++++++++++++++++++++----
 1 file changed, 27 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index fd81ca7..17cb0d6 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -41,6 +41,12 @@ static unsigned int		payload_misses;
 /* amount of memory (in bytes) currently consumed by the DRC */
 static unsigned int		drc_mem_usage;
 
+/* longest hash chain seen */
+static unsigned int		longest_chain;
+
+/* size of cache when we saw the longest hash chain */
+static unsigned int		longest_chain_cachesize;
+
 /*
  * Calculate the hash index from an XID.
  */
@@ -319,15 +325,30 @@ nfsd_cache_match(struct svc_rqst *rqstp, __wsum csum, struct svc_cacherep *rp)
 static struct svc_cacherep *
 nfsd_cache_search(struct svc_rqst *rqstp, __wsum csum)
 {
-	struct svc_cacherep	*rp;
+	struct svc_cacherep	*rp, *ret = NULL;
 	struct hlist_head 	*rh;
+	unsigned int		entries = 0;
 
 	rh = &cache_hash[request_hash(rqstp->rq_xid)];
 	hlist_for_each_entry(rp, rh, c_hash) {
-		if (nfsd_cache_match(rqstp, csum, rp))
-			return rp;
+		++entries;
+		if (nfsd_cache_match(rqstp, csum, rp)) {
+			ret = rp;
+			break;
+		}
+	}
+
+	/* tally hash chain length stats */
+	if (entries > longest_chain) {
+		longest_chain = entries;
+		longest_chain_cachesize = num_drc_entries;
+	} else if (entries == longest_chain) {
+		/* prefer to keep the smallest cachesize possible here */
+		longest_chain_cachesize = min(longest_chain_cachesize,
+						num_drc_entries);
 	}
-	return NULL;
+
+	return ret;
 }
 
 /*
@@ -573,6 +594,8 @@ static int nfsd_reply_cache_stats_show(struct seq_file *m, void *v)
 	seq_printf(m, "cache misses:          %u\n", nfsdstats.rcmisses);
 	seq_printf(m, "not cached:            %u\n", nfsdstats.rcnocache);
 	seq_printf(m, "payload misses:        %u\n", payload_misses);
+	seq_printf(m, "longest chain len:     %u\n", longest_chain);
+	seq_printf(m, "cachesize at longest:  %u\n", longest_chain_cachesize);
 	spin_unlock(&cache_lock);
 	return 0;
 }
-- 
1.7.11.7


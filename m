Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f50.google.com ([209.85.212.50]:47358 "EHLO
	mail-vb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758441Ab3CDS4x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Mar 2013 13:56:53 -0500
Received: by mail-vb0-f50.google.com with SMTP id ft2so994934vbb.37
        for <linux-nfs@vger.kernel.org>; Mon, 04 Mar 2013 10:56:52 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: [PATCH v2 5/5] nfsd: keep stats on worst hash balancing seen so far
Date: Mon,  4 Mar 2013 13:56:40 -0500
Message-Id: <1362423400-24380-6-git-send-email-jlayton@redhat.com>
In-Reply-To: <1362423400-24380-1-git-send-email-jlayton@redhat.com>
References: <1362423400-24380-1-git-send-email-jlayton@redhat.com>
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
 fs/nfsd/nfscache.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 7640e80..3af1767 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -50,6 +50,12 @@ static u64			num_searches;
 /* longest time we spent doing a single search */
 static s64			max_search_time;
 
+/* longest hash chain seen */
+static unsigned int		longest_chain;
+
+/* size of cache when we saw the longest hash chain */
+static unsigned int		longest_chain_cachesize;
+
 /*
  * Calculate the hash index from an XID.
  */
@@ -330,11 +336,13 @@ nfsd_cache_search(struct svc_rqst *rqstp, __wsum csum)
 	struct svc_cacherep	*rp, *ret = NULL;
 	struct hlist_head 	*rh;
 	ktime_t			start;
+	unsigned int		entries = 0;
 	s64			delta;
 
 	start = ktime_get();
 	rh = &cache_hash[request_hash(rqstp->rq_xid)];
 	hlist_for_each_entry(rp, rh, c_hash) {
+		++entries;
 		if (nfsd_cache_match(rqstp, csum, rp)) {
 			ret = rp;
 			break;
@@ -343,6 +351,17 @@ nfsd_cache_search(struct svc_rqst *rqstp, __wsum csum)
 	delta = ktime_to_ns(ktime_sub(ktime_get(), start));
 	time_in_search += delta;
 	max_search_time = max(max_search_time, delta);
+
+	/* tally hash chain length stats */
+	if (entries >= longest_chain) {
+		longest_chain = entries;
+		if (!longest_chain_cachesize)
+			longest_chain_cachesize = num_drc_entries;
+		else
+			longest_chain_cachesize = min(longest_chain_cachesize,
+							num_drc_entries);
+	}
+
 	++num_searches;
 
 	return ret;
@@ -603,6 +622,8 @@ static int nfsd_reply_cache_stats_show(struct seq_file *m, void *v)
 	seq_printf(m, "payload misses:        %u\n", payload_misses);
 	seq_printf(m, "avg search time:       %lldns\n", avg_search_time());
 	seq_printf(m, "max search time:       %lldns\n", max_search_time);
+	seq_printf(m, "longest chain len:     %u\n", longest_chain);
+	seq_printf(m, "cachesize at longest:  %u\n", longest_chain_cachesize);
 	spin_unlock(&cache_lock);
 	return 0;
 }
-- 
1.7.11.7


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f170.google.com ([209.85.216.170]:55717 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756211Ab3BUS2u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Feb 2013 13:28:50 -0500
Received: by mail-qc0-f170.google.com with SMTP id d42so3762883qca.15
        for <linux-nfs@vger.kernel.org>; Thu, 21 Feb 2013 10:28:49 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 5/5] nfsd: keep track of the max and average time to search the cache
Date: Thu, 21 Feb 2013 13:28:38 -0500
Message-Id: <1361471318-17971-6-git-send-email-jlayton@redhat.com>
In-Reply-To: <1361471318-17971-1-git-send-email-jlayton@redhat.com>
References: <1361471318-17971-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since we're moderately concerned about the potential increase in hash
chain lengths, keep a running average of the time and the max time to
search.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 25 +++++++++++++++++++++----
 1 file changed, 21 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 52493cb..ae6575d 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -33,6 +33,9 @@ static unsigned int		max_drc_entries; /* max number of entries */
 static unsigned int		drc_mem_usage;   /* memory used by cache */
 static unsigned int		csum_misses;     /* cache misses due only to
 						    csum comparison failures */
+static unsigned int		max_search_time; /* max time to search */
+static unsigned int		avg_search_time; /* avg time to search */
+
 /*
  * Calculate the hash index from an XID.
  */
@@ -310,16 +313,28 @@ nfsd_cache_match(struct svc_rqst *rqstp, __wsum csum, struct svc_cacherep *rp)
 static struct svc_cacherep *
 nfsd_cache_search(struct svc_rqst *rqstp, __wsum csum)
 {
-	struct svc_cacherep	*rp;
+	struct svc_cacherep	*rp, *ret = NULL;
 	struct hlist_node	*hn;
 	struct hlist_head 	*rh;
+	ktime_t			start;
+	unsigned int		delta;
+	static unsigned int	nsearches = 0;
+	unsigned int		osearches;
 
+	start = ktime_get();
 	rh = &cache_hash[request_hash(rqstp->rq_xid)];
 	hlist_for_each_entry(rp, hn, rh, c_hash) {
-		if (nfsd_cache_match(rqstp, csum, rp))
-			return rp;
+		if (nfsd_cache_match(rqstp, csum, rp)) {
+			ret = rp;
+			break;
+		}
 	}
-	return NULL;
+	delta = (unsigned int)ktime_to_ns(ktime_sub(ktime_get(), start));
+	osearches = nsearches++;
+	avg_search_time = (avg_search_time * osearches + delta) / nsearches;
+	max_search_time = max(max_search_time, delta);
+
+	return ret;
 }
 
 /*
@@ -589,6 +604,8 @@ static int nfsd_reply_cache_stats_show(struct seq_file *m, void *v)
 	seq_printf(m, "not cached:      %u\n", nfsdstats.rcnocache);
 	seq_printf(m, "checksum misses: %u\n", csum_misses);
 	seq_printf(m, "max chain len:   %u\n", nfsd_repcache_max_chain_len());
+	seq_printf(m, "avg search time: %uns\n", avg_search_time);
+	seq_printf(m, "max search time: %uns\n", max_search_time);
 	spin_unlock(&cache_lock);
 	return 0;
 }
-- 
1.7.11.7


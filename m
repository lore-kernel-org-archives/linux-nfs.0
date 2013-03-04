Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f181.google.com ([209.85.128.181]:39514 "EHLO
	mail-ve0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932160Ab3CDS4w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Mar 2013 13:56:52 -0500
Received: by mail-ve0-f181.google.com with SMTP id d10so5034676vea.12
        for <linux-nfs@vger.kernel.org>; Mon, 04 Mar 2013 10:56:51 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/5] nfsd: keep track of the max and average time to search the cache
Date: Mon,  4 Mar 2013 13:56:39 -0500
Message-Id: <1362423400-24380-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1362423400-24380-1-git-send-email-jlayton@redhat.com>
References: <1362423400-24380-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since we're moderately concerned about the potential increase in hash
chain lengths, keep a running average of the time and the max time to
search.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 37 +++++++++++++++++++++++++++++++++----
 1 file changed, 33 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 24ac996..7640e80 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -41,6 +41,15 @@ static unsigned int		payload_misses;
 /* amount of memory (in bytes) currently consumed by the DRC */
 static unsigned int		drc_mem_usage;
 
+/* total time spent searching the cache */
+static s64			time_in_search;
+
+/* total number of times we searched the cache */
+static u64			num_searches;
+
+/* longest time we spent doing a single search */
+static s64			max_search_time;
+
 /*
  * Calculate the hash index from an XID.
  */
@@ -318,15 +327,25 @@ nfsd_cache_match(struct svc_rqst *rqstp, __wsum csum, struct svc_cacherep *rp)
 static struct svc_cacherep *
 nfsd_cache_search(struct svc_rqst *rqstp, __wsum csum)
 {
-	struct svc_cacherep	*rp;
+	struct svc_cacherep	*rp, *ret = NULL;
 	struct hlist_head 	*rh;
+	ktime_t			start;
+	s64			delta;
 
+	start = ktime_get();
 	rh = &cache_hash[request_hash(rqstp->rq_xid)];
 	hlist_for_each_entry(rp, rh, c_hash) {
-		if (nfsd_cache_match(rqstp, csum, rp))
-			return rp;
+		if (nfsd_cache_match(rqstp, csum, rp)) {
+			ret = rp;
+			break;
+		}
 	}
-	return NULL;
+	delta = ktime_to_ns(ktime_sub(ktime_get(), start));
+	time_in_search += delta;
+	max_search_time = max(max_search_time, delta);
+	++num_searches;
+
+	return ret;
 }
 
 /*
@@ -558,6 +577,14 @@ nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *data)
 	return 1;
 }
 
+static s64
+avg_search_time(void)
+{
+	if (!num_searches)
+		return 0;
+	return time_in_search / num_searches;
+}
+
 /*
  * Note that fields may be added, removed or reordered in the future. Programs
  * scraping this file for info should test the labels to ensure they're
@@ -574,6 +601,8 @@ static int nfsd_reply_cache_stats_show(struct seq_file *m, void *v)
 	seq_printf(m, "cache misses:          %u\n", nfsdstats.rcmisses);
 	seq_printf(m, "not cached:            %u\n", nfsdstats.rcnocache);
 	seq_printf(m, "payload misses:        %u\n", payload_misses);
+	seq_printf(m, "avg search time:       %lldns\n", avg_search_time());
+	seq_printf(m, "max search time:       %lldns\n", max_search_time);
 	spin_unlock(&cache_lock);
 	return 0;
 }
-- 
1.7.11.7


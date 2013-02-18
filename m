Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f49.google.com ([209.85.128.49]:55272 "EHLO
	mail-qe0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751680Ab3BRPAT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2013 10:00:19 -0500
Received: by mail-qe0-f49.google.com with SMTP id 5so2454249qea.8
        for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2013 07:00:17 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: report length of the longest hash chain in reply cache stats
Date: Mon, 18 Feb 2013 09:52:42 -0500
Message-Id: <1361199162-15566-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So we can get a feel for how effective the hashing function is.

As Chuck Lever pointed out to me, it's generally acceptable to do
"expensive" stuff when reading the stats since that's a relatively
rare activity. When we go to read the file, walk all of the hash
chains and count the number of entries in each. Report the length
of the longest one.

Cc: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index a5ac9ab..52493cb 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -552,6 +552,28 @@ nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *data)
 }
 
 /*
+ * Walk each hash chain and count the number of entries. Return the length of
+ * the longest one. Must be called with the cache_lock held.
+ */
+static unsigned int
+nfsd_repcache_max_chain_len(void)
+{
+	int i;
+	struct hlist_node *pos;
+	unsigned int max = 0;
+
+	for (i = 0; i < HASHSIZE; ++i) {
+		unsigned int cur = 0;
+
+		hlist_for_each(pos, &cache_hash[i])
+			++cur;
+		max = max(cur, max);
+	}
+
+	return max;
+}
+
+/*
  * Note that fields may be added, removed or reordered in the future. Programs
  * scraping this file for info should test the labels to ensure they're
  * getting the correct field.
@@ -566,6 +588,7 @@ static int nfsd_reply_cache_stats_show(struct seq_file *m, void *v)
 	seq_printf(m, "cache misses:    %u\n", nfsdstats.rcmisses);
 	seq_printf(m, "not cached:      %u\n", nfsdstats.rcnocache);
 	seq_printf(m, "checksum misses: %u\n", csum_misses);
+	seq_printf(m, "max chain len:   %u\n", nfsd_repcache_max_chain_len());
 	spin_unlock(&cache_lock);
 	return 0;
 }
-- 
1.7.11.7


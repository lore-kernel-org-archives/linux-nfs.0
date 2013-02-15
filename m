Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f178.google.com ([209.85.213.178]:48935 "EHLO
	mail-ye0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729Ab3BOUEm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Feb 2013 15:04:42 -0500
Received: by mail-ye0-f178.google.com with SMTP id j12so614241yeg.37
        for <linux-nfs@vger.kernel.org>; Fri, 15 Feb 2013 12:04:40 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com
Subject: [PATCH RFC] nfsd: report length of the largest hash chain in reply cache stats
Date: Fri, 15 Feb 2013 15:04:32 -0500
Message-Id: <1360958672-5692-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <20130215133406.20b1ef09@tlielax.poochiereds.net>
References: <20130215133406.20b1ef09@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So we can get a feel for how effective the hashing function is.

As Chuck Lever pointed out to me, it's generally acceptable to do
"expensive" stuff when reading the stats since that's a relatively
rare activity.

Cc: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index a5ac9ab..172e211 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -551,6 +551,25 @@ nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *data)
 	return 1;
 }
 
+/* Get stats on the hashtable itself */
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
 /*
  * Note that fields may be added, removed or reordered in the future. Programs
  * scraping this file for info should test the labels to ensure they're
@@ -566,6 +585,7 @@ static int nfsd_reply_cache_stats_show(struct seq_file *m, void *v)
 	seq_printf(m, "cache misses:    %u\n", nfsdstats.rcmisses);
 	seq_printf(m, "not cached:      %u\n", nfsdstats.rcnocache);
 	seq_printf(m, "checksum misses: %u\n", csum_misses);
+	seq_printf(m, "max chain len:   %u\n", nfsd_repcache_max_chain_len());
 	spin_unlock(&cache_lock);
 	return 0;
 }
-- 
1.7.11.7


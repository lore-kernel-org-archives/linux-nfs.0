Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:44074 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932320Ab3LDNy6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Dec 2013 08:54:58 -0500
Date: Wed, 4 Dec 2013 05:54:57 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        gartim@gmail.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: when reusing an existing repcache entry, unhash it
 first
Message-ID: <20131204135457.GA16205@infradead.org>
References: <1386015979-27511-1-git-send-email-jlayton@redhat.com>
 <20131203102517.GA12576@infradead.org>
 <20131203132112.1f19c014@tlielax.poochiereds.net>
 <20131204083336.GB30216@infradead.org>
 <20131204075402.7b00d09d@tlielax.poochiereds.net>
 <20131204130944.GA3464@infradead.org>
 <20131204083101.6422fb40@tlielax.poochiereds.net>
 <20131204134036.GA3953@infradead.org>
 <20131204084503.5f94ad81@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131204084503.5f94ad81@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Yeah, I've noticed the same hang, but hadn't able to determine why it
> was hanging. I suspect that that hang is what's tickles the bug that my
> patch fixes. With the hang, we see the client doing retransmits and not
> getting replies and that means that we exercise the DRC more...

FYI here is the one that just kills the silly direct reclaim.  It also
fixes the oops, but I still see the hang:


diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 9186c7c..dd260a1 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -380,11 +380,8 @@ nfsd_cache_search(struct svc_rqst *rqstp, __wsum csum)
 }
 
 /*
- * Try to find an entry matching the current call in the cache. When none
- * is found, we try to grab the oldest expired entry off the LRU list. If
- * a suitable one isn't there, then drop the cache_lock and allocate a
- * new one, then search again in case one got inserted while this thread
- * didn't hold the lock.
+ * Try to find an entry matching the current call in the cache and if none is
+ * found allocate and insert a new one.
  */
 int
 nfsd_cache_lookup(struct svc_rqst *rqstp)
@@ -409,22 +406,8 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 
 	/*
 	 * Since the common case is a cache miss followed by an insert,
-	 * preallocate an entry. First, try to reuse the first entry on the LRU
-	 * if it works, then go ahead and prune the LRU list.
+	 * preallocate an entry.
 	 */
-	spin_lock(&cache_lock);
-	if (!list_empty(&lru_head)) {
-		rp = list_first_entry(&lru_head, struct svc_cacherep, c_lru);
-		if (nfsd_cache_entry_expired(rp) ||
-		    num_drc_entries >= max_drc_entries) {
-			lru_put_end(rp);
-			prune_cache_entries();
-			goto search_cache;
-		}
-	}
-
-	/* No expired ones available, allocate a new one. */
-	spin_unlock(&cache_lock);
 	rp = nfsd_reply_cache_alloc();
 	spin_lock(&cache_lock);
 	if (likely(rp)) {
@@ -432,7 +415,6 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 		drc_mem_usage += sizeof(*rp);
 	}
 
-search_cache:
 	found = nfsd_cache_search(rqstp, csum);
 	if (found) {
 		if (likely(rp))
@@ -446,15 +428,6 @@ search_cache:
 		goto out;
 	}
 
-	/*
-	 * We're keeping the one we just allocated. Are we now over the
-	 * limit? Prune one off the tip of the LRU in trade for the one we
-	 * just allocated if so.
-	 */
-	if (num_drc_entries >= max_drc_entries)
-		nfsd_reply_cache_free_locked(list_first_entry(&lru_head,
-						struct svc_cacherep, c_lru));
-
 	nfsdstats.rcmisses++;
 	rqstp->rq_cacherep = rp;
 	rp->c_state = RC_INPROG;

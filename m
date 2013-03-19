Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f52.google.com ([209.85.219.52]:51474 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752078Ab3CSNLw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Mar 2013 09:11:52 -0400
Received: by mail-oa0-f52.google.com with SMTP id k14so422225oag.11
        for <linux-nfs@vger.kernel.org>; Tue, 19 Mar 2013 06:11:52 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/6] nfsd: eliminate one of the DRC cache searches
Date: Tue, 19 Mar 2013 09:11:41 -0400
Message-Id: <1363698706-22036-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1363698706-22036-1-git-send-email-jlayton@redhat.com>
References: <1363698706-22036-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The most common case is to do a search of the cache, followed by an
insert. In the case where we have to allocate an entry off the slab,
then we end up having to redo the search, which is wasteful.

Better optimize the code for the common case by eliminating the initial
search of the cache and always preallocating an entry. In the case of a
cache hit, we'll end up just freeing that entry but that's preferable to
an extra search.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 41 +++++++++++++++++++----------------------
 1 file changed, 19 insertions(+), 22 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index ca05f6d..c61391e 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -318,55 +318,53 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 	__wsum			csum;
 	unsigned long		age;
 	int type = rqstp->rq_cachetype;
-	int rtn;
+	int rtn = RC_DOIT;
 
 	rqstp->rq_cacherep = NULL;
 	if (type == RC_NOCACHE) {
 		nfsdstats.rcnocache++;
-		return RC_DOIT;
+		return rtn;
 	}
 
 	csum = nfsd_cache_csum(rqstp);
 
+	/*
+	 * Since the common case is a cache miss followed by an insert,
+	 * preallocate an entry. First, try to reuse the first entry on the LRU
+	 * if it works, then go ahead and prune the LRU list.
+	 */
 	spin_lock(&cache_lock);
-	rtn = RC_DOIT;
-
-	rp = nfsd_cache_search(rqstp, csum);
-	if (rp)
-		goto found_entry;
-
-	/* Try to use the first entry on the LRU */
 	if (!list_empty(&lru_head)) {
 		rp = list_first_entry(&lru_head, struct svc_cacherep, c_lru);
 		if (nfsd_cache_entry_expired(rp) ||
 		    num_drc_entries >= max_drc_entries) {
 			lru_put_end(rp);
 			prune_cache_entries();
-			goto setup_entry;
+			goto search_cache;
 		}
 	}
 
-	/* Drop the lock and allocate a new entry */
+	/* No expired ones available, allocate a new one. */
 	spin_unlock(&cache_lock);
 	rp = nfsd_reply_cache_alloc();
-	if (!rp) {
-		dprintk("nfsd: unable to allocate DRC entry!\n");
-		return RC_DOIT;
-	}
 	spin_lock(&cache_lock);
-	++num_drc_entries;
+	if (likely(rp))
+		++num_drc_entries;
 
-	/*
-	 * Must search again just in case someone inserted one
-	 * after we dropped the lock above.
-	 */
+search_cache:
 	found = nfsd_cache_search(rqstp, csum);
 	if (found) {
-		nfsd_reply_cache_free_locked(rp);
+		if (likely(rp))
+			nfsd_reply_cache_free_locked(rp);
 		rp = found;
 		goto found_entry;
 	}
 
+	if (!rp) {
+		dprintk("nfsd: unable to allocate DRC entry!\n");
+		goto out;
+	}
+
 	/*
 	 * We're keeping the one we just allocated. Are we now over the
 	 * limit? Prune one off the tip of the LRU in trade for the one we
@@ -376,7 +374,6 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 		nfsd_reply_cache_free_locked(list_first_entry(&lru_head,
 						struct svc_cacherep, c_lru));
 
-setup_entry:
 	nfsdstats.rcmisses++;
 	rqstp->rq_cacherep = rp;
 	rp->c_state = RC_INPROG;
-- 
1.7.11.7


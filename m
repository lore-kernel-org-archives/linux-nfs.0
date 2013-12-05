Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f172.google.com ([209.85.216.172]:58379 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755639Ab3LELBD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Dec 2013 06:01:03 -0500
Received: by mail-qc0-f172.google.com with SMTP id e16so4686276qcx.17
        for <linux-nfs@vger.kernel.org>; Thu, 05 Dec 2013 03:01:02 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH RFC 1/3] nfsd: don't try to reuse an expired DRC entry off the list
Date: Thu,  5 Dec 2013 06:00:51 -0500
Message-Id: <1386241253-5781-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1386241253-5781-1-git-send-email-jlayton@redhat.com>
References: <1386241253-5781-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently when we are processing a request, we try to scrape an expired
or over-limit entry off the list in preference to allocating a new one
from the slab.

This is unnecessarily complicated. Just use the slab layer.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 36 ++++--------------------------------
 1 file changed, 4 insertions(+), 32 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index b6af150..f8f060f 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -132,13 +132,6 @@ nfsd_reply_cache_alloc(void)
 }
 
 static void
-nfsd_reply_cache_unhash(struct svc_cacherep *rp)
-{
-	hlist_del_init(&rp->c_hash);
-	list_del_init(&rp->c_lru);
-}
-
-static void
 nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
 {
 	if (rp->c_type == RC_REPLBUFF && rp->c_replvec.iov_base) {
@@ -416,22 +409,8 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 
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
-			nfsd_reply_cache_unhash(rp);
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
@@ -439,7 +418,9 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 		drc_mem_usage += sizeof(*rp);
 	}
 
-search_cache:
+	/* go ahead and prune the cache */
+	prune_cache_entries();
+
 	found = nfsd_cache_search(rqstp, csum);
 	if (found) {
 		if (likely(rp))
@@ -453,15 +434,6 @@ search_cache:
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
-- 
1.8.4.2


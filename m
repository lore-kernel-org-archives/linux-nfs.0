Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f176.google.com ([209.85.216.176]:45072 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965171AbaFTS50 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Jun 2014 14:57:26 -0400
Received: by mail-qc0-f176.google.com with SMTP id w7so3935013qcr.35
        for <linux-nfs@vger.kernel.org>; Fri, 20 Jun 2014 11:57:25 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: stable@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: [stable PATCH] nfsd: don't try to reuse an expired DRC entry off the list
Date: Fri, 20 Jun 2014 14:56:52 -0400
Message-Id: <1403290612-15341-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

This is commit a0ef5e19684f0447da9ff0654a12019c484f57ca in mainline.

While the commit message below doesn't lay this out, we've subsequently
found that there are some cases where an entry that's still in use can
be freed prematurely if a particular operation takes a *very* long time
(on the order of minutes) and/or the server is very busy and doesn't
have a lot of memory dedicated to the DRC. This patch eliminates that
possibility, so it's actually more than just a cleanup.

The regression crept in in v3.9, and this patch went into mainline in
v3.14. Please apply this to any stable kernel between those two
mainline releases.

Original patch description follows:

-------------------------------[snip]----------------------------

Currently when we are processing a request, we try to scrape an expired
or over-limit entry off the list in preference to allocating a new one
from the slab.

This is unnecessarily complicated. Just use the slab layer.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfscache.c | 36 ++++--------------------------------
 1 file changed, 4 insertions(+), 32 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index ec8d97ddc635..02e8e9ad5750 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -129,13 +129,6 @@ nfsd_reply_cache_alloc(void)
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
@@ -402,22 +395,8 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 
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
@@ -425,7 +404,9 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 		drc_mem_usage += sizeof(*rp);
 	}
 
-search_cache:
+	/* go ahead and prune the cache */
+	prune_cache_entries();
+
 	found = nfsd_cache_search(rqstp, csum);
 	if (found) {
 		if (likely(rp))
@@ -439,15 +420,6 @@ search_cache:
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
1.9.3


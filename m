Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:54449 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753001Ab0IVC6A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Sep 2010 22:58:00 -0400
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Wed, 22 Sep 2010 12:55:07 +1000
Subject: [PATCH 4/7] sunrpc/cache: centralise handling of size limit on
	deferred list.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20100922025507.31745.61919.stgit@localhost.localdomain>
In-Reply-To: <20100922025009.31745.98237.stgit@localhost.localdomain>
References: <20100922025009.31745.98237.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We limit the number of 'defer' requests to DFR_MAX.

The imposition of this limit is spread about a bit - sometime we don't
add new things to the list, sometimes we remove old things.

Also it is currently applied to requests which we are 'waiting' for
rather than 'deferring'.  This doesn't seem ideal as 'waiting'
requests are naturally limited by the number of threads.

So gather the DFR_MAX handling code to one place and only apply it to
requests that are actually being deferred.

This means that not all 'cache_deferred_req' structures go on the
'cache_defer_list, so we need to be careful when removing things.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 net/sunrpc/cache.c |   68 +++++++++++++++++++++++++++++++++++-----------------
 1 files changed, 46 insertions(+), 22 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 466f65c..1963e2a 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -511,22 +511,24 @@ static int cache_defer_cnt;
 
 static void __unhash_deferred_req(struct cache_deferred_req *dreq)
 {
-	list_del_init(&dreq->recent);
 	hlist_del_init(&dreq->hash);
-	cache_defer_cnt--;
+	if (!list_empty(&dreq->recent)) {
+		list_del_init(&dreq->recent);
+		cache_defer_cnt--;
+	}
 }
 
 static void __hash_deferred_req(struct cache_deferred_req *dreq, struct cache_head *item)
 {
 	int hash = DFR_HASH(item);
 
+	INIT_LIST_HEAD(&dreq->recent);
 	list_add(&dreq->recent, &cache_defer_list);
 	hlist_add_head(&dreq->hash, &cache_defer_hash[hash]);
 }
 
 static int setup_deferral(struct cache_deferred_req *dreq, struct cache_head *item)
 {
-	struct cache_deferred_req *discard;
 
 	dreq->item = item;
 
@@ -534,19 +536,8 @@ static int setup_deferral(struct cache_deferred_req *dreq, struct cache_head *it
 
 	__hash_deferred_req(dreq, item);
 
-	/* it is in, now maybe clean up */
-	discard = NULL;
-	if (++cache_defer_cnt > DFR_MAX) {
-		discard = list_entry(cache_defer_list.prev,
-				     struct cache_deferred_req, recent);
-		__unhash_deferred_req(discard);
-	}
 	spin_unlock(&cache_defer_lock);
 
-	if (discard)
-		/* there was one too many */
-		discard->revisit(discard, 1);
-
 	if (!test_bit(CACHE_PENDING, &item->flags)) {
 		/* must have just been validated... */
 		cache_revisit_request(item);
@@ -612,18 +603,47 @@ static int cache_wait_req(struct cache_req *req, struct cache_head *item)
 	return -EEXIST;
 }
 
+static void cache_limit_defers(struct cache_deferred_req *dreq)
+{
+	/* Add 'dreq' to the list of deferred requests and make sure
+	 * we don't exceed the limit of allowed deferred requests.
+	 */
+	struct cache_deferred_req *discard = NULL;
+
+	spin_lock(&cache_defer_lock);
+	if (!list_empty(&dreq->recent) ||
+	    hlist_unhashed(&dreq->hash)) {
+		/* Must have lost a race, maybe cache_revisit_request is
+		 * already processing this.  In any case, there is nothing for
+		 * us to do.
+		 */
+		spin_unlock(&cache_defer_lock);
+	}
+
+	/* First, add this to the list */
+	cache_defer_cnt++;
+	list_add(&dreq->recent, &cache_defer_list);
+
+	/* now consider removing either the first or the last */
+	if (cache_defer_cnt > DFR_MAX) {
+		if (net_random() & 1)
+			discard = list_entry(cache_defer_list.next,
+					     struct cache_deferred_req, recent);
+		else
+			discard = list_entry(cache_defer_list.prev,
+					     struct cache_deferred_req, recent);
+		__unhash_deferred_req(discard);
+	}
+	spin_unlock(&cache_defer_lock);
+	if (discard)
+		discard->revisit(discard, 1);
+}
+
 static int cache_defer_req(struct cache_req *req, struct cache_head *item)
 {
 	struct cache_deferred_req *dreq;
 	int ret;
 
-	if (cache_defer_cnt >= DFR_MAX) {
-		/* too much in the cache, randomly drop this one,
-		 * or continue and drop the oldest
-		 */
-		if (net_random()&1)
-			return -ENOMEM;
-	}
 	if (req->thread_wait) {
 		ret = cache_wait_req(req, item);
 		if (ret != -ETIMEDOUT)
@@ -632,7 +652,11 @@ static int cache_defer_req(struct cache_req *req, struct cache_head *item)
 	dreq = req->defer(req);
 	if (dreq == NULL)
 		return -ENOMEM;
-	return setup_deferral(dreq, item);
+	if (setup_deferral(dreq, item) < 0)
+		return -EAGAIN;
+	
+	cache_limit_defers(dreq);
+	return 0;
 }
 
 static void cache_revisit_request(struct cache_head *item)



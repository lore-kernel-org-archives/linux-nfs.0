Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:53013 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751496Ab0JGEa0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Oct 2010 00:30:26 -0400
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Thu, 07 Oct 2010 15:29:46 +1100
Subject: [PATCH 2/2] sunrpc/cache: centralise handling of size limit on
	deferred list.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20101007042946.26629.84702.stgit@localhost.localdomain>
In-Reply-To: <20101007042637.26629.60300.stgit@localhost.localdomain>
References: <20101007042637.26629.60300.stgit@localhost.localdomain>
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
'cache_defer_list, so we need to be careful when adding and removing
things.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 net/sunrpc/cache.c |   67 +++++++++++++++++++++++++++++++++-------------------
 1 files changed, 43 insertions(+), 24 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index a438a9c..e5a1867 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -513,22 +513,25 @@ static int cache_defer_cnt;
 
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
 
-	list_add(&dreq->recent, &cache_defer_list);
+	INIT_LIST_HEAD(&dreq->recent);
 	hlist_add_head(&dreq->hash, &cache_defer_hash[hash]);
 }
 
-static void setup_deferral(struct cache_deferred_req *dreq, struct cache_head *item)
+static void setup_deferral(struct cache_deferred_req *dreq,
+			   struct cache_head *item,
+			   int count_me)
 {
-	struct cache_deferred_req *discard;
 
 	dreq->item = item;
 
@@ -536,18 +539,13 @@ static void setup_deferral(struct cache_deferred_req *dreq, struct cache_head *i
 
 	__hash_deferred_req(dreq, item);
 
-	/* it is in, now maybe clean up */
-	discard = NULL;
-	if (++cache_defer_cnt > DFR_MAX) {
-		discard = list_entry(cache_defer_list.prev,
-				     struct cache_deferred_req, recent);
-		__unhash_deferred_req(discard);
+	if (count_me) {
+		cache_defer_cnt++;
+		list_add(&dreq->recent, &cache_defer_list);
 	}
+
 	spin_unlock(&cache_defer_lock);
 
-	if (discard)
-		/* there was one too many */
-		discard->revisit(discard, 1);
 }
 
 struct thread_deferred_req {
@@ -570,7 +568,7 @@ static void cache_wait_req(struct cache_req *req, struct cache_head *item)
 	sleeper.completion = COMPLETION_INITIALIZER_ONSTACK(sleeper.completion);
 	dreq->revisit = cache_restart_thread;
 
-	setup_deferral(dreq, item);
+	setup_deferral(dreq, item, 0);
 
 	if (!test_bit(CACHE_PENDING, &item->flags) ||
 	    wait_for_completion_interruptible_timeout(
@@ -594,19 +592,38 @@ static void cache_wait_req(struct cache_req *req, struct cache_head *item)
 	}
 }
 
+static void cache_limit_defers(void)
+{
+	/* Make sure we haven't exceed the limit of allowed deferred
+	 * requests.
+	 */
+	struct cache_deferred_req *discard = NULL;
+
+	if (cache_defer_cnt <= DFR_MAX)
+		return;
+
+	spin_lock(&cache_defer_lock);
+
+	/* Consider removing either the first or the last */
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
 static void cache_defer_req(struct cache_req *req, struct cache_head *item)
 {
 	struct cache_deferred_req *dreq;
 	int timeout;
 
-	if (cache_defer_cnt >= DFR_MAX)
-		/* too much in the cache, randomly drop this one,
-		 * or continue and drop the oldest
-		 */
-		if (net_random()&1)
-			return;
-
-
 	if (req->thread_wait) {
 		cache_wait_req(req, item, timeout);
 		if (!test_bit(CACHE_PENDING, &item->flags))
@@ -615,12 +632,14 @@ static void cache_defer_req(struct cache_req *req, struct cache_head *item)
 	dreq = req->defer(req);
 	if (dreq == NULL)
 		return;
-	setup_deferral(dreq, item);
+	setup_deferral(dreq, item, 1);
 	if (!test_bit(CACHE_PENDING, &item->flags))
 		/* Bit could have been cleared before we managed to
 		 * set up the deferral, so need to revisit just in case
 		 */
 		cache_revisit_request(item);
+	
+	cache_limit_defers();
 }
 
 static void cache_revisit_request(struct cache_head *item)



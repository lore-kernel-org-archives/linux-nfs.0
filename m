From: NeilBrown <neilb@suse.de>
Subject: [PATCH 9/9] sunrpc/cache: change deferred-request hash table to use
	hlist.
Date: Wed, 03 Feb 2010 17:31:31 +1100
Message-ID: <20100203063131.12945.53497.stgit@notabene.brown>
References: <20100203060657.12945.27293.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:45238 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755623Ab0BCGjz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Feb 2010 01:39:55 -0500
In-Reply-To: <20100203060657.12945.27293.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Being a hash table, hlist is the best option.

There is currently some ugliness were we treat "->next == NULL" as
a special case to avoid having to initialise the whole array.
This change nicely gets rid of that case.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 include/linux/sunrpc/cache.h |    2 +-
 net/sunrpc/cache.c           |   30 ++++++++++++------------------
 2 files changed, 13 insertions(+), 19 deletions(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index ef3db11..ba9d72c 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -133,7 +133,7 @@ struct cache_req {
  * delayed awaiting cache-fill
  */
 struct cache_deferred_req {
-	struct list_head	hash;	/* on hash chain */
+	struct hlist_node	hash;	/* on hash chain */
 	struct list_head	recent; /* on fifo */
 	struct cache_head	*item;  /* cache item we wait on */
 	void			*owner; /* we might need to discard all defered requests
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index b23b2e6..421b493 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -505,7 +505,7 @@ EXPORT_SYMBOL_GPL(cache_purge);
 
 static DEFINE_SPINLOCK(cache_defer_lock);
 static LIST_HEAD(cache_defer_list);
-static struct list_head cache_defer_hash[DFR_HASHSIZE];
+static struct hlist_head cache_defer_hash[DFR_HASHSIZE];
 static int cache_defer_cnt;
 
 struct thread_deferred_req {
@@ -549,9 +549,7 @@ static int cache_defer_req(struct cache_req *req, struct cache_head *item)
 
 	list_add(&dreq->recent, &cache_defer_list);
 
-	if (cache_defer_hash[hash].next == NULL)
-		INIT_LIST_HEAD(&cache_defer_hash[hash]);
-	list_add(&dreq->hash, &cache_defer_hash[hash]);
+	hlist_add_head(&dreq->hash, &cache_defer_hash[hash]);
 
 	/* it is in, now maybe clean up */
 	discard = NULL;
@@ -559,7 +557,7 @@ static int cache_defer_req(struct cache_req *req, struct cache_head *item)
 		discard = list_entry(cache_defer_list.prev,
 				     struct cache_deferred_req, recent);
 		list_del_init(&discard->recent);
-		list_del_init(&discard->hash);
+		hlist_del_init(&discard->hash);
 		cache_defer_cnt--;
 	}
 	spin_unlock(&cache_defer_lock);
@@ -578,12 +576,12 @@ static int cache_defer_req(struct cache_req *req, struct cache_head *item)
 		wait_event_interruptible_timeout(
 			sleeper.wait,
 			!test_bit(CACHE_PENDING, &item->flags)
-			|| list_empty(&sleeper.handle.hash),
+			|| hlist_unhashed(&sleeper.handle.hash),
 			req->thread_wait);
 		spin_lock(&cache_defer_lock);
-		if (!list_empty(&sleeper.handle.hash)) {
+		if (!hlist_unhashed(&sleeper.handle.hash)) {
 			list_del_init(&sleeper.handle.recent);
-			list_del_init(&sleeper.handle.hash);
+			hlist_del_init(&sleeper.handle.hash);
 			cache_defer_cnt--;
 		}
 		spin_unlock(&cache_defer_lock);
@@ -604,24 +602,20 @@ static void cache_revisit_request(struct cache_head *item)
 	struct cache_deferred_req *dreq;
 	struct list_head pending;
 
-	struct list_head *lp;
+	struct hlist_node *lp, *tmp;
 	int hash = DFR_HASH(item);
 
 	INIT_LIST_HEAD(&pending);
 	spin_lock(&cache_defer_lock);
 
-	lp = cache_defer_hash[hash].next;
-	if (lp) {
-		while (lp != &cache_defer_hash[hash]) {
-			dreq = list_entry(lp, struct cache_deferred_req, hash);
-			lp = lp->next;
+	hlist_for_each_entry_safe(dreq, lp, tmp,
+				  &cache_defer_hash[hash], hash)
 			if (dreq->item == item) {
-				list_del_init(&dreq->hash);
+				hlist_del_init(&dreq->hash);
 				list_move(&dreq->recent, &pending);
 				cache_defer_cnt--;
 			}
-		}
-	}
+
 	spin_unlock(&cache_defer_lock);
 
 	while (!list_empty(&pending)) {
@@ -642,7 +636,7 @@ void cache_clean_deferred(void *owner)
 
 	list_for_each_entry_safe(dreq, tmp, &cache_defer_list, recent) {
 		if (dreq->owner == owner) {
-			list_del_init(&dreq->hash);
+			hlist_del_init(&dreq->hash);
 			list_move(&dreq->recent, &pending);
 			cache_defer_cnt--;
 		}



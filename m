From: NeilBrown <neilb@suse.de>
Subject: [PATCH 2/9] sunrpc/cache: simplify cache_fresh_locked and
	cache_fresh_unlocked.
Date: Wed, 09 Sep 2009 16:32:54 +1000
Message-ID: <20090909063254.20462.36051.stgit@notabene.brown>
References: <20090909062539.20462.67466.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:56294 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751514AbZIIGcq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Sep 2009 02:32:46 -0400
In-Reply-To: <20090909062539.20462.67466.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The extra call to cache_revisit_request in cache_fresh_unlocked is not
needed, as should have been fairly clear at the time of
   commit 4013edea9a0b6cdcb1fdf5d4011e47e068fd6efb

If there are requests to be revisited, then we can be sure that
CACHE_PENDING is set, so the second call is sufficient.

So remove the first call.
Then remove the 'new' parameter,
then remove the return value for cache_fresh_locked which is only used
to provide the value for 'new'.

Signed-off-by: NeilBrown <neilb@suse.de>
---

 net/sunrpc/cache.c |   23 ++++++++++-------------
 1 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index aafb0e7..baddb23 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -105,18 +105,16 @@ EXPORT_SYMBOL_GPL(sunrpc_cache_lookup);
 
 static void cache_dequeue(struct cache_detail *detail, struct cache_head *ch);
 
-static int cache_fresh_locked(struct cache_head *head, time_t expiry)
+static void cache_fresh_locked(struct cache_head *head, time_t expiry)
 {
 	head->expiry_time = expiry;
 	head->last_refresh = get_seconds();
-	return !test_and_set_bit(CACHE_VALID, &head->flags);
+	set_bit(CACHE_VALID, &head->flags);
 }
 
 static void cache_fresh_unlocked(struct cache_head *head,
-			struct cache_detail *detail, int new)
+				 struct cache_detail *detail)
 {
-	if (new)
-		cache_revisit_request(head);
 	if (test_and_clear_bit(CACHE_PENDING, &head->flags)) {
 		cache_revisit_request(head);
 		cache_dequeue(detail, head);
@@ -132,7 +130,6 @@ struct cache_head *sunrpc_cache_update(struct cache_detail *detail,
 	 */
 	struct cache_head **head;
 	struct cache_head *tmp;
-	int is_new;
 
 	if (!test_bit(CACHE_VALID, &old->flags)) {
 		write_lock(&detail->hash_lock);
@@ -141,9 +138,9 @@ struct cache_head *sunrpc_cache_update(struct cache_detail *detail,
 				set_bit(CACHE_NEGATIVE, &old->flags);
 			else
 				detail->update(old, new);
-			is_new = cache_fresh_locked(old, new->expiry_time);
+			cache_fresh_locked(old, new->expiry_time);
 			write_unlock(&detail->hash_lock);
-			cache_fresh_unlocked(old, detail, is_new);
+			cache_fresh_unlocked(old, detail);
 			return old;
 		}
 		write_unlock(&detail->hash_lock);
@@ -167,11 +164,11 @@ struct cache_head *sunrpc_cache_update(struct cache_detail *detail,
 	*head = tmp;
 	detail->entries++;
 	cache_get(tmp);
-	is_new = cache_fresh_locked(tmp, new->expiry_time);
+	cache_fresh_locked(tmp, new->expiry_time);
 	cache_fresh_locked(old, 0);
 	write_unlock(&detail->hash_lock);
-	cache_fresh_unlocked(tmp, detail, is_new);
-	cache_fresh_unlocked(old, detail, 0);
+	cache_fresh_unlocked(tmp, detail);
+	cache_fresh_unlocked(old, detail);
 	cache_put(old, detail);
 	return tmp;
 }
@@ -240,8 +237,8 @@ int cache_check(struct cache_detail *detail,
 				cache_revisit_request(h);
 				if (rv == -EAGAIN) {
 					set_bit(CACHE_NEGATIVE, &h->flags);
-					cache_fresh_unlocked(h, detail,
-					     cache_fresh_locked(h, get_seconds()+CACHE_NEW_EXPIRY));
+					cache_fresh_locked(h, get_seconds()+CACHE_NEW_EXPIRY);
+					cache_fresh_unlocked(h, detail);
 					rv = -ENOENT;
 				}
 				break;



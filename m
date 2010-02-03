From: NeilBrown <neilb@suse.de>
Subject: [PATCH 3/9] sunrpc: never return expired entries in
	sunrpc_cache_lookup
Date: Wed, 03 Feb 2010 17:31:31 +1100
Message-ID: <20100203063131.12945.97779.stgit@notabene.brown>
References: <20100203060657.12945.27293.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:45224 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754362Ab0BCGjW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Feb 2010 01:39:22 -0500
In-Reply-To: <20100203060657.12945.27293.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If sunrpc_cache_lookup finds an expired entry, remove it from
the cache and return a freshly created non-VALID entry instead.
This ensures that we only ever get a usable entry, or an
entry that will become usable once an update arrives.
i.e. we will never need to repeat the lookup.

This allows us to remove the 'is_expired' test from cache_check
(i.e. from cache_is_valid).  cache_check should never get an expired
entry as 'lookup' will never return one.  If it does happen - due to
inconvenient timing - then just accept it as still valid, it won't be
very much past it's use-by date.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 net/sunrpc/cache.c |   17 ++++++++++++++---
 1 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 9826c5c..3e1ef8b 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -59,7 +59,7 @@ struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
 				       struct cache_head *key, int hash)
 {
 	struct cache_head **head,  **hp;
-	struct cache_head *new = NULL;
+	struct cache_head *new = NULL, *freeme = NULL;
 
 	head = &detail->hash_table[hash];
 
@@ -68,6 +68,9 @@ struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
 	for (hp=head; *hp != NULL ; hp = &(*hp)->next) {
 		struct cache_head *tmp = *hp;
 		if (detail->match(tmp, key)) {
+			if (cache_is_expired(detail, tmp))
+				/* This entry is expired, we will discard it. */
+				break;
 			cache_get(tmp);
 			read_unlock(&detail->hash_lock);
 			return tmp;
@@ -92,6 +95,13 @@ struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
 	for (hp=head; *hp != NULL ; hp = &(*hp)->next) {
 		struct cache_head *tmp = *hp;
 		if (detail->match(tmp, key)) {
+			if (cache_is_expired(detail, tmp)) {
+				*hp = tmp->next;
+				tmp->next = NULL;
+				detail->entries --;
+				freeme = tmp;
+				break;
+			}
 			cache_get(tmp);
 			write_unlock(&detail->hash_lock);
 			cache_put(new, detail);
@@ -104,6 +114,8 @@ struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
 	cache_get(new);
 	write_unlock(&detail->hash_lock);
 
+	if (freeme)
+		cache_put(freeme, detail);
 	return new;
 }
 EXPORT_SYMBOL_GPL(sunrpc_cache_lookup);
@@ -189,8 +201,7 @@ static int cache_make_upcall(struct cache_detail *cd, struct cache_head *h)
 
 static inline int cache_is_valid(struct cache_detail *detail, struct cache_head *h)
 {
-	if (!test_bit(CACHE_VALID, &h->flags) ||
-	    cache_is_expired(detail, h))
+	if (!test_bit(CACHE_VALID, &h->flags))
 		return -EAGAIN;
 	else {
 		/* entry is valid */



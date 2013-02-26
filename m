Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:55251 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755915Ab3BZGi6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Feb 2013 01:38:58 -0500
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Tue, 26 Feb 2013 17:36:42 +1100
Subject: [PATCH 2/2] sunrpc/cache: use cache_fresh_unlocked consistently and
 correctly.
Cc: Bodo Stroesser <bstroesser@ts.fujitsu.com>, linux-nfs@vger.kernel.org
Message-ID: <20130226063642.6063.79219.stgit@notabene.brown>
In-Reply-To: <20130226063637.6063.34934.stgit@notabene.brown>
References: <20130226063637.6063.34934.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

cache_fresh_unlocked() is called when a cache entry
has been updated and ensures that if there were any
pending upcalls, they are cleared.

So every time we update a cache entry, we should call this,
and this should be the only way that we try to clear
pending calls (that sort of uniformity makes code sooo much
easier to read).

try_to_negate_entry() will (possibly) mark an entry as
negative.  If it doesn't, it is because the entry already
is VALID.
So the entry will be valid on exit, so it is appropriate to
call cache_fresh_unlocked().
So tidy up try_to_negate_entry() to do that, and remove
partial open-coded cache_fresh_unlocked() from the one
call-site of try_to_negate_entry().

In the other branch of the 'switch(cache_make_upcall())',
we again have a partial open-coded version of cache_fresh_unlocked().
Replace that with a real call.

And again in cache_clean(), use a real call to cache_fresh_unlocked().

These call sites might previously have called
cache_revisit_request() if CACHE_PENDING wasn't set.
This is never necessary because cache_revisit_request() can
only do anything if the item is in the cache_defer_hash,
However any time that an item is added to the cache_defer_hash
(setup_deferral), the code immediately tests CACHE_PENDING,
and removes the entry again if it is clear.  So all other
places we only need to 'cache_revisit_request' if we've
just cleared CACHE_PENDING.

Reported-by: Bodo Stroesser <bstroesser@ts.fujitsu.com>
Signed-off-by: NeilBrown  <neilb@suse.de>
---
 net/sunrpc/cache.c |   20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index b48c8ef..7ebee64 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -228,15 +228,14 @@ static int try_to_negate_entry(struct cache_detail *detail, struct cache_head *h
 
 	write_lock(&detail->hash_lock);
 	rv = cache_is_valid(detail, h);
-	if (rv != -EAGAIN) {
-		write_unlock(&detail->hash_lock);
-		return rv;
+	if (rv == -EAGAIN) {
+		set_bit(CACHE_NEGATIVE, &h->flags);
+		cache_fresh_locked(h, seconds_since_boot()+CACHE_NEW_EXPIRY);
+		rv = -ENOENT;
 	}
-	set_bit(CACHE_NEGATIVE, &h->flags);
-	cache_fresh_locked(h, seconds_since_boot()+CACHE_NEW_EXPIRY);
 	write_unlock(&detail->hash_lock);
 	cache_fresh_unlocked(h, detail);
-	return -ENOENT;
+	return rv;
 }
 
 /*
@@ -275,13 +274,10 @@ int cache_check(struct cache_detail *detail,
 		if (!test_and_set_bit(CACHE_PENDING, &h->flags)) {
 			switch (cache_make_upcall(detail, h)) {
 			case -EINVAL:
-				clear_bit(CACHE_PENDING, &h->flags);
-				cache_revisit_request(h);
 				rv = try_to_negate_entry(detail, h);
 				break;
 			case -EAGAIN:
-				clear_bit(CACHE_PENDING, &h->flags);
-				cache_revisit_request(h);
+				cache_fresh_unlocked(h, detail);
 				break;
 			}
 		}
@@ -457,9 +453,7 @@ static int cache_clean(void)
 			current_index ++;
 		spin_unlock(&cache_list_lock);
 		if (ch) {
-			if (test_and_clear_bit(CACHE_PENDING, &ch->flags))
-				cache_dequeue(current_detail, ch);
-			cache_revisit_request(ch);
+			cache_fresh_unlocked(ch, d);
 			cache_put(ch, d);
 		}
 	} else



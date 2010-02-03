From: NeilBrown <neilb@suse.de>
Subject: [PATCH 1/9] sunrpc: don't keep expired entries in the auth caches.
Date: Wed, 03 Feb 2010 17:31:31 +1100
Message-ID: <20100203063130.12945.29226.stgit@notabene.brown>
References: <20100203060657.12945.27293.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:49509 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754362Ab0BCGjL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Feb 2010 01:39:11 -0500
In-Reply-To: <20100203060657.12945.27293.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

currently expired entries remain in the auth caches as long
as there is a reference.
This was needed long ago when the auth_domain cache used the same
cache infrastructure.  But since that (being a very different sort
of cache) was separated, this test is no longer needed.

So remove the test on refcnt and tidy up the surrounding code.

This allows the cache_dequeue call (which needed to be there to
drop a potentially awkward reference) can be moved outside of the
spinlock which is a better place for it.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 net/sunrpc/cache.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 39bddba..83592e0 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -397,31 +397,28 @@ static int cache_clean(void)
 		/* Ok, now to clean this strand */
 
 		cp = & current_detail->hash_table[current_index];
-		ch = *cp;
-		for (; ch; cp= & ch->next, ch= *cp) {
+		for (ch = *cp ; ch ; cp = & ch->next, ch = *cp) {
 			if (current_detail->nextcheck > ch->expiry_time)
 				current_detail->nextcheck = ch->expiry_time+1;
 			if (ch->expiry_time >= get_seconds() &&
 			    ch->last_refresh >= current_detail->flush_time)
 				continue;
-			if (test_and_clear_bit(CACHE_PENDING, &ch->flags))
-				cache_dequeue(current_detail, ch);
 
-			if (atomic_read(&ch->ref.refcount) == 1)
-				break;
-		}
-		if (ch) {
 			*cp = ch->next;
 			ch->next = NULL;
 			current_detail->entries--;
 			rv = 1;
+			break;
 		}
+
 		write_unlock(&current_detail->hash_lock);
 		d = current_detail;
 		if (!ch)
 			current_index ++;
 		spin_unlock(&cache_list_lock);
 		if (ch) {
+			if (test_and_clear_bit(CACHE_PENDING, &ch->flags))
+				cache_dequeue(current_detail, ch);
 			cache_revisit_request(ch);
 			cache_put(ch, d);
 		}



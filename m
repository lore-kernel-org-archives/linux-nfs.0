Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:35839 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757197Ab3FMCzF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Jun 2013 22:55:05 -0400
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Thu, 13 Jun 2013 12:53:42 +1000
Subject: [PATCH 3/5] sunrpc/cache: ensure items removed from cache do not
 have pending upcalls.
Cc: bstroesser@ts.fujitsu.com, linux-nfs@vger.kernel.org
Message-ID: <20130613025342.31861.71950.stgit@notabene.brown>
In-Reply-To: <20130613025132.31861.97407.stgit@notabene.brown>
References: <20130613025132.31861.97407.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is possible for a race to set CACHE_PENDING after cache_clean()
has removed a cache entry from the cache.
If CACHE_PENDING is still set when the entry is finally 'put',
the cache_dequeue() will never happen and we can leak memory.

So set a new flag 'CACHE_CLEANED' when we remove something from
the cache, and don't queue any upcall if it is set.

If CACHE_PENDING is set before CACHE_CLEANED, the call that
cache_clean() makes to cache_fresh_unlocked() will free memory
as needed.  If CACHE_PENDING is set after CACHE_CLEANED, the
test in sunrpc_cache_pipe_upcall will ensure that the memory
is not allocated.

Reported-by: <bstroesser@ts.fujitsu.com>
Signed-off-by: NeilBrown <neilb@suse.de>
---
 include/linux/sunrpc/cache.h |    1 +
 net/sunrpc/cache.c           |    6 +++++-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 303399b..8419f7d 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -57,6 +57,7 @@ struct cache_head {
 #define	CACHE_VALID	0	/* Entry contains valid data */
 #define	CACHE_NEGATIVE	1	/* Negative entry - there is no match for the key */
 #define	CACHE_PENDING	2	/* An upcall has been sent but no reply received yet*/
+#define	CACHE_CLEANED	3	/* Entry has been cleaned from cache */
 
 #define	CACHE_NEW_EXPIRY 120	/* keep new things pending confirmation for 120 seconds */
 
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 4940be0..454e23c 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -306,7 +306,7 @@ EXPORT_SYMBOL_GPL(cache_check);
  * a current pointer into that list and into the table
  * for that entry.
  *
- * Each time clean_cache is called it finds the next non-empty entry
+ * Each time cache_clean is called it finds the next non-empty entry
  * in the current table and walks the list in that entry
  * looking for entries that can be removed.
  *
@@ -453,6 +453,7 @@ static int cache_clean(void)
 			current_index ++;
 		spin_unlock(&cache_list_lock);
 		if (ch) {
+			set_bit(CACHE_CLEANED, &ch->flags);
 			cache_fresh_unlocked(ch, d);
 			cache_put(ch, d);
 		}
@@ -1178,6 +1179,9 @@ int sunrpc_cache_pipe_upcall(struct cache_detail *detail, struct cache_head *h)
 		warn_no_listener(detail);
 		return -EINVAL;
 	}
+	if (test_bit(CACHE_CLEANED, &h->flags))
+		/* Too late to make an upcall */
+		return -EAGAIN;
 
 	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
 	if (!buf)



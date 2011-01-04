Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53507 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751109Ab1ADTbU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 14:31:20 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/2] svcrpc: take lock on turning entry NEGATIVE in cache_check
Date: Tue,  4 Jan 2011 14:31:16 -0500
Message-Id: <1294169477-5920-1-git-send-email-bfields@redhat.com>
In-Reply-To: <20110104192350.GE2308@fieldses.org>
References: <20110104192350.GE2308@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We attempt to turn a cache entry negative in place.  But that entry may
already have been filled in by some other task since we last checked
whether it was valid, so we could be modifying an already-valid entry.
If nothing else there's a likely leak in such a case when the entry is
eventually put() and contents are not freed because it has
CACHE_NEGATIVE set.

So, take the cache_lock just as sunrpc_cache_update() does.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/cache.c |   25 ++++++++++++++++++-------
 1 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 0d6002f..a6c5733 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -213,6 +213,23 @@ static inline int cache_is_valid(struct cache_detail *detail, struct cache_head
 	}
 }
 
+static int try_to_negate_entry(struct cache_detail *detail, struct cache_head *h)
+{
+	int rv;
+
+	write_lock(&detail->hash_lock);
+	rv = cache_is_valid(detail, h);
+	if (rv != -EAGAIN) {
+		write_unlock(&detail->hash_lock);
+		return rv;
+	}
+	set_bit(CACHE_NEGATIVE, &h->flags);
+	cache_fresh_locked(h, seconds_since_boot()+CACHE_NEW_EXPIRY);
+	write_unlock(&detail->hash_lock);
+	cache_fresh_unlocked(h, detail);
+	return -ENOENT;
+}
+
 /*
  * This is the generic cache management routine for all
  * the authentication caches.
@@ -251,14 +268,8 @@ int cache_check(struct cache_detail *detail,
 			case -EINVAL:
 				clear_bit(CACHE_PENDING, &h->flags);
 				cache_revisit_request(h);
-				if (rv == -EAGAIN) {
-					set_bit(CACHE_NEGATIVE, &h->flags);
-					cache_fresh_locked(h, seconds_since_boot()+CACHE_NEW_EXPIRY);
-					cache_fresh_unlocked(h, detail);
-					rv = -ENOENT;
-				}
+				rv = try_to_negate_entry(detail, h);
 				break;
-
 			case -EAGAIN:
 				clear_bit(CACHE_PENDING, &h->flags);
 				cache_revisit_request(h);
-- 
1.7.1


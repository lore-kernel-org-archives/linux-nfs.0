From: Greg Banks <gnb@sgi.com>
Subject: [patch 05/14] sunrpc: Rename queue_loose() to cache_remove_queued().
Date: Thu, 08 Jan 2009 19:25:15 +1100
Message-ID: <20090108082603.445163000@sgi.com>
References: <20090108082510.050854000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:54350 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753368AbZAHI0J (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 03:26:09 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The new name is more accurate name as well being grammatically correct.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 net/sunrpc/cache.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: bfields/net/sunrpc/cache.c
===================================================================
--- bfields.orig/net/sunrpc/cache.c
+++ bfields/net/sunrpc/cache.c
@@ -101,7 +101,7 @@ struct cache_head *sunrpc_cache_lookup(s
 EXPORT_SYMBOL(sunrpc_cache_lookup);
 
 
-static void queue_loose(struct cache_detail *cd, struct cache_head *h);
+static void cache_remove_queued(struct cache_detail *cd, struct cache_head *h);
 
 static int cache_fresh_locked(struct cache_head *h, time_t expiry)
 {
@@ -117,7 +117,7 @@ static void cache_fresh_unlocked(struct 
 		cache_revisit_request(h);
 	if (test_and_clear_bit(CACHE_PENDING, &h->flags)) {
 		cache_revisit_request(h);
-		queue_loose(cd, h);
+		cache_remove_queued(cd, h);
 	}
 }
 
@@ -461,7 +461,7 @@ static int cache_clean(void)
 				)
 				continue;
 			if (test_and_clear_bit(CACHE_PENDING, &h->flags))
-				queue_loose(current_detail, h);
+				cache_remove_queued(current_detail, h);
 
 			if (atomic_read(&h->ref.refcount) == 1)
 				break;
@@ -924,7 +924,7 @@ static const struct file_operations cach
 };
 
 
-static void queue_loose(struct cache_detail *cd, struct cache_head *h)
+static void cache_remove_queued(struct cache_detail *cd, struct cache_head *h)
 {
 	struct cache_queue *cq;
 	spin_lock(&queue_lock);

--
-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

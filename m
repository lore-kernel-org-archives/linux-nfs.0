Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:35841 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757197Ab3FMCzM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Jun 2013 22:55:12 -0400
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Thu, 13 Jun 2013 12:53:42 +1000
Subject: [PATCH 4/5] net/sunrpc: xpt_auth_cache should be ignored when
 expired.
Cc: Bodo Stroesser <bstroesser@ts.fujitsu.com>, linux-nfs@vger.kernel.org
Message-ID: <20130613025342.31861.7329.stgit@notabene.brown>
In-Reply-To: <20130613025132.31861.97407.stgit@notabene.brown>
References: <20130613025132.31861.97407.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit d202cce8963d9268ff355a386e20243e8332b308
    sunrpc: never return expired entries in sunrpc_cache_lookup

moved the 'entry is expired' test from cache_check to
sunrpc_cache_lookup, so that it happened early and some races could
safely be ignored.

However the ip_map (in svcauth_unix.c) has a separate single-item
cache which allows quick lookup without locking.  An entry in this
case would not be subject to the expiry test and so could be used
well after it has expired.

This is not normally a big problem because the first time it is used
after it is expired an up-call will be scheduled to refresh the entry
(if it hasn't been scheduled already) and the old entry will then
be invalidated.  So on the second attempt to use it after it has
expired, ip_map_cached_get will discard it.

However that is subtle and not ideal, so replace the "!cache_valid"
test with "cache_is_expired".
In doing this we drop the test on the "CACHE_VALID" bit.  This is
unnecessary as the bit is never cleared, and an entry will only
be cached if the bit is set.

Reported-by: Bodo Stroesser <bstroesser@ts.fujitsu.com>
Signed-off-by: NeilBrown <neilb@suse.de>
---
 include/linux/sunrpc/cache.h |   48 ++++++++++++++++++------------------------
 net/sunrpc/cache.c           |    6 -----
 net/sunrpc/svcauth_unix.c    |    4 ++--
 3 files changed, 23 insertions(+), 35 deletions(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 8419f7d..6ce690d 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -149,6 +149,24 @@ struct cache_deferred_req {
 					   int too_many);
 };
 
+/*
+ * timestamps kept in the cache are expressed in seconds
+ * since boot.  This is the best for measuring differences in
+ * real time.
+ */
+static inline time_t seconds_since_boot(void)
+{
+	struct timespec boot;
+	getboottime(&boot);
+	return get_seconds() - boot.tv_sec;
+}
+
+static inline time_t convert_to_wallclock(time_t sinceboot)
+{
+	struct timespec boot;
+	getboottime(&boot);
+	return boot.tv_sec + sinceboot;
+}
 
 extern const struct file_operations cache_file_operations_pipefs;
 extern const struct file_operations content_file_operations_pipefs;
@@ -182,15 +200,10 @@ static inline void cache_put(struct cache_head *h, struct cache_detail *cd)
 	kref_put(&h->ref, cd->cache_put);
 }
 
-static inline int cache_valid(struct cache_head *h)
+static inline int cache_is_expired(struct cache_detail *detail, struct cache_head *h)
 {
-	/* If an item has been unhashed pending removal when
-	 * the refcount drops to 0, the expiry_time will be
-	 * set to 0.  We don't want to consider such items
-	 * valid in this context even though CACHE_VALID is
-	 * set.
-	 */
-	return (h->expiry_time != 0 && test_bit(CACHE_VALID, &h->flags));
+	return  (h->expiry_time < seconds_since_boot()) ||
+		(detail->flush_time > h->last_refresh);
 }
 
 extern int cache_check(struct cache_detail *detail,
@@ -251,25 +264,6 @@ static inline int get_uint(char **bpp, unsigned int *anint)
 	return 0;
 }
 
-/*
- * timestamps kept in the cache are expressed in seconds
- * since boot.  This is the best for measuring differences in
- * real time.
- */
-static inline time_t seconds_since_boot(void)
-{
-	struct timespec boot;
-	getboottime(&boot);
-	return get_seconds() - boot.tv_sec;
-}
-
-static inline time_t convert_to_wallclock(time_t sinceboot)
-{
-	struct timespec boot;
-	getboottime(&boot);
-	return boot.tv_sec + sinceboot;
-}
-
 static inline time_t get_expiry(char **bpp)
 {
 	int rv;
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 454e23c..d01eb07 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -50,12 +50,6 @@ static void cache_init(struct cache_head *h)
 	h->last_refresh = now;
 }
 
-static inline int cache_is_expired(struct cache_detail *detail, struct cache_head *h)
-{
-	return  (h->expiry_time < seconds_since_boot()) ||
-		(detail->flush_time > h->last_refresh);
-}
-
 struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
 				       struct cache_head *key, int hash)
 {
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 06bdf5a..a98853d 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -347,13 +347,13 @@ ip_map_cached_get(struct svc_xprt *xprt)
 		spin_lock(&xprt->xpt_lock);
 		ipm = xprt->xpt_auth_cache;
 		if (ipm != NULL) {
-			if (!cache_valid(&ipm->h)) {
+			sn = net_generic(xprt->xpt_net, sunrpc_net_id);
+			if (cache_is_expired(sn->ip_map_cache, &ipm->h)) {
 				/*
 				 * The entry has been invalidated since it was
 				 * remembered, e.g. by a second mount from the
 				 * same IP address.
 				 */
-				sn = net_generic(xprt->xpt_net, sunrpc_net_id);
 				xprt->xpt_auth_cache = NULL;
 				spin_unlock(&xprt->xpt_lock);
 				cache_put(&ipm->h, sn->ip_map_cache);



From: Greg Banks <gnb@sgi.com>
Subject: [patch 06/14] sunrpc: Gather forward declarations of static functions in cache.c.
Date: Thu, 08 Jan 2009 19:25:16 +1100
Message-ID: <20090108082603.660311000@sgi.com>
References: <20090108082510.050854000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:54354 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753431AbZAHI0O (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 03:26:14 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Previously these forward declarations were scattered throughout
the code.  This makes the cache code easier to read.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 net/sunrpc/cache.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: bfields/net/sunrpc/cache.c
===================================================================
--- bfields.orig/net/sunrpc/cache.c
+++ bfields/net/sunrpc/cache.c
@@ -36,6 +36,9 @@
 
 static int cache_defer_req(struct cache_req *req, struct cache_head *h);
 static void cache_revisit_request(struct cache_head *h);
+static int cache_make_upcall(struct cache_detail *cd, struct cache_head *h);
+static void cache_remove_queued(struct cache_detail *cd, struct cache_head *h);
+static void do_cache_clean(struct work_struct *work);
 
 static void cache_init(struct cache_head *h)
 {
@@ -101,7 +104,6 @@ struct cache_head *sunrpc_cache_lookup(s
 EXPORT_SYMBOL(sunrpc_cache_lookup);
 
 
-static void cache_remove_queued(struct cache_detail *cd, struct cache_head *h);
 
 static int cache_fresh_locked(struct cache_head *h, time_t expiry)
 {
@@ -175,7 +177,6 @@ struct cache_head *sunrpc_cache_update(s
 }
 EXPORT_SYMBOL(sunrpc_cache_update);
 
-static int cache_make_upcall(struct cache_detail *cd, struct cache_head *h);
 /*
  * This is the generic cache management routine for all
  * the authentication caches.
@@ -288,7 +289,6 @@ static const struct file_operations cach
 static const struct file_operations content_file_operations;
 static const struct file_operations cache_flush_operations;
 
-static void do_cache_clean(struct work_struct *work);
 static DECLARE_DELAYED_WORK(cache_cleaner, do_cache_clean);
 
 static void remove_cache_proc_entries(struct cache_detail *cd)

--
-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

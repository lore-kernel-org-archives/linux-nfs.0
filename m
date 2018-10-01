Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f193.google.com ([209.85.166.193]:55577 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729497AbeJAVUh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 17:20:37 -0400
Received: by mail-it1-f193.google.com with SMTP id c23-v6so11592901itd.5
        for <linux-nfs@vger.kernel.org>; Mon, 01 Oct 2018 07:42:28 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 09/15] SUNRPC: Remove non-RCU protected lookup
Date: Mon,  1 Oct 2018 10:41:51 -0400
Message-Id: <20181001144157.3515-10-trond.myklebust@hammerspace.com>
In-Reply-To: <20181001144157.3515-9-trond.myklebust@hammerspace.com>
References: <20181001144157.3515-1-trond.myklebust@hammerspace.com>
 <20181001144157.3515-2-trond.myklebust@hammerspace.com>
 <20181001144157.3515-3-trond.myklebust@hammerspace.com>
 <20181001144157.3515-4-trond.myklebust@hammerspace.com>
 <20181001144157.3515-5-trond.myklebust@hammerspace.com>
 <20181001144157.3515-6-trond.myklebust@hammerspace.com>
 <20181001144157.3515-7-trond.myklebust@hammerspace.com>
 <20181001144157.3515-8-trond.myklebust@hammerspace.com>
 <20181001144157.3515-9-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up the cache code by removing the non-RCU protected lookup.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 Documentation/filesystems/nfs/rpc-cache.txt |  6 +-
 include/linux/sunrpc/cache.h                |  6 --
 net/sunrpc/cache.c                          | 61 ++-------------------
 3 files changed, 7 insertions(+), 66 deletions(-)

diff --git a/Documentation/filesystems/nfs/rpc-cache.txt b/Documentation/filesystems/nfs/rpc-cache.txt
index ebcaaee21616..c4dac829db0f 100644
--- a/Documentation/filesystems/nfs/rpc-cache.txt
+++ b/Documentation/filesystems/nfs/rpc-cache.txt
@@ -84,7 +84,7 @@ Creating a Cache
 		A message from user space has arrived to fill out a
 		cache entry.  It is in 'buf' of length 'len'.
 		cache_parse should parse this, find the item in the
-		cache with sunrpc_cache_lookup, and update the item
+		cache with sunrpc_cache_lookup_rcu, and update the item
 		with sunrpc_cache_update.
 
 
@@ -95,7 +95,7 @@ Creating a Cache
 Using a cache
 -------------
 
-To find a value in a cache, call sunrpc_cache_lookup passing a pointer
+To find a value in a cache, call sunrpc_cache_lookup_rcu passing a pointer
 to the cache_head in a sample item with the 'key' fields filled in.
 This will be passed to ->match to identify the target entry.  If no
 entry is found, a new entry will be create, added to the cache, and
@@ -116,7 +116,7 @@ item does become valid, the deferred copy of the request will be
 revisited (->revisit).  It is expected that this method will
 reschedule the request for processing.
 
-The value returned by sunrpc_cache_lookup can also be passed to
+The value returned by sunrpc_cache_lookup_rcu can also be passed to
 sunrpc_cache_update to set the content for the item.  A second item is
 passed which should hold the content.  If the item found by _lookup
 has valid data, then it is discarded and a new item is created.  This
diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index cf3e17ee2786..c3d67e893430 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -171,9 +171,6 @@ extern struct cache_head *
 sunrpc_cache_lookup_rcu(struct cache_detail *detail,
 			struct cache_head *key, int hash);
 extern struct cache_head *
-sunrpc_cache_lookup(struct cache_detail *detail,
-		    struct cache_head *key, int hash);
-extern struct cache_head *
 sunrpc_cache_update(struct cache_detail *detail,
 		    struct cache_head *new, struct cache_head *old, int hash);
 
@@ -233,9 +230,6 @@ extern void sunrpc_cache_unregister_pipefs(struct cache_detail *);
 extern void sunrpc_cache_unhash(struct cache_detail *, struct cache_head *);
 
 /* Must store cache_detail in seq_file->private if using next three functions */
-extern void *cache_seq_start(struct seq_file *file, loff_t *pos);
-extern void *cache_seq_next(struct seq_file *file, void *p, loff_t *pos);
-extern void cache_seq_stop(struct seq_file *file, void *p);
 extern void *cache_seq_start_rcu(struct seq_file *file, loff_t *pos);
 extern void *cache_seq_next_rcu(struct seq_file *file, void *p, loff_t *pos);
 extern void cache_seq_stop_rcu(struct seq_file *file, void *p);
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 7593afed9036..593cf8607414 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -75,27 +75,6 @@ static struct cache_head *sunrpc_cache_find_rcu(struct cache_detail *detail,
 	return NULL;
 }
 
-static struct cache_head *sunrpc_cache_find(struct cache_detail *detail,
-					    struct cache_head *key, int hash)
-{
-	struct hlist_head *head = &detail->hash_table[hash];
-	struct cache_head *tmp;
-
-	read_lock(&detail->hash_lock);
-	hlist_for_each_entry(tmp, head, cache_list) {
-		if (detail->match(tmp, key)) {
-			if (cache_is_expired(detail, tmp))
-				/* This entry is expired, we will discard it. */
-				break;
-			cache_get(tmp);
-			read_unlock(&detail->hash_lock);
-			return tmp;
-		}
-	}
-	read_unlock(&detail->hash_lock);
-	return NULL;
-}
-
 static struct cache_head *sunrpc_cache_add_entry(struct cache_detail *detail,
 						 struct cache_head *key,
 						 int hash)
@@ -154,20 +133,6 @@ struct cache_head *sunrpc_cache_lookup_rcu(struct cache_detail *detail,
 }
 EXPORT_SYMBOL_GPL(sunrpc_cache_lookup_rcu);
 
-struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
-				       struct cache_head *key, int hash)
-{
-	struct cache_head *ret;
-
-	ret = sunrpc_cache_find(detail, key, hash);
-	if (ret)
-		return ret;
-	/* Didn't find anything, insert an empty entry */
-	return sunrpc_cache_add_entry(detail, key, hash);
-}
-EXPORT_SYMBOL_GPL(sunrpc_cache_lookup);
-
-
 static void cache_dequeue(struct cache_detail *detail, struct cache_head *ch);
 
 static void cache_fresh_locked(struct cache_head *head, time_t expiry,
@@ -1369,17 +1334,7 @@ static void *__cache_seq_start(struct seq_file *m, loff_t *pos)
 				struct cache_head, cache_list);
 }
 
-void *cache_seq_start(struct seq_file *m, loff_t *pos)
-	__acquires(cd->hash_lock)
-{
-	struct cache_detail *cd = m->private;
-
-	read_lock(&cd->hash_lock);
-	return __cache_seq_start(m, pos);
-}
-EXPORT_SYMBOL_GPL(cache_seq_start);
-
-void *cache_seq_next(struct seq_file *m, void *p, loff_t *pos)
+static void *cache_seq_next(struct seq_file *m, void *p, loff_t *pos)
 {
 	struct cache_head *ch = p;
 	int hash = (*pos >> 32);
@@ -1411,14 +1366,6 @@ void *cache_seq_next(struct seq_file *m, void *p, loff_t *pos)
 }
 EXPORT_SYMBOL_GPL(cache_seq_next);
 
-void cache_seq_stop(struct seq_file *m, void *p)
-	__releases(cd->hash_lock)
-{
-	struct cache_detail *cd = m->private;
-	read_unlock(&cd->hash_lock);
-}
-EXPORT_SYMBOL_GPL(cache_seq_stop);
-
 void *cache_seq_start_rcu(struct seq_file *m, loff_t *pos)
 	__acquires(RCU)
 {
@@ -1466,9 +1413,9 @@ static int c_show(struct seq_file *m, void *p)
 }
 
 static const struct seq_operations cache_content_op = {
-	.start	= cache_seq_start,
-	.next	= cache_seq_next,
-	.stop	= cache_seq_stop,
+	.start	= cache_seq_start_rcu,
+	.next	= cache_seq_next_rcu,
+	.stop	= cache_seq_stop_rcu,
 	.show	= c_show,
 };
 
-- 
2.17.1

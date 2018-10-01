Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f196.google.com ([209.85.166.196]:50904 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729479AbeJAVUi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 17:20:38 -0400
Received: by mail-it1-f196.google.com with SMTP id j81-v6so11614404ite.0
        for <linux-nfs@vger.kernel.org>; Mon, 01 Oct 2018 07:42:29 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 10/15] SUNRPC: Replace the cache_detail->hash_lock with a regular spinlock
Date: Mon,  1 Oct 2018 10:41:52 -0400
Message-Id: <20181001144157.3515-11-trond.myklebust@hammerspace.com>
In-Reply-To: <20181001144157.3515-10-trond.myklebust@hammerspace.com>
References: <20181001144157.3515-1-trond.myklebust@hammerspace.com>
 <20181001144157.3515-2-trond.myklebust@hammerspace.com>
 <20181001144157.3515-3-trond.myklebust@hammerspace.com>
 <20181001144157.3515-4-trond.myklebust@hammerspace.com>
 <20181001144157.3515-5-trond.myklebust@hammerspace.com>
 <20181001144157.3515-6-trond.myklebust@hammerspace.com>
 <20181001144157.3515-7-trond.myklebust@hammerspace.com>
 <20181001144157.3515-8-trond.myklebust@hammerspace.com>
 <20181001144157.3515-9-trond.myklebust@hammerspace.com>
 <20181001144157.3515-10-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that the reader functions are all RCU protected, use a regular
spinlock rather than a reader/writer lock.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/cache.h |  2 +-
 net/sunrpc/cache.c           | 46 ++++++++++++++++++------------------
 2 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index c3d67e893430..5a3e95017fc6 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -67,7 +67,7 @@ struct cache_detail {
 	struct module *		owner;
 	int			hash_size;
 	struct hlist_head *	hash_table;
-	rwlock_t		hash_lock;
+	spinlock_t		hash_lock;
 
 	char			*name;
 	void			(*cache_put)(struct kref *);
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 593cf8607414..f96345b1180e 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -92,7 +92,7 @@ static struct cache_head *sunrpc_cache_add_entry(struct cache_detail *detail,
 	cache_init(new, detail);
 	detail->init(new, key);
 
-	write_lock(&detail->hash_lock);
+	spin_lock(&detail->hash_lock);
 
 	/* check if entry appeared while we slept */
 	hlist_for_each_entry_rcu(tmp, head, cache_list) {
@@ -104,7 +104,7 @@ static struct cache_head *sunrpc_cache_add_entry(struct cache_detail *detail,
 				break;
 			}
 			cache_get(tmp);
-			write_unlock(&detail->hash_lock);
+			spin_unlock(&detail->hash_lock);
 			cache_put(new, detail);
 			return tmp;
 		}
@@ -113,7 +113,7 @@ static struct cache_head *sunrpc_cache_add_entry(struct cache_detail *detail,
 	hlist_add_head_rcu(&new->cache_list, head);
 	detail->entries++;
 	cache_get(new);
-	write_unlock(&detail->hash_lock);
+	spin_unlock(&detail->hash_lock);
 
 	if (freeme)
 		cache_put(freeme, detail);
@@ -167,18 +167,18 @@ struct cache_head *sunrpc_cache_update(struct cache_detail *detail,
 	struct cache_head *tmp;
 
 	if (!test_bit(CACHE_VALID, &old->flags)) {
-		write_lock(&detail->hash_lock);
+		spin_lock(&detail->hash_lock);
 		if (!test_bit(CACHE_VALID, &old->flags)) {
 			if (test_bit(CACHE_NEGATIVE, &new->flags))
 				set_bit(CACHE_NEGATIVE, &old->flags);
 			else
 				detail->update(old, new);
 			cache_fresh_locked(old, new->expiry_time, detail);
-			write_unlock(&detail->hash_lock);
+			spin_unlock(&detail->hash_lock);
 			cache_fresh_unlocked(old, detail);
 			return old;
 		}
-		write_unlock(&detail->hash_lock);
+		spin_unlock(&detail->hash_lock);
 	}
 	/* We need to insert a new entry */
 	tmp = detail->alloc();
@@ -189,7 +189,7 @@ struct cache_head *sunrpc_cache_update(struct cache_detail *detail,
 	cache_init(tmp, detail);
 	detail->init(tmp, old);
 
-	write_lock(&detail->hash_lock);
+	spin_lock(&detail->hash_lock);
 	if (test_bit(CACHE_NEGATIVE, &new->flags))
 		set_bit(CACHE_NEGATIVE, &tmp->flags);
 	else
@@ -199,7 +199,7 @@ struct cache_head *sunrpc_cache_update(struct cache_detail *detail,
 	cache_get(tmp);
 	cache_fresh_locked(tmp, new->expiry_time, detail);
 	cache_fresh_locked(old, 0, detail);
-	write_unlock(&detail->hash_lock);
+	spin_unlock(&detail->hash_lock);
 	cache_fresh_unlocked(tmp, detail);
 	cache_fresh_unlocked(old, detail);
 	cache_put(old, detail);
@@ -239,7 +239,7 @@ static int try_to_negate_entry(struct cache_detail *detail, struct cache_head *h
 {
 	int rv;
 
-	write_lock(&detail->hash_lock);
+	spin_lock(&detail->hash_lock);
 	rv = cache_is_valid(h);
 	if (rv == -EAGAIN) {
 		set_bit(CACHE_NEGATIVE, &h->flags);
@@ -247,7 +247,7 @@ static int try_to_negate_entry(struct cache_detail *detail, struct cache_head *h
 				   detail);
 		rv = -ENOENT;
 	}
-	write_unlock(&detail->hash_lock);
+	spin_unlock(&detail->hash_lock);
 	cache_fresh_unlocked(h, detail);
 	return rv;
 }
@@ -357,7 +357,7 @@ static struct delayed_work cache_cleaner;
 
 void sunrpc_init_cache_detail(struct cache_detail *cd)
 {
-	rwlock_init(&cd->hash_lock);
+	spin_lock_init(&cd->hash_lock);
 	INIT_LIST_HEAD(&cd->queue);
 	spin_lock(&cache_list_lock);
 	cd->nextcheck = 0;
@@ -377,11 +377,11 @@ void sunrpc_destroy_cache_detail(struct cache_detail *cd)
 {
 	cache_purge(cd);
 	spin_lock(&cache_list_lock);
-	write_lock(&cd->hash_lock);
+	spin_lock(&cd->hash_lock);
 	if (current_detail == cd)
 		current_detail = NULL;
 	list_del_init(&cd->others);
-	write_unlock(&cd->hash_lock);
+	spin_unlock(&cd->hash_lock);
 	spin_unlock(&cache_list_lock);
 	if (list_empty(&cache_list)) {
 		/* module must be being unloaded so its safe to kill the worker */
@@ -438,7 +438,7 @@ static int cache_clean(void)
 		struct hlist_head *head;
 		struct hlist_node *tmp;
 
-		write_lock(&current_detail->hash_lock);
+		spin_lock(&current_detail->hash_lock);
 
 		/* Ok, now to clean this strand */
 
@@ -455,7 +455,7 @@ static int cache_clean(void)
 			break;
 		}
 
-		write_unlock(&current_detail->hash_lock);
+		spin_unlock(&current_detail->hash_lock);
 		d = current_detail;
 		if (!ch)
 			current_index ++;
@@ -510,9 +510,9 @@ void cache_purge(struct cache_detail *detail)
 	struct hlist_node *tmp = NULL;
 	int i = 0;
 
-	write_lock(&detail->hash_lock);
+	spin_lock(&detail->hash_lock);
 	if (!detail->entries) {
-		write_unlock(&detail->hash_lock);
+		spin_unlock(&detail->hash_lock);
 		return;
 	}
 
@@ -524,13 +524,13 @@ void cache_purge(struct cache_detail *detail)
 			detail->entries--;
 
 			set_bit(CACHE_CLEANED, &ch->flags);
-			write_unlock(&detail->hash_lock);
+			spin_unlock(&detail->hash_lock);
 			cache_fresh_unlocked(ch, detail);
 			cache_put(ch, detail);
-			write_lock(&detail->hash_lock);
+			spin_lock(&detail->hash_lock);
 		}
 	}
-	write_unlock(&detail->hash_lock);
+	spin_unlock(&detail->hash_lock);
 }
 EXPORT_SYMBOL_GPL(cache_purge);
 
@@ -1873,13 +1873,13 @@ EXPORT_SYMBOL_GPL(sunrpc_cache_unregister_pipefs);
 
 void sunrpc_cache_unhash(struct cache_detail *cd, struct cache_head *h)
 {
-	write_lock(&cd->hash_lock);
+	spin_lock(&cd->hash_lock);
 	if (!hlist_unhashed(&h->cache_list)){
 		hlist_del_init_rcu(&h->cache_list);
 		cd->entries--;
-		write_unlock(&cd->hash_lock);
+		spin_unlock(&cd->hash_lock);
 		cache_put(h, cd);
 	} else
-		write_unlock(&cd->hash_lock);
+		spin_unlock(&cd->hash_lock);
 }
 EXPORT_SYMBOL_GPL(sunrpc_cache_unhash);
-- 
2.17.1

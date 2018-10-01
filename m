Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f193.google.com ([209.85.166.193]:50876 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729412AbeJAVUd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 17:20:33 -0400
Received: by mail-it1-f193.google.com with SMTP id j81-v6so11613807ite.0
        for <linux-nfs@vger.kernel.org>; Mon, 01 Oct 2018 07:42:23 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 03/15] SUNRPC: Allow cache lookups to use RCU protection rather than the r/w spinlock
Date: Mon,  1 Oct 2018 10:41:45 -0400
Message-Id: <20181001144157.3515-4-trond.myklebust@hammerspace.com>
In-Reply-To: <20181001144157.3515-3-trond.myklebust@hammerspace.com>
References: <20181001144157.3515-1-trond.myklebust@hammerspace.com>
 <20181001144157.3515-2-trond.myklebust@hammerspace.com>
 <20181001144157.3515-3-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of the reader/writer spinlock, allow cache lookups to use RCU
for looking up entries. This is more efficient since modifications can
occur while other entries are being looked up.

Note that for now, we keep the reader/writer spinlock until all users
have been converted to use RCU-safe freeing of their cache entries.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/cache.h |  12 ++++
 net/sunrpc/cache.c           | 122 +++++++++++++++++++++++++++++------
 2 files changed, 114 insertions(+), 20 deletions(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 40d2822f0e2f..cf3e17ee2786 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -167,6 +167,9 @@ extern const struct file_operations cache_file_operations_pipefs;
 extern const struct file_operations content_file_operations_pipefs;
 extern const struct file_operations cache_flush_operations_pipefs;
 
+extern struct cache_head *
+sunrpc_cache_lookup_rcu(struct cache_detail *detail,
+			struct cache_head *key, int hash);
 extern struct cache_head *
 sunrpc_cache_lookup(struct cache_detail *detail,
 		    struct cache_head *key, int hash);
@@ -186,6 +189,12 @@ static inline struct cache_head  *cache_get(struct cache_head *h)
 	return h;
 }
 
+static inline struct cache_head  *cache_get_rcu(struct cache_head *h)
+{
+	if (kref_get_unless_zero(&h->ref))
+		return h;
+	return NULL;
+}
 
 static inline void cache_put(struct cache_head *h, struct cache_detail *cd)
 {
@@ -227,6 +236,9 @@ extern void sunrpc_cache_unhash(struct cache_detail *, struct cache_head *);
 extern void *cache_seq_start(struct seq_file *file, loff_t *pos);
 extern void *cache_seq_next(struct seq_file *file, void *p, loff_t *pos);
 extern void cache_seq_stop(struct seq_file *file, void *p);
+extern void *cache_seq_start_rcu(struct seq_file *file, loff_t *pos);
+extern void *cache_seq_next_rcu(struct seq_file *file, void *p, loff_t *pos);
+extern void cache_seq_stop_rcu(struct seq_file *file, void *p);
 
 extern void qword_add(char **bpp, int *lp, char *str);
 extern void qword_addhex(char **bpp, int *lp, char *buf, int blen);
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 109fbe591e7b..7593afed9036 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -54,16 +54,34 @@ static void cache_init(struct cache_head *h, struct cache_detail *detail)
 	h->last_refresh = now;
 }
 
-struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
-				       struct cache_head *key, int hash)
+static struct cache_head *sunrpc_cache_find_rcu(struct cache_detail *detail,
+						struct cache_head *key,
+						int hash)
 {
-	struct cache_head *new = NULL, *freeme = NULL, *tmp = NULL;
-	struct hlist_head *head;
+	struct hlist_head *head = &detail->hash_table[hash];
+	struct cache_head *tmp;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(tmp, head, cache_list) {
+		if (detail->match(tmp, key)) {
+			if (cache_is_expired(detail, tmp))
+				continue;
+			tmp = cache_get_rcu(tmp);
+			rcu_read_unlock();
+			return tmp;
+		}
+	}
+	rcu_read_unlock();
+	return NULL;
+}
 
-	head = &detail->hash_table[hash];
+static struct cache_head *sunrpc_cache_find(struct cache_detail *detail,
+					    struct cache_head *key, int hash)
+{
+	struct hlist_head *head = &detail->hash_table[hash];
+	struct cache_head *tmp;
 
 	read_lock(&detail->hash_lock);
-
 	hlist_for_each_entry(tmp, head, cache_list) {
 		if (detail->match(tmp, key)) {
 			if (cache_is_expired(detail, tmp))
@@ -75,7 +93,15 @@ struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
 		}
 	}
 	read_unlock(&detail->hash_lock);
-	/* Didn't find anything, insert an empty entry */
+	return NULL;
+}
+
+static struct cache_head *sunrpc_cache_add_entry(struct cache_detail *detail,
+						 struct cache_head *key,
+						 int hash)
+{
+	struct cache_head *new, *tmp, *freeme = NULL;
+	struct hlist_head *head = &detail->hash_table[hash];
 
 	new = detail->alloc();
 	if (!new)
@@ -90,10 +116,10 @@ struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
 	write_lock(&detail->hash_lock);
 
 	/* check if entry appeared while we slept */
-	hlist_for_each_entry(tmp, head, cache_list) {
+	hlist_for_each_entry_rcu(tmp, head, cache_list) {
 		if (detail->match(tmp, key)) {
 			if (cache_is_expired(detail, tmp)) {
-				hlist_del_init(&tmp->cache_list);
+				hlist_del_init_rcu(&tmp->cache_list);
 				detail->entries --;
 				freeme = tmp;
 				break;
@@ -105,7 +131,7 @@ struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
 		}
 	}
 
-	hlist_add_head(&new->cache_list, head);
+	hlist_add_head_rcu(&new->cache_list, head);
 	detail->entries++;
 	cache_get(new);
 	write_unlock(&detail->hash_lock);
@@ -114,6 +140,31 @@ struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
 		cache_put(freeme, detail);
 	return new;
 }
+
+struct cache_head *sunrpc_cache_lookup_rcu(struct cache_detail *detail,
+					   struct cache_head *key, int hash)
+{
+	struct cache_head *ret;
+
+	ret = sunrpc_cache_find_rcu(detail, key, hash);
+	if (ret)
+		return ret;
+	/* Didn't find anything, insert an empty entry */
+	return sunrpc_cache_add_entry(detail, key, hash);
+}
+EXPORT_SYMBOL_GPL(sunrpc_cache_lookup_rcu);
+
+struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
+				       struct cache_head *key, int hash)
+{
+	struct cache_head *ret;
+
+	ret = sunrpc_cache_find(detail, key, hash);
+	if (ret)
+		return ret;
+	/* Didn't find anything, insert an empty entry */
+	return sunrpc_cache_add_entry(detail, key, hash);
+}
 EXPORT_SYMBOL_GPL(sunrpc_cache_lookup);
 
 
@@ -433,7 +484,7 @@ static int cache_clean(void)
 			if (!cache_is_expired(current_detail, ch))
 				continue;
 
-			hlist_del_init(&ch->cache_list);
+			hlist_del_init_rcu(&ch->cache_list);
 			current_detail->entries--;
 			rv = 1;
 			break;
@@ -504,7 +555,7 @@ void cache_purge(struct cache_detail *detail)
 	for (i = 0; i < detail->hash_size; i++) {
 		head = &detail->hash_table[i];
 		hlist_for_each_entry_safe(ch, tmp, head, cache_list) {
-			hlist_del_init(&ch->cache_list);
+			hlist_del_init_rcu(&ch->cache_list);
 			detail->entries--;
 
 			set_bit(CACHE_CLEANED, &ch->flags);
@@ -1289,21 +1340,19 @@ EXPORT_SYMBOL_GPL(qword_get);
  * get a header, then pass each real item in the cache
  */
 
-void *cache_seq_start(struct seq_file *m, loff_t *pos)
-	__acquires(cd->hash_lock)
+static void *__cache_seq_start(struct seq_file *m, loff_t *pos)
 {
 	loff_t n = *pos;
 	unsigned int hash, entry;
 	struct cache_head *ch;
 	struct cache_detail *cd = m->private;
 
-	read_lock(&cd->hash_lock);
 	if (!n--)
 		return SEQ_START_TOKEN;
 	hash = n >> 32;
 	entry = n & ((1LL<<32) - 1);
 
-	hlist_for_each_entry(ch, &cd->hash_table[hash], cache_list)
+	hlist_for_each_entry_rcu(ch, &cd->hash_table[hash], cache_list)
 		if (!entry--)
 			return ch;
 	n &= ~((1LL<<32) - 1);
@@ -1315,9 +1364,19 @@ void *cache_seq_start(struct seq_file *m, loff_t *pos)
 	if (hash >= cd->hash_size)
 		return NULL;
 	*pos = n+1;
-	return hlist_entry_safe(cd->hash_table[hash].first,
+	return hlist_entry_safe(rcu_dereference_raw(
+				hlist_first_rcu(&cd->hash_table[hash])),
 				struct cache_head, cache_list);
 }
+
+void *cache_seq_start(struct seq_file *m, loff_t *pos)
+	__acquires(cd->hash_lock)
+{
+	struct cache_detail *cd = m->private;
+
+	read_lock(&cd->hash_lock);
+	return __cache_seq_start(m, pos);
+}
 EXPORT_SYMBOL_GPL(cache_seq_start);
 
 void *cache_seq_next(struct seq_file *m, void *p, loff_t *pos)
@@ -1333,7 +1392,8 @@ void *cache_seq_next(struct seq_file *m, void *p, loff_t *pos)
 		*pos += 1LL<<32;
 	} else {
 		++*pos;
-		return hlist_entry_safe(ch->cache_list.next,
+		return hlist_entry_safe(rcu_dereference_raw(
+					hlist_next_rcu(&ch->cache_list)),
 					struct cache_head, cache_list);
 	}
 	*pos &= ~((1LL<<32) - 1);
@@ -1345,7 +1405,8 @@ void *cache_seq_next(struct seq_file *m, void *p, loff_t *pos)
 	if (hash >= cd->hash_size)
 		return NULL;
 	++*pos;
-	return hlist_entry_safe(cd->hash_table[hash].first,
+	return hlist_entry_safe(rcu_dereference_raw(
+				hlist_first_rcu(&cd->hash_table[hash])),
 				struct cache_head, cache_list);
 }
 EXPORT_SYMBOL_GPL(cache_seq_next);
@@ -1358,6 +1419,27 @@ void cache_seq_stop(struct seq_file *m, void *p)
 }
 EXPORT_SYMBOL_GPL(cache_seq_stop);
 
+void *cache_seq_start_rcu(struct seq_file *m, loff_t *pos)
+	__acquires(RCU)
+{
+	rcu_read_lock();
+	return __cache_seq_start(m, pos);
+}
+EXPORT_SYMBOL_GPL(cache_seq_start_rcu);
+
+void *cache_seq_next_rcu(struct seq_file *file, void *p, loff_t *pos)
+{
+	return cache_seq_next(file, p, pos);
+}
+EXPORT_SYMBOL_GPL(cache_seq_next_rcu);
+
+void cache_seq_stop_rcu(struct seq_file *m, void *p)
+	__releases(RCU)
+{
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL_GPL(cache_seq_stop_rcu);
+
 static int c_show(struct seq_file *m, void *p)
 {
 	struct cache_head *cp = p;
@@ -1846,7 +1928,7 @@ void sunrpc_cache_unhash(struct cache_detail *cd, struct cache_head *h)
 {
 	write_lock(&cd->hash_lock);
 	if (!hlist_unhashed(&h->cache_list)){
-		hlist_del_init(&h->cache_list);
+		hlist_del_init_rcu(&h->cache_list);
 		cd->entries--;
 		write_unlock(&cd->hash_lock);
 		cache_put(h, cd);
-- 
2.17.1

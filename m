Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:57592 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726811AbeJCW5L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 3 Oct 2018 18:57:11 -0400
Date: Wed, 3 Oct 2018 12:08:09 -0400
From: "J . Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 03/15] SUNRPC: Allow cache lookups to use RCU protection
 rather than the r/w spinlock
Message-ID: <20181003160809.GE17517@fieldses.org>
References: <20181001144157.3515-1-trond.myklebust@hammerspace.com>
 <20181001144157.3515-2-trond.myklebust@hammerspace.com>
 <20181001144157.3515-3-trond.myklebust@hammerspace.com>
 <20181001144157.3515-4-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20181001144157.3515-4-trond.myklebust@hammerspace.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 01, 2018 at 10:41:45AM -0400, Trond Myklebust wrote:
> Instead of the reader/writer spinlock, allow cache lookups to use RCU
> for looking up entries. This is more efficient since modifications can
> occur while other entries are being looked up.
> 
> Note that for now, we keep the reader/writer spinlock until all users
> have been converted to use RCU-safe freeing of their cache entries.

This one's a bit easier for me to review if I separate out find/add
split from the interesting part.

Looks good to me, applying as follows:

--b.

commit b92a8fababa9
Author: Trond Myklebust <trondmy@gmail.com>
Date:   Mon Oct 1 10:41:45 2018 -0400

    SUNRPC: Refactor sunrpc_cache_lookup
    
    This is a trivial split into lookup and insert functions, no change in
    behavior.
    
    Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 109fbe591e7b..aa8e62d61f4d 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -54,13 +54,11 @@ static void cache_init(struct cache_head *h, struct cache_detail *detail)
 	h->last_refresh = now;
 }
 
-struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
-				       struct cache_head *key, int hash)
+static struct cache_head *sunrpc_cache_find(struct cache_detail *detail,
+					    struct cache_head *key, int hash)
 {
-	struct cache_head *new = NULL, *freeme = NULL, *tmp = NULL;
-	struct hlist_head *head;
-
-	head = &detail->hash_table[hash];
+	struct hlist_head *head = &detail->hash_table[hash];
+	struct cache_head *tmp;
 
 	read_lock(&detail->hash_lock);
 
@@ -75,7 +73,15 @@ struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
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
@@ -114,8 +120,19 @@ struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
 		cache_put(freeme, detail);
 	return new;
 }
-EXPORT_SYMBOL_GPL(sunrpc_cache_lookup);
 
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
+EXPORT_SYMBOL_GPL(sunrpc_cache_lookup);
 
 static void cache_dequeue(struct cache_detail *detail, struct cache_head *ch);
 
commit b0e4dad04223
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Oct 3 12:01:22 2018 -0400

    SUNRPC: Allow cache lookups to use RCU protection rather than the r/w spinlock
    
    Instead of the reader/writer spinlock, allow cache lookups to use RCU
    for looking up entries. This is more efficient since modifications can
    occur while other entries are being looked up.
    
    Note that for now, we keep the reader/writer spinlock until all users
    have been converted to use RCU-safe freeing of their cache entries.
    
    Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

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
index aa8e62d61f4d..7593afed9036 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -54,6 +54,27 @@ static void cache_init(struct cache_head *h, struct cache_detail *detail)
 	h->last_refresh = now;
 }
 
+static struct cache_head *sunrpc_cache_find_rcu(struct cache_detail *detail,
+						struct cache_head *key,
+						int hash)
+{
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
+
 static struct cache_head *sunrpc_cache_find(struct cache_detail *detail,
 					    struct cache_head *key, int hash)
 {
@@ -61,7 +82,6 @@ static struct cache_head *sunrpc_cache_find(struct cache_detail *detail,
 	struct cache_head *tmp;
 
 	read_lock(&detail->hash_lock);
-
 	hlist_for_each_entry(tmp, head, cache_list) {
 		if (detail->match(tmp, key)) {
 			if (cache_is_expired(detail, tmp))
@@ -96,10 +116,10 @@ static struct cache_head *sunrpc_cache_add_entry(struct cache_detail *detail,
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
@@ -111,7 +131,7 @@ static struct cache_head *sunrpc_cache_add_entry(struct cache_detail *detail,
 		}
 	}
 
-	hlist_add_head(&new->cache_list, head);
+	hlist_add_head_rcu(&new->cache_list, head);
 	detail->entries++;
 	cache_get(new);
 	write_unlock(&detail->hash_lock);
@@ -121,6 +141,19 @@ static struct cache_head *sunrpc_cache_add_entry(struct cache_detail *detail,
 	return new;
 }
 
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
 struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
 				       struct cache_head *key, int hash)
 {
@@ -134,6 +167,7 @@ struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
 }
 EXPORT_SYMBOL_GPL(sunrpc_cache_lookup);
 
+
 static void cache_dequeue(struct cache_detail *detail, struct cache_head *ch);
 
 static void cache_fresh_locked(struct cache_head *head, time_t expiry,
@@ -450,7 +484,7 @@ static int cache_clean(void)
 			if (!cache_is_expired(current_detail, ch))
 				continue;
 
-			hlist_del_init(&ch->cache_list);
+			hlist_del_init_rcu(&ch->cache_list);
 			current_detail->entries--;
 			rv = 1;
 			break;
@@ -521,7 +555,7 @@ void cache_purge(struct cache_detail *detail)
 	for (i = 0; i < detail->hash_size; i++) {
 		head = &detail->hash_table[i];
 		hlist_for_each_entry_safe(ch, tmp, head, cache_list) {
-			hlist_del_init(&ch->cache_list);
+			hlist_del_init_rcu(&ch->cache_list);
 			detail->entries--;
 
 			set_bit(CACHE_CLEANED, &ch->flags);
@@ -1306,21 +1340,19 @@ EXPORT_SYMBOL_GPL(qword_get);
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
@@ -1332,9 +1364,19 @@ void *cache_seq_start(struct seq_file *m, loff_t *pos)
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
@@ -1350,7 +1392,8 @@ void *cache_seq_next(struct seq_file *m, void *p, loff_t *pos)
 		*pos += 1LL<<32;
 	} else {
 		++*pos;
-		return hlist_entry_safe(ch->cache_list.next,
+		return hlist_entry_safe(rcu_dereference_raw(
+					hlist_next_rcu(&ch->cache_list)),
 					struct cache_head, cache_list);
 	}
 	*pos &= ~((1LL<<32) - 1);
@@ -1362,7 +1405,8 @@ void *cache_seq_next(struct seq_file *m, void *p, loff_t *pos)
 	if (hash >= cd->hash_size)
 		return NULL;
 	++*pos;
-	return hlist_entry_safe(cd->hash_table[hash].first,
+	return hlist_entry_safe(rcu_dereference_raw(
+				hlist_first_rcu(&cd->hash_table[hash])),
 				struct cache_head, cache_list);
 }
 EXPORT_SYMBOL_GPL(cache_seq_next);
@@ -1375,6 +1419,27 @@ void cache_seq_stop(struct seq_file *m, void *p)
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
@@ -1863,7 +1928,7 @@ void sunrpc_cache_unhash(struct cache_detail *cd, struct cache_head *h)
 {
 	write_lock(&cd->hash_lock);
 	if (!hlist_unhashed(&h->cache_list)){
-		hlist_del_init(&h->cache_list);
+		hlist_del_init_rcu(&h->cache_list);
 		cd->entries--;
 		write_unlock(&cd->hash_lock);
 		cache_put(h, cd);

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34220 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187AbbFYOaB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Jun 2015 10:30:01 -0400
Message-ID: <558C105E.4000707@gmail.com>
Date: Thu, 25 Jun 2015 22:29:50 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Al Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org
CC: NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 07/10 v6] sunrpc: Switch to using list_head instead single
 list
References: <558C0D6A.9050104@gmail.com>
In-Reply-To: <558C0D6A.9050104@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Switch using list_head for cache_head in cache_detail,
it is useful of remove an cache_head entry directly from cache_detail.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 include/linux/sunrpc/cache.h |  4 +--
 net/sunrpc/cache.c           | 74 ++++++++++++++++++++++++--------------------
 2 files changed, 43 insertions(+), 35 deletions(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 04ee5a2..ecc0ff6 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -46,7 +46,7 @@
  * 
  */
 struct cache_head {
-	struct cache_head * next;
+	struct list_head	cache_list;
 	time_t		expiry_time;	/* After time time, don't use the data */
 	time_t		last_refresh;   /* If CACHE_PENDING, this is when upcall 
 					 * was sent, else this is when update was received
@@ -73,7 +73,7 @@ struct cache_detail_pipefs {
 struct cache_detail {
 	struct module *		owner;
 	int			hash_size;
-	struct cache_head **	hash_table;
+	struct list_head *	hash_table;
 	rwlock_t		hash_lock;
 
 	atomic_t		inuse; /* active user-space update or lookup */
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 673c2fa..ad2155c 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -44,7 +44,7 @@ static void cache_revisit_request(struct cache_head *item);
 static void cache_init(struct cache_head *h)
 {
 	time_t now = seconds_since_boot();
-	h->next = NULL;
+	INIT_LIST_HEAD(&h->cache_list);
 	h->flags = 0;
 	kref_init(&h->ref);
 	h->expiry_time = now + CACHE_NEW_EXPIRY;
@@ -54,15 +54,16 @@ static void cache_init(struct cache_head *h)
 struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
 				       struct cache_head *key, int hash)
 {
-	struct cache_head **head,  **hp;
 	struct cache_head *new = NULL, *freeme = NULL;
+	struct cache_head *tmp;
+	struct list_head *head, *pos, *tpos;
 
 	head = &detail->hash_table[hash];
 
 	read_lock(&detail->hash_lock);
 
-	for (hp=head; *hp != NULL ; hp = &(*hp)->next) {
-		struct cache_head *tmp = *hp;
+	list_for_each_safe(pos, tpos, head) {
+		tmp = list_entry(pos, struct cache_head, cache_list);
 		if (detail->match(tmp, key)) {
 			if (cache_is_expired(detail, tmp))
 				/* This entry is expired, we will discard it. */
@@ -88,12 +89,11 @@ struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
 	write_lock(&detail->hash_lock);
 
 	/* check if entry appeared while we slept */
-	for (hp=head; *hp != NULL ; hp = &(*hp)->next) {
-		struct cache_head *tmp = *hp;
+	list_for_each_safe(pos, tpos, head) {
+		tmp = list_entry(pos, struct cache_head, cache_list);
 		if (detail->match(tmp, key)) {
 			if (cache_is_expired(detail, tmp)) {
-				*hp = tmp->next;
-				tmp->next = NULL;
+				list_del_init(&tmp->cache_list);
 				detail->entries --;
 				freeme = tmp;
 				break;
@@ -104,8 +104,8 @@ struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
 			return tmp;
 		}
 	}
-	new->next = *head;
-	*head = new;
+
+	list_add(&new->cache_list, head);
 	detail->entries++;
 	cache_get(new);
 	write_unlock(&detail->hash_lock);
@@ -143,7 +143,6 @@ struct cache_head *sunrpc_cache_update(struct cache_detail *detail,
 	 * If 'old' is not VALID, we update it directly,
 	 * otherwise we need to replace it
 	 */
-	struct cache_head **head;
 	struct cache_head *tmp;
 
 	if (!test_bit(CACHE_VALID, &old->flags)) {
@@ -168,15 +167,13 @@ struct cache_head *sunrpc_cache_update(struct cache_detail *detail,
 	}
 	cache_init(tmp);
 	detail->init(tmp, old);
-	head = &detail->hash_table[hash];
 
 	write_lock(&detail->hash_lock);
 	if (test_bit(CACHE_NEGATIVE, &new->flags))
 		set_bit(CACHE_NEGATIVE, &tmp->flags);
 	else
 		detail->update(tmp, new);
-	tmp->next = *head;
-	*head = tmp;
+	list_add(&tmp->cache_list, &detail->hash_table[hash]);
 	detail->entries++;
 	cache_get(tmp);
 	cache_fresh_locked(tmp, new->expiry_time);
@@ -416,42 +413,44 @@ static int cache_clean(void)
 	/* find a non-empty bucket in the table */
 	while (current_detail &&
 	       current_index < current_detail->hash_size &&
-	       current_detail->hash_table[current_index] == NULL)
+	       list_empty(&current_detail->hash_table[current_index]))
 		current_index++;
 
 	/* find a cleanable entry in the bucket and clean it, or set to next bucket */
 
 	if (current_detail && current_index < current_detail->hash_size) {
-		struct cache_head *ch, **cp;
+		struct cache_head *ch = NULL, *putme = NULL;
+		struct list_head *head, *pos, *tpos;
 		struct cache_detail *d;
 
 		write_lock(&current_detail->hash_lock);
 
 		/* Ok, now to clean this strand */
 
-		cp = & current_detail->hash_table[current_index];
-		for (ch = *cp ; ch ; cp = & ch->next, ch = *cp) {
+		head = &current_detail->hash_table[current_index];
+		list_for_each_safe(pos, tpos, head) {
+			ch = list_entry(pos, struct cache_head, cache_list);
 			if (current_detail->nextcheck > ch->expiry_time)
 				current_detail->nextcheck = ch->expiry_time+1;
 			if (!cache_is_expired(current_detail, ch))
 				continue;
 
-			*cp = ch->next;
-			ch->next = NULL;
+			list_del_init(pos);
 			current_detail->entries--;
+			putme = ch;
 			rv = 1;
 			break;
 		}
 
 		write_unlock(&current_detail->hash_lock);
 		d = current_detail;
-		if (!ch)
+		if (!putme)
 			current_index ++;
 		spin_unlock(&cache_list_lock);
-		if (ch) {
-			set_bit(CACHE_CLEANED, &ch->flags);
-			cache_fresh_unlocked(ch, d);
-			cache_put(ch, d);
+		if (putme) {
+			set_bit(CACHE_CLEANED, &putme->flags);
+			cache_fresh_unlocked(putme, d);
+			cache_put(putme, d);
 		}
 	} else
 		spin_unlock(&cache_list_lock);
@@ -1277,6 +1276,7 @@ void *cache_seq_start(struct seq_file *m, loff_t *pos)
 	unsigned int hash, entry;
 	struct cache_head *ch;
 	struct cache_detail *cd = m->private;
+	struct list_head *ptr, *tptr;
 
 	read_lock(&cd->hash_lock);
 	if (!n--)
@@ -1284,19 +1284,22 @@ void *cache_seq_start(struct seq_file *m, loff_t *pos)
 	hash = n >> 32;
 	entry = n & ((1LL<<32) - 1);
 
-	for (ch=cd->hash_table[hash]; ch; ch=ch->next)
+	list_for_each_safe(ptr, tptr, &cd->hash_table[hash]) {
+		ch = list_entry(ptr, struct cache_head, cache_list);
 		if (!entry--)
 			return ch;
+	}
 	n &= ~((1LL<<32) - 1);
 	do {
 		hash++;
 		n += 1LL<<32;
 	} while(hash < cd->hash_size &&
-		cd->hash_table[hash]==NULL);
+		list_empty(&cd->hash_table[hash]));
 	if (hash >= cd->hash_size)
 		return NULL;
 	*pos = n+1;
-	return cd->hash_table[hash];
+	return list_first_entry_or_null(&cd->hash_table[hash],
+					struct cache_head, cache_list);
 }
 EXPORT_SYMBOL_GPL(cache_seq_start);
 
@@ -1308,23 +1311,24 @@ void *cache_seq_next(struct seq_file *m, void *p, loff_t *pos)
 
 	if (p == SEQ_START_TOKEN)
 		hash = 0;
-	else if (ch->next == NULL) {
+	else if (list_is_last(&ch->cache_list, &cd->hash_table[hash])) {
 		hash++;
 		*pos += 1LL<<32;
 	} else {
 		++*pos;
-		return ch->next;
+		return list_next_entry(ch, cache_list);
 	}
 	*pos &= ~((1LL<<32) - 1);
 	while (hash < cd->hash_size &&
-	       cd->hash_table[hash] == NULL) {
+	       list_empty(&cd->hash_table[hash])) {
 		hash++;
 		*pos += 1LL<<32;
 	}
 	if (hash >= cd->hash_size)
 		return NULL;
 	++*pos;
-	return cd->hash_table[hash];
+	return list_first_entry_or_null(&cd->hash_table[hash],
+					struct cache_head, cache_list);
 }
 EXPORT_SYMBOL_GPL(cache_seq_next);
 
@@ -1666,17 +1670,21 @@ EXPORT_SYMBOL_GPL(cache_unregister_net);
 struct cache_detail *cache_create_net(struct cache_detail *tmpl, struct net *net)
 {
 	struct cache_detail *cd;
+	int i;
 
 	cd = kmemdup(tmpl, sizeof(struct cache_detail), GFP_KERNEL);
 	if (cd == NULL)
 		return ERR_PTR(-ENOMEM);
 
-	cd->hash_table = kzalloc(cd->hash_size * sizeof(struct cache_head *),
+	cd->hash_table = kzalloc(cd->hash_size * sizeof(struct list_head),
 				 GFP_KERNEL);
 	if (cd->hash_table == NULL) {
 		kfree(cd);
 		return ERR_PTR(-ENOMEM);
 	}
+
+	for (i = 0; i < cd->hash_size; i++)
+		INIT_LIST_HEAD(&cd->hash_table[i]);
 	cd->net = net;
 	return cd;
 }
-- 
2.4.3


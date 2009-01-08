From: Greg Banks <gnb@sgi.com>
Subject: [patch 01/14] sunrpc: Use consistent naming for variables of type struct cache_detail*.
Date: Thu, 08 Jan 2009 19:25:11 +1100
Message-ID: <20090108082602.583924000@sgi.com>
References: <20090108082510.050854000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.171.31]:44987 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750917AbZAHI0H (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 03:26:07 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 net/sunrpc/cache.c |  118 +++++++++++++++++++++---------------------
 1 file changed, 59 insertions(+), 59 deletions(-)

Index: bfields/net/sunrpc/cache.c
===================================================================
--- bfields.orig/net/sunrpc/cache.c
+++ bfields/net/sunrpc/cache.c
@@ -47,28 +47,28 @@ static void cache_init(struct cache_head
 	h->last_refresh = now;
 }
 
-struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
+struct cache_head *sunrpc_cache_lookup(struct cache_detail *cd,
 				       struct cache_head *key, int hash)
 {
 	struct cache_head **head,  **hp;
 	struct cache_head *new = NULL;
 
-	head = &detail->hash_table[hash];
+	head = &cd->hash_table[hash];
 
-	read_lock(&detail->hash_lock);
+	read_lock(&cd->hash_lock);
 
 	for (hp=head; *hp != NULL ; hp = &(*hp)->next) {
 		struct cache_head *tmp = *hp;
-		if (detail->match(tmp, key)) {
+		if (cd->match(tmp, key)) {
 			cache_get(tmp);
-			read_unlock(&detail->hash_lock);
+			read_unlock(&cd->hash_lock);
 			return tmp;
 		}
 	}
-	read_unlock(&detail->hash_lock);
+	read_unlock(&cd->hash_lock);
 	/* Didn't find anything, insert an empty entry */
 
-	new = detail->alloc();
+	new = cd->alloc();
 	if (!new)
 		return NULL;
 	/* must fully initialise 'new', else
@@ -76,32 +76,32 @@ struct cache_head *sunrpc_cache_lookup(s
 	 * cache_put it soon.
 	 */
 	cache_init(new);
-	detail->init(new, key);
+	cd->init(new, key);
 
-	write_lock(&detail->hash_lock);
+	write_lock(&cd->hash_lock);
 
 	/* check if entry appeared while we slept */
 	for (hp=head; *hp != NULL ; hp = &(*hp)->next) {
 		struct cache_head *tmp = *hp;
-		if (detail->match(tmp, key)) {
+		if (cd->match(tmp, key)) {
 			cache_get(tmp);
-			write_unlock(&detail->hash_lock);
-			cache_put(new, detail);
+			write_unlock(&cd->hash_lock);
+			cache_put(new, cd);
 			return tmp;
 		}
 	}
 	new->next = *head;
 	*head = new;
-	detail->entries++;
+	cd->entries++;
 	cache_get(new);
-	write_unlock(&detail->hash_lock);
+	write_unlock(&cd->hash_lock);
 
 	return new;
 }
 EXPORT_SYMBOL(sunrpc_cache_lookup);
 
 
-static void queue_loose(struct cache_detail *detail, struct cache_head *ch);
+static void queue_loose(struct cache_detail *cd, struct cache_head *ch);
 
 static int cache_fresh_locked(struct cache_head *head, time_t expiry)
 {
@@ -111,17 +111,17 @@ static int cache_fresh_locked(struct cac
 }
 
 static void cache_fresh_unlocked(struct cache_head *head,
-			struct cache_detail *detail, int new)
+			struct cache_detail *cd, int new)
 {
 	if (new)
 		cache_revisit_request(head);
 	if (test_and_clear_bit(CACHE_PENDING, &head->flags)) {
 		cache_revisit_request(head);
-		queue_loose(detail, head);
+		queue_loose(cd, head);
 	}
 }
 
-struct cache_head *sunrpc_cache_update(struct cache_detail *detail,
+struct cache_head *sunrpc_cache_update(struct cache_detail *cd,
 				       struct cache_head *new, struct cache_head *old, int hash)
 {
 	/* The 'old' entry is to be replaced by 'new'.
@@ -133,49 +133,49 @@ struct cache_head *sunrpc_cache_update(s
 	int is_new;
 
 	if (!test_bit(CACHE_VALID, &old->flags)) {
-		write_lock(&detail->hash_lock);
+		write_lock(&cd->hash_lock);
 		if (!test_bit(CACHE_VALID, &old->flags)) {
 			if (test_bit(CACHE_NEGATIVE, &new->flags))
 				set_bit(CACHE_NEGATIVE, &old->flags);
 			else
-				detail->update(old, new);
+				cd->update(old, new);
 			is_new = cache_fresh_locked(old, new->expiry_time);
-			write_unlock(&detail->hash_lock);
-			cache_fresh_unlocked(old, detail, is_new);
+			write_unlock(&cd->hash_lock);
+			cache_fresh_unlocked(old, cd, is_new);
 			return old;
 		}
-		write_unlock(&detail->hash_lock);
+		write_unlock(&cd->hash_lock);
 	}
 	/* We need to insert a new entry */
-	tmp = detail->alloc();
+	tmp = cd->alloc();
 	if (!tmp) {
-		cache_put(old, detail);
+		cache_put(old, cd);
 		return NULL;
 	}
 	cache_init(tmp);
-	detail->init(tmp, old);
-	head = &detail->hash_table[hash];
+	cd->init(tmp, old);
+	head = &cd->hash_table[hash];
 
-	write_lock(&detail->hash_lock);
+	write_lock(&cd->hash_lock);
 	if (test_bit(CACHE_NEGATIVE, &new->flags))
 		set_bit(CACHE_NEGATIVE, &tmp->flags);
 	else
-		detail->update(tmp, new);
+		cd->update(tmp, new);
 	tmp->next = *head;
 	*head = tmp;
-	detail->entries++;
+	cd->entries++;
 	cache_get(tmp);
 	is_new = cache_fresh_locked(tmp, new->expiry_time);
 	cache_fresh_locked(old, 0);
-	write_unlock(&detail->hash_lock);
-	cache_fresh_unlocked(tmp, detail, is_new);
-	cache_fresh_unlocked(old, detail, 0);
-	cache_put(old, detail);
+	write_unlock(&cd->hash_lock);
+	cache_fresh_unlocked(tmp, cd, is_new);
+	cache_fresh_unlocked(old, cd, 0);
+	cache_put(old, cd);
 	return tmp;
 }
 EXPORT_SYMBOL(sunrpc_cache_update);
 
-static int cache_make_upcall(struct cache_detail *detail, struct cache_head *h);
+static int cache_make_upcall(struct cache_detail *cd, struct cache_head *h);
 /*
  * This is the generic cache management routine for all
  * the authentication caches.
@@ -188,7 +188,7 @@ static int cache_make_upcall(struct cach
  * -ETIMEDOUT if upcall failed and should be retried,
  * -ENOENT if cache entry was negative
  */
-int cache_check(struct cache_detail *detail,
+int cache_check(struct cache_detail *cd,
 		    struct cache_head *h, struct cache_req *rqstp)
 {
 	int rv;
@@ -198,7 +198,7 @@ int cache_check(struct cache_detail *det
 	if (!test_bit(CACHE_VALID, &h->flags) ||
 	    h->expiry_time < get_seconds())
 		rv = -EAGAIN;
-	else if (detail->flush_time > h->last_refresh)
+	else if (cd->flush_time > h->last_refresh)
 		rv = -EAGAIN;
 	else {
 		/* entry is valid */
@@ -218,12 +218,12 @@ int cache_check(struct cache_detail *det
 		dprintk("RPC:       Want update, refage=%ld, age=%ld\n",
 				refresh_age, age);
 		if (!test_and_set_bit(CACHE_PENDING, &h->flags)) {
-			switch (cache_make_upcall(detail, h)) {
+			switch (cache_make_upcall(cd, h)) {
 			case -EINVAL:
 				clear_bit(CACHE_PENDING, &h->flags);
 				if (rv == -EAGAIN) {
 					set_bit(CACHE_NEGATIVE, &h->flags);
-					cache_fresh_unlocked(h, detail,
+					cache_fresh_unlocked(h, cd,
 					     cache_fresh_locked(h, get_seconds()+CACHE_NEW_EXPIRY));
 					rv = -ENOENT;
 				}
@@ -242,7 +242,7 @@ int cache_check(struct cache_detail *det
 			rv = -ETIMEDOUT;
 
 	if (rv)
-		cache_put(h, detail);
+		cache_put(h, cd);
 	return rv;
 }
 EXPORT_SYMBOL(cache_check);
@@ -445,7 +445,7 @@ static int cache_clean(void)
 
 	if (current_detail && current_index < current_detail->hash_size) {
 		struct cache_head *ch, **cp;
-		struct cache_detail *d;
+		struct cache_detail *cd;
 
 		write_lock(&current_detail->hash_lock);
 
@@ -473,12 +473,12 @@ static int cache_clean(void)
 			rv = 1;
 		}
 		write_unlock(&current_detail->hash_lock);
-		d = current_detail;
+		cd = current_detail;
 		if (!ch)
 			current_index ++;
 		spin_unlock(&cache_list_lock);
 		if (ch)
-			cache_put(ch, d);
+			cache_put(ch, cd);
 	} else
 		spin_unlock(&cache_list_lock);
 
@@ -516,12 +516,12 @@ void cache_flush(void)
 }
 EXPORT_SYMBOL(cache_flush);
 
-void cache_purge(struct cache_detail *detail)
+void cache_purge(struct cache_detail *cd)
 {
-	detail->flush_time = LONG_MAX;
-	detail->nextcheck = get_seconds();
+	cd->flush_time = LONG_MAX;
+	cd->nextcheck = get_seconds();
 	cache_flush();
-	detail->flush_time = 1;
+	cd->flush_time = 1;
 }
 EXPORT_SYMBOL(cache_purge);
 
@@ -924,11 +924,11 @@ static const struct file_operations cach
 };
 
 
-static void queue_loose(struct cache_detail *detail, struct cache_head *ch)
+static void queue_loose(struct cache_detail *cd, struct cache_head *ch)
 {
 	struct cache_queue *cq;
 	spin_lock(&queue_lock);
-	list_for_each_entry(cq, &detail->queue, list)
+	list_for_each_entry(cq, &cd->queue, list)
 		if (!cq->reader) {
 			struct cache_request *cr = container_of(cq, struct cache_request, q);
 			if (cr->item != ch)
@@ -937,7 +937,7 @@ static void queue_loose(struct cache_det
 				continue;
 			list_del(&cr->q.list);
 			spin_unlock(&queue_lock);
-			cache_put(cr->item, detail);
+			cache_put(cr->item, cd);
 			kfree(cr->buf);
 			kfree(cr);
 			return;
@@ -1019,12 +1019,12 @@ void qword_addhex(char **bpp, int *lp, c
 }
 EXPORT_SYMBOL(qword_addhex);
 
-static void warn_no_listener(struct cache_detail *detail)
+static void warn_no_listener(struct cache_detail *cd)
 {
-	if (detail->last_warn != detail->last_close) {
-		detail->last_warn = detail->last_close;
-		if (detail->warn_no_listener)
-			detail->warn_no_listener(detail);
+	if (cd->last_warn != cd->last_close) {
+		cd->last_warn = cd->last_close;
+		if (cd->warn_no_listener)
+			cd->warn_no_listener(cd);
 	}
 }
 
@@ -1032,7 +1032,7 @@ static void warn_no_listener(struct cach
  * register an upcall request to user-space.
  * Each request is at most one page long.
  */
-static int cache_make_upcall(struct cache_detail *detail, struct cache_head *h)
+static int cache_make_upcall(struct cache_detail *cd, struct cache_head *h)
 {
 
 	char *buf;
@@ -1040,12 +1040,12 @@ static int cache_make_upcall(struct cach
 	char *bp;
 	int len;
 
-	if (detail->cache_request == NULL)
+	if (cd->cache_request == NULL)
 		return -EINVAL;
 
-	if (atomic_read(&detail->readers) == 0 &&
-	    detail->last_close < get_seconds() - 30) {
-			warn_no_listener(detail);
+	if (atomic_read(&cd->readers) == 0 &&
+	    cd->last_close < get_seconds() - 30) {
+			warn_no_listener(cd);
 			return -EINVAL;
 	}
 
@@ -1061,7 +1061,7 @@ static int cache_make_upcall(struct cach
 
 	bp = buf; len = PAGE_SIZE;
 
-	detail->cache_request(detail, h, &bp, &len);
+	cd->cache_request(cd, h, &bp, &len);
 
 	if (len < 0) {
 		kfree(buf);
@@ -1074,7 +1074,7 @@ static int cache_make_upcall(struct cach
 	crq->len = PAGE_SIZE - len;
 	crq->readers = 0;
 	spin_lock(&queue_lock);
-	list_add_tail(&crq->q.list, &detail->queue);
+	list_add_tail(&crq->q.list, &cd->queue);
 	spin_unlock(&queue_lock);
 	wake_up(&queue_wait);
 	return 0;

--
-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

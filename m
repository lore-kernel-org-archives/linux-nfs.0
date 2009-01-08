From: Greg Banks <gnb@sgi.com>
Subject: [patch 02/14] sunrpc: Use consistent naming for variables of type struct cache_head*
Date: Thu, 08 Jan 2009 19:25:12 +1100
Message-ID: <20090108082602.800094000@sgi.com>
References: <20090108082510.050854000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:50380 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753388AbZAHI0L (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 03:26:11 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This makes the cache code easier to read.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 net/sunrpc/cache.c |  100 +++++++++++++++++++++---------------------
 1 file changed, 50 insertions(+), 50 deletions(-)

Index: bfields/net/sunrpc/cache.c
===================================================================
--- bfields.orig/net/sunrpc/cache.c
+++ bfields/net/sunrpc/cache.c
@@ -34,8 +34,8 @@
 
 #define	 RPCDBG_FACILITY RPCDBG_CACHE
 
-static int cache_defer_req(struct cache_req *req, struct cache_head *item);
-static void cache_revisit_request(struct cache_head *item);
+static int cache_defer_req(struct cache_req *req, struct cache_head *h);
+static void cache_revisit_request(struct cache_head *h);
 
 static void cache_init(struct cache_head *h)
 {
@@ -101,23 +101,23 @@ struct cache_head *sunrpc_cache_lookup(s
 EXPORT_SYMBOL(sunrpc_cache_lookup);
 
 
-static void queue_loose(struct cache_detail *cd, struct cache_head *ch);
+static void queue_loose(struct cache_detail *cd, struct cache_head *h);
 
-static int cache_fresh_locked(struct cache_head *head, time_t expiry)
+static int cache_fresh_locked(struct cache_head *h, time_t expiry)
 {
-	head->expiry_time = expiry;
-	head->last_refresh = get_seconds();
-	return !test_and_set_bit(CACHE_VALID, &head->flags);
+	h->expiry_time = expiry;
+	h->last_refresh = get_seconds();
+	return !test_and_set_bit(CACHE_VALID, &h->flags);
 }
 
-static void cache_fresh_unlocked(struct cache_head *head,
+static void cache_fresh_unlocked(struct cache_head *h,
 			struct cache_detail *cd, int new)
 {
 	if (new)
-		cache_revisit_request(head);
-	if (test_and_clear_bit(CACHE_PENDING, &head->flags)) {
-		cache_revisit_request(head);
-		queue_loose(cd, head);
+		cache_revisit_request(h);
+	if (test_and_clear_bit(CACHE_PENDING, &h->flags)) {
+		cache_revisit_request(h);
+		queue_loose(cd, h);
 	}
 }
 
@@ -444,7 +444,7 @@ static int cache_clean(void)
 	/* find a cleanable entry in the bucket and clean it, or set to next bucket */
 
 	if (current_detail && current_index < current_detail->hash_size) {
-		struct cache_head *ch, **cp;
+		struct cache_head *h, **cp;
 		struct cache_detail *cd;
 
 		write_lock(&current_detail->hash_lock);
@@ -452,33 +452,33 @@ static int cache_clean(void)
 		/* Ok, now to clean this strand */
 
 		cp = & current_detail->hash_table[current_index];
-		ch = *cp;
-		for (; ch; cp= & ch->next, ch= *cp) {
-			if (current_detail->nextcheck > ch->expiry_time)
-				current_detail->nextcheck = ch->expiry_time+1;
-			if (ch->expiry_time >= get_seconds()
-			    && ch->last_refresh >= current_detail->flush_time
+		h = *cp;
+		for (; h; cp= & h->next, h= *cp) {
+			if (current_detail->nextcheck > h->expiry_time)
+				current_detail->nextcheck = h->expiry_time+1;
+			if (h->expiry_time >= get_seconds()
+			    && h->last_refresh >= current_detail->flush_time
 				)
 				continue;
-			if (test_and_clear_bit(CACHE_PENDING, &ch->flags))
-				queue_loose(current_detail, ch);
+			if (test_and_clear_bit(CACHE_PENDING, &h->flags))
+				queue_loose(current_detail, h);
 
-			if (atomic_read(&ch->ref.refcount) == 1)
+			if (atomic_read(&h->ref.refcount) == 1)
 				break;
 		}
-		if (ch) {
-			*cp = ch->next;
-			ch->next = NULL;
+		if (h) {
+			*cp = h->next;
+			h->next = NULL;
 			current_detail->entries--;
 			rv = 1;
 		}
 		write_unlock(&current_detail->hash_lock);
 		cd = current_detail;
-		if (!ch)
+		if (!h)
 			current_index ++;
 		spin_unlock(&cache_list_lock);
-		if (ch)
-			cache_put(ch, cd);
+		if (h)
+			cache_put(h, cd);
 	} else
 		spin_unlock(&cache_list_lock);
 
@@ -551,10 +551,10 @@ static LIST_HEAD(cache_defer_list);
 static struct list_head cache_defer_hash[DFR_HASHSIZE];
 static int cache_defer_cnt;
 
-static int cache_defer_req(struct cache_req *req, struct cache_head *item)
+static int cache_defer_req(struct cache_req *req, struct cache_head *h)
 {
 	struct cache_deferred_req *dreq;
-	int hash = DFR_HASH(item);
+	int hash = DFR_HASH(h);
 
 	if (cache_defer_cnt >= DFR_MAX) {
 		/* too much in the cache, randomly drop this one,
@@ -567,7 +567,7 @@ static int cache_defer_req(struct cache_
 	if (dreq == NULL)
 		return -ETIMEDOUT;
 
-	dreq->item = item;
+	dreq->item = h;
 
 	spin_lock(&cache_defer_lock);
 
@@ -592,20 +592,20 @@ static int cache_defer_req(struct cache_
 		/* there was one too many */
 		dreq->revisit(dreq, 1);
 	}
-	if (!test_bit(CACHE_PENDING, &item->flags)) {
+	if (!test_bit(CACHE_PENDING, &h->flags)) {
 		/* must have just been validated... */
-		cache_revisit_request(item);
+		cache_revisit_request(h);
 	}
 	return 0;
 }
 
-static void cache_revisit_request(struct cache_head *item)
+static void cache_revisit_request(struct cache_head *h)
 {
 	struct cache_deferred_req *dreq;
 	struct list_head pending;
 
 	struct list_head *lp;
-	int hash = DFR_HASH(item);
+	int hash = DFR_HASH(h);
 
 	INIT_LIST_HEAD(&pending);
 	spin_lock(&cache_defer_lock);
@@ -615,7 +615,7 @@ static void cache_revisit_request(struct
 		while (lp != &cache_defer_hash[hash]) {
 			dreq = list_entry(lp, struct cache_deferred_req, hash);
 			lp = lp->next;
-			if (dreq->item == item) {
+			if (dreq->item == h) {
 				list_del(&dreq->hash);
 				list_move(&dreq->recent, &pending);
 				cache_defer_cnt--;
@@ -924,14 +924,14 @@ static const struct file_operations cach
 };
 
 
-static void queue_loose(struct cache_detail *cd, struct cache_head *ch)
+static void queue_loose(struct cache_detail *cd, struct cache_head *h)
 {
 	struct cache_queue *cq;
 	spin_lock(&queue_lock);
 	list_for_each_entry(cq, &cd->queue, list)
 		if (!cq->reader) {
 			struct cache_request *cr = container_of(cq, struct cache_request, q);
-			if (cr->item != ch)
+			if (cr->item != h)
 				continue;
 			if (cr->readers != 0)
 				continue;
@@ -1159,7 +1159,7 @@ static void *c_start(struct seq_file *m,
 {
 	loff_t n = *pos;
 	unsigned hash, entry;
-	struct cache_head *ch;
+	struct cache_head *h;
 	struct cache_detail *cd = ((struct handle*)m->private)->cd;
 
 
@@ -1169,9 +1169,9 @@ static void *c_start(struct seq_file *m,
 	hash = n >> 32;
 	entry = n & ((1LL<<32) - 1);
 
-	for (ch=cd->hash_table[hash]; ch; ch=ch->next)
+	for (h=cd->hash_table[hash]; h; h=h->next)
 		if (!entry--)
-			return ch;
+			return h;
 	n &= ~((1LL<<32) - 1);
 	do {
 		hash++;
@@ -1186,18 +1186,18 @@ static void *c_start(struct seq_file *m,
 
 static void *c_next(struct seq_file *m, void *p, loff_t *pos)
 {
-	struct cache_head *ch = p;
+	struct cache_head *h = p;
 	int hash = (*pos >> 32);
 	struct cache_detail *cd = ((struct handle*)m->private)->cd;
 
 	if (p == SEQ_START_TOKEN)
 		hash = 0;
-	else if (ch->next == NULL) {
+	else if (h->next == NULL) {
 		hash++;
 		*pos += 1LL<<32;
 	} else {
 		++*pos;
-		return ch->next;
+		return h->next;
 	}
 	*pos &= ~((1LL<<32) - 1);
 	while (hash < cd->hash_size &&
@@ -1220,7 +1220,7 @@ static void c_stop(struct seq_file *m, v
 
 static int c_show(struct seq_file *m, void *p)
 {
-	struct cache_head *cp = p;
+	struct cache_head *h = p;
 	struct cache_detail *cd = ((struct handle*)m->private)->cd;
 
 	if (p == SEQ_START_TOKEN)
@@ -1228,15 +1228,15 @@ static int c_show(struct seq_file *m, vo
 
 	ifdebug(CACHE)
 		seq_printf(m, "# expiry=%ld refcnt=%d flags=%lx\n",
-			   cp->expiry_time, atomic_read(&cp->ref.refcount), cp->flags);
-	cache_get(cp);
-	if (cache_check(cd, cp, NULL))
+			   h->expiry_time, atomic_read(&h->ref.refcount), h->flags);
+	cache_get(h);
+	if (cache_check(cd, h, NULL))
 		/* cache_check does a cache_put on failure */
 		seq_printf(m, "# ");
 	else
-		cache_put(cp, cd);
+		cache_put(h, cd);
 
-	return cd->cache_show(m, cd, cp);
+	return cd->cache_show(m, cd, h);
 }
 
 static const struct seq_operations cache_content_op = {

--
-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

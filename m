Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:42189 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752375Ab0HLG4O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Aug 2010 02:56:14 -0400
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Thu, 12 Aug 2010 16:55:22 +1000
Subject: [PATCH 2/2] sunrpc: use monotonic time in expiry cache
Cc: linux-nfs@vger.kernel.org
Message-ID: <20100812065522.3408.25500.stgit@localhost.localdomain>
In-Reply-To: <20100812064957.3408.44224.stgit@localhost.localdomain>
References: <20100812064957.3408.44224.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

this protects us from confusion when the wallclock time changes.

We convert to and from wallclock when  setting or reading expiry
times.

Also use monotonic_seconds for last_clost time.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfs/dns_resolve.c         |    6 +++---
 fs/nfsd/nfs4idmap.c          |    2 +-
 include/linux/sunrpc/cache.h |   21 ++++++++++++++++++---
 net/sunrpc/cache.c           |   37 ++++++++++++++++++++-----------------
 4 files changed, 42 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
index 76fd235..3e6aab2 100644
--- a/fs/nfs/dns_resolve.c
+++ b/fs/nfs/dns_resolve.c
@@ -144,7 +144,7 @@ static int nfs_dns_show(struct seq_file *m, struct cache_detail *cd,
 		return 0;
 	}
 	item = container_of(h, struct nfs_dns_ent, h);
-	ttl = (long)item->h.expiry_time - (long)get_seconds();
+	ttl = item->h.expiry_time - monotonic_seconds();
 	if (ttl < 0)
 		ttl = 0;
 
@@ -216,7 +216,7 @@ static int nfs_dns_parse(struct cache_detail *cd, char *buf, int buflen)
 	ttl = get_expiry(&buf);
 	if (ttl == 0)
 		goto out;
-	key.h.expiry_time = ttl + get_seconds();
+	key.h.expiry_time = ttl + monotonic_seconds();
 
 	ret = -ENOMEM;
 	item = nfs_dns_lookup(cd, &key);
@@ -278,7 +278,7 @@ static int do_cache_lookup_nowait(struct cache_detail *cd,
 		goto out_err;
 	ret = -ETIMEDOUT;
 	if (!test_bit(CACHE_VALID, &(*item)->h.flags)
-			|| (*item)->h.expiry_time < get_seconds()
+			|| (*item)->h.expiry_time < monotonic_seconds()
 			|| cd->flush_time > (*item)->h.last_refresh)
 		goto out_put;
 	ret = -ENOENT;
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index c78dbf4..6031a90 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -550,7 +550,7 @@ do_idmap_lookup_nowait(struct ent *(*lookup_fn)(struct ent *),
 		goto out_err;
 	ret = -ETIMEDOUT;
 	if (!test_bit(CACHE_VALID, &(*item)->h.flags)
-			|| (*item)->h.expiry_time < get_seconds()
+			|| (*item)->h.expiry_time < monotonic_seconds()
 			|| detail->flush_time > (*item)->h.last_refresh)
 		goto out_put;
 	ret = -ENOENT;
diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 0e1febf..df7c19b 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -218,20 +218,35 @@ static inline int get_int(char **bpp, int *anint)
 	return 0;
 }
 
+/*
+ * timestamps kept in the cache are expressed in seconds
+ * since boot.  This is the best for measuring differences in
+ * real time.
+ */
+static inline time_t monotonic_seconds(void)
+{
+	struct timespec boot;
+	getboottime(&boot);
+	return get_seconds() - boot.tv_sec;
+}
+
 static inline time_t get_expiry(char **bpp)
 {
 	int rv;
+	struct timespec boot;
+
 	if (get_int(bpp, &rv))
 		return 0;
 	if (rv < 0)
 		return 0;
-	return rv;
+	getboottime(&boot);
+	return rv - boot.tv_sec;
 }
 
 static inline void sunrpc_invalidate(struct cache_head *h,
 				     struct cache_detail *detail)
 {
-	h->expiry_time = get_seconds() - 1;
-	detail->nextcheck = get_seconds();
+	h->expiry_time = monotonic_seconds() - 1;
+	detail->nextcheck = monotonic_seconds();
 }
 #endif /*  _LINUX_SUNRPC_CACHE_H_ */
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 2b06410..99d852e 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -42,7 +42,7 @@ static void cache_revisit_request(struct cache_head *item);
 
 static void cache_init(struct cache_head *h)
 {
-	time_t now = get_seconds();
+	time_t now = monotonic_seconds();
 	h->next = NULL;
 	h->flags = 0;
 	kref_init(&h->ref);
@@ -52,7 +52,7 @@ static void cache_init(struct cache_head *h)
 
 static inline int cache_is_expired(struct cache_detail *detail, struct cache_head *h)
 {
-	return  (h->expiry_time < get_seconds()) ||
+	return  (h->expiry_time < monotonic_seconds()) ||
 		(detail->flush_time > h->last_refresh);
 }
 
@@ -127,7 +127,7 @@ static void cache_dequeue(struct cache_detail *detail, struct cache_head *ch);
 static void cache_fresh_locked(struct cache_head *head, time_t expiry)
 {
 	head->expiry_time = expiry;
-	head->last_refresh = get_seconds();
+	head->last_refresh = monotonic_seconds();
 	set_bit(CACHE_VALID, &head->flags);
 }
 
@@ -238,7 +238,7 @@ int cache_check(struct cache_detail *detail,
 
 	/* now see if we want to start an upcall */
 	refresh_age = (h->expiry_time - h->last_refresh);
-	age = get_seconds() - h->last_refresh;
+	age = monotonic_seconds() - h->last_refresh;
 
 	if (rqstp == NULL) {
 		if (rv == -EAGAIN)
@@ -253,7 +253,7 @@ int cache_check(struct cache_detail *detail,
 				cache_revisit_request(h);
 				if (rv == -EAGAIN) {
 					set_bit(CACHE_NEGATIVE, &h->flags);
-					cache_fresh_locked(h, get_seconds()+CACHE_NEW_EXPIRY);
+					cache_fresh_locked(h, monotonic_seconds()+CACHE_NEW_EXPIRY);
 					cache_fresh_unlocked(h, detail);
 					rv = -ENOENT;
 				}
@@ -388,11 +388,11 @@ static int cache_clean(void)
 			return -1;
 		}
 		current_detail = list_entry(next, struct cache_detail, others);
-		if (current_detail->nextcheck > get_seconds())
+		if (current_detail->nextcheck > monotonic_seconds())
 			current_index = current_detail->hash_size;
 		else {
 			current_index = 0;
-			current_detail->nextcheck = get_seconds()+30*60;
+			current_detail->nextcheck = monotonic_seconds()+30*60;
 		}
 	}
 
@@ -477,7 +477,7 @@ EXPORT_SYMBOL_GPL(cache_flush);
 void cache_purge(struct cache_detail *detail)
 {
 	detail->flush_time = LONG_MAX;
-	detail->nextcheck = get_seconds();
+	detail->nextcheck = monotonic_seconds();
 	cache_flush();
 	detail->flush_time = 1;
 }
@@ -902,7 +902,7 @@ static int cache_release(struct inode *inode, struct file *filp,
 		filp->private_data = NULL;
 		kfree(rp);
 
-		cd->last_close = get_seconds();
+		cd->last_close = monotonic_seconds();
 		atomic_dec(&cd->readers);
 	}
 	module_put(cd->owner);
@@ -1034,7 +1034,7 @@ int sunrpc_cache_pipe_upcall(struct cache_detail *detail, struct cache_head *h,
 	int len;
 
 	if (atomic_read(&detail->readers) == 0 &&
-	    detail->last_close < get_seconds() - 30) {
+	    detail->last_close < monotonic_seconds() - 30) {
 			warn_no_listener(detail);
 			return -EINVAL;
 	}
@@ -1219,7 +1219,8 @@ static int c_show(struct seq_file *m, void *p)
 
 	ifdebug(CACHE)
 		seq_printf(m, "# expiry=%ld refcnt=%d flags=%lx\n",
-			   cp->expiry_time, atomic_read(&cp->ref.refcount), cp->flags);
+			   cp->expiry_time - monotonic_seconds() + get_seconds(),
+			   atomic_read(&cp->ref.refcount), cp->flags);
 	cache_get(cp);
 	if (cache_check(cd, cp, NULL))
 		/* cache_check does a cache_put on failure */
@@ -1285,7 +1286,8 @@ static ssize_t read_flush(struct file *file, char __user *buf,
 	unsigned long p = *ppos;
 	size_t len;
 
-	sprintf(tbuf, "%lu\n", cd->flush_time);
+	sprintf(tbuf, "%lu\n", (cd->flush_time - monotonic_seconds()
+				+ get_seconds()));
 	len = strlen(tbuf);
 	if (p >= len)
 		return 0;
@@ -1303,19 +1305,20 @@ static ssize_t write_flush(struct file *file, const char __user *buf,
 			   struct cache_detail *cd)
 {
 	char tbuf[20];
-	char *ep;
-	long flushtime;
+	char *bp, *ep;
+
 	if (*ppos || count > sizeof(tbuf)-1)
 		return -EINVAL;
 	if (copy_from_user(tbuf, buf, count))
 		return -EFAULT;
 	tbuf[count] = 0;
-	flushtime = simple_strtoul(tbuf, &ep, 0);
+	simple_strtoul(tbuf, &ep, 0);
 	if (*ep && *ep != '\n')
 		return -EINVAL;
 
-	cd->flush_time = flushtime;
-	cd->nextcheck = get_seconds();
+	bp = tbuf;
+	cd->flush_time = get_expiry(&bp);
+	cd->nextcheck = monotonic_seconds();
 	cache_flush();
 
 	*ppos += count;



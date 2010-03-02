From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 2/2] sunrpc: use monotonic time in expiry cache
Date: Tue, 2 Mar 2010 15:11:54 +1100
Message-ID: <20100302151154.34004e55@notabene.brown>
References: <20100217064330.13656.61404.stgit@notabene.brown>
	<20100217064730.13656.67205.stgit@notabene.brown>
	<4B7C6701.7070408@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:48714 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751690Ab0CBEME convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Mar 2010 23:12:04 -0500
In-Reply-To: <4B7C6701.7070408@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 17 Feb 2010 17:00:33 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:


> > +/*
> > + * timestamps kept in the cache are expressed in seconds
> > + * since boot.  This is the best for measuring differences in
> > + * real time.
> > + */
> > +static inline unsigned long monotonic_seconds(void)
> 
> I find the alternate use of long, unsigned long, and time_t for fields, 
> variables, and return values that represent time in seconds to be 
> confusing.  Would it be nicer if we stuck with one type, say, time_t, 
> for all of these?

Probably it would...
I think arch's can change it, but the default is that __kernel_time_t is
'long', and so is 'time_t'.
But "get_seconds()" is 'unsigned long'.  No idea why.

You could propose a patch to linux-kernel??

I'll change monotonic_seconds to return time_t, so we can get ride
of the casts in  dns_resolve.c, but I'm not up to trying to push
a broader fix.


> 
> That would at least avoid mixed sign comparisons where the return value 
> of get_seconds or monotonic_seconds is directly compared to fields in 
> the cache_head structure.  It might also simplify the ttl logic above in 
> the DNS lookup cache.
> 
> I've always wondered if the expiry math behaves correctly when seconds 
> wrap.  It hurts my head when I try to prove it is correct.

Seconds shouldn't wrap - or I suspect many more things will go wrong than
just expiry.
Any 32-bit hosts still running in 2038 might have problems, but I wouldn't
be surprised if even phones are 64-bit by then (making it easier to handle
IPv6 :-)



> > @@ -1207,7 +1207,8 @@ static int c_show(struct seq_file *m, void *p)
> >
> >   	ifdebug(CACHE)
> >   		seq_printf(m, "# expiry=%ld refcnt=%d flags=%lx\n",
> > -			   cp->expiry_time, atomic_read(&cp->ref.refcount), cp->flags);
> > +			   cp->expiry_time - monotonic_seconds() + get_seconds(),
> 
> I see this calculation in at least one other spot.  Maybe it would be 
> more clear if a helper was used.

Maybe .. there are only two places, and I don't think a helper would really
simplify it that much... sometimes I prefer things to be open coded so that I
can see exactly what is happening when I read the code.


> cache_check() still has a call to get_seconds() at about line 240; maybe 
> that should be monotonic_seconds() instead.
> 

Yes, you are right.  There is a reason why that one was left unchanged, but
it was only relevant in a previous iteration of the patch.

Thanks!
Revised version follows.

NeilBrown



>From 2e736c816e68580f4555a974508c258b82796873 Mon Sep 17 00:00:00 2001
From: NeilBrown <neilb@suse.de>
Date: Wed, 17 Feb 2010 16:35:36 +1100
Subject: [PATCH] sunrpc: use monotonic time in expiry cache

this protects us from confusion when the wallclock time changes.

We convert to and from wallclock when  setting or reading expiry
times.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
index 95e1ca7..9a0b7ad 100644
--- a/fs/nfs/dns_resolve.c
+++ b/fs/nfs/dns_resolve.c
@@ -131,7 +131,7 @@ static int nfs_dns_show(struct seq_file *m, struct cache_detail *cd,
 		return 0;
 	}
 	item = container_of(h, struct nfs_dns_ent, h);
-	ttl = (long)item->h.expiry_time - (long)get_seconds();
+	ttl = item->h.expiry_time - monotonic_seconds();
 	if (ttl < 0)
 		ttl = 0;
 
@@ -203,7 +203,7 @@ static int nfs_dns_parse(struct cache_detail *cd, char *buf, int buflen)
 	ttl = get_expiry(&buf);
 	if (ttl == 0)
 		goto out;
-	key.h.expiry_time = ttl + get_seconds();
+	key.h.expiry_time = ttl + monotonic_seconds();
 
 	ret = -ENOMEM;
 	item = nfs_dns_lookup(cd, &key);
@@ -265,7 +265,7 @@ static int do_cache_lookup_nowait(struct cache_detail *cd,
 		goto out_err;
 	ret = -ETIMEDOUT;
 	if (!test_bit(CACHE_VALID, &(*item)->h.flags)
-			|| (*item)->h.expiry_time < get_seconds()
+			|| (*item)->h.expiry_time < monotonic_seconds()
 			|| cd->flush_time > (*item)->h.last_refresh)
 		goto out_put;
 	ret = -ENOENT;
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index 6e2983b..8f5cc77 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -549,7 +549,7 @@ do_idmap_lookup_nowait(struct ent *(*lookup_fn)(struct ent *),
 		goto out_err;
 	ret = -ETIMEDOUT;
 	if (!test_bit(CACHE_VALID, &(*item)->h.flags)
-			|| (*item)->h.expiry_time < get_seconds()
+			|| (*item)->h.expiry_time < monotonic_seconds()
 			|| detail->flush_time > (*item)->h.last_refresh)
 		goto out_put;
 	ret = -ENOENT;
diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index e41ee6d..dbd11e0 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -217,20 +217,35 @@ static inline int get_int(char **bpp, int *anint)
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
index 39bddba..6818dc3 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -41,7 +41,7 @@ static void cache_revisit_request(struct cache_head *item);
 
 static void cache_init(struct cache_head *h)
 {
-	time_t now = get_seconds();
+	time_t now = monotonic_seconds();
 	h->next = NULL;
 	h->flags = 0;
 	kref_init(&h->ref);
@@ -108,7 +108,7 @@ static void cache_dequeue(struct cache_detail *detail, struct cache_head *ch);
 static void cache_fresh_locked(struct cache_head *head, time_t expiry)
 {
 	head->expiry_time = expiry;
-	head->last_refresh = get_seconds();
+	head->last_refresh = monotonic_seconds();
 	set_bit(CACHE_VALID, &head->flags);
 }
 
@@ -184,7 +184,7 @@ static int cache_make_upcall(struct cache_detail *cd, struct cache_head *h)
 static inline int cache_is_valid(struct cache_detail *detail, struct cache_head *h)
 {
 	if (!test_bit(CACHE_VALID, &h->flags) ||
-	    h->expiry_time < get_seconds())
+	    h->expiry_time < monotonic_seconds())
 		return -EAGAIN;
 	else if (detail->flush_time > h->last_refresh)
 		return -EAGAIN;
@@ -222,7 +222,7 @@ int cache_check(struct cache_detail *detail,
 
 	/* now see if we want to start an upcall */
 	refresh_age = (h->expiry_time - h->last_refresh);
-	age = get_seconds() - h->last_refresh;
+	age = monotonic_seconds() - h->last_refresh;
 
 	if (rqstp == NULL) {
 		if (rv == -EAGAIN)
@@ -237,7 +237,7 @@ int cache_check(struct cache_detail *detail,
 				cache_revisit_request(h);
 				if (rv == -EAGAIN) {
 					set_bit(CACHE_NEGATIVE, &h->flags);
-					cache_fresh_locked(h, get_seconds()+CACHE_NEW_EXPIRY);
+					cache_fresh_locked(h, monotonic_seconds()+CACHE_NEW_EXPIRY);
 					cache_fresh_unlocked(h, detail);
 					rv = -ENOENT;
 				}
@@ -372,11 +372,11 @@ static int cache_clean(void)
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
 
@@ -401,7 +401,7 @@ static int cache_clean(void)
 		for (; ch; cp= & ch->next, ch= *cp) {
 			if (current_detail->nextcheck > ch->expiry_time)
 				current_detail->nextcheck = ch->expiry_time+1;
-			if (ch->expiry_time >= get_seconds() &&
+			if (ch->expiry_time >= monotonic_seconds() &&
 			    ch->last_refresh >= current_detail->flush_time)
 				continue;
 			if (test_and_clear_bit(CACHE_PENDING, &ch->flags))
@@ -465,7 +465,7 @@ EXPORT_SYMBOL_GPL(cache_flush);
 void cache_purge(struct cache_detail *detail)
 {
 	detail->flush_time = LONG_MAX;
-	detail->nextcheck = get_seconds();
+	detail->nextcheck = monotonic_seconds();
 	cache_flush();
 	detail->flush_time = 1;
 }
@@ -1207,7 +1207,8 @@ static int c_show(struct seq_file *m, void *p)
 
 	ifdebug(CACHE)
 		seq_printf(m, "# expiry=%ld refcnt=%d flags=%lx\n",
-			   cp->expiry_time, atomic_read(&cp->ref.refcount), cp->flags);
+			   cp->expiry_time - monotonic_seconds() + get_seconds(),
+			   atomic_read(&cp->ref.refcount), cp->flags);
 	cache_get(cp);
 	if (cache_check(cd, cp, NULL))
 		/* cache_check does a cache_put on failure */
@@ -1271,7 +1272,8 @@ static ssize_t read_flush(struct file *file, char __user *buf,
 	unsigned long p = *ppos;
 	size_t len;
 
-	sprintf(tbuf, "%lu\n", cd->flush_time);
+	sprintf(tbuf, "%lu\n", (cd->flush_time - monotonic_seconds()
+				+ get_seconds()));
 	len = strlen(tbuf);
 	if (p >= len)
 		return 0;
@@ -1289,19 +1291,20 @@ static ssize_t write_flush(struct file *file, const char __user *buf,
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

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35386 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753432AbbJOGbZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Oct 2015 02:31:25 -0400
From: Neil Brown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Thu, 15 Oct 2015 17:31:16 +1100
Cc: Olaf Kirch <okir@suse.de>, linux-nfs@vger.kernel.org
Subject: [PATCH/RFC] sunrpc/cache: make cache flushing more reliable.
Message-ID: <87fv1cwsln.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


The caches used to store sunrpc authentication information can be
flushed by writing a timestamp to a file in /proc.

This timestamp has a one-second resolution and any entry in cache that
was last_refreshed *before* that time is treated as expired.

This is problematic as it is not possible to reliably flush the cache
without interrupting NFS service.
If the current time is written to the "flush" file, any entry that was
added since the current second started will still be treated as valid.
If one second beyond than the current time is written to the file
then no entries can be valid until the second ticks over.  This will
mean that no NFS request will be handled for up to 1 second.

To resolve this issue we make two changes:

1/ treat an entry as expired if the timestamp when it was last_refreshed
  is before *or the same as* the expiry time.  This means that current
  code which writes out the current time will now flush the cache
  reliably.

2/ when a new entry in added to the cache -  set the last_refresh timestamp
  to 1 second *beyond* the current flush time, when that not in the
  past.
  This ensures that newly added entries will always be valid.


Now that we have a very reliable way to flush the cache, and also
since we are using "since-boot" timestamps which are monotonic,
change cache_purge() to set the smallest future flush_time which
will work, and leave it there: don't revert to '1'.

Also disable the setting of the 'flush_time' far into the future.
That has never been useful and is now awkward as it would cause
last_refresh times to be strange.
Finally: if a request is made to set the 'flush_time' to the current
second, assume the intent is to flush the cache and advance it, if
necessary, to 1 second beyond the current 'flush_time' so that all
active entries will be deemed to be expired.

As part of this we need to add a 'cache_detail' arg to cache_init()
and cache_fresh_locked() so they can find the current ->flush_time.

Signed-off-by: NeilBrown <neilb@suse.com>
Reported-by: Olaf Kirch <okir@suse.com>

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 03d3b4c92d9f..ed03c9f7f908 100644
=2D-- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -48,8 +48,10 @@
 struct cache_head {
 	struct hlist_node	cache_list;
 	time_t		expiry_time;	/* After time time, don't use the data */
=2D	time_t		last_refresh;   /* If CACHE_PENDING, this is when upcall=20
=2D					 * was sent, else this is when update was received
+	time_t		last_refresh;   /* If CACHE_PENDING, this is when upcall was
+					 * sent, else this is when update was
+					 * received, though it is alway set to
+					 * be *after* ->flush_time.
 					 */
 	struct kref	ref;
 	unsigned long	flags;
@@ -105,8 +107,12 @@ struct cache_detail {
 	/* fields below this comment are for internal use
 	 * and should not be touched by cache owners
 	 */
=2D	time_t			flush_time;		/* flush all cache items with last_refresh
=2D							 * earlier than this */
+	time_t			flush_time;		/* flush all cache items with
+							 * last_refresh at or earlier
+							 * than this.  last_refresh
+							 * is never set at or earlier
+							 * than this.
+							 */
 	struct list_head	others;
 	time_t			nextcheck;
 	int			entries;
@@ -203,7 +209,7 @@ static inline void cache_put(struct cache_head *h, stru=
ct cache_detail *cd)
 static inline int cache_is_expired(struct cache_detail *detail, struct cac=
he_head *h)
 {
 	return  (h->expiry_time < seconds_since_boot()) ||
=2D		(detail->flush_time > h->last_refresh);
+		(detail->flush_time >=3D h->last_refresh);
 }
=20
 extern int cache_check(struct cache_detail *detail,
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 4a2340a54401..d220cc36ed2f 100644
=2D-- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -41,13 +41,16 @@
 static bool cache_defer_req(struct cache_req *req, struct cache_head *item=
);
 static void cache_revisit_request(struct cache_head *item);
=20
=2Dstatic void cache_init(struct cache_head *h)
+static void cache_init(struct cache_head *h, struct cache_detail *detail)
 {
 	time_t now =3D seconds_since_boot();
 	INIT_HLIST_NODE(&h->cache_list);
 	h->flags =3D 0;
 	kref_init(&h->ref);
 	h->expiry_time =3D now + CACHE_NEW_EXPIRY;
+	if (now <=3D detail->flush_time)
+		/* ensure it isn't already expired */
+		now =3D detail->flush_time + 1;
 	h->last_refresh =3D now;
 }
=20
@@ -81,7 +84,7 @@ struct cache_head *sunrpc_cache_lookup(struct cache_detai=
l *detail,
 	 * we might get lose if we need to
 	 * cache_put it soon.
 	 */
=2D	cache_init(new);
+	cache_init(new, detail);
 	detail->init(new, key);
=20
 	write_lock(&detail->hash_lock);
@@ -116,10 +119,15 @@ EXPORT_SYMBOL_GPL(sunrpc_cache_lookup);
=20
 static void cache_dequeue(struct cache_detail *detail, struct cache_head *=
ch);
=20
=2Dstatic void cache_fresh_locked(struct cache_head *head, time_t expiry)
+static void cache_fresh_locked(struct cache_head *head, time_t expiry,
+			       struct cache_detail *detail)
 {
+	time_t now =3D seconds_since_boot();
+	if (now <=3D detail->flush_time)
+		/* ensure it isn't immediately treated as expired */
+		now =3D detail->flush_time + 1;
 	head->expiry_time =3D expiry;
=2D	head->last_refresh =3D seconds_since_boot();
+	head->last_refresh =3D now;
 	smp_wmb(); /* paired with smp_rmb() in cache_is_valid() */
 	set_bit(CACHE_VALID, &head->flags);
 }
@@ -149,7 +157,7 @@ struct cache_head *sunrpc_cache_update(struct cache_det=
ail *detail,
 				set_bit(CACHE_NEGATIVE, &old->flags);
 			else
 				detail->update(old, new);
=2D			cache_fresh_locked(old, new->expiry_time);
+			cache_fresh_locked(old, new->expiry_time, detail);
 			write_unlock(&detail->hash_lock);
 			cache_fresh_unlocked(old, detail);
 			return old;
@@ -162,7 +170,7 @@ struct cache_head *sunrpc_cache_update(struct cache_det=
ail *detail,
 		cache_put(old, detail);
 		return NULL;
 	}
=2D	cache_init(tmp);
+	cache_init(tmp, detail);
 	detail->init(tmp, old);
=20
 	write_lock(&detail->hash_lock);
@@ -173,8 +181,8 @@ struct cache_head *sunrpc_cache_update(struct cache_det=
ail *detail,
 	hlist_add_head(&tmp->cache_list, &detail->hash_table[hash]);
 	detail->entries++;
 	cache_get(tmp);
=2D	cache_fresh_locked(tmp, new->expiry_time);
=2D	cache_fresh_locked(old, 0);
+	cache_fresh_locked(tmp, new->expiry_time, detail);
+	cache_fresh_locked(old, 0, detail);
 	write_unlock(&detail->hash_lock);
 	cache_fresh_unlocked(tmp, detail);
 	cache_fresh_unlocked(old, detail);
@@ -219,7 +227,8 @@ static int try_to_negate_entry(struct cache_detail *det=
ail, struct cache_head *h
 	rv =3D cache_is_valid(h);
 	if (rv =3D=3D -EAGAIN) {
 		set_bit(CACHE_NEGATIVE, &h->flags);
=2D		cache_fresh_locked(h, seconds_since_boot()+CACHE_NEW_EXPIRY);
+		cache_fresh_locked(h, seconds_since_boot()+CACHE_NEW_EXPIRY,
+				   detail);
 		rv =3D -ENOENT;
 	}
 	write_unlock(&detail->hash_lock);
@@ -487,10 +496,13 @@ EXPORT_SYMBOL_GPL(cache_flush);
=20
 void cache_purge(struct cache_detail *detail)
 {
=2D	detail->flush_time =3D LONG_MAX;
+	time_t now =3D seconds_since_boot();
+	if (detail->flush_time >=3D now)
+		now =3D detail->flush_time + 1;
+	/* 'now' is the maximum value any 'last_refresh' can have */
+	detail->flush_time =3D now + 1;
 	detail->nextcheck =3D seconds_since_boot();
 	cache_flush();
=2D	detail->flush_time =3D 1;
 }
 EXPORT_SYMBOL_GPL(cache_purge);
=20
@@ -1436,6 +1448,7 @@ static ssize_t write_flush(struct file *file, const c=
har __user *buf,
 {
 	char tbuf[20];
 	char *bp, *ep;
+	time_t then, now;
=20
 	if (*ppos || count > sizeof(tbuf)-1)
 		return -EINVAL;
@@ -1447,8 +1460,22 @@ static ssize_t write_flush(struct file *file, const =
char __user *buf,
 		return -EINVAL;
=20
 	bp =3D tbuf;
=2D	cd->flush_time =3D get_expiry(&bp);
=2D	cd->nextcheck =3D seconds_since_boot();
+	then =3D get_expiry(&bp);
+	now =3D seconds_since_boot();
+	cd->nextcheck =3D now;
+	/* Can only set flush_time to 1 second beyond "now", or
+	 * possibly 1 second beyond flushtime.  This is because
+	 * flush_time never goes backwards so it mustn't get too far
+	 * ahead of time.
+	 */
+	if (then >=3D now) {
+		/* Want to flush everything, so behave like cache_purge() */
+		if (cd->flush_time >=3D now)
+			now =3D cd->flush_time + 1;
+		then =3D now + 1;
+	}
+
+	cd->flush_time =3D then;
 	cache_flush();
=20
 	*ppos +=3D count;

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWH0g0AAoJEDnsnt1WYoG5n/gQAJNT0vraXhNz3J1g3eVooTe5
oWx4R1mfCN1pLyAPCw9DptCRobnU6STfNELnBzWrW+CSkpjITvPmq0yC85VjRyKG
tEra7Fs9TLN6qe2ma6DWZvnALtmdAxhXFcpxUEmsL6Z9jyyMmxunmBsD2pa8jiVa
LQD+MW7AcM4MykQE1N+BAg0zJ/Iefnr87cdjuy7sGbbxulPTKW/dVRHOzBT+Ikl4
af7qEma15Y2rAsA7GpeMteXbo4Xloa4ZexZncqrdUPydugkJXwcIrcW3D/d1YFRc
rkbbf9DQ2ktrPF/IYHze7sJiADuU81bc0Q/81xFznv6Ohoz9RHXQ4voFcR60rKkg
mTgEz7/hGU074uTLzP76ygFmhl2c55Wsa1pXfGEjrWQImiCPO6DGITXmZCbTS1Nw
QoUFigKFogbtBo3195mQAZYtQTtDwKWaqbUW6lTTj0FhZvmhGULc0qSZZ/edqmiQ
pGRXEKIHDPz9WPMY1YBJLnnjDa9/8Y0qK+Nkw0e/X1GmlIFhtHhu5ZgkZ8gQs3Gd
Xnh9A59GCJVCTVXMdT5kUWWjEimHL7x5rCtrXAa9nLvqoN2h5XsTRaUiZBKMIiDY
+o4uHOojEjVgT52xCCOMuz3D5oHFoBJyqFXObKdBZt6Kw0NLnhvrCFQzZDNSyFlL
DuyKKcy/3vwA6PTs3TH4
=k0OE
-----END PGP SIGNATURE-----
--=-=-=--

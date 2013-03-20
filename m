Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:42282 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750763Ab3CTEkL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Mar 2013 00:40:11 -0400
Date: Wed, 20 Mar 2013 15:39:58 +1100
From: NeilBrown <neilb@suse.de>
To: Bodo Stroesser <bstroesser@ts.fujitsu.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: sunrpc/cache.c: races while updating cache entries
Message-ID: <20130320153958.63dc5fe0@notabene.brown>
In-Reply-To: <d6437a$45t6bs@dgate10u.abg.fsc.net>
References: <d6437a$45t6bs@dgate10u.abg.fsc.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/o2tb=Uc7M.YaF=ErJ9VKsCB"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/o2tb=Uc7M.YaF=ErJ9VKsCB
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On 19 Mar 2013 20:58:53 +0100 Bodo Stroesser <bstroesser@ts.fujitsu.com>
wrote:

> On 19 Mar 2013 04:24:00 +0100 NeilBrown <neilb@suse.de> wrote:
>=20
> > On 14 Mar 2013 18:31:38 +0100 Bodo Stroesser <bstroesser@ts.fujitsu.com>
> > wrote:
> >=20
> > > On 13 Mar 2013 07:55:00 +0100 NeilBrown <neilb@suse.de> wrote:
> > >=20
> > > > On 11 Mar 2013 17:13:41 +0100 Bodo Stroesser=20
> > > > <bstroesser@ts.fujitsu.com>
> > > > wrote:
> > > >=20
> > > > > Hi,
> > > > >=20
> > > > > AFAICS, there is one more race in RPC cache.
> > > > >=20
> > > > > The problem showed up for the "auth.unix.ip" cache, that has a=20
> > > > > reader.
> > > > >=20
> > > > > If a server thread tries to find a cache entry, it first does a=20
> > > > > lookup (or calls ip_map_cached_get() in this specific case). Then=
,=20
> > > > > it calls cache_check() for this entry.
> > > > >=20
> > > > > If the reader updates the cache entry just between the thread's=20
> > > > > lookup and cache_check() execution, cache_check() will do an=20
> > > > > upcall for this cache entry. This is, because
> > > > > sunrpc_cache_update() calls cache_fresh_locked(old, 0), which set=
s=20
> > > > > expiry_time to 0.
> > > > >=20
> > > > > Unfortunately, the reply to the upcall will not dequeue the queue=
d=20
> > > > > cache_request, as the reply will be assigned to the cache entry=20
> > > > > newly created by the above cache update.
> > > > >=20
> > > > > The result is a growing queue of orphaned cache_request structure=
s=20
> > > > > --> memory leak.
> > > > >=20
> > > > > I found this on a SLES11 SP1 with a backport of the latest patche=
s=20
> > > > > that fix the other RPC races. On this old kernel, the problem als=
o=20
> > > > > leads to svc_drop() being called for the affected RPC request=20
> > > > > (after svc_defer()).
> > > > >=20
> > > > > Best Regards
> > > > > Bodo
> > > >=20
> > > > I don't think this is a real problem.
> > > > The periodic call to "cache_clean" should find these orphaned=20
> > > > requests and purge them.  So you could get a short term memory leak=
,=20
> > > > but it should correct itself.
> > > > Do you agree?
> > > >=20
> > > > Thanks,
> > > > NeilBrown
> > >=20
> > > Meanwhile I found the missing part of the race!
> > >=20
> > > It's just what I wrote above but additionally, immediately after the=
=20
> > > reader updated the cache, cache_clean() unhashes the old cache entry.=
=20
> > > In that case:
> > > 1) the thread will queue a request for a cache entry, that isn't
> > >    in the hash lists.
> > > 2) cache_clean() never will access this old cache entry again
> > > 3) every further cache update will call cache_dequeue() for a newer
> > >    cache entry, the request is never dequeued
> > >=20
> > > --> memory leak.
> >=20
> > Yes, I see that now.  Thanks.
> >=20
> > I suspect that bug was introduced by commit 3af4974eb2c7867d6e16.
> > Prior to then, cache_clean would never remove anything with an active r=
eference.  If something was about to get CACHE_PENDING, it would have a ref=
erence so cache_clean would leave it alone.
> >=20
> > I wanted to fix this by getting the last 'put' to call cache_dequeue() =
if CACHE_PENDING was still set.  However I couldn't get access to the CACHE=
_PENDING flag and the cache_detail at the same place - so I gave up on that.
> >=20
> > The patch I have included below sets a flag when an cache item is remov=
ed from the cache (by cache_clean) and refuses to lodge an upcall if the fl=
ag is set.  That will ensure there is never a pending upcall when the item =
is finally freed.
> >=20
> > You patch only addresses the particular situation that you had found.  =
I think it is possible that there might be other situations that also lead =
to memory leaks, so I wanted a solution that would guarantee that there cou=
ldn't be a leak.
> >=20
>=20
> I think, your patch is safe (And I've tried to think of a remaining race,
> but couldn't find ;-)
> I've inserted it into SLES11 SP1 instead of my patch and started the test.
>=20
>=20
> > >=20
> > > I verified this inserting some debug instructions. In a testrun that=
=20
> > > triggered 6 times, and the queue printed by crash after the run had 6=
=20
> > > orphaned entries.
> > >=20
> > > As I wrote yesterday, I have a patch that solves the problem by=20
> > > retesting the state of the cache entry after setting CACHE_PENDING in=
=20
> > > cache_check(). I can send it if you like.
> > >=20
> > > Bodo
> > >=20
> > > P.S.:
> > > Maybe I'm wrong, but AFAICS, there are two further minor problems=20
> > > regarding (nearly) expired cache entries:
> > > a) ip_map_cached_get() in some situations can return an already
> > >    outdated (it uses cache_valid that not fully checks the state)
> > >    cache entry. If cache_check() is caclled for that entry, it will
> > >    fail, I think
> > > b) Generally, if a cache entry is returned by sunrpc_cache_lookup()
> > >    and the entry is in the last second of it's expiry_time, the=20
> > >    clock might move to the next second before cache_check is called.
> > >    If this happens, cache_check will fail, I think.
> > > Do you agree?
> >=20
> > Yes, but I'm not sure how important this is.
> > Normally cache entries should be refreshed well before they expire, so =
we should normally find an entry with more than half of its lifetime left.
> >=20
> > In the rare case where the scenario you describe happens, cache_check()=
 will return -ETIMEDOUT.
> > In mainline, that will cause the request to be dropped and the connecti=
on closed so the client will try again and won't hit any race and so should=
 get a correct result.
> > In SLES11SP1, we retry the lookup and will hopefully get a better resul=
t without having to close the connection.
> >=20
> > So this should be rare and should fail-safe.
> >=20
> > Does that agree with your understanding?
>=20
> Only partly, because I was wrong.
>=20
> On SLES11 SP1, as you say, cache_is_valid() examines expiry_time, but
> the retry will avoid to make a RPC request fail.
>=20
> On a mainline kernel, cache_is_valid() does not evaluate the expiry_time.
> So, an old entry might start an upcall, but as the result of cache_is_val=
id
> still is 0, nothing will fail on mainline.
>=20
> The only little issue remaining is the fact, that ip_map_cached_get() will
> accept outdated cache entries as long as they are not yet cleaned.
> In mainline this entry will even be accepted by cache_check().
> Do you think it would be a good idea to replace cache_valid() by
> cache_is_valid()?
>=20


I think my problem is that I remember how this all used to work, rather than
how it has been changed to work over the years (largely by me or with my
oversight).  So I analyse the code against an out-of-date understanding :-(
I'm glad you aren't weighed down by that and so can see the code clearly!

Yes, in mainline an entry cached by ip_map_cached_put() will never be tested
for expiry.  I think we should change it to use cache_is_expired as below.

Thanks,
NeilBrown

=46rom 0262882daee7ebef8f04bb40404695ba524e0bd1 Mon Sep 17 00:00:00 2001
From: NeilBrown <neilb@suse.de>
Date: Wed, 20 Mar 2013 15:32:10 +1100
Subject: [PATCH] net/sunrpc: xpt_auth_cache should be ignored when expired.

commit d202cce8963d9268ff355a386e20243e8332b308
    sunrpc: never return expired entries in sunrpc_cache_lookup

moved the 'entry is expired' test from cache_check to
sunrpc_cache_lookup, so that it happened early and some races could
safely be ignored.

However the ip_map (in svcauth_unix.c) has a separate single-item
cache which allows quick lookup without locking.  An entry in this
case would not be subject to the expiry test and so could be used
well after it has expired.

This is not normally a big problem because the first time it is used
after it is expired an up-call will be scheduled to refresh the entry
(if it hasn't been scheduled already) and the old entry will then
be invalidated.  So on the second attempt to use it after it has
expired, ip_map_cached_get will discard it.

However that is subtle and not ideal, so replace the "!cache_valid"
test with "cache_is_expired".
In doing this we drop the test on the "CACHE_VALID" bit.  This is
unnecessary as the bit is never cleared, and an entry will only
be cached if the bit is set.

Reported-by: Bodo Stroesser <bstroesser@ts.fujitsu.com>
Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 8419f7d..6ce690d 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -149,6 +149,24 @@ struct cache_deferred_req {
 					   int too_many);
 };
=20
+/*
+ * timestamps kept in the cache are expressed in seconds
+ * since boot.  This is the best for measuring differences in
+ * real time.
+ */
+static inline time_t seconds_since_boot(void)
+{
+	struct timespec boot;
+	getboottime(&boot);
+	return get_seconds() - boot.tv_sec;
+}
+
+static inline time_t convert_to_wallclock(time_t sinceboot)
+{
+	struct timespec boot;
+	getboottime(&boot);
+	return boot.tv_sec + sinceboot;
+}
=20
 extern const struct file_operations cache_file_operations_pipefs;
 extern const struct file_operations content_file_operations_pipefs;
@@ -182,15 +200,10 @@ static inline void cache_put(struct cache_head *h, st=
ruct cache_detail *cd)
 	kref_put(&h->ref, cd->cache_put);
 }
=20
-static inline int cache_valid(struct cache_head *h)
+static inline int cache_is_expired(struct cache_detail *detail, struct cac=
he_head *h)
 {
-	/* If an item has been unhashed pending removal when
-	 * the refcount drops to 0, the expiry_time will be
-	 * set to 0.  We don't want to consider such items
-	 * valid in this context even though CACHE_VALID is
-	 * set.
-	 */
-	return (h->expiry_time !=3D 0 && test_bit(CACHE_VALID, &h->flags));
+	return  (h->expiry_time < seconds_since_boot()) ||
+		(detail->flush_time > h->last_refresh);
 }
=20
 extern int cache_check(struct cache_detail *detail,
@@ -251,25 +264,6 @@ static inline int get_uint(char **bpp, unsigned int *a=
nint)
 	return 0;
 }
=20
-/*
- * timestamps kept in the cache are expressed in seconds
- * since boot.  This is the best for measuring differences in
- * real time.
- */
-static inline time_t seconds_since_boot(void)
-{
-	struct timespec boot;
-	getboottime(&boot);
-	return get_seconds() - boot.tv_sec;
-}
-
-static inline time_t convert_to_wallclock(time_t sinceboot)
-{
-	struct timespec boot;
-	getboottime(&boot);
-	return boot.tv_sec + sinceboot;
-}
-
 static inline time_t get_expiry(char **bpp)
 {
 	int rv;
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 8e7ccbb..81defe6 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -50,12 +50,6 @@ static void cache_init(struct cache_head *h)
 	h->last_refresh =3D now;
 }
=20
-static inline int cache_is_expired(struct cache_detail *detail, struct cac=
he_head *h)
-{
-	return  (h->expiry_time < seconds_since_boot()) ||
-		(detail->flush_time > h->last_refresh);
-}
-
 struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
 				       struct cache_head *key, int hash)
 {
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index c3f9e1e..8d7a7b9 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -347,13 +347,13 @@ ip_map_cached_get(struct svc_xprt *xprt)
 		spin_lock(&xprt->xpt_lock);
 		ipm =3D xprt->xpt_auth_cache;
 		if (ipm !=3D NULL) {
-			if (!cache_valid(&ipm->h)) {
+			sn =3D net_generic(xprt->xpt_net, sunrpc_net_id);
+			if (cache_is_expired(sn->ip_map_cache, &ipm->h)) {
 				/*
 				 * The entry has been invalidated since it was
 				 * remembered, e.g. by a second mount from the
 				 * same IP address.
 				 */
-				sn =3D net_generic(xprt->xpt_net, sunrpc_net_id);
 				xprt->xpt_auth_cache =3D NULL;
 				spin_unlock(&xprt->xpt_lock);
 				cache_put(&ipm->h, sn->ip_map_cache);

--Sig_/o2tb=Uc7M.YaF=ErJ9VKsCB
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUUk9njnsnt1WYoG5AQKANA//bmYvpQv9TdMu/1b6D79cd3k2mY4sVU8M
mYebmugkGn1JCiA9E55DM9oDPwXUt7vzNZSk+tjUapAgPJlfchgE4wwDDzFVg7h0
mDwofroMJsg18jytifVZlawnGx/2/TemwzD+QIiY+x45XEE/AMWkL/G5bW7SCWqn
6gQmTuAeNnI15dXRhQiJONbteSTdkdqTTwm5yCqVPzmle8s0TDs+DVMtU2Zx9LKf
2PSeZctdIxFnL1Pa5/JfIHGoqsp+t2JcPLswyO+rniAHYeChEzgCvMLc1139WrBw
wok9PUiueDSSBgODuXOfYTSVGaoJyXTcSFMJ9SLYO/D1ulruRveDGSXSA2LuWtFF
QZT9GyCHdiRNAIdmyEsuax2CSWBpCbkO1LBYSMMJ0Wx7G9YORBKaNjpG0PNjYyDS
s221vQuNagfmFs6910uJd4PrwLcC/+++uvqR0ph/hMkp8tsd0LwhVUuXKW6VX6Qa
CeIj4LmvIAh/Gd9Zrckr0TKtOF7KpI/by79QhAGzvWJJHwfWdDiNC6tGGe+ixznX
3WzxFHoNo4LO3CdwI3IWiEIZRfimUBN3//tWyGdUhUn/DkKaeGht+lCMIWtthaMb
Z4bGEC44a/JnBd/WPH8TBX6VG8vOMdwnUh2Y4nxbf82nuBZW5A5cgjYAU+mCPEwA
ydxIYvUpD04=
=8H+6
-----END PGP SIGNATURE-----

--Sig_/o2tb=Uc7M.YaF=ErJ9VKsCB--

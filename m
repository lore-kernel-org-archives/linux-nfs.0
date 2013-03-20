Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:34334 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751624Ab3CTXeD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Mar 2013 19:34:03 -0400
Date: Thu, 21 Mar 2013 10:33:51 +1100
From: NeilBrown <neilb@suse.de>
To: Bodo Stroesser <bstroesser@ts.fujitsu.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: sunrpc/cache.c: races while updating cache entries
Message-ID: <20130321103351.105664dc@notabene.brown>
In-Reply-To: <61eb00$3hl8ah@dgate20u.abg.fsc.net>
References: <61eb00$3hl8ah@dgate20u.abg.fsc.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/wUPdHEBMBSszjNh/F_hqAzK"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/wUPdHEBMBSszjNh/F_hqAzK
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On 20 Mar 2013 19:45:48 +0100 Bodo Stroesser <bstroesser@ts.fujitsu.com>
wrote:

> On 19 Mar 2013 04:24:00 +0100 NeilBrown <neilb@suse.de> wrote:
>=20
> > On 14 Mar 2013 18:31:38 +0100 Bodo Stroesser <bstroesser@ts.fujitsu.com>
> > wrote:
> >=20
> > > On 13 Mar 2013 07:55:00 +0100 NeilBrown <neilb@suse.de> wrote:
> > >=20
> > > > On 11 Mar 2013 17:13:41 +0100 Bodo Stroesser <bstroesser@ts.fujitsu=
.com>
> > > > wrote:
> > > >=20
> > > > > Hi,
> > > > >=20
> > > > > AFAICS, there is one more race in RPC cache.
> > > > >=20
> > > > > The problem showed up for the "auth.unix.ip" cache, that
> > > > > has a reader.
> > > > >=20
> > > > > If a server thread tries to find a cache entry, it first
> > > > > does a lookup (or calls ip_map_cached_get() in this specific
> > > > > case). Then, it calls cache_check() for this entry.
> > > > >=20
> > > > > If the reader updates the cache entry just between the
> > > > > thread's lookup and cache_check() execution, cache_check()
> > > > > will do an upcall for this cache entry. This is, because
> > > > > sunrpc_cache_update() calls cache_fresh_locked(old, 0),
> > > > > which sets expiry_time to 0.
> > > > >=20
> > > > > Unfortunately, the reply to the upcall will not dequeue
> > > > > the queued cache_request, as the reply will be assigned to
> > > > > the cache entry newly created by the above cache update.
> > > > >=20
> > > > > The result is a growing queue of orphaned cache_request
> > > > > structures --> memory leak.
> > > > >=20
> > > > > I found this on a SLES11 SP1 with a backport of the latest
> > > > > patches that fix the other RPC races. On this old kernel,
> > > > > the problem also leads to svc_drop() being called for the
> > > > > affected RPC request (after svc_defer()).
> > > > >=20
> > > > > Best Regards
> > > > > Bodo
> > > >=20
> > > > I don't think this is a real problem.
> > > > The periodic call to "cache_clean" should find these orphaned reque=
sts and
> > > > purge them.  So you could get a short term memory leak, but it shou=
ld
> > > > correct itself.
> > > > Do you agree?
> > > >=20
> > > > Thanks,
> > > > NeilBrown
> > >=20
> > > Meanwhile I found the missing part of the race!
> > >=20
> > > It's just what I wrote above but additionally, immediately after
> > > the reader updated the cache, cache_clean() unhashes the old cache
> > > entry. In that case:
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
> > Prior to then, cache_clean would never remove anything with an active
> > reference.  If something was about to get CACHE_PENDING, it would have a
> > reference so cache_clean would leave it alone.
> >=20
> > I wanted to fix this by getting the last 'put' to call cache_dequeue() =
if
> > CACHE_PENDING was still set.  However I couldn't get access to the
> > CACHE_PENDING flag and the cache_detail at the same place - so I gave u=
p on
> > that.
> >=20
> > The patch I have included below sets a flag when an cache item is remov=
ed
> > from the cache (by cache_clean) and refuses to lodge an upcall if the f=
lag is
> > set.  That will ensure there is never a pending upcall when the item is
> > finally freed.
> >=20
> > You patch only addresses the particular situation that you had found.  I
> > think it is possible that there might be other situations that also lea=
d to
> > memory leaks, so I wanted a solution that would guarantee that there co=
uldn't
> > be a leak.
> >=20
> > >=20
> > > I verified this inserting some debug instructions. In a testrun
> > > that triggered 6 times, and the queue printed by crash after the
> > > run had 6 orphaned entries.
> > >=20
> > > As I wrote yesterday, I have a patch that solves the problem by
> > > retesting the state of the cache entry after setting CACHE_PENDING
> > > in cache_check(). I can send it if you like.
> > >=20
> > > Bodo
> > >=20
> > > P.S.:
> > > Maybe I'm wrong, but AFAICS, there are two further minor problems
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
we
> > should normally find an entry with more than half of its lifetime left.
> >=20
> > In the rare case where the scenario you describe happens, cache_check()=
 will
> > return -ETIMEDOUT.
> > In mainline, that will cause the request to be dropped and the connecti=
on
> > closed so the client will try again and won't hit any race and so shoul=
d get
> > a correct result.
> > In SLES11SP1, we retry the lookup and will hopefully get a better result
> > without having to close the connection.
> >=20
> > So this should be rare and should fail-safe.
> >=20
> > Does that agree with your understanding?
> >=20
> >=20
> > Thanks,
> > NeilBrown
> >=20
> >=20
> > From e76e6583405a3b5ff9c8d2ae1184704efb209ef0 Mon Sep 17 00:00:00 2001
> > From: NeilBrown <neilb@suse.de>
> > Date: Tue, 19 Mar 2013 13:58:58 +1100
> > Subject: [PATCH] sunrpc/cache: ensure items removed from cache do not h=
ave
> >  pending upcalls.
> >=20
> > It is possible for a race to set CACHE_PENDING after cache_clean()
> > has removed a cache entry from the cache.
> > If CACHE_PENDING is still set when the entry is finally 'put',
> > the cache_dequeue() will never happen and we can leak memory.
> >=20
> > So set a new flag 'CACHE_CLEANED' when we remove something from
> > the cache, and don't queue and upcall if it is set.
> >=20
> > If CACHE_PENDING is set before CACHE_CLEANED, the call that
> > cache_clean() makes to cache_fresh_unlocked() will free memory
> > as needed.  If CACHE_PENDING is set after CACHE_CLEANED, the
> > test in sunrpc_cache_pipe_upcall will ensure that the memory
> > is not allocated.
> >=20
> > Reported-by: <bstroesser@ts.fujitsu.com>
> > Signed-off-by: NeilBrown <neilb@suse.de>
> >=20
> > diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
> > index 303399b..8419f7d 100644
> > --- a/include/linux/sunrpc/cache.h
> > +++ b/include/linux/sunrpc/cache.h
> > @@ -57,6 +57,7 @@ struct cache_head {
> >  #define	CACHE_VALID	0	/* Entry contains valid data */
> >  #define	CACHE_NEGATIVE	1	/* Negative entry - there is no match for the=
 key */
> >  #define	CACHE_PENDING	2	/* An upcall has been sent but no reply receiv=
ed yet*/
> > +#define	CACHE_CLEANED	3	/* Entry has been cleaned from cache */
> > =20
> >  #define	CACHE_NEW_EXPIRY 120	/* keep new things pending confirmation f=
or 120 seconds */
> > =20
> > diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> > index 1677cfe..8e7ccbb 100644
> > --- a/net/sunrpc/cache.c
> > +++ b/net/sunrpc/cache.c
> > @@ -306,7 +306,7 @@ EXPORT_SYMBOL_GPL(cache_check);
> >   * a current pointer into that list and into the table
> >   * for that entry.
> >   *
> > - * Each time clean_cache is called it finds the next non-empty entry
> > + * Each time cache_clean is called it finds the next non-empty entry
> >   * in the current table and walks the list in that entry
> >   * looking for entries that can be removed.
> >   *
> > @@ -453,6 +453,7 @@ static int cache_clean(void)
> >  			current_index ++;
> >  		spin_unlock(&cache_list_lock);
> >  		if (ch) {
> > +			set_bit(CACHE_CLEANED, &ch->flags);
> >  			cache_fresh_unlocked(ch, d);
> >  			cache_put(ch, d);
> >  		}
> > @@ -1176,6 +1177,9 @@ int sunrpc_cache_pipe_upcall(struct cache_detail =
*detail, struct cache_head *h)
> >  		warn_no_listener(detail);
> >  		return -EINVAL;
> >  	}
> > +	if (test_bit(CACHE_CLEANED, &h->flags))
> > +		/* Too late to make an upcall */
> > +		return -EAGAIN;
> > =20
> >  	buf =3D kmalloc(PAGE_SIZE, GFP_KERNEL);
> >  	if (!buf)
> >=20
>=20
> I added this patch to my SLES11 SP1 and still had dropped RPC requests,
> but no leaked memory.
>=20
> The drops occur, because cache_check() allows to make upcalls for cache
> entries, that are substituted with new ones by sunrpc_cache_update().
> If cache_clean() comes too late to wake up the thread waiting for an
> update of the old cache entry, a timeout will occur and the RPC request
> is dropped.
>=20
> This will not happen on mainline, but why should we allow upcalls to be
> queued for replaced cache entries? This will create unnecessary traffic
> on the channel to the reader and as a result unnecessary calls to
> sunrpc_cache_update()
>=20
> By additionally to the above patch inserting
>     "setbit(CACHE_CLEANED, &old->flags);"
> into sunrpc_cache_update() between the two lines
>     "cache_fresh_unlocked(tmp, detail);"
>     "cache_fresh_unlocked(old, detail);"
> this unclean behavior can be avoided.
>=20
> If we do so, maybe CACHE_CLEAN should better be named CACHE_OLD or
> something else that reflects both uses of the bit.
>=20
> Do you agree?

This applies only to SLES11-SP1 (2.6.32+) right?
In mainline the request won't be dropped because the cache item isn't assum=
ed
to still be valid.

So we need to make sure that sunrpc_cache_pipe_upcall doesn't make an upcall
on a cache item that has been replaced.  I'd rather not use the CACHE_CLEAN
bit (whether renamed or not) as it has a well defined meaning "has been
removed from cache" and I'd rather not blur that meaning.
We already have a state that means "this has been replace"- ->expiry_time is
0.
So how about adding
   if (h->expiry_time =3D=3D 0)
         return -EAGAIN;
to sunrpc_cache_pipe_upcall() in SLES11-SP1.

Does that work for you?

Thanks,
NeilBrown

--Sig_/wUPdHEBMBSszjNh/F_hqAzK
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUUpHXznsnt1WYoG5AQJFFQ//XJyBo9dd5fF3q2aouSdztrthy6ThH6EU
i7f7NFdyPF9QzSGhxXVDF0Dpcn7iZLJl92EQWJelej5hb8VDDauhEnSXRrVLsQTu
CwRRBlMHNaQqXfRLpqdgwBsLmmA0PkOK+hRZRKKxIw8aAguVL5RoZYZj+oogtbiS
kAzVAw7LBhiYEoDzn3SBCMmQ8/quxQ1WPXl9Ru1UkEaQkXknJSiQpQ8fjwO3HewX
ScmFkSJ8v9p7PQ65+Pr18suFQLMA3NpnOamp65U+eG0X9j6/4aRDlv+x8vvG9amY
UjRj7expmyTdoKB14t8qHTtyLLJ2p9GFD9LdVzC9R6g/7yPA81oCRvRfJ/fG1cOE
XaGgb1/n42nqgbhTEsQgoZD5I5wIuSVNgX5v6Shrrb1TTmyGk0gAE38/2xaEQstb
b7EwGv32bHPmr1U62NqxmBoS1LFnTtaxMt0TtOib/OvDQeoWrgGq4mI986vrkPTe
1XN97MS39uB1Q7pOVuD1YrGLMTiCcpc+89q0iU5sE6gQ7jhAsxHEW2Osx5Y+sm8y
QFSxRHfTHsRRryoJjIP+syBpAvdDIwblFN1nnSO9Qg39kFbVYi+Tw6hjSIXH0Pb2
EnHbBx75N7iA2BfRLX35tSYQmjp6kw1bd2ZvTNS/rH3Zl0nmf3895J7ExvQdgRIy
sxAMJMCH7S4=
=GiA6
-----END PGP SIGNATURE-----

--Sig_/wUPdHEBMBSszjNh/F_hqAzK--

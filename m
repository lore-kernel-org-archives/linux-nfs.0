Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:43383 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751224Ab3BTXzg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Feb 2013 18:55:36 -0500
Date: Thu, 21 Feb 2013 10:55:19 +1100
From: NeilBrown <neilb@suse.de>
To: bstroesser@ts.fujitsu.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] sunrpc.ko: RPC cache fix races
Message-ID: <20130221105519.5f46d3e7@notabene.brown>
In-Reply-To: <d6437a$434ic3@dgate10u.abg.fsc.net>
References: <d6437a$434ic3@dgate10u.abg.fsc.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Co=saaYWjk7QQbZ7wSrrr8M"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Co=saaYWjk7QQbZ7wSrrr8M
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On 20 Feb 2013 14:57:07 +0100 bstroesser@ts.fujitsu.com wrote:

> On 20 Feb 2013 04:09:00 +0100 neilb@suse.de wrote:
>=20
> > On 19 Feb 2013 18:08:40 +0100 bstroesser@ts.fujitsu.com wrote:
> >=20
> > > Second attempt using the correct FROM. Sorry for the noise.
> > >=20
> > >=20
> > > Hi,
> > >=20
> > > I found a problem in sunrpc.ko on a SLES11 SP1 (2.6.32.59-0,7.1) and=
=20
> > > fixed it (see first patch ifor 2.6.32.60 below).
> > > For us the patch works fine (tested on 2.6.32.59-0.7.1).
> > >=20
> > > AFAICS from the code, the problem seems to persist in current kernel=
=20
> > > versions also. Thus, I added the second patch for 3.7.9.
> > > As the setup to reproduce the problem is quite complex, I couldn't=20
> > > test the second patch yet. So consider this one as a RFC.
> > >=20
> > > Best regards,
> > > Bodo
> > >=20
> > > Please CC me, I'm not on the list.
> > >=20
> > > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > > From: Bodo Stroesser <bstroesser@ts.fujitsu.com>
> > > Date: Fri, 08 Feb 2013
> > > Subject: [PATCH] net: sunrpc: fix races in RPC cache
> > >=20
> > > We found the problem and tested the patch on a SLES11 SP1=20
> > > 2.6.32.59-0.7.1
> > >=20
> > > This patch applies to linux-2.6.32.60 (changed monotonic_seconds -->
> > > get_seconds())
> > >=20
> > > Sporadically NFS3 RPC requests to the nfs server are dropped due to
> > > cache_check() (net/sunrpc/cache.c) returning -ETIMEDOUT for an entry=
=20
> > > of the "auth.unix.gid" cache.
> > > In this case, no NFS reply is sent to the client.
> > >=20
> > > The reason for the dropped requests are races in cache_check() when
> > > cache_make_upcall() returns -EINVAL (because it is called for a cache=
=20
> > > without readers) and cache_check() therefore refreshes the cache entr=
y=20
> > > (rv =3D=3D -EAGAIN).
> > >=20
> > > There are three details that need to be changed:
> > >  1) cache_revisit_request() must not be called before cache_fresh_loc=
ked()
> > >     has updated the cache entry, as cache_revisit_request() wakes up
> > >     threads waiting for the cache entry to be updated.
> >=20
> > This certainly seems correct.  It is wrong to call cache_revisit_reques=
t() so early.
> >=20
> > >     The explicit call to cache_revisit_request() is not needed, as
> > >     cache_fresh_unlocked() calls it anyway.
> >=20
> > But cache_fresh_unlocked is only called if "rv =3D=3D -EAGAIN", however=
 we also need to call it in the case where "age > refresh_age/2" - it must =
always be called after clearing CACHE_PENDING.
> >=20
> > Also, cache_fresh_unlocked() only calls cache_revisit_request() if CACH=
E_PENDING is set, but we have just cleared it!  Some definitely something w=
rong here.
> > (Note that I'm looking at the SLES 2.6.32 code at the moment, mainline =
is a bit different).
> >=20
> >=20
> > >     (But in case of not updating the cache entry, cache_revisit_reque=
st()
> > >     must be called. Thus, we use a fall through in the "case").
> >=20
> > Hmm... I don't like case fallthroughs unless they have nice big comment=
s:
> >     /* FALLTHROUGH */
> > or similar. :-)
> >=20
> > >  2) CACHE_PENDING must not be cleared before cache_fresh_locked() has
> > >     updated the cache entry, as cache_defer_req() can return without =
really
> > >     sleeping if it detects CACHE_PENDING unset.
> >=20
> > Agreed.  So we should leave the clearing of CACHE_PENDING to cache_fres=
h_unlocked().
> >=20
> >=20
> > >     (In case of not updating the cache entry again we use the fall=20
> > > through)
> > >  3) Imagine a thread that calls cache_check() and gets rv =3D -ENOENT=
 from
> > >     cache_is_valid(). Then it sets CACHE_PENDINGs and calls
> > >     cache_make_upcall().
> > >     We assume that meanwhile get_seconds() advances to the next
> > >     sec. and a second thread also calls cache_check(). It gets -EAGAI=
N from
> > >     cache_is_valid() for the same cache entry. As CACHE_PENDING still=
 is
> > >     set, it calls cache_defer_req() immediately and waits for a wakeu=
p from
> > >     the first thread.
> > >     After cache_make_upcall() returned -EINVAL, the first thread does=
 not
> > >     update the cache entry as it had got rv =3D -ENOENT, but wakes up=
 the
> > >     second thread by calling cache_revisit_request().
> > >     Thread two wakes up, calls cache_is_valid() and again gets -EAGAI=
N.
> > >     Thus, the result of the second cache_check() is -ETIMEDOUT and the
> > >     NFS request is dropped.
> >=20
> > Yep, that's not so good....
> >=20
> >=20
> > >     To solve this, the cache entry now is updated not only if rv =3D=
=3D -EAGAIN
> > >     but if rv =3D=3D -ENOENT also. This is a sufficient workaround, a=
s the
> > >     first thread would have to stay in cache_check() between its call=
 to
> > >     cache_is_valid() and clearing CACHE_PENDING for more than 60 seco=
nds
> > >     to break the workaround.
> >=20
> > Still, it isn't nice to just have a work-around.  It would be best to h=
ave a fix.
> > The key problem here is that cache_is_valid() is time-sensitive.  This =
have been address in mainline - cache_is_valid doesn't depend on the curren=
t time there.
>=20
> So, the solution would be a backport of the current mainline code ...

That would always be my preference, when it is practical.

>=20
> Anyway, I think for SLES11 SP1 and 2.6.32.60 the work-around would be suf=
ficient.
> BTW: it has the positive side effect, that - while a cache entry is in it=
s second
> half of life - no longer each cache_check() tries to do a cache_make_upca=
ll().

I agree that is an improvement.

>=20
>=20
> >=20
> >=20
> > >    =20
> > > Signed-off-by: Bodo Stroesser <bstroesser@ts.fujitsu.com>
> > > ---
> > >=20
> > > --- a/net/sunrpc/cache.c	2012-08-08 21:35:09.000000000 +0200
> > > +++ b/net/sunrpc/cache.c	2013-02-08 14:29:41.000000000 +0100
> > > @@ -233,15 +233,14 @@ int cache_check(struct cache_detail *det
> > >  		if (!test_and_set_bit(CACHE_PENDING, &h->flags)) {
> > >  			switch (cache_make_upcall(detail, h)) {
> > >  			case -EINVAL:
> > > -				clear_bit(CACHE_PENDING, &h->flags);
> > > -				cache_revisit_request(h);
> > > -				if (rv =3D=3D -EAGAIN) {
> > > +				if (rv =3D=3D -EAGAIN || rv =3D=3D -ENOENT) {
> > >  					set_bit(CACHE_NEGATIVE, &h->flags);
> > >  					cache_fresh_locked(h, get_seconds()+CACHE_NEW_EXPIRY);
> > > +					clear_bit(CACHE_PENDING, &h->flags);
> > >  					cache_fresh_unlocked(h, detail);
> > >  					rv =3D -ENOENT;
> > > +					break;
> > >  				}
> > > -				break;
> > > =20
> > >  			case -EAGAIN:
> > >  				clear_bit(CACHE_PENDING, &h->flags);
> >=20
> > I agree with some of this....
> > Maybe:
> >=20
> >   switch(cache_make_upcall(detail, h)) {
> >   case -EINVAL:
> >         if (rv) {
> > 		set_bit(CACHE_NEGATIVE, &h->flags);
> > 		cache_fresh_locked(h, get_seconds() + CACHE_NEW_EXPIRY);
> > 		rv =3D -ENOENT;
> > 	}
> > 	/* FALLTHROUGH */
> >   case -EAGAIN:
> > 	cache_fresh_unlocked(h, detail);
> >   }
>=20
> I agree, your patch is obviously better than the mine.
> But let me suggest one little change: I would like to substitute
> cache_fresh_unlocked() by clear_bit() and cache_revisit_request(),
> as the call to cache_dequeue() in cache_fresh_unlocked() seems to
> be obsolete here:

It is exactly this sort of thinking (on my part) that got us into this mess
in the first place.  I reasoned that the full locking/testing/whatever wasn=
't
necessary and took a short cut.  It wasn't a good idea.

Given that this is obviously difficult code to get right, we should make it
as easy to review as possible.  Have "cache_fresh_unlocked" makes it more
obviously correct, and that is a good thing.
Maybe cache_dequeue isn't needed here, but it won't hurt so I'd much rather
have the clearer code.
In fact, I'd also like to change

			if (test_and_clear_bit(CACHE_PENDING, &ch->flags))
				cache_dequeue(current_detail, ch);
			cache_revisit_request(ch);

near the end of cache_clean to call  cache_fresh_unlocked().


NeilBrown


--Sig_/Co=saaYWjk7QQbZ7wSrrr8M
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUSViZznsnt1WYoG5AQJ69g//ULa+R7Ll+Du68nYLZ5dYsfz93Rvhb2BF
csuu9XRAtHLBRKULvT+3WctpDbyE2KQjr8BSi8bhWy6aJjQG6l80ZBSX3EF//F64
HGTAKZO0LFHxqpq8A9utzZsfvtpzR8nyG2Aqt5Vn9IvhLTka9LYnV46Wgtfb/DNd
dBhE+f0zPddJTh/xoOANgaPkpp+3Id7B81KTakcHeIFysk8wYqpqW7LlyYxsj6rd
vqU3UmZmBKU2fewyVFl7yYoYw/m65Qfd6N5mwjAM9ynAc3h7vMP900FYZzp73W4u
FwVyseoknZb+Fu0SnBLFJ+07LynvpkWBScZoYjhLaUQpCplFvXrK1GSX0/KnjrH8
rg+YpM/jacwFmMoPcQj7dvIutuR8Ey2mkyliQKheth5fB04s2e05g0SGKUMj42kE
nmNtnwlHa/H5U4mnNFIin1SNXmf2FFlIQlpswjlBGCDf7g/Gih1v+o2s0JNrUKtK
1bxpx9WUabp5TSygHW5oQ68QBGIyQz1AElDrTSejvCCQsjAlDnnxr4Yn7EiAX8t8
StkQshgPI60r4kM+YWHezKbyMoIrTy8ixdhqQOOrm3mFqD8QDVTHZ9g657wIorYB
Schc8Ty/75ojj3LTrhfd4nJ1jb+IlNjUIe5ZJQ/vLlVnGZJEcL09vOD8KuzhUr7T
f9tBNd7EPLU=
=URwS
-----END PGP SIGNATURE-----

--Sig_/Co=saaYWjk7QQbZ7wSrrr8M--

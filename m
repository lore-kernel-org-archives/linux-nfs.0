Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:57503 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932685Ab3BTDJG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Feb 2013 22:09:06 -0500
Date: Wed, 20 Feb 2013 14:08:48 +1100
From: NeilBrown <neilb@suse.de>
To: bstroesser@ts.fujitsu.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] sunrpc.ko: RPC cache fix races
Message-ID: <20130220140848.7d664dfb@notabene.brown>
In-Reply-To: <61eb00$3f3hds@dgate20u.abg.fsc.net>
References: <61eb00$3f3hds@dgate20u.abg.fsc.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/X7yfFLKhhBhdIEMShQpAby_"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/X7yfFLKhhBhdIEMShQpAby_
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On 19 Feb 2013 18:08:40 +0100 bstroesser@ts.fujitsu.com wrote:

> Second attempt using the correct FROM. Sorry for the noise.
>=20
>=20
> Hi,
>=20
> I found a problem in sunrpc.ko on a SLES11 SP1 (2.6.32.59-0,7.1)
> and fixed it (see first patch ifor 2.6.32.60 below).
> For us the patch works fine (tested on 2.6.32.59-0.7.1).
>=20
> AFAICS from the code, the problem seems to persist in current
> kernel versions also. Thus, I added the second patch for 3.7.9.
> As the setup to reproduce the problem is quite complex, I couldn't
> test the second patch yet. So consider this one as a RFC.
>=20
> Best regards,
> Bodo
>=20
> Please CC me, I'm not on the list.
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> From: Bodo Stroesser <bstroesser@ts.fujitsu.com>
> Date: Fri, 08 Feb 2013
> Subject: [PATCH] net: sunrpc: fix races in RPC cache
>=20
> We found the problem and tested the patch on a SLES11 SP1 2.6.32.59-0.7.1
>=20
> This patch applies to linux-2.6.32.60 (changed monotonic_seconds -->
> get_seconds())
>=20
> Sporadically NFS3 RPC requests to the nfs server are dropped due to
> cache_check() (net/sunrpc/cache.c) returning -ETIMEDOUT for an entry
> of the "auth.unix.gid" cache.
> In this case, no NFS reply is sent to the client.
>=20
> The reason for the dropped requests are races in cache_check() when
> cache_make_upcall() returns -EINVAL (because it is called for a cache
> without readers) and cache_check() therefore refreshes the cache entry=20
> (rv =3D=3D -EAGAIN).
>=20
> There are three details that need to be changed:
>  1) cache_revisit_request() must not be called before cache_fresh_locked()
>     has updated the cache entry, as cache_revisit_request() wakes up
>     threads waiting for the cache entry to be updated.

This certainly seems correct.  It is wrong to call cache_revisit_request() =
so
early.

>     The explicit call to cache_revisit_request() is not needed, as
>     cache_fresh_unlocked() calls it anyway.

But cache_fresh_unlocked is only called if "rv =3D=3D -EAGAIN", however we =
also
need to call it in the case where "age > refresh_age/2" - it must always be
called after clearing CACHE_PENDING.

Also, cache_fresh_unlocked() only calls cache_revisit_request() if
CACHE_PENDING is set, but we have just cleared it!  Some definitely somethi=
ng
wrong here.
(Note that I'm looking at the SLES 2.6.32 code at the moment, mainline is a
bit different).


>     (But in case of not updating the cache entry, cache_revisit_request()
>     must be called. Thus, we use a fall through in the "case").

Hmm... I don't like case fallthroughs unless they have nice big comments:
    /* FALLTHROUGH */
or similar. :-)

>  2) CACHE_PENDING must not be cleared before cache_fresh_locked() has
>     updated the cache entry, as cache_defer_req() can return without real=
ly
>     sleeping if it detects CACHE_PENDING unset.

Agreed.  So we should leave the clearing of CACHE_PENDING to
cache_fresh_unlocked().


>     (In case of not updating the cache entry again we use the fall throug=
h)
>  3) Imagine a thread that calls cache_check() and gets rv =3D -ENOENT from
>     cache_is_valid(). Then it sets CACHE_PENDINGs and calls
>     cache_make_upcall().
>     We assume that meanwhile get_seconds() advances to the next
>     sec. and a second thread also calls cache_check(). It gets -EAGAIN fr=
om
>     cache_is_valid() for the same cache entry. As CACHE_PENDING still is
>     set, it calls cache_defer_req() immediately and waits for a wakeup fr=
om
>     the first thread.
>     After cache_make_upcall() returned -EINVAL, the first thread does not
>     update the cache entry as it had got rv =3D -ENOENT, but wakes up the
>     second thread by calling cache_revisit_request().
>     Thread two wakes up, calls cache_is_valid() and again gets -EAGAIN.
>     Thus, the result of the second cache_check() is -ETIMEDOUT and the
>     NFS request is dropped.

Yep, that's not so good....


>     To solve this, the cache entry now is updated not only if rv =3D=3D -=
EAGAIN
>     but if rv =3D=3D -ENOENT also. This is a sufficient workaround, as the
>     first thread would have to stay in cache_check() between its call to
>     cache_is_valid() and clearing CACHE_PENDING for more than 60 seconds
>     to break the workaround.

Still, it isn't nice to just have a work-around.  It would be best to have a
fix.
The key problem here is that cache_is_valid() is time-sensitive.  This have
been address in mainline - cache_is_valid doesn't depend on the current time
there.


>    =20
> Signed-off-by: Bodo Stroesser <bstroesser@ts.fujitsu.com>
> ---
>=20
> --- a/net/sunrpc/cache.c	2012-08-08 21:35:09.000000000 +0200
> +++ b/net/sunrpc/cache.c	2013-02-08 14:29:41.000000000 +0100
> @@ -233,15 +233,14 @@ int cache_check(struct cache_detail *det
>  		if (!test_and_set_bit(CACHE_PENDING, &h->flags)) {
>  			switch (cache_make_upcall(detail, h)) {
>  			case -EINVAL:
> -				clear_bit(CACHE_PENDING, &h->flags);
> -				cache_revisit_request(h);
> -				if (rv =3D=3D -EAGAIN) {
> +				if (rv =3D=3D -EAGAIN || rv =3D=3D -ENOENT) {
>  					set_bit(CACHE_NEGATIVE, &h->flags);
>  					cache_fresh_locked(h, get_seconds()+CACHE_NEW_EXPIRY);
> +					clear_bit(CACHE_PENDING, &h->flags);
>  					cache_fresh_unlocked(h, detail);
>  					rv =3D -ENOENT;
> +					break;
>  				}
> -				break;
> =20
>  			case -EAGAIN:
>  				clear_bit(CACHE_PENDING, &h->flags);

I agree with some of this....
Maybe:

  switch(cache_make_upcall(detail, h)) {
  case -EINVAL:
        if (rv) {
		set_bit(CACHE_NEGATIVE, &h->flags);
		cache_fresh_locked(h, get_seconds() + CACHE_NEW_EXPIRY);
		rv =3D -ENOENT;
	}
	/* FALLTHROUGH */
  case -EAGAIN:
	cache_fresh_unlocked(h, detail);
  }

Though it isn't good that cache_fresh_locked() is being called without
holding a lock!  Maybe we should import try_to_negate_entry() from mainline.

> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> From: Bodo Stroesser <bstroesser@ts.fujitsu.com>
> Date: Fri, 08 Feb 2013
> Subject: [PATCH] net: sunrpc: fix races in RPC cache
>=20
> This patch applies to SLES 11 SP2 linux-3.0.51-0.7.9 and also to
> vanilla linux-3.7.9
>=20
> It is untested and is only based on a code review after we
> analyzed the reason for NFS requests being dropped on a
> SLES11 SP1 (linux-2.6.32.59-0.7.1)
>=20
> Sporadically NFS3 RPC requests to the nfs server are dropped due to
> cache_check() (net/sunrpc/cache.c) returning -ETIMEDOUT for an entry
> of the "auth.unix.gid" cache.
> In this case, no NFS reply is sent to the client.
>=20
> The reason for the dropped requests are races in cache_check() when
> cache_make_upcall() returns -EINVAL (because it is called for a cache
> without readers) and cache_check() therefore refreshes the cache entry=20
> (rv =3D=3D -EAGAIN).
>=20
> There are two details that need to be changed:
>  1) cache_revisit_request() must not be called before cache_fresh_locked()
>     has updated the cache entry, as cache_revisit_request() wakes up
>     threads waiting for the cache entry to be updated.
>     The explicit call to cache_revisit_request() is not needed, as
>     cache_fresh_unlocked() calls it anyway.
>     (But in case of not updating the cache entry, cache_revisit_request()
>     must be called).
>  2) CACHE_PENDING must not be cleared before cache_fresh_locked() has
>     updated the cache entry, as cache_wait_req() called by
>     cache_defer_req() can return without really sleeping if it detects
>     CACHE_PENDING unset.
>=20
> Signed-off-by: Bodo Stroesser <bstroesser@ts.fujitsu.com>
> ---
>=20
> --- a/net/sunrpc/cache.c	2013-02-08 15:56:07.000000000 +0100
> +++ b/net/sunrpc/cache.c	2013-02-08 16:04:32.000000000 +0100
> @@ -230,11 +230,14 @@ static int try_to_negate_entry(struct ca
>  	rv =3D cache_is_valid(detail, h);
>  	if (rv !=3D -EAGAIN) {
>  		write_unlock(&detail->hash_lock);
> +		clear_bit(CACHE_PENDING, &h->flags);
> +		cache_revisit_request(h);

This should just be cache_fresh_unlocked(), as below.
>  		return rv;
>  	}
>  	set_bit(CACHE_NEGATIVE, &h->flags);
>  	cache_fresh_locked(h, seconds_since_boot()+CACHE_NEW_EXPIRY);
>  	write_unlock(&detail->hash_lock);
> +	clear_bit(CACHE_PENDING, &h->flags);
Clearing this bit is wrong  - cache_frsh_unlocked will do that.

>  	cache_fresh_unlocked(h, detail);
>  	return -ENOENT;
>  }
So maybe:

static int try_to_negate_entry(....)
{
	int rv;

	write_lock(&detail->hash_lock);
	rv =3D cache_is_valid(detail, h);
	if (rv =3D=3D -EAGAIN) {
		set_bit(CACHE_NEGATIVE, &h->flags);
		cache_fresh_locked(h, ....);
		rv =3D -ENOENT;
	}
	write_unlock(&detail->hash_lock);
	cache_fresh_unlocked(h, detail);
	return rv;
}
????


> @@ -275,8 +278,6 @@ int cache_check(struct cache_detail *det
>  		if (!test_and_set_bit(CACHE_PENDING, &h->flags)) {
>  			switch (cache_make_upcall(detail, h)) {
>  			case -EINVAL:
> -				clear_bit(CACHE_PENDING, &h->flags);
> -				cache_revisit_request(h);
>  				rv =3D try_to_negate_entry(detail, h);
>  				break;
>  			case -EAGAIN:

Yes, those lines should definitely be removed.

So maybe this against mainline:

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 9afa439..7296644 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -228,12 +228,11 @@ static int try_to_negate_entry(struct cache_detail *d=
etail, struct cache_head *h
=20
 	write_lock(&detail->hash_lock);
 	rv =3D cache_is_valid(detail, h);
-	if (rv !=3D -EAGAIN) {
-		write_unlock(&detail->hash_lock);
-		return rv;
+	if (rv =3D=3D -EAGAIN) {
+		set_bit(CACHE_NEGATIVE, &h->flags);
+		cache_fresh_locked(h, seconds_since_boot()+CACHE_NEW_EXPIRY);
+		rv =3D -ENOENT;
 	}
-	set_bit(CACHE_NEGATIVE, &h->flags);
-	cache_fresh_locked(h, seconds_since_boot()+CACHE_NEW_EXPIRY);
 	write_unlock(&detail->hash_lock);
 	cache_fresh_unlocked(h, detail);
 	return -ENOENT;
@@ -275,13 +274,10 @@ int cache_check(struct cache_detail *detail,
 		if (!test_and_set_bit(CACHE_PENDING, &h->flags)) {
 			switch (cache_make_upcall(detail, h)) {
 			case -EINVAL:
-				clear_bit(CACHE_PENDING, &h->flags);
-				cache_revisit_request(h);
 				rv =3D try_to_negate_entry(detail, h);
 				break;
 			case -EAGAIN:
-				clear_bit(CACHE_PENDING, &h->flags);
-				cache_revisit_request(h);
+				cache_fresh_unlocked(h, detail);
 				break;
 			}
 		}


Is that convincing?

Thanks a lot for your very thorough analysis!

NeilBrown

--Sig_/X7yfFLKhhBhdIEMShQpAby_
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUSQ+QDnsnt1WYoG5AQKLgg//X9NyY8jO1LI9zRfrneCDkljA/5tn6JqF
r6F7nFadWSfwSMdb1B/f/vfZVZKt14UdMUvs/FcAvMkYW2qrKMAnFIcJrwcR3L69
JrMXVaYbg9Jvq0khDjxmYUwGDRDILR9KAsHAJ5LVvDSa0ttqYFUaI2wtXAEopOn5
uEvW3K2QIh+l9DL0Fn94NeSR6bGXXQtwl9VkOABylW7aUi3haZnN3SxFUMZAODJh
2LTGexuFJqe7qLuuKzkAPXkvJr8ICtZwroZTJTKW/pbwxrCetRtzTw2LJg4dMjcn
vhwrNOImBZtLAvoAKQk+LU9GzB6tIxkvXPQ0QhOL9/xi5vNYgFKX800BSPSwXv4y
1csqQH06Av0BLqDLPEfQsEomROdDGqpmAP+bvN0rEVf2TM9ITDd+4TIrOukF1qyc
OriBq5dIpPj2LEXQm0Wjkb1szZ7JMgGvtrzu3zJ1wSgmnDWEaQ+eMt3sBNKY+yZD
e+Vmi7aQL8BhrhnAp+ANaiEUXXwnEMC2hwWQToDvhbWxiiwLK8YrDyAeQllv3MN1
w6vfiuh4sMy222syTDcbCSJteyz9IWXEV4NKcfpY7ay0G8qw3PM9GcASASPXhBen
bikDWQJDqprYtKp43GwTNGDfX2i8SmwJWjQ0jnBDY6EHRANhpoa0MCoTHkM1brvq
S9XMMw5COnU=
=r9+M
-----END PGP SIGNATURE-----

--Sig_/X7yfFLKhhBhdIEMShQpAby_--

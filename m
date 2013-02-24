Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52092 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759345Ab3BXXrh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 24 Feb 2013 18:47:37 -0500
Date: Mon, 25 Feb 2013 09:52:41 +1100
From: NeilBrown <neilb@suse.de>
To: Bodo Stroesser <bstroesser@ts.fujitsu.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] sunrpc.ko: RPC cache fix races
Message-ID: <20130225095241.7e2313af@notabene.brown>
In-Reply-To: <61eb00$3f9tb7@dgate20u.abg.fsc.net>
References: <61eb00$3f9tb7@dgate20u.abg.fsc.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/=27/O6fye5Ujn=WLkfhNXlf"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/=27/O6fye5Ujn=WLkfhNXlf
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On 21 Feb 2013 16:44:41 +0100 Bodo Stroesser <bstroesser@ts.fujitsu.com>
wrote:

> On 21 Feb 2013 00:55:00 +0100 neilb@suse.de wrote:
>=20
> > On 20 Feb 2013 14:57:07 +0100 bstroesser@ts.fujitsu.com wrote:
> >=20
> > > On 20 Feb 2013 04:09:00 +0100 neilb@suse.de wrote:
>=20
> snip
>=20
> > > > Maybe:
> > > >=20
> > > >   switch(cache_make_upcall(detail, h)) {
> > > >   case -EINVAL:
> > > >         if (rv) {
> > > > 		set_bit(CACHE_NEGATIVE, &h->flags);
> > > > 		cache_fresh_locked(h, get_seconds() + CACHE_NEW_EXPIRY);
> > > > 		rv =3D -ENOENT;
> > > > 	}
> > > > 	/* FALLTHROUGH */
> > > >   case -EAGAIN:
> > > > 	cache_fresh_unlocked(h, detail);
> > > >   }
> > >=20
> > > I agree, your patch is obviously better than the mine.
> > > But let me suggest one little change: I would like to substitute
> > > cache_fresh_unlocked() by clear_bit() and cache_revisit_request(),
> > > as the call to cache_dequeue() in cache_fresh_unlocked() seems to
> > > be obsolete here:
> >=20
> > It is exactly this sort of thinking (on my part) that got us into this =
mess
> > in the first place.  I reasoned that the full locking/testing/whatever =
wasn't
> > necessary and took a short cut.  It wasn't a good idea.
>=20
> Maybe I'm totally wrong, but AFAICS, calling cache_dequeue() here in extr=
eme
> situations (two threads in parallel calling check_cache() while a first r=
eader
> is going to open cache access) could again cause a race (?)

Can you explain the race you see?

>=20
> BTW: if there is a reader for a cache, is there any protection against ma=
ny
> upcalls being queued for the same cache entry?

The CACHE_PENDING flag should provide that protection.  We only queue an
upcall after "test_and_set", and always dequeue after "clear_bit".

NeilBrown


>=20
> Bodo
>=20
> >=20
> > Given that this is obviously difficult code to get right, we should mak=
e it
> > as easy to review as possible.  Have "cache_fresh_unlocked" makes it mo=
re
> > obviously correct, and that is a good thing.
> > Maybe cache_dequeue isn't needed here, but it won't hurt so I'd much ra=
ther
> > have the clearer code.
> > In fact, I'd also like to change
> >=20
> > 			if (test_and_clear_bit(CACHE_PENDING, &ch->flags))
> > 				cache_dequeue(current_detail, ch);
> > 			cache_revisit_request(ch);
> >=20
> > near the end of cache_clean to call  cache_fresh_unlocked().
> >=20


--Sig_/=27/O6fye5Ujn=WLkfhNXlf
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUSqZuTnsnt1WYoG5AQI2rRAAnNubWuJ4dwl9WwVS6j2FupZ16D4Xo8xj
LYaIRUS7J3+Jy0M9o8YwEsZXgjr74n1Ou4SQjBmS64nlX5Mvqh6txMSAqsMucKO9
4LjLgoJl1PDpnGFpcL1Tash5XnpYxa9hc3wU3QxIrTvwIsxtdFzQlFJQjA7rEO4X
Cf0DcZPHt6lCJ2mkbEdDOA/fXTB4GgyFrutGIJ5xsJvUlWSLCJ4lHiwpjJVMAP2q
k7gcyDK0dV5KTEiELLODQq20IkkgrcOUIEjRtqm9ue4PLPaQFBXfO9olJ25PraSN
YQOkYaQgBPdczJeRk62gkBkjqB68uWdKwClqo80vsA3u/FhRp/WKzj/rwk6nPjMF
X18ken+/iK7wOQFaj4TSKz8HL1GRXZYp1P8qOH1Ckig0HzLXwZ87ZY1NpN5KSbcV
tdzd4Uph12Wib4lJ4uJl1a6iug0Ofj/N6lTzebB6wWyTGTm01OOUj2YdNguGpBRY
pihEhvb/Da2IwK3ZYMogej8gumRwJsYEovh6EswavkXVnKT47f363V0j56mPoHAv
npQOEhRUpHw8qpnzn9hPL5hq4RpI5Ud5YJUY2T4hRvMDv6bQd+v0PeHBiRIiW6jN
Nl+D6QsZWZA7D0POQwmiGtna73gCv0vSSIiK7whSae9a58sRjJENmzo4DESMsC6N
MhxP331gJns=
=ajzk
-----END PGP SIGNATURE-----

--Sig_/=27/O6fye5Ujn=WLkfhNXlf--

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:50450 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755984Ab3BZC4R (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Feb 2013 21:56:17 -0500
Date: Tue, 26 Feb 2013 13:56:07 +1100
From: NeilBrown <neilb@suse.de>
To: Bodo Stroesser <bstroesser@ts.fujitsu.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] sunrpc.ko: RPC cache fix races
Message-ID: <20130226135607.65d8d676@notabene.brown>
In-Reply-To: <d6437a$43j82m@dgate10u.abg.fsc.net>
References: <d6437a$43j82m@dgate10u.abg.fsc.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/nLd/uKrkXbKITPj7E9uMTub"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/nLd/uKrkXbKITPj7E9uMTub
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On 25 Feb 2013 20:55:50 +0100 Bodo Stroesser <bstroesser@ts.fujitsu.com>
wrote:

> On 24 Feb 2013 23:53:00 +0100 neilb@suse.de wrote:
>=20
> > On 21 Feb 2013 16:44:41 +0100 Bodo Stroesser <bstroesser@ts.fujitsu.com>
> > wrote:
> >=20
> > > On 21 Feb 2013 00:55:00 +0100 neilb@suse.de wrote:
> > >=20
> > > > On 20 Feb 2013 14:57:07 +0100 bstroesser@ts.fujitsu.com wrote:
> > > >=20
> > > > > On 20 Feb 2013 04:09:00 +0100 neilb@suse.de wrote:
> > >=20
> > > snip
> > >=20
> > > > > > Maybe:
> > > > > >=20
> > > > > >   switch(cache_make_upcall(detail, h)) {
> > > > > >   case -EINVAL:
> > > > > >         if (rv) {
> > > > > > 		set_bit(CACHE_NEGATIVE, &h->flags);
> > > > > > 		cache_fresh_locked(h, get_seconds() + CACHE_NEW_EXPIRY);
> > > > > > 		rv =3D -ENOENT;
> > > > > > 	}
> > > > > > 	/* FALLTHROUGH */
> > > > > >   case -EAGAIN:
> > > > > > 	cache_fresh_unlocked(h, detail);
> > > > > >   }
> > > > >=20
> > > > > I agree, your patch is obviously better than the mine.
> > > > > But let me suggest one little change: I would like to substitute
> > > > > cache_fresh_unlocked() by clear_bit() and cache_revisit_request(),
> > > > > as the call to cache_dequeue() in cache_fresh_unlocked() seems to
> > > > > be obsolete here:
> > > >=20
> > > > It is exactly this sort of thinking (on my part) that got us into t=
his mess
> > > > in the first place.  I reasoned that the full locking/testing/whate=
ver wasn't
> > > > necessary and took a short cut.  It wasn't a good idea.
> > >=20
> > > Maybe I'm totally wrong, but AFAICS, calling cache_dequeue() here in =
extreme
> > > situations (two threads in parallel calling check_cache() while a fir=
st reader
> > > is going to open cache access) could again cause a race (?)
> >=20
> > Can you explain the race you see?
>=20
> O.k., let me try ...
>=20
> Suppposed there are 2 threads calling cache_check concurrently and a
> user process that is going to become a reader for the involved cache.
>=20
> The first thread calls cache_is_valid() and gets -EAGAIN.
> Next, it sets CACHE_PENDING and calls cache_make_upcall(), which
> returns -EINVAL, as there is no reader yet.
>=20
> Meanwhile the second thread also calls cache_is_valid(), also gets
> -EAGAIN, but now is interrupted and delayed for a while.
>=20
> The first thread continues its work, negates the entry and calls
> cache_fresh_locked() followed by cache_fresh_unlocked().
> In cache_fresh_unlocked it resets CACHE_PENDING and calls
> cache_revisit_request(). While this, it is interrupted and delayed.
>=20
> The user process is scheduled and opens the channel to become a reader.
>=20
> The second thread wakes up again and sets CACHE_PENDING. Next it calls
> cache_make_upcall(), which results in a request being queued, as there
> is a reader now.
>=20
> The first thread wakes up and continues its work calling cache_dequeue().
> Maybe the request is dropped before the reader could process it.
>=20
> Do you agree or did I miss something?

Yes, I see what you mean, thanks.

I would close that race with:
@@ -1022,6 +1016,9 @@ static void cache_dequeue(struct cache_detail *detail=
, struct cache_head *ch)
 			struct cache_request *cr =3D container_of(cq, struct cache_request, q);
 			if (cr->item !=3D ch)
 				continue;
+			if (test_bit(CACHE_PENDING, &ch->flags))
+				/* Lost a race and it is pending again */
+				break;
 			if (cr->readers !=3D 0)
 				continue;
 			list_del(&cr->q.list);

>=20
>=20
> >=20
> > >=20
> > > BTW: if there is a reader for a cache, is there any protection agains=
t many
> > > upcalls being queued for the same cache entry?
> >=20
> > The CACHE_PENDING flag should provide that protection.  We only queue an
> > upcall after "test_and_set", and always dequeue after "clear_bit".
>=20
> Sorry, my question wasn't very clear. CACHE_PENDING *does* provide the
> protection against parallel upcalls.
>=20
> OTOH, as cache_is_valid() is called before test_and_set_bit(CACHE_PENDING)
> and then the upcall is made without again calling cache_is_valid(),
> I see a small chance of a second request being queued unnecessarily just
> after the first request was answered.=20

A small chance, yes.  However  I don't think it is harmful, just unnecessar=
y.
So I'm not sure it is worth fixing.

Thanks,
NeilBrown


>=20
> Bodo
>=20
> >=20
> > NeilBrown
> >=20
> >=20
> > >=20
> > > Bodo
> > >=20
> > > >=20
> > > > Given that this is obviously difficult code to get right, we should=
 make it
> > > > as easy to review as possible.  Have "cache_fresh_unlocked" makes i=
t more
> > > > obviously correct, and that is a good thing.
> > > > Maybe cache_dequeue isn't needed here, but it won't hurt so I'd muc=
h rather
> > > > have the clearer code.
> > > > In fact, I'd also like to change
> > > >=20
> > > > 			if (test_and_clear_bit(CACHE_PENDING, &ch->flags))
> > > > 				cache_dequeue(current_detail, ch);
> > > > 			cache_revisit_request(ch);
> > > >=20
> > > > near the end of cache_clean to call  cache_fresh_unlocked().
> > > >=20


--Sig_/nLd/uKrkXbKITPj7E9uMTub
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUSwkRznsnt1WYoG5AQJ1QA//QxyxGzR2mXvLdFjnozEAuvu1aB8aZfza
oTeKisY1ZyDtwxu+1F0SlmHlRJosEpYDj7Ye7KwV5TQZVDpubEGSgxSwHZlGdwqZ
fng1CocIEQbQBwf1vyKparXY/GA11eSz6+St0VipwnYVWWRW+8DmPVpsNBo73Te8
+YXIzwc6Lv53iGM8auuJzMMW/jHeS0tN+SE5qgVVXduQnuj9rcLQjNJwxDp/p5v0
LchmMCs/Szz/cSsPsBeNlVqMSQw7tBU3WWJSngLb3xdZ41ferIOZDJTu8A4WHsNA
kulirCjQ/KVBA3lCOZ4ct6iWh6CWFszW/5dDRFTBiVovAhPOnqoFQSfDMkhC4h4X
kJ69lXZ7k0CNYWqMS2We9+terKUJvUMH7X3aNSvZTX+lrb82Ebn84uO9glyFiu7T
lKcVNX7N9hjODP1Zp5K8lArMq4pQFPYJzSJHNzwVSL8I5SJrj15xj1uvhfxjwq/N
YVGbYFQpj/NCIFnzbNjFiPdjOoVrVbHPt0SLoY5Fa2Ks+x8DDGarXcGguw9mCyhO
7Ai2BnUp+uxqUPU23SChwPx1St+SrieFnOkP2V/8wx5IQtMUC1MyBkTGNXv9YxLV
R+kEM+U7LDLnD9eRfkmXGbzIkLiKvuE1ok+SfoYzcjWdtv1xqCvQ5BWO2Ig0BxRo
OXIfbRqKnmU=
=JZ08
-----END PGP SIGNATURE-----

--Sig_/nLd/uKrkXbKITPj7E9uMTub--

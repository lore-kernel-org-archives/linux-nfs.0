Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:57863 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752033Ab3B0XYf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Feb 2013 18:24:35 -0500
Date: Thu, 28 Feb 2013 10:24:25 +1100
From: NeilBrown <neilb@suse.de>
To: Bodo Stroesser <bstroesser@ts.fujitsu.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] sunrpc/cache: remove races with queuing an upcall.
Message-ID: <20130228102425.7c272699@notabene.brown>
In-Reply-To: <61eb00$3fkshf@dgate20u.abg.fsc.net>
References: <61eb00$3fkshf@dgate20u.abg.fsc.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/UjxLJ.kwlDrB+A.jOrXrCPG"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/UjxLJ.kwlDrB+A.jOrXrCPG
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On 26 Feb 2013 15:02:01 +0100 Bodo Stroesser <bstroesser@ts.fujitsu.com>
wrote:

> On 26 Feb 2013 07:37:00 +0100 NeilBrown <neilb@suse.de> wrote:
>=20
> > We currently queue an upcall after setting CACHE_PENDING, and dequeue a=
fter clearing CACHE_PENDING.
> > So a request should only be present when CACHE_PENDING is set.
> >=20
> > However we don't combine the test and the enqueue/dequeue in a protecte=
d region, so it is possible (if unlikely) for a race to result in a request=
 being queued without CACHE_PENDING set, or a request to be absent despite =
CACHE_PENDING.
> >=20
> > So: include a test for CACHE_PENDING inside the regions of enqueue and =
dequeue where queue_lock is held, and abort the operation if the value is n=
ot as expected.
> >=20
> > With this, it perfectly safe and correct to:
> >  - call cache_dequeue() if and only if we have just
> >    cleared CACHE_PENDING
> >  - call sunrpc_cache_pipe_upcall() (via cache_make_upcall)
> >    if and only if we have just set CACHE_PENDING.
> >=20
> > Reported-by: Bodo Stroesser <bstroesser@ts.fujitsu.com>
> > Signed-off-by: NeilBrown <neilb@suse.de>
>=20
> Sorry, I don't agree with this patch, as it fixes the first scenario of m=
y mail
> from 24 Feb 2013, but AFAICS changes the second one (which has been a min=
or
> point that didn't need fixing necessarily) to a memory leak.
>=20
> I'll try to expain my doubts:
>=20
> Again, assume two threads calling cache_check() concurrently for the same=
 cache
> entry of a cache that has a reader.
> Both threads get result -EAGAIN from cache_is_valid(). The second thread =
at that
> moment is interrupted and suspended for a while.
> The first thread sets CACHE_PENDING and queues an upcall request and slee=
ps
> waiting for the reply.
> The reader reads the request and replies accordingly. In sunrpc_cache_upd=
ate()
> the reader changes the entry to CACHE_VALID and calls cache_fresh_unlocke=
d().
> In cache_fresh_unlocked() it resets CACHE_PENDING. At this moment it is
> interrupted and suspended.
> Now the second thread wakes up, sets CACHE_PENDING again and queues a new=
 upcall
> request.
> The reader wakes up and sees, that CACHE_PENDING is set again and does not
> dequeue the old request. --> memory leak (?)

Yes, I think you are right.

>=20
> In my opinion, there are two possible fixes that could replace this patch:
>=20
> 1) Don't call cache_dequeue() from cache_check(). Trying to dequeue somet=
hing
>    even if we know, that we haven't queued, looks strange to me. (And yes=
, I
>    understand the reason, why you don't like it, but nevertheless I consi=
der
>    this the best solution.)

The reason for calling cache_dequeue() is that someone else might have queu=
ed
something.  We are the last to leave so we turn out the lights - doesn't
matter that we didn't turn them on.

So I think the correct fix to the leak is to remove the "return" near the e=
nd
of cache_dequeue().
i.e. whoever clears CACHE_PENDING must remove all entries from the queue.  =
If
someone else sets CACHE_PENDING they might not succeed, but it doesn't matt=
er
as then someone else will come along and remove all the entries.

>    This one would fix my first scenariop only, but not the second.
>=20
> 2) I think, the starting point of all trouble is in cache_check().
>    Currently, if a thread has set CACHE_PENDING, is works using a=20
>    possibly no longer valid state of the cache entry (rv).
>    AFAICS, it would fix most of the problems to re-check the
>    cache entry's state between setting CACHE_PENDING and the upcall.
>    The upcall should be done only, if still necessary.
>    This one could be combined with a new bit in the entry's state, that is
>    set if a valid entry is updated (that is: replaced). Checking this
>    bit also immediately before cache_make_upcall() is called would
>    also fix my second scenario fully in that it avoids unnecessary
>    upcalls.

Repeating the tests after setting CACHE_PENDING wouldn't hurt, but in almost
all cases it wouldn't help either.  The races that could result in a second
unnecessary up-call are extremely unlikely.  So I think the best approach is
not trying to avoid them, but making sure that they don't cause any harm.
This is best done with safe programming practices, like the "last one out
turns out the lights" pattern. =20
The "return" which I suggest removing is really a premature optimisation
which should never have been included.  Without it we should be completely
safe.

??

NeilBrown


--Sig_/UjxLJ.kwlDrB+A.jOrXrCPG
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUS6VqTnsnt1WYoG5AQJ2lBAAiEYujnFIZX4WVnvNvT+sdqKpzsPU0TNU
fraYZ93hJDf7aLfqymS1yn23/wrGSHSJ5uFFxfEuQttpOgjS8I8t/TUCLK7cA5hr
B3kMqN760aF3dVHktUj3TJJ6mL/wlFnqCSVeeXfbThhI1s21q3cMGFTmsj8RyV6a
FyBz6FiHqrB5UETmPd3bb5dfKtPrwCg/ffppmseYW7deCvD9ns42192CiqoVUN31
C0pmqRFkaVxr+wv2/UYxejdFygGSHVgwCMmmiSgBvXBjZ2lYraelNdIqNsHcDsgQ
o2kdV8ggp+mGefzlHSPGJ3VKXcFx479wMWNmoNPz19yjzW448NAZ43YapNOlOjlr
KFghgfn7Y/kDWEDZzLhPTbEzLcppFczowTllw7DXRW34C9+0D6pJZQ+l8KVH9JRJ
VGz37Hf6RlGkSX2HZYvY1w3dW+73e179VvSeH5g6syS5ddNL6dyhdQGYNgTvLkQg
m0mQ0IEs4C8eBYaCTKCb03fqmOJXCXS3tfjKr92tDWc9Udbx42DYyJkC/B+jMzAg
wD9ZRcOA9RMRt40hWiTvJZA/mpB6ny21VQwzCj8zsMuwdoahh3D8MJtq6fnEjyTY
IdtDcl5yMWpPkiRJMadv+pmb8UjCA1nAomRpeWZJ7ns2Yp6OQotVYwPWfXHDIcBi
qy1QiJTb3bc=
=jZyz
-----END PGP SIGNATURE-----

--Sig_/UjxLJ.kwlDrB+A.jOrXrCPG--

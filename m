Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:46837 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751866AbaDCVWL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Apr 2014 17:22:11 -0400
Date: Fri, 4 Apr 2014 08:21:54 +1100
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Boaz Harrosh <openosd@gmail.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: Should exportfs/mountd cope with case-insensitive directory
 names.
Message-ID: <20140404082154.4cfdab5a@notabene.brown>
In-Reply-To: <20140403172431.GB5884@fieldses.org>
References: <20140403164652.5d7770ad@notabene.brown>
	<20140403130909.GA24700@fieldses.org>
	<533D8629.10907@gmail.com>
	<20140403171625.GA5884@fieldses.org>
	<20140403172431.GB5884@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/M4Hr70D8KLib147xqXVms5u"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/M4Hr70D8KLib147xqXVms5u
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 3 Apr 2014 13:24:31 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Thu, Apr 03, 2014 at 01:16:25PM -0400, J. Bruce Fields wrote:
> > In the presence of bind mounts it's definitely possible for two
> > different paths to reach the same directory.
> >=20
> > I don't know if that's actually a problem here....
>=20
> Without testing: if we've got the same filesystem mounted at /foo/bar
> and /foo/baz, but only export /foo/bar, will this change make that
> export show up at /foo/baz as well?
>=20
> (Since we'll now consider /foo/bar and /foo/baz to match where
> previously they didn't?)

Good question.  I should test, but I suspect "yes".  I'm not really happy
about that.

Maybe we could use name_to_handle_at().  That returns the mnt_id
which is different for different bind mounts.
So if the mnt_id and the handle are the same, it is the same directory.  If
not, then not.

I did worry a bit about all the extra stat calls, but as you say: they are
cached so it shouldn't be a big problem.

It would  make sense to stat (or name_to_handle_at) the name from the kernel
just once, then compare the value against everything in the export table.

We could possible store handles in the export table, but then we would need
to check for changes to mountinfo (I think 'poll' can do that) and clear out
the cache whenever a mount changes.

I might play with some code if I find time...

Thanks,
NeilBrown

--Sig_/M4Hr70D8KLib147xqXVms5u
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUz3Q+Dnsnt1WYoG5AQISERAAg681vh5NE723ay98BohSxwmrGalCPXwe
rNmNjupvVUWY8ZxT1J4YF9kHxOowAQF6UQe/QTaTKh2Cey0RYnx1d6NP9FD4I5Jo
f9+zGp91aUJEHd0R0a6tPH7Q6FBru7yn3XaqLorBkOWTYR24uWkhP7sM07xp0qXf
7jbkRnbT46GhhvYvWKqMHvjj7nCL2GF7bgA2V3CocQB5zPwHI36FpscwK1kjd+vB
vnyBBe+AJ+hcrKgQZDLteMg5g2n7T/t4gYVBWeyHav3UgMcwQRARnuU5SLksXlT+
omSpzuMTO54RG0u1m2jMEiKetjMqwXhq9oJ6GHQB//LGgISVs913F8jGw8PanAEc
wnQqWVDW+kNcocUD9ATaJG/0g87TPsykcj2kcj62dSo/dSr8L4gmU2bWCp/IMRkC
elfZzYeUiMPQ7aGJ8B/QnXWpWk6QqpcNZgp1779tXdoSv6ScSIoWg8Md4pb31X9n
qb4a+AbNkm+IG1zZ/fb/mQHAUgU3iWvpWWzhb2OLUb0HuqhKmJWq03QMzC+pKZTZ
hJ5bg5ys0+qmrioxVMQ2kj4m1IFFWFvUkwSIVMkU1/vOazxi4RNOLJDx/zwqN4iK
1d3Gvc8diT5lKo5yNh21bpFSuGaFReexWBGIi2NdY6BIoMuk7pHLjIBveBkUdWKk
sPDyWIkC65M=
=Cruv
-----END PGP SIGNATURE-----

--Sig_/M4Hr70D8KLib147xqXVms5u--

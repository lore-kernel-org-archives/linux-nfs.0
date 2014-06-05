Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:46571 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754506AbaFEAeb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jun 2014 20:34:31 -0400
Date: Thu, 5 Jun 2014 10:34:23 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Live lock in silly-rename.
Message-ID: <20140605103423.43e21569@notabene.brown>
In-Reply-To: <20140604220531.GA8362@fieldses.org>
References: <20140529164521.02324559@notabene.brown>
	<CAHQdGtTtU9_zBcfzRb_wmEf7XaX9rNg-_Q85ZLX9BYax14D2Gg@mail.gmail.com>
	<20140530075135.753fb7ed@notabene.brown>
	<20140530004423.GA13746@fieldses.org>
	<20140530134442.5a8e5983@notabene.brown>
	<20140530215522.GA27615@fieldses.org>
	<20140531081358.62ae69b3@notabene.brown>
	<20140604173926.53918af3@notabene.brown>
	<20140604220531.GA8362@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/ak8nWgI6Sgn3CNBEatBYI3h"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/ak8nWgI6Sgn3CNBEatBYI3h
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 4 Jun 2014 18:05:31 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Wed, Jun 04, 2014 at 05:39:26PM +1000, NeilBrown wrote:
> > Below is my suggestion.  It seems easy enough.  It even works.
>=20
> Woah!
>=20
> Anyway, looks reasonable to me, and it fixes an immediate problem so I'm
> inclined to just apply.
>=20
> The vfs knows about delegations at this point, and there's been this
> vague idea we might give user space servers request them at some point,
> so we might eventually want this code to fs/locks.c instead of here.
>=20
> Wonder if filehandle is the right thing to hash on, as opposed to inode
> number, or inode pointer, or something else?

I pondered that question for a short while too.

inode number didn't seem right as you might export two filesystems with the
same inode numbers.
inode pointer didn't seem right as it could fall out of the cache and
something else could be loaded in the same place.

filehandle isn't perfect as it isn't 100% unique (you can have two
filehandles with different 'types' for the one inode).  But I felt it was
close enough in practice.

superblock pointer plus inode number plus inode generation number would
probably be perfect, but that is so close to the filehandle which was alrea=
dy
easily available, it seems silly not to just use filehandle.

Certainly if the code ever wants to move to locks.c, the question can be
revisited.

And if you are going to apply it, you'll want:

   Signed-off-by: NeilBrown <neilb@suse.de>

I forgot that in the original.

Thanks,
NeilBrown

--Sig_/ak8nWgI6Sgn3CNBEatBYI3h
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU4+7Dznsnt1WYoG5AQK7hxAAok3meN5mjZZYkwUZE7mf6za0XMx4A7pz
8BSDvK+qyr5NzHhKcrZxKbVjhTNTMWYF7RdlOGLVzQPNomYW32z3aZo0Wq8NGGRt
ZrO1+m4A1wSzdM2u4tLqxVMqOTTKq94lsAaqPEqJG8Uz/IhvIqxUv3lB+xMkXzlp
c3HkktDrs/O70LQDP+IWopli/XE6sXV2exeQHGCIGvJRq0AQkUvAosK1UgOaLGSP
fL7cFlb9AYp/USkBvR2ADR1Xtz9ASwpwiPx64+sQnxbByQO2/BNDmWgDlpkjM+4M
wwISrYBTb/cy8UYcwRaWHGnr8snxckuOCY8/eyyRxyfXnJ+MsiV77JEwi4a3tWvs
PtjPj4tLA7l+oYDlaLJzH0CrqINODSCOHLraXtVEwloLrjJtr3eYjBO3+hzncjZA
udqKc/5nUkbZo0Vcky84+Zeaa2j6OYW2xNPmgS/4NOtyIYLoM9Jnoo5EW5NvLZyr
3IGOTQYscMvzqCxkNb/GFL1RinmVx+qApAvV8xhlL53dKz0Ms+h10LLSuciGshBX
6WpwF0NUXBtLeBM4knFCGifVle/8REQmO74nC7h7bx+w5oQIa3RSpYB3X7zBaWvi
OkkcMGyEKPohJoUVhVDv6FsT3mMjHUVvbh7PNbV1LGExl1lk4/GuXFVNXKWtovFs
VgvpcndG204=
=B6aW
-----END PGP SIGNATURE-----

--Sig_/ak8nWgI6Sgn3CNBEatBYI3h--

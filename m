Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:41876 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751561AbaCaGzG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Mar 2014 02:55:06 -0400
Date: Mon, 31 Mar 2014 17:54:58 +1100
From: NeilBrown <neilb@suse.de>
To: Jeff Layton <jlayton@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: nfsd needs "md5", but fips=1 disables it -> hang
Message-ID: <20140331175458.5f674ac5@notabene.brown>
In-Reply-To: <20140327131132.5fe8ea33@ipyr.poochiereds.net>
References: <20140327205239.2ea29060@notabene.brown>
	<20140327143024.GA27633@fieldses.org>
	<20140327131132.5fe8ea33@ipyr.poochiereds.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/.5p4p+pPTBv+wm27O6.8Zc6"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/.5p4p+pPTBv+wm27O6.8Zc6
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 27 Mar 2014 13:11:32 -0700 Jeff Layton <jlayton@redhat.com> wrote:

> On Thu, 27 Mar 2014 10:30:24 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>=20
> > On Thu, Mar 27, 2014 at 08:52:39PM +1100, NeilBrown wrote:
> > >=20
> > > [I sent this 2 days ago but haven't seen it come back on the nfs
> > >  list and don't see it in the archives.  Maybe someone we cannot
> > > name filtered it because it contains the word 'crypto' ??]
> >=20
> > Huh.

And my email still didn't get to the list, but at least it got to Bruce.
And you replies only got to be directly, not through the list!
Very weird ... I wonder if I care....

> >=20
> > > Apparently there is a thing called "FIPS" which lists some approved
> > > crypto algorithms.  And some sites need to only use those.  So they
> > > boot their kernel with
> > >     fips=3D1
> > > and anything non-fips-approved stops working.
> > >=20
>=20
> Yes. As best I can tell, the primary purpose of FIPS is to render the
> machine unusable for any non-trivial purpose. ;)

I'd notice this wasn't the only thing that broke.  However it appear to be a
thing that we want to support :-(

>=20
> The story I have heard is that FIPS carves out an exemption for the use
> of unapproved crypto as long as it stays "within the
> implementation" (whatever that means).

So it is probably ok to use md5 as long as we don't pretend that we are doi=
ng
crypto (which we aren't)

>=20
> > > "md5" is not fips-approved.
> > >=20
> > > So
> > >=20
> > > 	desc.tfm =3D crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);
> > >=20
> > > in
> > >=20
> > > nfs4_make_rec_clidname(char *dname, const struct xdr_netobj *clname)
> > >=20
> > >=20
> > > always fails when fips=3D1.  This interferes with efficient NFS
> > > service (every 'open' hangs).
> > >=20
> > > s/md5/sha1/
> > >=20
> > > makes this problem go away, because sha1 is fips-approved.
> > >=20
> > > My question is: is this safe, or is the hash value used in some
> > > external way (in /var/lib/nfs/v4recovery ??).
> >=20
>=20
> The hashes aren't used outside the machine and they're not even
> cryptographically significant. The kernel only uses it as a way to
> squash the long-form clientid into something that it can use as a
> directory name.
>=20
> In hindsight, the decision to use md5 for that purpose was
> unfortunate...

Isn't there a book about that .. "A series of unfortunate decisions" ...


>=20
> > Right, it's used in v4recovery, so you'd lose client state when you
> > rebooted the server to the new (SHA1-using) server.
> >=20
> > Our intention was to migrate people that care about FIPS to the umh
> > upcall.  But rhel6 has a hack (a private md5 implementation).
> >=20
> > Cc'ing jlayton (currently traveling) who did that work.
> >=20
>=20
> Yep, exactly.
>=20
> For any newer kernels and nfs-utils, just use nfsdcltrack and don't
> bother with the legacy code. Eventually I can forsee us getting rid of
> the legacy client tracking.

Where "newer" means .... Linux v3.8 and nfs-utils 1.2.7.
I'll keep that in mind for future releases then, thanks.


>=20
> > >=20
> > > If changing the hash to sha1 is safe, we should do that and
> > > probably add select CRYPTO_SHA1
> > > to Kconfig just to be safe.
> > >=20
> > > If we really need to keep it stable, I guess we need to find a way
> > > to perform md5 computations that bypasses the fips checks.
>=20
> For RHEL6 I just made a private md5 implementation. I had considered
> switching it to sha1 instead, but the problem is that you'll lose
> persistent state if you upgrade the kernel and it switches the hashing
> implementation.
>=20

Sounds like a plan ... thanks for the help.

NeilBrown

--Sig_/.5p4p+pPTBv+wm27O6.8Zc6
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUzkRQjnsnt1WYoG5AQKQBA//SpHt078se0nKguk1MUW03T18sm0/fUmz
72drhQW8wt5VKh2UmIOZ5Y5JiwuFWDe325qxb3inpGfEI8k+di4RxF3/kpzTK6EG
YDyIQsTIALk7Wzms0y0AXy9tPAjz1bTlDWeHTvMH8/iYeRFLQWEkjkOAW6bV0mFc
amstzZvIUeWndMv7ztr9Y4DzUA6iGpcJ3okz01NYmWth3aRaym9nozH5YrCCDYZ6
QJjQqjAJdlgsDjnclhjCO5RPOXBCArRjNOKCm3PEgHZ1zA4Or8iGk7SDJt7zoB0Z
GOuX3syFCXw4lLCkZoqSowZ9mXT1ebvWe4E7dobMfpMzks2Cl2rzx7a0SZ2qtjKT
KPKygubbHV07aOi3/MzLVev6/8hZbcL4VDmi04RPukXWqufQE7RF6Tadv9N+283A
JkHu0p0wK0NXFDfJkzHU1+WU9ddVecI2F6H1zbnM/NbPNn5Uq0v2yQe9mLpEi4fP
L+TWSFcZou3aC7malKC2QssQT9AY4aMiljc5sWFIYU/9pf0b8+H1vcKCqH1PCPRb
zuMTZ6Tw6D0UoiG3k88UIONaZLsLmWw8YNu+QSQXuutBExNKDUzlNQv4jdzy4cWQ
iO8EXuytX9kfMrf/HVLUifMiv3rpttJ2Ciat3mNg2cRHdwU4Grkat2He1sx4T2zh
ODOaOLXwAZs=
=e731
-----END PGP SIGNATURE-----

--Sig_/.5p4p+pPTBv+wm27O6.8Zc6--

From: Timo Sirainen <tss@iki.fi>
Subject: Re: inode caching
Date: Wed, 28 May 2008 18:20:57 +0300
Message-ID: <1211988057.3904.304.camel@hurina>
References: <1211835499.3904.231.camel@hurina> <483C031B.80601@redhat.com>
	 <1211902848.3904.279.camel@hurina> <483C4E61.7020102@redhat.com>
	 <0BF144BC-6CBB-49FA-8F49-D765FB58AF5E@iki.fi>
	 <483CEFD5.8050507@panasas.com>  <20080528135935.GA17606@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-4S9mQgSd12fFyjv1gNP5"
Cc: Benny Halevy <bhalevy@panasas.com>,
	Peter Staubach <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dovecot.org ([82.118.211.50]:43653 "EHLO dovecot.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752442AbYE1PVA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 May 2008 11:21:00 -0400
In-Reply-To: <20080528135935.GA17606@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-4S9mQgSd12fFyjv1gNP5
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-05-28 at 09:59 -0400, J. Bruce Fields wrote:
> On Wed, May 28, 2008 at 08:38:29AM +0300, Benny Halevy wrote:
> > On May. 27, 2008, 22:13 +0300, Timo Sirainen <tss@iki.fi> wrote:
> > > I'd still like to understand why exactly this happens though. Maybe =20
> > > there's a chance that this is just a bug in the current NFS =20
> > > implementation so I could keep using my current code (which is =20
> > > actually very difficult to break even with stress testing, so if this=
 =20
> > > doesn't get fixed on kernel side I'll probably just leave my code as =
=20
> > > it is). I guess I'll start debugging the NFS code to find out what's =
=20
> > > really going on.
> >=20
> > My guess would be that the new incarnation of the inode generates the
> > same filehandle as the old one, not just the same inode number.
>=20
> That sounds like a server bug (either in the server itself, or the
> filesystem it's exporting); the generation number is supposed to prevent
> this.

And if it happens, wouldn't the struct inode on NFS client be the same
for both files then? I'm seeing different results for fstat() calls
(just with the same st_ino).


--=-4S9mQgSd12fFyjv1gNP5
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBIPXhZyUhSUUBViskRAq2HAJ0ZgAuzdSt8p3eitFk4vbiO38ofpACdE478
QbsbGxOjC/nhWpNyB93/spg=
=srIJ
-----END PGP SIGNATURE-----

--=-4S9mQgSd12fFyjv1gNP5--


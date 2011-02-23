Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zak.futurequest.net ([69.5.6.152]:36605 "HELO
	zak.futurequest.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752336Ab1BWOuH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Feb 2011 09:50:07 -0500
Date: Wed, 23 Feb 2011 08:50:04 -0600
From: Bruce Guenter <bruce@untroubled.org>
To: linux-nfs@vger.kernel.org
Subject: Re: Invisible file problem
Message-ID: <20110223145004.GA6747@untroubled.org>
References: <20110222215214.GA32537@untroubled.org>
 <1298447447.2968.8.camel@heimdal.trondhjem.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZPt4rx8FFjLCG7dd"
In-Reply-To: <1298447447.2968.8.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--ZPt4rx8FFjLCG7dd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Feb 22, 2011 at 11:50:47PM -0800, Trond Myklebust wrote:
> There is a known bug in readdir that has been fixed in 2.6.38-rc6, but
> hasn't yet hit the 2.6.37 stable series. Please check the patch at
>=20
> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git&a=3Dco=
mmitdiff&h=3Dd1205f87bbb8040c1408bbd9e0a720310b2b0b9b
>=20
> and see if it fixes your problem.

Yes it did, thank you very much.

--=20
Bruce Guenter <bruce@untroubled.org>                http://untroubled.org/

--ZPt4rx8FFjLCG7dd
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iEYEARECAAYFAk1lHpwACgkQ6W+y3GmZgOjCeQCeJoUIRlHzUFu0qeLHc5PO/Lri
CnQAnihnWKvNN7Q7BZEm8ZPmwvGIqP3z
=HFaB
-----END PGP SIGNATURE-----

--ZPt4rx8FFjLCG7dd--

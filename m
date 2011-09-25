Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58121 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751511Ab1IYIjj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 25 Sep 2011 04:39:39 -0400
Date: Sun, 25 Sep 2011 18:39:30 +1000
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: ANNOUNCE: nfs-utils-1.2.5 released.
Message-ID: <20110925183930.69b33573@notabene.brown>
In-Reply-To: <4E7DD35D.9080800@RedHat.com>
References: <4E7DD35D.9080800@RedHat.com>
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/F62TwiidTLJoY9/k/gau64j"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--Sig_/F62TwiidTLJoY9/k/gau64j
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sat, 24 Sep 2011 08:55:57 -0400 Steve Dickson <SteveD@redhat.com> wrote:

> New Features in this release:
>=20
>    * With the addition of the blkmapd daemon, the client=20
>      now supports every pNFS layout type.=20
>=20
>    * The usual assorted bug fixes.=20
>=20
> The tarball can only be found at Sourceforge.net since=20
> master.kernel.org is still down:
>=20
>   http://sourceforge.net/projects/nfs
>=20
> [ Maybe we should start thinking about putting the rpms on linux-nfs.org?=
? ]
>=20
> The git tree is at:
>    git://linux-nfs.org/nfs-utils
>=20
> The change log is also only on Sourceforge.net:
>=20
> http://sourceforge.net/projects/nfs/files/nfs-utils/1.2.5/Changelog-1.2.5=
/download
>=20

I've packaged this up for openSUSE so it should appear in openSUSE:Factory
and probably openSUSE:Tumbleweed in a day or two.

Only oddity I noticed is that the configure script doesn't check for
libdevmapper.h so I get a complaint when compiling instead of when
configuring.  I don't know if that is a good thing or a bad thing, but I
thought I would mention it.

If my archaeology is right, this is now 4 years and 11 releases
that you have presided over nfs-utils.  Thanks for the ongoing efforts!

Thanks,
NeilBrown


--Sig_/F62TwiidTLJoY9/k/gau64j
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iD8DBQFOfujCG5fc6gV+Wb0RAsH0AKDS76Rb3XQ5VnlluQ0qQbjoI72pBgCg2fg1
Z2kb1GyTlEJSazaExbr6z+Q=
=ckyZ
-----END PGP SIGNATURE-----

--Sig_/F62TwiidTLJoY9/k/gau64j--

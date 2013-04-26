Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.15.15]:53198 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757822Ab3DZJUm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Apr 2013 05:20:42 -0400
Received: from mailout-de.gmx.net ([10.1.76.2]) by mrigmx.server.lan
 (mrigmx002) with ESMTP (Nemesis) id 0MNOMB-1UPMNE1swz-006t9y for
 <linux-nfs@vger.kernel.org>; Fri, 26 Apr 2013 11:20:41 +0200
Message-ID: <517A46E7.1020404@gmx.de>
Date: Fri, 26 Apr 2013 11:20:39 +0200
From: =?UTF-8?B?TWFsdGUgU2NocsO2ZGVy?= <maltesch@gmx.de>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: NFS4 sec=krb5 broken in 3.9-rc8
References: <5176E715.2070201@gmx.de> <20130423215807.GL3676@fieldses.org> <51777494.8010306@gmx.de> <20130424140152.GA9794@fieldses.org> <5178116F.1010608@gmx.de> <20130424192353.GI20275@fieldses.org>
In-Reply-To: <20130424192353.GI20275@fieldses.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2BQALLGAAINHOHCRWLBUT"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2BQALLGAAINHOHCRWLBUT
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 24.04.2013 21:23, J. Bruce Fields wrote:
> On Wed, Apr 24, 2013 at 07:07:59PM +0200, Malte Schr=C3=B6der wrote:
> Probably some of those "svc_process dropit"s are coming from attempts t=
o
> look up the newly created cred (so lookups in the rsc_cache) which fail=

> for some reason.  I'm not sure what that would be.
>=20
> --b.

Hi,
I tried bisecting the problem. It identified
683428fae8c73d7d7da0fa2e0b6beb4d8df4e808 as the problem, reverting it
didn't fix the problem, though. During the process there where some
states where mounting wouldn't hang but be denied. I will try bisecting
again, later.

/Malte


------enig2BQALLGAAINHOHCRWLBUT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlF6RucACgkQ4q3E2oMjYtU5QQCg69zPnfT28hI0MyIBCNJmKvVx
GXwAnRauZYt7m9GaWFCsEdhaF7ua1klQ
=getX
-----END PGP SIGNATURE-----

------enig2BQALLGAAINHOHCRWLBUT--

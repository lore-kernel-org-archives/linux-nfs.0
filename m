Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.15.15]:55554 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753330Ab3DWTzM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Apr 2013 15:55:12 -0400
Received: from mailout-de.gmx.net ([10.1.76.24]) by mrigmx.server.lan
 (mrigmx002) with ESMTP (Nemesis) id 0MUzZb-1U1Dxm40yL-00YTsN for
 <linux-nfs@vger.kernel.org>; Tue, 23 Apr 2013 21:55:08 +0200
Message-ID: <5176E715.2070201@gmx.de>
Date: Tue, 23 Apr 2013 21:55:01 +0200
From: =?ISO-8859-1?Q?Malte_Schr=F6der?= <maltesch@gmx.de>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
CC: linux-kernel@vger.kernel.org
Subject: NFS4 sec=krb5 broken in 3.9-rc8
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2KMLOTBWEQBFAFLRLUUAS"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2KMLOTBWEQBFAFLRLUUAS
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi,
when I update my server from kernel 3.8.5 to 3.9-rc8 I cannot mount its
NFS exports from clients using nfs4 and sec=3Dkrb5. Using sec=3Dsys works=
,
using 3.8.5 also works good with both modes.

Kind regards
Malte Schr=F6der


------enig2KMLOTBWEQBFAFLRLUUAS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlF25xgACgkQ4q3E2oMjYtV4/ACeJiKFsx9Hh7wqii3ORlYUjQyB
xtkAoMq+wFxftNfV5ulPYAsCikCNPcCb
=rcTr
-----END PGP SIGNATURE-----

------enig2KMLOTBWEQBFAFLRLUUAS--

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:48952 "EHLO
        shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756931AbcLNWra (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Dec 2016 17:47:30 -0500
Message-ID: <1481755634.2742.55.camel@decadent.org.uk>
Subject: Re: Bug#847681: improving NFS stability in next Debian release
From: Ben Hutchings <ben@decadent.org.uk>
To: Daniel Pocock <daniel@pocock.pro>, 847681@bugs.debian.org,
        linux-nfs@vger.kernel.org
Date: Wed, 14 Dec 2016 22:47:14 +0000
In-Reply-To: <1786db90-cdec-7959-6897-f78245831f05@pocock.pro>
References: <4415ff5c-98c3-629d-aefd-a5e677688bbb@pocock.pro>
         <1786db90-cdec-7959-6897-f78245831f05@pocock.pro>
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-4uTVH+x8/UdCedtT+iZ3"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-4uTVH+x8/UdCedtT+iZ3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-12-14 at 20:27 +0100, Daniel Pocock wrote:
> Brief update on this issue: nfs-utils 1.3.4 is now in Debian sid
[...]

But it's broken: https://bugs.debian.org/848145

This one looks stranger; may or may not be a regression:
https://bugs.debian.org/848115

Ben.

--=20
Ben Hutchings
The two most common things in the universe are hydrogen and stupidity.

--=-4uTVH+x8/UdCedtT+iZ3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEErCspvTSmr92z9o8157/I7JWGEQkFAlhRy/IACgkQ57/I7JWG
EQnN3xAAny2/jNHRz9CLFk1z8kB1mlAhKSoD1dAmBExyLAjh50V004hv9hdPKtCr
LL4t7fWbJVf+Cays9ASV4QeN4kwnSNk07mdyseN3nSBC5DsSSeYgZpCStwtcQIjQ
TQmgZJaOZY74Onr2KnSSmuZTkC5ZNqI+6ZXLQwF97N3kxCTQNcSZbCx+RrBtHdo3
6yl+05C395w1wWNrxvX08CuiW9JKAffQsbm1k0CYoz++eYTeZO5E2Y7Onj9CkyK1
xFrMf8EvcNPzpmzqXEDOOSvdP7D2jdZo5phjN0CrBxJuVtgvyEUh2aF72aWA0EqK
ehhn528RkVqhWF4yGhM4UBz99YavNx5h+ZEizIvUtl3DRKcmIVOE2qvxQV59/1TD
YOxixd0r+csrgbnE4gnLttueXETxHbhv7lh0Vqjb+7w4VGz2C/5IC05DtdLISm39
NTpj7GapBIPXXyeJyzOkn3r78zw2+AqZ9DqQANu1ITWO4A+/OoFK6c7BLoqYhEzT
mc/tmkonVI6cdH1/vA5SeusA8DL+X4hhHulyb+L7GIYr/++KUo6bygGRJx0dr7/c
dtqncCR2YS5bspfc1Mn9h6/Nv9nHQ7Zd3w605tSUvCCFoziEURyUuwld4W9koBff
n+mr422mgGCLSV4cG+XmBb1ibO5Xd1wzgjKgUEy4TryP7qM8Mlw=
=bZ4Q
-----END PGP SIGNATURE-----

--=-4uTVH+x8/UdCedtT+iZ3--

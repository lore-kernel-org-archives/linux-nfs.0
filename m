Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:46040 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758655Ab3CDWoQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Mar 2013 17:44:16 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Akinobu Mita <akinobu.mita@gmail.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH -v3 17/23] net/sunrpc: rename random32() to prandom_u32()
Date: Mon, 4 Mar 2013 22:44:13 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9286AF0DB@sacexcmbx05-prd.hq.netapp.com>
References: <1362401911-14074-1-git-send-email-akinobu.mita@gmail.com>
	 <1362401911-14074-18-git-send-email-akinobu.mita@gmail.com>
In-Reply-To: <1362401911-14074-18-git-send-email-akinobu.mita@gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="=-SQIidN/DRVZ2+Ig/p9iA"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-SQIidN/DRVZ2+Ig/p9iA
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-03-04 at 21:58 +0900, Akinobu Mita wrote:
> Use more preferable function name which implies using a pseudo-random
> number generator.
>=20
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
> Cc: "J. Bruce Fields" <bfields@fieldses.org>
> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Cc: linux-nfs@vger.kernel.org
> ---
>=20
> No change from v2
>=20
>  net/sunrpc/auth_gss/gss_krb5_wrap.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gs=
s_krb5_wrap.c
> index 88edec9..1da52d1 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> @@ -130,8 +130,8 @@ gss_krb5_make_confounder(char *p, u32 conflen)
> =20
>  	/* initialize to random value */
>  	if (i =3D=3D 0) {
> -		i =3D random32();
> -		i =3D (i << 32) | random32();
> +		i =3D prandom_u32();
> +		i =3D (i << 32) | prandom_u32();
>  	}
> =20
>  	switch (conflen) {

Acked-by: Trond Myklebust <Trond.Myklebust@netapp.com>

--=-SQIidN/DRVZ2+Ig/p9iA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABAgAGBQJRNSPAAAoJEGcL54qWCgDywo0P+gJT0QdtovcdlKjovq/XK/kY
HvzP26Z0Agri5kA5xLdQvhWEjUe+G1j+rraNLO6iUMF09EwG4rqnlYSAMHq0SsL5
f9SuBNFdRK7Vd/jvnQjyL2Sf05PFT9OEAYplMcMgI0Cew5NMMYXtI7GQU4y+ucxF
vyzw7WeKqbYrUsQV99plJ5fpq63lSmEgn4uzURudzbIq0cuz8uYGkWTfQllZRdaa
bJ3Ov375udPvNHN696s+KopVelg28TEA9ooBufwJr7ynUzNjSs9VgyJPPvpB/+NA
QFVfdbpCrh/n4/cucmtLh6OBoCl1I0uzHZCXU9Px/thR7Nr2lZ78jaTE1qR8QJh1
MYQOe3ugzc4IFouhgKYic+MgTrRtEALa/8sZ7rYjx2/rz/gHCkc6CSzuZy5w7jf0
FJ4a8hBSz0fEGkgz5NcgGPsCG8xOOjA9uQnB2GcyN4Ni2p3USAaSoriLT+gr8zqX
oC05AU5IaxO29c+wYC7EyKLJjfGJeDR6I/7CKfRnjBmvFg+2/4fwAnoI0vGd03US
o99gDvGEQ3S9uw4zMGuwirBEP73V5OhqENpqEMn39F0+nuG0u4QXpOsB5IXRTiNT
UXmvQWCG4kdGK98/Ra+z8TrBL+JpowuKGhaoMgQgLNW0wp+wJW8Ftw7nLAAbL4Ed
/8LAEAJGld12kQ+CiiXN
=K/Tl
-----END PGP SIGNATURE-----

--=-SQIidN/DRVZ2+Ig/p9iA--

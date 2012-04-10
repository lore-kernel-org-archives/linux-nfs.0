Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:41223 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753687Ab2DJASy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Apr 2012 20:18:54 -0400
Date: Tue, 10 Apr 2012 10:18:44 +1000
From: NeilBrown <neilb@suse.de>
To: Jim Rees <rees@umich.edu>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] fix page number calculation bug for block layout decode
 buffer
Message-ID: <20120410101844.62c09f57@notabene.brown>
In-Reply-To: <1334013727-1931-1-git-send-email-rees@umich.edu>
References: <1334013727-1931-1-git-send-email-rees@umich.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/NrOIA5NinjIr.BXKwgbv3sR"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/NrOIA5NinjIr.BXKwgbv3sR
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon,  9 Apr 2012 19:22:07 -0400 Jim Rees <rees@umich.edu> wrote:

> Signed-off-by: Jim Rees <rees@umich.edu>
> Suggested-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/blocklayout/blocklayout.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blockl=
ayout.c
> index 48cfac3..576da5b 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -872,7 +872,7 @@ nfs4_blk_get_deviceinfo(struct nfs_server *server, co=
nst struct nfs_fh *fh,
>  	 * GETDEVICEINFO's maxcount
>  	 */
>  	max_resp_sz =3D server->nfs_client->cl_session->fc_attrs.max_resp_sz;
> -	max_pages =3D max_resp_sz >> PAGE_SHIFT;
> +	max_pages =3D (max_resp_sz  + PAGE_SIZE - 1) >> PAGE_SHIFT;

        max_pages =3D DIV_ROUND_UP(max_resp_sz, PAGE_SIZE);

??

compiler should optimise the constant-divide into a shift, and it is more
"obviously correct" this way.

NeilBrown


>  	dprintk("%s max_resp_sz %u max_pages %d\n",
>  		__func__, max_resp_sz, max_pages);
> =20


--Sig_/NrOIA5NinjIr.BXKwgbv3sR
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBT4N8ZDnsnt1WYoG5AQIc9hAAsC+ErfyQiSc6NL1mfa/p3tqXXc3dIRty
aqO0CsVLTxyLb8KDk1T2mSgAn2+sXigbbWKJ5XxcBVCrMG2OISlMslZm1ievwQ9B
gzi9KBG5GFJvp57M4aLs0u7odYb52OBbbOsQli3lFZtL9D15BgcLrh+MXAyinLwd
c1b8OTzA9iIePpkw2G8DcUFq/Hg9w1WqQUxUYPpNxdtlTIFOfhBejfRN+4GEZOR2
HVvmsGwF8rXsrTnOQbPulX6wKqbtSBhJYvG7bLx/gIXC/ZFu5Hcw4J34Sj1MPl8w
pMq24k7Vg13KLJg7IiJW1LOrC/upnGymbPdCOHufnJSKau3Rn1wTy9t/jvc82gJe
YUHZkcWigc4WNiymJHEp2QjFTWwmfeniluTBgULBpfytTTOqjvCCX7lj80eArdI5
Jy2nBazp7V0XqGv5EUNE2Lrl9DTBNgsXEYbk3ia6BACrfqYQF5vp+Qx32J0tUF6Q
ohTbBDact3pEFlVpTfi8vgn9pC0uiKRjPWnOSoy4OVRPpvfTmSjTl6pFxf/EcODr
uz2LceePR1WD5cxSh3c8l3qwUTcA7GzHYl+tWSAvtBskqHAQ/RceA5o59mIwDsx+
Urc1GTV31vbk+WFR9pEAFKp0dqvnO3hR3zdwCbqOhD+s6+k27MBlF4+YIwLyzLEq
0WNDdsl91GQ=
=VTNP
-----END PGP SIGNATURE-----

--Sig_/NrOIA5NinjIr.BXKwgbv3sR--

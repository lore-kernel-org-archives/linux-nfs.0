Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:33451 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097Ab1AEPj6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jan 2011 10:39:58 -0500
Message-ID: <4D2490C3.4000407@pengutronix.de>
Date: Wed, 05 Jan 2011 16:39:47 +0100
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: =?UTF-8?B?VXdlIEtsZWluZS1Lw7ZuaWc=?=
	<u.kleine-koenig@pengutronix.de>,
        Russell King - ARM Linux <linux@arm.linux.org.uk>,
        linux-nfs@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>, stable@kernel.org
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
References: <20101230171453.GA5787@pengutronix.de>	 <1293731992.4919.5.camel@heimdal.trondhjem.org>	 <20101230191846.GB14221@pengutronix.de>	 <20110103213850.GC25121@pengutronix.de>	 <1294100558.25100.8.camel@heimdal.trondhjem.org>	 <20110105084014.GN25121@pengutronix.de>	 <20110105110517.GQ25121@pengutronix.de>	 <20110105112701.GA8638@n2100.arm.linux.org.uk>	 <20110105134045.GS25121@pengutronix.de>	 <1294239193.3014.9.camel@heimdal.trondhjem.org>	 <4D2487CA.5040501@pengutronix.de>	 <1294240457.3014.13.camel@heimdal.trondhjem.org> <1294241369.3014.15.camel@heimdal.trondhjem.org>
In-Reply-To: <1294241369.3014.15.camel@heimdal.trondhjem.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigB02CF3540C51CE001DA01B7E"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------enigB02CF3540C51CE001DA01B7E
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/05/2011 04:29 PM, Trond Myklebust wrote:
> On Wed, 2011-01-05 at 10:14 -0500, Trond Myklebust wrote:=20
>> OK. So,the new behaviour in 2.6.37 is that we're writing to a series o=
f
>> pages via the usual kmap_atomic()/kunmap_atomic() and kmap()/kunmap()
>> interfaces, but we can end up reading them via a virtual address range=

>> that gets set up via vm_map_ram() (that range gets set up before the
>> write occurs).
>>
>> Do we perhaps need an invalidate_kernel_vmap_range() before we can rea=
d
>> the data on ARM in this kind of scenario?
>=20
> IOW: Does something like the following patch fix the problem?
>=20
> -----------------------------------------------------------------------=
--------=20
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> NFS: Ensure we clean the TLB cache in nfs_readdir_xdr_to_array
>    =20
> After calling nfs_readdir_xdr_filler(), we need a call to
> invalidate_kernel_vmap_range() before we can proceed to read
> the data back through the virtual address range.
>    =20
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 996dd89..4640470 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -587,6 +587,9 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor=
_t *desc, struct page *page,
>  		if (status < 0)
>  			break;
>  		pglen =3D status;
> +
> +		invalidate_kernel_vmap_range(pages_ptr, pglen);
> +
>  		status =3D nfs_readdir_page_filler(desc, &entry, pages_ptr, page, pg=
len);
>  		if (status < 0) {
>  			if (status =3D=3D -ENOSPC)

\o/ - Works for me (at91, armv5)

Tested-by: Marc Kleine-Budde <mkl@pengutronix.de>

This is a candidate for stable (Cc'd).

Regards,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigB02CF3540C51CE001DA01B7E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk0kkMYACgkQjTAFq1RaXHPajACffedzEyEWRnmcOeWvtOwT0eYz
IE0AnjKE3Yl1uIDNmr4RH9Ma1tro+3+r
=JxJd
-----END PGP SIGNATURE-----

--------------enigB02CF3540C51CE001DA01B7E--

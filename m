Return-Path: linux-nfs-owner@vger.kernel.org
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46967 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752988AbaHTXKw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Aug 2014 19:10:52 -0400
Message-ID: <1408576235.2618.47.camel@deadeye.wl.decadent.org.uk>
Subject: Re: [PATCH] nfs: use canonical path in nfs_show_devname
From: Ben Hutchings <ben@decadent.org.uk>
To: Xiong Zhou <xzhou@redhat.com>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Wed, 20 Aug 2014 16:10:35 -0700
In-Reply-To: <1927160445.21851828.1408504000719.JavaMail.zimbra@redhat.com>
References: <1927160445.21851828.1408504000719.JavaMail.zimbra@redhat.com>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-sIVnMayMqgVW4+IhREkr"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-sIVnMayMqgVW4+IhREkr
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-08-19 at 23:06 -0400, Xiong Zhou wrote:
> When export root dir(/) via nfs, and mount a particular dir under root, e=
g
> /nfsexport, there will be defect double slash output in /proc/mounts, lik=
e
> localhost://nfsexport.
>=20
> Signed-off-by: Xiong Zhou <xzhou@redhat.com>
> ---
>  fs/nfs/super.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index e4499d5..62b1cab 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -780,7 +780,7 @@ int nfs_show_devname(struct seq_file *m, struct dentr=
y *root)
>  	int err =3D 0;
>  	if (!page)
>  		return -ENOMEM;
> -	devname =3D nfs_path(&dummy, root, page, PAGE_SIZE, 0);
> +	devname =3D nfs_path(&dummy, root, page, PAGE_SIZE, 1);
>  	if (IS_ERR(devname))
>  		err =3D PTR_ERR(devname);
>  	else

This will reintroduce the problem reported in
<https://bugs.debian.org/669314>.

Ben.

--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.

--=-sIVnMayMqgVW4+IhREkr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAU/Uq8Oe/yOyVhhEJAQqLbA/+Jgab2JOwo2qzEKMDNJrvDgKh/nYAUZq9
bXtVr0uCk0idEbuYo9MYQCIApzlub+bX8LhpyisyDKes9FM1pJr2MAq5/nQs26W+
vr3I5u2sGPtf00VBOYYAZQv5OZlS7/ZPDIGitMaUGsRBGNoO2L5cPdx72Sss2zu9
epTwE49aB5InNigoQiTdVy1K+IJ2aoq83Latxe+fIKLAtrO7J5673OdJ4RswAzdc
8YejLNd0AMukG6F0vjsZIs6WNAY5JSL/1TOoPm/GmZQgmXM2z2mmRR0Ru/mVluqI
3PLOhxVCpIEnvHGR9q01DLPmx4kv47yUpSw4Z3Kw1q7LGZyairJ8MHG796DhWn5M
jsAghou7dHPvuuFpHVUd3ShDRh3Kh9k+RCqkap4aPICc5WecZWxY0/7cWzLv4a3T
YQilk3W3rQ3Q540J/V4e25J2nUNNBA+DK2aDQf5L8MDKJNVY1ttVbcfMSoiMZl5x
Z9CNfpoweltKDADrYMrhzIYyGifCmI3dcfW7v0LTl5sOOM8f9YrK4BBlI9z+z2Nm
6/qu0D3Jpxf9NMesgIbGUIY52Hi+u/XnWNF6YtCYc13gqCOKEBddw765j2+Rd4dj
QasQQ4u85dJwo0Ez3Zl3/ylAyOMU2gkWDhKo0Y514uSU01IlYFwRu+zYuXcBs/4y
NhK2ZiiBz/4=
=Iobq
-----END PGP SIGNATURE-----

--=-sIVnMayMqgVW4+IhREkr--

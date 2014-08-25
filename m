Return-Path: linux-nfs-owner@vger.kernel.org
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58074 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753136AbaHYVHX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Aug 2014 17:07:23 -0400
Message-ID: <1409000826.3033.32.camel@deadeye.wl.decadent.org.uk>
Subject: Re: [PATCH v2] nfs: remove redundant slash from nfs_path
From: Ben Hutchings <ben@decadent.org.uk>
To: Xiong Zhou <xzhou@redhat.com>
Cc: trond myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Mon, 25 Aug 2014 14:07:06 -0700
In-Reply-To: <1859750321.23735105.1408945864304.JavaMail.zimbra@redhat.com>
References: <1927160445.21851828.1408504000719.JavaMail.zimbra@redhat.com>
	 <1408576235.2618.47.camel@deadeye.wl.decadent.org.uk>
	 <1859750321.23735105.1408945864304.JavaMail.zimbra@redhat.com>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-j32SpW4SKORTBFFgN3ZG"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-j32SpW4SKORTBFFgN3ZG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-08-25 at 01:51 -0400, Xiong Zhou wrote:
> When export root dir(/) via nfs, and mount a particular dir under root, e=
g
> /nfsexport, there will be defect double slash output in /proc/mounts, lik=
e
> localhost://nfsexport. While this patch change it to localhost:/nfsexport=
.
>=20
> Signed-off-by: Xiong Zhou <xzhou@redhat.com>
> ---
>  fs/nfs/namespace.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
> index b5a0afc..24f954e 100644
> --- a/fs/nfs/namespace.c
> +++ b/fs/nfs/namespace.c
> @@ -98,7 +98,7 @@ rename_retry:
>  		return end;
>  	}
>  	namelen =3D strlen(base);
> -	if (flags & NFS_PATH_CANONICAL) {
> +	if ((flags & NFS_PATH_CANONICAL) || *end =3D=3D '/') {
>  		/* Strip off excess slashes in base string */
>  		while (namelen > 0 && base[namelen - 1] =3D=3D '/')
>  			namelen--;

I think this makes sense, though I'm not sure I completely understand
this function. :-/

Ben.

--=20
Ben Hutchings
All extremists should be taken out and shot.

--=-j32SpW4SKORTBFFgN3ZG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAU/ulfue/yOyVhhEJAQrLAA/7BCIRixVgXxva9focAazyzWmaZFy2wa8i
sBGisv1DkO9/XdmmfgWupPez0886AxcmKJo85IZT+Cm2YDDy8DKmrfWqNpdZ8RDz
yfQadJL8UJCSWt/dYqe2gKVHEGNSRJzUVrDLnnrzkP6MRDTNxkz737kkaLT9g2r1
7L5xmMFVfuJhFA92milX592yUC9YC2IXzevFPw4MjQsyIaXtKGc95X8etyYRUBV3
dcEnYXQ3UKTG6O1IKOKr3iuj0D2ioOK8U9A8fQ5Spv0K/Z3u7DrI6BpKR1liiQks
rPFLpSwOilSXEMiF5zVlrTBww2y9nr7CYu6nj7FdCvl2xJtqE08LUvHzuCLu9vz5
8dzaRTfSQflCIHAYGBRL56A9wpiRZgAfp8Up8LcJ1jqrvVYHh/e3ctrMBxRZzrDX
5/0+g89Ql8b0DrLOzGUrnK8UUCkdklbChfdz9QcfGfQfhg22J1R2Qrgl0dFYhTRC
xqlE+zoU+1fqG4BsQ3wOmwYbuAAInL6BF3mcn9x8UQRDizC1NjGpPWSMsmJNamG0
HK7kqY5CKxfgjRmCupe5u0IvSw7qPVkrMy2pbRlvDjRreu/EJJsikD2QkStR/q8S
54NbwZYAsqftV5kuY3JdKMESiWDedGzIzRFjzu0jLUE9S4gCKaDzjAV8IOCeGean
zxecfRBpt0o=
=UP7o
-----END PGP SIGNATURE-----

--=-j32SpW4SKORTBFFgN3ZG--

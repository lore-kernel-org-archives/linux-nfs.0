Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39638 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751552AbeB0CMg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 26 Feb 2018 21:12:36 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Tue, 27 Feb 2018 13:12:25 +1100
Subject: Re: [PATCH 1/1] mount.nfs: minorversion setting is being ignored with -t flag
In-Reply-To: <20180226191542.31447-2-steved@redhat.com>
References: <20180226191542.31447-1-steved@redhat.com> <20180226191542.31447-2-steved@redhat.com>
Message-ID: <87zi3vgoza.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 26 2018, Steve Dickson wrote:

> mount -t nfs or mount -t nfs4 and setting minorversion
> should set the v4 minor version. This patch adds a few
> checks to make sure the minor version is set.
>
> The patch also translate the minorversion=3D option
> to vers=3D4.x in the arguments passed to the kernel.
>

If you do this, then you break compatibility with v3.4 and earlier.
(anything without Commit: 0d71b058092f ("NFS: Extend the -overs=3D mount
option to allow 4.x minorversions")).

Maybe that is OK, but I think that fact should be clearly stated in the
commit log, and preferably the configure script should warn if you try
to build on an unsupported kernel.

Do we have any sort of policy on the oldest kernel the nfs-utils still
supports?  Should we?

Thanks,
NeilBrown


> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/mount/network.c | 15 ++++++++++-----
>  utils/mount/stropts.c | 14 ++++++++++++++
>  2 files changed, 24 insertions(+), 5 deletions(-)
>
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index 8ab5be8..8d6e4c6 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -1275,8 +1275,8 @@ nfs_nfs_version(char *type, struct mount_options *o=
ptions, struct nfs_version *v
>  		}
>  	}
>=20=20
> -	if (!found && strcmp(type, "nfs4") =3D=3D 0)
> -		version_val =3D type + 3;
> +	if (!found && strncmp(type, "nfs", 3) =3D=3D 0)
> +		version_val =3D "4";
>  	else if (!found)
>  		return 1;
>  	else if (i <=3D 2 ) {
> @@ -1308,9 +1308,14 @@ nfs_nfs_version(char *type, struct mount_options *=
options, struct nfs_version *v
>  		if (!(version->minor =3D strtol(version_val, &cptr, 10)) && cptr =3D=
=3D version_val)
>  			goto ret_error;
>  		version->v_mode =3D V_SPECIFIC;
> -	} else if (version->major > 3 && *cptr =3D=3D '\0')
> -		version->v_mode =3D V_GENERAL;
> -
> +	} else if (version->major > 3 && *cptr =3D=3D '\0') {
> +		version_val =3D po_get(options, "minorversion");
> +		if (version_val !=3D NULL) {
> +			version->minor =3D strtol(version_val, &cptr, 10);
> +			version->v_mode =3D V_SPECIFIC;
> +		} else=20
> +			version->v_mode =3D V_GENERAL;
> +	}
>  	if (*cptr !=3D '\0')
>  		goto ret_error;
>=20=20
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 777de39..6bbfd71 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -767,6 +767,20 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
>  			mi->version.minor);
>  #pragma GCC diagnostic warning "-Wformat-nonliteral"
>=20=20
> +		if (po_append(options, version_opt) =3D=3D PO_FAILED) {
> +			errno =3D EINVAL;
> +			goto out_fail;
> +		}
> +	} else if (po_get(options, "minorversion")) {
> +		/*
> +	 	 * convert minorversion=3D into vers=3D4.x
> +	 	 */
> +		po_remove_all(options, "minorversion");
> +
> +		snprintf(version_opt, sizeof(version_opt) - 1,
> +			"vers=3D%lu.%lu", mi->version.major,
> +			mi->version.minor);
> +
>  		if (po_append(options, version_opt) =3D=3D PO_FAILED) {
>  			errno =3D EINVAL;
>  			goto out_fail;
> --=20
> 2.14.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlqUvokACgkQOeye3VZi
gbkzfBAAooDImZrNHwBMvfzgR6/NW5/Do9XD9ddxAouQCgUNdoeb0SoxA6sFQmZ6
26s5nj24ID8lrcux6OtGF+kZjtHC8dKN8aGI9AZUntTOPNnvAmfDGMnWZ3IpvIdT
uzjaayE2RUqumZkdd8VRDDWATGGF7G+fZ/XWSZ/SIpbnp3iXD0V/03AbFLs0XuNb
+sZcjrDDxfhQhpTycS6z2NSJMXlC0G7uF0FE0Do0vDBv3NMPsatY9BiKRfvsV5Ek
UU3PJbunhSwW6vbSiUF/dBNOQFq9ECQM4qhrwhy8ilINgBIO3qBMiooOog8zgzTN
bRoV2ZjueKBz21g3HANOyloT4q1BpHQ9ATp2MDL/x8sZ9d2clJwOVlp18qtJEmHX
WlqKqMCpDJj59mf7rG/55hrhDcYCsgb9eF7Ez7DjYRHzYEHmguo+yABi8iJ3Dh2N
GhFJRgfi+xbNoO1R483wzF+I4n0FwbHArjLR1QsW2x+hVzOIYB55vNcL5PKzCWh1
kFUZ7IeOVXfrqa9FLB0zXosYNmH9qnquF+8Q5oNhmeqieAU2Ildi0SwsSyhPYXSh
+0Ay4xQa4n3AlBQ2ttq2z/GOj6mRWJqz4JGza2UJGPSxtz6zjyb9I6sUl2izLkhR
w/YiwDRyVlhn1mL9tXiITOcqXQGddcjwdlUH+aKbyiaVa39Za/E=
=CTFg
-----END PGP SIGNATURE-----
--=-=-=--

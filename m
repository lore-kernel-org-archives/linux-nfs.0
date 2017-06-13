Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38044 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752824AbdFMBTe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 12 Jun 2017 21:19:34 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Tue, 13 Jun 2017 11:19:25 +1000
Subject: Re: [PATCH 2/2 V2] mount.nfs: Use default minor version when -o v4 is specified
In-Reply-To: <20170609132608.12213-2-steved@redhat.com>
References: <20170609132608.12213-1-steved@redhat.com> <20170609132608.12213-2-steved@redhat.com>
Message-ID: <87poe88z1e.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 09 2017, Steve Dickson wrote:

> When v4 is specified on the command line the
> default minor version needs to be used.
>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/mount/stropts.c | 27 ++++++++++++++++++++-------
>  1 file changed, 20 insertions(+), 7 deletions(-)
>
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 81fb945..d2d303f 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -119,14 +119,22 @@ static void nfs_default_version(struct nfsmount_inf=
o *mi)
>  	if (mi->version.v_mode =3D=3D V_DEFAULT &&
>  		config_default_vers.v_mode !=3D V_DEFAULT) {
>  		mi->version.major =3D config_default_vers.major;
> -		mi->version.minor =3D config_default_vers.minor;
> +		if (config_default_vers.minor)
> +			mi->version.minor =3D config_default_vers.minor;
> +		else if (!mi->version.minor)
> +			mi->version.minor =3D NFS_DEFAULT_MINOR;

No, this looks wrong.  A minor number of '0' can be perfectly valid.
Deciding to turn a minor of '0' into '2' is simply wrong.

You can only tell if .minor is valid by looking at .v_mode.
If .v_mode is V_GENERAL or V_DEFAULT, then .minor is not valid
and a default should be used.  If it is V_SPECIFIC, then .minor is
either valid or irrelevant, depending on .major.


>  		return;
>  	}
>=20=20
>  	if (mi->version.v_mode =3D=3D V_GENERAL) {
>  		if (config_default_vers.v_mode !=3D V_DEFAULT &&
> -		    mi->version.major =3D=3D config_default_vers.major)
> -			mi->version.minor =3D config_default_vers.minor;
> +		    mi->version.major =3D=3D config_default_vers.major) {
> +			if (mi->version.minor)
> +				mi->version.minor =3D config_default_vers.minor;

Again, don't test version.minor like this.

> +			else if (!mi->version.minor)
> +				mi->version.minor =3D NFS_DEFAULT_MINOR;
> +		} else if (!mi->version.minor)
> +			mi->version.minor =3D NFS_DEFAULT_MINOR;
>  		return;
>  	}
>=20=20
> @@ -740,10 +748,15 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
>  	}
>=20=20
>  	if (mi->version.v_mode !=3D V_SPECIFIC) {
> -		if (mi->version.v_mode =3D=3D V_GENERAL)
> -			snprintf(version_opt, sizeof(version_opt) - 1,
> -				"vers=3D%lu", mi->version.major);
> -		else
> +		if (mi->version.v_mode =3D=3D V_GENERAL) {
> +			if (mi->version.major > 3)

This test is pointless as .v_mode is only ever V_GENERAL when
 .major =3D=3D 4

And given that this is nfs_do_mount_v4(), we can be certain that
version.major =3D=3D 4.

Prior to
Commit: 0d71b058092f ("NFS: Extend the -overs=3D mount option to allow 4.x =
minorversions")

in Linux 3.4, writing "vers=3D4.1" wasn't supported.
So I think it would be safest to use
  vers=3D4                   if minor =3D=3D 0
  vers=3D4,minorversion=3D1    if minor =3D=3D 1
  vers=3D4.2                 if minor =3D=3D 2

This is despite the fact that the comment in the kernel says
                                                  In future,
                 * the mount program should always supply
                 * a NFSv4 minor version number.

I think vers=3D4.%d is appropriate for v4.2 and later, but not for earlier
versions.

Alternately we could test the kernel version and behave differently, but
I think that is worse.

Thanks,
NeilBrown

> +				snprintf(version_opt, sizeof(version_opt) - 1,
> +					"vers=3D%lu.%lu", mi->version.major,
> +					mi->version.minor);
> +			else=20
> +				snprintf(version_opt, sizeof(version_opt) - 1,
> +					"vers=3D%lu", mi->version.major);
> +		} else
>  			snprintf(version_opt, sizeof(version_opt) - 1,
>  				"vers=3D%lu.%lu", mi->version.major,
>  				mi->version.minor);
> --=20
> 2.9.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlk/PZ8ACgkQOeye3VZi
gbnTwQ/8Ctr2Rcas6DIPS+9DkS1lMBSLzqnkOxC0ApDBuaibmrUhV3s/FHMJSYqM
RF9b4yC1d0sNP9xDvV4nAALcwIKAASpYHjIq+6bHB6E+y8p1wvHsZUKT5/VDzUYL
I/lWNe7tEp1Q+IH/0tRt2YfBL+sar1GI6NwM1AENUH6nyoSx2IIHGq9Hfv3DPuih
CrfB60ZkfrIno+XttHjP76emA6ZT5anCJF9Yezy8jvxv6xJO8pM7QzW2Ou8OEQYo
6ZJuENlGrBUHP5r60eLunH2GKTqc8pPpf7z/tiB0WFvnrnIZjconEQpM9ToqJ1IQ
V5pxFCrQh1UWGVPbmYuXFpgM2xo7Su/8ocjYHf9HHlTeU/S8DQl6Ydbb1xVTuDXD
IhctBulL3X1a8uZTzD6Sxb8OWAztaOAA/8ds4ww0uPADCthKYOIFaBEB2/Zy521j
Js3OUCTy0n6OoqGJ068rhPSOLUQXsvuj/Kc6AEUHU2M95pwczpsIZRFqhs3hmNMM
QkJXMLPIszI1aHoy06WfUVI8BflXttYwMpYRVMSgjXfDe1e01W6bh4oThfp3+ilh
Vh0uwFqKKAWU8MfYKyJgG03VDmfem7tX19hZMPOXBAENf0AF3nykcXbNzovlMUnx
Hu+KNxQh4WRE1vyA7PrBfWFA8d4KMwf8Omus2lW8I/T8ruzxnNE=
=DcHa
-----END PGP SIGNATURE-----
--=-=-=--

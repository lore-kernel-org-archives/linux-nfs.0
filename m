Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51951 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751573AbdFGCs5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Jun 2017 22:48:57 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Wed, 07 Jun 2017 12:48:47 +1000
Subject: Re: [PATCH] mount.nfs: Use default minor version when -t nfs4 is specified
In-Reply-To: <20170606194812.4248-1-steved@redhat.com>
References: <20170606194812.4248-1-steved@redhat.com>
cc: Chuck Lever <chuck.lever@oracle.com>
Message-ID: <87y3t4bjhs.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Jun 06 2017, Steve Dickson wrote:

> When the nfs4 filesystem specified, the default minor
> version should be used not v4.0.
>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/mount/stropts.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index c0266e5..57efb26 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -317,7 +317,8 @@ static int nfs_set_version(struct nfsmount_info *mi)
>=20=20
>  	if (strncmp(mi->type, "nfs4", 4) =3D=3D 0) {
>  		mi->version.major =3D 4;
> -		mi->version.v_mode =3D V_GENERAL;
> +		mi->version.minor =3D 2;
> +		mi->version.v_mode =3D V_SPECIFIC;

I think this is wrong.

By setting the mode to SPECIFIC, you are saying that if the server
doesn't support v4.2, then fail the mount.  That cannot be right.

Given that (currently) v_mode is not V_SPECIFIC, nfs_set_version()
will go on and call nfs_default_version(), which will use the default
value from the config file - just as Chuck suggests.

If there is no default in the config file .... nfs_default_version()
will do nothing.  So version.minor will probably remain at zero.
So setting
> +		mi->version.minor =3D 2;

(where 2 is the maximum supported version) is probably correct.
Setting
> +		mi->version.v_mode =3D V_SPECIFIC;
is unnecessary and wrong.

If there an easy way to find out the maximum minor version that the
kernel supports?  We should really default version.minor to that.
Once we get up to v4.20, it'll seem odd to try to mount 4.20, 4.19,
4.18,... until something succeeds....

Thanks,
NeilBrown

>  	}
>  	/*
>  	 * Before 2.6.32, the kernel NFS client didn't
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

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlk3aZEACgkQOeye3VZi
gbls0w/8DXLcJE+0m4j7z18Z9PIcvgn/VGQ2Z209Q5WGddAPCqWi2WRJlCHfTa0C
shLLOgoSjy8j74MFd2/jEF/9wrvgvDstCITqAAemCOxrn2dr6O3iyqODmwQX2S6e
+c7abYWvi4DC69La1X3RABP+LwmQP4F+M5znYw4iSCESRvBewD6BXjMvNh8VA4uq
PSqg3qEMZqOG7UcNY8ATpCAIQzMGLpEaoLphZsaaxmrDBOH7p6M/RMIr3DnarbH9
PY7uSyM8boo9Lpxa97P51w6gXsxS7qRbyQadWawVFD32+pV/0XR2wg/jJ9AimS7a
8OAMOgteTec6loiJnxAyrllcLK2FRBdfgAKCqz6o4xu7akT+ZLrdjG9Xy/n3Zlym
e1Os1Y18RyEGBh7NE7GGl51GdrqjcU75NoHk44w2eKrygDOTmzoikqOYQMQ+7Cta
SYxax+zBj4k1lLT/9m9RwkT4Ojksc2TAF1G/3C3uVRfFJpjam6ZY7ABNxkLz/Zn0
Uo5ePzkdQZ7LQAaZJ4d9EiR6W7cQ7LWw6+/KNZafReqNxbeCrPcplmjBis8EjWIJ
W/v0+9uTiW2tGeuwRaeNVg6cpYzdX0A1/DL6v6PsSldkv/wgOvIGY5wKVv5d0Hrd
Z9dXG4+1rOXeHRP3DgezmHs6k+B9gs8ABWdkNUcM4nqMVwqaWDk=
=I08c
-----END PGP SIGNATURE-----
--=-=-=--

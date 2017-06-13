Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35357 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752508AbdFMA72 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 12 Jun 2017 20:59:28 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Tue, 13 Jun 2017 10:59:18 +1000
Subject: Re: [PATCH 1/2 V2] mount.nfs: Use default minor version when -t nfs4 is specified
In-Reply-To: <20170609132608.12213-1-steved@redhat.com>
References: <20170609132608.12213-1-steved@redhat.com>
Message-ID: <87shj48zyx.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 09 2017, Steve Dickson wrote:

> When the nfs4 filesystem specified, the default major
> and minor versions should be used.
>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/mount/stropts.c | 16 ++++++++++++----
>  1 file changed, 12 insertions(+), 4 deletions(-)
>
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index c0266e5..81fb945 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -73,6 +73,13 @@
>  #define NFS_DEF_BG_TIMEOUT_MINUTES	(10000u)
>  #endif
>=20=20
> +#ifndef NFS_DEFAULT_MAJOR
> +#define NFS_DEFAULT_MAJOR	4
> +#endif
> +#ifndef NFS_DEFAULT_MINOR
> +#define NFS_DEFAULT_MINOR	2
> +#endif
> +
>  extern int nfs_mount_data_version;
>  extern char *progname;
>  extern int verbose;
> @@ -124,8 +131,8 @@ static void nfs_default_version(struct nfsmount_info =
*mi)
>  	}
>=20=20
>  #endif /* MOUNT_CONFIG */
> -	mi->version.major =3D 4;
> -	mi->version.minor =3D 2;
> +	mi->version.major =3D NFS_DEFAULT_MAJOR;
> +	mi->version.minor =3D NFS_DEFAULT_MINOR;
>  }
>=20=20
>  /*
> @@ -316,8 +323,9 @@ static int nfs_set_version(struct nfsmount_info *mi)
>  		return 0;
>=20=20
>  	if (strncmp(mi->type, "nfs4", 4) =3D=3D 0) {
> -		mi->version.major =3D 4;
> -		mi->version.v_mode =3D V_GENERAL;
> +		/* Set to default values */
> +		mi->version.major =3D NFS_DEFAULT_MAJOR;
> +		mi->version.minor =3D NFS_DEFAULT_MINOR;

Why do you remove the setting of v_mode to V_GENERAL?
Won't that leave it as V_DEFAULT, and doesn't that mean
that it will negotiate from v4 down to v3??

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

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlk/OOcACgkQOeye3VZi
gbmxMQ//aX05K5m9qN4u9ht1hltH3vqybjKPaVD0wKHspT9R9dIsLrdYrVxdg0q7
vmrww0PPCwZi7KXBUGqT+MnpT0EAcMKwcp/25w4WwTAPXTjhuoJtvaePpN4jJMx0
KKS4x96XYPZInrMZPzzCANK8GkIWDIDk7YxLh5qHu5oLbqS6K0e9wL8BtOOnJqS1
YnbcjQS8NRqJ0VbjfowStXdJUAiZsMvGvY6KX1tGuN7S/96Um6OckoZwuQKGP2Gd
3oY1QDYAP7IW8FCXuWyBG9g9tJl+7z298/UGTkn9VQLGVm7ceeCO4TTbXCpAs4hg
EgCKRrDNx50g5AGPMcwKGzEa3KY8wftCRsHcMA9MqWjnbRpePHoGpWuuWQ7qh8Kw
Ck9j26cG6Ne85jAln6tDgqrdb8gQUW8oI16bZrwWgu+2WTFjHBTWg4Pl0JVoeasU
Z5BEyosNvwDXpxnum995c4SQ/LynUNHgVd2wNLshsApAzwL5WYpssbVd+UAHZ6fr
wzTmsjbeP8MnZixGGCQyHXUbJazZ2rS5TvgdeUw4X1IIpXryIJC2EtfhHZ5nzoUd
nEYA7nkRLk5RBKexP33UF+4W7jfktYRqYAmSZaqOkaA/0MJKSm1bM7dpqaTKUCfV
sY5TMPShtx/oMFF9kBRC5+hWaVx2+nHigHHUhtRs4iiGF7mknvY=
=oLu2
-----END PGP SIGNATURE-----
--=-=-=--

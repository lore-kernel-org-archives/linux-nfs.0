Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41971 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752603AbdLEWJF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Dec 2017 17:09:05 -0500
From: NeilBrown <neilb@suse.com>
To: Thiago Rafael Becker <thiago.becker@gmail.com>,
        bfields@fieldses.org
Date: Wed, 06 Dec 2017 09:08:57 +1100
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Thiago Rafael Becker <thiago.becker@gmail.com>
Subject: Re: [PATCH 2/3] kernel: Move groups_sort to the caller of set_groups.
In-Reply-To: <20171205185523.20600-1-thiago.becker@gmail.com>
References: <20171205140512.13349-3-thiago.becker@gmail.com> <20171205185523.20600-1-thiago.becker@gmail.com>
Message-ID: <87374ou8sm.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Dec 05 2017, Thiago Rafael Becker wrote:

> The responsibility for calling groups_sort is now on the caller
> of set_groups.
>
> Signed-off-by: Thiago Rafael Becker <thiago.becker@gmail.com>
> ---
>  arch/s390/kernel/compat_linux.c   | 1 +
>  fs/nfsd/auth.c                    | 3 +++
>  kernel/groups.c                   | 1 +
>  kernel/uid16.c                    | 1 +
>  net/sunrpc/auth_gss/gss_rpc_xdr.c | 1 +
>  net/sunrpc/auth_gss/svcauth_gss.c | 1 +
>  net/sunrpc/svcauth_unix.c         | 8 ++++++++
>  7 files changed, 16 insertions(+)
>
> diff --git a/arch/s390/kernel/compat_linux.c b/arch/s390/kernel/compat_li=
nux.c
> index f04db37..59eea9c 100644
> --- a/arch/s390/kernel/compat_linux.c
> +++ b/arch/s390/kernel/compat_linux.c
> @@ -263,6 +263,7 @@ COMPAT_SYSCALL_DEFINE2(s390_setgroups16, int, gidsets=
ize, u16 __user *, grouplis
>  		return retval;
>  	}
>=20=20
> +	groups_sort(group_info);
>  	retval =3D set_current_groups(group_info);
>  	put_group_info(group_info);
>=20=20
> diff --git a/fs/nfsd/auth.c b/fs/nfsd/auth.c
> index 697f8ae..7b5099b 100644
> --- a/fs/nfsd/auth.c
> +++ b/fs/nfsd/auth.c
> @@ -60,6 +60,9 @@ int nfsd_setuser(struct svc_rqst *rqstp, struct svc_exp=
ort *exp)
>  				gi->gid[i] =3D exp->ex_anon_gid;
>  			else
>  				gi->gid[i] =3D rqgi->gid[i];
> +
> +			/* Should be race free as long as each thread allocates a new gi */
> +			groups_sort(gi);
>  		}
>  	} else {
>  		gi =3D get_group_info(rqgi);
> diff --git a/kernel/groups.c b/kernel/groups.c
> index 4c9c9ed..17073a9 100644
> --- a/kernel/groups.c
> +++ b/kernel/groups.c
> @@ -208,6 +208,7 @@ SYSCALL_DEFINE2(setgroups, int, gidsetsize, gid_t __u=
ser *, grouplist)
>  		return retval;
>  	}
>=20=20
> +	groups_sort(group_info);
>  	retval =3D set_current_groups(group_info);
>  	put_group_info(group_info);
>=20=20
> diff --git a/kernel/uid16.c b/kernel/uid16.c
> index ce74a49..ef1da2a 100644
> --- a/kernel/uid16.c
> +++ b/kernel/uid16.c
> @@ -192,6 +192,7 @@ SYSCALL_DEFINE2(setgroups16, int, gidsetsize, old_gid=
_t __user *, grouplist)
>  		return retval;
>  	}
>=20=20
> +	groups_sort(group_info);
>  	retval =3D set_current_groups(group_info);
>  	put_group_info(group_info);
>=20=20
> diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.c b/net/sunrpc/auth_gss/gss_=
rpc_xdr.c
> index c4778ca..444380f 100644
> --- a/net/sunrpc/auth_gss/gss_rpc_xdr.c
> +++ b/net/sunrpc/auth_gss/gss_rpc_xdr.c
> @@ -231,6 +231,7 @@ static int gssx_dec_linux_creds(struct xdr_stream *xd=
r,
>  			goto out_free_groups;
>  		creds->cr_group_info->gid[i] =3D kgid;
>  	}
> +	groups_sort(creds->cr_group_info);
>=20=20
>  	return 0;
>  out_free_groups:
> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svca=
uth_gss.c
> index 5dd4e6c..2653119 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -481,6 +481,7 @@ static int rsc_parse(struct cache_detail *cd,
>  				goto out;
>  			rsci.cred.cr_group_info->gid[i] =3D kgid;
>  		}
> +		groups_sort(rsci.cred.cr_group_info);
>=20=20
>  		/* mech name */
>  		len =3D qword_get(&mesg, buf, mlen);
> diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
> index 740b67d..99841e1 100644
> --- a/net/sunrpc/svcauth_unix.c
> +++ b/net/sunrpc/svcauth_unix.c
> @@ -20,6 +20,7 @@
>=20=20
>=20=20
>  #include "netns.h"
> +void groups_sort(struct group_info *group_info);
>=20=20
>  /*
>   * AUTHUNIX and AUTHNULL credentials are both handled here.
> @@ -520,6 +521,12 @@ static int unix_gid_parse(struct cache_detail *cd,
>  		ug.gi->gid[i] =3D kgid;
>  	}
>=20=20
> +	/* Sort the groups before inserting this entry
> +	 * into the cache to avoid future corrutpions
> +	 * by multiple simultaneous attempts to sort this
> +	 * entry.
> +	 */
> +	groups_sort(ug.gi);
>  	ugp =3D unix_gid_lookup(cd, uid);
>  	if (ugp) {
>  		struct cache_head *ch;
> @@ -819,6 +826,7 @@ svcauth_unix_accept(struct svc_rqst *rqstp, __be32 *a=
uthp)
>  		kgid_t kgid =3D make_kgid(&init_user_ns, svc_getnl(argv));
>  		cred->cr_group_info->gid[i] =3D kgid;
>  	}
> +	groups_sort(cred->cr_group_info);
>  	if (svc_getu32(argv) !=3D htonl(RPC_AUTH_NULL) || svc_getu32(argv) !=3D=
 0) {
>  		*authp =3D rpc_autherr_badverf;
>  		return SVC_DENIED;
> --=20
> 2.9.5

Reviewed-by: NeilBrown <neilb@suse.com>

Looks good to me, thanks.
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlonGPkACgkQOeye3VZi
gbm0Dg/+O1P4eyKnbI3+9Rh3yTfaB8R6rx5NmBMjd+pYbkLQvCGhCtCQundOcXYf
jt+wLnAMouXH+capE4NA4aVxc+s+mwPOJ7j7OFoQrPZBvp/vyPGr0YiDlOWAq4Qj
AuZmd06nKy23GUI37DWJatzu2wi0F9fEOnaN6NhXv0ssNmtCe1ml1kEFMnTXefhf
kLfxfbWtG8YHvJf1su0vPrdtp/t5KdGh9QNsI8MDAtCkPwBC0Pwz72lcRGeAmNHc
eTmmRkDWX+Rd/R5ruvT62xxVMx00bBlAcMY8LPn44mer40o8hXhRXdiFpNZJGwCz
IJq7R6WpY3+NC7a4UcyrkdZAi7AqB63qdd+kznT5DeksXDCWu1yD9mI+57Ytkcpe
lQrsB9AWhFU0Gx+nLXL9cyNw+KqXIEAg5DTfIeVSPEQFrPzRvnR/T4yAs1YOKfFh
p58l+xbJ/mYkmW594YRCyRJjsbZX6msyOc0J8EXwgpXfpgQ/mz9XiiVf3maoQK18
L8wV3wO0qhaGP218VGVqCZL8kbpCfrmq0WfyPVOaceQEAAqJGVMh9R0aCKH2rJat
d1uoq2liTJmp7QVZd/OKQsOYvzQPYzxTycjs5G4Dwa3xzaG93mm9zV7LraOIGDpo
nQYbsP3728PM7cmNgSXBaHGEdak37Y/yilL30Xvs4E4Aoo2pEf0=
=N3xP
-----END PGP SIGNATURE-----
--=-=-=--

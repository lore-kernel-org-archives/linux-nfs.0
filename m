Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43981 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751385AbdLDBmz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 3 Dec 2017 20:42:55 -0500
From: NeilBrown <neilb@suse.com>
To: Thiago Rafael Becker <thiago.becker@gmail.com>,
        bfields@fieldses.org
Date: Mon, 04 Dec 2017 12:42:46 +1100
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Thiago Rafael Becker <thiago.becker@gmail.com>
Subject: Re: [PATCH 2/3, V2] kernel: Move groups_sort to the caller of set_groups.
In-Reply-To: <20171130130457.11429-3-thiago.becker@gmail.com>
References: <20171130130457.11429-1-thiago.becker@gmail.com> <20171130130457.11429-3-thiago.becker@gmail.com>
Message-ID: <87mv2ztgix.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 30 2017, Thiago Rafael Becker wrote:

> The responsibility for calling groups_sort is now on the caller
> of set_groups.
>
> Signed-off-by: Thiago Rafael Becker <thiago.becker@gmail.com>
> ---
>  kernel/groups.c           | 1 +
>  kernel/uid16.c            | 1 +
>  net/sunrpc/svcauth_unix.c | 7 +++++++
>  3 files changed, 9 insertions(+)
>
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
> diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
> index f81eaa8..91e3d34 100644
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


I think you need to add groups_sort() in a few more places.
Almost anywhere that calls groups_alloc() should be considered.
net/sunrpc/svcauth_unix.c, net/sunrpc/auth_gss/svcauth_gss.c,
fs/nfsd/auth.c definitely need it.

I wonder if there is a more robust way to fix this.
Maybe:
  groups_alloc() could initialize ->usage to -1
  groups_sort() to require it be -1, and change it to 1
  get_group_info() complains if ->usage is -1 ???

or something.
Maybe it could be done with types.
'struct group_info' could be declared with ngroups and
gid[] as const.
'struct group_info_unsorted' could be the same structure but
without the 'const'.
Then groups_sort() takes a 'struct group_info_unsorted *' and returns
a 'struct group_info *'...

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlokqBYACgkQOeye3VZi
gblXhQ//TxsDPLIbEbohtcGENk+M8vYxswvIGGpmkwHK6UTMFayonlPxEbbHYZI7
ge0fg2e38uc4a79XD5CxW8wMcueB7VeLDj3EkEyvbg2HOHNy75CDI/H7vsbo4DY3
DjbMzFpraa9hkjX6CaT7/giLEe5jiSg/Z3Y2mU4R5x0DVGRKXiY5EPKm8iGFol4S
JUul66z+CgTiONQoYnHoLpRPa42QxsLtbF7w6Pm9Ii3q0II19TV4pxP5/HDchpDD
bn8el2XMpvwm3qyTMdD3497Vn0sgN6XVYmVZX5/9NnP5/TtzYCpMJfkBijcusBnF
j95w8oyEb19mUZYCnvUh2GLxoVWSn5rNc6Byry6zgAzZWGKBA2LDO5+8hSmlXbK0
djGWXmLBUTg1mTkQyoNEB09SzdRclKocRnyQ5VPkBoksG8E+HIKB4zkTWS8cNvV5
19LjeIHB+BGkNcrwrpEDu9J1KcA1g88fBinfhrSXuFxaNsTJdeg8UhBUCr4DjIkj
JBJg2FZiayIPEc4VhQHYT2KeEVqjUdP0YeLXDugLdG9yWXNND6LzQgPj+oPwIpTF
mqchPGXQld8nVb8M5APemN4WWBTR/VQuIGw12Gv45eNx9lwzU4xaLsxuiL0Bgxp8
IE1P0WfWoQpjr91jtlIy2oo5HNwThq6w+bGFZ/m/5XsHyreFJiU=
=QBtB
-----END PGP SIGNATURE-----
--=-=-=--

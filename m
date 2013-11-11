Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:46194 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751220Ab3KKHyJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Nov 2013 02:54:09 -0500
Date: Mon, 11 Nov 2013 18:53:56 +1100
From: NeilBrown <neilb@suse.de>
To: Harshula Jayasuriya <harshula@redhat.com>
Cc: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org,
        Jeff Layton <jlayton@redhat.com>,
        "J.Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH] exportfs: modify can_test() to use LONG_MAX when
 appropriate
Message-ID: <20131111185356.6e0fd0a9@notabene.brown>
In-Reply-To: <1384154434.16759.39.camel@serendib>
References: <1376588800.17754.14.camel@serendib>
	<20130815175258.GS17781@fieldses.org>
	<1384154434.16759.39.camel@serendib>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/VKGKCgGWFyWdv.EmXuI9xcA"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/VKGKCgGWFyWdv.EmXuI9xcA
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 11 Nov 2013 18:20:34 +1100 Harshula Jayasuriya <harshula@redhat.com>
wrote:

> This patch is the nfs-utils patch corresponding to the kernel patch=20
> commit 2f74f972d4cc7d83408ea0c32d424edcb44887bf "sunrpc: prepare NFS=20
> for 2038": "The kernel sunrpc code needs to handle seconds since epoch=20
> greater than 2147483647. This means functions that parse time as an=20
> int need to handle it as time_t."
>=20
> When appropriate exportfs should use LONG_MAX in can_test() instead of
> INT_MAX.
>=20
> kernel INT_MAX + exportfs INT_MAX: "Tue Jan 19 03:14:08 UTC 2038"
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> exportfs: /mnt/export does not support NFS export:
> ------------------------------------------------------------
>  # cat /proc/net/rpc/auth.unix.ip/content
>  #class IP domain
> ------------------------------------------------------------
>=20
> + mount fail:
> ------------------------------------------------------------
>  # cat /proc/net/rpc/auth.unix.ip/content
>  #class IP domain
>  # expiry=3D2147483768 refcnt=3D2 flags=3D4
>  # nfsd 192.168.1.6 -no-domain-
> ------------------------------------------------------------
>=20
> kernel LONG_MAX + exportfs INT_MAX: "Tue Jan 19 03:14:08 UTC 2038"
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> "exportfs: /mnt/export does not support NFS export":
> ------------------------------------------------------------
>  # cat /proc/net/rpc/auth.unix.ip/content
>  #class IP domain
> ------------------------------------------------------------
>=20
> + mount success:
> ------------------------------------------------------------
>  # cat /proc/net/rpc/auth.unix.ip/content
>  #class IP domain
>  # expiry=3D2147485448 refcnt=3D2 flags=3D1
>  nfsd 192.168.1.6 *
> ------------------------------------------------------------
>=20
> kernel LONG_MAX + exportfs LONG_MAX: "Tue Jan 19 03:14:08 UTC 2038"
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> exportfs:
> ------------------------------------------------------------
>  # cat /proc/net/rpc/auth.unix.ip/content
>  #class IP domain
>  # expiry=3D9223372036854775807 refcnt=3D1 flags=3D1
>  nfsd 0.0.0.0 -test-client-
> ------------------------------------------------------------
>=20
> + mount success:
> ------------------------------------------------------------
>  # cat /proc/net/rpc/auth.unix.ip/content
>  #class IP domain
>  # expiry=3D2147485448 refcnt=3D2 flags=3D1
>  nfsd 192.168.1.6 *
>  # expiry=3D9223372036854775807 refcnt=3D1 flags=3D1
>  nfsd 0.0.0.0 -test-client-
> ------------------------------------------------------------
>=20
> Signed-off-by: Harshula Jayasuriya <harshula@redhat.com>
> ---
>  utils/exportfs/exportfs.c | 20 ++++++++++++++++----
>  1 file changed, 16 insertions(+), 4 deletions(-)
>=20
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index da5fe21..bccbed5 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -27,6 +27,8 @@
>  #include <netdb.h>
>  #include <errno.h>
>  #include <dirent.h>
> +#include <limits.h>
> +#include <time.h>
> =20
>  #include "sockaddr.h"
>  #include "misc.h"
> @@ -406,17 +408,27 @@ unexportfs(char *arg, int verbose)
> =20
>  static int can_test(void)
>  {
> +	char buf[1024];
>  	int fd;
>  	int n;
> -	char *setup =3D "nfsd 0.0.0.0 2147483647 -test-client-\n";
> +
>  	fd =3D open("/proc/net/rpc/auth.unix.ip/channel", O_WRONLY);
> -	if ( fd < 0) return 0;
> -	n =3D write(fd, setup, strlen(setup));
> +	if (fd < 0)
> +		return 0;
> +
> +	if (time(NULL) > INT_MAX)
> +		sprintf(buf, "nfsd 0.0.0.0 %ld -test-client-\n", LONG_MAX);
> +	else
> +		sprintf(buf, "nfsd 0.0.0.0 %d -test-client-\n", INT_MAX);

This generally makes sense, but I think the cut-off is a bit too fine.
If time(NULL) is exactly INT_MAX, then this might not do what is required.
How about
   if (time(NULL) > INT_MAX - (24*3600))
??

NeilBrown


> +
> +	n =3D write(fd, buf, strlen(buf));
>  	close(fd);
>  	if (n < 0)
>  		return 0;
> +
>  	fd =3D open("/proc/net/rpc/nfsd.export/channel", O_WRONLY);
> -	if ( fd < 0) return 0;
> +	if (fd < 0)
> +		return 0;
>  	close(fd);
>  	return 1;
>  }


--Sig_/VKGKCgGWFyWdv.EmXuI9xcA
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUoCNFDnsnt1WYoG5AQLXEg/+J/UAx3QDsrdB06ZlccrYmBz9HSGRF29v
urG7mG9xI4iLjJnm2Z+aBd/9JKhchIv/pdgUN20GDBmGf1U9ctVJDtfNqAh/DVhC
tJBzC3YSH5dWeKvyxEe87YsDsMe4cRMGV94+DGJRKm1b/COKyfkyxmtFrfXzYumb
4cVipj8+IVBniC+HTFy2YCXyJiivDENRY7xyCsQEs9V15yaHqJPU16hbx5AXqWbK
Kbl9Fadt9MtgfTilL95OzaZSwEsLrcPt+Q4bilsuxq6vuebsXHwyHdrZnp6wVats
5BDYyUsoLdeSBOmuOplgtbQ/d2FVcB+E7YHQZlaNP1j3aNwRdMC3mjSgu3FcWpV4
qm/qsUJDacwSf/dGD5tzvabKVjeOhDJV2gw9o9cKuPUnHeJXotJ7i23Adp73SiSe
dPjEo0C2Wer056qIy9vnezU+Y+34XHrm8dqVHIT/5e1C6nHyV9d7bYS3lp6jTgfN
vJTBwl3okFjP0FgLYjOGqOcNpC/PZCkWrGtFZXDfX7CMcx6MgrDb1fvElmRGf55c
gzSQ4JW0bi8cQobGJz4GSFHQPGjp4A94ijO8BJ8BmnydIsuBAMEjzybYJLFaehbp
5Jw//PqQsg+sY1oD12f3vfi/Rbun58jAdh6Ad+tOxh34IaYy+pED+Jn29cpWWKZ6
RtE0ShFLRoM=
=Y2Sf
-----END PGP SIGNATURE-----

--Sig_/VKGKCgGWFyWdv.EmXuI9xcA--

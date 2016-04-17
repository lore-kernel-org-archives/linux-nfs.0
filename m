Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:43720 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750976AbcDQQSP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 17 Apr 2016 12:18:15 -0400
Date: Sun, 17 Apr 2016 12:18:13 -0400
From: Mike Frysinger <vapier@gentoo.org>
To: Felix Janda <felix.janda@posteo.de>
Cc: libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: [Libtirpc-devel] [PATCH 7/7] Deduplicate extern "C" blocks
Message-ID: <20160417161813.GG5369@vapier.lan>
References: <20160417091113.GF2737@nyan>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="w/VI3ydZO+RcZ3Ux"
In-Reply-To: <20160417091113.GF2737@nyan>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--w/VI3ydZO+RcZ3Ux
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 17 Apr 2016 11:11, Felix Janda wrote:
> Signed-off-by: Felix Janda <felix.janda@posteo.de>
> ---
>  tirpc/rpc/auth.h      | 62 +++++++--------------------------------------=
------
>  tirpc/rpc/auth_des.h  | 14 +++++-------
>  tirpc/rpc/clnt.h      | 50 +++++++----------------------------------
>  tirpc/rpc/clnt_soc.h  | 27 +++++-----------------
>  tirpc/rpc/des_crypt.h | 20 +++++------------
>  tirpc/rpc/rpc.h       | 14 +++++-------
>  tirpc/rpc/svc.h       | 55 ++++++---------------------------------------
>  tirpc/rpc/svc_soc.h   | 38 +++++--------------------------
>  tirpc/rpc/xdr.h       | 15 +++++--------
>  9 files changed, 54 insertions(+), 241 deletions(-)
>=20
> diff --git a/tirpc/rpc/auth.h b/tirpc/rpc/auth.h
> index 5f8ea72..f743034 100644
> --- a/tirpc/rpc/auth.h
> +++ b/tirpc/rpc/auth.h
> @@ -46,6 +46,10 @@
>  #ifndef _TIRPC_AUTH_H
>  #define  _TIRPC_AUTH_H
> =20
> +#ifdef __cplusplus
> +extern "C" {
> +#endif
> +
>  #include <rpc/xdr.h>
>  #include <rpc/clnt_stat.h>
>  #include <sys/socket.h>

it isn't normal to wrap includes in extern C.  header files should only
be wrapping their own local content.
-mike

--w/VI3ydZO+RcZ3Ux
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXE7dFAAoJEEFjO5/oN/WBP+4QAJi938JHRPDEaXhy3GJBKuuq
170df0x2TmY0fag+pz42MBGdfHMakj/LIkxbXEwEG2MsaEywojm7gs+8FsktuCx5
0EXoodCDB4Fe4iOetCk/bA5znKLk9B0/IBpnuLsDEAq3C0Rrfe12cPFKOX2Kcqhu
Pf7QE+qZXzEDBGW3i3Lg0a4tXYvHY8lNFtn/nWtPsnmzrq0ubVKQYVmLvhiqXEbr
rkVZGeBMXY0Nun2t2wWgE/hre25epTUJFkJmRunvHVd+lGwZbi1SdBd5FFAezB2X
xrTmX9+RNGkrkW67XZeTBh5BGcgaXt3I1qMoNFG0gfvDtjnkUkyF8kQ4mWQMQzgn
nsZpXZAOWaQUJ8NClssUNYYNScntM+iB4Ei2lPnLk4GHffen+z8hzPRtP3XMAlVo
2Xh+jiLa7hiVijn8lpOJu+2AtW5qHAjOxJK3pi9hE7z0UtscoIzXbIzTbub4kC1/
6q4IFjPC2O98IOYuA7CmyPruoYPGGxm0ed4BL6Ahd8IGWVCMJhLUp4UZaCMdktJo
q2X88p4pK07sjPTC2MaxXpdqVk9ZQR6uLYY7anE6aZgYKoaqueTArrOM7odPGV4d
ogFRYWIROQ9l4XCQ+rnanPYdTRtwxEuZ5EdUE7WbG4pPi0cdaK9c5/PPVMhi96AV
GCewbqT+nyYD2AYwwkfh
=Dqjk
-----END PGP SIGNATURE-----

--w/VI3ydZO+RcZ3Ux--

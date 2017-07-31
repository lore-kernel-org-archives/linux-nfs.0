Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34079 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752071AbdGaOfh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Jul 2017 10:35:37 -0400
Received: by mail-io0-f193.google.com with SMTP id m88so14467034iod.1
        for <linux-nfs@vger.kernel.org>; Mon, 31 Jul 2017 07:35:36 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [Libtirpc-devel] [PATCH] Replace bzero() calls with equivalent memset() calls
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <47646199-1784-f1ac-23ae-eedaf3a24c95@gentoo.org>
Date: Mon, 31 Jul 2017 10:35:34 -0400
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <C52540F1-EF74-4D0F-BA55-43F094AC8D8E@gmail.com>
References: <47646199-1784-f1ac-23ae-eedaf3a24c95@gentoo.org>
To: Joshua Kinard <kumba@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 31, 2017, at 12:25 AM, Joshua Kinard <kumba@gentoo.org> wrote:
>=20
> As annotated in the bzero(3) man page, bzero() was marked as LEGACY in
> POSIX.1-2001 and removed in POSIX.1-2008, and should be replaced with
> memset() calls to write zeros to a memory region.  The attached patch
> replaces two bzero() calls and one __bzero() call in libtirpc with
> equivalent memset() calls.  The latter replacement fixes a compile =
error
> under uclibc-ng, which lacks a definition for __bzero()

OK. Nits below.

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> Signed-off-by: Joshua Kinard <kumba@gentoo.org>
> ---
>=20
> src/auth_time.c    |    2 +-
> src/des_impl.c     |    2 +-
> src/svc_auth_des.c |    2 +-
> 3 files changed, 3 insertions(+), 3 deletions(-)
>=20
> diff --git a/src/auth_time.c b/src/auth_time.c
> index 7f83ab4..210d251 100644
> --- a/src/auth_time.c
> +++ b/src/auth_time.c
> @@ -317,7 +317,7 @@ __rpc_get_time_offset(td, srv, thost, uaddr, =
netid)
> 	sprintf(ipuaddr, "%d.%d.%d.%d.0.111", a1, a2, a3, a4);
> 	useua =3D &ipuaddr[0];
>=20
> -	bzero((char *)&sin, sizeof(sin));
> +	memset((char *)&sin, 0, sizeof(sin));

The type cast is likely to be unnecessary, and
could be removed in this patch.


> 	if (uaddr_to_sockaddr(useua, &sin)) {
> 		msg("unable to translate uaddr to sockaddr.");
> 		if (needfree)
> diff --git a/src/des_impl.c b/src/des_impl.c
> index 9dbccaf..15bec2a 100644
> --- a/src/des_impl.c
> +++ b/src/des_impl.c
> @@ -588,7 +588,7 @@ _des_crypt (char *buf, unsigned len, struct =
desparams *desp)
>     }
>   tin0 =3D tin1 =3D tout0 =3D tout1 =3D xor0 =3D xor1 =3D 0;
>   tbuf[0] =3D tbuf[1] =3D 0;
> -  __bzero (schedule, sizeof (schedule));
> +  memset (schedule, 0, sizeof (schedule));

You should fix the white space damage here
(space before left paren, x2).


>   return (1);
> }
> diff --git a/src/svc_auth_des.c b/src/svc_auth_des.c
> index 2e90146..64a7682 100644
> --- a/src/svc_auth_des.c
> +++ b/src/svc_auth_des.c
> @@ -356,7 +356,7 @@ cache_init()
>=20
> 	authdes_cache =3D (struct cache_entry *)
> 		mem_alloc(sizeof(struct cache_entry) * AUTHDES_CACHESZ);=09=

> -	bzero((char *)authdes_cache,=20
> +	memset((char *)authdes_cache, 0,
> 		sizeof(struct cache_entry) * AUTHDES_CACHESZ);

Type cast is unnecessary.


> 	authdes_lru =3D (short *)mem_alloc(sizeof(short) * =
AUTHDES_CACHESZ);
>=20

--
Chuck Lever
chucklever@gmail.com




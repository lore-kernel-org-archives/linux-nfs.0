Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:37074 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752042AbaKEC4m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Nov 2014 21:56:42 -0500
Date: Wed, 5 Nov 2014 13:56:33 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] rpc.svcgssd: Add a configure switch to disable
 building the daemon
Message-ID: <20141105135633.4ea63a2c@notabene.brown>
In-Reply-To: <1411489301-28991-2-git-send-email-steved@redhat.com>
References: <1411489301-28991-1-git-send-email-steved@redhat.com>
	<1411489301-28991-2-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/OJ4EoWRIywwVcFdcD7E21FX"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/OJ4EoWRIywwVcFdcD7E21FX
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 23 Sep 2014 12:21:40 -0400 Steve Dickson <steved@redhat.com> wrote:

> Now that gssproxy is supported on modern kernels,
> the svcgssd is no longer needed. This switch
> disables the building of the daemon.
>=20
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  configure.ac           | 23 +++++++++++++++++++----
>  utils/gssd/Makefile.am | 11 +++++++++--
>  2 files changed, 28 insertions(+), 6 deletions(-)
>=20
> diff --git a/configure.ac b/configure.ac
> index bc48373..b63d821 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -90,21 +90,36 @@ AC_ARG_ENABLE(nfsv41,
> =20
>  AC_ARG_ENABLE(gss,
>  	[AC_HELP_STRING([--enable-gss],
> -                        [enable support for rpcsec_gss @<:@default=3Dyes=
@:>@])],
> +              [enable client support for rpcsec_gss @<:@default=3Dyes@:>=
@])],
>  	enable_gss=3D$enableval,
>  	enable_gss=3Dyes)
>  	if test "$enable_gss" =3D yes; then
>  		GSSD=3Dgssd
> -		SVCGSSD=3Dsvcgssd
>  	else
>  		enable_gss=3D
>  		GSSD=3D
> -		SVCGSSD=3D
>  	fi
>  	AC_SUBST(GSSD)
> -	AC_SUBST(SVCGSSD)
>  	AC_SUBST(enable_gss)
>  	AM_CONDITIONAL(CONFIG_GSS, [test "$enable_gss" =3D "yes"])
> +
> +AC_ARG_ENABLE(svcgss,
> +	[AC_HELP_STRING([--enable-svcgss],
> +    [dissable building svcgssd for rpcsec_gss server support @<:@default=
=3Dyes@:>@])],
> +	enable_svcgss=3D$enableval,
> +	enable_svcgss=3Dyes)
> +	if test "$enable_gss" =3D yes; then
> +		if "enable_svcgss" =3D yes; then
> +			SVCGSSD=3Dsvcgssd
> +		fi

Hi Steve,
 I just noticed that this causes an error when I try "./configure".
It tries to run a program called "enable_svcgss" with args "=3D" and "yes",
but this fails....

A simple fix would leave the code doing nothing if enable_gss =3D yes, but
enable_svcgss =3D no.  Is that what you want?

Should it be:

        if test "$enable_gss" =3D yes -a "$enable_svcgss" =3D yes; then
                SVCGSSD=3Dsvcgssd
> +	else
> +		enable_svcgss=3D
> +		SVCGSSD=3D
> +	fi

??

Would you like a patch, or will you just fix it up?

Thanks,
NeilBrown


> +	AC_SUBST(SVCGSSD)
> +	AC_SUBST(enable_svcgss)
> +	AM_CONDITIONAL(CONFIG_SVCGSS, [test "$enable_svcgss" =3D "yes"])
> +
>  AC_ARG_ENABLE(kprefix,
>  	[AC_HELP_STRING([--enable-kprefix], [install progs as rpc.knfsd etc])],
>  	test "$enableval" =3D "yes" && kprefix=3Dk,
> diff --git a/utils/gssd/Makefile.am b/utils/gssd/Makefile.am
> index af59791..9835117 100644
> --- a/utils/gssd/Makefile.am
> +++ b/utils/gssd/Makefile.am
> @@ -1,10 +1,17 @@
>  ## Process this file with automake to produce Makefile.in
> =20
> -man8_MANS	=3D gssd.man svcgssd.man
> +man8_MANS	=3D gssd.man
> +if CONFIG_SVCGSS
> +man8_MANS	+=3D svcgssd.man
> +endif
> =20
>  RPCPREFIX	=3D rpc.
>  KPREFIX		=3D @kprefix@
> -sbin_PREFIXED	=3D gssd svcgssd
> +sbin_PREFIXED	=3D gssd
> +if CONFIG_SVCGSS
> +sbin_PREFIXED	+=3D svcgssd
> +endif
> +
>  sbin_PROGRAMS	=3D $(sbin_PREFIXED)
> =20
>  EXTRA_DIST =3D \


--Sig_/OJ4EoWRIywwVcFdcD7E21FX
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVFmR4Tnsnt1WYoG5AQJdKhAAwrsrOJzEzTPjn21LqwtJEncuZmuc5wSu
UtbnQOiC8/yOThUAChZGyuuoai5Sbka5MQsqa9ZKnVozYg1lnPdHp8oAG9wLXlEC
pJNbZOKnMQQibBcy7dXZ7qyFFavs/I5kMWj8V0zyZRZ92K886NxNAFXlq9KXxEB7
TGUKUtllAjZBF0/thx4zNCPYOxkl7goLqGY0xIfz+Kyaug9+AHxpteeREqHslLlW
oa04qZOL7oMA/Ehzp/mhfgniB+NqSMKYo8vUbEkhe0IFY+Oog/w1ByYH5Bg3KrL9
rLCpsacMxo75LL5/RtpCEGUtlONwZ6q0dOXSATjNjm0IOFQJLS3m87fVHgv0aqDQ
8SNW4zHPotVvo71UJRNLIyz9XD6uUGKUBQvNTXTc1zFHf3NRW1S++llOcjEGY5HU
a7Hr9PT2LxKvWyMHfumstcrz/gKWrrpqk5K9Gp0mxyWNt+TBdzjrGwzFjlq7qvf0
k67b4ZY9AgILx3L2JzwN/2HeQQrzjSgF+UkVRGq/htLncMt+7miv35Irk6UeNKF4
AsecXWF4SXYR9q9R7F9UUFb0iPUGSB9Qey/dmfkLwmQVdOEIzxyJhTFtHdvxfCpv
mxFlIz88Ncpbm6Q8DB+AeWX0SiMdgHlN6qpe/rJJd+KIPkn/7oX6egMGSfuT6Qg8
i4EbDhN7J1o=
=ajoU
-----END PGP SIGNATURE-----

--Sig_/OJ4EoWRIywwVcFdcD7E21FX--

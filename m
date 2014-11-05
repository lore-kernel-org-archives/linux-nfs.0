Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:60724 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751209AbaKETpZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2014 14:45:25 -0500
Date: Thu, 6 Nov 2014 06:45:14 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] rpc.svcgssd: Add a configure switch to disable
 building the daemon
Message-ID: <20141106064514.4b8fd215@notabene.brown>
In-Reply-To: <545A4D8E.5010106@RedHat.com>
References: <1411489301-28991-1-git-send-email-steved@redhat.com>
	<1411489301-28991-2-git-send-email-steved@redhat.com>
	<20141105135633.4ea63a2c@notabene.brown>
	<545A4D8E.5010106@RedHat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/j8xixvKKZ.F5RZJyCyjOb2W"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/j8xixvKKZ.F5RZJyCyjOb2W
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 05 Nov 2014 11:17:18 -0500 Steve Dickson <SteveD@redhat.com> wrote:

>=20
>=20
> On 11/04/2014 09:56 PM, NeilBrown wrote:
> > Hi Steve,
> >  I just noticed that this causes an error when I try "./configure".
> > It tries to run a program called "enable_svcgss" with args "=3D" and "y=
es",
> > but this fails....
> >=20
> > A simple fix would leave the code doing nothing if enable_gss =3D yes, =
but
> > enable_svcgss =3D no.  Is that what you want?
> No...=20
>=20
> >=20
> > Should it be:
> >=20
> >         if test "$enable_gss" =3D yes -a "$enable_svcgss" =3D yes; then
> >                 SVCGSSD=3Dsvcgssd
> >> > +	else
> >> > +		enable_svcgss=3D
> >> > +		SVCGSSD=3D
> >> > +	fi
> > ??
> >=20
> > Would you like a patch, or will you just fix it up?
> I got it... thanks!=20
>=20
> commit e186d734cb3d7c53ef8038b2f62e5b1825d9fa26
> Author: Steve Dickson <steved@redhat.com>
> Date:   Wed Nov 5 11:12:03 2014 -0500
>=20
>     configure: Fixed logic around $enable_gss and $enable_svcgss
>    =20
>     Signed-off-by: Steve Dickson <steved@redhat.com>
>=20
> diff --git a/configure.ac b/configure.ac
> index 59fd14d..377ba2e 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -108,10 +108,8 @@ AC_ARG_ENABLE(svcgss,
>      [enable building svcgssd for rpcsec_gss server support @<:@default=
=3Dyes@:>@])],
>         enable_svcgss=3D$enableval,
>         enable_svcgss=3Dyes)
> -       if test "$enable_gss" =3D yes; then
> -               if "enable_svcgss" =3D yes; then
> -                       SVCGSSD=3Dsvcgssd
> -               fi
> +       if test "$enable_gss" =3D yes -a "enable_svcgss" =3D yes; then
                                         $
> +               SVCGSSD=3Dsvcgssd
>         else
>                 enable_svcgss=3D
>                 SVCGSSD=3D

Apart from the missing '$', looks good to me - thanks.

NeilBrown

>=20
>=20
> steved.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Sig_/j8xixvKKZ.F5RZJyCyjOb2W
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVFp+Sjnsnt1WYoG5AQJFhhAAkvdWTwMY+FeEEvIWDWrxrPE+ImwhIuW8
d0B42Re2d/hPJlYe5RUiZx2AizrxSwwOF526Ko5R3bzOZ7ASKLOfKhuM+smqZ3y6
kiAd47SblqOwS7Bje2mRo3pRW6EDVMu+G9bgWagBF+k1dSK/Mpr5IQcrUDYCVbAg
gVOja/pl3DM9HuWkxUOC6N3NQbZS3v/j4LrpspCteroHOMQxaE8x4Yj3A7CUAAwG
ySHvXa1hKsJj+eieVNX9k0/DXcqBuI/GfJ8L7najxEn4s5KUIdpYtqtaJZJTZ9xR
27v5fYDyQcqockIzm7KBKE4iFigk/C6qEqla9CQyhpP4kSDGep/JKHgvHad1C1MM
ggIS7rJFG/nkVwKqLD4VMJH2JcNBlLtXEMCK7/xkC/irg8+rvvANiO1OXnZaBs0U
c148irakWTEQg59cILk6W8M5n9GmgVeeCcOZGjkPm3fuEetmdKuLCx1NQVTf21Zh
kbsyH6ys8GvPESWb5v5aiWebTz0C0jjXmFr1bxb2bfJ4XijFVEFJta1mL9yd9nKB
r3rN49khdx3vwgfsHYcL+raxhdHuQougZQyj6gvXnh7PalYMkIj8h4C4I1K6bDK1
o6TJ0bfNbhHtT33jN9sDhPvhUtNzawH2qyfSm/TYRa7NdgEK4/rnFNkG4FIj8KSp
X6liTjZ8TyY=
=6f7O
-----END PGP SIGNATURE-----

--Sig_/j8xixvKKZ.F5RZJyCyjOb2W--

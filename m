Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-in-01.arcor-online.net ([151.189.21.41]:55549 "EHLO
	mail-in-01.arcor-online.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752442AbbKAKvK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Nov 2015 05:51:10 -0500
Date: Sun, 1 Nov 2015 11:51:06 +0100
From: Andreas Radke <a.radke@arcor.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: libtirpc <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: ANNOUNCE: libtirpc-1.0.1 released.
Message-ID: <20151101115106.54815c74@workstation64.home>
In-Reply-To: <56351BDA.1090500@RedHat.com>
References: <56351BDA.1090500@RedHat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/okE4/sMz1B+peWEo0NiC=3A"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/okE4/sMz1B+peWEo0NiC=3A
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Am Sat, 31 Oct 2015 15:51:54 -0400
schrieb Steve Dickson <SteveD@redhat.com>:

> Hello,
>=20
> The 1.0.1 version of libtirpc has just been release.
>=20
> In this release the SONAME has been changed to 3.0.0 to
> reflect a number of changes in the API. Those changes=20
> were needed to make the Linux version of libtirpc=20
> more compatible with other implementations =20

This break rpcbind recompilation:

src/rpcb_svc_com.c: In function 'handle_reply':
src/rpcb_svc_com.c:1298:6: error: 'SVCXPRT {aka struct __rpc_svcxprt}'
has no member named 'xp_auth' xprt->xp_auth =3D &svc_auth_none;
      ^
In file included from /usr/include/tirpc/rpc/rpc.h:62:0,
                 from src/rpcb_svc_com.c:48:
src/rpcb_svc_com.c:1300:22: error: 'SVCXPRT {aka struct __rpc_svcxprt}'
has no member named 'xp_auth' SVCAUTH_DESTROY(xprt->xp_auth);
                      ^
/usr/include/tirpc/rpc/svc_auth.h:63:7: note: in definition of macro
'SVCAUTH_DESTROY' ((*((auth)->svc_ah_ops->svc_ah_destroy))(auth))
       ^
src/rpcb_svc_com.c:1300:22: error: 'SVCXPRT {aka struct __rpc_svcxprt}'
has no member named 'xp_auth' SVCAUTH_DESTROY(xprt->xp_auth);
                      ^
/usr/include/tirpc/rpc/svc_auth.h:63:43: note: in definition of macro
'SVCAUTH_DESTROY' ((*((auth)->svc_ah_ops->svc_ah_destroy))(auth))
                                           ^
src/rpcb_svc_com.c:1301:6: error: 'SVCXPRT {aka struct __rpc_svcxprt}'
has no member named 'xp_auth' xprt->xp_auth =3D NULL;
      ^
Makefile:481: recipe for target 'src/rpcb_svc_com.o' failed
make: *** [src/rpcb_svc_com.o] Error 1
make: *** Waiting for unfinished jobs....
=3D=3D> ERROR: A failure occurred in build().

Do you have a fix?

-Andy
Arch Linux

--Sig_/okE4/sMz1B+peWEo0NiC=3A
Content-Type: application/pgp-signature
Content-Description: Digitale Signatur von OpenPGP

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWNe6aAAoJEJRlerIPKgkry9wH/2HhooJgxNnPbV53d853XYDl
p1NZ19XEmik9sG6ZTz4jkdZkWCs+Fw3mDBFnuazTPiEWcje/sQME8ssLAQbfMf7E
3mKj36jb8aUG+ldSA/3ijbl8Iy5nWjmQTI2xK8xnMDNoRckjpy7lSg94MB5roffk
/N/EVMrm6jF2sPdatZF3QI4KnklKEdtu7srHDaK7b97lgn/OGixUfBRrobSwjm67
U8vGxzjyQI4CeMM0/inh3BnedyUf8ELkvRwtTJfvy32nIiLaOkLm8xTHBqR65W1D
Sg7kw1fgN4e957Kbz8pFLJ+s8q1yRw2iX4vJ4ZtKrRiEahAaYJy1FO17tbf3UJE=
=jHn/
-----END PGP SIGNATURE-----

--Sig_/okE4/sMz1B+peWEo0NiC=3A--

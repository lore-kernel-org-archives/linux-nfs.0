Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.gentoo.org ([140.211.166.183]:50504 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933907Ab3BSTOl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Feb 2013 14:14:41 -0500
From: Mike Frysinger <vapier@gentoo.org>
To: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH [rpcbind]] fix building one systems w/out nss.h
Date: Tue, 19 Feb 2013 14:14:51 -0500
Cc: libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
References: <1361299690-19402-1-git-send-email-vapier@gentoo.org> <D1025EAD-8EEB-40A4-8EA4-0D21ECC16B66@oracle.com>
In-Reply-To: <D1025EAD-8EEB-40A4-8EA4-0D21ECC16B66@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart680669240.rEUriskGGZ";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Message-Id: <201302191414.51958.vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--nextPart680669240.rEUriskGGZ
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Tuesday 19 February 2013 13:54:19 Chuck Lever wrote:
> On Feb 19, 2013, at 1:48 PM, Mike Frysinger <vapier@gentoo.org> wrote:
> > The nss.h header is glibc-specific, so use the existing HAVE_NSS_H defi=
ne
> > to avoid including/using it when it is not available.
> > --- a/src/rpcbind.c
> > +++ b/src/rpcbind.c
> > @@ -67,7 +67,11 @@
> > #include <pwd.h>
> > #include <string.h>
> > #include <errno.h>
> > +#ifdef HAVE_NSS_H
> > #include <nss.h>
> > +#else
> > +static inline void __nss_configure_lookup(const char *db, const char *=
s)
> > {} +#endif
>=20
> Where is rpcbind getting the __nss_configure_lookup() function in this
> case?  I don't see that the call sites are ifdef-d out if HAVE_NSS_H is
> not defined.

i'm not sure what you mean.

if nss.h exists, then HAVE_NSS_H is defined, and the nss.h header provides =
the=20
__nss_configure_lookup prototype (and presumably, the C library provides th=
at=20
func).

if nss.h doesn't exist, then HAVE_NSS_H is not defined, so we have to stub =
out=20
the __nss_configure_lookup func.  i could have put "#ifdef HAVE_NSS_H" arou=
nd=20
all the call sites, but i think this version is cleaner and less error pron=
e.

also, i typoed the subject name ("one" vs "on").
=2Dmike

--nextPart680669240.rEUriskGGZ
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJRI88rAAoJEEFjO5/oN/WBwp4QAI9dg0JVhAsQiEq66RD0zubZ
t4IRaHBU1ifKnoqcccs0bfxrlbJBN2mAwE57BMDJbdHsrE7i6zH+zd0PdTHc4MbC
USfC3CxLxdcNTDcmcAL/KlejSdPhkSs99wwo9Ht1Q/AlZlUD+JSOVdbZr5YhUCzh
MOMskKMSf7LRgeTut08zPlC9qn6mZRs0aiKqJeau9WkrOXJUSRPLll/r+zXKt3YX
mtLVmG3iCvrYtRCSLn5ckhreddC75q984ofG+7V2z17/8jb7ltSYQz3c03mjfro6
x6OBL6Bi3o8HnlK7m7p5CZi70slF9XSs/CLUCvoB4UdPbpsTolxD/38A4txYq5P/
qo8If473ZXCF9+KyGFL6/QjVNiM7UU21/EVTz4K7Xz9O2KbHVJxvynt/yfmHk9nS
iPYqzgYNuFs50sjPDGcO7Af1bloWLFBVUxAR5bEZ6Uxlo+Cy0RJQFi8jG6BTs9M0
kcgK45rYudLOZeMHzkMa7ddS/ZASwZ6zGTCl7mLA8u5QI+MjQYndWvsEwDxf3ofZ
wqmUTmdMUJISLjVM3vO12k7EwE1MC4OGQhUH5dVQuMsSedK+Hy2l5++yb0UYXvZL
ZkamNC4b6FptHmUTs6d10s8xiRHVxfh2hdfmQEtqK+8DWm7ZCnp1ooWuNCRX9jtm
WGI6YR7xMJbNr+merRlj
=0hnw
-----END PGP SIGNATURE-----

--nextPart680669240.rEUriskGGZ--

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f45.google.com ([74.125.82.45]:57356 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751782AbaE3MUo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 May 2014 08:20:44 -0400
Date: Fri, 30 May 2014 14:18:08 +0200
From: Thierry Reding <thierry.reding@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] NFS: Use smp_mb__{before,after}_atomic()
Message-ID: <20140530121807.GA19178@ulmo>
References: <1401440815-4227-1-git-send-email-thierry.reding@gmail.com>
 <1401449890.4645.1.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="h31gzZEtNLTqOjlF"
In-Reply-To: <1401449890.4645.1.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, May 30, 2014 at 06:38:10AM -0500, Trond Myklebust wrote:
> On Fri, 2014-05-30 at 11:06 +0200, Thierry Reding wrote:
> > From: Thierry Reding <treding@nvidia.com>
> >=20
> > Commit febdbfe8a91c (arch: Prepare for smp_mb__{before,after}_atomic())
> > deprecated the smp_mb__{before,after}_{atomic,clear}_{dec,inc,bit}*()
> > functions in favour of the unified smp_mb__{before,after}_atomic().
>=20
> Where is this commit? It doesn't seem to have hit upstream yet.

It's been in linux-next for over 5 weeks now, so I'd expect it to hit
3.16 during the merge window.

Thierry

--h31gzZEtNLTqOjlF
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJTiHb/AAoJEN0jrNd/PrOhxwUQAKU3rpMrEeBP+ntJRmwatmSL
RpJSxIq6zQ2J+8cWjM/C5wHPaUpviKLUFGGFQQr4iBXkWdLczKN7ODEwzSN5bCWh
e64Y8RR7XhBcL3SD7how5o1ysNvP10y3OON66/8TmnodbtM9bix+j+Zt3jM2kdgn
8jnKmxMeX0yO3rU+yB+raE9rAAARUFJrdZRSFz1mo++8CcqN2QFRsZZ2TWDUf8PZ
p66drcV0YDbUYYUB1q1DJxqfLbxe44tDYlZoYnb1qY/JHPVuPk9Q1HQQtA8IpeUA
E4cL+N0oRlC6UF2TVblF9oJXPIEEQL8v8tt12Sw4VoaTGdUXzg62yTkAFToC4/k2
3ew6cxInQPv67TlBp+clZMFvFkBF/WG5aEWfKnSLUygA8LmgX8LW6ZusLW9GQk/V
lMzqkph/a5OJL9NsIdUyBoRRWdvDA/sn+I1FhkuUWESmDB1vT/M+xP9jbdndiSek
HdfX0Vi8xcgSCctoP/EDVe/dx59MxC0Y5YH8VZVrZSnI4DXgln1+FXwUE3X2qezD
Ey1MC4uFrDLkgnHgbcP6pWGbWMDtXrNZCHqt+UPLDx8PKWgZaydpteyfkFesqQPG
j7Se66v1phC0TTatGgLITM6CFmFfaDHQtfbVeTlLHRekdq5Z3n5fKcJIv+y8p08/
WL6VnyLgFYWok155uUQx
=I8Y+
-----END PGP SIGNATURE-----

--h31gzZEtNLTqOjlF--

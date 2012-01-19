Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vr160.rayconnect.de ([213.155.88.90]:36438 "EHLO
	mail.schwartzkopff.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753025Ab2ASPBW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jan 2012 10:01:22 -0500
Received: from nb002.localnet (cl-1872.cgn-01.de.sixxs.net [IPv6:2001:4dd0:ff00:74f::2])
	(Authenticated sender: misch)
	by mail.schwartzkopff.org (Postfix) with ESMTPSA id CA3BE129359
	for <linux-nfs@vger.kernel.org>; Thu, 19 Jan 2012 15:52:31 +0100 (CET)
From: Michael Schwartzkopff <misch@schwartzkopff.org>
Reply-To: misch@schwartzkopff.org
To: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 and high-availability
Date: Thu, 19 Jan 2012 15:52:30 +0100
References: <20120119135044.GS10362@ics.muni.cz>
In-Reply-To: <20120119135044.GS10362@ics.muni.cz>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart7546249.FY2Syddfhg";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Message-Id: <201201191552.30691.misch@schwartzkopff.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--nextPart7546249.FY2Syddfhg
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

> Hello,
>=20
> are there currently any options for HA setups with NFSv4? Is it possible =
to
> migrate an NFSv4 klient from one server to another one on the fly? (Witho=
ut
> remount, closing all apps, and so on, in the case that all NFSv4 servers
> share the same storage).
>=20
> I know it could be possible to migrate IP address from a crashed NFSv4
> server to another one, but this solution seems to be a last resort for us.
> Are there any options client based?

Yes. You can setup a NFSv4 cluster using a cluster manager like pacemaker.

Last time I set it up there were some issues with locking and timeouts. I=20
don't know if this is already fixed. I'd have to try it myself again.

Greetings,

=2D-=20
Dr. Michael Schwartzkopff
Guardinistr. 63
81375 M=FCnchen

Tel: (0163) 172 50 98
=46ax: (089) 620 304 13

--nextPart7546249.FY2Syddfhg
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk8YLi4ACgkQH8fVuZhm6xy5ggCgpayDhNbN4rvBxSwuCjMlRXHu
HSQAmwXA/URodHyO4I1TfJDZAxpzqrA2
=eTsh
-----END PGP SIGNATURE-----

--nextPart7546249.FY2Syddfhg--

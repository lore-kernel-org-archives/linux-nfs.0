Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.gentoo.org ([140.211.166.183]:40597 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753337Ab1LVQUJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Dec 2011 11:20:09 -0500
From: Mike Frysinger <vapier@gentoo.org>
To: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] nfsidmap: auto disable when keyutils is not found
Date: Thu, 22 Dec 2011 11:20:11 -0500
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
References: <1314991015-21484-1-git-send-email-vapier@gentoo.org> <20111222093855.40112b8c@tlielax.poochiereds.net>
In-Reply-To: <20111222093855.40112b8c@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1361722.GZoQQnBzFI";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Message-Id: <201112221120.12395.vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--nextPart1361722.GZoQQnBzFI
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Thursday 22 December 2011 09:38:55 Jeff Layton wrote:
> On Fri,  2 Sep 2011 15:16:55 -0400 Mike Frysinger wrote:
> > --- a/aclocal/libnfsidmap.m4
> > +++ b/aclocal/libnfsidmap.m4
> >=20
> > -  AC_CHECK_LIB([nfsidmap], [nfs4_owner_to_uid], [enable_nfsidmap=3Dyes=
],
> > -               [enable_nfsidmap=3Dno])
> > +  AC_CHECK_LIB([nfsidmap], [nfs4_owner_to_uid])
>=20
> The above delta in this patch has caused a build-time regression.
>=20
> When you eliminated the 3rd argument to AC_CHECK_LIB, this started
> adding -lnfsidmap to $LIBS. That means that that library gets linked
> into every binary that's being built.
>=20
> I haven't determined the right fix for this yet, but I think
> libnfsidmap.m4 could use some cleanup.

AC_CHECK_LIB([nfsidmap], [nfs4_owner_to_uid], [])
=2Dmike

--nextPart1361722.GZoQQnBzFI
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJO81i8AAoJEEFjO5/oN/WBaigP/3SM9sFndWU37/ris0PFy1ns
/9Dwjlp33TZttSPk1nbHASrEJncaAjm34jw+S98lPQ0Xtp1QtGPaQDZbSF2GFBmP
w+e9t5RnXEnVIrMbCyobXXeiP8do6iozm992sIusYLIsj6ad4yytQtyo8T4uj1EB
M/T+FyyycOP3oqEKnW28w6zvpXz7umXfSHXgf5hpxHA/7JTSJaBGbZb4ayigaXlt
eWWAqBU9sdu8uqEiMv7Wv8w9kQeKzy20slngC3Ggl/fQ17O1HRC0mLddahh4ivT2
sQY4NLAmkLIIibBjEejeY+EtSMmCOA5AkohAB2s1+4P+64OYttTcuQdvtSM3wKtd
XX0VROFwFGfdS24WfMY/xXSB1KVmGlzjR+3VZm9f1OyNax39KPCRtlqcP8fbwrVO
1kEeIN+tPznenhUWPfxkk+RMCIFbozNvWaES3vUw0sUZdD/7qmKLidA+f04ZNvE/
pRRv1D4TtMvV0qsQTRuycd9hqIdGsxHie5Q/0EZNDqlgbb+ZFKpcgkt1sBsM5hjT
EX5hvJZs99Su+dgAMscduAQ4gSva2xhguoQDkysoQMta6/4vraDKyjawjwpj9y7h
oDekE+E2UnFyPe+einhsYlIJqB9RhbM7qqKeqzB47uYZ8D3ZQKl84nRFJu9j7cip
bBIkTOaXIw3/C1Es4hn4
=7jiA
-----END PGP SIGNATURE-----

--nextPart1361722.GZoQQnBzFI--

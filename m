Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:57891 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751996Ab0H1UrJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Aug 2010 16:47:09 -0400
Received: from vapier.localnet (localhost [127.0.0.1])
	by smtp.gentoo.org (Postfix) with ESMTP id 986EC1B403D
	for <linux-nfs@vger.kernel.org>; Sat, 28 Aug 2010 20:47:08 +0000 (UTC)
From: Mike Frysinger <vapier@gentoo.org>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: `rpc.nfsd #` gets hung up when loopback iface is down
Date: Sat, 28 Aug 2010 16:46:44 -0400
Content-Type: multipart/signed;
  boundary="nextPart2031438.bYRsGoouUc";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Message-Id: <201008281646.44883.vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--nextPart2031438.bYRsGoouUc
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

is it expected behavior that `rpc.nfsd #` gets hung up whenever the loopbac=
k=20
interface hasnt been configured ?  even `rpc.nfsd 0` which seems a bit odd.
=2Dmike

--nextPart2031438.bYRsGoouUc
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.16 (GNU/Linux)

iQIcBAABAgAGBQJMeXW0AAoJEEFjO5/oN/WBDW8QALu4zMWRfFjAtXG+N0Mkkq5b
r1TnMulo8UG1n7RrA1Fa3vC5iJJM6sjN0uV1mg5iRo6ValbLOGi1fdn9lO4v2ETM
BwxDsMtqhLG5pGwnk/qwWyLHwAxPElo7yAMi2YYJhKZbupVle3DOyH4YuiOH0odz
Xo8o6iUjeu8OKsln5iDVHbM1U2IF8x9NVwOR6XT6rlSKI5a0GVE4lND47OkOJDIn
rxli9CGC3lfJJR6vYskx7/dFoGAZMEWd1AMVC2QHoLIC1jiIJO40ZMCNvoiPm10P
3HXTLusGifh0FDiirgGAxSF1Sa2RCvnMED9cNPEmBsLld7U7+MDyj7pjTvlDsBE3
sAxZ1hDu8UZQ1ncycZi5FmMTZWGIJ53CwIGV6spYm4eRQplBbZxM0KtxxHubanLK
jtzvVT25TEQl+pzcySYqfiHlsfjSLUBlOinu18A6Uya1VI+3XUZbgaSch1IzHO0K
IoLuc0p05iwTsfNE7j1BUxVrJQwcadlmqaOm5EaY0uhiJQHtRmUQ01RwFVG9eh/R
WKhsQ95dZ6C72hP4nVtdqr8VWjBptfmiTbCYj+bSj3ltRUjgVL+GuFYc4LvIaIW7
MSOFa6oKUMvPoCBRBSQhh1p9ueGxO2nzk2zH7uTi7yG5+768DltUumHNcEDZfmXQ
J8gHSqNb5L2hR8E1wX0M
=JX8O
-----END PGP SIGNATURE-----

--nextPart2031438.bYRsGoouUc--

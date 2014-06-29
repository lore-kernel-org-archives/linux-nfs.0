Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx02.posteo.de ([89.146.194.165]:60001 "EHLO posteo.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751401AbaF2Q3O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Jun 2014 12:29:14 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.posteo.de (Postfix) with ESMTP id 3A18625B17CE
	for <linux-nfs@vger.kernel.org>; Sun, 29 Jun 2014 18:29:12 +0200 (CEST)
Received: from posteo.de ([10.125.125.178])
	by localhost (amavis1.posteo.de [10.125.125.165]) (amavisd-new, port 10026)
	with ESMTP id p4BXjiQi9CBX for <linux-nfs@vger.kernel.org>;
	Sun, 29 Jun 2014 18:29:10 +0200 (CEST)
Received: from mail.posteo.de (localhost [127.0.0.1])
	by mail.posteo.de (Postfix) with ESMTPSA id 6D12B2C0115
	for <linux-nfs@vger.kernel.org>; Sun, 29 Jun 2014 18:29:10 +0200 (CEST)
Message-ID: <53B03ED5.6040400@posteo.de>
Date: Sun, 29 Jun 2014 18:29:09 +0200
From: Karl-Philipp Richter <krichter@posteo.de>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: (Follow) sparse file support (development)
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="S4ipTR636iX5k2t8r0ccGew66sN8R20E1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--S4ipTR636iX5k2t8r0ccGew66sN8R20E1
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Hi together,
I had trouble finding a statement in the NFS wiki

    http://wiki.linux-nfs.org/wiki/index.php/Main_Page

about sparse file support or development plans for it outside of (very
very) technical documents which I honestly didn't take the time to
understand. Maybe I can get you to give me short statement on this :).

Best regards,
Kalle Richter


--S4ipTR636iX5k2t8r0ccGew66sN8R20E1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJTsD7VAAoJEGadKJ8eJ7ZGwnMIAIv1n24a+UA35wcteBlrz46K
AYQmUiJhG85iVwHHcUQKA9sIPF5emcxEo+FBbNKjkqb+bBr3tdxC1c/xMvkMGhHl
xSolGjJdJfaPEIV58IFbU1V/AU9BUl49wvx41ziKHuf6LcFG2oar6bMZgPKa/6D3
bh/0GW4OkEMg48aXD6QcpFEOXWXr8IDqdcInBlmw/3UE7G8grFTPI5a9lPZjzMMU
DZo7nimmL3JLhlUOJzdcbgYdg3eAMw39SuOvpSttnSu8qPbry/kkuIHNKW8jl20K
0121WvYYuWqOTBYwln96fLTEraPIB5dTgB4dpsDHJb+0ozuSBkPYBy3dvrSug8I=
=cVAb
-----END PGP SIGNATURE-----

--S4ipTR636iX5k2t8r0ccGew66sN8R20E1--

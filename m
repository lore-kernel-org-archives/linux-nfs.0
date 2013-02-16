Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zarafa16.zmi.at ([212.69.164.59]:57223 "EHLO zarafa16.zmi.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753188Ab3BPLiw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 16 Feb 2013 06:38:52 -0500
Received: from saturn.localnet (h081217106014.dyn.cm.kabsi.at [81.217.106.14])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	by zarafa16.zmi.at (Postfix) with ESMTPSA id 9D0A018A03A7
	for <linux-nfs@vger.kernel.org>; Sat, 16 Feb 2013 12:30:13 +0100 (CET)
From: Michael Monnerie <lists.michael.monnerie@is.it-management.at>
To: linux-nfs@vger.kernel.org
Subject: How to make clients NOT block
Date: Sat, 16 Feb 2013 12:30:07 +0100
Message-ID: <680509590.JPpPf8D3KZ@saturn>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart9324502.SIcGh17B0a"; micalg="pgp-sha1"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--nextPart9324502.SIcGh17B0a
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="utf-8"

Dear list,

we've had several servers block today because they all have a NFS mount=
 point=20
from a linux kernel 3.7.6 server. This is the fstab entry:

1.1.1.1:/nfsshare/all /shared nfs4 defaults,tcp,intr,relatime,async,acl=
 0 9

The NFS server crashed and was offline, that made all clients block. Ev=
en=20
after the NFS server was up again, most clients were stuck to the point=
 they=20
had to be rebooted. What mount options should we use so clients don't b=
lock=20
completely when the NFS server is gone? It's no problem to unmount the =
NFS=20
share, or get errors, but the clients must not stop their work.

--=20
mit freundlichen Gr=C3=BCssen,
Michael Monnerie, Ing. BSc | Tel: +43 660 415 6531

XING: https://www.xing.com/profile/Michael_Monnerie
Facebook: https://www.facebook.com/michael.monnerie
Twitter: @MichaelMonnerie https://twitter.com/MichaelMonnerie
LinkedIn: http://lnkd.in/uGx6ug
Google+: https://plus.google.com/u/0/100598203632716687928/

Prot=C3=A9ger.at Internet Services Austria [gesprochen: Prot-e-schee]
http://prot=C3=A9ger.at | http://proteger.at
Facebook: https://www.facebook.com/protegerat
Mitglied im it-management Netzwerk http://it-management.at

--nextPart9324502.SIcGh17B0a
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEABECAAYFAlEfbcMACgkQzhSR9xwSCbRzAwCdGB3PRvgBkooNPDQkiNwVufY6
CUkAoLgQDHMKEYGBh2eAUHfHlT5yI0zr
=G/Bh
-----END PGP SIGNATURE-----

--nextPart9324502.SIcGh17B0a--


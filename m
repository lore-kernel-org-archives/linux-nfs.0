Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:48699 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750873AbaDOHyd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Apr 2014 03:54:33 -0400
Date: Tue, 15 Apr 2014 17:54:24 +1000
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: PATCH - nfs-utils] nfsdctltrack: ensure binary is installed in
 /sbin
Message-ID: <20140415175424.68a318e2@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/g2_Z9Hbx8eji0wAx7snR8LH"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/g2_Z9Hbx8eji0wAx7snR8LH
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


The kernel "knows" this lives in /sbin, so just like
mount.nfs and osd_login, it must unconditionally be installed
there.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/utils/nfsdcltrack/Makefile.am b/utils/nfsdcltrack/Makefile.am
index a860ffb82e2c..7524295f394e 100644
--- a/utils/nfsdcltrack/Makefile.am
+++ b/utils/nfsdcltrack/Makefile.am
@@ -1,5 +1,9 @@
 ## Process this file with automake to produce Makefile.in
=20
+# These binaries go in /sbin (not /usr/sbin), and that cannot be
+# overridden at config time. The kernel "knows" the /sbin name.
+sbindir =3D /sbin
+
 man8_MANS	=3D nfsdcltrack.man
 EXTRA_DIST	=3D $(man8_MANS)
=20

--Sig_/g2_Z9Hbx8eji0wAx7snR8LH
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU0zlsTnsnt1WYoG5AQIWvQ/+NaU96LmmXReUbdRKcnUYNP+xBSzgP6Hz
0cj2H4ea47REhj6M7ukv+dH2Sid5dfEdaEBoByhcpj+Ivwd/CnKyRwZAlVpt+TqP
N9g01+gI09D4QRgnXsNaWzEqTHk8h+iLBP2H43bfTemYC6TfnpcUHi7u4lwd2Qpf
T6ZTBnMXEdA3GO2+T6ZZuAcljkqtC4Gi3HeNNyNFAZjWm6aZ4/24va/cDJN0qSKj
xKce0dSN5qU5SxqTHtWUTeeURhCZV7RSM1vY5vlF700c5FC0OGlwhCmOdxa8q++t
8OGXnmgmcArrn48HZwW3D6ph+MbcZrkTERdfy+90ppQ7uds8zPRPxMn+tT2KBd7O
QD/reS6H0Qsey+z3bnNYAc31eSI5gUOtUKntSIH0f+FSxID2BcOmfBJwkmH5oO7v
7lp7JdyZDzS8MCzwFDeLAaTHaT+1M6Add5kY9Bm5TCEKtTHb/Y2nVX0VvC/VdgOR
t9wAYM6ljWzv+6p2qPhOd6RKOS3WgimDn0v+Nq/DuQ79IXwEJUvod0KTw5mdimgM
uhmeCD0MBzA6B+FWZHn5n134AnXKwTIQbSch8yB3RCwK0/r+nMp891J8Xpw4bIdD
/qr8Jg59q/xyAlivyACEvJu+CXgwISm+O+YCdk0ALReXygzh/DcSv/LtiRaJlKRq
Ml9YIOECLjY=
=4aE2
-----END PGP SIGNATURE-----

--Sig_/g2_Z9Hbx8eji0wAx7snR8LH--

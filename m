From: Muli Ben-Yehuda <mulix@mulix.org>
Subject: [PATCH] fix compile warning in fs/nfsd/nfs4xdr.c, 2.6.0-t5-cvs
Date: Sun, 21 Sep 2003 11:09:23 +0300
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030921080923.GC4938@actcom.co.il>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Sr1nOIr3CvdE5hEN"
Cc: Linux-Kernel <linux-kernel@vger.kernel.org>,
	nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Neil Brown <neilb@cse.unsw.edu.au>
List-ID: <nfs.lists.sourceforge.net>


--Sr1nOIr3CvdE5hEN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

When compiling fs/nfsd/nfs4xdr.c, I get a warning:

fs/nfsd/nfs4xdr.c: In function `nfsd4_encode_open':
fs/nfsd/nfs4xdr.c:1773: warning: `return' with a value, in function
returning void

This patch fixes it. I'm not 100% sure about it, but it seems
correct, and the return value is ignored anyway...=20

diff --exclude-from /home/muli/p/dontdiff -Naur ../linux-2.5/fs/nfsd/nfs4xd=
r.c 2.6.0-t5-Werror/fs/nfsd/nfs4xdr.c
--- ../linux-2.5/fs/nfsd/nfs4xdr.c	Tue Sep  2 12:51:06 2003
+++ 2.6.0-t5-Werror/fs/nfsd/nfs4xdr.c	Sun Sep 21 10:18:19 2003
@@ -1709,13 +1709,13 @@
 }
=20
=20
-static void
+static int
 nfsd4_encode_open(struct nfsd4_compoundres *resp, int nfserr, struct nfsd4=
_open *open)
 {
 	ENCODE_HEAD;
=20
 	if (nfserr)
-		return;
+		return nfserr;
=20
 	RESERVE_SPACE(36 + sizeof(stateid_t));
 	WRITE32(open->op_stateid.si_generation);

--=20
Muli Ben-Yehuda
http://www.mulix.org


--Sr1nOIr3CvdE5hEN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQE/bVyzKRs727/VN8sRAto2AKCO53m8PNgLFlu+SSWriqFuBO/QjwCguBqU
KzpMAFa5zYYeYnojylOaMAs=
=aOTg
-----END PGP SIGNATURE-----

--Sr1nOIr3CvdE5hEN--

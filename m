Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:50155 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754546Ab3J1DnQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 27 Oct 2013 23:43:16 -0400
Date: Mon, 28 Oct 2013 14:43:05 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: Tony Asleson <tasleson@redhat.com>, NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH - nfs-utils] exportfs: report failure if asked to unexport
 something not exported.
Message-ID: <20131028144305.0f91f025@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/aC=CcOuqh5b9fqU5ZvnE4G2"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/aC=CcOuqh5b9fqU5ZvnE4G2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



Currently if exportfs is asked to unexport something that is not
exported it silently succeeds.  This is not ideal, particularly for
scripting situations.

So report an error unless the unexport was successful.

Reported-by: Tony Asleson <tasleson@redhat.com>
Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 52fc03d..c9e12db 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -351,6 +351,7 @@ unexportfs(char *arg, int verbose)
 	char		*path;
 	char		*hname =3D arg;
 	int		htype;
+	int		success =3D 0;
=20
 	if ((path =3D strchr(arg, ':')) !=3D NULL)
 		*path++ =3D '\0';
@@ -397,7 +398,10 @@ unexportfs(char *arg, int verbose)
 #endif
 		exp->m_xtabent =3D 0;
 		exp->m_mayexport =3D 0;
+		success =3D 1;
 	}
+	if (!success)
+		xlog(L_ERROR, "Could not find %s to unexport.\n", arg);
=20
 	freeaddrinfo(ai);
 }

--Sig_/aC=CcOuqh5b9fqU5ZvnE4G2
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUm3dSTnsnt1WYoG5AQJ0YhAAs9ygvWxCf5V2YP4EyHabVGPPJ+pCmoDo
l6gKVy0p9sMgkC57XPxtQMJTeyRKfbl+Bg2yjXVCotLOLGrynrfV1sLzBz4BiXrE
6mqoIcEWtL7yuk+7RlkLnMiAVY5byNDiycdwP1oIijKrDwAFpYOOUaIee6eJy7in
uWCvgn4DwfoVtkhiEQSsQdUfB0z/6ZomBa5xyT0mjt48k05aoe8nsm/cjfokr5UY
fLDOXmu+VgKbkt4/DqETcE4uVxR7uW/4p3MEympbL1tYPdz4QoLrJcpMh9qsBl4M
j7lrN6FppKWWSe24kBuwNvmsk2O0Xx0UBHRrk9WaW8fc9/XNI3dFqMzNu2wwDoAi
+Urq+F1oBCFWz98SXOTUwnbZYCTyuuJUnmVfu8EJDt1/HLsBEhGTxXxIL0msy8ng
X+iJIrqQ8aMYdAhdVdYRriXWVO5G9D711N4t18iCtCp/0Ni249Hvz3czioygK9JB
wKIW4Gbo5BBRdQkDX3ZERNHvxwOXlLhBiyz3vP+pyiDU6g9q3chb1iXsiH5uBH2X
uH32KIc094Lo97/eRuUd93ozzHWT62+wVzueu2BmdeTSNSR+18aegXZGR37+IMEi
eu6TK4FY8nx/nmodPtfQKvr7ubxuWlQsfJQV0BzYyT9rtpyynQrMgx4bkRuO/op3
c5SoZ2i5XY0=
=avhp
-----END PGP SIGNATURE-----

--Sig_/aC=CcOuqh5b9fqU5ZvnE4G2--

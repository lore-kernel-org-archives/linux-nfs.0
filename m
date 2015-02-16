Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:57312 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752022AbbBPBTE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 15 Feb 2015 20:19:04 -0500
Date: Mon, 16 Feb 2015 12:18:56 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH - nfs-utils] mountd: fix next_mnt handling for "/"
Message-ID: <20150216121856.7efe2237@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/d2LNGpbEp=zRLlJ2=pDdsqF"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/d2LNGpbEp=zRLlJ2=pDdsqF
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



If the (exported) path passed to next_mnt() is simply "/", next_mnt()
will not report any children, as none start with "/" followed by
a '/'.
So make a special case for strlen(p)=3D=3D1.  In that case, return all
children.

This gives correct handling if only "/" is exported.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index c23d384d24eb..ac36b6d9f21e 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -377,6 +377,7 @@ static char *next_mnt(void **v, char *p)
 	} else
 		f =3D *v;
 	while ((me =3D getmntent(f)) !=3D NULL &&
+	       l > 1 &&
 	       (strncmp(me->mnt_dir, p, l) !=3D 0 ||
 		me->mnt_dir[l] !=3D '/'))
 		;

--Sig_/d2LNGpbEp=zRLlJ2=pDdsqF
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVOFFgDnsnt1WYoG5AQI5YBAAkgn3aweMyJF/Jse4AbQjwEYLI0ZpXEWY
H3IWFkkGgUPxjQYoZLYUlMBLsuaGBwN5IgIIXykY5podfrG5b9VWYK8GDW1t9Lr1
DRcm2EaWb/oI+K8ZFqDPANlJ9liF1YmPFRWWyD2E/c0WpTfFGz6OJ/YeZXWC1zGV
imMbwi1FeHKVSKoCV/6YWAc3F/XwWK+YrmY6t3tHgGeBdWxrWvRhk92iK0gov6kL
x7Kmh2g09rgbLfrHlLxQTQ+3OU2L5KRW9+MMHNOZXsaw7vYOnBbYxhROlq1Z5b+b
2tssSbAchX0PN1cJoGebVBBuo8ZW+Qnh7/PO0HfBdbRIqLRI4yFNetk7UyOEk6fx
biYlZZCLjpGyRM5KbIRHz1i4PoQ9V7zsAD3Iz8HHD/n3GC3R6oAr7nSegGBjKtzQ
Wi1jMVL5MUa/oODKLoIRr+3w2H/hQ0Nc98zeUUFNx8t76HXrbcYEjOWiA5egabAy
mIjE+xKwAyQHvyNLw5lGN02Vchr+JGqgthQOQzH1cQ+KF81H1m04bEMPZ5Vpg/q4
Pw9M8q0uptohaMd9HsiwzAe9xCDC6fEkLb9BDqe3uhZMiWqSjBU1iWCvMQaShvC5
GKpGAYNwtY4Wico5q86jfj6DmnGRLfVbAncFg/qMZUJiTJ7Fsy3L95hMSTiy7r2s
naXXNLFpyL4=
=skMR
-----END PGP SIGNATURE-----

--Sig_/d2LNGpbEp=zRLlJ2=pDdsqF--

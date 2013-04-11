Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:53161 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935511Ab3DKBCB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Apr 2013 21:02:01 -0400
Date: Thu, 11 Apr 2013 11:01:50 +1000
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH: nfs-utils] mountd: fix exporting of "/" with sec= setting.
Message-ID: <20130411110150.39f127aa@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/7QIN5m0S=+.s_WPuQBuwe7O"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/7QIN5m0S=+.s_WPuQBuwe7O
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



Commit 91bb95f2689e84856ecdf6fac365489d36709cf9
   4set_root: force "fsid=3D0" for all exports of '/'

set NFSEXP_FSID for the export of "/" if nothing else had any fsid set,
however it didn't also set the flag for all security flavours.  So the
kernel complains that the flags on the security flavours don't match and
it rejects the export.

So call fix_pseudoflavor_flags() in write_secinfo() to make sure that
any fiddling that has been done to e_flags gets copied to e_secinfo.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 5960feb..1fbf754 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -177,6 +177,7 @@ struct export_features {
 };
=20
 struct export_features *get_export_features(void);
+void fix_pseudoflavor_flags(struct exportent *ep);
=20
 /* Record export error.  */
 extern int export_errno;
diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index 6c08a2b..dea040f 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -469,7 +469,7 @@ static void clearflags(int mask, unsigned int active, s=
truct exportent *ep)
  * ensure that the export flags agree with the flags on each
  * pseudoflavor:
  */
-static void fix_pseudoflavor_flags(struct exportent *ep)
+void fix_pseudoflavor_flags(struct exportent *ep)
 {
 	struct export_features *ef;
 	struct sec_entry *p;
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 978698d..53552b3 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -735,6 +735,7 @@ static void write_secinfo(FILE *f, struct exportent *ep=
, int flag_mask)
 		/* There was no sec=3D option */
 		return;
 	}
+	fix_pseudoflavor_flags(ep);
 	qword_print(f, "secinfo");
 	qword_printint(f, p - ep->e_secinfo);
 	for (p =3D ep->e_secinfo; p->flav; p++) {

--Sig_/7QIN5m0S=+.s_WPuQBuwe7O
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUWYLfjnsnt1WYoG5AQLApBAAoGCPl04rWYEJ38DGGnO4OC9DwL8HI5mb
qbhMDM0tcmRIz/eY7PXzyapELu2rP7XXc5khFSfNxRCeKlDitZ6hpjWHoYi9DiWE
YmunLmWao8VzqRzvyorNkjGTJ/h37So+nugiV2vsAkGaAGOpNbPM9N3lKH5akCYi
8spcGugjZzUOWoKFJQT/NChkbLi3jiwJtEI90kGSCcDeZrRpDHpghp+Lt146y4gD
lZcQ1v3hRyVIM4ncgtkeQASqXuOQI105Dtt5pr5w71eKo1XBgVF6WIvGFISBXnMk
cYefmg8rdTjO4M/rzn4lYY7ScKfG+SEK1j6HkQEu73XcNKF8QQIYVFSgIeb3ctgP
SNO9xQP/QP5OPXk3HJKXF/2D7LZK0MttQiBigge5TxEQxBu8DVaRepicbBJAECtf
xYu26cGB44yyQIT7LYH8o8IugUo21RXXwnjgGHIEy75FYXbhs7RVbBtTaDrv11NQ
Q/QZfJb7IgIPrDxX7Rdz2W3090CUzF18hfjp82M0XBO5A16KNuL3dChMfRA5Y/nJ
myh2q8aPl7nF5uP7d3FCHnJ9y3WRGtkNKBcDdkSARRm6Iy4FGA/ySgBmTY24jrZi
4E0GzTIznFm5TQt3eH92cvJpwhfMrp9hT4gWPlysA6Bq9hIEANVcUT+eNyKejZqf
WXFIGouF8Fw=
=VlrW
-----END PGP SIGNATURE-----

--Sig_/7QIN5m0S=+.s_WPuQBuwe7O--

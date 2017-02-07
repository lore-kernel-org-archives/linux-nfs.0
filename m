Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59413 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753798AbdBGW4Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Feb 2017 17:56:16 -0500
From: NeilBrown <neilb@suse.com>
To: steved@redhat.com
Date: Wed, 08 Feb 2017 09:56:09 +1100
Cc: Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: [PATCH] mount: call setgroups() before setuid()
Message-ID: <877f51wqye.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


It is generally wise to call setgroups() (and setgid()) before calling
setuid() to ensure no unexpected permission leaks happen.
SUSE's build system checks all binaries for conformance with this
and generates a warning for mountd.

As we are setting the uid to 0, there is no risk that the group list
will provide extra permissions, so there is no real risk here.
But it is nice to silence warnings, and including a setgroups()
call is probably a good practice to encourage.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 utils/mount/network.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index d1c8fec75174..281e9354a7fa 100644
=2D-- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -33,6 +33,7 @@
 #include <errno.h>
 #include <netdb.h>
 #include <time.h>
+#include <grp.h>
=20
 #include <sys/types.h>
 #include <sys/socket.h>
@@ -804,6 +805,7 @@ int start_statd(void)
 			pid_t pid =3D fork();
 			switch (pid) {
 			case 0: /* child */
+				setgroups(0, NULL);
 				setgid(0);
 				setuid(0);
 				execle(START_STATD, START_STATD, NULL, envp);
=2D-=20
2.11.0


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliaUIkACgkQOeye3VZi
gbl/vg//fOSwku3ic8Uyfp4APXzXfQL+6YEJ9A+jWHcjjmlpBuMmkxuOypeSCRrV
AHhPGNrmrhZ+i9HTGd+buvQpv37AE58Y+lv9B8wFNemBnIypq2ze3RD3U1EW+8eM
XeAfypgyVISqRdCyjezhUlPTlcuf3JcUMwqshmUETuGWVqL+do4Al82C9oQTtpGT
cm6lJP8DiQyUXCkk/9aMMINIgG7cG9Ixbn59kLVxQOkLCpIpBMowBS7zQQ5FxkAK
eZ69eyemjitr5WOmgjJh0mvJ0b7p6FLmhvBtBl6BP5nNdQszl0RLZ10wX1AbtuHp
pUTKJ6enWOU2epMcT7v4Omq59v/XpzGyv+ButqPDFcgW1qyzTCOuP5S0BoO9rc1U
iQ87BsShvresVwmhdcJI4WSWQyh4zg9e5JANazY3KHORmGcpJbXmE1TTviEglyJ7
ygHvSBZUJfL+MpHquUGQhUP4kbtMOonuG0w58Y9oAzVVzO2P6w91kOc0VAx/j9H5
gAVA+1QevxxGmR87GDd0hBp9PfWJ0RaKRDIqlXAcJm2H4Glden3P18j6I+HB5X43
e+ap2PaAHC4aZFaso3q+UIym9MJOFCm28dnSmde6k7cwCmZc1mm1wmp1i45KEcIz
/lgGYPiufkm121rNpFa9aWgbLDXo66okjJetBsqPKgZ4hbORyow=
=lD+C
-----END PGP SIGNATURE-----
--=-=-=--

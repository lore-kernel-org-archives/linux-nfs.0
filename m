Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:53692 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933932AbcCPBec (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Mar 2016 21:34:32 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Wed, 16 Mar 2016 12:34:24 +1100
Cc: Benjamin Coddington <bcodding@redhat.com>
Subject: [PATCH - nfs-utils] systemd: ensure nfs-config service is re-run as needed.
cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Message-ID: <87fuvrfbof.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


The nfs-config service translates distro-specific startup
configuration into "environment" variable read and used
by systemd unit files.

Currently it is only run once, so subsequent changes to the
distro-specific files do not take effect when an nfs service is
restarted.

If we change "RemainAfterExit=3Dyes" to "RemainAfterExit=3Dno" then the
service will be restarted before any dependant service is started, so
the environment file will always be up to date.

Reported-and-tested-by: Benjamin Coddington <bcodding@redhat.com>
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 systemd/nfs-config.service | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/systemd/nfs-config.service b/systemd/nfs-config.service
index 7f653058f424..e0a7f83314f5 100644
=2D-- a/systemd/nfs-config.service
+++ b/systemd/nfs-config.service
@@ -5,5 +5,9 @@ DefaultDependencies=3Dno
=20
 [Service]
 Type=3Doneshot
=2DRemainAfterExit=3Dyes
+# This service needs to run any time any nfs service
+# is started, so changes to local config files get
+# incorporated.  Having "RemainAfterExit=3Dno" (the default)
+# ensures this happens.
+RemainAfterExit=3Dno
 ExecStart=3D/usr/lib/systemd/scripts/nfs-utils_env.sh
=2D-=20
2.7.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW6LggAAoJEDnsnt1WYoG5ZXYP/Reo1qpCeeY8/2UfA6oYH+M1
4mKaRKREHuDeEcN7ycFOUQ0+xpzI32RHF2cJDgBPkQ2SweIOrB4wMA9gRDgNmAS1
Ve1IevgXz5lC0GreGZsTVhZNHv/KpfOlbRlkyR5NFSwY/TzVKnTCOO96le1qN2bm
u6KbgNTmtlQr3YppxA18pCBpvH5UKPmTUG8Fwu0gsIJVV+gDZdmBxIrXjyXtFfVI
0TGuL9yuoGoLHulWg1HlFYkh/kv4UWI0vobhvK587XLSuen4bRj8OQumCCTWR7KZ
zphQfce25CRccUSdJHzL6wNjBINEhU8s743N8MbMdj2NYgmXrLPw9j1yaLTkICiD
vlfqLOZKXRE/8OlhVt+YkWjp5uerJE4YlGgxZgqASSh7pri9vOnTFtpui9nPxxPM
cliruMkU0RJDbJFtihUmWTU6Zx6dr/MnM0c953HMg4quZLsshUVEaQmbbslxIhVF
Z54MfHlpr2I3J3JY/s51oMfSUBZVxLNujqINuJX4PKEtod9UKWxoo2RIngAjBgQj
E7Rc50a7Yus3i7mM8OfrKUuhGQvKC4edp+2W0BfxrVyzb0S6eCOgS3hx401i9SgC
d1KHhpFHxvdMlugNZE/bkeINqrCfVpzQOFn3fkShbF6LqNevRaIVU/Veha40vmsb
mgBoXzvEiCoTajc9Sa82
=aH5N
-----END PGP SIGNATURE-----
--=-=-=--

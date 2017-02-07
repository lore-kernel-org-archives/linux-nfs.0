Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59350 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752108AbdBGWyz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Feb 2017 17:54:55 -0500
From: NeilBrown <neilb@suse.com>
To: steved@redhat.com
Date: Wed, 08 Feb 2017 09:54:47 +1100
Cc: Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: [PATCH] conffile: ignore empty environment variables.
Message-ID: <87a89xwr0o.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


conf_set() already refuses to set an empty value, so if
  foo=3D
appears in the config file, it will be ignored.
This patch extends the policy to environment variables, so empty
environment variables are treated as though they didn't exist.

This means that a separate environment file (e.g. /etc/sysconfig/nfs)
will be treated the same way whether it is:
 - included in the [environment] section of /etc/nfs.conf
 - sourced by the shell before running code
 - sourced by the systemd EnvironmentFile directive.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 support/nfs/conffile.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index e717c1e39bab..203efd2aa602 100644
=2D-- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -533,7 +533,7 @@ retry:
 				 * or from environment
 				 */
 				char *env =3D getenv(cb->value+1);
=2D				if (env)
+				if (env && *env)
 					return env;
 				section =3D "environment";
 				tag =3D cb->value + 1;
=2D-=20
2.11.0


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliaUDcACgkQOeye3VZi
gblqnA/+I/XXM/zI9AN2AbU4OLt14K6QANz49q29SATpHjgGBfTkxqGyI+/Z8YYD
UliEKL/MOPeYmXXHvd3SxdAET6YqqqhBLIebTvz0UV9taKmHUuypzepNNCapbDsJ
AvbNHVvkR96MBmjf1Ye8lRA1qEv2H6kJ/p+4C04Lhqz2sRMrCbS2jBwuCDaot7/3
BTYWFW8uEncku9k1aHGVVnPx4ZiQXHj6RVcjusSncoLVqRQnto0TYaDErrPFNs9C
UoR1nQo914y1opqCtBCfb3ImA9xgjiMN/vlI5Jz7xowTu9G1QWbtlgzLpYE7z9Yy
P+wBRlhRJZnAHGX0labdRCDo8hxgmw0UMepBlnvx6T/uUTGVo9I4wksw4ArRomtz
x0DElgdfWnIzOKLg9xwfm4R2E6xTUm7V3bEuogV+AH4pIipegn4op+hkL6PcferO
iRjQRMhzDzb9jEf+OHGvMLKvdgwyNc8TMwmgTmA/4fgFFEC4fgqEFQCkl4IwN+9q
HwXsdZEkJUQm1DERcI7mlhHz5Bo/TZdqNX8S4XpQaWL0z2Dnv1P71VoFJPJyt3rA
9ETMk+4+7eV0cWvKqE0bTJMWteYWAM4WkmTmKMw98GbCBG3ma+3qH2Be5Wa5AuwI
fOcau7HymNJxkLV3uUGDO66XLha5DeX6tOZlXhxMqM5sGb4ZqHk=
=YMRi
-----END PGP SIGNATURE-----
--=-=-=--

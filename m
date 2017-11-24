Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:34808 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752318AbdKXEaQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 23 Nov 2017 23:30:16 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Fri, 24 Nov 2017 15:30:07 +1100
Cc: "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Lennart Poettering <lennart@poettering.net>
Subject: [nfs-utils PATCH] mount.nfs: don't parse "device" name for -o remount
Message-ID: <87zi7cxprk.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


When "-o remount" is used, the device/special name
is ignored.  So don't parse it and risk generating a
useless error.

This is particularly important when nfs-root is used
as the "device name" is listed as "/dev/nfs".
Because mount.nfs doesn't think that is valid,
  mount -o remount,rw /
will fail.

Link: https://github.com/systemd/systemd/issues/3590
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 utils/mount/stropts.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 440131482e2b..12178235f068 100644
=2D-- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -384,7 +384,9 @@ static int nfs_set_version(struct nfsmount_info *mi)
  */
 static int nfs_validate_options(struct nfsmount_info *mi)
 {
=2D	if (!nfs_parse_devname(mi->spec, &mi->hostname, NULL))
+	/* For remount, ignore mi->spec: the kernel will. */
+	if (!(mi->flags & MS_REMOUNT) &&
+	    !nfs_parse_devname(mi->spec, &mi->hostname, NULL))
 		return 0;
=20
 	if (!nfs_nfs_proto_family(mi->options, &mi->family))
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAloXoFAACgkQOeye3VZi
gbl0Fg/+PPiQVixci5x+lHCKrRctSJxmcZ0PjKwS7whvGIA3YAAhUkDADb7DPIbR
j1HhwEMMODl7oqN8s7U5jnIrwWNylBrjLnLQ+O2ughdt3ycUi4vnshBWWXII6s1C
9FMm9Lo9osMnuOVOX5hWDmI2IrlvqGAKuyZIBi6w20LcNptxdYV+3U7bkfw8DGqw
tGMAykScyVayrU4alxGKVkhybPGvMBwQ0QEAz5y89VogDxJD8qzYV9iPmmOQVaWM
VfdGyQiBMPqngXcwSt9FhzfKvRtq4dJAlaBlHXkNol+OaQkIr+R7UWegKE6Tbv9j
U8QCeyrPdxokh+q+upX0r7TKeIHF/vTjHVwtD3SNqvzcLOaGoZPq9XMe537s2oI0
CzFM1x+UuILoNGMuknG+zZGAn8YvIjglFJJUFEjf/q+hDcvJSncFXOaA8tlyVlBj
U9QIgnNM+5mt+HNm81+WNA1o4x49HJPIAzXrHg1IV7QcpU32LAIKiZTXYJ/egFUh
XgzHJqjVoN7tiPA1jWi13eIf+VrphkjaV9dvHNonnhPmF3OPHP2Run6hoy1vWVy8
f1SPXrRzkNpT3YosQ2sgBf8xrPKVsdm9XzRkHPu/ZyTCQjqaulaw0TtzPCBKSndI
kA8iEEU/o0UaJYu6U6xRSln4lpR4HFBboALi0QoikGR2wCw75J4=
=42Jz
-----END PGP SIGNATURE-----
--=-=-=--

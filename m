Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39964 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750841AbdHJGdE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 10 Aug 2017 02:33:04 -0400
From: NeilBrown <neilb@suse.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Date: Thu, 10 Aug 2017 16:30:36 +1000
Subject: [PATCH] VFS: lookup path of "-o remount" the same way as "umount"
cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        lkml <linux-kernel@vger.kernel.org>
Message-ID: <87shh0q6ib.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


"mount -o remount" does not need to validate the target directory
for the same reasons that "umount" doesn't.  It just needs to
find the mountpoint and verify it is a mountpount.

So change do_mount() to use user_path_mountpoint_at() in the
MS_REMOUNT case.

This means that mount(.., MS_REMOUNT|MS_RO, ..) on a network
attached filesystem will only access the network if there
is data to be written out.  This reduces the chance of a hang
when the network is down.

Systemd-shutdown currently calls
   mount(NULL, path, NULL, MS_REMOUNT|MS_RDONLY, ...);
   umount2(path, 0);

which is not unreasonable for local filesystems which may still
be in use, but causes a hang for NFS filesystems which have not
been unmounted.

Note that this change does not affect
   /usr/bin/mount -o remount,ro ...
as that currently calls "lstat()" on the mount point.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 fs/namespace.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index f8893dc6a989..31ded3a1cdff 100644
=2D-- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2718,7 +2718,10 @@ long do_mount(const char *dev_name, const char __use=
r *dir_name,
 		((char *)data_page)[PAGE_SIZE - 1] =3D 0;
=20
 	/* ... and get the mountpoint */
=2D	retval =3D user_path(dir_name, &path);
+	if (flags & MS_REMOUNT)
+		retval =3D user_path_mountpoint_at(AT_FDCWD, dir_name, 0, &path);
+	else
+		retval =3D user_path(dir_name, &path);
 	if (retval)
 		return retval;
=20
=2D-=20
2.12.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmL/Y4ACgkQOeye3VZi
gbktyw//ZJMrHhtJMHwdShovN7P7eHEQwEprJeW9JmgU6A5ck3Buy8+sCdnwJEnL
SFZq/41HwS6mc0n2nIoMDgn/G6VlSFLmjE3oJqkaa0B68OFKFQ9SHv4kvtggUQ9h
VbQ2tZmiXrKldsZgc1aTr6SEGAVzXJTwvcSSY/bDyM2jGMuVdi/E28Bx9v/9tEAQ
C0VIcqe8wEpHnfgVQFgmRQX1M/sfSm5mjWDe53yB+XX+Ytj8XySVhjxB+0L9wiwp
yWFCxDCrS+LVxQl1j27zWnAl2QRzPoZF2yK8r+NW6XMDXyPNqO5qKOPSyAkO90KJ
Ic+d8c3nBDr6QWicpQL9NIDVl25Q5kRV9DJPwRSwJn+FSJbZSyLC33eZCczkSnkZ
VB5GhvxyrtJPeOpKU0SxJycOUJ9SfglkFvUTEaYgHTLkTCb7BZ8hM9EQAfBLF16e
PfwV/i34wy/yZSYGGES7zePtffZmi6VCx2Eb3gFwCIxfduELhGhhfBDRnENHk779
IoKJxKosabbqmiJ47s/ALMP/q55ZBj9xFEdc7NC4L7CUdzcJGgCg3tuC+640Y7uX
R6pHW9V4ytHxYH+T7TGkbEB3qVgMKL2W1ltqsO1Ij2Q5GcbO93df9POrK08sP9V6
OJjwS4N/rbjjy2QDcAC/qU7CyWiCDPBIWBHUdGXrBYKsp/GVhuk=
=RZs+
-----END PGP SIGNATURE-----
--=-=-=--

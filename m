Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56764 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751204AbdFECir (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 4 Jun 2017 22:38:47 -0400
From: NeilBrown <neilb@suse.com>
To: util-linux@vger.kernel.org,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Mon, 05 Jun 2017 12:38:39 +1000
Cc: Franck Bui <fbui@suse.com>
Subject: [nfs-utils PATCH] umount.nfs: assume path name is canonical.
In-Reply-To: <8760gbduzp.fsf@notabene.neil.brown.name>
References: <8760gbduzp.fsf@notabene.neil.brown.name>
Message-ID: <8737bfduq8.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


/usr/bin/umount will always pass a canonical name
to umount.nfs, so it is safe to disable canonicalization.

When umounting an NFS filesystem, it is generally safest to
not "stat" the mountpoint at all as that can block
indefinitely.  umount() will not block, but lstat() etc can.
By disabling canonicalization in libmount, we discourage it
from ever calling 'stat' family operations, and thus reduce
the chance of a hang.

Note that to be fully effective, this requires changes to
util-linux which have not yet been accepted.
When both that change and this are in effect, automounters
can use "umount -c $PATH" to safely unmount a filesystem
without blocking.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 utils/mount/mount_libmount.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/utils/mount/mount_libmount.c b/utils/mount/mount_libmount.c
index 1f01f7f7a4e7..2d4065759a6c 100644
=2D-- a/utils/mount/mount_libmount.c
+++ b/utils/mount/mount_libmount.c
@@ -188,6 +188,7 @@ static int umount_main(struct libmnt_context *cxt, int =
argc, char **argv)
 	};
=20
 	mnt_context_init_helper(cxt, MNT_ACT_UMOUNT, 0);
+	mnt_context_disable_canonicalize(cxt, 1);
=20
 	while ((c =3D getopt_long (argc, argv, "fvnrlh", longopts, NULL)) !=3D -1=
) {
=20
=2D-=20
2.12.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlk0xDAACgkQOeye3VZi
gbkQkQ/6AlOcgJFkr49ABY0mx1sKyJEKHVf1F13NmHp1WVDC4Mw8mStJ51keSiDj
hlKfGL1w9j9OASdhr+QbHQab/Nnn/vollP/hc5ev2rpXupgr/JNk3Y34FqFb8Dgo
wztp7SDEsfU/d7NU0BVxlm6Xh2uNYflquqxCnXpRKPsTF5wGUsbQWCXXTchUpbZ7
2KzkaEqjm0sMXWMNd0mMW50l99ZYf5DR2NtszijbxS4Mj2EgQQQZPQTDeix0i8m1
wHNCSfHyyPvKrxGPsFOGDp4KO/zC5E+PrrHHzqU8Ux7HysdhLewcXHxinJI74GEf
L25pl896VP174FAq2h+bahBlrH8IQ6uQpj8WCLId8ua0Rk2Acl/Xa19aI53EH/7B
sdmaBBwDghH9TgYRZ4+CYdB31Zzwt6YAkLEaAXiewg2ZUIG0PLlMw+NkaO8nbcKj
aGWrKWLbYe3i1+sGJq9veFuqxqG9NV+XCmNEvcQXFtW3QP9V9+HLmrYNAeu0r8Ry
J7gAoeNyvCW9kBhr3uaZeyxYXJbkI6RXhaY5nAs2mN1MpeIQ7hwKXbsETeme9QqC
ZPyecoUzu1x8ZPvktLNJsWQkNGPQgG8rGySDjQN7khe2ED8lJjpkTXjJ/VGUy7Pu
5/zQYmAtaTHswAJkDOguGHnXxCmFtY/G4erq0zhlUKoA/x5PI7Q=
=Aq70
-----END PGP SIGNATURE-----
--=-=-=--

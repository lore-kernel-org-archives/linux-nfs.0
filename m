Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40709 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753353AbdKWXxs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 23 Nov 2017 18:53:48 -0500
From: NeilBrown <neilb@suse.com>
To: "Michael Kerrisk \(man-pages\)" <mtk.manpages@gmail.com>
Date: Fri, 24 Nov 2017 10:53:36 +1100
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        Lennart Poettering <lennart@poettering.net>
Subject: [manpages PATCH] open_by_handle_at.2: clarify MAX_HANDLE_SZ
In-Reply-To: <52c5800b-150a-7ec9-133b-6c32e97249f4@gmail.com>
References: <87wp2j1ggu.fsf@notabene.neil.brown.name> <52c5800b-150a-7ec9-133b-6c32e97249f4@gmail.com>
Message-ID: <873754zh4v.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


As hinted in the kernel source, MAX_HANDLE_SZ is a hint
rather than a promise:

    /* limit the handle size to NFSv4 handle size now */
    #define MAX_HANDLE_SZ 128

Note the "now" (probably should be "for now").
So change the description to make this clear.

Reported-by: Lennart Poettering <lennart@poettering.net>
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 man2/open_by_handle_at.2 | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/man2/open_by_handle_at.2 b/man2/open_by_handle_at.2
index 79987308bf3e..f3473d24fa50 100644
=2D-- a/man2/open_by_handle_at.2
+++ b/man2/open_by_handle_at.2
@@ -91,7 +91,8 @@ field should be initialized to contain the allocated size=
 for
 .BR MAX_HANDLE_SZ ,
 defined in
 .IR <fcntl.h> ,
=2Dspecifies the maximum possible size for a file handle.)
+specifies the maximum expected size for a file handle. It is not a
+guaranteed upper limit as future filesystems may require more space.)
 Upon successful return, the
 .IR handle_bytes
 field is updated to contain the number of bytes actually written to
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAloXX4EACgkQOeye3VZi
gblV4g/8CACmiSHDeuI94g21paKs7WOMe+ww1TxBwPhQHrHnwkvQdPl7YXkGrN2n
FynRWU4mpk3pz5RoYvkzW/fbQmL/fCnejy8E8+J/8PjpR12s/mWW3LmbMZCWndc9
8xjG2AlcP/gzGwPBqx3aelFEVwS8TXjm7opTLixjUdu+YFITOsJ9frG8uIfCm/1w
e/58RX7mjY25CwAg2rj3bPLx+l4WbxUnxvkPjJYmhgyEfPi6UrKbmTjll9GeZGpV
MiAQnHAjGgUMTgbZLiL44P+KpSv4eXBCsBzzwN1oCzs3k0aEuYo/RJQhHcckg7oy
/ygugljwiEksz/Vj1Sbnfh/atUKXOt5xUvkFLy6aCXWSyocsHZKOpS9c4CfAvLVk
tDMbNbI0UGsRXXjhe0nUULdo9wlaPjdCbCiOWfeo1Sbc0rlJ3vN/1QsvE/fYqI40
BzlcQz/fohVSaGYypcZ4mHh5xy5XpDKveOjMQiDKsM3qIw3xIXFTYuQsJKkZPc2B
xXyJmxXFHD3cy2CZPqXegRna7P/pDdK4PFYLODB6jccVCe6EGv1l5Bnb8hksOt/x
xR8UwvSnpw2dV8bz5XFmXz9xzwTIqgGDOTNQrmIZn+HVOueIGng+0Pu4c62V1yiA
nqtedz5ps3V4nFY/5Ii64Uy08AKTsPYGXhECUnd8IMsVI51qGgo=
=CLuE
-----END PGP SIGNATURE-----
--=-=-=--

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33952 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726268AbeJDJCs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 Oct 2018 05:02:48 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Trond Myklebust <trond.myklebust@hammerspace.com>
Date: Thu, 04 Oct 2018 12:11:33 +1000
Cc: Jan Harkes <jaharkes@cs.cmu.edu>, linux-nfs@vger.kernel.org,
        Miklos Szeredi <miklos@szeredi.hu>,
        Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, David Howells <dhowells@redhat.com>,
        coda@cs.cmu.edu, linux-fsdevel@vger.kernel.org,
        Christoph Hellwig <hch@lst.de>
Subject: [PATCH 2/3 v2] VFS: allow MAY_ flags to be easily extended.
In-Reply-To: <153861496332.30373.4846710512713338280.stgit@noble>
References: <153861471803.30373.6184444014227748848.stgit@noble> <153861496332.30373.4846710512713338280.stgit@noble>
Message-ID: <87ftxmtq96.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


NFSD uses permission flags similar to the MAY_* flags,
with some overlap, and depends on the overlap matching.
This is currently a little fragile and hard to extend.

So add __MAY_UNUSED to identify the first unused flag,
and have NFSD use that flag and later flags for its
non-standard permissions.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

v1 of this patch had an obvious bug which, of course, I couldn't see
until after posting.
__MAY_UNUSED had the same value as MAY_ACT_AS_OWNER - so it wasn't
unused!

NeilBrown


 fs/nfsd/vfs.h      | 33 ++++++++++++++++++---------------
 include/linux/fs.h |  2 ++
 2 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index a7e107309f76..2b1c70d3757a 100644
=2D-- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -13,23 +13,26 @@
  * Flags for nfsd_permission
  */
 #define NFSD_MAY_NOP			0
=2D#define NFSD_MAY_EXEC			0x001 /* =3D=3D MAY_EXEC */
=2D#define NFSD_MAY_WRITE			0x002 /* =3D=3D MAY_WRITE */
=2D#define NFSD_MAY_READ			0x004 /* =3D=3D MAY_READ */
=2D#define NFSD_MAY_SATTR			0x008
=2D#define NFSD_MAY_TRUNC			0x010
=2D#define NFSD_MAY_LOCK			0x020
=2D#define NFSD_MAY_MASK			0x03f
+#define NFSD_MAY_EXEC			MAY_EXEC
+#define NFSD_MAY_WRITE			MAY_WRITE
+#define NFSD_MAY_READ			MAY_READ
+#define NFSD_MAY_SATTR			(__MAY_UNUSED << 0)
+#define NFSD_MAY_TRUNC			(__MAY_UNUSED << 1)
+#define NFSD_MAY_LOCK			(__MAY_UNUSED << 2)
+#define __NFSD_MAY_FIRST_HINT		(__MAY_UNUSED << 3)
+#define NFSD_MAY_MASK			(__NFSD_MAY_FIRST_HINT - 1)
=20
 /* extra hints to permission and open routines: */
=2D#define NFSD_MAY_OWNER_OVERRIDE		0x040
=2D#define NFSD_MAY_LOCAL_ACCESS		0x080 /* for device special files */
=2D#define NFSD_MAY_BYPASS_GSS_ON_ROOT	0x100
=2D#define NFSD_MAY_NOT_BREAK_LEASE	0x200
=2D#define NFSD_MAY_BYPASS_GSS		0x400
=2D#define NFSD_MAY_READ_IF_EXEC		0x800
=2D
=2D#define NFSD_MAY_64BIT_COOKIE		0x1000 /* 64 bit readdir cookies for >=3D=
 NFSv3 */
+#define NFSD_MAY_OWNER_OVERRIDE		(__NFSD_MAY_FIRST_HINT << 0)
+/* for device special files */
+#define NFSD_MAY_LOCAL_ACCESS		(__NFSD_MAY_FIRST_HINT << 1)
+#define NFSD_MAY_BYPASS_GSS_ON_ROOT	(__NFSD_MAY_FIRST_HINT << 2)
+#define NFSD_MAY_NOT_BREAK_LEASE	(__NFSD_MAY_FIRST_HINT << 3)
+#define NFSD_MAY_BYPASS_GSS		(__NFSD_MAY_FIRST_HINT << 4)
+#define NFSD_MAY_READ_IF_EXEC		(__NFSD_MAY_FIRST_HINT << 5)
+
+/* 64 bit readdir cookies for >=3D NFSv3 */
+#define NFSD_MAY_64BIT_COOKIE		(__NFSD_MAY_FIRST_HINT << 6)
=20
 #define NFSD_MAY_CREATE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE)
 #define NFSD_MAY_REMOVE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 5a8878a88cbb..9fc914c259f9 100644
=2D-- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -103,6 +103,8 @@ typedef int (dio_iodone_t)(struct kiocb *iocb, loff_t o=
ffset,
  */
 #define MAY_ACT_AS_OWNER	0x00000100
=20
+#define	__MAY_UNUSED		0x00000200
+
 /*
  * flags in file.f_mode.  Note that FMODE_READ and FMODE_WRITE must corres=
pond
  * to O_WRONLY and O_RDWR via the strange trick in do_dentry_open()
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlu1dtcACgkQOeye3VZi
gblA0A//dw3gv7+xLxxCMgpSamVXn09sVWuetXcj1ntIObC55cvy1YAyq9I0P/Wv
/nHg69pOmVN06PwPikY9is1GD/S2+ixbLd5zcYggS7SWF9Pst+mjjiHAxzYBBL03
ePh34iCc3Gz5TtYhoyoFoEZ/JL8TSSJDpsNyDxEupp12AFYg9u0FqC8wVGu/6lYb
IYFDj+/Jdgpv9DBAQLR4UR04ttesZLyySwgmGKhg1H36n1rkO3HjaglB6I1O9Yit
wMqiRePnpggfHWrs/UmmA9bgFynNwWK5CyuhsiQX3FUVVA7CIok5GxZdk3IFoYiJ
3fmtc7POFoxtylj5Nqf5Hh88ys0J7PeroR1p8xwtNzPQSPQoDmqvM8xVRdBTif4b
ircqJXwaeO5tLevzcbcbH7csHMmASf5PSPNOvIVL9Jtnaz67CvQj57gdEYBdvAJU
+Cu8BSNfg6up9xGYvPV73mWa6hqsR5iXKmQaaBAVzEqYLizL6wqoshAwCicK/mJL
FG26Sx9ZvlEHuoH9X5e0oMJM0synR+1ICVzKEDVpxOm2jHp6+Nm+CQUqyylf0DBY
hG652C+B2CWndrT62rnRbshevt8sXizNYSsF1g3ldrxKHM6wdMxq9UrIyw4N9DdE
zwdlW4eE0Nz4bEgYmyK/Q0sgNq/Z1/ROh5ZEsZAN+klCczFsk20=
=C+wE
-----END PGP SIGNATURE-----
--=-=-=--

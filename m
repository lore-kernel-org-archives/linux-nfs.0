Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:34640 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754793Ab2LMAZl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Dec 2012 19:25:41 -0500
Date: Thu, 13 Dec 2012 11:25:29 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: NFS <linux-nfs@vger.kernel.org>,
        Sean Finney <sean.finney@sonyericsson.com>
Subject: [nfs-utils PATCH] mountd: fix checking for errors when exporting
 filesystems.
Message-ID: <20121213112529.06ebda22@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/mHCB/Ias8HjV+WcgG+5tdzl"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/mHCB/Ias8HjV+WcgG+5tdzl
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



commit 5604b35a61e22930873ffc4e9971002f578e7978
  nfs-utils: Increase the stdio file buffer size for procfs files

changed writes to some sysfs files to be line buffered (_IOLBF) where
they weren't before.  While this probably makes sense, it introduced a bug.

With fully buffered streams, you don't expect to get an error until you
call fflush().
With line buffered streams you can get the error from fprintf() et al.

qword_eol() only tests the return from fflush(), not from fprintf().  Conse=
quently
errors were not noticed.

One result of this is that if you export, with crossmnt, a filesystem under=
neath
which are mounted non-exportable filesystems (e.g. /proc) then an 'ls -l' o=
n the
client will block indefinitely waiting for a meaningful 'yes' or 'no' from =
the
server, but will never get one.

This patch changes qword_eol to test both fprintf and fflush.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/support/nfs/cacheio.c b/support/nfs/cacheio.c
index e641c45..61e07a8 100644
--- a/support/nfs/cacheio.c
+++ b/support/nfs/cacheio.c
@@ -162,11 +162,16 @@ int qword_eol(FILE *f)
 {
 	int err;
=20
-	fprintf(f,"\n");
-	err =3D fflush(f);
-	if (err) {
-		xlog_warn("qword_eol: fflush failed: errno %d (%s)",
+	err =3D fprintf(f,"\n");
+	if (err < 0) {
+		xlog_warn("qword_eol: fprintf failed: errno %d (%s)",
 			    errno, strerror(errno));
+	} else {
+		err =3D fflush(f);
+		if (err) {
+			xlog_warn("qword_eol: fflush failed: errno %d (%s)",
+				  errno, strerror(errno));
+		}
 	}
 	/*
 	 * We must send one line (and one line only) in a single write

--Sig_/mHCB/Ias8HjV+WcgG+5tdzl
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUMkgeTnsnt1WYoG5AQLBjQ/+LVWwpvdMg5Itt5qZvx6WXHLo3gkIzMAn
SOVD8PteC6H2hWp7s2U2n6yVwgvALy6AO7NJfI9XEOkeVKwiJclVAhtpkpnyJdyu
dTcpfjVV+jx9OqV8y4q37yzqxxta6uPn03N1b8fgoAiPe+SkSebwXaHLfrTtE80V
oxgEvrXkXA3Z5KD8Maj4g7mYUcVhqmGDXIBIu4gmDU1T2J6dFOL8i3oAWlL6noC0
RzOq6036kmfpfbXavzIuniP9gOzsHrlTQ9nfB5rHW1Z1voTy9uHBGALaxzslh3Ei
EVyrw8GGCYvgfXnXir6Gxc/c3OyNAvSah7cwLkkIrK1XPfpMVWN8JTyeJI7KCKqI
Ky/IPIO5xr3sHXlW9piYhXoHsFe5u6ygpVRitYnq4GaHNJZjuHJlRVCO/39/5qyz
0IGnJd2sxb8EwYaNDjEONUjUxxM8luvIkya2xRbPMyZb9B7bjBQsEnVfa2e5Tm4b
koFuUK65l/e87HRmP1LFgNnnhUVIUZRDvUptr2BLNs/zr9kwiug0ZXdHzZShlsCU
MNbNoD0oMP+mcq118KeEETEo7ZTa23zBc9XwZNCVf0FnNKnYAqZhMlr3sylIstLX
/WLJ/li38cQLnW0p3JgIaxEp9lQJsYtgb778L96nk2IekbBZLE+CcH1TLaCAcChA
68FALkwyVmw=
=oxzC
-----END PGP SIGNATURE-----

--Sig_/mHCB/Ias8HjV+WcgG+5tdzl--

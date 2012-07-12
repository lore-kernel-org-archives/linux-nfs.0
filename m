Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:60931 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753738Ab2GLD2E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Jul 2012 23:28:04 -0400
Date: Thu, 12 Jul 2012 13:27:57 +1000
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] umount.nfs: restore correct error status when umount fails.
Message-ID: <20120712132757.7f86b86b@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_//Tu+.8T4nJJqRvPoEHRUXpQ"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_//Tu+.8T4nJJqRvPoEHRUXpQ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



If nfs-utils is built without --enable-libmount-mount, then
an unmount that failed due to the filesystem being busy will
exit with '16' - EX_FILEIO.
Autofs apparently relies on this.

When built with --enable-libmount-mount, the same case will
exit with '32' - EX_FAIL.  Normally this is reserved for
internal errors.

This patch restores the use of EX_FILEIO for errors from umount.

Signed-off-by: NeilBrown <neilb@suse.de>
--

I confess that I haven't done a complete case analysis to see that we are
always using the correct error code, but this looks OK and handles the case
I care about.

There is a case that I know it doesn't handle.  If you ask umount.nfs to
unmount a filesystem that is not nfs or nfs4, then the old code will
refuse
  umount.nfs: /dev/sda7 on /mnt2 is not an NFS filesystem

and exit with status '1'.
The new libmount code will just think that it couldn't find anything in
fstab and will try to do an nfs23 unmount.  This is clearly different behav=
iour,
I'm not sure that anyone would care though.

NeilBrown


diff --git a/utils/mount/mount_libmount.c b/utils/mount/mount_libmount.c
index e8f17a9..5c1116a 100644
--- a/utils/mount/mount_libmount.c
+++ b/utils/mount/mount_libmount.c
@@ -173,6 +173,7 @@ static int umount_main(struct libmnt_context *cxt, int =
argc, char **argv)
 {
 	int rc, c;
 	char *spec =3D NULL, *opts =3D NULL;
+	int ret =3D EX_FAIL;
=20
 	static const struct option longopts[] =3D {
 		{ "force", 0, 0, 'f' },
@@ -243,7 +244,7 @@ static int umount_main(struct libmnt_context *cxt, int =
argc, char **argv)
 			/* strange, no entry in mtab or /proc not mounted */
 			nfs_umount23(spec, "tcp,v3");
 	}
-
+	ret =3D EX_FILEIO;
 	rc =3D mnt_context_do_umount(cxt);	/* call umount(2) syscall */
 	mnt_context_finalize_mount(cxt);	/* mtab update */
=20
@@ -252,12 +253,10 @@ static int umount_main(struct libmnt_context *cxt, in=
t argc, char **argv)
 		umount_error(rc, spec);
 		goto err;
 	}
-
-	free(opts);
-	return EX_SUCCESS;
+	ret =3D EX_SUCCESS;
 err:
 	free(opts);
-	return EX_FAIL;
+	return ret;
 }
=20
 static int mount_main(struct libmnt_context *cxt, int argc, char **argv)

--Sig_//Tu+.8T4nJJqRvPoEHRUXpQ
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBT/5EPTnsnt1WYoG5AQJe1g//e4p92RLCCW03miKRRAIc+HAG6uKaP+ua
Hww5f+ayn7cqO9bA4ybA0P2/EnE5SOUZMr2GIzkWdMQ0Z05zbRqRbsSEAVmBzW3G
AMAz1QDfPfC+J03JzEL2UGNz2czgqPDowq1MrTvv4o+PDOJ/v7lGF1ZoZ4Mqv/tN
Ygebi6eKG0Qn7LgFp8VNCtAPWdm3xE0sVSfxt5XB9wjbajj0l7pCBuQtOfm4dlWc
kFcgBC8NE88hAD6T4KRpxjL5RKiqTEXEDPTS3yL9XmBR3UN19BGpJEncRC10W2+z
h2EAfu9/wDhmA24Ezu04zXvBOVx7JE5cQalpIcZj0NW0ej2my+euxJ3mpWQgiB7r
CgJbskqhzQn6mOcW3hKBsh71kU/TjG1YP1ZkyHHdhsoT2Bkb7n5a1KBvtqCaZiYr
AJ5r1qpVwvaIxsWgLyCTk20oByWWu9I7Ao4d0mnGADXOqBRdtyrvMJCPKgmPkBD5
KS1XQ+hPTxPY9B7KVXbtYS+GGB8busgMY5qDgA6w1Ecd98XSbOgF2CSQY3kNyASL
K9FT86HGLg2kb5N139U1yTdUvv17nuoKJ8dM+EwDOxMozflVJRhycj5NiR0jLcUM
p3oOZTICPvYh+bgxwv0MBNYO2torrjfZ4H+xDgRFozi0c8y2LWASMa0l1lQgOZ8q
vzKzeGnDoKQ=
=HFuf
-----END PGP SIGNATURE-----

--Sig_//Tu+.8T4nJJqRvPoEHRUXpQ--

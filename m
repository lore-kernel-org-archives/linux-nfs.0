Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:60041 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753116Ab2HBAV4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Aug 2012 20:21:56 -0400
Date: Thu, 2 Aug 2012 10:21:42 +1000
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: Karel Zak <kzak@redhat.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: nfs-utils: Something is wrong in is_vers4()
Message-ID: <20120802102142.10be27f4@notabene.brown>
In-Reply-To: <5019499C.2040805@RedHat.com>
References: <20120731165842.08017d60@notabene.brown>
	<5018103A.9070607@RedHat.com>
	<20120731183739.GA16347@x2.net.home>
	<5019499C.2040805@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/BmQBG/s.1Gi_EKIITd2XLkb"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/BmQBG/s.1Gi_EKIITd2XLkb
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 01 Aug 2012 11:22:04 -0400 Steve Dickson <SteveD@redhat.com> wrote:

>=20
>=20
> On 07/31/2012 02:37 PM, Karel Zak wrote:
> > On Tue, Jul 31, 2012 at 01:04:58PM -0400, Steve Dickson wrote:
> >>> BTW Steve, Karel's "[PATCH] umount.nfs: ignore non-nfs filesystems"
> >>> which appears in email:
> >>>
> >>> From: Karel Zak <kzak@redhat.com>
> >>> To: NeilBrown <neilb@suse.de>
> >>> Cc: Steve Dickson <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>
> >>> Subject: Re: [PATCH] umount.nfs: restore correct error status when um=
ount fails.
> >>> Date: Thu, 12 Jul 2012 18:44:20 +0200
> >>>
> >>> hasn't been applied, but probably should be.
> >> I beg to differ....
> >>
> >> commit 76908c3f14a12e865054ea5d6e4cad201c28839a
> >> Author: NeilBrown <neilb@suse.de>
> >> Date:   Mon Jul 16 08:43:28 2012 -0400
> >>
> >>     mount.nfs: restore correct error status when umount fails
> >>
> >> Or am I missing something?
> >=20
> >  Yes, Neil found two problems:
> >=20
> >     http://www.spinics.net/lists/linux-nfs/msg31466.html
> Ah... Found it and committed it...=20
>=20
> steved.

Thanks.
So here is one more :-)  This  fixes the the bug in $SUBJECT

NeilBrown

From: Neil Brown <neilb@suse.de>
Date: Thu, 2 Aug 2012 10:20:13 +1000
Subject: [PATCH] umount: use correct return value for is_vers4.

is_vers4 in mount_libmount.c is based on nfs_umount_is_vers4
in nfsumount.c, except the return values are reversed.
The result of this is:
 - a MOUNT_UMNT call is not sent when an NFSv3 or NFSv2
   filesystem is unmounted
 - a MOUNT_UMNT call *is* sent when and 'nfs4' filesystem
   is unmounted (but not when an 'nfs -o vers=3D4 filesystem
   is unmounted, as that is checked elsewhere).

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/utils/mount/mount_libmount.c b/utils/mount/mount_libmount.c
index ddf61b2..701d41e 100644
--- a/utils/mount/mount_libmount.c
+++ b/utils/mount/mount_libmount.c
@@ -140,14 +140,14 @@ static int try_mount(struct libmnt_context *cxt, int =
bg)
 	return ret;
 }
=20
-/* returns: error =3D -1, success =3D 0 , unknown =3D 1 */
+/* returns: error =3D -1, success =3D 1 , not vers4 =3D=3D 0 */
 static int is_vers4(struct libmnt_context *cxt)
 {
 	struct libmnt_fs *fs =3D mnt_context_get_fs(cxt);
 	struct libmnt_table *tb =3D NULL;
 	const char *src =3D mnt_context_get_source(cxt),
 		   *tgt =3D mnt_context_get_target(cxt);
-	int rc =3D 1;
+	int rc =3D 0;
=20
 	if (!src || !tgt)
 		return -1;
@@ -163,7 +163,7 @@ static int is_vers4(struct libmnt_context *cxt)
 	if (fs) {
 		const char *type =3D mnt_fs_get_fstype(fs);
 		if (type && strcmp(type, "nfs4") =3D=3D 0)
-			rc =3D 0;
+			rc =3D 1;
 	}
 	mnt_free_table(tb);
 	return rc;

--Sig_/BmQBG/s.1Gi_EKIITd2XLkb
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUBnIFjnsnt1WYoG5AQIE6w//Tpgq9Q3D2aGvf23uWc3B2eOZBXyBwyI+
39XGP/5CP6KxwBwMK7hZeZ7OgLMbhB+SJVPP1k1X12QAO2iALTmt59A9gKvFd30k
Y5t0rclrvhfeHfewOeJ9gbJQHWRCMAVsMDeSQtsgxdJtSUj3ohpwPdQxEHTegslE
3iCLxRRJw1nr3+0lSVD/g1iC943zdZSSPli9fA+a/7l/Cf9zII5Glah4OcPehzEB
IgH25XUpIQ2ctt9E/9tD8dd+/8dFeJ3h+f0NACP54FOQ/r/aOCRv4/gLIh6sFCvT
3NwLMKOM03LKGE4KwE0/YNmSIHQMtrr5kRYV2vBcNzZnEySqh4aHSAPyigUVNcxi
ggrAGU0eitYBMcXDnT0Va68/3WwxLx7YEjfB3cqEit9+RURyYMufj6B4j0Kd2+5u
mtvUoclVmPDvU/DehWqrW0t3WG5CXhQj3nWqObCJ9VlzWz6UzCYp7VpzOCkgvjQS
z8xFslrqVBEPSWeIXGh0m5xN/Oz9S8CnH1kikFWoOjgFWUS6poyy8/lIxMBon2/1
QIwXPHV3TB5WaJcHxdiflKDEqNFNmZYOzr51D75zYD8LsygJEJaVoffRSuVxDg2I
KI8W7TRoFD+uq5MToDaj3f7fztRZI6pXflfKCqiQaKVcJFCozeXn6mmu6667ryZ/
tujeSUeWQ58=
=G87H
-----END PGP SIGNATURE-----

--Sig_/BmQBG/s.1Gi_EKIITd2XLkb--

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36078 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750851AbdCOBky (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Mar 2017 21:40:54 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Wed, 15 Mar 2017 12:40:44 +1100
Cc: Linux NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS: don't try to cross a mountpount when there isn't one there.
Message-ID: <87fuife2qr.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


consider the sequence of commands:
 mkdir -p /import/nfs /import/bind /import/etc
 mount --bind / /import/bind
 mount --make-private /import/bind
 mount --bind /import/etc /import/bind/etc

 exportfs -o rw,no_root_squash,crossmnt,async,no_subtree_check localhost:/
 mount -o vers=3D4 localhost:/ /import/nfs
 ls -l /import/nfs/etc

You would not expect this to report a stale file handle.
Yet it does.

The manipulations under /import/bind cause the dentry for
/etc to get the DCACHE_MOUNTED flag set, even though nothing
is mounted on /etc.  This causes nfsd to call
nfsd_cross_mnt() even though there is no mountpoint.  So an
upcall to mountd for "/etc" is performed.

The 'crossmnt' flag on the export of / causes mountd to
report that /etc is exported as it is a descendant of /.  It
assumes the kernel wouldn't ask about something that wasn't
a mountpoint.  The filehandle returned identifies the
filesystem and the inode number of /etc.

When this filehandle is presented to rpc.mountd, via
"nfsd.fh", the inode cannot be found associated with any
name in /etc/exports, or with any mountpoint listed by
getmntent().  So rpc.mountd says the filehandle doesn't
exist. Hence ESTALE.

This is fixed by teaching nfsd not to trust DCACHE_MOUNTD
too much.  It is just a hint, not a guarantee.
Change nfsd_mountpoint() to return '1' for a certain mountpoint,
'2' for a possible mountpoint, and 0 otherwise.

Then change nfsd_crossmnt() to check if follow_down()
actually found a mountpount and, if not, to avoid performing
a lookup if the location is not known to certainly require
an export-point.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 fs/nfsd/vfs.c | 24 ++++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 19d50f600e8d..04cafaa94bf7 100644
=2D-- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -94,6 +94,12 @@ nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **d=
pp,
 	err =3D follow_down(&path);
 	if (err < 0)
 		goto out;
+	if (path.mnt =3D=3D exp->ex_path.mnt && path.dentry =3D=3D dentry &&
+	    nfsd_mountpoint(dentry, exp) =3D=3D 2) {
+		/* This is only a mountpoint in some other namespace */
+		path_put(&path);
+		goto out;
+	}
=20
 	exp2 =3D rqst_exp_get_by_name(rqstp, &path);
 	if (IS_ERR(exp2)) {
@@ -167,16 +173,26 @@ static int nfsd_lookup_parent(struct svc_rqst *rqstp,=
 struct dentry *dparent, st
 /*
  * For nfsd purposes, we treat V4ROOT exports as though there was an
  * export at *every* directory.
+ * We return:
+ * '1' if this dentry *must* be an export point,
+ * '2' if it might be, if there is really a mount here, and
+ * '0' if there is no chance of an export point here.
  */
 int nfsd_mountpoint(struct dentry *dentry, struct svc_export *exp)
 {
=2D	if (d_mountpoint(dentry))
+	if (!d_inode(dentry))
+		return 0;
+	if (exp->ex_flags & NFSEXP_V4ROOT)
 		return 1;
 	if (nfsd4_is_junction(dentry))
 		return 1;
=2D	if (!(exp->ex_flags & NFSEXP_V4ROOT))
=2D		return 0;
=2D	return d_inode(dentry) !=3D NULL;
+	if (d_mountpoint(dentry))
+		/*
+		 * Might only be a mountpoint in a different namespace,
+		 * but we need to check.
+		 */
+		return 2;
+	return 0;
 }
=20
 __be32
=2D-=20
2.12.0


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljIm50ACgkQOeye3VZi
gbk0eA//RdVXsLnbDN3jsPkKbb+bzHWNkWdlljU0K8mjrKP8vXyy7rnmwyNJoz2m
XW+J7B20xXNve1R7upPUWwirmA25VIxJBibA2KBDs7JYv1fBPAKx7HAJ9yX+vlVp
kQjg6dr4plL5akJQ827jMv7PcXIk2uE2HZmK0z+OqWIMDvZj6mvEeENzgSoKACcB
9I/JEqqD/EmAw9tSMdlaNHs1vPHB/jAQXdhkqjcdmLdOuh34RftN4umbWCgP8ipx
JfdX8MFtt8+YaCxfuIIJBLvnu0oXVTNsouALEMdiCmaFoQjW7FwT26R9AjoD53b6
8pAXTnR+ipENz4P4GFjJeYEY4H6vNgfz5Ln7Cw0ktOWzkBY1gocOHJmQrNHyhKuU
0fZY3vQ+a9bytvVoULC3ndfuM0GpRaYBL1GkKeqBWnfozPP/TFIaWZ/OPTq8DWdp
fkQ/0yOABn+5l0Z+PbURed6N2+td7LJGzciBd4iFW1eTtfQf/l10io+/xFaiaEcD
fzUMHye08dtmUY/XGHbN4BHhMR52nka/yLBOMlK7MZXc/J7fXljfEED1yzDtoJrc
smjVOJuOGWiDpm0pQ1Q31xwBUOfVOUBXSI34/+/DuJ4MJ1qJRloKDlpokw2lzi7M
rU3sWU6KYtxVNrjXwgcqJX+t+2TMzb9PUBWbzwD3LRmhINHTBGY=
=r4lL
-----END PGP SIGNATURE-----
--=-=-=--

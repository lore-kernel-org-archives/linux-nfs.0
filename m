Return-Path: linux-nfs-owner@vger.kernel.org
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58291 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932353Ab2JUSYO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Oct 2012 14:24:14 -0400
Message-ID: <1350843832.22276.34.camel@deadeye.wl.decadent.org.uk>
Subject: [PATCH] nfs: Show original device name verbatim in
 /proc/*/mount{s,info}
From: Ben Hutchings <ben@decadent.org.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: 669314@bugs.debian.org, viro@zeniv.linux.org.uk, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Micheal Waltz <mwaltz@qualcomm.com>,
        Gabriel Evanoff <gevanoff@salk.edu>,
        Jonathan Nieder <jrnieder@gmail.com>
Date: Sun, 21 Oct 2012 19:23:52 +0100
In-Reply-To: <7941E5E1-488D-4D0B-A21A-4E389EF6EBBA@salk.edu>
References: <7941E5E1-488D-4D0B-A21A-4E389EF6EBBA@salk.edu>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-dlFn8Q2JHHsS51d4UNo0"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-dlFn8Q2JHHsS51d4UNo0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Since commit c7f404b ('vfs: new superblock methods to override
/proc/*/mount{s,info}'), nfs_path() is used to generate the mounted
device name reported back to userland.

nfs_path() always generates a trailing slash when the given dentry is
the root of an NFS mount, but userland may expect the original device
name to be returned verbatim (as it used to be).  Make this
canonicalisation optional and change the callers accordingly.

Reported-and-tested-by: Chris Hiestand <chiestand@salk.edu>
Reference: http://bugs.debian.org/669314
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Cc: <stable@vger.kernel.org> # v2.6.39+
---
 fs/nfs/internal.h      |    4 ++--
 fs/nfs/namespace.c     |   15 ++++++++++-----
 fs/nfs/nfs4namespace.c |    2 +-
 fs/nfs/super.c         |    2 +-
 4 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 31fdb03..5eaf902 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -354,7 +354,7 @@ extern void nfs_sb_deactive(struct super_block *sb);
=20
 /* namespace.c */
 extern char *nfs_path(char **p, struct dentry *dentry,
-		      char *buffer, ssize_t buflen);
+		      char *buffer, ssize_t buflen, bool canonical);
 extern struct vfsmount *nfs_d_automount(struct path *path);
 struct vfsmount *nfs_submount(struct nfs_server *, struct dentry *,
 			      struct nfs_fh *, struct nfs_fattr *);
@@ -491,7 +491,7 @@ static inline char *nfs_devname(struct dentry *dentry,
 				char *buffer, ssize_t buflen)
 {
 	char *dummy;
-	return nfs_path(&dummy, dentry, buffer, buflen);
+	return nfs_path(&dummy, dentry, buffer, buflen, true);
 }
=20
 /*
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 6559253..059975e 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -33,6 +33,8 @@ int nfs_mountpoint_expiry_timeout =3D 500 * HZ;
  * @dentry - pointer to dentry
  * @buffer - result buffer
  * @buflen - length of buffer
+ * @canonical - ensure there is exactly one slash after the original
+ *		device (export) name; if false, return it verbatim
  *
  * Helper function for constructing the server pathname
  * by arbitrary hashed dentry.
@@ -41,7 +43,8 @@ int nfs_mountpoint_expiry_timeout =3D 500 * HZ;
  * server side when automounting on top of an existing partition
  * and in generating /proc/mounts and friends.
  */
-char *nfs_path(char **p, struct dentry *dentry, char *buffer, ssize_t bufl=
en)
+char *nfs_path(char **p, struct dentry *dentry, char *buffer, ssize_t bufl=
en,
+	       bool canonical)
 {
 	char *end;
 	int namelen;
@@ -74,7 +77,7 @@ rename_retry:
 		rcu_read_unlock();
 		goto rename_retry;
 	}
-	if (*end !=3D '/') {
+	if (canonical && *end !=3D '/') {
 		if (--buflen < 0) {
 			spin_unlock(&dentry->d_lock);
 			rcu_read_unlock();
@@ -91,9 +94,11 @@ rename_retry:
 		return end;
 	}
 	namelen =3D strlen(base);
-	/* Strip off excess slashes in base string */
-	while (namelen > 0 && base[namelen - 1] =3D=3D '/')
-		namelen--;
+	if (canonical) {
+		/* Strip off excess slashes in base string */
+		while (namelen > 0 && base[namelen - 1] =3D=3D '/')
+			namelen--;
+	}
 	buflen -=3D namelen;
 	if (buflen < 0) {
 		spin_unlock(&dentry->d_lock);
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 017b4b0..94e8652 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -81,7 +81,7 @@ static char *nfs_path_component(const char *nfspath, cons=
t char *end)
 static char *nfs4_path(struct dentry *dentry, char *buffer, ssize_t buflen=
)
 {
 	char *limit;
-	char *path =3D nfs_path(&limit, dentry, buffer, buflen);
+	char *path =3D nfs_path(&limit, dentry, buffer, buflen, true);
 	if (!IS_ERR(path)) {
 		char *path_component =3D nfs_path_component(path, limit);
 		if (path_component)
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ac6a3c5..6087ed0 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -730,7 +730,7 @@ int nfs_show_devname(struct seq_file *m, struct dentry =
*root)
 	int err =3D 0;
 	if (!page)
 		return -ENOMEM;
-	devname =3D nfs_path(&dummy, root, page, PAGE_SIZE);
+	devname =3D nfs_path(&dummy, root, page, PAGE_SIZE, false);
 	if (IS_ERR(devname))
 		err =3D PTR_ERR(devname);
 	else


--=-dlFn8Q2JHHsS51d4UNo0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUIQ9uOe/yOyVhhEJAQouFBAA1P4IGcHk4P64hyeBHuTp0/nCMLiDC5Kp
k/X2GSn1xtfEtRET2g22+jacBOYHJSWtNh0dns0HMZ+S3bXHr3IL5vBtQNpdxpBL
ciooxI0koEfDdWwWShZGn8IY3Z8DpWGIdU9OEtiioN7cGYU5s6bx+hKPmwSh3haJ
DiFGv7soDTWst1FEk7gjUzfhKA2LHxy7XUPki+UaKbwEekgg1DbsYuhOT67wvKng
KmiCWRb69Ra/rD7+ZHmZKu9PGEYf8TOW6tz/TPbpzZZceHdqlGRjbe3ATJTxb2/L
gtUoOFbhFXn8HjAxRk6T7luOz7peT/2/v05eZEqpZYMHO5oFL3u+G4T4Oa/C1HVi
ub8S2ozq2sJFY1bRmy5eMUpWJ76gQFOWbr6uo7fD9zNmnx+RwKXXvO51Y815Y2dh
018/hpPTcu5twEntIfN6iqQAze8MBAZiGUBovSYAlfFaifosJLJ1KOmZtNDLOeJa
z80NUds6Iq0icEPsJot5D72AFDWwwZ+gW1dP6QwsTUfkyzivvkRvrOscymqVpjLA
rIuzb109ZKF3BeNuQ3ue31b+6qToddppS6B9l2qM2eGruveDmsfLn23zEz3c+aDR
66jPaDIJaQZRjXKgUea8K3J6uNCtuwkO3W4+Z1fGh5uuaxA5DiCHA8uuU8jcTInW
GH19JsOaMSc=
=Dg59
-----END PGP SIGNATURE-----

--=-dlFn8Q2JHHsS51d4UNo0--

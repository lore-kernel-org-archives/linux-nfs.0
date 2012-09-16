Return-Path: linux-nfs-owner@vger.kernel.org
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52670 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751011Ab2IPCVb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 15 Sep 2012 22:21:31 -0400
Message-ID: <1347762073.13258.188.camel@deadeye.wl.decadent.org.uk>
Subject: Re: NFS: kernel forces trailing slash for export in
 /proc/self/mounts
From: Ben Hutchings <ben@decadent.org.uk>
To: viro@zeniv.linux.org.uk, Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        669314@bugs.debian.org, Chris Hiestand <chiestand@salk.edu>
Date: Sun, 16 Sep 2012 03:21:13 +0100
In-Reply-To: <8F8193BD-84C6-4905-8789-DE7EB2579A4E@salk.edu>
References: <8F8193BD-84C6-4905-8789-DE7EB2579A4E@salk.edu>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-s19U7PtftxI++zun600/"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-s19U7PtftxI++zun600/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-06-19 at 12:43 -0700, Chris Hiestand wrote:
> Hi Alexander Viro et al,
>=20
> This is an escalation of Debian Bug #669314 http://bugs.debian.org/669314=
, which I will
> re-elaborate in this email for your convenience.
>=20
> You committed a change to the way the linux kernel reports NFS mounts - n=
ow with a
> trailing slash for the remote export (among other changes). The change ha=
ppened here:
> > commit c7f404b40a3665d9f4e9a927cc5c1ee0479ed8f9
> > Author: Al Viro <viro@zeniv.linux.org.uk>
> > Date:   Wed Mar 16 06:59:40 2011 -0400
> >=20
> >     vfs: new superblock methods to override /proc/*/mount{s,info}
> >    =20
> >     a) ->show_devname(m, mnt) - what to put into devname columns in mou=
nts,
> >     mountinfo and mountstats
> >     b) ->show_path(m, mnt) - what to put into relative path column in m=
ountinfo
> >    =20
> >     Leaving those NULL gives old behaviour.  NFS switched to using thos=
e.
> >    =20
> >     Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> >=20
>=20
> The "problematic" behavior is that NFS exports now have a trailing slash =
in
> /proc/self/mounts.
[...]
> If there is a new convention to display the trailing slash, we need to up=
date
> our tools to handle this change. If there is not a new convention, I'd ar=
gue
> this is a bug.
>=20
> So is this a new convention or not? What is the appropriate way for
> Debian to move forward?

Al, Trond, what's going on here?  This sure looks like it broke
userland, in which case we need to revert the change in behaviour.

How about the following (untested) change?

Ben.
---
Subject: nfs: Show original device name verbatim in /proc/*/mount{s,info}

Since commit c7f404b ('vfs: new superblock methods to override
/proc/*/mount{s,info}'), nfs_path() is used to generate the mounted
device name reported back to userland.

nfs_path() always generates a trailing slash when the given dentry is
the root of an NFS mount, but userland may expect the original device
name to be returned verbatim (as it used to be).  Make this
canonicalisation optional and change the callers accordingly.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Cc: <stable@vger.kernel.org> # v2.6.39+
---
 fs/nfs/internal.h      |    4 ++--
 fs/nfs/namespace.c     |   15 ++++++++++-----
 fs/nfs/nfs4namespace.c |    2 +-
 fs/nfs/super.c         |    2 +-
 4 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index d554438..c38224a 100644
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
index d2c7f5d..630a1e2 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -765,7 +765,7 @@ int nfs_show_devname(struct seq_file *m, struct dentry =
*root)
 	int err =3D 0;
 	if (!page)
 		return -ENOMEM;
-	devname =3D nfs_path(&dummy, root, page, PAGE_SIZE);
+	devname =3D nfs_path(&dummy, root, page, PAGE_SIZE, false);
 	if (IS_ERR(devname))
 		err =3D PTR_ERR(devname);
 	else

--=20
Ben Hutchings
Experience is what causes a person to make new mistakes instead of old ones=
.

--=-s19U7PtftxI++zun600/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUFU3mee/yOyVhhEJAQoSGQ/+P4eLH69nQpCKP42SdOfeF96G9vZI+ZyO
Y+aLM786ctSo5Xwd0yvj23wAn5SRg00EP1/QXGqxAUpfPiFhSndHVl+SMkJyQxIP
aiyNwpmA9+RYG2c0bY3k5GvCx4ZHQDnlenJI5/tZjdhtAd5igyUqhA7OA6jeuSyT
XkPinzCjpx9Ly9YXHugpMR6vASYzhnB/1LRviE3TmU6xL2fIQxn5uXAir8kpl52w
hLQrewWYJ4+tyF3p8wId9rhCnejTA0T+YBSYp/3RcJnPsx+ie6vV9c+cP6PU+DNz
psYGoFyttfroTo/G3npI/y0guI+OR/oo6s8gRunstDaXPZHeHoQQQX9R1sAOEJB9
RqlE1ppJlF5PR/1aEX3PiF3GxXR6Z95ZS2mHlkttKF938/b5p1ZfsJV+uUrCLmto
YDB8P3Ut8Kf+jvedZSlptUhK9UXxxcCEP7Hr0+nZUEAIZ4eDAs8E8wz/jeeK6JFY
zhzQsWE7x6c1fRu+4Po1TD5rYFxnOHaIZ8lTb9NXR3TR2KiX0lZJFkauQbImdkoS
GqL21EtxGkHBSPbauf70munKBZnHIc+mPLPHrRTibKh3qXk+Qz9PyHP6tLKvpzAw
ieJ7m3yAgoJQ4V3anSlQlIIrWg7S/U0cWZZDBu9UR8NEQeqX4UXEz9EekVJ2Z7Da
EYXT1YU/Yo4=
=3A3h
-----END PGP SIGNATURE-----

--=-s19U7PtftxI++zun600/--

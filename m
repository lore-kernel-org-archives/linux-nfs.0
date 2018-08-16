Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:37276 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726062AbeHPDeb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 15 Aug 2018 23:34:31 -0400
From: NeilBrown <neilb@suse.com>
To: Bruce Fields <bfields@fieldses.org>
Date: Thu, 16 Aug 2018 10:39:35 +1000
Cc: Nelson Elhage <nelhage@nelhage.com>,
        Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org,
        James Brown <jbrown@easypost.com>
Subject: Re: NFSv3 may inappropriately return EPERM for fsetxattr
In-Reply-To: <20180814194334.GO7906@fieldses.org>
References: <CAPSG9dbOPRv_gM_w_Ys9fJ-fSPRnw+Rgb3yaaHVEqZ9YyDntzg@mail.gmail.com> <20160321144349.GA12804@lst.de> <CAPSG9dZX45Uq07Xue55Aom3i-WyH9_SA_SKydBjsEX1Y14VwoA@mail.gmail.com> <874lg3roua.fsf@notabene.neil.brown.name> <20180810170027.GF7906@fieldses.org> <20180810170312.GG7906@fieldses.org> <87d0uor11r.fsf@notabene.neil.brown.name> <20180812132100.GL7906@fieldses.org> <878t5bqgx0.fsf@notabene.neil.brown.name> <87ftzhb9rh.fsf@notabene.neil.brown.name> <20180814194334.GO7906@fieldses.org>
Message-ID: <87r2iz9mbc.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 14 2018, Bruce Fields wrote:
> Honestly I'm not completely sure I understand the proposal.

Ok, here is a concrete RFC proposal which should make it easier to
understand.
I've tested that this fixes the specific problem in that a user with a
uid that doesn't match the file, but which the server will give
ownership rights to, can now setacl a file.

Thanks,
NeilBrown

From=2034f8b23b224e575d5f1fa30834b247e82a854546 Mon Sep 17 00:00:00 2001
From: NeilBrown <neilb@suse.com>
Date: Thu, 16 Aug 2018 10:37:21 +1000
Subject: [PATCH] VFS: introduce MAY_ACT_AS_OWNER

A few places in VFS, particularly set_posix_acl(), use
inode_owner_or_capable() to check if the caller has "owner"
access to the inode.
This assumes that it is valid to test inode->i_uid, which is not
always the case.  Particularly in the case of NFS it is not valid to
us i_uid (or i_mode) for permission tests - the server needs to make
the decision.

As a result if the server is remaping uids
(e.g. all-squash,anon_uid=3D1000),
then all users should have ownership access, but most users will not
be able to set acls.

This patch moves the ownership test to inode_permission and
i_op->permission.
A new flag for this functions, MAY_ACT_AS_OWNER is introduced.
generic_permission() now handles this correctly and many
i_op->permission functions call this function() and don't need any
changes.  A few are changed to handle MAY_ACT_AS_OWNER exactly
as generic_permission() does, using inode_owner_or_capable().
For these filesystems, no behavioural change should be noticed.

For NFS, nfs_permission is changed to always return 0 (success) if
MAY_ACT_AS_OWNER.  For NFS, and operations which use this flag should
be sent to the server, and the server will succeed or fail as
appropriate.

nfsd has a similar flag - NFSD_MAY_OWNER_OVERRIDE.  This is currently
implemented by a test on inode->i_uid.  It is changed to map this
flag to MAY_ACT_AS_OWNER.

Fixes: 013cdf1088d7 ("nfs: use generic posix ACL infrastructure for v3 Posi=
x ACLs")
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 fs/afs/security.c  | 10 ++++++++++
 fs/attr.c          | 12 +++++-------
 fs/coda/dir.c      | 10 ++++++++++
 fs/fcntl.c         |  2 +-
 fs/fuse/dir.c      | 10 ++++++++++
 fs/namei.c         |  9 +++++++++
 fs/nfs/dir.c       |  8 ++++++++
 fs/nfsd/vfs.c      |  9 +++++----
 fs/posix_acl.c     |  2 +-
 fs/xattr.c         |  2 +-
 include/linux/fs.h |  8 ++++++++
 11 files changed, 68 insertions(+), 14 deletions(-)

diff --git a/fs/afs/security.c b/fs/afs/security.c
index 81dfedb7879f..ac2e39de8bff 100644
=2D-- a/fs/afs/security.c
+++ b/fs/afs/security.c
@@ -349,6 +349,16 @@ int afs_permission(struct inode *inode, int mask)
 	if (mask & MAY_NOT_BLOCK)
 		return -ECHILD;
=20
+	/* Short-circuit for owner */
+	if (mask & MAY_ACT_AS_OWNER) {
+		if (inode_owner_or_capable(inode))
+			return 0;
+		mask &=3D ~MAY_ACT_AS_OWNER;
+		if (!mask)
+			/* No other permission will suffice */
+			return -EACCES;
+	}
+
 	_enter("{{%x:%u},%lx},%x,",
 	       vnode->fid.vid, vnode->fid.vnode, vnode->flags, mask);
=20
diff --git a/fs/attr.c b/fs/attr.c
index d22e8187477f..c1160bd9416b 100644
=2D-- a/fs/attr.c
+++ b/fs/attr.c
@@ -87,7 +87,7 @@ int setattr_prepare(struct dentry *dentry, struct iattr *=
attr)
=20
 	/* Make sure a caller can chmod. */
 	if (ia_valid & ATTR_MODE) {
=2D		if (!inode_owner_or_capable(inode))
+		if (inode_permission(inode, MAY_ACT_AS_OWNER) < 0)
 			return -EPERM;
 		/* Also check the setgid bit! */
 		if (!in_group_p((ia_valid & ATTR_GID) ? attr->ia_gid :
@@ -98,7 +98,7 @@ int setattr_prepare(struct dentry *dentry, struct iattr *=
attr)
=20
 	/* Check for setting the inode time. */
 	if (ia_valid & (ATTR_MTIME_SET | ATTR_ATIME_SET | ATTR_TIMES_SET)) {
=2D		if (!inode_owner_or_capable(inode))
+		if (inode_permission(inode, MAY_ACT_AS_OWNER) < 0)
 			return -EPERM;
 	}
=20
@@ -246,11 +246,9 @@ int notify_change(struct dentry * dentry, struct iattr=
 * attr, struct inode **de
 		if (IS_IMMUTABLE(inode))
 			return -EPERM;
=20
=2D		if (!inode_owner_or_capable(inode)) {
=2D			error =3D inode_permission(inode, MAY_WRITE);
=2D			if (error)
=2D				return error;
=2D		}
+		error =3D inode_permission(inode, MAY_ACT_AS_OWNER | MAY_WRITE);
+		if (error)
+			return error;
 	}
=20
 	if ((ia_valid & ATTR_MODE)) {
diff --git a/fs/coda/dir.c b/fs/coda/dir.c
index 00876ddadb43..7e31f68d4973 100644
=2D-- a/fs/coda/dir.c
+++ b/fs/coda/dir.c
@@ -80,6 +80,16 @@ int coda_permission(struct inode *inode, int mask)
 	if (mask & MAY_NOT_BLOCK)
 		return -ECHILD;
=20
+	/* Short-circuit for owner */
+	if (mask & MAY_ACT_AS_OWNER) {
+		if (inode_owner_or_capable(inode))
+			return 0;
+		mask &=3D ~MAY_ACT_AS_OWNER;
+		if (!mask)
+			/* No other permission will suffice */
+			return -EACCES;
+	}
+
 	mask &=3D MAY_READ | MAY_WRITE | MAY_EXEC;
=20=20
 	if (!mask)
diff --git a/fs/fcntl.c b/fs/fcntl.c
index 12273b6ea56d..dbf2531dc7fa 100644
=2D-- a/fs/fcntl.c
+++ b/fs/fcntl.c
@@ -46,7 +46,7 @@ static int setfl(int fd, struct file * filp, unsigned lon=
g arg)
=20
 	/* O_NOATIME can only be set by the owner or superuser */
 	if ((arg & O_NOATIME) && !(filp->f_flags & O_NOATIME))
=2D		if (!inode_owner_or_capable(inode))
+		if (inode_permission(inode, MAY_ACT_AS_OWNER) < 0)
 			return -EPERM;
=20
 	/* required for strict SunOS emulation */
diff --git a/fs/fuse/dir.c b/fs/fuse/dir.c
index d80aab0d5982..46deb2652dca 100644
=2D-- a/fs/fuse/dir.c
+++ b/fs/fuse/dir.c
@@ -1117,6 +1117,16 @@ static int fuse_permission(struct inode *inode, int =
mask)
 	if (!fuse_allow_current_process(fc))
 		return -EACCES;
=20
+	/* Short-circuit for owner */
+	if (mask & MAY_ACT_AS_OWNER) {
+		if (inode_owner_or_capable(inode))
+			return 0;
+		mask &=3D ~MAY_ACT_AS_OWNER;
+		if (!mask)
+			/* No other permission will suffice */
+			return -EACCES;
+	}
+
 	/*
 	 * If attributes are needed, refresh them before proceeding
 	 */
diff --git a/fs/namei.c b/fs/namei.c
index 3cd396277cd3..364bfafa5b01 100644
=2D-- a/fs/namei.c
+++ b/fs/namei.c
@@ -335,6 +335,15 @@ int generic_permission(struct inode *inode, int mask)
 {
 	int ret;
=20
+	/* Short-circuit for owner */
+	if (mask & MAY_ACT_AS_OWNER) {
+		if (inode_owner_or_capable(inode))
+			return 0;
+		mask &=3D ~MAY_ACT_AS_OWNER;
+		if (!mask)
+			/* No other permission will suffice */
+			return -EACCES;
+	}
 	/*
 	 * Do the basic permission checks.
 	 */
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index d7f158c3efc8..e487429318d8 100644
=2D-- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2516,6 +2516,14 @@ int nfs_permission(struct inode *inode, int mask)
=20
 	nfs_inc_stats(inode, NFSIOS_VFSACCESS);
=20
+	/* Short-circuit for owner */
+	if (mask & MAY_ACT_AS_OWNER)
+		/*
+		 * Ownership will be tested by server when we
+		 * actually try operation.
+		 */
+		return 0;
+
 	if ((mask & (MAY_READ | MAY_WRITE | MAY_EXEC)) =3D=3D 0)
 		goto out;
 	/* Is this sys_access() ? */
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 55a099e47ba2..467b3418af20 100644
=2D-- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -2038,12 +2038,13 @@ nfsd_permission(struct svc_rqst *rqstp, struct svc_=
export *exp,
 	 * We must trust the client to do permission checking - using "ACCESS"
 	 * with NFSv3.
 	 */
=2D	if ((acc & NFSD_MAY_OWNER_OVERRIDE) &&
=2D	    uid_eq(inode->i_uid, current_fsuid()))
=2D		return 0;
=20
 	/* This assumes  NFSD_MAY_{READ,WRITE,EXEC} =3D=3D MAY_{READ,WRITE,EXEC} =
*/
=2D	err =3D inode_permission(inode, acc & (MAY_READ|MAY_WRITE|MAY_EXEC));
+	if (acc & NFSD_MAY_OWNER_OVERRIDE)
+		err =3D inode_permission(inode, ((acc & (MAY_READ|MAY_WRITE|MAY_EXEC))
+					       | MAY_ACT_AS_OWNER));
+	else
+		err =3D inode_permission(inode, acc & (MAY_READ|MAY_WRITE|MAY_EXEC));
=20
 	/* Allow read access to binaries even when mode 111 */
 	if (err =3D=3D -EACCES && S_ISREG(inode->i_mode) &&
diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 2fd0fde16fe1..a90c7dca892a 100644
=2D-- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -863,7 +863,7 @@ set_posix_acl(struct inode *inode, int type, struct pos=
ix_acl *acl)
=20
 	if (type =3D=3D ACL_TYPE_DEFAULT && !S_ISDIR(inode->i_mode))
 		return acl ? -EACCES : 0;
=2D	if (!inode_owner_or_capable(inode))
+	if (inode_permission(inode, MAY_ACT_AS_OWNER) < 0)
 		return -EPERM;
=20
 	if (acl) {
diff --git a/fs/xattr.c b/fs/xattr.c
index f9cb1db187b7..9ce0a0994abd 100644
=2D-- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -127,7 +127,7 @@ xattr_permission(struct inode *inode, const char *name,=
 int mask)
 		if (!S_ISREG(inode->i_mode) && !S_ISDIR(inode->i_mode))
 			return (mask & MAY_WRITE) ? -EPERM : -ENODATA;
 		if (S_ISDIR(inode->i_mode) && (inode->i_mode & S_ISVTX) &&
=2D		    (mask & MAY_WRITE) && !inode_owner_or_capable(inode))
+		    (mask & MAY_WRITE) && inode_permission(inode, MAY_ACT_AS_OWNER) < 0)
 			return -EPERM;
 	}
=20
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 1ec33fd0423f..2641fb50bed0 100644
=2D-- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -92,6 +92,14 @@ typedef int (dio_iodone_t)(struct kiocb *iocb, loff_t of=
fset,
 #define MAY_CHDIR		0x00000040
 /* called from RCU mode, don't block */
 #define MAY_NOT_BLOCK		0x00000080
+/*
+ * File Owner is always allowed to perform pending
+ * operation.  If current user is an owner, or if
+ * filesystem performs permission check at time-of-operation,
+ * then succeed, else require some other permission
+ * if listed.
+ */
+#define MAY_ACT_AS_OWNER	0x00000100
=20
 /*
  * flags in file.f_mode.  Note that FMODE_READ and FMODE_WRITE must corres=
pond
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlt0x8gACgkQOeye3VZi
gbnBIhAAl3GE58+WYeSh2Eslvis6YDbb8zGcmAl7JDeZaKQBhHJS2woCYd8ewSsi
ea4tusS9OYeqJnyzvMDrt4uEJVJuKWFwcr0CLtCCsspOXctoE5azfD8WRcidXNae
0oCizLP7+7Jbe/FfIFWVXjnfmFcZuS+Uwf5Exc5CqaYA0wFUUS48dYQJcayVEgTo
jnNTDviAA4in+DE9TfM2LtkbEdtpSHLdXuLFvYC/KOxIDPhEK5+TL9dqtF+2LpIK
3Park7YEyCurhLNFl6az7c1I7MM0Q90rKi3N0BLm9xDPMyBSQFIwxIgNzPtoSpci
mxuGLdQzdgwDeqbJjhny0f8jOutJdmNNHyqcSnVmCNB7ulk7JZLWwOnDZgoaMEp/
Mr0rdg7tK5r5OQfEumj2HlSGDqcvxL4K2IbrYI1AK6nIeoddcepUZtxjLhezKUrB
SbLrtIHuqkcZM6xjKedUNsBLzsxhM+iJ3eIlzF72l6NorbUhaOGXAlOuvDz2i741
MVIZ8VZzlAsp4yEil4qHtkeAQT8RzltOktAQM/IEoTBAGGTk1Hs/miv6lknMNJwr
HZ9JQEJveB/f+xmhTCyoDV5RolRGEVsuplbtqRjpQ1Hguyb0arxQmnRAXLb8ci84
MOKJhH40Nz55vbM7WYKcN5QyVmE1FF/vg7s7+nLWGf6x+7y6bMU=
=V/gy
-----END PGP SIGNATURE-----
--=-=-=--

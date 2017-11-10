Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:34675 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755161AbdKJAVk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Nov 2017 19:21:40 -0500
From: NeilBrown <neilb@suse.com>
To: Jeff Layton <jlayton@redhat.com>, Ian Kent <ikent@redhat.com>,
        Latchesar Ionkov <lucho@ionkov.net>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Ron Minnich <rminnich@sandia.gov>,
        Trond Myklebust <trondmy@primarydata.com>
Date: Fri, 10 Nov 2017 11:21:26 +1100
Cc: linux-nfs@vger.kernel.org, autofs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        v9fs-developer@lists.sourceforge.net,
        Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 0/3] VFS: name lookup improvements.
In-Reply-To: <87a7zvf9ha.fsf@notabene.neil.brown.name>
References: <151021179901.22743.15252956909042161062.stgit@noble> <1510230754.29194.6.camel@redhat.com> <87a7zvf9ha.fsf@notabene.neil.brown.name>
Message-ID: <87r2t7dlvd.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 10 2017, NeilBrown wrote:
>>
>> Your patch does make me wonder if we should consider merging
>> d_weak_revalidate and d_revalidate back together, and simply require all
>> the d_revalidate ops vet the flags more thoroughly.
>
> This boils down to adding
>
>  if (flags & LOOKUP_JUMPED)
>  	return 1;
>
> to the front of almost every d_revalidate function.
> I'm probably in favour of that, but it isn't an obvious win.
> I can certainly offer it as a follow-on patch so we can see
> exactly the impact.


See below.
NeilBrown

From: NeilBrown <neilb@suse.com>
Date: Wed, 16 Aug 2017 09:03:36 +1000
Subject: [PATCH] VFS: remove d_weak_revalidate inode operation

d_weak_revalidate is now very similar to d_revalidate.
The difference is that the former always has LOOKUP_JUMPED
set and the later doesn't.  When LOOKUP_JUMPED is set
the name does not need to be revalidated, but the inode might.

This distinction can be managed entirely in the filesystem
without needing two similar entry points.

So discard d_weak_revalidate and call d_revalidate instead.
Make sure all d_revalidate functions avoid checking the validity
of the name if LOOKUP_JUMPED is set.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 Documentation/filesystems/Locking            |  2 --
 Documentation/filesystems/porting            |  6 ++++++
 Documentation/filesystems/vfs.txt            | 20 +++++---------------
 drivers/staging/lustre/lustre/llite/dcache.c |  2 +-
 fs/9p/vfs_dentry.c                           |  3 +++
 fs/afs/dir.c                                 |  3 +++
 fs/ceph/dir.c                                |  3 +++
 fs/cifs/dir.c                                |  3 +++
 fs/coda/dir.c                                |  3 +++
 fs/crypto/crypto.c                           |  3 +++
 fs/dcache.c                                  |  3 ---
 fs/ecryptfs/dentry.c                         |  3 +++
 fs/fat/namei_vfat.c                          |  4 ++++
 fs/fuse/dir.c                                |  3 +++
 fs/gfs2/dentry.c                             |  3 +++
 fs/kernfs/dir.c                              |  3 +++
 fs/namei.c                                   |  4 ++--
 fs/ncpfs/dir.c                               |  3 +++
 fs/nfs/dir.c                                 |  2 --
 fs/ocfs2/dcache.c                            |  3 +++
 fs/orangefs/dcache.c                         |  3 +++
 fs/overlayfs/super.c                         | 19 -------------------
 fs/overlayfs/util.c                          |  3 +--
 fs/proc/base.c                               |  3 +++
 fs/proc/fd.c                                 |  3 +++
 include/linux/dcache.h                       |  3 ---
 26 files changed, 64 insertions(+), 49 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/=
Locking
index 75d2d57e2c44..a824a305cf5d 100644
=2D-- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -10,7 +10,6 @@ be able to use diff(1).
 --------------------------- dentry_operations --------------------------
 prototypes:
 	int (*d_revalidate)(struct dentry *, unsigned int);
=2D	int (*d_weak_revalidate)(struct dentry *, unsigned int);
 	int (*d_hash)(const struct dentry *, struct qstr *);
 	int (*d_compare)(const struct dentry *,
 			unsigned int, const char *, const struct qstr *);
@@ -27,7 +26,6 @@ prototypes:
 locking rules:
 		rename_lock	->d_lock	may block	rcu-walk
 d_revalidate:	no		no		yes (ref-walk)	maybe
=2Dd_weak_revalidate:no		no		yes	 	no
 d_hash		no		no		no		maybe
 d_compare:	yes		no		no		maybe
 d_delete:	no		yes		no		no
diff --git a/Documentation/filesystems/porting b/Documentation/filesystems/=
porting
index f455757ff1c6..56809d6938b5 100644
=2D-- a/Documentation/filesystems/porting
+++ b/Documentation/filesystems/porting
@@ -611,3 +611,9 @@ in your dentry operations instead.
 	->d_weak_revalidate should perform the same handling of LOOKUP_OPEN as
 	->d_revalidate.  If LOOKUP_OPEN is not set, d_weak_revalidate need not
 	do anything.
+--
+[mandatory]
+	->d_weak_revalidate() is gone.  ->d_revalidate must check for
+	LOOKUP_JUMPED and skip revalidate of the name in that case.
+	If LOOKUP_JUMPED is set and LOOKUP_OPEN is not set, ->d_revalidate
+	need not do anything.
diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/=
vfs.txt
index c2025e226b29..d4bd4f016115 100644
=2D-- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -976,7 +976,6 @@ defined:
=20
 struct dentry_operations {
 	int (*d_revalidate)(struct dentry *, unsigned int);
=2D	int (*d_weak_revalidate)(struct dentry *, unsigned int);
 	int (*d_hash)(const struct dentry *, struct qstr *);
 	int (*d_compare)(const struct dentry *,
 			unsigned int, const char *, const struct qstr *);
@@ -1010,20 +1009,11 @@ struct dentry_operations {
 	If a situation is encountered that rcu-walk cannot handle, return
 	-ECHILD and it will be called again in ref-walk mode.
=20
=2D d_weak_revalidate: called when the VFS needs to revalidate a "jumped" d=
entry.
=2D	This is called when a path-walk ends at dentry that was not acquired by
=2D	doing a lookup in the parent directory. This includes "/", "." and "..",
=2D	as well as procfs-style symlinks and mountpoint traversal.
=2D
=2D	Filesystems only need this if they handle LOOKUP_OPEN in
=2D	d_revalidate, in which case the same handling should be applied
=2D	in d_weak_revalidate.  When LOOKUP_OPEN is not set,
=2D	d_weak_revalidate can safely be a no-op.
=2D
=2D	This function has the same return code semantics as d_revalidate.
=2D
=2D	d_weak_revalidate is only called after leaving rcu-walk mode,
=2D	so LOOKUP_RCU is never set.
+	If LOOKUP_JUMPED is set in flags, the name does not need to be
+	revalidated and in many cases d_revalidate can safely do
+	nothing.  If the filesystem handles LOOKUP_OPEN in
+	d_revalidate, that same handling should still be performed
+	when LOOKUP_JUMPED is set.
=20
   d_hash: called when the VFS adds a dentry to the hash table. The first
 	dentry passed to d_hash is the parent directory that the name is
diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging=
/lustre/lustre/llite/dcache.c
index 3670fcaf373f..b6c54edc45cd 100644
=2D-- a/drivers/staging/lustre/lustre/llite/dcache.c
+++ b/drivers/staging/lustre/lustre/llite/dcache.c
@@ -240,7 +240,7 @@ static int ll_revalidate_dentry(struct dentry *dentry,
 	 * to this dentry, then its lock has not been revoked and the
 	 * path component is valid.
 	 */
=2D	if (lookup_flags & LOOKUP_PARENT)
+	if (lookup_flags & (LOOKUP_PARENT | LOOKUP_JUMPED))
 		return 1;
=20
 	/* Symlink - always valid as long as the dentry was found */
diff --git a/fs/9p/vfs_dentry.c b/fs/9p/vfs_dentry.c
index 99eaf3c6d44c..0995aaa4e48e 100644
=2D-- a/fs/9p/vfs_dentry.c
+++ b/fs/9p/vfs_dentry.c
@@ -83,6 +83,9 @@ static int v9fs_lookup_revalidate(struct dentry *dentry, =
unsigned int flags)
 	if (flags & LOOKUP_RCU)
 		return -ECHILD;
=20
+	if (flags & LOOKUP_JUMPED)
+		return 1;
+
 	inode =3D d_inode(dentry);
 	if (!inode)
 		goto out_valid;
diff --git a/fs/afs/dir.c b/fs/afs/dir.c
index 613a77058263..71b46202c15a 100644
=2D-- a/fs/afs/dir.c
+++ b/fs/afs/dir.c
@@ -588,6 +588,9 @@ static int afs_d_revalidate(struct dentry *dentry, unsi=
gned int flags)
 	if (flags & LOOKUP_RCU)
 		return -ECHILD;
=20
+	if (flags & LOOKUP_JUMPED)
+		return 1;
+
 	vnode =3D AFS_FS_I(d_inode(dentry));
=20
 	if (d_really_is_positive(dentry))
diff --git a/fs/ceph/dir.c b/fs/ceph/dir.c
index 8a5266699b67..718547b8c348 100644
=2D-- a/fs/ceph/dir.c
+++ b/fs/ceph/dir.c
@@ -1217,6 +1217,9 @@ static int ceph_d_revalidate(struct dentry *dentry, u=
nsigned int flags)
 	struct dentry *parent;
 	struct inode *dir;
=20
+	if (flags & LOOKUP_JUMPED)
+		return 1;
+
 	if (flags & LOOKUP_RCU) {
 		parent =3D READ_ONCE(dentry->d_parent);
 		dir =3D d_inode_rcu(parent);
diff --git a/fs/cifs/dir.c b/fs/cifs/dir.c
index 81ba6e0d88d8..5714a036c0a6 100644
=2D-- a/fs/cifs/dir.c
+++ b/fs/cifs/dir.c
@@ -843,6 +843,9 @@ cifs_d_revalidate(struct dentry *direntry, unsigned int=
 flags)
 	if (flags & LOOKUP_RCU)
 		return -ECHILD;
=20
+	if (flags & LOOKUP_JUMPED)
+		return 1;
+
 	if (d_really_is_positive(direntry)) {
 		if (cifs_revalidate_dentry(direntry))
 			return 0;
diff --git a/fs/coda/dir.c b/fs/coda/dir.c
index 00876ddadb43..41a44465de2d 100644
=2D-- a/fs/coda/dir.c
+++ b/fs/coda/dir.c
@@ -461,6 +461,9 @@ static int coda_dentry_revalidate(struct dentry *de, un=
signed int flags)
 	if (flags & LOOKUP_RCU)
 		return -ECHILD;
=20
+	if (flags & LOOKUP_JUMPED)
+		return 1;
+
 	inode =3D d_inode(de);
 	if (!inode || is_root_inode(inode))
 		goto out;
diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index c7835df7e7b8..fd14eb2cd6cc 100644
=2D-- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -339,6 +339,9 @@ static int fscrypt_d_revalidate(struct dentry *dentry, =
unsigned int flags)
 	if (flags & LOOKUP_RCU)
 		return -ECHILD;
=20
+	if (flags & LOOKUP_JUMPED)
+		return 1;
+
 	dir =3D dget_parent(dentry);
 	if (!d_inode(dir)->i_sb->s_cop->is_encrypted(d_inode(dir))) {
 		dput(dir);
diff --git a/fs/dcache.c b/fs/dcache.c
index 3130d62f29c9..0dd4e53fbc43 100644
=2D-- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1755,7 +1755,6 @@ void d_set_d_op(struct dentry *dentry, const struct d=
entry_operations *op)
 	WARN_ON_ONCE(dentry->d_flags & (DCACHE_OP_HASH	|
 				DCACHE_OP_COMPARE	|
 				DCACHE_OP_REVALIDATE	|
=2D				DCACHE_OP_WEAK_REVALIDATE	|
 				DCACHE_OP_DELETE	|
 				DCACHE_OP_REAL));
 	dentry->d_op =3D op;
@@ -1767,8 +1766,6 @@ void d_set_d_op(struct dentry *dentry, const struct d=
entry_operations *op)
 		dentry->d_flags |=3D DCACHE_OP_COMPARE;
 	if (op->d_revalidate)
 		dentry->d_flags |=3D DCACHE_OP_REVALIDATE;
=2D	if (op->d_weak_revalidate)
=2D		dentry->d_flags |=3D DCACHE_OP_WEAK_REVALIDATE;
 	if (op->d_delete)
 		dentry->d_flags |=3D DCACHE_OP_DELETE;
 	if (op->d_prune)
diff --git a/fs/ecryptfs/dentry.c b/fs/ecryptfs/dentry.c
index 63cd2c147221..bf908d964aab 100644
=2D-- a/fs/ecryptfs/dentry.c
+++ b/fs/ecryptfs/dentry.c
@@ -50,6 +50,9 @@ static int ecryptfs_d_revalidate(struct dentry *dentry, u=
nsigned int flags)
 	if (flags & LOOKUP_RCU)
 		return -ECHILD;
=20
+	if (flags & LOOKUP_JUMPED)
+		return 1;
+
 	if (lower_dentry->d_flags & DCACHE_OP_REVALIDATE)
 		rc =3D lower_dentry->d_op->d_revalidate(lower_dentry, flags);
=20
diff --git a/fs/fat/namei_vfat.c b/fs/fat/namei_vfat.c
index 02c066663a3a..a5bfb7fde9c5 100644
=2D-- a/fs/fat/namei_vfat.c
+++ b/fs/fat/namei_vfat.c
@@ -45,6 +45,7 @@ static inline void vfat_d_version_set(struct dentry *dent=
ry,
 static int vfat_revalidate_shortname(struct dentry *dentry)
 {
 	int ret =3D 1;
+
 	spin_lock(&dentry->d_lock);
 	if (vfat_d_version(dentry) !=3D d_inode(dentry->d_parent)->i_version)
 		ret =3D 0;
@@ -68,6 +69,9 @@ static int vfat_revalidate_ci(struct dentry *dentry, unsi=
gned int flags)
 	if (flags & LOOKUP_RCU)
 		return -ECHILD;
=20
+	if (flags & LOOKUP_JUMPED)
+		return 1;
+
 	/*
 	 * This is not negative dentry. Always valid.
 	 *
diff --git a/fs/fuse/dir.c b/fs/fuse/dir.c
index 24967382a7b1..883215127bcd 100644
=2D-- a/fs/fuse/dir.c
+++ b/fs/fuse/dir.c
@@ -186,6 +186,9 @@ static int fuse_dentry_revalidate(struct dentry *entry,=
 unsigned int flags)
 	struct fuse_inode *fi;
 	int ret;
=20
+	if (flags & LOOKUP_JUMPED)
+		return 1;
+
 	inode =3D d_inode_rcu(entry);
 	if (inode && is_bad_inode(inode))
 		goto invalid;
diff --git a/fs/gfs2/dentry.c b/fs/gfs2/dentry.c
index 5173b98ca036..8cd906abf424 100644
=2D-- a/fs/gfs2/dentry.c
+++ b/fs/gfs2/dentry.c
@@ -47,6 +47,9 @@ static int gfs2_drevalidate(struct dentry *dentry, unsign=
ed int flags)
 	if (flags & LOOKUP_RCU)
 		return -ECHILD;
=20
+	if (flags & LOOKUP_JUMPED)
+		return 1;
+
 	parent =3D dget_parent(dentry);
 	sdp =3D GFS2_SB(d_inode(parent));
 	dip =3D GFS2_I(d_inode(parent));
diff --git a/fs/kernfs/dir.c b/fs/kernfs/dir.c
index 89d1dc19340b..8f0aad50c3b3 100644
=2D-- a/fs/kernfs/dir.c
+++ b/fs/kernfs/dir.c
@@ -562,6 +562,9 @@ static int kernfs_dop_revalidate(struct dentry *dentry,=
 unsigned int flags)
 	if (flags & LOOKUP_RCU)
 		return -ECHILD;
=20
+	if (flags & LOOKUP_JUMPED)
+		return 1;
+
 	/* Always perform fresh lookup for negatives */
 	if (d_really_is_negative(dentry))
 		goto out_bad_unlocked;
diff --git a/fs/namei.c b/fs/namei.c
index e90680a3f6f1..cc1d472749b1 100644
=2D-- a/fs/namei.c
+++ b/fs/namei.c
@@ -809,10 +809,10 @@ static int complete_walk(struct nameidata *nd)
 	if (likely(!(nd->flags & LOOKUP_JUMPED)))
 		return 0;
=20
=2D	if (likely(!(dentry->d_flags & DCACHE_OP_WEAK_REVALIDATE)))
+	if (likely(!(dentry->d_flags & DCACHE_OP_REVALIDATE)))
 		return 0;
=20
=2D	status =3D dentry->d_op->d_weak_revalidate(dentry, nd->flags);
+	status =3D dentry->d_op->d_revalidate(dentry, nd->flags);
 	if (status > 0)
 		return 0;
=20
diff --git a/fs/ncpfs/dir.c b/fs/ncpfs/dir.c
index b5ec1d980dc9..fb78808b45e2 100644
=2D-- a/fs/ncpfs/dir.c
+++ b/fs/ncpfs/dir.c
@@ -323,6 +323,9 @@ ncp_lookup_validate(struct dentry *dentry, unsigned int=
 flags)
 	if (flags & LOOKUP_RCU)
 		return -ECHILD;
=20
+	if (flags & LOOKUP_JUMPED)
+		return 1;
+
 	parent =3D dget_parent(dentry);
 	dir =3D d_inode(parent);
=20
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index fc349577526f..ffe76746cce8 100644
=2D-- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1273,7 +1273,6 @@ static void nfs_d_release(struct dentry *dentry)
=20
 const struct dentry_operations nfs_dentry_operations =3D {
 	.d_revalidate	=3D nfs_lookup_revalidate,
=2D	.d_weak_revalidate	=3D nfs_lookup_revalidate,
 	.d_delete	=3D nfs_dentry_delete,
 	.d_iput		=3D nfs_dentry_iput,
 	.d_automount	=3D nfs_d_automount,
@@ -1352,7 +1351,6 @@ static int nfs4_lookup_revalidate(struct dentry *, un=
signed int);
=20
 const struct dentry_operations nfs4_dentry_operations =3D {
 	.d_revalidate	=3D nfs4_lookup_revalidate,
=2D	.d_weak_revalidate	=3D nfs4_lookup_revalidate,
 	.d_delete	=3D nfs_dentry_delete,
 	.d_iput		=3D nfs_dentry_iput,
 	.d_automount	=3D nfs_d_automount,
diff --git a/fs/ocfs2/dcache.c b/fs/ocfs2/dcache.c
index 290373024d9d..2ca92974f0b3 100644
=2D-- a/fs/ocfs2/dcache.c
+++ b/fs/ocfs2/dcache.c
@@ -57,6 +57,9 @@ static int ocfs2_dentry_revalidate(struct dentry *dentry,=
 unsigned int flags)
 	if (flags & LOOKUP_RCU)
 		return -ECHILD;
=20
+	if (flags & LOOKUP_JUMPED)
+		return 1;
+
 	inode =3D d_inode(dentry);
 	osb =3D OCFS2_SB(dentry->d_sb);
=20
diff --git a/fs/orangefs/dcache.c b/fs/orangefs/dcache.c
index ae782df5c063..64d5f462ffc2 100644
=2D-- a/fs/orangefs/dcache.c
+++ b/fs/orangefs/dcache.c
@@ -103,6 +103,9 @@ static int orangefs_d_revalidate(struct dentry *dentry,=
 unsigned int flags)
 	if (flags & LOOKUP_RCU)
 		return -ECHILD;
=20
+	if (flags & LOOKUP_JUMPED)
+		return 1;
+
 	gossip_debug(GOSSIP_DCACHE_DEBUG, "%s: called on dentry %p.\n",
 		     __func__, dentry);
=20
diff --git a/fs/overlayfs/super.c b/fs/overlayfs/super.c
index f5738e96a052..6824ac56927f 100644
=2D-- a/fs/overlayfs/super.c
+++ b/fs/overlayfs/super.c
@@ -138,24 +138,6 @@ static int ovl_dentry_revalidate(struct dentry *dentry=
, unsigned int flags)
 	return 1;
 }
=20
=2Dstatic int ovl_dentry_weak_revalidate(struct dentry *dentry, unsigned in=
t flags)
=2D{
=2D	struct ovl_entry *oe =3D dentry->d_fsdata;
=2D	unsigned int i;
=2D	int ret =3D 1;
=2D
=2D	for (i =3D 0; i < oe->numlower; i++) {
=2D		struct dentry *d =3D oe->lowerstack[i].dentry;
=2D
=2D		if (d->d_flags & DCACHE_OP_WEAK_REVALIDATE) {
=2D			ret =3D d->d_op->d_weak_revalidate(d, flags);
=2D			if (ret <=3D 0)
=2D				break;
=2D		}
=2D	}
=2D	return ret;
=2D}
=2D
 static const struct dentry_operations ovl_dentry_operations =3D {
 	.d_release =3D ovl_dentry_release,
 	.d_real =3D ovl_d_real,
@@ -165,7 +147,6 @@ static const struct dentry_operations ovl_reval_dentry_=
operations =3D {
 	.d_release =3D ovl_dentry_release,
 	.d_real =3D ovl_d_real,
 	.d_revalidate =3D ovl_dentry_revalidate,
=2D	.d_weak_revalidate =3D ovl_dentry_weak_revalidate,
 };
=20
 static struct kmem_cache *ovl_inode_cachep;
diff --git a/fs/overlayfs/util.c b/fs/overlayfs/util.c
index b9b239fa5cfd..131501b5a35b 100644
=2D-- a/fs/overlayfs/util.c
+++ b/fs/overlayfs/util.c
@@ -78,8 +78,7 @@ struct ovl_entry *ovl_alloc_entry(unsigned int numlower)
 bool ovl_dentry_remote(struct dentry *dentry)
 {
 	return dentry->d_flags &
=2D		(DCACHE_OP_REVALIDATE | DCACHE_OP_WEAK_REVALIDATE |
=2D		 DCACHE_OP_REAL);
+		(DCACHE_OP_REVALIDATE | DCACHE_OP_REAL);
 }
=20
 bool ovl_dentry_weird(struct dentry *dentry)
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 9d357b2ea6cb..10709224efca 100644
=2D-- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1926,6 +1926,9 @@ static int map_files_d_revalidate(struct dentry *dent=
ry, unsigned int flags)
 	if (flags & LOOKUP_RCU)
 		return -ECHILD;
=20
+	if (flags & LOOKUP_JUMPED)
+		return 1;
+
 	inode =3D d_inode(dentry);
 	task =3D get_proc_task(inode);
 	if (!task)
diff --git a/fs/proc/fd.c b/fs/proc/fd.c
index 96fc70225e54..68ec359c8161 100644
=2D-- a/fs/proc/fd.c
+++ b/fs/proc/fd.c
@@ -91,6 +91,9 @@ static int tid_fd_revalidate(struct dentry *dentry, unsig=
ned int flags)
 	if (flags & LOOKUP_RCU)
 		return -ECHILD;
=20
+	if (flags & LOOKUP_JUMPED)
+		return 1;
+
 	inode =3D d_inode(dentry);
 	task =3D get_proc_task(inode);
 	fd =3D proc_fd(inode);
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index f05a659cdf34..5da4c2ed5f3b 100644
=2D-- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -135,7 +135,6 @@ enum dentry_d_lock_class
=20
 struct dentry_operations {
 	int (*d_revalidate)(struct dentry *, unsigned int);
=2D	int (*d_weak_revalidate)(struct dentry *, unsigned int);
 	int (*d_hash)(const struct dentry *, struct qstr *);
 	int (*d_compare)(const struct dentry *,
 			unsigned int, const char *, const struct qstr *);
@@ -184,8 +183,6 @@ struct dentry_operations {
 #define DCACHE_GENOCIDE			0x00000200
 #define DCACHE_SHRINK_LIST		0x00000400
=20
=2D#define DCACHE_OP_WEAK_REVALIDATE	0x00000800
=2D
 #define DCACHE_NFSFS_RENAMED		0x00001000
      /* this dentry has been "silly renamed" and has to be deleted on the =
last
       * dput() */
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAloE8QcACgkQOeye3VZi
gbm7Gg/9EPtDhT/wR2acUVGLi0TwJud0SO/4x3m6LZFmVp7QkpE4J2LWetJ1YdvP
BAJHXv/vpTqRK6v1RXrCcf/uNUXnxBvKtbCv0SHQKZyPCo9AAwxvknm3V/Q15j0f
lcNqQ92w0srhPDZZHEl6NwjJ6qsdLiTPf4PeRuHTVU2vIzQCfYh3+l4CA0r9uh+h
7DhvxtrirPddTqxbFq6SAImOg/GBW+trok6vAieX6bjT4wXRAh14tanEuL2iHZYN
Oe5PrWir1HD3+3vb2PwDeuJ5oiCEbXcd5PWdHFlaqXyVuYg13Jq1ZcBmfllCChhz
QnKPo48FSjhBhmrFG5Cfs5drGB4mDqRUUsBH9UI2z4HEEvs6+daHm1r6FtLLHjTX
sQOpKOJ5OJQIZcl4oYRFJDObDmw1A3I+4KYRqH8Cm06QccHAR3fawNUgNRo55+ZB
x+YE8qx1Dfe+rQKlsT9WFEBlykXW2mHxhBobPHpdzhUrC6Yz/6HeQ2X5JyKfCqaU
6laZxmZAvolGFXdLm7cA6nr9FjsJq04q++YW0uDZ57YY3M7fIFCgEoMdcTgVIaFw
Yq3V+6cxlK5b8w2z5w51CYHl2kVlHBhixvEffe7oZfhEBt/ms5OUrLDl5G+TRj4a
9pzA6JXN7tiUrkb/fGPeVrR1u0xAztUIpDXkpqt5m0azVeGBS/s=
=aST3
-----END PGP SIGNATURE-----
--=-=-=--

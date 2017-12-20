Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38129 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751955AbdLTWpy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Dec 2017 17:45:54 -0500
From: NeilBrown <neilb@suse.com>
To: Al Viro <viro@zeniv.linux.org.uk>,
        Linus Torvalds <torvalds@linux-foundation.org>
to: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Date: Thu, 21 Dec 2017 09:45:40 +1100
Subject: [PATCH/RFC] VFS: don't keep disconnected dentries on d_anon
cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <87y3lxj9wr.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


The original purpose of the per-superblock d_anon list was to
keep disconnected dentries in the cache between consecutive
requests to the NFS server.  Dentries can be disconnected if
a client holds a file open and repeatedly performs IO on it,
and if the server drops the dentry, whether due to memory
pressure, server restart, or "echo 3 > /proc/sys/vm/drop_caches".

This purpose was thwarted by commit 75a6f82a0d10 ("freeing unlinked
file indefinitely delayed") which caused disconnected dentries
to be freed as soon as their refcount reached zero.

This means that, when a dentry being used by nfsd gets disconnected, a
new one needs to be allocated for every request (unless requests
overlap).  As the dentry has no name, no parent, and no children,
there is little of value to cache.  As small memory allocations are
typically fast (from per-cpu free lists) this likely has little cost.

This means that the original purpose of s_anon is no longer relevant:
there is no longer any need to keep disconnected dentries on a list so
they appear to be hashed.

However, s_anon now has a new use.  When you mount an NFS filesystem,
the dentry stored in s_root is just a placebo.  The "real" root dentry
is allocated using d_obtain_root() and so it kept on the s_anon list.
I don't know the reason for this, but suspect it related to NFSv4
where a mount of "server:/some/path" require NFS to look up the root
filehandle on the server, then walk down "/some" and "/path" to get
the filehandle to mount.

Whatever the reason, NFS depends on the s_anon list and on
shrink_dcache_for_umount() pruning all dentries on this list.  So we
cannot simply remove s_anon.

We could just leave the code unchanged, but apart from that being
potentially confusing, the (unfair) bit-spin-lock which protects
s_anon can become a bottle neck when lots of disconnected dentries are
being created.

So this patch renames s_anon to s_roots, and stops storing
disconnected dentries on the list.  Only dentries obtained with
d_obtain_root() are now stored on this list.  There are many fewer of
these (only NFS and NILFS2 use the call, and only during filesystem
mount) so contention on the bit-lock will not be a problem.

Possibly an alternate solution should be found for NFS and NILFS2, but
that would require understanding their needs first.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 Documentation/filesystems/nfs/Exporting            | 19 ++++++++++---------
 .../staging/lustre/lustre/llite/llite_internal.h   | 10 +---------
 fs/dcache.c                                        | 22 ++++++++++++------=
----
 fs/super.c                                         |  2 +-
 include/linux/fs.h                                 |  2 +-
 5 files changed, 25 insertions(+), 30 deletions(-)

diff --git a/Documentation/filesystems/nfs/Exporting b/Documentation/filesy=
stems/nfs/Exporting
index 520a4becb75c..269ff98f1a0f 100644
=2D-- a/Documentation/filesystems/nfs/Exporting
+++ b/Documentation/filesystems/nfs/Exporting
@@ -56,15 +56,16 @@ a/ A dentry flag DCACHE_DISCONNECTED which is set on
    any dentry that might not be part of the proper prefix.
    This is set when anonymous dentries are created, and cleared when a
    dentry is noticed to be a child of a dentry which is in the proper
=2D   prefix.=20
=2D
=2Db/ A per-superblock list "s_anon" of dentries which are the roots of
=2D   subtrees that are not in the proper prefix.  These dentries, as
=2D   well as the proper prefix, need to be released at unmount time.  As
=2D   these dentries will not be hashed, they are linked together on the
=2D   d_hash list_head.
=2D
=2Dc/ Helper routines to allocate anonymous dentries, and to help attach
+   prefix.  If the refcount on a dentry with this flag set
+   becomes zero, the dentry is immediately discarded, rather than being
+   kept in the dcache.  If a dentry that is not already in the dcache
+   is repeatedly accessed by filehandle (as NFSD might do), an new dentry
+   will be a allocated for each access, and discarded at the end of
+   the access.  As there is no parent, children, or name in the dentry
+   is it unlikely that there will be any useful information to lose,
+   and allocating a new dentry should normally be fast.
+
+b/ Helper routines to allocate anonymous dentries, and to help attach
    loose directory dentries at lookup time. They are:
     d_obtain_alias(inode) will return a dentry for the given inode.
       If the inode already has a dentry, one of those is returned.
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers=
/staging/lustre/lustre/llite/llite_internal.h
index b133fd00c08c..0d62fcf016dc 100644
=2D-- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -1296,15 +1296,7 @@ static inline void d_lustre_invalidate(struct dentry=
 *dentry, int nested)
 	spin_lock_nested(&dentry->d_lock,
 			 nested ? DENTRY_D_LOCK_NESTED : DENTRY_D_LOCK_NORMAL);
 	ll_d2d(dentry)->lld_invalid =3D 1;
=2D	/*
=2D	 * We should be careful about dentries created by d_obtain_alias().
=2D	 * These dentries are not put in the dentry tree, instead they are
=2D	 * linked to sb->s_anon through dentry->d_hash.
=2D	 * shrink_dcache_for_umount() shrinks the tree and sb->s_anon list.
=2D	 * If we unhashed such a dentry, unmount would not be able to find
=2D	 * it and busy inodes would be reported.
=2D	 */
=2D	if (d_count(dentry) =3D=3D 0 && !(dentry->d_flags & DCACHE_DISCONNECTED=
))
+	if (d_count(dentry) =3D=3D 0)
 		__d_drop(dentry);
 	spin_unlock(&dentry->d_lock);
 }
diff --git a/fs/dcache.c b/fs/dcache.c
index 5c7df1df81ff..2c0db70a92fa 100644
=2D-- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -49,8 +49,8 @@
  *   - i_dentry, d_u.d_alias, d_inode of aliases
  * dcache_hash_bucket lock protects:
  *   - the dcache hash table
=2D * s_anon bl list spinlock protects:
=2D *   - the s_anon list (see __d_drop)
+ * s_roots bl list spinlock protects:
+ *   - the s_roots list (see __d_drop)
  * dentry->d_sb->s_dentry_lru_lock protects:
  *   - the dcache lru lists and counters
  * d_lock protects:
@@ -68,7 +68,7 @@
  *   dentry->d_lock
  *     dentry->d_sb->s_dentry_lru_lock
  *     dcache_hash_bucket lock
=2D *     s_anon lock
+ *     s_roots lock
  *
  * If there is an ancestor relationship:
  * dentry->d_parent->...->d_parent->d_lock
@@ -477,10 +477,10 @@ void __d_drop(struct dentry *dentry)
 		/*
 		 * Hashed dentries are normally on the dentry hashtable,
 		 * with the exception of those newly allocated by
=2D		 * d_obtain_alias, which are always IS_ROOT:
+		 * d_obtain_root, which are always IS_ROOT:
 		 */
 		if (unlikely(IS_ROOT(dentry)))
=2D			b =3D &dentry->d_sb->s_anon;
+			b =3D &dentry->d_sb->s_roots;
 		else
 			b =3D d_hash(dentry->d_name.hash);
=20
@@ -1500,8 +1500,8 @@ void shrink_dcache_for_umount(struct super_block *sb)
 	sb->s_root =3D NULL;
 	do_one_tree(dentry);
=20
=2D	while (!hlist_bl_empty(&sb->s_anon)) {
=2D		dentry =3D dget(hlist_bl_entry(hlist_bl_first(&sb->s_anon), struct den=
try, d_hash));
+	while (!hlist_bl_empty(&sb->s_roots)) {
+		dentry =3D dget(hlist_bl_entry(hlist_bl_first(&sb->s_roots), struct dent=
ry, d_hash));
 		do_one_tree(dentry);
 	}
 }
@@ -1965,9 +1965,11 @@ static struct dentry *__d_obtain_alias(struct inode =
*inode, int disconnected)
 	spin_lock(&tmp->d_lock);
 	__d_set_inode_and_type(tmp, inode, add_flags);
 	hlist_add_head(&tmp->d_u.d_alias, &inode->i_dentry);
=2D	hlist_bl_lock(&tmp->d_sb->s_anon);
=2D	hlist_bl_add_head(&tmp->d_hash, &tmp->d_sb->s_anon);
=2D	hlist_bl_unlock(&tmp->d_sb->s_anon);
+	if (!disconnected) {
+		hlist_bl_lock(&tmp->d_sb->s_roots);
+		hlist_bl_add_head(&tmp->d_hash, &tmp->d_sb->s_roots);
+		hlist_bl_unlock(&tmp->d_sb->s_roots);
+	}
 	spin_unlock(&tmp->d_lock);
 	spin_unlock(&inode->i_lock);
=20
diff --git a/fs/super.c b/fs/super.c
index 7ff1349609e4..14c2ba3a1c28 100644
=2D-- a/fs/super.c
+++ b/fs/super.c
@@ -225,7 +225,7 @@ static struct super_block *alloc_super(struct file_syst=
em_type *type, int flags,
 	if (s->s_user_ns !=3D &init_user_ns)
 		s->s_iflags |=3D SB_I_NODEV;
 	INIT_HLIST_NODE(&s->s_instances);
=2D	INIT_HLIST_BL_HEAD(&s->s_anon);
+	INIT_HLIST_BL_HEAD(&s->s_roots);
 	mutex_init(&s->s_sync_lock);
 	INIT_LIST_HEAD(&s->s_inodes);
 	spin_lock_init(&s->s_inode_list_lock);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 511fbaabf624..cfe88cc65a52 100644
=2D-- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1359,7 +1359,7 @@ struct super_block {
=20
 	const struct fscrypt_operations	*s_cop;
=20
=2D	struct hlist_bl_head	s_anon;		/* anonymous dentries for (nfs) exporting=
 */
+	struct hlist_bl_head	s_roots;	/* alternate root dentries for NFS */
 	struct list_head	s_mounts;	/* list of mounts; _not_ for fs use */
 	struct block_device	*s_bdev;
 	struct backing_dev_info *s_bdi;
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlo66BUACgkQOeye3VZi
gbn+PRAAiqzVRw4jGeFMDpFh7KstL0wQYRcV3fzuXjWLg2iL8sel62gZJW2Km8BG
k23fsFHbXRLuC34UhF0SneCyyJBObSon1uoidMXccgy6N0JeDq7j7rGDNcigeSwj
gT6B/GJG3jjbydO1u2911mHuexC0dvbpiQnyCCYZ1OheIKskcvavWyrfoBpHhn3a
3jv4DjkOdLsxoXVwk4SsQ7wx7sxJIHFvI3pqQqOpBuFkjKzdJEe+y/AfxTO4INGu
0zgrrY/zEmD8ZmgvE0hTD9PjfAfrq/gwHd+vNXPwk9pvQpIq9Rsh9rCEm/ShJgrc
t62mwwr+8SkQNa0E/LCezpToLahqAa3z8hEfIBf9hZwHuxAjAyC/tfwCYt58zzia
WGA99q5TXM5UNVeCTvE7+yJJf25zn9+SFUPQW0/O8gALhDX261SvGp91fFLuOSvm
RyUcZ5B8ZWyKFdtlWdwvZ4FU+OyXYCKhCCvGt3kplcmR/+G2b1RAFM4Ytxmp2etQ
UdtTTLwbTY+cJVEKD9XL794Ij+CcU+HMZMesE+sQEvHQkTCom4j6KStyCpoZMqK6
l294WEezm0s8/jmWGiwoTISk380jc3W0gjjZT1e5EWsoAz2y4NqQq789AxV9lHpA
pMV8CpATk4oF2boQ8S2d07sOoe+E9mg4ky04DSte1y0Rrl6VwlE=
=ngYI
-----END PGP SIGNATURE-----
--=-=-=--

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f46.google.com ([209.85.128.46]:55804 "EHLO
	mail-qe0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935480Ab3BTQTM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Feb 2013 11:19:12 -0500
Received: by mail-qe0-f46.google.com with SMTP id 1so3706704qec.5
        for <linux-nfs@vger.kernel.org>; Wed, 20 Feb 2013 08:19:11 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk, trond.myklebust@netapp.com
Cc: neilb@suse.de, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH v1] vfs: kill FS_REVAL_DOT by adding a d_reval_jumped dentry op
Date: Wed, 20 Feb 2013 11:19:05 -0500
Message-Id: <1361377145-28094-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following set of operations on a NFS client and server will cause

    server# mkdir a
    client# cd a
    server# mv a a.bak
    client# sleep 30  # (or whatever the dir attrcache timeout is)
    client# stat .
    stat: cannot stat ‘.’: Stale NFS file handle

Obviously, we should not be getting an ESTALE error back there since the
inode still exists on the server. The problem is that the lookup code
will call d_revalidate on the dentry that "." refers to, because NFS has
FS_REVAL_DOT set.

nfs_lookup_revalidate will see that the parent directory has changed and
will try to reverify the dentry by redoing a LOOKUP. That of course
fails, so the lookup code returns ESTALE.

The problem here is that d_revalidate is really a bad fit for this case.
What we really want to know at this point is whether the inode is still
good or not, but we don't really care what name it goes by or whether
the dcache is still valid.

Add a new d_op->d_reval_jumped operation and have complete_walk call
that instead of d_revalidate. The intent there is to allow for a
"weaker" d_revalidate that just checks to see whether the inode is still
good. This is also gives us an opportunity to kill off the FS_REVAL_DOT
special casing.

In a perfect world, this would be a new inode operation instead, but
I don't see a way to cleanly handle that for 9p, which needs a
dentry in order to get a fid.

Cc: NeilBrown <neilb@suse.de>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 Documentation/filesystems/Locking |  2 ++
 Documentation/filesystems/vfs.txt | 32 ++++++++++++++++++++++++++--
 fs/9p/vfs_dentry.c                |  1 +
 fs/9p/vfs_super.c                 |  2 +-
 fs/dcache.c                       |  3 +++
 fs/namei.c                        |  8 ++-----
 fs/nfs/dir.c                      | 45 +++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4super.c                |  6 +++---
 fs/nfs/super.c                    |  6 +++---
 include/linux/dcache.h            |  3 +++
 include/linux/fs.h                |  1 -
 11 files changed, 93 insertions(+), 16 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index f48e0c6..9718b667 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -10,6 +10,7 @@ be able to use diff(1).
 --------------------------- dentry_operations --------------------------
 prototypes:
 	int (*d_revalidate)(struct dentry *, unsigned int);
+	int (*d_reval_jumped)(struct dentry *, unsigned int);
 	int (*d_hash)(const struct dentry *, const struct inode *,
 			struct qstr *);
 	int (*d_compare)(const struct dentry *, const struct inode *,
@@ -25,6 +26,7 @@ prototypes:
 locking rules:
 		rename_lock	->d_lock	may block	rcu-walk
 d_revalidate:	no		no		yes (ref-walk)	maybe
+d_reval_jumped:	no		no		yes (ref-walk)	maybe
 d_hash		no		no		no		maybe
 d_compare:	yes		no		no		maybe
 d_delete:	no		yes		no		no
diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index e3869098..93c7380 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -900,6 +900,7 @@ defined:
 
 struct dentry_operations {
 	int (*d_revalidate)(struct dentry *, unsigned int);
+	int (*d_reval_jumped)(struct dentry *, unsigned int);
 	int (*d_hash)(const struct dentry *, const struct inode *,
 			struct qstr *);
 	int (*d_compare)(const struct dentry *, const struct inode *,
@@ -915,8 +916,13 @@ struct dentry_operations {
 
   d_revalidate: called when the VFS needs to revalidate a dentry. This
 	is called whenever a name look-up finds a dentry in the
-	dcache. Most filesystems leave this as NULL, because all their
-	dentries in the dcache are valid
+	dcache. Most local filesystems leave this as NULL, because all their
+	dentries in the dcache are valid. Network filesystems are different
+	since things can change on the server without the client necessarily
+	being aware of it.
+
+	This function should return a positive value if the dentry is still
+	valid, and zero or a negative error code if it isn't.
 
 	d_revalidate may be called in rcu-walk mode (flags & LOOKUP_RCU).
 	If in rcu-walk mode, the filesystem must revalidate the dentry without
@@ -927,6 +933,28 @@ struct dentry_operations {
 	If a situation is encountered that rcu-walk cannot handle, return
 	-ECHILD and it will be called again in ref-walk mode.
 
+ d_reval_jumped: called when the VFS needs to revalidate a "jumped" dentry.
+	This is called during a path-walk whenever we reach a dentry that was
+	not acquired by doing a lookup in the parent directory. This includes
+	"/", "." and "..", as well as procfs-style symlinks and mountpoint
+	traversal.
+
+	In this case, we are less concerned with whether the dentry is still
+	fully correct, but rather that the inode is still valid. As with
+	d_revalidate, most local filesystems will set this to NULL since their
+	dcache entries are always valid.
+
+	This function has the same return code semantics as d_revalidate.
+
+	d_reval_jumped may be called in rcu-walk mode (flags & LOOKUP_RCU).
+	If in rcu-walk mode, the filesystem must revalidate the dentry without
+	blocking or storing to the dentry, d_parent and d_inode should not be
+	used without care (because they can change and, in d_inode case, even
+	become NULL under us).
+
+	If a situation is encountered that rcu-walk cannot handle, return
+	-ECHILD and it will be called again in ref-walk mode.
+
   d_hash: called when the VFS adds a dentry to the hash table. The first
 	dentry passed to d_hash is the parent directory that the name is
 	to be hashed into. The inode is the dentry's inode.
diff --git a/fs/9p/vfs_dentry.c b/fs/9p/vfs_dentry.c
index 64600b5..e02a754 100644
--- a/fs/9p/vfs_dentry.c
+++ b/fs/9p/vfs_dentry.c
@@ -137,6 +137,7 @@ out_valid:
 
 const struct dentry_operations v9fs_cached_dentry_operations = {
 	.d_revalidate = v9fs_lookup_revalidate,
+	.d_reval_jumped = v9fs_lookup_revalidate,
 	.d_delete = v9fs_cached_dentry_delete,
 	.d_release = v9fs_dentry_release,
 };
diff --git a/fs/9p/vfs_super.c b/fs/9p/vfs_super.c
index 137d503..91dad63 100644
--- a/fs/9p/vfs_super.c
+++ b/fs/9p/vfs_super.c
@@ -363,5 +363,5 @@ struct file_system_type v9fs_fs_type = {
 	.mount = v9fs_mount,
 	.kill_sb = v9fs_kill_super,
 	.owner = THIS_MODULE,
-	.fs_flags = FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT,
+	.fs_flags = FS_RENAME_DOES_D_MOVE,
 };
diff --git a/fs/dcache.c b/fs/dcache.c
index ada6123..6a409ab 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1358,6 +1358,7 @@ void d_set_d_op(struct dentry *dentry, const struct dentry_operations *op)
 	WARN_ON_ONCE(dentry->d_flags & (DCACHE_OP_HASH	|
 				DCACHE_OP_COMPARE	|
 				DCACHE_OP_REVALIDATE	|
+				DCACHE_OP_REVAL_JUMPED	|
 				DCACHE_OP_DELETE ));
 	dentry->d_op = op;
 	if (!op)
@@ -1368,6 +1369,8 @@ void d_set_d_op(struct dentry *dentry, const struct dentry_operations *op)
 		dentry->d_flags |= DCACHE_OP_COMPARE;
 	if (op->d_revalidate)
 		dentry->d_flags |= DCACHE_OP_REVALIDATE;
+	if (op->d_reval_jumped)
+		dentry->d_flags |= DCACHE_OP_REVAL_JUMPED;
 	if (op->d_delete)
 		dentry->d_flags |= DCACHE_OP_DELETE;
 	if (op->d_prune)
diff --git a/fs/namei.c b/fs/namei.c
index 31bf225..ab94232 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -600,14 +600,10 @@ static int complete_walk(struct nameidata *nd)
 	if (likely(!(nd->flags & LOOKUP_JUMPED)))
 		return 0;
 
-	if (likely(!(dentry->d_flags & DCACHE_OP_REVALIDATE)))
+	if (likely(!(dentry->d_flags & DCACHE_OP_REVAL_JUMPED)))
 		return 0;
 
-	if (likely(!(dentry->d_sb->s_type->fs_flags & FS_REVAL_DOT)))
-		return 0;
-
-	/* Note: we do not d_invalidate() */
-	status = d_revalidate(dentry, nd->flags);
+	status = dentry->d_op->d_reval_jumped(dentry, nd->flags);
 	if (status > 0)
 		return 0;
 
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index a8bd28c..1d88b77 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1136,6 +1136,50 @@ out_error:
 }
 
 /*
+ * A weaker form of d_revalidate for revalidating just the dentry->d_inode
+ * when we don't really care about the dentry name. This is called when a
+ * pathwalk ends on a dentry that was not found via a normal lookup in the
+ * parent dir (e.g.: ".", "..", procfs symlinks or mountpoint traversals).
+ *
+ * In this situation, we just want to verify that the inode itself is OK
+ * since the dentry might have changed on the server.
+ */
+static int nfs_reval_jumped(struct dentry *dentry, unsigned int flags)
+{
+	int error;
+	struct inode *inode = dentry->d_inode;
+
+	if (flags & LOOKUP_RCU)
+		return -ECHILD;
+
+	/*
+	 * I believe we can only get a negative dentry here in the case of a
+	 * procfs-style symlink. Just assume it's correct for now, but we may
+	 * eventually need to do something more here.
+	 */
+	if (!inode) {
+		dfprintk(LOOKUPCACHE, "%s: %s/%s has negative inode\n",
+				__func__, dentry->d_parent->d_name.name,
+				dentry->d_name.name);
+		return 1;
+	}
+
+	if (is_bad_inode(inode)) {
+		dfprintk(LOOKUPCACHE, "%s: %s/%s has dud inode\n",
+				__func__, dentry->d_parent->d_name.name,
+				dentry->d_name.name);
+		return 0;
+	}
+
+	error = nfs_revalidate_inode(NFS_SERVER(inode), inode);
+	dfprintk(LOOKUPCACHE, "NFS: %s: inode %lu is %s\n",
+			__func__, inode->i_ino, error ? "invalid" : "valid");
+	if (error)
+		return 0;
+	return 1;
+}
+
+/*
  * This is called from dput() when d_count is going to 0.
  */
 static int nfs_dentry_delete(const struct dentry *dentry)
@@ -1202,6 +1246,7 @@ static void nfs_d_release(struct dentry *dentry)
 
 const struct dentry_operations nfs_dentry_operations = {
 	.d_revalidate	= nfs_lookup_revalidate,
+	.d_reval_jumped	= nfs_reval_jumped,
 	.d_delete	= nfs_dentry_delete,
 	.d_iput		= nfs_dentry_iput,
 	.d_automount	= nfs_d_automount,
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 84d2e9e..569b166 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -28,7 +28,7 @@ static struct file_system_type nfs4_remote_fs_type = {
 	.name		= "nfs4",
 	.mount		= nfs4_remote_mount,
 	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
 };
 
 static struct file_system_type nfs4_remote_referral_fs_type = {
@@ -36,7 +36,7 @@ static struct file_system_type nfs4_remote_referral_fs_type = {
 	.name		= "nfs4",
 	.mount		= nfs4_remote_referral_mount,
 	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
 };
 
 struct file_system_type nfs4_referral_fs_type = {
@@ -44,7 +44,7 @@ struct file_system_type nfs4_referral_fs_type = {
 	.name		= "nfs4",
 	.mount		= nfs4_referral_mount,
 	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
 };
 
 static const struct super_operations nfs4_sops = {
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 939b9f0..aee63bd 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -292,7 +292,7 @@ struct file_system_type nfs_fs_type = {
 	.name		= "nfs",
 	.mount		= nfs_fs_mount,
 	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
 };
 EXPORT_SYMBOL_GPL(nfs_fs_type);
 
@@ -301,7 +301,7 @@ struct file_system_type nfs_xdev_fs_type = {
 	.name		= "nfs",
 	.mount		= nfs_xdev_mount,
 	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
 };
 
 const struct super_operations nfs_sops = {
@@ -331,7 +331,7 @@ struct file_system_type nfs4_fs_type = {
 	.name		= "nfs4",
 	.mount		= nfs_fs_mount,
 	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
 };
 EXPORT_SYMBOL_GPL(nfs4_fs_type);
 
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index 03d1692..a80b7bc 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -145,6 +145,7 @@ enum dentry_d_lock_class
 
 struct dentry_operations {
 	int (*d_revalidate)(struct dentry *, unsigned int);
+	int (*d_reval_jumped)(struct dentry *, unsigned int);
 	int (*d_hash)(const struct dentry *, const struct inode *,
 			struct qstr *);
 	int (*d_compare)(const struct dentry *, const struct inode *,
@@ -192,6 +193,8 @@ struct dentry_operations {
 #define DCACHE_GENOCIDE		0x0200
 #define DCACHE_SHRINK_LIST	0x0400
 
+#define DCACHE_OP_REVAL_JUMPED	0x0800
+
 #define DCACHE_NFSFS_RENAMED	0x1000
      /* this dentry has been "silly renamed" and has to be deleted on the last
       * dput() */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 19be991..c766afd 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1806,7 +1806,6 @@ struct file_system_type {
 #define FS_HAS_SUBTYPE		4
 #define FS_USERNS_MOUNT		8	/* Can be mounted by userns root */
 #define FS_USERNS_DEV_MOUNT	16 /* A userns mount does not imply MNT_NODEV */
-#define FS_REVAL_DOT		16384	/* Check the paths ".", ".." for staleness */
 #define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move() during rename() internally. */
 	struct dentry *(*mount) (struct file_system_type *, int,
 		       const char *, void *);
-- 
1.7.11.7


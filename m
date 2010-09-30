Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7154 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755002Ab0I3SPs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 14:15:48 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 01/17] Add a dentry op to handle automounting rather than
	abusing follow_link()
To: viro@ftp.linux.org.uk, jmoyer@redhat.com
Cc: linux-fs@vger.kernel.org, autofs@linux.kernel.org,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        David Howells <dhowells@redhat.com>, Ian Kent <raven@themaw.net>
Date: Thu, 30 Sep 2010 19:15:00 +0100
Message-ID: <20100930181500.30939.27727.stgit@warthog.procyon.org.uk>
In-Reply-To: <20100930181455.30939.53914.stgit@warthog.procyon.org.uk>
References: <20100930181455.30939.53914.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Add a dentry op (d_automount) to handle automounting directories rather than
abusing the follow_link() inode operation.  The operation is keyed off a new
inode flag (S_AUTOMOUNT).

This makes it easier to add an AT_ flag to suppress terminal segment automount
during pathwalk.  It should also remove the need for the kludge code in the
pathwalk algorithm to handle directories with follow_link() semantics.

A new pathwalk subroutine, follow_automount() is added to handle mountpoints.
It will return -EREMOTE if the S_AUTOMOUNT was set, but no d_automount() op was
supplied, -ELOOP if we've encountered too many symlinks or mountpoints, -EISDIR
if the walk point should be used without mounting and 0 if successful.  path
will be updated if an automount took place to point to the mounted filesystem.

I've only changed __follow_mount() to handle call follow_automount(), but it
might be necessary to change follow_mount() too.  The latter is only called
from follow_dotdot(), but any automounts on ".." should be pinned whilst we're
using a child of it.

I've also extracted the mount/don't-mount logic from autofs4 and included it
here.  It makes the mount go ahead anyway if someone calls open() or creat(),
tries to traverse the directory, tries to chdir/chroot/etc. into the directory,
or sticks a '/' on the end of the pathname.  If they do a stat(), however,
they'll only trigger the automount if they didn't also say O_NOFOLLOW.

Signed-off-by: David Howells <dhowells@redhat.com>
Acked-by: Ian Kent <raven@themaw.net>
---

 Documentation/filesystems/Locking |    2 +
 Documentation/filesystems/vfs.txt |   13 +++++
 fs/namei.c                        |  101 ++++++++++++++++++++++++++++++-------
 include/linux/dcache.h            |    5 ++
 include/linux/fs.h                |    2 +
 5 files changed, 104 insertions(+), 19 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index 2db4283..35fd21c 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -16,6 +16,7 @@ prototypes:
 	void (*d_release)(struct dentry *);
 	void (*d_iput)(struct dentry *, struct inode *);
 	char *(*d_dname)((struct dentry *dentry, char *buffer, int buflen);
+	struct vfsmount *(*d_automount)(struct path *path);
 
 locking rules:
 	none have BKL
@@ -27,6 +28,7 @@ d_delete:	yes		no		yes		no
 d_release:	no		no		no		yes
 d_iput:		no		no		no		yes
 d_dname:	no		no		no		no
+d_automount:	no		no		no		yes
 
 --------------------------- inode_operations --------------------------- 
 prototypes:
diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index ed7e5ef..ff4bf82 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -847,6 +847,7 @@ struct dentry_operations {
 	void (*d_release)(struct dentry *);
 	void (*d_iput)(struct dentry *, struct inode *);
 	char *(*d_dname)(struct dentry *, char *, int);
+	struct vfsmount *(*d_automount)(struct path *);
 };
 
   d_revalidate: called when the VFS needs to revalidate a dentry. This
@@ -881,6 +882,18 @@ struct dentry_operations {
 	at the end of the buffer, and returns a pointer to the first char.
 	dynamic_dname() helper function is provided to take care of this.
 
+  d_automount: called when an automount dentry is to be traversed (optional).
+	This should create a new VFS mount record, mount it on the directory
+	and return the record to the caller.  The caller is supplied with a
+	path parameter giving the automount directory to describe the automount
+	target and the parent VFS mount record to provide inheritable mount
+	parameters.  NULL should be returned if someone else managed to make
+	the automount first.  If the automount failed, then an error code
+	should be returned.
+
+	This function is only used if S_AUTOMOUNT is set on the inode to which
+	the dentry refers.
+
 Example :
 
 static char *pipefs_dname(struct dentry *dent, char *buffer, int buflen)
diff --git a/fs/namei.c b/fs/namei.c
index 24896e8..c50b9d7 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -612,24 +612,85 @@ int follow_up(struct path *path)
 	return 1;
 }
 
+/*
+ * Perform an automount
+ * - return -EISDIR to tell __follow_mount() to stop and return the path we
+ *   were called with.
+ */
+static int follow_automount(struct path *path, unsigned flags,
+			    bool *need_mntput)
+{
+	struct vfsmount *mnt;
+
+	if (!path->dentry->d_op || !path->dentry->d_op->d_automount)
+		return -EREMOTE;
+
+	/* We want to mount if someone is trying to open/create a file of any
+	 * type under the mountpoint, wants to traverse through the mountpoint
+	 * or wants to open the mounted directory.
+	 *
+	 * We don't want to mount if someone's just doing a stat and they've
+	 * set AT_SYMLINK_NOFOLLOW - unless they're stat'ing a directory and
+	 * appended a '/' to the name.
+	 */
+	if (!(flags & LOOKUP_FOLLOW) &&
+	    !(flags & (LOOKUP_CONTINUE | LOOKUP_DIRECTORY |
+		       LOOKUP_OPEN | LOOKUP_CREATE)))
+		return -EISDIR;
+
+	current->total_link_count++;
+	if (current->total_link_count >= 40)
+		return -ELOOP;
+
+	mnt = path->dentry->d_op->d_automount(path);
+	if (IS_ERR(mnt))
+		return PTR_ERR(mnt);
+	if (!mnt) /* mount collision */
+		return 0;
+
+	if (mnt->mnt_sb == path->mnt->mnt_sb &&
+	    mnt->mnt_root == path->dentry) {
+		mntput(mnt);
+		return -ELOOP;
+	}
+
+	dput(path->dentry);
+	if (*need_mntput)
+		mntput(path->mnt);
+	path->mnt = mnt;
+	path->dentry = dget(mnt->mnt_root);
+	*need_mntput = true;
+	return 0;
+}
+
 /* no need for dcache_lock, as serialization is taken care in
  * namespace.c
  */
-static int __follow_mount(struct path *path)
+static int __follow_mount(struct path *path, unsigned flags)
 {
-	int res = 0;
-	while (d_mountpoint(path->dentry)) {
-		struct vfsmount *mounted = lookup_mnt(path);
-		if (!mounted)
+	struct vfsmount *mounted;
+	bool need_mntput = false;
+	int ret;
+
+	for (;;) {
+		while (d_mountpoint(path->dentry)) {
+			mounted = lookup_mnt(path);
+			if (!mounted)
+				break;
+			dput(path->dentry);
+			if (need_mntput)
+				mntput(path->mnt);
+			path->mnt = mounted;
+			path->dentry = dget(mounted->mnt_root);
+			need_mntput = true;
+		}
+		if (!d_automount_point(path->dentry))
 			break;
-		dput(path->dentry);
-		if (res)
-			mntput(path->mnt);
-		path->mnt = mounted;
-		path->dentry = dget(mounted->mnt_root);
-		res = 1;
+		ret = follow_automount(path, flags, &need_mntput);
+		if (ret < 0)
+			return ret == -EISDIR ? 0 : ret;
 	}
-	return res;
+	return 0;
 }
 
 static void follow_mount(struct path *path)
@@ -726,6 +787,8 @@ static int do_lookup(struct nameidata *nd, struct qstr *name,
 	struct vfsmount *mnt = nd->path.mnt;
 	struct dentry *dentry, *parent;
 	struct inode *dir;
+	int ret;
+
 	/*
 	 * See if the low-level filesystem might want
 	 * to use its own hash..
@@ -750,8 +813,10 @@ found:
 done:
 	path->mnt = mnt;
 	path->dentry = dentry;
-	__follow_mount(path);
-	return 0;
+	ret = __follow_mount(path, nd->flags);
+	if (unlikely(ret < 0))
+		path_put_conditional(path, nd);
+	return ret;
 
 need_lookup:
 	parent = nd->path.dentry;
@@ -1701,11 +1766,9 @@ static struct file *do_last(struct nameidata *nd, struct path *path,
 	if (open_flag & O_EXCL)
 		goto exit_dput;
 
-	if (__follow_mount(path)) {
-		error = -ELOOP;
-		if (open_flag & O_NOFOLLOW)
-			goto exit_dput;
-	}
+	error = __follow_mount(path, nd->flags);
+	if (error < 0)
+		goto exit_dput;
 
 	error = -ENOENT;
 	if (!path->dentry->d_inode)
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index 6a4aea3..ab62055 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -139,6 +139,7 @@ struct dentry_operations {
 	void (*d_release)(struct dentry *);
 	void (*d_iput)(struct dentry *, struct inode *);
 	char *(*d_dname)(struct dentry *, char *, int);
+	struct vfsmount *(*d_automount)(struct path *);
 };
 
 /* the dentry parameter passed to d_hash and d_compare is the parent
@@ -157,6 +158,7 @@ d_compare:	no		yes		yes      no
 d_delete:	no		yes		no       no
 d_release:	no		no		no       yes
 d_iput:		no		no		no       yes
+d_automount:	no		no		no	 yes
  */
 
 /* d_flags entries */
@@ -391,6 +393,9 @@ static inline int d_mountpoint(struct dentry *dentry)
 	return dentry->d_mounted;
 }
 
+#define d_automount_point(dentry) \
+	(dentry->d_inode && IS_AUTOMOUNT(dentry->d_inode))
+
 extern struct vfsmount *lookup_mnt(struct path *);
 extern struct dentry *lookup_create(struct nameidata *nd, int is_dir);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 63d069b..29ef320 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -235,6 +235,7 @@ struct inodes_stat_t {
 #define S_NOCMTIME	128	/* Do not update file c/mtime */
 #define S_SWAPFILE	256	/* Do not truncate: swapon got its bmaps */
 #define S_PRIVATE	512	/* Inode is fs-internal */
+#define S_AUTOMOUNT	1024	/* Automount/referral quasi-directory */
 
 /*
  * Note that nosuid etc flags are inode-specific: setting some file-system
@@ -269,6 +270,7 @@ struct inodes_stat_t {
 #define IS_NOCMTIME(inode)	((inode)->i_flags & S_NOCMTIME)
 #define IS_SWAPFILE(inode)	((inode)->i_flags & S_SWAPFILE)
 #define IS_PRIVATE(inode)	((inode)->i_flags & S_PRIVATE)
+#define IS_AUTOMOUNT(inode)	((inode)->i_flags & S_AUTOMOUNT)
 
 /* the read-only stuff doesn't really belong here, but any other place is
    probably as bad and I don't want to create yet another include file. */


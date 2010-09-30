Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5975 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932094Ab0I3SQC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 14:16:02 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 07/17] Make dentry::d_mounted into a more general field for
	special function dirs
To: viro@ftp.linux.org.uk, jmoyer@redhat.com
Cc: linux-fs@vger.kernel.org, autofs@linux.kernel.org,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        David Howells <dhowells@redhat.com>, Ian Kent <raven@themaw.net>
Date: Thu, 30 Sep 2010 19:15:31 +0100
Message-ID: <20100930181531.30939.10438.stgit@warthog.procyon.org.uk>
In-Reply-To: <20100930181455.30939.53914.stgit@warthog.procyon.org.uk>
References: <20100930181455.30939.53914.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Make the d_mounted field in struct dentry into a more general field for special
function directories such as mountpoints and autofs substructures.

d_mounted is renamed d_managed, and that is split into three fields:

 (*) #define DMANAGED_MOUNTPOINT	0x0fffffff

     This is the mounted-on-this-dentry count as per d_mounted.

 (*) #define DMANAGED_AUTOMOUNT	0x10000000

     This is a reflection of the S_AUTOMOUNT inode flag.  This is reflected by
     __d_instantiate().  follow_automount() is now keyed off of this rather
     than being keyed off S_AUTOMOUNT directly.  Possibly S_AUTOMOUNT should
     shift to the dentry entirely.

 (*) #define DMANAGED_TRANSIT	0x20000000

     This is an indicator that the filesystem that owns the dentry wants to
     manage processes transiting away from that dentry.  If this is set on a
     dentry, then a new dentry op:

		int (*d_manage)(struct path *);

     is invoked.  This is allowed to sleep and is allowed to return an error.

     This allows autofs to hold non-Oz-mode processes here without any
     filesystem locks being held.

Since d_managed is just an integer, all three fields can be tested in one go,
reducing the amount of intrusion into the normal path.  __follow_mount() is
replaced by managed_dentry() which now handles transit to a mountpoint's root
dentry, automount points and points that the filesystem wants to manage.


==========================
WHAT THIS MEANS FOR AUTOFS
==========================

autofs currently uses the lookup() inode op and the d_revalidate() dentry op to
trigger the automounting of indirect mounts, and both of these can be called
with i_mutex held.

autofs knows that the i_mutex will be held by the caller in lookup(), and so
can drop it before invoking the daemon - but this isn't so for d_revalidate(),
since the lock is only held on _some_ of the code paths that call it.  This
means that autofs can't risk dropping i_mutex from its d_revalidate() function
before it calls the daemon.

The bug could manifest itself as, for example, a process that's trying to
validate an automount dentry that gets made to wait because that dentry is
expired and needs cleaning up:

	mkdir         S ffffffff8014e05a     0 32580  24956
	Call Trace:
	 [<ffffffff885371fd>] :autofs4:autofs4_wait+0x674/0x897
	 [<ffffffff80127f7d>] avc_has_perm+0x46/0x58
	 [<ffffffff8009fdcf>] autoremove_wake_function+0x0/0x2e
	 [<ffffffff88537be6>] :autofs4:autofs4_expire_wait+0x41/0x6b
	 [<ffffffff88535cfc>] :autofs4:autofs4_revalidate+0x91/0x149
	 [<ffffffff80036d96>] __lookup_hash+0xa0/0x12f
	 [<ffffffff80057a2f>] lookup_create+0x46/0x80
	 [<ffffffff800e6e31>] sys_mkdirat+0x56/0xe4

versus the automount daemon which wants to remove that dentry, but can't
because the normal process is holding the i_mutex lock:

	automount     D ffffffff8014e05a     0 32581      1              32561
	Call Trace:
	 [<ffffffff80063c3f>] __mutex_lock_slowpath+0x60/0x9b
	 [<ffffffff8000ccf1>] do_path_lookup+0x2ca/0x2f1
	 [<ffffffff80063c89>] .text.lock.mutex+0xf/0x14
	 [<ffffffff800e6d55>] do_rmdir+0x77/0xde
	 [<ffffffff8005d229>] tracesys+0x71/0xe0
	 [<ffffffff8005d28d>] tracesys+0xd5/0xe0

which means that the system is deadlocked.

This patch allows autofs to hold up normal processes whilst the daemon goes
ahead and does things to the dentry tree behind the automouter point without
risking a deadlock as no locks are held in d_manage() or d_automount().

Signed-off-by: David Howells <dhowells@redhat.com>
Acked-by: Ian Kent <raven@themaw.net>
---

 Documentation/filesystems/vfs.txt |   13 +++-
 fs/autofs4/expire.c               |    4 +
 fs/dcache.c                       |    7 ++
 fs/namei.c                        |  118 +++++++++++++++++++++++++------------
 fs/namespace.c                    |    6 +-
 include/linux/dcache.h            |   15 +++--
 6 files changed, 110 insertions(+), 53 deletions(-)

diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index ff4bf82..fc27e43 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -848,6 +848,7 @@ struct dentry_operations {
 	void (*d_iput)(struct dentry *, struct inode *);
 	char *(*d_dname)(struct dentry *, char *, int);
 	struct vfsmount *(*d_automount)(struct path *);
+	int (*d_manage)(struct path *);
 };
 
   d_revalidate: called when the VFS needs to revalidate a dentry. This
@@ -891,8 +892,16 @@ struct dentry_operations {
 	the automount first.  If the automount failed, then an error code
 	should be returned.
 
-	This function is only used if S_AUTOMOUNT is set on the inode to which
-	the dentry refers.
+	This function is only used if DMANAGED_AUTOMOUNT is set on the dentry.
+	This is set by d_add() if S_AUTOMOUNT is set on the inode being added.
+
+  d_manage: called to allow the filesystem to manage the transition from a
+	dentry (optional).  This allows autofs, for example, to hold up clients
+	waiting to explore behind a 'mountpoint', whilst letting the daemon go
+	past and construct the subtree there.
+
+	This function is only used if DMANAGED_TRANSIT is set on the dentry
+	being transited from.
 
 Example :
 
diff --git a/fs/autofs4/expire.c b/fs/autofs4/expire.c
index a796c94..9f5bde2 100644
--- a/fs/autofs4/expire.c
+++ b/fs/autofs4/expire.c
@@ -276,7 +276,7 @@ struct dentry *autofs4_expire_direct(struct super_block *sb,
 		struct autofs_info *ino = autofs4_dentry_ino(root);
 		if (d_mountpoint(root)) {
 			ino->flags |= AUTOFS_INF_MOUNTPOINT;
-			root->d_mounted--;
+			root->d_managed--;
 		}
 		ino->flags |= AUTOFS_INF_EXPIRING;
 		init_completion(&ino->expire_complete);
@@ -499,7 +499,7 @@ int autofs4_do_expire_multi(struct super_block *sb, struct vfsmount *mnt,
 
 		spin_lock(&sbi->fs_lock);
 		if (ino->flags & AUTOFS_INF_MOUNTPOINT) {
-			sb->s_root->d_mounted++;
+			sb->s_root->d_managed++;
 			ino->flags &= ~AUTOFS_INF_MOUNTPOINT;
 		}
 		ino->flags &= ~AUTOFS_INF_EXPIRING;
diff --git a/fs/dcache.c b/fs/dcache.c
index 83293be..35e5a54 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -956,7 +956,7 @@ struct dentry *d_alloc(struct dentry * parent, const struct qstr *name)
 	dentry->d_sb = NULL;
 	dentry->d_op = NULL;
 	dentry->d_fsdata = NULL;
-	dentry->d_mounted = 0;
+	dentry->d_managed = 0;
 	INIT_HLIST_NODE(&dentry->d_hash);
 	INIT_LIST_HEAD(&dentry->d_lru);
 	INIT_LIST_HEAD(&dentry->d_subdirs);
@@ -993,8 +993,11 @@ EXPORT_SYMBOL(d_alloc_name);
 /* the caller must hold dcache_lock */
 static void __d_instantiate(struct dentry *dentry, struct inode *inode)
 {
-	if (inode)
+	if (inode) {
 		list_add(&dentry->d_alias, &inode->i_dentry);
+		if (IS_AUTOMOUNT(inode))
+			dentry->d_managed |= DMANAGED_AUTOMOUNT;
+	}
 	dentry->d_inode = inode;
 	fsnotify_d_instantiate(dentry, inode);
 }
diff --git a/fs/namei.c b/fs/namei.c
index 74bce3a..1bbd2d4 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -614,7 +614,7 @@ int follow_up(struct path *path)
 
 /*
  * Perform an automount
- * - return -EISDIR to tell __follow_mount() to stop and return the path we
+ * - return -EISDIR to tell managed_dentry() to stop and return the path we
  *   were called with.
  */
 static int follow_automount(struct path *path, unsigned flags,
@@ -629,7 +629,7 @@ static int follow_automount(struct path *path, unsigned flags,
 	 * and this is the terminal part of the path.
 	 */
 	if ((flags & LOOKUP_NO_AUTOMOUNT) && !(flags & LOOKUP_CONTINUE))
-		return -EXDEV; /* we actually want to stop here */
+		return -EISDIR; /* we actually want to stop here */
 
 	/* We want to mount if someone is trying to open/create a file of any
 	 * type under the mountpoint, wants to traverse through the mountpoint
@@ -649,8 +649,20 @@ static int follow_automount(struct path *path, unsigned flags,
 		return -ELOOP;
 
 	mnt = path->dentry->d_op->d_automount(path);
-	if (IS_ERR(mnt))
+	if (IS_ERR(mnt)) {
+		/*
+		 * The filesystem is allowed to return -EISDIR here to indicate
+		 * it doesn't want to automount.  For instance, autofs would do
+		 * this so that its userspace daemon can mount on this dentry.
+		 *
+		 * However, we can only permit this if it's a terminal point in
+		 * the path being looked up; if it wasn't then the remainder of
+		 * the path is inaccessible and we should say so.
+		 */
+		if (PTR_ERR(mnt) == -EISDIR && (flags & LOOKUP_CONTINUE))
+			return -EREMOTE;
 		return PTR_ERR(mnt);
+	}
 	if (!mnt) /* mount collision */
 		return 0;
 
@@ -669,47 +681,61 @@ static int follow_automount(struct path *path, unsigned flags,
 	return 0;
 }
 
-/* no need for dcache_lock, as serialization is taken care in
- * namespace.c
+/*
+ * Handle a dentry that is managed in some way.
+ * - Flagged for transit management (autofs)
+ * - Flagged as mountpoint
+ * - Flagged as automount point
  */
-static int __follow_mount(struct path *path, unsigned flags)
+static int managed_dentry(struct path *path, unsigned flags)
 {
-	struct vfsmount *mounted;
+	unsigned d_managed;
 	bool need_mntput = false;
 	int ret;
 
-	for (;;) {
-		while (d_mountpoint(path->dentry)) {
-			mounted = lookup_mnt(path);
-			if (!mounted)
-				break;
-			dput(path->dentry);
-			if (need_mntput)
-				mntput(path->mnt);
-			path->mnt = mounted;
-			path->dentry = dget(mounted->mnt_root);
-			need_mntput = true;
+	while (d_managed = path->dentry->d_managed,
+	       unlikely(d_managed != 0)) {
+		/* Allow the filesystem to manage the transit without i_mutex
+		 * being held. */
+		if (d_managed & DMANAGED_TRANSIT) {
+			BUG_ON(!path->dentry->d_op);
+			BUG_ON(!path->dentry->d_op->d_manage);
+			ret = path->dentry->d_op->d_manage(path);
+			if (ret < 0)
+				return ret;
 		}
-		if (!d_automount_point(path->dentry))
-			break;
-		ret = follow_automount(path, flags, &need_mntput);
-		if (ret < 0)
-			return ret == -EISDIR ? 0 : ret;
-	}
-	return 0;
-}
 
-static void follow_mount(struct path *path)
-{
-	while (d_mountpoint(path->dentry)) {
-		struct vfsmount *mounted = lookup_mnt(path);
-		if (!mounted)
-			break;
-		dput(path->dentry);
-		mntput(path->mnt);
-		path->mnt = mounted;
-		path->dentry = dget(mounted->mnt_root);
+		/* Transit to a mounted filesystem. */
+		if (d_managed & DMANAGED_MOUNTPOINT) {
+			struct vfsmount *mounted = lookup_mnt(path);
+			if (mounted) {
+				dput(path->dentry);
+				if (need_mntput)
+					mntput(path->mnt);
+				path->mnt = mounted;
+				path->dentry = dget(mounted->mnt_root);
+				need_mntput = true;
+				continue;
+			}
+
+			/* Something is mounted on this dentry in another
+			 * namespace and/or whatever was mounted there in this
+			 * namespace got unmounted before we managed to get the
+			 * vfsmount_lock */
+		}
+
+		/* Handle an automount point */
+		if (d_managed & DMANAGED_AUTOMOUNT) {
+			ret = follow_automount(path, flags, &need_mntput);
+			if (ret < 0)
+				return ret == -EISDIR ? 0 : ret;
+			continue;
+		}
+
+		/* We didn't change the current path point */
+		break;
 	}
+	return 0;
 }
 
 /* no need for dcache_lock, as serialization is taken care in
@@ -730,6 +756,22 @@ int follow_down(struct path *path)
 	return 0;
 }
 
+/*
+ * Skip to top of mountpoint pile for follow_dotdot().
+ */
+static void follow_mount(struct path *path)
+{
+	while (d_mountpoint(path->dentry)) {
+		struct vfsmount *mounted = lookup_mnt(path);
+		if (!mounted)
+			break;
+		dput(path->dentry);
+		mntput(path->mnt);
+		path->mnt = mounted;
+		path->dentry = dget(mounted->mnt_root);
+	}
+}
+
 static __always_inline void follow_dotdot(struct nameidata *nd)
 {
 	set_root(nd);
@@ -819,7 +861,7 @@ found:
 done:
 	path->mnt = mnt;
 	path->dentry = dentry;
-	ret = __follow_mount(path, nd->flags);
+	ret = managed_dentry(path, nd->flags);
 	if (unlikely(ret < 0))
 		path_put_conditional(path, nd);
 	return ret;
@@ -1762,7 +1804,7 @@ static struct file *do_last(struct nameidata *nd, struct path *path,
 	if (open_flag & O_EXCL)
 		goto exit_dput;
 
-	error = __follow_mount(path, nd->flags);
+	error = managed_dentry(path, nd->flags);
 	if (error < 0)
 		goto exit_dput;
 
diff --git a/fs/namespace.c b/fs/namespace.c
index a72eaab..e72b7b9 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -503,7 +503,7 @@ static void detach_mnt(struct vfsmount *mnt, struct path *old_path)
 	mnt->mnt_mountpoint = mnt->mnt_root;
 	list_del_init(&mnt->mnt_child);
 	list_del_init(&mnt->mnt_hash);
-	old_path->dentry->d_mounted--;
+	old_path->dentry->d_managed--;
 }
 
 /*
@@ -514,7 +514,7 @@ void mnt_set_mountpoint(struct vfsmount *mnt, struct dentry *dentry,
 {
 	child_mnt->mnt_parent = mntget(mnt);
 	child_mnt->mnt_mountpoint = dget(dentry);
-	dentry->d_mounted++;
+	dentry->d_managed++;
 }
 
 /*
@@ -1074,7 +1074,7 @@ void umount_tree(struct vfsmount *mnt, int propagate, struct list_head *kill)
 		list_del_init(&p->mnt_child);
 		if (p->mnt_parent != p) {
 			p->mnt_parent->mnt_ghosts++;
-			p->mnt_mountpoint->d_mounted--;
+			p->mnt_mountpoint->d_managed--;
 		}
 		change_mnt_propagation(p, MS_PRIVATE);
 	}
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index ab62055..2da5aa4 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -90,7 +90,11 @@ struct dentry {
 	atomic_t d_count;
 	unsigned int d_flags;		/* protected by d_lock */
 	spinlock_t d_lock;		/* per dentry lock */
-	int d_mounted;
+	unsigned d_managed;		/* >0 if we want to manage the
+					 * pathwalk at this point */
+#define DMANAGED_MOUNTPOINT	0x0fffffff /* mountpoint count */
+#define DMANAGED_AUTOMOUNT	0x10000000 /* handle automount flag */
+#define DMANAGED_TRANSIT	0x20000000 /* managed transit */
 	struct inode *d_inode;		/* Where the name belongs to - NULL is
 					 * negative */
 	/*
@@ -140,6 +144,7 @@ struct dentry_operations {
 	void (*d_iput)(struct dentry *, struct inode *);
 	char *(*d_dname)(struct dentry *, char *, int);
 	struct vfsmount *(*d_automount)(struct path *);
+	int (*d_manage)(struct path *);
 };
 
 /* the dentry parameter passed to d_hash and d_compare is the parent
@@ -159,6 +164,7 @@ d_delete:	no		yes		no       no
 d_release:	no		no		no       yes
 d_iput:		no		no		no       yes
 d_automount:	no		no		no	 yes
+d_manage:	no		no		no	 yes
  */
 
 /* d_flags entries */
@@ -388,14 +394,11 @@ static inline struct dentry *dget_parent(struct dentry *dentry)
 
 extern void dput(struct dentry *);
 
-static inline int d_mountpoint(struct dentry *dentry)
+static inline bool d_mountpoint(struct dentry *dentry)
 {
-	return dentry->d_mounted;
+	return (dentry->d_managed & DMANAGED_MOUNTPOINT) != 0;
 }
 
-#define d_automount_point(dentry) \
-	(dentry->d_inode && IS_AUTOMOUNT(dentry->d_inode))
-
 extern struct vfsmount *lookup_mnt(struct path *);
 extern struct dentry *lookup_create(struct nameidata *nd, int is_dir);
 


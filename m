Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36458 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758682AbdEVPxJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 11:53:09 -0400
Subject: [PATCH 09/23] VFS: Implement a superblock configuration context
 [ver #4]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk, jlayton@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Mon, 22 May 2017 16:53:00 +0100
Message-ID: <149546838034.9289.791029078711426485.stgit@warthog.procyon.org.uk>
In-Reply-To: <149546825563.9289.9065118651584207610.stgit@warthog.procyon.org.uk>
References: <149546825563.9289.9065118651584207610.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Implement a superblock configuration context concept to be used during
superblock creation for mount and superblock reconfiguration for remount.

The mounting procedure then becomes:

 (1) Allocate new sb_config context.

 (2) Configure the context.

 (3) Create superblock.

 (4) Mount the superblock any number of times.

 (5) Destroy the context.

Rather than calling fs_type->mount(), an sb_config struct is created and
fs_type->init_sb_config() is called to set it up.  fs_type->sb_config_size
says how much space should be allocated for the config context.  The
sb_config struct is placed at the beginning and any extra space is for the
filesystem's use.

A set of operations has to be set by ->init_sb_config() to provide freeing,
duplication, option parsing, binary data parsing, validation, mounting and
superblock filling.

Legacy filesystems are supported by the provision of a set of legacy
sb_config operations that build up a list of mount options and then invoke
fs_type->mount() from within the sb_config ->get_tree() operation.  This
allows all filesystems to be accessed using sb_config.

It should be noted that, whilst this patch adds a lot of lines of code,
there is quite a bit of duplication with existing code that can be
eliminated should all filesystems be converted over.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/Makefile               |    3 
 fs/internal.h             |    2 
 fs/libfs.c                |   17 +
 fs/namespace.c            |  389 ++++++++++++++++++++++++++--------
 fs/sb_config.c            |  512 +++++++++++++++++++++++++++++++++++++++++++++
 fs/super.c                |   57 +++++
 include/linux/fs.h        |   14 +
 include/linux/mount.h     |    4 
 include/linux/sb_config.h |   13 +
 9 files changed, 907 insertions(+), 104 deletions(-)
 create mode 100644 fs/sb_config.c

diff --git a/fs/Makefile b/fs/Makefile
index 7bbaca9c67b1..8f5142525866 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -11,7 +11,8 @@ obj-y :=	open.o read_write.o file_table.o super.o \
 		attr.o bad_inode.o file.o filesystems.o namespace.o \
 		seq_file.o xattr.o libfs.o fs-writeback.o \
 		pnode.o splice.o sync.o utimes.o \
-		stack.o fs_struct.o statfs.o fs_pin.o nsfs.o
+		stack.o fs_struct.o statfs.o fs_pin.o nsfs.o \
+		sb_config.o
 
 ifeq ($(CONFIG_BLOCK),y)
 obj-y +=	buffer.o block_dev.o direct-io.o mpage.o
diff --git a/fs/internal.h b/fs/internal.h
index 9676fe11c093..39121a99d930 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -87,7 +87,7 @@ extern struct file *get_empty_filp(void);
 /*
  * super.c
  */
-extern int do_remount_sb(struct super_block *, int, void *, int);
+extern int do_remount_sb(struct super_block *, int, void *, int, struct sb_config *);
 extern bool trylock_super(struct super_block *sb);
 extern struct dentry *mount_fs(struct file_system_type *,
 			       int, const char *, void *);
diff --git a/fs/libfs.c b/fs/libfs.c
index a04395334bb1..e8787adf0363 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -9,6 +9,7 @@
 #include <linux/slab.h>
 #include <linux/cred.h>
 #include <linux/mount.h>
+#include <linux/sb_config.h>
 #include <linux/vfs.h>
 #include <linux/quotaops.h>
 #include <linux/mutex.h>
@@ -574,13 +575,27 @@ static DEFINE_SPINLOCK(pin_fs_lock);
 
 int simple_pin_fs(struct file_system_type *type, struct vfsmount **mount, int *count)
 {
+	struct sb_config *sc;
 	struct vfsmount *mnt = NULL;
+	int ret;
+
 	spin_lock(&pin_fs_lock);
 	if (unlikely(!*mount)) {
 		spin_unlock(&pin_fs_lock);
-		mnt = vfs_kern_mount(type, MS_KERNMOUNT, type->name, NULL);
+
+		sc = __vfs_new_sb_config(type, NULL, MS_KERNMOUNT, SB_CONFIG_FOR_NEW);
+		if (IS_ERR(sc))
+			return PTR_ERR(sc);
+
+		ret = vfs_get_tree(sc);
+		if (ret < 0)
+			return ret;
+
+		mnt = vfs_kern_mount_sc(sc);
+		put_sb_config(sc);
 		if (IS_ERR(mnt))
 			return PTR_ERR(mnt);
+
 		spin_lock(&pin_fs_lock);
 		if (!*mount)
 			*mount = mnt;
diff --git a/fs/namespace.c b/fs/namespace.c
index c076787871e7..e92bc48accb5 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -25,7 +25,9 @@
 #include <linux/magic.h>
 #include <linux/bootmem.h>
 #include <linux/task_work.h>
+#include <linux/file.h>
 #include <linux/sched/task.h>
+#include <linux/sb_config.h>
 
 #include "pnode.h"
 #include "internal.h"
@@ -957,55 +959,6 @@ static struct mount *skip_mnt_tree(struct mount *p)
 	return p;
 }
 
-struct vfsmount *
-vfs_kern_mount(struct file_system_type *type, int flags, const char *name, void *data)
-{
-	struct mount *mnt;
-	struct dentry *root;
-
-	if (!type)
-		return ERR_PTR(-ENODEV);
-
-	mnt = alloc_vfsmnt(name);
-	if (!mnt)
-		return ERR_PTR(-ENOMEM);
-
-	if (flags & MS_KERNMOUNT)
-		mnt->mnt.mnt_flags = MNT_INTERNAL;
-
-	root = mount_fs(type, flags, name, data);
-	if (IS_ERR(root)) {
-		mnt_free_id(mnt);
-		free_vfsmnt(mnt);
-		return ERR_CAST(root);
-	}
-
-	mnt->mnt.mnt_root = root;
-	mnt->mnt.mnt_sb = root->d_sb;
-	mnt->mnt_mountpoint = mnt->mnt.mnt_root;
-	mnt->mnt_parent = mnt;
-	lock_mount_hash();
-	list_add_tail(&mnt->mnt_instance, &root->d_sb->s_mounts);
-	unlock_mount_hash();
-	return &mnt->mnt;
-}
-EXPORT_SYMBOL_GPL(vfs_kern_mount);
-
-struct vfsmount *
-vfs_submount(const struct dentry *mountpoint, struct file_system_type *type,
-	     const char *name, void *data)
-{
-	/* Until it is worked out how to pass the user namespace
-	 * through from the parent mount to the submount don't support
-	 * unprivileged mounts with submounts.
-	 */
-	if (mountpoint->d_sb->s_user_ns != &init_user_ns)
-		return ERR_PTR(-EPERM);
-
-	return vfs_kern_mount(type, MS_SUBMOUNT, name, data);
-}
-EXPORT_SYMBOL_GPL(vfs_submount);
-
 static struct mount *clone_mnt(struct mount *old, struct dentry *root,
 					int flag)
 {
@@ -1593,7 +1546,7 @@ static int do_umount(struct mount *mnt, int flags)
 			return -EPERM;
 		down_write(&sb->s_umount);
 		if (!(sb->s_flags & MS_RDONLY))
-			retval = do_remount_sb(sb, MS_RDONLY, NULL, 0);
+			retval = do_remount_sb(sb, MS_RDONLY, NULL, 0, NULL);
 		up_write(&sb->s_umount);
 		return retval;
 	}
@@ -2276,6 +2229,20 @@ static int change_mount_flags(struct vfsmount *mnt, int ms_flags)
 }
 
 /*
+ * Parse the monolithic page of mount data given to sys_mount().
+ */
+static int parse_monolithic_mount_data(struct sb_config *sc, void *data)
+{
+	int (*monolithic_mount_data)(struct sb_config *, void *);
+
+	monolithic_mount_data = sc->ops->monolithic_mount_data;
+	if (!monolithic_mount_data)
+		monolithic_mount_data = generic_monolithic_mount_data;
+
+	return monolithic_mount_data(sc, data);
+}
+
+/*
  * change filesystem flags. dir should be a physical root of filesystem.
  * If you've mounted a non-root directory somewhere and want to do remount
  * on it - tough luck.
@@ -2283,9 +2250,11 @@ static int change_mount_flags(struct vfsmount *mnt, int ms_flags)
 static int do_remount(struct path *path, int flags, int mnt_flags,
 		      void *data)
 {
+	struct sb_config *sc = NULL;
 	int err;
 	struct super_block *sb = path->mnt->mnt_sb;
 	struct mount *mnt = real_mount(path->mnt);
+	struct file_system_type *type = sb->s_type;
 
 	if (!check_mnt(mnt))
 		return -EINVAL;
@@ -2320,9 +2289,19 @@ static int do_remount(struct path *path, int flags, int mnt_flags,
 		return -EPERM;
 	}
 
-	err = security_sb_remount(sb, data);
-	if (err)
-		return err;
+	if (type->init_sb_config) {
+		sc = vfs_sb_reconfig(path->mnt, flags);
+		if (IS_ERR(sc))
+			return PTR_ERR(sc);
+
+		err = parse_monolithic_mount_data(sc, data);
+		if (err < 0)
+			goto err_sc;
+	} else {
+		err = security_sb_remount(sb, data);
+		if (err)
+			return err;
+	}
 
 	down_write(&sb->s_umount);
 	if (flags & MS_BIND)
@@ -2330,7 +2309,7 @@ static int do_remount(struct path *path, int flags, int mnt_flags,
 	else if (!capable(CAP_SYS_ADMIN))
 		err = -EPERM;
 	else
-		err = do_remount_sb(sb, flags, data, 0);
+		err = do_remount_sb(sb, flags, data, 0, sc);
 	if (!err) {
 		lock_mount_hash();
 		mnt_flags |= mnt->mnt.mnt_flags & ~MNT_USER_SETTABLE_MASK;
@@ -2339,6 +2318,9 @@ static int do_remount(struct path *path, int flags, int mnt_flags,
 		unlock_mount_hash();
 	}
 	up_write(&sb->s_umount);
+err_sc:
+	if (sc)
+		put_sb_config(sc);
 	return err;
 }
 
@@ -2422,29 +2404,6 @@ static int do_move_mount(struct path *path, const char *old_name)
 	return err;
 }
 
-static struct vfsmount *fs_set_subtype(struct vfsmount *mnt, const char *fstype)
-{
-	int err;
-	const char *subtype = strchr(fstype, '.');
-	if (subtype) {
-		subtype++;
-		err = -EINVAL;
-		if (!subtype[0])
-			goto err;
-	} else
-		subtype = "";
-
-	mnt->mnt_sb->s_subtype = kstrdup(subtype, GFP_KERNEL);
-	err = -ENOMEM;
-	if (!mnt->mnt_sb->s_subtype)
-		goto err;
-	return mnt;
-
- err:
-	mntput(mnt);
-	return ERR_PTR(err);
-}
-
 /*
  * add a mount into a namespace's mount tree
  */
@@ -2492,40 +2451,80 @@ static int do_add_mount(struct mount *newmnt, struct path *path, int mnt_flags)
 static bool mount_too_revealing(struct vfsmount *mnt, int *new_mnt_flags);
 
 /*
+ * Create a new mount using a superblock configuration and request it
+ * be added to the namespace tree.
+ */
+static int do_new_mount_sc(struct sb_config *sc, struct path *mountpoint,
+			   unsigned int mnt_flags)
+{
+	struct vfsmount *mnt;
+	int ret;
+
+	mnt = vfs_kern_mount_sc(sc);
+	if (IS_ERR(mnt))
+		return PTR_ERR(mnt);
+
+	ret = -EPERM;
+	if (mount_too_revealing(mnt, &mnt_flags)) {
+		errorf("VFS: Mount too revealing");
+		goto err_mnt;
+	}
+
+	ret = do_add_mount(real_mount(mnt), mountpoint, mnt_flags);
+	if (ret < 0) {
+		errorf("VFS: Failed to add mount");
+		goto err_mnt;
+	}
+	return ret;
+
+err_mnt:
+	mntput(mnt);
+	return ret;
+}
+
+/*
  * create a new mount for userspace and request it to be added into the
  * namespace's tree
  */
-static int do_new_mount(struct path *path, const char *fstype, int flags,
+static int do_new_mount(struct path *mountpoint, const char *fstype, int flags,
 			int mnt_flags, const char *name, void *data)
 {
-	struct file_system_type *type;
-	struct vfsmount *mnt;
+	struct sb_config *sc;
 	int err;
 
 	if (!fstype)
 		return -EINVAL;
 
-	type = get_fs_type(fstype);
-	if (!type)
-		return -ENODEV;
+	sc = vfs_new_sb_config(fstype);
+	if (IS_ERR(sc)) {
+		err = PTR_ERR(sc);
+		goto err;
+	}
+	sc->ms_flags = flags;
 
-	mnt = vfs_kern_mount(type, flags, name, data);
-	if (!IS_ERR(mnt) && (type->fs_flags & FS_HAS_SUBTYPE) &&
-	    !mnt->mnt_sb->s_subtype)
-		mnt = fs_set_subtype(mnt, fstype);
+	err = -ENOMEM;
+	sc->device = kstrdup(name, GFP_KERNEL);
+	if (!sc->device)
+		goto err_sc;
 
-	put_filesystem(type);
-	if (IS_ERR(mnt))
-		return PTR_ERR(mnt);
+	err = parse_monolithic_mount_data(sc, data);
+	if (err < 0)
+		goto err_sc;
 
-	if (mount_too_revealing(mnt, &mnt_flags)) {
-		mntput(mnt);
-		return -EPERM;
-	}
+	err = vfs_get_tree(sc);
+	if (err < 0)
+		goto err_sc;
 
-	err = do_add_mount(real_mount(mnt), path, mnt_flags);
+	err = do_new_mount_sc(sc, mountpoint, mnt_flags);
 	if (err)
-		mntput(mnt);
+		goto err_sc;
+
+	put_sb_config(sc);
+	return 0;
+
+err_sc:
+	put_sb_config(sc);
+err:
 	return err;
 }
 
@@ -3058,6 +3057,187 @@ SYSCALL_DEFINE5(mount, char __user *, dev_name, char __user *, dir_name,
 	return ret;
 }
 
+/**
+ * vfs_get_tree - Get the mountable root
+ * @sc: The superblock configuration context.
+ *
+ * The filesystem is invoked to get or create a superblock which can then later
+ * be used for mounting.  The filesystem places a pointer to the root to be
+ * used for mounting in @sc->root.
+ */
+int vfs_get_tree(struct sb_config *sc)
+{
+	struct super_block *sb;
+	int ret;
+
+	if (sc->root)
+		return -EBUSY;
+
+	if (sc->ops->validate) {
+		ret = sc->ops->validate(sc);
+		if (ret < 0)
+			return ret;
+	}
+
+	/* The filesystem may transfer preallocated resources from the
+	 * configuration context to the superblock, thereby rendering the
+	 * config unusable for another attempt at creation if this one fails.
+	 */
+	if (sc->degraded)
+		return invalf("VFS: The config is degraded");
+
+	/* Get the mountable root in sc->root, with a ref on the root and a ref
+	 * on the superblock.
+	 */
+	ret = sc->ops->get_tree(sc);
+	if (ret < 0)
+		return ret;
+
+	BUG_ON(!sc->root);
+	sb = sc->root->d_sb;
+	WARN_ON(!sb->s_bdi);
+
+	ret = security_sb_get_tree(sc);
+	if (ret < 0)
+		goto err_sb;
+
+	ret = -ENOMEM;
+	if (sc->subtype && !sb->s_subtype) {
+		sb->s_subtype = kstrdup(sc->subtype, GFP_KERNEL);
+		if (!sb->s_subtype)
+			goto err_sb;
+	}
+
+	sb->s_flags |= MS_BORN;
+
+	/* Filesystems should never set s_maxbytes larger than MAX_LFS_FILESIZE
+	 * but s_maxbytes was an unsigned long long for many releases.  Throw
+	 * this warning for a little while to try and catch filesystems that
+	 * violate this rule.
+	 */
+	WARN(sb->s_maxbytes < 0,
+	     "%s set sb->s_maxbytes to negative value (%lld)\n",
+	     sc->fs_type->name, sb->s_maxbytes);
+
+	up_write(&sb->s_umount);
+	return 0;
+
+err_sb:
+	dput(sc->root);
+	sc->root = NULL;
+	deactivate_locked_super(sb);
+	return ret;
+}
+EXPORT_SYMBOL(vfs_get_tree);
+
+/**
+ * vfs_kern_mount_sc - Create a mount for a configured superblock
+ * sc: The configuration context with the superblock attached
+ *
+ * Create a mount to an already configured superblock.  If necessary, the
+ * caller should invoke vfs_create_super() before calling this.
+ */
+struct vfsmount *vfs_kern_mount_sc(struct sb_config *sc)
+{
+	struct mount *mnt;
+
+	if (!sc->root)
+		return ERR_PTR(invalf("VFS: Root must be obtained before mount"));
+
+	mnt = alloc_vfsmnt(sc->device ?: "none");
+	if (!mnt)
+		return ERR_PTR(-ENOMEM);
+
+	if (sc->ms_flags & MS_KERNMOUNT)
+		mnt->mnt.mnt_flags = MNT_INTERNAL;
+
+	atomic_inc(&sc->root->d_sb->s_active);
+	mnt->mnt.mnt_sb		= sc->root->d_sb;
+	mnt->mnt.mnt_root	= dget(sc->root);
+	mnt->mnt_mountpoint	= mnt->mnt.mnt_root;
+	mnt->mnt_parent		= mnt;
+
+	lock_mount_hash();
+	list_add_tail(&mnt->mnt_instance, &mnt->mnt.mnt_sb->s_mounts);
+	unlock_mount_hash();
+	return &mnt->mnt;
+}
+EXPORT_SYMBOL_GPL(vfs_kern_mount_sc);
+
+struct vfsmount *vfs_kern_mount(struct file_system_type *type,
+				int flags, const char *name, void *data)
+{
+	struct sb_config *sc;
+	struct vfsmount *mnt;
+	int ret;
+
+	if (!type)
+		return ERR_PTR(-EINVAL);
+
+	sc = __vfs_new_sb_config(type, NULL, flags, SB_CONFIG_FOR_NEW);
+	if (IS_ERR(sc))
+		return ERR_CAST(sc);
+
+	if (name) {
+		ret = -ENOMEM;
+		sc->device = kstrdup(name, GFP_KERNEL);
+		if (!sc->device)
+			goto err_sc;
+	}
+
+	ret = parse_monolithic_mount_data(sc, data);
+	if (ret < 0)
+		goto err_sc;
+
+	ret = vfs_get_tree(sc);
+	if (ret < 0)
+		goto err_sc;
+
+	mnt = vfs_kern_mount_sc(sc);
+	if (IS_ERR(mnt)) {
+		ret = PTR_ERR(mnt);
+		goto err_sc;
+	}
+
+	put_sb_config(sc);
+	return mnt;
+
+err_sc:
+	put_sb_config(sc);
+	return ERR_PTR(ret);
+}
+EXPORT_SYMBOL_GPL(vfs_kern_mount);
+
+struct vfsmount *
+vfs_submount_sc(const struct dentry *mountpoint, struct sb_config *sc)
+{
+	/* Until it is worked out how to pass the user namespace
+	 * through from the parent mount to the submount don't support
+	 * unprivileged mounts with submounts.
+	 */
+	if (mountpoint->d_sb->s_user_ns != &init_user_ns)
+		return ERR_PTR(-EPERM);
+
+	sc->ms_flags = MS_SUBMOUNT;
+	return vfs_kern_mount_sc(sc);
+}
+EXPORT_SYMBOL_GPL(vfs_submount_sc);
+
+struct vfsmount *
+vfs_submount(const struct dentry *mountpoint, struct file_system_type *type,
+	     const char *name, void *data)
+{
+	/* Until it is worked out how to pass the user namespace
+	 * through from the parent mount to the submount don't support
+	 * unprivileged mounts with submounts.
+	 */
+	if (mountpoint->d_sb->s_user_ns != &init_user_ns)
+		return ERR_PTR(-EPERM);
+
+	return vfs_kern_mount(type, MS_SUBMOUNT, name, data);
+}
+EXPORT_SYMBOL_GPL(vfs_submount);
+
 /*
  * Return true if path is reachable from root
  *
@@ -3299,6 +3479,23 @@ struct vfsmount *kern_mount_data(struct file_system_type *type, void *data)
 }
 EXPORT_SYMBOL_GPL(kern_mount_data);
 
+struct vfsmount *kern_mount_data_sc(struct sb_config *sc)
+{
+	struct vfsmount *mnt;
+
+	sc->ms_flags = MS_KERNMOUNT;
+	mnt = vfs_kern_mount_sc(sc);
+	if (!IS_ERR(mnt)) {
+		/*
+		 * it is a longterm mount, don't release mnt until
+		 * we unmount before file sys is unregistered
+		*/
+		real_mount(mnt)->mnt_ns = MNT_NS_INTERNAL;
+	}
+	return mnt;
+}
+EXPORT_SYMBOL_GPL(kern_mount_data_sc);
+
 void kern_unmount(struct vfsmount *mnt)
 {
 	/* release long term mount so mount point can be released */
diff --git a/fs/sb_config.c b/fs/sb_config.c
new file mode 100644
index 000000000000..4d9bfb982d41
--- /dev/null
+++ b/fs/sb_config.c
@@ -0,0 +1,512 @@
+/* Provide a way to create a superblock configuration context within the kernel
+ * that allows a superblock to be set up prior to mounting.
+ *
+ * Copyright (C) 2017 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+#include <linux/sb_config.h>
+#include <linux/fs.h>
+#include <linux/mount.h>
+#include <linux/nsproxy.h>
+#include <linux/slab.h>
+#include <linux/magic.h>
+#include <linux/security.h>
+#include <linux/parser.h>
+#include <linux/mnt_namespace.h>
+#include <linux/pid_namespace.h>
+#include <linux/user_namespace.h>
+#include <net/net_namespace.h>
+#include "mount.h"
+
+struct legacy_sb_config {
+	struct sb_config	sc;
+	char			*legacy_data;	/* Data page for legacy filesystems */
+	char			*secdata;
+	unsigned int		data_usage;
+};
+
+static const struct sb_config_operations legacy_sb_config_ops;
+
+static const match_table_t common_set_mount_options = {
+	{ MS_DIRSYNC,		"dirsync" },
+	{ MS_I_VERSION,		"iversion" },
+	{ MS_LAZYTIME,		"lazytime" },
+	{ MS_MANDLOCK,		"mand" },
+	{ MS_POSIXACL,		"posixacl" },
+	{ MS_RDONLY,		"ro" },
+	{ MS_REC,		"rec" },
+	{ MS_SYNCHRONOUS,	"sync" },
+	{ MS_VERBOSE,		"verbose" },
+	{ },
+};
+
+static const match_table_t common_clear_mount_options = {
+	{ MS_LAZYTIME,		"nolazytime" },
+	{ MS_MANDLOCK,		"nomand" },
+	{ MS_RDONLY,		"rw" },
+	{ MS_SILENT,		"silent" },
+	{ MS_SYNCHRONOUS,	"async" },
+	{ },
+};
+
+static const match_table_t forbidden_mount_options = {
+	{ MS_BIND,		"bind" },
+	{ MS_MOVE,		"move" },
+	{ MS_PRIVATE,		"private" },
+	{ MS_REMOUNT,		"remount" },
+	{ MS_SHARED,		"shared" },
+	{ MS_SLAVE,		"slave" },
+	{ MS_UNBINDABLE,	"unbindable" },
+	{ MS_NOATIME,		"noatime" },
+	{ MS_RELATIME,		"relatime" },
+	{ MS_RELATIME,		"norelatime" },
+	{ MS_STRICTATIME,	"strictatime" },
+	{ MS_STRICTATIME,	"nostrictatime" },
+	{ MS_NODIRATIME,	"nodiratime" },
+	{ MS_NODEV,		"dev" },
+	{ MS_NODEV,		"nodev" },
+	{ MS_NOEXEC,		"exec" },
+	{ MS_NOEXEC,		"noexec" },
+	{ MS_NOSUID,		"suid" },
+	{ MS_NOSUID,		"nosuid" },
+	{ },
+};
+
+/*
+ * Check for a common mount option.
+ */
+static int vfs_parse_ms_mount_option(struct sb_config *sc, char *data)
+{
+	substring_t args[MAX_OPT_ARGS];
+	unsigned int token;
+
+	token = match_token(data, common_set_mount_options, args);
+	if (token) {
+		sc->ms_flags |= token;
+		return 1;
+	}
+
+	token = match_token(data, common_clear_mount_options, args);
+	if (token) {
+		sc->ms_flags &= ~token;
+		return 1;
+	}
+
+	token = match_token(data, forbidden_mount_options, args);
+	if (token)
+		return invalf("VFS: Mount option, not superblock option");
+
+	return 0;
+}
+
+/**
+ * vfs_parse_mount_option - Add a single mount option to a superblock config
+ * @mc: The superblock configuration to modify
+ * @p: The option to apply.
+ *
+ * A single mount option in string form is applied to the superblock
+ * configuration being set up.  Certain standard options (for example "ro") are
+ * translated into flag bits without going to the filesystem.  The active
+ * security module is allowed to observe and poach options.  Any other options
+ * are passed over to the filesystem to parse.
+ *
+ * This may be called multiple times for a context.
+ *
+ * Returns 0 on success and a negative error code on failure.  In the event of
+ * failure, sc->error may have been set to a non-allocated string that gives
+ * more information.
+ */
+int vfs_parse_mount_option(struct sb_config *sc, char *p)
+{
+	int ret;
+
+	ret = vfs_parse_ms_mount_option(sc, p);
+	if (ret < 0)
+		return ret;
+	if (ret == 1)
+		return 0;
+
+	ret = security_sb_config_parse_option(sc, p);
+	if (ret < 0)
+		return ret;
+	if (ret == 1)
+		return 0;
+
+	if (sc->ops->parse_option)
+		return sc->ops->parse_option(sc, p);
+
+	return invalf("VFS: FS takes no options");
+}
+EXPORT_SYMBOL(vfs_parse_mount_option);
+
+/**
+ * generic_monolithic_mount_data - Parse key[=val][,key[=val]]* mount data
+ * @mc: The superblock configuration to fill in.
+ * @data: The data to parse
+ *
+ * Parse a blob of data that's in key[=val][,key[=val]]* form.  This can be
+ * called from the ->monolithic_mount_data() sb_config operation.
+ *
+ * Returns 0 on success or the error returned by the ->parse_option() sb_config
+ * operation on failure.
+ */
+int generic_monolithic_mount_data(struct sb_config *ctx, void *data)
+{
+	char *options = data, *p;
+	int ret;
+
+	if (!options)
+		return 0;
+
+	while ((p = strsep(&options, ",")) != NULL) {
+		if (*p) {
+			ret = vfs_parse_mount_option(ctx, p);
+			if (ret < 0)
+				return ret;
+		}
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(generic_monolithic_mount_data);
+
+/**
+ * __vfs_new_sb_config - Create a superblock config.
+ * @fs_type: The filesystem type.
+ * @src_sb: A superblock from which this one derives (or NULL)
+ * @ms_flags: Superblock flags and op flags (such as MS_REMOUNT)
+ * @purpose: The purpose that this configuration shall be used for.
+ *
+ * Open a filesystem and create a mount context.  The mount context is
+ * initialised with the supplied flags and, if a submount/automount from
+ * another superblock (@src_sb), may have parameters such as namespaces copied
+ * across from that superblock.
+ */
+struct sb_config *__vfs_new_sb_config(struct file_system_type *fs_type,
+				      struct super_block *src_sb,
+				      unsigned int ms_flags,
+				      enum sb_config_purpose purpose)
+{
+	struct sb_config *sc;
+	size_t sc_size = fs_type->sb_config_size;
+	int ret;
+
+	BUG_ON(fs_type->init_sb_config && sc_size < sizeof(*sc));
+
+	if (!fs_type->init_sb_config)
+		sc_size = sizeof(struct legacy_sb_config);
+
+	sc = kzalloc(sc_size, GFP_KERNEL);
+	if (!sc)
+		return ERR_PTR(-ENOMEM);
+
+	sc->purpose	= purpose;
+	sc->ms_flags	= ms_flags;
+	sc->fs_type	= get_filesystem(fs_type);
+	sc->net_ns	= get_net(current->nsproxy->net_ns);
+	sc->user_ns	= get_user_ns(current_user_ns());
+	sc->cred	= get_current_cred();
+
+	/* TODO: Make all filesystems support this unconditionally */
+	if (sc->fs_type->init_sb_config) {
+		ret = sc->fs_type->init_sb_config(sc, src_sb);
+		if (ret < 0)
+			goto err_sc;
+	} else {
+		sc->ops = &legacy_sb_config_ops;
+	}
+
+	/* Do the security check last because ->init_sb_config may change the
+	 * namespace subscriptions.
+	 */
+	ret = security_sb_config_alloc(sc, src_sb);
+	if (ret < 0)
+		goto err_sc;
+
+	return sc;
+
+err_sc:
+	put_sb_config(sc);
+	return ERR_PTR(ret);
+}
+EXPORT_SYMBOL(__vfs_new_sb_config);
+
+/**
+ * vfs_new_sb_config - Create a superblock config for a new mount.
+ * @fs_name: The name of the filesystem
+ *
+ * Open a filesystem and create a superblock config context for a new mount
+ * that will hold the mount options, device name, security details, etc..  Note
+ * that the caller should check the ->ops pointer in the returned context to
+ * determine whether the filesystem actually supports the superblock context
+ * itself.
+ */
+struct sb_config *vfs_new_sb_config(const char *fs_name)
+{
+	struct file_system_type *fs_type;
+	struct sb_config *sc;
+
+	fs_type = get_fs_type(fs_name);
+	if (!fs_type)
+		return ERR_PTR(-ENODEV);
+
+	sc = __vfs_new_sb_config(fs_type, NULL, 0, SB_CONFIG_FOR_NEW);
+	put_filesystem(fs_type);
+	return sc;
+}
+EXPORT_SYMBOL(vfs_new_sb_config);
+
+/**
+ * vfs_sb_reconfig - Create a superblock config for remount/reconfiguration
+ * @mnt: The mountpoint to open
+ * @ms_flags: Superblock flags and op flags (such as MS_REMOUNT)
+ *
+ * Open a mounted filesystem and create a mount context such that a remount can
+ * be effected.
+ */
+struct sb_config *vfs_sb_reconfig(struct vfsmount *mnt,
+				  unsigned int ms_flags)
+{
+	return __vfs_new_sb_config(mnt->mnt_sb->s_type, mnt->mnt_sb,
+				   ms_flags, SB_CONFIG_FOR_REMOUNT);
+}
+
+/**
+ * vfs_dup_sc_config: Duplicate a superblock configuration context.
+ * @src_sc: The context to copy.
+ */
+struct sb_config *vfs_dup_sb_config(struct sb_config *src_sc)
+{
+	struct sb_config *sc;
+	size_t sc_size;
+	int ret;
+
+	if (!src_sc->ops->dup)
+		return ERR_PTR(-ENOTSUPP);
+
+	sc_size = src_sc->fs_type->sb_config_size;
+	if (!src_sc->fs_type->init_sb_config)
+		sc_size = sizeof(struct legacy_sb_config);
+
+	sc = kmemdup(src_sc, src_sc->fs_type->sb_config_size, GFP_KERNEL);
+	if (!sc)
+		return ERR_PTR(-ENOMEM);
+
+	sc->device	= NULL;
+	sc->security	= NULL;
+	get_filesystem(sc->fs_type);
+	get_net(sc->net_ns);
+	get_user_ns(sc->user_ns);
+	get_cred(sc->cred);
+
+	/* Can't call put until we've called ->dup */
+	ret = sc->ops->dup(sc, src_sc);
+	if (ret < 0)
+		goto err_sc;
+
+	ret = security_sb_config_dup(sc, src_sc);
+	if (ret < 0)
+		goto err_sc;
+	return sc;
+
+err_sc:
+	put_sb_config(sc);
+	return ERR_PTR(ret);
+}
+EXPORT_SYMBOL(vfs_dup_sb_config);
+
+/**
+ * put_sb_config - Dispose of a superblock configuration context.
+ * @sc: The context to dispose of.
+ */
+void put_sb_config(struct sb_config *sc)
+{
+	struct super_block *sb;
+
+	if (sc->root) {
+		sb = sc->root->d_sb;
+		dput(sc->root);
+		sc->root = NULL;
+		deactivate_super(sb);
+	}
+
+	if (sc->ops && sc->ops->free)
+		sc->ops->free(sc);
+
+	security_sb_config_free(sc);
+	if (sc->net_ns)
+		put_net(sc->net_ns);
+	put_user_ns(sc->user_ns);
+	if (sc->cred)
+		put_cred(sc->cred);
+	kfree(sc->subtype);
+	put_filesystem(sc->fs_type);
+	kfree(sc->device);
+	kfree(sc);
+}
+EXPORT_SYMBOL(put_sb_config);
+
+/*
+ * Free the config for a filesystem that doesn't support sb_config.
+ */
+static void legacy_sb_config_free(struct sb_config *sc)
+{
+	struct legacy_sb_config *cfg = container_of(sc, struct legacy_sb_config, sc);
+
+	free_secdata(cfg->secdata);
+	kfree(cfg->legacy_data);
+}
+
+/*
+ * Duplicate a legacy config.
+ */
+static int legacy_sb_config_dup(struct sb_config *sc, struct sb_config *src_sc)
+{
+	struct legacy_sb_config *cfg = container_of(sc, struct legacy_sb_config, sc);
+	struct legacy_sb_config *src_cfg = container_of(src_sc, struct legacy_sb_config, sc);
+
+	cfg->legacy_data = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!cfg->legacy_data)
+		return -ENOMEM;
+	memcpy(cfg->legacy_data, src_cfg->legacy_data, sizeof(PAGE_SIZE));
+	return 0;
+}
+
+/*
+ * Add an option to a legacy config.  We build up a comma-separated list of
+ * options.
+ */
+static int legacy_parse_option(struct sb_config *sc, char *p)
+{
+	struct legacy_sb_config *cfg = container_of(sc, struct legacy_sb_config, sc);
+	unsigned int usage = cfg->data_usage;
+	size_t len = strlen(p);
+
+	if (len > PAGE_SIZE - 2 - usage)
+		return invalf("VFS: Insufficient data buffer space");
+	if (memchr(p, ',', len) != NULL)
+		return invalf("VFS: Options cannot contain commas");
+	if (!cfg->legacy_data) {
+		cfg->legacy_data = kmalloc(PAGE_SIZE, GFP_KERNEL);
+		if (!cfg->legacy_data)
+			return -ENOMEM;
+	}
+
+	cfg->legacy_data[usage++] = ',';
+	memcpy(cfg->legacy_data + usage, p, len);
+	usage += len;
+	cfg->legacy_data[usage] = '\0';
+	cfg->data_usage = usage;
+	return 0;
+}
+
+/*
+ * Add monolithic mount data.
+ */
+static int legacy_monolithic_mount_data(struct sb_config *sc, void *data)
+{
+	struct legacy_sb_config *cfg = container_of(sc, struct legacy_sb_config, sc);
+
+	if (cfg->data_usage != 0)
+		return invalf("VFS: Can't mix monolithic and individual options");
+	if (!data)
+		return 0;
+	if (!cfg->legacy_data) {
+		cfg->legacy_data = kmalloc(PAGE_SIZE, GFP_KERNEL);
+		if (!cfg->legacy_data)
+			return -ENOMEM;
+	}
+
+	memcpy(cfg->legacy_data, data, PAGE_SIZE);
+	cfg->data_usage = PAGE_SIZE;
+	return 0;
+}
+
+/*
+ * Use the legacy mount validation step to strip out and process security
+ * config options.
+ */
+static int legacy_validate(struct sb_config *sc)
+{
+	struct legacy_sb_config *cfg = container_of(sc, struct legacy_sb_config, sc);
+
+	if (!cfg->legacy_data || cfg->sc.fs_type->fs_flags & FS_BINARY_MOUNTDATA)
+		return 0;
+
+	cfg->secdata = alloc_secdata();
+	if (!cfg->secdata)
+		return -ENOMEM;
+
+	return security_sb_copy_data(cfg->legacy_data, cfg->secdata);
+}
+
+/*
+ * Determine the superblock subtype.
+ */
+static int legacy_set_subtype(struct sb_config *sc)
+{
+	const char *subtype = strchr(sc->fs_type->name, '.');
+
+	if (subtype) {
+		subtype++;
+		if (!subtype[0])
+			return -EINVAL;
+	} else {
+		subtype = "";
+	}
+
+	sc->subtype = kstrdup(subtype, GFP_KERNEL);
+	if (!sc->subtype)
+		return -ENOMEM;
+	return 0;
+}
+
+/*
+ * Get a mountable root with the legacy mount command.
+ */
+static int legacy_get_tree(struct sb_config *sc)
+{
+	struct legacy_sb_config *cfg = container_of(sc, struct legacy_sb_config, sc);
+	struct super_block *sb;
+	struct dentry *root;
+	int ret;
+
+	root = cfg->sc.fs_type->mount(cfg->sc.fs_type, cfg->sc.ms_flags,
+				      cfg->sc.device, cfg->legacy_data);
+	if (IS_ERR(root))
+		return PTR_ERR(root);
+
+	sb = root->d_sb;
+	BUG_ON(!sb);
+
+	if ((cfg->sc.fs_type->fs_flags & FS_HAS_SUBTYPE) &&
+	    !sc->subtype) {
+		ret = legacy_set_subtype(sc);
+		if (ret < 0)
+			goto err_sb;
+	}
+
+	cfg->sc.root = root;
+	return 0;
+
+err_sb:
+	dput(root);
+	deactivate_locked_super(sb);
+	return ret;
+}
+
+static const struct sb_config_operations legacy_sb_config_ops = {
+	.free			= legacy_sb_config_free,
+	.dup			= legacy_sb_config_dup,
+	.parse_option		= legacy_parse_option,
+	.monolithic_mount_data	= legacy_monolithic_mount_data,
+	.validate		= legacy_validate,
+	.get_tree		= legacy_get_tree,
+};
diff --git a/fs/super.c b/fs/super.c
index adb0c0de428c..e4b47d481679 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -34,6 +34,7 @@
 #include <linux/fsnotify.h>
 #include <linux/lockdep.h>
 #include <linux/user_namespace.h>
+#include <linux/sb_config.h>
 #include "internal.h"
 
 
@@ -805,10 +806,13 @@ struct super_block *user_get_super(dev_t dev)
  *	@flags:	numeric part of options
  *	@data:	the rest of options
  *      @force: whether or not to force the change
+ *	@sc:	the superblock config for filesystems that support it
+ *		(NULL if called from emergency or umount)
  *
  *	Alters the mount options of a mounted file system.
  */
-int do_remount_sb(struct super_block *sb, int flags, void *data, int force)
+int do_remount_sb(struct super_block *sb, int flags, void *data, int force,
+		  struct sb_config *sc)
 {
 	int retval;
 	int remount_ro;
@@ -850,8 +854,14 @@ int do_remount_sb(struct super_block *sb, int flags, void *data, int force)
 		}
 	}
 
-	if (sb->s_op->remount_fs) {
-		retval = sb->s_op->remount_fs(sb, &flags, data);
+	if (sb->s_op->remount_fs_sc ||
+	    sb->s_op->remount_fs) {
+		if (sb->s_op->remount_fs_sc) {
+		    retval = sb->s_op->remount_fs_sc(sb, sc);
+		    flags = sc->ms_flags;
+		} else {
+			retval = sb->s_op->remount_fs(sb, &flags, data);
+		}
 		if (retval) {
 			if (!force)
 				goto cancel_readonly;
@@ -898,7 +908,7 @@ static void do_emergency_remount(struct work_struct *work)
 			/*
 			 * What lock protects sb->s_flags??
 			 */
-			do_remount_sb(sb, MS_RDONLY, NULL, 1);
+			do_remount_sb(sb, MS_RDONLY, NULL, 1, NULL);
 		}
 		up_write(&sb->s_umount);
 		spin_lock(&sb_lock);
@@ -1048,6 +1058,43 @@ struct dentry *mount_ns(struct file_system_type *fs_type,
 
 EXPORT_SYMBOL(mount_ns);
 
+int mount_ns_sc(struct sb_config *sc,
+		int (*fill_super)(struct super_block *sb, struct sb_config *sc),
+		void *ns)
+{
+	struct super_block *sb;
+
+	/* Don't allow mounting unless the caller has CAP_SYS_ADMIN
+	 * over the namespace.
+	 */
+	if (!(sc->ms_flags & MS_KERNMOUNT) &&
+	    !ns_capable(sc->user_ns, CAP_SYS_ADMIN))
+		return -EPERM;
+
+	sb = sget_userns(sc->fs_type, ns_test_super, ns_set_super,
+			 sc->ms_flags, sc->user_ns, ns);
+	if (IS_ERR(sb))
+		return PTR_ERR(sb);
+
+	if (!sb->s_root) {
+		int err;
+		err = fill_super(sb, sc);
+		if (err) {
+			deactivate_locked_super(sb);
+			return err;
+		}
+
+		sb->s_flags |= MS_ACTIVE;
+	}
+
+	if (!sc->root) {
+		sc->root = sb->s_root;
+		dget(sb->s_root);
+	}
+	return 0;
+}
+EXPORT_SYMBOL(mount_ns_sc);
+
 #ifdef CONFIG_BLOCK
 static int set_bdev_super(struct super_block *s, void *data)
 {
@@ -1196,7 +1243,7 @@ struct dentry *mount_single(struct file_system_type *fs_type,
 		}
 		s->s_flags |= MS_ACTIVE;
 	} else {
-		do_remount_sb(s, flags, data, 0);
+		do_remount_sb(s, flags, data, 0, NULL);
 	}
 	return dget(s->s_root);
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index bc0c054894b9..1acb76f400c4 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -54,6 +54,7 @@ struct workqueue_struct;
 struct iov_iter;
 struct fscrypt_info;
 struct fscrypt_operations;
+struct sb_config;
 
 extern void __init inode_init(void);
 extern void __init inode_init_early(void);
@@ -701,6 +702,11 @@ static inline void inode_unlock(struct inode *inode)
 	up_write(&inode->i_rwsem);
 }
 
+static inline int inode_lock_killable(struct inode *inode)
+{
+	return down_write_killable(&inode->i_rwsem);
+}
+
 static inline void inode_lock_shared(struct inode *inode)
 {
 	down_read(&inode->i_rwsem);
@@ -1787,6 +1793,7 @@ struct super_operations {
 	int (*unfreeze_fs) (struct super_block *);
 	int (*statfs) (struct dentry *, struct kstatfs *);
 	int (*remount_fs) (struct super_block *, int *, char *);
+	int (*remount_fs_sc) (struct super_block *, struct sb_config *);
 	void (*umount_begin) (struct super_block *);
 
 	int (*show_options)(struct seq_file *, struct dentry *);
@@ -2021,8 +2028,10 @@ struct file_system_type {
 #define FS_HAS_SUBTYPE		4
 #define FS_USERNS_MOUNT		8	/* Can be mounted by userns root */
 #define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move() during rename() internally. */
+	unsigned short sb_config_size;	/* Size of superblock config context to allocate */
 	struct dentry *(*mount) (struct file_system_type *, int,
 		       const char *, void *);
+	int (*init_sb_config)(struct sb_config *, struct super_block *);
 	void (*kill_sb) (struct super_block *);
 	struct module *owner;
 	struct file_system_type * next;
@@ -2040,6 +2049,10 @@ struct file_system_type {
 
 #define MODULE_ALIAS_FS(NAME) MODULE_ALIAS("fs-" NAME)
 
+extern int mount_ns_sc(struct sb_config *mc,
+		       int (*fill_super)(struct super_block *sb,
+					 struct sb_config *sc),
+		       void *ns);
 extern struct dentry *mount_ns(struct file_system_type *fs_type,
 	int flags, void *data, void *ns, struct user_namespace *user_ns,
 	int (*fill_super)(struct super_block *, void *, int));
@@ -2106,6 +2119,7 @@ extern int register_filesystem(struct file_system_type *);
 extern int unregister_filesystem(struct file_system_type *);
 extern struct vfsmount *kern_mount_data(struct file_system_type *, void *data);
 #define kern_mount(type) kern_mount_data(type, NULL)
+extern struct vfsmount *kern_mount_data_sc(struct sb_config *);
 extern void kern_unmount(struct vfsmount *mnt);
 extern int may_umount_tree(struct vfsmount *);
 extern int may_umount(struct vfsmount *);
diff --git a/include/linux/mount.h b/include/linux/mount.h
index 8e0352af06b7..a5dca6abc4d5 100644
--- a/include/linux/mount.h
+++ b/include/linux/mount.h
@@ -20,6 +20,7 @@ struct super_block;
 struct vfsmount;
 struct dentry;
 struct mnt_namespace;
+struct sb_config;
 
 #define MNT_NOSUID	0x01
 #define MNT_NODEV	0x02
@@ -90,9 +91,12 @@ struct file_system_type;
 extern struct vfsmount *vfs_kern_mount(struct file_system_type *type,
 				      int flags, const char *name,
 				      void *data);
+extern struct vfsmount *vfs_kern_mount_sc(struct sb_config *sc);
 extern struct vfsmount *vfs_submount(const struct dentry *mountpoint,
 				     struct file_system_type *type,
 				     const char *name, void *data);
+extern struct vfsmount *vfs_submount_sc(const struct dentry *mountpoint,
+					struct sb_config *sc);
 
 extern void mnt_set_expiry(struct vfsmount *mnt, struct list_head *expiry_list);
 extern void mark_mounts_for_expiry(struct list_head *mounts);
diff --git a/include/linux/sb_config.h b/include/linux/sb_config.h
index d2af7342a082..0da92dd99d60 100644
--- a/include/linux/sb_config.h
+++ b/include/linux/sb_config.h
@@ -69,4 +69,17 @@ struct sb_config_operations {
 	int (*get_tree)(struct sb_config *sc);
 };
 
+extern struct sb_config *vfs_new_sb_config(const char *fs_name);
+extern struct sb_config *__vfs_new_sb_config(struct file_system_type *fs_type,
+					     struct super_block *src_sb,
+					     unsigned int ms_flags,
+					     enum sb_config_purpose purpose);
+extern struct sb_config *vfs_sb_reconfig(struct vfsmount *mnt,
+					 unsigned int ms_flags);
+extern struct sb_config *vfs_dup_sb_config(struct sb_config *src);
+extern int vfs_parse_mount_option(struct sb_config *sc, char *data);
+extern int generic_monolithic_mount_data(struct sb_config *sc, void *data);
+extern int vfs_get_tree(struct sb_config *sc);
+extern void put_sb_config(struct sb_config *sc);
+
 #endif /* _LINUX_SB_CONFIG_H */


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43720 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933464AbdEKOB7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 11 May 2017 10:01:59 -0400
Subject: [PATCH 14/14] Add commands to create or update a superblock [ver #2]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk, jlayton@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 11 May 2017 15:01:51 +0100
Message-ID: <149451131140.4599.11211466722628195518.stgit@warthog.procyon.org.uk>
In-Reply-To: <149451118535.4599.16084557087363834548.stgit@warthog.procyon.org.uk>
References: <149451118535.4599.16084557087363834548.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Institute a separate step in the mounting procedure:

 (1) Create new sb_config context.

 (2) Configure the context.

 (3) Create superblock.

 (4) Mount the superblock any number of times.

 (5) Destroy the context.

Step (3) is added and must be given by userspace before fsmount() may be
used:

	mfd = fsopen("nfs4", -1, 0);
	E_write(mfd, "d warthog:/root");
	E_write(mfd, "o fsc");
	E_write(mfd, "o sync");
	E_write(mfd, "o intr");
	E_write(mfd, "o foo");
	E_write(mfd, "create");		<---- here
	fsmount(mfd, ...);

This the sb_config context to be used to reconfigure a superblock (not
implemented yet):

	mfd = mntopen("/mnt/foo);
	E_write(mfd, "o foo=1");
	E_write(mfd, "o nobar");
	E_write(mfd, "update");		<---- atomically update the superblock
---

 Documentation/filesystems/mounting.txt |   54 ++++--
 fs/fsopen.c                            |   43 ++++-
 fs/internal.h                          |    2 
 fs/libfs.c                             |   16 ++
 fs/namespace.c                         |  270 +++++++++++++++++---------------
 fs/nfs/getroot.c                       |   76 +++++----
 fs/nfs/internal.h                      |   18 +-
 fs/nfs/mount.c                         |   64 ++++----
 fs/nfs/nfs3proc.c                      |    3 
 fs/nfs/nfs4_fs.h                       |    4 
 fs/nfs/nfs4proc.c                      |    4 
 fs/nfs/nfs4super.c                     |   77 +++++----
 fs/nfs/proc.c                          |    3 
 fs/nfs/super.c                         |   46 +++--
 fs/proc/root.c                         |   11 +
 fs/sb_config.c                         |   74 +++++++--
 fs/super.c                             |   72 +--------
 include/linux/fs.h                     |    8 -
 include/linux/lsm_hooks.h              |   13 +-
 include/linux/nfs_xdr.h                |    4 
 include/linux/sb_config.h              |   11 +
 include/linux/security.h               |   11 -
 security/security.c                    |   14 --
 security/selinux/hooks.c               |   31 +---
 24 files changed, 485 insertions(+), 444 deletions(-)

diff --git a/Documentation/filesystems/mounting.txt b/Documentation/filesystems/mounting.txt
index 03e9086f754d..4d920ad1ef05 100644
--- a/Documentation/filesystems/mounting.txt
+++ b/Documentation/filesystems/mounting.txt
@@ -75,6 +75,7 @@ configuration context.  This is represented by the sb_config structure:
 	struct sb_config {
 		const struct sb_config_operations *ops;
 		struct file_system_type *fs;
+		struct dentry		*root;
 		struct user_namespace	*user_ns;
 		struct net		*net_ns;
 		const struct cred	*cred;
@@ -82,9 +83,9 @@ configuration context.  This is represented by the sb_config structure:
 		void			*security;
 		const char		*error_msg;
 		unsigned int		ms_flags;
-		bool			mounted;
 		bool			sloppy;
 		bool			silent;
+		bool			degraded;
 		enum mount_type		mount_type : 8;
 	};
 
@@ -122,6 +123,11 @@ The sb_config fields are as follows:
      A pointer to the file_system_type of the filesystem that is being
      constructed or reconfigured.  This retains a ref on the type owner.
 
+ (*) struct dentry *root
+
+     A pointer to the root of the mountable tree (and indirectly, the
+     superblock thereof).  This is filled in by the ->get_tree() op.
+
  (*) struct user_namespace *user_ns
  (*) struct net *net_ns
 
@@ -164,12 +170,6 @@ The sb_config fields are as follows:
 
      This holds the MS_* flags mount flags.
 
- (*) bool mounted
-
-     This is set to true once a mount attempt is made.  This causes an error to
-     be given on subsequent mount attempts with the same context and prevents
-     multiple mount attempts.
-
  (*) bool sloppy
  (*) bool silent
 
@@ -181,6 +181,12 @@ The sb_config fields are as follows:
 
      [NOTE] silent is probably redundant with ms_flags & MS_SILENT.
 
+ (*) bool degraded
+
+     This is set if any preallocated resources in the configuration have been
+     used up, thereby rendering the configuration unreusable for the
+     ->get_tree() op.
+
  (*) enum mount_type
 
      This indicates the type of mount operation.  The available values are:
@@ -217,7 +223,7 @@ The superblock configuration context points to a table of operations:
 		int (*parse_option)(struct sb_config *sc, char *p);
 		int (*monolithic_mount_data)(struct sb_config *sc, void *data);
 		int (*validate)(struct sb_config *sc);
-		struct dentry *(*mount)(struct sb_config *sc);
+		int (*get_tree)(struct sb_config *sc);
 	};
 
 These operations are invoked by the various stages of the mount procedure to
@@ -279,18 +285,18 @@ manage the superblock configuration context.  They are as follows:
 
      The return value is as for ->parse_option().
 
- (*) struct dentry *(*mount)(struct sb_config *sc);
+ (*) int (*get_tree)(struct sb_config *sc);
 
-     Called to effect a new mount or new submount using the information stored
-     in the superblock configuration context (remounts go via a different
-     vector).  It may detach any resources it desires from the superblock
-     configuration context and transfer them to the superblock it creates.
+     Called to get or create the mountable root and superblock, using the
+     information stored in the superblock configuration context (remounts go
+     via a different vector).  It may detach any resources it desires from the
+     superblock configuration context and transfer them to the superblock it
+     creates.
 
-     On success it should return the dentry that's at the root of the mount.
-     In future, sc->root_path will then be applied to this.
+     On success it should set sc->root to the mountable root.
 
-     In the case of an error, it should return a negative error code and invoke
-     sb_cfg_inval() or sb_cfg_error().
+     In the case of an error, it should return a negative error code and
+     consider invoking sb_cfg_inval() or sb_cfg_error().
 
 
 =========================================
@@ -379,7 +385,7 @@ one for destroying a context:
      extant mount and initialise the mount parameters from the superblock
      underlying that mount.  This is for use by remount.
 
- (*) struct sb_config *vfs_fsopen(const char *fs_name);
+ (*) struct sb_config *vfs_new_sb_config(const char *fs_name);
 
      Create a superblock configuration context given a filesystem name.  It is
      assumed that the mount flags will be passed in as text options or set
@@ -425,11 +431,19 @@ In the remaining operations, if an error occurs, a negative error code is
 returned and, if not obvious, sc->error_msg may have been set to point to a
 useful string.  This string should not be freed.
 
+ (*) int vfs_get_tree(struct sb_config *sc);
+
+     Get or create the mountable root and superblock, using the parameters in
+     the parsed configuration to select/configure the superblock.  This invokes
+     the ->validate() op and then the ->get_tree() op.
+
+     [NOTE] ->validate() can probably be rolled into ->get_tree() and
+     ->remount_fs_sc().
+
  (*) struct vfsmount *vfs_kern_mount_sc(struct sb_config *sc);
 
      Create a mount given the parameters in the specified superblock
-     configuration context.  This invokes the ->validate() op and then the
-     ->mount() op.
+     configuration context.
 
  (*) struct vfsmount *vfs_submount_sc(const struct dentry *mountpoint,
 				      struct sb_config *sc);
diff --git a/fs/fsopen.c b/fs/fsopen.c
index a4e9d5a7ce2b..0cc79a4f8ae7 100644
--- a/fs/fsopen.c
+++ b/fs/fsopen.c
@@ -52,22 +52,25 @@ static ssize_t fs_fs_read(struct file *file, char __user *_buf, size_t len, loff
 }
 
 /*
- * Userspace writes configuration data to the fd and we parse it here.  For the
- * moment, we assume a single option per write.  Each line written is of the form
+ * Userspace writes configuration data and commands to the fd and we parse it
+ * here.  For the moment, we assume a single option or command per write.  Each
+ * line written is of the form
  *
  *	<option_type><space><stuff...>
+ *	<command>
  *
  *	d /dev/sda1				-- Device name
  *	o noatime				-- Option without value
  *	o cell=grand.central.org		-- Option with value
- *	r /					-- Dir within device to mount
+ *	create					-- Create a superblock
+ *	update					-- Reconfigure a superblock
  */
 static ssize_t fs_fs_write(struct file *file,
 			   const char __user *_buf, size_t len, loff_t *pos)
 {
 	struct sb_config *sc = file->private_data;
 	struct inode *inode = file_inode(file);
-	char opt[2], *data;
+	char opt[8], *data;
 	ssize_t ret;
 
 	if (len < 3 || len > 4095)
@@ -79,11 +82,21 @@ static ssize_t fs_fs_write(struct file *file,
 	case 's':
 	case 'o':
 		break;
+	case 'c':
+	case 'u':
+		if (len != 6)
+			goto err_bad_cmd;
+		if (copy_from_user(opt, _buf, 6) != 0)
+			return -EFAULT;
+		if (memcmp(opt, "create", 6) == 0 ||
+		    memcmp(opt, "update", 6) == 0)
+			break;
+		goto err_bad_cmd;
 	default:
-		return sb_cfg_inval(sc, "VFS: Unsupported write spec");
+		goto err_bad_cmd;
 	}
 	if (opt[1] != ' ')
-		return sb_cfg_inval(sc, "VFS: Unsupported write spec");
+		goto err_bad_cmd;
 
 	data = memdup_user_nul(_buf + 2, len - 2);
 	if (IS_ERR(data))
@@ -96,10 +109,6 @@ static ssize_t fs_fs_write(struct file *file,
 	if (ret < 0)
 		goto err_free;
 
-	ret = -EBUSY;
-	if (sc->mounted)
-		goto err_unlock;
-
 	ret = -EINVAL;
 	switch (opt[0]) {
 	case 's':
@@ -115,6 +124,18 @@ static ssize_t fs_fs_write(struct file *file,
 			goto err_unlock;
 		break;
 
+	case 'c':
+		ret = vfs_get_tree(sc);
+		if (ret < 0)
+			goto err_unlock;
+		break;
+
+	case 'u':
+		ret = vfs_reconfigure_super(sc);
+		if (ret < 0)
+			goto err_unlock;
+		break;
+
 	default:
 		goto err_unlock;
 	}
@@ -125,6 +146,8 @@ static ssize_t fs_fs_write(struct file *file,
 err_free:
 	kfree(data);
 	return ret;
+err_bad_cmd:
+	return sb_cfg_inval(sc, "VFS: Unsupported write spec");
 }
 
 const struct file_operations fs_fs_fops = {
diff --git a/fs/internal.h b/fs/internal.h
index 6ac2191cb59a..183f248fb819 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -89,8 +89,6 @@ extern struct file *get_empty_filp(void);
  */
 extern int do_remount_sb(struct super_block *, int, void *, int, struct sb_config *);
 extern bool trylock_super(struct super_block *sb);
-extern struct dentry *mount_fs(struct file_system_type *,
-			       int, const char *, void *);
 extern struct super_block *user_get_super(dev_t);
 
 /*
diff --git a/fs/libfs.c b/fs/libfs.c
index 2733d070b1ef..e2c2b4c48ea3 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -575,13 +575,27 @@ static DEFINE_SPINLOCK(pin_fs_lock);
 
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
index bb339252c592..3056e7fbf5ef 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -962,55 +962,6 @@ static struct mount *skip_mnt_tree(struct mount *p)
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
@@ -2286,18 +2237,12 @@ static int change_mount_flags(struct vfsmount *mnt, int ms_flags)
 static int parse_monolithic_mount_data(struct sb_config *sc, void *data)
 {
 	int (*monolithic_mount_data)(struct sb_config *, void *);
-	int ret;
 
 	monolithic_mount_data = sc->ops->monolithic_mount_data;
 	if (!monolithic_mount_data)
 		monolithic_mount_data = generic_monolithic_mount_data;
 
-	ret = monolithic_mount_data(sc, data);
-	if (ret < 0)
-		return ret;
-	if (sc->ops->validate)
-		return sc->ops->validate(sc);
-	return 0;
+	return monolithic_mount_data(sc, data);
 }
 
 /*
@@ -2461,29 +2406,6 @@ static int do_move_mount(struct path *path, const char *old_name)
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
@@ -2544,11 +2466,10 @@ static int do_new_mount_sc(struct sb_config *sc, struct path *mountpoint,
 	if (IS_ERR(mnt))
 		return PTR_ERR(mnt);
 
-	if ((sc->fs_type->fs_flags & FS_HAS_SUBTYPE) &&
-	    !mnt->mnt_sb->s_subtype) {
-		mnt = fs_set_subtype(mnt, sc->fs_type->name);
-		if (IS_ERR(mnt))
-			return PTR_ERR(mnt);
+	if (sc->subtype && !mnt->mnt_sb->s_subtype) {
+		mnt->mnt_sb->s_subtype = kstrdup(sc->subtype, GFP_KERNEL);
+		if (!mnt->mnt_sb->s_subtype)
+			return -ENOMEM;
 	}
 
 	ret = -EPERM;
@@ -2583,8 +2504,10 @@ static int do_new_mount(struct path *mountpoint, const char *fstype, int flags,
 		return -EINVAL;
 
 	sc = vfs_new_sb_config(fstype);
-	if (IS_ERR(sc))
-		return PTR_ERR(sc);
+	if (IS_ERR(sc)) {
+		err = PTR_ERR(sc);
+		goto err;
+	}
 	sc->ms_flags = flags;
 
 	err = -ENOMEM;
@@ -2596,6 +2519,10 @@ static int do_new_mount(struct path *mountpoint, const char *fstype, int flags,
 	if (err < 0)
 		goto err_sc;
 
+	err = vfs_get_tree(sc);
+	if (err < 0)
+		goto err_sc;
+
 	err = do_new_mount_sc(sc, mountpoint, mnt_flags);
 	if (err)
 		goto err_sc;
@@ -2607,6 +2534,7 @@ static int do_new_mount(struct path *mountpoint, const char *fstype, int flags,
 	if (sc->error_msg)
 		pr_info("Mount failed: %s\n", sc->error_msg);
 	put_sb_config(sc);
+err:
 	return err;
 }
 
@@ -3139,54 +3067,87 @@ SYSCALL_DEFINE5(mount, char __user *, dev_name, char __user *, dir_name,
 	return ret;
 }
 
-static struct dentry *__do_mount_sc(struct sb_config *sc)
+/**
+ * vfs_get_tree - Get the mountable root
+ * @sc: The superblock configuration context.
+ *
+ * The filesystem is invoked to get or create a superblock which can then later
+ * be used for mounting.  The filesystem places a pointer to the root to be
+ * used for mounting in @sc->root.
+ */
+int vfs_get_tree(struct sb_config *sc)
 {
 	struct super_block *sb;
-	struct dentry *root;
 	int ret;
 
-	root = sc->ops->mount(sc);
-	if (IS_ERR(root))
-		return root;
+	if (sc->root)
+		return -EBUSY;
+
+	if (sc->ops->validate) {
+		ret = sc->ops->validate(sc);
+		if (ret < 0)
+			return ret;
+	}
+
+	/* We assume that the filesystem may transfer preallocated resources
+	 * from the configuration context to the superblock, thereby rendering
+	 * the config unusable for another attempt at creation if this one
+	 * fails.
+	 */
+	if (sc->degraded)
+		return sb_cfg_inval(sc, "VFS: The config is degraded");
+	sc->degraded = true;
+
+	/* Get the mountable root in sc->root, with a ref on the root and a ref
+	 * on the superblock.
+	 */
+	ret = sc->ops->get_tree(sc);
+	if (ret < 0)
+		return ret;
 
-	sb = root->d_sb;
-	BUG_ON(!sb);
+	BUG_ON(!sc->root);
+	sb = sc->root->d_sb;
 	WARN_ON(!sb->s_bdi);
-	sb->s_flags |= MS_BORN;
 
-	ret = security_sb_config_kern_mount(sc, sb);
+	ret = security_sb_get_tree(sc);
 	if (ret < 0)
 		goto err_sb;
 
-	/*
-	 * filesystems should never set s_maxbytes larger than MAX_LFS_FILESIZE
-	 * but s_maxbytes was an unsigned long long for many releases. Throw
+	sb->s_flags |= MS_BORN;
+
+	/* Filesystems should never set s_maxbytes larger than MAX_LFS_FILESIZE
+	 * but s_maxbytes was an unsigned long long for many releases.  Throw
 	 * this warning for a little while to try and catch filesystems that
 	 * violate this rule.
 	 */
-	WARN((sb->s_maxbytes < 0), "%s set sb->s_maxbytes to "
-		"negative value (%lld)\n", sc->fs_type->name, sb->s_maxbytes);
+	WARN(sb->s_maxbytes < 0,
+	     "%s set sb->s_maxbytes to negative value (%lld)\n",
+	     sc->fs_type->name, sb->s_maxbytes);
 
 	up_write(&sb->s_umount);
-	return root;
+	return 0;
 
 err_sb:
-	dput(root);
+	dput(sc->root);
+	sc->root = NULL;
 	deactivate_locked_super(sb);
-	return ERR_PTR(ret);
+	return ret;
 }
+EXPORT_SYMBOL(vfs_get_tree);
 
+/**
+ * vfs_kern_mount_sc - Create a mount for a configured superblock
+ * sc: The configuration context with the superblock attached
+ *
+ * Create a mount to an already configured superblock.  If necessary, the
+ * caller should invoke vfs_create_super() before calling this.
+ */
 struct vfsmount *vfs_kern_mount_sc(struct sb_config *sc)
 {
-	struct dentry *root;
 	struct mount *mnt;
-	int ret;
 
-	if (sc->ops->validate) {
-		ret = sc->ops->validate(sc);
-		if (ret < 0)
-			return ERR_PTR(ret);
-	}
+	if (!sc->root)
+		return ERR_PTR(sb_cfg_inval(sc, "VFS: Root must be obtained before mount"));
 
 	mnt = alloc_vfsmnt(sc->device ?: "none");
 	if (!mnt)
@@ -3195,24 +3156,65 @@ struct vfsmount *vfs_kern_mount_sc(struct sb_config *sc)
 	if (sc->ms_flags & MS_KERNMOUNT)
 		mnt->mnt.mnt_flags = MNT_INTERNAL;
 
-	root = __do_mount_sc(sc);
-	if (IS_ERR(root)) {
-		mnt_free_id(mnt);
-		free_vfsmnt(mnt);
-		return ERR_CAST(root);
-	}
-
-	mnt->mnt.mnt_root	= root;
-	mnt->mnt.mnt_sb		= root->d_sb;
+	atomic_inc(&sc->root->d_sb->s_active);
+	mnt->mnt.mnt_sb		= sc->root->d_sb;
+	mnt->mnt.mnt_root	= dget(sc->root);
 	mnt->mnt_mountpoint	= mnt->mnt.mnt_root;
 	mnt->mnt_parent		= mnt;
+
 	lock_mount_hash();
-	list_add_tail(&mnt->mnt_instance, &root->d_sb->s_mounts);
+	list_add_tail(&mnt->mnt_instance, &mnt->mnt.mnt_sb->s_mounts);
 	unlock_mount_hash();
 	return &mnt->mnt;
 }
 EXPORT_SYMBOL_GPL(vfs_kern_mount_sc);
 
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
+	if (sc->error_msg)
+		pr_info("Kernmount failed: %s\n", sc->error_msg);
+	put_sb_config(sc);
+	return ERR_PTR(ret);
+}
+EXPORT_SYMBOL_GPL(vfs_kern_mount);
+
 struct vfsmount *
 vfs_submount_sc(const struct dentry *mountpoint, struct sb_config *sc)
 {
@@ -3228,6 +3230,21 @@ vfs_submount_sc(const struct dentry *mountpoint, struct sb_config *sc)
 }
 EXPORT_SYMBOL_GPL(vfs_submount_sc);
 
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
  * Mount a new, prepared superblock (specified by fs_fd) on the location
  * specified by dfd and dir_name.  dfd can be AT_FDCWD, a dir fd or a container
@@ -3286,17 +3303,14 @@ SYSCALL_DEFINE5(fsmount, int, fs_fd, int, dfd, const char __user *, dir_name,
 	    ((sc->ms_flags & MS_MANDLOCK) && !may_mandlock()))
 		goto err_fsfd;
 
-	/* Prevent further changes. */
+	/* There must be a valid superblock or we can't mount it */
 	inode = file_inode(f.file);
 	ret = inode_lock_killable(inode);
-	if (ret < 0)
-		goto err_fsfd;
-	ret = -EBUSY;
-	if (!sc->mounted) {
-		sc->mounted = true;
-		ret = 0;
+	if (ret == 0) {
+		if (!sc->root)
+			ret = sb_cfg_inval(sc, "VFS: Root must be obtained before mount");
+		inode_unlock(inode);
 	}
-	inode_unlock(inode);
 	if (ret < 0)
 		goto err_fsfd;
 
diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index 391dafaf9182..f564ab76708f 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -66,68 +66,72 @@ static int nfs_superblock_set_dummy_root(struct super_block *sb, struct inode *i
 }
 
 /*
- * get an NFS2/NFS3 root dentry from the root filehandle
+ * get an NFS2/NFS3 root dentry from the root filehandle.
  */
-struct dentry *nfs_get_root(struct super_block *sb, struct nfs_fh *mntfh,
-			    const char *devname)
+int nfs_get_root(struct super_block *s, struct nfs_sb_config *cfg)
 {
-	struct nfs_server *server = NFS_SB(sb);
+	struct nfs_server *server = NFS_SB(s);
 	struct nfs_fsinfo fsinfo;
-	struct dentry *ret;
+	struct dentry *root;
 	struct inode *inode;
-	void *name = kstrdup(devname, GFP_KERNEL);
-	int error;
+	char *name;
+	int error = -ENOMEM;
 
+	name = kstrdup(cfg->sc.device, GFP_KERNEL);
 	if (!name)
-		return ERR_PTR(-ENOMEM);
-
+		goto out;
+	
 	/* get the actual root for this mount */
 	fsinfo.fattr = nfs_alloc_fattr();
-	if (fsinfo.fattr == NULL) {
-		kfree(name);
-		return ERR_PTR(-ENOMEM);
-	}
+	if (fsinfo.fattr == NULL)
+		goto out_name;
 
-	error = server->nfs_client->rpc_ops->getroot(server, mntfh, &fsinfo);
+	error = server->nfs_client->rpc_ops->getroot(server, cfg->mntfh, &fsinfo);
 	if (error < 0) {
 		dprintk("nfs_get_root: getattr error = %d\n", -error);
-		ret = ERR_PTR(error);
-		goto out;
+		nfs_cfg_error(cfg, "NFS: Couldn't getattr on root");
+		goto out_fattr;
 	}
 
-	inode = nfs_fhget(sb, mntfh, fsinfo.fattr, NULL);
+	inode = nfs_fhget(s, cfg->mntfh, fsinfo.fattr, NULL);
 	if (IS_ERR(inode)) {
 		dprintk("nfs_get_root: get root inode failed\n");
-		ret = ERR_CAST(inode);
-		goto out;
+		error = PTR_ERR(inode);
+		nfs_cfg_error(cfg, "NFS: Couldn't get root inode");
+		goto out_fattr;
 	}
 
-	error = nfs_superblock_set_dummy_root(sb, inode);
-	if (error != 0) {
-		ret = ERR_PTR(error);
-		goto out;
-	}
+	error = nfs_superblock_set_dummy_root(s, inode);
+	if (error != 0)
+		goto out_fattr;
 
 	/* root dentries normally start off anonymous and get spliced in later
 	 * if the dentry tree reaches them; however if the dentry already
 	 * exists, we'll pick it up at this point and use it as the root
 	 */
-	ret = d_obtain_root(inode);
-	if (IS_ERR(ret)) {
+	root = d_obtain_root(inode);
+	if (IS_ERR(root)) {
 		dprintk("nfs_get_root: get root dentry failed\n");
-		goto out;
+		error = PTR_ERR(root);
+		nfs_cfg_error(cfg, "NFS: Couldn't get root dentry");
+		goto out_fattr;
 	}
 
-	security_d_instantiate(ret, inode);
-	spin_lock(&ret->d_lock);
-	if (IS_ROOT(ret) && !ret->d_fsdata &&
-	    !(ret->d_flags & DCACHE_NFSFS_RENAMED)) {
-		ret->d_fsdata = name;
+	security_d_instantiate(root, inode);
+	spin_lock(&root->d_lock);
+	if (IS_ROOT(root) && !root->d_fsdata &&
+	    !(root->d_flags & DCACHE_NFSFS_RENAMED)) {
+		root->d_fsdata = name;
 		name = NULL;
 	}
-	spin_unlock(&ret->d_lock);
-out:
-	kfree(name);
+	spin_unlock(&root->d_lock);
+	cfg->sc.root = root;
+	error = 0;
+
+out_fattr:
 	nfs_free_fattr(fsinfo.fattr);
-	return ret;
+out_name:
+	kfree(name);
+out:
+	return error;
 }
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 11017c30b94d..5f63456df555 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -131,8 +131,7 @@ struct nfs_sb_config {
 	struct nfs_fh		*mntfh;
 	struct nfs_subversion	*nfs_mod;
 
-	int (*set_security)(struct super_block *, struct dentry *,
-			    struct nfs_sb_config *);
+	int (*set_security)(struct super_block *, struct nfs_sb_config *);
 
 	/* Information for a cloned mount. */
 	struct nfs_clone_mount {
@@ -416,10 +415,10 @@ extern int nfs_wait_atomic_killable(atomic_t *p);
 extern const struct super_operations nfs_sops;
 extern struct file_system_type nfs_fs_type;
 bool nfs_auth_info_match(const struct nfs_auth_info *, rpc_authflavor_t);
-struct dentry *nfs_try_mount(struct nfs_sb_config *);
-int nfs_set_sb_security(struct super_block *, struct dentry *, struct nfs_sb_config *);
-int nfs_clone_sb_security(struct super_block *, struct dentry *, struct nfs_sb_config *);
-struct dentry *nfs_fs_mount_common(struct nfs_server *, struct nfs_sb_config *);
+int nfs_try_get_tree(struct nfs_sb_config *);
+int nfs_set_sb_security(struct super_block *, struct nfs_sb_config *);
+int nfs_clone_sb_security(struct super_block *, struct nfs_sb_config *);
+int nfs_get_tree_common(struct nfs_server *, struct nfs_sb_config *);
 void nfs_kill_super(struct super_block *);
 int nfs_fill_super(struct super_block *, struct nfs_sb_config *);
 
@@ -454,12 +453,9 @@ struct vfsmount *nfs_do_submount(struct dentry *, struct nfs_fh *,
 				 struct nfs_fattr *, rpc_authflavor_t);
 
 /* getroot.c */
-extern struct dentry *nfs_get_root(struct super_block *, struct nfs_fh *,
-				   const char *);
+extern int nfs_get_root(struct super_block *s, struct nfs_sb_config *cfg);
 #if IS_ENABLED(CONFIG_NFS_V4)
-extern struct dentry *nfs4_get_root(struct super_block *, struct nfs_fh *,
-				    const char *);
-
+extern int nfs4_get_root(struct super_block *s, struct nfs_sb_config *cfg);
 extern int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh, bool);
 #endif
 
diff --git a/fs/nfs/mount.c b/fs/nfs/mount.c
index c930857413cb..ddbf5b44d2ca 100644
--- a/fs/nfs/mount.c
+++ b/fs/nfs/mount.c
@@ -1274,20 +1274,20 @@ static int nfs_sb_config_validate(struct sb_config *sc)
 /*
  * Use the preparsed information in the mount context to effect a mount.
  */
-static struct dentry *nfs_ordinary_mount(struct nfs_sb_config *cfg)
+static int nfs_get_ordinary_tree(struct nfs_sb_config *cfg)
 {
 	cfg->set_security = nfs_set_sb_security;
 
-	return cfg->nfs_mod->rpc_ops->try_mount(cfg);
+	return cfg->nfs_mod->rpc_ops->try_get_tree(cfg);
 }
 
 /*
  * Clone an NFS2/3/4 server record on xdev traversal (FSID-change)
  */
-static struct dentry *nfs_xdev_mount(struct nfs_sb_config *cfg)
+static int nfs_get_xdev_tree(struct nfs_sb_config *cfg)
 {
 	struct nfs_server *server;
-	struct dentry *mntroot = ERR_PTR(-ENOMEM);
+	int ret;
 
 	dprintk("--> nfs_xdev_mount()\n");
 
@@ -1300,52 +1300,48 @@ static struct dentry *nfs_xdev_mount(struct nfs_sb_config *cfg)
 						     cfg->selected_flavor);
 
 	if (IS_ERR(server))
-		mntroot = ERR_CAST(server);
+		ret = PTR_ERR(server);
 	else
-		mntroot = nfs_fs_mount_common(server, cfg);
+		ret = nfs_get_tree_common(server, cfg);
 
-	dprintk("<-- nfs_xdev_mount() = %ld\n",
-			IS_ERR(mntroot) ? PTR_ERR(mntroot) : 0L);
-	return mntroot;
+	dprintk("<-- nfs_get_xdev_tree() = %d\n", ret);
+	return ret;
 }
 
 /*
- * Handle ordinary mounts inspired by the user and cross-FSID mounts.
+ * Create an NFS superblock by the appropriate method.
  */
-struct dentry *nfs_general_mount(struct nfs_sb_config *cfg)
-{
-	switch (cfg->mount_type) {
-	case NFS_MOUNT_ORDINARY:
-		return nfs_ordinary_mount(cfg);
-
-	case NFS_MOUNT_CROSS_DEV:
-		return nfs_xdev_mount(cfg);
-
-	default:
-		nfs_cfg_error(cfg, "NFS: Unknown mount type");
-		return ERR_PTR(-ENOTSUPP);
-	}
-}
-EXPORT_SYMBOL_GPL(nfs_general_mount);
-
-static struct dentry *nfs_fs_mount(struct sb_config *sc)
+static int nfs_get_tree(struct sb_config *sc)
 {
 	struct nfs_sb_config *cfg = container_of(sc, struct nfs_sb_config, sc);
+	int ret;
 
 	if (!cfg->nfs_mod) {
 		pr_warn("Missing nfs_mod\n");
-		return ERR_PTR(-EINVAL);
+		return -EINVAL;
 	}
 	if (!cfg->nfs_mod->rpc_ops) {
 		pr_warn("Missing rpc_ops\n");
-		return ERR_PTR(-EINVAL);
+		return -EINVAL;
 	}
-	if (!cfg->nfs_mod->rpc_ops->mount) {
-		pr_warn("Missing mount\n");
-		return ERR_PTR(-EINVAL);
+
+	if (cfg->nfs_mod->rpc_ops->get_tree) {
+		ret = cfg->nfs_mod->rpc_ops->get_tree(cfg);
+		if (ret != 1)
+			return ret;
 	}
 
-	return cfg->nfs_mod->rpc_ops->mount(cfg);
+	switch (cfg->mount_type) {
+	case NFS_MOUNT_ORDINARY:
+		return nfs_get_ordinary_tree(cfg);
+
+	case NFS_MOUNT_CROSS_DEV:
+		return nfs_get_xdev_tree(cfg);
+
+	default:
+		nfs_cfg_error(cfg, "NFS: Unknown mount type");
+		return -ENOTSUPP;
+	}
 }
 
 /*
@@ -1392,7 +1388,7 @@ static const struct sb_config_operations nfs_sb_config_ops = {
 	.parse_option		= nfs_sb_config_parse_option,
 	.monolithic_mount_data	= nfs_monolithic_mount_data,
 	.validate		= nfs_sb_config_validate,
-	.mount			= nfs_fs_mount,
+	.get_tree		= nfs_get_tree,
 };
 
 /*
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 1e0349fc33ec..1a8d0f832bda 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -922,9 +922,8 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.file_inode_ops	= &nfs3_file_inode_operations,
 	.file_ops	= &nfs_file_operations,
 	.getroot	= nfs3_proc_get_root,
-	.mount		= nfs_general_mount,
 	.submount	= nfs_submount,
-	.try_mount	= nfs_try_mount,
+	.try_get_tree	= nfs_try_get_tree,
 	.getattr	= nfs3_proc_getattr,
 	.setattr	= nfs3_proc_setattr,
 	.lookup		= nfs3_proc_lookup,
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 05769b633b76..effcea28d7cc 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -476,8 +476,8 @@ extern bool recover_lost_locks;
 #define NFS4_CLIENT_ID_UNIQ_LEN		(64)
 extern char nfs4_client_id_uniquifier[NFS4_CLIENT_ID_UNIQ_LEN];
 
-extern struct dentry *nfs4_try_mount(struct nfs_sb_config *);
-extern struct dentry *nfs4_mount(struct nfs_sb_config *);
+extern int nfs4_try_get_tree(struct nfs_sb_config *);
+extern int nfs4_get_tree(struct nfs_sb_config *);
 
 /* nfs4sysctl.c */
 #ifdef CONFIG_SYSCTL
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 32d8c10bc45e..da1fb302ee61 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -9318,9 +9318,9 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.file_inode_ops	= &nfs4_file_inode_operations,
 	.file_ops	= &nfs4_file_operations,
 	.getroot	= nfs4_proc_get_root,
-	.mount		= nfs4_mount,
+	.get_tree	= nfs4_get_tree,
 	.submount	= nfs4_submount,
-	.try_mount	= nfs4_try_mount,
+	.try_get_tree	= nfs4_try_get_tree,
 	.getattr	= nfs4_proc_getattr,
 	.setattr	= nfs4_proc_setattr,
 	.lookup		= nfs4_proc_lookup,
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 7bc27a28d5da..853e20a25333 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -18,9 +18,6 @@
 
 static int nfs4_write_inode(struct inode *inode, struct writeback_control *wbc);
 static void nfs4_evict_inode(struct inode *inode);
-static struct dentry *nfs4_remote_mount(struct nfs_sb_config *cfg);
-static struct dentry *nfs4_referral_mount(struct nfs_sb_config *cfg);
-static struct dentry *nfs4_remote_referral_mount(struct nfs_sb_config *cfg);
 
 static const struct super_operations nfs4_sops = {
 	.alloc_inode	= nfs_alloc_inode,
@@ -77,7 +74,7 @@ static void nfs4_evict_inode(struct inode *inode)
 /*
  * Get the superblock for the NFS4 root partition
  */
-static struct dentry *nfs4_remote_mount(struct nfs_sb_config *cfg)
+static int nfs4_get_remote_tree(struct nfs_sb_config *cfg)
 {
 	struct nfs_server *server;
 
@@ -86,9 +83,9 @@ static struct dentry *nfs4_remote_mount(struct nfs_sb_config *cfg)
 	/* Get a volume representation */
 	server = nfs4_create_server(cfg);
 	if (IS_ERR(server))
-		return ERR_CAST(server);
+		return PTR_ERR(server);
 
-	return nfs_fs_mount_common(server, cfg);
+	return nfs_get_tree_common(server, cfg);
 }
 
 /*
@@ -104,6 +101,7 @@ static struct vfsmount *nfs_do_root_mount(struct nfs_sb_config *cfg,
 	struct vfsmount *root_mnt;
 	char *root_devname;
 	size_t len;
+	int ret;
 
 	root_sc = vfs_dup_sb_config(&cfg->sc);
 	if (IS_ERR(root_sc))
@@ -126,6 +124,10 @@ static struct vfsmount *nfs_do_root_mount(struct nfs_sb_config *cfg,
 		snprintf(root_devname, len, "%s:/", hostname);
 	root_cfg->sc.device = root_devname;
 
+	ret = vfs_get_tree(&root_cfg->sc);
+	if (ret < 0)
+		return ERR_PTR(ret);
+
 	root_mnt = vfs_kern_mount_sc(&root_cfg->sc);
 out_sc:
 	put_sb_config(root_sc);
@@ -219,12 +221,12 @@ static struct dentry *nfs_follow_remote_path(struct vfsmount *root_mnt,
 	return dentry;
 }
 
-struct dentry *nfs4_try_mount(struct nfs_sb_config *cfg)
+int nfs4_try_get_tree(struct nfs_sb_config *cfg)
 {
 	struct vfsmount *root_mnt;
-	struct dentry *res;
+	struct dentry *root;
 
-	dfprintk(MOUNT, "--> nfs4_try_mount()\n");
+	dfprintk(MOUNT, "--> nfs4_try_get_tree()\n");
 
 	/* We create a mount for the server's root, walk to the requested
 	 * location and then create another mount for that.
@@ -232,74 +234,83 @@ struct dentry *nfs4_try_mount(struct nfs_sb_config *cfg)
 	root_mnt = nfs_do_root_mount(cfg, cfg->nfs_server.hostname,
 				     NFS4_MOUNT_REMOTE);
 	if (IS_ERR(root_mnt))
-		return ERR_CAST(root_mnt);
+		return PTR_ERR(root_mnt);
 
-	res = nfs_follow_remote_path(root_mnt, cfg->nfs_server.export_path);
-	if (IS_ERR(res))
+	root = nfs_follow_remote_path(root_mnt, cfg->nfs_server.export_path);
+	if (IS_ERR(root)) {
 		nfs_cfg_error(cfg, "NFS4: Couldn't follow remote path");
+		dfprintk(MOUNT, "<-- nfs4_try_mount() = %ld [error]\n",
+			 PTR_ERR(root));
+		return PTR_ERR(root);
+	}
 
-	dfprintk(MOUNT, "<-- nfs4_try_mount() = %d%s\n",
-		 PTR_ERR_OR_ZERO(res),
-		 IS_ERR(res) ? " [error]" : "");
-	return res;
+	cfg->sc.root = root;
+	dfprintk(MOUNT, "<-- nfs4_try_get_tree() = 0\n");
+	return 0;
 }
 
-static struct dentry *nfs4_remote_referral_mount(struct nfs_sb_config *cfg)
+static int nfs4_get_remote_referral_tree(struct nfs_sb_config *cfg)
 {
 	struct nfs_server *server;
 
-	dprintk("--> nfs4_referral_get_sb()\n");
+	dprintk("--> nfs4_get_remote_referral_tree()\n");
 
 	cfg->set_security = nfs_clone_sb_security;
 
 	if (!cfg->clone_data.cloned)
-		return ERR_PTR(-EINVAL);
+		return -EINVAL;
 
 	/* create a new volume representation */
 	server = nfs4_create_referral_server(cfg);
 	if (IS_ERR(server))
-		return ERR_CAST(server);
+		return PTR_ERR(server);
 
-	return nfs_fs_mount_common(server, cfg);
+	return nfs_get_tree_common(server, cfg);
 }
 
 /*
  * Create an NFS4 server record on referral traversal
  */
-static struct dentry *nfs4_referral_mount(struct nfs_sb_config *cfg)
+static int nfs4_get_referral_tree(struct nfs_sb_config *cfg)
 {
 	struct vfsmount *root_mnt;
-	struct dentry *res;
+	struct dentry *root;
 
 	dprintk("--> nfs4_referral_mount()\n");
 
 	root_mnt = nfs_do_root_mount(cfg, cfg->nfs_server.hostname,
 				     NFS4_MOUNT_REMOTE_REFERRAL);
 
-	res = nfs_follow_remote_path(root_mnt, cfg->nfs_server.export_path);
-	dprintk("<-- nfs4_referral_mount() = %d%s\n",
-		PTR_ERR_OR_ZERO(res),
-		IS_ERR(res) ? " [error]" : "");
-	return res;
+	root = nfs_follow_remote_path(root_mnt, cfg->nfs_server.export_path);
+	if (IS_ERR(root)) {
+		nfs_cfg_error(cfg, "NFS4: Couldn't follow remote path");
+		dfprintk(MOUNT, "<-- nfs4_referral_mount() = %ld [error]\n",
+			 PTR_ERR(root));
+		return PTR_ERR(root);
+	}
+
+	cfg->sc.root = root;
+	dfprintk(MOUNT, "<-- nfs4_get_referral_tree() = 0\n");
+	return 0;
 }
 
 /*
  * Handle special NFS4 mount types.
  */
-struct dentry *nfs4_mount(struct nfs_sb_config *cfg)
+int nfs4_get_tree(struct nfs_sb_config *cfg)
 {
 	switch (cfg->mount_type) {
 	case NFS4_MOUNT_REMOTE:
-		return nfs4_remote_mount(cfg);
+		return nfs4_get_remote_tree(cfg);
 
 	case NFS4_MOUNT_REFERRAL:
-		return nfs4_referral_mount(cfg);
+		return nfs4_get_referral_tree(cfg);
 
 	case NFS4_MOUNT_REMOTE_REFERRAL:
-		return nfs4_remote_referral_mount(cfg);
+		return nfs4_get_remote_referral_tree(cfg);
 
 	default:
-		return nfs_general_mount(cfg);
+		return 1;
 	}
 }
 
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index edae9cd50412..9f1cae2a101c 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -704,9 +704,8 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.file_inode_ops	= &nfs_file_inode_operations,
 	.file_ops	= &nfs_file_operations,
 	.getroot	= nfs_proc_get_root,
-	.mount		= nfs_general_mount,
 	.submount	= nfs_submount,
-	.try_mount	= nfs_try_mount,
+	.try_get_tree	= nfs_try_get_tree,
 	.getattr	= nfs_proc_getattr,
 	.setattr	= nfs_proc_setattr,
 	.lookup		= nfs_proc_lookup,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 8551bfb4e7da..32918f67d1fe 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -855,7 +855,7 @@ static struct nfs_server *nfs_try_mount_request(struct nfs_sb_config *cfg)
 	return cfg->nfs_mod->rpc_ops->create_server(cfg);
 }
 
-struct dentry *nfs_try_mount(struct nfs_sb_config *cfg)
+int nfs_try_get_tree(struct nfs_sb_config *cfg)
 {
 	struct nfs_server *server;
 
@@ -866,12 +866,12 @@ struct dentry *nfs_try_mount(struct nfs_sb_config *cfg)
 
 	if (IS_ERR(server)) {
 		nfs_cfg_error(cfg, "NFS: Couldn't create server");
-		return ERR_CAST(server);
+		return PTR_ERR(server);
 	}
 
-	return nfs_fs_mount_common(server, cfg);
+	return nfs_get_tree_common(server, cfg);
 }
-EXPORT_SYMBOL_GPL(nfs_try_mount);
+EXPORT_SYMBOL_GPL(nfs_try_get_tree);
 
 
 #define NFS_REMOUNT_CMP_FLAGMASK ~(NFS_MOUNT_INTR \
@@ -1179,40 +1179,38 @@ static void nfs_get_cache_cookie(struct super_block *sb,
 }
 #endif
 
-int nfs_set_sb_security(struct super_block *s, struct dentry *mntroot,
-			struct nfs_sb_config *cfg)
+int nfs_set_sb_security(struct super_block *sb, struct nfs_sb_config *cfg)
 {
 	int error;
 	unsigned long kflags = 0, kflags_out = 0;
 
-	if (NFS_SB(s)->caps & NFS_CAP_SECURITY_LABEL)
+	if (NFS_SB(sb)->caps & NFS_CAP_SECURITY_LABEL)
 		kflags |= SECURITY_LSM_NATIVE_LABELS;
 
-	error = security_sb_set_mnt_opts(s, cfg->sc.security,
+	error = security_sb_set_mnt_opts(sb, cfg->sc.security,
 					 kflags, &kflags_out);
 	if (error)
 		goto err;
 
-	if (NFS_SB(s)->caps & NFS_CAP_SECURITY_LABEL &&
-		!(kflags_out & SECURITY_LSM_NATIVE_LABELS))
-		NFS_SB(s)->caps &= ~NFS_CAP_SECURITY_LABEL;
+	if (NFS_SB(sb)->caps & NFS_CAP_SECURITY_LABEL &&
+	    !(kflags_out & SECURITY_LSM_NATIVE_LABELS))
+		NFS_SB(sb)->caps &= ~NFS_CAP_SECURITY_LABEL;
 err:
 	return error;
 }
 EXPORT_SYMBOL_GPL(nfs_set_sb_security);
 
-int nfs_clone_sb_security(struct super_block *s, struct dentry *mntroot,
-			  struct nfs_sb_config *cfg)
+int nfs_clone_sb_security(struct super_block *sb, struct nfs_sb_config *cfg)
 {
 	/* clone any lsm security options from the parent to the new sb */
-	if (d_inode(mntroot)->i_op != NFS_SB(s)->nfs_client->rpc_ops->dir_inode_ops)
+	if (d_inode(cfg->sc.root)->i_op !=
+	    NFS_SB(sb)->nfs_client->rpc_ops->dir_inode_ops)
 		return -ESTALE;
-	return security_sb_clone_mnt_opts(cfg->clone_data.sb, s);
+	return security_sb_clone_mnt_opts(cfg->clone_data.sb, sb);
 }
 EXPORT_SYMBOL_GPL(nfs_clone_sb_security);
 
-struct dentry *nfs_fs_mount_common(struct nfs_server *server,
-				   struct nfs_sb_config *cfg)
+int nfs_get_tree_common(struct nfs_server *server, struct nfs_sb_config *cfg)
 {
 	struct super_block *s;
 	struct dentry *mntroot = ERR_PTR(-ENOMEM);
@@ -1238,7 +1236,7 @@ struct dentry *nfs_fs_mount_common(struct nfs_server *server,
 	s = sget(cfg->nfs_mod->nfs_fs, compare_super, nfs_set_super, cfg->sc.ms_flags,
 		 &sb_mntdata);
 	if (IS_ERR(s)) {
-		mntroot = ERR_CAST(s);
+		error = PTR_ERR(s);
 		nfs_cfg_error(cfg, "NFS: Couldn't get superblock");
 		goto out_err_nosb;
 	}
@@ -1256,20 +1254,21 @@ struct dentry *nfs_fs_mount_common(struct nfs_server *server,
 		nfs_get_cache_cookie(s, cfg);
 	}
 
-	mntroot = nfs_get_root(s, cfg->mntfh, cfg->sc.device);
-	if (IS_ERR(mntroot)) {
+	error = nfs_get_root(s, cfg);
+	if (error < 0) {
 		nfs_cfg_error(cfg, "NFS: Couldn't get root dentry");
 		goto error_splat_super;
 	}
 
-	error = cfg->set_security(s, mntroot, cfg);
+	error = cfg->set_security(s, cfg);
 	if (error)
 		goto error_splat_root;
 
 	s->s_flags |= MS_ACTIVE;
+	error = 0;
 
 out:
-	return mntroot;
+	return error;
 
 out_err_nosb:
 	nfs_free_server(server);
@@ -1277,12 +1276,11 @@ struct dentry *nfs_fs_mount_common(struct nfs_server *server,
 
 error_splat_root:
 	dput(mntroot);
-	mntroot = ERR_PTR(error);
 error_splat_super:
 	deactivate_locked_super(s);
 	goto out;
 }
-EXPORT_SYMBOL_GPL(nfs_fs_mount_common);
+EXPORT_SYMBOL_GPL(nfs_get_tree_common);
 
 /*
  * Destroy an NFS2/3 superblock
diff --git a/fs/proc/root.c b/fs/proc/root.c
index da5757d1c518..8781415be2e0 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -148,7 +148,7 @@ int proc_remount(struct super_block *sb, struct sb_config *sc)
 	return 0;
 }
 
-static struct dentry *proc_mount(struct sb_config *sc)
+static int proc_get_tree(struct sb_config *sc)
 {
 	struct proc_sb_config *cfg = container_of(sc, struct proc_sb_config, sc);
 
@@ -166,7 +166,7 @@ static void proc_sb_config_free(struct sb_config *sc)
 static const struct sb_config_operations proc_sb_config_ops = {
 	.free		= proc_sb_config_free,
 	.parse_option	= proc_parse_mount_option,
-	.mount		= proc_mount,
+	.get_tree	= proc_get_tree,
 };
 
 static int proc_init_sb_config(struct sb_config *sc, struct super_block *src_sb)
@@ -298,6 +298,7 @@ int pid_ns_prepare_proc(struct pid_namespace *ns)
 	struct proc_sb_config *cfg;
 	struct sb_config *sc;
 	struct vfsmount *mnt;
+	int ret;
 
 	sc = __vfs_new_sb_config(&proc_fs_type, NULL, 0, SB_CONFIG_FOR_NEW);
 	if (IS_ERR(sc))
@@ -310,6 +311,12 @@ int pid_ns_prepare_proc(struct pid_namespace *ns)
 		cfg->pid_ns = ns;
 	}
 
+	ret = vfs_get_tree(sc);
+	if (ret < 0) {
+		put_sb_config(sc);
+		return ret;
+	}
+
 	mnt = kern_mount_data_sc(sc);
 	put_sb_config(sc);
 	if (IS_ERR(mnt))
diff --git a/fs/sb_config.c b/fs/sb_config.c
index 62e309cd62ef..6b6853b6d769 100644
--- a/fs/sb_config.c
+++ b/fs/sb_config.c
@@ -127,9 +127,6 @@ int vfs_parse_mount_option(struct sb_config *sc, char *p)
 {
 	int ret;
 
-	if (sc->mounted)
-		return -EBUSY;
-
 	ret = vfs_parse_ms_mount_option(sc, p);
 	if (ret < 0)
 		return ret;
@@ -324,19 +321,44 @@ struct sb_config *vfs_dup_sb_config(struct sb_config *src_sc)
 EXPORT_SYMBOL(vfs_dup_sb_config);
 
 /**
+ * vfs_reconfigure_super - Reconfigure a superblock.
+ * @sc: The configuration updates to apply
+ */
+int vfs_reconfigure_super(struct sb_config *sc)
+{
+	pr_notice("*** vfs_reconfigure_super()\n");
+
+	if (!sc->root)
+		return -EINVAL;
+	return -ENOANO; // TODO
+}
+EXPORT_SYMBOL(vfs_reconfigure_super);
+
+/**
  * put_sb_config - Dispose of a superblock configuration context.
  * @sc: The context to dispose of.
  */
 void put_sb_config(struct sb_config *sc)
 {
+	struct super_block *sb;
+
+	if (sc->root) {
+		sb = sc->root->d_sb;
+		dput(sc->root);
+		sc->root = NULL;
+		deactivate_super(sb);
+	}
+
 	if (sc->ops && sc->ops->free)
 		sc->ops->free(sc);
+
 	security_sb_config_free(sc);
 	if (sc->net_ns)
 		put_net(sc->net_ns);
 	put_user_ns(sc->user_ns);
 	if (sc->cred)
 		put_cred(sc->cred);
+	kfree(sc->subtype);
 	put_filesystem(sc->fs_type);
 	kfree(sc->device);
 	kfree(sc);
@@ -438,9 +460,30 @@ static int legacy_validate(struct sb_config *sc)
 }
 
 /*
- * Perform a legacy mount.
+ * Determine the superblock subtype.
  */
-static struct dentry *legacy_mount(struct sb_config *sc)
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
 {
 	struct legacy_sb_config *cfg = container_of(sc, struct legacy_sb_config, sc);
 	struct super_block *sb;
@@ -448,22 +491,27 @@ static struct dentry *legacy_mount(struct sb_config *sc)
 	int ret;
 
 	root = cfg->sc.fs_type->mount(cfg->sc.fs_type, cfg->sc.ms_flags,
-				     cfg->sc.device, cfg->legacy_data);
+				      cfg->sc.device, cfg->legacy_data);
 	if (IS_ERR(root))
-		return ERR_CAST(root);
+		return PTR_ERR(root);
 
 	sb = root->d_sb;
 	BUG_ON(!sb);
-	ret = security_sb_kern_mount(sb, cfg->sc.ms_flags, cfg->secdata);
-	if (ret < 0)
-		goto err_sb;
 
-	return root;
+	if ((cfg->sc.fs_type->fs_flags & FS_HAS_SUBTYPE) &&
+	    !sc->subtype) {
+		ret = legacy_set_subtype(sc);
+		if (ret < 0)
+			goto err_sb;
+	}
+
+	cfg->sc.root = root;
+	return 0;
 
 err_sb:
 	dput(root);
 	deactivate_locked_super(sb);
-	return ERR_PTR(ret);
+	return ret;
 }
 
 static const struct sb_config_operations legacy_sb_config_ops = {
@@ -472,5 +520,5 @@ static const struct sb_config_operations legacy_sb_config_ops = {
 	.parse_option		= legacy_parse_option,
 	.monolithic_mount_data	= legacy_monolithic_mount_data,
 	.validate		= legacy_validate,
-	.mount			= legacy_mount,
+	.get_tree		= legacy_get_tree,
 };
diff --git a/fs/super.c b/fs/super.c
index 4d923a775bd0..7ca217552977 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -1058,10 +1058,9 @@ struct dentry *mount_ns(struct file_system_type *fs_type,
 
 EXPORT_SYMBOL(mount_ns);
 
-struct dentry *mount_ns_sc(struct sb_config *sc,
-			   int (*fill_super)(struct super_block *sb,
-					     struct sb_config *sc),
-			   void *ns)
+int mount_ns_sc(struct sb_config *sc,
+		int (*fill_super)(struct super_block *sb, struct sb_config *sc),
+		void *ns)
 {
 	struct super_block *sb;
 
@@ -1070,25 +1069,29 @@ struct dentry *mount_ns_sc(struct sb_config *sc,
 	 */
 	if (!(sc->ms_flags & MS_KERNMOUNT) &&
 	    !ns_capable(sc->user_ns, CAP_SYS_ADMIN))
-		return ERR_PTR(-EPERM);
+		return -EPERM;
 
 	sb = sget_userns(sc->fs_type, ns_test_super, ns_set_super,
 			 sc->ms_flags, sc->user_ns, ns);
 	if (IS_ERR(sb))
-		return ERR_CAST(sb);
+		return PTR_ERR(sb);
 
 	if (!sb->s_root) {
 		int err;
 		err = fill_super(sb, sc);
 		if (err) {
 			deactivate_locked_super(sb);
-			return ERR_PTR(err);
+			return err;
 		}
 
 		sb->s_flags |= MS_ACTIVE;
 	}
 
-	return dget(sb->s_root);
+	if (!sc->root) {
+		sc->root = sb->s_root;
+		dget(sb->s_root);
+	}
+	return 0;
 }
 EXPORT_SYMBOL(mount_ns_sc);
 
@@ -1246,59 +1249,6 @@ struct dentry *mount_single(struct file_system_type *fs_type,
 }
 EXPORT_SYMBOL(mount_single);
 
-struct dentry *
-mount_fs(struct file_system_type *type, int flags, const char *name, void *data)
-{
-	struct dentry *root;
-	struct super_block *sb;
-	char *secdata = NULL;
-	int error = -ENOMEM;
-
-	if (data && !(type->fs_flags & FS_BINARY_MOUNTDATA)) {
-		secdata = alloc_secdata();
-		if (!secdata)
-			goto out;
-
-		error = security_sb_copy_data(data, secdata);
-		if (error)
-			goto out_free_secdata;
-	}
-
-	root = type->mount(type, flags, name, data);
-	if (IS_ERR(root)) {
-		error = PTR_ERR(root);
-		goto out_free_secdata;
-	}
-	sb = root->d_sb;
-	BUG_ON(!sb);
-	WARN_ON(!sb->s_bdi);
-	sb->s_flags |= MS_BORN;
-
-	error = security_sb_kern_mount(sb, flags, secdata);
-	if (error)
-		goto out_sb;
-
-	/*
-	 * filesystems should never set s_maxbytes larger than MAX_LFS_FILESIZE
-	 * but s_maxbytes was an unsigned long long for many releases. Throw
-	 * this warning for a little while to try and catch filesystems that
-	 * violate this rule.
-	 */
-	WARN((sb->s_maxbytes < 0), "%s set sb->s_maxbytes to "
-		"negative value (%lld)\n", type->name, sb->s_maxbytes);
-
-	up_write(&sb->s_umount);
-	free_secdata(secdata);
-	return root;
-out_sb:
-	dput(root);
-	deactivate_locked_super(sb);
-out_free_secdata:
-	free_secdata(secdata);
-out:
-	return ERR_PTR(error);
-}
-
 /*
  * Setup private BDI for given superblock. It gets automatically cleaned up
  * in generic_shutdown_super().
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3ebfedd1bfb8..2b96e7ae539f 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2048,10 +2048,10 @@ struct file_system_type {
 
 #define MODULE_ALIAS_FS(NAME) MODULE_ALIAS("fs-" NAME)
 
-extern struct dentry *mount_ns_sc(struct sb_config *mc,
-				  int (*fill_super)(struct super_block *sb,
-						    struct sb_config *sc),
-				  void *ns);
+extern int mount_ns_sc(struct sb_config *mc,
+		       int (*fill_super)(struct super_block *sb,
+					 struct sb_config *sc),
+		       void *ns);
 extern struct dentry *mount_ns(struct file_system_type *fs_type,
 	int flags, void *data, void *ns, struct user_namespace *user_ns,
 	int (*fill_super)(struct super_block *, void *, int));
diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
index e8e473ce5ddd..006c4b486169 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -97,10 +97,11 @@
  *	filesystem.
  *	@sc indicates the superblock configuration context.
  *	@p indicates the option in "key[=val]" form.
- * @sb_config_kern_mount:
- *	Equivalent of sb_kern_mount, but with a superblock configuration context.
+ * @sb_get_tree:
+ *	Assign the security to a newly created superblock.
  *	@sc indicates the superblock configuration context.
- *	@src_sb indicates the new superblock.
+ *	@sc->root indicates the root that will be mounted.
+ *	@sc->root->d_sb points to the superblock.
  * @sb_config_mountpoint:
  *	Equivalent of sb_mount, but with an sb_config.
  *	@sc indicates the superblock configuration context.
@@ -1393,14 +1394,13 @@ union security_list_options {
 	int (*sb_config_dup)(struct sb_config *sc, struct sb_config *src_sc);
 	void (*sb_config_free)(struct sb_config *sc);
 	int (*sb_config_parse_option)(struct sb_config *sc, char *opt);
-	int (*sb_config_kern_mount)(struct sb_config *sc, struct super_block *sb);
+	int (*sb_get_tree)(struct sb_config *sc);
 	int (*sb_config_mountpoint)(struct sb_config *sc, struct path *mountpoint);
 
 	int (*sb_alloc_security)(struct super_block *sb);
 	void (*sb_free_security)(struct super_block *sb);
 	int (*sb_copy_data)(char *orig, char *copy);
 	int (*sb_remount)(struct super_block *sb, void *data);
-	int (*sb_kern_mount)(struct super_block *sb, int flags, void *data);
 	int (*sb_show_options)(struct seq_file *m, struct super_block *sb);
 	int (*sb_statfs)(struct dentry *dentry);
 	int (*sb_mount)(const char *dev_name, const struct path *path,
@@ -1708,13 +1708,12 @@ struct security_hook_heads {
 	struct list_head sb_config_dup;
 	struct list_head sb_config_free;
 	struct list_head sb_config_parse_option;
-	struct list_head sb_config_kern_mount;
+	struct list_head sb_get_tree;
 	struct list_head sb_config_mountpoint;
 	struct list_head sb_alloc_security;
 	struct list_head sb_free_security;
 	struct list_head sb_copy_data;
 	struct list_head sb_remount;
-	struct list_head sb_kern_mount;
 	struct list_head sb_show_options;
 	struct list_head sb_statfs;
 	struct list_head sb_mount;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 9377afd5ecc8..733f62542644 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1554,10 +1554,10 @@ struct nfs_rpc_ops {
 
 	int	(*getroot) (struct nfs_server *, struct nfs_fh *,
 			    struct nfs_fsinfo *);
-	struct dentry *(*mount)(struct nfs_sb_config *);
+	int	(*get_tree)(struct nfs_sb_config *);
 	struct vfsmount *(*submount) (struct nfs_server *, struct dentry *,
 				      struct nfs_fh *, struct nfs_fattr *);
-	struct dentry *(*try_mount) (struct nfs_sb_config *);
+	int	(*try_get_tree) (struct nfs_sb_config *);
 	int	(*getattr) (struct nfs_server *, struct nfs_fh *,
 			    struct nfs_fattr *, struct nfs4_label *);
 	int	(*setattr) (struct dentry *, struct nfs_fattr *,
diff --git a/include/linux/sb_config.h b/include/linux/sb_config.h
index 0b21e381d9f0..5d84175386d3 100644
--- a/include/linux/sb_config.h
+++ b/include/linux/sb_config.h
@@ -38,21 +38,26 @@ enum sb_config_purpose {
  * allocated is specified in struct file_system_type::sb_config_size and this
  * must include sufficient space for the sb_config struct.
  *
+ * Superblock creation fills in ->root whereas reconfiguration begins with this
+ * already set.
+ *
  * See Documentation/filesystems/mounting.txt
  */
 struct sb_config {
 	const struct sb_config_operations *ops;
 	struct file_system_type	*fs_type;
+	struct dentry		*root;		/* The root and superblock */
 	struct user_namespace	*user_ns;	/* The user namespace for this mount */
 	struct net		*net_ns;	/* The network namespace for this mount */
 	const struct cred	*cred;		/* The mounter's credentials */
 	char			*device;	/* The device name or mount target */
+	char			*subtype;	/* The subtype to set on the superblock */
 	void			*security;	/* The LSM context */
 	const char		*error_msg;	/* Error string to be read by read() */
 	unsigned int		ms_flags;	/* The superblock flags (MS_*) */
-	bool			mounted;	/* Set when mounted */
 	bool			sloppy;		/* Unrecognised options are okay */
 	bool			silent;
+	bool			degraded;	/* True if the config can't be reused */
 	enum sb_config_purpose 	purpose : 8;
 };
 
@@ -62,7 +67,7 @@ struct sb_config_operations {
 	int (*parse_option)(struct sb_config *sc, char *p);
 	int (*monolithic_mount_data)(struct sb_config *sc, void *data);
 	int (*validate)(struct sb_config *sc);
-	struct dentry *(*mount)(struct sb_config *sc);
+	int (*get_tree)(struct sb_config *sc);
 };
 
 extern const struct file_operations fs_fs_fops;
@@ -77,6 +82,8 @@ extern struct sb_config *vfs_sb_reconfig(struct vfsmount *mnt,
 extern struct sb_config *vfs_dup_sb_config(struct sb_config *src);
 extern int vfs_parse_mount_option(struct sb_config *sc, char *data);
 extern int generic_monolithic_mount_data(struct sb_config *sc, void *data);
+extern int vfs_get_tree(struct sb_config *sc);
+extern int vfs_reconfigure_super(struct sb_config *sc);
 extern void put_sb_config(struct sb_config *sc);
 
 static inline void sb_cfg_error(struct sb_config *sc, const char *msg)
diff --git a/include/linux/security.h b/include/linux/security.h
index f95dc555cf29..f6baa8f01068 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -225,13 +225,12 @@ int security_sb_config_alloc(struct sb_config *sc, struct super_block *sb);
 int security_sb_config_dup(struct sb_config *sc, struct sb_config *src_sc);
 void security_sb_config_free(struct sb_config *sc);
 int security_sb_config_parse_option(struct sb_config *sc, char *opt);
-int security_sb_config_kern_mount(struct sb_config *sc, struct super_block *sb);
+int security_sb_get_tree(struct sb_config *sc);
 int security_sb_config_mountpoint(struct sb_config *sc, struct path *mountpoint);
 int security_sb_alloc(struct super_block *sb);
 void security_sb_free(struct super_block *sb);
 int security_sb_copy_data(char *orig, char *copy);
 int security_sb_remount(struct super_block *sb, void *data);
-int security_sb_kern_mount(struct super_block *sb, int flags, void *data);
 int security_sb_show_options(struct seq_file *m, struct super_block *sb);
 int security_sb_statfs(struct dentry *dentry);
 int security_sb_mount(const char *dev_name, const struct path *path,
@@ -537,8 +536,7 @@ static inline int security_sb_config_parse_option(struct sb_config *sc, char *op
 {
 	return 0;
 }
-static inline int security_sb_config_kern_mount(struct sb_config *sc,
-						struct super_block *sb)
+static inline int security_sb_get_tree(struct sb_config *sc)
 {
 	return 0;
 }
@@ -566,11 +564,6 @@ static inline int security_sb_remount(struct super_block *sb, void *data)
 	return 0;
 }
 
-static inline int security_sb_kern_mount(struct super_block *sb, int flags, void *data)
-{
-	return 0;
-}
-
 static inline int security_sb_show_options(struct seq_file *m,
 					   struct super_block *sb)
 {
diff --git a/security/security.c b/security/security.c
index 8b2b7e6b3112..a0af89fd12af 100644
--- a/security/security.c
+++ b/security/security.c
@@ -329,9 +329,9 @@ int security_sb_config_parse_option(struct sb_config *sc, char *opt)
 	return call_int_hook(sb_config_parse_option, 0, sc, opt);
 }
 
-int security_sb_config_kern_mount(struct sb_config *sc, struct super_block *sb)
+int security_sb_get_tree(struct sb_config *sc)
 {
-	return call_int_hook(sb_config_kern_mount, 0, sc, sb);
+	return call_int_hook(sb_get_tree, 0, sc);
 }
 
 int security_sb_config_mountpoint(struct sb_config *sc, struct path *mountpoint)
@@ -360,11 +360,6 @@ int security_sb_remount(struct super_block *sb, void *data)
 	return call_int_hook(sb_remount, 0, sb, data);
 }
 
-int security_sb_kern_mount(struct super_block *sb, int flags, void *data)
-{
-	return call_int_hook(sb_kern_mount, 0, sb, flags, data);
-}
-
 int security_sb_show_options(struct seq_file *m, struct super_block *sb)
 {
 	return call_int_hook(sb_show_options, 0, m, sb);
@@ -1694,8 +1689,7 @@ struct security_hook_heads security_hook_heads = {
 	.sb_config_free = LIST_HEAD_INIT(security_hook_heads.sb_config_free),
 	.sb_config_parse_option =
 		LIST_HEAD_INIT(security_hook_heads.sb_config_parse_option),
-	.sb_config_kern_mount =
-		LIST_HEAD_INIT(security_hook_heads.sb_config_kern_mount),
+	.sb_get_tree = LIST_HEAD_INIT(security_hook_heads.sb_get_tree),
 	.sb_config_mountpoint =
 		LIST_HEAD_INIT(security_hook_heads.sb_config_mountpoint),
 	.sb_alloc_security =
@@ -1704,8 +1698,6 @@ struct security_hook_heads security_hook_heads = {
 		LIST_HEAD_INIT(security_hook_heads.sb_free_security),
 	.sb_copy_data =	LIST_HEAD_INIT(security_hook_heads.sb_copy_data),
 	.sb_remount =	LIST_HEAD_INIT(security_hook_heads.sb_remount),
-	.sb_kern_mount =
-		LIST_HEAD_INIT(security_hook_heads.sb_kern_mount),
 	.sb_show_options =
 		LIST_HEAD_INIT(security_hook_heads.sb_show_options),
 	.sb_statfs =	LIST_HEAD_INIT(security_hook_heads.sb_statfs),
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index e1bf18af72f5..e5218172a44d 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -2775,25 +2775,6 @@ static int selinux_sb_remount(struct super_block *sb, void *data)
 	goto out_free_opts;
 }
 
-static int selinux_sb_kern_mount(struct super_block *sb, int flags, void *data)
-{
-	const struct cred *cred = current_cred();
-	struct common_audit_data ad;
-	int rc;
-
-	rc = superblock_doinit(sb, data);
-	if (rc)
-		return rc;
-
-	/* Allow all mounts performed by the kernel */
-	if (flags & MS_KERNMOUNT)
-		return 0;
-
-	ad.type = LSM_AUDIT_DATA_DENTRY;
-	ad.u.dentry = sb->s_root;
-	return superblock_has_perm(cred, sb, FILESYSTEM__MOUNT, &ad);
-}
-
 static int selinux_sb_statfs(struct dentry *dentry)
 {
 	const struct cred *cred = current_cred();
@@ -2967,14 +2948,13 @@ static int selinux_sb_config_parse_option(struct sb_config *sc, char *opt)
 	return sb_cfg_inval(sc, "SELinux: Incompatible mount options");
 }
 
-static int selinux_sb_config_kern_mount(struct sb_config *sc,
-					struct super_block *sb)
+static int selinux_sb_get_tree(struct sb_config *sc)
 {
 	const struct cred *cred = current_cred();
 	struct common_audit_data ad;
 	int rc;
 
-	rc = selinux_set_mnt_opts(sb, sc->security, 0, NULL);
+	rc = selinux_set_mnt_opts(sc->root->d_sb, sc->security, 0, NULL);
 	if (rc)
 		return rc;
 
@@ -2983,8 +2963,8 @@ static int selinux_sb_config_kern_mount(struct sb_config *sc,
 		return 0;
 
 	ad.type = LSM_AUDIT_DATA_DENTRY;
-	ad.u.dentry = sb->s_root;
-	rc = superblock_has_perm(cred, sb, FILESYSTEM__MOUNT, &ad);
+	ad.u.dentry = sc->root;
+	rc = superblock_has_perm(cred, sc->root->d_sb, FILESYSTEM__MOUNT, &ad);
 	if (rc < 0)
 		sb_cfg_error(sc, "SELinux: Mount of superblock not permitted");
 	return rc;
@@ -6311,14 +6291,13 @@ static struct security_hook_list selinux_hooks[] = {
 	LSM_HOOK_INIT(sb_config_dup, selinux_sb_config_dup),
 	LSM_HOOK_INIT(sb_config_free, selinux_sb_config_free),
 	LSM_HOOK_INIT(sb_config_parse_option, selinux_sb_config_parse_option),
-	LSM_HOOK_INIT(sb_config_kern_mount, selinux_sb_config_kern_mount),
+	LSM_HOOK_INIT(sb_get_tree, selinux_sb_get_tree),
 	LSM_HOOK_INIT(sb_config_mountpoint, selinux_sb_config_mountpoint),
 
 	LSM_HOOK_INIT(sb_alloc_security, selinux_sb_alloc_security),
 	LSM_HOOK_INIT(sb_free_security, selinux_sb_free_security),
 	LSM_HOOK_INIT(sb_copy_data, selinux_sb_copy_data),
 	LSM_HOOK_INIT(sb_remount, selinux_sb_remount),
-	LSM_HOOK_INIT(sb_kern_mount, selinux_sb_kern_mount),
 	LSM_HOOK_INIT(sb_show_options, selinux_sb_show_options),
 	LSM_HOOK_INIT(sb_statfs, selinux_sb_statfs),
 	LSM_HOOK_INIT(sb_mount, selinux_mount),


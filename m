Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2146 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751995Ab1IWQ0D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Sep 2011 12:26:03 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 3/7] VFS: Change LOOKUP_NO_AUTOMOUNT to LOOKUP_AUTOMOUNT
To: miklos@szeredi.hu, raven@themaw.net, viro@ZenIV.linux.org.uk,
        torvalds@linux-foundation.org
Cc: dhowells@redhat.com, jlayton@redhat.com, gregkh@suse.de,
        linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Date: Fri, 23 Sep 2011 17:25:16 +0100
Message-ID: <20110923162515.13574.44720.stgit@warthog.procyon.org.uk>
In-Reply-To: <20110923162438.13574.52985.stgit@warthog.procyon.org.uk>
References: <20110923162438.13574.52985.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Change LOOKUP_NO_AUTOMOUNT (don't do terminal automount) to LOOKUP_AUTOMOUNT
(do terminal automount) to parallel LOOKUP_FOLLOW and set it everywhere
LOOKUP_FOLLOW is set.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 drivers/mtd/ubi/build.c            |    2 +-
 drivers/mtd/ubi/kapi.c             |    2 +-
 fs/autofs4/dev-ioctl.c             |    2 +-
 fs/block_dev.c                     |    2 +-
 fs/configfs/symlink.c              |    2 +-
 fs/ecryptfs/main.c                 |    2 +-
 fs/exec.c                          |    5 +++--
 fs/fhandle.c                       |    2 +-
 fs/gfs2/ops_fstype.c               |    2 +-
 fs/namei.c                         |   11 ++++++-----
 fs/namespace.c                     |    8 ++++----
 fs/nfs/super.c                     |    2 +-
 fs/nfsd/nfs4state.c                |    2 +-
 fs/notify/fanotify/fanotify_user.c |    2 +-
 fs/notify/inotify/inotify_user.c   |    2 +-
 fs/open.c                          |   12 ++++++------
 fs/quota/quota.c                   |    2 +-
 fs/stat.c                          |    4 ++--
 fs/utimes.c                        |    2 +-
 include/linux/namei.h              |    9 +++++----
 net/unix/af_unix.c                 |    2 +-
 security/tomoyo/load_policy.c      |    2 +-
 security/tomoyo/mount.c            |    3 ++-
 23 files changed, 44 insertions(+), 40 deletions(-)

diff --git a/drivers/mtd/ubi/build.c b/drivers/mtd/ubi/build.c
index 6c3fb5a..28627f1 100644
--- a/drivers/mtd/ubi/build.c
+++ b/drivers/mtd/ubi/build.c
@@ -1122,7 +1122,7 @@ static struct mtd_info * __init open_mtd_by_chdev(const char *mtd_dev)
 	struct path path;
 
 	/* Probably this is an MTD character device node path */
-	err = kern_path(mtd_dev, LOOKUP_FOLLOW, &path);
+	err = kern_path(mtd_dev, LOOKUP_FOLLOW_ALL, &path);
 	if (err)
 		return ERR_PTR(err);
 
diff --git a/drivers/mtd/ubi/kapi.c b/drivers/mtd/ubi/kapi.c
index d39716e..056fbdb 100644
--- a/drivers/mtd/ubi/kapi.c
+++ b/drivers/mtd/ubi/kapi.c
@@ -303,7 +303,7 @@ struct ubi_volume_desc *ubi_open_volume_path(const char *pathname, int mode)
 	if (!pathname || !*pathname)
 		return ERR_PTR(-EINVAL);
 
-	error = kern_path(pathname, LOOKUP_FOLLOW, &path);
+	error = kern_path(pathname, LOOKUP_FOLLOW_ALL, &path);
 	if (error)
 		return ERR_PTR(error);
 
diff --git a/fs/autofs4/dev-ioctl.c b/fs/autofs4/dev-ioctl.c
index 509fe1e..1b2120d 100644
--- a/fs/autofs4/dev-ioctl.c
+++ b/fs/autofs4/dev-ioctl.c
@@ -533,7 +533,7 @@ static int autofs_dev_ioctl_ismountpoint(struct file *fp,
 
 	if (!fp || param->ioctlfd == -1) {
 		if (autofs_type_any(type))
-			err = kern_path(name, LOOKUP_FOLLOW, &path);
+			err = kern_path(name, LOOKUP_FOLLOW_ALL, &path);
 		else
 			err = find_autofs_mount(name, &path, test_by_type, &type);
 		if (err)
diff --git a/fs/block_dev.c b/fs/block_dev.c
index 95f786e..ff38dc5 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -1629,7 +1629,7 @@ struct block_device *lookup_bdev(const char *pathname)
 	if (!pathname || !*pathname)
 		return ERR_PTR(-EINVAL);
 
-	error = kern_path(pathname, LOOKUP_FOLLOW, &path);
+	error = kern_path(pathname, LOOKUP_FOLLOW_ALL, &path);
 	if (error)
 		return ERR_PTR(error);
 
diff --git a/fs/configfs/symlink.c b/fs/configfs/symlink.c
index 0f3eb41..c602b92 100644
--- a/fs/configfs/symlink.c
+++ b/fs/configfs/symlink.c
@@ -114,7 +114,7 @@ static int get_target(const char *symname, struct path *path,
 {
 	int ret;
 
-	ret = kern_path(symname, LOOKUP_FOLLOW|LOOKUP_DIRECTORY, path);
+	ret = kern_path(symname, LOOKUP_FOLLOW_ALL|LOOKUP_DIRECTORY, path);
 	if (!ret) {
 		if (path->dentry->d_sb == configfs_sb) {
 			*target = configfs_get_config_item(path->dentry);
diff --git a/fs/ecryptfs/main.c b/fs/ecryptfs/main.c
index b4a6bef..00e8ba7 100644
--- a/fs/ecryptfs/main.c
+++ b/fs/ecryptfs/main.c
@@ -519,7 +519,7 @@ static struct dentry *ecryptfs_mount(struct file_system_type *fs_type, int flags
 	s->s_d_op = &ecryptfs_dops;
 
 	err = "Reading sb failed";
-	rc = kern_path(dev_name, LOOKUP_FOLLOW | LOOKUP_DIRECTORY, &path);
+	rc = kern_path(dev_name, LOOKUP_FOLLOW_ALL | LOOKUP_DIRECTORY, &path);
 	if (rc) {
 		ecryptfs_printk(KERN_WARNING, "kern_path() failed\n");
 		goto out1;
diff --git a/fs/exec.c b/fs/exec.c
index 25dcbe5..7d56198 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -124,7 +124,7 @@ SYSCALL_DEFINE1(uselib, const char __user *, library)
 	if (IS_ERR(tmp))
 		goto out;
 
-	file = do_filp_open(AT_FDCWD, tmp, &uselib_flags, LOOKUP_FOLLOW);
+	file = do_filp_open(AT_FDCWD, tmp, &uselib_flags, LOOKUP_FOLLOW_ALL);
 	putname(tmp);
 	error = PTR_ERR(file);
 	if (IS_ERR(file))
@@ -769,7 +769,8 @@ struct file *open_exec(const char *name)
 		.intent = LOOKUP_OPEN
 	};
 
-	file = do_filp_open(AT_FDCWD, name, &open_exec_flags, LOOKUP_FOLLOW);
+	file = do_filp_open(AT_FDCWD, name, &open_exec_flags,
+			    LOOKUP_FOLLOW_ALL);
 	if (IS_ERR(file))
 		goto out;
 
diff --git a/fs/fhandle.c b/fs/fhandle.c
index 6b08864..131e1ae 100644
--- a/fs/fhandle.c
+++ b/fs/fhandle.c
@@ -98,7 +98,7 @@ SYSCALL_DEFINE5(name_to_handle_at, int, dfd, const char __user *, name,
 	if ((flag & ~(AT_SYMLINK_FOLLOW | AT_EMPTY_PATH)) != 0)
 		return -EINVAL;
 
-	lookup_flags = (flag & AT_SYMLINK_FOLLOW) ? LOOKUP_FOLLOW : 0;
+	lookup_flags = (flag & AT_SYMLINK_FOLLOW) ? LOOKUP_FOLLOW_ALL : 0;
 	if (flag & AT_EMPTY_PATH)
 		lookup_flags |= LOOKUP_EMPTY;
 	err = user_path_at(dfd, name, lookup_flags, &path);
diff --git a/fs/gfs2/ops_fstype.c b/fs/gfs2/ops_fstype.c
index 079587e..c532776 100644
--- a/fs/gfs2/ops_fstype.c
+++ b/fs/gfs2/ops_fstype.c
@@ -1350,7 +1350,7 @@ static struct dentry *gfs2_mount_meta(struct file_system_type *fs_type,
 	struct path path;
 	int error;
 
-	error = kern_path(dev_name, LOOKUP_FOLLOW, &path);
+	error = kern_path(dev_name, LOOKUP_FOLLOW_ALL, &path);
 	if (error) {
 		printk(KERN_WARNING "GFS2: path_lookup on %s returned error %d\n",
 		       dev_name, error);
diff --git a/fs/namei.c b/fs/namei.c
index c64b81d..30a364b 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -724,7 +724,7 @@ static int follow_automount(struct path *path, unsigned flags,
 	/* We don't want to mount if someone supplied AT_NO_AUTOMOUNT
 	 * and this is the terminal part of the path.
 	 */
-	if ((flags & LOOKUP_NO_AUTOMOUNT) && !(flags & LOOKUP_PARENT))
+	if (!(flags & LOOKUP_AUTOMOUNT) && !(flags & LOOKUP_PARENT))
 		return -EISDIR; /* we actually want to stop here */
 
 	/*
@@ -1573,7 +1573,7 @@ out_fail:
 static inline int lookup_last(struct nameidata *nd, struct path *path)
 {
 	if (nd->last_type == LAST_NORM && nd->last.name[nd->last.len])
-		nd->flags |= LOOKUP_FOLLOW | LOOKUP_DIRECTORY;
+		nd->flags |= LOOKUP_FOLLOW_ALL | LOOKUP_DIRECTORY;
 
 	nd->flags &= ~LOOKUP_PARENT;
 	return walk_component(nd, path, &nd->last, nd->last_type,
@@ -2125,8 +2125,8 @@ static struct file *do_last(struct nameidata *nd, struct path *path,
 	if (!(open_flag & O_CREAT)) {
 		int symlink_ok = 0;
 		if (nd->last.name[nd->last.len])
-			nd->flags |= LOOKUP_FOLLOW | LOOKUP_DIRECTORY;
-		if (open_flag & O_PATH && !(nd->flags & LOOKUP_FOLLOW))
+			nd->flags |= LOOKUP_FOLLOW_ALL | LOOKUP_DIRECTORY;
+		if (open_flag & O_PATH && !(nd->flags & LOOKUP_FOLLOW_ALL))
 			symlink_ok = 1;
 		/* we _can_ be in RCU mode here */
 		error = walk_component(nd, path, &nd->last, LAST_NORM,
@@ -2928,7 +2928,7 @@ SYSCALL_DEFINE5(linkat, int, olddfd, const char __user *, oldname,
 {
 	struct dentry *new_dentry;
 	struct path old_path, new_path;
-	int how = 0;
+	int how;
 	int error;
 
 	if ((flags & ~(AT_SYMLINK_FOLLOW | AT_EMPTY_PATH)) != 0)
@@ -2946,6 +2946,7 @@ SYSCALL_DEFINE5(linkat, int, olddfd, const char __user *, oldname,
 
 	if (flags & AT_SYMLINK_FOLLOW)
 		how |= LOOKUP_FOLLOW;
+	how |= LOOKUP_AUTOMOUNT;
 
 	error = user_path_at(olddfd, oldname, how, &old_path);
 	if (error)
diff --git a/fs/namespace.c b/fs/namespace.c
index 22bfe82..71c218a 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1368,7 +1368,7 @@ SYSCALL_DEFINE2(umount, char __user *, name, int, flags)
 		return -EINVAL;
 
 	if (!(flags & UMOUNT_NOFOLLOW))
-		lookup_flags |= LOOKUP_FOLLOW;
+		lookup_flags |= LOOKUP_FOLLOW_ALL;
 
 	retval = user_path_at(AT_FDCWD, name, lookup_flags, &path);
 	if (retval)
@@ -1757,7 +1757,7 @@ static int do_loopback(struct path *path, char *old_name,
 		return err;
 	if (!old_name || !*old_name)
 		return -EINVAL;
-	err = kern_path(old_name, LOOKUP_FOLLOW, &old_path);
+	err = kern_path(old_name, LOOKUP_FOLLOW_ALL, &old_path);
 	if (err)
 		return err;
 
@@ -1875,7 +1875,7 @@ static int do_move_mount(struct path *path, char *old_name)
 		return -EPERM;
 	if (!old_name || !*old_name)
 		return -EINVAL;
-	err = kern_path(old_name, LOOKUP_FOLLOW, &old_path);
+	err = kern_path(old_name, LOOKUP_FOLLOW_ALL, &old_path);
 	if (err)
 		return err;
 
@@ -2305,7 +2305,7 @@ long do_mount(char *dev_name, char *dir_name, char *type_page,
 		((char *)data_page)[PAGE_SIZE - 1] = 0;
 
 	/* ... and get the mountpoint */
-	retval = kern_path(dir_name, LOOKUP_FOLLOW, &path);
+	retval = kern_path(dir_name, LOOKUP_FOLLOW_ALL, &path);
 	if (retval)
 		return retval;
 
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 9b7dd70..1143a77 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2798,7 +2798,7 @@ static struct dentry *nfs_follow_remote_path(struct vfsmount *root_mnt,
 		goto out_put_mnt_ns;
 
 	ret = vfs_path_lookup(root_mnt->mnt_root, root_mnt,
-			export_path, LOOKUP_FOLLOW, &path);
+			export_path, LOOKUP_FOLLOW_ALL, &path);
 
 	nfs_referral_loop_unprotect();
 	put_mnt_ns(ns_private);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3787ec1..0d50e6e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4656,7 +4656,7 @@ nfs4_reset_recoverydir(char *recdir)
 	int status;
 	struct path path;
 
-	status = kern_path(recdir, LOOKUP_FOLLOW, &path);
+	status = kern_path(recdir, LOOKUP_FOLLOW_ALL, &path);
 	if (status)
 		return status;
 	status = -ENOTDIR;
diff --git a/fs/notify/fanotify/fanotify_user.c b/fs/notify/fanotify/fanotify_user.c
index 9fde1c0..e8a4467 100644
--- a/fs/notify/fanotify/fanotify_user.c
+++ b/fs/notify/fanotify/fanotify_user.c
@@ -491,7 +491,7 @@ static int fanotify_find_path(int dfd, const char __user *filename,
 		path_get(path);
 		fput_light(file, fput_needed);
 	} else {
-		unsigned int lookup_flags = 0;
+		unsigned int lookup_flags = LOOKUP_AUTOMOUNT;
 
 		if (!(flags & FAN_MARK_DONT_FOLLOW))
 			lookup_flags |= LOOKUP_FOLLOW;
diff --git a/fs/notify/inotify/inotify_user.c b/fs/notify/inotify/inotify_user.c
index 8445fbc..90f6010 100644
--- a/fs/notify/inotify/inotify_user.c
+++ b/fs/notify/inotify/inotify_user.c
@@ -759,7 +759,7 @@ SYSCALL_DEFINE3(inotify_add_watch, int, fd, const char __user *, pathname,
 	struct path path;
 	struct file *filp;
 	int ret, fput_needed;
-	unsigned flags = 0;
+	unsigned flags = LOOKUP_AUTOMOUNT;
 
 	filp = fget_light(fd, &fput_needed);
 	if (unlikely(!filp))
diff --git a/fs/open.c b/fs/open.c
index 6d6cd90..414939e 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -325,7 +325,7 @@ SYSCALL_DEFINE3(faccessat, int, dfd, const char __user *, filename, int, mode)
 
 	old_cred = override_creds(override_cred);
 
-	res = user_path_at(dfd, filename, LOOKUP_FOLLOW, &path);
+	res = user_path_at(dfd, filename, LOOKUP_FOLLOW_ALL, &path);
 	if (res)
 		goto out;
 
@@ -487,7 +487,7 @@ SYSCALL_DEFINE3(fchmodat, int, dfd, const char __user *, filename, mode_t, mode)
 	struct path path;
 	int error;
 
-	error = user_path_at(dfd, filename, LOOKUP_FOLLOW, &path);
+	error = user_path_at(dfd, filename, LOOKUP_FOLLOW_ALL, &path);
 	if (!error) {
 		error = chmod_common(&path, mode);
 		path_put(&path);
@@ -537,7 +537,7 @@ SYSCALL_DEFINE5(fchownat, int, dfd, const char __user *, filename, uid_t, user,
 	if ((flag & ~(AT_SYMLINK_NOFOLLOW | AT_EMPTY_PATH)) != 0)
 		goto out;
 
-	lookup_flags = (flag & AT_SYMLINK_NOFOLLOW) ? 0 : LOOKUP_FOLLOW;
+	lookup_flags = (flag & AT_SYMLINK_NOFOLLOW) ? 0 : LOOKUP_FOLLOW_ALL;
 	if (flag & AT_EMPTY_PATH)
 		lookup_flags |= LOOKUP_EMPTY;
 	error = user_path_at(dfd, filename, lookup_flags, &path);
@@ -556,12 +556,12 @@ out:
 
 SYSCALL_DEFINE3(chown, const char __user *, filename, uid_t, user, gid_t, group)
 {
-	return fchownat(AT_FDCWD, filename, user, group, 0);
+	return sys_fchownat(AT_FDCWD, filename, user, group, 0);
 }
 
 SYSCALL_DEFINE3(lchown, const char __user *, filename, uid_t, user, gid_t, group)
 {
-	return fchownat(AT_FDCWD, filename, user, group, AT_SYMLINK_NOFOLLOW);
+	return sys_fchownat(AT_FDCWD, filename, user, group, AT_SYMLINK_NOFOLLOW);
 }
 
 SYSCALL_DEFINE3(fchown, unsigned int, fd, uid_t, user, gid_t, group)
@@ -901,7 +901,7 @@ static inline int build_open_flags(int flags, int mode, struct open_flags *op)
 	if (flags & O_DIRECTORY)
 		lookup_flags |= LOOKUP_DIRECTORY;
 	if (!(flags & O_NOFOLLOW))
-		lookup_flags |= LOOKUP_FOLLOW;
+		lookup_flags |= LOOKUP_FOLLOW_ALL;
 	return lookup_flags;
 }
 
diff --git a/fs/quota/quota.c b/fs/quota/quota.c
index b34bdb2..156486a 100644
--- a/fs/quota/quota.c
+++ b/fs/quota/quota.c
@@ -355,7 +355,7 @@ SYSCALL_DEFINE4(quotactl, unsigned int, cmd, const char __user *, special,
 	 * resolution (think about autofs) and thus deadlocks could arise.
 	 */
 	if (cmds == Q_QUOTAON) {
-		ret = user_path_at(AT_FDCWD, addr, LOOKUP_FOLLOW, &path);
+		ret = user_path_at(AT_FDCWD, addr, LOOKUP_FOLLOW_ALL, &path);
 		if (ret)
 			pathp = ERR_PTR(ret);
 		else
diff --git a/fs/stat.c b/fs/stat.c
index ba5316f..52ead31 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -80,9 +80,9 @@ int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
 		goto out;
 
 	if (!(flag & AT_SYMLINK_NOFOLLOW))
-		lookup_flags |= LOOKUP_FOLLOW;
+		lookup_flags |= LOOKUP_FOLLOW_ALL;
 	if (flag & AT_NO_AUTOMOUNT)
-		lookup_flags |= LOOKUP_NO_AUTOMOUNT;
+		lookup_flags &= ~LOOKUP_AUTOMOUNT;
 	if (flag & AT_EMPTY_PATH)
 		lookup_flags |= LOOKUP_EMPTY;
 
diff --git a/fs/utimes.c b/fs/utimes.c
index ba653f3..ea82831 100644
--- a/fs/utimes.c
+++ b/fs/utimes.c
@@ -157,7 +157,7 @@ long do_utimes(int dfd, const char __user *filename, struct timespec *times,
 		int lookup_flags = 0;
 
 		if (!(flags & AT_SYMLINK_NOFOLLOW))
-			lookup_flags |= LOOKUP_FOLLOW;
+			lookup_flags |= LOOKUP_FOLLOW_ALL;
 
 		error = user_path_at(dfd, filename, lookup_flags, &path);
 		if (error)
diff --git a/include/linux/namei.h b/include/linux/namei.h
index 76fe2c6..86d6993 100644
--- a/include/linux/namei.h
+++ b/include/linux/namei.h
@@ -44,7 +44,7 @@ enum {LAST_NORM, LAST_ROOT, LAST_DOT, LAST_DOTDOT, LAST_BIND};
  *  - ending slashes ok even for nonexistent files
  *  - internal "there are more path components" flag
  *  - dentry cache is untrusted; force a real lookup
- *  - suppress terminal automount
+ *  - follow terminal automount
  */
 #define LOOKUP_FOLLOW		0x0001
 #define LOOKUP_DIRECTORY	0x0002
@@ -52,7 +52,8 @@ enum {LAST_NORM, LAST_ROOT, LAST_DOT, LAST_DOTDOT, LAST_BIND};
 #define LOOKUP_PARENT		0x0010
 #define LOOKUP_REVAL		0x0020
 #define LOOKUP_RCU		0x0040
-#define LOOKUP_NO_AUTOMOUNT	0x0080
+#define LOOKUP_AUTOMOUNT	0x0080
+#define LOOKUP_FOLLOW_ALL	(LOOKUP_FOLLOW | LOOKUP_AUTOMOUNT)
 /*
  * Intent data
  */
@@ -67,10 +68,10 @@ enum {LAST_NORM, LAST_ROOT, LAST_DOT, LAST_DOTDOT, LAST_BIND};
 
 extern int user_path_at(int, const char __user *, unsigned, struct path *);
 
-#define user_path(name, path) user_path_at(AT_FDCWD, name, LOOKUP_FOLLOW, path)
+#define user_path(name, path) user_path_at(AT_FDCWD, name, LOOKUP_FOLLOW_ALL, path)
 #define user_lpath(name, path) user_path_at(AT_FDCWD, name, 0, path)
 #define user_path_dir(name, path) \
-	user_path_at(AT_FDCWD, name, LOOKUP_FOLLOW | LOOKUP_DIRECTORY, path)
+	user_path_at(AT_FDCWD, name, LOOKUP_FOLLOW_ALL | LOOKUP_DIRECTORY, path)
 
 extern int kern_path(const char *, unsigned, struct path *);
 
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index ec68e1c..0c091d5 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -756,7 +756,7 @@ static struct sock *unix_find_other(struct net *net,
 
 	if (sunname->sun_path[0]) {
 		struct inode *inode;
-		err = kern_path(sunname->sun_path, LOOKUP_FOLLOW, &path);
+		err = kern_path(sunname->sun_path, LOOKUP_FOLLOW_ALL, &path);
 		if (err)
 			goto fail;
 		inode = path.dentry->d_inode;
diff --git a/security/tomoyo/load_policy.c b/security/tomoyo/load_policy.c
index 6797540..8de4d49 100644
--- a/security/tomoyo/load_policy.c
+++ b/security/tomoyo/load_policy.c
@@ -38,7 +38,7 @@ static bool tomoyo_policy_loader_exists(void)
 	struct path path;
 	if (!tomoyo_loader)
 		tomoyo_loader = CONFIG_SECURITY_TOMOYO_POLICY_LOADER;
-	if (kern_path(tomoyo_loader, LOOKUP_FOLLOW, &path)) {
+	if (kern_path(tomoyo_loader, LOOKUP_FOLLOW_ALL, &path)) {
 		printk(KERN_INFO "Not activating Mandatory Access Control "
 		       "as %s does not exist.\n", tomoyo_loader);
 		return false;
diff --git a/security/tomoyo/mount.c b/security/tomoyo/mount.c
index bee09d0..786c47f 100644
--- a/security/tomoyo/mount.c
+++ b/security/tomoyo/mount.c
@@ -128,7 +128,8 @@ static int tomoyo_mount_acl(struct tomoyo_request_info *r, char *dev_name,
 	}
 	if (need_dev) {
 		/* Get mount point or device file. */
-		if (!dev_name || kern_path(dev_name, LOOKUP_FOLLOW, &path)) {
+		if (!dev_name ||
+		    kern_path(dev_name, LOOKUP_FOLLOW_ALL, &path)) {
 			error = -ENOENT;
 			goto out;
 		}


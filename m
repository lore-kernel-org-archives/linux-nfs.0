Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15615 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752042Ab1IWQ0Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Sep 2011 12:26:16 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 4/7] VFS: Move the automount suppression decision out to the
 initial callers of
To: miklos@szeredi.hu, raven@themaw.net, viro@ZenIV.linux.org.uk,
        torvalds@linux-foundation.org
Cc: dhowells@redhat.com, jlayton@redhat.com, gregkh@suse.de,
        linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Date: Fri, 23 Sep 2011 17:25:28 +0100
Message-ID: <20110923162528.13574.48402.stgit@warthog.procyon.org.uk>
In-Reply-To: <20110923162438.13574.52985.stgit@warthog.procyon.org.uk>
References: <20110923162438.13574.52985.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

pathwalk, in particular get attribute-fetching system calls and define the
to-terminal-automount-or-not policy there by supplying LOOKUP_AUTOMOUNT or not
as appropriate.

Suppress automount on the following:

	lchown
	lgetxattr
	llistxattr
	lremovexattr
	lsetxattr
	lstat
	openat/open with O_NOFOLLOW but not O_DIRECTORY
	readlinkat, readlink

	ocfs2_reflink_ioctl()

Require terminal automounting on the following:

	chdir
	chown
	chroot
	execve
	faccessat, access
	fanotify
	fchmodat, chmod
	getxattr
	inotify
	linkat, link
	listxattr
	mkdirat, mkdir
	mknodat, mknod
	mount
	openat/open without O_NOFOLLOW or with O_DIRECTORY
	quotactl
	removexattr
	renameat, rename
	setxattr
	socket(AF_UNIX)
	stat
	statfs
	symlinkat, symlink
	unlinkat, unlink, rmdir
	uselib
	utimes, futimesat

	autofs_dev_ioctl_ismountpoint()
	ecryptfs_mount()
	get_target() in configfs/symlink.c
	gfs2_mount_meta()
	lookup_bdev()
	nfs4_reset_recoverydir()
	nfs_follow_remote_path()
	open_mtd_by_chdev()
	tomoyo_mount_acl()
	tomoyo_policy_loader_exists()
	ubi_open_volume_path()

Default the automount-follow setting to the same as the symlink-follow setting
(as controlled by AT_SYMLINK_NOFOLLOW, UMOUNT_NOFOLLOW or
FAN_MARK_DONT_FOLLOW):

	fchownat
	fstatat
	name_to_handle_at
	umount
	utimensat

Provide an AT_AUTOMOUNT_FOLLOW option where possible to override the
behaviour, and try to make all four relevant AT_ flags available to all AT_
flag taking functions.  Given the flags available, the behaviour is then
calculated using the following rules in order of descending priority:

  (1) If the path ends in a '/', follow the automount.

  (2) If AT_AUTOMOUNT_FOLLOW is set, follow the automount.

  (3) If AT_NO_AUTOMOUNT is set, don't follow the automount.

  (4) If AT_SYMLINK_FOLLOW is set, follow the automount.

  (5) If AT_SYMLINK_NOFOLLOW is set, don't follow the automount.

  (6) Follow the automount.

To change the behaviour to make stat, xattr functions always suppress
automounting too is then a matter of changing vfs_fstatat() and the
appropriate xattr syscalls.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/fhandle.c          |   11 +++++------
 fs/internal.h         |   17 +++++++++++++++++
 fs/namei.c            |    2 +-
 fs/open.c             |   13 +++++++------
 fs/stat.c             |   14 +++++---------
 fs/statfs.c           |    2 +-
 fs/utimes.c           |   14 +++++++-------
 fs/xattr.c            |   16 ++++++++--------
 include/linux/fcntl.h |    1 +
 9 files changed, 52 insertions(+), 38 deletions(-)

diff --git a/fs/fhandle.c b/fs/fhandle.c
index 131e1ae..d81c506 100644
--- a/fs/fhandle.c
+++ b/fs/fhandle.c
@@ -92,15 +92,14 @@ SYSCALL_DEFINE5(name_to_handle_at, int, dfd, const char __user *, name,
 		int, flag)
 {
 	struct path path;
-	int lookup_flags;
-	int err;
+	int err, lookup_flags;
 
-	if ((flag & ~(AT_SYMLINK_FOLLOW | AT_EMPTY_PATH)) != 0)
+	if ((flag & ~(AT_SYMLINK_NOFOLLOW | AT_SYMLINK_FOLLOW |
+		      AT_NO_AUTOMOUNT | AT_AUTOMOUNT_FOLLOW |
+		      AT_EMPTY_PATH)) != 0)
 		return -EINVAL;
+	lookup_flags = at_to_lookup_flags(flag, 0);
 
-	lookup_flags = (flag & AT_SYMLINK_FOLLOW) ? LOOKUP_FOLLOW_ALL : 0;
-	if (flag & AT_EMPTY_PATH)
-		lookup_flags |= LOOKUP_EMPTY;
 	err = user_path_at(dfd, name, lookup_flags, &path);
 	if (!err) {
 		err = do_sys_name_to_handle(&path, handle, mnt_id);
diff --git a/fs/internal.h b/fs/internal.h
index fe327c2..11664f5 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -9,6 +9,7 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#include <linux/namei.h>
 #include <linux/lglock.h>
 
 struct super_block;
@@ -16,6 +17,22 @@ struct file_system_type;
 struct linux_binprm;
 struct path;
 
+/**
+ * at_to_lookup_flags - Translate AT_ flags to LOOKUP_ flags
+ * @flags: The AT_ flags to translate.
+ * @lookup_flags: The default.
+ */
+static inline int at_to_lookup_flags(int flag, int lookup_flags)
+{
+	if (flag & AT_SYMLINK_NOFOLLOW)	lookup_flags &= ~LOOKUP_FOLLOW_ALL;
+	if (flag & AT_SYMLINK_FOLLOW)	lookup_flags |= LOOKUP_FOLLOW_ALL;
+	if (flag & AT_NO_AUTOMOUNT)	lookup_flags &= ~LOOKUP_AUTOMOUNT;
+	if (flag & AT_AUTOMOUNT_FOLLOW)	lookup_flags |= LOOKUP_AUTOMOUNT;
+	if (flag & AT_EMPTY_PATH)	lookup_flags |= LOOKUP_EMPTY;
+
+	return lookup_flags;
+}
+
 /*
  * block_dev.c
  */
diff --git a/fs/namei.c b/fs/namei.c
index 30a364b..c2a2cc3 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2126,7 +2126,7 @@ static struct file *do_last(struct nameidata *nd, struct path *path,
 		int symlink_ok = 0;
 		if (nd->last.name[nd->last.len])
 			nd->flags |= LOOKUP_FOLLOW_ALL | LOOKUP_DIRECTORY;
-		if (open_flag & O_PATH && !(nd->flags & LOOKUP_FOLLOW_ALL))
+		if (open_flag & O_PATH && !(nd->flags & LOOKUP_FOLLOW))
 			symlink_ok = 1;
 		/* we _can_ be in RCU mode here */
 		error = walk_component(nd, path, &nd->last, LAST_NORM,
diff --git a/fs/open.c b/fs/open.c
index 414939e..b592c18 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -534,12 +534,12 @@ SYSCALL_DEFINE5(fchownat, int, dfd, const char __user *, filename, uid_t, user,
 	int error = -EINVAL;
 	int lookup_flags;
 
-	if ((flag & ~(AT_SYMLINK_NOFOLLOW | AT_EMPTY_PATH)) != 0)
+	if ((flag & ~(AT_SYMLINK_NOFOLLOW | AT_SYMLINK_FOLLOW |
+		      AT_NO_AUTOMOUNT | AT_AUTOMOUNT_FOLLOW |
+		      AT_EMPTY_PATH)) != 0)
 		goto out;
+	lookup_flags = at_to_lookup_flags(flag, LOOKUP_FOLLOW_ALL);
 
-	lookup_flags = (flag & AT_SYMLINK_NOFOLLOW) ? 0 : LOOKUP_FOLLOW_ALL;
-	if (flag & AT_EMPTY_PATH)
-		lookup_flags |= LOOKUP_EMPTY;
 	error = user_path_at(dfd, filename, lookup_flags, &path);
 	if (error)
 		goto out;
@@ -561,7 +561,8 @@ SYSCALL_DEFINE3(chown, const char __user *, filename, uid_t, user, gid_t, group)
 
 SYSCALL_DEFINE3(lchown, const char __user *, filename, uid_t, user, gid_t, group)
 {
-	return sys_fchownat(AT_FDCWD, filename, user, group, AT_SYMLINK_NOFOLLOW);
+	return sys_fchownat(AT_FDCWD, filename, user, group,
+			    AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT);
 }
 
 SYSCALL_DEFINE3(fchown, unsigned int, fd, uid_t, user, gid_t, group)
@@ -899,7 +900,7 @@ static inline int build_open_flags(int flags, int mode, struct open_flags *op)
 	}
 
 	if (flags & O_DIRECTORY)
-		lookup_flags |= LOOKUP_DIRECTORY;
+		lookup_flags |= LOOKUP_DIRECTORY | LOOKUP_AUTOMOUNT;
 	if (!(flags & O_NOFOLLOW))
 		lookup_flags |= LOOKUP_FOLLOW_ALL;
 	return lookup_flags;
diff --git a/fs/stat.c b/fs/stat.c
index 52ead31..305aa10 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -17,6 +17,7 @@
 
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
+#include "internal.h"
 
 void generic_fillattr(struct inode *inode, struct kstat *stat)
 {
@@ -73,18 +74,13 @@ int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
 {
 	struct path path;
 	int error = -EINVAL;
-	int lookup_flags = 0;
+	int lookup_flags;
 
-	if ((flag & ~(AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT |
+	if ((flag & ~(AT_SYMLINK_NOFOLLOW | AT_SYMLINK_FOLLOW |
+		      AT_NO_AUTOMOUNT | AT_AUTOMOUNT_FOLLOW |
 		      AT_EMPTY_PATH)) != 0)
 		goto out;
-
-	if (!(flag & AT_SYMLINK_NOFOLLOW))
-		lookup_flags |= LOOKUP_FOLLOW_ALL;
-	if (flag & AT_NO_AUTOMOUNT)
-		lookup_flags &= ~LOOKUP_AUTOMOUNT;
-	if (flag & AT_EMPTY_PATH)
-		lookup_flags |= LOOKUP_EMPTY;
+	lookup_flags = at_to_lookup_flags(flag, LOOKUP_FOLLOW_ALL);
 
 	error = user_path_at(dfd, filename, lookup_flags, &path);
 	if (error)
diff --git a/fs/statfs.c b/fs/statfs.c
index 8244924..e82eae2 100644
--- a/fs/statfs.c
+++ b/fs/statfs.c
@@ -76,7 +76,7 @@ EXPORT_SYMBOL(vfs_statfs);
 int user_statfs(const char __user *pathname, struct kstatfs *st)
 {
 	struct path path;
-	int error = user_path(pathname, &path);
+	int error = user_path_at(AT_FDCWD, pathname, LOOKUP_FOLLOW_ALL, &path);
 	if (!error) {
 		error = vfs_statfs(&path, st);
 		path_put(&path);
diff --git a/fs/utimes.c b/fs/utimes.c
index ea82831..72f10c5 100644
--- a/fs/utimes.c
+++ b/fs/utimes.c
@@ -10,6 +10,7 @@
 #include <linux/syscalls.h>
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
+#include "internal.h"
 
 #ifdef __ARCH_WANT_SYS_UTIME
 
@@ -116,7 +117,7 @@ out:
  * @dfd: open file descriptor, -1 or AT_FDCWD
  * @filename: path name or NULL
  * @times: new times or NULL
- * @flags: zero or more flags (only AT_SYMLINK_NOFOLLOW for the moment)
+ * @flags: zero or more AT_* flags
  *
  * If filename is NULL and dfd refers to an open file, then operate on
  * the file.  Otherwise look up filename, possibly using dfd as a
@@ -136,13 +137,15 @@ long do_utimes(int dfd, const char __user *filename, struct timespec *times,
 		goto out;
 	}
 
-	if (flags & ~AT_SYMLINK_NOFOLLOW)
+	if (flags & ~(AT_SYMLINK_NOFOLLOW | AT_SYMLINK_FOLLOW |
+		      AT_NO_AUTOMOUNT | AT_AUTOMOUNT_FOLLOW))
 		goto out;
 
 	if (filename == NULL && dfd != AT_FDCWD) {
 		struct file *file;
 
-		if (flags & AT_SYMLINK_NOFOLLOW)
+		if (flags & (AT_SYMLINK_NOFOLLOW | AT_SYMLINK_FOLLOW |
+			     AT_NO_AUTOMOUNT | AT_AUTOMOUNT_FOLLOW))
 			goto out;
 
 		file = fget(dfd);
@@ -154,10 +157,7 @@ long do_utimes(int dfd, const char __user *filename, struct timespec *times,
 		fput(file);
 	} else {
 		struct path path;
-		int lookup_flags = 0;
-
-		if (!(flags & AT_SYMLINK_NOFOLLOW))
-			lookup_flags |= LOOKUP_FOLLOW_ALL;
+		int lookup_flags = at_to_lookup_flags(flags, LOOKUP_FOLLOW_ALL);
 
 		error = user_path_at(dfd, filename, lookup_flags, &path);
 		if (error)
diff --git a/fs/xattr.c b/fs/xattr.c
index f060663..4921010 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -290,7 +290,7 @@ SYSCALL_DEFINE5(setxattr, const char __user *, pathname,
 	struct path path;
 	int error;
 
-	error = user_path(pathname, &path);
+	error = user_path_at(AT_FDCWD, pathname, LOOKUP_FOLLOW_ALL, &path);
 	if (error)
 		return error;
 	error = mnt_want_write(path.mnt);
@@ -309,7 +309,7 @@ SYSCALL_DEFINE5(lsetxattr, const char __user *, pathname,
 	struct path path;
 	int error;
 
-	error = user_lpath(pathname, &path);
+	error = user_path_at(AT_FDCWD, pathname, 0, &path);
 	if (error)
 		return error;
 	error = mnt_want_write(path.mnt);
@@ -386,7 +386,7 @@ SYSCALL_DEFINE4(getxattr, const char __user *, pathname,
 	struct path path;
 	ssize_t error;
 
-	error = user_path(pathname, &path);
+	error = user_path_at(AT_FDCWD, pathname, LOOKUP_FOLLOW_ALL, &path);
 	if (error)
 		return error;
 	error = getxattr(path.dentry, name, value, size);
@@ -400,7 +400,7 @@ SYSCALL_DEFINE4(lgetxattr, const char __user *, pathname,
 	struct path path;
 	ssize_t error;
 
-	error = user_lpath(pathname, &path);
+	error = user_path_at(AT_FDCWD, pathname, 0, &path);
 	if (error)
 		return error;
 	error = getxattr(path.dentry, name, value, size);
@@ -459,7 +459,7 @@ SYSCALL_DEFINE3(listxattr, const char __user *, pathname, char __user *, list,
 	struct path path;
 	ssize_t error;
 
-	error = user_path(pathname, &path);
+	error = user_path_at(AT_FDCWD, pathname, LOOKUP_FOLLOW_ALL, &path);
 	if (error)
 		return error;
 	error = listxattr(path.dentry, list, size);
@@ -473,7 +473,7 @@ SYSCALL_DEFINE3(llistxattr, const char __user *, pathname, char __user *, list,
 	struct path path;
 	ssize_t error;
 
-	error = user_lpath(pathname, &path);
+	error = user_path_at(AT_FDCWD, pathname, 0, &path);
 	if (error)
 		return error;
 	error = listxattr(path.dentry, list, size);
@@ -519,7 +519,7 @@ SYSCALL_DEFINE2(removexattr, const char __user *, pathname,
 	struct path path;
 	int error;
 
-	error = user_path(pathname, &path);
+	error = user_path_at(AT_FDCWD, pathname, LOOKUP_FOLLOW_ALL, &path);
 	if (error)
 		return error;
 	error = mnt_want_write(path.mnt);
@@ -537,7 +537,7 @@ SYSCALL_DEFINE2(lremovexattr, const char __user *, pathname,
 	struct path path;
 	int error;
 
-	error = user_lpath(pathname, &path);
+	error = user_path_at(AT_FDCWD, pathname, 0, &path);
 	if (error)
 		return error;
 	error = mnt_want_write(path.mnt);
diff --git a/include/linux/fcntl.h b/include/linux/fcntl.h
index f550f89..768fb66 100644
--- a/include/linux/fcntl.h
+++ b/include/linux/fcntl.h
@@ -47,6 +47,7 @@
 #define AT_SYMLINK_FOLLOW	0x400   /* Follow symbolic links.  */
 #define AT_NO_AUTOMOUNT		0x800	/* Suppress terminal automount traversal */
 #define AT_EMPTY_PATH		0x1000	/* Allow empty relative pathname */
+#define AT_AUTOMOUNT_FOLLOW	0x2000	/* Follow terminal automounts */
 
 #ifdef __KERNEL__
 


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59034 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757895AbdEVQXl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 12:23:41 -0400
Subject: [PATCH 8/9] Honour CONTAINER_NEW_EMPTY_FS_NS
From: David Howells <dhowells@redhat.com>
To: trondmy@primarydata.com
Cc: mszeredi@redhat.com, linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        cgroups@vger.kernel.org, ebiederm@xmission.com
Date: Mon, 22 May 2017 17:23:32 +0100
Message-ID: <149547021255.10599.1836759405907841397.stgit@warthog.procyon.org.uk>
In-Reply-To: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow a container to be created with an empty mount namespace, as specified
by passing CONTAINER_NEW_EMPTY_FS_NS to container_create(), and allow a
root filesystem to be mounted into the container:

	cfd = container_create("foo", CONTAINER_NEW_EMPTY_FS_NS);
	fd = fsopen("ext3", cfd, 0);
	write(fd, "o foo");
	...
	fsmount(fd, -1, "/", AT_FSMOUNT_CONTAINER_ROOT, 0);
	close(fd);
	fd = fsopen("proc", cfd, 0);
	fsmount(fd, cfd, "/proc", 0, 0);
	close(fd);
---

 fs/namespace.c             |   84 ++++++++++++++++++++++++++++++++++++--------
 include/linux/mount.h      |    3 +-
 include/uapi/linux/fcntl.h |    2 +
 kernel/container.c         |    6 +++
 kernel/fork.c              |    5 ++-
 security/selinux/hooks.c   |    2 +
 6 files changed, 85 insertions(+), 17 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 9ca8b9f49f80..a365a7cba3ad 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2458,6 +2458,38 @@ static int do_add_mount(struct mount *newmnt, struct path *path, int mnt_flags,
 }
 
 static bool mount_too_revealing(struct vfsmount *mnt, int *new_mnt_flags);
+static struct mnt_namespace *create_mnt_ns(struct vfsmount *m);
+
+/*
+ * Create a mount namespace for a container and set the root mount in it.
+ */
+static int set_container_root(struct sb_config *sc, struct vfsmount *mnt)
+{
+	struct container *container = sc->container;
+	struct mnt_namespace *mnt_ns;
+	int ret = -EBUSY;
+
+	mnt_ns = create_mnt_ns(mnt);
+	if (IS_ERR(mnt_ns))
+		return PTR_ERR(mnt_ns);
+
+	spin_lock(&container->lock);
+	if (!container->ns->mnt_ns) {
+		container->ns->mnt_ns = mnt_ns;
+		write_seqcount_begin(&container->seq);
+		container->root.mnt = mnt;
+		container->root.dentry = mnt->mnt_root;
+		write_seqcount_end(&container->seq);
+		path_get(&container->root);
+		mnt_ns = NULL;
+		ret = 0;
+	}
+	spin_unlock(&container->lock);
+
+	if (ret < 0)
+		put_mnt_ns(mnt_ns);
+	return ret;
+}
 
 /*
  * Create a new mount using a superblock configuration and request it
@@ -2479,8 +2511,12 @@ static int do_new_mount_sc(struct sb_config *sc, struct path *mountpoint,
 		goto err_mnt;
 	}
 
-	ret = do_add_mount(real_mount(mnt), mountpoint, mnt_flags,
-			   sc->container ? sc->container->ns->mnt_ns : NULL);
+	if (mnt_flags & MNT_CONTAINER_ROOT)
+		ret = set_container_root(sc, mnt);
+	else
+		ret = do_add_mount(real_mount(mnt), mountpoint, mnt_flags,
+				   sc->container ? sc->container->ns->mnt_ns : NULL);
+
 	if (ret < 0) {
 		errorf("VFS: Failed to add mount");
 		goto err_mnt;
@@ -3262,10 +3298,17 @@ SYSCALL_DEFINE5(fsmount, int, fs_fd, int, dfd, const char __user *, dir_name,
 	struct fd f;
 	unsigned int lookup_flags, mnt_flags = 0;
 	long ret;
+	char buf[2];
 
 	if ((at_flags & ~(AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT |
-			  AT_EMPTY_PATH)) != 0)
+			  AT_EMPTY_PATH | AT_FSMOUNT_CONTAINER_ROOT)) != 0)
 		return -EINVAL;
+	if (at_flags & AT_FSMOUNT_CONTAINER_ROOT) {
+		if (strncpy_from_user(buf, dir_name, 2) < 0)
+			return -EFAULT;
+		if (buf[0] != '/' || buf[1] != '\0')
+			return -EINVAL;
+	}
 
 	if (flags & ~(MS_RDONLY | MS_NOSUID | MS_NODEV | MS_NOEXEC |
 		      MS_NOATIME | MS_NODIRATIME | MS_RELATIME | MS_STRICTATIME))
@@ -3317,18 +3360,29 @@ SYSCALL_DEFINE5(fsmount, int, fs_fd, int, dfd, const char __user *, dir_name,
 	if (ret < 0)
 		goto err_fsfd;
 
-	/* Find the mountpoint.  A container can be specified in dfd. */
-	lookup_flags = LOOKUP_FOLLOW | LOOKUP_AUTOMOUNT;
-	if (at_flags & AT_SYMLINK_NOFOLLOW)
-		lookup_flags &= ~LOOKUP_FOLLOW;
-	if (at_flags & AT_NO_AUTOMOUNT)
-		lookup_flags &= ~LOOKUP_AUTOMOUNT;
-	if (at_flags & AT_EMPTY_PATH)
-		lookup_flags |= LOOKUP_EMPTY;
-	ret = user_path_at(dfd, dir_name, lookup_flags, &mountpoint);
-	if (ret < 0) {
-		errorf("VFS: Mountpoint lookup failed");
-		goto err_fsfd;
+	if (at_flags & AT_FSMOUNT_CONTAINER_ROOT) {
+		/* We're mounting the root of the container that was specified
+		 * to sys_fsopen().  The dir_name should be specified as "/"
+		 * and dfd is ignored.
+		 */
+		mountpoint.mnt = NULL;
+		mountpoint.dentry = NULL;
+		mnt_flags |= MNT_CONTAINER_ROOT;
+	} else {
+		/* Find the mountpoint.  A container can be specified in dfd. */
+		lookup_flags = LOOKUP_FOLLOW | LOOKUP_AUTOMOUNT;
+
+		if (at_flags & AT_SYMLINK_NOFOLLOW)
+			lookup_flags &= ~LOOKUP_FOLLOW;
+		if (at_flags & AT_NO_AUTOMOUNT)
+			lookup_flags &= ~LOOKUP_AUTOMOUNT;
+		if (at_flags & AT_EMPTY_PATH)
+			lookup_flags |= LOOKUP_EMPTY;
+		ret = user_path_at(dfd, dir_name, lookup_flags, &mountpoint);
+		if (ret < 0) {
+			errorf("VFS: Mountpoint lookup failed");
+			goto err_fsfd;
+		}
 	}
 
 	ret = security_sb_mountpoint(sc, &mountpoint);
diff --git a/include/linux/mount.h b/include/linux/mount.h
index 265e9aa2ab0b..480c6b4061e0 100644
--- a/include/linux/mount.h
+++ b/include/linux/mount.h
@@ -51,7 +51,8 @@ struct sb_config;
 #define MNT_INTERNAL_FLAGS (MNT_SHARED | MNT_WRITE_HOLD | MNT_INTERNAL | \
 			    MNT_DOOMED | MNT_SYNC_UMOUNT | MNT_MARKED)
 
-#define MNT_INTERNAL	0x4000
+#define MNT_INTERNAL		0x4000
+#define MNT_CONTAINER_ROOT	0x8000		/* Mounting a container root */
 
 #define MNT_LOCK_ATIME		0x040000
 #define MNT_LOCK_NOEXEC		0x080000
diff --git a/include/uapi/linux/fcntl.h b/include/uapi/linux/fcntl.h
index 813afd6eee71..747af8704bbf 100644
--- a/include/uapi/linux/fcntl.h
+++ b/include/uapi/linux/fcntl.h
@@ -68,5 +68,7 @@
 #define AT_STATX_FORCE_SYNC	0x2000	/* - Force the attributes to be sync'd with the server */
 #define AT_STATX_DONT_SYNC	0x4000	/* - Don't sync attributes with the server */
 
+#define AT_FSMOUNT_CONTAINER_ROOT	0x2000
+
 
 #endif /* _UAPI_LINUX_FCNTL_H */
diff --git a/kernel/container.c b/kernel/container.c
index 5ebbf548f01a..68276603d255 100644
--- a/kernel/container.c
+++ b/kernel/container.c
@@ -23,6 +23,7 @@
 #include <linux/printk.h>
 #include <linux/security.h>
 #include <linux/proc_fs.h>
+#include <linux/mnt_namespace.h>
 #include "namespaces.h"
 
 struct container init_container = {
@@ -500,6 +501,11 @@ static struct container *create_container(const char *name, unsigned int flags)
 	fs->root.mnt = NULL;
 	fs->root.dentry = NULL;
 
+	if (flags & CONTAINER_NEW_EMPTY_FS_NS) {
+		put_mnt_ns(ns->mnt_ns);
+		ns->mnt_ns = NULL;
+	}
+
 	ret = security_container_alloc(c, flags);
 	if (ret < 0)
 		goto err_fs;
diff --git a/kernel/fork.c b/kernel/fork.c
index 68cd7367fcd5..e5111d4bcc1c 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -2169,7 +2169,10 @@ SYSCALL_DEFINE1(fork_into_container, int, containerfd)
 	if (is_container_file(f.file)) {
 		struct container *c = f.file->private_data;
 
-		ret = _do_fork(SIGCHLD, 0, 0, NULL, NULL, 0, c);
+		if (!c->ns->mnt_ns)
+			ret = -ENOENT;
+		else
+			ret = _do_fork(SIGCHLD, 0, 0, NULL, NULL, 0, c);
 	}
 	fdput(f);
 	return ret;
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 23bdbb0c2de5..f6b994b15a4d 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -2975,6 +2975,8 @@ static int selinux_sb_mountpoint(struct sb_config *sc, struct path *mountpoint)
 	const struct cred *cred = current_cred();
 	int ret;
 
+	if (!mountpoint->mnt)
+		return 0; /* This is the root in an empty namespace */
 	ret = path_has_perm(cred, mountpoint, FILE__MOUNTON);
 	if (ret < 0)
 		errorf("SELinux: Mount on mountpoint not permitted");


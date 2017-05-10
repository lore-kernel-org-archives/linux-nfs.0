Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60652 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754157AbdEJQTk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 10 May 2017 12:19:40 -0400
Subject: [PATCH 08/14] Implement fsmount() to effect a pre-configured mount
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk, jlayton@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Wed, 10 May 2017 17:19:38 +0100
Message-ID: <149443317815.2378.6903095335343754427.stgit@warthog.procyon.org.uk>
In-Reply-To: <149443309780.2378.6532276992468576087.stgit@warthog.procyon.org.uk>
References: <149443309780.2378.6532276992468576087.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Provide a system call by which a filesystem opened with fsopen() and
configured by a series of writes can be mounted:

	int ret = fsmount(int fsfd, int dfd, const char *path);

where fsfd is the fd returned by fsopen(), dfd and path describe the
mountpoint.  dfd can be AT_FDCWD or an fd open to a directory.

In the event that fsmount() fails, it may be possible to get an error
message by calling read().  If no message is available, ENODATA will be
reported.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 arch/x86/entry/syscalls/syscall_32.tbl |    1 
 arch/x86/entry/syscalls/syscall_64.tbl |    1 
 fs/namespace.c                         |   87 ++++++++++++++++++++++++++++++++
 include/linux/lsm_hooks.h              |    6 ++
 include/linux/security.h               |    6 ++
 include/linux/syscalls.h               |    1 
 kernel/sys_ni.c                        |    1 
 security/security.c                    |    7 +++
 security/selinux/hooks.c               |   13 +++++
 9 files changed, 123 insertions(+)

diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index 9bf8d4c62f85..abe6ea95e0e6 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -392,3 +392,4 @@
 383	i386	statx			sys_statx
 384	i386	arch_prctl		sys_arch_prctl			compat_sys_arch_prctl
 385	i386	fsopen			sys_fsopen
+386	i386	fsmount			sys_fsmount
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index 9b198c5fc412..0977c5079831 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -340,6 +340,7 @@
 331	common	pkey_free		sys_pkey_free
 332	common	statx			sys_statx
 333	common	fsopen			sys_fsopen
+334	common	fsmount			sys_fsmount
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/fs/namespace.c b/fs/namespace.c
index 554e99c980e0..49d630a4fbd4 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -3261,6 +3261,93 @@ vfs_submount_sc(const struct dentry *mountpoint, struct sb_config *sc)
 EXPORT_SYMBOL_GPL(vfs_submount_sc);
 
 /*
+ * Mount a new, prepared superblock (specified by fs_fd) on the location
+ * specified by dfd and dir_name.  dfd can be AT_FDCWD, a dir fd or a container
+ * fd.  This cannot be used for binding, moving or remounting mounts.
+ */
+SYSCALL_DEFINE3(fsmount, int, fs_fd, int, dfd, const char __user *, dir_name)
+{
+	struct sb_config *sc;
+	struct inode *inode;
+	struct path mountpoint;
+	struct fd f = fdget(fs_fd);
+	unsigned int mnt_flags = 0;
+	long ret;
+
+	if (!f.file)
+		return -EBADF;
+
+	ret = -EINVAL;
+	if (f.file->f_op != &fs_fs_fops)
+		goto err_fsfd;
+
+	sc = f.file->private_data;
+
+	ret = -EPERM;
+	if (!may_mount() ||
+	    ((sc->ms_flags & MS_MANDLOCK) && !may_mandlock()))
+		goto err_fsfd;
+
+	/* Prevent further changes. */
+	inode = file_inode(f.file);
+	ret = inode_lock_killable(inode);
+	if (ret < 0)
+		goto err_fsfd;
+	ret = -EBUSY;
+	if (!sc->mounted) {
+		sc->mounted = true;
+		ret = 0;
+	}
+	inode_unlock(inode);
+	if (ret < 0)
+		goto err_fsfd;
+
+	/* Find the mountpoint.  A container can be specified in dfd. */
+	ret = user_path_at(dfd, dir_name, LOOKUP_FOLLOW | LOOKUP_AUTOMOUNT,
+			   &mountpoint);
+	if (ret < 0) {
+		sb_cfg_error(sc, "VFS: Mountpoint lookup failed");
+		goto err_fsfd;
+	}
+
+	ret = security_sb_config_mountpoint(sc, &mountpoint);
+	if (ret < 0)
+		goto err_mp;
+
+	/* Default to relatime unless overriden */
+	if (!(sc->ms_flags & MS_NOATIME))
+		mnt_flags |= MNT_RELATIME;
+
+	/* Separate the per-mountpoint flags */
+	if (sc->ms_flags & MS_NOSUID)
+		mnt_flags |= MNT_NOSUID;
+	if (sc->ms_flags & MS_NODEV)
+		mnt_flags |= MNT_NODEV;
+	if (sc->ms_flags & MS_NOEXEC)
+		mnt_flags |= MNT_NOEXEC;
+	if (sc->ms_flags & MS_NOATIME)
+		mnt_flags |= MNT_NOATIME;
+	if (sc->ms_flags & MS_NODIRATIME)
+		mnt_flags |= MNT_NODIRATIME;
+	if (sc->ms_flags & MS_STRICTATIME)
+		mnt_flags &= ~(MNT_RELATIME | MNT_NOATIME);
+	if (sc->ms_flags & MS_RDONLY)
+		mnt_flags |= MNT_READONLY;
+
+	sc->ms_flags &= ~(MS_NOSUID | MS_NOEXEC | MS_NODEV | MS_ACTIVE | MS_BORN |
+			  MS_NOATIME | MS_NODIRATIME | MS_RELATIME| MS_KERNMOUNT |
+			  MS_STRICTATIME | MS_NOREMOTELOCK | MS_SUBMOUNT);
+
+	ret = do_new_mount_sc(sc, &mountpoint, mnt_flags);
+
+err_mp:
+	path_put(&mountpoint);
+err_fsfd:
+	fdput(f);
+	return ret;
+}
+
+/*
  * Return true if path is reachable from root
  *
  * namespace_sem or mount_lock is held
diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
index 6238fccaf5a4..e8e473ce5ddd 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -101,6 +101,10 @@
  *	Equivalent of sb_kern_mount, but with a superblock configuration context.
  *	@sc indicates the superblock configuration context.
  *	@src_sb indicates the new superblock.
+ * @sb_config_mountpoint:
+ *	Equivalent of sb_mount, but with an sb_config.
+ *	@sc indicates the superblock configuration context.
+ *	@mountpoint indicates the path on which the mount will take place.
  *
  * Security hooks for filesystem operations.
  *
@@ -1390,6 +1394,7 @@ union security_list_options {
 	void (*sb_config_free)(struct sb_config *sc);
 	int (*sb_config_parse_option)(struct sb_config *sc, char *opt);
 	int (*sb_config_kern_mount)(struct sb_config *sc, struct super_block *sb);
+	int (*sb_config_mountpoint)(struct sb_config *sc, struct path *mountpoint);
 
 	int (*sb_alloc_security)(struct super_block *sb);
 	void (*sb_free_security)(struct super_block *sb);
@@ -1704,6 +1709,7 @@ struct security_hook_heads {
 	struct list_head sb_config_free;
 	struct list_head sb_config_parse_option;
 	struct list_head sb_config_kern_mount;
+	struct list_head sb_config_mountpoint;
 	struct list_head sb_alloc_security;
 	struct list_head sb_free_security;
 	struct list_head sb_copy_data;
diff --git a/include/linux/security.h b/include/linux/security.h
index 49a7254aa30a..f95dc555cf29 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -226,6 +226,7 @@ int security_sb_config_dup(struct sb_config *sc, struct sb_config *src_sc);
 void security_sb_config_free(struct sb_config *sc);
 int security_sb_config_parse_option(struct sb_config *sc, char *opt);
 int security_sb_config_kern_mount(struct sb_config *sc, struct super_block *sb);
+int security_sb_config_mountpoint(struct sb_config *sc, struct path *mountpoint);
 int security_sb_alloc(struct super_block *sb);
 void security_sb_free(struct super_block *sb);
 int security_sb_copy_data(char *orig, char *copy);
@@ -541,6 +542,11 @@ static inline int security_sb_config_kern_mount(struct sb_config *sc,
 {
 	return 0;
 }
+static inline int security_sb_config_mountpoint(struct sb_config *sc,
+						struct path *mountpoint)
+{
+	return 0;
+}
 
 static inline int security_sb_alloc(struct super_block *sb)
 {
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 91ec8802ad5d..9ac7d8ca8c2e 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -906,5 +906,6 @@ asmlinkage long sys_pkey_free(int pkey);
 asmlinkage long sys_statx(int dfd, const char __user *path, unsigned flags,
 			  unsigned mask, struct statx __user *buffer);
 asmlinkage long sys_fsopen(const char *fs_name, int containerfd, unsigned int flags);
+asmlinkage long sys_fsmount(int fsfd, int dfd, const char *path);
 
 #endif
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index de1dc63e7e47..a0fe764bd5dd 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -261,3 +261,4 @@ cond_syscall(sys_pkey_free);
 
 /* fd-based mount */
 cond_syscall(sys_fsopen);
+cond_syscall(sys_fsmount);
diff --git a/security/security.c b/security/security.c
index fa9037186634..8b2b7e6b3112 100644
--- a/security/security.c
+++ b/security/security.c
@@ -334,6 +334,11 @@ int security_sb_config_kern_mount(struct sb_config *sc, struct super_block *sb)
 	return call_int_hook(sb_config_kern_mount, 0, sc, sb);
 }
 
+int security_sb_config_mountpoint(struct sb_config *sc, struct path *mountpoint)
+{
+	return call_int_hook(sb_config_mountpoint, 0, sc, mountpoint);
+}
+
 int security_sb_alloc(struct super_block *sb)
 {
 	return call_int_hook(sb_alloc_security, 0, sb);
@@ -1691,6 +1696,8 @@ struct security_hook_heads security_hook_heads = {
 		LIST_HEAD_INIT(security_hook_heads.sb_config_parse_option),
 	.sb_config_kern_mount =
 		LIST_HEAD_INIT(security_hook_heads.sb_config_kern_mount),
+	.sb_config_mountpoint =
+		LIST_HEAD_INIT(security_hook_heads.sb_config_mountpoint),
 	.sb_alloc_security =
 		LIST_HEAD_INIT(security_hook_heads.sb_alloc_security),
 	.sb_free_security =
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 142be91888c9..e1bf18af72f5 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -2990,6 +2990,18 @@ static int selinux_sb_config_kern_mount(struct sb_config *sc,
 	return rc;
 }
 
+static int selinux_sb_config_mountpoint(struct sb_config *sc,
+					struct path *mountpoint)
+{
+	const struct cred *cred = current_cred();
+	int ret;
+
+	ret = path_has_perm(cred, mountpoint, FILE__MOUNTON);
+	if (ret < 0)
+		sb_cfg_error(sc, "SELinux: Mount on mountpoint not permitted");
+	return ret;
+}
+
 /* inode security operations */
 
 static int selinux_inode_alloc_security(struct inode *inode)
@@ -6300,6 +6312,7 @@ static struct security_hook_list selinux_hooks[] = {
 	LSM_HOOK_INIT(sb_config_free, selinux_sb_config_free),
 	LSM_HOOK_INIT(sb_config_parse_option, selinux_sb_config_parse_option),
 	LSM_HOOK_INIT(sb_config_kern_mount, selinux_sb_config_kern_mount),
+	LSM_HOOK_INIT(sb_config_mountpoint, selinux_sb_config_mountpoint),
 
 	LSM_HOOK_INIT(sb_alloc_security, selinux_sb_alloc_security),
 	LSM_HOOK_INIT(sb_free_security, selinux_sb_free_security),


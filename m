Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48954 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753312AbdECQFZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 3 May 2017 12:05:25 -0400
Subject: [PATCH 5/9] Implement fsmount() to effect a pre-configured mount
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, dhowells@redhat.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        mszeredi@redhat.com
Date: Wed, 03 May 2017 17:05:15 +0100
Message-ID: <149382751575.30481.5197100856310494934.stgit@warthog.procyon.org.uk>
In-Reply-To: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
References: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
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
 fs/namespace.c                         |   93 ++++++++++++++++++++++++++++++++
 include/linux/lsm_hooks.h              |    6 ++
 include/linux/security.h               |    6 ++
 include/linux/syscalls.h               |    1 
 kernel/sys_ni.c                        |    1 
 security/security.c                    |    7 ++
 security/selinux/hooks.c               |   13 ++++
 9 files changed, 129 insertions(+)

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
index e0edab9af308..a367b6cb2ac8 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -3259,6 +3259,99 @@ static int do_new_mount_mc(struct mount_context *mc, struct path *mountpoint,
 }
 
 /*
+ * Mount a new, prepared superblock (specified by fs_fd) on the location
+ * specified by dfd and dir_name.  dfd can be AT_FDCWD, a dir fd or a container
+ * fd.  This cannot be used for binding, moving or remounting mounts.
+ *
+ * If fd is a container and dir_name is NULL, then we try to make this the root
+ * filesystem of that container.  This requires CONTAINER_NEW_EMPTY_FS_NS to
+ * have been passed when creating the container.  This operation may only be
+ * done once.
+ */
+SYSCALL_DEFINE3(fsmount, int, fs_fd, int, dfd, const char __user *, dir_name)
+{
+	struct mount_context *mc;
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
+	mc = f.file->private_data;
+
+	ret = -EPERM;
+	if (!may_mount() ||
+	    ((mc->ms_flags & MS_MANDLOCK) && !may_mandlock()))
+		goto err_fsfd;
+
+	/* Prevent further changes. */
+	inode = file_inode(f.file);
+	ret = inode_lock_killable(inode);
+	if (ret < 0)
+		goto err_fsfd;
+	ret = -EBUSY;
+	if (!mc->mounted) {
+		mc->mounted = true;
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
+		mc->error = "VFS: Mountpoint lookup failed";
+		goto err_fsfd;
+	}
+
+	ret = security_mount_ctx_mountpoint(mc, &mountpoint);
+	if (ret < 0)
+		goto err_mp;
+
+	/* Default to relatime unless overriden */
+	if (!(mc->ms_flags & MS_NOATIME))
+		mnt_flags |= MNT_RELATIME;
+
+	/* Separate the per-mountpoint flags */
+	if (mc->ms_flags & MS_NOSUID)
+		mnt_flags |= MNT_NOSUID;
+	if (mc->ms_flags & MS_NODEV)
+		mnt_flags |= MNT_NODEV;
+	if (mc->ms_flags & MS_NOEXEC)
+		mnt_flags |= MNT_NOEXEC;
+	if (mc->ms_flags & MS_NOATIME)
+		mnt_flags |= MNT_NOATIME;
+	if (mc->ms_flags & MS_NODIRATIME)
+		mnt_flags |= MNT_NODIRATIME;
+	if (mc->ms_flags & MS_STRICTATIME)
+		mnt_flags &= ~(MNT_RELATIME | MNT_NOATIME);
+	if (mc->ms_flags & MS_RDONLY)
+		mnt_flags |= MNT_READONLY;
+	mc->mnt_flags = mnt_flags;
+
+	mc->ms_flags &= ~(MS_NOSUID | MS_NOEXEC | MS_NODEV | MS_ACTIVE | MS_BORN |
+			  MS_NOATIME | MS_NODIRATIME | MS_RELATIME| MS_KERNMOUNT |
+			  MS_STRICTATIME | MS_NOREMOTELOCK | MS_SUBMOUNT);
+
+	ret = do_new_mount_mc(mc, &mountpoint, mnt_flags);
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
index f6aa68b8e68e..fe2bffd7264d 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -100,6 +100,10 @@
  *	Equivalent of sb_kern_mount, but with a mount_context.
  *	@mc indicates the mount context.
  *	@src_sb indicates the new superblock.
+ * @mount_ctx_mountpoint:
+ *	Equivalent of sb_mount, but with a mount_context.
+ *	@mc indicates the mount context.
+ *	@mountpoint indicates the path on which the mount will take place.
  *
  * Security hooks for filesystem operations.
  *
@@ -1389,6 +1393,7 @@ union security_list_options {
 	void (*mount_ctx_free)(struct mount_context *mc);
 	int (*mount_ctx_option)(struct mount_context *mc, char *opt);
 	int (*mount_ctx_kern_mount)(struct mount_context *mc, struct super_block *sb);
+	int (*mount_ctx_mountpoint)(struct mount_context *mc, struct path *mountpoint);
 
 	int (*sb_alloc_security)(struct super_block *sb);
 	void (*sb_free_security)(struct super_block *sb);
@@ -1703,6 +1708,7 @@ struct security_hook_heads {
 	struct list_head mount_ctx_free;
 	struct list_head mount_ctx_option;
 	struct list_head mount_ctx_kern_mount;
+	struct list_head mount_ctx_mountpoint;
 	struct list_head sb_alloc_security;
 	struct list_head sb_free_security;
 	struct list_head sb_copy_data;
diff --git a/include/linux/security.h b/include/linux/security.h
index 91efe3039bff..b427a554033a 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -226,6 +226,7 @@ int security_mount_ctx_dup(struct mount_context *mc, struct mount_context *src);
 void security_mount_ctx_free(struct mount_context *mc);
 int security_mount_ctx_option(struct mount_context *mc, char *opt);
 int security_mount_ctx_kern_mount(struct mount_context *mc, struct super_block *sb);
+int security_mount_ctx_mountpoint(struct mount_context *mc, struct path *mountpoint);
 int security_sb_alloc(struct super_block *sb);
 void security_sb_free(struct super_block *sb);
 int security_sb_copy_data(char *orig, char *copy);
@@ -541,6 +542,11 @@ static inline int security_mount_ctx_kern_mount(struct mount_context *mc,
 {
 	return 0;
 }
+static inline int security_mount_ctx_mountpoint(struct mount_context *mc,
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
index 2e522361df66..56780c1852b5 100644
--- a/security/security.c
+++ b/security/security.c
@@ -334,6 +334,11 @@ int security_mount_ctx_kern_mount(struct mount_context *mc, struct super_block *
 	return call_int_hook(mount_ctx_kern_mount, 0, mc, sb);
 }
 
+int security_mount_ctx_mountpoint(struct mount_context *mc, struct path *mountpoint)
+{
+	return call_int_hook(mount_ctx_mountpoint, 0, mc, mountpoint);
+}
+
 int security_sb_alloc(struct super_block *sb)
 {
 	return call_int_hook(sb_alloc_security, 0, sb);
@@ -1691,6 +1696,8 @@ struct security_hook_heads security_hook_heads = {
 		LIST_HEAD_INIT(security_hook_heads.mount_ctx_option),
 	.mount_ctx_kern_mount =
 		LIST_HEAD_INIT(security_hook_heads.mount_ctx_kern_mount),
+	.mount_ctx_mountpoint =
+		LIST_HEAD_INIT(security_hook_heads.mount_ctx_mountpoint),
 	.sb_alloc_security =
 		LIST_HEAD_INIT(security_hook_heads.sb_alloc_security),
 	.sb_free_security =
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index cf38db840f71..2bd8e73eb9c9 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -2999,6 +2999,18 @@ static int selinux_mount_ctx_kern_mount(struct mount_context *mc,
 	return rc;
 }
 
+static int selinux_mount_ctx_mountpoint(struct mount_context *mc,
+					struct path *mountpoint)
+{
+	const struct cred *cred = current_cred();
+	int ret;
+
+	ret = path_has_perm(cred, mountpoint, FILE__MOUNTON);
+	if (ret < 0)
+		mc->error = "SELinux: Mount on mountpoint not permitted";
+	return ret;
+}
+
 /* inode security operations */
 
 static int selinux_inode_alloc_security(struct inode *inode)
@@ -6309,6 +6321,7 @@ static struct security_hook_list selinux_hooks[] = {
 	LSM_HOOK_INIT(mount_ctx_free, selinux_mount_ctx_free),
 	LSM_HOOK_INIT(mount_ctx_option, selinux_mount_ctx_option),
 	LSM_HOOK_INIT(mount_ctx_kern_mount, selinux_mount_ctx_kern_mount),
+	LSM_HOOK_INIT(mount_ctx_mountpoint, selinux_mount_ctx_mountpoint),
 
 	LSM_HOOK_INIT(sb_alloc_security, selinux_sb_alloc_security),
 	LSM_HOOK_INIT(sb_free_security, selinux_sb_free_security),


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41192 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752141AbdFNPR2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Jun 2017 11:17:28 -0400
Subject: [PATCH 13/27] VFS: Implement fsmount() to effect a pre-configured
 mount [ver #5]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Date: Wed, 14 Jun 2017 16:17:19 +0100
Message-ID: <149745343991.10897.9754948236224112565.stgit@warthog.procyon.org.uk>
In-Reply-To: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
References: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Provide a system call by which a filesystem opened with fsopen() and
configured by a series of writes can be mounted:

	int ret = fsmount(int fsfd, int dfd, const char *path,
			  unsigned int at_flags, unsigned int flags);

where fsfd is the fd returned by fsopen(), dfd, path and at_flags locate
the mountpoint and flags are the applicable MS_* flags.  dfd can be
AT_FDCWD or an fd open to a directory.

In the event that fsmount() fails, it may be possible to get an error
message by calling read().  If no message is available, ENODATA will be
reported.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 arch/x86/entry/syscalls/syscall_32.tbl |    1 
 arch/x86/entry/syscalls/syscall_64.tbl |    1 
 fs/namespace.c                         |   85 ++++++++++++++++++++++++++++++++
 include/linux/syscalls.h               |    2 +
 kernel/sys_ni.c                        |    1 
 5 files changed, 90 insertions(+)

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
index cd44283dee99..9158b67936a5 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -3241,6 +3241,91 @@ vfs_submount(const struct dentry *mountpoint, struct file_system_type *type,
 EXPORT_SYMBOL_GPL(vfs_submount);
 
 /*
+ * Mount a new, prepared superblock (specified by fs_fd) on the location
+ * specified by dfd and dir_name.  dfd can be AT_FDCWD, a dir fd or a container
+ * fd.  This cannot be used for binding, moving or remounting mounts.
+ */
+SYSCALL_DEFINE5(fsmount, int, fs_fd, int, dfd, const char __user *, dir_name,
+		unsigned int, at_flags, unsigned int, flags)
+{
+	struct fs_context *fc;
+	struct path mountpoint;
+	struct fd f;
+	unsigned int lookup_flags, mnt_flags = 0;
+	long ret;
+
+	if ((at_flags & ~(AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT |
+			  AT_EMPTY_PATH)) != 0)
+		return -EINVAL;
+
+	if (flags & ~(MS_RDONLY | MS_NOSUID | MS_NODEV | MS_NOEXEC |
+		      MS_NOATIME | MS_NODIRATIME | MS_RELATIME | MS_STRICTATIME))
+		return -EINVAL;
+
+	if (flags & MS_RDONLY)
+		mnt_flags |= MNT_READONLY;
+	if (flags & MS_NOSUID)
+		mnt_flags |= MNT_NOSUID;
+	if (flags & MS_NODEV)
+		mnt_flags |= MNT_NODEV;
+	if (flags & MS_NOEXEC)
+		mnt_flags |= MNT_NOEXEC;
+	if (flags & MS_NODIRATIME)
+		mnt_flags |= MNT_NODIRATIME;
+
+	if (flags & MS_STRICTATIME) {
+		if (flags & MS_NOATIME)
+			return -EINVAL;
+	} else if (flags & MS_NOATIME) {
+		mnt_flags |= MNT_NOATIME;
+	} else {
+		mnt_flags |= MNT_RELATIME;
+	}
+
+	f = fdget(fs_fd);
+	if (!f.file)
+		return -EBADF;
+
+	ret = -EINVAL;
+	if (f.file->f_op != &fs_fs_fops)
+		goto err_fsfd;
+
+	fc = f.file->private_data;
+
+	ret = -EPERM;
+	if (!may_mount() ||
+	    ((fc->sb_flags & MS_MANDLOCK) && !may_mandlock()))
+		goto err_fsfd;
+
+	/* There must be a valid superblock or we can't mount it */
+	if (!fc->root) {
+		ret = invalf("VFS: Root must be obtained before mount");
+		goto err_fsfd;
+	}
+
+	/* Find the mountpoint.  A container can be specified in dfd. */
+	lookup_flags = LOOKUP_FOLLOW | LOOKUP_AUTOMOUNT;
+	if (at_flags & AT_SYMLINK_NOFOLLOW)
+		lookup_flags &= ~LOOKUP_FOLLOW;
+	if (at_flags & AT_NO_AUTOMOUNT)
+		lookup_flags &= ~LOOKUP_AUTOMOUNT;
+	if (at_flags & AT_EMPTY_PATH)
+		lookup_flags |= LOOKUP_EMPTY;
+	ret = user_path_at(dfd, dir_name, lookup_flags, &mountpoint);
+	if (ret < 0) {
+		errorf("VFS: Mountpoint lookup failed");
+		goto err_fsfd;
+	}
+
+	ret = do_new_mount_fc(fc, &mountpoint, mnt_flags);
+
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
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 91ec8802ad5d..07e4f775f24d 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -906,5 +906,7 @@ asmlinkage long sys_pkey_free(int pkey);
 asmlinkage long sys_statx(int dfd, const char __user *path, unsigned flags,
 			  unsigned mask, struct statx __user *buffer);
 asmlinkage long sys_fsopen(const char *fs_name, int containerfd, unsigned int flags);
+asmlinkage long sys_fsmount(int fsfd, int dfd, const char *path, unsigned int at_flags,
+			    unsigned int flags);
 
 #endif
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index de1dc63e7e47..a0fe764bd5dd 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -261,3 +261,4 @@ cond_syscall(sys_pkey_free);
 
 /* fd-based mount */
 cond_syscall(sys_fsopen);
+cond_syscall(sys_fsmount);


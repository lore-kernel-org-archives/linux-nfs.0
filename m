Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:42964 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752666AbeDSNdY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 19 Apr 2018 09:33:24 -0400
Subject: [PATCH 19/24] VFS: Implement fsmount() to effect a pre-configured
 mount [ver #7]
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Date: Thu, 19 Apr 2018 14:33:21 +0100
Message-ID: <152414480180.23902.5252193699954530512.stgit@warthog.procyon.org.uk>
In-Reply-To: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
References: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
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
 fs/namespace.c                         |   82 ++++++++++++++++++++++++++++++++
 include/linux/fs_context.h             |    2 -
 include/linux/syscalls.h               |    2 +
 kernel/sys_ni.c                        |    1 
 6 files changed, 88 insertions(+), 1 deletion(-)

diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index d02346692c3f..5efec45b5ecb 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -397,3 +397,4 @@
 383	i386	statx			sys_statx			__ia32_sys_statx
 384	i386	arch_prctl		sys_arch_prctl			__ia32_compat_sys_arch_prctl
 385	i386	fsopen			sys_fsopen			__ia32_sys_fsopen
+386	i386	fsmount			sys_fsmount			__ia32_sys_fsmount
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index 6708847571e2..f602389e1406 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -342,6 +342,7 @@
 331	common	pkey_free		__x64_sys_pkey_free
 332	common	statx			__x64_sys_statx
 333	common	fsopen			__x64_sys_fsopen
+334	common	fsmount			__x64_sys_fsmount
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/fs/namespace.c b/fs/namespace.c
index dff482ad87b4..14d110901bbe 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -3192,6 +3192,88 @@ struct vfsmount *kern_mount(struct file_system_type *type)
 }
 EXPORT_SYMBOL_GPL(kern_mount);
 
+/*
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
+	if (f.file->f_op != &fscontext_fs_fops)
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
+	ret = -EINVAL;
+	if (!fc->root)
+		goto err_fsfd;
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
+	if (ret < 0)
+		goto err_fsfd;
+
+	ret = do_new_mount_fc(fc, &mountpoint, mnt_flags);
+
+	path_put(&mountpoint);
+err_fsfd:
+	fdput(f);
+	return ret;
+}
+
 /*
  * Return true if path is reachable from root
  *
diff --git a/include/linux/fs_context.h b/include/linux/fs_context.h
index 536ae7d60f1f..dd79acddabec 100644
--- a/include/linux/fs_context.h
+++ b/include/linux/fs_context.h
@@ -102,5 +102,5 @@ extern int vfs_get_super(struct fs_context *fc,
 			 int (*fill_super)(struct super_block *sb,
 					   struct fs_context *fc));
 
-extern const struct file_operations fs_fs_fops;
+extern const struct file_operations fscontext_fs_fops;
 #endif /* _LINUX_FS_CONTEXT_H */
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 3c9b10e92015..e5f68788a096 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -892,6 +892,8 @@ asmlinkage long sys_statx(int dfd, const char __user *path, unsigned flags,
 			  unsigned mask, struct statx __user *buffer);
 asmlinkage long sys_fsopen(const char *fs_name, unsigned int flags,
 			   void *reserved3, void *reserved4, void *reserved5);
+asmlinkage long sys_fsmount(int fsfd, int dfd, const char *path, unsigned int at_flags,
+			    unsigned int flags);
 
 
 /*
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index c113fc9d5e77..2c236aad9b80 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -433,3 +433,4 @@ COND_SYSCALL(setuid16);
 
 /* fd-based mount */
 COND_SYSCALL(sys_fsopen);
+COND_SYSCALL(sys_fsmount);


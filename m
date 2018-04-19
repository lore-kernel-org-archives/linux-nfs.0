Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:60624 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753423AbeDSNdR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 19 Apr 2018 09:33:17 -0400
Subject: [PATCH 18/24] VFS: Implement fsopen() to prepare for a mount [ver
 #7]
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Date: Thu, 19 Apr 2018 14:33:14 +0100
Message-ID: <152414479473.23902.12923535574509363916.stgit@warthog.procyon.org.uk>
In-Reply-To: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
References: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Provide an fsopen() system call that starts the process of preparing to
mount, using an fd as a context handle.  fsopen() is given the name of the
filesystem that will be used:

	int mfd = fsopen(const char *fsname, int open_flags,
			 void *reserved3, void *reserved4,
			 void *reserved5);

where open_flags can be 0 or O_CLOEXEC and reserved* should all be NULL for
the moment.

For example:

	mfd = fsopen("ext4", O_CLOEXEC, NULL, NULL, NULL);
	write(mfd, "s /dev/sdb1"); // note I'm ignoring write's length arg
	write(mfd, "o noatime");
	write(mfd, "o acl");
	write(mfd, "o user_attr");
	write(mfd, "o iversion");
	write(mfd, "o ");
	write(mfd, "r /my/container"); // root inside the fs
	write(mfd, "x create"); // create the superblock
	fsmount(mfd, container_fd, "/mnt", AT_NO_FOLLOW);

	mfd = fsopen("afs", -1);
	write(mfd, "s %grand.central.org:root.cell");
	write(mfd, "o cell=grand.central.org");
	write(mfd, "r /");
	write(mfd, "x create");
	fsmount(mfd, AT_FDCWD, "/mnt", 0);

If an error is reported at any step, an error message may be available to be
read() back (ENODATA will be reported if there isn't an error available) in
the form:

	"e <subsys>:<problem>"
	"e SELinux:Mount on mountpoint not permitted"

Once fsmount() has been called, further write() calls will incur EBUSY,
even if the fsmount() fails.  read() is still possible to retrieve error
information.

The fsopen() syscall creates a mount context and hangs it of the fd that it
returns.

Netlink is not used because it is optional.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 arch/x86/entry/syscalls/syscall_32.tbl |    1 
 arch/x86/entry/syscalls/syscall_64.tbl |    1 
 fs/Makefile                            |    2 
 fs/fsopen.c                            |  304 ++++++++++++++++++++++++++++++++
 fs/super.c                             |    3 
 include/linux/fs_context.h             |    1 
 include/linux/syscalls.h               |    2 
 include/uapi/linux/magic.h             |    1 
 kernel/sys_ni.c                        |    3 
 9 files changed, 315 insertions(+), 3 deletions(-)
 create mode 100644 fs/fsopen.c

diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index d6b27dab1b30..d02346692c3f 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -396,3 +396,4 @@
 382	i386	pkey_free		sys_pkey_free			__ia32_sys_pkey_free
 383	i386	statx			sys_statx			__ia32_sys_statx
 384	i386	arch_prctl		sys_arch_prctl			__ia32_compat_sys_arch_prctl
+385	i386	fsopen			sys_fsopen			__ia32_sys_fsopen
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index 4dfe42666d0c..6708847571e2 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -341,6 +341,7 @@
 330	common	pkey_alloc		__x64_sys_pkey_alloc
 331	common	pkey_free		__x64_sys_pkey_free
 332	common	statx			__x64_sys_statx
+333	common	fsopen			__x64_sys_fsopen
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/fs/Makefile b/fs/Makefile
index 6f2dae3c32da..ee3c8b31cc58 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -13,7 +13,7 @@ obj-y :=	open.o read_write.o file_table.o super.o \
 		seq_file.o xattr.o libfs.o fs-writeback.o \
 		pnode.o splice.o sync.o utimes.o d_path.o \
 		stack.o fs_struct.o statfs.o fs_pin.o nsfs.o \
-		fs_context.o
+		fs_context.o fsopen.o
 
 ifeq ($(CONFIG_BLOCK),y)
 obj-y +=	buffer.o block_dev.o direct-io.o mpage.o
diff --git a/fs/fsopen.c b/fs/fsopen.c
new file mode 100644
index 000000000000..2d115bad13bb
--- /dev/null
+++ b/fs/fsopen.c
@@ -0,0 +1,304 @@
+/* Filesystem access-by-fd.
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
+#include <linux/fs_context.h>
+#include <linux/mount.h>
+#include <linux/slab.h>
+#include <linux/uaccess.h>
+#include <linux/file.h>
+#include <linux/magic.h>
+#include <linux/syscalls.h>
+
+static struct vfsmount *fscontext_fs_mnt __read_mostly;
+
+static int fscontext_fs_release(struct inode *inode, struct file *file)
+{
+	struct fs_context *fc = file->private_data;
+
+	file->private_data = NULL;
+
+	put_fs_context(fc);
+	return 0;
+}
+
+/*
+ * Userspace writes configuration data and commands to the fd and we parse it
+ * here.  For the moment, we assume a single option or command per write.  Each
+ * line written is of the form
+ *
+ *	<option_type><space><stuff...>
+ *
+ *	d /dev/sda1				-- Device name
+ *	o noatime				-- Option without value
+ *	o cell=grand.central.org		-- Option with value
+ *	r /					-- Dir within device to mount
+ *	x create				-- Create a superblock
+ */
+static ssize_t fscontext_fs_write(struct file *file,
+			   const char __user *_buf, size_t len, loff_t *pos)
+{
+	struct fs_context *fc = file->private_data;
+	struct inode *inode = file_inode(file);
+	char opt[2], *data;
+	ssize_t ret;
+
+	if (len < 3 || len > 4095)
+		return -EINVAL;
+
+	if (copy_from_user(opt, _buf, 2) != 0)
+		return -EFAULT;
+	switch (opt[0]) {
+	case 's':
+	case 'o':
+	case 'x':
+		break;
+	default:
+		goto err_bad_cmd;
+	}
+	if (opt[1] != ' ')
+		goto err_bad_cmd;
+
+	data = memdup_user_nul(_buf + 2, len - 2);
+	if (IS_ERR(data))
+		return PTR_ERR(data);
+
+	/* From this point onwards we need to lock the fd against someone
+	 * trying to mount it.
+	 */
+	ret = inode_lock_killable(inode);
+	if (ret < 0)
+		goto err_free;
+
+	ret = -EINVAL;
+	switch (opt[0]) {
+	case 's':
+		ret = vfs_set_fs_source(fc, data, len - 2);
+		if (ret < 0)
+			goto err_unlock;
+		data = NULL;
+		break;
+
+	case 'o':
+		ret = vfs_parse_fs_option(fc, data, len - 2);
+		if (ret < 0)
+			goto err_unlock;
+		break;
+
+	case 'x':
+		if (strcmp(data, "create") == 0) {
+			ret = vfs_get_tree(fc);
+		} else {
+			ret = -EOPNOTSUPP;
+		}
+		if (ret < 0)
+			goto err_unlock;
+		break;
+
+	default:
+		goto err_unlock;
+	}
+
+	ret = len;
+err_unlock:
+	inode_unlock(inode);
+err_free:
+	kfree(data);
+	return ret;
+err_bad_cmd:
+	return -EINVAL;
+}
+
+const struct file_operations fscontext_fs_fops = {
+	.write		= fscontext_fs_write,
+	.release	= fscontext_fs_release,
+	.llseek		= no_llseek,
+};
+
+/*
+ * Indicate the name we want to display the filesystem file as.
+ */
+static char *fscontext_fs_dname(struct dentry *dentry, char *buffer, int buflen)
+{
+	return dynamic_dname(dentry, buffer, buflen, "fs:[%lu]",
+			     d_inode(dentry)->i_ino);
+}
+
+static const struct dentry_operations fscontext_fs_dentry_operations = {
+	.d_dname	= fscontext_fs_dname,
+};
+
+/*
+ * Create a file that can be used to configure a new mount.
+ */
+static struct file *create_fscontext_file(struct fs_context *fc)
+{
+	struct inode *inode;
+	struct file *f;
+	struct path path;
+	int ret;
+
+	inode = alloc_anon_inode(fscontext_fs_mnt->mnt_sb);
+	if (IS_ERR(inode))
+		return ERR_CAST(inode);
+	inode->i_fop = &fscontext_fs_fops;
+
+	ret = -ENOMEM;
+	path.dentry = d_alloc_pseudo(fscontext_fs_mnt->mnt_sb, &empty_name);
+	if (!path.dentry)
+		goto err_inode;
+	path.mnt = mntget(fscontext_fs_mnt);
+
+	d_instantiate(path.dentry, inode);
+
+	f = alloc_file(&path, FMODE_READ | FMODE_WRITE, &fscontext_fs_fops);
+	if (IS_ERR(f)) {
+		ret = PTR_ERR(f);
+		goto err_file;
+	}
+
+	f->private_data = fc;
+	return f;
+
+err_file:
+	path_put(&path);
+	return ERR_PTR(ret);
+
+err_inode:
+	iput(inode);
+	return ERR_PTR(ret);
+}
+
+static const struct super_operations fscontext_fs_super_ops = {
+	.drop_inode	= generic_delete_inode,
+	.destroy_inode	= free_inode_nonrcu,
+	.statfs		= simple_statfs,
+};
+
+/*
+ * Finish filling in the superblock and allocate the root dentry.
+ */
+static int fscontext_fs_fill_super(struct super_block *sb,
+				   struct fs_context *fc)
+{
+	struct dentry *root;
+	struct inode *inode;
+
+	sb->s_op = &fscontext_fs_super_ops;
+	inode = alloc_anon_inode(sb);
+	if (IS_ERR(inode))
+		return PTR_ERR(inode);
+	inode->i_fop = &fscontext_fs_fops;
+
+	root = d_make_root(inode);
+	if (!root)
+		return -ENOMEM; /* inode is put by d_make_root() */
+	sb->s_root = root;
+	return 0;
+}
+
+static int fscontext_fs_get_tree(struct fs_context *fc)
+{
+	return vfs_get_super(fc, vfs_get_single_super, fscontext_fs_fill_super);
+}
+
+static const struct fs_context_operations fscontext_fs_context_ops = {
+	.get_tree	= fscontext_fs_get_tree,
+};
+
+static int fs_init_fs_context(struct fs_context *fc, struct super_block *src_sb)
+{
+	fc->ops = &fscontext_fs_context_ops;
+	return 0;
+}
+
+static struct file_system_type fscontext_fs_type = {
+	.name			= "fscontext",
+	.fs_context_size	= sizeof(struct fs_context),
+	.init_fs_context	= fs_init_fs_context,
+	.kill_sb		= kill_anon_super,
+};
+
+static int __init init_fscontext_fs(void)
+{
+	int ret;
+
+	ret = register_filesystem(&fscontext_fs_type);
+	if (ret < 0)
+		panic("Cannot register fscontext_fs\n");
+
+	fscontext_fs_mnt = kern_mount(&fscontext_fs_type);
+	if (IS_ERR(fscontext_fs_mnt))
+		panic("Cannot mount fscontext_fs: %ld\n",
+		      PTR_ERR(fscontext_fs_mnt));
+	return 0;
+}
+
+fs_initcall(init_fscontext_fs);
+
+/*
+ * Open a filesystem by name so that it can be configured for mounting.
+ *
+ * We are allowed to specify a container in which the filesystem will be
+ * opened, thereby indicating which namespaces will be used (notably, which
+ * network namespace will be used for network filesystems).
+ */
+SYSCALL_DEFINE5(fsopen, const char __user *, _fs_name, unsigned int, flags,
+		void *, reserved3, void *, reserved4, void *, reserved5)
+{
+	struct file_system_type *fs_type;
+	struct fs_context *fc;
+	struct file *file;
+	const char *fs_name;
+	int fd, ret;
+
+	if (flags & ~O_CLOEXEC || reserved3 || reserved4 || reserved5)
+		return -EINVAL;
+
+	fs_name = strndup_user(_fs_name, PAGE_SIZE);
+	if (IS_ERR(fs_name))
+		return PTR_ERR(fs_name);
+
+	fs_type = get_fs_type(fs_name);
+	kfree(fs_name);
+	if (!fs_type)
+		return -ENODEV;
+
+	fc = vfs_new_fs_context(fs_type, NULL, 0, FS_CONTEXT_FOR_USER_MOUNT);
+	put_filesystem(fs_type);
+	if (IS_ERR(fc))
+		return PTR_ERR(fc);
+
+	ret = -ENOTSUPP;
+	if (!fc->ops)
+		goto err_fc;
+
+	file = create_fscontext_file(fc);
+	if (IS_ERR(file)) {
+		ret = PTR_ERR(file);
+		goto err_fc;
+	}
+
+	ret = get_unused_fd_flags(flags & O_CLOEXEC);
+	if (ret < 0)
+		goto err_file;
+
+	fd = ret;
+	fd_install(fd, file);
+	return fd;
+
+err_file:
+	fput(file);
+	return ret;
+
+err_fc:
+	put_fs_context(fc);
+	return ret;
+}
diff --git a/fs/super.c b/fs/super.c
index a27487e34ea4..1e2942f81bc9 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -1270,8 +1270,7 @@ int vfs_get_super(struct fs_context *fc,
 		return PTR_ERR(sb);
 
 	if (!sb->s_root) {
-		int err;
-		err = fill_super(sb, fc);
+		int err = fill_super(sb, fc);
 		if (err) {
 			deactivate_locked_super(sb);
 			return err;
diff --git a/include/linux/fs_context.h b/include/linux/fs_context.h
index 1914eef0a88f..536ae7d60f1f 100644
--- a/include/linux/fs_context.h
+++ b/include/linux/fs_context.h
@@ -102,4 +102,5 @@ extern int vfs_get_super(struct fs_context *fc,
 			 int (*fill_super)(struct super_block *sb,
 					   struct fs_context *fc));
 
+extern const struct file_operations fs_fs_fops;
 #endif /* _LINUX_FS_CONTEXT_H */
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 70fcda1a9049..3c9b10e92015 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -890,6 +890,8 @@ asmlinkage long sys_pkey_alloc(unsigned long flags, unsigned long init_val);
 asmlinkage long sys_pkey_free(int pkey);
 asmlinkage long sys_statx(int dfd, const char __user *path, unsigned flags,
 			  unsigned mask, struct statx __user *buffer);
+asmlinkage long sys_fsopen(const char *fs_name, unsigned int flags,
+			   void *reserved3, void *reserved4, void *reserved5);
 
 
 /*
diff --git a/include/uapi/linux/magic.h b/include/uapi/linux/magic.h
index 1a6fee974116..2fe02277fb32 100644
--- a/include/uapi/linux/magic.h
+++ b/include/uapi/linux/magic.h
@@ -89,5 +89,6 @@
 #define UDF_SUPER_MAGIC		0x15013346
 #define BALLOON_KVM_MAGIC	0x13661366
 #define ZSMALLOC_MAGIC		0x58295829
+#define FSCONTEXT_FS_MAGIC	0x66736673
 
 #endif /* __LINUX_MAGIC_H__ */
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 9791364925dc..c113fc9d5e77 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -430,3 +430,6 @@ COND_SYSCALL(setresgid16);
 COND_SYSCALL(setresuid16);
 COND_SYSCALL(setreuid16);
 COND_SYSCALL(setuid16);
+
+/* fd-based mount */
+COND_SYSCALL(sys_fsopen);


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55308 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965773AbdEOPTc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 15 May 2017 11:19:32 -0400
Subject: [PATCH 07/21] Implement fsopen() to prepare for a mount [ver #3]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk, jlayton@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Mon, 15 May 2017 16:19:17 +0100
Message-ID: <149486155723.23956.13096907184281290025.stgit@warthog.procyon.org.uk>
In-Reply-To: <149486147335.23956.2504187638938281431.stgit@warthog.procyon.org.uk>
References: <149486147335.23956.2504187638938281431.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Provide an fsopen() system call that starts the process of preparing to
mount, using an fd as a context handle.  fsopen() is given the name of the
filesystem that will be used:

	int mfd = fsopen(const char *fsname, int reserved,
			 int open_flags);

where reserved should be -1 for the moment (it will be used to pass the
namespace information in future) and open_flags can be 0 or O_CLOEXEC.

For example:

	mfd = fsopen("ext4", -1, O_CLOEXEC);
	write(mfd, "s /dev/sdb1"); // note I'm ignoring write's length arg
	write(mfd, "o noatime");
	write(mfd, "o acl");
	write(mfd, "o user_attr");
	write(mfd, "o iversion");
	write(mfd, "o ");
	write(mfd, "r /my/container"); // root inside the fs
	fsmount(mfd, container_fd, "/mnt", AT_NO_FOLLOW);

	mfd = fsopen("afs", -1);
	write(mfd, "s %grand.central.org:root.cell");
	write(mfd, "o cell=grand.central.org");
	write(mfd, "r /");
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
 fs/fsopen.c                            |  279 ++++++++++++++++++++++++++++++++
 include/linux/syscalls.h               |    1 
 include/uapi/linux/magic.h             |    1 
 kernel/sys_ni.c                        |    3 
 7 files changed, 287 insertions(+), 1 deletion(-)
 create mode 100644 fs/fsopen.c

diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index 448ac2161112..9bf8d4c62f85 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -391,3 +391,4 @@
 382	i386	pkey_free		sys_pkey_free
 383	i386	statx			sys_statx
 384	i386	arch_prctl		sys_arch_prctl			compat_sys_arch_prctl
+385	i386	fsopen			sys_fsopen
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index 5aef183e2f85..9b198c5fc412 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -339,6 +339,7 @@
 330	common	pkey_alloc		sys_pkey_alloc
 331	common	pkey_free		sys_pkey_free
 332	common	statx			sys_statx
+333	common	fsopen			sys_fsopen
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/fs/Makefile b/fs/Makefile
index 8f5142525866..b8fcf48b0400 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -12,7 +12,7 @@ obj-y :=	open.o read_write.o file_table.o super.o \
 		seq_file.o xattr.o libfs.o fs-writeback.o \
 		pnode.o splice.o sync.o utimes.o \
 		stack.o fs_struct.o statfs.o fs_pin.o nsfs.o \
-		sb_config.o
+		sb_config.o fsopen.o
 
 ifeq ($(CONFIG_BLOCK),y)
 obj-y +=	buffer.o block_dev.o direct-io.o mpage.o
diff --git a/fs/fsopen.c b/fs/fsopen.c
new file mode 100644
index 000000000000..a4e9d5a7ce2b
--- /dev/null
+++ b/fs/fsopen.c
@@ -0,0 +1,279 @@
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
+#include <linux/sb_config.h>
+#include <linux/mount.h>
+#include <linux/slab.h>
+#include <linux/uaccess.h>
+#include <linux/file.h>
+#include <linux/magic.h>
+#include <linux/syscalls.h>
+
+static struct vfsmount *fs_fs_mnt __read_mostly;
+
+static int fs_fs_release(struct inode *inode, struct file *file)
+{
+	struct sb_config *sc = file->private_data;
+
+	file->private_data = NULL;
+
+	put_sb_config(sc);
+	return 0;
+}
+
+/*
+ * Read any error message back from the fd.  Will be prefixed by "e ".
+ */
+static ssize_t fs_fs_read(struct file *file, char __user *_buf, size_t len, loff_t *pos)
+{
+	struct sb_config *sc = file->private_data;
+	const char *msg;
+	size_t mlen;
+
+	msg = READ_ONCE(sc->error_msg);
+	if (!msg)
+		return -ENODATA;
+
+	mlen = strlen(msg);
+	if (mlen + 2 > len)
+		return -ETOOSMALL;
+	if (copy_to_user(_buf, "e ", 2) != 0 ||
+	    copy_to_user(_buf + 2, msg, mlen) != 0)
+		return -EFAULT;
+	return mlen + 2;
+}
+
+/*
+ * Userspace writes configuration data to the fd and we parse it here.  For the
+ * moment, we assume a single option per write.  Each line written is of the form
+ *
+ *	<option_type><space><stuff...>
+ *
+ *	d /dev/sda1				-- Device name
+ *	o noatime				-- Option without value
+ *	o cell=grand.central.org		-- Option with value
+ *	r /					-- Dir within device to mount
+ */
+static ssize_t fs_fs_write(struct file *file,
+			   const char __user *_buf, size_t len, loff_t *pos)
+{
+	struct sb_config *sc = file->private_data;
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
+		break;
+	default:
+		return sb_cfg_inval(sc, "VFS: Unsupported write spec");
+	}
+	if (opt[1] != ' ')
+		return sb_cfg_inval(sc, "VFS: Unsupported write spec");
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
+	ret = -EBUSY;
+	if (sc->mounted)
+		goto err_unlock;
+
+	ret = -EINVAL;
+	switch (opt[0]) {
+	case 's':
+		if (sc->device)
+			goto err_unlock;
+		sc->device = data;
+		data = NULL;
+		break;
+
+	case 'o':
+		ret = vfs_parse_mount_option(sc, data);
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
+}
+
+const struct file_operations fs_fs_fops = {
+	.read		= fs_fs_read,
+	.write		= fs_fs_write,
+	.release	= fs_fs_release,
+	.llseek		= no_llseek,
+};
+
+/*
+ * Indicate the name we want to display the filesystem file as.
+ */
+static char *fs_fs_dname(struct dentry *dentry, char *buffer, int buflen)
+{
+	return dynamic_dname(dentry, buffer, buflen, "fs:[%lu]",
+			     d_inode(dentry)->i_ino);
+}
+
+static const struct dentry_operations fs_fs_dentry_operations = {
+	.d_dname	= fs_fs_dname,
+};
+
+/*
+ * Create a file that can be used to configure a new mount.
+ */
+static struct file *create_fs_file(struct sb_config *sc)
+{
+	struct inode *inode;
+	struct file *f;
+	struct path path;
+	int ret;
+
+	inode = alloc_anon_inode(fs_fs_mnt->mnt_sb);
+	if (!inode)
+		return ERR_PTR(-ENFILE);
+	inode->i_fop = &fs_fs_fops;
+
+	ret = -ENOMEM;
+	path.dentry = d_alloc_pseudo(fs_fs_mnt->mnt_sb, &empty_name);
+	if (!path.dentry)
+		goto err_inode;
+	path.mnt = mntget(fs_fs_mnt);
+
+	d_instantiate(path.dentry, inode);
+
+	f = alloc_file(&path, FMODE_READ | FMODE_WRITE, &fs_fs_fops);
+	if (IS_ERR(f)) {
+		ret = PTR_ERR(f);
+		goto err_file;
+	}
+
+	f->private_data = sc;
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
+ const struct super_operations fs_fs_ops = {
+	.drop_inode	= generic_delete_inode,
+	.destroy_inode	= free_inode_nonrcu,
+	.statfs		= simple_statfs,
+};
+
+static struct dentry *fs_fs_mount(struct file_system_type *fs_type,
+				  int flags, const char *dev_name,
+				  void *data)
+{
+	return mount_pseudo(fs_type, "fs_fs:", &fs_fs_ops,
+			    &fs_fs_dentry_operations, FS_FS_MAGIC);
+}
+
+static struct file_system_type fs_fs_type = {
+	.name		= "fs_fs",
+	.mount		= fs_fs_mount,
+	.kill_sb	= kill_anon_super,
+};
+
+static int __init init_fs_fs(void)
+{
+	int ret;
+
+	ret = register_filesystem(&fs_fs_type);
+	if (ret < 0)
+		panic("Cannot register fs_fs\n");
+
+	fs_fs_mnt = kern_mount(&fs_fs_type);
+	if (IS_ERR(fs_fs_mnt))
+		panic("Cannot mount fs_fs: %ld\n", PTR_ERR(fs_fs_mnt));
+	return 0;
+}
+
+fs_initcall(init_fs_fs);
+
+/*
+ * Open a filesystem by name so that it can be configured for mounting.
+ *
+ * We are allowed to specify a container in which the filesystem will be
+ * opened, thereby indicating which namespaces will be used (notably, which
+ * network namespace will be used for network filesystems).
+ */
+SYSCALL_DEFINE3(fsopen, const char __user *, _fs_name, int, reserved,
+		unsigned int, flags)
+{
+	struct sb_config *sc;
+	struct file *file;
+	const char *fs_name;
+	int fd, ret;
+
+	if (flags & ~O_CLOEXEC || reserved != -1)
+		return -EINVAL;
+
+	fs_name = strndup_user(_fs_name, PAGE_SIZE);
+	if (IS_ERR(fs_name))
+		return PTR_ERR(fs_name);
+
+	sc = vfs_new_sb_config(fs_name);
+	kfree(fs_name);
+	if (IS_ERR(sc))
+		return PTR_ERR(sc);
+
+	ret = -ENOTSUPP;
+	if (!sc->ops)
+		goto err_sc;
+
+	file = create_fs_file(sc);
+	if (IS_ERR(file)) {
+		ret = PTR_ERR(file);
+		goto err_sc;
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
+err_sc:
+	put_sb_config(sc);
+	return ret;
+}
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 980c3c9b06f8..91ec8802ad5d 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -905,5 +905,6 @@ asmlinkage long sys_pkey_alloc(unsigned long flags, unsigned long init_val);
 asmlinkage long sys_pkey_free(int pkey);
 asmlinkage long sys_statx(int dfd, const char __user *path, unsigned flags,
 			  unsigned mask, struct statx __user *buffer);
+asmlinkage long sys_fsopen(const char *fs_name, int containerfd, unsigned int flags);
 
 #endif
diff --git a/include/uapi/linux/magic.h b/include/uapi/linux/magic.h
index e230af2e6855..88ae83492f7c 100644
--- a/include/uapi/linux/magic.h
+++ b/include/uapi/linux/magic.h
@@ -84,5 +84,6 @@
 #define UDF_SUPER_MAGIC		0x15013346
 #define BALLOON_KVM_MAGIC	0x13661366
 #define ZSMALLOC_MAGIC		0x58295829
+#define FS_FS_MAGIC		0x66736673
 
 #endif /* __LINUX_MAGIC_H__ */
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 8acef8576ce9..de1dc63e7e47 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -258,3 +258,6 @@ cond_syscall(sys_membarrier);
 cond_syscall(sys_pkey_mprotect);
 cond_syscall(sys_pkey_alloc);
 cond_syscall(sys_pkey_free);
+
+/* fd-based mount */
+cond_syscall(sys_fsopen);


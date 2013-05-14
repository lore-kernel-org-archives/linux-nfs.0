Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37082 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758555Ab3ENVQE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 May 2013 17:16:04 -0400
From: Zach Brown <zab@redhat.com>
To: "Martin K. Petersen" <martin.petersen@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [RFC v0 1/4] vfs: add copy_range syscall and vfs entry point
Date: Tue, 14 May 2013 14:15:23 -0700
Message-Id: <1368566126-17610-2-git-send-email-zab@redhat.com>
In-Reply-To: <1368566126-17610-1-git-send-email-zab@redhat.com>
References: <1368566126-17610-1-git-send-email-zab@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This adds a syscall and vfs entry point for clone_range which offloads
data copying between existing files.

The syscall is a thin wrapper around the vfs entry point.  Its arguments
are inspired by sys_splice().

The behaviour of the vfs helper is derived from the current btrfs
CLONE_RANGE ioctl.
---
 fs/Makefile                       |   2 +-
 fs/copy_range.c                   | 127 ++++++++++++++++++++++++++++++++++++++
 include/linux/fs.h                |   3 +
 include/uapi/asm-generic/unistd.h |   4 +-
 kernel/sys_ni.c                   |   1 +
 5 files changed, 135 insertions(+), 2 deletions(-)
 create mode 100644 fs/copy_range.c

diff --git a/fs/Makefile b/fs/Makefile
index 4fe6df3..1be83b3 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -11,7 +11,7 @@ obj-y :=	open.o read_write.o file_table.o super.o \
 		attr.o bad_inode.o file.o filesystems.o namespace.o \
 		seq_file.o xattr.o libfs.o fs-writeback.o \
 		pnode.o splice.o sync.o utimes.o \
-		stack.o fs_struct.o statfs.o
+		stack.o fs_struct.o statfs.o copy_range.o
 
 ifeq ($(CONFIG_BLOCK),y)
 obj-y +=	buffer.o bio.o block_dev.o direct-io.o mpage.o ioprio.o
diff --git a/fs/copy_range.c b/fs/copy_range.c
new file mode 100644
index 0000000..3000b9f
--- /dev/null
+++ b/fs/copy_range.c
@@ -0,0 +1,127 @@
+/*
+ * "copy_range": offload data copying between existing files
+ *
+ * Copyright (C) 2013 Zach Brown <zab@redhat.com>
+ */
+#include <linux/fs.h>
+#include <linux/file.h>
+#include <linux/mount.h>
+#include <linux/syscalls.h>
+#include <linux/export.h>
+#include <linux/fsnotify.h>
+
+/**
+ * vfs_copy_range - copy range of bytes from source file to existing file
+ * @file_in:   source regular file
+ * @pos_in:    starting byte offset to copy from the source file
+ * @file_out:  destination regular file
+ * @pos_out:   starting byte offset to copy to in the destination file
+ * @count:     number of bytes to copy
+ *
+ * Returns number of bytes successfully copied from the start of the range or
+ * a negative errno error value.
+ *
+ * The number of bytes successfully written can be less than the input
+ * count if an error is encountered.  In this partial success case the
+ * contents of the destination range after the copied bytes can be a mix
+ * of pre-existing bytes, bytes from the source range, or zeros,
+ * depending on the implementation.
+ *
+ * The source range must be entirely within i_size in the source file.
+ * A destination range outside of the size of the destination file will
+ * extend its size.
+ */
+ssize_t vfs_copy_range(struct file *file_in, loff_t pos_in,
+		       struct file *file_out, loff_t pos_out,
+		       size_t count)
+{
+	struct inode *inode_in;
+	struct inode *inode_out;
+	ssize_t ret;
+
+	if (count == 0)
+		return 0;
+
+	/* copy_range allows full ssize_t count, ignoring MAX_RW_COUNT  */
+	ret = rw_verify_area(READ, file_in, &pos_in, count);
+	if (ret >= 0)
+		ret = rw_verify_area(WRITE, file_out, &pos_out, count);
+	if (ret < 0)
+		return ret;
+
+	if (!(file_in->f_mode & FMODE_READ) ||
+	    !(file_out->f_mode & FMODE_WRITE) ||
+	    (file_out->f_flags & O_APPEND) ||
+	    !file_in->f_op || !file_in->f_op->copy_range)
+		return -EINVAL;
+
+	inode_in = file_inode(file_in);
+	inode_out = file_inode(file_out);
+
+	/* make sure offsets don't wrap and the input is inside i_size */
+	if (pos_in + count < pos_in || pos_out + count < pos_out ||
+	    pos_in + count > i_size_read(inode_in))
+		return -EINVAL;
+
+	/* XXX do we want this test?  btrfs_ioctl_clone_range() */
+	if (S_ISDIR(inode_in->i_mode) || S_ISDIR(inode_out->i_mode))
+		return -EISDIR;
+
+	if (!S_ISREG(inode_in->i_mode) || !S_ISREG(inode_out->i_mode))
+		return -EINVAL;
+
+	if (inode_in->i_sb != inode_out->i_sb ||
+	    file_in->f_path.mnt != file_out->f_path.mnt)
+		return -EXDEV;
+
+	/* forbid ranges in the same file for now */
+	if (inode_in == inode_out)
+		return -EINVAL;
+
+	ret = mnt_want_write_file(file_out);
+	if (ret)
+		return ret;
+
+	ret = file_in->f_op->copy_range(file_in, pos_in, file_out, pos_out,
+					count);
+	if (ret > 0) {
+		fsnotify_access(file_in);
+		add_rchar(current, ret);
+		fsnotify_modify(file_out);
+		add_wchar(current, ret);
+	}
+	inc_syscr(current);
+	inc_syscw(current);
+
+	mnt_drop_write_file(file_out);
+
+	return ret;
+}
+EXPORT_SYMBOL(vfs_copy_range);
+
+SYSCALL_DEFINE5(copy_range, int, fd_in, loff_t __user *, upos_in,
+		int, fd_out, loff_t __user *, upos_out, size_t, count)
+{
+	loff_t pos_in;
+	loff_t pos_out;
+	struct fd f_in;
+	struct fd f_out;
+	ssize_t ret;
+
+	if (get_user(pos_in, upos_in) || get_user(pos_out, upos_out))
+		return -EFAULT;
+
+	f_in = fdget(fd_in);
+	f_out = fdget(fd_out);
+
+	if (f_in.file && f_out.file)
+		ret = vfs_copy_range(f_in.file, pos_in, f_out.file, pos_out,
+				     count);
+	else
+		ret = -EBADF;
+
+	fdput(f_in);
+	fdput(f_out);
+
+	return ret;
+}
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 43db02e..6214893 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1543,6 +1543,7 @@ struct file_operations {
 	long (*fallocate)(struct file *file, int mode, loff_t offset,
 			  loff_t len);
 	int (*show_fdinfo)(struct seq_file *m, struct file *f);
+	ssize_t (*copy_range)(struct file *, loff_t, struct file *, loff_t, size_t);
 };
 
 struct inode_operations {
@@ -1588,6 +1589,8 @@ extern ssize_t vfs_readv(struct file *, const struct iovec __user *,
 		unsigned long, loff_t *);
 extern ssize_t vfs_writev(struct file *, const struct iovec __user *,
 		unsigned long, loff_t *);
+extern ssize_t vfs_copy_range(struct file *, loff_t , struct file *, loff_t,
+		size_t);
 
 struct super_operations {
    	struct inode *(*alloc_inode)(struct super_block *sb);
diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
index 0cc74c4..3935d1c 100644
--- a/include/uapi/asm-generic/unistd.h
+++ b/include/uapi/asm-generic/unistd.h
@@ -692,9 +692,11 @@ __SC_COMP(__NR_process_vm_writev, sys_process_vm_writev, \
 __SYSCALL(__NR_kcmp, sys_kcmp)
 #define __NR_finit_module 273
 __SYSCALL(__NR_finit_module, sys_finit_module)
+#define __NR_copy_range 274
+__SYSCALL(__NR_copy_range, sys_copy_range)
 
 #undef __NR_syscalls
-#define __NR_syscalls 274
+#define __NR_syscalls 275
 
 /*
  * All syscalls below here should go away really,
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 7078052..af7808a 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -151,6 +151,7 @@ cond_syscall(sys_process_vm_readv);
 cond_syscall(sys_process_vm_writev);
 cond_syscall(compat_sys_process_vm_readv);
 cond_syscall(compat_sys_process_vm_writev);
+cond_syscall(sys_copy_range);
 
 /* arch-specific weak syscall entries */
 cond_syscall(sys_pciconfig_read);
-- 
1.7.11.7


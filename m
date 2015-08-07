Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:7454 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946136AbbHGUie (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Aug 2015 16:38:34 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>,
        <bfields@fieldses.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH 1/7] vfs: add copy_file_range syscall and vfs helper
Date: Fri, 7 Aug 2015 16:38:17 -0400
Message-ID: <1438979904-8775-2-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1438979904-8775-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1438979904-8775-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Zach Brown <zab@redhat.com>

Add a copy_file_range() system call for offloading copies between
regular files.

This gives an interface to underlying layers of the storage stack which
can copy without reading and writing all the data.  There are a few
candidates that should support copy offloading in the nearer term:

- btrfs shares extent references with its clone ioctl
- NFS has patches to add a COPY command which copies on the server
- SCSI has a family of XCOPY commands which copy in the device

This system call avoids the complexity of also accelerating the creation
of the destination file by operating on an existing destination file
descriptor, not a path.

Currently the high level vfs entry point limits copy offloading to files
on the same mount and super (and not in the same file).  This can be
relaxed if we get implementations which can copy between file systems
safely.

Signed-off-by: Zach Brown <zab@redhat.com>
---
 fs/read_write.c                   | 129 ++++++++++++++++++++++++++++++++++++++
 include/linux/fs.h                |   3 +
 include/uapi/asm-generic/unistd.h |   4 +-
 kernel/sys_ni.c                   |   1 +
 4 files changed, 136 insertions(+), 1 deletion(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index 819ef3f..3804547 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -16,6 +16,7 @@
 #include <linux/pagemap.h>
 #include <linux/splice.h>
 #include <linux/compat.h>
+#include <linux/mount.h>
 #include "internal.h"
 
 #include <asm/uaccess.h>
@@ -1327,3 +1328,131 @@ COMPAT_SYSCALL_DEFINE4(sendfile64, int, out_fd, int, in_fd,
 	return do_sendfile(out_fd, in_fd, NULL, count, 0);
 }
 #endif
+
+/*
+ * copy_file_range() differs from regular file read and write in that it
+ * specifically allows return partial success.  When it does so is up to
+ * the copy_file_range method.
+ */
+ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
+			    struct file *file_out, loff_t pos_out,
+			    size_t len, int flags)
+{
+	struct inode *inode_in;
+	struct inode *inode_out;
+	ssize_t ret;
+
+	if (flags)
+		return -EINVAL;
+
+	if (len == 0)
+		return 0;
+
+	/* copy_file_range allows full ssize_t len, ignoring MAX_RW_COUNT  */
+	ret = rw_verify_area(READ, file_in, &pos_in, len);
+	if (ret >= 0)
+		ret = rw_verify_area(WRITE, file_out, &pos_out, len);
+	if (ret < 0)
+		return ret;
+
+	if (!(file_in->f_mode & FMODE_READ) ||
+	    !(file_out->f_mode & FMODE_WRITE) ||
+	    (file_out->f_flags & O_APPEND) ||
+	    !file_in->f_op || !file_in->f_op->copy_file_range)
+		return -EINVAL;
+
+	inode_in = file_inode(file_in);
+	inode_out = file_inode(file_out);
+
+	/* make sure offsets don't wrap and the input is inside i_size */
+	if (pos_in + len < pos_in || pos_out + len < pos_out ||
+	    pos_in + len > i_size_read(inode_in))
+		return -EINVAL;
+
+	/* this could be relaxed once a method supports cross-fs copies */
+	if (inode_in->i_sb != inode_out->i_sb ||
+	    file_in->f_path.mnt != file_out->f_path.mnt)
+		return -EXDEV;
+
+	/* forbid ranges in the same file */
+	if (inode_in == inode_out)
+		return -EINVAL;
+
+	ret = mnt_want_write_file(file_out);
+	if (ret)
+		return ret;
+
+	ret = file_in->f_op->copy_file_range(file_in, pos_in, file_out, pos_out,
+					     len, flags);
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
+EXPORT_SYMBOL(vfs_copy_file_range);
+
+SYSCALL_DEFINE6(copy_file_range, int, fd_in, loff_t __user *, off_in,
+		int, fd_out, loff_t __user *, off_out,
+		size_t, len, unsigned int, flags)
+{
+	loff_t pos_in;
+	loff_t pos_out;
+	struct fd f_in;
+	struct fd f_out;
+	ssize_t ret;
+
+	f_in = fdget(fd_in);
+	f_out = fdget(fd_out);
+	if (!f_in.file || !f_out.file) {
+		ret = -EBADF;
+		goto out;
+	}
+
+	ret = -EFAULT;
+	if (off_in) {
+		if (copy_from_user(&pos_in, off_in, sizeof(loff_t)))
+			goto out;
+	} else {
+		pos_in = f_in.file->f_pos;
+	}
+
+	if (off_out) {
+		if (copy_from_user(&pos_out, off_out, sizeof(loff_t)))
+			goto out;
+	} else {
+		pos_out = f_out.file->f_pos;
+	}
+
+	ret = vfs_copy_file_range(f_in.file, pos_in, f_out.file, pos_out, len,
+				  flags);
+	if (ret > 0) {
+		pos_in += ret;
+		pos_out += ret;
+
+		if (off_in) {
+			if (copy_to_user(off_in, &pos_in, sizeof(loff_t)))
+				ret = -EFAULT;
+		} else {
+			f_in.file->f_pos = pos_in;
+		}
+
+		if (off_out) {
+			if (copy_to_user(off_out, &pos_out, sizeof(loff_t)))
+				ret = -EFAULT;
+		} else {
+			f_out.file->f_pos = pos_out;
+		}
+	}
+out:
+	fdput(f_in);
+	fdput(f_out);
+	return ret;
+}
diff --git a/include/linux/fs.h b/include/linux/fs.h
index cc008c3..c97aed8 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1631,6 +1631,7 @@ struct file_operations {
 #ifndef CONFIG_MMU
 	unsigned (*mmap_capabilities)(struct file *);
 #endif
+	ssize_t (*copy_file_range)(struct file *, loff_t, struct file *, loff_t, size_t, int);
 };
 
 struct inode_operations {
@@ -1684,6 +1685,8 @@ extern ssize_t vfs_readv(struct file *, const struct iovec __user *,
 		unsigned long, loff_t *);
 extern ssize_t vfs_writev(struct file *, const struct iovec __user *,
 		unsigned long, loff_t *);
+extern ssize_t vfs_copy_file_range(struct file *, loff_t , struct file *,
+				   loff_t, size_t, int);
 
 struct super_operations {
    	struct inode *(*alloc_inode)(struct super_block *sb);
diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
index e016bd9..2b60f0c 100644
--- a/include/uapi/asm-generic/unistd.h
+++ b/include/uapi/asm-generic/unistd.h
@@ -709,9 +709,11 @@ __SYSCALL(__NR_memfd_create, sys_memfd_create)
 __SYSCALL(__NR_bpf, sys_bpf)
 #define __NR_execveat 281
 __SC_COMP(__NR_execveat, sys_execveat, compat_sys_execveat)
+#define __NR_copy_file_range 282
+__SYSCALL(__NR_copy_file_range, sys_copy_file_range)
 
 #undef __NR_syscalls
-#define __NR_syscalls 282
+#define __NR_syscalls 283
 
 /*
  * All syscalls below here should go away really,
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 7995ef5..4e01cd9 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -173,6 +173,7 @@ cond_syscall(sys_setfsuid);
 cond_syscall(sys_setfsgid);
 cond_syscall(sys_capget);
 cond_syscall(sys_capset);
+cond_syscall(sys_copy_file_range);
 
 /* arch-specific weak syscall entries */
 cond_syscall(sys_pciconfig_read);
-- 
2.5.0


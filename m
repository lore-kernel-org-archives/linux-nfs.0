Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:1517 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751761AbdHGVX7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 7 Aug 2017 17:23:59 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <linux-fsdevel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <linux-api@vger.kernel.org>
Subject: [RFC v3 1/3] VFS adding destroy_creds call
Date: Mon, 7 Aug 2017 17:23:52 -0400
Message-ID: <20170807212355.29127-2-kolga@netapp.com>
In-Reply-To: <20170807212355.29127-1-kolga@netapp.com>
References: <20170807212355.29127-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Filesystems (like NFS) would benefit from an ability to destroy
credentials for the current uid.

Systemcall takes in a file descriptor that's a mount point of the
file system. If a non-directory file descriptor supplied it will
failed with EINVAL. If a bad fd leads to EBADF. And if the file
system doesn't implement destroy_creds, ENOSYS is returned.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 arch/x86/entry/syscalls/syscall_32.tbl |  1 +
 arch/x86/entry/syscalls/syscall_64.tbl |  1 +
 fs/read_write.c                        | 22 ++++++++++++++++++++++
 include/linux/fs.h                     |  2 ++
 include/linux/syscalls.h               |  2 +-
 include/uapi/asm-generic/unistd.h      |  4 +++-
 kernel/sys_ni.c                        |  1 +
 7 files changed, 31 insertions(+), 2 deletions(-)

diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index 448ac21..298e72b 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -391,3 +391,4 @@
 382	i386	pkey_free		sys_pkey_free
 383	i386	statx			sys_statx
 384	i386	arch_prctl		sys_arch_prctl			compat_sys_arch_prctl
+385	i386	destroy_creds		sys_destroy_creds
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index 5aef183..c8a7e38 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -339,6 +339,7 @@
 330	common	pkey_alloc		sys_pkey_alloc
 331	common	pkey_free		sys_pkey_free
 332	common	statx			sys_statx
+333	common	destroy_creds		sys_destroy_creds
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/fs/read_write.c b/fs/read_write.c
index 0cc7033..f2e169b 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -2041,3 +2041,25 @@ int vfs_dedupe_file_range(struct file *file, struct file_dedupe_range *same)
 	return ret;
 }
 EXPORT_SYMBOL(vfs_dedupe_file_range);
+
+long vfs_destroy_creds(struct file *fd)
+{
+	struct inode *inode = file_inode(fd);
+
+	if (!S_ISDIR(inode->i_mode))
+		return -EINVAL;
+	if (fd->f_op->destroy_creds)
+		return fd->f_op->destroy_creds(fd);
+	return -ENOSYS;
+}
+EXPORT_SYMBOL(vfs_destroy_creds);
+
+SYSCALL_DEFINE1(destroy_creds, int, fd_in)
+{
+	struct fd f_in;
+
+	f_in = fdget(fd_in);
+	if (!f_in.file)
+		return -EBADF;
+	return vfs_destroy_creds(f_in.file);
+}
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 6e1fd5d..882bd40 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1699,6 +1699,7 @@ struct file_operations {
 			u64);
 	ssize_t (*dedupe_file_range)(struct file *, u64, u64, struct file *,
 			u64);
+	int (*destroy_creds)(struct file *);
 } __randomize_layout;
 
 struct inode_operations {
@@ -1773,6 +1774,7 @@ extern int vfs_dedupe_file_range_compare(struct inode *src, loff_t srcoff,
 					 loff_t len, bool *is_same);
 extern int vfs_dedupe_file_range(struct file *file,
 				 struct file_dedupe_range *same);
+extern long vfs_destroy_creds(struct file *fd);
 
 struct super_operations {
    	struct inode *(*alloc_inode)(struct super_block *sb);
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 3cb15ea..3b7b749 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -905,5 +905,5 @@ asmlinkage long sys_pkey_mprotect(unsigned long start, size_t len,
 asmlinkage long sys_pkey_free(int pkey);
 asmlinkage long sys_statx(int dfd, const char __user *path, unsigned flags,
 			  unsigned mask, struct statx __user *buffer);
-
+asmlinkage long sys_destroy_creds(int fd_in);
 #endif
diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
index 061185a..0ad6a0d 100644
--- a/include/uapi/asm-generic/unistd.h
+++ b/include/uapi/asm-generic/unistd.h
@@ -731,9 +731,11 @@
 __SYSCALL(__NR_pkey_free,     sys_pkey_free)
 #define __NR_statx 291
 __SYSCALL(__NR_statx,     sys_statx)
+#define __NR_destroy_creds 292
+__SYSCALL(__NR_destroy_creds, sys_destroy_creds)
 
 #undef __NR_syscalls
-#define __NR_syscalls 292
+#define __NR_syscalls 293
 
 /*
  * All syscalls below here should go away really,
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 8acef85..cb9ee0b 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -178,6 +178,7 @@ asmlinkage long sys_ni_syscall(void)
 cond_syscall(sys_capget);
 cond_syscall(sys_capset);
 cond_syscall(sys_copy_file_range);
+cond_syscall(sys_destroy_creds);
 
 /* arch-specific weak syscall entries */
 cond_syscall(sys_pciconfig_read);
-- 
1.8.3.1


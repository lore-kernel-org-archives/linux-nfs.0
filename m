Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:10414 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752316Ab3GSVDy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Jul 2013 17:03:54 -0400
From: <bjschuma@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC 1/5] Improve on the copyfile systemcall
Date: Fri, 19 Jul 2013 17:03:46 -0400
Message-ID: <1374267830-30154-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1374267830-30154-1-git-send-email-bjschuma@netapp.com>
References: <1374267830-30154-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I added in a fallback to do_splice_direct() if the filesystem doesn't
support the copy_range call.  This is because the declaration of
do_splice_direct() is now found in fs/internal.h and can't be used by
other filesystems.

I also had to add sys_copy_range to include/linux/syscalls.h to get my
test program to recognize the new syscall.

Other thoughts:
- Pass count = 0 to mean "copy the entire file"
- rw_verify_area() limits count to values that can fit in an int, so
  files larger than about 2GB cannot be copied.
---
 fs/copy_range.c          | 10 +++++++---
 include/linux/syscalls.h |  1 +
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/copy_range.c b/fs/copy_range.c
index 3000b9f..bcf6e67 100644
--- a/fs/copy_range.c
+++ b/fs/copy_range.c
@@ -10,6 +10,8 @@
 #include <linux/export.h>
 #include <linux/fsnotify.h>
 
+#include "internal.h"
+
 /**
  * vfs_copy_range - copy range of bytes from source file to existing file
  * @file_in:   source regular file
@@ -52,7 +54,7 @@ ssize_t vfs_copy_range(struct file *file_in, loff_t pos_in,
 	if (!(file_in->f_mode & FMODE_READ) ||
 	    !(file_out->f_mode & FMODE_WRITE) ||
 	    (file_out->f_flags & O_APPEND) ||
-	    !file_in->f_op || !file_in->f_op->copy_range)
+	    !file_in->f_op)
 		return -EINVAL;
 
 	inode_in = file_inode(file_in);
@@ -82,8 +84,10 @@ ssize_t vfs_copy_range(struct file *file_in, loff_t pos_in,
 	if (ret)
 		return ret;
 
-	ret = file_in->f_op->copy_range(file_in, pos_in, file_out, pos_out,
-					count);
+	if (file_in->f_op->copy_range)
+		ret = file_in->f_op->copy_range(file_in, pos_in, file_out, pos_out, count);
+	else
+		ret = do_splice_direct(file_in, &pos_in, file_out, &pos_out, count, 0);
 	if (ret > 0) {
 		fsnotify_access(file_in);
 		add_rchar(current, ret);
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 4147d70..5afcd00 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -485,6 +485,7 @@ asmlinkage long sys_sendfile(int out_fd, int in_fd,
 			     off_t __user *offset, size_t count);
 asmlinkage long sys_sendfile64(int out_fd, int in_fd,
 			       loff_t __user *offset, size_t count);
+asmlinkage long sys_copy_range(int, loff_t __user *, int, loff_t __user *, size_t);
 asmlinkage long sys_readlink(const char __user *path,
 				char __user *buf, int bufsiz);
 asmlinkage long sys_creat(const char __user *pathname, umode_t mode);
-- 
1.8.3.3


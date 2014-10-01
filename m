Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:19440 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751142AbaJATPQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Oct 2014 15:15:16 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <viro@zeniv.linux.org.uk>
CC: <linux-fsdevel@vger.kernel.org>, <linux-nfs@vger.kernel.org>, <hch@lst.de>,
        <bfields@fieldses.org>, <Trond.Myklebust@primarydata.com>
Subject: [PATCH] VFS: Rename do_fallocate() to vfs_fallocate()
Date: Wed, 1 Oct 2014 15:15:07 -0400
Message-ID: <1412190907-30307-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@netapp.com>

This function needs to be exported so it can be used by the NFSD module
when responding to the new ALLOCATE and DEALLOCATE operations in NFS
v4.2.  Christoph Hellwig suggested renaming the function to stay
consistent with how other vfs functions are named.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 drivers/staging/android/ashmem.c | 2 +-
 fs/ioctl.c                       | 2 +-
 fs/open.c                        | 5 +++--
 include/linux/fs.h               | 2 +-
 mm/madvise.c                     | 2 +-
 5 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
index 713a972..9c799987 100644
--- a/drivers/staging/android/ashmem.c
+++ b/drivers/staging/android/ashmem.c
@@ -446,7 +446,7 @@ ashmem_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
 		loff_t start = range->pgstart * PAGE_SIZE;
 		loff_t end = (range->pgend + 1) * PAGE_SIZE;
 
-		do_fallocate(range->asma->file,
+		vfs_fallocate(range->asma->file,
 				FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
 				start, end - start);
 		range->purged = ASHMEM_WAS_PURGED;
diff --git a/fs/ioctl.c b/fs/ioctl.c
index 8ac3fad..0bd61421 100644
--- a/fs/ioctl.c
+++ b/fs/ioctl.c
@@ -443,7 +443,7 @@ int ioctl_preallocate(struct file *filp, void __user *argp)
 		return -EINVAL;
 	}
 
-	return do_fallocate(filp, FALLOC_FL_KEEP_SIZE, sr.l_start, sr.l_len);
+	return vfs_fallocate(filp, FALLOC_FL_KEEP_SIZE, sr.l_start, sr.l_len);
 }
 
 static int file_ioctl(struct file *filp, unsigned int cmd,
diff --git a/fs/open.c b/fs/open.c
index d6fd3ac..c94449b 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -222,7 +222,7 @@ SYSCALL_DEFINE2(ftruncate64, unsigned int, fd, loff_t, length)
 #endif /* BITS_PER_LONG == 32 */
 
 
-int do_fallocate(struct file *file, int mode, loff_t offset, loff_t len)
+int vfs_fallocate(struct file *file, int mode, loff_t offset, loff_t len)
 {
 	struct inode *inode = file_inode(file);
 	long ret;
@@ -298,6 +298,7 @@ int do_fallocate(struct file *file, int mode, loff_t offset, loff_t len)
 	sb_end_write(inode->i_sb);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(vfs_fallocate);
 
 SYSCALL_DEFINE4(fallocate, int, fd, int, mode, loff_t, offset, loff_t, len)
 {
@@ -305,7 +306,7 @@ SYSCALL_DEFINE4(fallocate, int, fd, int, mode, loff_t, offset, loff_t, len)
 	int error = -EBADF;
 
 	if (f.file) {
-		error = do_fallocate(f.file, mode, offset, len);
+		error = vfs_fallocate(f.file, mode, offset, len);
 		fdput(f);
 	}
 	return error;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 9418772..476f555 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2049,7 +2049,7 @@ struct filename {
 extern long vfs_truncate(struct path *, loff_t);
 extern int do_truncate(struct dentry *, loff_t start, unsigned int time_attrs,
 		       struct file *filp);
-extern int do_fallocate(struct file *file, int mode, loff_t offset,
+extern int vfs_fallocate(struct file *file, int mode, loff_t offset,
 			loff_t len);
 extern long do_sys_open(int dfd, const char __user *filename, int flags,
 			umode_t mode);
diff --git a/mm/madvise.c b/mm/madvise.c
index 0938b30..a271adc 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -326,7 +326,7 @@ static long madvise_remove(struct vm_area_struct *vma,
 	 */
 	get_file(f);
 	up_read(&current->mm->mmap_sem);
-	error = do_fallocate(f,
+	error = vfs_fallocate(f,
 				FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
 				offset, end - start);
 	fput(f);
-- 
2.1.1


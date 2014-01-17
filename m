Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f42.google.com ([209.85.215.42]:52941 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752298AbaAQKHc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jan 2014 05:07:32 -0500
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-kernel@vger.kernel.org
Cc: linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: [PATCH v7 2/7] VFS: Add O_DENYDELETE support for VFS
Date: Fri, 17 Jan 2014 14:07:07 +0400
Message-Id: <1389953232-9428-3-git-send-email-piastry@etersoft.ru>
In-Reply-To: <1389953232-9428-1-git-send-email-piastry@etersoft.ru>
References: <1389953232-9428-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce new LOCK_DELETE flock flag that is suggested to be used
internally only to map O_DENYDELETE open flag:

!O_DENYDELETE -> LOCK_DELETE | LOCK_MAND.

Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
---
 fs/locks.c                       |   56 ++++++++++++++++++++++++++++++++------
 fs/namei.c                       |    3 ++
 include/linux/fs.h               |    6 ++++
 include/uapi/asm-generic/fcntl.h |    1 +
 4 files changed, 57 insertions(+), 9 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index ffde4d4..7ecc511 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -295,7 +295,7 @@ EXPORT_SYMBOL(locks_copy_lock);
 
 static inline int flock_translate_cmd(int cmd) {
 	if (cmd & LOCK_MAND)
-		return cmd & (LOCK_MAND | LOCK_RW);
+		return cmd & (LOCK_MAND | LOCK_RW | LOCK_DELETE);
 	switch (cmd) {
 	case LOCK_SH:
 		return F_RDLCK;
@@ -717,6 +717,8 @@ deny_flags_to_cmd(unsigned int flags)
 		cmd |= LOCK_READ;
 	if (!(flags & O_DENYWRITE))
 		cmd |= LOCK_WRITE;
+	if (!(flags & O_DENYDELETE))
+		cmd |= LOCK_DELETE;
 
 	return cmd;
 }
@@ -941,6 +943,34 @@ out:
 	return error;
 }
 
+int
+sharelock_may_delete(struct dentry *dentry)
+{
+	struct file_lock **before;
+	struct inode *inode = dentry->d_inode;
+	int rc = 0;
+
+	if (!IS_SHARELOCK(inode))
+		return rc;
+
+	spin_lock(&inode->i_lock);
+	for_each_lock(inode, before) {
+		struct file_lock *fl = *before;
+		if (IS_POSIX(fl))
+			break;
+		if (IS_LEASE(fl))
+			continue;
+		if (!(fl->fl_type & LOCK_MAND))
+			continue;
+		if (fl->fl_type & LOCK_DELETE)
+			continue;
+		rc = 1;
+		break;
+	}
+	spin_unlock(&inode->i_lock);
+	return rc;
+}
+
 /*
  * Determine if a file is allowed to be opened with specified access and share
  * modes. Lock the file and return 0 if checks passed, otherwise return
@@ -955,10 +985,6 @@ sharelock_lock_file(struct file *filp)
 	if (!IS_SHARELOCK(filp->f_path.dentry->d_inode))
 		return error;
 
-	/* Disable O_DENYDELETE support for now */
-	if (filp->f_flags & O_DENYDELETE)
-		return -EINVAL;
-
 	error = flock_make_lock(filp, &lock, deny_flags_to_cmd(filp->f_flags));
 	if (error)
 		return error;
@@ -1872,6 +1898,12 @@ SYSCALL_DEFINE2(flock, unsigned int, fd, unsigned int, cmd)
 	if (!f.file)
 		goto out;
 
+	/* LOCK_DELETE is defined to be translated from O_DENYDELETE only */
+	if (cmd & LOCK_DELETE) {
+		error = -EINVAL;
+		goto out;
+	}
+
 	can_sleep = !(cmd & LOCK_NB);
 	cmd &= ~LOCK_NB;
 	unlock = (cmd == LOCK_UN);
@@ -2419,10 +2451,16 @@ static void lock_get_status(struct seq_file *f, struct file_lock *fl,
 		seq_printf(f, "UNKNOWN UNKNOWN  ");
 	}
 	if (fl->fl_type & LOCK_MAND) {
-		seq_printf(f, "%s ",
-			       (fl->fl_type & LOCK_READ)
-			       ? (fl->fl_type & LOCK_WRITE) ? "RW   " : "READ "
-			       : (fl->fl_type & LOCK_WRITE) ? "WRITE" : "NONE ");
+		if (fl->fl_type & LOCK_DELETE)
+			seq_printf(f, "%s ",
+				(fl->fl_type & LOCK_READ) ?
+				(fl->fl_type & LOCK_WRITE) ? "RWDEL" : "RDDEL" :
+				(fl->fl_type & LOCK_WRITE) ? "WRDEL" : "DEL  ");
+		else
+			seq_printf(f, "%s ",
+				(fl->fl_type & LOCK_READ) ?
+				(fl->fl_type & LOCK_WRITE) ? "RW   " : "READ " :
+				(fl->fl_type & LOCK_WRITE) ? "WRITE" : "NONE ");
 	} else {
 		seq_printf(f, "%s ",
 			       (lease_breaking(fl))
diff --git a/fs/namei.c b/fs/namei.c
index 2b741a1..1643ab8 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2383,6 +2383,7 @@ static inline int check_sticky(struct inode *dir, struct inode *inode)
  *  9. We can't remove a root or mountpoint.
  * 10. We don't allow removal of NFS sillyrenamed files; it's handled by
  *     nfs_async_unlink().
+ * 11. We can't do it if victim is locked by O_DENYDELETE sharelock.
  */
 static int may_delete(struct inode *dir, struct dentry *victim, bool isdir)
 {
@@ -2416,6 +2417,8 @@ static int may_delete(struct inode *dir, struct dentry *victim, bool isdir)
 		return -ENOENT;
 	if (victim->d_flags & DCACHE_NFSFS_RENAMED)
 		return -EBUSY;
+	if (sharelock_may_delete(victim))
+		return -ESHAREDENIED;
 	return 0;
 }
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index aa061ca..6dc9275 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1030,6 +1030,7 @@ extern int lease_modify(struct file_lock **, int);
 extern int lock_may_read(struct inode *, loff_t start, unsigned long count);
 extern int lock_may_write(struct inode *, loff_t start, unsigned long count);
 extern int sharelock_lock_file(struct file *);
+extern int sharelock_may_delete(struct dentry *);
 #else /* !CONFIG_FILE_LOCKING */
 static inline int fcntl_getlk(struct file *file, struct flock __user *user)
 {
@@ -1176,6 +1177,11 @@ static inline int sharelock_lock_file(struct file *filp)
 	return 0;
 }
 
+static inline int sharelock_may_delete(struct dentry *dentry)
+{
+	return 0;
+}
+
 #endif /* !CONFIG_FILE_LOCKING */
 
 
diff --git a/include/uapi/asm-generic/fcntl.h b/include/uapi/asm-generic/fcntl.h
index 9881cfe..41ba131 100644
--- a/include/uapi/asm-generic/fcntl.h
+++ b/include/uapi/asm-generic/fcntl.h
@@ -175,6 +175,7 @@ struct f_owner_ex {
 				   blocking */
 #define LOCK_UN		8	/* remove lock */
 
+#define LOCK_DELETE	16	/* which allows to delete a file */
 #define LOCK_MAND	32	/* This is a mandatory flock ... */
 #define LOCK_READ	64	/* which allows concurrent read operations */
 #define LOCK_WRITE	128	/* which allows concurrent write operations */
-- 
1.7.10.4


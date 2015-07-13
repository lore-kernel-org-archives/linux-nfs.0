Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:33175 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180AbbGMKWb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 06:22:31 -0400
Received: by ykeo3 with SMTP id o3so190396929yke.0
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2015 03:22:30 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: linux-nfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, bfields@fieldses.org, william@gandi.net
Subject: [PATCH 5/4] locks: inline posix_lock_file_wait and flock_lock_file_wait
Date: Mon, 13 Jul 2015 06:22:21 -0400
Message-Id: <1436782941-9569-1-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1436560414-26306-1-git-send-email-jeff.layton@primarydata.com>
References: <1436560414-26306-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

They just call file_inode and then the corresponding *_inode_file_wait
function. Just make them static inlines instead.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/locks.c         | 28 ----------------------------
 include/linux/fs.h | 32 ++++++++++++++------------------
 2 files changed, 14 insertions(+), 46 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index ba268a503c1b..d3d558ba4da7 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1190,21 +1190,6 @@ int posix_lock_inode_wait(struct inode *inode, struct file_lock *fl)
 EXPORT_SYMBOL(posix_lock_inode_wait);
 
 /**
- * posix_lock_file_wait - Apply a POSIX-style lock to a file
- * @filp: The file to apply the lock to
- * @fl: The lock to be applied
- *
- * Add a POSIX style lock to a file.
- * We merge adjacent & overlapping locks whenever possible.
- * POSIX locks are sorted by owner task, then by starting address
- */
-int posix_lock_file_wait(struct file *filp, struct file_lock *fl)
-{
-	return posix_lock_inode_wait(file_inode(filp), fl);
-}
-EXPORT_SYMBOL(posix_lock_file_wait);
-
-/**
  * locks_mandatory_locked - Check for an active lock
  * @file: the file to check
  *
@@ -1890,19 +1875,6 @@ int flock_lock_inode_wait(struct inode *inode, struct file_lock *fl)
 EXPORT_SYMBOL(flock_lock_inode_wait);
 
 /**
- * flock_lock_file_wait - Apply a FLOCK-style lock to a file
- * @filp: The file to apply the lock to
- * @fl: The lock to be applied
- *
- * Add a FLOCK style lock to a file.
- */
-int flock_lock_file_wait(struct file *filp, struct file_lock *fl)
-{
-	return flock_lock_inode_wait(file_inode(filp), fl);
-}
-EXPORT_SYMBOL(flock_lock_file_wait);
-
-/**
  *	sys_flock: - flock() system call.
  *	@fd: the file descriptor to lock.
  *	@cmd: the type of lock to apply.
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 4c990edd1377..cc008c338f5a 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1047,13 +1047,11 @@ extern void locks_release_private(struct file_lock *);
 extern void posix_test_lock(struct file *, struct file_lock *);
 extern int posix_lock_file(struct file *, struct file_lock *, struct file_lock *);
 extern int posix_lock_inode_wait(struct inode *, struct file_lock *);
-extern int posix_lock_file_wait(struct file *, struct file_lock *);
 extern int posix_unblock_lock(struct file_lock *);
 extern int vfs_test_lock(struct file *, struct file_lock *);
 extern int vfs_lock_file(struct file *, unsigned int, struct file_lock *, struct file_lock *);
 extern int vfs_cancel_lock(struct file *filp, struct file_lock *fl);
 extern int flock_lock_inode_wait(struct inode *inode, struct file_lock *fl);
-extern int flock_lock_file_wait(struct file *filp, struct file_lock *fl);
 extern int __break_lease(struct inode *inode, unsigned int flags, unsigned int type);
 extern void lease_get_mtime(struct inode *, struct timespec *time);
 extern int generic_setlease(struct file *, long, struct file_lock **, void **priv);
@@ -1145,11 +1143,6 @@ static inline int posix_lock_inode_wait(struct inode *inode,
 	return -ENOLCK;
 }
 
-static inline int posix_lock_file_wait(struct file *filp, struct file_lock *fl)
-{
-	return -ENOLCK;
-}
-
 static inline int posix_unblock_lock(struct file_lock *waiter)
 {
 	return -ENOENT;
@@ -1177,12 +1170,6 @@ static inline int flock_lock_inode_wait(struct inode *inode,
 	return -ENOLCK;
 }
 
-static inline int flock_lock_file_wait(struct file *filp,
-				       struct file_lock *request)
-{
-	return -ENOLCK;
-}
-
 static inline int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 {
 	return 0;
@@ -1216,6 +1203,20 @@ static inline void show_fd_locks(struct seq_file *f,
 			struct file *filp, struct files_struct *files) {}
 #endif /* !CONFIG_FILE_LOCKING */
 
+static inline struct inode *file_inode(const struct file *f)
+{
+	return f->f_inode;
+}
+
+static inline int posix_lock_file_wait(struct file *filp, struct file_lock *fl)
+{
+	return posix_lock_inode_wait(file_inode(filp), fl);
+}
+
+static inline int flock_lock_file_wait(struct file *filp, struct file_lock *fl)
+{
+	return flock_lock_inode_wait(file_inode(filp), fl);
+}
 
 struct fasync_struct {
 	spinlock_t		fa_lock;
@@ -2025,11 +2026,6 @@ extern void ihold(struct inode * inode);
 extern void iput(struct inode *);
 extern int generic_update_time(struct inode *, struct timespec *, int);
 
-static inline struct inode *file_inode(const struct file *f)
-{
-	return f->f_inode;
-}
-
 /* /sys/fs */
 extern struct kobject *fs_kobj;
 
-- 
2.4.3


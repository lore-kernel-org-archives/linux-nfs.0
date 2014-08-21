Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f53.google.com ([209.85.192.53]:50114 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017AbaHUPrf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Aug 2014 11:47:35 -0400
Received: by mail-qg0-f53.google.com with SMTP id z60so5408445qgd.26
        for <linux-nfs@vger.kernel.org>; Thu, 21 Aug 2014 08:47:34 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] locks: remove lock_may_read and lock_may_write
Date: Thu, 21 Aug 2014 11:47:29 -0400
Message-Id: <1408636049-30737-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There are no callers of these functions.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/locks.c         | 80 ------------------------------------------------------
 include/linux/fs.h | 14 ----------
 2 files changed, 94 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 0ee775d691a9..bfd1438b2a2e 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -2597,86 +2597,6 @@ static int __init proc_locks_init(void)
 module_init(proc_locks_init);
 #endif
 
-/**
- *	lock_may_read - checks that the region is free of locks
- *	@inode: the inode that is being read
- *	@start: the first byte to read
- *	@len: the number of bytes to read
- *
- *	Emulates Windows locking requirements.  Whole-file
- *	mandatory locks (share modes) can prohibit a read and
- *	byte-range POSIX locks can prohibit a read if they overlap.
- *
- *	N.B. this function is only ever called
- *	from knfsd and ownership of locks is never checked.
- */
-int lock_may_read(struct inode *inode, loff_t start, unsigned long len)
-{
-	struct file_lock *fl;
-	int result = 1;
-
-	spin_lock(&inode->i_lock);
-	for (fl = inode->i_flock; fl != NULL; fl = fl->fl_next) {
-		if (IS_POSIX(fl)) {
-			if (fl->fl_type == F_RDLCK)
-				continue;
-			if ((fl->fl_end < start) || (fl->fl_start > (start + len)))
-				continue;
-		} else if (IS_FLOCK(fl)) {
-			if (!(fl->fl_type & LOCK_MAND))
-				continue;
-			if (fl->fl_type & LOCK_READ)
-				continue;
-		} else
-			continue;
-		result = 0;
-		break;
-	}
-	spin_unlock(&inode->i_lock);
-	return result;
-}
-
-EXPORT_SYMBOL(lock_may_read);
-
-/**
- *	lock_may_write - checks that the region is free of locks
- *	@inode: the inode that is being written
- *	@start: the first byte to write
- *	@len: the number of bytes to write
- *
- *	Emulates Windows locking requirements.  Whole-file
- *	mandatory locks (share modes) can prohibit a write and
- *	byte-range POSIX locks can prohibit a write if they overlap.
- *
- *	N.B. this function is only ever called
- *	from knfsd and ownership of locks is never checked.
- */
-int lock_may_write(struct inode *inode, loff_t start, unsigned long len)
-{
-	struct file_lock *fl;
-	int result = 1;
-
-	spin_lock(&inode->i_lock);
-	for (fl = inode->i_flock; fl != NULL; fl = fl->fl_next) {
-		if (IS_POSIX(fl)) {
-			if ((fl->fl_end < start) || (fl->fl_start > (start + len)))
-				continue;
-		} else if (IS_FLOCK(fl)) {
-			if (!(fl->fl_type & LOCK_MAND))
-				continue;
-			if (fl->fl_type & LOCK_WRITE)
-				continue;
-		} else
-			continue;
-		result = 0;
-		break;
-	}
-	spin_unlock(&inode->i_lock);
-	return result;
-}
-
-EXPORT_SYMBOL(lock_may_write);
-
 static int __init filelock_init(void)
 {
 	int i;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3b07ce2698de..458f733c96bd 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -985,8 +985,6 @@ extern void lease_get_mtime(struct inode *, struct timespec *time);
 extern int generic_setlease(struct file *, long, struct file_lock **);
 extern int vfs_setlease(struct file *, long, struct file_lock **);
 extern int lease_modify(struct file_lock **, int);
-extern int lock_may_read(struct inode *, loff_t start, unsigned long count);
-extern int lock_may_write(struct inode *, loff_t start, unsigned long count);
 #else /* !CONFIG_FILE_LOCKING */
 static inline int fcntl_getlk(struct file *file, unsigned int cmd,
 			      struct flock __user *user)
@@ -1117,18 +1115,6 @@ static inline int lease_modify(struct file_lock **before, int arg)
 {
 	return -EINVAL;
 }
-
-static inline int lock_may_read(struct inode *inode, loff_t start,
-				unsigned long len)
-{
-	return 1;
-}
-
-static inline int lock_may_write(struct inode *inode, loff_t start,
-				 unsigned long len)
-{
-	return 1;
-}
 #endif /* !CONFIG_FILE_LOCKING */
 
 
-- 
1.9.3


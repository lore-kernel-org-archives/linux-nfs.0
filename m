Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44288 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934404AbdEZUO5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 26 May 2017 16:14:57 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
        Jeff Layton <jlayton@poochiereds.net>, bfields@fieldses.org
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] fs/locks: Use fs-specific l_pid for remote locks
Date: Fri, 26 May 2017 16:14:51 -0400
Message-Id: <25fc5f8da5fb2c41a319160d0556b01afe3ed78d.1495829587.git.bcodding@redhat.com>
In-Reply-To: <cover.1495829587.git.bcodding@redhat.com>
References: <cover.1495829587.git.bcodding@redhat.com>
In-Reply-To: <cover.1495829587.git.bcodding@redhat.com>
References: <cover.1495829587.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we're setting fl_nspid at file_lock allocation, we need to handle
the case where a remote filesystem directly sets fl_pid.  If the filesystem
implements the lock operation, set a flag to return the lock's fl_pid,
rather than fl_nspid.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/locks.c         | 25 +++++++++++++++++++------
 include/linux/fs.h |  1 +
 2 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 270ae50247db..f1aac1680394 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -2052,16 +2052,28 @@ SYSCALL_DEFINE2(flock, unsigned int, fd, unsigned int, cmd)
  */
 int vfs_test_lock(struct file *filp, struct file_lock *fl)
 {
-	if (filp->f_op->lock && is_remote_lock(filp))
+	if (filp->f_op->lock && is_remote_lock(filp)) {
+		fl->fl_flags |= FL_PID_PRIV;
 		return filp->f_op->lock(filp, F_GETLK, fl);
+	}
 	posix_test_lock(filp, fl);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(vfs_test_lock);
 
+static inline int flock_translate_pid(struct file_lock *fl)
+{
+	if (IS_OFDLCK(fl))
+		return -1;
+	if (fl->fl_flags & FL_PID_PRIV)
+		return fl->fl_pid;
+	return pid_vnr(fl->fl_nspid);
+}
+
+
 static int posix_lock_to_flock(struct flock *flock, struct file_lock *fl)
 {
-	flock->l_pid = IS_OFDLCK(fl) ? -1 : fl->fl_pid;
+	flock->l_pid = flock_translate_pid(fl);
 #if BITS_PER_LONG == 32
 	/*
 	 * Make sure we can represent the posix lock via
@@ -2083,7 +2095,7 @@ static int posix_lock_to_flock(struct flock *flock, struct file_lock *fl)
 #if BITS_PER_LONG == 32
 static void posix_lock_to_flock64(struct flock64 *flock, struct file_lock *fl)
 {
-	flock->l_pid = IS_OFDLCK(fl) ? -1 : fl->fl_pid;
+	flock->l_pid = flock_translate_pid(fl);
 	flock->l_start = fl->fl_start;
 	flock->l_len = fl->fl_end == OFFSET_MAX ? 0 :
 		fl->fl_end - fl->fl_start + 1;
@@ -2636,7 +2648,9 @@ static void lock_get_status(struct seq_file *f, struct file_lock *fl,
 	struct inode *inode = NULL;
 	unsigned int fl_pid;
 
-	if (fl->fl_nspid) {
+	if (fl->fl_flags & FL_PID_PRIV) {
+		fl_pid = fl->fl_pid;
+	} else {
 		struct pid_namespace *proc_pidns = file_inode(f->file)->i_sb->s_fs_info;
 
 		/* Don't let fl_pid change based on who is reading the file */
@@ -2649,8 +2663,7 @@ static void lock_get_status(struct seq_file *f, struct file_lock *fl,
 		 */
 		if (fl_pid == 0)
 			return;
-	} else
-		fl_pid = fl->fl_pid;
+	}
 
 	if (fl->fl_file != NULL)
 		inode = locks_inode(fl->fl_file);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 0ad325ed71e8..8d945b86b9f3 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -908,6 +908,7 @@ static inline struct file *get_file(struct file *f)
 #define FL_UNLOCK_PENDING	512 /* Lease is being broken */
 #define FL_OFDLCK	1024	/* lock is "owned" by struct file */
 #define FL_LAYOUT	2048	/* outstanding pNFS layout */
+#define FL_PID_PRIV	4096	/* F_GETLK should report fl_pid */
 
 #define FL_CLOSE_POSIX (FL_POSIX | FL_CLOSE)
 
-- 
2.9.3


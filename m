Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54746 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750844AbdFSNYJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Jun 2017 09:24:09 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Jeff Layton <jlayton@poochiereds.net>, bfields@fieldses.org,
        Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 2/2] fs/locks: Remove fl_nspid and use fs-specific l_pid for remote locks
Date: Mon, 19 Jun 2017 09:24:07 -0400
Message-Id: <901367ff4ffd87594a380e3a0a5d20c4e4195b0e.1497877897.git.bcodding@redhat.com>
In-Reply-To: <cover.1497877897.git.bcodding@redhat.com>
References: <cover.1497877897.git.bcodding@redhat.com>
In-Reply-To: <cover.1497877897.git.bcodding@redhat.com>
References: <cover.1497877897.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since commit c69899a17ca4 "NFSv4: Update of VFS byte range lock must be
atomic with the stateid update", NFSv4 has been inserting locks in rpciod
worker context.  The result is that the file_lock's fl_nspid is the
kworker's pid instead of the original userspace pid.

The fl_nspid is only used to represent the namespaced virtual pid number
when displaying locks or returning from F_GETLK.  There's no reason to set
it for every inserted lock, since we can usually just look it up from
fl_pid.  So, instead of looking up and holding struct pid for every lock,
let's just look up the virtual pid number from fl_pid when it is needed.
That means we can remove fl_nspid entirely.

Also, if we're now translating fl_pid for F_GETLK and /proc/locks, we need
to handle the case where a remote filesystem directly sets fl_pid.  In that
case, the fl_pid should not be translated into a local pid namespace.  If
the filesystem implements the lock operation, set a flag to return the
lock's fl_pid value directly, rather translate it.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/locks.c         | 70 +++++++++++++++++++++++++++++++++++-------------------
 include/linux/fs.h |  2 +-
 2 files changed, 46 insertions(+), 26 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index d7daa6c8932f..206a46d28bbd 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -733,7 +733,6 @@ static void locks_wake_up_blocks(struct file_lock *blocker)
 static void
 locks_insert_lock_ctx(struct file_lock *fl, struct list_head *before)
 {
-	fl->fl_nspid = get_pid(task_tgid(current));
 	list_add_tail(&fl->fl_list, before);
 	locks_insert_global_locks(fl);
 }
@@ -743,10 +742,6 @@ locks_unlink_lock_ctx(struct file_lock *fl)
 {
 	locks_delete_global_locks(fl);
 	list_del_init(&fl->fl_list);
-	if (fl->fl_nspid) {
-		put_pid(fl->fl_nspid);
-		fl->fl_nspid = NULL;
-	}
 	locks_wake_up_blocks(fl);
 }
 
@@ -823,8 +818,6 @@ posix_test_lock(struct file *filp, struct file_lock *fl)
 	list_for_each_entry(cfl, &ctx->flc_posix, fl_list) {
 		if (posix_locks_conflict(fl, cfl)) {
 			locks_copy_conflock(fl, cfl);
-			if (cfl->fl_nspid)
-				fl->fl_pid = pid_vnr(cfl->fl_nspid);
 			goto out;
 		}
 	}
@@ -2041,16 +2034,46 @@ SYSCALL_DEFINE2(flock, unsigned int, fd, unsigned int, cmd)
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
 
+/**
+ * locks_translate_pid - translate a pid number into a namespace
+ * @nr: The pid number in the init_pid_ns
+ * @ns: The namespace into which the pid should be translated
+ *
+ * Used to tranlate a fl_pid into a namespace virtual pid number
+ */
+static pid_t locks_translate_pid(int init_nr, struct pid_namespace *ns)
+{
+	pid_t vnr;
+	struct pid *pid;
+
+	rcu_read_lock();
+	pid = find_pid_ns(init_nr, &init_pid_ns);
+	vnr = pid_nr_ns(pid, ns);
+	rcu_read_unlock();
+	return vnr;
+}
+
+static pid_t flock_translate_pid(struct file_lock *fl)
+{
+	if (IS_OFDLCK(fl))
+		return -1;
+	if (fl->fl_flags & FL_PID_PRIV)
+		return fl->fl_pid;
+	return locks_translate_pid(fl->fl_pid,  task_active_pid_ns(current));
+}
+
 static int posix_lock_to_flock(struct flock *flock, struct file_lock *fl)
 {
-	flock->l_pid = IS_OFDLCK(fl) ? -1 : fl->fl_pid;
+	flock->l_pid = flock_translate_pid(fl);
 #if BITS_PER_LONG == 32
 	/*
 	 * Make sure we can represent the posix lock via
@@ -2072,7 +2095,7 @@ static int posix_lock_to_flock(struct flock *flock, struct file_lock *fl)
 #if BITS_PER_LONG == 32
 static void posix_lock_to_flock64(struct flock64 *flock, struct file_lock *fl)
 {
-	flock->l_pid = IS_OFDLCK(fl) ? -1 : fl->fl_pid;
+	flock->l_pid = flock_translate_pid(fl);
 	flock->l_start = fl->fl_start;
 	flock->l_len = fl->fl_end == OFFSET_MAX ? 0 :
 		fl->fl_end - fl->fl_start + 1;
@@ -2584,22 +2607,19 @@ static void lock_get_status(struct seq_file *f, struct file_lock *fl,
 {
 	struct inode *inode = NULL;
 	unsigned int fl_pid;
+	struct pid_namespace *proc_pidns = file_inode(f->file)->i_sb->s_fs_info;
 
-	if (fl->fl_nspid) {
-		struct pid_namespace *proc_pidns = file_inode(f->file)->i_sb->s_fs_info;
-
-		/* Don't let fl_pid change based on who is reading the file */
-		fl_pid = pid_nr_ns(fl->fl_nspid, proc_pidns);
-
-		/*
-		 * If there isn't a fl_pid don't display who is waiting on
-		 * the lock if we are called from locks_show, or if we are
-		 * called from __show_fd_info - skip lock entirely
-		 */
-		if (fl_pid == 0)
-			return;
-	} else
+	if (fl->fl_flags & FL_PID_PRIV)
 		fl_pid = fl->fl_pid;
+	else
+		fl_pid = locks_translate_pid(fl->fl_pid, proc_pidns);
+	/*
+	 * If there isn't a fl_pid don't display who is waiting on
+	 * the lock if we are called from locks_show, or if we are
+	 * called from __show_fd_info - skip lock entirely
+	 */
+	if (fl_pid == 0)
+		return;
 
 	if (fl->fl_file != NULL)
 		inode = locks_inode(fl->fl_file);
@@ -2674,7 +2694,7 @@ static int locks_show(struct seq_file *f, void *v)
 
 	fl = hlist_entry(v, struct file_lock, fl_link);
 
-	if (fl->fl_nspid && !pid_nr_ns(fl->fl_nspid, proc_pidns))
+	if (locks_translate_pid(fl->fl_pid, proc_pidns) == 0)
 		return 0;
 
 	lock_get_status(f, fl, iter->li_pos, "");
diff --git a/include/linux/fs.h b/include/linux/fs.h
index aa4affb38c39..179496a9719d 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -908,6 +908,7 @@ static inline struct file *get_file(struct file *f)
 #define FL_UNLOCK_PENDING	512 /* Lease is being broken */
 #define FL_OFDLCK	1024	/* lock is "owned" by struct file */
 #define FL_LAYOUT	2048	/* outstanding pNFS layout */
+#define FL_PID_PRIV	4096	/* F_GETLK should report fl_pid */
 
 #define FL_CLOSE_POSIX (FL_POSIX | FL_CLOSE)
 
@@ -984,7 +985,6 @@ struct file_lock {
 	unsigned char fl_type;
 	unsigned int fl_pid;
 	int fl_link_cpu;		/* what cpu's list is this on? */
-	struct pid *fl_nspid;
 	wait_queue_head_t fl_wait;
 	struct file *fl_file;
 	loff_t fl_start;
-- 
2.9.3


From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: file locking patches
Date: Sun, 3 Feb 2008 19:25:41 -0500
Message-ID: <20080204002541.GB6156@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pie.citi.umich.edu ([141.211.133.115]:50663 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753949AbYBDAZr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 3 Feb 2008 19:25:47 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following changes are available from the locks branch of the git
repository at:

  git://linux-nfs.org/~bfields/linux.git locks

These are just three small file-locking-related patches, mostly cleanup.
All of them have been unchanged in -mm for a while.

--b.

J. Bruce Fields (1):
      locks: clarify posix_locks_deadlock

Matthew Wilcox (1):
      file locks: Use wait_event_interruptible_timeout()

Vitaliy Gusev (1):
      pid-namespaces-vs-locks-interaction

 fs/locks.c         |  125 ++++++++++++++++++++++++++-------------------------
 include/linux/fs.h |    1 +
 2 files changed, 65 insertions(+), 61 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 8b8388e..49354b9 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -125,6 +125,7 @@
 #include <linux/syscalls.h>
 #include <linux/time.h>
 #include <linux/rcupdate.h>
+#include <linux/pid_namespace.h>
 
 #include <asm/semaphore.h>
 #include <asm/uaccess.h>
@@ -185,6 +186,7 @@ void locks_init_lock(struct file_lock *fl)
 	fl->fl_fasync = NULL;
 	fl->fl_owner = NULL;
 	fl->fl_pid = 0;
+	fl->fl_nspid = NULL;
 	fl->fl_file = NULL;
 	fl->fl_flags = 0;
 	fl->fl_type = 0;
@@ -553,6 +555,8 @@ static void locks_insert_lock(struct file_lock **pos, struct file_lock *fl)
 {
 	list_add(&fl->fl_link, &file_lock_list);
 
+	fl->fl_nspid = get_pid(task_tgid(current));
+
 	/* insert into file's list */
 	fl->fl_next = *pos;
 	*pos = fl;
@@ -584,6 +588,11 @@ static void locks_delete_lock(struct file_lock **thisfl_p)
 	if (fl->fl_ops && fl->fl_ops->fl_remove)
 		fl->fl_ops->fl_remove(fl);
 
+	if (fl->fl_nspid) {
+		put_pid(fl->fl_nspid);
+		fl->fl_nspid = NULL;
+	}
+
 	locks_wake_up_blocks(fl);
 	locks_free_lock(fl);
 }
@@ -634,33 +643,6 @@ static int flock_locks_conflict(struct file_lock *caller_fl, struct file_lock *s
 	return (locks_conflict(caller_fl, sys_fl));
 }
 
-static int interruptible_sleep_on_locked(wait_queue_head_t *fl_wait, int timeout)
-{
-	int result = 0;
-	DECLARE_WAITQUEUE(wait, current);
-
-	__set_current_state(TASK_INTERRUPTIBLE);
-	add_wait_queue(fl_wait, &wait);
-	if (timeout == 0)
-		schedule();
-	else
-		result = schedule_timeout(timeout);
-	if (signal_pending(current))
-		result = -ERESTARTSYS;
-	remove_wait_queue(fl_wait, &wait);
-	__set_current_state(TASK_RUNNING);
-	return result;
-}
-
-static int locks_block_on_timeout(struct file_lock *blocker, struct file_lock *waiter, int time)
-{
-	int result;
-	locks_insert_block(blocker, waiter);
-	result = interruptible_sleep_on_locked(&waiter->fl_wait, time);
-	__locks_delete_block(waiter);
-	return result;
-}
-
 void
 posix_test_lock(struct file *filp, struct file_lock *fl)
 {
@@ -673,55 +655,67 @@ posix_test_lock(struct file *filp, struct file_lock *fl)
 		if (posix_locks_conflict(fl, cfl))
 			break;
 	}
-	if (cfl)
+	if (cfl) {
 		__locks_copy_lock(fl, cfl);
-	else
+		if (cfl->fl_nspid)
+			fl->fl_pid = pid_nr_ns(cfl->fl_nspid,
+						task_active_pid_ns(current));
+	} else
 		fl->fl_type = F_UNLCK;
 	unlock_kernel();
 	return;
 }
-
 EXPORT_SYMBOL(posix_test_lock);
 
-/* This function tests for deadlock condition before putting a process to
- * sleep. The detection scheme is no longer recursive. Recursive was neat,
- * but dangerous - we risked stack corruption if the lock data was bad, or
- * if the recursion was too deep for any other reason.
+/*
+ * Deadlock detection:
+ *
+ * We attempt to detect deadlocks that are due purely to posix file
+ * locks.
  *
- * We rely on the fact that a task can only be on one lock's wait queue
- * at a time. When we find blocked_task on a wait queue we can re-search
- * with blocked_task equal to that queue's owner, until either blocked_task
- * isn't found, or blocked_task is found on a queue owned by my_task.
+ * We assume that a task can be waiting for at most one lock at a time.
+ * So for any acquired lock, the process holding that lock may be
+ * waiting on at most one other lock.  That lock in turns may be held by
+ * someone waiting for at most one other lock.  Given a requested lock
+ * caller_fl which is about to wait for a conflicting lock block_fl, we
+ * follow this chain of waiters to ensure we are not about to create a
+ * cycle.
  *
- * Note: the above assumption may not be true when handling lock requests
- * from a broken NFS client. But broken NFS clients have a lot more to
- * worry about than proper deadlock detection anyway... --okir
+ * Since we do this before we ever put a process to sleep on a lock, we
+ * are ensured that there is never a cycle; that is what guarantees that
+ * the while() loop in posix_locks_deadlock() eventually completes.
  *
- * However, the failure of this assumption (also possible in the case of
- * multiple tasks sharing the same open file table) also means there's no
- * guarantee that the loop below will terminate.  As a hack, we give up
- * after a few iterations.
+ * Note: the above assumption may not be true when handling lock
+ * requests from a broken NFS client. It may also fail in the presence
+ * of tasks (such as posix threads) sharing the same open file table.
+ *
+ * To handle those cases, we just bail out after a few iterations.
  */
 
 #define MAX_DEADLK_ITERATIONS 10
 
+/* Find a lock that the owner of the given block_fl is blocking on. */
+static struct file_lock *what_owner_is_waiting_for(struct file_lock *block_fl)
+{
+	struct file_lock *fl;
+
+	list_for_each_entry(fl, &blocked_list, fl_link) {
+		if (posix_same_owner(fl, block_fl))
+			return fl->fl_next;
+	}
+	return NULL;
+}
+
 static int posix_locks_deadlock(struct file_lock *caller_fl,
 				struct file_lock *block_fl)
 {
-	struct file_lock *fl;
 	int i = 0;
 
-next_task:
-	if (posix_same_owner(caller_fl, block_fl))
-		return 1;
-	list_for_each_entry(fl, &blocked_list, fl_link) {
-		if (posix_same_owner(fl, block_fl)) {
-			if (i++ > MAX_DEADLK_ITERATIONS)
-				return 0;
-			fl = fl->fl_next;
-			block_fl = fl;
-			goto next_task;
-		}
+	while ((block_fl = what_owner_is_waiting_for(block_fl))) {
+		if (i++ > MAX_DEADLK_ITERATIONS)
+			return 0;
+		if (posix_same_owner(caller_fl, block_fl))
+			return 1;
 	}
 	return 0;
 }
@@ -1256,7 +1250,10 @@ restart:
 		if (break_time == 0)
 			break_time++;
 	}
-	error = locks_block_on_timeout(flock, new_fl, break_time);
+	locks_insert_block(flock, new_fl);
+	error = wait_event_interruptible_timeout(new_fl->fl_wait,
+						!new_fl->fl_next, break_time);
+	__locks_delete_block(new_fl);
 	if (error >= 0) {
 		if (error == 0)
 			time_out_leases(inode);
@@ -2084,6 +2081,12 @@ static void lock_get_status(struct seq_file *f, struct file_lock *fl,
 							int id, char *pfx)
 {
 	struct inode *inode = NULL;
+	unsigned int fl_pid;
+
+	if (fl->fl_nspid)
+		fl_pid = pid_nr_ns(fl->fl_nspid, task_active_pid_ns(current));
+	else
+		fl_pid = fl->fl_pid;
 
 	if (fl->fl_file != NULL)
 		inode = fl->fl_file->f_path.dentry->d_inode;
@@ -2124,16 +2127,16 @@ static void lock_get_status(struct seq_file *f, struct file_lock *fl,
 	}
 	if (inode) {
 #ifdef WE_CAN_BREAK_LSLK_NOW
-		seq_printf(f, "%d %s:%ld ", fl->fl_pid,
+		seq_printf(f, "%d %s:%ld ", fl_pid,
 				inode->i_sb->s_id, inode->i_ino);
 #else
 		/* userspace relies on this representation of dev_t ;-( */
-		seq_printf(f, "%d %02x:%02x:%ld ", fl->fl_pid,
+		seq_printf(f, "%d %02x:%02x:%ld ", fl_pid,
 				MAJOR(inode->i_sb->s_dev),
 				MINOR(inode->i_sb->s_dev), inode->i_ino);
 #endif
 	} else {
-		seq_printf(f, "%d <none>:0 ", fl->fl_pid);
+		seq_printf(f, "%d <none>:0 ", fl_pid);
 	}
 	if (IS_POSIX(fl)) {
 		if (fl->fl_end == OFFSET_MAX)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index a516b67..b7736ab 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -872,6 +872,7 @@ struct file_lock {
 	struct list_head fl_block;	/* circular list of blocked processes */
 	fl_owner_t fl_owner;
 	unsigned int fl_pid;
+	struct pid *fl_nspid;
 	wait_queue_head_t fl_wait;
 	struct file *fl_file;
 	unsigned char fl_flags;

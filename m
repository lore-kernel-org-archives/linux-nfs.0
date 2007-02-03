From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 5/14] locks: add fl_notify arguments for asynchronous lock return
Date: Sat,  3 Feb 2007 00:34:01 -0500
Message-ID: <43483.1035360277$1170484082@news.gmane.org>
References: 11704806552464-git-send-email- <11704808501171-git-send-email-> <11704808502512-git-send-email-> <11704808513862-git-send-email-> <1170480851972-git-send-email->
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
To: linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1170480851972-git-send-email->
Message-Id: <a4ecb8974d61a5077d24cf42ed2c564b4fa7aadf.1170479265.git.bfields@citi.umich.edu>
In-Reply-To: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu>
References: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: Marc Eshel <eshel@almaden.ibm.com> - unquoted

Acquiring a lock on a cluster filesystem may require communication with remote
hosts, and to avoid blocking lockd or nfsd threads during such communication,
we allow the results to be returned asynchronously.

When a ->lock() call needs to block, the file system will return -EINPROGRESS,
and then later return the results with a call to the routine in the fl_notify
field of the lock_manager_operations struct.

Note that this is different from the ->lock() call discovering that there is a
conflict which would cause the caller to block; this is still handled in the
same way as before.  In fact, we don't currently handle "blocking" locks at
all; those are less urgent, because the filesystem can always just return an
immediate -EAGAIN without denying the lock.

So this asynchronous interface is only used in the case of a non-blocking lock,
where we must know whether to allow or deny the lock now.

We're using fl_notify to asynchronously return the result of a lock
request.  So we want fl_notify to be able to return a status and, if
appropriate, a conflicting lock.

This only current caller of fl_notify is in the blocked case, in which case
we don't use these extra arguments.

We also allow fl_notify to return an error.  (Also ignored for now.)

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/svclock.c |    7 ++++---
 fs/locks.c         |   21 ++++++++++++++++++++-
 include/linux/fs.h |    2 +-
 3 files changed, 25 insertions(+), 5 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index c7db0a5..d2c8020 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -506,12 +506,13 @@ nlmsvc_cancel_blocked(struct nlm_file *file, struct nlm_lock *lock)
  * This function doesn't grant the blocked lock instantly, but rather moves
  * the block to the head of nlm_blocked where it can be picked up by lockd.
  */
-static void
-nlmsvc_notify_blocked(struct file_lock *fl)
+static int
+nlmsvc_notify_blocked(struct file_lock *fl, struct file_lock *conf, int result)
 {
 	struct nlm_block	*block;
 
-	dprintk("lockd: VFS unblock notification for block %p\n", fl);
+	dprintk("lockd: nlmsvc_notify_blocked lock %p conf %p result %d\n",
+							fl, conf, result);
 	list_for_each_entry(block, &nlm_blocked, b_list) {
 		if (nlm_compare_locks(&block->b_call->a_args.lock.fl, fl)) {
 			nlmsvc_insert_block(block, 0);
diff --git a/fs/locks.c b/fs/locks.c
index 1bd6418..819dc28 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -544,7 +544,7 @@ static void locks_wake_up_blocks(struct file_lock *blocker)
 				struct file_lock, fl_block);
 		__locks_delete_block(waiter);
 		if (waiter->fl_lmops && waiter->fl_lmops->fl_notify)
-			waiter->fl_lmops->fl_notify(waiter);
+			waiter->fl_lmops->fl_notify(waiter, NULL, -EAGAIN);
 		else
 			wake_up(&waiter->fl_wait);
 	}
@@ -1696,6 +1696,25 @@ out:
  * @filp: The file to apply the lock to
  * @cmd: type of locking operation (F_SETLK, F_GETLK, etc.)
  * @fl: The lock to be applied
+ *
+ * To avoid blocking kernel daemons, such as lockd, that need to acquire POSIX
+ * locks, the ->lock() interface may return asynchronously, before the lock has
+ * been granted or denied by the underlying filesystem, if (and only if)
+ * fl_notify is set. Callers expecting ->lock() to return asynchronously
+ * will only use F_SETLK, not F_SETLKW; they will set FL_SLEEP if (and only if)
+ * the request is for a blocking lock. When ->lock() does return asynchronously,
+ * it must return -EINPROGRESS, and call ->fl_notify() when the lock
+ * request completes.
+ * If the request is for non-blocking lock the file system should return
+ * -EINPROGRESS then try to get the lock and call the callback routine with
+ * the result. If the request timed out the callback routine will return a
+ * nonzero return code and the file system should release the lock. The file
+ * system is also responsible to keep a corresponding posix lock when it
+ * grants a lock so the VFS can find out which locks are locally held and do
+ * the correct lock cleanup when required.
+ * The underlying filesystem must not drop the kernel lock or call
+ * ->fl_notify() before returning to the caller with a -EINPROGRESS
+ * return code.
  */
 int vfs_lock_file(struct file *filp, unsigned int cmd, struct file_lock *fl)
 {
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 1410e53..5d44d25 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -783,7 +783,7 @@ struct file_lock_operations {
 
 struct lock_manager_operations {
 	int (*fl_compare_owner)(struct file_lock *, struct file_lock *);
-	void (*fl_notify)(struct file_lock *);	/* unblock callback */
+	int (*fl_notify)(struct file_lock *, struct file_lock *, int);
 	void (*fl_copy_lock)(struct file_lock *, struct file_lock *);
 	void (*fl_release_private)(struct file_lock *);
 	void (*fl_break)(struct file_lock *);
-- 
1.5.0.rc1.g72fe


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58018 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751660Ab1GUCpr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jul 2011 22:45:47 -0400
Date: Wed, 20 Jul 2011 22:45:46 -0400
To: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH] locks: rename lock-manager ops
Message-ID: <20110721024546.GA30918@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

Both the filesystem and the lock manager can associate operations with a
lock.  Confusingly, one of them (fl_release_private) actually has the
same name in both operation structures.

It would save some confusion to give the lock-manager ops different
prefixes.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---

Just a superficial change that would have saved me some confusion in a
few cases; objections?

--b.

 Documentation/filesystems/Locking |   24 ++++++++++++------------
 fs/dlm/plock.c                    |   10 +++++-----
 fs/fuse/file.c                    |    2 +-
 fs/lockd/svclock.c                |    8 ++++----
 fs/locks.c                        |   34 +++++++++++++++++-----------------
 fs/nfsd/nfs4state.c               |    4 ++--
 include/linux/fs.h                |   12 ++++++------
 7 files changed, 47 insertions(+), 47 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index 57d827d..82e8e52 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -338,21 +338,21 @@ fl_release_private:	maybe		no
 
 ----------------------- lock_manager_operations ---------------------------
 prototypes:
-	int (*fl_compare_owner)(struct file_lock *, struct file_lock *);
-	void (*fl_notify)(struct file_lock *);  /* unblock callback */
-	int (*fl_grant)(struct file_lock *, struct file_lock *, int);
-	void (*fl_release_private)(struct file_lock *);
-	void (*fl_break)(struct file_lock *); /* break_lease callback */
-	int (*fl_change)(struct file_lock **, int);
+	int (*lm_compare_owner)(struct file_lock *, struct file_lock *);
+	void (*lm_notify)(struct file_lock *);  /* unblock callback */
+	int (*lm_grant)(struct file_lock *, struct file_lock *, int);
+	void (*lm_release_private)(struct file_lock *);
+	void (*lm_break)(struct file_lock *); /* break_lease callback */
+	int (*lm_change)(struct file_lock **, int);
 
 locking rules:
 			file_lock_lock	may block
-fl_compare_owner:	yes		no
-fl_notify:		yes		no
-fl_grant:		no		no
-fl_release_private:	maybe		no
-fl_break:		yes		no
-fl_change		yes		no
+lm_compare_owner:	yes		no
+lm_notify:		yes		no
+lm_grant:		no		no
+lm_release_private:	maybe		no
+lm_break:		yes		no
+lm_change		yes		no
 
 --------------------------- buffer_head -----------------------------------
 prototypes:
diff --git a/fs/dlm/plock.c b/fs/dlm/plock.c
index e2b8780..01fd5c1 100644
--- a/fs/dlm/plock.c
+++ b/fs/dlm/plock.c
@@ -92,7 +92,7 @@ static void do_unlock_close(struct dlm_ls *ls, u64 number,
 	op->info.number		= number;
 	op->info.start		= 0;
 	op->info.end		= OFFSET_MAX;
-	if (fl->fl_lmops && fl->fl_lmops->fl_grant)
+	if (fl->fl_lmops && fl->fl_lmops->lm_grant)
 		op->info.owner	= (__u64) fl->fl_pid;
 	else
 		op->info.owner	= (__u64)(long) fl->fl_owner;
@@ -128,11 +128,11 @@ int dlm_posix_lock(dlm_lockspace_t *lockspace, u64 number, struct file *file,
 	op->info.number		= number;
 	op->info.start		= fl->fl_start;
 	op->info.end		= fl->fl_end;
-	if (fl->fl_lmops && fl->fl_lmops->fl_grant) {
+	if (fl->fl_lmops && fl->fl_lmops->lm_grant) {
 		/* fl_owner is lockd which doesn't distinguish
 		   processes on the nfs client */
 		op->info.owner	= (__u64) fl->fl_pid;
-		xop->callback	= fl->fl_lmops->fl_grant;
+		xop->callback	= fl->fl_lmops->lm_grant;
 		locks_init_lock(&xop->flc);
 		locks_copy_lock(&xop->flc, fl);
 		xop->fl		= fl;
@@ -268,7 +268,7 @@ int dlm_posix_unlock(dlm_lockspace_t *lockspace, u64 number, struct file *file,
 	op->info.number		= number;
 	op->info.start		= fl->fl_start;
 	op->info.end		= fl->fl_end;
-	if (fl->fl_lmops && fl->fl_lmops->fl_grant)
+	if (fl->fl_lmops && fl->fl_lmops->lm_grant)
 		op->info.owner	= (__u64) fl->fl_pid;
 	else
 		op->info.owner	= (__u64)(long) fl->fl_owner;
@@ -327,7 +327,7 @@ int dlm_posix_get(dlm_lockspace_t *lockspace, u64 number, struct file *file,
 	op->info.number		= number;
 	op->info.start		= fl->fl_start;
 	op->info.end		= fl->fl_end;
-	if (fl->fl_lmops && fl->fl_lmops->fl_grant)
+	if (fl->fl_lmops && fl->fl_lmops->lm_grant)
 		op->info.owner	= (__u64) fl->fl_pid;
 	else
 		op->info.owner	= (__u64)(long) fl->fl_owner;
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 82a6646..9150865 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1495,7 +1495,7 @@ static int fuse_setlk(struct file *file, struct file_lock *fl, int flock)
 	pid_t pid = fl->fl_type != F_UNLCK ? current->tgid : 0;
 	int err;
 
-	if (fl->fl_lmops && fl->fl_lmops->fl_grant) {
+	if (fl->fl_lmops && fl->fl_lmops->lm_grant) {
 		/* NLM needs asynchronous locks, which we don't support yet */
 		return -ENOLCK;
 	}
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 6e31695..f0179c3 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -632,7 +632,7 @@ nlmsvc_cancel_blocked(struct nlm_file *file, struct nlm_lock *lock)
 
 /*
  * This is a callback from the filesystem for VFS file lock requests.
- * It will be used if fl_grant is defined and the filesystem can not
+ * It will be used if lm_grant is defined and the filesystem can not
  * respond to the request immediately.
  * For GETLK request it will copy the reply to the nlm_block.
  * For SETLK or SETLKW request it will get the local posix lock.
@@ -719,9 +719,9 @@ static int nlmsvc_same_owner(struct file_lock *fl1, struct file_lock *fl2)
 }
 
 const struct lock_manager_operations nlmsvc_lock_operations = {
-	.fl_compare_owner = nlmsvc_same_owner,
-	.fl_notify = nlmsvc_notify_blocked,
-	.fl_grant = nlmsvc_grant_deferred,
+	.lm_compare_owner = nlmsvc_same_owner,
+	.lm_notify = nlmsvc_notify_blocked,
+	.lm_grant = nlmsvc_grant_deferred,
 };
 
 /*
diff --git a/fs/locks.c b/fs/locks.c
index 7ddab3f..703f545 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -187,8 +187,8 @@ void locks_release_private(struct file_lock *fl)
 		fl->fl_ops = NULL;
 	}
 	if (fl->fl_lmops) {
-		if (fl->fl_lmops->fl_release_private)
-			fl->fl_lmops->fl_release_private(fl);
+		if (fl->fl_lmops->lm_release_private)
+			fl->fl_lmops->lm_release_private(fl);
 		fl->fl_lmops = NULL;
 	}
 
@@ -423,9 +423,9 @@ static void lease_release_private_callback(struct file_lock *fl)
 }
 
 static const struct lock_manager_operations lease_manager_ops = {
-	.fl_break = lease_break_callback,
-	.fl_release_private = lease_release_private_callback,
-	.fl_change = lease_modify,
+	.lm_break = lease_break_callback,
+	.lm_release_private = lease_release_private_callback,
+	.lm_change = lease_modify,
 };
 
 /*
@@ -478,9 +478,9 @@ static inline int locks_overlap(struct file_lock *fl1, struct file_lock *fl2)
  */
 static int posix_same_owner(struct file_lock *fl1, struct file_lock *fl2)
 {
-	if (fl1->fl_lmops && fl1->fl_lmops->fl_compare_owner)
+	if (fl1->fl_lmops && fl1->fl_lmops->lm_compare_owner)
 		return fl2->fl_lmops == fl1->fl_lmops &&
-			fl1->fl_lmops->fl_compare_owner(fl1, fl2);
+			fl1->fl_lmops->lm_compare_owner(fl1, fl2);
 	return fl1->fl_owner == fl2->fl_owner;
 }
 
@@ -530,8 +530,8 @@ static void locks_wake_up_blocks(struct file_lock *blocker)
 		waiter = list_first_entry(&blocker->fl_block,
 				struct file_lock, fl_block);
 		__locks_delete_block(waiter);
-		if (waiter->fl_lmops && waiter->fl_lmops->fl_notify)
-			waiter->fl_lmops->fl_notify(waiter);
+		if (waiter->fl_lmops && waiter->fl_lmops->lm_notify)
+			waiter->fl_lmops->lm_notify(waiter);
 		else
 			wake_up(&waiter->fl_wait);
 	}
@@ -1218,7 +1218,7 @@ int __break_lease(struct inode *inode, unsigned int mode)
 			fl->fl_type = future;
 			fl->fl_break_time = break_time;
 			/* lease must have lmops break callback */
-			fl->fl_lmops->fl_break(fl);
+			fl->fl_lmops->lm_break(fl);
 		}
 	}
 
@@ -1328,7 +1328,7 @@ int fcntl_getlease(struct file *filp)
  *	@arg: type of lease to obtain
  *	@flp: input - file_lock to use, output - file_lock inserted
  *
- *	The (input) flp->fl_lmops->fl_break function is required
+ *	The (input) flp->fl_lmops->lm_break function is required
  *	by break_lease().
  *
  *	Called with file_lock_lock held.
@@ -1354,7 +1354,7 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
 
 	time_out_leases(inode);
 
-	BUG_ON(!(*flp)->fl_lmops->fl_break);
+	BUG_ON(!(*flp)->fl_lmops->lm_break);
 
 	if (arg != F_UNLCK) {
 		error = -EAGAIN;
@@ -1396,7 +1396,7 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
 		goto out;
 
 	if (my_before != NULL) {
-		error = lease->fl_lmops->fl_change(my_before, arg);
+		error = lease->fl_lmops->lm_change(my_before, arg);
 		if (!error)
 			*flp = *my_before;
 		goto out;
@@ -1432,7 +1432,7 @@ static int __vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
  *	@lease: file_lock to use
  *
  *	Call this to establish a lease on the file.
- *	The (*lease)->fl_lmops->fl_break operation must be set; if not,
+ *	The (*lease)->fl_lmops->lm_break operation must be set; if not,
  *	break_lease will oops!
  *
  *	This will call the filesystem's setlease file method, if
@@ -1730,10 +1730,10 @@ out:
  * To avoid blocking kernel daemons, such as lockd, that need to acquire POSIX
  * locks, the ->lock() interface may return asynchronously, before the lock has
  * been granted or denied by the underlying filesystem, if (and only if)
- * fl_grant is set. Callers expecting ->lock() to return asynchronously
+ * lm_grant is set. Callers expecting ->lock() to return asynchronously
  * will only use F_SETLK, not F_SETLKW; they will set FL_SLEEP if (and only if)
  * the request is for a blocking lock. When ->lock() does return asynchronously,
- * it must return FILE_LOCK_DEFERRED, and call ->fl_grant() when the lock
+ * it must return FILE_LOCK_DEFERRED, and call ->lm_grant() when the lock
  * request completes.
  * If the request is for non-blocking lock the file system should return
  * FILE_LOCK_DEFERRED then try to get the lock and call the callback routine
@@ -1743,7 +1743,7 @@ out:
  * grants a lock so the VFS can find out which locks are locally held and do
  * the correct lock cleanup when required.
  * The underlying filesystem must not drop the kernel lock or call
- * ->fl_grant() before returning to the caller with a FILE_LOCK_DEFERRED
+ * ->lm_grant() before returning to the caller with a FILE_LOCK_DEFERRED
  * return code.
  */
 int vfs_lock_file(struct file *filp, unsigned int cmd, struct file_lock *fl, struct file_lock *conf)
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6a471af..47da5257 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2425,8 +2425,8 @@ int nfsd_change_deleg_cb(struct file_lock **onlist, int arg)
 }
 
 static const struct lock_manager_operations nfsd_lease_mng_ops = {
-	.fl_break = nfsd_break_deleg_cb,
-	.fl_change = nfsd_change_deleg_cb,
+	.lm_break = nfsd_break_deleg_cb,
+	.lm_change = nfsd_change_deleg_cb,
 };
 
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index b5b9792..cf719be 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1069,12 +1069,12 @@ struct file_lock_operations {
 };
 
 struct lock_manager_operations {
-	int (*fl_compare_owner)(struct file_lock *, struct file_lock *);
-	void (*fl_notify)(struct file_lock *);	/* unblock callback */
-	int (*fl_grant)(struct file_lock *, struct file_lock *, int);
-	void (*fl_release_private)(struct file_lock *);
-	void (*fl_break)(struct file_lock *);
-	int (*fl_change)(struct file_lock **, int);
+	int (*lm_compare_owner)(struct file_lock *, struct file_lock *);
+	void (*lm_notify)(struct file_lock *);	/* unblock callback */
+	int (*lm_grant)(struct file_lock *, struct file_lock *, int);
+	void (*lm_release_private)(struct file_lock *);
+	void (*lm_break)(struct file_lock *);
+	int (*lm_change)(struct file_lock **, int);
 };
 
 struct lock_manager {
-- 
1.7.4.1


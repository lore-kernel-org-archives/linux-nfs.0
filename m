Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:28775 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752248Ab3FQPOf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Jun 2013 11:14:35 -0400
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk, matthew@wil.cx, bfields@fieldses.org
Cc: dhowells@redhat.com, sage@inktank.com, smfrench@gmail.com,
        swhiteho@redhat.com, Trond.Myklebust@netapp.com,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, piastryyy@gmail.com
Subject: [PATCH v3 06/13] locks: protect most of the file_lock handling with i_lock
Date: Mon, 17 Jun 2013 11:13:49 -0400
Message-Id: <1371482036-15958-7-git-send-email-jlayton@redhat.com>
In-Reply-To: <1371482036-15958-1-git-send-email-jlayton@redhat.com>
References: <1371482036-15958-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Having a global lock that protects all of this code is a clear
scalability problem. Instead of doing that, move most of the code to be
protected by the i_lock instead. The exceptions are the global lists
that the ->fl_link sits on, and the ->fl_block list.

->fl_link is what connects these structures to the
global lists, so we must ensure that we hold those locks when iterating
over or updating these lists.

Furthermore, sound deadlock detection requires that we hold the
blocked_list state steady while checking for loops. We also must ensure
that the search and update to the list are atomic.

For the checking and insertion side of the blocked_list, push the
acquisition of the global lock into __posix_lock_file and ensure that
checking and update of the  blocked_list is done without dropping the
lock in between.

On the removal side, when waking up blocked lock waiters, take the
global lock before walking the blocked list and dequeue the waiters from
the global list prior to removal from the fl_block list.

With this, deadlock detection should be race free while we minimize
excessive file_lock_lock thrashing.

Finally, in order to avoid a lock inversion problem when handling
/proc/locks output we must ensure that manipulations of the fl_block
list are also protected by the file_lock_lock.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 Documentation/filesystems/Locking |   21 ++++--
 fs/afs/flock.c                    |    5 +-
 fs/ceph/locks.c                   |    2 +-
 fs/ceph/mds_client.c              |    8 +-
 fs/cifs/cifsfs.c                  |    2 +-
 fs/cifs/file.c                    |   13 ++--
 fs/gfs2/file.c                    |    2 +-
 fs/lockd/svcsubs.c                |   12 ++--
 fs/locks.c                        |  151 ++++++++++++++++++++++---------------
 fs/nfs/delegation.c               |   10 +-
 fs/nfs/nfs4state.c                |    8 +-
 fs/nfsd/nfs4state.c               |    8 +-
 include/linux/fs.h                |   11 ---
 13 files changed, 140 insertions(+), 113 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index 0706d32..413685f 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -344,7 +344,7 @@ prototypes:
 
 
 locking rules:
-			file_lock_lock	may block
+			inode->i_lock	may block
 fl_copy_lock:		yes		no
 fl_release_private:	maybe		no
 
@@ -357,12 +357,19 @@ prototypes:
 	int (*lm_change)(struct file_lock **, int);
 
 locking rules:
-			file_lock_lock	may block
-lm_compare_owner:	yes		no
-lm_notify:		yes		no
-lm_grant:		no		no
-lm_break:		yes		no
-lm_change		yes		no
+
+			inode->i_lock	file_lock_lock	may block
+lm_compare_owner:	yes[1]		maybe		no
+lm_notify:		yes		yes		no
+lm_grant:		no		no		no
+lm_break:		yes		no		no
+lm_change		yes		no		no
+
+[1]:	->lm_compare_owner is generally called with *an* inode->i_lock held. It
+may not be the i_lock of the inode for either file_lock being compared! This is
+the case with deadlock detection, since the code has to chase down the owners
+of locks that may be entirely unrelated to the one on which the lock is being
+acquired. When doing a search for deadlocks, the file_lock_lock is also held.
 
 --------------------------- buffer_head -----------------------------------
 prototypes:
diff --git a/fs/afs/flock.c b/fs/afs/flock.c
index 2497bf3..03fc0d1 100644
--- a/fs/afs/flock.c
+++ b/fs/afs/flock.c
@@ -252,6 +252,7 @@ static void afs_defer_unlock(struct afs_vnode *vnode, struct key *key)
  */
 static int afs_do_setlk(struct file *file, struct file_lock *fl)
 {
+	struct inode = file_inode(file);
 	struct afs_vnode *vnode = AFS_FS_I(file->f_mapping->host);
 	afs_lock_type_t type;
 	struct key *key = file->private_data;
@@ -273,7 +274,7 @@ static int afs_do_setlk(struct file *file, struct file_lock *fl)
 
 	type = (fl->fl_type == F_RDLCK) ? AFS_LOCK_READ : AFS_LOCK_WRITE;
 
-	lock_flocks();
+	spin_lock(&inode->i_lock);
 
 	/* make sure we've got a callback on this file and that our view of the
 	 * data version is up to date */
@@ -420,7 +421,7 @@ given_lock:
 	afs_vnode_fetch_status(vnode, NULL, key);
 
 error:
-	unlock_flocks();
+	spin_unlock(&inode->i_lock);
 	_leave(" = %d", ret);
 	return ret;
 
diff --git a/fs/ceph/locks.c b/fs/ceph/locks.c
index ebbf680..690f73f 100644
--- a/fs/ceph/locks.c
+++ b/fs/ceph/locks.c
@@ -192,7 +192,7 @@ void ceph_count_locks(struct inode *inode, int *fcntl_count, int *flock_count)
 
 /**
  * Encode the flock and fcntl locks for the given inode into the ceph_filelock
- * array. Must be called with lock_flocks() already held.
+ * array. Must be called with inode->i_lock already held.
  * If we encounter more of a specific lock type than expected, return -ENOSPC.
  */
 int ceph_encode_locks_to_buffer(struct inode *inode,
diff --git a/fs/ceph/mds_client.c b/fs/ceph/mds_client.c
index 4d29203..74fd289 100644
--- a/fs/ceph/mds_client.c
+++ b/fs/ceph/mds_client.c
@@ -2481,20 +2481,20 @@ static int encode_caps_cb(struct inode *inode, struct ceph_cap *cap,
 		struct ceph_filelock *flocks;
 
 encode_again:
-		lock_flocks();
+		spin_lock(&inode->i_lock);
 		ceph_count_locks(inode, &num_fcntl_locks, &num_flock_locks);
-		unlock_flocks();
+		spin_unlock(&inode->i_lock);
 		flocks = kmalloc((num_fcntl_locks+num_flock_locks) *
 				 sizeof(struct ceph_filelock), GFP_NOFS);
 		if (!flocks) {
 			err = -ENOMEM;
 			goto out_free;
 		}
-		lock_flocks();
+		spin_lock(&inode->i_lock);
 		err = ceph_encode_locks_to_buffer(inode, flocks,
 						  num_fcntl_locks,
 						  num_flock_locks);
-		unlock_flocks();
+		spin_unlock(&inode->i_lock);
 		if (err) {
 			kfree(flocks);
 			if (err == -ENOSPC)
diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index 3752b9f..e81655c 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -765,7 +765,7 @@ static loff_t cifs_llseek(struct file *file, loff_t offset, int whence)
 
 static int cifs_setlease(struct file *file, long arg, struct file_lock **lease)
 {
-	/* note that this is called by vfs setlease with lock_flocks held
+	/* note that this is called by vfs setlease with i_lock held
 	   to protect *lease from going away */
 	struct inode *inode = file_inode(file);
 	struct cifsFileInfo *cfile = file->private_data;
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 44a4f18..0dd10cd 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -1092,6 +1092,7 @@ struct lock_to_push {
 static int
 cifs_push_posix_locks(struct cifsFileInfo *cfile)
 {
+	struct inode *inode = cfile->dentry->d_inode;
 	struct cifs_tcon *tcon = tlink_tcon(cfile->tlink);
 	struct file_lock *flock, **before;
 	unsigned int count = 0, i = 0;
@@ -1102,12 +1103,12 @@ cifs_push_posix_locks(struct cifsFileInfo *cfile)
 
 	xid = get_xid();
 
-	lock_flocks();
-	cifs_for_each_lock(cfile->dentry->d_inode, before) {
+	spin_lock(&inode->i_lock);
+	cifs_for_each_lock(inode, before) {
 		if ((*before)->fl_flags & FL_POSIX)
 			count++;
 	}
-	unlock_flocks();
+	spin_unlock(&inode->i_lock);
 
 	INIT_LIST_HEAD(&locks_to_send);
 
@@ -1126,8 +1127,8 @@ cifs_push_posix_locks(struct cifsFileInfo *cfile)
 	}
 
 	el = locks_to_send.next;
-	lock_flocks();
-	cifs_for_each_lock(cfile->dentry->d_inode, before) {
+	spin_lock(&inode->i_lock);
+	cifs_for_each_lock(inode, before) {
 		flock = *before;
 		if ((flock->fl_flags & FL_POSIX) == 0)
 			continue;
@@ -1152,7 +1153,7 @@ cifs_push_posix_locks(struct cifsFileInfo *cfile)
 		lck->offset = flock->fl_start;
 		el = el->next;
 	}
-	unlock_flocks();
+	spin_unlock(&inode->i_lock);
 
 	list_for_each_entry_safe(lck, tmp, &locks_to_send, llist) {
 		int stored_rc;
diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
index ad0dc38..2398b41 100644
--- a/fs/gfs2/file.c
+++ b/fs/gfs2/file.c
@@ -896,7 +896,7 @@ out_uninit:
  * cluster; until we do, disable leases (by just returning -EINVAL),
  * unless the administrator has requested purely local locking.
  *
- * Locking: called under lock_flocks
+ * Locking: called under i_lock
  *
  * Returns: errno
  */
diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
index 97e8741..dc5c759 100644
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -169,7 +169,7 @@ nlm_traverse_locks(struct nlm_host *host, struct nlm_file *file,
 
 again:
 	file->f_locks = 0;
-	lock_flocks(); /* protects i_flock list */
+	spin_lock(&inode->i_lock);
 	for (fl = inode->i_flock; fl; fl = fl->fl_next) {
 		if (fl->fl_lmops != &nlmsvc_lock_operations)
 			continue;
@@ -181,7 +181,7 @@ again:
 		if (match(lockhost, host)) {
 			struct file_lock lock = *fl;
 
-			unlock_flocks();
+			spin_unlock(&inode->i_lock);
 			lock.fl_type  = F_UNLCK;
 			lock.fl_start = 0;
 			lock.fl_end   = OFFSET_MAX;
@@ -193,7 +193,7 @@ again:
 			goto again;
 		}
 	}
-	unlock_flocks();
+	spin_unlock(&inode->i_lock);
 
 	return 0;
 }
@@ -228,14 +228,14 @@ nlm_file_inuse(struct nlm_file *file)
 	if (file->f_count || !list_empty(&file->f_blocks) || file->f_shares)
 		return 1;
 
-	lock_flocks();
+	spin_lock(&inode->i_lock);
 	for (fl = inode->i_flock; fl; fl = fl->fl_next) {
 		if (fl->fl_lmops == &nlmsvc_lock_operations) {
-			unlock_flocks();
+			spin_unlock(&inode->i_lock);
 			return 1;
 		}
 	}
-	unlock_flocks();
+	spin_unlock(&inode->i_lock);
 	file->f_locks = 0;
 	return 0;
 }
diff --git a/fs/locks.c b/fs/locks.c
index c0e613f..8f56651 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -153,27 +153,21 @@ int lease_break_time = 45;
 #define for_each_lock(inode, lockp) \
 	for (lockp = &inode->i_flock; *lockp != NULL; lockp = &(*lockp)->fl_next)
 
-/* The global file_lock_list is only used for displaying /proc/locks. */
+/*
+ * The global file_lock_list is only used for displaying /proc/locks. Protected
+ * by the file_lock_lock.
+ */
 static LIST_HEAD(file_lock_list);
 
-/* The blocked_list is used to find POSIX lock loops for deadlock detection. */
+/*
+ * The blocked_list is used to find POSIX lock loops for deadlock detection.
+ * Protected by file_lock_lock.
+ */
 static LIST_HEAD(blocked_list);
 
-/* Protects the two list heads above, plus the inode->i_flock list */
+/* Protects the two list heads above, and fl->fl_block list. */
 static DEFINE_SPINLOCK(file_lock_lock);
 
-void lock_flocks(void)
-{
-	spin_lock(&file_lock_lock);
-}
-EXPORT_SYMBOL_GPL(lock_flocks);
-
-void unlock_flocks(void)
-{
-	spin_unlock(&file_lock_lock);
-}
-EXPORT_SYMBOL_GPL(unlock_flocks);
-
 static struct kmem_cache *filelock_cache __read_mostly;
 
 static void locks_init_lock_heads(struct file_lock *fl)
@@ -489,13 +483,17 @@ static int posix_same_owner(struct file_lock *fl1, struct file_lock *fl2)
 static inline void
 locks_insert_global_locks(struct file_lock *waiter)
 {
+	spin_lock(&file_lock_lock);
 	list_add_tail(&waiter->fl_link, &file_lock_list);
+	spin_unlock(&file_lock_lock);
 }
 
 static inline void
 locks_delete_global_locks(struct file_lock *waiter)
 {
+	spin_lock(&file_lock_lock);
 	list_del_init(&waiter->fl_link);
+	spin_unlock(&file_lock_lock);
 }
 
 static inline void
@@ -512,6 +510,8 @@ locks_delete_global_blocked(struct file_lock *waiter)
 
 /* Remove waiter from blocker's block list.
  * When blocker ends up pointing to itself then the list is empty.
+ *
+ * Must be called with file_lock_lock held.
  */
 static void __locks_delete_block(struct file_lock *waiter)
 {
@@ -520,37 +520,47 @@ static void __locks_delete_block(struct file_lock *waiter)
 	waiter->fl_next = NULL;
 }
 
-/*
- */
 static void locks_delete_block(struct file_lock *waiter)
 {
-	lock_flocks();
+	spin_lock(&file_lock_lock);
 	__locks_delete_block(waiter);
-	unlock_flocks();
+	spin_unlock(&file_lock_lock);
 }
 
 /* Insert waiter into blocker's block list.
  * We use a circular list so that processes can be easily woken up in
  * the order they blocked. The documentation doesn't require this but
  * it seems like the reasonable thing to do.
+ *
+ * Must be called with file_lock_lock held!
  */
-static void locks_insert_block(struct file_lock *blocker, 
-			       struct file_lock *waiter)
+static void __locks_insert_block(struct file_lock *blocker,
+					struct file_lock *waiter)
 {
 	BUG_ON(!list_empty(&waiter->fl_block));
 	waiter->fl_next = blocker;
 	list_add_tail(&waiter->fl_block, &blocker->fl_block);
 	if (IS_POSIX(blocker))
-		locks_insert_global_blocked(request);
+		locks_insert_global_blocked(waiter);
+}
+
+/* Must be called with i_lock held. */
+static void locks_insert_block(struct file_lock *blocker,
+					struct file_lock *waiter)
+{
+	spin_lock(&file_lock_lock);
+	__locks_insert_block(blocker, waiter);
+	spin_unlock(&file_lock_lock);
 }
 
 /*
  * Wake up processes blocked waiting for blocker.
  *
- * Must be called with the file_lock_lock held!
+ * Must be called with the inode->i_lock held!
  */
 static void locks_wake_up_blocks(struct file_lock *blocker)
 {
+	spin_lock(&file_lock_lock);
 	while (!list_empty(&blocker->fl_block)) {
 		struct file_lock *waiter;
 
@@ -562,10 +572,13 @@ static void locks_wake_up_blocks(struct file_lock *blocker)
 		else
 			wake_up(&waiter->fl_wait);
 	}
+	spin_unlock(&file_lock_lock);
 }
 
 /* Insert file lock fl into an inode's lock list at the position indicated
  * by pos. At the same time add the lock to the global file lock list.
+ *
+ * Must be called with the i_lock held!
  */
 static void locks_insert_lock(struct file_lock **pos, struct file_lock *fl)
 {
@@ -583,6 +596,8 @@ static void locks_insert_lock(struct file_lock **pos, struct file_lock *fl)
  * Wake up processes that are blocked waiting for this lock,
  * notify the FS that the lock has been cleared and
  * finally free the lock.
+ *
+ * Must be called with the i_lock held!
  */
 static void locks_delete_lock(struct file_lock **thisfl_p)
 {
@@ -652,8 +667,9 @@ void
 posix_test_lock(struct file *filp, struct file_lock *fl)
 {
 	struct file_lock *cfl;
+	struct inode *inode = file_inode(filp);
 
-	lock_flocks();
+	spin_lock(&inode->i_lock);
 	for (cfl = file_inode(filp)->i_flock; cfl; cfl = cfl->fl_next) {
 		if (!IS_POSIX(cfl))
 			continue;
@@ -666,7 +682,7 @@ posix_test_lock(struct file *filp, struct file_lock *fl)
 			fl->fl_pid = pid_vnr(cfl->fl_nspid);
 	} else
 		fl->fl_type = F_UNLCK;
-	unlock_flocks();
+	spin_unlock(&inode->i_lock);
 	return;
 }
 EXPORT_SYMBOL(posix_test_lock);
@@ -710,6 +726,7 @@ static struct file_lock *what_owner_is_waiting_for(struct file_lock *block_fl)
 	return NULL;
 }
 
+/* Must be called with the file_lock_lock held! */
 static int posix_locks_deadlock(struct file_lock *caller_fl,
 				struct file_lock *block_fl)
 {
@@ -745,7 +762,7 @@ static int flock_lock_file(struct file *filp, struct file_lock *request)
 			return -ENOMEM;
 	}
 
-	lock_flocks();
+	spin_lock(&inode->i_lock);
 	if (request->fl_flags & FL_ACCESS)
 		goto find_conflict;
 
@@ -775,9 +792,9 @@ static int flock_lock_file(struct file *filp, struct file_lock *request)
 	 * give it the opportunity to lock the file.
 	 */
 	if (found) {
-		unlock_flocks();
+		spin_unlock(&inode->i_lock);
 		cond_resched();
-		lock_flocks();
+		spin_lock(&inode->i_lock);
 	}
 
 find_conflict:
@@ -804,7 +821,7 @@ find_conflict:
 	error = 0;
 
 out:
-	unlock_flocks();
+	spin_unlock(&inode->i_lock);
 	if (new_fl)
 		locks_free_lock(new_fl);
 	return error;
@@ -834,7 +851,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 		new_fl2 = locks_alloc_lock();
 	}
 
-	lock_flocks();
+	spin_lock(&inode->i_lock);
 	/*
 	 * New lock request. Walk all POSIX locks and look for conflicts. If
 	 * there are any, either return error or put the request on the
@@ -852,11 +869,17 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 			error = -EAGAIN;
 			if (!(request->fl_flags & FL_SLEEP))
 				goto out;
+			/*
+			 * Deadlock detection and insertion into the blocked
+			 * locks list must be done while holding the same lock!
+			 */
 			error = -EDEADLK;
-			if (posix_locks_deadlock(request, fl))
-				goto out;
-			error = FILE_LOCK_DEFERRED;
-			locks_insert_block(fl, request);
+			spin_lock(&file_lock_lock);
+			if (likely(!posix_locks_deadlock(request, fl))) {
+				error = FILE_LOCK_DEFERRED;
+				__locks_insert_block(fl, request);
+			}
+			spin_unlock(&file_lock_lock);
 			goto out;
   		}
   	}
@@ -1006,7 +1029,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 		locks_wake_up_blocks(left);
 	}
  out:
-	unlock_flocks();
+	spin_unlock(&inode->i_lock);
 	/*
 	 * Free any unused locks.
 	 */
@@ -1081,14 +1104,14 @@ int locks_mandatory_locked(struct inode *inode)
 	/*
 	 * Search the lock list for this inode for any POSIX locks.
 	 */
-	lock_flocks();
+	spin_lock(&inode->i_lock);
 	for (fl = inode->i_flock; fl != NULL; fl = fl->fl_next) {
 		if (!IS_POSIX(fl))
 			continue;
 		if (fl->fl_owner != owner)
 			break;
 	}
-	unlock_flocks();
+	spin_unlock(&inode->i_lock);
 	return fl ? -EAGAIN : 0;
 }
 
@@ -1231,7 +1254,7 @@ int __break_lease(struct inode *inode, unsigned int mode)
 	if (IS_ERR(new_fl))
 		return PTR_ERR(new_fl);
 
-	lock_flocks();
+	spin_lock(&inode->i_lock);
 
 	time_out_leases(inode);
 
@@ -1281,11 +1304,11 @@ restart:
 			break_time++;
 	}
 	locks_insert_block(flock, new_fl);
-	unlock_flocks();
+	spin_unlock(&inode->i_lock);
 	error = wait_event_interruptible_timeout(new_fl->fl_wait,
 						!new_fl->fl_next, break_time);
-	lock_flocks();
-	__locks_delete_block(new_fl);
+	spin_lock(&inode->i_lock);
+	locks_delete_block(new_fl);
 	if (error >= 0) {
 		if (error == 0)
 			time_out_leases(inode);
@@ -1302,7 +1325,7 @@ restart:
 	}
 
 out:
-	unlock_flocks();
+	spin_unlock(&inode->i_lock);
 	locks_free_lock(new_fl);
 	return error;
 }
@@ -1355,9 +1378,10 @@ EXPORT_SYMBOL(lease_get_mtime);
 int fcntl_getlease(struct file *filp)
 {
 	struct file_lock *fl;
+	struct inode *inode = file_inode(filp);
 	int type = F_UNLCK;
 
-	lock_flocks();
+	spin_lock(&inode->i_lock);
 	time_out_leases(file_inode(filp));
 	for (fl = file_inode(filp)->i_flock; fl && IS_LEASE(fl);
 			fl = fl->fl_next) {
@@ -1366,7 +1390,7 @@ int fcntl_getlease(struct file *filp)
 			break;
 		}
 	}
-	unlock_flocks();
+	spin_unlock(&inode->i_lock);
 	return type;
 }
 
@@ -1460,7 +1484,7 @@ static int generic_delete_lease(struct file *filp, struct file_lock **flp)
  *	The (input) flp->fl_lmops->lm_break function is required
  *	by break_lease().
  *
- *	Called with file_lock_lock held.
+ *	Called with inode->i_lock held.
  */
 int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
 {
@@ -1529,11 +1553,12 @@ static int __vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
 
 int vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
 {
+	struct inode *inode = file_inode(filp);
 	int error;
 
-	lock_flocks();
+	spin_lock(&inode->i_lock);
 	error = __vfs_setlease(filp, arg, lease);
-	unlock_flocks();
+	spin_unlock(&inode->i_lock);
 
 	return error;
 }
@@ -1551,6 +1576,7 @@ static int do_fcntl_delete_lease(struct file *filp)
 static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
 {
 	struct file_lock *fl, *ret;
+	struct inode *inode = file_inode(filp);
 	struct fasync_struct *new;
 	int error;
 
@@ -1564,10 +1590,10 @@ static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
 		return -ENOMEM;
 	}
 	ret = fl;
-	lock_flocks();
+	spin_lock(&inode->i_lock);
 	error = __vfs_setlease(filp, arg, &ret);
 	if (error) {
-		unlock_flocks();
+		spin_unlock(&inode->i_lock);
 		locks_free_lock(fl);
 		goto out_free_fasync;
 	}
@@ -1584,7 +1610,7 @@ static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
 		new = NULL;
 
 	error = __f_setown(filp, task_pid(current), PIDTYPE_PID, 0);
-	unlock_flocks();
+	spin_unlock(&inode->i_lock);
 
 out_free_fasync:
 	if (new)
@@ -2108,7 +2134,7 @@ void locks_remove_flock(struct file *filp)
 			fl.fl_ops->fl_release_private(&fl);
 	}
 
-	lock_flocks();
+	spin_lock(&inode->i_lock);
 	before = &inode->i_flock;
 
 	while ((fl = *before) != NULL) {
@@ -2126,7 +2152,7 @@ void locks_remove_flock(struct file *filp)
  		}
 		before = &fl->fl_next;
 	}
-	unlock_flocks();
+	spin_unlock(&inode->i_lock);
 }
 
 /**
@@ -2139,14 +2165,15 @@ void locks_remove_flock(struct file *filp)
 int
 posix_unblock_lock(struct file *filp, struct file_lock *waiter)
 {
+	struct inode *inode = file_inode(filp);
 	int status = 0;
 
-	lock_flocks();
+	spin_lock(&inode->i_lock);
 	if (waiter->fl_next)
-		__locks_delete_block(waiter);
+		locks_delete_block(waiter);
 	else
 		status = -ENOENT;
-	unlock_flocks();
+	spin_unlock(&inode->i_lock);
 	return status;
 }
 
@@ -2261,7 +2288,7 @@ static void *locks_start(struct seq_file *f, loff_t *pos)
 {
 	loff_t *p = f->private;
 
-	lock_flocks();
+	spin_lock(&file_lock_lock);
 	*p = (*pos + 1);
 	return seq_list_start(&file_lock_list, *pos);
 }
@@ -2275,7 +2302,7 @@ static void *locks_next(struct seq_file *f, void *v, loff_t *pos)
 
 static void locks_stop(struct seq_file *f, void *v)
 {
-	unlock_flocks();
+	spin_unlock(&file_lock_lock);
 }
 
 static const struct seq_operations locks_seq_operations = {
@@ -2322,7 +2349,8 @@ int lock_may_read(struct inode *inode, loff_t start, unsigned long len)
 {
 	struct file_lock *fl;
 	int result = 1;
-	lock_flocks();
+
+	spin_lock(&inode->i_lock);
 	for (fl = inode->i_flock; fl != NULL; fl = fl->fl_next) {
 		if (IS_POSIX(fl)) {
 			if (fl->fl_type == F_RDLCK)
@@ -2339,7 +2367,7 @@ int lock_may_read(struct inode *inode, loff_t start, unsigned long len)
 		result = 0;
 		break;
 	}
-	unlock_flocks();
+	spin_unlock(&inode->i_lock);
 	return result;
 }
 
@@ -2362,7 +2390,8 @@ int lock_may_write(struct inode *inode, loff_t start, unsigned long len)
 {
 	struct file_lock *fl;
 	int result = 1;
-	lock_flocks();
+
+	spin_lock(&inode->i_lock);
 	for (fl = inode->i_flock; fl != NULL; fl = fl->fl_next) {
 		if (IS_POSIX(fl)) {
 			if ((fl->fl_end < start) || (fl->fl_start > (start + len)))
@@ -2377,7 +2406,7 @@ int lock_may_write(struct inode *inode, loff_t start, unsigned long len)
 		result = 0;
 		break;
 	}
-	unlock_flocks();
+	spin_unlock(&inode->i_lock);
 	return result;
 }
 
diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 57db324..7ec4814 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -73,20 +73,20 @@ static int nfs_delegation_claim_locks(struct nfs_open_context *ctx, struct nfs4_
 	if (inode->i_flock == NULL)
 		goto out;
 
-	/* Protect inode->i_flock using the file locks lock */
-	lock_flocks();
+	/* Protect inode->i_flock using the i_lock */
+	spin_lock(&inode->i_lock);
 	for (fl = inode->i_flock; fl != NULL; fl = fl->fl_next) {
 		if (!(fl->fl_flags & (FL_POSIX|FL_FLOCK)))
 			continue;
 		if (nfs_file_open_context(fl->fl_file) != ctx)
 			continue;
-		unlock_flocks();
+		spin_unlock(&inode->i_lock);
 		status = nfs4_lock_delegation_recall(fl, state, stateid);
 		if (status < 0)
 			goto out;
-		lock_flocks();
+		spin_lock(&inode->i_lock);
 	}
-	unlock_flocks();
+	spin_unlock(&inode->i_lock);
 out:
 	return status;
 }
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 1fab140..ff10b4a 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1373,13 +1373,13 @@ static int nfs4_reclaim_locks(struct nfs4_state *state, const struct nfs4_state_
 	/* Guard against delegation returns and new lock/unlock calls */
 	down_write(&nfsi->rwsem);
 	/* Protect inode->i_flock using the BKL */
-	lock_flocks();
+	spin_lock(&inode->i_lock);
 	for (fl = inode->i_flock; fl != NULL; fl = fl->fl_next) {
 		if (!(fl->fl_flags & (FL_POSIX|FL_FLOCK)))
 			continue;
 		if (nfs_file_open_context(fl->fl_file)->state != state)
 			continue;
-		unlock_flocks();
+		spin_unlock(&inode->i_lock);
 		status = ops->recover_lock(state, fl);
 		switch (status) {
 			case 0:
@@ -1406,9 +1406,9 @@ static int nfs4_reclaim_locks(struct nfs4_state *state, const struct nfs4_state_
 				/* kill_proc(fl->fl_pid, SIGLOST, 1); */
 				status = 0;
 		}
-		lock_flocks();
+		spin_lock(&inode->i_lock);
 	}
-	unlock_flocks();
+	spin_unlock(&inode->i_lock);
 out:
 	up_write(&nfsi->rwsem);
 	return status;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 316ec84..f170518 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2645,13 +2645,13 @@ static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
 
 	list_add_tail(&dp->dl_recall_lru, &nn->del_recall_lru);
 
-	/* only place dl_time is set. protected by lock_flocks*/
+	/* Only place dl_time is set; protected by i_lock: */
 	dp->dl_time = get_seconds();
 
 	nfsd4_cb_recall(dp);
 }
 
-/* Called from break_lease() with lock_flocks() held. */
+/* Called from break_lease() with i_lock held. */
 static void nfsd_break_deleg_cb(struct file_lock *fl)
 {
 	struct nfs4_file *fp = (struct nfs4_file *)fl->fl_owner;
@@ -4520,7 +4520,7 @@ check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner)
 	struct inode *inode = filp->fi_inode;
 	int status = 0;
 
-	lock_flocks();
+	spin_lock(&inode->i_lock);
 	for (flpp = &inode->i_flock; *flpp != NULL; flpp = &(*flpp)->fl_next) {
 		if ((*flpp)->fl_owner == (fl_owner_t)lowner) {
 			status = 1;
@@ -4528,7 +4528,7 @@ check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner)
 		}
 	}
 out:
-	unlock_flocks();
+	spin_unlock(&inode->i_lock);
 	return status;
 }
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 94105d2..e2f896d 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1024,8 +1024,6 @@ extern int vfs_setlease(struct file *, long, struct file_lock **);
 extern int lease_modify(struct file_lock **, int);
 extern int lock_may_read(struct inode *, loff_t start, unsigned long count);
 extern int lock_may_write(struct inode *, loff_t start, unsigned long count);
-extern void lock_flocks(void);
-extern void unlock_flocks(void);
 #else /* !CONFIG_FILE_LOCKING */
 static inline int fcntl_getlk(struct file *file, struct flock __user *user)
 {
@@ -1167,15 +1165,6 @@ static inline int lock_may_write(struct inode *inode, loff_t start,
 {
 	return 1;
 }
-
-static inline void lock_flocks(void)
-{
-}
-
-static inline void unlock_flocks(void)
-{
-}
-
 #endif /* !CONFIG_FILE_LOCKING */
 
 
-- 
1.7.1


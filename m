Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46664 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755918AbdERQCZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 May 2017 12:02:25 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
        Jeff Layton <jlayton@poochiereds.net>, bfields@fieldses.org
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH] locks: Set fl_nspid at file_lock allocation
Date: Thu, 18 May 2017 12:02:22 -0400
Message-Id: <896e8ca302614f71f3030015ebf3befe2b40d3c4.1495122972.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since commit c69899a17ca4 "NFSv4: Update of VFS byte range lock must be
atomic with the stateid update", NFSv4 has been inserting locks in rpciod
worker context.  The result is that the file_lock's fl_nspid is the
kworker's pid instead of the original userspace pid.  We can fix that up by
setting fl_nspid in locks_allocate_lock, and tranfer it to the file_lock
that's eventually recorded.

Also, let's set fl_nspid directly in a few places it is stored on the
stack.  The use of fl_pid is retained for lock managers that do not set
fl_nspid and instead wish to use and record private fl_pid numbers.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/locks.c | 44 ++++++++++++++++++++++++++------------------
 1 file changed, 26 insertions(+), 18 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index af2031a1fcff..959b3f93f4bd 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -249,7 +249,7 @@ locks_dump_ctx_list(struct list_head *list, char *list_type)
 	struct file_lock *fl;
 
 	list_for_each_entry(fl, list, fl_list) {
-		pr_warn("%s: fl_owner=%p fl_flags=0x%x fl_type=0x%x fl_pid=%u\n", list_type, fl->fl_owner, fl->fl_flags, fl->fl_type, fl->fl_pid);
+		pr_warn("%s: fl_owner=%p fl_flags=0x%x fl_type=0x%x fl_pid=%u\n", list_type, fl->fl_owner, fl->fl_flags, fl->fl_type, pid_vnr(fl->fl_nspid));
 	}
 }
 
@@ -294,8 +294,10 @@ struct file_lock *locks_alloc_lock(void)
 {
 	struct file_lock *fl = kmem_cache_zalloc(filelock_cache, GFP_KERNEL);
 
-	if (fl)
+	if (fl) {
 		locks_init_lock_heads(fl);
+		fl->fl_nspid = get_pid(task_tgid(current));
+	}
 
 	return fl;
 }
@@ -328,6 +330,8 @@ void locks_free_lock(struct file_lock *fl)
 	BUG_ON(!hlist_unhashed(&fl->fl_link));
 
 	locks_release_private(fl);
+	if (fl->fl_nspid)
+		put_pid(fl->fl_nspid);
 	kmem_cache_free(filelock_cache, fl);
 }
 EXPORT_SYMBOL(locks_free_lock);
@@ -357,8 +361,15 @@ EXPORT_SYMBOL(locks_init_lock);
  */
 void locks_copy_conflock(struct file_lock *new, struct file_lock *fl)
 {
+	struct pid *replace_pid = new->fl_nspid;
+
 	new->fl_owner = fl->fl_owner;
 	new->fl_pid = fl->fl_pid;
+	if (fl->fl_nspid) {
+		new->fl_nspid = get_pid(fl->fl_nspid);
+		if (replace_pid)
+			put_pid(replace_pid);
+	}
 	new->fl_file = NULL;
 	new->fl_flags = fl->fl_flags;
 	new->fl_type = fl->fl_type;
@@ -422,7 +433,6 @@ flock_make_lock(struct file *filp, unsigned int cmd)
 
 	fl->fl_file = filp;
 	fl->fl_owner = filp;
-	fl->fl_pid = current->tgid;
 	fl->fl_flags = FL_FLOCK;
 	fl->fl_type = type;
 	fl->fl_end = OFFSET_MAX;
@@ -482,7 +492,6 @@ static int flock64_to_posix_lock(struct file *filp, struct file_lock *fl,
 		fl->fl_end = OFFSET_MAX;
 
 	fl->fl_owner = current->files;
-	fl->fl_pid = current->tgid;
 	fl->fl_file = filp;
 	fl->fl_flags = FL_POSIX;
 	fl->fl_ops = NULL;
@@ -547,8 +556,6 @@ static int lease_init(struct file *filp, long type, struct file_lock *fl)
 		return -EINVAL;
 
 	fl->fl_owner = filp;
-	fl->fl_pid = current->tgid;
-
 	fl->fl_file = filp;
 	fl->fl_flags = FL_LEASE;
 	fl->fl_start = 0;
@@ -733,7 +740,6 @@ static void locks_wake_up_blocks(struct file_lock *blocker)
 static void
 locks_insert_lock_ctx(struct file_lock *fl, struct list_head *before)
 {
-	fl->fl_nspid = get_pid(task_tgid(current));
 	list_add_tail(&fl->fl_list, before);
 	locks_insert_global_locks(fl);
 }
@@ -743,10 +749,6 @@ locks_unlink_lock_ctx(struct file_lock *fl)
 {
 	locks_delete_global_locks(fl);
 	list_del_init(&fl->fl_list);
-	if (fl->fl_nspid) {
-		put_pid(fl->fl_nspid);
-		fl->fl_nspid = NULL;
-	}
 	locks_wake_up_blocks(fl);
 }
 
@@ -823,8 +825,6 @@ posix_test_lock(struct file *filp, struct file_lock *fl)
 	list_for_each_entry(cfl, &ctx->flc_posix, fl_list) {
 		if (posix_locks_conflict(fl, cfl)) {
 			locks_copy_conflock(fl, cfl);
-			if (cfl->fl_nspid)
-				fl->fl_pid = pid_vnr(cfl->fl_nspid);
 			goto out;
 		}
 	}
@@ -1298,7 +1298,7 @@ int locks_mandatory_area(struct inode *inode, struct file *filp, loff_t start,
 	bool sleep = false;
 
 	locks_init_lock(&fl);
-	fl.fl_pid = current->tgid;
+	fl.fl_nspid = get_pid(task_tgid(current));
 	fl.fl_file = filp;
 	fl.fl_flags = FL_POSIX | FL_ACCESS;
 	if (filp && !(filp->f_flags & O_NONBLOCK))
@@ -1336,6 +1336,7 @@ int locks_mandatory_area(struct inode *inode, struct file *filp, loff_t start,
 		break;
 	}
 
+	put_pid(fl.fl_nspid);
 	return error;
 }
 
@@ -2052,7 +2053,7 @@ EXPORT_SYMBOL_GPL(vfs_test_lock);
 
 static int posix_lock_to_flock(struct flock *flock, struct file_lock *fl)
 {
-	flock->l_pid = IS_OFDLCK(fl) ? -1 : fl->fl_pid;
+	flock->l_pid = IS_OFDLCK(fl) ? -1 : pid_vnr(fl->fl_nspid);
 #if BITS_PER_LONG == 32
 	/*
 	 * Make sure we can represent the posix lock via
@@ -2074,7 +2075,7 @@ static int posix_lock_to_flock(struct flock *flock, struct file_lock *fl)
 #if BITS_PER_LONG == 32
 static void posix_lock_to_flock64(struct flock64 *flock, struct file_lock *fl)
 {
-	flock->l_pid = IS_OFDLCK(fl) ? -1 : fl->fl_pid;
+	flock->l_pid = IS_OFDLCK(fl) ? -1 : pid_vnr(fl->fl_nspid);
 	flock->l_start = fl->fl_start;
 	flock->l_len = fl->fl_end == OFFSET_MAX ? 0 :
 		fl->fl_end - fl->fl_start + 1;
@@ -2093,6 +2094,7 @@ int fcntl_getlk(struct file *filp, unsigned int cmd, struct flock __user *l)
 	int error;
 
 	error = -EFAULT;
+	file_lock.fl_nspid = get_pid(task_tgid(current));
 	if (copy_from_user(&flock, l, sizeof(flock)))
 		goto out;
 	error = -EINVAL;
@@ -2129,6 +2131,7 @@ int fcntl_getlk(struct file *filp, unsigned int cmd, struct flock __user *l)
 rel_priv:
 	locks_release_private(&file_lock);
 out:
+	put_pid(file_lock.fl_nspid);
 	return error;
 }
 
@@ -2322,6 +2325,7 @@ int fcntl_getlk64(struct file *filp, unsigned int cmd, struct flock64 __user *l)
 	int error;
 
 	error = -EFAULT;
+	file_lock.fl_nspid = get_pid(task_tgid(current));
 	if (copy_from_user(&flock, l, sizeof(flock)))
 		goto out;
 	error = -EINVAL;
@@ -2356,6 +2360,7 @@ int fcntl_getlk64(struct file *filp, unsigned int cmd, struct flock64 __user *l)
 
 	locks_release_private(&file_lock);
 out:
+	put_pid(file_lock.fl_nspid);
 	return error;
 }
 
@@ -2482,7 +2487,7 @@ void locks_remove_posix(struct file *filp, fl_owner_t owner)
 	lock.fl_start = 0;
 	lock.fl_end = OFFSET_MAX;
 	lock.fl_owner = owner;
-	lock.fl_pid = current->tgid;
+	lock.fl_nspid = get_pid(task_tgid(current));
 	lock.fl_file = filp;
 	lock.fl_ops = NULL;
 	lock.fl_lmops = NULL;
@@ -2491,6 +2496,7 @@ void locks_remove_posix(struct file *filp, fl_owner_t owner)
 
 	if (lock.fl_ops && lock.fl_ops->fl_release_private)
 		lock.fl_ops->fl_release_private(&lock);
+	put_pid(lock.fl_nspid);
 	trace_locks_remove_posix(inode, &lock, error);
 }
 
@@ -2502,7 +2508,6 @@ locks_remove_flock(struct file *filp, struct file_lock_context *flctx)
 {
 	struct file_lock fl = {
 		.fl_owner = filp,
-		.fl_pid = current->tgid,
 		.fl_file = filp,
 		.fl_flags = FL_FLOCK | FL_CLOSE,
 		.fl_type = F_UNLCK,
@@ -2513,6 +2518,8 @@ locks_remove_flock(struct file *filp, struct file_lock_context *flctx)
 	if (list_empty(&flctx->flc_flock))
 		return;
 
+	fl.fl_nspid = get_pid(task_tgid(current));
+
 	if (filp->f_op->flock && is_remote_lock(filp))
 		filp->f_op->flock(filp, F_SETLKW, &fl);
 	else
@@ -2520,6 +2527,7 @@ locks_remove_flock(struct file *filp, struct file_lock_context *flctx)
 
 	if (fl.fl_ops && fl.fl_ops->fl_release_private)
 		fl.fl_ops->fl_release_private(&fl);
+	put_pid(fl.fl_nspid);
 }
 
 /* The i_flctx must be valid when calling into here */
-- 
2.9.3


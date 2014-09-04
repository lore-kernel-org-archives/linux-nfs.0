Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f177.google.com ([209.85.216.177]:61320 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752354AbaIDMjL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 08:39:11 -0400
Received: by mail-qc0-f177.google.com with SMTP id i8so10037898qcq.8
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2014 05:39:10 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org
Subject: [PATCH v2 09/17] locks: define a lm_setup handler for leases
Date: Thu,  4 Sep 2014 08:38:35 -0400
Message-Id: <1409834323-7171-10-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and move the fasync setup into it for fcntl lease calls. At the same
time, change the semantics of how the file_lock double-pointer is
handled. Up until now, on a successful lease return you got a pointer to
the lock on the list. This is bad, since that pointer can no longer be
relied on as valid once the inode->i_lock has been released.

Change the code to instead just zero out the pointer if the lease we
passed in ended up being used. Then the callers can just check to see
if it's NULL after the call and free it if it isn't.

The priv argument has the same semantics. The lm_setup function can
zero the pointer out to signal to the caller that it should not be
freed after the function returns.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/locks.c          | 92 ++++++++++++++++++++++++++++-------------------------
 fs/nfsd/nfs4state.c |  6 ++--
 include/linux/fs.h  |  1 +
 3 files changed, 51 insertions(+), 48 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 7162a5836dba..a5ed4a1f73ca 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -432,9 +432,27 @@ static void lease_break_callback(struct file_lock *fl)
 	kill_fasync(&fl->fl_fasync, SIGIO, POLL_MSG);
 }
 
+static void
+lease_setup(struct file_lock *fl, void **priv)
+{
+	struct file *filp = fl->fl_file;
+	struct fasync_struct *fa = *priv;
+
+	/*
+	 * fasync_insert_entry() returns the old entry if any. If there was no
+	 * old entry, then it used "priv" and inserted it into the fasync list.
+	 * Clear the pointer to indicate that it shouldn't be freed.
+	 */
+	if (!fasync_insert_entry(fa->fa_fd, filp, &fl->fl_fasync, fa))
+		*priv = NULL;
+
+	__f_setown(filp, task_pid(current), PIDTYPE_PID, 0);
+}
+
 static const struct lock_manager_operations lease_manager_ops = {
 	.lm_break = lease_break_callback,
 	.lm_change = lease_modify,
+	.lm_setup = lease_setup,
 };
 
 /*
@@ -1607,10 +1625,11 @@ generic_add_lease(struct file *filp, long arg, struct file_lock **flp, void **pr
 	}
 
 	if (my_before != NULL) {
+		lease = *my_before;
 		error = lease->fl_lmops->lm_change(my_before, arg);
-		if (!error)
-			*flp = *my_before;
-		goto out;
+		if (error)
+			goto out;
+		goto out_setup;
 	}
 
 	error = -EINVAL;
@@ -1631,9 +1650,15 @@ generic_add_lease(struct file *filp, long arg, struct file_lock **flp, void **pr
 	error = check_conflicting_open(dentry, arg);
 	if (error)
 		goto out_unlink;
+
+out_setup:
+	if (lease->fl_lmops->lm_setup)
+		lease->fl_lmops->lm_setup(lease, priv);
 out:
 	if (is_deleg)
 		mutex_unlock(&inode->i_mutex);
+	if (!error && !my_before)
+		*flp = NULL;
 	return error;
 out_unlink:
 	locks_unlink_lock(before);
@@ -1661,10 +1686,11 @@ static int generic_delete_lease(struct file *filp)
 
 /**
  *	generic_setlease	-	sets a lease on an open file
- *	@filp: file pointer
- *	@arg: type of lease to obtain
- *	@flp: input - file_lock to use, output - file_lock inserted
- *	@priv: private data for lm_setup
+ *	@filp:	file pointer
+ *	@arg:	type of lease to obtain
+ *	@flp:	input - file_lock to use, output - file_lock inserted
+ *	@priv:	private data for lm_setup (may be NULL if lm_setup
+ *		doesn't require it)
  *
  *	The (input) flp->fl_lmops->lm_break function is required
  *	by break_lease().
@@ -1704,29 +1730,23 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp,
 }
 EXPORT_SYMBOL(generic_setlease);
 
-static int
-__vfs_setlease(struct file *filp, long arg, struct file_lock **lease, void **priv)
-{
-	if (filp->f_op->setlease)
-		return filp->f_op->setlease(filp, arg, lease, priv);
-	else
-		return generic_setlease(filp, arg, lease, priv);
-}
-
 /**
  * vfs_setlease        -       sets a lease on an open file
- * @filp: file pointer
- * @arg: type of lease to obtain
- * @lease: file_lock to use when adding a lease
- * @priv: private info for lm_setup when adding a lease
+ * @filp:	file pointer
+ * @arg:	type of lease to obtain
+ * @lease:	file_lock to use when adding a lease
+ * @priv:	private info for lm_setup when adding a lease (may be
+ * 		NULL if lm_setup doesn't require it)
  *
  * Call this to establish a lease on the file. The "lease" argument is not
  * used for F_UNLCK requests and may be NULL. For commands that set or alter
  * an existing lease, the (*lease)->fl_lmops->lm_break operation must be set;
  * if not, this function will return -ENOLCK (and generate a scary-looking
  * stack trace).
+ *
+ * The "priv" pointer is passed directly to the lm_setup function as-is. It
+ * may be NULL if the lm_setup operation doesn't require it.
  */
-
 int
 vfs_setlease(struct file *filp, long arg, struct file_lock **lease, void **priv)
 {
@@ -1734,17 +1754,18 @@ vfs_setlease(struct file *filp, long arg, struct file_lock **lease, void **priv)
 	int error;
 
 	spin_lock(&inode->i_lock);
-	error = __vfs_setlease(filp, arg, lease, priv);
+	if (filp->f_op->setlease)
+		error = filp->f_op->setlease(filp, arg, lease, priv);
+	else
+		error = generic_setlease(filp, arg, lease, priv);
 	spin_unlock(&inode->i_lock);
-
 	return error;
 }
 EXPORT_SYMBOL_GPL(vfs_setlease);
 
 static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
 {
-	struct file_lock *fl, *ret;
-	struct inode *inode = file_inode(filp);
+	struct file_lock *fl;
 	struct fasync_struct *new;
 	int error;
 
@@ -1757,26 +1778,9 @@ static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
 		locks_free_lock(fl);
 		return -ENOMEM;
 	}
-	ret = fl;
-	spin_lock(&inode->i_lock);
-	error = __vfs_setlease(filp, arg, &ret, NULL);
-	if (error)
-		goto out_unlock;
-	if (ret == fl)
-		fl = NULL;
+	new->fa_fd = fd;
 
-	/*
-	 * fasync_insert_entry() returns the old entry if any.
-	 * If there was no old entry, then it used 'new' and
-	 * inserted it into the fasync list. Clear new so that
-	 * we don't release it here.
-	 */
-	if (!fasync_insert_entry(fd, filp, &ret->fl_fasync, new))
-		new = NULL;
-
-	__f_setown(filp, task_pid(current), PIDTYPE_PID, 0);
-out_unlock:
-	spin_unlock(&inode->i_lock);
+	error = vfs_setlease(filp, arg, &fl, (void **)&new);
 	if (fl)
 		locks_free_lock(fl);
 	if (new)
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d964a41c9151..86eebf13b3d0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3789,12 +3789,10 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
 	fl->fl_file = filp;
 	ret = fl;
 	status = vfs_setlease(filp, fl->fl_type, &fl, NULL);
-	if (status) {
+	if (fl)
 		locks_free_lock(fl);
+	if (status)
 		goto out_fput;
-	}
-	if (ret != fl)
-		locks_free_lock(fl);
 	spin_lock(&state_lock);
 	spin_lock(&fp->fi_lock);
 	/* Did the lease get broken before we took the lock? */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f1870eb67b02..9a6d56154dd5 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -874,6 +874,7 @@ struct lock_manager_operations {
 	int (*lm_grant)(struct file_lock *, int);
 	void (*lm_break)(struct file_lock *);
 	int (*lm_change)(struct file_lock **, int);
+	void (*lm_setup)(struct file_lock *, void **);
 };
 
 struct lock_manager {
-- 
1.9.3


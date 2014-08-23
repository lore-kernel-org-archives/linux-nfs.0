Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f43.google.com ([209.85.216.43]:39414 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751724AbaHWOlj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Aug 2014 10:41:39 -0400
Received: by mail-qa0-f43.google.com with SMTP id w8so10819552qac.16
        for <linux-nfs@vger.kernel.org>; Sat, 23 Aug 2014 07:41:38 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: bfields@fieldses.org, hch@infradead.org, cluster-devel@redhat.com,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH 07/10] locks: define a lm_setup handler for leases
Date: Sat, 23 Aug 2014 10:41:15 -0400
Message-Id: <1408804878-1331-8-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
References: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and call it when setting up a new lease or modifying an existing one.
Add a lm_setup handler for fcntl leases and move the fasync setup into
it.

At the same time, change the semantics of how the file_lock double
pointer is handled. Up until now on a successful lease return, you get
back a pointer to the lock on the inode's i_flock list. This is bad,
since that pointer can't be relied on as valid once the inode->i_lock
has been released. Leases also don't carry a lot of information, so
tracking a pointer to it isn't terribly helpful anyway.

Change the code to instead just zero out the pointer if the lease we
passed in ended up being used. Then the callers can just check to see
if it's NULL after the call and free it if it isn't.

The new aux argument for lm_setup has the same semantics. The lm_setup
function can zero the pointer out to signal to the caller that it should
not be freed after the function returns.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/locks.c          | 96 +++++++++++++++++++++++++++++------------------------
 fs/nfsd/nfs4state.c |  9 ++---
 include/linux/fs.h  |  1 +
 3 files changed, 56 insertions(+), 50 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 906e09da115a..b35b706c05fe 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -432,9 +432,32 @@ static void lease_break_callback(struct file_lock *fl)
 	kill_fasync(&fl->fl_fasync, SIGIO, POLL_MSG);
 }
 
+static void
+lease_setup(struct file_lock *fl, void **aux)
+{
+	struct file *filp = fl->fl_file;
+	struct fasync_struct *fa = *aux;
+
+	/*
+	 * fasync_insert_entry() returns the old entry if any. If there was no
+	 * old entry, then it used "aux" and inserted it into the fasync list.
+	 * Clear the pointer to indicate that it shouldn't be freed.
+	 */
+	if (!fasync_insert_entry(fa->fa_fd, filp, &fl->fl_fasync, fa))
+		*aux = NULL;
+
+	/*
+	 * Despite the fact that it's an int return function, __f_setown never
+	 * returns an error. Just ignore any error return here, but spew a
+	 * WARN_ON_ONCE in case this ever changes.
+	 */
+	WARN_ON_ONCE(__f_setown(filp, task_pid(current), PIDTYPE_PID, 0));
+}
+
 static const struct lock_manager_operations lease_manager_ops = {
 	.lm_break = lease_break_callback,
 	.lm_change = lease_modify,
+	.lm_setup = lease_setup,
 };
 
 /*
@@ -1609,9 +1632,9 @@ generic_add_lease(struct file *filp, long arg, struct file_lock **flp, void **au
 	if (my_before != NULL) {
 		lease = *my_before;
 		error = lease->fl_lmops->lm_change(my_before, arg);
-		if (!error)
-			*flp = *my_before;
-		goto out;
+		if (error)
+			goto out;
+		goto out_setup;
 	}
 
 	error = -EINVAL;
@@ -1632,9 +1655,15 @@ generic_add_lease(struct file *filp, long arg, struct file_lock **flp, void **au
 	error = check_conflicting_open(dentry, arg);
 	if (error)
 		goto out_unlink;
+
+out_setup:
+	if (lease->fl_lmops->lm_setup)
+		lease->fl_lmops->lm_setup(lease, aux);
 out:
 	if (is_deleg)
 		mutex_unlock(&inode->i_mutex);
+	if (!error && !my_before)
+		*flp = NULL;
 	return error;
 out_unlink:
 	locks_unlink_lock(before);
@@ -1659,10 +1688,11 @@ static int generic_delete_lease(struct file *filp)
 
 /**
  *	generic_setlease	-	sets a lease on an open file
- *	@filp: file pointer
- *	@arg: type of lease to obtain
- *	@flp: input - file_lock to use, output - file_lock inserted
- *	@aux: auxillary data for lm_setup
+ *	@filp:	file pointer
+ *	@arg:	type of lease to obtain
+ *	@flp:	input - file_lock to use, output - file_lock inserted
+ *	@aux:	auxillary data for lm_setup (may be NULL if lm_setup
+ *		doesn't require it)
  *
  *	The (input) flp->fl_lmops->lm_break function is required
  *	by break_lease().
@@ -1702,21 +1732,13 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp,
 }
 EXPORT_SYMBOL(generic_setlease);
 
-static int
-__vfs_setlease(struct file *filp, long arg, struct file_lock **lease, void **aux)
-{
-	if (filp->f_op->setlease)
-		return filp->f_op->setlease(filp, arg, lease, aux);
-	else
-		return generic_setlease(filp, arg, lease, aux);
-}
-
 /**
  * vfs_setlease        -       sets a lease on an open file
- * @filp: file pointer
- * @arg: type of lease to obtain
- * @lease: file_lock to use when adding a lease
- * @aux: auxillary info for lm_setup when adding a lease
+ * @filp:	file pointer
+ * @arg:	type of lease to obtain
+ * @lease:	file_lock to use when adding a lease
+ * @aux:	auxillary info for lm_setup when adding a lease (may be
+ * 		NULL if lm_setup doesn't require it)
  *
  * Call this to establish a lease on the file. The "lease" argument is not
  * used for F_UNLCK requests and may be NULL. For commands that set or alter
@@ -1730,8 +1752,10 @@ __vfs_setlease(struct file *filp, long arg, struct file_lock **lease, void **aux
  * where fcntl_getlease() can find it.  Since fcntl_getlease() only reports
  * whether the current task holds a lease, a cluster filesystem need only do
  * this for leases held by processes on this node.
+ *
+ * The "aux" pointer is passed directly to the lm_setup function as-is. It
+ * may be NULL if the lm_setup operation doesn't require it.
  */
-
 int
 vfs_setlease(struct file *filp, long arg, struct file_lock **lease, void **aux)
 {
@@ -1739,17 +1763,18 @@ vfs_setlease(struct file *filp, long arg, struct file_lock **lease, void **aux)
 	int error;
 
 	spin_lock(&inode->i_lock);
-	error = __vfs_setlease(filp, arg, lease, aux);
+	if (filp->f_op->setlease)
+		error = filp->f_op->setlease(filp, arg, lease, aux);
+	else
+		error = generic_setlease(filp, arg, lease, aux);
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
 
@@ -1762,26 +1787,9 @@ static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
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
-	error = __f_setown(filp, task_pid(current), PIDTYPE_PID, 0);
-out_unlock:
-	spin_unlock(&inode->i_lock);
+	error = vfs_setlease(filp, arg, &fl, (void **)&new);
 	if (fl)
 		locks_free_lock(fl);
 	if (new)
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d964a41c9151..6af5d0890373 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3773,7 +3773,7 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_file *fp, int flag)
 static int nfs4_setlease(struct nfs4_delegation *dp)
 {
 	struct nfs4_file *fp = dp->dl_stid.sc_file;
-	struct file_lock *fl, *ret;
+	struct file_lock *fl;
 	struct file *filp;
 	int status = 0;
 
@@ -3787,14 +3787,11 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
 		return -EBADF;
 	}
 	fl->fl_file = filp;
-	ret = fl;
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
index 2668d054147f..70d22c12924f 100644
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


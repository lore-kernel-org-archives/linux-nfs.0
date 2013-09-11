Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45473 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757137Ab3IKUD0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Sep 2013 16:03:26 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        jlayton@redhat.com, Dave Chinner <david@fromorbit.com>,
        Bruce Fields <bfields@fieldses.org>,
        David Howells <dhowells@redhat.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 13/13] locks: close potential race between setlease and open
Date: Wed, 11 Sep 2013 16:03:19 -0400
Message-Id: <1378929799-1110-14-git-send-email-bfields@redhat.com>
In-Reply-To: <1378929799-1110-1-git-send-email-bfields@redhat.com>
References: <1378929799-1110-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

v2:
- fix potential double-free of lease if second check finds conflict
- add smp_mb's to ensure that other CPUs see i_flock changes

v3:
- remove smp_mb calls. Partial ordering is unlikely to help here.

v4:
- add back smp_mb calls. While we have implicit barriers in place
  that enforce this today, it's best to be explicit about it as a
  defensive coding measure.

As Al Viro points out, there is an unlikely, but possible race between
opening a file and setting a lease on it. generic_add_lease is done with
the i_lock held, but the inode->i_flock check in break_lease is
lockless. It's possible for another task doing an open to do the entire
pathwalk and call break_lease between the point where generic_add_lease
checks for a conflicting open and adds the lease to the list. If this
occurs, we can end up with a lease set on the file with a conflicting
open.

To guard against that, check again for a conflicting open after adding
the lease to the i_flock list. If the above race occurs, then we can
simply unwind the lease setting and return -EAGAIN.

Because we take dentry references and acquire write access on the file
before calling break_lease, we know that if the i_flock list is empty
when the open caller goes to check it then the necessary refcounts have
already been incremented. Thus the additional check for a conflicting
open will see that there is one and the setlease call will fail.

Cc: Bruce Fields <bfields@fieldses.org>
Cc: David Howells <dhowells@redhat.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Reported-by: Al Viro <viro@ZenIV.linux.org.uk>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/locks.c         |   75 +++++++++++++++++++++++++++++++++++++++++++---------
 include/linux/fs.h |    6 +++++
 2 files changed, 68 insertions(+), 13 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 7336920..64346ef 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -652,15 +652,18 @@ static void locks_insert_lock(struct file_lock **pos, struct file_lock *fl)
 	locks_insert_global_locks(fl);
 }
 
-/*
- * Delete a lock and then free it.
- * Wake up processes that are blocked waiting for this lock,
- * notify the FS that the lock has been cleared and
- * finally free the lock.
+/**
+ * locks_delete_lock - Delete a lock and then free it.
+ * @thisfl_p: pointer that points to the fl_next field of the previous
+ * 	      inode->i_flock list entry
+ *
+ * Unlink a lock from all lists and free the namespace reference, but don't
+ * free it yet. Wake up processes that are blocked waiting for this lock and
+ * notify the FS that the lock has been cleared.
  *
  * Must be called with the i_lock held!
  */
-static void locks_delete_lock(struct file_lock **thisfl_p)
+static void locks_unlink_lock(struct file_lock **thisfl_p)
 {
 	struct file_lock *fl = *thisfl_p;
 
@@ -675,6 +678,18 @@ static void locks_delete_lock(struct file_lock **thisfl_p)
 	}
 
 	locks_wake_up_blocks(fl);
+}
+
+/*
+ * Unlink a lock from all lists and free it.
+ *
+ * Must be called with i_lock held!
+ */
+static void locks_delete_lock(struct file_lock **thisfl_p)
+{
+	struct file_lock *fl = *thisfl_p;
+
+	locks_unlink_lock(thisfl_p);
 	locks_free_lock(fl);
 }
 
@@ -1472,6 +1487,32 @@ int fcntl_getlease(struct file *filp)
 	return type;
 }
 
+/**
+ * check_conflicting_open - see if the given dentry points to a file that has
+ * 			    an existing open that would conflict with the
+ * 			    desired lease.
+ * @dentry:	dentry to check
+ * @arg:	type of lease that we're trying to acquire
+ *
+ * Check to see if there's an existing open fd on this file that would
+ * conflict with the lease we're trying to set.
+ */
+static int
+check_conflicting_open(const struct dentry *dentry, const long arg)
+{
+	int ret = 0;
+	struct inode *inode = dentry->d_inode;
+
+	if ((arg == F_RDLCK) && (atomic_read(&inode->i_writecount) > 0))
+		return -EAGAIN;
+
+	if ((arg == F_WRLCK) && ((d_count(dentry) > 1) ||
+	    (atomic_read(&inode->i_count) > 1)))
+		ret = -EAGAIN;
+
+	return ret;
+}
+
 static int generic_add_lease(struct file *filp, long arg, struct file_lock **flp)
 {
 	struct file_lock *fl, **before, **my_before = NULL, *lease;
@@ -1498,12 +1539,8 @@ static int generic_add_lease(struct file *filp, long arg, struct file_lock **flp
 		return -EINVAL;
 	}
 
-	error = -EAGAIN;
-	if ((arg == F_RDLCK) && (atomic_read(&inode->i_writecount) > 0))
-		goto out;
-	if ((arg == F_WRLCK)
-	    && ((d_count(dentry) > 1)
-		|| (atomic_read(&inode->i_count) > 1)))
+	error = check_conflicting_open(dentry, arg);
+	if (error)
 		goto out;
 
 	/*
@@ -1548,7 +1585,19 @@ static int generic_add_lease(struct file *filp, long arg, struct file_lock **flp
 		goto out;
 
 	locks_insert_lock(before, lease);
-	error = 0;
+	/*
+	 * The check in break_lease() is lockless. It's possible for another
+	 * open to race in after we did the earlier check for a conflicting
+	 * open but before the lease was inserted. Check again for a
+	 * conflicting open and cancel the lease if there is one.
+	 *
+	 * We also add a barrier here to ensure that the insertion of the lock
+	 * precedes these checks.
+	 */
+	smp_mb();
+	error = check_conflicting_open(dentry, arg);
+	if (error)
+		locks_unlink_lock(flp);
 out:
 	if (is_deleg)
 		mutex_unlock(&inode->i_mutex);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 4084f3b..0d477ac 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1969,6 +1969,12 @@ static inline int locks_verify_truncate(struct inode *inode,
 
 static inline int break_lease(struct inode *inode, unsigned int mode)
 {
+	/*
+	 * Since this check is lockless, we must ensure that any refcounts
+	 * taken are done before checking inode->i_flock. Otherwise, we could
+	 * end up racing with tasks trying to set a new lease on this file.
+	 */
+	smp_mb();
 	if (inode->i_flock)
 		return __break_lease(inode, mode, FL_LEASE);
 	return 0;
-- 
1.7.9.5


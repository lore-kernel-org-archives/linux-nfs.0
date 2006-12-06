From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 1/10] lockd: add new export operation for nfsv4/lockd locking
Date: Wed,  6 Dec 2006 00:34:11 -0500
Message-ID: <8eb625184e6025f7f3d081dfe0a805abdd62a068.1165380892.git.bfields__35633.3189913586$1165383398$gmane$org@citi.umich.edu>
References: <11653832602203-git-send-email-bfields@fieldses.org>
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: linux-fsdevel@vger.kernel.org
In-Reply-To: <11653832602203-git-send-email-bfields@fieldses.org>
Message-Id: <8eb625184e6025f7f3d081dfe0a805abdd62a068.1165380892.git.bfields@citi.umich.edu>
To: me <bfields@umich.edu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: Marc Eshel <eshel@almaden.ibm.com>

There is currently a filesystem ->lock() method, but it is defined only by
a few filesystems that are not exported via nfsd.  So none of the lock
routines that are used by lockd or nfsv4 bother to call those methods.

Filesystems such as cluster filesystems would like to do their own locking
and also would like to be exportable via NFS.

So we add a new lock() export operation, and new routines vfs_lock_file,
vfs_test_lock, and vfs_cancel_lock, which call the new export operation,
falling back on the appropriate local operation if the export operation is
unavailable.

These new functions are intended to be used by lockd and nfsd; lockd and
nfsd changes to take advantage of them are made by later patches.

Acquiring a lock may require communication with remote hosts, and to avoid
blocking lockd or nfsd threads during such communication, we allow the
results to be returned asynchronously.

When a ->lock() call needs to block, the file system will return
-EINPROGRESS, and then later return the results with a call to the routine
in the fl_notify field of the lock_manager_operations struct.

Note that this is different from the ->lock() call discovering that there
is a conflict which would cause the caller to block; this is still handled
in the same way as before.  In fact, we don't currently handle "blocking"
locks at all; those are less urgent, because the filesystem can always just
return an immediate -EAGAIN without denying the lock.

So this asynchronous interface is only used in the case of a non-blocking
lock, where we must know whether to allow or deny the lock now.

(Note: with this patch, we haven't yet modified lockd to handle such a
callback, which we must do so before a filesystem can safely use it in this
way.)

Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/svclock.c         |  108 +++++++++++++++++++++++++++++++++++++++++++-
 include/linux/fs.h         |    2 +
 include/linux/lockd/bind.h |    4 ++
 3 files changed, 113 insertions(+), 1 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 7e219b9..f523ca2 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -20,6 +20,7 @@
  * Copyright (C) 1996, Olaf Kirch <okir@monad.swb.de>
  */
 
+#include <linux/module.h>
 #include <linux/types.h>
 #include <linux/errno.h>
 #include <linux/kernel.h>
@@ -51,6 +52,111 @@ static const struct rpc_call_ops nlmsvc_grant_ops;
  */
 static LIST_HEAD(nlm_blocked);
 
+ /**
+ * vfs_lock_file - file byte range lock
+ * @filp: The file to apply the lock to
+ * @fl: The lock to be applied
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
+ */
+int vfs_lock_file(struct file *filp, struct file_lock *fl)
+{
+	struct super_block *sb;
+
+	sb = filp->f_dentry->d_inode->i_sb;
+	if (sb->s_export_op && sb->s_export_op->lock)
+		return sb->s_export_op->lock(filp, F_SETLK, fl);
+	else
+		return posix_lock_file(filp, fl);
+}
+EXPORT_SYMBOL(vfs_lock_file);
+
+/**
+ * vfs_lock_file - file byte range lock
+ * @filp: The file to apply the lock to
+ * @fl: The lock to be applied
+ * @conf: Place to return a copy of the conflicting lock, if found.
+ *
+ * read comments for vfs_lock_file()
+ */
+int vfs_lock_file_conf(struct file *filp, struct file_lock *fl, struct file_lock *conf)
+{
+	struct super_block *sb;
+
+	sb = filp->f_dentry->d_inode->i_sb;
+	if (sb->s_export_op && sb->s_export_op->lock) {
+		locks_copy_lock(conf, fl);
+		return sb->s_export_op->lock(filp, F_SETLK, fl);
+	} else
+		return posix_lock_file_conf(filp, fl, conf);
+}
+EXPORT_SYMBOL(vfs_lock_file_conf);
+
+/**
+ * vfs_test_lock - test file byte range lock
+ * @filp: The file to test lock for
+ * @fl: The lock to test
+ * @conf: Place to return a copy of the conflicting lock, if found.
+ */
+int vfs_test_lock(struct file *filp, struct file_lock *fl, struct file_lock *conf)
+{
+	int error;
+	struct super_block *sb;
+
+	conf->fl_type = F_UNLCK;
+	sb = filp->f_dentry->d_inode->i_sb;
+	if (sb->s_export_op && sb->s_export_op->lock) {
+ 		locks_copy_lock(conf, fl);
+		error = sb->s_export_op->lock(filp, F_GETLK, conf);
+		if (!error) {
+			if (conf->fl_type != F_UNLCK)
+				error =  1;
+		}
+		return error;
+ 	} else
+		return posix_test_lock(filp, fl, conf);
+}
+EXPORT_SYMBOL(vfs_test_lock);
+
+/**
+ * vfs_cancel_lock - file byte range unblock lock
+ * @filp: The file to apply the unblock to
+ * @fl: The lock to be unblocked
+ *
+ * FL_CANCELED is used to cancel blocked requests
+ */
+int vfs_cancel_lock(struct file *filp, struct file_lock *fl)
+{
+	int status;
+	struct super_block *sb;
+
+	fl->fl_flags |= FL_CANCEL;
+	sb = filp->f_dentry->d_inode->i_sb;
+	if (sb->s_export_op && sb->s_export_op->lock)
+		status = sb->s_export_op->lock(filp, F_SETLK, fl);
+	else
+		status = posix_unblock_lock(filp, fl);
+	fl->fl_flags &= ~FL_CANCEL;
+	return status;
+}
+
 /*
  * Insert a blocked lock into the global list
  */
@@ -241,7 +347,7 @@ static int nlmsvc_unlink_block(struct nlm_block *block)
 	dprintk("lockd: unlinking block %p...\n", block);
 
 	/* Remove block from list */
-	status = posix_unblock_lock(block->b_file->f_file, &block->b_call->a_args.lock.fl);
+	status = vfs_cancel_lock(block->b_file->f_file, &block->b_call->a_args.lock.fl);
 	nlmsvc_remove_block(block);
 	return status;
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 2fe6e3f..b1d287b 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -770,6 +770,7 @@ extern spinlock_t files_lock;
 
 #define FL_POSIX	1
 #define FL_FLOCK	2
+#define FL_CANCEL	4	/* set to request cancelling a lock */
 #define FL_ACCESS	8	/* not trying to lock, just looking */
 #define FL_EXISTS	16	/* when unlocking, test for existence */
 #define FL_LEASE	32	/* lease held on this file */
@@ -1372,6 +1373,7 @@ struct export_operations {
 		int (*acceptable)(void *context, struct dentry *de),
 		void *context);
 
+	int (*lock) (struct file *, int, struct file_lock *);
 
 };
 
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
index aa50d89..780bec4 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -38,4 +38,8 @@ extern int	nlmclnt_proc(struct inode *, int, struct file_lock *);
 extern int	lockd_up(int proto);
 extern void	lockd_down(void);
 
+extern int vfs_lock_file(struct file *, struct file_lock *);
+extern int vfs_lock_file_conf(struct file *, struct file_lock *, struct file_lock *);
+extern int vfs_test_lock(struct file *, struct file_lock *, struct file_lock *);
+
 #endif /* LINUX_LOCKD_BIND_H */
-- 
1.4.4.1


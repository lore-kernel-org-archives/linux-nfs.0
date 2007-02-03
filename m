From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 3/14] locks: factor out generic/filesystem switch from setlock code
Date: Sat,  3 Feb 2007 00:33:59 -0500
Message-ID: <48189.4525037662$1170484081@news.gmane.org>
References: 11704806552464-git-send-email- <11704808501171-git-send-email-> <11704808502512-git-send-email->
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
To: linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <11704808502512-git-send-email->
Message-Id: <1dd47bf9aeb6f19c82a59efb2f4236f23f73019d.1170479265.git.bfields@citi.umich.edu>
In-Reply-To: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu>
References: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: Marc Eshel <eshel@almaden.ibm.com> - unquoted

Factor out the code that switches between generic and filesystem-specific lock
methods; eventually we want to call this from lock managers (lockd and nfsd)
too; currently they only call the generic methods.

This patch does that for all the setlk code.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
---
 fs/locks.c                 |   68 +++++++++++++++++++++++--------------------
 include/linux/lockd/bind.h |    1 +
 2 files changed, 37 insertions(+), 32 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 95246dc..c88139d 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1691,6 +1691,21 @@ out:
 	return error;
 }
 
+/**
+ * vfs_lock_file - file byte range lock
+ * @filp: The file to apply the lock to
+ * @cmd: type of locking operation (F_SETLK, F_GETLK, etc.)
+ * @fl: The lock to be applied
+ */
+int vfs_lock_file(struct file *filp, unsigned int cmd, struct file_lock *fl)
+{
+	if (filp->f_op && filp->f_op->lock)
+		return filp->f_op->lock(filp, cmd, fl);
+	else
+		return posix_lock_file(filp, fl);
+}
+EXPORT_SYMBOL(vfs_lock_file);
+
 /* Apply the lock described by l to an open file descriptor.
  * This implements both the F_SETLK and F_SETLKW commands of fcntl().
  */
@@ -1753,21 +1768,17 @@ again:
 	if (error)
 		goto out;
 
-	if (filp->f_op && filp->f_op->lock != NULL)
-		error = filp->f_op->lock(filp, cmd, file_lock);
-	else {
-		for (;;) {
-			error = posix_lock_file(filp, file_lock);
-			if ((error != -EAGAIN) || (cmd == F_SETLK))
-				break;
-			error = wait_event_interruptible(file_lock->fl_wait,
-					!file_lock->fl_next);
-			if (!error)
-				continue;
-
-			locks_delete_block(file_lock);
+	for (;;) {
+		error = vfs_lock_file(filp, cmd, file_lock);
+		if ((error != -EAGAIN) || (cmd == F_SETLK))
 			break;
-		}
+		error = wait_event_interruptible(file_lock->fl_wait,
+				!file_lock->fl_next);
+		if (!error)
+			continue;
+
+		locks_delete_block(file_lock);
+		break;
 	}
 
 	/*
@@ -1889,21 +1900,17 @@ again:
 	if (error)
 		goto out;
 
-	if (filp->f_op && filp->f_op->lock != NULL)
-		error = filp->f_op->lock(filp, cmd, file_lock);
-	else {
-		for (;;) {
-			error = posix_lock_file(filp, file_lock);
-			if ((error != -EAGAIN) || (cmd == F_SETLK64))
-				break;
-			error = wait_event_interruptible(file_lock->fl_wait,
-					!file_lock->fl_next);
-			if (!error)
-				continue;
-
-			locks_delete_block(file_lock);
+	for (;;) {
+		error = vfs_lock_file(filp, cmd, file_lock);
+		if ((error != -EAGAIN) || (cmd == F_SETLK64))
 			break;
-		}
+		error = wait_event_interruptible(file_lock->fl_wait,
+				!file_lock->fl_next);
+		if (!error)
+			continue;
+
+		locks_delete_block(file_lock);
+		break;
 	}
 
 	/*
@@ -1940,10 +1947,7 @@ void locks_remove_posix(struct file *filp, fl_owner_t owner)
 	lock.fl_ops = NULL;
 	lock.fl_lmops = NULL;
 
-	if (filp->f_op && filp->f_op->lock != NULL)
-		filp->f_op->lock(filp, F_SETLK, &lock);
-	else
-		posix_lock_file(filp, &lock);
+	vfs_lock_file(filp, F_SETLK, &lock);
 
 	if (lock.fl_ops && lock.fl_ops->fl_release_private)
 		lock.fl_ops->fl_release_private(&lock);
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
index f78b24a..c88da8e 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -39,5 +39,6 @@ extern int	lockd_up(int proto);
 extern void	lockd_down(void);
 
 extern int vfs_test_lock(struct file *, struct file_lock *, struct file_lock *);
+extern int vfs_lock_file(struct file *, int cmd, struct file_lock *);
 
 #endif /* LINUX_LOCKD_BIND_H */
-- 
1.5.0.rc1.g72fe


From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 6/14] locks: add lock cancel command
Date: Sat,  3 Feb 2007 00:34:02 -0500
Message-ID: <49315.8145611689$1170484083@news.gmane.org>
References: 11704806552464-git-send-email- <11704808501171-git-send-email-> <11704808502512-git-send-email-> <11704808513862-git-send-email-> <1170480851972-git-send-email-> <11704808513070-git-send-email->
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
To: linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <11704808513070-git-send-email->
Message-Id: <fdf19cb6a33a08dd9220cdf2379d712d3c15e66f.1170479265.git.bfields@citi.umich.edu>
In-Reply-To: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu>
References: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: Marc Eshel <eshel@almaden.ibm.com> - unquoted

Lock managers need to be able to cancel pending lock requests.  In the case
where the exported filesystem manages its own locks, it's not sufficient just
to call posix_unblock_lock(); we need to let the filesystem know what's
happening too.

We do this by adding a new fcntl lock command: FL_CANCELLK.  Some day this
might also be made available to userspace applications that could benefit from
an asynchronous locking api.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
---
 fs/locks.c                 |   17 +++++++++++++++++
 include/linux/fcntl.h      |    4 ++++
 include/linux/lockd/bind.h |    1 +
 3 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 819dc28..8ee72b3 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -2061,6 +2061,23 @@ posix_unblock_lock(struct file *filp, struct file_lock *waiter)
 
 EXPORT_SYMBOL(posix_unblock_lock);
 
+/**
+ * vfs_cancel_lock - file byte range unblock lock
+ * @filp: The file to apply the unblock to
+ * @fl: The lock to be unblocked
+ *
+ * Used by lock managers to cancel blocked requests
+ */
+int vfs_cancel_lock(struct file *filp, struct file_lock *fl)
+{
+	if (filp->f_op && filp->f_op->lock)
+		return filp->f_op->lock(filp, F_CANCELLK, fl);
+	else
+		return posix_unblock_lock(filp, fl);
+}
+
+EXPORT_SYMBOL(vfs_cancel_lock);
+
 static void lock_get_status(char* out, struct file_lock *fl, int id, char *pfx)
 {
 	struct inode *inode = NULL;
diff --git a/include/linux/fcntl.h b/include/linux/fcntl.h
index 996f561..40b9326 100644
--- a/include/linux/fcntl.h
+++ b/include/linux/fcntl.h
@@ -3,6 +3,10 @@
 
 #include <asm/fcntl.h>
 
+/* Cancel a blocking posix lock; internal use only until we expose an
+ * asynchronous lock api to userspace: */
+#define F_CANCELLK	(F_LINUX_SPECIFIC_BASE+5)
+
 #define F_SETLEASE	(F_LINUX_SPECIFIC_BASE+0)
 #define F_GETLEASE	(F_LINUX_SPECIFIC_BASE+1)
 
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
index 01c25e4..1333dcf 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -41,5 +41,6 @@ extern void	lockd_down(void);
 extern int vfs_test_lock(struct file *, struct file_lock *, struct file_lock *);
 extern int vfs_lock_file(struct file *, int cmd, struct file_lock *);
 extern int vfs_lock_file_conf(struct file *, struct file_lock *, struct file_lock *);
+extern int vfs_cancel_lock(struct file *filp, struct file_lock *fl);
 
 #endif /* LINUX_LOCKD_BIND_H */
-- 
1.5.0.rc1.g72fe


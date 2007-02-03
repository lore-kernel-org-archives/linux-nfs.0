From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 4/14] locks: add locking function that returns conflicting lock
Date: Sat,  3 Feb 2007 00:34:00 -0500
Message-ID: <49195.9495273933$1170483221@news.gmane.org>
References: 11704806552464-git-send-email- <11704808501171-git-send-email-> <11704808502512-git-send-email-> <11704808513862-git-send-email->
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
To: linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <11704808513862-git-send-email->
Message-Id: <96a0abaf64b433a7e7450e7e35d0baf2c44103db.1170479265.git.bfields@citi.umich.edu>
In-Reply-To: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu>
References: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: Marc Eshel <eshel@almaden.ibm.com> - unquoted

The nfsv4 protocol's lock operation, in the case of a conflict, returns
information about the conflicting lock.

It's unclear how clients can use this, so for now we're not going so far as to
add a filesystem method that can return a conflicting lock, but we may as well
return something in the local case when it's easy to.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
---
 fs/locks.c                 |   18 ++++++++++++++++++
 include/linux/lockd/bind.h |    1 +
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index c88139d..1bd6418 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1706,6 +1706,24 @@ int vfs_lock_file(struct file *filp, unsigned int cmd, struct file_lock *fl)
 }
 EXPORT_SYMBOL(vfs_lock_file);
 
+/**
+ * vfs_lock_file_conf - file byte range lock
+ * @filp: The file to apply the lock to
+ * @fl: The lock to be applied
+ * @conf: Place to return a copy of the conflicting lock, if found.
+ *
+ * read comments for vfs_lock_file()
+ */
+int vfs_lock_file_conf(struct file *filp, struct file_lock *fl, struct file_lock *conf)
+{
+	if (filp->f_op && filp->f_op->lock) {
+		__locks_copy_lock(conf, fl);
+		return filp->f_op->lock(filp, F_SETLK, fl);
+	} else
+		return posix_lock_file_conf(filp, fl, conf);
+}
+EXPORT_SYMBOL(vfs_lock_file_conf);
+
 /* Apply the lock described by l to an open file descriptor.
  * This implements both the F_SETLK and F_SETLKW commands of fcntl().
  */
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
index c88da8e..01c25e4 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -40,5 +40,6 @@ extern void	lockd_down(void);
 
 extern int vfs_test_lock(struct file *, struct file_lock *, struct file_lock *);
 extern int vfs_lock_file(struct file *, int cmd, struct file_lock *);
+extern int vfs_lock_file_conf(struct file *, struct file_lock *, struct file_lock *);
 
 #endif /* LINUX_LOCKD_BIND_H */
-- 
1.5.0.rc1.g72fe


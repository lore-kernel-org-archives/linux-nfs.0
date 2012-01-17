Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50552 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754700Ab2AQQAc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 11:00:32 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [RFC PATCH 2/6] locks: give break_lease its own flags
Date: Tue, 17 Jan 2012 11:00:25 -0500
Message-Id: <1326816029-13913-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1326816029-13913-1-git-send-email-bfields@redhat.com>
References: <1326816029-13913-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Instead of passing O_* flags to break_lease, give it its own set of
constants to use.  We'll want more bits here soon.

Be careful to continue treating these bits the same way for now, so
there isn't a "flag day" for break_lease callers.  We'll probably change
the constants eventually, though.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/locks.c         |   10 +++++-----
 fs/nfsd/vfs.c      |    6 +++---
 fs/open.c          |    4 ++--
 include/linux/fs.h |   40 ++++++++++++++++++++++++++++++++++++++++
 4 files changed, 50 insertions(+), 10 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index bc55194..d6661a6 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1188,12 +1188,12 @@ static void time_out_leases(struct inode *inode)
 /**
  *	__break_lease	-	revoke all outstanding leases on file
  *	@inode: the inode of the file to return
- *	@mode: the open mode (read or write)
+ *	@mode: the type of leases to break
  *
  *	break_lease (inlined for speed) has checked there already is at least
- *	some kind of lock (maybe a lease) on this file.  Leases are broken on
- *	a call to open() or truncate().  This function can sleep unless you
- *	specified %O_NONBLOCK to your open().
+ *	some kind of lock (maybe a lease) on this file.
+ *	This function will wait for the lease to be broken unless you include
+ *	BREAK_NONBLOCK in the mode.
  */
 int __break_lease(struct inode *inode, unsigned int mode)
 {
@@ -1202,7 +1202,7 @@ int __break_lease(struct inode *inode, unsigned int mode)
 	struct file_lock *fl;
 	unsigned long break_time;
 	int i_have_this_lease = 0;
-	int want_write = (mode & O_ACCMODE) != O_RDONLY;
+	int want_write = break_all_leases(mode);
 
 	new_fl = lease_alloc(NULL, want_write ? F_WRLCK : F_RDLCK);
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 8968913..a522b2f 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -276,7 +276,7 @@ static int nfsd_break_lease(struct inode *inode)
 {
 	if (!S_ISREG(inode->i_mode))
 		return 0;
-	return break_lease(inode, O_WRONLY | O_NONBLOCK);
+	return break_lease(inode, BREAK_ALL_LEASES | BREAK_NONBLOCK);
 }
 
 /*
@@ -731,8 +731,8 @@ static int nfsd_open_break_lease(struct inode *inode, int access)
 
 	if (access & NFSD_MAY_NOT_BREAK_LEASE)
 		return 0;
-	mode = (access & NFSD_MAY_WRITE) ? O_WRONLY : O_RDONLY;
-	return break_lease(inode, mode | O_NONBLOCK);
+	mode = (access & NFSD_MAY_WRITE) ? BREAK_ALL_LEASES : BREAK_WRITE_LEASES;
+	return break_lease(inode, mode | BREAK_NONBLOCK);
 }
 
 /*
diff --git a/fs/open.c b/fs/open.c
index 22c41b5..b7d55e2 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -105,7 +105,7 @@ static long do_sys_truncate(const char __user *pathname, loff_t length)
 	 * Make sure that there are no leases.  get_write_access() protects
 	 * against the truncate racing with a lease-granting setlease().
 	 */
-	error = break_lease(inode, O_WRONLY);
+	error = break_lease(inode, BREAK_ALL_LEASES);
 	if (error)
 		goto put_write_and_out;
 
@@ -685,7 +685,7 @@ static struct file *__dentry_open(struct dentry *dentry, struct vfsmount *mnt,
 	if (error)
 		goto cleanup_all;
 
-	error = break_lease(inode, f->f_flags);
+	error = open_break_lease(inode, f->f_flags);
 	if (error)
 		goto cleanup_all;
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 425d05d..939cb3b 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1083,6 +1083,35 @@ static inline int file_check_writeable(struct file *filp)
 #define FL_DOWNGRADE_PENDING	256 /* Lease is being downgraded */
 #define FL_UNLOCK_PENDING	512 /* Lease is being broken */
 
+/* break-lease flags */
+/*
+ * These agree with O_RDONLY, O_WRONLY, O_ACCMODE, and O_NONBLOCK as a
+ * (possibly temporary) courtesy to developers of any out-of-tree
+ * code that calls break_lease:
+ */
+#define BREAK_WRITE_LEASES	00000000
+#define BREAK_ALL_LEASES	00000001
+#define BREAK_TYPE_MASK		00000003
+#define BREAK_NONBLOCK		00004000
+/*
+ * Read delegations are also broken on operations that modify file
+ * metadata or the set of links that point to a file:
+ */
+#define BREAK_ONLY_DELEGS	00000010
+
+/*
+ * Make it easy to allow O_RDONLY, O_RDWR, O_WRONLY to continue to work
+ * as they did before, for now:
+ */
+static inline bool break_write_leases(unsigned int type)
+{
+	return ((type & BREAK_TYPE_MASK) == BREAK_WRITE_LEASES);
+}
+static inline bool break_all_leases(unsigned int type)
+{
+	return ((type & BREAK_TYPE_MASK) == BREAK_ALL_LEASES);
+}
+
 /*
  * Special return value from posix_lock_file() and vfs_lock_file() for
  * asynchronous locking.
@@ -2005,6 +2034,13 @@ static inline int break_lease(struct inode *inode, unsigned int mode)
 		return __break_lease(inode, mode);
 	return 0;
 }
+
+static inline int open_break_lease(struct inode *inode, unsigned int mode)
+{
+	unsigned int type = (mode & O_ACCMODE) == O_RDONLY ?
+			BREAK_WRITE_LEASES : BREAK_ALL_LEASES;
+	return __break_lease(inode, type);
+}
 #else /* !CONFIG_FILE_LOCKING */
 static inline int locks_mandatory_locked(struct inode *inode)
 {
@@ -2044,6 +2080,10 @@ static inline int break_lease(struct inode *inode, unsigned int mode)
 	return 0;
 }
 
+static inline int open_break_lease(struct inode *inode, unsigned int mode)
+{
+	return 0;
+}
 #endif /* CONFIG_FILE_LOCKING */
 
 /* fs/open.c */
-- 
1.7.5.4


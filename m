Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f171.google.com ([209.85.217.171]:42068 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162074Ab3DEQyG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Apr 2013 12:54:06 -0400
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-kernel@vger.kernel.org
Cc: linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: [PATCH v4 1/7] fcntl: Introduce new O_DENY* open flags
Date: Fri,  5 Apr 2013 20:57:49 +0400
Message-Id: <1365181075-22540-2-git-send-email-piastry@etersoft.ru>
In-Reply-To: <1365181075-22540-1-git-send-email-piastry@etersoft.ru>
References: <1365181075-22540-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds 3 flags:
1) O_DENYREAD that doesn't permit read access,
2) O_DENYWRITE that doesn't permit write access,
3) O_DENYDELETE that doesn't permit delete or rename,

Network filesystems CIFS, SMB2.0, SMB3.0 and NFSv4 have such flags -
this change can benefit cifs and nfs modules as well as Samba and
NFS file servers that export the same directory for Windows clients,
or Wine applications that access the same files simultaneously.

These flags are only take affect for opens on mounts with 'sharelock'
mount option. They are translated to flock's flags:

!O_DENYREAD  -> LOCK_READ | LOCK_MAND
!O_DENYWRITE -> LOCK_WRITE | LOCK_MAND

and set through flock_lock_file on a file. If the file can't be locked
due conflicts with another open with O_DENY* flags, the -EBUSY error
code is returned.

Create codepath is slightly changed to prevent data races on
newely created files: when open with O_CREAT can return with -EBUSY
error for successfully created files due to a deny lock set by
another task.

Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
---
 fs/fcntl.c                       |  5 ++-
 fs/locks.c                       | 93 +++++++++++++++++++++++++++++++++++++---
 fs/namei.c                       | 45 +++++++++++++++++--
 fs/proc_namespace.c              |  1 +
 include/linux/fs.h               |  7 +++
 include/uapi/asm-generic/fcntl.h | 11 +++++
 include/uapi/linux/fs.h          |  1 +
 7 files changed, 150 insertions(+), 13 deletions(-)

diff --git a/fs/fcntl.c b/fs/fcntl.c
index 71a600a..7abce5a 100644
--- a/fs/fcntl.c
+++ b/fs/fcntl.c
@@ -730,14 +730,15 @@ static int __init fcntl_init(void)
 	 * Exceptions: O_NONBLOCK is a two bit define on parisc; O_NDELAY
 	 * is defined as O_NONBLOCK on some platforms and not on others.
 	 */
-	BUILD_BUG_ON(19 - 1 /* for O_RDONLY being 0 */ != HWEIGHT32(
+	BUILD_BUG_ON(22 - 1 /* for O_RDONLY being 0 */ != HWEIGHT32(
 		O_RDONLY	| O_WRONLY	| O_RDWR	|
 		O_CREAT		| O_EXCL	| O_NOCTTY	|
 		O_TRUNC		| O_APPEND	| /* O_NONBLOCK	| */
 		__O_SYNC	| O_DSYNC	| FASYNC	|
 		O_DIRECT	| O_LARGEFILE	| O_DIRECTORY	|
 		O_NOFOLLOW	| O_NOATIME	| O_CLOEXEC	|
-		__FMODE_EXEC	| O_PATH
+		__FMODE_EXEC	| O_PATH	| O_DENYREAD	|
+		O_DENYWRITE	| O_DENYDELETE
 		));
 
 	fasync_cache = kmem_cache_create("fasync_cache",
diff --git a/fs/locks.c b/fs/locks.c
index a94e331..1eccc75 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -605,20 +605,73 @@ static int posix_locks_conflict(struct file_lock *caller_fl, struct file_lock *s
 	return (locks_conflict(caller_fl, sys_fl));
 }
 
-/* Determine if lock sys_fl blocks lock caller_fl. FLOCK specific
- * checking before calling the locks_conflict().
+static unsigned int
+deny_flags_to_cmd(unsigned int flags)
+{
+	unsigned int cmd = LOCK_MAND;
+
+	if (!(flags & O_DENYREAD))
+		cmd |= LOCK_READ;
+	if (!(flags & O_DENYWRITE))
+		cmd |= LOCK_WRITE;
+
+	return cmd;
+}
+
+/*
+ * locks_mand_conflict - Determine if there's a share reservation conflict
+ * @caller_fl: lock we're attempting to acquire
+ * @sys_fl: lock already present on system that we're checking against
+ *
+ * Check to see if there's a share_reservation conflict. LOCK_READ/LOCK_WRITE
+ * tell us whether the reservation allows other readers and writers.
+ */
+static int
+locks_mand_conflict(struct file_lock *caller_fl, struct file_lock *sys_fl)
+{
+	unsigned char caller_type = caller_fl->fl_type;
+	unsigned char sys_type = sys_fl->fl_type;
+	fmode_t caller_fmode = caller_fl->fl_file->f_mode;
+	fmode_t sys_fmode = sys_fl->fl_file->f_mode;
+
+	/* they can only conflict if FS is mounted with MS_SHARELOCK */
+	if (!IS_SHARELOCK(caller_fl->fl_file->f_path.dentry->d_inode))
+		return 0;
+
+	/* they can only conflict if they're both LOCK_MAND */
+	if (!(caller_type & LOCK_MAND) || !(sys_type & LOCK_MAND))
+		return 0;
+
+	if (!(caller_type & LOCK_READ) && (sys_fmode & FMODE_READ))
+		return 1;
+	if (!(caller_type & LOCK_WRITE) && (sys_fmode & FMODE_WRITE))
+		return 1;
+	if (!(sys_type & LOCK_READ) && (caller_fmode & FMODE_READ))
+		return 1;
+	if (!(sys_type & LOCK_WRITE) && (caller_fmode & FMODE_WRITE))
+		return 1;
+
+	return 0;
+}
+
+/*
+ * Determine if lock sys_fl blocks lock caller_fl. FLOCK specific checking
+ * before calling the locks_conflict().
  */
 static int flock_locks_conflict(struct file_lock *caller_fl, struct file_lock *sys_fl)
 {
-	/* FLOCK locks referring to the same filp do not conflict with
+	if (!IS_FLOCK(sys_fl))
+		return 0;
+	if ((caller_fl->fl_type & LOCK_MAND) || (sys_fl->fl_type & LOCK_MAND))
+		return locks_mand_conflict(caller_fl, sys_fl);
+	/*
+	 * FLOCK locks referring to the same filp do not conflict with
 	 * each other.
 	 */
-	if (!IS_FLOCK(sys_fl) || (caller_fl->fl_file == sys_fl->fl_file))
-		return (0);
-	if ((caller_fl->fl_type & LOCK_MAND) || (sys_fl->fl_type & LOCK_MAND))
+	if (caller_fl->fl_file == sys_fl->fl_file)
 		return 0;
 
-	return (locks_conflict(caller_fl, sys_fl));
+	return locks_conflict(caller_fl, sys_fl);
 }
 
 void
@@ -783,6 +836,32 @@ out:
 	return error;
 }
 
+/*
+ * Determine if a file is allowed to be opened with specified access and deny
+ * modes. Lock the file and return 0 if checks passed, otherwise return a error
+ * code.
+ */
+int
+deny_lock_file(struct file *filp)
+{
+	struct file_lock *lock;
+	int error = 0;
+
+	if (!IS_SHARELOCK(filp->f_path.dentry->d_inode))
+		return error;
+
+	error = flock_make_lock(filp, &lock, deny_flags_to_cmd(filp->f_flags));
+	if (error)
+		return error;
+
+	error = flock_lock_file(filp, lock);
+	if (error == -EAGAIN)
+		error = -EBUSY;
+
+	locks_free_lock(lock);
+	return error;
+}
+
 static int __posix_lock_file(struct inode *inode, struct file_lock *request, struct file_lock *conflock)
 {
 	struct file_lock *fl;
diff --git a/fs/namei.c b/fs/namei.c
index ec97aef..416c74f 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2557,9 +2557,14 @@ static int atomic_open(struct nameidata *nd, struct dentry *dentry,
 	 * here.
 	 */
 	error = may_open(&file->f_path, acc_mode, open_flag);
-	if (error)
+	if (error) {
 		fput(file);
+		goto out;
+	}
 
+	error = deny_lock_file(file);
+	if (error)
+		fput(file);
 out:
 	dput(dentry);
 	return error;
@@ -2769,9 +2774,9 @@ retry_lookup:
 	}
 	mutex_lock(&dir->d_inode->i_mutex);
 	error = lookup_open(nd, path, file, op, got_write, opened);
-	mutex_unlock(&dir->d_inode->i_mutex);
 
 	if (error <= 0) {
+		mutex_unlock(&dir->d_inode->i_mutex);
 		if (error)
 			goto out;
 
@@ -2789,8 +2794,32 @@ retry_lookup:
 		will_truncate = false;
 		acc_mode = MAY_OPEN;
 		path_to_nameidata(path, nd);
-		goto finish_open_created;
+
+		/*
+		 * Unlock parent i_mutex later when the open finishes - prevent
+		 * races when a file can be locked with a deny lock by another
+		 * task that opens the file.
+		 */
+		error = may_open(&nd->path, acc_mode, open_flag);
+		if (error) {
+			mutex_unlock(&dir->d_inode->i_mutex);
+			goto out;
+		}
+		file->f_path.mnt = nd->path.mnt;
+		error = finish_open(file, nd->path.dentry, NULL, opened);
+		if (error) {
+			mutex_unlock(&dir->d_inode->i_mutex);
+			if (error == -EOPENSTALE)
+				goto stale_open;
+			goto out;
+		}
+		error = deny_lock_file(file);
+		mutex_unlock(&dir->d_inode->i_mutex);
+		if (error)
+			goto exit_fput;
+		goto opened;
 	}
+	mutex_unlock(&dir->d_inode->i_mutex);
 
 	/*
 	 * create/update audit record if it already exists.
@@ -2872,7 +2901,6 @@ finish_open:
 			goto out;
 		got_write = true;
 	}
-finish_open_created:
 	error = may_open(&nd->path, acc_mode, open_flag);
 	if (error)
 		goto out;
@@ -2883,6 +2911,15 @@ finish_open_created:
 			goto stale_open;
 		goto out;
 	}
+	/*
+	 * Lock parent i_mutex to prevent races with deny locks on newely
+	 * created files.
+	 */
+	mutex_lock(&dir->d_inode->i_mutex);
+	error = deny_lock_file(file);
+	mutex_unlock(&dir->d_inode->i_mutex);
+	if (error)
+		goto exit_fput;
 opened:
 	error = open_check_o_direct(file);
 	if (error)
diff --git a/fs/proc_namespace.c b/fs/proc_namespace.c
index 2033f74..6edbadc 100644
--- a/fs/proc_namespace.c
+++ b/fs/proc_namespace.c
@@ -44,6 +44,7 @@ static int show_sb_opts(struct seq_file *m, struct super_block *sb)
 		{ MS_SYNCHRONOUS, ",sync" },
 		{ MS_DIRSYNC, ",dirsync" },
 		{ MS_MANDLOCK, ",mand" },
+		{ MS_SHARELOCK, ",sharelock" },
 		{ 0, NULL }
 	};
 	const struct proc_fs_info *fs_infop;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 1a39c33..073e31a 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1005,6 +1005,7 @@ extern int lease_modify(struct file_lock **, int);
 extern int lock_may_read(struct inode *, loff_t start, unsigned long count);
 extern int lock_may_write(struct inode *, loff_t start, unsigned long count);
 extern void locks_delete_block(struct file_lock *waiter);
+extern int deny_lock_file(struct file *);
 extern void lock_flocks(void);
 extern void unlock_flocks(void);
 #else /* !CONFIG_FILE_LOCKING */
@@ -1153,6 +1154,11 @@ static inline void locks_delete_block(struct file_lock *waiter)
 {
 }
 
+static inline int deny_lock_file(struct file *filp)
+{
+	return 0;
+}
+
 static inline void lock_flocks(void)
 {
 }
@@ -1668,6 +1674,7 @@ struct super_operations {
 #define IS_PRIVATE(inode)	((inode)->i_flags & S_PRIVATE)
 #define IS_IMA(inode)		((inode)->i_flags & S_IMA)
 #define IS_AUTOMOUNT(inode)	((inode)->i_flags & S_AUTOMOUNT)
+#define IS_SHARELOCK(inode)	__IS_FLG(inode, MS_SHARELOCK)
 #define IS_NOSEC(inode)		((inode)->i_flags & S_NOSEC)
 
 /*
diff --git a/include/uapi/asm-generic/fcntl.h b/include/uapi/asm-generic/fcntl.h
index a48937d..5ac0d49 100644
--- a/include/uapi/asm-generic/fcntl.h
+++ b/include/uapi/asm-generic/fcntl.h
@@ -84,6 +84,17 @@
 #define O_PATH		010000000
 #endif
 
+#ifndef O_DENYREAD
+#define O_DENYREAD	020000000	/* Do not permit read access */
+#endif
+#ifndef O_DENYWRITE
+#define O_DENYWRITE	040000000	/* Do not permit write access */
+#endif
+/* FMODE_NONOTIFY	0100000000 */
+#ifndef O_DENYDELETE
+#define O_DENYDELETE	0200000000	/* Do not permit delete or rename */
+#endif
+
 #ifndef O_NDELAY
 #define O_NDELAY	O_NONBLOCK
 #endif
diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
index 780d4c6..f1925f7 100644
--- a/include/uapi/linux/fs.h
+++ b/include/uapi/linux/fs.h
@@ -86,6 +86,7 @@ struct inodes_stat_t {
 #define MS_KERNMOUNT	(1<<22) /* this is a kern_mount call */
 #define MS_I_VERSION	(1<<23) /* Update inode I_version field */
 #define MS_STRICTATIME	(1<<24) /* Always perform atime updates */
+#define MS_SHARELOCK	(1<<25) /* Allow share locks on an FS */
 #define MS_NOSEC	(1<<28)
 #define MS_BORN		(1<<29)
 #define MS_ACTIVE	(1<<30)
-- 
1.8.1.5


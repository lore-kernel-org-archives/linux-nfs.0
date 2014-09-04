Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:41188 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980AbaIDMjK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 08:39:10 -0400
Received: by mail-qg0-f51.google.com with SMTP id i50so9708626qgf.38
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2014 05:39:09 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org
Subject: [PATCH v2 08/17] locks: plumb a "priv" pointer into the setlease routines
Date: Thu,  4 Sep 2014 08:38:34 -0400
Message-Id: <1409834323-7171-9-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In later patches, we're going to add a new lock_manager_operation to
finish setting up the lease while still holding the i_lock.  To do
this, we'll need to pass a little bit of info in the fcntl setlease
case (primarily an fasync structure). Plumb the extra pointer into
there in advance of that.

We declare this pointer as a void ** to make it clear that this is
private info, and that the caller isn't required to set this unless
the lm_setup specifically requires it.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/cifs/cifsfs.c    |  7 ++++---
 fs/libfs.c          |  4 +++-
 fs/locks.c          | 32 ++++++++++++++++++++------------
 fs/nfsd/nfs4state.c |  4 ++--
 include/linux/fs.h  | 12 ++++++------
 5 files changed, 35 insertions(+), 24 deletions(-)

diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index 889b98455750..9d7996e8e793 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -813,7 +813,8 @@ static loff_t cifs_llseek(struct file *file, loff_t offset, int whence)
 	return generic_file_llseek(file, offset, whence);
 }
 
-static int cifs_setlease(struct file *file, long arg, struct file_lock **lease)
+static int
+cifs_setlease(struct file *file, long arg, struct file_lock **lease, void **priv)
 {
 	/*
 	 * Note that this is called by vfs setlease with i_lock held to
@@ -829,7 +830,7 @@ static int cifs_setlease(struct file *file, long arg, struct file_lock **lease)
 	if (arg == F_UNLCK ||
 	    ((arg == F_RDLCK) && CIFS_CACHE_READ(CIFS_I(inode))) ||
 	    ((arg == F_WRLCK) && CIFS_CACHE_WRITE(CIFS_I(inode))))
-		return generic_setlease(file, arg, lease);
+		return generic_setlease(file, arg, lease, priv);
 	else if (tlink_tcon(cfile->tlink)->local_lease &&
 		 !CIFS_CACHE_READ(CIFS_I(inode)))
 		/*
@@ -840,7 +841,7 @@ static int cifs_setlease(struct file *file, long arg, struct file_lock **lease)
 		 * knows that the file won't be changed on the server by anyone
 		 * else.
 		 */
-		return generic_setlease(file, arg, lease);
+		return generic_setlease(file, arg, lease, priv);
 	else
 		return -EAGAIN;
 }
diff --git a/fs/libfs.c b/fs/libfs.c
index 29012a303ef8..171d2846f2a3 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -1081,12 +1081,14 @@ EXPORT_SYMBOL(alloc_anon_inode);
  * @filp: file pointer
  * @arg: type of lease to obtain
  * @flp: new lease supplied for insertion
+ * @priv: private data for lm_setup operation
  *
  * Generic helper for filesystems that do not wish to allow leases to be set.
  * All arguments are ignored and it just returns -EINVAL.
  */
 int
-simple_nosetlease(struct file *filp, long arg, struct file_lock **flp)
+simple_nosetlease(struct file *filp, long arg, struct file_lock **flp,
+		  void **priv)
 {
 	return -EINVAL;
 }
diff --git a/fs/locks.c b/fs/locks.c
index 81a4628f5594..7162a5836dba 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1297,7 +1297,6 @@ int lease_modify(struct file_lock **before, int arg)
 	}
 	return 0;
 }
-
 EXPORT_SYMBOL(lease_modify);
 
 static bool past_time(unsigned long then)
@@ -1543,7 +1542,8 @@ check_conflicting_open(const struct dentry *dentry, const long arg)
 	return ret;
 }
 
-static int generic_add_lease(struct file *filp, long arg, struct file_lock **flp)
+static int
+generic_add_lease(struct file *filp, long arg, struct file_lock **flp, void **priv)
 {
 	struct file_lock *fl, **before, **my_before = NULL, *lease;
 	struct dentry *dentry = filp->f_path.dentry;
@@ -1630,11 +1630,14 @@ static int generic_add_lease(struct file *filp, long arg, struct file_lock **flp
 	smp_mb();
 	error = check_conflicting_open(dentry, arg);
 	if (error)
-		locks_unlink_lock(before);
+		goto out_unlink;
 out:
 	if (is_deleg)
 		mutex_unlock(&inode->i_mutex);
 	return error;
+out_unlink:
+	locks_unlink_lock(before);
+	goto out;
 }
 
 static int generic_delete_lease(struct file *filp)
@@ -1661,13 +1664,15 @@ static int generic_delete_lease(struct file *filp)
  *	@filp: file pointer
  *	@arg: type of lease to obtain
  *	@flp: input - file_lock to use, output - file_lock inserted
+ *	@priv: private data for lm_setup
  *
  *	The (input) flp->fl_lmops->lm_break function is required
  *	by break_lease().
  *
  *	Called with inode->i_lock held.
  */
-int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
+int generic_setlease(struct file *filp, long arg, struct file_lock **flp,
+			void **priv)
 {
 	struct dentry *dentry = filp->f_path.dentry;
 	struct inode *inode = dentry->d_inode;
@@ -1692,19 +1697,20 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
 			WARN_ON_ONCE(1);
 			return -ENOLCK;
 		}
-		return generic_add_lease(filp, arg, flp);
+		return generic_add_lease(filp, arg, flp, priv);
 	default:
 		return -EINVAL;
 	}
 }
 EXPORT_SYMBOL(generic_setlease);
 
-static int __vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
+static int
+__vfs_setlease(struct file *filp, long arg, struct file_lock **lease, void **priv)
 {
 	if (filp->f_op->setlease)
-		return filp->f_op->setlease(filp, arg, lease);
+		return filp->f_op->setlease(filp, arg, lease, priv);
 	else
-		return generic_setlease(filp, arg, lease);
+		return generic_setlease(filp, arg, lease, priv);
 }
 
 /**
@@ -1712,6 +1718,7 @@ static int __vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
  * @filp: file pointer
  * @arg: type of lease to obtain
  * @lease: file_lock to use when adding a lease
+ * @priv: private info for lm_setup when adding a lease
  *
  * Call this to establish a lease on the file. The "lease" argument is not
  * used for F_UNLCK requests and may be NULL. For commands that set or alter
@@ -1720,13 +1727,14 @@ static int __vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
  * stack trace).
  */
 
-int vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
+int
+vfs_setlease(struct file *filp, long arg, struct file_lock **lease, void **priv)
 {
 	struct inode *inode = file_inode(filp);
 	int error;
 
 	spin_lock(&inode->i_lock);
-	error = __vfs_setlease(filp, arg, lease);
+	error = __vfs_setlease(filp, arg, lease, priv);
 	spin_unlock(&inode->i_lock);
 
 	return error;
@@ -1751,7 +1759,7 @@ static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
 	}
 	ret = fl;
 	spin_lock(&inode->i_lock);
-	error = __vfs_setlease(filp, arg, &ret);
+	error = __vfs_setlease(filp, arg, &ret, NULL);
 	if (error)
 		goto out_unlock;
 	if (ret == fl)
@@ -1789,7 +1797,7 @@ out_unlock:
 int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
 {
 	if (arg == F_UNLCK)
-		return vfs_setlease(filp, F_UNLCK, NULL);
+		return vfs_setlease(filp, F_UNLCK, NULL, NULL);
 	return do_fcntl_add_lease(fd, filp, arg);
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d0a6e8e022a2..d964a41c9151 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -683,7 +683,7 @@ static void nfs4_put_deleg_lease(struct nfs4_file *fp)
 	if (!fp->fi_deleg_file)
 		return;
 	if (atomic_dec_and_test(&fp->fi_delegees)) {
-		vfs_setlease(fp->fi_deleg_file, F_UNLCK, NULL);
+		vfs_setlease(fp->fi_deleg_file, F_UNLCK, NULL, NULL);
 		fput(fp->fi_deleg_file);
 		fp->fi_deleg_file = NULL;
 	}
@@ -3788,7 +3788,7 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
 	}
 	fl->fl_file = filp;
 	ret = fl;
-	status = vfs_setlease(filp, fl->fl_type, &ret);
+	status = vfs_setlease(filp, fl->fl_type, &fl, NULL);
 	if (status) {
 		locks_free_lock(fl);
 		goto out_fput;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 96528f73dda4..f1870eb67b02 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -982,8 +982,8 @@ extern int vfs_cancel_lock(struct file *filp, struct file_lock *fl);
 extern int flock_lock_file_wait(struct file *filp, struct file_lock *fl);
 extern int __break_lease(struct inode *inode, unsigned int flags, unsigned int type);
 extern void lease_get_mtime(struct inode *, struct timespec *time);
-extern int generic_setlease(struct file *, long, struct file_lock **);
-extern int vfs_setlease(struct file *, long, struct file_lock **);
+extern int generic_setlease(struct file *, long, struct file_lock **, void **priv);
+extern int vfs_setlease(struct file *, long, struct file_lock **, void **);
 extern int lease_modify(struct file_lock **, int);
 #else /* !CONFIG_FILE_LOCKING */
 static inline int fcntl_getlk(struct file *file, unsigned int cmd,
@@ -1100,13 +1100,13 @@ static inline void lease_get_mtime(struct inode *inode, struct timespec *time)
 }
 
 static inline int generic_setlease(struct file *filp, long arg,
-				    struct file_lock **flp)
+				    struct file_lock **flp, void **priv)
 {
 	return -EINVAL;
 }
 
 static inline int vfs_setlease(struct file *filp, long arg,
-			       struct file_lock **lease)
+			       struct file_lock **lease, void **priv)
 {
 	return -EINVAL;
 }
@@ -1494,7 +1494,7 @@ struct file_operations {
 	int (*flock) (struct file *, int, struct file_lock *);
 	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
 	ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
-	int (*setlease)(struct file *, long, struct file_lock **);
+	int (*setlease)(struct file *, long, struct file_lock **, void **);
 	long (*fallocate)(struct file *file, int mode, loff_t offset,
 			  loff_t len);
 	int (*show_fdinfo)(struct seq_file *m, struct file *f);
@@ -2599,7 +2599,7 @@ extern int simple_write_end(struct file *file, struct address_space *mapping,
 			struct page *page, void *fsdata);
 extern int always_delete_dentry(const struct dentry *);
 extern struct inode *alloc_anon_inode(struct super_block *);
-extern int simple_nosetlease(struct file *, long, struct file_lock **);
+extern int simple_nosetlease(struct file *, long, struct file_lock **, void **);
 extern const struct dentry_operations simple_dentry_operations;
 
 extern struct dentry *simple_lookup(struct inode *, struct dentry *, unsigned int flags);
-- 
1.9.3


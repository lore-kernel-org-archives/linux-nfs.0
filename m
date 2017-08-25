Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38316 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756309AbdHYVwj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 25 Aug 2017 17:52:39 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/3] fs: hide another detail of delegation logic
Date: Fri, 25 Aug 2017 17:52:37 -0400
Message-Id: <1503697958-6122-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1503697958-6122-1-git-send-email-bfields@redhat.com>
References: <1503697958-6122-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Pass around a new struct deleg_break_ctl instead of pointers to inode
pointers; in a future patch I want to use this to pass a little more
information from the nfs server to the lease code.

No change in behavior.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/attr.c          | 10 +++++-----
 fs/namei.c         | 50 +++++++++++++++++++++++++-------------------------
 fs/open.c          | 12 ++++++------
 fs/utimes.c        |  6 +++---
 include/linux/fs.h | 34 ++++++++++++++++++++--------------
 5 files changed, 59 insertions(+), 53 deletions(-)

diff --git a/fs/attr.c b/fs/attr.c
index 135304146120..255315dbca32 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -185,23 +185,23 @@ EXPORT_SYMBOL(setattr_copy);
  * notify_change - modify attributes of a filesytem object
  * @dentry:	object affected
  * @iattr:	new attributes
- * @delegated_inode: returns inode, if the inode is delegated
+ * @deleg_break_ctl: used to return inode, if the inode is delegated
  *
  * The caller must hold the i_mutex on the affected object.
  *
  * If notify_change discovers a delegation in need of breaking,
  * it will return -EWOULDBLOCK and return a reference to the inode in
- * delegated_inode.  The caller should then break the delegation and
+ * deleg_break_ctl.  The caller should then break the delegation and
  * retry.  Because breaking a delegation may take a long time, the
  * caller should drop the i_mutex before doing so.
  *
- * Alternatively, a caller may pass NULL for delegated_inode.  This may
+ * Alternatively, a caller may pass NULL for deleg_break_ctl. This may
  * be appropriate for callers that expect the underlying filesystem not
  * to be NFS exported.  Also, passing NULL is fine for callers holding
  * the file open for write, as there can be no conflicting delegation in
  * that case.
  */
-int notify_change(struct dentry * dentry, struct iattr * attr, struct inode **delegated_inode)
+int notify_change(struct dentry * dentry, struct iattr * attr, struct deleg_break_ctl *deleg_break_ctl)
 {
 	struct inode *inode = dentry->d_inode;
 	umode_t mode = inode->i_mode;
@@ -304,7 +304,7 @@ int notify_change(struct dentry * dentry, struct iattr * attr, struct inode **de
 	error = security_inode_setattr(dentry, attr);
 	if (error)
 		return error;
-	error = try_break_deleg(inode, delegated_inode);
+	error = try_break_deleg(inode, deleg_break_ctl);
 	if (error)
 		return error;
 
diff --git a/fs/namei.c b/fs/namei.c
index 5a93be7b2c9c..a75ab583aee7 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3941,21 +3941,21 @@ SYSCALL_DEFINE1(rmdir, const char __user *, pathname)
  * vfs_unlink - unlink a filesystem object
  * @dir:	parent directory
  * @dentry:	victim
- * @delegated_inode: returns victim inode, if the inode is delegated.
+ * @deleg_break_ctl: used to return victim inode, if the inode is delegated.
  *
  * The caller must hold dir->i_mutex.
  *
  * If vfs_unlink discovers a delegation, it will return -EWOULDBLOCK and
- * return a reference to the inode in delegated_inode.  The caller
+ * return a reference to the inode in deleg_break_ctl.  The caller
  * should then break the delegation on that inode and retry.  Because
  * breaking a delegation may take a long time, the caller should drop
  * dir->i_mutex before doing so.
  *
- * Alternatively, a caller may pass NULL for delegated_inode.  This may
+ * Alternatively, a caller may pass NULL for deleg_break_ctl.  This may
  * be appropriate for callers that expect the underlying filesystem not
  * to be NFS exported.
  */
-int vfs_unlink(struct inode *dir, struct dentry *dentry, struct inode **delegated_inode)
+int vfs_unlink(struct inode *dir, struct dentry *dentry, struct deleg_break_ctl *deleg_break_ctl)
 {
 	struct inode *target = dentry->d_inode;
 	int error = may_delete(dir, dentry, 0);
@@ -3972,7 +3972,7 @@ int vfs_unlink(struct inode *dir, struct dentry *dentry, struct inode **delegate
 	else {
 		error = security_inode_unlink(dir, dentry);
 		if (!error) {
-			error = try_break_deleg(target, delegated_inode);
+			error = try_break_deleg(target, deleg_break_ctl);
 			if (error)
 				goto out;
 			error = dir->i_op->unlink(dir, dentry);
@@ -4010,7 +4010,7 @@ static long do_unlinkat(int dfd, const char __user *pathname)
 	struct qstr last;
 	int type;
 	struct inode *inode = NULL;
-	struct inode *delegated_inode = NULL;
+	struct deleg_break_ctl deleg_break_ctl = {};
 	unsigned int lookup_flags = 0;
 retry:
 	name = filename_parentat(dfd, getname(pathname), lookup_flags,
@@ -4040,7 +4040,7 @@ static long do_unlinkat(int dfd, const char __user *pathname)
 		error = security_path_unlink(&path, dentry);
 		if (error)
 			goto exit2;
-		error = vfs_unlink(path.dentry->d_inode, dentry, &delegated_inode);
+		error = vfs_unlink(path.dentry->d_inode, dentry, &deleg_break_ctl);
 exit2:
 		dput(dentry);
 	}
@@ -4048,7 +4048,7 @@ static long do_unlinkat(int dfd, const char __user *pathname)
 	if (inode)
 		iput(inode);	/* truncate the inode here */
 	inode = NULL;
-	error = break_deleg_wait(&delegated_inode, error);
+	error = break_deleg_wait(&deleg_break_ctl, error);
 	if (error == DELEG_RETRY)
 		goto retry_deleg;
 	mnt_drop_write(path.mnt);
@@ -4150,21 +4150,21 @@ SYSCALL_DEFINE2(symlink, const char __user *, oldname, const char __user *, newn
  * @old_dentry:	object to be linked
  * @dir:	new parent
  * @new_dentry:	where to create the new link
- * @delegated_inode: returns inode needing a delegation break
+ * @deleg_break_ctl: returns inode needing a delegation break
  *
  * The caller must hold dir->i_mutex
  *
  * If vfs_link discovers a delegation on the to-be-linked file in need
  * of breaking, it will return -EWOULDBLOCK and return a reference to the
- * inode in delegated_inode.  The caller should then break the delegation
+ * inode in deleg_break_ctl.  The caller should then break the delegation
  * and retry.  Because breaking a delegation may take a long time, the
  * caller should drop the i_mutex before doing so.
  *
- * Alternatively, a caller may pass NULL for delegated_inode.  This may
+ * Alternatively, a caller may pass NULL for deleg_break_ctl.  This may
  * be appropriate for callers that expect the underlying filesystem not
  * to be NFS exported.
  */
-int vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *new_dentry, struct inode **delegated_inode)
+int vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *new_dentry, struct deleg_break_ctl *deleg_break_ctl)
 {
 	struct inode *inode = old_dentry->d_inode;
 	unsigned max_links = dir->i_sb->s_max_links;
@@ -4208,7 +4208,7 @@ int vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *new_de
 	else if (max_links && inode->i_nlink >= max_links)
 		error = -EMLINK;
 	else {
-		error = try_break_deleg(inode, delegated_inode);
+		error = try_break_deleg(inode, deleg_break_ctl);
 		if (!error)
 			error = dir->i_op->link(old_dentry, dir, new_dentry);
 	}
@@ -4239,7 +4239,7 @@ SYSCALL_DEFINE5(linkat, int, olddfd, const char __user *, oldname,
 {
 	struct dentry *new_dentry;
 	struct path old_path, new_path;
-	struct inode *delegated_inode = NULL;
+	struct deleg_break_ctl deleg_break_ctl = {};
 	int how = 0;
 	int error;
 
@@ -4278,10 +4278,10 @@ SYSCALL_DEFINE5(linkat, int, olddfd, const char __user *, oldname,
 	error = security_path_link(old_path.dentry, &new_path, new_dentry);
 	if (error)
 		goto out_dput;
-	error = vfs_link(old_path.dentry, new_path.dentry->d_inode, new_dentry, &delegated_inode);
+	error = vfs_link(old_path.dentry, new_path.dentry->d_inode, new_dentry, &deleg_break_ctl);
 out_dput:
 	done_path_create(&new_path, new_dentry);
-	error = break_deleg_wait(&delegated_inode, error);
+	error = break_deleg_wait(&deleg_break_ctl, error);
 	if (error == DELEG_RETRY) {
 		path_put(&old_path);
 		goto retry;
@@ -4308,19 +4308,19 @@ SYSCALL_DEFINE2(link, const char __user *, oldname, const char __user *, newname
  * @old_dentry:	source
  * @new_dir:	parent of destination
  * @new_dentry:	destination
- * @delegated_inode: returns an inode needing a delegation break
+ * @deleg_break_ctl: used to return an inode needing a delegation break
  * @flags:	rename flags
  *
  * The caller must hold multiple mutexes--see lock_rename()).
  *
  * If vfs_rename discovers a delegation in need of breaking at either
  * the source or destination, it will return -EWOULDBLOCK and return a
- * reference to the inode in delegated_inode.  The caller should then
+ * reference to the inode in deleg_break_ctl.  The caller should then
  * break the delegation and retry.  Because breaking a delegation may
  * take a long time, the caller should drop all locks before doing
  * so.
  *
- * Alternatively, a caller may pass NULL for delegated_inode.  This may
+ * Alternatively, a caller may pass NULL for deleg_break_ctl.  This may
  * be appropriate for callers that expect the underlying filesystem not
  * to be NFS exported.
  *
@@ -4354,7 +4354,7 @@ SYSCALL_DEFINE2(link, const char __user *, oldname, const char __user *, newname
  */
 int vfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	       struct inode *new_dir, struct dentry *new_dentry,
-	       struct inode **delegated_inode, unsigned int flags)
+	       struct deleg_break_ctl *deleg_break_ctl, unsigned int flags)
 {
 	int error;
 	bool is_dir = d_is_dir(old_dentry);
@@ -4431,12 +4431,12 @@ int vfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	if (is_dir && !(flags & RENAME_EXCHANGE) && target)
 		shrink_dcache_parent(new_dentry);
 	if (!is_dir) {
-		error = try_break_deleg(source, delegated_inode);
+		error = try_break_deleg(source, deleg_break_ctl);
 		if (error)
 			goto out;
 	}
 	if (target && !new_is_dir) {
-		error = try_break_deleg(target, delegated_inode);
+		error = try_break_deleg(target, deleg_break_ctl);
 		if (error)
 			goto out;
 	}
@@ -4485,7 +4485,7 @@ SYSCALL_DEFINE5(renameat2, int, olddfd, const char __user *, oldname,
 	struct path old_path, new_path;
 	struct qstr old_last, new_last;
 	int old_type, new_type;
-	struct inode *delegated_inode = NULL;
+	struct deleg_break_ctl deleg_break_ctl = {};
 	struct filename *from;
 	struct filename *to;
 	unsigned int lookup_flags = 0, target_flags = LOOKUP_RENAME_TARGET;
@@ -4590,14 +4590,14 @@ SYSCALL_DEFINE5(renameat2, int, olddfd, const char __user *, oldname,
 		goto exit5;
 	error = vfs_rename(old_path.dentry->d_inode, old_dentry,
 			   new_path.dentry->d_inode, new_dentry,
-			   &delegated_inode, flags);
+			   &deleg_break_ctl, flags);
 exit5:
 	dput(new_dentry);
 exit4:
 	dput(old_dentry);
 exit3:
 	unlock_rename(new_path.dentry, old_path.dentry);
-	error = break_deleg_wait(&delegated_inode, error);
+	error = break_deleg_wait(&deleg_break_ctl, error);
 	if (error == DELEG_RETRY)
 		goto retry_deleg;
 	mnt_drop_write(old_path.mnt);
diff --git a/fs/open.c b/fs/open.c
index d49e9385e45d..6c6443476316 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -515,7 +515,7 @@ SYSCALL_DEFINE1(chroot, const char __user *, filename)
 static int chmod_common(const struct path *path, umode_t mode)
 {
 	struct inode *inode = path->dentry->d_inode;
-	struct inode *delegated_inode = NULL;
+	struct deleg_break_ctl deleg_break_ctl = {};
 	struct iattr newattrs;
 	int error;
 
@@ -529,10 +529,10 @@ static int chmod_common(const struct path *path, umode_t mode)
 		goto out_unlock;
 	newattrs.ia_mode = (mode & S_IALLUGO) | (inode->i_mode & ~S_IALLUGO);
 	newattrs.ia_valid = ATTR_MODE | ATTR_CTIME;
-	error = notify_change(path->dentry, &newattrs, &delegated_inode);
+	error = notify_change(path->dentry, &newattrs, &deleg_break_ctl);
 out_unlock:
 	inode_unlock(inode);
-	error = break_deleg_wait(&delegated_inode, error);
+	error = break_deleg_wait(&deleg_break_ctl, error);
 	if (error == DELEG_RETRY)
 		goto retry_deleg;
 	mnt_drop_write(path->mnt);
@@ -578,7 +578,7 @@ SYSCALL_DEFINE2(chmod, const char __user *, filename, umode_t, mode)
 static int chown_common(const struct path *path, uid_t user, gid_t group)
 {
 	struct inode *inode = path->dentry->d_inode;
-	struct inode *delegated_inode = NULL;
+	struct deleg_break_ctl deleg_break_ctl = {};
 	int error;
 	struct iattr newattrs;
 	kuid_t uid;
@@ -607,9 +607,9 @@ static int chown_common(const struct path *path, uid_t user, gid_t group)
 	inode_lock(inode);
 	error = security_path_chown(path, uid, gid);
 	if (!error)
-		error = notify_change(path->dentry, &newattrs, &delegated_inode);
+		error = notify_change(path->dentry, &newattrs, &deleg_break_ctl);
 	inode_unlock(inode);
-	error = break_deleg_wait(&delegated_inode, error);
+	error = break_deleg_wait(&deleg_break_ctl, error);
 	if (error == DELEG_RETRY)
 		goto retry_deleg;
 	return error;
diff --git a/fs/utimes.c b/fs/utimes.c
index 75467b7ebfce..9af7ca3810db 100644
--- a/fs/utimes.c
+++ b/fs/utimes.c
@@ -49,7 +49,7 @@ static int utimes_common(const struct path *path, struct timespec *times)
 	int error;
 	struct iattr newattrs;
 	struct inode *inode = path->dentry->d_inode;
-	struct inode *delegated_inode = NULL;
+	struct deleg_break_ctl deleg_break_ctl = {};
 
 	error = mnt_want_write(path->mnt);
 	if (error)
@@ -87,9 +87,9 @@ static int utimes_common(const struct path *path, struct timespec *times)
 	}
 retry_deleg:
 	inode_lock(inode);
-	error = notify_change(path->dentry, &newattrs, &delegated_inode);
+	error = notify_change(path->dentry, &newattrs, &deleg_break_ctl);
 	inode_unlock(inode);
-	error = break_deleg_wait(&delegated_inode, error);
+	error = break_deleg_wait(&deleg_break_ctl, error);
 	if (error == DELEG_RETRY)
 		goto retry_deleg;
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 1d0d2fde1766..20a07375e60c 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1564,6 +1564,11 @@ static inline void sb_start_intwrite(struct super_block *sb)
 
 extern bool inode_owner_or_capable(const struct inode *inode);
 
+/* Used to pass some information used by NFSv4 delegations */
+struct deleg_break_ctl {
+	struct inode *delegated_inode; /* inode with in-progress break */
+};
+
 /*
  * VFS helper functions..
  */
@@ -1571,10 +1576,10 @@ extern int vfs_create(struct inode *, struct dentry *, umode_t, bool);
 extern int vfs_mkdir(struct inode *, struct dentry *, umode_t);
 extern int vfs_mknod(struct inode *, struct dentry *, umode_t, dev_t);
 extern int vfs_symlink(struct inode *, struct dentry *, const char *);
-extern int vfs_link(struct dentry *, struct inode *, struct dentry *, struct inode **);
+extern int vfs_link(struct dentry *, struct inode *, struct dentry *, struct deleg_break_ctl *);
 extern int vfs_rmdir(struct inode *, struct dentry *);
-extern int vfs_unlink(struct inode *, struct dentry *, struct inode **);
-extern int vfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *, struct inode **, unsigned int);
+extern int vfs_unlink(struct inode *, struct dentry *, struct deleg_break_ctl *);
+extern int vfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *, struct deleg_break_ctl *, unsigned int);
 extern int vfs_whiteout(struct inode *, struct dentry *);
 
 extern struct dentry *vfs_tmpfile(struct dentry *dentry, umode_t mode,
@@ -2276,13 +2281,13 @@ static inline int break_deleg(struct inode *inode, unsigned int mode)
 	return 0;
 }
 
-static inline int try_break_deleg(struct inode *inode, struct inode **delegated_inode)
+static inline int try_break_deleg(struct inode *inode, struct deleg_break_ctl *deleg_break_ctl)
 {
 	int ret;
 
 	ret = break_deleg(inode, O_WRONLY|O_NONBLOCK);
-	if (ret == -EWOULDBLOCK && delegated_inode) {
-		*delegated_inode = inode;
+	if (ret == -EWOULDBLOCK && deleg_break_ctl) {
+		deleg_break_ctl->delegated_inode = inode;
 		ihold(inode);
 	}
 	return ret;
@@ -2290,13 +2295,14 @@ static inline int try_break_deleg(struct inode *inode, struct inode **delegated_
 
 #define DELEG_RETRY 1
 
-static inline int break_deleg_wait(struct inode **delegated_inode, int error)
+static inline int break_deleg_wait(struct deleg_break_ctl *deleg_break_ctl, int error)
 {
-	if (!*delegated_inode)
+	if (!deleg_break_ctl->delegated_inode)
 		return error;
-	error = break_deleg(*delegated_inode, O_WRONLY);
-	iput(*delegated_inode);
-	*delegated_inode = NULL;
+
+	error = break_deleg(deleg_break_ctl->delegated_inode, O_WRONLY);
+	iput(deleg_break_ctl->delegated_inode);
+	deleg_break_ctl->delegated_inode = NULL;
 	return error ? error : DELEG_RETRY;
 }
 
@@ -2321,12 +2327,12 @@ static inline int break_deleg(struct inode *inode, unsigned int mode)
 	return 0;
 }
 
-static inline int try_break_deleg(struct inode *inode, struct inode **delegated_inode)
+static inline int try_break_deleg(struct inode *inode, struct deleg_break_ctl *deleg_break_ctl)
 {
 	return 0;
 }
 
-static inline int break_deleg_wait(struct inode **delegated_inode)
+static inline int break_deleg_wait(struct deleg_break_ctl *deleg_break_ctl, int error)
 {
 	BUG();
 	return 0;
@@ -2639,7 +2645,7 @@ extern void emergency_remount(void);
 #ifdef CONFIG_BLOCK
 extern sector_t bmap(struct inode *, sector_t);
 #endif
-extern int notify_change(struct dentry *, struct iattr *, struct inode **);
+extern int notify_change(struct dentry *, struct iattr *, struct deleg_break_ctl *);
 extern int inode_permission(struct inode *, int);
 extern int __inode_permission(struct inode *, int);
 extern int generic_permission(struct inode *, int);
-- 
2.13.5


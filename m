Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:41191 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932737Ab2KEPW2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Nov 2012 10:22:28 -0500
Received: by mail-gh0-f174.google.com with SMTP id g15so1012581ghb.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Nov 2012 07:22:28 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v9 04/34] vfs: add new "reval" argument to kern_path_create and user_path_create
Date: Mon,  5 Nov 2012 10:21:43 -0500
Message-Id: <1352128933-28526-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
References: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...for now, all of the callers pass in "false". Eventually, we'll set
that to "true" when we retry the lookup after getting back an ESTALE on
a call.

While we're at it, change the is_dir arg to a bool since that's how it's
used currently.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 arch/powerpc/platforms/cell/spufs/syscalls.c |  2 +-
 drivers/base/devtmpfs.c                      |  7 ++++---
 fs/namei.c                                   | 23 +++++++++++++++--------
 fs/ocfs2/refcounttree.c                      |  3 ++-
 include/linux/namei.h                        |  4 ++--
 net/unix/af_unix.c                           |  2 +-
 6 files changed, 25 insertions(+), 16 deletions(-)

diff --git a/arch/powerpc/platforms/cell/spufs/syscalls.c b/arch/powerpc/platforms/cell/spufs/syscalls.c
index 5b7d8ff..cb4acc7 100644
--- a/arch/powerpc/platforms/cell/spufs/syscalls.c
+++ b/arch/powerpc/platforms/cell/spufs/syscalls.c
@@ -66,7 +66,7 @@ static long do_spu_create(const char __user *pathname, unsigned int flags,
 	struct dentry *dentry;
 	int ret;
 
-	dentry = user_path_create(AT_FDCWD, pathname, &path, 1);
+	dentry = user_path_create(AT_FDCWD, pathname, &path, true, false);
 	ret = PTR_ERR(dentry);
 	if (!IS_ERR(dentry)) {
 		ret = spufs_create(&path, dentry, flags, mode, neighbor);
diff --git a/drivers/base/devtmpfs.c b/drivers/base/devtmpfs.c
index 147d1a4..128e156 100644
--- a/drivers/base/devtmpfs.c
+++ b/drivers/base/devtmpfs.c
@@ -148,7 +148,7 @@ static int dev_mkdir(const char *name, umode_t mode)
 	struct path path;
 	int err;
 
-	dentry = kern_path_create(AT_FDCWD, name, &path, 1);
+	dentry = kern_path_create(AT_FDCWD, name, &path, true, false);
 	if (IS_ERR(dentry))
 		return PTR_ERR(dentry);
 
@@ -193,10 +193,11 @@ static int handle_create(const char *nodename, umode_t mode, struct device *dev)
 	struct path path;
 	int err;
 
-	dentry = kern_path_create(AT_FDCWD, nodename, &path, 0);
+	dentry = kern_path_create(AT_FDCWD, nodename, &path, false, false);
 	if (dentry == ERR_PTR(-ENOENT)) {
 		create_path(nodename);
-		dentry = kern_path_create(AT_FDCWD, nodename, &path, 0);
+		dentry = kern_path_create(AT_FDCWD, nodename, &path,
+								false, false);
 	}
 	if (IS_ERR(dentry))
 		return PTR_ERR(dentry);
diff --git a/fs/namei.c b/fs/namei.c
index 937f9d5..8618a47 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3039,12 +3039,18 @@ struct file *do_file_open_root(struct dentry *dentry, struct vfsmount *mnt,
 	return file;
 }
 
-struct dentry *kern_path_create(int dfd, const char *pathname, struct path *path, int is_dir)
+struct dentry *kern_path_create(int dfd, const char *pathname, struct path *path, bool is_dir, bool reval)
 {
 	struct dentry *dentry = ERR_PTR(-EEXIST);
 	struct nameidata nd;
 	int err2;
-	int error = do_path_lookup(dfd, pathname, LOOKUP_PARENT, &nd);
+	int error;
+	unsigned int lookup_flags = LOOKUP_PARENT;
+
+	if (reval)
+		lookup_flags |= LOOKUP_REVAL;
+
+	error = do_path_lookup(dfd, pathname, lookup_flags, &nd);
 	if (error)
 		return ERR_PTR(error);
 
@@ -3108,13 +3114,14 @@ void done_path_create(struct path *path, struct dentry *dentry)
 }
 EXPORT_SYMBOL(done_path_create);
 
-struct dentry *user_path_create(int dfd, const char __user *pathname, struct path *path, int is_dir)
+struct dentry *user_path_create(int dfd, const char __user *pathname,
+				struct path *path, bool is_dir, bool reval)
 {
 	struct filename *tmp = getname(pathname);
 	struct dentry *res;
 	if (IS_ERR(tmp))
 		return ERR_CAST(tmp);
-	res = kern_path_create(dfd, tmp->name, path, is_dir);
+	res = kern_path_create(dfd, tmp->name, path, is_dir, reval);
 	putname(tmp);
 	return res;
 }
@@ -3175,7 +3182,7 @@ SYSCALL_DEFINE4(mknodat, int, dfd, const char __user *, filename, umode_t, mode,
 	if (error)
 		return error;
 
-	dentry = user_path_create(dfd, filename, &path, 0);
+	dentry = user_path_create(dfd, filename, &path, false, false);
 	if (IS_ERR(dentry))
 		return PTR_ERR(dentry);
 
@@ -3237,7 +3244,7 @@ SYSCALL_DEFINE3(mkdirat, int, dfd, const char __user *, pathname, umode_t, mode)
 	struct path path;
 	int error;
 
-	dentry = user_path_create(dfd, pathname, &path, 1);
+	dentry = user_path_create(dfd, pathname, &path, true, false);
 	if (IS_ERR(dentry))
 		return PTR_ERR(dentry);
 
@@ -3513,7 +3520,7 @@ SYSCALL_DEFINE3(symlinkat, const char __user *, oldname,
 	if (IS_ERR(from))
 		return PTR_ERR(from);
 
-	dentry = user_path_create(newdfd, newname, &path, 0);
+	dentry = user_path_create(newdfd, newname, &path, false, false);
 	error = PTR_ERR(dentry);
 	if (IS_ERR(dentry))
 		goto out_putname;
@@ -3613,7 +3620,7 @@ SYSCALL_DEFINE5(linkat, int, olddfd, const char __user *, oldname,
 	if (error)
 		return error;
 
-	new_dentry = user_path_create(newdfd, newname, &new_path, 0);
+	new_dentry = user_path_create(newdfd, newname, &new_path, false, false);
 	error = PTR_ERR(new_dentry);
 	if (IS_ERR(new_dentry))
 		goto out;
diff --git a/fs/ocfs2/refcounttree.c b/fs/ocfs2/refcounttree.c
index 30a0550..645e225 100644
--- a/fs/ocfs2/refcounttree.c
+++ b/fs/ocfs2/refcounttree.c
@@ -4453,7 +4453,8 @@ int ocfs2_reflink_ioctl(struct inode *inode,
 		return error;
 	}
 
-	new_dentry = user_path_create(AT_FDCWD, newname, &new_path, 0);
+	new_dentry = user_path_create(AT_FDCWD, newname, &new_path,
+					false, false);
 	error = PTR_ERR(new_dentry);
 	if (IS_ERR(new_dentry)) {
 		mlog_errno(error);
diff --git a/include/linux/namei.h b/include/linux/namei.h
index 4bf19d8..2202740 100644
--- a/include/linux/namei.h
+++ b/include/linux/namei.h
@@ -65,8 +65,8 @@ extern int user_path_at_empty(int, const char __user *, unsigned, struct path *,
 
 extern int kern_path(const char *, unsigned, struct path *);
 
-extern struct dentry *kern_path_create(int, const char *, struct path *, int);
-extern struct dentry *user_path_create(int, const char __user *, struct path *, int);
+extern struct dentry *kern_path_create(int, const char *, struct path *, bool, bool);
+extern struct dentry *user_path_create(int, const char __user *, struct path *, bool, bool);
 extern void done_path_create(struct path *, struct dentry *);
 extern struct dentry *kern_path_locked(const char *, struct path *);
 extern int vfs_path_lookup(struct dentry *, struct vfsmount *,
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 5b5c876..8ce6209 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -829,7 +829,7 @@ static int unix_mknod(const char *sun_path, umode_t mode, struct path *res)
 	 * Get the parent directory, calculate the hash for last
 	 * component.
 	 */
-	dentry = kern_path_create(AT_FDCWD, sun_path, &path, 0);
+	dentry = kern_path_create(AT_FDCWD, sun_path, &path, false, false);
 	err = PTR_ERR(dentry);
 	if (IS_ERR(dentry))
 		return err;
-- 
1.7.11.7


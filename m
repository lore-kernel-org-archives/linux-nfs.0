Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gy0-f174.google.com ([209.85.160.174]:50296 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590Ab2DZQ6m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Apr 2012 12:58:42 -0400
Received: by ghrr11 with SMTP id r11so1080149ghr.19
        for <linux-nfs@vger.kernel.org>; Thu, 26 Apr 2012 09:58:41 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, miklos@szeredi.hu, hch@infradead.org,
        michael.brantley@deshaw.com
Subject: [PATCH v1 04/12] vfs: add new "reval" argument to kern_path_create and user_path_create
Date: Thu, 26 Apr 2012 11:57:15 -0400
Message-Id: <1335455843-16089-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1335455843-16089-1-git-send-email-jlayton@redhat.com>
References: <1335455843-16089-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...for now, all of the callers pass in "false". Eventually, we'll set
that to "true" when we retry the lookup after getting back an ESTALE on
a call.

While we're at it, change the is_dir arg to a bool since that's how
it's used currently.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 arch/powerpc/platforms/cell/spufs/syscalls.c |    2 +-
 drivers/base/devtmpfs.c                      |    7 ++++---
 fs/namei.c                                   |   22 ++++++++++++++--------
 fs/ocfs2/refcounttree.c                      |    3 ++-
 include/linux/namei.h                        |    4 ++--
 net/unix/af_unix.c                           |    3 ++-
 6 files changed, 25 insertions(+), 16 deletions(-)

diff --git a/arch/powerpc/platforms/cell/spufs/syscalls.c b/arch/powerpc/platforms/cell/spufs/syscalls.c
index 5665dcc..3c222cc 100644
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
index 8493536..70eb0b0 100644
--- a/drivers/base/devtmpfs.c
+++ b/drivers/base/devtmpfs.c
@@ -148,7 +148,7 @@ static int dev_mkdir(const char *name, umode_t mode)
 	struct path path;
 	int err;
 
-	dentry = kern_path_create(AT_FDCWD, name, &path, 1);
+	dentry = kern_path_create(AT_FDCWD, name, &path, false, false);
 	if (IS_ERR(dentry))
 		return PTR_ERR(dentry);
 
@@ -195,10 +195,11 @@ static int handle_create(const char *nodename, umode_t mode, struct device *dev)
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
index 0062dd1..367b0f2 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2460,11 +2460,17 @@ struct file *do_file_open_root(struct dentry *dentry, struct vfsmount *mnt,
 	return file;
 }
 
-struct dentry *kern_path_create(int dfd, const char *pathname, struct path *path, int is_dir)
+struct dentry *kern_path_create(int dfd, const char *pathname, struct path *path, bool is_dir, bool reval)
 {
 	struct dentry *dentry = ERR_PTR(-EEXIST);
 	struct nameidata nd;
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
 
@@ -2512,13 +2518,13 @@ out:
 }
 EXPORT_SYMBOL(kern_path_create);
 
-struct dentry *user_path_create(int dfd, const char __user *pathname, struct path *path, int is_dir)
+struct dentry *user_path_create(int dfd, const char __user *pathname, struct path *path, bool is_dir, bool reval)
 {
 	char *tmp = getname(pathname);
 	struct dentry *res;
 	if (IS_ERR(tmp))
 		return ERR_CAST(tmp);
-	res = kern_path_create(dfd, tmp, path, is_dir);
+	res = kern_path_create(dfd, tmp, path, is_dir, reval);
 	putname(tmp);
 	return res;
 }
@@ -2579,7 +2585,7 @@ SYSCALL_DEFINE4(mknodat, int, dfd, const char __user *, filename, umode_t, mode,
 	if (S_ISDIR(mode))
 		return -EPERM;
 
-	dentry = user_path_create(dfd, filename, &path, 0);
+	dentry = user_path_create(dfd, filename, &path, false, false);
 	if (IS_ERR(dentry))
 		return PTR_ERR(dentry);
 
@@ -2652,7 +2658,7 @@ SYSCALL_DEFINE3(mkdirat, int, dfd, const char __user *, pathname, umode_t, mode)
 	struct path path;
 	int error;
 
-	dentry = user_path_create(dfd, pathname, &path, 1);
+	dentry = user_path_create(dfd, pathname, &path, true, false);
 	if (IS_ERR(dentry))
 		return PTR_ERR(dentry);
 
@@ -2939,7 +2945,7 @@ SYSCALL_DEFINE3(symlinkat, const char __user *, oldname,
 	if (IS_ERR(from))
 		return PTR_ERR(from);
 
-	dentry = user_path_create(newdfd, newname, &path, 0);
+	dentry = user_path_create(newdfd, newname, &path, false, false);
 	error = PTR_ERR(dentry);
 	if (IS_ERR(dentry))
 		goto out_putname;
@@ -3048,7 +3054,7 @@ SYSCALL_DEFINE5(linkat, int, olddfd, const char __user *, oldname,
 	if (error)
 		return error;
 
-	new_dentry = user_path_create(newdfd, newname, &new_path, 0);
+	new_dentry = user_path_create(newdfd, newname, &new_path, false, false);
 	error = PTR_ERR(new_dentry);
 	if (IS_ERR(new_dentry))
 		goto out;
diff --git a/fs/ocfs2/refcounttree.c b/fs/ocfs2/refcounttree.c
index 9f32d7c..b52b24d 100644
--- a/fs/ocfs2/refcounttree.c
+++ b/fs/ocfs2/refcounttree.c
@@ -4453,7 +4453,8 @@ int ocfs2_reflink_ioctl(struct inode *inode,
 		return error;
 	}
 
-	new_dentry = user_path_create(AT_FDCWD, newname, &new_path, 0);
+	new_dentry = user_path_create(AT_FDCWD, newname, &new_path,
+								false, false);
 	error = PTR_ERR(new_dentry);
 	if (IS_ERR(new_dentry)) {
 		mlog_errno(error);
diff --git a/include/linux/namei.h b/include/linux/namei.h
index ffc0213..3e90dcd 100644
--- a/include/linux/namei.h
+++ b/include/linux/namei.h
@@ -76,8 +76,8 @@ extern int user_path_at_empty(int, const char __user *, unsigned, struct path *,
 
 extern int kern_path(const char *, unsigned, struct path *);
 
-extern struct dentry *kern_path_create(int, const char *, struct path *, int);
-extern struct dentry *user_path_create(int, const char __user *, struct path *, int);
+extern struct dentry *kern_path_create(int, const char *, struct path *, bool, bool);
+extern struct dentry *user_path_create(int, const char __user *, struct path *, bool, bool);
 extern int kern_path_parent(const char *, struct nameidata *);
 extern int vfs_path_lookup(struct dentry *, struct vfsmount *,
 			   const char *, unsigned int, struct path *);
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index d510353..9951294 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -865,7 +865,8 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		 * Get the parent directory, calculate the hash for last
 		 * component.
 		 */
-		dentry = kern_path_create(AT_FDCWD, sun_path, &path, 0);
+		dentry = kern_path_create(AT_FDCWD, sun_path, &path,
+								false, false);
 		err = PTR_ERR(dentry);
 		if (IS_ERR(dentry))
 			goto out_mknod_parent;
-- 
1.7.7.6


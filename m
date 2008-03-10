From: Peter Staubach <staubach@redhat.com>
Subject: [PATCH 2/3] enhanced syscall ESTALE error handling (v3)
Date: Mon, 10 Mar 2008 16:23:39 -0400
Message-ID: <47D598CB.8050701@redhat.com>
References: <4790C768.4080207@redhat.com> <47A387D4.70605@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050606040007090607010506"
Cc: linux-nfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41853 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756095AbYCJUYY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Mar 2008 16:24:24 -0400
In-Reply-To: <47A387D4.70605@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050606040007090607010506
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi.

This patch adds handling for the error, ESTALE, to the system
calls which take pathnames as arguments.  The algorithm used
is to detect that an ESTALE error has occurred during an
operation subsequent to the lookup process and then to unwind
appropriately and then to perform the lookup process again.
Eventually, either the lookup process will return an error
or a valid dentry/inode combination and then operation can
succeed or fail based on its own merits.

A partial list of the updated system calls are stat, stat64,
lstat, lstat64, mkdir, link, open, access, chmod, chown,
readlink, utime, utimes, chdir, chroot, rename, exec, mknod,
statfs, inotify, setxattr, getxattr, and listxattr.  Due to
common code factoring, other system calls may have been
included too, but were not explicitly tested.

    Thanx...

        ps

Signed-off-by: Peter Staubach <staubach@redhat.com>

--------------050606040007090607010506
Content-Type: text/plain;
 name="estale.syscall.3"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="estale.syscall.3"

--- linux-2.6.24.i686/fs/namei.c.org
+++ linux-2.6.24.i686/fs/namei.c
@@ -1958,6 +1984,7 @@ asmlinkage long sys_mknodat(int dfd, con
 	if (IS_ERR(tmp))
 		return PTR_ERR(tmp);
 
+top:
 	error = do_path_lookup(dfd, tmp, LOOKUP_PARENT, &nd);
 	if (error)
 		goto out;
@@ -1988,6 +2015,8 @@ asmlinkage long sys_mknodat(int dfd, con
 	}
 	mutex_unlock(&nd.path.dentry->d_inode->i_mutex);
 	path_put(&nd.path);
+	if (error == -ESTALE)
+		goto top;
 out:
 	putname(tmp);
 
@@ -2023,8 +2052,8 @@ int vfs_mkdir(struct inode *dir, struct 
 
 asmlinkage long sys_mkdirat(int dfd, const char __user *pathname, int mode)
 {
-	int error = 0;
-	char * tmp;
+	int error;
+	char *tmp;
 	struct dentry *dentry;
 	struct nameidata nd;
 
@@ -2033,6 +2062,7 @@ asmlinkage long sys_mkdirat(int dfd, con
 	if (IS_ERR(tmp))
 		goto out_err;
 
+top:
 	error = do_path_lookup(dfd, tmp, LOOKUP_PARENT, &nd);
 	if (error)
 		goto out;
@@ -2048,6 +2078,8 @@ asmlinkage long sys_mkdirat(int dfd, con
 out_unlock:
 	mutex_unlock(&nd.path.dentry->d_inode->i_mutex);
 	path_put(&nd.path);
+	if (error == -ESTALE)
+		goto top;
 out:
 	putname(tmp);
 out_err:
@@ -2127,23 +2159,24 @@ static long do_rmdir(int dfd, const char
 	struct nameidata nd;
 
 	name = getname(pathname);
-	if(IS_ERR(name))
+	if (IS_ERR(name))
 		return PTR_ERR(name);
 
+top:
 	error = do_path_lookup(dfd, name, LOOKUP_PARENT, &nd);
 	if (error)
 		goto exit;
 
-	switch(nd.last_type) {
-		case LAST_DOTDOT:
-			error = -ENOTEMPTY;
-			goto exit1;
-		case LAST_DOT:
-			error = -EINVAL;
-			goto exit1;
-		case LAST_ROOT:
-			error = -EBUSY;
-			goto exit1;
+	switch (nd.last_type) {
+	case LAST_DOTDOT:
+		error = -ENOTEMPTY;
+		goto exit1;
+	case LAST_DOT:
+		error = -EINVAL;
+		goto exit1;
+	case LAST_ROOT:
+		error = -EBUSY;
+		goto exit1;
 	}
 	mutex_lock_nested(&nd.path.dentry->d_inode->i_mutex, I_MUTEX_PARENT);
 	dentry = lookup_hash(&nd);
@@ -2156,6 +2189,8 @@ exit2:
 	mutex_unlock(&nd.path.dentry->d_inode->i_mutex);
 exit1:
 	path_put(&nd.path);
+	if (error == -ESTALE)
+		goto top;
 exit:
 	putname(name);
 	return error;
@@ -2209,12 +2244,14 @@ static long do_unlinkat(int dfd, const c
 	char * name;
 	struct dentry *dentry;
 	struct nameidata nd;
-	struct inode *inode = NULL;
+	struct inode *inode;
 
 	name = getname(pathname);
 	if(IS_ERR(name))
 		return PTR_ERR(name);
 
+top:
+	inode = NULL;
 	error = do_path_lookup(dfd, name, LOOKUP_PARENT, &nd);
 	if (error)
 		goto exit;
@@ -2240,6 +2277,8 @@ static long do_unlinkat(int dfd, const c
 		iput(inode);	/* truncate the inode here */
 exit1:
 	path_put(&nd.path);
+	if (error == -ESTALE)
+		goto top;
 exit:
 	putname(name);
 	return error;
@@ -2304,6 +2343,7 @@ asmlinkage long sys_symlinkat(const char
 	if (IS_ERR(to))
 		goto out_putname;
 
+top:
 	error = do_path_lookup(newdfd, to, LOOKUP_PARENT, &nd);
 	if (error)
 		goto out;
@@ -2317,6 +2357,8 @@ asmlinkage long sys_symlinkat(const char
 out_unlock:
 	mutex_unlock(&nd.path.dentry->d_inode->i_mutex);
 	path_put(&nd.path);
+	if (error == -ESTALE)
+		goto top;
 out:
 	putname(to);
 out_putname:
@@ -2392,6 +2434,7 @@ asmlinkage long sys_linkat(int olddfd, c
 	if (IS_ERR(to))
 		return PTR_ERR(to);
 
+top:
 	error = __user_walk_fd(olddfd, oldname,
 			       flags & AT_SYMLINK_FOLLOW ? LOOKUP_FOLLOW : 0,
 			       &old_nd);
@@ -2411,6 +2454,11 @@ asmlinkage long sys_linkat(int olddfd, c
 	dput(new_dentry);
 out_unlock:
 	mutex_unlock(&nd.path.dentry->d_inode->i_mutex);
+	if (error == -ESTALE) {
+		path_put(&nd.path);
+		path_put(&old_nd.path);
+		goto top;
+	}
 out_release:
 	path_put(&nd.path);
 out:
@@ -2581,6 +2629,7 @@ static int do_rename(int olddfd, const c
 	struct dentry * trap;
 	struct nameidata oldnd, newnd;
 
+top:
 	error = do_path_lookup(olddfd, oldname, LOOKUP_PARENT, &oldnd);
 	if (error)
 		goto exit;
@@ -2641,6 +2690,11 @@ exit4:
 	dput(old_dentry);
 exit3:
 	unlock_rename(new_dir, old_dir);
+	if (error == -ESTALE) {
+		path_put(&newnd.path);
+		path_put(&oldnd.path);
+		goto top;
+	}
 exit2:
 	path_put(&newnd.path);
 exit1:
--- linux-2.6.24.i686/fs/open.c.org
+++ linux-2.6.24.i686/fs/open.c
@@ -124,6 +124,7 @@ asmlinkage long sys_statfs(const char __
 	struct nameidata nd;
 	int error;
 
+top:
 	error = user_path_walk(path, &nd);
 	if (!error) {
 		struct statfs tmp;
@@ -131,6 +132,8 @@ asmlinkage long sys_statfs(const char __
 		if (!error && copy_to_user(buf, &tmp, sizeof(tmp)))
 			error = -EFAULT;
 		path_put(&nd.path);
+		if (error == -ESTALE)
+			goto top;
 	}
 	return error;
 }
@@ -143,6 +146,7 @@ asmlinkage long sys_statfs64(const char 
 
 	if (sz != sizeof(*buf))
 		return -EINVAL;
+top:
 	error = user_path_walk(path, &nd);
 	if (!error) {
 		struct statfs64 tmp;
@@ -150,6 +154,8 @@ asmlinkage long sys_statfs64(const char 
 		if (!error && copy_to_user(buf, &tmp, sizeof(tmp)))
 			error = -EFAULT;
 		path_put(&nd.path);
+		if (error == -ESTALE)
+			goto top;
 	}
 	return error;
 }
@@ -230,6 +236,7 @@ static long do_sys_truncate(const char _
 	if (length < 0)	/* sorry, but loff_t says... */
 		goto out;
 
+top:
 	error = user_path_walk(path, &nd);
 	if (error)
 		goto out;
@@ -278,6 +285,8 @@ put_write_and_out:
 	put_write_access(inode);
 dput_and_out:
 	path_put(&nd.path);
+	if (error == -ESTALE)
+		goto top;
 out:
 	return error;
 }
@@ -448,6 +457,7 @@ asmlinkage long sys_faccessat(int dfd, c
 	else
 		current->cap_effective = current->cap_permitted;
 
+top:
 	res = __user_walk_fd(dfd, filename, LOOKUP_FOLLOW|LOOKUP_ACCESS, &nd);
 	if (res)
 		goto out;
@@ -463,6 +473,8 @@ asmlinkage long sys_faccessat(int dfd, c
 
 out_path_release:
 	path_put(&nd.path);
+	if (res == -ESTALE)
+		goto top;
 out:
 	current->fsuid = old_fsuid;
 	current->fsgid = old_fsgid;
@@ -481,6 +493,7 @@ asmlinkage long sys_chdir(const char __u
 	struct nameidata nd;
 	int error;
 
+top:
 	error = __user_walk(filename,
 			    LOOKUP_FOLLOW|LOOKUP_DIRECTORY|LOOKUP_CHDIR, &nd);
 	if (error)
@@ -494,6 +507,8 @@ asmlinkage long sys_chdir(const char __u
 
 dput_and_out:
 	path_put(&nd.path);
+	if (error == -ESTALE)
+		goto top;
 out:
 	return error;
 }
@@ -529,6 +544,7 @@ asmlinkage long sys_chroot(const char __
 	struct nameidata nd;
 	int error;
 
+top:
 	error = __user_walk(filename, LOOKUP_FOLLOW | LOOKUP_DIRECTORY | LOOKUP_NOALT, &nd);
 	if (error)
 		goto out;
@@ -546,6 +562,8 @@ asmlinkage long sys_chroot(const char __
 	error = 0;
 dput_and_out:
 	path_put(&nd.path);
+	if (error == -ESTALE)
+		goto top;
 out:
 	return error;
 }
@@ -595,6 +613,7 @@ asmlinkage long sys_fchmodat(int dfd, co
 	int error;
 	struct iattr newattrs;
 
+top:
 	error = __user_walk_fd(dfd, filename, LOOKUP_FOLLOW, &nd);
 	if (error)
 		goto out;
@@ -618,6 +637,8 @@ asmlinkage long sys_fchmodat(int dfd, co
 
 dput_and_out:
 	path_put(&nd.path);
+	if (error == -ESTALE)
+		goto top;
 out:
 	return error;
 }
@@ -668,11 +689,14 @@ asmlinkage long sys_chown(const char __u
 	struct nameidata nd;
 	int error;
 
+top:
 	error = user_path_walk(filename, &nd);
 	if (error)
 		goto out;
 	error = chown_common(nd.path.dentry, user, group);
 	path_put(&nd.path);
+	if (error == -ESTALE)
+		goto top;
 out:
 	return error;
 }
@@ -688,11 +712,14 @@ asmlinkage long sys_fchownat(int dfd, co
 		goto out;
 
 	follow = (flag & AT_SYMLINK_NOFOLLOW) ? 0 : LOOKUP_FOLLOW;
+top:
 	error = __user_walk_fd(dfd, filename, follow, &nd);
 	if (error)
 		goto out;
 	error = chown_common(nd.path.dentry, user, group);
 	path_put(&nd.path);
+	if (error == -ESTALE)
+		goto top;
 out:
 	return error;
 }
@@ -702,11 +729,14 @@ asmlinkage long sys_lchown(const char __
 	struct nameidata nd;
 	int error;
 
+top:
 	error = user_path_walk_link(filename, &nd);
 	if (error)
 		goto out;
 	error = chown_common(nd.path.dentry, user, group);
 	path_put(&nd.path);
+	if (error == -ESTALE)
+		goto top;
 out:
 	return error;
 }
@@ -815,16 +845,22 @@ static struct file *do_filp_open(int dfd
 {
 	int namei_flags, error;
 	struct nameidata nd;
+	struct file *res;
 
+top:
 	namei_flags = flags;
 	if ((namei_flags+1) & O_ACCMODE)
 		namei_flags++;
 
 	error = open_namei(dfd, filename, namei_flags, mode, &nd);
-	if (!error)
-		return nameidata_to_filp(&nd, flags);
+	if (error)
+		return ERR_PTR(error);
+
+	res = nameidata_to_filp(&nd, flags);
+	if (IS_ERR(res) && res == ERR_PTR(-ESTALE))
+		goto top;
+	return res;
 
-	return ERR_PTR(error);
 }
 
 struct file *filp_open(const char *filename, int flags, int mode)
--- linux-2.6.24.i686/fs/inotify_user.c.org
+++ linux-2.6.24.i686/fs/inotify_user.c
@@ -361,13 +361,17 @@ static int find_inode(const char __user 
 {
 	int error;
 
+top:
 	error = __user_walk(dirname, flags, nd);
 	if (error)
 		return error;
 	/* you can only watch an inode if you have read permissions on it */
 	error = vfs_permission(nd, MAY_READ);
-	if (error)
+	if (error) {
 		path_put(&nd->path);
+		if (error == -ESTALE)
+			goto top;
+	}
 	return error;
 }
 
--- linux-2.6.24.i686/fs/stat.c.org
+++ linux-2.6.24.i686/fs/stat.c
@@ -60,10 +60,13 @@ int vfs_stat_fd(int dfd, char __user *na
 	struct nameidata nd;
 	int error;
 
+top:
 	error = __user_walk_fd(dfd, name, LOOKUP_FOLLOW, &nd);
 	if (!error) {
 		error = vfs_getattr(nd.path.mnt, nd.path.dentry, stat);
 		path_put(&nd.path);
+		if (error == -ESTALE)
+			goto top;
 	}
 	return error;
 }
@@ -80,10 +83,13 @@ int vfs_lstat_fd(int dfd, char __user *n
 	struct nameidata nd;
 	int error;
 
+top:
 	error = __user_walk_fd(dfd, name, 0, &nd);
 	if (!error) {
 		error = vfs_getattr(nd.path.mnt, nd.path.dentry, stat);
 		path_put(&nd.path);
+		if (error == -ESTALE)
+			goto top;
 	}
 	return error;
 }
@@ -300,6 +306,7 @@ asmlinkage long sys_readlinkat(int dfd, 
 	if (bufsiz <= 0)
 		return -EINVAL;
 
+top:
 	error = __user_walk_fd(dfd, path, 0, &nd);
 	if (!error) {
 		struct inode *inode = nd.path.dentry->d_inode;
@@ -314,6 +321,8 @@ asmlinkage long sys_readlinkat(int dfd, 
 			}
 		}
 		path_put(&nd.path);
+		if (error == -ESTALE)
+			goto top;
 	}
 	return error;
 }
--- linux-2.6.24.i686/fs/exec.c.org
+++ linux-2.6.24.i686/fs/exec.c
@@ -107,6 +107,7 @@ asmlinkage long sys_uselib(const char __
 	struct nameidata nd;
 	int error;
 
+top:
 	error = __user_path_lookup_open(library, LOOKUP_FOLLOW, &nd, FMODE_READ|FMODE_EXEC);
 	if (error)
 		goto out;
@@ -149,6 +150,8 @@ out:
 exit:
 	release_open_intent(&nd);
 	path_put(&nd.path);
+	if (error == -ESTALE)
+		goto top;
 	goto out;
 }
 
@@ -656,6 +659,7 @@ struct file *open_exec(const char *name)
 	int err;
 	struct file *file;
 
+top:
 	err = path_lookup_open(AT_FDCWD, name, LOOKUP_FOLLOW, &nd, FMODE_READ|FMODE_EXEC);
 	file = ERR_PTR(err);
 
@@ -663,7 +667,7 @@ struct file *open_exec(const char *name)
 		struct inode *inode = nd.path.dentry->d_inode;
 		file = ERR_PTR(-EACCES);
 		if (S_ISREG(inode->i_mode)) {
-			int err = vfs_permission(&nd, MAY_EXEC);
+			err = vfs_permission(&nd, MAY_EXEC);
 			file = ERR_PTR(err);
 			if (!err) {
 				file = nameidata_to_filp(&nd,
@@ -674,13 +678,16 @@ struct file *open_exec(const char *name)
 						fput(file);
 						file = ERR_PTR(err);
 					}
-				}
+				} else if (file == ERR_PTR(-ESTALE))
+					goto top;
 out:
 				return file;
 			}
 		}
 		release_open_intent(&nd);
 		path_put(&nd.path);
+		if (err == -ESTALE)
+			goto top;
 	}
 	goto out;
 }
--- linux-2.6.24.i686/fs/utimes.c.org
+++ linux-2.6.24.i686/fs/utimes.c
@@ -80,6 +80,7 @@ long do_utimes(int dfd, char __user *fil
 			goto out;
 		dentry = f->f_path.dentry;
 	} else {
+top:
 		error = __user_walk_fd(dfd, filename, (flags & AT_SYMLINK_NOFOLLOW) ? 0 : LOOKUP_FOLLOW, &nd);
 		if (error)
 			goto out;
@@ -137,8 +138,11 @@ long do_utimes(int dfd, char __user *fil
 dput_and_out:
 	if (f)
 		fput(f);
-	else
+	else {
 		path_put(&nd.path);
+		if (error == -ESTALE)
+			goto top;
+	}
 out:
 	return error;
 }
--- linux-2.6.24.i686/fs/compat.c.org
+++ linux-2.6.24.i686/fs/compat.c
@@ -238,6 +238,7 @@ asmlinkage long compat_sys_statfs(const 
 	struct nameidata nd;
 	int error;
 
+top:
 	error = user_path_walk(path, &nd);
 	if (!error) {
 		struct kstatfs tmp;
@@ -245,6 +246,8 @@ asmlinkage long compat_sys_statfs(const 
 		if (!error)
 			error = put_compat_statfs(buf, &tmp);
 		path_put(&nd.path);
+		if (error == -ESTALE)
+			goto top;
 	}
 	return error;
 }
@@ -306,6 +309,7 @@ asmlinkage long compat_sys_statfs64(cons
 	if (sz != sizeof(*buf))
 		return -EINVAL;
 
+top:
 	error = user_path_walk(path, &nd);
 	if (!error) {
 		struct kstatfs tmp;
@@ -313,6 +317,8 @@ asmlinkage long compat_sys_statfs64(cons
 		if (!error)
 			error = put_compat_statfs64(buf, &tmp);
 		path_put(&nd.path);
+		if (error == -ESTALE)
+			goto top;
 	}
 	return error;
 }
--- linux-2.6.24.i686/fs/xattr.c.org
+++ linux-2.6.24.i686/fs/xattr.c
@@ -259,11 +259,14 @@ sys_setxattr(char __user *path, char __u
 	struct nameidata nd;
 	int error;
 
+top:
 	error = user_path_walk(path, &nd);
 	if (error)
 		return error;
 	error = setxattr(nd.path.dentry, name, value, size, flags);
 	path_put(&nd.path);
+	if (error == -ESTALE)
+		goto top;
 	return error;
 }
 
@@ -274,11 +277,14 @@ sys_lsetxattr(char __user *path, char __
 	struct nameidata nd;
 	int error;
 
+top:
 	error = user_path_walk_link(path, &nd);
 	if (error)
 		return error;
 	error = setxattr(nd.path.dentry, name, value, size, flags);
 	path_put(&nd.path);
+	if (error == -ESTALE)
+		goto top;
 	return error;
 }
 
@@ -344,11 +350,14 @@ sys_getxattr(char __user *path, char __u
 	struct nameidata nd;
 	ssize_t error;
 
+top:
 	error = user_path_walk(path, &nd);
 	if (error)
 		return error;
 	error = getxattr(nd.path.dentry, name, value, size);
 	path_put(&nd.path);
+	if (error == -ESTALE)
+		goto top;
 	return error;
 }
 
@@ -359,11 +368,14 @@ sys_lgetxattr(char __user *path, char __
 	struct nameidata nd;
 	ssize_t error;
 
+top:
 	error = user_path_walk_link(path, &nd);
 	if (error)
 		return error;
 	error = getxattr(nd.path.dentry, name, value, size);
 	path_put(&nd.path);
+	if (error == -ESTALE)
+		goto top;
 	return error;
 }
 
@@ -418,11 +430,14 @@ sys_listxattr(char __user *path, char __
 	struct nameidata nd;
 	ssize_t error;
 
+top:
 	error = user_path_walk(path, &nd);
 	if (error)
 		return error;
 	error = listxattr(nd.path.dentry, list, size);
 	path_put(&nd.path);
+	if (error == -ESTALE)
+		goto top;
 	return error;
 }
 
@@ -432,11 +447,14 @@ sys_llistxattr(char __user *path, char _
 	struct nameidata nd;
 	ssize_t error;
 
+top:
 	error = user_path_walk_link(path, &nd);
 	if (error)
 		return error;
 	error = listxattr(nd.path.dentry, list, size);
 	path_put(&nd.path);
+	if (error == -ESTALE)
+		goto top;
 	return error;
 }
 
@@ -479,11 +497,14 @@ sys_removexattr(char __user *path, char 
 	struct nameidata nd;
 	int error;
 
+top:
 	error = user_path_walk(path, &nd);
 	if (error)
 		return error;
 	error = removexattr(nd.path.dentry, name);
 	path_put(&nd.path);
+	if (error == -ESTALE)
+		goto top;
 	return error;
 }
 
@@ -493,11 +514,14 @@ sys_lremovexattr(char __user *path, char
 	struct nameidata nd;
 	int error;
 
+top:
 	error = user_path_walk_link(path, &nd);
 	if (error)
 		return error;
 	error = removexattr(nd.path.dentry, name);
 	path_put(&nd.path);
+	if (error == -ESTALE)
+		goto top;
 	return error;
 }
 

--------------050606040007090607010506--

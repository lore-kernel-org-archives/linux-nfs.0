Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36038 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755392Ab2JPWBr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Oct 2012 18:01:47 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>,
        David Howells <dhowells@redhat.com>
Subject: [PATCH 10/12] locks: break delegations on rename
Date: Tue, 16 Oct 2012 18:01:35 -0400
Message-Id: <1350424897-26894-11-git-send-email-bfields@redhat.com>
In-Reply-To: <1350424897-26894-1-git-send-email-bfields@redhat.com>
References: <1350424897-26894-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Cc: David Howells <dhowells@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/cachefiles/namei.c |    2 +-
 fs/namei.c            |   30 ++++++++++++++++++++++++------
 fs/nfsd/vfs.c         |    2 +-
 include/linux/fs.h    |    2 +-
 4 files changed, 27 insertions(+), 9 deletions(-)

diff --git a/fs/cachefiles/namei.c b/fs/cachefiles/namei.c
index 10cf5c6..ef23d2a 100644
--- a/fs/cachefiles/namei.c
+++ b/fs/cachefiles/namei.c
@@ -397,7 +397,7 @@ try_again:
 		cachefiles_io_error(cache, "Rename security error %d", ret);
 	} else {
 		ret = vfs_rename(dir->d_inode, rep,
-				 cache->graveyard->d_inode, grave);
+				 cache->graveyard->d_inode, grave, NULL);
 		if (ret != 0 && ret != -ENOMEM)
 			cachefiles_io_error(cache,
 					    "Rename failed with error %d", ret);
diff --git a/fs/namei.c b/fs/namei.c
index 66228a8..4d0982b 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3735,7 +3735,8 @@ out:
 }
 
 static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
-			    struct inode *new_dir, struct dentry *new_dentry)
+			    struct inode *new_dir, struct dentry *new_dentry,
+			    struct inode **delegated_inode)
 {
 	struct inode *target = new_dentry->d_inode;
 	struct inode *source = old_dentry->d_inode;
@@ -3755,6 +3756,14 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
 	if (d_mountpoint(old_dentry)||d_mountpoint(new_dentry))
 		goto out;
 
+	error = try_break_deleg(source, delegated_inode);
+	if (error)
+		goto out;
+	if (target) {
+		error = try_break_deleg(target, delegated_inode);
+		if (error)
+			goto out;
+	}
 	error = old_dir->i_op->rename(old_dir, old_dentry, new_dir, new_dentry);
 	if (error)
 		goto out;
@@ -3773,7 +3782,8 @@ out:
 }
 
 int vfs_rename(struct inode *old_dir, struct dentry *old_dentry,
-	       struct inode *new_dir, struct dentry *new_dentry)
+	       struct inode *new_dir, struct dentry *new_dentry,
+	       struct inode **delegated_inode)
 {
 	int error;
 	int is_dir = S_ISDIR(old_dentry->d_inode->i_mode);
@@ -3801,7 +3811,7 @@ int vfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	if (is_dir)
 		error = vfs_rename_dir(old_dir,old_dentry,new_dir,new_dentry);
 	else
-		error = vfs_rename_other(old_dir,old_dentry,new_dir,new_dentry);
+		error = vfs_rename_other(old_dir,old_dentry,new_dir,new_dentry,delegated_inode);
 	if (!error)
 		fsnotify_move(old_dir, new_dir, old_name, is_dir,
 			      new_dentry->d_inode, old_dentry);
@@ -3817,8 +3827,9 @@ SYSCALL_DEFINE4(renameat, int, olddfd, const char __user *, oldname,
 	struct dentry *old_dentry, *new_dentry;
 	struct dentry *trap;
 	struct nameidata oldnd, newnd;
-	struct filename *from;
-	struct filename *to;
+	struct inode *delegated_inode = NULL;
+	char *from;
+	char *to;
 	int error;
 
 	from = user_path_parent(olddfd, oldname, &oldnd);
@@ -3854,6 +3865,7 @@ SYSCALL_DEFINE4(renameat, int, olddfd, const char __user *, oldname,
 	newnd.flags &= ~LOOKUP_PARENT;
 	newnd.flags |= LOOKUP_RENAME_TARGET;
 
+retry_deleg:
 	trap = lock_rename(new_dir, old_dir);
 
 	old_dentry = lookup_hash(&oldnd);
@@ -3890,13 +3902,19 @@ SYSCALL_DEFINE4(renameat, int, olddfd, const char __user *, oldname,
 	if (error)
 		goto exit5;
 	error = vfs_rename(old_dir->d_inode, old_dentry,
-				   new_dir->d_inode, new_dentry);
+				   new_dir->d_inode, new_dentry,
+				   &delegated_inode);
 exit5:
 	dput(new_dentry);
 exit4:
 	dput(old_dentry);
 exit3:
 	unlock_rename(new_dir, old_dir);
+	if (delegated_inode) {
+		error = break_deleg_wait(&delegated_inode);
+		if (!error)
+			goto retry_deleg;
+	}
 	mnt_drop_write(oldnd.path.mnt);
 exit2:
 	path_put(&newnd.path);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index c51f4c9..903fae1 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1820,7 +1820,7 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 		if (host_err)
 			goto out_dput_new;
 	}
-	host_err = vfs_rename(fdir, odentry, tdir, ndentry);
+	host_err = vfs_rename(fdir, odentry, tdir, ndentry, NULL);
 	if (!host_err) {
 		host_err = commit_metadata(tfhp);
 		if (!host_err)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 0e761e7..84183db 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1400,7 +1400,7 @@ extern int vfs_symlink(struct inode *, struct dentry *, const char *);
 extern int vfs_link(struct dentry *, struct inode *, struct dentry *);
 extern int vfs_rmdir(struct inode *, struct dentry *);
 extern int vfs_unlink(struct inode *, struct dentry *, struct inode **);
-extern int vfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *);
+extern int vfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *, struct inode **);
 
 /*
  * VFS dentry helper functions.
-- 
1.7.9.5


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43946 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759456Ab2IEUzg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Sep 2012 16:55:36 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>,
        David Howells <dhowells@redhat.com>
Subject: [RFC PATCH 11/13] locks: break delegations on rename
Date: Wed,  5 Sep 2012 16:55:21 -0400
Message-Id: <1346878524-10585-12-git-send-email-bfields@redhat.com>
In-Reply-To: <1346878524-10585-1-git-send-email-bfields@redhat.com>
References: <1346878524-10585-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Cc: David Howells <dhowells@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/cachefiles/namei.c |    2 +-
 fs/namei.c            |   26 ++++++++++++++++++++++----
 fs/nfsd/vfs.c         |    2 +-
 include/linux/fs.h    |    2 +-
 4 files changed, 25 insertions(+), 7 deletions(-)

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
index eef4806..c7318ae 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3666,7 +3666,8 @@ out:
 }
 
 static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
-			    struct inode *new_dir, struct dentry *new_dentry)
+			    struct inode *new_dir, struct dentry *new_dentry,
+			    struct inode **delegated_inode)
 {
 	struct inode *target = new_dentry->d_inode;
 	struct inode *source = old_dentry->d_inode;
@@ -3683,6 +3684,14 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
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
@@ -3698,7 +3707,8 @@ out:
 }
 
 int vfs_rename(struct inode *old_dir, struct dentry *old_dentry,
-	       struct inode *new_dir, struct dentry *new_dentry)
+	       struct inode *new_dir, struct dentry *new_dentry,
+	       struct inode **delegated_inode)
 {
 	int error;
 	int is_dir = S_ISDIR(old_dentry->d_inode->i_mode);
@@ -3726,7 +3736,7 @@ int vfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	if (is_dir)
 		error = vfs_rename_dir(old_dir,old_dentry,new_dir,new_dentry);
 	else
-		error = vfs_rename_other(old_dir,old_dentry,new_dir,new_dentry);
+		error = vfs_rename_other(old_dir,old_dentry,new_dir,new_dentry,delegated_inode);
 	if (!error)
 		fsnotify_move(old_dir, new_dir, old_name, is_dir,
 			      new_dentry->d_inode, old_dentry);
@@ -3742,6 +3752,7 @@ SYSCALL_DEFINE4(renameat, int, olddfd, const char __user *, oldname,
 	struct dentry *old_dentry, *new_dentry;
 	struct dentry *trap;
 	struct nameidata oldnd, newnd;
+	struct inode *delegated_inode = NULL;
 	char *from;
 	char *to;
 	int error;
@@ -3775,6 +3786,7 @@ SYSCALL_DEFINE4(renameat, int, olddfd, const char __user *, oldname,
 	newnd.flags &= ~LOOKUP_PARENT;
 	newnd.flags |= LOOKUP_RENAME_TARGET;
 
+retry_deleg:
 	trap = lock_rename(new_dir, old_dir);
 
 	old_dentry = lookup_hash(&oldnd);
@@ -3811,13 +3823,19 @@ SYSCALL_DEFINE4(renameat, int, olddfd, const char __user *, oldname,
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
index 9c39d26..c8f5e74 100644
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
index 4c0fa4f..ad9df65e 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1724,7 +1724,7 @@ extern int vfs_symlink(struct inode *, struct dentry *, const char *);
 extern int vfs_link(struct dentry *, struct inode *, struct dentry *);
 extern int vfs_rmdir(struct inode *, struct dentry *);
 extern int vfs_unlink(struct inode *, struct dentry *, struct inode **);
-extern int vfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *);
+extern int vfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *, struct inode **);
 
 /*
  * VFS dentry helper functions.
-- 
1.7.9.5


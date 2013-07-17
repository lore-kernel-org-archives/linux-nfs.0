Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53645 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756375Ab3GQUuX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Jul 2013 16:50:23 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        jlayton@redhat.com, Dave Chinner <david@fromorbit.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        David Howells <dhowells@redhat.com>
Subject: [PATCH 10/16] locks: break delegations on rename
Date: Wed, 17 Jul 2013 16:50:11 -0400
Message-Id: <1374094217-31493-12-git-send-email-bfields@redhat.com>
In-Reply-To: <1374094217-31493-1-git-send-email-bfields@redhat.com>
References: <1374094217-31493-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Cc: David Howells <dhowells@redhat.com>
Acked-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/cachefiles/namei.c |    2 +-
 fs/namei.c            |   47 +++++++++++++++++++++++++++++++++++++++++++----
 fs/nfsd/vfs.c         |    2 +-
 include/linux/fs.h    |    2 +-
 4 files changed, 46 insertions(+), 7 deletions(-)

diff --git a/fs/cachefiles/namei.c b/fs/cachefiles/namei.c
index 6846fcef..1363eae 100644
--- a/fs/cachefiles/namei.c
+++ b/fs/cachefiles/namei.c
@@ -396,7 +396,7 @@ try_again:
 		cachefiles_io_error(cache, "Rename security error %d", ret);
 	} else {
 		ret = vfs_rename(dir->d_inode, rep,
-				 cache->graveyard->d_inode, grave);
+				 cache->graveyard->d_inode, grave, NULL);
 		if (ret != 0 && ret != -ENOMEM)
 			cachefiles_io_error(cache,
 					    "Rename failed with error %d", ret);
diff --git a/fs/namei.c b/fs/namei.c
index d3b6a35..0554c9a 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3834,7 +3834,8 @@ out:
 }
 
 static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
-			    struct inode *new_dir, struct dentry *new_dentry)
+			    struct inode *new_dir, struct dentry *new_dentry,
+			    struct inode **delegated_inode)
 {
 	struct inode *target = new_dentry->d_inode;
 	struct inode *source = old_dentry->d_inode;
@@ -3851,6 +3852,14 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
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
@@ -3865,8 +3874,30 @@ out:
 	return error;
 }
 
+/**
+ * vfs_rename - rename a filesystem object
+ * @old_dir:	parent of source
+ * @old_dentry:	source
+ * @new_dir:	parent of destination
+ * @new_dentry:	destination
+ * @delegated_inode: returns an inode needing a delegation break
+ *
+ * The caller must hold multiple mutexes--see lock_rename()).
+ *
+ * If vfs_rename discovers a delegation in need of breaking at either
+ * the source or destination, it will return -EWOULDBLOCK and return a
+ * reference to the inode in delegated_inode.  The caller should then
+ * break the delegation and retry.  Because breaking a delegation may
+ * take a long time, the caller should drop all locks before doing
+ * so.
+ *
+ * Alternatively, a caller may pass NULL for delegated_inode.  This may
+ * be appropriate for callers that expect the underlying filesystem not
+ * to be NFS exported.
+ */
 int vfs_rename(struct inode *old_dir, struct dentry *old_dentry,
-	       struct inode *new_dir, struct dentry *new_dentry)
+	       struct inode *new_dir, struct dentry *new_dentry,
+	       struct inode **delegated_inode)
 {
 	int error;
 	int is_dir = S_ISDIR(old_dentry->d_inode->i_mode);
@@ -3894,7 +3925,7 @@ int vfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	if (is_dir)
 		error = vfs_rename_dir(old_dir,old_dentry,new_dir,new_dentry);
 	else
-		error = vfs_rename_other(old_dir,old_dentry,new_dir,new_dentry);
+		error = vfs_rename_other(old_dir,old_dentry,new_dir,new_dentry,delegated_inode);
 	if (!error)
 		fsnotify_move(old_dir, new_dir, old_name, is_dir,
 			      new_dentry->d_inode, old_dentry);
@@ -3910,6 +3941,7 @@ SYSCALL_DEFINE4(renameat, int, olddfd, const char __user *, oldname,
 	struct dentry *old_dentry, *new_dentry;
 	struct dentry *trap;
 	struct nameidata oldnd, newnd;
+	struct inode *delegated_inode = NULL;
 	struct filename *from;
 	struct filename *to;
 	unsigned int lookup_flags = 0;
@@ -3949,6 +3981,7 @@ retry:
 	newnd.flags &= ~LOOKUP_PARENT;
 	newnd.flags |= LOOKUP_RENAME_TARGET;
 
+retry_deleg:
 	trap = lock_rename(new_dir, old_dir);
 
 	old_dentry = lookup_hash(&oldnd);
@@ -3985,13 +4018,19 @@ retry:
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
 	if (retry_estale(error, lookup_flags))
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index ff1fc44..fbf22d2 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1837,7 +1837,7 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 		if (host_err)
 			goto out_dput_new;
 	}
-	host_err = vfs_rename(fdir, odentry, tdir, ndentry);
+	host_err = vfs_rename(fdir, odentry, tdir, ndentry, NULL);
 	if (!host_err) {
 		host_err = commit_metadata(tfhp);
 		if (!host_err)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 43a3506..74aa0c7 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1470,7 +1470,7 @@ extern int vfs_symlink(struct inode *, struct dentry *, const char *);
 extern int vfs_link(struct dentry *, struct inode *, struct dentry *);
 extern int vfs_rmdir(struct inode *, struct dentry *);
 extern int vfs_unlink(struct inode *, struct dentry *, struct inode **);
-extern int vfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *);
+extern int vfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *, struct inode **);
 
 /*
  * VFS dentry helper functions.
-- 
1.7.9.5


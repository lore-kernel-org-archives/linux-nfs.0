Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45441 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756847Ab3IKUDW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Sep 2013 16:03:22 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        jlayton@redhat.com, Dave Chinner <david@fromorbit.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Tyler Hicks <tyhicks@canonical.com>,
        Dustin Kirkland <dustin.kirkland@gazzang.com>
Subject: [PATCH 11/13] locks: break delegations on link
Date: Wed, 11 Sep 2013 16:03:17 -0400
Message-Id: <1378929799-1110-12-git-send-email-bfields@redhat.com>
In-Reply-To: <1378929799-1110-1-git-send-email-bfields@redhat.com>
References: <1378929799-1110-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Cc: Tyler Hicks <tyhicks@canonical.com>
Cc: Dustin Kirkland <dustin.kirkland@gazzang.com>
Acked-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/ecryptfs/inode.c |    2 +-
 fs/namei.c          |   36 ++++++++++++++++++++++++++++++++----
 fs/nfsd/vfs.c       |    2 +-
 include/linux/fs.h  |    2 +-
 4 files changed, 35 insertions(+), 7 deletions(-)

diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
index 0b8b632..cb3ac33 100644
--- a/fs/ecryptfs/inode.c
+++ b/fs/ecryptfs/inode.c
@@ -475,7 +475,7 @@ static int ecryptfs_link(struct dentry *old_dentry, struct inode *dir,
 	dget(lower_new_dentry);
 	lower_dir_dentry = lock_parent(lower_new_dentry);
 	rc = vfs_link(lower_old_dentry, lower_dir_dentry->d_inode,
-		      lower_new_dentry);
+		      lower_new_dentry, NULL);
 	if (rc || !lower_new_dentry->d_inode)
 		goto out_lock;
 	rc = ecryptfs_interpose(lower_new_dentry, new_dentry, dir->i_sb);
diff --git a/fs/namei.c b/fs/namei.c
index fcce3cc..6e2edbd8 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3843,7 +3843,26 @@ SYSCALL_DEFINE2(symlink, const char __user *, oldname, const char __user *, newn
 	return sys_symlinkat(oldname, AT_FDCWD, newname);
 }
 
-int vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *new_dentry)
+/**
+ * vfs_link - create a new link
+ * @old_dentry:	object to be linked
+ * @dir:	new parent
+ * @new_dentry:	where to create the new link
+ * @delegated_inode: returns inode needing a delegation break
+ *
+ * The caller must hold dir->i_mutex
+ *
+ * If vfs_link discovers a delegation on the to-be-linked file in need
+ * of breaking, it will return -EWOULDBLOCK and return a reference to the
+ * inode in delegated_inode.  The caller should then break the delegation
+ * and retry.  Because breaking a delegation may take a long time, the
+ * caller should drop the i_mutex before doing so.
+ *
+ * Alternatively, a caller may pass NULL for delegated_inode.  This may
+ * be appropriate for callers that expect the underlying filesystem not
+ * to be NFS exported.
+ */
+int vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *new_dentry, struct inode **delegated_inode)
 {
 	struct inode *inode = old_dentry->d_inode;
 	unsigned max_links = dir->i_sb->s_max_links;
@@ -3879,8 +3898,11 @@ int vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *new_de
 		error =  -ENOENT;
 	else if (max_links && inode->i_nlink >= max_links)
 		error = -EMLINK;
-	else
-		error = dir->i_op->link(old_dentry, dir, new_dentry);
+	else {
+		error = try_break_deleg(inode, delegated_inode);
+		if (!error)
+			error = dir->i_op->link(old_dentry, dir, new_dentry);
+	}
 
 	if (!error && (inode->i_state & I_LINKABLE)) {
 		spin_lock(&inode->i_lock);
@@ -3907,6 +3929,7 @@ SYSCALL_DEFINE5(linkat, int, olddfd, const char __user *, oldname,
 {
 	struct dentry *new_dentry;
 	struct path old_path, new_path;
+	struct inode *delegated_inode = NULL;
 	int how = 0;
 	int error;
 
@@ -3945,9 +3968,14 @@ retry:
 	error = security_path_link(old_path.dentry, &new_path, new_dentry);
 	if (error)
 		goto out_dput;
-	error = vfs_link(old_path.dentry, new_path.dentry->d_inode, new_dentry);
+	error = vfs_link(old_path.dentry, new_path.dentry->d_inode, new_dentry, &delegated_inode);
 out_dput:
 	done_path_create(&new_path, new_dentry);
+	if (delegated_inode) {
+		error = break_deleg_wait(&delegated_inode);
+		if (!error)
+			goto retry;
+	}
 	if (retry_estale(error, how)) {
 		how |= LOOKUP_REVAL;
 		goto retry;
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 680081b..93227d9 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1737,7 +1737,7 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
 		err = nfserrno(host_err);
 		goto out_dput;
 	}
-	host_err = vfs_link(dold, dirp, dnew);
+	host_err = vfs_link(dold, dirp, dnew, NULL);
 	if (!host_err) {
 		err = nfserrno(commit_metadata(ffhp));
 		if (!err)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index e476e5a..a3e5554 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1470,7 +1470,7 @@ extern int vfs_create(struct inode *, struct dentry *, umode_t, bool);
 extern int vfs_mkdir(struct inode *, struct dentry *, umode_t);
 extern int vfs_mknod(struct inode *, struct dentry *, umode_t, dev_t);
 extern int vfs_symlink(struct inode *, struct dentry *, const char *);
-extern int vfs_link(struct dentry *, struct inode *, struct dentry *);
+extern int vfs_link(struct dentry *, struct inode *, struct dentry *, struct inode **);
 extern int vfs_rmdir(struct inode *, struct dentry *);
 extern int vfs_unlink(struct inode *, struct dentry *, struct inode **);
 extern int vfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *, struct inode **);
-- 
1.7.9.5


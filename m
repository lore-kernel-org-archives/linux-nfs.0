Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46518 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753379Ab3BCQbi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 3 Feb 2013 11:31:38 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Tyler Hicks <tyhicks@canonical.com>,
        Dustin Kirkland <dustin.kirkland@gazzang.com>
Subject: [PATCH 11/12] locks: break delegations on link
Date: Sun,  3 Feb 2013 11:31:31 -0500
Message-Id: <1359909092-24857-12-git-send-email-bfields@redhat.com>
In-Reply-To: <1359909092-24857-1-git-send-email-bfields@redhat.com>
References: <1359909092-24857-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Cc: Tyler Hicks <tyhicks@canonical.com>
Cc: Dustin Kirkland <dustin.kirkland@gazzang.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/ecryptfs/inode.c |    2 +-
 fs/namei.c          |   17 +++++++++++++----
 fs/nfsd/vfs.c       |    2 +-
 include/linux/fs.h  |    2 +-
 4 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
index 30d7e59..a3b2b08 100644
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
index 939e81a..36f22ba 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3577,7 +3577,7 @@ SYSCALL_DEFINE2(symlink, const char __user *, oldname, const char __user *, newn
 	return sys_symlinkat(oldname, AT_FDCWD, newname);
 }
 
-int vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *new_dentry)
+int vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *new_dentry, struct inode **delegated_inode)
 {
 	struct inode *inode = old_dentry->d_inode;
 	unsigned max_links = dir->i_sb->s_max_links;
@@ -3613,8 +3613,11 @@ int vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *new_de
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
 	mutex_unlock(&inode->i_mutex);
 	if (!error)
 		fsnotify_link(dir, inode, new_dentry);
@@ -3635,6 +3638,7 @@ SYSCALL_DEFINE5(linkat, int, olddfd, const char __user *, oldname,
 {
 	struct dentry *new_dentry;
 	struct path old_path, new_path;
+	struct inode *delegated_inode = NULL;
 	int how = 0;
 	int error;
 
@@ -3673,9 +3677,14 @@ retry:
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
index 4011028..99ec672 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1707,7 +1707,7 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
 		err = nfserrno(host_err);
 		goto out_dput;
 	}
-	host_err = vfs_link(dold, dirp, dnew);
+	host_err = vfs_link(dold, dirp, dnew, NULL);
 	if (!host_err) {
 		err = nfserrno(commit_metadata(ffhp));
 		if (!err)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 64ee5f6..cf5758e 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1459,7 +1459,7 @@ extern int vfs_create(struct inode *, struct dentry *, umode_t, bool);
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


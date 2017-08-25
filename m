Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38314 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756274AbdHYVwj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 25 Aug 2017 17:52:39 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/3] fs: cleanup to hide some details of delegation logic
Date: Fri, 25 Aug 2017 17:52:36 -0400
Message-Id: <1503697958-6122-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1503697958-6122-1-git-send-email-bfields@redhat.com>
References: <1503697958-6122-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Pull the checks for delegated_inode into break_deleg_wait() to simplify
the callers a little.

No change in behavior.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/namei.c         | 26 ++++++++++----------------
 fs/open.c          | 16 ++++++----------
 fs/utimes.c        |  8 +++-----
 include/linux/fs.h | 12 +++++++-----
 4 files changed, 26 insertions(+), 36 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index ddb6a7c2b3d4..5a93be7b2c9c 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -4048,11 +4048,9 @@ static long do_unlinkat(int dfd, const char __user *pathname)
 	if (inode)
 		iput(inode);	/* truncate the inode here */
 	inode = NULL;
-	if (delegated_inode) {
-		error = break_deleg_wait(&delegated_inode);
-		if (!error)
-			goto retry_deleg;
-	}
+	error = break_deleg_wait(&delegated_inode, error);
+	if (error == DELEG_RETRY)
+		goto retry_deleg;
 	mnt_drop_write(path.mnt);
 exit1:
 	path_put(&path);
@@ -4283,12 +4281,10 @@ SYSCALL_DEFINE5(linkat, int, olddfd, const char __user *, oldname,
 	error = vfs_link(old_path.dentry, new_path.dentry->d_inode, new_dentry, &delegated_inode);
 out_dput:
 	done_path_create(&new_path, new_dentry);
-	if (delegated_inode) {
-		error = break_deleg_wait(&delegated_inode);
-		if (!error) {
-			path_put(&old_path);
-			goto retry;
-		}
+	error = break_deleg_wait(&delegated_inode, error);
+	if (error == DELEG_RETRY) {
+		path_put(&old_path);
+		goto retry;
 	}
 	if (retry_estale(error, how)) {
 		path_put(&old_path);
@@ -4601,11 +4597,9 @@ SYSCALL_DEFINE5(renameat2, int, olddfd, const char __user *, oldname,
 	dput(old_dentry);
 exit3:
 	unlock_rename(new_path.dentry, old_path.dentry);
-	if (delegated_inode) {
-		error = break_deleg_wait(&delegated_inode);
-		if (!error)
-			goto retry_deleg;
-	}
+	error = break_deleg_wait(&delegated_inode, error);
+	if (error == DELEG_RETRY)
+		goto retry_deleg;
 	mnt_drop_write(old_path.mnt);
 exit2:
 	if (retry_estale(error, lookup_flags))
diff --git a/fs/open.c b/fs/open.c
index 35bb784763a4..d49e9385e45d 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -532,11 +532,9 @@ static int chmod_common(const struct path *path, umode_t mode)
 	error = notify_change(path->dentry, &newattrs, &delegated_inode);
 out_unlock:
 	inode_unlock(inode);
-	if (delegated_inode) {
-		error = break_deleg_wait(&delegated_inode);
-		if (!error)
-			goto retry_deleg;
-	}
+	error = break_deleg_wait(&delegated_inode, error);
+	if (error == DELEG_RETRY)
+		goto retry_deleg;
 	mnt_drop_write(path->mnt);
 	return error;
 }
@@ -611,11 +609,9 @@ static int chown_common(const struct path *path, uid_t user, gid_t group)
 	if (!error)
 		error = notify_change(path->dentry, &newattrs, &delegated_inode);
 	inode_unlock(inode);
-	if (delegated_inode) {
-		error = break_deleg_wait(&delegated_inode);
-		if (!error)
-			goto retry_deleg;
-	}
+	error = break_deleg_wait(&delegated_inode, error);
+	if (error == DELEG_RETRY)
+		goto retry_deleg;
 	return error;
 }
 
diff --git a/fs/utimes.c b/fs/utimes.c
index 6571d8c848a0..75467b7ebfce 100644
--- a/fs/utimes.c
+++ b/fs/utimes.c
@@ -89,11 +89,9 @@ static int utimes_common(const struct path *path, struct timespec *times)
 	inode_lock(inode);
 	error = notify_change(path->dentry, &newattrs, &delegated_inode);
 	inode_unlock(inode);
-	if (delegated_inode) {
-		error = break_deleg_wait(&delegated_inode);
-		if (!error)
-			goto retry_deleg;
-	}
+	error = break_deleg_wait(&delegated_inode, error);
+	if (error == DELEG_RETRY)
+		goto retry_deleg;
 
 	mnt_drop_write(path->mnt);
 out:
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 6e1fd5d21248..1d0d2fde1766 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2288,14 +2288,16 @@ static inline int try_break_deleg(struct inode *inode, struct inode **delegated_
 	return ret;
 }
 
-static inline int break_deleg_wait(struct inode **delegated_inode)
-{
-	int ret;
+#define DELEG_RETRY 1
 
-	ret = break_deleg(*delegated_inode, O_WRONLY);
+static inline int break_deleg_wait(struct inode **delegated_inode, int error)
+{
+	if (!*delegated_inode)
+		return error;
+	error = break_deleg(*delegated_inode, O_WRONLY);
 	iput(*delegated_inode);
 	*delegated_inode = NULL;
-	return ret;
+	return error ? error : DELEG_RETRY;
 }
 
 static inline int break_layout(struct inode *inode, bool wait)
-- 
2.13.5


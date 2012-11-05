Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f46.google.com ([209.85.213.46]:54428 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932887Ab2KEPWl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Nov 2012 10:22:41 -0500
Received: by mail-yh0-f46.google.com with SMTP id m54so971899yhm.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Nov 2012 07:22:41 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v9 11/34] vfs: make do_unlinkat retry on ESTALE errors
Date: Mon,  5 Nov 2012 10:21:50 -0500
Message-Id: <1352128933-28526-12-git-send-email-jlayton@redhat.com>
In-Reply-To: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
References: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c | 87 +++++++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 52 insertions(+), 35 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 0b70e6d..fb5a084 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3432,6 +3432,13 @@ int vfs_unlink(struct inode *dir, struct dentry *dentry)
 	return error;
 }
 
+/* Return an appropriate error code for unlink, based on the inode */
+static inline int
+unlinkat_slashes(struct inode *inode)
+{
+	return !inode ? -ENOENT : S_ISDIR(inode->i_mode) ? -EISDIR : -ENOTDIR;
+}
+
 /*
  * Make sure that the actual truncation of the file will occur outside its
  * directory's i_mutex.  Truncate can take a long time if there is a lot of
@@ -3444,52 +3451,62 @@ static long do_unlinkat(int dfd, const char __user *pathname)
 	struct filename *name;
 	struct dentry *dentry;
 	struct nameidata nd;
-	struct inode *inode = NULL;
+	unsigned int try = 0;
 
-	name = user_path_parent(dfd, pathname, &nd, 0);
-	if (IS_ERR(name))
-		return PTR_ERR(name);
+	do {
+		/* Must ensure that this is reset on each pass */
+		struct inode *inode = NULL;
 
-	error = -EISDIR;
-	if (nd.last_type != LAST_NORM)
-		goto exit1;
+		name = user_path_parent(dfd, pathname, &nd, try);
+		if (IS_ERR(name)) {
+			error = PTR_ERR(name);
+			break;
+		}
 
-	nd.flags &= ~LOOKUP_PARENT;
-	error = mnt_want_write(nd.path.mnt);
-	if (error)
-		goto exit1;
+		error = -EISDIR;
+		if (nd.last_type != LAST_NORM)
+			goto exit1;
+
+		nd.flags &= ~LOOKUP_PARENT;
+		error = mnt_want_write(nd.path.mnt);
+		if (error)
+			goto exit1;
+
+		mutex_lock_nested(&nd.path.dentry->d_inode->i_mutex,
+							I_MUTEX_PARENT);
+		dentry = lookup_hash(&nd);
+		error = PTR_ERR(dentry);
+		if (IS_ERR(dentry))
+			goto exit2;
 
-	mutex_lock_nested(&nd.path.dentry->d_inode->i_mutex, I_MUTEX_PARENT);
-	dentry = lookup_hash(&nd);
-	error = PTR_ERR(dentry);
-	if (!IS_ERR(dentry)) {
 		/* Why not before? Because we want correct error value */
-		if (nd.last.name[nd.last.len])
-			goto slashes;
+		if (nd.last.name[nd.last.len]) {
+			error = unlinkat_slashes(dentry->d_inode);
+			goto exit3;
+		}
+
 		inode = dentry->d_inode;
-		if (!inode)
-			goto slashes;
+		if (!inode) {
+			error = -ENOENT;
+			goto exit3;
+		}
 		ihold(inode);
+
 		error = security_path_unlink(&nd.path, dentry);
-		if (error)
-			goto exit2;
-		error = vfs_unlink(nd.path.dentry->d_inode, dentry);
-exit2:
+		if (!error)
+			error = vfs_unlink(nd.path.dentry->d_inode, dentry);
+exit3:
 		dput(dentry);
-	}
-	mutex_unlock(&nd.path.dentry->d_inode->i_mutex);
-	if (inode)
-		iput(inode);	/* truncate the inode here */
-	mnt_drop_write(nd.path.mnt);
+exit2:
+		mutex_unlock(&nd.path.dentry->d_inode->i_mutex);
+		if (inode)
+			iput(inode);	/* truncate the inode here */
+		mnt_drop_write(nd.path.mnt);
 exit1:
-	path_put(&nd.path);
-	putname(name);
+		path_put(&nd.path);
+		putname(name);
+	} while (retry_estale(error, try++));
 	return error;
-
-slashes:
-	error = !dentry->d_inode ? -ENOENT :
-		S_ISDIR(dentry->d_inode->i_mode) ? -EISDIR : -ENOTDIR;
-	goto exit2;
 }
 
 SYSCALL_DEFINE3(unlinkat, int, dfd, const char __user *, pathname, int, flag)
-- 
1.7.11.7


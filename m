Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:46821 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932689Ab2F2S6T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jun 2012 14:58:19 -0400
Received: by mail-yx0-f174.google.com with SMTP id l2so3038060yen.19
        for <linux-nfs@vger.kernel.org>; Fri, 29 Jun 2012 11:58:19 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v3 08/17] vfs: fix mknodat to retry on ESTALE errors
Date: Fri, 29 Jun 2012 14:57:51 -0400
Message-Id: <1340996280-27123-9-git-send-email-jlayton@redhat.com>
In-Reply-To: <1340996280-27123-1-git-send-email-jlayton@redhat.com>
References: <1340996280-27123-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c |   68 +++++++++++++++++++++++++++++++++++------------------------
 1 files changed, 40 insertions(+), 28 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 86aa8ee..ef3ccee 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2656,44 +2656,56 @@ SYSCALL_DEFINE4(mknodat, int, dfd, const char __user *, filename, umode_t, mode,
 	struct dentry *dentry;
 	struct path path;
 	int error;
+	char *name;
+	unsigned int try = 0;
 
 	if (S_ISDIR(mode))
 		return -EPERM;
 
-	dentry = user_path_create(dfd, filename, &path, 0);
-	if (IS_ERR(dentry))
-		return PTR_ERR(dentry);
+	name = getname(filename);
+	if (IS_ERR(name))
+		return PTR_ERR(name);
 
-	if (!IS_POSIXACL(path.dentry->d_inode))
-		mode &= ~current_umask();
-	error = may_mknod(mode);
-	if (error)
-		goto out_dput;
-	error = mnt_want_write(path.mnt);
-	if (error)
-		goto out_dput;
-	error = security_path_mknod(&path, dentry, mode, dev);
-	if (error)
-		goto out_drop_write;
-	switch (mode & S_IFMT) {
-		case 0: case S_IFREG:
-			error = vfs_create(path.dentry->d_inode,dentry,mode,NULL);
+	do {
+		dentry = kern_path_create(dfd, name, &path, false, try);
+		if (IS_ERR(dentry))
+			return PTR_ERR(dentry);
+
+		if (!IS_POSIXACL(path.dentry->d_inode))
+			mode &= ~current_umask();
+		error = may_mknod(mode);
+		if (error)
+			goto out_dput;
+		error = mnt_want_write(path.mnt);
+		if (error)
+			goto out_dput;
+		error = security_path_mknod(&path, dentry, mode, dev);
+		if (error)
+			goto out_drop_write;
+		switch (mode & S_IFMT) {
+		case 0:
+		case S_IFREG:
+			error = vfs_create(path.dentry->d_inode, dentry,
+					mode, NULL);
 			break;
-		case S_IFCHR: case S_IFBLK:
-			error = vfs_mknod(path.dentry->d_inode,dentry,mode,
+		case S_IFCHR:
+		case S_IFBLK:
+			error = vfs_mknod(path.dentry->d_inode, dentry, mode,
 					new_decode_dev(dev));
 			break;
-		case S_IFIFO: case S_IFSOCK:
-			error = vfs_mknod(path.dentry->d_inode,dentry,mode,0);
-			break;
-	}
+		case S_IFIFO:
+		case S_IFSOCK:
+			error = vfs_mknod(path.dentry->d_inode, dentry,
+					mode, 0);
+		}
 out_drop_write:
-	mnt_drop_write(path.mnt);
+		mnt_drop_write(path.mnt);
 out_dput:
-	dput(dentry);
-	mutex_unlock(&path.dentry->d_inode->i_mutex);
-	path_put(&path);
-
+		dput(dentry);
+		mutex_unlock(&path.dentry->d_inode->i_mutex);
+		path_put(&path);
+	} while (retry_estale(error, try++));
+	putname(name);
 	return error;
 }
 
-- 
1.7.7.6


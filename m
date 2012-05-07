Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:53748 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756897Ab2EGOMZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 May 2012 10:12:25 -0400
Received: by gglu4 with SMTP id u4so295845ggl.19
        for <linux-nfs@vger.kernel.org>; Mon, 07 May 2012 07:12:25 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, miklos@szeredi.hu, hch@infradead.org,
        michael.brantley@deshaw.com
Subject: [PATCH v1 RESEND 05/12] vfs: fix mknodat to retry on ESTALE errors
Date: Mon,  7 May 2012 10:12:04 -0400
Message-Id: <1336399931-20234-6-git-send-email-jlayton@redhat.com>
In-Reply-To: <1336399931-20234-1-git-send-email-jlayton@redhat.com>
References: <1336399931-20234-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c |   62 ++++++++++++++++++++++++++++++-----------------------------
 1 files changed, 32 insertions(+), 30 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 43e568b..471c038 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2581,44 +2581,46 @@ SYSCALL_DEFINE4(mknodat, int, dfd, const char __user *, filename, umode_t, mode,
 	struct dentry *dentry;
 	struct path path;
 	int error;
+	unsigned int try = 0;
 
 	if (S_ISDIR(mode))
 		return -EPERM;
 
-	dentry = user_path_create(dfd, filename, &path, false, false);
-	if (IS_ERR(dentry))
-		return PTR_ERR(dentry);
+	do {
+		dentry = user_path_create(dfd, filename, &path, false, try);
+		if (IS_ERR(dentry))
+			return PTR_ERR(dentry);
 
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
-			break;
-		case S_IFCHR: case S_IFBLK:
-			error = vfs_mknod(path.dentry->d_inode,dentry,mode,
-					new_decode_dev(dev));
-			break;
-		case S_IFIFO: case S_IFSOCK:
-			error = vfs_mknod(path.dentry->d_inode,dentry,mode,0);
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
+			case 0: case S_IFREG:
+				error = vfs_create(path.dentry->d_inode, dentry, mode, NULL);
+				break;
+			case S_IFCHR: case S_IFBLK:
+				error = vfs_mknod(path.dentry->d_inode, dentry, mode,
+						new_decode_dev(dev));
+				break;
+			case S_IFIFO: case S_IFSOCK:
+				error = vfs_mknod(path.dentry->d_inode, dentry, mode, 0);
 			break;
-	}
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
 	return error;
 }
 
-- 
1.7.7.6


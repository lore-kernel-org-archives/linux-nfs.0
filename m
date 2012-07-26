Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:40413 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752435Ab2GZLzk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jul 2012 07:55:40 -0400
Received: by mail-gg0-f174.google.com with SMTP id u4so1821110ggl.19
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jul 2012 04:55:40 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v4 09/17] vfs: fix mkdir to retry on ESTALE errors
Date: Thu, 26 Jul 2012 07:55:12 -0400
Message-Id: <1343303720-11199-10-git-send-email-jlayton@redhat.com>
In-Reply-To: <1343303720-11199-1-git-send-email-jlayton@redhat.com>
References: <1343303720-11199-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c | 43 ++++++++++++++++++++++++++-----------------
 1 file changed, 26 insertions(+), 17 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 6705757..4bec3f4 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3051,26 +3051,35 @@ SYSCALL_DEFINE3(mkdirat, int, dfd, const char __user *, pathname, umode_t, mode)
 	struct dentry *dentry;
 	struct path path;
 	int error;
+	char *name;
+	unsigned int try = 0;
 
-	dentry = user_path_create(dfd, pathname, &path, 1);
-	if (IS_ERR(dentry))
-		return PTR_ERR(dentry);
-
-	if (!IS_POSIXACL(path.dentry->d_inode))
-		mode &= ~current_umask();
-	error = mnt_want_write(path.mnt);
-	if (error)
-		goto out_dput;
-	error = security_path_mkdir(&path, dentry, mode);
-	if (error)
-		goto out_drop_write;
-	error = vfs_mkdir(path.dentry->d_inode, dentry, mode);
+	name = getname(pathname);
+	if (IS_ERR(name))
+		return PTR_ERR(name);
+	do {
+		dentry = kern_path_create(dfd, name, &path, true, try);
+		if (IS_ERR(dentry)) {
+			error = PTR_ERR(dentry);
+			break;
+		}
+		if (!IS_POSIXACL(path.dentry->d_inode))
+			mode &= ~current_umask();
+		error = mnt_want_write(path.mnt);
+		if (error)
+			goto out_dput;
+		error = security_path_mkdir(&path, dentry, mode);
+		if (error)
+			goto out_drop_write;
+		error = vfs_mkdir(path.dentry->d_inode, dentry, mode);
 out_drop_write:
-	mnt_drop_write(path.mnt);
+		mnt_drop_write(path.mnt);
 out_dput:
-	dput(dentry);
-	mutex_unlock(&path.dentry->d_inode->i_mutex);
-	path_put(&path);
+		dput(dentry);
+		mutex_unlock(&path.dentry->d_inode->i_mutex);
+		path_put(&path);
+	} while (retry_estale(error, try++));
+	putname(name);
 	return error;
 }
 
-- 
1.7.11.2


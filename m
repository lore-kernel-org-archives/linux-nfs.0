Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:53756 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757625Ab2DZQ2j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Apr 2012 12:28:39 -0400
Received: by yenl12 with SMTP id l12so1046184yen.19
        for <linux-nfs@vger.kernel.org>; Thu, 26 Apr 2012 09:28:39 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, miklos@szeredi.hu, hch@infradead.org,
        michael.brantley@deshaw.com
Subject: [PATCH v1 06/12] vfs: fix mkdir to retry on ESTALE errors
Date: Thu, 26 Apr 2012 11:57:17 -0400
Message-Id: <1335455843-16089-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1335455843-16089-1-git-send-email-jlayton@redhat.com>
References: <1335455843-16089-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c |   38 +++++++++++++++++++++-----------------
 1 files changed, 21 insertions(+), 17 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 9ee6b4e..e9da40b 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2659,26 +2659,30 @@ SYSCALL_DEFINE3(mkdirat, int, dfd, const char __user *, pathname, umode_t, mode)
 	struct dentry *dentry;
 	struct path path;
 	int error;
+	unsigned int try = 0;
 
-	dentry = user_path_create(dfd, pathname, &path, true, false);
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
+	do {
+		dentry = user_path_create(dfd, pathname, &path, true, try);
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
 	return error;
 }
 
-- 
1.7.7.6

